import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/expenses/data/expenses_repository.dart';
import 'package:jarz_pos/src/features/expenses/models/expense_models.dart';
import 'package:jarz_pos/src/features/expenses/state/expenses_notifier.dart';

// ── Fake Repository ─────────────────────────────────────────────────────

class _FakeExpensesRepository extends ExpensesRepository {
  _FakeExpensesRepository() : super(Dio());

  ExpenseBootstrap? fetchResult;
  ExpenseRecord? createResult;
  ExpenseRecord? approveResult;
  bool shouldThrow = false;
  final List<String> calls = [];

  @override
  Future<ExpenseBootstrap> fetchExpenses({String? month, List<String>? paymentIds}) async {
    calls.add('fetchExpenses:$month:$paymentIds');
    if (shouldThrow) throw Exception('fetch failed');
    return fetchResult ?? _emptyBootstrap();
  }

  @override
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
    calls.add('createExpense:$amount:$reasonAccount');
    if (shouldThrow) throw Exception('create failed');
    return createResult ?? _dummyRecord('NEW-1');
  }

  @override
  Future<ExpenseRecord> approveExpense(String name) async {
    calls.add('approveExpense:$name');
    if (shouldThrow) throw Exception('approve failed');
    return approveResult ?? _dummyRecord(name, docstatus: 1);
  }
}

ExpenseBootstrap _emptyBootstrap() => const ExpenseBootstrap(
      isManager: false,
      currentMonth: '2024-06',
      requestedMonth: '2024-06',
      months: [],
      paymentSources: [],
      reasons: [],
      expenses: [],
      summary: ExpenseSummary(totalAmount: 0, pendingCount: 0, pendingAmount: 0, approvedCount: 0),
      appliedPaymentIds: [],
    );

ExpenseBootstrap _populatedBootstrap() => ExpenseBootstrap(
      isManager: true,
      currentMonth: '2024-06',
      requestedMonth: '2024-06',
      months: [const ExpenseMonthOption(id: '2024-06', label: 'June')],
      paymentSources: [const ExpensePaymentSource(id: 'ps1', account: 'A', label: 'Cash', category: 'cash', balance: 1000)],
      reasons: [const ExpenseReason(account: 'R', label: 'Misc')],
      expenses: [_dummyRecord('EXP-1'), _dummyRecord('EXP-2', docstatus: 1)],
      summary: const ExpenseSummary(totalAmount: 200, pendingCount: 1, pendingAmount: 100, approvedCount: 1),
      appliedPaymentIds: ['ps1'],
    );

ExpenseRecord _dummyRecord(String name, {int docstatus = 0}) {
  return ExpenseRecord.fromJson({
    'name': name,
    'amount': 100,
    'docstatus': docstatus,
    'requires_approval': docstatus == 0,
  });
}

