// Visual harness — NOT run by CI (no workflow job globs test/screenshots).
//
// Renders the Production Board screens against a scrubbed copy of a real
// staging payload, so the UI can be inspected rather than merely asserted on.
//
//   flutter test test/screenshots --update-goldens
//
// Writes PNGs to test/screenshots/shots/.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/basket_rollup.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/batch_line.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/bom_details.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/production_suggestion.dart';
import 'package:jarz_pos/src/features/manufacturing/data/repositories/production_basket_repository.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/production_batch_tab.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/production_plan_tab.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_basket_notifier.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_providers.dart';

class _FakeBasketRepository implements ProductionBasketRepository {
  @override
  Future<ProductionBasket?> load() async => null;
  @override
  Future<void> save(ProductionBasket basket) async {}
  @override
  Future<void> clear() async {}
}

class _StubSuggestions extends ProductionSuggestionsNotifier {
  _StubSuggestions(this._page);
  final ProductionSuggestionsPage _page;
  @override
  Future<ProductionSuggestionsPage> build() async => _page;
}

late final ProductionSuggestionsPage realPage;

/// Derived from FLUTTER_ROOT (set by `flutter test`) rather than hardcoded, so
/// this renders the same on any machine. Falls back to boxes if unresolved.
final _flutterFonts = () {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null || root.isEmpty) return '';
  return '$root${Platform.pathSeparator}bin${Platform.pathSeparator}cache'
      '${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts';
}();

/// `flutter test` ships no fonts, so text renders as filled boxes. Load the
/// real ones — including the app's bundled Inter and Tajawal — so these
/// screenshots show what a user actually sees.
Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final present =
        paths.where((p) => p.isNotEmpty && File(p).existsSync()).toList();
    if (present.isEmpty) return;
    final loader = FontLoader(family);
    for (final path in present) {
      loader.addFont(
        Future.value(File(path).readAsBytesSync().buffer.asByteData()),
      );
    }
    await loader.load();
  }

  String sdkFont(String name) =>
      _flutterFonts.isEmpty ? '' : '$_flutterFonts${Platform.pathSeparator}$name';

  await load('Roboto', [
    sdkFont('roboto-regular.ttf'),
    sdkFont('roboto-medium.ttf'),
    sdkFont('roboto-bold.ttf'),
  ]);
  await load('MaterialIcons', [sdkFont('materialicons-regular.otf')]);
  await load('Inter', [
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Bold.ttf',
  ]);
  await load('Tajawal', [
    'assets/fonts/Tajawal-Regular.ttf',
    'assets/fonts/Tajawal-Bold.ttf',
  ]);
}

/// Mirrors `lib/src/core/app.dart` so the shots match the real app chrome.
ThemeData _appTheme(Brightness brightness) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: brightness,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 1),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );

