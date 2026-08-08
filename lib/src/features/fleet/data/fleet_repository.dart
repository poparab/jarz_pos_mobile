import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import 'models/fleet_models.dart';

final fleetRepositoryProvider = Provider<FleetRepository>((ref) {
  return FleetRepository(ref.watch(dioProvider));
});

/// The signed-in user is not a supervisor.
///
/// Kept as its own type because it is the one failure retrying can never fix:
/// `_ensure_ops_permission` deliberately excludes couriers, so a courier
/// hitting this screen must be told *why* instead of watching a spinner retry
/// forever.
class FleetPermissionDeniedException implements Exception {
  const FleetPermissionDeniedException();

  @override
  String toString() => 'FleetPermissionDeniedException';
}

/// The response arrived but was not the documented envelope.
class FleetMalformedResponseException implements Exception {
  const FleetMalformedResponseException(this.detail);

  final String detail;

  @override
  String toString() => 'FleetMalformedResponseException: $detail';
}

/// Reads live courier positions from `jarz_courier.api.tracking`.
///
/// The endpoint is Redis-only and explicitly safe to poll.
class FleetRepository {
  FleetRepository(this._dio);

  final Dio _dio;

  /// Fetches every courier position the caller is allowed to see.
  ///
  /// [branch] is the endpoint's own optional scope. Leaving it null does **not**
  /// mean "everything": the backend still scopes the answer to the caller, and
  /// an empty scope yields nothing rather than the whole fleet. Callers must
  /// never react to an empty result by retrying unscoped.
  Future<FleetSnapshot> getLivePositions({String? branch}) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post(
        ApiEndpoints.getLiveCourierPositions,
        data: {
          if (branch != null && branch.trim().isNotEmpty) 'branch': branch.trim(),
        },
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 403) {
        throw const FleetPermissionDeniedException();
      }
      rethrow;
    }

    final payload = _unwrap(response.data);
    if (payload is! Map) {
      throw const FleetMalformedResponseException('expected a JSON object');
    }

    final map = Map<String, dynamic>.from(payload);
    if (map['success'] == false) {
      throw FleetMalformedResponseException(
        (map['error'] ?? map['message'] ?? 'request rejected').toString(),
      );
    }

    return FleetSnapshot.fromJson(map, fetchedAt: DateTime.now());
  }

  /// Unwraps Frappe's `{ "message": ... }` envelope.
  dynamic _unwrap(dynamic data) {
    if (data is Map && data.containsKey('message')) return data['message'];
    return data;
  }
}
