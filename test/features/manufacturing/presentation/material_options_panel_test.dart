import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/manufacturing/data/manufacturing_service.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/widgets/material_options_panel.dart';
import 'package:jarz_pos/src/features/manufacturing/state/production_providers.dart';

import '../../../helpers/mock_services.dart';

class _Harness extends StatefulWidget {
  const _Harness({required this.initialSelections});

  final Map<String, String> initialSelections;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late Map<String, String> selections = Map.of(widget.initialSelections);

  @override
  Widget build(BuildContext context) {
    return MaterialOptionsPanel(
      bomName: 'BOM-BLUEBERRY',
      qty: 10,
      selections: selections,
      onSelectionChanged: (original, selected) {
        setState(() {
          if (original == selected) {
            selections.remove(original);
          } else {
            selections[original] = selected;
          }
        });
      },
    );
  }
}

Map<String, dynamic> _response() => {
  'message': {
    'bom_name': 'BOM-BLUEBERRY',
    'qty': 10,
    'components': [
      {
        'original_item_code': 'ALDIA',
        'original_item_name': 'Aldia Blueberry',
        'required_qty': 10,
        'stock_uom': 'Kg',
        'combined_available_qty': 30,
        'options': [
          {
            'item_code': 'ALDIA',
            'item_name': 'Aldia Blueberry',
            'stock_uom': 'Kg',
            'available_qty': 10,
            'is_recipe_item': 1,
          },
          {
            'item_code': 'PURATOS',
            'item_name': 'Puratos Blueberry',
            'stock_uom': 'Kg',
            'available_qty': 20,
          },
        ],
      },
      {
        'original_item_code': 'PURATOS',
        'original_item_name': 'Puratos Blueberry',
        'required_qty': 5,
        'stock_uom': 'Kg',
        'combined_available_qty': 30,
        'options': [
          {
            'item_code': 'PURATOS',
            'item_name': 'Puratos Blueberry',
            'stock_uom': 'Kg',
            'available_qty': 20,
            'is_recipe_item': 1,
          },
          {
            'item_code': 'ALDIA',
            'item_name': 'Aldia Blueberry',
            'stock_uom': 'Kg',
            'available_qty': 10,
          },
        ],
      },
    ],
  },
};

Future<void> _pump(
  WidgetTester tester, {
  Map<String, String> selections = const {},
  Map<String, dynamic>? response,
}) async {
  final dio = MockDio()
    ..setResponse(
      '/api/method/jarz_pos.api.manufacturing.get_material_options',
      response ?? _response(),
    );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        manufacturingServiceProvider.overrideWithValue(
          ManufacturingService(dio),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: _Harness(initialSelections: selections)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'does not offer an actual item already used by another component',
    (tester) async {
      await _pump(tester);

      await tester.tap(find.byKey(const ValueKey('ALDIA:ALDIA')));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Puratos Blueberry').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('ALDIA:ALDIA')), findsOneWidget);
    },
  );

  testWidgets('requires an explicit reset for a stale saved choice', (
    tester,
  ) async {
    await _pump(tester, selections: const {'ALDIA': 'REMOVED-BRAND'});

    expect(find.text('REMOVED-BRAND'), findsOneWidget);
    expect(
      materialSelectionsAreValid(
        await ProviderScope.containerOf(
          tester.element(find.byType(_Harness)),
        ).read(
          materialOptionsProvider(
            const MaterialOptionsRequest(bomName: 'BOM-BLUEBERRY', qty: 10),
          ).future,
        ),
        tester.state<_HarnessState>(find.byType(_Harness)).selections,
      ),
      isFalse,
    );
    await tester.tap(find.text('Retry').first);
    await tester.pumpAndSettle();

    expect(find.text('REMOVED-BRAND'), findsNothing);
    expect(find.byKey(const ValueKey('ALDIA:ALDIA')), findsOneWidget);
    expect(
      tester.state<_HarnessState>(find.byType(_Harness)).selections,
      isEmpty,
    );
  });

  testWidgets('shows and clears a selection key removed from the BOM', (
    tester,
  ) async {
    await _pump(
      tester,
      selections: const {'OLD-BOM-ITEM': 'REMOVED-BRAND'},
      response: {
        'message': {
          'bom_name': 'BOM-BLUEBERRY',
          'qty': 10,
          'components': [
            {
              'original_item_code': 'ALDIA',
              'original_item_name': 'Aldia Blueberry',
              'required_qty': 10,
              'stock_uom': 'Kg',
              'options': [
                {
                  'item_code': 'ALDIA',
                  'item_name': 'Aldia Blueberry',
                  'stock_uom': 'Kg',
                  'available_qty': 10,
                  'is_recipe_item': 1,
                },
              ],
            },
          ],
        },
      },
    );

    expect(find.textContaining('OLD-BOM-ITEM'), findsOneWidget);
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(
      tester.state<_HarnessState>(find.byType(_Harness)).selections,
      isEmpty,
    );
  });
}
