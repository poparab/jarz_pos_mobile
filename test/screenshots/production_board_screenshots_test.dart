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
import 'package:jarz_pos/src/features/manufacturing/data/models/material_options.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/production_policy.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/production_suggestion.dart';
import 'package:jarz_pos/src/features/manufacturing/data/repositories/production_basket_repository.dart';
import 'package:jarz_pos/src/features/manufacturing/data/daily_plan_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/daily_plan.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/manufacturing_screen.dart';
import 'package:jarz_pos/src/features/manufacturing/state/daily_plan_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/running_batch.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/sop.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/production_plan_tab.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/production_running_tab.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/sop_execute_screen.dart';
import 'package:jarz_pos/src/features/manufacturing/state/running_batches_notifier.dart';
import 'package:jarz_pos/src/features/manufacturing/state/sop_providers.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_basket_notifier.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_providers.dart';

import '../helpers/mock_services.dart';

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

/// The plan template that goes with [realPage].
///
/// The merged Plan tab asks two endpoints — the ranked board for the cover
/// figures and the plan template for the flavour list and the mixer — so a shot
/// that stubs only the first renders half a screen. Derived from the same
/// payload, so the two halves cannot disagree about which flavours exist.
DailyPlanTemplate _templateFor(ProductionSuggestionsPage page) {
  return DailyPlanTemplate(
    planDate: '2026-08-02',
    mix: const DailyPlanMix(
      itemCode: 'BASE-CHEESECAKE-MIX',
      batchQty: 12,
      uom: 'Kg',
    ),
    items: [
      for (final item in page.items)
        DailyPlanItem(
          itemCode: item.itemCode,
          itemName: item.itemName,
          itemGroup: item.itemGroup ?? '',
          defaultBom: item.defaultBom,
          mixQtyPerUnit: 0.1,
          jarsPerBatch: 120,
          usesMix: true,
        ),
    ],
  );
}

/// A plan service that answers without a network: the mixer split the draft
/// recomputes after every edit would otherwise reach Dio and paint an error
/// into the shot.
DailyPlanService _planService() {
  final dio = MockDio();
  dio.setResponse('/api/method/jarz_pos.api.daily_plan.preview_plan', {
    'message': {
      'mix': {'item_code': 'BASE-CHEESECAKE-MIX', 'batch_qty': 12, 'uom': 'Kg'},
      'total_mix_qty': 18.0,
      'required_batches': 1.5,
      'run_detail': [
        {'size': 1.5, 'quality': 'preferred'},
      ],
      'run_count': 1,
      'overproduction_batches': 0.0,
    },
  });
  return DailyPlanService(dio);
}

/// The day these shots are taken "on".
///
/// Every date this harness renders is measured against it, and `_shoot` pins
/// the production policy to it for every shot, so nothing here reads the
/// machine's clock. A golden that depends on `DateTime.now()` stops matching
/// the morning after it is generated, whatever the code does: shot 06 pinned
/// its basket to this day, left the policy reading the device clock, and duly
/// broke on 2026-08-03 when `isBackDated` flipped and the date bar grew its
/// "recording a past date" caption.
///
/// Fixtures date themselves from this rather than spelling out a literal, so
/// a shot cannot drift away from the day the harness thinks it is.
final _boardToday = DateTime(2026, 8, 2);

