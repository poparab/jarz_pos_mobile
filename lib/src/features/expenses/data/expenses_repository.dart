import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
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
      '/api/method/jarz_pos.api.expenses.get_expense_bootstrap',
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
      '/api/method/jarz_pos.api.expenses.create_expense',
      data: body,
    );
    final data = response.data is Map ? response.data['message'] ?? response.data : response.data;
    final expenseJson = Map<String, dynamic>.from(data['expense'] as Map);
    return ExpenseRecord.fromJson(expenseJson);
  }

  Future<ExpenseRecord> approveExpense(String name) async {
    final response = await _dio.post(
      '/api/method/jarz_pos.api.expenses.approve_expense',
      data: {'name': name},
    );
    final data = response.data is Map ? response.data['message'] ?? response.data : response.data;
    final expenseJson = Map<String, dynamic>.from(data['expense'] as Map);
    return ExpenseRecord.fromJson(expenseJson);
  }
}
