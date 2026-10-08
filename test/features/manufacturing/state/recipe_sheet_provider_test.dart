import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/manufacturing/data/daily_plan_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/manufacturing_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/recipe_sheet.dart';
import 'package:jarz_pos/src/features/manufacturing/state/daily_plan_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/recipe_sheet_providers.dart';
import 'package:jarz_pos/src/features/manufacturing/state/sop_providers.dart';

import '../../../helpers/mock_services.dart';

const _recipeSheetPath = '/api/method/jarz_pos.api.sop.get_recipe_sheet';

/// Comfortably past the provider's debounce.
const _settle = Duration(milliseconds: 600);

Map<String, dynamic> _sheetResponse() => {
  'message': {
    'sheets': [
      {
        'title': 'Tiramisu',
        'items': [
          {
            'item_code': 'Tiramisu Large',
            'item_name': 'Tiramisu Large',
            'qty': 10,
          },
        ],
        'total_qty': 10,
        'ingredients': const [],
        'steps': const [],
        'unresolved_tokens': const [],
      },
    ],
  },
};

MockDio _dio({List<String> sopItems = const ['Tiramisu Large']}) {
  final dio = MockDio()
    ..setResponse(ApiEndpoints.listItemsWithSop, {
      'message': {'item_codes': sopItems},
    })
    ..setResponse(_recipeSheetPath, _sheetResponse())
    ..setResponse(ApiEndpoints.dailyPlanPreview, {
      'message': {
        'mix': {'item_code': 'MIX', 'batch_qty': 30.0, 'uom': 'Kg'},
        'total_mix_qty': 0.0,
        'required_batches': 0.0,
        'run_detail': const <Map<String, dynamic>>[],
        'run_count': 0,
      },
    });
  return dio;
}

ProviderContainer _container(MockDio dio) {
  final container = ProviderContainer(
    overrides: [
      manufacturingServiceProvider.overrideWithValue(ManufacturingService(dio)),
      dailyPlanServiceProvider.overrideWithValue(DailyPlanService(dio)),
    ],
  );
  addTearDown(container.dispose);
  // What the screens do: keep the chain alive while they are up.
  container.listen(recipeSheetProvider, (_, _) {});
  return container;
}

List<Map<String, dynamic>> _sheetCalls(MockDio dio) =>
    dio.requestLog.where((r) => r['path'] == _recipeSheetPath).toList();

List<dynamic> _linesOf(Map<String, dynamic> call) =>
    jsonDecode((call['data'] as Map)['lines'] as String) as List<dynamic>;

