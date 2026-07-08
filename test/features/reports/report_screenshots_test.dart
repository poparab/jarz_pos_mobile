// Visual screenshot harness for the six analytics report dashboards.
//
// For each dashboard this test:
//   1. Loads a REAL captured fixture from `test/fixtures/reports/<x>.json`
//      (captured from staging, 90-day range) and parses it with the model's
//      `fromJson`.
//   2. Pumps the screen inside a `ProviderScope` whose family data provider is
//      overridden to return the parsed fixture for ANY range (so the network is
//      never hit and `.when(...)` renders the data state, not loading).
//   3. Renders at a phone width (~400 logical px) on a very tall surface so the
//      KPI grid AND the first data sections/charts are captured in one image.
//   4. Loads the app's bundled fonts so text renders as real glyphs (not Ahem
//      boxes), then writes a PNG to `test/goldens/reports/<name>.png`.
//
// Regenerate / refresh every PNG with:
//   flutter test --update-goldens test/features/reports/report_screenshots_test.dart
//
// The PNGs are a permanent visual regression artifact: open them to confirm the
// KPI numbers populate (they previously rendered 0 due to JSON key mismatches).

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/reports/data/models/shipping_analytics.dart';
import 'package:jarz_pos/src/features/reports/data/models/inventory_intelligence.dart';
import 'package:jarz_pos/src/features/reports/data/models/product_analytics.dart';
import 'package:jarz_pos/src/features/reports/data/models/customer_analytics.dart';
import 'package:jarz_pos/src/features/reports/data/models/executive_overview.dart';
import 'package:jarz_pos/src/features/reports/data/models/b2b_sales_clients.dart';
import 'package:jarz_pos/src/features/reports/state/reports_providers.dart';
import 'package:jarz_pos/src/features/reports/presentation/screens/shipping_analytics_screen.dart';
import 'package:jarz_pos/src/features/reports/presentation/screens/inventory_intelligence_screen.dart';
import 'package:jarz_pos/src/features/reports/presentation/screens/product_analytics_screen.dart';
import 'package:jarz_pos/src/features/reports/presentation/screens/customer_analytics_screen.dart';
import 'package:jarz_pos/src/features/reports/presentation/screens/executive_overview_screen.dart';
import 'package:jarz_pos/src/features/reports/presentation/screens/b2b_sales_clients_screen.dart';

// Phone-width, very-tall render surface (logical px). Tall enough to capture the
// KPI grid plus the first couple of data sections/charts in one image.
const double _kLogicalWidth = 400;
// Tall enough that even the Executive board (whose KPI grid sits *below* a long
// priority-alerts list) still captures the KPI numbers in one frame.
const double _kLogicalHeight = 3600;
const double _kDpr = 2.0;

// A fixed range so the date-range bar text is deterministic. The data providers
// are overridden to ignore the range entirely, so the value only affects the bar.
final _fixedRange = ReportRange(
  from: DateTime(2026, 4, 9),
  to: DateTime(2026, 7, 8),
);

Map<String, dynamic> _loadFixture(String name) {
  final file = File('test/fixtures/reports/$name.json');
  final decoded = jsonDecode(file.readAsStringSync());
  // Fixtures are already unwrapped (no Frappe `{"message": ...}` envelope), but
  // tolerate the envelope just in case a future capture keeps it.
  if (decoded is Map && decoded['message'] is Map) {
    return Map<String, dynamic>.from(decoded['message'] as Map);
  }
  return Map<String, dynamic>.from(decoded as Map);
}

Future<void> _loadAppFonts() async {
  // Load the real bundled TTFs straight off disk so glyphs render legibly in the
  // golden PNGs instead of Ahem placeholder boxes.
  final families = <String, List<String>>{
    'Inter': [
      'assets/fonts/Inter-Regular.ttf',
      'assets/fonts/Inter-Bold.ttf',
    ],
    'Tajawal': [
      'assets/fonts/Tajawal-Regular.ttf',
      'assets/fonts/Tajawal-Bold.ttf',
    ],
    'DMSerifDisplay': [
      'assets/fonts/DMSerifDisplay-Regular.ttf',
    ],
  };

  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      final bytes = File(path).readAsBytesSync();
      loader.addFont(
        Future<ByteData>.value(
          ByteData.sublistView(Uint8List.fromList(bytes)),
        ),
      );
    }
    await loader.load();
  }
}

