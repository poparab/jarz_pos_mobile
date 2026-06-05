import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import '../models/shift_monitor_models.dart';

class ShiftMonitorRepository {
  ShiftMonitorRepository(this._dio);

  final Dio _dio;

  Future<ShiftMonitorResponse> fetchShiftMonitor({
    required String fromDate,
    required String toDate,
    String? posProfile,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getPosShiftMonitor,
        queryParameters: {
          'from_date': fromDate,
          'to_date': toDate,
          if (posProfile != null && posProfile.isNotEmpty)
            'pos_profile': posProfile,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );

      final data = response.data is String
          ? json.decode(response.data)
          : response.data;
      final message = data is Map<String, dynamic>
          ? (data['message'] ?? data)
          : data;
      if (message is Map<String, dynamic>) {
        return ShiftMonitorResponse.fromJson(message);
      }
      throw Exception('Unexpected shift monitor response');
    } catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to load shift monitor');
    }
  }
}

final shiftMonitorRepositoryProvider = Provider<ShiftMonitorRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ShiftMonitorRepository(dio);
});
