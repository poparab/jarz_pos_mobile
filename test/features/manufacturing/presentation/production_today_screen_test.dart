import 'package:flutter/material.dart';
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
import 'package:jarz_pos/src/features/manufacturing/domain/base_batch_math.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/production_today_screen.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/widgets/mixer_run_summary.dart';
import 'package:jarz_pos/src/features/manufacturing/state/base_production_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/daily_plan_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_today_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/running_batches_notifier.dart';

import '../../../helpers/mock_services.dart';

/// One batch of this base yields 9.52 kg — a deliberately awkward figure, so a
/// conversion that silently sends batches as units cannot pass by looking
/// plausible.
const _baseYield = 9.52;

const _jar = DailyPlanItem(
  itemCode: 'JAR-LOTUS',
  itemName: 'Lotus Jar',
  itemGroup: 'Jars',
  defaultBom: 'BOM-JAR-LOTUS-001',
  mixQtyPerUnit: 0.25,
  jarsPerBatch: 120,
  usesMix: true,
);

const _template = DailyPlanTemplate(
  planDate: '2026-09-08',
  mix: DailyPlanMix(
    itemCode: 'MIX-CHEESECAKE',
    defaultBom: 'BOM-MIX-001',
    batchQty: 30,
    uom: 'Kg',
  ),
  items: [_jar],
);

const _runningBatch = RunningBatch(
  workOrder: 'MFG-WO-0001',
  itemCode: 'CAKE-A',
  itemName: 'Cake A',
  status: 'In Process',
  qty: 30,
);

class _StubBaseItems extends BaseItemsNotifier {
  _StubBaseItems(this._page);
  final BaseItemsPage _page;

  @override
  Future<BaseItemsPage> build() async => _page;
}

/// A base catalogue that never loads. `valueOrNull` is null for the whole
/// life of the screen, exactly as it is when the first fetch fails.
class _FailingBaseItems extends BaseItemsNotifier {
  @override
  Future<BaseItemsPage> build() async =>
      throw StateError('base list unavailable');
}

class _StubRunningBatches extends RunningBatchesNotifier {
  _StubRunningBatches(this._batches);
  final List<RunningBatch> _batches;

  @override
  Future<List<RunningBatch>> build() async => _batches;
}

/// [MockDio] plus a per-call queue for `produce_now`.
///
/// The Make action hits that one path twice with different payloads, and the
/// whole point of the test is that the two calls are distinguishable and
/// ordered — a single canned response could not tell a bases stage that
/// succeeded from a jars stage that was never sent.
class _QueueDio extends MockDio {
  final List<Object> produceQueue = [];

  int get produceCalls => requestLog
      .where((entry) => entry['path'] == ApiEndpoints.produceNow)
      .length;