Future<void> _shoot(
  WidgetTester tester,
  String name,
  Widget child, {
  Size size = const Size(390, 844),
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        productionBasketRepositoryProvider
            .overrideWithValue(_FakeBasketRepository()),
        ...overrides,
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        theme: _appTheme(brightness),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: AppBar(title: const Text('Production Board')),
          body: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/$name.png'));
}

void main() {
  setUpAll(() async {
    await _loadFonts();
    final raw = File('test/screenshots/staging_payload.json').readAsStringSync();
    realPage = ProductionSuggestionsPage.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  });

  testWidgets('01 plan tab — phone, light, real staging data', (tester) async {
    await _shoot(
      tester,
      '01_plan_phone_light',
      const ProductionPlanTab(),
      overrides: [
        productionSuggestionsProvider.overrideWith(() => _StubSuggestions(realPage)),
      ],
    );
  });

  testWidgets('02 plan tab — phone, dark', (tester) async {
    await _shoot(
      tester,
      '02_plan_phone_dark',
      const ProductionPlanTab(),
      brightness: Brightness.dark,
      overrides: [
        productionSuggestionsProvider.overrideWith(() => _StubSuggestions(realPage)),
      ],
    );
  });

  testWidgets('03 plan tab — Arabic RTL', (tester) async {
    await _shoot(
      tester,
      '03_plan_phone_arabic',
      const ProductionPlanTab(),
      locale: const Locale('ar'),
      overrides: [
        productionSuggestionsProvider.overrideWith(() => _StubSuggestions(realPage)),
      ],
    );
  });

  testWidgets('04 plan tab — tablet', (tester) async {
    await _shoot(
      tester,
      '04_plan_tablet',
      const ProductionPlanTab(),
      size: const Size(1024, 1366),
      overrides: [
        productionSuggestionsProvider.overrideWith(() => _StubSuggestions(realPage)),
      ],
    );
  });

  testWidgets('05 plan tab — empty board, velocity never run', (tester) async {
    await _shoot(
      tester,
      '05_plan_empty',
      const ProductionPlanTab(),
      overrides: [
        productionSuggestionsProvider.overrideWith(
          () => _StubSuggestions(const ProductionSuggestionsPage()),
        ),
      ],
    );
  });

  testWidgets('06 batch tab — two lines sharing a short material',
      (tester) async {
    // The exact case the old per-line check could not see.
    const flourA = BomComponent(
      itemCode: 'RM-FLOUR',
      itemName: 'Flour',
      uom: 'Kg',
      qtyPerBom: 1.2,
      sourceWarehouse: 'Stores - J',
    );
    const cream = BomComponent(
      itemCode: 'RM-CREAM',
      itemName: 'Cream',
      uom: 'L',
      qtyPerBom: 0.4,
      sourceWarehouse: 'Stores - J',
    );

    final basket = ProductionBasket(
      postingDate: DateTime(2026, 8, 2),
      lines: const [
        BatchLine(
          itemCode: 'FG-RED-M',
          itemName: 'Redvelvet Medium',
          bomName: 'BOM-RED-M',
          stockUom: 'Nos',
          bomQtyYield: 12,
          batches: 5,
          components: [flourA, cream],
        ),
        BatchLine(
          itemCode: 'FG-LOTUS-L',
          itemName: 'Lotus Large',
          bomName: 'BOM-LOTUS-L',
          stockUom: 'Nos',
          bomQtyYield: 8,
          batches: 4,
          components: [flourA],
        ),
      ],
    );

    const rollup = BasketRollup(
      ok: false,
      lineCount: 2,
      components: [
        RollupComponent(
          itemCode: 'RM-FLOUR',
          itemName: 'Flour',
          uom: 'Kg',
          sourceWarehouse: 'Stores - J',
          requiredQty: 10.8,
          availableQty: 7.0,
          missingQty: 3.8,
          reason: 'insufficient_stock',
          contributingLines: [
            ContributingLine(lineIndex: 0, itemCode: 'FG-RED-M', requiredQty: 6.0),
            ContributingLine(lineIndex: 1, itemCode: 'FG-LOTUS-L', requiredQty: 4.8),
          ],
        ),
        RollupComponent(
          itemCode: 'RM-CREAM',
          itemName: 'Cream',
          uom: 'L',
          sourceWarehouse: 'Stores - J',
          requiredQty: 2.0,
          availableQty: 40.0,
          contributingLines: [
            ContributingLine(lineIndex: 0, itemCode: 'FG-RED-M', requiredQty: 2.0),
          ],
        ),
      ],
      shortages: [
        RollupComponent(
          itemCode: 'RM-FLOUR',
          itemName: 'Flour',
          uom: 'Kg',
          sourceWarehouse: 'Stores - J',
          requiredQty: 10.8,
          availableQty: 7.0,
          missingQty: 3.8,
          reason: 'insufficient_stock',
        ),
      ],
      maxFeasibleScale: 0.648,
    );

    await _shoot(
      tester,
      '06_batch_shared_shortage',
      const ProductionBatchTab(),
      overrides: [
        productionBasketProvider.overrideWith(() => _SeededBasket(basket)),
        basketRollupProvider.overrideWith((ref) async => rollup),
      ],
    );
  });

  testWidgets('07 batch tab — empty', (tester) async {
    await _shoot(tester, '07_batch_empty', const ProductionBatchTab());
  });
}

class _SeededBasket extends ProductionBasketNotifier {
  _SeededBasket(this._seed);
  final ProductionBasket _seed;
  @override
  ProductionBasket build() => _seed;
}
