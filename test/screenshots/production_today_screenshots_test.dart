// Visual harness for the Today screen — NOT run by CI (no workflow job globs
// test/screenshots).
//
// Renders the collapsed floor screen against data shaped like production's
// (18 fillable jars, 9 bases), so the thing the review argued for can be
// looked at rather than only asserted on.
//
//   flutter test test/screenshots/production_today_screenshots_test.dart --update-goldens
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
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/daily_plan_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/manufacturing_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/base_item.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/daily_plan.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/production_policy.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/running_batch.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/production_today_screen.dart';
import 'package:jarz_pos/src/features/manufacturing/state/base_production_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/daily_plan_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/running_batches_notifier.dart';

import '../helpers/mock_services.dart';

/// Real production names, so the shot is judged on the layout the floor will
/// actually meet rather than on "Sample finished good 01".
DailyPlanItem _jar(String code, String name, {double jarsPerBatch = 120}) =>
    DailyPlanItem(
      itemCode: code,
      itemName: name,
      itemGroup: 'Medium',
      defaultBom: 'BOM-$code-001',
      mixQtyPerUnit: 0.0793,
      jarsPerBatch: jarsPerBatch,
      usesMix: true,
    );

const _mix = DailyPlanMix(
  itemCode: 'Cheesecake Mix',
  defaultBom: 'BOM-Cheesecake Mix-007',
  batchQty: 9.52,
  uom: 'Kg',
);

final _template = DailyPlanTemplate(
  planDate: '2026-09-08',
  mix: _mix,
  items: [
    _jar('FG-LOTUS-M', 'Lotus Medium'),
    _jar('FG-BLUE-M', 'Blueberry Medium'),
    _jar('FG-RED-M', 'Redvelvet Medium'),
    _jar('FG-LOTUS-L', 'Lotus Large', jarsPerBatch: 77),
    _jar('FG-MANGO-L', 'Mango Large', jarsPerBatch: 146),
  ],
);

BaseItem _base(
  String name, {
  required double batchYield,
  required double onHand,
  double needed = 0,
  int? canMakeNow,
}) => BaseItem(
  itemCode: name,
  itemName: name,
  stockUom: 'Kg',
  defaultBom: 'BOM-$name-001',
  batchYield: batchYield,
  onHand: onHand,
  batchesOnHand: onHand / batchYield,
  canMakeNowBatches: canMakeNow,
  demand: needed > 0
      ? BaseDemand(batchesRequired: needed, driver: "today's plan")
      : null,
);

/// Mirrors what production answers today: Fudge Cake well stocked, Red Velvet
/// effectively empty, Mango mix blocked on materials.
final _bases = BaseItemsPage(
  company: 'JARZ',
  demandSource: BaseDemandSource.plan,
  items: [
    _base('Fudge Cake', batchYield: 9.258, onHand: 25.14, needed: 1, canMakeNow: 3),
    _base('Butter Biscuit', batchYield: 13.674, onHand: 4.336, needed: 2, canMakeNow: 2),
    _base('Red Velvet Cake', batchYield: 9.278, onHand: 0.031, needed: 2, canMakeNow: 1),
    _base('Chocolate ganache', batchYield: 5.898, onHand: 2.534, canMakeNow: 2),
    _base('Mango mix', batchYield: 3.0, onHand: 0.09, needed: 1, canMakeNow: 0),
  ],
  summary: const BaseItemsSummary(total: 5, shortOfDemand: 3, blockedByMaterials: 1),
);

const _running = RunningBatch(
  workOrder: 'MFG-WO-jarz-2026-00031',
  itemCode: 'Butter Biscuit',
  itemName: 'Butter Biscuit',
  status: 'In Process',
  qty: 27.348,
);

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
  String name, {
  Size size = const Size(390, 844),
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
  List<RunningBatch> running = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final dio = MockDio();
  dio.setResponse(ApiEndpoints.dailyPlanPreview, {
    'message': {
      'mix': {
        'item_code': 'Cheesecake Mix',
        'batch_qty': 9.52,
        'uom': 'Kg',
      },
      'total_mix_qty': 14.28,
      'required_batches': 1.5,
      'planned_batches': 1.5,
      'run_detail': [
        {'size': 1.5, 'quality': 'preferred'},
      ],
      'run_count': 1,
    },
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        canAccessProductionBoardProvider.overrideWithValue(true),
        canExecuteProductionProvider.overrideWithValue(true),
        productionPolicyProvider.overrideWith(
          (ref) async => const ProductionPolicy(canExecute: true),
        ),
        baseItemsProvider.overrideWith(() => _StubBases(_bases)),
        dailyPlanTemplateProvider.overrideWith((ref) async => _template),
        runningBatchesProvider.overrideWith(() => _StubRunning(running)),
        manufacturingServiceProvider.overrideWithValue(ManufacturingService(dio)),
        dailyPlanServiceProvider.overrideWithValue(DailyPlanService(dio)),
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
        home: const ProductionTodayScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('shots/$name.png'),
  );
}

class _StubBases extends BaseItemsNotifier {
  _StubBases(this._page);
  final BaseItemsPage _page;

  @override
  Future<BaseItemsPage> build() async => _page;
}

class _StubRunning extends RunningBatchesNotifier {
  _StubRunning(this._batches);
  final List<RunningBatch> _batches;

  @override
  Future<List<RunningBatch>> build() async => _batches;
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('10 today — phone, light', (tester) async {
    await _shoot(tester, '10_today_phone_light');
  });

  testWidgets('11 today — with a batch still open', (tester) async {
    await _shoot(tester, '11_today_open_batch', running: const [_running]);
  });

  testWidgets('12 today — Arabic RTL', (tester) async {
    await _shoot(tester, '12_today_arabic', locale: const Locale('ar'));
  });

  testWidgets('13 today — tablet', (tester) async {
    await _shoot(tester, '13_today_tablet', size: const Size(1024, 1366));
  });
}
