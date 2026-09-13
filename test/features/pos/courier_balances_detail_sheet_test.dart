// Regression test for Sentry JARZ-FLUTTER-CLIENT-J: tapping a per-invoice
// "Settle" in the courier details sheet crashed with "Null check operator used on
// a null value" after the balances list had reloaded underneath the sheet.
//
// The sheet is its own route and outlives the courier tile that opened it. The
// dialog body swaps its list for a spinner on every reload, disposing that tile;
// the handler then called ScaffoldMessenger.of(<the tile's dead context>).
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/courier_service.dart';
import 'package:jarz_pos/src/core/websocket/websocket_service.dart';
import 'package:jarz_pos/src/features/pos/data/models/courier_balance.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/courier_repository.dart';
import 'package:jarz_pos/src/features/pos/presentation/widgets/courier_balances_dialog.dart';
import 'package:jarz_pos/src/features/pos/state/courier_balances_provider.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';

import '../../helpers/mock_services.dart';

class _FakePosNotifier extends StateNotifier<PosState> implements PosNotifier {
  _FakePosNotifier() : super(PosState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// First call answers at once; every later call hangs until [release], which
/// holds the dialog in its loading state (list replaced by a spinner).
class _ReloadingCourierRepository extends CourierRepository {
  _ReloadingCourierRepository(this._balances) : super(CourierService(createMockDio()));

  final List<CourierBalance> _balances;
  final Completer<void> _hold = Completer<void>();
  int calls = 0;

  void release() {
    if (!_hold.isCompleted) _hold.complete();
  }

  @override
  Future<List<CourierBalance>> getBalances({String? posProfile}) async {
    calls++;
    if (calls > 1) await _hold.future;
    return _balances;
  }
}

List<CourierBalance> _fixture() => [
      CourierBalance(
        courier: 'EMP-COURIER-001',
        courierName: 'Ahmed Hassan',
        balance: 125.00,
        partyType: 'Supplier',
        party: 'SUP-001',
        details: [
          CourierBalanceDetail(
            invoice: 'ACC-SINV-2026-00101',
            city: 'Maadi',
            amount: 150,
            shipping: 25,
          ),
        ],
      ),
    ];

/// The bundled Inter font, as the golden suite loads it: the test font's wider
/// placeholder glyphs overflow the courier tile's fixed-width trailing row.
Future<void> _loadAppFonts() async {
  final loader = FontLoader('Inter');
  for (final path in const ['assets/fonts/Inter-Regular.ttf', 'assets/fonts/Inter-Bold.ttf']) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future<ByteData>.value(ByteData.sublistView(Uint8List.fromList(bytes))));
  }
  await loader.load();
}

void main() {
  setUpAll(_loadAppFonts);

  testWidgets('per-invoice Settle survives a balances reload under the open sheet', (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _ReloadingCourierRepository(_fixture());
    addTearDown(repo.release);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courierRepositoryProvider.overrideWithValue(repo),
          posNotifierProvider.overrideWith((ref) => _FakePosNotifier()),
          webSocketServiceProvider.overrideWithValue(MockWebSocketService()),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          theme: ThemeData(useMaterial3: true, fontFamily: 'Inter'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: CourierBalancesDialog()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Ahmed Hassan'), findsOneWidget);

    // Open the details sheet from the courier tile.
    await tester.tap(find.text('Ahmed Hassan'));
    await tester.pumpAndSettle();
    expect(find.text('Details – Ahmed Hassan'), findsOneWidget);

    // A reload starts (as after a settlement or a websocket refresh): the dialog
    // body shows its spinner and the tile that opened the sheet is disposed.
    final container = ProviderScope.containerOf(tester.element(find.byType(CourierBalancesDialog)));
    unawaited(container.read(courierBalancesProvider.notifier).load());
    await tester.pump();
    expect(container.read(courierBalancesProvider).loading, isTrue);
    expect(find.text('Ahmed Hassan'), findsNothing);

    // The sheet is still open; its Settle must still work. With no POS profile
    // selected the handler's first step is a snackbar - reaching it at all is
    // what used to crash.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Settle'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Choose a POS profile:'), findsOneWidget);

    repo.release();
    await tester.pumpAndSettle();
  });
}
