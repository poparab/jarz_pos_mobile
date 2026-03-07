import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/timing_config.dart';
import '../session/session_manager.dart';
import 'cookie_manager.dart';
import '../offline/offline_queue.dart';

class SessionInterceptor extends Interceptor {
  SessionInterceptor(this._sessionManager, this._offlineQueue, this._frappeSite);

  final SessionManager _sessionManager;
  final OfflineQueue _offlineQueue;
  final String _frappeSite;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add session cookies
    await CookieManager.attachCookiesToRequest(options);
    
    // Also use session manager for backward compatibility
    final sessionId = await _sessionManager.getSessionId();
    if (sessionId != null) {
      options.headers['Cookie'] = 'sid=$sessionId';
    }
    
    // Ensure Frappe site routing for multi-tenant backend
    if (_frappeSite.isNotEmpty) {
      options.headers['X-Frappe-Site-Name'] = _frappeSite;
      // Note: Don't set Host header - let it be the actual domain name
      // Setting Host to site name breaks HTTPS/domain-based routing
    }
    
    if (kDebugMode) {
      print('📤 API Request: ${options.method} ${options.path}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
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
    
    // Clear session on 401 Unauthorized
    if (err.response?.statusCode == 401) {
      await _sessionManager.clearSession();
      await CookieManager.clearCookies();
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
