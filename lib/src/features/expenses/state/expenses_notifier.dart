import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/expenses_repository.dart';
import '../models/expense_models.dart';

class ExpensesState {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final bool initialized;
  final bool isManager;
  final String selectedMonth;
  final List<ExpenseMonthOption> months;
  final List<ExpensePaymentSource> paymentSources;
  final List<ExpenseReason> reasons;
  final List<ExpenseRecord> expenses;
  final ExpenseSummary summary;
  final Set<String> paymentFilters;

  const ExpensesState({
    required this.isLoading,
    required this.isSubmitting,
    required this.error,
    required this.initialized,
    required this.isManager,
    required this.selectedMonth,
    required this.months,
    required this.paymentSources,
    required this.reasons,
    required this.expenses,
    required this.summary,
    required this.paymentFilters,
  });

  factory ExpensesState.initial() => ExpensesState(
        isLoading: false,
        isSubmitting: false,
        error: null,
        initialized: false,
        isManager: false,
        selectedMonth: '',
        months: const [],
        paymentSources: const [],
        reasons: const [],
        expenses: const [],
        summary: const ExpenseSummary(
          totalAmount: 0,
          pendingCount: 0,
          pendingAmount: 0,
          approvedCount: 0,
        ),
        paymentFilters: <String>{},
      );

  ExpensesState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool? clearError,
    bool? initialized,
    bool? isManager,
    String? selectedMonth,
    List<ExpenseMonthOption>? months,
    List<ExpensePaymentSource>? paymentSources,
    List<ExpenseReason>? reasons,
    List<ExpenseRecord>? expenses,
    ExpenseSummary? summary,
    Set<String>? paymentFilters,
  }) {
    return ExpensesState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError == true ? null : error ?? this.error,
      initialized: initialized ?? this.initialized,
      isManager: isManager ?? this.isManager,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      months: months ?? this.months,
      paymentSources: paymentSources ?? this.paymentSources,
      reasons: reasons ?? this.reasons,
      expenses: expenses ?? this.expenses,
      summary: summary ?? this.summary,
      paymentFilters: paymentFilters ?? this.paymentFilters,
    );
  }
}

final expensesNotifierProvider = StateNotifierProvider<ExpensesNotifier, ExpensesState>((ref) {
  final repo = ref.watch(expensesRepositoryProvider);
  return ExpensesNotifier(repo);
});

class ExpensesNotifier extends StateNotifier<ExpensesState> {
  final ExpensesRepository _repository;

  ExpensesNotifier(this._repository) : super(ExpensesState.initial());

  Future<void> load({String? month, Set<String>? paymentFilters}) async {
    final currentFilters = paymentFilters ?? state.paymentFilters;
    final monthCandidate = month ?? state.selectedMonth;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final bootstrap = await _repository.fetchExpenses(
        month: monthCandidate.isNotEmpty ? monthCandidate : null,
        paymentIds: currentFilters.isNotEmpty ? currentFilters.toList() : null,
      );
      final requested = bootstrap.requestedMonth.isNotEmpty
          ? bootstrap.requestedMonth
          : (monthCandidate.isNotEmpty ? monthCandidate : bootstrap.currentMonth);
      final months = bootstrap.months.isNotEmpty ? bootstrap.months : state.months;
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        isManager: bootstrap.isManager,
        selectedMonth: requested,
        months: months,
        paymentSources: bootstrap.paymentSources,
        reasons: bootstrap.reasons,
        expenses: bootstrap.expenses,
        summary: bootstrap.summary,
        paymentFilters: bootstrap.appliedPaymentIds.toSet(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await load(month: state.selectedMonth, paymentFilters: state.paymentFilters);
  }

  Future<void> setMonth(String month) async {
    await load(month: month, paymentFilters: state.paymentFilters);
  }

  Future<void> togglePaymentFilter(String id) async {
    final updated = Set<String>.from(state.paymentFilters);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    await load(month: state.selectedMonth, paymentFilters: updated);
  }

  Future<void> clearFilters() async {
    await load(month: state.selectedMonth, paymentFilters: <String>{});
  }

  Future<ExpenseRecord?> createExpense({
    required double amount,
    required String reasonAccount,
    String? expenseDate,
    String? remarks,
    String? posProfile,
    String? payingAccount,
    String? paymentSourceType,
    String? paymentLabel,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final record = await _repository.createExpense(
        amount: amount,
        reasonAccount: reasonAccount,
        expenseDate: expenseDate,
        remarks: remarks,
        posProfile: posProfile,
        payingAccount: payingAccount,
        paymentSourceType: paymentSourceType,
        paymentLabel: paymentLabel,
      );
      await load(month: state.selectedMonth, paymentFilters: state.paymentFilters);
      state = state.copyWith(isSubmitting: false);
      return record;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }

  Future<ExpenseRecord?> approveExpense(String name) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final updated = await _repository.approveExpense(name);
      final expenses = state.expenses.toList();
      final index = expenses.indexWhere((e) => e.name == name);
      if (index >= 0) {
        expenses[index] = updated;
      }
      final summary = _recalculateSummary(expenses);
      state = state.copyWith(
        isSubmitting: false,
        expenses: expenses,
        summary: summary,
      );
      return updated;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  ExpenseSummary _recalculateSummary(List<ExpenseRecord> expenses) {
    double total = 0;
    double pendingAmount = 0;
    int pendingCount = 0;
    int approvedCount = 0;
    for (final record in expenses) {
      total += record.amount;
      if (record.isPending) {
        pendingCount += 1;
        pendingAmount += record.amount;
      } else if (record.isApproved) {
        approvedCount += 1;
      }
    }
    return ExpenseSummary(
      totalAmount: total,
      pendingCount: pendingCount,
      pendingAmount: pendingAmount,
      approvedCount: approvedCount,
    );
  }
}
