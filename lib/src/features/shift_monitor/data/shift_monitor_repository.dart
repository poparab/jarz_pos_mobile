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

  Future<ForceClosePreview> fetchForceClosePreview(String openingEntry) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.getForceCloseShiftPreview,
        data: {'pos_opening_entry': openingEntry},
      );
      final message = _unwrap(response.data);
      if (message is Map<String, dynamic>) {
        return ForceClosePreview.fromJson(message);
      }
      throw Exception('Unexpected force-close preview response');
    } catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to load shift details');
    }
  }

  /// Close a shift opened by someone else.
  ///
  /// [closingAmounts] is keyed by mode of payment — the manager's physical
  /// count, which takes the same accounting path as a normal close, so a real
  /// difference still books a Cash Over/Short entry.
  Future<Map<String, dynamic>> forceCloseShift({
    required String openingEntry,
    required Map<String, double> closingAmounts,
    required String reason,
    bool acknowledgeUnsettled = false,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.forceCloseShift,
        data: {
          'pos_opening_entry': openingEntry,
          'reason': reason,
          'acknowledge_unsettled': acknowledgeUnsettled ? 1 : 0,
          'closing_balances': closingAmounts.entries
              .map(
                (e) => {
                  'mode_of_payment': e.key,
                  'closing_amount': e.value,
                },
              )
              .toList(),
        },
      );
      final message = _unwrap(response.data);
      return message is Map<String, dynamic>
          ? message
          : <String, dynamic>{'closed': true};
    } catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to close shift');
    }
  }

  Object? _unwrap(Object? raw) {
    final data = raw is String ? json.decode(raw) : raw;
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data;
    }
    return data;
  }
}

final shiftMonitorRepositoryProvider = Provider<ShiftMonitorRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ShiftMonitorRepository(dio);
});
