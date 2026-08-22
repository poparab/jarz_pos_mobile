// Documentation screenshots — NOT run by CI (no workflow job globs
// test/screenshots).
//
// Renders the screens the staff / line-manager guide describes and writes the
// PNGs straight into `web/docs/assets/img/<lang>/`, in both English and
// Arabic. Regenerate with:
//
//   flutter test test/screenshots/docs_screenshots_test.dart --update-goldens
//
// Then rebuild the guide (`python scripts/build_staff_docs.py`) and commit the
// images with it.
//
// Why goldens rather than real screenshots of a running app: this needs no
// server, no login, no POS profile and — decisively — no real customer data.
// Staging is a clone of production, so a screenshot taken there would publish
// real names, phones and addresses on a public docs page. Every value below is
// invented.
//
// Determinism: fixed viewport, fixed fixtures, bundled fonts, no clock and no
// network. The same bytes come out on any machine.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/localization/locale_notifier.dart';
import 'package:jarz_pos/src/core/network/courier_service.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/core/router.dart';
import 'package:jarz_pos/src/core/websocket/websocket_service.dart';
import 'package:jarz_pos/src/core/widgets/app_drawer.dart';
import 'package:jarz_pos/src/features/auth/data/auth_repository.dart';
import 'package:jarz_pos/src/features/auth/presentation/login_screen.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';
import 'package:jarz_pos/src/features/kanban/providers/kanban_provider.dart';
import 'package:jarz_pos/src/features/kanban/widgets/invoice_card_widget.dart';
import 'package:jarz_pos/src/features/manager/state/manager_providers.dart';
import 'package:jarz_pos/src/features/pos/data/models/courier_balance.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/courier_repository.dart';
import 'package:jarz_pos/src/features/pos/presentation/widgets/courier_balances_dialog.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';
import 'package:jarz_pos/src/features/shift/state/shift_notifier.dart';

import '../helpers/mock_services.dart';
import '../helpers/test_helpers.dart';

/// Where the guide expects to find them, relative to this test file.
const _outDir = '../../web/docs/assets/img';

const _phone = Size(390, 844);

/// Lets a shot open the drawer it is about to photograph.
final _scaffoldKey = GlobalKey<ScaffoldState>();

// ── Fonts ───────────────────────────────────────────────────────────────────

/// Derived from FLUTTER_ROOT (set by `flutter test`) so this renders the same
/// on any machine.
final _sdkFonts = () {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null || root.isEmpty) return '';
  final s = Platform.pathSeparator;
  return '$root${s}bin${s}cache${s}artifacts${s}material_fonts';
}();

Future<void> _load(String family, List<String> paths) async {
  final present = paths.where((p) => p.isNotEmpty && File(p).existsSync());
  if (present.isEmpty) return;
  final loader = FontLoader(family);
  for (final path in present) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(
      Future<ByteData>.value(ByteData.sublistView(Uint8List.fromList(bytes))),
    );
  }
  await loader.load();
}

/// `flutter test` ships no fonts, so text renders as filled boxes without this.
/// Tajawal matters most: the app sets no Arabic family and relies on the
/// device's system fallback, which does not exist under the test binding — so
/// every Arabic screenshot would otherwise be a wall of tofu.
Future<void> _loadFonts() async {
  String sdk(String n) =>
      _sdkFonts.isEmpty ? '' : '$_sdkFonts${Platform.pathSeparator}$n';
  await _load('Roboto', [
    sdk('Roboto-Regular.ttf'),
    sdk('roboto-regular.ttf'),
    sdk('Roboto-Medium.ttf'),
    sdk('roboto-medium.ttf'),
    sdk('Roboto-Bold.ttf'),
    sdk('roboto-bold.ttf'),
  ]);
  await _load('MaterialIcons', [
    sdk('MaterialIcons-Regular.otf'),
    sdk('materialicons-regular.otf'),
  ]);
  await _load('Inter', [
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Bold.ttf',
  ]);
  await _load('Tajawal', [
    'assets/fonts/Tajawal-Regular.ttf',
    'assets/fonts/Tajawal-Bold.ttf',
  ]);
}

/// Inter for Latin with Tajawal behind it, which is how the app resolves
/// Arabic on a real device (there via the system font, here via the bundled
/// one). Without the fallback the Arabic pages render as boxes.
ThemeData _theme() => ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      fontFamilyFallback: const ['Tajawal', 'Roboto'],
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 1),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );

// ── Harness ─────────────────────────────────────────────────────────────────

