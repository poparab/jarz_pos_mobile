import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/reports/presentation/screens/stock_reports_screen.dart';
import 'package:jarz_pos/src/features/reports/state/reports_providers.dart';

const _finalProducts = <String, dynamic>{
  'groups': [
    {
      'group_name': 'Jars',
      'warehouses': ['Maadi - JB'],
      'items': [
        {
          'item_name': 'Chocolate Jar',
          'warehouse_qty': {'Maadi - JB': 4},
          'total_qty': 4,
          'stock_value': 400,
        },
      ],
      'totals': {'qty': 4, 'stock_value': 400},
    },
  ],
  'totals': {'qty': 4, 'stock_value': 400},
};

/// The same report from a server that sends days of cover.
const _finalProductsWithCover = <String, dynamic>{
  'cover': {'sales_days': 14, 'red_below': 3, 'green_above': 7},
  'groups': [
    {
      'group_name': 'Jars',
      'warehouses': ['Maadi - JB', 'Zamalek - JB', 'Nasr - JB'],
      'items': [
        {
          'item_name': 'Chocolate Jar',
          'warehouse_qty': {'Maadi - JB': 4, 'Zamalek - JB': 20, 'Nasr - JB': 0},
          'total_qty': 24,
          'stock_value': 2400,
          // Maadi amber, Zamalek green, Nasr empty (red).
          // (Nasr sells it, so the backend reports 0.0 cover, not null.)
          'days_cover': {'Maadi - JB': 4.5, 'Zamalek - JB': 10.0, 'Nasr - JB': 0.0},
          'total_days_cover': 2.0,
          'sells_per_day': {'Maadi - JB': 1.0, 'Zamalek - JB': 2.0, 'Nasr - JB': 0.5},
          'total_sells_per_day': 3.5,
        },
        {
          'item_name': 'Vanilla Jar',
          'warehouse_qty': {'Maadi - JB': 5, 'Zamalek - JB': 5, 'Nasr - JB': 5},
          'total_qty': 15,
          'stock_value': 1500,
          // No recent sales anywhere: left untinted.
          'days_cover': {'Maadi - JB': null, 'Zamalek - JB': null, 'Nasr - JB': null},
          'total_days_cover': null,
          'sells_per_day': {'Maadi - JB': 0, 'Zamalek - JB': 0, 'Nasr - JB': 0},
          'total_sells_per_day': 0,
        },
      ],
      'totals': {'qty': 39, 'stock_value': 3900},
    },
  ],
  'totals': {'qty': 39, 'stock_value': 3900},
};

const _materials = <String, dynamic>{
  'raw_materials': [
    {
      'item_name': 'Flour',
      'stock_uom': 'Kg',
      'total_qty': 10,
      'stock_value': 250,
      'warehouse_qty': {'Maadi - JB': 10},
    },
  ],
  'sub_assemblies': [],
  'consumables': [],
  'bucket_totals': {
    'raw_materials': {'qty': 10, 'stock_value': 250},
  },
  'totals': {'qty': 10, 'stock_value': 250},
};

