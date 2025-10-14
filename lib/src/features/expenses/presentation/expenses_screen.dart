import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/app_drawer.dart';
import '../models/expense_models.dart';
import '../state/expenses_notifier.dart';
import 'widgets/expense_card.dart';
import 'widgets/expense_filters_bar.dart';
import 'widgets/expense_form_sheet.dart';
import 'widgets/expenses_summary_header.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expensesNotifierProvider.notifier).load();
    });
    ref.listen<ExpensesState>(expensesNotifierProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
        ref.read(expensesNotifierProvider.notifier).clearError();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expensesNotifierProvider);
    final notifier = ref.read(expensesNotifierProvider.notifier);

    final isBusy = state.isLoading && !state.initialized;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: state.isLoading ? null : () => notifier.refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isSubmitting
            ? null
            : () async {
                final record = await showModalBottomSheet<ExpenseRecord?>(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => ExpenseFormSheet(
                    isManager: state.isManager,
                    reasons: state.reasons,
                    paymentSources: state.paymentSources,
                  ),
                );
                if (record != null && mounted) {
                  final label = record.isApproved ? 'Expense recorded' : 'Expense submitted for approval';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(label)),
                  );
                }
              },
        icon: const Icon(Icons.add),
        label: const Text('New Expense'),
      ),
      body: SafeArea(
        child: isBusy
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(// allow pull-to-refresh
                onRefresh: notifier.refresh,
                child: ListView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 120,
                  ),
                  children: [
                    _MonthSelector(
                      months: state.months,
                      selectedMonth: state.selectedMonth,
                      onChanged: (value) => notifier.setMonth(value),
                    ),
                    const SizedBox(height: 12),
                    ExpenseFiltersBar(
                      paymentSources: state.paymentSources,
                      activeFilters: state.paymentFilters,
                      onToggle: notifier.togglePaymentFilter,
                      onClear: state.paymentFilters.isEmpty ? null : notifier.clearFilters,
                    ),
                    const SizedBox(height: 12),
                    ExpensesSummaryHeader(summary: state.summary, isManager: state.isManager),
                    const SizedBox(height: 16),
                    if (state.expenses.isEmpty)
                      _EmptyState(isManager: state.isManager)
                    else
                      ...state.expenses.map((expense) => ExpenseCard(
                            expense: expense,
                            canApprove: state.isManager && expense.isPending && !state.isSubmitting,
                            onApprove: () => notifier.approveExpense(expense.name),
                          )),
                  ],
                ),
              ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final List<ExpenseMonthOption> months;
  final String selectedMonth;
  final ValueChanged<String> onChanged;

  const _MonthSelector({
    required this.months,
    required this.selectedMonth,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMonths = months.isEmpty
        ? [
            ExpenseMonthOption(
              id: selectedMonth,
              label: selectedMonth.isEmpty
                  ? 'Current Month'
                  : DateFormat('MMMM yyyy').format(DateTime.tryParse('${selectedMonth}-01') ?? DateTime.now()),
            )
          ]
        : months;

    return Row(
      children: [
        Text(
          'Month',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: effectiveMonths.any((m) => m.id == selectedMonth) ? selectedMonth : effectiveMonths.first.id,
            items: effectiveMonths
                .map((m) => DropdownMenuItem<String>(
                      value: m.id,
                      child: Text(m.label),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isManager;
  const _EmptyState({required this.isManager});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No expenses recorded for this month.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            isManager
                ? 'Create a new expense to capture operational spending.'
                : 'Submit a new expense and your manager will review it.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
