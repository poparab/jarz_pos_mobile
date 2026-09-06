import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import '../models/monthly_expense_models.dart';

final monthlyExpensesRepositoryProvider =
    Provider<MonthlyExpensesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MonthlyExpensesRepository(dio);
});

/// The server refused a payment because it would push the period's paid total
/// past what is due.
///
/// Modelled as its own exception rather than a plain failure because it is not
/// a failure: it is a question. The backend states by how much the payment
/// overshoots, and the same call succeeds with `allow_overpay=1`, so the UI has
/// to be able to tell this apart from "the payment did not work" and offer the
/// retry instead of a red snackbar.
class MonthlyExpenseOverpayException implements Exception {
  /// The server's own sentence, which carries the amount of the overshoot.
  final String message;

  const MonthlyExpenseOverpayException(this.message);

  @override
  String toString() => message;
}

/// Recognises the overpay refusal in whatever the server said.
///
/// The contract froze the *behaviour* ("reject ... unless `allow_overpay=1` is
/// passed, and say by how much") but not the wording, so this matches on the
/// stable parts: the flag name, which appears in the hint the backend gives,
/// and the word "overpay" in either language's stem. Anything else stays a
/// normal error — offering "pay anyway" on an unrelated failure would be worse
/// than not offering it at all.
bool looksLikeOverpayRefusal(String message) {
  final text = message.toLowerCase();
  return text.contains('allow_overpay') ||
      text.contains('overpay') ||
      text.contains('over-pay') ||
      text.contains('دفع زائد') ||
      text.contains('أكثر من المستحق');
}

class MonthlyExpensesRepository {
  final Dio _dio;
  MonthlyExpensesRepository(this._dio);

  /// The company's bill for one `YYYY-MM` period. `month` null means the
  /// server's current month.
  Future<MonthlyExpensesPayload> fetchMonth({String? month, String? company}) async {
    final response = await _dio.post(
      ApiEndpoints.getMonthlyExpenses,
      data: {
        if (month != null && month.isNotEmpty) 'month': month,
        if (company != null && company.isNotEmpty) 'company': company,
      },
    );
    return MonthlyExpensesPayload.fromJson(_unwrap(response));
  }

  /// Pay a period of a registry item. Returns the whole recomputed month rather
  /// than the single row the server echoes: paying one item moves the summary,
  /// the category total and — when the item shares an expense account — the
  /// `inferred` flag on its neighbours, so patching one row in place would leave
  /// four numbers on screen disagreeing with the fifth.
  Future<void> payRecurringExpense({
    required String recurringExpense,
    required String month,
    required double amount,
    required String payingAccount,
    String? paymentDate,
    String? remarks,
    bool allowOverpay = false,
  }) async {
    await _post(ApiEndpoints.payRecurringExpense, {
      'recurring_expense': recurringExpense,
      'month': month,
      'amount': amount,
      'paying_account': payingAccount,
      if (paymentDate != null && paymentDate.isNotEmpty)
        'payment_date': paymentDate,
      if (remarks != null && remarks.trim().isNotEmpty)
        'remarks': remarks.trim(),
      'allow_overpay': allowOverpay ? 1 : 0,
    });
  }

  Future<void> paySalary({
    required String employee,
    required String month,
    required double amount,
    required String payingAccount,
    String? paymentDate,
    String? remarks,
    bool allowOverpay = false,
  }) async {
    await _post(ApiEndpoints.paySalary, {
      'employee': employee,
      'month': month,
      'amount': amount,
      'paying_account': payingAccount,
      if (paymentDate != null && paymentDate.isNotEmpty)
        'payment_date': paymentDate,
      if (remarks != null && remarks.trim().isNotEmpty)
        'remarks': remarks.trim(),
      'allow_overpay': allowOverpay ? 1 : 0,
    });
  }

  /// Create (no `name`) or update (with `name`) a registry entry.
  Future<void> saveRecurringExpense(RecurringExpenseDraft draft) async {
    await _post(ApiEndpoints.saveRecurringExpense, {'payload': draft.toJson()});
  }

  /// `Active` / `Paused` / `Ended`.
  Future<void> setRecurringExpenseStatus({
    required String name,
    required String status,
  }) async {
    await _post(ApiEndpoints.setRecurringExpenseStatus, {
      'name': name,
      'status': status,
    });
  }

  /// Reverse a payment. The reason is mandatory server-side — the endpoint
  /// delegates to `expenses.cancel_expense`, which cancels the journal entry
  /// the payment posted.
  Future<void> cancelExpensePayment({
    required String name,
    required String reason,
  }) async {
    await _post(ApiEndpoints.cancelExpensePayment, {
      'name': name,
      'reason': reason,
    });
  }

  /// Every mutation goes through here so the overpay question is recognised in
  /// exactly one place, and every other failure is turned into the same
  /// readable exception the rest of the app raises.
  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post(endpoint, data: body);
      return _unwrap(response);
    } catch (error) {
      final message = extractFrappeErrorMessage(error);
      if (looksLikeOverpayRefusal(message)) {
        throw MonthlyExpenseOverpayException(message);
      }
      throw mapFrappeError(error);
    }
  }

  Map<String, dynamic> _unwrap(Response<dynamic> response) {
    final data = response.data;
    final payload = data is Map ? (data['message'] ?? data) : data;
    if (payload is Map) return Map<String, dynamic>.from(payload);
    return <String, dynamic>{};
  }
}