/// Render [child] and write `web/docs/assets/img/<lang>/<name>.png`.
Future<void> _shoot(
  WidgetTester tester,
  String lang,
  String name,
  Widget child, {
  Size size = _phone,
  List<Override> overrides = const [],
  Finder? clip,
  bool openDrawer = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Locale(lang),
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
  // Bounded: a stray timer or async load would hang an unbounded settle, and
  // the final frame is static either way.
  try {
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  } catch (_) {
    await tester.pump(const Duration(milliseconds: 300));
  }

  // A Scaffold does not build its drawer until it is opened, so the finder
  // would come back empty on a closed one.
  if (openDrawer) {
    _scaffoldKey.currentState!.openDrawer();
    await tester.pumpAndSettle();
  }

  await expectLater(
    clip ?? find.byType(MaterialApp),
    matchesGoldenFile('$_outDir/$lang/$name.png'),
  );
}

// ── Inert fakes ─────────────────────────────────────────────────────────────
//
// The real notifiers open sockets, arm timers and hit dio. A screenshot must
// not depend on any of that; the widgets read state at build time and only call
// notifier methods from tap handlers, which never fire here.

class _FakeKanban extends StateNotifier<KanbanState> implements KanbanNotifier {
  _FakeKanban() : super(KanbanState());
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakePos extends StateNotifier<PosState> implements PosNotifier {
  _FakePos() : super(PosState());
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeCourierRepo extends CourierRepository {
  _FakeCourierRepo(this._balances) : super(CourierService(createMockDio()));
  final List<CourierBalance> _balances;
  @override
  Future<List<CourierBalance>> getBalances() async => _balances;
}

/// The real one reads the saved locale out of a Hive box that no test binding
/// opens. The screenshot's language comes from MaterialApp.locale anyway.
class _FakeLocale extends StateNotifier<Locale?> implements LocaleNotifier {
  _FakeLocale() : super(null);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _IdleAuth extends AuthRepository {
  _IdleAuth() : super(createMockDio(), MockSessionManager());
  @override
  Future<bool> login(String username, String password) async => false;
  @override
  Future<void> logout() async {}
}

// ── Fixtures (invented; never real customer data) ───────────────────────────

/// The note is the thing this shot exists to show, so it is written in the
/// reader's language — a real note carries whatever the staff typed.
InvoiceCard _orderFixture(String lang) => InvoiceCard(
      id: 'ACC-SINV-2026-00042',
      invoiceIdShort: '42',
      customerName: 'Nour Adel',
      customer: 'CUST-0042',
      territory: 'Maadi',
      status: 'Received',
      postingDate: '2026-08-22',
      // Preformatted so the cell never falls back to a clock-relative label.
      deliverySlotLabel: 'Aug 22 - 5:00 PM',
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
      customerPhone: '+20 100 000 0000',
      paymentMethod: 'Cash',
      requiresAcceptanceFlag: false,
      outstandingAmount: 450,
      noteCount: 2,
      latestNote: lang == 'ar'
          ? 'العميل طلب التوصيل بعد ٥ العصر ويتصل بيه أول ما يوصل.'
          : 'Customer asked to deliver after 5 PM and to call on arrival.',
    );

List<CourierBalance> _balancesFixture() => [
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

/// The drawer as a plain staff member sees it: no manager groups, no B2B, no
/// production board. This is the menu the guide's "open the menu" steps mean.
List<Override> _staffDrawerOverrides({required bool lineManager}) => [
      isLineManagerProvider.overrideWithValue(lineManager),
      canActAsLineManagerProvider.overrideWithValue(lineManager),
      canAccessManagerDashboardRoleProvider.overrideWithValue(lineManager),
      canAccessShiftMonitorProvider.overrideWithValue(lineManager),
      isModeratorProvider.overrideWithValue(false),
      canAccessB2bProvider.overrideWithValue(false),
      canAccessProductionBoardProvider.overrideWithValue(false),
      requirePosShiftProvider.overrideWithValue(true),
      managerAccessProvider.overrideWith((ref) => lineManager),
      activeShiftProvider.overrideWith((ref) async => null),
      posNotifierProvider.overrideWith((ref) => _FakePos()),
      kanbanProvider.overrideWith((ref) => _FakeKanban()),
      webSocketServiceProvider.overrideWithValue(MockWebSocketService()),
      localeNotifierProvider.overrideWith((ref) => _FakeLocale()),
    ];

// ── Shots ───────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  setUpAll(_loadFonts);

  for (final lang in const ['en', 'ar']) {
    group('[$lang]', () {
      testWidgets('login screen', (tester) async {
        await _shoot(
          tester,
          lang,
          'login',
          const LoginScreen(),
          size: const Size(390, 560),
          overrides: [
            authRepositoryProvider.overrideWith((ref) => _IdleAuth()),
            currentAuthStateProvider.overrideWith((ref) => false),
          ],
        );
      });

      testWidgets('menu — staff', (tester) async {
        await _shoot(
          tester,
          lang,
          'menu-staff',
          Scaffold(
            key: _scaffoldKey,
            body: const SizedBox.expand(),
            drawer: const AppDrawer(),
          ),
          overrides: _staffDrawerOverrides(lineManager: false),
          clip: find.byType(AppDrawer),
          openDrawer: true,
        );
      });

      testWidgets('menu — line manager', (tester) async {
        await _shoot(
          tester,
          lang,
          'menu-line-manager',
          Scaffold(
            key: _scaffoldKey,
            body: const SizedBox.expand(),
            drawer: const AppDrawer(),
          ),
          overrides: _staffDrawerOverrides(lineManager: true),
          clip: find.byType(AppDrawer),
          openDrawer: true,
        );
      });

      testWidgets('order card', (tester) async {
        await _shoot(
          tester,
          lang,
          'order-card',
          Scaffold(
            backgroundColor: const Color(0xFFECEFF1),
            body: ListView(
              padding: const EdgeInsets.all(12),
              children: [InvoiceCardWidget(invoice: _orderFixture(lang))],
            ),
          ),
          overrides: [
            kanbanProvider.overrideWith((ref) => _FakeKanban()),
            isLineManagerProvider.overrideWithValue(false),
            canActAsLineManagerProvider.overrideWithValue(false),
            managerAccessProvider.overrideWith((ref) => false),
          ],
          clip: find.byType(InvoiceCardWidget),
        );
      });

      testWidgets('courier balances', (tester) async {
        await _shoot(
          tester,
          lang,
          'courier-balances',
          const Scaffold(body: CourierBalancesDialog()),
          size: const Size(390, 430),
          overrides: [
            courierRepositoryProvider
                .overrideWithValue(_FakeCourierRepo(_balancesFixture())),
            webSocketServiceProvider.overrideWithValue(MockWebSocketService()),
          ],
        );
      });
    });
  }
}
