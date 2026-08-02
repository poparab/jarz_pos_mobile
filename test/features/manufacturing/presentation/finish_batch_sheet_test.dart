import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/manufacturing/data/manufacturing_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/running_batch.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/widgets/finish_batch_sheet.dart';

import '../../../helpers/mock_services.dart';

const _batch = RunningBatch(
  workOrder: 'MFG-WO-0001',
  itemCode: 'CAKE-A',
  itemName: 'Cake A',
  bomName: 'BOM-CAKE-A-001',
  stockUom: 'Nos',
  qty: 30,
  producedQty: 0,
  status: 'In Process',
);

MockDio _dio() {
  final dio = MockDio();
  dio.setResponse(ApiEndpoints.listRunningWorkOrders, {'message': []});
  dio.setResponse(ApiEndpoints.getBatchCost, {
    'message': {
      'work_order': 'MFG-WO-0001',
      'material_cost': 600.0,
      'produced_qty': 0.0,
      'cost_per_unit': null,
      'standard_per_unit': null,
      'currency': 'EGP',
    },
  });
  return dio;
}

Future<void> _pumpSheet(
  WidgetTester tester,
  MockDio dio, {
  RunningBatch batch = _batch,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        manufacturingServiceProvider
            .overrideWithValue(ManufacturingService(dio)),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: FinishBatchSheet(batch: batch)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TextField _field(WidgetTester tester, String key) => tester.widget<TextField>(
      find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(TextField),
      ),
    );

FilledButton _submitButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byKey(const Key('finishSubmit')));

void main() {
  testWidgets('prefills the actual quantity with what is still outstanding',
      (tester) async {
    await _pumpSheet(
      tester,
      _dio(),
      batch: _batch.copyWith(qty: 30, producedQty: 12),
    );

    expect(_field(tester, 'finishActualQty').controller!.text, '18');
    expect(_field(tester, 'finishScrapQty').controller!.text, '0');
    expect(_submitButton(tester).onPressed, isNotNull);
  });

  testWidgets('blocks a quantity above what was planned', (tester) async {
    await _pumpSheet(tester, _dio());

    await tester.enterText(find.byKey(const Key('finishActualQty')), '31');
    await tester.pump();

    expect(find.text('More than the 30 planned'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNull);
  });

  testWidgets('allows exactly the planned quantity', (tester) async {
    await _pumpSheet(tester, _dio());

    await tester.enterText(find.byKey(const Key('finishActualQty')), '30');
    await tester.pump();

    expect(find.textContaining('More than the'), findsNothing);
    expect(_submitButton(tester).onPressed, isNotNull);
  });

  testWidgets('blocks a zero or empty produced quantity', (tester) async {
    await _pumpSheet(tester, _dio());

    await tester.enterText(find.byKey(const Key('finishActualQty')), '0');
    await tester.pump();

    expect(find.text('Enter how much actually came out'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('finishActualQty')), '');
    await tester.pump();
    expect(_submitButton(tester).onPressed, isNull);
  });

  testWidgets('scrap cannot be made negative', (tester) async {
    await _pumpSheet(tester, _dio());

    // The shared decimal formatter refuses the sign outright, so a negative
    // scrap figure can never reach the payload.
    await tester.enterText(find.byKey(const Key('finishScrapQty')), '-3');
    await tester.pump();

    expect(_field(tester, 'finishScrapQty').controller!.text, '0');
    expect(_submitButton(tester).onPressed, isNotNull);
  });

  testWidgets('submits the payload keys the backend expects', (tester) async {
    final dio = _dio();
    dio.setResponse(ApiEndpoints.finishProductionBatch, {
      'message': {
        'work_order': 'MFG-WO-0001',
        'manufacture_entry': 'MAT-STE-0002',
        'actual_qty': 27.5,
        'scrap_qty': 1.5,
        'status': 'Completed',
        'wip_leftover_qty': 0.0,
      },
    });
    await _pumpSheet(tester, dio);

    await tester.enterText(find.byKey(const Key('finishActualQty')), '27.5');
    await tester.enterText(find.byKey(const Key('finishScrapQty')), '1.5');
    await tester.enterText(
      find.byKey(const Key('finishNotes')),
      'second tray under-baked',
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('finishSubmit')));
    await tester.pumpAndSettle();

    final call = dio.requestLog
        .firstWhere((r) => r['path'] == ApiEndpoints.finishProductionBatch);
    final payload = call['data'] as Map<String, dynamic>;
    expect(payload['work_order'], 'MFG-WO-0001');
    expect(payload['actual_qty'], 27.5);
    expect(payload['scrap_qty'], 1.5);
    expect(payload['notes'], 'second tray under-baked');
  });

  testWidgets('an empty note is left out of the payload entirely',
      (tester) async {
    final dio = _dio();
    dio.setResponse(ApiEndpoints.finishProductionBatch, {
      'message': {'work_order': 'MFG-WO-0001', 'actual_qty': 30.0},
    });
    await _pumpSheet(tester, dio);

    await tester.tap(find.byKey(const Key('finishSubmit')));
    await tester.pumpAndSettle();

    final call = dio.requestLog
        .firstWhere((r) => r['path'] == ApiEndpoints.finishProductionBatch);
    expect((call['data'] as Map).containsKey('notes'), isFalse);
  });

  testWidgets('a failed finish keeps the sheet open and says why',
      (tester) async {
    final dio = _dio();
    dio.setError(
      ApiEndpoints.finishProductionBatch,
      createMockDioException(
        statusCode: 417,
        data: {'exception': 'ValidationError: Not enough material in WIP'},
      ),
    );
    await _pumpSheet(tester, dio);

    await tester.tap(find.byKey(const Key('finishSubmit')));
    await tester.pumpAndSettle();

    expect(find.byType(FinishBatchSheet), findsOneWidget);
    expect(find.textContaining('Not enough material in WIP'), findsOneWidget);
  });

  testWidgets('a fully produced batch still has a way out', (tester) async {
    // Outstanding is zero, so capping on it would leave a sheet that refuses
    // every number and a Work Order nobody can close.
    await _pumpSheet(
      tester,
      _dio(),
      batch: _batch.copyWith(qty: 30, producedQty: 30),
    );

    expect(_field(tester, 'finishActualQty').controller!.text, '30');
    expect(_submitButton(tester).onPressed, isNotNull);
  });
}
