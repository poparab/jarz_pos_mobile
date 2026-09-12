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
import 'package:jarz_pos/src/features/manufacturing/state/running_batches_notifier.dart';

import '../../../helpers/mock_services.dart';

const _materialOptionsEndpoint =
    '/api/method/jarz_pos.api.manufacturing.get_material_options';

/// A mix: weighed, not counted, and eaten by two jar sizes at a fixed rate.
///
/// The numbers are production's own — `Blueberry mix` yields 2 Kg from 1 Kg of
/// fruit and 1 Kg of jelly, and a medium jar takes 0.030 Kg where a large takes
/// 0.040.
BaseItem _mix({
  String itemCode = 'Blueberry mix',
  double batchYield = 2.0,
  double onHand = 0.58,
  bool stockIsNegative = false,
  int? canMakeNowBatches,
  String? status,
  double? daysOfCover,
  List<BaseJarConsumer>? jarConsumers,
}) {
  return BaseItem(
    itemCode: itemCode,
    itemName: itemCode,
    stockUom: 'Kg',
    defaultBom: 'BOM-$itemCode-003',
    batchYield: batchYield,
    onHand: onHand,
    stockIsNegative: stockIsNegative,
    batchesOnHand: onHand / batchYield,
    canMakeNowBatches: canMakeNowBatches,
    entryMode: kBaseEntryQuantity,
    status: status,
    daysOfCover: daysOfCover,
    jarConsumers:
        jarConsumers ??
        const [
          BaseJarConsumer(
            itemCode: 'Blueberry Medium',
            itemName: 'Blueberry Medium',
            qtyPerJar: 0.03,
          ),
          BaseJarConsumer(
            itemCode: 'Blueberry Large',
            itemName: 'Blueberry Large',
            qtyPerJar: 0.04,
          ),
        ],
  );
}

/// A cake: counted in eggs, 30 of them to a batch, like Fudge Cake on
/// production.
BaseItem _cake({
  String itemCode = 'Fudge Cake',
  double batchYield = 9.258,
  double onHand = 18.5,
  BaseBatchUnit? batchUnit,
}) {
  return BaseItem(
    itemCode: itemCode,
    itemName: itemCode,
    stockUom: 'Kg',
    defaultBom: 'BOM-$itemCode-004',
    batchYield: batchYield,
    onHand: onHand,
    batchesOnHand: onHand / batchYield,
    entryMode: kBaseEntryBatch,
    batchUnit:
        batchUnit ??
        const BaseBatchUnit(
          itemCode: 'eggs',
          itemName: 'eggs',
          uom: 'piece',
          qtyPerBatch: 30,
        ),
  );
}

class _StubBaseItemsNotifier extends BaseItemsNotifier {
  _StubBaseItemsNotifier(this._page);
  final BaseItemsPage _page;

  @override
  Future<BaseItemsPage> build() async => _page;

  /// The real one re-reads from the server; the stub only has to not explode
  /// when a successful Make refreshes the list.
  @override
  Future<void> refresh() async {
    state = AsyncValue.data(_page);
  }
}

Map<String, dynamic> _preview({
  required double itemQty,
  double batchYield = 2.0,
  bool hasShortage = false,
  List<Map<String, dynamic>> components = const [],
  String itemCode = 'Blueberry mix',
}) {
  return {
    'item_code': itemCode,
    'bom_name': 'BOM-$itemCode-003',
    'batches': itemQty / batchYield,
    'batch_yield': batchYield,
    'item_qty': itemQty,
    'stock_uom': 'Kg',
    'components': components,
    'has_shortage': hasShortage,
    'run_size_ok': true,
    'has_sop': false,
  };
}

