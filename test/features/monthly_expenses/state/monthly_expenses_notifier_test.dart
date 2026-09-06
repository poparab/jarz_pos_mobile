import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/monthly_expenses/data/monthly_expenses_repository.dart';
import 'package:jarz_pos/src/features/monthly_expenses/models/monthly_expense_models.dart';
import 'package:jarz_pos/src/features/monthly_expenses/state/monthly_expenses_notifier.dart';

class _FakeRepository extends MonthlyExpensesRepository {
  _FakeRepository() : super(Dio());

  final List<String> calls = [];
  MonthlyExpensesPayload payload = const MonthlyExpensesPayload();
  Object? throwOnMutate;
  bool throwOnFetch = false;

  /// Payments that were accepted, so a test can assert the retry actually
  /// carried `allow_overpay`.
  final List<bool> allowOverpayFlags = [];

  @override
  Future<MonthlyExpensesPayload> fetchMonth({String? month, String? company}) async {
    calls.add('fetch:$month');
    if (throwOnFetch) throw Exception('fetch failed');
    return payload;
  }

  @override
  Future<void> payRecurringExpense({
    required String recurringExpense,
    required String month,
    required double amount,
    required String payingAccount,
    String? paymentDate,
    String? remarks,
    bool allowOverpay = false,
  }) async {
    calls.add('pay:$recurringExpense:$month:$amount:$allowOverpay');
    allowOverpayFlags.add(allowOverpay);
    _maybeThrow(allowOverpay);
  }

  @override
  Future<void> paySalary({
    required String employee,
    required String month,
    required double amount,
    required String payingAccount,
    String? paymentDate,
    String? remarks,
    bool allowOverpay = false,
  }) async {
    calls.add('paySalary:$employee:$month:$amount:$allowOverpay');
    allowOverpayFlags.add(allowOverpay);
    _maybeThrow(allowOverpay);
  }

  @override
  Future<void> saveRecurringExpense(RecurringExpenseDraft draft) async {
    calls.add('save:${draft.name ?? "<new>"}');
    _maybeThrow(false);
  }

  @override
  Future<void> setRecurringExpenseStatus({
    required String name,
    required String status,
  }) async {
    calls.add('status:$name:$status');
    _maybeThrow(false);
  }

  @override
  Future<void> cancelExpensePayment({
    required String name,
    required String reason,
  }) async {
    calls.add('cancel:$name:$reason');
    _maybeThrow(false);
  }

  /// The overpay refusal only fires when the caller did NOT ask for it, which
  /// is exactly how the server behaves.
  void _maybeThrow(bool allowOverpay) {
    final error = throwOnMutate;
    if (error == null) return;
    if (allowOverpay && error is MonthlyExpenseOverpayException) return;
    throw error;
  }
}

MonthlyExpensesPayload _payload({
  String month = '2026-09',
  List<String> months = const ['2026-07', '2026-08', '2026-09'],
}) {
  return MonthlyExpensesPayload(
    month: month,
    monthLabel: month,
    currency: 'EGP',
    availableMonths:
        months.map((m) => MonthlyExpenseMonthOption(id: m)).toList(),
    summary: const MonthlyExpenseSummary(due: 155000, paid: 47000, remaining: 108000),
    canManage: true,
  );
}

