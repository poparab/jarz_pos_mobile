import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/storage_keys.dart';
import 'package:jarz_pos/src/core/localization/locale_notifier.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/inventory_count/data/inventory_count_service.dart';
import 'package:jarz_pos/src/features/inventory_count/presentation/inventory_count_screen.dart';
import 'package:jarz_pos/src/features/manager/state/manager_providers.dart';
import 'package:jarz_pos/src/features/shift/state/shift_notifier.dart';

class _FakeInventoryCountService extends InventoryCountService {
  _FakeInventoryCountService({required this.warehouses, required this.items})
    : super(Dio());

  final List<Map<String, dynamic>> warehouses;
  final List<Map<String, dynamic>> items;
  final List<String> requestedWarehouses = <String>[];
  bool submitCalled = false;
  String? submittedWarehouse;
  List<Map<String, dynamic>>? submittedLines;
  String? submittedPostingDate;
  bool? submittedEnforceAll;

  @override
  Future<List<Map<String, dynamic>>> listWarehouses({String? company}) async {
    return warehouses
        .map((warehouse) => Map<String, dynamic>.from(warehouse))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> listItemsForCount({
    required String warehouse,
    String? search,
    String? itemGroup,
    int? limit,
  }) async {
    requestedWarehouses.add(warehouse);
    return items.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  @override
  Future<Map<String, dynamic>> submitReconciliation({
    required String warehouse,
    required List<Map<String, dynamic>> lines,
    String? postingDate,
    bool enforceAll = true,
  }) async {
    submitCalled = true;
    submittedWarehouse = warehouse;
    submittedLines = lines
        .map((line) => Map<String, dynamic>.from(line))
        .toList(growable: false);
    submittedPostingDate = postingDate;
    submittedEnforceAll = enforceAll;
    return <String, dynamic>{'stock_reconciliation': 'SR-TEST'};
  }
}

class _MemoryBox implements Box<dynamic> {
  final Map<dynamic, dynamic> _values = <dynamic, dynamic>{};

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) =>
      _values.containsKey(key) ? _values[key] : defaultValue;

  @override
  Future<void> put(dynamic key, dynamic value) {
    _values[key] = value;
    return Future<void>.value();
  }

  @override
  Future<void> delete(dynamic key) {
    _values.remove(key);
    return Future<void>.value();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpInventoryCountScreen(
  WidgetTester tester,
  _FakeInventoryCountService service, {
  Box<dynamic>? cacheBox,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        inventoryCountServiceProvider.overrideWithValue(service),
        managerAccessProvider.overrideWith((ref) async => true),
        isJarzManagerProvider.overrideWith((ref) => false),
        isLineManagerProvider.overrideWith((ref) => false),
        canActAsLineManagerProvider.overrideWith((ref) => false),
        isModeratorProvider.overrideWith((ref) => false),
        requirePosShiftProvider.overrideWith((ref) => false),
        activeShiftProvider.overrideWith((ref) async => null),
        localeNotifierProvider.overrideWith(
          (ref) => LocaleNotifier(Hive.box(HiveBoxes.appSettings)),
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
        home: InventoryCountScreen(cacheBox: cacheBox ?? _MemoryBox()),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> _selectWarehouse(WidgetTester tester, String warehouseName) async {
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(warehouseName).last);
  await tester.pumpAndSettle();
}

Future<void> _startCount(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.play_arrow));
  await tester.pumpAndSettle();
}

Future<void> _enterItemCount(
  WidgetTester tester, {
  required String itemCode,
  required String quantity,
}) async {
  final countField = find.descendant(
    of: find.byKey(ValueKey(itemCode)),
    matching: find.byType(TextField),
  );
  await tester.enterText(countField, quantity);
  await tester.pumpAndSettle();
}

Future<void> _enterItemComponentCount(
  WidgetTester tester, {
  required String itemCode,
  required String uom,
  required String quantity,
}) async {
  final component = find.byKey(ValueKey('$itemCode:component:$uom'));
  await tester.ensureVisible(component);
  await tester.pumpAndSettle();
  await tester.enterText(
    find.descendant(of: component, matching: find.byType(TextField)),
    quantity,
  );
  await tester.pumpAndSettle();
}

Future<void> _submitItemComponentCount(
  WidgetTester tester, {
  required String itemCode,
  required String uom,
}) async {
  final component = find.byKey(ValueKey('$itemCode:component:$uom'));
  await tester.ensureVisible(component);
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: component,
      matching: find.byIcon(Icons.check_circle_outline),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectItemComponentUom(
  WidgetTester tester, {
  required String itemCode,
  required String currentUom,
  required String nextUom,
}) async {
  final component = find.byKey(ValueKey('$itemCode:component:$currentUom'));
  await tester.ensureVisible(component);
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: component,
      matching: find.byType(DropdownButtonFormField<String>),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(nextUom).last);
  await tester.pumpAndSettle();
}

Future<void> _addItemUom(WidgetTester tester, String itemCode) async {
  final item = find.byKey(ValueKey(itemCode));
  final addButton = find.descendant(of: item, matching: find.byIcon(Icons.add));
  await tester.ensureVisible(addButton);
  await tester.pumpAndSettle();
  await tester.tap(addButton);
  await tester.pumpAndSettle();
}

Future<void> _submitItemCount(
  WidgetTester tester, {
  required String itemCode,
}) async {
  final submitLabel = find.descendant(
    of: find.byKey(ValueKey(itemCode)),
    matching: find.text('Submit'),
  );
  final submitButton = find.ancestor(
    of: submitLabel,
    matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
  );
  await tester.tap(submitButton);
  await tester.pumpAndSettle();
}

Future<void> _tapQuantityButton(
  WidgetTester tester, {
  required String itemCode,
  required IconData icon,
}) async {
  await tester.tap(
    find.descendant(
      of: find.byKey(ValueKey(itemCode)),
      matching: find.byIcon(icon),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _progressText(String value) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && (widget.data?.contains(value) ?? false),
  );
}

Future<void> _openReview(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.visibility_outlined));
  await tester.pumpAndSettle();
}

ButtonStyleButton _buttonForIcon(WidgetTester tester, IconData icon) {
  return tester.widget<ButtonStyleButton>(
    find.ancestor(
      of: find.byIcon(icon),
      matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
    ),
  );
}

Future<void> _confirmSubmitDialog(WidgetTester tester) async {
  expect(find.text('Confirm posting date'), findsOneWidget);
  await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveTempDir;

  setUpAll(() async {
    hiveTempDir = await Directory.systemTemp.createTemp(
      'inventory-count-screen-test',
    );
    Hive.init(hiveTempDir.path);
    await Hive.openBox(HiveBoxes.appSettings);
  });

  tearDown(() async {
    if (Hive.isBoxOpen(HiveBoxes.appSettings)) {
      await Hive.box(HiveBoxes.appSettings).clear();
    }
  });

  tearDownAll(() async {
    if (Hive.isBoxOpen(HiveBoxes.appSettings)) {
      await Hive.box(HiveBoxes.appSettings).close();
    }
    await Hive.close();
    if (await hiveTempDir.exists()) {
      await hiveTempDir.delete(recursive: true);
    }
  });

  group('InventoryCountScreen staged flow', () {
    testWidgets(
      'keeps submit disabled in review until all loaded items are counted',
      (tester) async {
        final service = _FakeInventoryCountService(
          warehouses: const [
            {'name': 'Main Warehouse', 'company': 'Jarz'},
          ],
          items: const [
            {
              'item_code': 'ITEM-001',
              'item_name': 'Blueberry Box',
              'current_qty': 10,
              'stock_uom': 'Box',
              'valuation_rate': 12.5,
            },
            {
              'item_code': 'ITEM-002',
              'item_name': 'Mango Box',
              'current_qty': 4,
              'stock_uom': 'Box',
              'valuation_rate': 8.0,
            },
          ],
        );

        await _pumpInventoryCountScreen(tester, service);

        await _selectWarehouse(tester, 'Main Warehouse');
        await _startCount(tester);

        expect(service.requestedWarehouses, equals(['Main Warehouse']));
        expect(find.text('2 of 2 items'), findsOneWidget);
        expect(find.text('Back to setup'), findsOneWidget);

        await _enterItemCount(tester, itemCode: 'ITEM-001', quantity: '9');

        expect(_progressText('0 / 2'), findsOneWidget);

        await _submitItemCount(tester, itemCode: 'ITEM-001');

        expect(_progressText('1 / 2'), findsOneWidget);

        await _openReview(tester);

        expect(find.text('Back to counting'), findsOneWidget);
        expect(find.textContaining('Missing items'), findsWidgets);

        final submitButton = _buttonForIcon(tester, Icons.save_outlined);
        expect(submitButton.onPressed, isNull);
        expect(service.submitCalled, isFalse);
      },
    );

    testWidgets(
      'accepts typed decimal quantities and keeps stepper buttons working',
      (tester) async {
        final service = _FakeInventoryCountService(
          warehouses: const [
            {'name': 'Main Warehouse', 'company': 'Jarz'},
          ],
          items: const [
            {
              'item_code': 'ITEM-001',
              'item_name': 'Blueberry Box',
              'current_qty': 10,
              'stock_uom': 'Box',
              'valuation_rate': 12.5,
            },
          ],
        );

        await _pumpInventoryCountScreen(tester, service);

        await _selectWarehouse(tester, 'Main Warehouse');
        await _startCount(tester);

        await _enterItemCount(tester, itemCode: 'ITEM-001', quantity: '0.5');

        expect(find.text('0.5'), findsOneWidget);

        await _tapQuantityButton(
          tester,
          itemCode: 'ITEM-001',
          icon: Icons.add_circle_outline,
        );
        expect(find.text('1.5'), findsOneWidget);

        await _tapQuantityButton(
          tester,
          itemCode: 'ITEM-001',
          icon: Icons.remove_circle_outline,
        );
        expect(find.text('0.5'), findsOneWidget);

        await _submitItemCount(tester, itemCode: 'ITEM-001');
        await _openReview(tester);

        await tester.tap(find.byIcon(Icons.save_outlined));
        await tester.pumpAndSettle();
        await _confirmSubmitDialog(tester);

        expect(service.submitCalled, isTrue);
        expect(service.submittedLines, hasLength(1));
        expect(service.submittedLines!.single['counted_qty'], equals(0.5));
      },
    );

    testWidgets(
      'submits multiple UOM components and reviews their combined stock quantity',
      (tester) async {
        final service = _FakeInventoryCountService(
          warehouses: const [
            {'name': 'Main Warehouse', 'company': 'Jarz'},
          ],
          items: const [
            {
              'item_code': 'BLUEBERRY',
              'item_name': 'Blueberry filling',
              'current_qty': 10,
              'stock_uom': 'Kg',
              'valuation_rate': 12.5,
              'uoms': [
                {'uom': 'Box', 'conversion_factor': 2.7},
              ],
            },
          ],
        );

        await _pumpInventoryCountScreen(tester, service);
        await _selectWarehouse(tester, 'Main Warehouse');
        await _startCount(tester);

        await _selectItemComponentUom(
          tester,
          itemCode: 'BLUEBERRY',
          currentUom: 'Kg',
          nextUom: 'Box',
        );
        await _enterItemComponentCount(
          tester,
          itemCode: 'BLUEBERRY',
          uom: 'Box',
          quantity: '4',
        );
        await _submitItemComponentCount(
          tester,
          itemCode: 'BLUEBERRY',
          uom: 'Box',
        );
        await _addItemUom(tester, 'BLUEBERRY');
        await _enterItemComponentCount(
          tester,
          itemCode: 'BLUEBERRY',
          uom: 'Kg',
          quantity: '1.5',
        );
        await _submitItemComponentCount(
          tester,
          itemCode: 'BLUEBERRY',
          uom: 'Kg',
        );

        await _openReview(tester);

        expect(find.text('Counted: 4 Box'), findsOneWidget);
        expect(find.text('Counted: 1.5 Kg'), findsOneWidget);
        expect(find.text('Stock equivalent: 12.3 Kg'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.save_outlined));
        await tester.pumpAndSettle();
        await _confirmSubmitDialog(tester);

        expect(service.submittedLines, hasLength(2));
        expect(
          service.submittedLines,
          equals([
            {
              'item_code': 'BLUEBERRY',
              'counted_qty': 4.0,
              'uom': 'Box',
              'valuation_rate': 12.5,
            },
            {
              'item_code': 'BLUEBERRY',
              'counted_qty': 1.5,
              'uom': 'Kg',
              'valuation_rate': 12.5,
            },
          ]),
        );
      },
    );

    testWidgets(
      'blocks spot-count submission while an added UOM is incomplete',
      (tester) async {
        final service = _FakeInventoryCountService(
          warehouses: const [
            {'name': 'Main Warehouse', 'company': 'Jarz'},
          ],
          items: const [
            {
              'item_code': 'BLUEBERRY',
              'item_name': 'Blueberry filling',
              'current_qty': 10,
              'stock_uom': 'Kg',
              'uoms': [
                {'uom': 'Box', 'conversion_factor': 2.7},
              ],
            },
          ],
        );

        await _pumpInventoryCountScreen(tester, service);
        await _selectWarehouse(tester, 'Main Warehouse');
        await tester.tap(find.text('Spot count'));
        await tester.pumpAndSettle();
        await _startCount(tester);
        await _enterItemComponentCount(
          tester,
          itemCode: 'BLUEBERRY',
          uom: 'Kg',
          quantity: '1.5',
        );
        await _submitItemComponentCount(
          tester,
          itemCode: 'BLUEBERRY',
          uom: 'Kg',
        );
        await _addItemUom(tester, 'BLUEBERRY');

        expect(find.text('Pending'), findsOneWidget);
        await _openReview(tester);

        expect(find.textContaining('Missing items'), findsWidgets);
        expect(_buttonForIcon(tester, Icons.save_outlined).onPressed, isNull);
        expect(service.submitCalled, isFalse);
      },
    );

    testWidgets(
      'groups linked brands while keeping actual-item counts separate',
      (tester) async {
        const groupKey = 'ALDIA-BLUEBERRY|PURATOS-BLUEBERRY';
        final service = _FakeInventoryCountService(
          warehouses: const [
            {'name': 'Main Warehouse', 'company': 'Jarz'},
          ],
          items: const [
            {
              'item_code': 'ALDIA-BLUEBERRY',
              'item_name': 'Aldia Blueberry',
              'current_qty': 1.7,
              'stock_uom': 'Kg',
              'has_batch_no': 1,
              'alternative_group_key': groupKey,
              'linked_items_display': 'Aldia Blueberry + Puratos Blueberry',
              'combined_net_current_qty': 7.7,
              'uoms': [
                {'uom': 'Box', 'conversion_factor': 2.7},
              ],
            },
            {
              'item_code': 'PURATOS-BLUEBERRY',
              'item_name': 'Puratos Blueberry',
              'current_qty': 6,
              'stock_uom': 'Kg',
              'has_serial_no': 1,
              'alternative_group_key': groupKey,
              'linked_items_display': 'Aldia Blueberry + Puratos Blueberry',
              'combined_net_current_qty': 7.7,
              'uoms': [
                {'uom': 'Box', 'conversion_factor': 5},
              ],
            },
          ],
        );

        await _pumpInventoryCountScreen(tester, service);
        await _selectWarehouse(tester, 'Main Warehouse');
        await _startCount(tester);

        expect(
          find.byKey(const ValueKey('alternative-group:$groupKey')),
          findsOneWidget,
        );
        expect(find.text('Current: 7.7 Kg'), findsNothing);

        await _selectItemComponentUom(
          tester,
          itemCode: 'ALDIA-BLUEBERRY',
          currentUom: 'Kg',
          nextUom: 'Box',
        );
        await _enterItemComponentCount(
          tester,
          itemCode: 'ALDIA-BLUEBERRY',
          uom: 'Box',
          quantity: '1',
        );
        await _submitItemComponentCount(
          tester,
          itemCode: 'ALDIA-BLUEBERRY',
          uom: 'Box',
        );

        await _openReview(tester);
        expect(find.text('Stock equivalent: 2.7 Kg'), findsNothing);
        expect(_buttonForIcon(tester, Icons.save_outlined).onPressed, isNull);
        await tester.tap(find.text('Back to counting'));
        await tester.pumpAndSettle();

        await _selectItemComponentUom(
          tester,
          itemCode: 'PURATOS-BLUEBERRY',
          currentUom: 'Kg',
          nextUom: 'Box',
        );
        await _enterItemComponentCount(
          tester,
          itemCode: 'PURATOS-BLUEBERRY',
          uom: 'Box',
          quantity: '1',
        );
        await _submitItemComponentCount(
          tester,
          itemCode: 'PURATOS-BLUEBERRY',
          uom: 'Box',
        );

        await _openReview(tester);

        expect(
          find.byKey(const ValueKey('review-group:$groupKey')),
          findsOneWidget,
        );
        expect(find.text('Stock equivalent: 7.7 Kg'), findsOneWidget);
        expect(find.text('Current: 7.7 Kg'), findsOneWidget);
        expect(find.text('Delta: +1 Kg'), findsOneWidget);
        expect(find.text('Delta: -1 Kg'), findsOneWidget);
        expect(find.text('Batch tracked'), findsOneWidget);
        expect(find.text('Serial tracked'), findsOneWidget);
        expect(find.text('Aldia Blueberry · ALDIA-BLUEBERRY'), findsOneWidget);
        expect(
          find.text('Puratos Blueberry · PURATOS-BLUEBERRY'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'restores mixed-UOM drafts without treating edited quantities as confirmed',
      (tester) async {
        final cacheBox = _MemoryBox();
        final service = _FakeInventoryCountService(
          warehouses: const [
            {'name': 'Main Warehouse', 'company': 'Jarz'},
          ],
          items: const [
            {
              'item_code': 'BLUEBERRY',
              'item_name': 'Blueberry filling',
              'current_qty': 10,
              'stock_uom': 'Kg',
              'uoms': [
                {'uom': 'Box', 'conversion_factor': 2.7},
              ],
            },
          ],
        );

        await _pumpInventoryCountScreen(tester, service, cacheBox: cacheBox);
        await _selectWarehouse(tester, 'Main Warehouse');
        await _startCount(tester);
        await _selectItemComponentUom(
          tester,
          itemCode: 'BLUEBERRY',
          currentUom: 'Kg',
          nextUom: 'Box',
        );
        await _enterItemComponentCount(
          tester,
          itemCode: 'BLUEBERRY',
          uom: 'Box',
          quantity: '4',
        );
        await _submitItemComponentCount(
          tester,
          itemCode: 'BLUEBERRY',
          uom: 'Box',
        );
        await _addItemUom(tester, 'BLUEBERRY');
        await _enterItemComponentCount(
          tester,
          itemCode: 'BLUEBERRY',
          uom: 'Kg',
          quantity: '1.5',
        );
        await _submitItemComponentCount(
          tester,
          itemCode: 'BLUEBERRY',
          uom: 'Kg',
        );

        await _enterItemComponentCount(
          tester,
          itemCode: 'BLUEBERRY',
          uom: 'Kg',
          quantity: '',
        );
        expect(find.text('Pending'), findsOneWidget);

        await tester.tap(find.text('Back to setup'));
        await tester.pumpAndSettle();
        await _startCount(tester);

        expect(find.text('Pending'), findsOneWidget);
        final reloadedBoxField = find.descendant(
          of: find.byKey(const ValueKey('BLUEBERRY:component:Box')),
          matching: find.byType(TextField),
        );
        expect(
          tester.widget<TextField>(reloadedBoxField).controller?.text,
          '4',
        );
        final reloadedKgField = find.descendant(
          of: find.byKey(const ValueKey('BLUEBERRY:component:Kg')),
          matching: find.byType(TextField),
        );
        expect(
          tester.widget<TextField>(reloadedKgField).controller?.text,
          isEmpty,
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await _pumpInventoryCountScreen(tester, service, cacheBox: cacheBox);

        expect(find.text('Pending'), findsOneWidget);
        final restoredField = find.descendant(
          of: find.byKey(const ValueKey('BLUEBERRY:component:Kg')),
          matching: find.byType(TextField),
        );
        expect(
          tester.widget<TextField>(restoredField).controller?.text,
          isEmpty,
        );
        final restoredBoxField = find.descendant(
          of: find.byKey(const ValueKey('BLUEBERRY:component:Box')),
          matching: find.byType(TextField),
        );
        expect(
          tester.widget<TextField>(restoredBoxField).controller?.text,
          '4',
        );
        await _openReview(tester);
        expect(_buttonForIcon(tester, Icons.save_outlined).onPressed, isNull);
      },
    );

    testWidgets(
      'removing the first component keeps the second UOM quantity attached',
      (tester) async {
        final service = _FakeInventoryCountService(
          warehouses: const [
            {'name': 'Main Warehouse', 'company': 'Jarz'},
          ],
          items: const [
            {
              'item_code': 'BLUEBERRY',
              'item_name': 'Blueberry filling',
              'current_qty': 1,
              'stock_uom': 'Kg',
              'uoms': [
                {'uom': 'Box', 'conversion_factor': 2.7},
              ],
            },
          ],
        );

        await _pumpInventoryCountScreen(tester, service);
        await _selectWarehouse(tester, 'Main Warehouse');
        await _startCount(tester);
        await _selectItemComponentUom(
          tester,
          itemCode: 'BLUEBERRY',
          currentUom: 'Kg',
          nextUom: 'Box',
        );
        await _enterItemComponentCount(
          tester,
          itemCode: 'BLUEBERRY',
          uom: 'Box',
          quantity: '4',
        );
        await _submitItemComponentCount(
          tester,
          itemCode: 'BLUEBERRY',
          uom: 'Box',
        );
        await _addItemUom(tester, 'BLUEBERRY');
        await _enterItemComponentCount(
          tester,
          itemCode: 'BLUEBERRY',
          uom: 'Kg',
          quantity: '1.5',
        );
        await _submitItemComponentCount(
          tester,
          itemCode: 'BLUEBERRY',
          uom: 'Kg',
        );

        await tester.tap(
          find.descendant(
            of: find.byKey(const ValueKey('BLUEBERRY:component:Box')),
            matching: find.byIcon(Icons.delete_outline),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('BLUEBERRY:component:Box')),
          findsNothing,
        );
        final remainingField = find.descendant(
          of: find.byKey(const ValueKey('BLUEBERRY:component:Kg')),
          matching: find.byType(TextField),
        );
        expect(
          tester.widget<TextField>(remainingField).controller?.text,
          '1.5',
        );
      },
    );

    testWidgets(
      'spot count mode allows partial submit without missing-item blocking',
      (tester) async {
        final service = _FakeInventoryCountService(
          warehouses: const [
            {'name': 'Main Warehouse', 'company': 'Jarz'},
          ],
          items: const [
            {
              'item_code': 'ITEM-001',
              'item_name': 'Blueberry Box',
              'current_qty': 10,
              'stock_uom': 'Box',
              'valuation_rate': 12.5,
            },
            {
              'item_code': 'ITEM-002',
              'item_name': 'Mango Box',
              'current_qty': 4,
              'stock_uom': 'Box',
              'valuation_rate': 8.0,
            },
          ],
        );

        await _pumpInventoryCountScreen(tester, service);

        await _selectWarehouse(tester, 'Main Warehouse');
        await tester.tap(find.text('Spot count'));
        await tester.pumpAndSettle();

        await _startCount(tester);
        await _enterItemCount(tester, itemCode: 'ITEM-001', quantity: '9');
        await _submitItemCount(tester, itemCode: 'ITEM-001');
        await _openReview(tester);

        expect(find.text('Missing items'), findsNothing);
        expect(
          find.text('Count every loaded item before submitting (1 remaining)'),
          findsNothing,
        );

        final submitButton = _buttonForIcon(tester, Icons.save_outlined);
        expect(submitButton.onPressed, isNotNull);

        await tester.tap(find.byIcon(Icons.save_outlined));
        await tester.pumpAndSettle();
        await _confirmSubmitDialog(tester);

        expect(service.submitCalled, isTrue);
        expect(service.submittedWarehouse, equals('Main Warehouse'));
        expect(service.submittedEnforceAll, isFalse);
        expect(service.submittedPostingDate, isNotNull);
        expect(service.submittedLines, hasLength(1));
        expect(service.submittedLines!.single['item_code'], equals('ITEM-001'));
        expect(service.submittedLines!.single['counted_qty'], equals(9));
        expect(service.submittedLines!.single['uom'], equals('Box'));
        expect(service.submittedLines!.single['valuation_rate'], equals(12.5));
      },
    );

    testWidgets(
      'full submit path confirms date, submits all counted lines, and resets to setup',
      (tester) async {
        final service = _FakeInventoryCountService(
          warehouses: const [
            {'name': 'Main Warehouse', 'company': 'Jarz'},
          ],
          items: const [
            {
              'item_code': 'ITEM-001',
              'item_name': 'Blueberry Box',
              'current_qty': 10,
              'stock_uom': 'Box',
              'valuation_rate': 12.5,
            },
            {
              'item_code': 'ITEM-002',
              'item_name': 'Mango Box',
              'current_qty': 4,
              'stock_uom': 'Box',
              'valuation_rate': 8.0,
            },
          ],
        );

        await _pumpInventoryCountScreen(tester, service);

        await _selectWarehouse(tester, 'Main Warehouse');
        await _startCount(tester);
        await _enterItemCount(tester, itemCode: 'ITEM-001', quantity: '9');
        await _submitItemCount(tester, itemCode: 'ITEM-001');
        await _enterItemCount(tester, itemCode: 'ITEM-002', quantity: '4');
        await _submitItemCount(tester, itemCode: 'ITEM-002');
        await _openReview(tester);

        final submitButton = _buttonForIcon(tester, Icons.save_outlined);
        expect(submitButton.onPressed, isNotNull);

        await tester.tap(find.byIcon(Icons.save_outlined));
        await tester.pumpAndSettle();
        await _confirmSubmitDialog(tester);

        expect(service.submitCalled, isTrue);
        expect(service.submittedWarehouse, equals('Main Warehouse'));
        expect(service.submittedEnforceAll, isTrue);
        expect(service.submittedPostingDate, isNotNull);
        expect(service.submittedLines, hasLength(2));
        expect(
          service.submittedLines!.map((line) => line['item_code']),
          containsAll(<String>['ITEM-001', 'ITEM-002']),
        );
        expect(find.text('Submitted: SR-TEST'), findsOneWidget);
        expect(find.text('Start count'), findsOneWidget);
        expect(_progressText('0 / 2'), findsOneWidget);
        expect(find.text('Back to counting'), findsNothing);

        await _startCount(tester);

        expect(service.requestedWarehouses, hasLength(2));
        expect(_progressText('0 / 2'), findsOneWidget);
        expect(find.text('Back to setup'), findsOneWidget);
        expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
        expect(find.text('Counted'), findsNothing);
      },
    );
    testWidgets(
      'groups the sheet by category and filters to one category on tap',
      (tester) async {
        // A factory sheet is several shelves in one list. Without headers and
        // chips the only way to reach one shelf was to type its group name into
        // the search box.
        final service = _FakeInventoryCountService(
          warehouses: const [
            {'name': 'Raw Material - J', 'company': 'Jarz'},
          ],
          items: const [
            {
              'item_code': 'RM-1',
              'item_name': 'flour',
              'item_group': 'Raw Material',
              'current_qty': 5,
              'stock_uom': 'Kg',
            },
            {
              'item_code': 'LB-1',
              'item_name': 'Lotus Jar label 212',
              'item_group': 'Labels',
              'current_qty': 200,
              'stock_uom': 'Nos',
            },
            {
              'item_code': 'PK-1',
              'item_name': 'Glass Jar',
              'item_group': 'Packaging',
              'current_qty': 40,
              'stock_uom': 'Nos',
            },
          ],
        );

        await _pumpInventoryCountScreen(tester, service);
        await _selectWarehouse(tester, 'Raw Material - J');
        await _startCount(tester);

        // One chip per category, plus All, each carrying its uncounted total.
        expect(
          find.widgetWithText(FilterChip, 'All Groups (3)'),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(FilterChip, 'Raw Material (1)'),
          findsOneWidget,
        );
        expect(find.widgetWithText(FilterChip, 'Labels (1)'), findsOneWidget);
        expect(
          find.widgetWithText(FilterChip, 'Packaging (1)'),
          findsOneWidget,
        );

        // Headers label each run. Assert only that they appear: the list is
        // lazily built, so entry rows below the test viewport are absent from
        // the element tree and asserting on them would tie this to screen size.
        // The "N of M items" counter is the viewport-safe read on filtering.
        expect(find.text('0/1'), findsWidgets);
        expect(find.text('3 of 3 items'), findsOneWidget);

        await tester.tap(find.widgetWithText(FilterChip, 'Packaging (1)'));
        await tester.pumpAndSettle();

        // Only the chosen shelf remains, and its header is dropped as
        // redundant with the selected chip.
        expect(find.text('1 of 3 items'), findsOneWidget);
        expect(find.text('0/1'), findsNothing);
        expect(find.byKey(const ValueKey('LB-1')), findsNothing);
        expect(find.byKey(const ValueKey('RM-1')), findsNothing);

        await tester.tap(find.widgetWithText(FilterChip, 'All Groups (3)'));
        await tester.pumpAndSettle();
        expect(find.text('3 of 3 items'), findsOneWidget);
        expect(find.text('0/1'), findsWidgets);
      },
    );

    testWidgets(
      'hides the category chips when the sheet is a single category',
      (tester) async {
        final service = _FakeInventoryCountService(
          warehouses: const [
            {'name': 'Consumables - J', 'company': 'Jarz'},
          ],
          items: const [
            {
              'item_code': 'CN-1',
              'item_name': 'Tissue',
              'item_group': 'Consumable',
              'current_qty': 12,
              'stock_uom': 'Nos',
            },
            {
              'item_code': 'CN-2',
              'item_name': 'gloves',
              'item_group': 'Consumable',
              'current_qty': 50,
              'stock_uom': 'Nos',
            },
          ],
        );

        await _pumpInventoryCountScreen(tester, service);
        await _selectWarehouse(tester, 'Consumables - J');
        await _startCount(tester);

        expect(find.byType(FilterChip), findsNothing);
        expect(find.text('0/2'), findsNothing);
        expect(find.text('2 of 2 items'), findsOneWidget);
      },
    );
  });
}