  List<Map<String, dynamic>> produceLinesAt(int index) {
    final calls = requestLog
        .where((entry) => entry['path'] == ApiEndpoints.produceNow)
        .toList();
    final data = calls[index]['data'] as Map<String, dynamic>;
    return (data['lines'] as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    if (path == ApiEndpoints.produceNow && produceQueue.isNotEmpty) {
      final next = produceQueue.removeAt(0);
      if (next is DioException) {
        setError(path, next);
      } else {
        setResponse(path, next);
      }
    }
    return super.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}

Map<String, dynamic> _produced(String itemCode) => {
  'line': {'item_code': itemCode},
  'ok': true,
  'work_order': 'MFG-WO-$itemCode',
};

Map<String, dynamic> _failed(String itemCode, String error) => {
  'line': {'item_code': itemCode},
  'ok': false,
  'error': error,
};

Map<String, dynamic> _response(
  List<Map<String, dynamic>> results, {
  List<Map<String, dynamic>> shortages = const [],
}) => {
  'message': {'results': results, 'basket_shortages': shortages},
};

Future<_QueueDio> _pump(
  WidgetTester tester, {
  BaseItemsPage page = const BaseItemsPage(),
  DailyPlanTemplate template = _template,
  List<RunningBatch> running = const [],
  bool canExecute = true,
  List<Object> produceQueue = const [],
  bool planSaveFails = false,
  Locale? locale,
  BaseItemsNotifier Function()? baseItems,
  Map<String, dynamic>? savedPlan,
  ValueNotifier<bool>? visible,
}) async {
  final dio = _QueueDio()..produceQueue.addAll(produceQueue);

  if (savedPlan != null) {
    dio.setResponse(ApiEndpoints.dailyPlanGet, {'message': savedPlan});
  }

  dio.setResponse(ApiEndpoints.dailyPlanPreview, {
    'message': {
      'mix': {'item_code': 'MIX-CHEESECAKE', 'batch_qty': 30.0, 'uom': 'Kg'},
      'total_mix_qty': 45.0,
      'required_batches': 1.5,
      'planned_batches': 1.5,
      'run_detail': [
        {'size': 1.5, 'quality': 'preferred'},
      ],
      'run_count': 1,
    },
  });
  if (planSaveFails) {
    dio.setError(
      ApiEndpoints.dailyPlanSave,
      createMockDioException(statusCode: 417, path: ApiEndpoints.dailyPlanSave),
    );
  } else {
    dio.setResponse(ApiEndpoints.dailyPlanSave, {
      'message': {'name': 'DPP-2026-09-08', 'plan_date': '2026-09-08'},
    });
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        canAccessProductionBoardProvider.overrideWithValue(true),
        canExecuteProductionProvider.overrideWithValue(canExecute),
        // Today-only, which is what the fallback assumes anyway: this screen
        // never offers a date, so the gate must simply not refuse today.
        productionPolicyProvider.overrideWith(
          (ref) async => const ProductionPolicy(canExecute: true),
        ),
        baseItemsProvider.overrideWith(
          baseItems ?? () => _StubBaseItems(page),
        ),
        dailyPlanTemplateProvider.overrideWith((ref) async => template),
        runningBatchesProvider.overrideWith(() => _StubRunningBatches(running)),
        manufacturingServiceProvider.overrideWithValue(
          ManufacturingService(dio),
        ),
        dailyPlanServiceProvider.overrideWithValue(DailyPlanService(dio)),
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
        // The screen can be swapped out and back, which is what tapping
        // "Full board" and returning does: the State is disposed, while the
        // notifiers behind it live on in the root scope.
        home: visible == null
            ? const ProductionTodayScreen()
            : ValueListenableBuilder<bool>(
                valueListenable: visible,
                builder: (_, showing, _) => showing
                    ? const ProductionTodayScreen()
                    : const Scaffold(body: Center(child: Text('full board'))),
              ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return dio;
}

/// The bases field comes first in the tree, the jars field second.
Finder _baseField() => find.byType(TextField).first;
Finder _baseFieldAt(int index) => find.byType(TextField).at(index);
Finder _jarField() => find.byType(TextField).last;

String? _textIn(WidgetTester tester, Finder field) =>
    tester.widget<TextField>(field).controller?.text;

/// Lets the result SnackBar time out, so the next tap on the action bar lands
/// on the button rather than on the bar floating over it.
Future<void> _settleSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

Finder _makeButton() => find.widgetWithText(FilledButton, 'Make');

Future<void> _tapMake(WidgetTester tester) async {
  await tester.tap(_makeButton());
  await tester.pumpAndSettle();
  // The posting-moment confirmation, which every production path goes through.
  await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
  await tester.pumpAndSettle();
}

void main() {
  const page = BaseItemsPage(
    demandSource: BaseDemandSource.plan,
    items: [
      BaseItem(
        itemCode: 'BASE-FUDGE',
        itemName: 'Fudge Cake',
        stockUom: 'Kg',
        defaultBom: 'BOM-BASE-FUDGE-001',
        batchYield: _baseYield,
        batchesOnHand: 1.8,
        demand: BaseDemand(batchesRequired: 2.5),
      ),
    ],
  );

  testWidgets('renders both sections and the mixer split', (tester) async {
    await _pump(tester, page: page);

    expect(find.text('Bases'), findsOneWidget);
    expect(find.text('Fudge Cake'), findsOneWidget);
    expect(find.text('Jars'), findsOneWidget);
    expect(find.text('Lotus Jar'), findsOneWidget);

    // The two facts a base row is allowed to carry, and nothing else.
    expect(find.text('Needed today: 2.5'), findsOneWidget);
    expect(find.text('In freezer: 1.8'), findsOneWidget);

    expect(find.byType(MixerRunSummary), findsOneWidget);

    await tester.enterText(_jarField(), '180');
    await tester.pumpAndSettle();
    expect(find.text('180 jars recorded'), findsOneWidget);
    // Live off `preview_plan`, so the split is the server's answer.
    expect(find.text('1.5'), findsOneWidget);
  });

  testWidgets('Make is disabled until something is typed', (tester) async {
    await _pump(tester, page: page);

    expect(tester.widget<FilledButton>(_makeButton()).onPressed, isNull);

    await tester.enterText(_jarField(), '12');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(_makeButton()).onPressed, isNotNull);
  });

  testWidgets('Make stays disabled without execute rights', (tester) async {
    await _pump(tester, page: page, canExecute: false);

    await tester.enterText(_jarField(), '12');
    await tester.pumpAndSettle();

    expect(tester.widget<FilledButton>(_makeButton()).onPressed, isNull);
  });

  testWidgets('bases are produced before jars, in batch-yield units', (
    tester,
  ) async {
    final dio = await _pump(
      tester,
      page: page,
      produceQueue: [
        _response([_produced('BASE-FUDGE')]),
        _response([_produced('JAR-LOTUS')]),
      ],
    );

    await tester.enterText(_baseField(), '2');
    await tester.enterText(_jarField(), '180');
    await tester.pumpAndSettle();
    await _tapMake(tester);

    expect(dio.produceCalls, 2);

    // Bases first: the jars eat the mix these lines produce, so a single
    // basket would be refused for material that is about to exist.
    final baseLines = dio.produceLinesAt(0);
    expect(baseLines, hasLength(1));
    expect(baseLines.single['item_code'], 'BASE-FUDGE');
    expect(baseLines.single['bom_name'], 'BOM-BASE-FUDGE-001');
    // 2 batches × 9.52 per batch — batches never reach the wire.
    expect(baseLines.single['item_qty'], closeTo(2 * _baseYield, 1e-9));

    final jarLines = dio.produceLinesAt(1);
    expect(jarLines, hasLength(1));
    expect(jarLines.single['item_code'], 'JAR-LOTUS');
    expect(jarLines.single['item_qty'], 180.0);

    // Both stages go strict: a partial day is worse than a refused one.
    final firstCall = dio.requestLog
        .firstWhere((e) => e['path'] == ApiEndpoints.produceNow)['data'];
    expect((firstCall as Map)['strict_basket'], 1);

    // Produced rows are emptied; the plan falls out as a by-product.
    expect(find.text('2 of 2 recorded'), findsOneWidget);
    expect(tester.widget<TextField>(_baseField()).controller?.text, isEmpty);
    expect(
      dio.requestLog.any((e) => e['path'] == ApiEndpoints.dailyPlanSave),
      isTrue,
    );
  });

  testWidgets('a failed bases stage never sends the jars', (tester) async {
    final dio = await _pump(
      tester,
      page: page,
      produceQueue: [
        _response([_failed('BASE-FUDGE', 'Insufficient stock for RM-COCOA')]),
        _response([_produced('JAR-LOTUS')]),
      ],
    );

    await tester.enterText(_baseField(), '2');
    await tester.enterText(_jarField(), '180');
    await tester.pumpAndSettle();
    await _tapMake(tester);

    expect(dio.produceCalls, 1);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.textContaining('Insufficient stock for RM-COCOA'),
      findsOneWidget,
    );
    expect(
      find.textContaining('the bases have to come out first'),
      findsOneWidget,
    );

    // Nothing posted, so nothing is filed as a plan either.
    expect(
      dio.requestLog.any((e) => e['path'] == ApiEndpoints.dailyPlanSave),
      isFalse,
    );

    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();
    // The failed row keeps its number so it can be retried as typed.
    expect(tester.widget<TextField>(_baseField()).controller?.text, '2');
  });

  testWidgets('a failed plan save is not a production failure', (tester) async {
    final dio = await _pump(
      tester,
      page: page,
      planSaveFails: true,
      produceQueue: [
        _response([_produced('JAR-LOTUS')]),
      ],
    );

    await tester.enterText(_jarField(), '180');
    await tester.pumpAndSettle();
    await _tapMake(tester);

    expect(dio.produceCalls, 1);
    // No error dialog: the stock entries are posted, and saying "production
    // failed" here is how a correct posting gets repeated.
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.textContaining('1 of 1 recorded'), findsOneWidget);
    expect(find.textContaining("The day's plan did not save"), findsOneWidget);
  });

  // The safety valve, in both directions. Two tests rather than two pumps in
  // one: a second `pumpWidget` reuses the ProviderScope element, so the stub
  // notifier from the first pump survives and the assertion passes for the
  // wrong reason.
  testWidgets('no open-batches banner when nothing is running', (tester) async {
    await _pump(tester, page: page);
    expect(find.textContaining('still open'), findsNothing);
  });

  testWidgets('the open-batches banner shows what is still running', (
    tester,
  ) async {
    await _pump(tester, page: page, running: const [_runningBatch]);
    expect(find.text('1 batch still open'), findsOneWidget);
  });

  testWidgets('a material block is shown on the base row', (tester) async {
    await _pump(
      tester,
      page: const BaseItemsPage(
        items: [
          BaseItem(
            itemCode: 'BASE-FUDGE',
            itemName: 'Fudge Cake',
            stockUom: 'Kg',
            defaultBom: 'BOM-BASE-FUDGE-001',
            batchYield: _baseYield,
            canMakeNowBatches: 0,
            limitingComponent: BaseLimitingComponent(
              itemCode: 'RM-COCOA',
              itemName: 'Cocoa',
            ),
          ),
        ],
      ),
    );

    expect(find.text('Not enough Cocoa for a run'), findsOneWidget);
  });

  // Every test below pins one of the four ways this screen could post stock
  // nobody made. They are regressions, not features: each one failed before the
  // fix in the way the comment describes.

  // 1. A partial bases stage returns before `_clearSucceeded` used to run, so
  // the batch that DID post stayed in the draft. The field was emptied by the
  // screen, and `TextEditingController.clear()` fires no `onChanged` — so the
  // next Make re-posted a run that had already reached the ledger.
  testWidgets('a partial bases stage leaves the succeeded base out of the next '
      'Make', (tester) async {
    const twoBases = BaseItemsPage(
      demandSource: BaseDemandSource.plan,
      items: [
        BaseItem(
          itemCode: 'BASE-FUDGE',
          itemName: 'Fudge Cake',
          stockUom: 'Kg',
          defaultBom: 'BOM-BASE-FUDGE-001',
          batchYield: _baseYield,
        ),
        BaseItem(
          itemCode: 'BASE-CARAMEL',
          itemName: 'Caramel',
          stockUom: 'Kg',
          defaultBom: 'BOM-BASE-CARAMEL-001',
          batchYield: 4,
        ),
      ],
    );

    final dio = await _pump(
      tester,
      page: twoBases,
      produceQueue: [
        _response([
          _produced('BASE-FUDGE'),
          _failed('BASE-CARAMEL', 'Insufficient stock for RM-SUGAR'),
        ]),
        _response([_produced('BASE-CARAMEL')]),
      ],
    );

    await tester.enterText(_baseFieldAt(0), '2');
    await tester.enterText(_baseFieldAt(1), '1');
    await tester.pumpAndSettle();
    await _tapMake(tester);

    expect(dio.produceCalls, 1);
    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();

    // What posted is gone from the field; what failed keeps its number.
    expect(_textIn(tester, _baseFieldAt(0)), isEmpty);
    expect(_textIn(tester, _baseFieldAt(1)), '1');

    await _settleSnackBar(tester);
    await _tapMake(tester);

    // And the retry carries ONLY the base that never posted.
    expect(dio.produceCalls, 2);
    final retry = dio.produceLinesAt(1);
    expect(retry, hasLength(1));
    expect(retry.single['item_code'], 'BASE-CARAMEL');
  });

  // 1b. `productionTodayProvider` is a root NotifierProvider that outlives the
  // screen, so a field rebuilt empty over a draft that still holds a number is
  // a batch the operator cannot see and Make will still post.
  testWidgets('leaving the screen and returning shows what is still typed, and '
      'nothing more', (tester) async {
    final visible = ValueNotifier<bool>(true);
    addTearDown(visible.dispose);

    final dio = await _pump(
      tester,
      page: page,
      visible: visible,
      produceQueue: [
        _response([_produced('BASE-FUDGE')]),
      ],
    );

    Future<void> leaveAndReturn() async {
      visible.value = false;
      await tester.pumpAndSettle();
      visible.value = true;
      await tester.pumpAndSettle();
    }

    await tester.enterText(_baseField(), '2');
    await tester.pumpAndSettle();
    await leaveAndReturn();

    // The field says what the notifier holds...
    expect(_textIn(tester, _baseField()), '2');

    await _tapMake(tester);
    expect(
      dio.produceLinesAt(0).single['item_qty'],
      closeTo(2 * _baseYield, 1e-9),
    );

    // ...and once it has posted, neither the field nor the notifier has it,
    // so a second visit cannot resurrect it.
    await _settleSnackBar(tester);
    await leaveAndReturn();
    expect(_textIn(tester, _baseField()), isEmpty);
    expect(tester.widget<FilledButton>(_makeButton()).onPressed, isNull);
    expect(dio.produceCalls, 1);
  });

  // 2. The base catalogue can be absent — errored, or refetching after a pull
  // to refresh. Typed bases used to be dropped one by one against that empty
  // map, which shrank the bases stage to nothing and let the jars post on
  // their own against mix that was never made.
  testWidgets('a base that cannot be resolved aborts the Make and sends no '
      'jars', (tester) async {
    final dio = await _pump(
      tester,
      page: page,
      baseItems: _FailingBaseItems.new,
      produceQueue: [
        _response([_produced('BASE-FUDGE')]),
        _response([_produced('JAR-LOTUS')]),
      ],
    );

    // Two batches typed on an earlier visit — the notifier outlives the screen
    // — against a catalogue that is now unavailable, so the row they belong to
    // is not even on the page and `batch_yield` cannot be read.
    ProviderScope.containerOf(
      tester.element(find.byType(ProductionTodayScreen)),
      listen: false,
    ).read(productionTodayProvider.notifier).setBaseBatches('BASE-FUDGE', 2);
    await tester.pumpAndSettle();

    await tester.enterText(_jarField(), '180');
    await tester.pumpAndSettle();

    await _tapMake(tester);

    // Nothing at all was sent — not the bases, and above all not the jars.
    expect(dio.produceCalls, 0);
    expect(
      dio.requestLog.any((e) => e['path'] == ApiEndpoints.dailyPlanSave),
      isFalse,
    );
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('base list is not loaded'), findsOneWidget);
    // Named, so the refusal points at the row it is about.
    expect(find.textContaining('BASE-FUDGE'), findsOneWidget);
  });

