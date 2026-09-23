import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/cash_custody/data/cash_custody_repository.dart';
import 'package:jarz_pos/src/features/cash_custody/models/cash_custody_models.dart';
import 'package:jarz_pos/src/features/cash_custody/presentation/widgets/custody_movement_sheet.dart';

import '../fake_cash_custody_repository.dart';

const _holder = CustodyHolder(
  name: 'CUST-1',
  employee: 'HR-EMP-1',
  employeeName: 'Ahmed',
  account: 'Custody - Ahmed - J',
  balance: 120,
  enabled: true,
);

const _accounts = [
  CustodyAccountOption(
    account: 'Nasr City Drawer - J',
    label: 'Nasr City',
    category: 'pos_profile',
    balance: 300,
    posProfile: 'Nasr City',
  ),
];

Future<void> _pumpSheet(WidgetTester tester, FakeCashCustodyRepository repo) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        cashCustodyRepositoryProvider.overrideWithValue(repo),
        canAccessCashTransferProvider.overrideWithValue(false),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CustodyMovementSheet(
            mode: CustodyMovementMode.returnCash,
            holder: _holder,
            accounts: _accounts,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('CustodyMovementSheet (return)', () {
    testWidgets('should prefill the amount with the full balance',
        (tester) async {
      await _pumpSheet(tester, FakeCashCustodyRepository());
      await tester.pumpAndSettle();

      final field = tester.widget<TextFormField>(
        find.byKey(const Key('custody-amount-field')),
      );
      expect(field.controller?.text, '120.00');
    });

    testWidgets('should refuse an amount above the custody balance',
        (tester) async {
      final repo = FakeCashCustodyRepository();
      await _pumpSheet(tester, repo);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('custody-amount-field')),
        '120.50',
      );
      await tester.tap(find.byKey(const Key('custody-submit')));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Amount cannot exceed the custody balance'),
        findsOneWidget,
      );
      expect(repo.calls.where((c) => c.startsWith('return:')), isEmpty);
    });

    testWidgets('should refuse a zero amount', (tester) async {
      final repo = FakeCashCustodyRepository();
      await _pumpSheet(tester, repo);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('custody-amount-field')),
        '0',
      );
      await tester.tap(find.byKey(const Key('custody-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Enter an amount greater than zero.'), findsOneWidget);
      expect(repo.calls.where((c) => c.startsWith('return:')), isEmpty);
    });

    testWidgets('should submit an amount within the balance', (tester) async {
      final repo = FakeCashCustodyRepository();
      await _pumpSheet(tester, repo);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('custody-amount-field')),
        '120',
      );
      await tester.tap(find.byKey(const Key('custody-submit')));
      await tester.pumpAndSettle();

      expect(
        repo.calls,
        contains('return:CUST-1:Nasr City Drawer - J:120.0'),
      );
    });
  });
}