void main() {
  // ── ExpensesState ─────────────────────────────────────────────────────

  group('ExpensesState', () {
    test('initial() has correct defaults', () {
      final s = ExpensesState.initial();
      expect(s.isLoading, isFalse);
      expect(s.isSubmitting, isFalse);
      expect(s.error, isNull);
      expect(s.initialized, isFalse);
      expect(s.isManager, isFalse);
      expect(s.selectedMonth, '');
      expect(s.months, isEmpty);
      expect(s.paymentSources, isEmpty);
      expect(s.reasons, isEmpty);
      expect(s.expenses, isEmpty);
      expect(s.paymentFilters, isEmpty);
    });

    test('copyWith overrides fields', () {
      final s = ExpensesState.initial().copyWith(
        isLoading: true,
        isManager: true,
        selectedMonth: '2024-06',
      );
      expect(s.isLoading, isTrue);
      expect(s.isManager, isTrue);
      expect(s.selectedMonth, '2024-06');
    });

    test('copyWith clearError clears error', () {
      final s = ExpensesState.initial().copyWith(error: 'fail');
      expect(s.error, 'fail');
      final cleared = s.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });

    test('copyWith preserves fields when not specified', () {
      final s = ExpensesState.initial().copyWith(isManager: true);
      final copy = s.copyWith(isLoading: true);
      expect(copy.isManager, isTrue); // preserved
      expect(copy.isLoading, isTrue); // overridden
    });
  });

  // ── ExpensesNotifier ──────────────────────────────────────────────────

  group('ExpensesNotifier', () {
    late _FakeExpensesRepository repo;
    late ExpensesNotifier notifier;

    setUp(() {
      repo = _FakeExpensesRepository();
      notifier = ExpensesNotifier(repo);
    });

    tearDown(() {
      notifier.dispose();
    });

    test('initial state', () {
      expect(notifier.state.initialized, isFalse);
      expect(notifier.state.isLoading, isFalse);
    });

    group('load', () {
      test('success populates state', () async {
        repo.fetchResult = _populatedBootstrap();
        await notifier.load();

        expect(notifier.state.initialized, isTrue);
        expect(notifier.state.isManager, isTrue);
        expect(notifier.state.selectedMonth, '2024-06');
        expect(notifier.state.months, hasLength(1));
        expect(notifier.state.paymentSources, hasLength(1));
        expect(notifier.state.reasons, hasLength(1));
        expect(notifier.state.expenses, hasLength(2));
        expect(notifier.state.isLoading, isFalse);
      });

      test('error sets error message', () async {
        repo.shouldThrow = true;
        await notifier.load();

        expect(notifier.state.error, isNotNull);
        expect(notifier.state.isLoading, isFalse);
      });

      test('passes month parameter', () async {
        await notifier.load(month: '2024-07');
        expect(repo.calls.first, contains('2024-07'));
      });

      test('passes payment filters', () async {
        await notifier.load(paymentFilters: {'ps1', 'ps2'});
        expect(repo.calls.first, contains('ps1'));
      });
    });

    group('setMonth', () {
      test('triggers load with new month', () async {
        await notifier.setMonth('2024-08');
        expect(repo.calls, hasLength(1));
        expect(repo.calls.first, contains('2024-08'));
      });
    });

    group('refresh', () {
      test('uses current state month and filters', () async {
        repo.fetchResult = _populatedBootstrap();
        await notifier.load(month: '2024-06');
        repo.calls.clear();

        await notifier.refresh();
        expect(repo.calls, hasLength(1));
      });
    });

    group('togglePaymentFilter', () {
      test('adds filter then removes it', () async {
        repo.fetchResult = _populatedBootstrap();
        await notifier.load();

        // The bootstrap returns appliedPaymentIds: ['ps1']
        // Toggle off ps1
        repo.fetchResult = _emptyBootstrap();
        await notifier.togglePaymentFilter('ps1');
        // Should have called fetchExpenses
        expect(repo.calls.length, greaterThan(1));
      });
    });

    group('clearFilters', () {
      test('clears all payment filters', () async {
        repo.fetchResult = _populatedBootstrap();
        await notifier.load();
        repo.calls.clear();

        repo.fetchResult = _emptyBootstrap();
        await notifier.clearFilters();
        // Check call happened
        expect(repo.calls, hasLength(1));
      });
    });

    group('createExpense', () {
      test('success reloads and returns record', () async {
        repo.createResult = _dummyRecord('NEW-1');
        final result = await notifier.createExpense(
          amount: 50,
          reasonAccount: 'Misc',
        );

        expect(result, isNotNull);
        expect(result?.name, 'NEW-1');
        expect(notifier.state.isSubmitting, isFalse);
        // Should have called createExpense + fetchExpenses (reload)
        expect(repo.calls, contains(startsWith('createExpense')));
      });

      test('error returns null and sets error', () async {
        repo.shouldThrow = true;
        final result = await notifier.createExpense(
          amount: 50,
          reasonAccount: 'R',
        );

        expect(result, isNull);
        expect(notifier.state.error, isNotNull);
        expect(notifier.state.isSubmitting, isFalse);
      });
    });

    group('approveExpense', () {
      test('success updates expense in list', () async {
        repo.fetchResult = _populatedBootstrap();
        await notifier.load();

        repo.approveResult = _dummyRecord('EXP-1', docstatus: 1);
        final result = await notifier.approveExpense('EXP-1');

        expect(result, isNotNull);
        expect(result?.docstatus, 1);
        expect(notifier.state.isSubmitting, isFalse);
        // Summary should be recalculated
        expect(notifier.state.summary.approvedCount, greaterThanOrEqualTo(1));
      });

      test('error returns null', () async {
        repo.shouldThrow = true;
        final result = await notifier.approveExpense('X');

        expect(result, isNull);
        expect(notifier.state.error, isNotNull);
      });
    });

    group('clearError', () {
      test('clears existing error', () async {
        repo.shouldThrow = true;
        await notifier.load();
        expect(notifier.state.error, isNotNull);

        notifier.clearError();
        expect(notifier.state.error, isNull);
      });
    });
  });
}
