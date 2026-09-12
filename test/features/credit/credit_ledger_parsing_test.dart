import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/credit/data/credit_payment_token.dart';
import 'package:jarz_pos/src/features/credit/data/models/credit_models.dart';
import 'package:jarz_pos/src/features/credit/presentation/credit_payment_summary.dart';
import 'package:jarz_pos/src/features/credit/presentation/widgets/record_credit_payment_sheet.dart';
import 'package:jarz_pos/src/features/credit/state/credit_providers.dart';

/// Parsing tests over the REAL `get_credit_ledger` payload.
///
/// Their absence is the whole story of this feature's first production week:
/// the customer row's balance was read from `total_outstanding`, a key that
/// exists only on `summary`, so every row parsed as 0.00. `owing` filters on
/// non-zero, so the accounts list rendered its empty state for every shop, the
/// detail balance read 0.00, and the payment sheet flagged every amount as
/// "more than the balance". Nothing in the suite touched `fromJson`, so all of
/// it shipped green.
///
/// The payload below is copied from a staging response, key for key. Anything
/// asserted here is asserted against the wire, not against the model's wishes.

/// One customer row exactly as staging sends it.
Map<String, dynamic> _stagingLedger() => {
      'success': true,
      'filters': {
        'customer': '',
        'pos_profile': '',
        'from_date': '2026-06-13',
        'to_date': '2026-09-11',
        'limit': 200,
      },
      'summary': {
        // `total_outstanding` IS correct here — this is the one place it
        // exists. The row below deliberately does not repeat it.
        'total_outstanding': 580.0,
        'customer_count': 1,
        'invoice_count': 2,
        'currency': 'EGP',
        'outstanding_is_all_time': true,
      },
      'customers': [
        {
          'customer': 'E2E CREDIT TESTER',
          'customer_name': 'E2E Credit Tester',
          'outstanding': 580.0,
          'invoice_count': 2,
          'oldest_invoice_date': '2026-09-10',
          'oldest_age_days': 0,
          'credit_allowed': true,
          'credit_days': 30,
          'credit_limit': 5000.0,
          'currency': 'EGP',
          'open_invoices': [
            {
              'invoice': 'ACC-SINV-2026-18197',
              'posting_date': '2026-09-11',
              'due_date': '2026-10-11',
              'outstanding': 180.0,
              'grand_total': 180.0,
            },
            {
              // The older of the two, sent second: the screen must not depend
              // on the server's ordering to get FIFO right.
              'invoice': 'ACC-SINV-2026-18193',
              'posting_date': '2026-09-10',
              'due_date': '2026-10-10',
              'outstanding_amount': 400.0,
              'grand_total': 500.0,
            },
          ],
        },
      ],
      'invoices': [
        {
          'invoice': 'ACC-SINV-2026-18197',
          'customer': 'E2E CREDIT TESTER',
          'customer_name': 'E2E Credit Tester',
          'posting_date': '2026-09-11',
          'grand_total': 180.0,
          'outstanding_amount': 180.0,
          'status': 'Unpaid',
          'currency': 'EGP',
        },
        {
          // Fully paid, still in the window. The activity feed lists it; the
          // "open invoices" heading must not.
          'invoice': 'ACC-SINV-2026-18150',
          'customer': 'E2E CREDIT TESTER',
          'customer_name': 'E2E Credit Tester',
          'posting_date': '2026-07-02',
          'grand_total': 900.0,
          'outstanding_amount': 0.0,
          'status': 'Paid',
          'currency': 'EGP',
        },
      ],
    };

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

String _money(double amount) => amount.toStringAsFixed(0);

