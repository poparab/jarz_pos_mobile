// Revenue dashboard: the model reads the contract payload
// (`.scratch/revenue-dashboard/CONTRACT.md`) key for key, survives a sparse
// payload, and the screen renders the four snapshot cards on a 360dp phone
// in both languages.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/reports/data/models/revenue_dashboard.dart';
import 'package:jarz_pos/src/features/reports/presentation/screens/revenue_dashboard_screen.dart';
import 'package:jarz_pos/src/features/reports/state/reports_providers.dart';

Map<String, dynamic> _json() => Map<String, dynamic>.from(
  jsonDecode(
        File(
          'test/fixtures/reports/revenue_dashboard.json',
        ).readAsStringSync(),
      )
      as Map,
);

const _snapshotKeys = [
  'revenue-snapshot-today',
  'revenue-snapshot-yesterday',
  'revenue-snapshot-last-7-days',
  'revenue-snapshot-month-to-date',
];

void _expectTitle(String cardKey, String title) => expect(
  find.descendant(of: find.byKey(ValueKey(cardKey)), matching: find.text(title)),
  findsOneWidget,
  reason: cardKey,
);

void main() {
  group('model', () {
    final d = RevenueDashboard.fromJson(_json());

    test('reads the envelope and filters', () {
      expect(d.isEmpty, isFalse);
      expect(d.generatedAt, '2026-10-18 14:05:11');
      expect(d.today, '2026-10-18');
      expect(d.filters.dateFrom, '2026-10-12');
      expect(d.filters.dateTo, '2026-10-18');
      expect(d.filters.branch, isNull);
      expect(d.granularity, 'day');
    });

    test('reads all four snapshot periods', () {
      final s = d.snapshot;
      expect(s.today.netSales, 12500.0);
      expect(s.today.b2c, 9800.0);
      expect(s.today.b2b, 2500.0);
      expect(s.today.other, 200.0);
      expect(s.today.orders, 31);
      expect(s.today.b2cOrders, 27);
      expect(s.today.b2bOrders, 3);
      expect(s.today.aov, closeTo(403.23, 0.001));
      expect(s.today.compareNetSales, 11000.0);
      expect(s.today.compareOrders, 28);
      expect(s.today.changePct, 13.6);
      expect(s.today.compareFrom, '2026-10-11');
      expect(s.today.labelFrom, '2026-10-18');
      expect(s.yesterday.changePct, -7.7);
      expect(s.last7Days.netSales, 78250.0);
      expect(s.last7Days.compareTo, '2026-10-11');
      // Nothing to compare against: the backend sends null, not 0.
      expect(s.monthToDate.changePct, isNull);
      expect(s.monthToDate.netSales, 201400.0);
    });

    test('reads the period summary and the previous period', () {
      final s = d.summary;
      expect(s.netSales, 78250.0);
      expect(s.b2c + s.b2b + s.other, closeTo(s.netSales, 0.01));
      expect(s.staff, 650.0);
      expect(s.samples, 350.0);
      expect(s.shippingIncome, 5420.0);
      expect(s.totalRevenue, 83670.0);
      expect(s.orders, 192);
      expect(s.b2cOrders + s.b2bOrders + s.otherOrders, s.orders);
      expect(s.aov, 407.55);
      expect(s.b2cAov, 360.29);
      expect(s.b2bAov, 888.89);
      expect(s.b2bSharePct, 20.4);
      expect(s.returns, 2);
      expect(s.returnsValue, 740.0);
      expect(s.cancelled, 3);
      expect(s.cancelledValue, 1210.0);
      expect(s.discountTotal, 2315.5);
      expect(s.customers, 161);
      expect(s.newCustomers, 47);
      expect(s.days, 7);
      expect(s.dailyAverage, 11178.57);
      expect(s.bestDay?.date, '2026-10-16');
      expect(s.bestDay?.netSales, 14900.0);
      expect(s.worstDay?.date, '2026-10-13');
      final p = s.previous;
      expect(p.dateFrom, '2026-10-05');
      expect(p.dateTo, '2026-10-11');
      expect(p.netSales, 70100.0);
      expect(p.orders, 180);
      expect(p.changePct, 11.6);
      expect(p.b2cChangePct, 7.3);
      expect(p.b2bChangePct, 31.1);
      expect(p.ordersChangePct, -2.5);
    });

    test('reads the trend and every breakdown', () {
      expect(d.trend, hasLength(7));
      expect(
        d.trend.fold<double>(0, (a, t) => a + t.netSales),
        closeTo(d.summary.netSales, 0.01),
      );
      expect(d.trend.last.b2b, 3800.0);
      expect(d.trend.last.orders, 31);

      expect(d.bySource.map((r) => r.source), [
        'pos',
        'woo',
        'talabat',
        'partner',
        'b2b',
        'staff',
        'samples',
      ]);
      expect(d.bySource.first.sharePct, 42.4);
      expect(
        d.bySource.fold<double>(0, (a, r) => a + r.netSales),
        closeTo(d.summary.netSales, 0.01),
      );

      expect(d.byPayment.map((r) => r.method), contains('Unspecified'));
      expect(d.byPayment.first.orders, 101);

      expect(d.byBranch, hasLength(3));
      expect(d.byBranch.last.branch, '(No Profile)');
      expect(d.byBranch.first.b2b, 8200.0);
      expect(d.byBranch.first.sharePct, 52.7);

      expect(d.byHour, hasLength(24));
      expect(d.hourly, hasLength(24));
      expect(d.hourly[18].orders, 14);
      expect(d.hourly[3].orders, 0);

      expect(d.fulfilment.deliveryOrders, 141);
      expect(d.fulfilment.pickupOrders, 51);
      expect(d.fulfilment.total, 192);

      expect(d.topProducts, hasLength(10));
      expect(d.topProducts.first.displayName, 'Lotus Jar');
      expect(d.topProducts.first.qty, 96.0);
      // No item name: falls back to the code.
      expect(d.topProducts.last.displayName, 'JAR-010');

      expect(d.topB2bCustomers, hasLength(3));
      expect(d.topB2bCustomers.first.displayName, 'Cafe Roma');
      expect(d.topB2bCustomers.last.displayName, 'CUST-B2B-0003');
    });

    test('a sparse {} payload does not throw and reads as zeros', () {
      final e = RevenueDashboard.fromJson(const {});
      expect(e.isEmpty, isTrue);
      expect(e.snapshot.today.netSales, 0);
      expect(e.snapshot.today.changePct, isNull);
      expect(e.snapshot.monthToDate.orders, 0);
      expect(e.summary.netSales, 0);
      expect(e.summary.aov, isNull);
      expect(e.summary.b2bSharePct, isNull);
      expect(e.summary.bestDay, isNull);
      expect(e.summary.worstDay, isNull);
      expect(e.summary.previous.changePct, isNull);
      expect(e.trend, isEmpty);
      expect(e.bySource, isEmpty);
      expect(e.byBranch, isEmpty);
      expect(e.fulfilment.total, 0);
      expect(e.hourly, hasLength(24));
      expect(e.hourly.every((h) => h.orders == 0), isTrue);
    });

    test('partial rows and wrong types fall back instead of throwing', () {
      final e = RevenueDashboard.fromJson({
        'snapshot': {
          'today': {'net_sales': '1500.5', 'orders': null},
        },
        'summary': {'best_day': null, 'previous': 'oops'},
        'by_hour': [
          {'hour': 20, 'orders': 3},
          {'orders': 9}, // no hour: dropped
          'not a row',
        ],
        'top_products': [{}],
      });
      expect(e.snapshot.today.netSales, 1500.5);
      expect(e.snapshot.today.orders, 0);
      expect(e.summary.bestDay, isNull);
      expect(e.summary.previous.netSales, 0);
      expect(e.hourly, hasLength(24));
      expect(e.hourly[20].orders, 3);
      expect(e.hourly.fold<int>(0, (a, h) => a + h.orders), 3);
      expect(e.topProducts.single.displayName, '');
    });
  });

  group('screen', () {
    Future<void> pump(
      WidgetTester tester,
      RevenueDashboard data,
      Locale locale,
    ) async {
      final view = tester.view;
      view.physicalSize = const Size(360 * 2, 7000 * 2);
      view.devicePixelRatio = 2;
      addTearDown(view.resetPhysicalSize);
      addTearDown(view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            revenueDashboardProvider.overrideWith((ref, q) => data),
            reportBranchesProvider.overrideWith((ref) => const []),
            reportBranchProvider.overrideWith((ref) => null),
            reportRangeProvider.overrideWith(
              (ref) => ReportRange(
                from: DateTime(2026, 10, 12),
                to: DateTime(2026, 10, 18),
              ),
            ),
          ],
          child: MaterialApp(
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const RevenueDashboardScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('English, 360dp: four snapshot cards and every section', (
      tester,
    ) async {
      await pump(tester, RevenueDashboard.fromJson(_json()), const Locale('en'));
      expect(tester.takeException(), isNull);
      for (final k in _snapshotKeys) {
        expect(find.byKey(ValueKey(k)), findsOneWidget, reason: k);
      }
      // Scoped to the card: the filter bar has its own "Today" preset.
      _expectTitle('revenue-snapshot-today', 'Today');
      _expectTitle('revenue-snapshot-yesterday', 'Yesterday');
      _expectTitle('revenue-snapshot-last-7-days', 'Last 7 days');
      _expectTitle('revenue-snapshot-month-to-date', 'Month to date');
      expect(find.text('vs same day last week'), findsNWidgets(2));
      expect(find.text('vs previous 7 days'), findsOneWidget);
      expect(find.text('vs same days last month'), findsOneWidget);
      // Month to date has nothing to compare against.
      expect(find.text('▲ 13.6%'), findsOneWidget);
      expect(find.text('▼ 7.7%'), findsOneWidget);
      expect(find.text('B2B vs B2C trend'), findsOneWidget);
      expect(find.text('Sales by source'), findsOneWidget);
      expect(find.text('Website'), findsOneWidget);
      expect(find.text('By branch'), findsOneWidget);
      expect(find.text('No branch'), findsOneWidget);
      expect(find.text('(No Profile)'), findsNothing);
      expect(find.text('Orders by hour'), findsOneWidget);
      expect(find.text('Delivery vs pickup'), findsOneWidget);
      expect(find.text('Top 10 products'), findsOneWidget);
      expect(find.text('Top 10 B2B customers'), findsOneWidget);
      expect(find.text('Cafe Roma'), findsOneWidget);
    });

    testWidgets('Arabic, 360dp: renders right-to-left without overflow', (
      tester,
    ) async {
      await pump(tester, RevenueDashboard.fromJson(_json()), const Locale('ar'));
      expect(tester.takeException(), isNull);
      for (final k in _snapshotKeys) {
        expect(find.byKey(ValueKey(k)), findsOneWidget, reason: k);
      }
      _expectTitle('revenue-snapshot-today', 'اليوم');
      _expectTitle('revenue-snapshot-month-to-date', 'منذ بداية الشهر');
    });

    testWidgets('a sparse payload shows the empty state, not a crash', (
      tester,
    ) async {
      await pump(tester, RevenueDashboard.fromJson(const {}), const Locale('en'));
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('revenue-snapshot-today')), findsNothing);
    });

    testWidgets('a zeroed payload still renders every card', (tester) async {
      await pump(
        tester,
        RevenueDashboard.fromJson(const {'today': '2026-10-18'}),
        const Locale('en'),
      );
      expect(tester.takeException(), isNull);
      for (final k in _snapshotKeys) {
        expect(find.byKey(ValueKey(k)), findsOneWidget, reason: k);
      }
    });
  });
}
