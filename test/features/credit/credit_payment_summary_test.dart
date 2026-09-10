import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/credit/data/models/credit_models.dart';
import 'package:jarz_pos/src/features/credit/presentation/credit_payment_summary.dart';
import 'package:jarz_pos/src/features/credit/presentation/widgets/record_credit_payment_sheet.dart';

/// FIFO allocation is the one place in this feature where the outcome is
/// routinely NOT what the user intended: a round payment clears two invoices
/// and leaves a tail, or clears nothing at all and becomes an advance. These
/// tests pin the sentences that difference is reported in.

CreditPaymentAllocation _allocation({
  required String invoice,
  required double allocated,
  double before = 0,
  bool settled = true,
}) {
  return CreditPaymentAllocation(
    invoice: invoice,
    allocatedAmount: allocated,
    outstandingBefore: before,
    fullySettled: settled,
  );
}

/// Money formatting is the widget layer's job; the wording is what is under
/// test, so amounts are rendered as plain integers.
String _money(double amount) => amount.toStringAsFixed(0);

Future<AppLocalizations> _l10n(WidgetTester tester, Locale locale) async {
  late AppLocalizations resolved;
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
      home: Builder(
        builder: (context) {
          resolved = AppLocalizations.of(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return resolved;
}

void main() {
  group('creditPaymentSummaryLines', () {
    testWidgets('reports two cleared invoices and the advance tail',
        (tester) async {
      final l10n = await _l10n(tester, const Locale('en'));

      final result = CreditPaymentResult(
        paymentEntry: 'ACC-PAY-2026-00042',
        amount: 1960,
        totalAllocated: 1840,
        unallocatedAmount: 120,
        allocations: [
          _allocation(
            invoice: 'ACC-SINV-2026-18193',
            allocated: 1000,
            before: 1000,
          ),
          _allocation(
            invoice: 'ACC-SINV-2026-18197',
            allocated: 840,
            before: 840,
          ),
        ],
      );

      final lines = creditPaymentSummaryLines(
        l10n: l10n,
        result: result,
        money: _money,
      );

      // The shape the owner asked for: "1,840 cleared invoices 18193 and
      // 18197; 120 left as advance" — the invoice ids stripped of the
      // ACC-SINV- prefix nobody outside Desk uses.
      expect(lines, [
        '1840 cleared invoices 2026-18193 and 2026-18197',
        '120 left as an advance',
      ]);
    });

    testWidgets('names the part-paid invoice instead of implying it closed',
        (tester) async {
      final l10n = await _l10n(tester, const Locale('en'));

      final result = CreditPaymentResult(
        amount: 1500,
        totalAllocated: 1500,
        remainingBalance: 500,
        allocations: [
          _allocation(
            invoice: 'ACC-SINV-2026-18193',
            allocated: 1000,
            before: 1000,
          ),
          // The FIFO tail: allocated, but still carrying an outstanding
          // amount afterwards.
          _allocation(
            invoice: 'ACC-SINV-2026-18197',
            allocated: 500,
            before: 1000,
            settled: false,
          ),
        ],
      );

      final lines = creditPaymentSummaryLines(
        l10n: l10n,
        result: result,
        money: _money,
      );

      expect(lines, [
        '1000 cleared invoice 2026-18193',
        '500 went to invoice 2026-18197, which is still partly open',
        'Still on account: 500',
      ]);
    });

    testWidgets('says so when nothing was open and it all became an advance',
        (tester) async {
      final l10n = await _l10n(tester, const Locale('en'));

      final result = const CreditPaymentResult(
        amount: 300,
        totalAllocated: 0,
        unallocatedAmount: 300,
      );

      final lines = creditPaymentSummaryLines(
        l10n: l10n,
        result: result,
        money: _money,
      );

      expect(lines, [
        'Nothing was open, so all 300 is sitting as an advance',
      ]);
    });

    testWidgets('renders in Arabic without leaking an English list joiner',
        (tester) async {
      final l10n = await _l10n(tester, const Locale('ar'));

      final result = CreditPaymentResult(
        totalAllocated: 1840,
        unallocatedAmount: 120,
        allocations: [
          _allocation(invoice: 'ACC-SINV-2026-18193', allocated: 1000),
          _allocation(invoice: 'ACC-SINV-2026-18197', allocated: 840),
        ],
      );

      final lines = creditPaymentSummaryLines(
        l10n: l10n,
        result: result,
        money: _money,
      );

      expect(lines.length, 2);
      expect(lines.first, contains('و2026-18197'));
      expect(lines.first, isNot(contains(' and ')));
      expect(lines.last, contains('رصيد مقدم'));
    });

    testWidgets('joins three cleared invoices with commas and the last word',
        (tester) async {
      final l10n = await _l10n(tester, const Locale('en'));

      expect(joinCreditList(l10n, const ['A', 'B', 'C']), 'A, B and C');
      expect(joinCreditList(l10n, const ['A']), 'A');
      expect(joinCreditList(l10n, const []), '');
    });
  });

  group('CreditPaymentResultDialog', () {
    testWidgets('shows every allocation fact, not a one-line confirmation',
        (tester) async {
      final result = CreditPaymentResult(
        paymentEntry: 'ACC-PAY-2026-00042',
        currency: 'EGP',
        totalAllocated: 1840,
        unallocatedAmount: 120,
        remainingBalance: 640,
        allocations: [
          _allocation(invoice: 'ACC-SINV-2026-18193', allocated: 1000),
          _allocation(invoice: 'ACC-SINV-2026-18197', allocated: 840),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: CreditPaymentResultDialog(result: result),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Payment recorded'), findsOneWidget);
      expect(
        find.textContaining('cleared invoices 2026-18193 and 2026-18197'),
        findsOneWidget,
      );
      expect(find.textContaining('left as an advance'), findsOneWidget);
      expect(find.textContaining('Still on account'), findsOneWidget);
      // The Payment Entry is the audit trail back to the ledger.
      expect(
        find.textContaining('ACC-PAY-2026-00042'),
        findsOneWidget,
      );
    });
  });

  group('CreditPaymentResult wire tolerance', () {
    test('reads the alternate key spellings the endpoint may use', () {
      final result = CreditPaymentResult.fromJson(const {
        'success': true,
        'payment_entry': 'ACC-PAY-1',
        // `allocated_total` / `advance_amount` / `allocated_invoices` are the
        // spellings used by the neighbouring settlement payloads.
        'allocated_total': '1840.00',
        'advance_amount': 120,
        'allocated_invoices': [
          {'sales_invoice': 'ACC-SINV-2026-18193', 'amount': '1000.00'},
          {'name': 'ACC-SINV-2026-18197', 'allocated': 840},
        ],
      });

      expect(result.totalAllocated, 1840.0);
      expect(result.unallocatedAmount, 120.0);
      expect(result.allocations.map((a) => a.displayId).toList(), [
        '2026-18193',
        '2026-18197',
      ]);
      expect(result.allocations.first.allocatedAmount, 1000.0);
      expect(result.hasAdvance, isTrue);
      expect(result.isEntirelyAdvance, isFalse);
    });

    test('a decimal serialised as a string is still money', () {
      final profile = CustomerCreditProfile.fromJson(const {
        'credit_allowed': 1,
        'credit_days': '30',
        'credit_limit': '5000.00',
        'current_balance': '1200.50',
        'available_credit': '3799.50',
      });

      expect(profile.creditAllowed, isTrue);
      expect(profile.creditDays, 30);
      expect(profile.availableCredit, 3799.5);
      expect(profile.hasLimit, isTrue);
      expect(profile.isOverLimit, isFalse);
    });

    test('an unreadable credit_allowed never opens credit', () {
      expect(
        CustomerCreditProfile.fromJson(const {}).creditAllowed,
        isFalse,
      );
      expect(
        CustomerCreditProfile.fromJson(const {'credit_allowed': 'maybe'})
            .creditAllowed,
        isFalse,
      );
    });
  });
}
