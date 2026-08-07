// Golden tests locking in three shipped UI fixes so they cannot silently
// regress:
//
//   1. Kanban invoice card — the amber "has notes" treatment must stay OPAQUE
//      (an earlier bug passed the accent at low alpha straight to Card.color,
//      turning the whole card ~94% transparent and dimming it). Rendered over a
//      colored column-like gradient so a regression to the translucent look
//      would bleed the background through and change the pixels. Also captures
//      the note border + note-count badge + card-face note preview strip.
//   2. Courier settlement popup — the collect (balance > 0) and pay
//      (balance < 0) rows must show the correct, non-inverted labels/colors.
//   3. InstaPay reconciliation screen — the AppBar must keep its back arrow
//      leading button alongside the drawer menu button.
//
// Run to GENERATE / refresh baselines (after an intentional UI change):
//   flutter test --update-goldens test/goldens/ui_fixes_golden_test.dart
//
// Run to VERIFY (CI / normal run — the "Golden Visual Tests" job runs
// `flutter test test/goldens/` on windows-latest, matching these baselines):
//   flutter test test/goldens/ui_fixes_golden_test.dart
//
// Baselines live under test/goldens/goldens/ and are committed to git. Every
// render uses a fixed 800×1280 viewport, fixed fixtures, the English locale and
// the bundled Inter font so the output is deterministic (no time / random /
// network). The heavy Kanban / POS StateNotifiers are replaced with inert fakes
// (see below) so a widget golden never spins up the real network/socket/timer
// backend graph.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';

// ── Feature under test: Kanban invoice card ─────────────────────────────────
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';
import 'package:jarz_pos/src/features/kanban/widgets/invoice_card_widget.dart';
import 'package:jarz_pos/src/features/kanban/providers/kanban_provider.dart';
import 'package:jarz_pos/src/core/websocket/websocket_service.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/manager/state/manager_providers.dart';

// ── Feature under test: Courier settlement popup ────────────────────────────
import 'package:jarz_pos/src/features/pos/presentation/widgets/courier_balances_dialog.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/courier_repository.dart';
import 'package:jarz_pos/src/core/network/courier_service.dart';
import 'package:jarz_pos/src/features/pos/data/models/courier_balance.dart';

// ── Feature under test: InstaPay reconciliation screen ──────────────────────
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';
import 'package:jarz_pos/src/features/instapay_reconciliation/presentation/instapay_reconciliation_screen.dart';
import 'package:jarz_pos/src/features/instapay_reconciliation/state/instapay_reconciliation_providers.dart';
import 'package:jarz_pos/src/features/instapay_reconciliation/data/models/unconfirmed_online_order.dart';

import '../helpers/mock_services.dart';
import '../helpers/test_helpers.dart';

// ── Fonts ───────────────────────────────────────────────────────────────────

/// Load the real bundled Inter TTFs so text renders as legible glyphs with
/// production metrics (Ahem placeholder boxes are both unreadable AND wider,
/// which overflows tight rows like the courier tile). Mirrors the font loader
/// in test/features/reports/report_screenshots_test.dart.
Future<void> _loadAppFonts() async {
  final loader = FontLoader('Inter');
  for (final path in const [
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Bold.ttf',
  ]) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(
      Future<ByteData>.value(ByteData.sublistView(Uint8List.fromList(bytes))),
    );
  }
  await loader.load();
}

ThemeData _theme() => ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    );

// ── Shared harness ──────────────────────────────────────────────────────────

/// Pump [child] inside a full localized [MaterialApp] pinned to a deterministic
/// 800×1280 viewport and the English locale. Mirrors `pumpGoldenWidget` in
/// screens_golden_test.dart, but settles defensively: any stray async load or
/// timer would otherwise hang an unbounded pumpAndSettle, so we bound it and
/// fall back to a fixed single advance — the final frame is static either way.
Future<void> pumpGoldenWidget(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(800, 1280);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('en'),
        theme: _theme(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );

  try {
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  } catch (_) {
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }
}