void main() {
  group('MonthlyExpensesState', () {
    test('initial() is empty and not yet loaded', () {
      final state = MonthlyExpensesState.initial();
      expect(state.isLoading, isFalse);
      expect(state.initialized, isFalse);
      expect(state.selectedMonth, '');
      expect(state.payload.recurring, isEmpty);
      expect(state.monthIndex, -1);
      expect(state.hasPreviousMonth, isFalse);
      expect(state.hasNextMonth, isFalse);
    });

    test('walks available_months, which is ordered newest last', () {
      final state = MonthlyExpensesState.initial()
          .copyWith(selectedMonth: '2026-08', payload: _payload());

      expect(state.monthIndex, 1);
      expect(state.previousMonth, '2026-07');
      expect(state.nextMonth, '2026-09');
      expect(state.hasPreviousMonth, isTrue);
      expect(state.hasNextMonth, isTrue);
    });

    test('the ends of the window have no step beyond them', () {
      final oldest = MonthlyExpensesState.initial()
          .copyWith(selectedMonth: '2026-07', payload: _payload());
      final newest = MonthlyExpensesState.initial()
          .copyWith(selectedMonth: '2026-09', payload: _payload());

      expect(oldest.hasPreviousMonth, isFalse);
      expect(oldest.previousMonth, isNull);
      expect(newest.hasNextMonth, isFalse);
      expect(newest.nextMonth, isNull);
    });

    test('clearError wipes the error rather than carrying it forward', () {
      final state =
          MonthlyExpensesState.initial().copyWith(error: 'boom');
      expect(state.copyWith(clearError: true).error, isNull);
    });
  });

  group('load', () {
    test('adopts the month the server echoed, not the one requested', () async {
      final repo = _FakeRepository()..payload = _payload(month: '2026-09');
      final notifier = MonthlyExpensesNotifier(repo);

      // The client asked for a month outside the window; the server answered
      // for September, and the header must agree with the figures below it.
      await notifier.setMonth('2020-01');

      expect(repo.calls, ['fetch:2020-01']);
      expect(notifier.state.selectedMonth, '2026-09');
      expect(notifier.state.initialized, isTrue);
      expect(notifier.state.isLoading, isFalse);
    });

    test('first load asks for no month at all', () async {
      final repo = _FakeRepository()..payload = _payload();
      await MonthlyExpensesNotifier(repo).load();
      expect(repo.calls, ['fetch:null']);
    });

    test('a failure lands in error and leaves the payload alone', () async {
      final repo = _FakeRepository()..throwOnFetch = true;
      final notifier = MonthlyExpensesNotifier(repo);
      await notifier.load();

      expect(notifier.state.error, contains('fetch failed'));
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.initialized, isFalse);
    });

    test('prev/next step through the list', () async {
      final repo = _FakeRepository()..payload = _payload(month: '2026-08');
      final notifier = MonthlyExpensesNotifier(repo);
      await notifier.load();

      await notifier.goToPreviousMonth();
      expect(repo.calls.last, 'fetch:2026-07');

      await notifier.goToNextMonth();
      expect(repo.calls.last, 'fetch:2026-09');
    });

    test('a step past the end of the window is not requested', () async {
      final repo = _FakeRepository()..payload = _payload(month: '2026-09');
      final notifier = MonthlyExpensesNotifier(repo);
      await notifier.load();
      final before = repo.calls.length;

      await notifier.goToNextMonth();
      expect(repo.calls.length, before);
    });
  });

  group('mutations refresh the month', () {
    test('paying a recurring item refetches before reporting success', () async {
      final repo = _FakeRepository()..payload = _payload();
      final notifier = MonthlyExpensesNotifier(repo);
      await notifier.load();
      repo.calls.clear();

      final result = await notifier.payRecurringExpense(
        recurringExpense: 'JRE-0001',
        amount: 20000,
        payingAccount: 'Cash - J',
      );

      expect(result.success, isTrue);
      expect(repo.calls, [
        'pay:JRE-0001:2026-09:20000.0:false',
        'fetch:2026-09',
      ]);
      expect(notifier.state.isSubmitting, isFalse);
    });

    test('paying a salary, saving, status and cancel all refetch', () async {
      final repo = _FakeRepository()..payload = _payload();
      final notifier = MonthlyExpensesNotifier(repo);
      await notifier.load();
      repo.calls.clear();

      await notifier.paySalary(
        employee: 'HR-EMP-00001',
        amount: 7000,
        payingAccount: 'Cash - J',
      );
      await notifier.saveRecurringExpense(const RecurringExpenseDraft(
        expenseName: 'New rent',
        category: 'Rent',
        amount: 1000,
        frequency: 'Monthly',
        expenseAccount: 'Rent - Factory - J',
      ));
      await notifier.setStatus(name: 'JRE-0001', status: 'Paused');
      await notifier.cancelPayment(name: 'JER-0009', reason: 'wrong account');

      expect(
        repo.calls.where((c) => c.startsWith('fetch:')).length,
        4,
        reason: 'every mutation refetches the month',
      );
      expect(repo.calls, contains('status:JRE-0001:Paused'));
      expect(repo.calls, contains('cancel:JER-0009:wrong account'));
      expect(repo.calls, contains('save:<new>'));
    });

    test('a failed mutation does not refetch and does surface the error',
        () async {
      final repo = _FakeRepository()
        ..payload = _payload()
        ..throwOnMutate = Exception('Not permitted');
      final notifier = MonthlyExpensesNotifier(repo);
      await notifier.load();
      repo.calls.clear();

      final result =
          await notifier.setStatus(name: 'JRE-0001', status: 'Ended');

      expect(result.success, isFalse);
      expect(result.needsOverpayConfirmation, isFalse);
      expect(result.error, contains('Not permitted'));
      expect(notifier.state.error, contains('Not permitted'));
      expect(repo.calls.where((c) => c.startsWith('fetch:')), isEmpty);
    });
  });

  group('overpay', () {
    test('is a question, not an error: nothing is snackbarred', () async {
      final repo = _FakeRepository()
        ..payload = _payload()
        ..throwOnMutate = const MonthlyExpenseOverpayException(
            'Paying 30,000 would overpay Factory rent by 10,000.');
      final notifier = MonthlyExpensesNotifier(repo);
      await notifier.load();

      final result = await notifier.payRecurringExpense(
        recurringExpense: 'JRE-0001',
        amount: 30000,
        payingAccount: 'Cash - J',
      );

      expect(result.success, isFalse);
      expect(result.needsOverpayConfirmation, isTrue);
      expect(result.overpayMessage, contains('10,000'));
      // The amount of the overshoot is the point; a generic failure would have
      // thrown it away.
      expect(result.error, isNull);
      expect(notifier.state.error, isNull);
      expect(notifier.state.isSubmitting, isFalse);
    });

    test('the retry carries allow_overpay and then succeeds', () async {
      final repo = _FakeRepository()
        ..payload = _payload()
        ..throwOnMutate =
            const MonthlyExpenseOverpayException('would overpay by 10,000');
      final notifier = MonthlyExpensesNotifier(repo);
      await notifier.load();

      await notifier.payRecurringExpense(
        recurringExpense: 'JRE-0001',
        amount: 30000,
        payingAccount: 'Cash - J',
      );
      final retry = await notifier.payRecurringExpense(
        recurringExpense: 'JRE-0001',
        amount: 30000,
        payingAccount: 'Cash - J',
        allowOverpay: true,
      );

      expect(retry.success, isTrue);
      expect(repo.allowOverpayFlags, [false, true]);
    });
  });

  group('looksLikeOverpayRefusal', () {
    test('recognises the flag name and the word, in both languages', () {
      expect(looksLikeOverpayRefusal('Pass allow_overpay=1 to continue'), isTrue);
      expect(looksLikeOverpayRefusal('This would OVERPAY by 500'), isTrue);
      expect(looksLikeOverpayRefusal('هذا دفع زائد بمقدار ٥٠٠'), isTrue);
    });

    test('leaves unrelated failures alone', () {
      // Offering "pay anyway" on a permission error or a network drop would be
      // worse than not offering it at all.
      expect(looksLikeOverpayRefusal('Not permitted'), isFalse);
      expect(looksLikeOverpayRefusal('Connection closed'), isFalse);
      expect(looksLikeOverpayRefusal('Amount must be greater than zero'), isFalse);
    });
  });
}