Future<List<String?>> _pump(
  WidgetTester tester, {
  required int initialTab,
  bool singleReport = true,
  List<String> roles = const ['JARZ Manager'],
  Object? error,
  Map<String, dynamic> finalProducts = _finalProducts,
  Locale locale = const Locale('en'),
}) async {
  final view = tester.view;
  view.physicalSize = const Size(400 * 2, 1600 * 2);
  view.devicePixelRatio = 2;
  addTearDown(view.resetPhysicalSize);
  addTearDown(view.resetDevicePixelRatio);

  final requested = <String?>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        finalProductsReportProvider.overrideWith((ref, branch) async {
          requested.add(branch);
          if (error != null) throw error;
          return finalProducts;
        }),
        materialsReportProvider.overrideWith((ref, branch) async {
          requested.add(branch);
          if (error != null) throw error;
          return _materials;
        }),
        reportBranchesProvider.overrideWith((ref) => const []),
        reportBranchProvider.overrideWith((ref) => 'Maadi'),
        userRolesFutureProvider.overrideWith(
          (ref) async => UserRoles(user: 'u@jarz.pos', roles: roles),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: StockReportsScreen(
          initialTab: initialTab,
          singleReport: singleReport,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return requested;
}

/// Every tinted cell background in the Final Products table.
List<Color> _tints(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(DataTable),
        matching: find.byType(DecoratedBox),
      ),
    )
    .map((d) => d.decoration)
    .whereType<BoxDecoration>()
    .map((d) => d.color)
    .whereType<Color>()
    .where((c) => c.a > 0.1 && c.a < 0.25)
    .toList();

void main() {
  group('coverTone', () {
    test('nothing on hand is red when the item sells there', () {
      expect(coverTone(0, 0, 3, 7), CoverTone.red);
      expect(coverTone(-2, 30, 3, 7), CoverTone.red);
    });
    test('nothing on hand where it never sells is untinted', () {
      expect(coverTone(0, null, 3, 7), CoverTone.none);
      expect(coverTone(-2, null, 3, 7), CoverTone.none);
    });
    test('no recent sales is untinted', () {
      expect(coverTone(5, null, 3, 7), CoverTone.none);
    });
    test('thresholds: < red_below red, up to green_above amber, above green',
        () {
      expect(coverTone(5, 2.9, 3, 7), CoverTone.red);
      expect(coverTone(5, 3, 3, 7), CoverTone.amber);
      expect(coverTone(5, 7, 3, 7), CoverTone.amber);
      expect(coverTone(5, 7.1, 3, 7), CoverTone.green);
    });
    test('thresholds come from the payload, defaulting to 3 and 7', () {
      final d = CoverThresholds.fromJson(null);
      expect(d.redBelow, 3);
      expect(d.greenAbove, 7);
      final c = CoverThresholds.fromJson({'red_below': 2, 'green_above': 10});
      expect(c.redBelow, 2);
      expect(c.greenAbove, 10);
      expect(coverTone(5, 8, c.redBelow, c.greenAbove), CoverTone.amber);
    });
  });

  testWidgets('single Final Products report: branch, value and totals',
      (tester) async {
    final requested = await _pump(tester, initialTab: 0);

    expect(find.byType(TabBar), findsNothing);
    expect(find.text('Final Products'), findsOneWidget);
    // The selected branch reaches the provider.
    expect(requested, contains('Maadi'));
    expect(find.text('Chocolate Jar'), findsOneWidget);
    expect(find.text('Grand total'), findsOneWidget);
    expect(find.text('Stock value'), findsWidgets);
  });

  testWidgets('single Materials report shows bucket totals', (tester) async {
    await _pump(tester, initialTab: 1);

    expect(find.byType(TabBar), findsNothing);
    expect(find.text('Materials & Consumables'), findsOneWidget);
    expect(find.text('Flour'), findsOneWidget);
    expect(find.text('Grand total'), findsOneWidget);
    expect(find.textContaining('Total qty'), findsWidgets);
  });

  testWidgets('tabbed mode never offers Final Products to a materials-only '
      'user', (tester) async {
    await _pump(tester, initialTab: 0, singleReport: false, roles: const []);

    expect(find.byType(TabBar), findsNothing);
    expect(find.text('Materials & Consumables'), findsOneWidget);
    expect(find.text('Chocolate Jar'), findsNothing);
  });

  testWidgets('a branch without a stock warehouse shows the error view',
      (tester) async {
    await _pump(
      tester,
      initialTab: 0,
      error: Exception('No stock warehouse configured for Maadi'),
    );

    expect(find.text("Couldn't load report"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('an older server without days of cover: no legend, no tints',
      (tester) async {
    await _pump(tester, initialTab: 0);
    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('final-products-cover-legend')),
      findsNothing,
    );
    expect(_tints(tester), isEmpty);
  });

  testWidgets('days of cover: legend and green / amber / red cells',
      (tester) async {
    await _pump(
      tester,
      initialTab: 0,
      finalProducts: _finalProductsWithCover,
    );
    expect(tester.takeException(), isNull);

    final legend = find.byKey(const ValueKey('final-products-cover-legend'));
    expect(legend, findsOneWidget);
    for (final label in ['Days cover', '< 3', '3–7', '> 7', 'No sales']) {
      expect(
        find.descendant(of: legend, matching: find.text(label)),
        findsOneWidget,
        reason: label,
      );
    }

    // Chocolate: Maadi amber, Zamalek green, Nasr red (empty), total red
    // (2 days). Vanilla: no sales, nothing tinted.
    final tints = _tints(tester);
    expect(tints, hasLength(4));
    Color hue(Color c) => c.withValues(alpha: 1);
    expect(tints.map(hue).toSet(), {
      const Color(0xFFFFA000),
      const Color(0xFF43A047),
      const Color(0xFFE53935),
    });
    expect(
      tints.where((c) => hue(c) == const Color(0xFFE53935)),
      hasLength(2),
    );

    // The tooltip carries the days of cover.
    expect(find.byTooltip('Maadi: 4\n4.5 days cover'), findsOneWidget);
    expect(find.byTooltip('Maadi: 5\nNo sales yet'), findsOneWidget);
  });

  testWidgets('days of cover legend fits a phone in Arabic', (tester) async {
    await _pump(
      tester,
      initialTab: 0,
      finalProducts: _finalProductsWithCover,
      locale: const Locale('ar'),
    );
    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('final-products-cover-legend')),
      findsOneWidget,
    );
  });
}