// ── Inert notifier fakes ─────────────────────────────────────────────────────
//
// The real KanbanNotifier / PosNotifier constructors open sockets, arm polling
// timers and hit the network via dio (which itself needs dotenv). A widget
// golden must not depend on any of that. These fakes `implement` the notifier
// type (so they satisfy the provider's type) while `extends StateNotifier`
// directly — bypassing the heavy real constructor — and expose only an empty
// initial state. The widgets under test read state at build time and only call
// notifier methods from tap handlers, which never fire in these goldens, so
// noSuchMethod is a safe catch-all.

class _FakeKanbanNotifier extends StateNotifier<KanbanState>
    implements KanbanNotifier {
  _FakeKanbanNotifier() : super(KanbanState());

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakePosNotifier extends StateNotifier<PosState> implements PosNotifier {
  _FakePosNotifier() : super(PosState());

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

/// Serves fixed balances so the courier popup renders from data (not network),
/// with no loading spinner or timers.
class _FakeCourierRepository extends CourierRepository {
  _FakeCourierRepository(this._balances)
      : super(CourierService(createMockDio()));

  final List<CourierBalance> _balances;

  @override
  Future<List<CourierBalance>> getBalances() async => _balances;
}

// ── Fixtures ────────────────────────────────────────────────────────────────

/// A single, fixed Kanban invoice card. [withNotes] toggles only the note
/// signal so the two goldens differ purely by the amber note treatment.
InvoiceCard _invoiceFixture({required bool withNotes}) => InvoiceCard(
      id: 'ACC-SINV-2026-00042',
      invoiceIdShort: '42',
      customerName: 'Sarah Johnson',
      customer: 'CUST-0042',
      territory: 'Maadi',
      status: 'Received',
      postingDate: '2026-07-19',
      // Fixed preformatted slot label so the date cell never falls back to a
      // DateTime.now()-relative "Today/Yesterday" string (keeps it deterministic).
      deliverySlotLabel: 'Jul 19 - 5:00 PM',
      grandTotal: 450,
      netTotal: 400,
      totalTaxesAndCharges: 0,
      fullAddress: '12 Nile St, Maadi, Cairo',
      items: [
        InvoiceItem(
          itemCode: 'CAKE-01',
          itemName: 'Chocolate Cake',
          qty: 2,
          rate: 200,
          amount: 400,
        ),
      ],
      shippingIncome: 50,
      shippingExpense: 30,
      customerPhone: '+20 100 123 4567',
      paymentMethod: 'Cash',
      // Not pending acceptance → no green "Accept" button and, crucially, no
      // green "accepted" border that would otherwise outrank the amber note
      // border we want to lock in.
      requiresAcceptanceFlag: false,
      outstandingAmount: 450, // fully unpaid
      noteCount: withNotes ? 2 : 0,
      latestNote: withNotes
          ? 'Customer asked to deliver after 5 PM and to call on arrival.'
          : null,
    );

const String _kNotePreviewText =
    'Customer asked to deliver after 5 PM and to call on arrival.';

/// Two representative courier balances: one to COLLECT (balance > 0) and one to
/// PAY (balance < 0), so both label/colour branches are captured.
List<CourierBalance> _courierBalancesFixture() => [
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
      CourierBalance(
        courier: 'EMP-COURIER-002',
        courierName: 'Mona Ali',
        balance: -80.00,
        partyType: 'Supplier',
        party: 'SUP-002',
        details: [
          CourierBalanceDetail(
            invoice: 'ACC-SINV-2026-00102',
            city: 'Zamalek',
            amount: 0,
            shipping: 80,
          ),
        ],
      ),
    ];

/// A colored, column-like gradient behind the card. The whole point of the
/// notes golden is that the fixed wash stays opaque over a NON-white surface —
/// so the background must not be plain white or the translucency regression
/// would be invisible.
Widget _cardScene(Key key, {required bool withNotes}) {
  // A ListView gives the card unbounded vertical space (exactly like the real
  // Kanban column) so its `mainAxisSize.max` Column collapses to its natural
  // height instead of stretching to fill the viewport.
  return Scaffold(
    body: ListView(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: RepaintBoundary(
            key: key,
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFB0BEC5), Color(0xFF607D8B)],
                ),
              ),
              child: InvoiceCardWidget(
                invoice: _invoiceFixture(withNotes: withNotes),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

List<Override> _cardOverrides() => [
      kanbanProvider.overrideWith((ref) => _FakeKanbanNotifier()),
      isLineManagerProvider.overrideWithValue(false),
      canActAsLineManagerProvider.overrideWithValue(false),
      managerAccessProvider.overrideWith((ref) => false),
    ];

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  setUpAll(() async {
    await _loadAppFonts();
  });

  // ── 1. Kanban invoice card ─────────────────────────────────────────────

  testWidgets('golden: invoice card WITH notes — opaque amber wash + border + '
      'badge + preview strip', (tester) async {
    const key = ValueKey('invoice_card_with_notes');
    await pumpGoldenWidget(
      tester,
      _cardScene(key, withNotes: true),
      overrides: _cardOverrides(),
    );

    // The note affordances must actually be on the card face.
    expect(find.text(_kNotePreviewText), findsOneWidget); // body preview strip
    expect(find.text('2'), findsOneWidget); // note-count badge
    expect(find.byIcon(Icons.comment_outlined), findsWidgets); // note glyph
    // The strip now uses a uniform border, so the note-preview strip paints its
    // inner content cleanly — no non-uniform-border + borderRadius assert to
    // tolerate anymore.
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byKey(key),
      matchesGoldenFile('goldens/kanban_invoice_card_with_notes.png'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'golden: invoice card WITHOUT notes — baseline, no wash/badge/strip',
      (tester) async {
    const key = ValueKey('invoice_card_without_notes');
    await pumpGoldenWidget(
      tester,
      _cardScene(key, withNotes: false),
      overrides: _cardOverrides(),
    );

    // No note treatment when the invoice carries no notes.
    expect(find.text(_kNotePreviewText), findsNothing);
    expect(find.text('2'), findsNothing);
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byKey(key),
      matchesGoldenFile('goldens/kanban_invoice_card_without_notes.png'),
    );
  });

  // ── 2. Courier settlement popup ────────────────────────────────────────

  testWidgets('golden: courier balances popup — collect vs pay labels',
      (tester) async {
    await pumpGoldenWidget(
      tester,
      const Scaffold(body: CourierBalancesDialog()),
      overrides: [
        courierRepositoryProvider.overrideWithValue(
          _FakeCourierRepository(_courierBalancesFixture()),
        ),
        webSocketServiceProvider.overrideWithValue(MockWebSocketService()),
      ],
    );

    // Non-inverted labels: positive balance collects, negative pays.
    expect(find.text('Collect From Courier'), findsOneWidget);
    expect(find.text('Pay Courier'), findsOneWidget);
    expect(find.text('125.00'), findsOneWidget);
    expect(find.text('-80.00'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byType(CourierBalancesDialog),
      matchesGoldenFile('goldens/courier_balances_collect_pay.png'),
    );
  });

  // ── 3. InstaPay reconciliation screen AppBar ───────────────────────────

  testWidgets('golden: InstaPay reconciliation AppBar — back arrow + menu',
      (tester) async {
    await pumpGoldenWidget(
      tester,
      const InstapayReconciliationScreen(),
      overrides: [
        posNotifierProvider.overrideWith((ref) => _FakePosNotifier()),
        // No network: an empty awaiting-orders list renders the data state so
        // the AppBar (the fix) is captured without a spinner.
        unconfirmedOnlineOrdersProvider
            .overrideWith((ref, arg) => <UnconfirmedOnlineOrder>[]),
      ],
    );

    // The back-button fix: leading back arrow AND the drawer menu button.
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.text('InstaPay Reconciliation'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byType(AppBar),
      matchesGoldenFile('goldens/instapay_reconciliation_appbar.png'),
    );
  });
}
