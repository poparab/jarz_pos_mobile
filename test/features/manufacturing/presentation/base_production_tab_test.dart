import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/manufacturing/data/manufacturing_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/base_item.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/base_production_tab.dart';
import 'package:jarz_pos/src/features/manufacturing/state/base_production_providers.dart';

import '../../../helpers/mock_services.dart';

BaseItem _base({
  String itemCode = 'BASE-FUDGE',
  String itemName = 'Fudge Cake',
  double batchYield = 9.52,
  double onHand = 17.136,
  double batchesOnHand = 1.8,
  bool stockIsNegative = false,
  int? canMakeNowBatches,
  List<double>? runSizes,
  BaseDemand? demand,
  bool hasSop = false,
}) {
  return BaseItem(
    itemCode: itemCode,
    itemName: itemName,
    stockUom: 'Kg',
    defaultBom: 'BOM-$itemCode-001',
    batchYield: batchYield,
    onHand: onHand,
    stockIsNegative: stockIsNegative,
    batchesOnHand: batchesOnHand,
    canMakeNowBatches: canMakeNowBatches,
    runSizes: runSizes,
    demand: demand,
    hasSop: hasSop,
  );
}

class _StubBaseItemsNotifier extends BaseItemsNotifier {
  _StubBaseItemsNotifier(this._page);
  final BaseItemsPage _page;

  @override
  Future<BaseItemsPage> build() async => _page;
}

