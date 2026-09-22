import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../models/pending_approvals.dart';

final pendingApprovalsRepositoryProvider = Provider<PendingApprovalsRepository>(
  (ref) {
    return PendingApprovalsRepository(ref.watch(dioProvider));
  },
);

class PendingApprovalsRepository {
  final Dio _dio;
  PendingApprovalsRepository(this._dio);

  Future<PendingApprovals> fetch() async {
    final response = await _dio.post(
      ApiEndpoints.getPendingApprovals,
      data: {},
    );
    final payload = response.data;
    // Frappe wraps whitelisted return values in a `message` envelope, but not
    // always — unwrap defensively rather than assuming either shape.
    final body = payload is Map && payload['message'] is Map
        ? payload['message']
        : payload;
    if (body is! Map) {
      throw Exception('Unexpected response shape: ${body.runtimeType}');
    }
    return PendingApprovals.fromJson(Map<String, dynamic>.from(body));
  }
}