void main() {
  group('sopItemCodesProvider', () {
    test('reads the item codes off the envelope', () async {
      final dio = MockDio()
        ..setResponse(ApiEndpoints.listItemsWithSop, {
          'message': {
            'item_codes': ['Tiramisu Large', 'Tiramisu Small', ''],
          },
        });
      final container = _container(dio);

      final codes = await container.read(sopItemCodesProvider.future);
      expect(codes, {'Tiramisu Large', 'Tiramisu Small'});
    });

    test('an older backend without the endpoint is an empty set', () async {
      final dio = MockDio()
        ..setError(
          ApiEndpoints.listItemsWithSop,
          createMockDioException(
            statusCode: 417,
            path: ApiEndpoints.listItemsWithSop,
          ),
        );
      final container = _container(dio);

      final codes = await container.read(sopItemCodesProvider.future);
      expect(codes, isEmpty);
    });
  });

  group('ManufacturingService.getRecipeSheet', () {
    test('sends the positive lines as a JSON string', () async {
      final dio = _dio();
      final response = await ManufacturingService(
        dio,
      ).getRecipeSheet({'Tiramisu Large': 10, 'Tiramisu Small': 0});

      final call = _sheetCalls(dio).single;
      expect(call['method'], 'POST');
      expect((call['data'] as Map)['lines'], isA<String>());
      expect(_linesOf(call), [
        {'item_code': 'Tiramisu Large', 'qty': 10},
      ]);
      expect(response.sheets.single.title, 'Tiramisu');
    });

    test('nothing positive answers without a call', () async {
      final dio = _dio();
      final response = await ManufacturingService(
        dio,
      ).getRecipeSheet({'Tiramisu Large': 0});

      expect(response.isEmpty, isTrue);
      expect(_sheetCalls(dio), isEmpty);
    });

    test('a failure propagates', () async {
      final dio = _dio()
        ..setError(
          _recipeSheetPath,
          createMockDioException(statusCode: 500, path: _recipeSheetPath),
        );
      await expectLater(
        ManufacturingService(dio).getRecipeSheet({'Tiramisu Large': 1}),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('recipeSheetProvider', () {
    test('no SOP jar typed: null and no call', () async {
      final dio = _dio();
      final container = _container(dio);
      await container.read(sopItemCodesProvider.future);

      container
          .read(dailyPlanDraftProvider.notifier)
          .setQuantity('JAR-LOTUS', 5);
      await Future<void>.delayed(_settle);

      expect(await container.read(recipeSheetProvider.future), isNull);
      expect(_sheetCalls(dio), isEmpty);
    });

    test('a failing SOP list means no call at all', () async {
      final dio = _dio()
        ..setError(
          ApiEndpoints.listItemsWithSop,
          createMockDioException(
            statusCode: 404,
            path: ApiEndpoints.listItemsWithSop,
          ),
        );
      final container = _container(dio);
      await container.read(sopItemCodesProvider.future);

      container
          .read(dailyPlanDraftProvider.notifier)
          .setQuantity('Tiramisu Large', 5);
      await Future<void>.delayed(_settle);

      expect(await container.read(recipeSheetProvider.future), isNull);
      expect(_sheetCalls(dio), isEmpty);
    });

    test('asks only for the SOP jars, once', () async {
      final dio = _dio(sopItems: ['Tiramisu Large', 'Tiramisu Small']);
      final container = _container(dio);
      await container.read(sopItemCodesProvider.future);

      container.read(dailyPlanDraftProvider.notifier)
        ..setQuantity('Tiramisu Large', 10)
        ..setQuantity('JAR-LOTUS', 7)
        ..setQuantity('Tiramisu Small', 6);
      await Future<void>.delayed(_settle);

      final sheet = await container.read(recipeSheetProvider.future);
      expect(sheet!.sheets.single.title, 'Tiramisu');
      final call = _sheetCalls(dio).single;
      expect(_linesOf(call), [
        {'item_code': 'Tiramisu Large', 'qty': 10},
        {'item_code': 'Tiramisu Small', 'qty': 6},
      ]);

      // A jar without a recipe changing is not a new sheet.
      container
          .read(dailyPlanDraftProvider.notifier)
          .setQuantity('JAR-LOTUS', 9);
      await Future<void>.delayed(_settle);
      expect(_sheetCalls(dio), hasLength(1));
    });

    test(
      'rapid typing collapses into one request for the last count',
      () async {
        final dio = _dio();
        final container = _container(dio);
        await container.read(sopItemCodesProvider.future);

        final draft = container.read(dailyPlanDraftProvider.notifier);
        draft.setQuantity('Tiramisu Large', 1);
        await Future<void>.delayed(const Duration(milliseconds: 100));
        draft.setQuantity('Tiramisu Large', 12);
        await Future<void>.delayed(const Duration(milliseconds: 100));
        draft.setQuantity('Tiramisu Large', 120);
        await Future<void>.delayed(_settle);

        final call = _sheetCalls(dio).single;
        expect(_linesOf(call), [
          {'item_code': 'Tiramisu Large', 'qty': 120},
        ]);
        expect(
          await container.read(recipeSheetProvider.future),
          isA<RecipeSheetResponse>(),
        );
      },
    );

    test('clearing the SOP jars goes back to null', () async {
      final dio = _dio();
      final container = _container(dio);
      await container.read(sopItemCodesProvider.future);

      final draft = container.read(dailyPlanDraftProvider.notifier);
      draft.setQuantity('Tiramisu Large', 4);
      await Future<void>.delayed(_settle);
      expect(await container.read(recipeSheetProvider.future), isNotNull);

      draft.setQuantity('Tiramisu Large', 0);
      expect(await container.read(recipeSheetProvider.future), isNull);
      expect(_sheetCalls(dio), hasLength(1));
    });
  });

  test('RecipeSheetJars is value-equal regardless of key order', () {
    expect(
      RecipeSheetJars({'b': 2, 'a': 1, 'c': 0}),
      RecipeSheetJars({'a': 1, 'b': 2}),
    );
    expect(
      RecipeSheetJars.from({'a': 1, 'x': 3}, {'a'}),
      RecipeSheetJars({'a': 1}),
    );
  });
}