/// Pumps the tab with a canned list and (optionally) a canned preview.
///
/// The preview is deliberately keyed at `batches: 1`, matching the stepper's
/// starting value — a preview taken at a different count is treated as stale by
/// the card and must not drive the Start button.
Future<MockDio> _pump(
  WidgetTester tester,
  BaseItemsPage page, {
  Map<String, dynamic>? preview,
  Locale? locale,
}) async {
  final dio = MockDio();
  if (preview != null) {
    dio.setResponse(ApiEndpoints.previewBaseBatch, {'message': preview});
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        manufacturingServiceProvider.overrideWithValue(ManufacturingService(dio)),
        baseItemsProvider.overrideWith(() => _StubBaseItemsNotifier(page)),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: const Scaffold(body: BaseProductionTab()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  // Lets the card's debounced first preview fire.
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
  return dio;
}

Map<String, dynamic> _preview({
  double batches = 1,
  bool hasShortage = false,
  List<Map<String, dynamic>> components = const [],
  bool runSizeOk = true,
  List<double>? runSizes,
}) {
  return {
    'item_code': 'BASE-FUDGE',
    'bom_name': 'BOM-BASE-FUDGE-001',
    'batches': batches,
    'batch_yield': 9.52,
    'item_qty': batches * 9.52,
    'stock_uom': 'Kg',
    'components': components,
    'has_shortage': hasShortage,
    'run_size_ok': runSizeOk,
    if (runSizes != null) 'run_sizes': runSizes,
    'has_sop': false,
  };
}

/// The batch count currently in the stepper's field.
String _stepperText(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText)).controller.text;

/// The label of the single selected run-size chip, or null when none is.
String? _selectedRunSize(WidgetTester tester) {
  for (final chip in tester.widgetList<ChoiceChip>(find.byType(ChoiceChip))) {
    if (chip.selected) return (chip.label as Text).data;
  }
  return null;
}

void main() {
  testWidgets('shows what one batch yields and the freezer position',
      (tester) async {
    await _pump(
      tester,
      BaseItemsPage(items: [_base()]),
      preview: _preview(),
    );

    expect(find.text('Fudge Cake'), findsOneWidget);
    expect(find.text('1 batch = 9.52 Kg'), findsOneWidget);
    // Read back as batches, which is what the mixer operator counts in.
    expect(find.text('1.8 batches'), findsOneWidget);
    expect(find.text('17.14 Kg'), findsOneWidget);
  });

  testWidgets('a base with no demand still gets an action panel',
      (tester) async {
    // The whole point of the tab: the sales board hides its panel behind
    // `suggestedBatches > 0`, which is always zero for something never sold.
    await _pump(
      tester,
      BaseItemsPage(items: [_base()]),
      preview: _preview(),
    );

    expect(find.widgetWithText(FilledButton, 'Start batch'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Start batch'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('negative freezer stock is called out', (tester) async {
    await _pump(
      tester,
      BaseItemsPage(
        items: [_base(onHand: -4.2, batchesOnHand: -0.44, stockIsNegative: true)],
      ),
      preview: _preview(),
    );

    expect(find.text('Stock is negative — count this item'), findsOneWidget);
  });

  testWidgets('the demand hint reads as a hint, and never fills the stepper',
      (tester) async {
    await _pump(
      tester,
      BaseItemsPage(
        demandSource: BaseDemandSource.plan,
        items: [
          _base(
            demand: const BaseDemand(
              qtyRequired: 30.464,
              batchesRequired: 3.2,
              shortfallBatches: 1.4,
              driver: 'the day plan',
            ),
          ),
        ],
      ),
      preview: _preview(),
    );

    expect(
      find.text('The plan needs 3.2 batches · you have 1.8'),
      findsOneWidget,
    );
    expect(find.text('from the day plan'), findsOneWidget);

    // The stepper still starts at 1 — demand is offered, never applied.
    expect(_stepperText(tester), '1');
    // 1.4 batches short rounds UP to a runnable 1.5.
    expect(find.text('Use 1.5'), findsOneWidget);
  });

  testWidgets('tapping the demand offer moves the stepper to it',
      (tester) async {
    await _pump(
      tester,
      BaseItemsPage(
        demandSource: BaseDemandSource.plan,
        items: [
          _base(
            demand: const BaseDemand(
              batchesRequired: 3.2,
              shortfallBatches: 1.4,
            ),
          ),
        ],
      ),
      preview: _preview(),
    );

    await tester.tap(find.text('Use 1.5'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(_stepperText(tester), '1.5');
  });

  testWidgets('run sizes render as chips and select on tap', (tester) async {
    await _pump(
      tester,
      BaseItemsPage(items: [_base(runSizes: const [1, 1.5, 2])]),
      preview: _preview(runSizes: const [1, 1.5, 2]),
    );

    expect(find.text('Mixer runs'), findsOneWidget);
    // Bare figures under the header — not "1 batches".
    expect(find.widgetWithText(ChoiceChip, '1'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '1.5'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '2'), findsOneWidget);

    expect(_selectedRunSize(tester), '1', reason: 'the stepper starts on 1');

    await tester.tap(find.widgetWithText(ChoiceChip, '2'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // The stepper follows the chip, and the selection moves with it.
    expect(_stepperText(tester), '2');
    expect(_selectedRunSize(tester), '2');
  });

  testWidgets('an off-grid figure warns but does not block the start',
      (tester) async {
    await _pump(
      tester,
      BaseItemsPage(items: [_base(runSizes: const [1, 1.5, 2])]),
      preview: _preview(runSizeOk: false, runSizes: const [1, 1.5, 2]),
    );

    expect(
      find.text("Not one of the mixer's usual runs — double-check before mixing"),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Start batch'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('a shortage names the component and offers a runnable number',
      (tester) async {
    await _pump(
      tester,
      BaseItemsPage(items: [_base(canMakeNowBatches: 0)]),
      preview: _preview(
        hasShortage: true,
        components: const [
          {
            'item_code': 'RM-COCOA',
            'item_name': 'Cocoa',
            'uom': 'Kg',
            'required_qty': 10.0,
            'available_qty': 6.0,
            'shortfall': 4.0,
          },
        ],
      ),
    );

    expect(find.text('Cocoa is short by 4 Kg'), findsOneWidget);
    // 6 of 10 kg covers 0.6 batches → half a batch is runnable.
    expect(find.widgetWithText(FilledButton, 'Reduce to 0.5'), findsOneWidget);

    final start = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Start batch'),
    );
    expect(start.onPressed, isNull);
  });

  testWidgets('a failed preview degrades to a retry, not a dead card',
      (tester) async {
    // The endpoint is new, so it can legitimately be missing on a server that
    // has not been deployed yet. Starting a run must survive that.
    await _pump(tester, BaseItemsPage(items: [_base()]));

    expect(find.textContaining('Could not check materials'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Retry'), findsOneWidget);

    final start = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Start batch'),
    );
    expect(start.onPressed, isNotNull);
  });

  testWidgets('the preview is debounced, not fired on every stepper tap',
      (tester) async {
    final dio = await _pump(
      tester,
      BaseItemsPage(items: [_base()]),
      preview: _preview(),
    );

    expect(dio.requestLog, hasLength(1), reason: 'the first preview');

    final plus = find.byIcon(Icons.add);
    for (var i = 0; i < 3; i++) {
      await tester.tap(plus);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(
      dio.requestLog,
      hasLength(2),
      reason: 'three taps inside the debounce window cost one request',
    );
    expect(dio.requestLog.last['data']['batches'], 2.5);
    expect(dio.requestLog.last['data']['item_code'], 'BASE-FUDGE');
  });

  testWidgets('the busiest card fits an Arabic 360 dp screen', (tester) async {
    // Arabic labels run longer than English, and every side-by-side control on
    // the card is a Wrap because of it. A RenderFlex overflow here fails the
    // test through the binding's pending-exception check.
    tester.view.physicalSize = const Size(360, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(
      tester,
      BaseItemsPage(
        demandSource: BaseDemandSource.plan,
        items: [
          _base(
            stockIsNegative: true,
            canMakeNowBatches: 0,
            runSizes: const [0.5, 1, 1.5, 2, 3],
            hasSop: true,
            demand: const BaseDemand(
              qtyRequired: 30.464,
              batchesRequired: 3.2,
              shortfallBatches: 1.4,
              driver: 'خطة اليوم',
            ),
          ),
        ],
      ),
      preview: _preview(
        hasShortage: true,
        runSizeOk: false,
        runSizes: const [0.5, 1, 1.5, 2, 3],
        components: const [
          {
            'item_code': 'RM-COCOA',
            'item_name': 'كاكاو خام مستورد',
            'uom': 'Kg',
            'required_qty': 10.0,
            'available_qty': 6.0,
            'shortfall': 4.0,
          },
        ],
      ),
      locale: const Locale('ar'),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(BaseProductionTab), findsOneWidget);
  });

  testWidgets('an empty list stays pull-to-refreshable', (tester) async {
    await _pump(tester, const BaseItemsPage());

    expect(find.text('No bases configured'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('a failed list offers a retry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          manufacturingServiceProvider
              .overrideWithValue(ManufacturingService(MockDio())),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: BaseProductionTab()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
  });
}
