import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/business_constants.dart';
import 'package:jarz_pos/src/features/credit/data/credit_repository.dart';
import 'package:jarz_pos/src/features/credit/data/models/credit_models.dart';
import 'package:jarz_pos/src/features/credit/state/credit_providers.dart';
import 'package:jarz_pos/src/features/pos/presentation/dialogs/payment_method_dialog.dart';

/// Credit at checkout is a gate on money the company will not see today, so
/// these tests pin the four states the selector can be in: approved (offered
/// with terms), not approved on a B2B order (visible, inert, with the reason),
/// not approved on a retail order (absent), and unreachable profile (inert).
class _FakeCreditRepository extends CreditRepository {
  _FakeCreditRepository(this._profile, {this.shouldThrow = false})
      : super(Dio());

  final CustomerCreditProfile _profile;
  final bool shouldThrow;
  int calls = 0;

  @override
  Future<CustomerCreditProfile> getCustomerCreditProfile(
    String customer,
  ) async {
    calls += 1;
    if (shouldThrow) throw Exception('boom');
    return _profile;
  }
}

Widget _wrap({
  required _FakeCreditRepository repository,
  required Widget child,
}) {
  return ProviderScope(
    overrides: [
      creditRepositoryProvider.overrideWithValue(repository),
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
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('PaymentMethodDialog credit gating', () {
    testWidgets('offers Credit with terms and headroom when approved',
        (tester) async {
      final repository = _FakeCreditRepository(
        const CustomerCreditProfile(
          creditAllowed: true,
          creditDays: 30,
          creditLimit: 5000,
          currentBalance: 1200,
          availableCredit: 3800,
          currency: 'EGP',
        ),
      );

      String? selected;
      await tester.pumpWidget(
        _wrap(
          repository: repository,
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                selected = await PaymentMethodDialog.show(
                  context,
                  customer: 'CUST-COFFEE',
                  creditAllowedHint: true,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Credit (on account)'), findsOneWidget);
      // The terms and the remaining headroom are what the operator commits the
      // shop to, so both must be on screen before the tap, not after.
      expect(find.textContaining('Available credit'), findsOneWidget);
      expect(find.text('Due in 30 days'), findsOneWidget);

      await tester.tap(find.text('Credit (on account)'));
      await tester.pumpAndSettle();

      // The value handed back is the backend's `custom_payment_method` option
      // verbatim; a re-spelling here would post an invoice nobody can settle.
      expect(selected, PaymentModes.credit);
      expect(repository.calls, 1);
    });

    testWidgets(
        'shows Credit disabled with the reason on a B2B order when not approved',
        (tester) async {
      final repository = _FakeCreditRepository(
        const CustomerCreditProfile(creditAllowed: false, currency: 'EGP'),
      );

      String? selected = 'untouched';
      await tester.pumpWidget(
        _wrap(
          repository: repository,
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                selected = await PaymentMethodDialog.show(
                  context,
                  customer: 'CUST-NOCREDIT',
                  showCreditWhenNotAllowed: true,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Credit (on account)'), findsOneWidget);
      expect(
        find.text('This customer is not approved for credit'),
        findsOneWidget,
      );

      // Inert: tapping it must not close the dialog with a Credit result.
      await tester.tap(find.text('Credit (on account)'));
      await tester.pumpAndSettle();
      expect(selected, 'untouched');
      expect(find.text('Cash'), findsOneWidget);
    });

    testWidgets('hides Credit entirely on a retail order', (tester) async {
      final repository = _FakeCreditRepository(
        const CustomerCreditProfile(creditAllowed: false),
      );

      await tester.pumpWidget(
        _wrap(
          repository: repository,
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => PaymentMethodDialog.show(
                context,
                customer: 'CUST-WALKIN',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Credit (on account)'), findsNothing);
      // No row means no lookup: a retail checkout must not pay for a request
      // whose answer it would throw away.
      expect(repository.calls, 0);
    });

    testWidgets('never opens credit when the profile lookup fails',
        (tester) async {
      final repository = _FakeCreditRepository(
        const CustomerCreditProfile(creditAllowed: true),
        shouldThrow: true,
      );

      String? selected = 'untouched';
      await tester.pumpWidget(
        _wrap(
          repository: repository,
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                selected = await PaymentMethodDialog.show(
                  context,
                  customer: 'CUST-COFFEE',
                  creditAllowedHint: true,
                  showCreditWhenNotAllowed: true,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(
        find.text('Could not check the credit account right now'),
        findsOneWidget,
      );
      await tester.tap(find.text('Credit (on account)'));
      await tester.pumpAndSettle();
      expect(selected, 'untouched');
    });

    testWidgets('walk-in orders have no customer to put credit on',
        (tester) async {
      final repository = _FakeCreditRepository(
        const CustomerCreditProfile(creditAllowed: true),
      );

      await tester.pumpWidget(
        _wrap(
          repository: repository,
          child: Builder(
            builder: (context) => TextButton(
              // No customer, but both credit flags on: an empty customer id
              // still has to suppress the row, because there is nobody to
              // carry the debt.
              onPressed: () => PaymentMethodDialog.show(
                context,
                creditAllowedHint: true,
                showCreditWhenNotAllowed: true,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Credit (on account)'), findsNothing);
      expect(repository.calls, 0);
    });
  });

  group('customerCreditProfileProvider', () {
    test('survives the read that warmed it, so the dialog opens resolved',
        () async {
      final repository = _FakeCreditRepository(
        const CustomerCreditProfile(creditAllowed: true, creditDays: 15),
      );
      final container = ProviderContainer(
        overrides: [creditRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      // The warm read at customer-selection time.
      await container.read(customerCreditProfileProvider('CUST-1').future);
      // The payment dialog, minutes later.
      await container.read(customerCreditProfileProvider('CUST-1').future);

      expect(repository.calls, 1);
    });
  });
}
