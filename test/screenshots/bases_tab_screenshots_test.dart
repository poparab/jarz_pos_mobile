// Visual harness — NOT run by CI (no workflow job globs test/screenshots).
//
// Renders the rebuilt Bases tab against production's own catalogue: the four
// fruit mixes and the ganache, which have nothing countable in their recipes and
// are made by the kilo, above the five baked bases, which the floor counts in
// eggs.
//
//   flutter test test/screenshots/bases_tab_screenshots_test.dart --update-goldens
//
// Writes PNGs to test/screenshots/shots/.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/manufacturing/data/manufacturing_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/base_item.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/base_production_tab.dart';
import 'package:jarz_pos/src/features/manufacturing/state/base_production_providers.dart';

import '../helpers/mock_services.dart';

/// Production's own bases, read live on 2026-09-12. Quantities, yields and
/// per-jar rates are the real ones, so the shots show what the floor will see.
final _page = BaseItemsPage(
  coverIncluded: true,
  items: [
    _mix(
      'Blueberry mix',
      onHand: 0.58,
      consumers: const [
        ('Blueberry Medium', 0.03),
        ('Blueberry Large', 0.04),
      ],
      status: 'low',
      daysOfCover: 2.4,
    ),
    _mix(
      'strawberry mix',
      onHand: 0.14,
      consumers: const [
        ('Strawberry Medium', 0.03),
        ('Strawberry Large', 0.04),
      ],
      status: 'critical',
      daysOfCover: 0.6,
    ),
    _mix(
      'raspberry mix',
      onHand: 0.465,
      consumers: const [
        ('Redvelvet Medium', 0.03),
        ('Redvelvet Large', 0.04),
      ],
      status: 'low',
      daysOfCover: 3.1,
    ),
    _mix(
      'Mango mix',
      onHand: 0.09,
      batchYield: 3.0,
      consumers: const [
        ('Mango Medium', 0.073),
        ('Mango Large', 0.097),
      ],
      status: 'critical',
      daysOfCover: 0.4,
    ),
    _mix(
      'Chocolate ganache',
      onHand: 2.54,
      batchYield: 5.898,
      consumers: const [
        ('Molten Medium', 0.045),
        ('Molten Large', 0.075),
      ],
      status: 'ok',
      daysOfCover: 18.0,
    ),
    _baked('Fudge Cake', yieldKg: 9.258, onHand: 18.5, eggs: 30, cover: 9.2),
    _baked('Red Velvet Cake', yieldKg: 9.278, onHand: 4.1, eggs: 30, cover: 3.0),
    _baked('Savoiardi', yieldKg: 2.5, onHand: 6.2, eggs: 30, cover: 21.0),
    _baked('Sponge Cake', yieldKg: 4.0, onHand: 1.3, eggs: 45, cover: 4.4),
    _baked('Butter Biscuit', yieldKg: 13.674, onHand: 27.3, eggs: 23, cover: 30.0),
  ],
);

BaseItem _mix(
  String code, {
  required double onHand,
  required List<(String, double)> consumers,
  double batchYield = 2.0,
  String? status,
  double? daysOfCover,
}) {
  return BaseItem(
    itemCode: code,
    itemName: code,
    stockUom: 'Kg',
    defaultBom: 'BOM-$code-001',
    batchYield: batchYield,
    onHand: onHand,
    batchesOnHand: onHand / batchYield,
    entryMode: kBaseEntryQuantity,
    status: status,
    daysOfCover: daysOfCover,
    targetDays: 14,
    consumptionPerDay: daysOfCover == null ? null : onHand / daysOfCover,
    jarConsumers: [
      for (final (jar, rate) in consumers)
        BaseJarConsumer(itemCode: jar, itemName: jar, qtyPerJar: rate),
    ],
  );
}

BaseItem _baked(
  String code, {
  required double yieldKg,
  required double onHand,
  required double eggs,
  required double cover,
}) {
  return BaseItem(
    itemCode: code,
    itemName: code,
    stockUom: 'Kg',
    defaultBom: 'BOM-$code-001',
    batchYield: yieldKg,
    onHand: onHand,
    batchesOnHand: onHand / yieldKg,
    entryMode: kBaseEntryBatch,
    batchUnit: BaseBatchUnit(
      itemCode: 'eggs',
      itemName: 'eggs',
      uom: 'piece',
      qtyPerBatch: eggs,
    ),
    status: cover < 5 ? 'low' : 'ok',
    daysOfCover: cover,
    targetDays: 14,
    consumptionPerDay: onHand / cover,
  );
}

