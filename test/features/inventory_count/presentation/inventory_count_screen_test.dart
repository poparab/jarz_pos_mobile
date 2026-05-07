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
  _FakeInventoryCountService({
    required this.warehouses,
    required this.items,
  }) : super(Dio());

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

Future<void> _pumpInventoryCountScreen(
  WidgetTester tester,
  _FakeInventoryCountService service,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        inventoryCountServiceProvider.overrideWithValue(service),
        managerAccessProvider.overrideWith((ref) async => true),
        isJarzManagerProvider.overrideWith((ref) => false),
        isLineManagerProvider.overrideWith((ref) => false),
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
        home: const InventoryCountScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> _selectWarehouse(
  WidgetTester tester,
  String warehouseName,
) async {
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

Future<void> _openReview(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.visibility_outlined));
  await tester.pumpAndSettle();
}

ButtonStyleButton _buttonForIcon(
  WidgetTester tester,
  IconData icon,
) {
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
    if (Hive.isBoxOpen(HiveBoxes.inventoryCount)) {
      await Hive.box(HiveBoxes.inventoryCount).clear();
    }
    if (Hive.isBoxOpen(HiveBoxes.appSettings)) {
      await Hive.box(HiveBoxes.appSettings).clear();
    }
  });

  tearDownAll(() async {
    if (Hive.isBoxOpen(HiveBoxes.inventoryCount)) {
      await Hive.box(HiveBoxes.inventoryCount).close();
    }
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

        await _enterItemCount(
          tester,
          itemCode: 'ITEM-001',
          quantity: '9',
        );

        expect(find.text('Counted 1 / 2'), findsOneWidget);

        await _openReview(tester);

        expect(find.text('Back to counting'), findsOneWidget);
        expect(
          find.text('Count every loaded item before submitting (1 remaining)'),
          findsOneWidget,
        );

        final submitButton = _buttonForIcon(tester, Icons.save_outlined);
        expect(submitButton.onPressed, isNull);
        expect(service.submitCalled, isFalse);
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
        await _enterItemCount(
          tester,
          itemCode: 'ITEM-001',
          quantity: '9',
        );
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
        await _enterItemCount(
          tester,
          itemCode: 'ITEM-001',
          quantity: '9',
        );
        await _enterItemCount(
          tester,
          itemCode: 'ITEM-002',
          quantity: '4',
        );
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
        expect(find.text('Counted 0 / 2'), findsOneWidget);
        expect(find.text('Back to counting'), findsNothing);

        await _startCount(tester);

        expect(service.requestedWarehouses, hasLength(2));
        expect(find.text('Counted 0 / 2'), findsOneWidget);
        expect(find.text('Back to setup'), findsOneWidget);
        expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
        expect(find.text('Counted'), findsNothing);
      },
    );
  });
}