  // 3. "Save for later" is what writes today's plan, so on THIS screen the
  // saved plan is the morning TARGET. Seeding it into the field Make reads put
  // a figure nobody produced one un-edited tap away from becoming stock.
  testWidgets('a saved plan is a target on the row, never a number in the '
      'field', (tester) async {
    final dio = await _pump(
      tester,
      page: page,
      template: const DailyPlanTemplate(
        planDate: '2026-09-08',
        mix: DailyPlanMix(
          itemCode: 'MIX-CHEESECAKE',
          defaultBom: 'BOM-MIX-001',
          batchQty: 30,
          uom: 'Kg',
        ),
        items: [_jar],
        existingPlan: 'DPP-2026-09-08',
      ),
      savedPlan: {
        'name': 'DPP-2026-09-08',
        'plan_date': '2026-09-08',
        'status': 'Planned',
        'lines': [
          {'item_code': 'JAR-LOTUS', 'planned_qty': 50},
        ],
      },
      produceQueue: [
        _response([_produced('JAR-LOTUS')]),
      ],
    );
    await tester.pumpAndSettle();

    // The plan is on the row as a target, and the field stays empty.
    expect(find.text("Today's target: 50"), findsOneWidget);
    expect(_textIn(tester, _jarField()), isEmpty);

    // So a tap on Make cannot book a plan as production: there is nothing to
    // post until somebody types what actually came out.
    expect(tester.widget<FilledButton>(_makeButton()).onPressed, isNull);

    // What is typed is what is posted — 42 baked, not 50 planned.
    await tester.enterText(_jarField(), '42');
    await tester.pumpAndSettle();
    await _tapMake(tester);

    expect(dio.produceLinesAt(0).single['item_qty'], 42.0);
    // The plan document is still updated rather than duplicated for the day.
    final save = dio.requestLog
        .firstWhere((e) => e['path'] == ApiEndpoints.dailyPlanSave)['data'];
    expect((save as Map)['name'], 'DPP-2026-09-08');
  });

