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
          return _finalProducts;
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
        locale: const Locale('en'),
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

void main() {
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
}