final _flutterFonts = () {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null || root.isEmpty) return '';
  return '$root${Platform.pathSeparator}bin${Platform.pathSeparator}cache'
      '${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts';
}();

/// `flutter test` ships no fonts, so text renders as filled boxes without this.
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

  String sdkFont(String name) => _flutterFonts.isEmpty
      ? ''
      : '$_flutterFonts${Platform.pathSeparator}$name';

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
ThemeData _appTheme(Brightness brightness, {String? fontFamily}) => ThemeData(
  useMaterial3: true,
  fontFamily: fontFamily,
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

class _StubBases extends BaseItemsNotifier {
  _StubBases(this._page);
  final BaseItemsPage _page;

  @override
  Future<BaseItemsPage> build() async => _page;
}

Map<String, dynamic> _preview(double itemQty, double batchYield) => {
  'item_code': 'x',
  'bom_name': 'BOM-x',
  'batches': itemQty / batchYield,
  'batch_yield': batchYield,
  'item_qty': itemQty,
  'stock_uom': 'Kg',
  'components': const [
    {
      'item_code': 'Puratos Blueberry KG',
      'item_name': 'Puratos Blueberry KG',
      'uom': 'Kg',
      'required_qty': 0.75,
      'available_qty': 25.0,
      'shortfall': 0.0,
      'valuation_rate': 390.82,
      'estimated_amount': 293.12,
    },
    {
      'item_code': 'jelly',
      'item_name': 'jelly',
      'uom': 'Kg',
      'required_qty': 0.75,
      'available_qty': 36.621,
      'shortfall': 0.0,
      'valuation_rate': 55.0,
      'estimated_amount': 41.25,
    },
  ],
  'has_shortage': false,
  'run_size_ok': true,
  'estimated_cost': 334.37,
  'has_sop': false,
};

Future<MockDio> _pump(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final dio = MockDio();
  dio.setResponse(ApiEndpoints.previewBaseBatch, {
    'message': _preview(1.5, 2.0),
  });
  dio.setResponse(
    '/api/method/jarz_pos.api.manufacturing.get_material_options',
    {
      'message': {
        'bom_name': 'BOM-x',
        'qty': 1.5,
        'components': <Map<String, dynamic>>[],
      },
    },
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        baseItemsProvider.overrideWith(() => _StubBases(_page)),
        manufacturingServiceProvider.overrideWithValue(
          ManufacturingService(dio),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        theme: _appTheme(
          brightness,
          fontFamily: locale.languageCode == 'ar' ? 'Tajawal' : null,
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: SafeArea(child: BaseProductionTab())),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return dio;
}

Future<void> _open(WidgetTester tester, String itemCode) async {
  await tester.tap(find.text(itemCode));
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

Future<void> _shoot(WidgetTester tester, String name) =>
    expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/$name.png'));

void main() {
  setUpAll(_loadFonts);

  testWidgets('20 bases — the whole list, closed', (tester) async {
    await _pump(tester);
    await _shoot(tester, '20_bases_list');
  });

  testWidgets('21 bases — a mix open, filling jars', (tester) async {
    await _pump(tester);
    await _open(tester, 'Blueberry mix');

    await tester.enterText(find.byType(TextField).at(0), '40');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), '20');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    await _shoot(tester, '21_bases_mix_by_jars');
  });

  testWidgets('22 bases — a cake open, counted in eggs', (tester) async {
    await _pump(tester);
    // Scrolled to, because the baked group sits below five mixes.
    await tester.scrollUntilVisible(find.text('Fudge Cake'), 200);
    await tester.pumpAndSettle();
    await _open(tester, 'Fudge Cake');
    await _shoot(tester, '22_bases_cake_by_eggs');
  });

  testWidgets('23 bases — three mixes picked at once', (tester) async {
    await _pump(tester, size: const Size(390, 1200));
    await _open(tester, 'Blueberry mix');
    await _open(tester, 'strawberry mix');
    await _open(tester, 'raspberry mix');
    await _shoot(tester, '23_bases_three_at_once');
  });

  testWidgets('24 bases — Arabic RTL', (tester) async {
    await _pump(tester, locale: const Locale('ar'));
    await _open(tester, 'Blueberry mix');
    await _shoot(tester, '24_bases_arabic');
  });

  testWidgets('25 bases — dark', (tester) async {
    await _pump(tester, brightness: Brightness.dark);
    await _shoot(tester, '25_bases_dark');
  });
}
