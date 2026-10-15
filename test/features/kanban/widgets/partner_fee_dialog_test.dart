import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/kanban/widgets/settlement_preview_dialog.dart';

/// The InstaPay / Mobile Wallet "awaiting payment" dispatch has no settlement
/// preview, so a Delivery Partner rider (e.g. Deliverk) gets this prompt for
/// the partner's delivery cost instead. Without it the server refuses the
/// dispatch (order 18268, 2026-10-15).
void main() {
  Future<_Harness> open(WidgetTester tester, {String locale = 'en'}) async {
    final harness = _Harness();
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                harness.result =
                    await showPartnerFeeDialog(context, partnerName: 'Deliverk');
                harness.closed = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return harness;
  }

  final en = lookupAppLocalizations(const Locale('en'));

  testWidgets('shows the partner and returns the typed fee', (tester) async {
    final h = await open(tester);
    expect(find.text(en.settlementPartnerLabel('Deliverk')), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('partner-fee-input')), '45.5');
    await tester.tap(find.text(en.commonConfirm));
    await tester.pumpAndSettle();

    expect(h.closed, isTrue);
    expect(h.result, 45.5);
  });

  testWidgets('refuses an empty or invalid fee', (tester) async {
    final h = await open(tester);

    await tester.tap(find.text(en.commonConfirm));
    await tester.pumpAndSettle();
    expect(find.text(en.settlementPartnerFeeRequired), findsOneWidget);
    expect(h.closed, isFalse);

    await tester.enterText(find.byKey(const ValueKey('partner-fee-input')), '-3');
    await tester.tap(find.text(en.commonConfirm));
    await tester.pumpAndSettle();
    expect(find.text(en.settlementPartnerFeeInvalid), findsOneWidget);
    expect(h.closed, isFalse);
  });

  testWidgets('cancel returns null so the caller reverts the move', (tester) async {
    final h = await open(tester);
    await tester.tap(find.text(en.commonCancel));
    await tester.pumpAndSettle();
    expect(h.closed, isTrue);
    expect(h.result, isNull);
  });

  testWidgets('renders in Arabic', (tester) async {
    final ar = lookupAppLocalizations(const Locale('ar'));
    await open(tester, locale: 'ar');
    expect(find.text(ar.settlementPartnerFeeWhy), findsOneWidget);
    expect(find.text(ar.settlementPartnerLabel('Deliverk')), findsOneWidget);
  });

  test('validatePartnerFeeInput accepts zero and decimals', () {
    expect(validatePartnerFeeInput('0', en), isNull);
    expect(validatePartnerFeeInput(' 60.25 ', en), isNull);
    expect(validatePartnerFeeInput('abc', en), en.settlementPartnerFeeInvalid);
    expect(validatePartnerFeeInput('  ', en), en.settlementPartnerFeeRequired);
  });
}

class _Harness {
  double? result;
  bool closed = false;
}