void main() {
  group('CreditLedger.fromJson — the staging payload', () {
    test('the row balance comes off `outstanding`, and reaches `owing`', () {
      final ledger = CreditLedger.fromJson(_stagingLedger());

      final row = ledger.rowFor('E2E CREDIT TESTER');
      expect(row, isNotNull);
      expect(row!.outstanding, 580.0);

      // The bug in one assertion: a shop that owes 580 must be in the list the
      // accounts screen renders.
      expect(ledger.owing.map((r) => r.customer), ['E2E CREDIT TESTER']);
      expect(ledger.owing.single.outstanding, 580.0);
      expect(ledger.isEmpty, isFalse);
    });

    test('`total_outstanding` still belongs to the summary', () {
      final ledger = CreditLedger.fromJson(_stagingLedger());
      expect(ledger.summary.totalOutstanding, 580.0);
      expect(ledger.summary.outstandingIsAllTime, isTrue);
      expect(ledger.summary.currency, 'EGP');
    });

    test('a row spelling the balance the summary way is still read', () {
      // Tolerance only — the contract is `outstanding`. This exists so a
      // backend that ever unifies the two keys cannot empty the screen again.
      final row = CreditCustomerRow.fromJson(const {
        'customer': 'LEGACY',
        'total_outstanding': '1200.50',
      });
      expect(row.outstanding, 1200.5);
    });

    test('the server\'s own ageing wins over the handset clock', () {
      final row = CreditCustomerRow.fromJson(const {
        'customer': 'X',
        'outstanding': 100,
        'oldest_invoice_date': '2020-01-01',
        'oldest_age_days': 3,
      });
      expect(row.oldestInvoiceAgeDays, 3);

      // Absent is not zero: with no reported age it falls back to the date.
      final undated = CreditCustomerRow.fromJson(const {
        'customer': 'X',
        'outstanding': 100,
      });
      expect(undated.oldestInvoiceAgeDays, isNull);
    });
  });

  group('open invoices vs. the activity feed', () {
    test('`open_invoices` parses, oldest first, whatever order it arrives in',
        () {
      final ledger = CreditLedger.fromJson(_stagingLedger());
      final open = ledger.openInvoicesFor('E2E CREDIT TESTER');

      expect(open.map((i) => i.displayId).toList(), [
        '2026-18193',
        '2026-18197',
      ]);
      // Both wire spellings of the amount survive.
      expect(open.first.outstandingAmount, 400.0);
      expect(open.last.outstandingAmount, 180.0);
      // They add up to the row balance, which is the point of listing them.
      expect(
        open.fold<double>(0, (sum, i) => sum + i.outstandingAmount),
        580.0,
      );
    });

    test('a settled invoice in the window never reaches "open invoices"', () {
      final ledger = CreditLedger.fromJson(_stagingLedger());

      // The feed carries it, at 0.00 — that is what the old screen listed.
      expect(
        ledger.invoicesFor('E2E CREDIT TESTER').map((i) => i.displayId),
        containsAll(<String>['2026-18150', '2026-18197']),
      );
      expect(
        ledger.openInvoicesFor('E2E CREDIT TESTER').map((i) => i.displayId),
        isNot(contains('2026-18150')),
      );
    });

    test('an open invoice older than the window is listed all the same', () {
      final ledger = CreditLedger.fromJson(_stagingLedger());
      // 18193 is open and absent from the 90-day feed; the debt worth chasing
      // is exactly the one the window used to hide.
      expect(
        ledger.invoicesFor('E2E CREDIT TESTER').map((i) => i.displayId),
        isNot(contains('2026-18193')),
      );
      expect(
        ledger.openInvoicesFor('E2E CREDIT TESTER').map((i) => i.displayId),
        contains('2026-18193'),
      );
    });

    test('with no row at all, the feed fallback still drops paid invoices', () {
      final payload = _stagingLedger()..['customers'] = <dynamic>[];
      final ledger = CreditLedger.fromJson(payload);

      expect(
        ledger.openInvoicesFor('E2E CREDIT TESTER').map((i) => i.displayId),
        ['2026-18197'],
      );
    });
  });

  group('replay of an already-recorded payment', () {
    /// The exact shape of the backend's replay branch: an id, the notice, and
    /// none of the allocation fields the dialog is otherwise built from.
    CreditPaymentResult replay() => CreditPaymentResult.fromJson(const {
          'success': true,
          'payment_entry': 'ACC-PAY-2026-00042',
          'customer': 'E2E CREDIT TESTER',
          'amount': 580.0,
          'already_recorded': true,
          'notice_code': 'already_recorded',
          'notice': 'This payment was already recorded.',
          'currency': 'EGP',
        });

    test('the notice fields parse and nothing is mistaken for an allocation',
        () {
      final result = replay();
      expect(result.isReplay, isTrue);
      expect(result.alreadyRecorded, isTrue);
      expect(result.noticeCode, 'already_recorded');
      expect(result.allocations, isEmpty);
      expect(result.hasAdvance, isFalse);
      // `isEntirelyAdvance` must NOT fire here: no advance was created.
      expect(result.isEntirelyAdvance, isFalse);
      expect(result.remainingBalance, isNull);
    });

    testWidgets('it renders a sentence instead of an empty dialog',
        (tester) async {
      final l10n = await _l10n(tester, const Locale('en'));
      final lines = creditPaymentSummaryLines(
        l10n: l10n,
        result: replay(),
        money: _money,
      );

      // Before the fix this list was empty and the operator saw a title and an
      // id — the blank result that earns a third tap.
      expect(lines, isNotEmpty);
      expect(lines.first, contains('already recorded'));
      expect(lines.first, contains('580'));
      expect(lines.last, contains('Refresh'));
    });

    testWidgets('the dialog title does not claim a second payment went in',
        (tester) async {
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
          home: CreditPaymentResultDialog(result: replay()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Already recorded'), findsOneWidget);
      expect(find.text('Payment recorded'), findsNothing);
      expect(find.textContaining('ACC-PAY-2026-00042'), findsOneWidget);
    });

    testWidgets('it reads in Arabic too', (tester) async {
      final l10n = await _l10n(tester, const Locale('ar'));
      final lines = creditPaymentSummaryLines(
        l10n: l10n,
        result: replay(),
        money: _money,
      );
      expect(lines, hasLength(2));
      expect(lines.first, contains('قبل كده'));
      expect(lines.first, isNot(contains('already')));
    });

    test('an unrecognised notice is still shown verbatim', () async {
      final result = CreditPaymentResult.fromJson(const {
        'success': true,
        'notice_code': 'something_new',
        'notice': 'Allocated against a different company.',
      });
      expect(result.isReplay, isFalse);
      expect(result.unknownNotice, 'Allocated against a different company.');
    });
  });

  group('CreditPaymentIdempotency', () {
    test('a retry of the same attempt carries the same token', () {
      final idempotency = CreditPaymentIdempotency();
      final first = idempotency.tokenFor(
        customer: 'E2E CREDIT TESTER',
        amount: 580,
        posProfile: 'Main',
        paymentMethod: 'Cash',
      );
      // The timeout-then-tap-again path — three minutes later, outside the
      // backend's 2-minute heuristic, which is where the double booking was.
      final retry = idempotency.tokenFor(
        customer: 'E2E CREDIT TESTER',
        amount: 580.00,
        posProfile: 'Main',
        paymentMethod: 'Cash',
      );
      expect(retry, first);
      expect(first, startsWith('cpay-'));
    });

    test('changing any figure makes it a different payment', () {
      final idempotency = CreditPaymentIdempotency();
      final first = idempotency.tokenFor(
        customer: 'C',
        amount: 580,
        posProfile: 'Main',
        paymentMethod: 'Cash',
      );
      expect(
        idempotency.tokenFor(
          customer: 'C',
          amount: 500,
          posProfile: 'Main',
          paymentMethod: 'Cash',
        ),
        isNot(first),
      );
      final afterAmount = idempotency.current;
      expect(
        idempotency.tokenFor(
          customer: 'C',
          amount: 500,
          posProfile: 'Main',
          paymentMethod: 'Instapay',
        ),
        isNot(afterAmount),
      );
    });

    test('after a recorded payment, the next one is genuinely new', () {
      // Two real handovers of the same round figure at one branch, minutes
      // apart, are two payments — the case the (customer, amount) heuristic
      // silently discarded.
      final idempotency = CreditPaymentIdempotency();
      final first = idempotency.tokenFor(
        customer: 'C',
        amount: 500,
        posProfile: 'Main',
        paymentMethod: 'Cash',
      );
      idempotency.reset();
      expect(idempotency.current, isNull);
      final second = idempotency.tokenFor(
        customer: 'C',
        amount: 500,
        posProfile: 'Main',
        paymentMethod: 'Cash',
      );
      expect(second, isNot(first));
    });
  });

  group('creditPaymentIdempotencyProvider', () {
    test('the attempt outlives the sheet it was typed into', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final holder = container.read(
        creditPaymentIdempotencyProvider('E2E CREDIT TESTER'),
      );
      final token = holder.tokenFor(
        customer: 'E2E CREDIT TESTER',
        amount: 580,
        posProfile: 'Main',
        paymentMethod: 'Cash',
      );

      // Timed out, sheet dismissed, sheet reopened, same figure re-entered:
      // the retry must still be recognisable as a retry.
      final reopened = container.read(
        creditPaymentIdempotencyProvider('E2E CREDIT TESTER'),
      );
      expect(identical(reopened, holder), isTrue);
      expect(
        reopened.tokenFor(
          customer: 'E2E CREDIT TESTER',
          amount: 580,
          posProfile: 'Main',
          paymentMethod: 'Cash',
        ),
        token,
      );

      // A different shop is a different attempt.
      expect(
        container.read(creditPaymentIdempotencyProvider('OTHER SHOP')).current,
        isNull,
      );
    });
  });

  group('RecordCreditPaymentSheet prefill', () {
    testWidgets('prefills the real balance and does not cry over-payment',
        (tester) async {
      final ledger = CreditLedger.fromJson(_stagingLedger());
      final balance = ledger.rowFor('E2E CREDIT TESTER')!.outstanding;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            creditPaymentPosProfilesProvider
                .overrideWith((ref) async => const <String>['Main']),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: RecordCreditPaymentSheet(
                customer: 'E2E CREDIT TESTER',
                customerName: 'E2E Credit Tester',
                balance: balance,
                currency: 'EGP',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // With the balance parsing as 0.00 this field was blank and every typed
      // amount tripped the over-payment notice.
      expect(find.text('580.00'), findsOneWidget);
      expect(
        find.textContaining('More than the balance'),
        findsNothing,
      );
      // The scope asymmetry is stated where the payment is made.
      expect(
        find.textContaining('across every branch'),
        findsOneWidget,
      );
    });
  });
}
