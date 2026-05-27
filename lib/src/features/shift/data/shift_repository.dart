import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/frappe_error_message.dart';
import '../models/shift_models.dart';

class ShiftRepository {
  ShiftRepository(this._dio);

  final Dio _dio;

  Exception _mapApiException(
    Object error, {
    String fallback = 'Request failed',
  }) {
    return mapFrappeError(error, fallback: fallback);
  }

  Future<ShiftEntry?> getActiveShift({String? posProfile}) async {
    final response = await _dio.post(
      ApiEndpoints.getActiveShift,
      data: {
        if (posProfile != null && posProfile.isNotEmpty) 'pos_profile': posProfile,
      },
    );
    final message = response.data is Map ? response.data['message'] : null;
    if (message is Map) {
      return ShiftEntry.fromJson(Map<String, dynamic>.from(message));
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getShiftPaymentMethods(String posProfile) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.getShiftPaymentMethods,
        data: {'pos_profile': posProfile},
      );

      final message = response.data is Map ? response.data['message'] : null;
      if (message is List) {
        return message.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      throw _mapApiException(e);
    }
  }

  Future<String> startShift({
    required String posProfile,
    required List<Map<String, dynamic>> openingBalances,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.startShift,
        data: {
          'pos_profile': posProfile,
          'opening_balances': openingBalances,
        },
      );

      final message = response.data is Map ? response.data['message'] : null;
      if (message is Map && message['opening_entry'] != null) {
        return message['opening_entry'].toString();
      }
      throw Exception('Unexpected start shift response');
    } catch (e) {
      throw _mapApiException(e);
    }
  }

  Future<ShiftSummary> getShiftSummary(String openingEntry) async {
    final response = await _dio.post(
      ApiEndpoints.getShiftSummary,
      data: {'pos_opening_entry': openingEntry},
    );

    final message = response.data is Map ? response.data['message'] : null;
    if (message is Map) {
      return ShiftSummary.fromJson(Map<String, dynamic>.from(message));
    }
    throw Exception('Unexpected shift summary response');
  }

  Future<ShiftSummary> endShift({
    required String openingEntry,
    required List<Map<String, dynamic>> closingBalances,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.endShift,
        data: {
          'pos_opening_entry': openingEntry,
          'closing_balances': closingBalances,
        },
      );

      final message = response.data is Map ? response.data['message'] : null;
      if (message is Map) {
        return ShiftSummary.fromJson(Map<String, dynamic>.from(message));
      }
      throw Exception('Unexpected end shift response');
    } catch (e) {
      throw _mapApiException(e, fallback: 'Failed to close shift');
    }
  }
}

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ShiftRepository(dio);
});