/// An operator's policy — today-only, like the shipped fallback — but with the
/// server's today pinned to [_boardToday] instead of left null.
///
/// Null is the whole bug: [ProductionPolicy.today] falls back to the device
/// clock when `serverDate` is unset, and the fallback policy every screen gets
/// while the real one loads leaves it unset.
final _boardPolicy = ProductionPolicy(serverDate: _boardToday);

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
  Duration? warmUp,
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
        // Every batch line renders a MaterialOptionsPanel, which calls the
        // real service unless stubbed — in this harness that throws and the
        // panel paints its Error/Retry card into the screenshot. Default to
        // "no alternatives", the common BOM shape, so a shot shows the board
        // rather than a failed fetch. A test needing real options overrides
        // this family again in its own `overrides`.
        materialOptionsProvider.overrideWith(
          (ref, request) async => MaterialOptions(
            bomName: request.bomName,
            qty: request.qty,
            components: const [],
          ),
        ),
        // The clock, pinned, for EVERY shot — not just the ones that render a
        // date today. `ProductionPolicy.today()` falls back to the device
        // clock whenever `serverDate` is null, which is exactly the shape of
        // the shipped fallback policy, so any shot reaching a widget that
        // asks the policy what day it is becomes a golden that expires. Both
        // seams are pinned: consumers read the fallback provider, but a
        // screen that reads the FutureProvider directly would otherwise slip
        // past the override and reach the real service.
        productionPolicyOrFallbackProvider.overrideWithValue(_boardPolicy),
        productionPolicyProvider.overrideWith((ref) async => _boardPolicy),
        // The merged Plan tab's other half, stubbed for every shot for the
        // same reason the policy is: left real, it reaches Dio.
        dailyPlanServiceProvider.overrideWithValue(_planService()),
        bomReadinessProvider.overrideWith(
          (ref) async => const BomReadiness(ok: true),
        ),
        dailyPlanTemplateProvider.overrideWith(
          (ref) async => _templateFor(realPage),
        ),
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
  // Some shots need the debounced halves of the tab to land: the mixer split is
  // recomputed 350 ms after the last edit, and the roll-up 400 ms after the
  // queue stops changing. Neither schedules a frame, so `pumpAndSettle` alone
  // returns before either has run.
  if (warmUp != null) {
    await tester.pump(warmUp);
    await tester.pumpAndSettle();
  }
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/$name.png'));
}