  // 4. The mixer's unit of work is half a batch, and 1.5 is the normal run —
  // a digits-only field forced the operator to record 1 or 2, both wrong.
  testWidgets('a base records a half batch, converted by yield', (tester) async {
    final dio = await _pump(
      tester,
      page: page,
      produceQueue: [
        _response([_produced('BASE-FUDGE')]),
      ],
    );

    await tester.enterText(_baseField(), '1.5');
    await tester.pumpAndSettle();
    expect(_textIn(tester, _baseField()), '1.5');

    await _tapMake(tester);
    expect(
      dio.produceLinesAt(0).single['item_qty'],
      closeTo(1.5 * _baseYield, 1e-9),
    );
  });

  // 4b. The ceiling the stepper deliberately cannot pass applies to a typed
  // figure too, and it is applied in the field so what is on screen is what
  // will be posted.
  testWidgets('a typed base run is clamped to the batch ceiling', (
    tester,
  ) async {
    final dio = await _pump(
      tester,
      page: page,
      produceQueue: [
        _response([_produced('BASE-FUDGE')]),
      ],
    );

    await tester.enterText(_baseField(), '500');
    await tester.pumpAndSettle();
    expect(_textIn(tester, _baseField()), '40');

    await _tapMake(tester);
    expect(
      dio.produceLinesAt(0).single['item_qty'],
      closeTo(kMaxBatches * _baseYield, 1e-9),
    );
  });

  // Arabic is the register the floor actually reads, and it is longer than the
  // English everywhere. A row that only fits in English overflows here, which
  // is why the facts under a base name are a Wrap and not a Row.
  testWidgets('lays out in Arabic on a 360 dp phone', (tester) async {
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await _pump(tester, page: page, locale: const Locale('ar'));

    expect(find.text('الأساسات'), findsOneWidget);
    expect(find.text('البرطمانات'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(_jarField(), '180');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
