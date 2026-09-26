// Profit & Loss: the model reads the real backend payload, the numbers in it
// hold together, and the screen renders in both languages on a small phone.
//
// Fixtures are REAL production captures (read-only):
//   profit_and_loss.json             2026-09-01..26, complete books
//   profit_and_loss_incomplete.json  2026-07-01..31, no stock or courier cost
//                                    posted (0 Delivery Notes for 472 orders)

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/reports/data/models/profit_and_loss.dart';
import 'package:jarz_pos/src/features/reports/presentation/screens/profit_and_loss_screen.dart';
import 'package:jarz_pos/src/features/reports/state/reports_providers.dart';

ProfitAndLoss _fixture(String name) => ProfitAndLoss.fromJson(
  Map<String, dynamic>.from(
    jsonDecode(File('test/fixtures/reports/$name.json').readAsStringSync())
        as Map,
  ),
);

void main() {
  group('model (production September 2026)', () {
    final pnl = _fixture('profit_and_loss');

    test('reads the headline figures', () {
      expect(pnl.summary.totalRevenue, 279856.0);
      expect(pnl.summary.b2bRevenue, 54808.0);
      expect(pnl.summary.b2cRevenue, 223619.0);
      expect(pnl.summary.netProfit, closeTo(10730.42, 0.01));
      expect(pnl.shipping.income, 12755.0);
      expect(pnl.shipping.expense, 25477.0);
      expect(pnl.reconciliation.matches, isTrue);
      expect(pnl.dataQuality.warnings, isNot(contains('cogs_incomplete')));
    });

    test('channels add up to total revenue', () {
      final sum = pnl.channels.fold<double>(0, (s, c) => s + c.revenue);
      expect(sum, closeTo(pnl.summary.totalRevenue, 0.01));
      expect(pnl.channel('b2b').orders, 36);
    });

    test('expense sections add up to total expenses', () {
      final s = pnl.summary;
      expect(
        s.costOfSales +
            s.shippingExpense +
            s.recurringExpenses +
            s.otherExpenses,
        closeTo(s.totalExpenses, 0.01),
      );
      expect(s.totalRevenue - s.totalExpenses, closeTo(s.netProfit, 0.01));
    });

    test('every trend bucket adds up to the period totals', () {
      double sum(double Function(PnlTrendPoint) f) =>
          pnl.trend.fold<double>(0, (a, p) => a + f(p));
      expect(pnl.granularity, 'day');
      expect(pnl.trend, hasLength(26));
      expect(sum((p) => p.revenue), closeTo(pnl.summary.totalRevenue, 0.05));
      expect(sum((p) => p.expenses), closeTo(pnl.summary.totalExpenses, 0.05));
      expect(sum((p) => p.netProfit), closeTo(pnl.summary.netProfit, 0.05));
      expect(sum((p) => p.b2b), closeTo(pnl.channel('b2b').sales, 0.05));
    });

    test('incomplete books carry their warnings', () {
      final july = _fixture('profit_and_loss_incomplete');
      expect(july.dataQuality.cogsCoveragePct, 0);
      expect(
        july.dataQuality.warnings,
        containsAll(['cogs_incomplete', 'shipping_expense_incomplete']),
      );
    });

    test('an empty or older payload does not throw', () {
      final empty = ProfitAndLoss.fromJson(const {});
      expect(empty.summary.netProfit, 0);
      expect(empty.dataQuality.cogsCoveragePct, 100);
      expect(empty.channel('b2b').revenue, 0);
    });
  });

  group('screen', () {
    Future<void> pump(
      WidgetTester tester,
      ProfitAndLoss data,
      Locale locale,
    ) async {
      final view = tester.view;
      view.physicalSize = const Size(360 * 2, 5200 * 2);
      view.devicePixelRatio = 2;
      addTearDown(view.resetPhysicalSize);
      addTearDown(view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profitAndLossProvider.overrideWith((ref, range) => data),
            reportRangeProvider.overrideWith(
              (ref) => ReportRange(
                from: DateTime(2026, 9, 1),
                to: DateTime(2026, 9, 26),
              ),
            ),
          ],
          child: MaterialApp(
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const ProfitAndLossScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('English, 360dp: renders every section without overflow', (
      tester,
    ) async {
      await pump(tester, _fixture('profit_and_loss'), const Locale('en'));
      expect(tester.takeException(), isNull);
      expect(find.text('Matches the ledger'), findsOneWidget);
      expect(find.text('B2B vs B2C'), findsOneWidget);
      expect(find.text('Profit & loss statement'), findsOneWidget);
      expect(find.text('Shipping: charged vs paid'), findsOneWidget);
      expect(find.text('Cash Over Short'), findsOneWidget);
      expect(
        find.textContaining('Cost of goods is recorded for only'),
        findsNothing,
      );
    });

    testWidgets('Arabic, 360dp: renders right-to-left without overflow', (
      tester,
    ) async {
      await pump(tester, _fixture('profit_and_loss'), const Locale('ar'));
      expect(tester.takeException(), isNull);
      expect(find.text('مطابق للدفاتر'), findsOneWidget);
      expect(find.text('الشركات مقابل الأفراد'), findsOneWidget);
    });

    testWidgets('incomplete books lead with the warnings', (tester) async {
      await pump(
        tester,
        _fixture('profit_and_loss_incomplete'),
        const Locale('en'),
      );
      expect(tester.takeException(), isNull);
      expect(
        find.textContaining('Cost of goods is recorded for only 0'),
        findsOneWidget,
      );
      expect(
        find.textContaining('of the courier cost recorded on orders'),
        findsOneWidget,
      );
    });
  });
}
