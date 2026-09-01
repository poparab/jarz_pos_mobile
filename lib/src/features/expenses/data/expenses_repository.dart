import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/expense_models.dart';

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ExpensesRepository(dio);
});

class ExpensesRepository {
  final Dio _dio;
  ExpensesRepository(this._dio);

  Future<ExpenseBootstrap> fetchExpenses({String? month, List<String>? paymentIds}) async {
    final filters = <String, dynamic>{};
    if (month != null && month.isNotEmpty) {
      filters['month'] = month;
    }
    if (paymentIds != null && paymentIds.isNotEmpty) {
      filters['payment_ids'] = paymentIds;
    }
    final response = await _dio.post(
      ApiEndpoints.getExpenseBootstrap,
      data: {'filters': jsonEncode(filters)},
    );
    final data = response.data is Map ? response.data['message'] ?? response.data : response.data;
    final payload = Map<String, dynamic>.from(data as Map);
    return ExpenseBootstrap.fromJson(payload);
  }

  Future<ExpenseRecord> createExpense({
    required double amount,
    required String reasonAccount,
    String? expenseDate,
    String? remarks,
    String? posProfile,
    String? payingAccount,
    String? paymentSourceType,
    String? paymentLabel,
  }) async {
    final body = {
      'amount': amount,
      'reason_account': reasonAccount,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (remarks != null && remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
      if (posProfile != null) 'pos_profile': posProfile,
      if (payingAccount != null) 'paying_account': payingAccount,
      if (paymentSourceType != null) 'payment_source_type': paymentSourceType,
      if (paymentLabel != null) 'payment_label': paymentLabel,
    };

    final response = await _dio.post(
      ApiEndpoints.createExpense,
      data: body,
    );
    final data = response.data is Map ? response.data['message'] ?? response.data : response.data;
    final expenseJson = Map<String, dynamic>.from(data['expense'] as Map);
    return ExpenseRecord.fromJson(expenseJson);
  }

  Future<ExpenseRecord> approveExpense(String name) async {
    return _decide(ApiEndpoints.approveExpense, {'name': name});
  }

  /// Turn down a request that has not been approved. Leaves it a draft with the
  /// reason attached, so the person who filed it finds out why.
  Future<ExpenseRecord> rejectExpense(String name, String reason) async {
    return _decide(ApiEndpoints.rejectExpense, {'name': name, 'reason': reason});
  }

  /// Reverse a request that was already approved. The server cancels the
  /// journal entry the approval posted; a failure to do so fails the call
  /// rather than leaving a cancelled request next to a live expense entry.
  Future<ExpenseRecord> cancelExpense(String name, String reason) async {
    return _decide(ApiEndpoints.cancelExpense, {'name': name, 'reason': reason});
  }

  /// The three decision endpoints return the same `{expense: {...}}` envelope,
  /// so the unwrapping lives here once instead of three times.
  Future<ExpenseRecord> _decide(String endpoint, Map<String, dynamic> body) async {
    final response = await _dio.post(endpoint, data: body);
    final data = response.data is Map ? response.data['message'] ?? response.data : response.data;
    final expenseJson = Map<String, dynamic>.from(data['expense'] as Map);
    return ExpenseRecord.fromJson(expenseJson);
  }
}
