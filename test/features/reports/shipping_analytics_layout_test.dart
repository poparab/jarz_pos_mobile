// Shipping Analytics on a phone: the complaints from 2026-09-27, pinned.
//
// - KPI cards sat one per row (the grid measured the width before the list's
//   padding, so two cards never fit).
// - Alerts were a wall of per-area lines; now summaries, three at a time.
// - Courier overrides were a long per-order list; now a money summary.
// - Every report gets a "Last Month" range.
//
// Fixture: production 2026-09-01..27 (staff emails and reasons stripped).

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/reports/data/models/shipping_analytics.dart';
import 'package:jarz_pos/src/features/reports/presentation/screens/shipping_analytics_screen.dart';
import 'package:jarz_pos/src/features/reports/presentation/widgets/kpi_card.dart';
import 'package:jarz_pos/src/features/reports/state/reports_providers.dart';

ShippingAnalytics _fixture() => ShippingAnalytics.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(
          File('test/fixtures/reports/shipping_analytics.json')
              .readAsStringSync(),
        ) as Map,
      ),
    );

Future<void> _pump(WidgetTester tester, ShippingAnalytics data,
    {List<Map<String, dynamic>>? alerts}) async {
  tester.view.physicalSize = const Size(360 * 3, 8000 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final model = alerts == null
      ? data
      : data.copyWith(
          alerts: [for (final a in alerts) ShippingAlert.fromJson(a)],
        );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        shippingAnalyticsProvider.overrideWith((ref, range) => model),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const ShippingAnalyticsScreen(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('KPI cards sit two per row on a 360dp phone', (tester) async {
    await _pump(tester, _fixture());
    expect(tester.takeException(), isNull);
    final cards = find.byType(KpiCard);
    expect(cards, findsWidgets);
    final first = tester.getTopLeft(cards.at(0));
    final second = tester.getTopLeft(cards.at(1));
    expect(second.dy, first.dy, reason: 'second KPI card wrapped to a new row');
    expect(second.dx, greaterThan(first.dx));
  });

  testWidgets('alerts show three, the rest behind Show all', (tester) async {
    final many = [
      for (var i = 0; i < 7; i++)
        {'type': 'warning', 'message': 'Alert number $i'},
    ];
    await _pump(tester, _fixture(), alerts: many);
    expect(find.text('Alert number 2'), findsOneWidget);
    expect(find.text('Alert number 3'), findsNothing);
    await tester.tap(find.text('Show all (7)'));
    await tester.pump();
    expect(find.text('Alert number 6'), findsOneWidget);
    expect(find.text('Show less'), findsOneWidget);
  });

  testWidgets('overrides are a money summary, not an order list',
      (tester) async {
    final data = _fixture();
    await _pump(tester, data);
    expect(tester.takeException(), isNull);
    expect(find.text('Courier cost overrides'), findsOneWidget);
    expect(find.text('Net extra paid'), findsOneWidget);
    expect(find.text('EGP4,187.00'), findsOneWidget);
    expect(find.text('Where the extra goes'), findsOneWidget);
    // No per-order rows any more (they carried the order id).
    final anyRow = data.customShippingBreakdown.rows.first;
    expect(find.text(anyRow.displayId), findsNothing);
  });

  test('the override summary adds up', () {
    final s = _fixture().customShippingBreakdown.summary;
    expect(s.netEffect, closeTo(s.approvedExtra - s.approvedSaved, 0.01));
    expect(s.approved + s.rejected + s.pending, s.total);
  });

  group('ReportRange.lastMonth', () {
    test('mid-month', () {
      final r = ReportRange.lastMonth(DateTime(2026, 9, 27));
      expect(r.fromIso, '2026-08-01');
      expect(r.toIso, '2026-08-31');
    });
    test('January rolls back to December', () {
      final r = ReportRange.lastMonth(DateTime(2027, 1, 5));
      expect(r.fromIso, '2026-12-01');
      expect(r.toIso, '2026-12-31');
    });
    test('March gets February', () {
      final r = ReportRange.lastMonth(DateTime(2028, 3, 31));
      expect(r.fromIso, '2028-02-01');
      expect(r.toIso, '2028-02-29');
    });
  });
}