ThemeData _buildTheme() {
  // Mirror the production app theme, but pin `fontFamily: Inter` so every glyph
  // resolves to a real, legible font in the rendered PNG.
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    // Arabic customer/territory names in the data fall back to Tajawal (Inter
    // has no Arabic glyphs) so they render as real script, not tofu boxes.
    fontFamilyFallback: const ['Tajawal'],
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 1),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  );
}

/// Pumps [screen] with [override] applied, then writes the PNG golden [name].
Future<void> _renderDashboard(
  WidgetTester tester, {
  required String name,
  required Widget screen,
  required Override override,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // Ignore the network: always yield the parsed fixture.
        override,
        // Fixed, deterministic range for the date bar.
        reportRangeProvider.overrideWith((ref) => _fixedRange),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        theme: _buildTheme(),
        home: screen,
      ),
    ),
  );

  // Let localization + fl_chart + list layout settle. Fall back to a bounded
  // pump if a lingering animation would otherwise time out pumpAndSettle.
  try {
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  } catch (_) {
    await tester.pump(const Duration(seconds: 1));
  }

  // Surface any build/render error so a broken screen is visible in test output
  // rather than silently producing a red PNG.
  final err = tester.takeException();
  if (err != null) {
    // ignore: avoid_print
    print('RENDER ERROR in "$name": $err');
  }

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../goldens/reports/$name.png'),
  );
}

void main() {
  setUpAll(() async {
    await _loadAppFonts();
  });

  setUp(() {
    // Phone width, tall surface (physical px = logical * dpr).
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    view.physicalSize = const Size(_kLogicalWidth * _kDpr, _kLogicalHeight * _kDpr);
    view.devicePixelRatio = _kDpr;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });
  });

  testWidgets('Executive Overview dashboard renders fixture', (tester) async {
    final model = ExecutiveOverview.fromJson(_loadFixture('executive_analytics'));
    await _renderDashboard(
      tester,
      name: 'executive_overview',
      screen: const ExecutiveOverviewScreen(),
      override: executiveOverviewProvider.overrideWith((ref, range) => model),
    );
  });

  testWidgets('Shipping Analytics dashboard renders fixture', (tester) async {
    final model = ShippingAnalytics.fromJson(_loadFixture('shipping_analytics'));
    await _renderDashboard(
      tester,
      name: 'shipping_analytics',
      screen: const ShippingAnalyticsScreen(),
      override: shippingAnalyticsProvider.overrideWith((ref, range) => model),
    );
  });

  testWidgets('Inventory Intelligence dashboard renders fixture', (tester) async {
    final model =
        InventoryIntelligence.fromJson(_loadFixture('inventory_analytics'));
    await _renderDashboard(
      tester,
      name: 'inventory_intelligence',
      screen: const InventoryIntelligenceScreen(),
      override:
          inventoryIntelligenceProvider.overrideWith((ref, range) => model),
    );
  });

  testWidgets('Product Analytics dashboard renders fixture', (tester) async {
    final model = ProductAnalytics.fromJson(_loadFixture('product_analytics'));
    await _renderDashboard(
      tester,
      name: 'product_analytics',
      screen: const ProductAnalyticsScreen(),
      override: productAnalyticsProvider.overrideWith((ref, range) => model),
    );
  });

  testWidgets('Customer Analytics dashboard renders fixture', (tester) async {
    final model = CustomerAnalytics.fromJson(_loadFixture('customer_analytics'));
    await _renderDashboard(
      tester,
      name: 'customer_analytics',
      screen: const CustomerAnalyticsScreen(),
      override: customerAnalyticsProvider.overrideWith((ref, range) => model),
    );
  });

  testWidgets('B2B Sales & Clients dashboard renders fixture', (tester) async {
    final model = B2bSalesAnalytics.fromJson(_loadFixture('b2b_analytics'));
    await _renderDashboard(
      tester,
      name: 'b2b_sales_clients',
      screen: const B2bSalesClientsScreen(),
      override: b2bSalesClientsProvider.overrideWith((ref, range) => model),
    );
  });
}
