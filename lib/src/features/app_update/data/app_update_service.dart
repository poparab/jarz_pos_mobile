import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';

/// The server's verdict on this build.
@immutable
class AppUpdateRequirement {
  const AppUpdateRequirement({
    required this.updateRequired,
    required this.updateAvailable,
    required this.minimumBuild,
    required this.latestBuild,
    required this.downloadUrl,
    required this.message,
  });

  /// The safe answer for every failure path: an unreachable or misbehaving
  /// server must not be able to lock the POS out of its own tills.
  static const none = AppUpdateRequirement(
    updateRequired: false,
    updateAvailable: false,
    minimumBuild: 0,
    latestBuild: 0,
    downloadUrl: '',
    message: '',
  );

  final bool updateRequired;
  final bool updateAvailable;
  final int minimumBuild;
  final int latestBuild;
  final String downloadUrl;
  final String message;

  AppUpdateRequirement copyWith({bool? updateRequired}) {
    return AppUpdateRequirement(
      updateRequired: updateRequired ?? this.updateRequired,
      updateAvailable: updateAvailable,
      minimumBuild: minimumBuild,
      latestBuild: latestBuild,
      downloadUrl: downloadUrl,
      message: message,
    );
  }

  static AppUpdateRequirement fromJson(Map<String, dynamic> json) {
    return AppUpdateRequirement(
      updateRequired: json['update_required'] == true,
      updateAvailable: json['update_available'] == true,
      minimumBuild: _asInt(json['minimum_build']),
      latestBuild: _asInt(json['latest_build']),
      downloadUrl: (json['download_url'] as String?)?.trim() ?? '',
      message: (json['message'] as String?)?.trim() ?? '',
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}'.trim()) ?? 0;
  }
}

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService(ref.watch(dioProvider));
});

class AppUpdateService {
  AppUpdateService(this._dio);

  final Dio _dio;

  /// Asks the server whether [buildNumber] on [platform] may still run.
  ///
  /// Never throws. Every error - offline, 500, a proxy returning HTML - maps
  /// to [AppUpdateRequirement.none], because a failed check must degrade to
  /// "carry on", never to "you are locked out". The server-side `before_request`
  /// gate is what stops a genuinely stale build that got a soft answer here.
  Future<AppUpdateRequirement> fetchRequirement({
    required String platform,
    required int? buildNumber,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.getAppRequirement,
        queryParameters: <String, dynamic>{
          'platform': platform,
          if (buildNumber != null) 'build_number': '$buildNumber',
        },
      );

      final body = response.data;
      if (body is! Map) {
        return AppUpdateRequirement.none;
      }
      // Frappe wraps whitelisted return values in `message`.
      final payload = body['message'];
      if (payload is! Map) {
        return AppUpdateRequirement.none;
      }
      return AppUpdateRequirement.fromJson(
        Map<String, dynamic>.from(payload),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('App update check failed (ignored): $error');
      }
      return AppUpdateRequirement.none;
    }
  }
}
