import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'
  show debugPrint, kDebugMode, kIsWeb, visibleForTesting;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/timing_config.dart';
import '../env/app_build_identity.dart';
import '../monitoring/sentry_service.dart';
import '../session/session_manager.dart';
import 'app_upgrade_signal.dart';
import 'cookie_manager.dart';
import '../offline/offline_queue.dart';

/// Headers the server's release gate reads. Every request carries them so a
/// build below the floor is refused even if it never ran the version check.
const kBuildHeader = 'X-Jarz-Build';
const kPlatformHeader = 'X-Jarz-Platform';

/// HTTP 426. Distinct from 401 (which would log the user out) and 403 (which
/// reads as a permission bug).
const kUpgradeRequiredStatus = 426;

class SessionInterceptor extends Interceptor {
  SessionInterceptor(
    this._sessionManager,
    this._offlineQueue,
    this._frappeSite, {
    bool? isWebOverride,
  }) : _isWeb = isWebOverride ?? kIsWeb;

  final SessionManager _sessionManager;
  final OfflineQueue _offlineQueue;
  final String _frappeSite;
  final bool _isWeb;

  /// Resolved once and reused. PackageInfo hits a platform channel, and this
  /// runs on every single request.
  Future<AppBuildIdentity>? _buildIdentity;

  Future<AppBuildIdentity> _resolveBuildIdentity() {
    return _buildIdentity ??= loadAppBuildIdentity();
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // On web, browsers manage cookies automatically for same-origin requests.
    // Manually setting Cookie headers is blocked by browsers and causes issues.
    if (!_isWeb) {
      // Add session cookies
      await CookieManager.attachCookiesToRequest(options);
      
      // Also use session manager for backward compatibility
      final sessionId = await _sessionManager.getSessionId();
      if (sessionId != null) {
        options.headers['Cookie'] = 'sid=$sessionId';
      }
    }
    
    // Ensure Frappe site routing for multi-tenant backend
    if (_frappeSite.isNotEmpty) {
      options.headers['X-Frappe-Site-Name'] = _frappeSite;
      // Note: Don't set Host header - let it be the actual domain name
      // Setting Host to site name breaks HTTPS/domain-based routing
    }
    
    // Identify the build to the server's release gate. Wrapped because a
    // platform-channel failure must cost us the header, not the request.
    try {
      final identity = await _resolveBuildIdentity();
      if (identity.buildNumber != null) {
        options.headers[kBuildHeader] = '${identity.buildNumber}';
        options.headers[kPlatformHeader] = identity.platform;
      }
    } catch (_) {
      // No header: the server treats an unidentified client as ungated.
    }

    if (kDebugMode) {
      print('📤 API Request: ${options.method} ${options.path}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // On web, browsers manage cookies automatically. The set-cookie header
    // is hidden from JavaScript by the browser for security.
    if (!_isWeb) {
      // Save cookies using new cookie manager
      await CookieManager.saveCookies(response);
      
      // Also extract session cookie for session manager (backward compatibility)
      final setCookieHeader = response.headers['set-cookie'];
      if (setCookieHeader != null) {
        for (final cookie in setCookieHeader) {
          if (cookie.startsWith('sid=')) {
            final sessionId = cookie.split(';')[0].split('=')[1];
            await _sessionManager.saveSessionId(sessionId);
            break;
          }
        }
      }
    }
    
    if (kDebugMode) {
      print('📥 API Response: ${response.statusCode} ${response.requestOptions.path}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      print('❌ API Error: ${err.response?.statusCode} ${err.requestOptions.path} - ${err.message}');
    }
    
    // 426 Upgrade Required: the server refuses this build outright. Raise the
    // gate rather than letting the call sites surface it as a random failure.
    if (err.response?.statusCode == kUpgradeRequiredStatus) {
      AppUpgradeSignal.instance.report(
        readUpgradeRefusal(err.response?.data),
      );
    }

    // Clear session on 401 Unauthorized
    if (err.response?.statusCode == 401) {
      await clearStoredSessionAfterUnauthorized(
        isWeb: _isWeb,
        sessionManager: _sessionManager,
        clearCookies: CookieManager.clearCookies,
      );
    }
    
    // Add to offline queue if network error and it's a modifying request
    if (err.type == DioExceptionType.connectionError || 
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      
      if (err.requestOptions.method.toUpperCase() == 'POST' && 
          err.requestOptions.path.contains('create')) {
        
        await _offlineQueue.addTransaction({
          'endpoint': err.requestOptions.path,
          'method': err.requestOptions.method,
          'data': err.requestOptions.data,
          'headers': err.requestOptions.headers,
        });
        
        if (kDebugMode) {
          print('🔄 OFFLINE: Added failed request to queue');
        }
      }
    }
    
    handler.next(err);
  }
}

/// Pulls the refusal details out of a 426 body.
///
/// Frappe puts the fields at the top level of the error response, but an
/// upstream proxy can replace the body with HTML, so every field falls back to
/// a harmless default rather than assuming the shape.
@visibleForTesting
AppUpgradeRefusal readUpgradeRefusal(Object? body) {
  final map = body is Map ? body : const <String, dynamic>{};
  final minimum = map['minimum_build'];
  return AppUpgradeRefusal(
    minimumBuild: minimum is int
        ? minimum
        : int.tryParse('${minimum ?? ''}'.trim()) ?? 0,
    downloadUrl: '${map['download_url'] ?? ''}'.trim(),
    message: '${map['message'] ?? ''}'.trim(),
  );
}

@visibleForTesting
Future<void> clearStoredSessionAfterUnauthorized({
  required bool isWeb,
  required SessionManager sessionManager,
  required Future<void> Function() clearCookies,
}) async {
  if (isWeb) {
    return;
  }

  await sessionManager.clearSession();
  await clearCookies();
}

final dioProvider = Provider<Dio>((ref) {
  final sessionManager = ref.watch(sessionManagerProvider);
  final offlineQueue = ref.watch(offlineQueueProvider);
  final baseUrl = dotenv.get('ERP_BASE_URL');
  final frappeSite = dotenv.get('FRAPPE_SITE', fallback: '');

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: NetworkTimeouts.httpConnect,
      receiveTimeout: NetworkTimeouts.httpReceive,
      sendTimeout: NetworkTimeouts.httpSend,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Record every request/response/error as a Sentry breadcrumb. Without this,
  // events raised from this Dio instance (which serves most of the app) arrive
  // with no trace of which endpoint failed or what it returned.
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        SentryService.instance.addHttpBreadcrumb(
          method: options.method,
          path: options.path,
          category: 'http.request',
        );
        handler.next(options);
      },
      onResponse: (response, handler) {
        SentryService.instance.addHttpBreadcrumb(
          method: response.requestOptions.method,
          path: response.requestOptions.path,
          statusCode: response.statusCode,
          category: 'http.response',
        );
        handler.next(response);
      },
      onError: (error, handler) {
        SentryService.instance.addHttpBreadcrumb(
          method: error.requestOptions.method,
          path: error.requestOptions.path,
          statusCode: error.response?.statusCode,
          category: 'http.error',
          failed: true,
        );
        handler.next(error);
      },
    ),
  );

  // Add enhanced session interceptor with offline support
  dio.interceptors.add(SessionInterceptor(sessionManager, offlineQueue, frappeSite));

  // Add logging interceptor for debugging
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
  logPrint: (object) => debugPrint('🌐 HTTP: $object'),
    ));
  }

  return dio;
});
