import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/monthly_expenses/models/monthly_expense_models.dart';
import 'package:jarz_pos/src/features/monthly_expenses/presentation/widgets/monthly_expenses_summary_header.dart';
import 'package:jarz_pos/src/features/monthly_expenses/presentation/widgets/recurring_expense_card.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

RecurringExpenseItem _item({
  bool inferred = false,
  bool sharedAccount = false,
  bool canPay = true,
  String status = 'Active',
  String paymentStatus = 'Partial',
  List<MonthlyExpensePayment> payments = const [],
}) {
  return RecurringExpenseItem(
    name: 'JRE-0001',
    expenseName: 'Factory rent',
    category: 'Rent',
    status: status,
    amount: 20000,
    frequency: 'Monthly',
    monthlyEquivalent: 20000,
    expenseAccount: 'Rent - Factory - J',
    expenseAccountLabel: 'Rent - Factory',
    dueThisMonth: true,
    dueAmount: 20000,
    paidAmount: 15000,
    paidLinked: 10000,
    paidUnlinked: 5000,
    remaining: 5000,
    paymentStatus: paymentStatus,
    sharedAccount: sharedAccount,
    inferred: inferred,
    canPay: canPay,
    payments: payments,
  );
}

void main() {
  group('MonthlyExpensesSummaryHeader', () {
    testWidgets('leads with Remaining', (tester) async {
      await _pump(
        tester,
        const MonthlyExpensesSummaryHeader(
          summary: MonthlyExpenseSummary(
            runRate: 155000,
            due: 155000,
            paid: 47000,
            remaining: 108000,
            itemsTotal: 4,
            itemsPaid: 1,
            itemsUnpaid: 3,
          ),
          currency: 'EGP',
        ),
      );

      final remaining = tester.widget<Text>(
        find.byKey(const ValueKey('monthlyExpensesRemainingValue')),
      );
      expect(remaining.data, contains('108,000'));
      // Remaining is the headline: it is rendered larger than Due and Paid.
      expect(remaining.style?.fontWeight, FontWeight.bold);
      expect(find.textContaining('155,000'), findsWidgets);
    });

    testWidgets('calls out an overpaid month', (tester) async {
      await _pump(
        tester,
        const MonthlyExpensesSummaryHeader(
          summary: MonthlyExpenseSummary(
            due: 47000,
            paid: 50000,
            remaining: 0,
            overpaid: 3000,
          ),
          currency: 'EGP',
        ),
      );
      expect(find.textContaining('Overpaid by'), findsOneWidget);
    });
  });

  group('RecurringExpenseCard', () {
    testWidgets('shows due, paid and remaining with the status', (tester) async {
      await _pump(
        tester,
        RecurringExpenseCard(
          item: _item(),
          currency: 'EGP',
          canManage: true,
        ),
      );

      expect(find.text('Factory rent'), findsOneWidget);
      expect(find.text('Partial'), findsOneWidget);
      expect(find.textContaining('15,000'), findsWidgets);
      expect(find.textContaining('5,000'), findsWidgets);
    });

    testWidgets('is silent about attribution when there is nothing to disclose',
        (tester) async {
      await _pump(
        tester,
        RecurringExpenseCard(
          item: _item(),
          currency: 'EGP',
          canManage: true,
        ),
      );
      expect(find.text('From the ledger'), findsNothing);
      expect(find.text('Shared account'), findsNothing);
    });

    testWidgets('says so when the paid figure came from the ledger',
        (tester) async {
      await _pump(
        tester,
        RecurringExpenseCard(
          item: _item(inferred: true),
          currency: 'EGP',
          canManage: true,
        ),
      );

      // The badge is on the face of the card, not hidden in the expansion:
      // "paid" meaning "the ledger says so" is a materially weaker claim than
      // "we paid it here", and the user has to be able to tell.
      expect(find.text('From the ledger'), findsOneWidget);

      await tester.tap(find.text('Factory rent'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('read from the ledger'),
        findsOneWidget,
      );
    });

    testWidgets('says so when the expense account is shared', (tester) async {
      await _pump(
        tester,
        RecurringExpenseCard(
          item: _item(sharedAccount: true),
          currency: 'EGP',
          canManage: true,
        ),
      );
      expect(find.text('Shared account'), findsOneWidget);

      await tester.tap(find.text('Factory rent'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Rent - Factory'), findsWidgets);
    });

    testWidgets('a paused item is labelled as paused', (tester) async {
      await _pump(
        tester,
        RecurringExpenseCard(
          item: _item(status: 'Paused', paymentStatus: 'Not Due', canPay: false),
          currency: 'EGP',
          canManage: true,
        ),
      );
      expect(find.text('Paused'), findsOneWidget);
      expect(find.text('Not due'), findsOneWidget);
    });

    testWidgets('the Pay button follows can_pay, never the client guess',
        (tester) async {
      await _pump(
        tester,
        RecurringExpenseCard(
          item: _item(canPay: false),
          currency: 'EGP',
          canManage: true,
          onPay: () {},
        ),
      );
      await tester.tap(find.text('Factory rent'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'Pay'), findsNothing);
    });

    testWidgets('offers Pay when the server allows it', (tester) async {
      var paid = false;
      await _pump(
        tester,
        RecurringExpenseCard(
          item: _item(),
          currency: 'EGP',
          canManage: true,
          onPay: () => paid = true,
        ),
      );
      await tester.tap(find.text('Factory rent'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Pay'));
      expect(paid, isTrue);
    });

    testWidgets('hides the manage menu when the payload says read-only',
        (tester) async {
      await _pump(
        tester,
        RecurringExpenseCard(
          item: _item(),
          currency: 'EGP',
          canManage: false,
          onMenuAction: (_) {},
        ),
      );
      await tester.tap(find.text('Factory rent'));
      await tester.pumpAndSettle();
      expect(find.byType(PopupMenuButton<RecurringExpenseMenuAction>),
          findsNothing);
    });

    testWidgets('lists the payment history with a cancel action',
        (tester) async {
      MonthlyExpensePayment? cancelled;
      await _pump(
        tester,
        RecurringExpenseCard(
          item: _item(payments: [
            MonthlyExpensePayment(
              name: 'JER-0009',
              amount: 15000,
              date: DateTime(2026, 9, 3),
              payingAccount: 'Cash - J',
              payingLabel: 'Main cash drawer',
              journalEntry: 'ACC-JV-2026-00042',
            ),
          ]),
          currency: 'EGP',
          canManage: true,
          onCancelPayment: (payment) => cancelled = payment,
        ),
      );

      await tester.tap(find.text('Factory rent'));
      await tester.pumpAndSettle();
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('ACC-JV-2026-00042'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.undo));
      expect(cancelled?.name, 'JER-0009');
    });

    testWidgets('renders in Arabic without falling back to English',
        (tester) async {
      await _pump(
        tester,
        RecurringExpenseCard(
          item: _item(inferred: true),
          currency: 'EGP',
          canManage: true,
        ),
        locale: const Locale('ar'),
      );

      expect(find.text('جزئي'), findsOneWidget);
      expect(find.text('من دفتر الأستاذ'), findsOneWidget);
      expect(find.text('Partial'), findsNothing);
    });
  });
}
