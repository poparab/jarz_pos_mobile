// Backing out of Inventory Count is a normal thing to do — the screen opens a
// cold Hive box and then asks the server for the item list, and a user who
// changes their mind is gone long before either lands. When that happens the
// continuations run on a dead State: `setState` throws "called after
// dispose()", and `ref.read` throws "Cannot use ref after the widget was
// disposed". Neither sits inside a try, so both escape.
//
// This disposes the screen mid-await and asserts the flow ends quietly.
//
// Honest scope note: this test passes against the pre-fix code too, so it is a
// regression guard rather than a proof. `setState()` after dispose is a debug
// assert, and on this path it was thrown inside the existing try and swallowed
// by the catch. The throw that actually reached production — the release-mode
// `Cannot use ref after the widget was disposed` StateError, which sat outside
// that try — only happens when the State dies during `_openBox`'s cold
// `Hive.openBox`, and forcing that window deadlocks the widget-test
// fake-async zone. The guard for it is in `_openBox` and at the top of
// `_loadItems`; what this test locks in is that the whole flow stays quiet when
// the screen goes away mid-lookup, so a future change that moves work outside
// the try is caught here.
library;

import 'dart:async';
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

/// The item lookup hangs until the test releases it, which is the window a
/// user backing out of the screen actually lands in.
class _HangingInventoryCountService extends InventoryCountService {
  _HangingInventoryCountService() : super(Dio());

  final Completer<List<Map<String, dynamic>>> items =
      Completer<List<Map<String, dynamic>>>();

  @override
  Future<List<Map<String, dynamic>>> listWarehouses({String? company}) async {
    return [
      {'name': 'Main Warehouse', 'company': 'Jarz'},
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> listItemsForCount({
    required String warehouse,
    String? search,
    String? itemGroup,
    int? limit,
  }) => items.future;
}

Widget _host(InventoryCountService service, {required bool showScreen}) {
  return ProviderScope(
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
      home: showScreen
          ? const InventoryCountScreen()
          : const Scaffold(body: SizedBox.shrink()),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveTempDir;

  setUpAll(() async {
    hiveTempDir = await Directory.systemTemp.createTemp(
      'inventory-count-dispose-test',
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

  testWidgets(
    'leaving the screen while the item lookup is in flight does not throw',
    (tester) async {
      final service = _HangingInventoryCountService();

      await tester.pumpWidget(_host(service, showScreen: true));
      await tester.pumpAndSettle();

      // Pick a warehouse and start the count; the item lookup now hangs.
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Main Warehouse').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.play_arrow));
      // Not pumpAndSettle: `_loading` renders a progress indicator that never
      // stops animating while the lookup is outstanding.
      await tester.pump();

      // The user backs out.
      await tester.pumpWidget(_host(service, showScreen: false));
      await tester.pump();

      // The lookup lands on a State that no longer exists. Without the guard
      // this is `setState() called after dispose()`.
      service.items.complete(const [
        {
          'item_code': 'ITEM-001',
          'item_name': 'Blueberry Box',
          'current_qty': 10,
          'stock_uom': 'Box',
        },
      ]);
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );


}
