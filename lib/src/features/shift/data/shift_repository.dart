import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../models/shift_models.dart';

class ShiftRepository {
  ShiftRepository(this._dio);

  final Dio _dio;

  Exception _mapApiException(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['message']?.toString();
        final exception = data['exception']?.toString();
        final serverMessages = data['_server_messages']?.toString();
        if (message != null && message.isNotEmpty) {
          return Exception(message);
        }
        if (exception != null && exception.isNotEmpty) {
          return Exception(exception);
        }
        if (serverMessages != null && serverMessages.isNotEmpty) {
          return Exception(serverMessages);
        }
      }
    }
    return Exception(error.toString());
  }

  Future<ShiftEntry?> getActiveShift() async {
    final response = await _dio.post('/api/method/jarz_pos.api.shift.get_active_shift', data: {});
    final message = response.data is Map ? response.data['message'] : null;
    if (message is Map) {
      return ShiftEntry.fromJson(Map<String, dynamic>.from(message));
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getShiftPaymentMethods(String posProfile) async {
    try {
      final response = await _dio.post(
        '/api/method/jarz_pos.api.shift.get_shift_payment_methods',
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
        '/api/method/jarz_pos.api.shift.start_shift',
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
      '/api/method/jarz_pos.api.shift.get_shift_summary',
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
    final response = await _dio.post(
      '/api/method/jarz_pos.api.shift.end_shift',
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
  }
}

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ShiftRepository(dio);
});