Future<MockDio> _pump(
  WidgetTester tester,
  BaseItemsPage page, {
  Map<String, dynamic>? preview,
  Map<String, dynamic>? produceNow,
  Map<String, dynamic>? startBatches,
  Locale? locale,
}) async {
  final dio = MockDio();
  dio.setResponse(_materialOptionsEndpoint, {
    'message': {
      'bom_name': 'BOM-x',
      'qty': 1.0,
      'components': <Map<String, dynamic>>[],
    },
  });
  if (preview != null) {
    dio.setResponse(ApiEndpoints.previewBaseBatch, {'message': preview});
  }
  if (produceNow != null) {
    dio.setResponse(ApiEndpoints.produceNow, {'message': produceNow});
  }
  if (startBatches != null) {
    dio.setResponse(ApiEndpoints.startProductionBatches, {
      'message': startBatches,
    });
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        manufacturingServiceProvider.overrideWithValue(
          ManufacturingService(dio),
        ),
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
  return dio;
}

/// A window tall enough that two open rows do not push the third out of the
/// tree. The default 800x600 surface is shorter than one expanded mix.
void _tallWindow(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Opens a row by tapping its name, then lets the debounced preview land.
Future<void> _open(WidgetTester tester, String itemCode) async {
  await tester.tap(find.text(itemCode));
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

List<Map<String, dynamic>> _requests(MockDio dio, String path) =>
    dio.requestLog.where((r) => r['path'] == path).toList(growable: false);

Map<String, dynamic> _lastBody(MockDio dio, String path) =>
    Map<String, dynamic>.from(_requests(dio, path).last['data'] as Map);

void main() {
  group('the two kinds of base are kept apart', () {
    testWidgets('each lands under its own heading', (tester) async {
      await _pump(tester, BaseItemsPage(items: [_mix(), _cake()]));

      expect(find.text('Mixes'), findsOneWidget);
      expect(find.text('Made by the kilo — enter jars or weight'), findsOneWidget);
      expect(find.text('Cakes & biscuits'), findsOneWidget);
      expect(find.text('Made in batches — counted in eggs'), findsOneWidget);
    });

    testWidgets('a group with nothing in it is not announced', (tester) async {
      await _pump(tester, BaseItemsPage(items: [_mix()]));

      expect(find.text('Mixes'), findsOneWidget);
      expect(find.text('Cakes & biscuits'), findsNothing);
    });

    testWidgets('a closed row shows the store, and no batch language on a mix', (
      tester,
    ) async {
      await _pump(
        tester,
        BaseItemsPage(
          coverIncluded: true,
          items: [_mix(status: 'low', daysOfCover: 2.1)],
        ),
      );

      expect(find.text('0.58 Kg in store · 2.1 d'), findsOneWidget);
      // The whole complaint this screen answers: a mix has no batch, so no
      // figure on it may be expressed in one.
      expect(find.textContaining('batch'), findsNothing);
    });
  });

  group('a mix is entered in jars and kilos', () {
    testWidgets('opening it offers the recipe amount and prices it by quantity', (
      tester,
    ) async {
      final dio = await _pump(
        tester,
        BaseItemsPage(items: [_mix()]),
        preview: _preview(itemQty: 2.0),
      );
      await _open(tester, 'Blueberry mix');

      // One recipe: 1 Kg of fruit and 1 Kg of jelly. Not "1 batch".
      expect(find.text('Makes 2 Kg'), findsOneWidget);

      // The contract that matters: a weighed base is costed by `qty`, never by a
      // batch count the server would have to divide back out.
      final body = _lastBody(dio, ApiEndpoints.previewBaseBatch);
      expect(body['qty'], 2.0);
      expect(body.containsKey('batches'), isFalse);
    });

    testWidgets('a closed row asks the server nothing', (tester) async {
      final dio = await _pump(
        tester,
        BaseItemsPage(items: [_mix(), _cake()]),
        preview: _preview(itemQty: 2.0),
      );

      // Nine bases used to fire nine previews on load. The list is now free.
      expect(_requests(dio, ApiEndpoints.previewBaseBatch), isEmpty);
    });

    testWidgets('typing jar counts works the kilos out', (tester) async {
      await _pump(
        tester,
        BaseItemsPage(items: [_mix()]),
        preview: _preview(itemQty: 2.0),
      );
      await _open(tester, 'Blueberry mix');

      await tester.enterText(_jarField(tester, 'Blueberry Medium'), '40');
      await tester.pumpAndSettle();
      await tester.enterText(_jarField(tester, 'Blueberry Large'), '20');
      await tester.pumpAndSettle();

      // 40 x 0.030 + 20 x 0.040 = 2 Kg exactly, and rendered as "2" rather than
      // the 2.0000000000000004 the arithmetic actually produces.
      expect(
        find.text('Those jars need 2 Kg — 1.42 more than the store holds'),
        findsOneWidget,
      );
      expect(_qtyFieldText(tester), '2');
    });

    testWidgets('clearing a jar row takes its kilos back out', (tester) async {
      await _pump(
        tester,
        BaseItemsPage(items: [_mix()]),
        preview: _preview(itemQty: 2.0),
      );
      await _open(tester, 'Blueberry mix');

      await tester.enterText(_jarField(tester, 'Blueberry Medium'), '40');
      await tester.pumpAndSettle();
      expect(_qtyFieldText(tester), '1.2');

      await tester.enterText(_jarField(tester, 'Blueberry Medium'), '');
      await tester.pumpAndSettle();
      // An emptied field is a zero, not "leave the last number standing".
      expect(_qtyFieldText(tester), '');
    });

    testWidgets('the shortfall is offered rounded up to something weighable', (
      tester,
    ) async {
      await _pump(
        tester,
        BaseItemsPage(items: [_mix()]),
        preview: _preview(itemQty: 2.0),
      );
      await _open(tester, 'Blueberry mix');

      await tester.enterText(_jarField(tester, 'Blueberry Medium'), '40');
      await tester.pumpAndSettle();
      await tester.enterText(_jarField(tester, 'Blueberry Large'), '20');
      await tester.pumpAndSettle();

      // Needs 2, store holds 0.58, so 1.42 is missing — and nobody weighs out
      // 1.42, so the offer is 1.5.
      final chip = find.widgetWithText(ActionChip, 'Make 1.5 Kg');
      expect(chip, findsOneWidget);

      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(_qtyFieldText(tester), '1.5');
    });
  });

  group('a cake is entered in eggs', () {
    testWidgets('the chips are egg counts, not batch numbers', (tester) async {
      await _pump(
        tester,
        BaseItemsPage(items: [_cake()]),
        preview: _preview(
          itemQty: 9.258,
          batchYield: 9.258,
          itemCode: 'Fudge Cake',
        ),
      );
      await _open(tester, 'Fudge Cake');

      expect(find.text('One batch = 30 eggs'), findsOneWidget);
      // 0.5, 1, 1.5, 2 and 3 batches, in the kitchen's own unit.
      for (final eggs in ['15', '30', '45', '60', '90']) {
        expect(find.widgetWithText(ChoiceChip, eggs), findsOneWidget);
      }
    });

    testWidgets('45 eggs is a batch and a half, and posts that much', (
      tester,
    ) async {
      final dio = await _pump(
        tester,
        BaseItemsPage(items: [_cake()]),
        preview: _preview(
          itemQty: 9.258,
          batchYield: 9.258,
          itemCode: 'Fudge Cake',
        ),
      );
      await _open(tester, 'Fudge Cake');

      await tester.tap(find.widgetWithText(ChoiceChip, '45'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('45 eggs · 1.5 batches'), findsOneWidget);
      final body = _lastBody(dio, ApiEndpoints.previewBaseBatch);
      expect((body['qty'] as double), closeTo(1.5 * 9.258, 0.001));
    });

    testWidgets('no jar counter on a cake', (tester) async {
      await _pump(
        tester,
        BaseItemsPage(items: [_cake()]),
        preview: _preview(
          itemQty: 9.258,
          batchYield: 9.258,
          itemCode: 'Fudge Cake',
        ),
      );
      await _open(tester, 'Fudge Cake');

      expect(find.text('Jars to fill'), findsNothing);
    });

    testWidgets('a recipe with nothing countable in it still reads honestly', (
      tester,
    ) async {
      // Defensive: `entry_mode: batch` with no usable unit should fall back to
      // batch figures rather than rendering "0 eggs".
      await _pump(
        tester,
        BaseItemsPage(
          items: [_cake(batchUnit: const BaseBatchUnit())],
        ),
        preview: _preview(
          itemQty: 9.258,
          batchYield: 9.258,
          itemCode: 'Fudge Cake',
        ),
      );
      await _open(tester, 'Fudge Cake');

      expect(find.text('1 batch = 9.26 Kg'), findsOneWidget);
      // The heading legitimately says "counted in eggs"; the ROW must not,
      // because this recipe has no egg line to count.
      expect(find.widgetWithText(ChoiceChip, '30'), findsNothing);
      expect(find.textContaining('One batch = '), findsNothing);
    });
  });

  group('making several at once', () {
    testWidgets('the bar says what pressing it will actually do', (
      tester,
    ) async {
      _tallWindow(tester);
      await _pump(
        tester,
        BaseItemsPage(
          items: [_mix(), _mix(itemCode: 'strawberry mix'), _cake()],
        ),
        preview: _preview(itemQty: 2.0),
      );

      await _open(tester, 'Blueberry mix');
      expect(find.widgetWithText(FilledButton, 'Make 1 mix'), findsOneWidget);

      await _open(tester, 'strawberry mix');
      expect(find.widgetWithText(FilledButton, 'Make 2 mixes'), findsOneWidget);

      await _open(tester, 'Fudge Cake');
      // Two different things happen to stock, so the button says so rather than
      // hiding it behind a generic Submit.
      expect(find.widgetWithText(FilledButton, 'Make 2 · start 1'), findsOneWidget);
      expect(
        find.text(
          'Mixes are booked as made · batches go to Running to be finished',
        ),
        findsOneWidget,
      );
    });

    testWidgets('mixes are booked outright and cakes only started', (
      tester,
    ) async {
      _tallWindow(tester);
      final dio = await _pump(
        tester,
        BaseItemsPage(items: [_mix(), _cake()]),
        preview: _preview(itemQty: 2.0),
        produceNow: {
          'results': [
            {'ok': true, 'work_order': 'WO-1', 'line': {'item_code': 'Blueberry mix'}},
          ],
        },
        startBatches: {
          'results': [
            {'ok': true, 'work_order': 'WO-2', 'line': {'item_code': 'Fudge Cake'}},
          ],
        },
      );

      await _open(tester, 'Blueberry mix');
      await _open(tester, 'Fudge Cake');
      await tester.tap(find.widgetWithText(FilledButton, 'Make 1 · start 1'));
      await tester.pumpAndSettle();

      final mixBody = _lastBody(dio, ApiEndpoints.produceNow);
      final mixLines = (mixBody['lines'] as List).cast<Map>();
      expect(mixLines.single['item_code'], 'Blueberry mix');
      expect(mixLines.single['item_qty'], 2.0);
      // All-or-nothing, because a basket that passes line by line can still
      // empty a store.
      expect(mixBody['strict_basket'], 1);

      final cakeBody = _lastBody(dio, ApiEndpoints.startProductionBatches);
      final cakeLines = (cakeBody['lines'] as List).cast<Map>();
      expect(cakeLines.single['item_code'], 'Fudge Cake');

      // The cake is in the oven, so the day continues on Running. Three booked
      // mixes would not have moved anybody anywhere.
      expect(find.textContaining('1 mix made'), findsOneWidget);
      expect(find.textContaining('1 batch started'), findsOneWidget);
    });

    testWidgets('a mix-only make never posts a start call', (tester) async {
      final dio = await _pump(
        tester,
        BaseItemsPage(items: [_mix()]),
        preview: _preview(itemQty: 2.0),
        produceNow: {
          'results': [
            {'ok': true, 'work_order': 'WO-1', 'line': {'item_code': 'Blueberry mix'}},
          ],
        },
      );

      await _open(tester, 'Blueberry mix');
      await tester.tap(find.widgetWithText(FilledButton, 'Make 1 mix'));
      await tester.pumpAndSettle();

      expect(_requests(dio, ApiEndpoints.startProductionBatches), isEmpty);
      // Booked and gone: the row lets go of its numbers so a second press
      // cannot re-post a run already in the ledger.
      expect(find.widgetWithText(FilledButton, 'Make 1 mix'), findsNothing);
    });

    testWidgets('a known shortage on one pick holds the whole button', (
      tester,
    ) async {
      await _pump(
        tester,
        BaseItemsPage(items: [_mix()]),
        preview: _preview(
          itemQty: 2.0,
          hasShortage: true,
          components: [
            {
              'item_code': 'jelly',
              'item_name': 'jelly',
              'uom': 'Kg',
              'required_qty': 1.0,
              'available_qty': 0.2,
              'shortfall': 0.8,
            },
          ],
        ),
      );
      await _open(tester, 'Blueberry mix');

      expect(
        find.text('1 pick is short of materials — untick it to make the rest'),
        findsOneWidget,
      );
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Make 1 mix'),
      );
      expect(button.onPressed, isNull);
      expect(find.text('jelly is short by 0.8 Kg'), findsOneWidget);
    });

    testWidgets('a pick with no amount is named rather than silently dropped', (
      tester,
    ) async {
      await _pump(
        tester,
        BaseItemsPage(items: [_mix()]),
        preview: _preview(itemQty: 2.0),
      );
      await _open(tester, 'Blueberry mix');

      await tester.enterText(_qtyField(tester), '');
      await tester.pumpAndSettle();

      expect(find.text('1 pick has no amount yet'), findsOneWidget);
      expect(find.text('Nothing set to make yet'), findsOneWidget);
    });

    testWidgets('cancel drops the selection without posting', (tester) async {
      final dio = await _pump(
        tester,
        BaseItemsPage(items: [_mix()]),
        preview: _preview(itemQty: 2.0),
      );
      await _open(tester, 'Blueberry mix');

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(FilledButton), findsNothing);
      expect(_requests(dio, ApiEndpoints.produceNow), isEmpty);
    });
  });

  group('an older backend', () {
    testWidgets('reads every base as a batch rather than crashing', (
      tester,
    ) async {
      // No `entry_mode`, no `batch_unit`, no `jar_consumers` — exactly what a
      // server that predates this screen answers with.
      final page = BaseItemsPage.fromJson({
        'items': [
          {
            'item_code': 'Sponge Cake',
            'item_name': 'Sponge Cake',
            'stock_uom': 'Kg',
            'default_bom': 'BOM-Sponge Cake-001',
            'batch_yield': 4.0,
            'on_hand': 8.0,
            'batches_on_hand': 2.0,
          },
        ],
      });

      await _pump(
        tester,
        page,
        preview: _preview(
          itemQty: 4.0,
          batchYield: 4.0,
          itemCode: 'Sponge Cake',
        ),
      );

      expect(find.text('Cakes & biscuits'), findsOneWidget);
      expect(find.text('Mixes'), findsNothing);
      await _open(tester, 'Sponge Cake');
      expect(find.text('1 batch = 4 Kg'), findsOneWidget);
      expect(find.text('Jars to fill'), findsNothing);
    });
  });

  group('urgency comes first', () {
    testWidgets('a critical mix sorts above a healthy one', (tester) async {
      await _pump(
        tester,
        BaseItemsPage(
          coverIncluded: true,
          items: [
            _mix(itemCode: 'Aardvark mix', status: 'ok', daysOfCover: 40),
            _mix(itemCode: 'Zebra mix', status: 'critical', daysOfCover: 1),
          ],
        ),
      );

      final zebra = tester.getTopLeft(find.text('Zebra mix')).dy;
      final aardvark = tester.getTopLeft(find.text('Aardvark mix')).dy;
      expect(zebra, lessThan(aardvark));
    });
  });

  test('the Running tab index the bar jumps to is still the third one', () {
    // A guard on a constant two files apart: the merge to three tabs moved it
    // once already, and a stale index sends the floor to the wrong screen.
    expect(kProductionRunningTabIndex, 2);
  });
}

/// The jar count field sitting beside [jarName].
Finder _jarField(WidgetTester tester, String jarName) {
  return find.descendant(
    of: find.ancestor(
      of: find.text(jarName),
      matching: find.byType(Row),
    ).first,
    matching: find.byType(TextField),
  );
}

/// The "Make ___ Kg" field. Last, because the jar fields come above it.
Finder _qtyField(WidgetTester tester) => find.byType(TextField).last;

String _qtyFieldText(WidgetTester tester) =>
    tester.widget<TextField>(_qtyField(tester)).controller!.text;