/// Shoots a screen that brings its own Scaffold.
///
/// [_shoot] wraps its child in a Scaffold with a stand-in app bar, which is
/// exactly the part under inspection here — the board's own bar carries the
/// link back to Today, and its TabBar is what has to fit a phone.
Future<void> _shootScreen(
  WidgetTester tester,
  String name,
  Widget screen, {
  Size size = const Size(390, 844),
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
        productionPolicyOrFallbackProvider.overrideWithValue(_boardPolicy),
        productionPolicyProvider.overrideWith((ref) async => _boardPolicy),
        dailyPlanServiceProvider.overrideWithValue(_planService()),
        bomReadinessProvider.overrideWith(
          (ref) async => const BomReadiness(ok: true),
        ),
        dailyPlanTemplateProvider.overrideWith(
          (ref) async => _templateFor(realPage),
        ),
        materialOptionsProvider.overrideWith(
          (ref, request) async => MaterialOptions(
            bomName: request.bomName,
            qty: request.qty,
            components: const [],
          ),
        ),
        ...overrides,
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _appTheme(Brightness.light),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
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
        // Empty means empty on both halves: a template still full of flavours
        // would render a form under a board that says there is nothing to do.
        dailyPlanTemplateProvider.overrideWith(
          (ref) async => const DailyPlanTemplate(),
        ),
      ],
    );
  });

  testWidgets('06 plan tab — two flavours sharing a short material',
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
      postingDate: _boardToday,
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
      '06_plan_shared_shortage',
      const ProductionPlanTab(),
      // Long enough for the mixer split and the roll-up to land.
      warmUp: const Duration(seconds: 1),
      overrides: [
        // The queue as it comes back from Hive. The tab fills the jar fields
        // from it, so this shot is the restore path as well as the shortage.
        productionBasketProvider.overrideWith(() => _SeededBasket(basket)),
        basketRollupProvider.overrideWith((ref) async => rollup),
        productionSuggestionsProvider.overrideWith(
          () => _StubSuggestions(
            ProductionSuggestionsPage(
              items: realPage.items.take(2).toList(),
              summary: realPage.summary,
              velocityUpdatedOn: realPage.velocityUpdatedOn,
            ),
          ),
        ),
        dailyPlanTemplateProvider.overrideWith(
          (ref) async => const DailyPlanTemplate(
            planDate: '2026-08-02',
            mix: DailyPlanMix(
              itemCode: 'BASE-CHEESECAKE-MIX',
              batchQty: 12,
              uom: 'Kg',
            ),
            items: [
              DailyPlanItem(
                itemCode: 'FG-RED-M',
                itemName: 'Redvelvet Medium',
                itemGroup: 'Products',
                defaultBom: 'BOM-RED-M',
                jarsPerBatch: 120,
                usesMix: true,
              ),
              DailyPlanItem(
                itemCode: 'FG-LOTUS-L',
                itemName: 'Lotus Large',
                itemGroup: 'Products',
                defaultBom: 'BOM-LOTUS-L',
                jarsPerBatch: 77,
                usesMix: true,
              ),
            ],
          ),
        ),
      ],
    );
  });

  testWidgets('07 plan tab — nothing queued yet', (tester) async {
    // The state the board opens in every morning: figures on every row, both
    // actions in reach, and not a single quantity the operator did not type.
    await _shoot(
      tester,
      '07_plan_nothing_queued',
      const ProductionPlanTab(),
      overrides: [
        productionSuggestionsProvider.overrideWith(
          () => _StubSuggestions(realPage),
        ),
      ],
    );
  });

  testWidgets('08 running tab — a batch with stranded WIP', (tester) async {
    // The case that must never be quiet: material went into WIP and did not
    // come back out.
    const batch = RunningBatch(
      workOrder: 'MFG-WO-0042',
      itemCode: 'FG-SAMPLE-01',
      itemName: 'Sample finished good 01',
      bomName: 'BOM-FG-SAMPLE-01',
      stockUom: 'Nos',
      qty: 60,
      producedQty: 24,
      status: 'In Process',
      startedBy: 'baker@jarz.test',
      startedAt: '2026-08-02 06:15:00',
      elapsedMinutes: 185,
      wipLeftoverQty: 4.5,
      sopVersion: 'SOP-0003#2',
    );

    await _shoot(
      tester,
      '08_running_wip_leftover',
      const ProductionRunningTab(),
      overrides: [
        runningBatchesProvider.overrideWith(() => _StubRunning(const [batch])),
        canManageProductionWipProvider.overrideWithValue(true),
        canExecuteProductionProvider.overrideWithValue(true),
      ],
    );
  });

  testWidgets('09 SOP step — scaled instruction with a capture', (tester) async {
    const doc = SopDocument(
      hasSop: true,
      sop: 'SOP-0003',
      version: 2,
      itemCode: 'FG-SAMPLE-01',
      itemName: 'Sample finished good 01',
      yieldPercent: 96,
      prepTimeMins: 20,
      equipment: 'Mixer, 60cm tray, probe thermometer',
      batches: 5,
      units: 60,
      totalDurationMins: 95,
      steps: [
        SopStep(
          stepNo: 1,
          title: 'Weigh and combine the dry mix',
          // The whole point of stage 3: quantities arrive already scaled for
          // the batch, so nobody multiplies anything on the bench.
          instructionText:
              'Weigh 12.500 Kg Sample raw material 01 into the mixer bowl. '
              'Add 3.750 Kg Sample raw material 02 and combine on speed 1 for '
              'two minutes until no dry pockets remain.',
          durationMins: 12,
          scalingMode: SopScaling.perBatch,
          captureType: SopCapture.temperature,
          captureLabel: 'Mix temperature',
          captureMin: 18,
          captureMax: 24,
        ),
      ],
    );

    await _shoot(
      tester,
      '09_sop_step',
      const SopExecuteScreen(
        args: SopLaunchArgs(workOrder: 'MFG-WO-0042', itemCode: 'FG-SAMPLE-01'),
      ),
      overrides: [
        sopForWorkOrderProvider('MFG-WO-0042').overrideWith((ref) async => doc),
      ],
    );
  });

  testWidgets('14 board — phone app bar and tabs', (tester) async {
    // The two links that make the board and Today one feature rather than two
    // screens: "Today" in the bar, and three legible tabs on a phone — the
    // fixed bar that replaced the scrolling five.
    await _shootScreen(
      tester,
      '14_board_phone_nav',
      const ManufacturingScreen(initialTab: kProductionPlanTabIndex),
      overrides: [
        canAccessProductionBoardProvider.overrideWithValue(true),
        productionSuggestionsProvider.overrideWith(() => _StubSuggestions(realPage)),
      ],
    );
  });
}

class _StubRunning extends RunningBatchesNotifier {
  _StubRunning(this._batches);
  final List<RunningBatch> _batches;
  @override
  Future<List<RunningBatch>> build() async => _batches;
}

class _SeededBasket extends ProductionBasketNotifier {
  _SeededBasket(this._seed);
  final ProductionBasket _seed;
  @override
  ProductionBasket build() => _seed;
}
