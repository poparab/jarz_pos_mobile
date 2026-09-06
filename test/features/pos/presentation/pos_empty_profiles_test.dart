import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/app_routes.dart';
import 'package:jarz_pos/src/core/connectivity/connectivity_service.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/core/offline/offline_queue.dart';
import 'package:jarz_pos/src/core/sync/offline_sync_service.dart';
import 'package:jarz_pos/src/core/websocket/websocket_service.dart';
import 'package:jarz_pos/src/features/pos/data/models/draft_cart.dart';
import 'package:jarz_pos/src/features/pos/data/models/courier_balance.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/draft_cart_repository.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/courier_repository.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import 'package:jarz_pos/src/features/pos/presentation/screens/pos_screen.dart';
import 'package:jarz_pos/src/features/pos/state/courier_balances_provider.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';
import 'package:jarz_pos/src/core/network/courier_service.dart';
import 'package:jarz_pos/src/features/printing/pos_printer_provider.dart';
import 'package:jarz_pos/src/features/printing/pos_printer_service.dart';
import 'package:jarz_pos/src/features/shift/state/shift_notifier.dart';

import '../../../helpers/test_helpers.dart';

class _EmptyPosRepository extends PosRepository {
  _EmptyPosRepository() : super(Dio());
}

class _EmptyCourierRepository extends CourierRepository {
  _EmptyCourierRepository() : super(CourierService(Dio()));

  @override
  Future<List<CourierBalance>> getBalances({String? posProfile}) async =>
      const [];
}

class _EmptyDraftCartRepository extends DraftCartRepository {
  @override
  Future<List<DraftCart>> loadAll() async => const [];

  @override
  Future<void> upsert(DraftCart draft) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> clearAll() async {}
}

class _RecordingPosNotifier extends PosNotifier {
  _RecordingPosNotifier({PosState? initialState})
    : super(_EmptyPosRepository(), _EmptyDraftCartRepository()) {
    state = initialState ?? PosState();
  }

  int loadProfilesCalls = 0;
  int refreshCatalogCalls = 0;
  int startB2bOrderCalls = 0;
  int policyCalls = 0;
  int retryContextCalls = 0;
  bool bindingShouldSucceed = false;

  @override
  Future<void> loadProfiles({bool deferSingleProfileCatalog = false}) async {
    loadProfilesCalls++;
  }

  @override
  Future<void> refreshCatalog({bool showLoading = false}) async {
    refreshCatalogCalls++;
  }

  @override
  Future<bool> startB2bOrder(Map<String, dynamic> customer) async {
    startB2bOrderCalls++;
    state = state.copyWith(
      isB2bOrder: true,
      b2bSetupComplete: false,
      selectedCustomer: customer,
    );
    return true;
  }

  @override
  Future<bool> setCommercialPolicyByOrderPurpose(String orderPurpose) async {
    policyCalls++;
    if (bindingShouldSucceed) {
      state = state.copyWith(boundB2bOrderPurpose: orderPurpose);
    }
    return bindingShouldSucceed;
  }

  @override
  Future<bool> retryB2bPricingContext() async {
    retryContextCalls++;
    if (bindingShouldSucceed) {
      state = state.copyWith(b2bSetupComplete: true);
    }
    return bindingShouldSucceed;
  }

  @override
  void markB2bSetupComplete() {
    state = state.copyWith(isB2bOrder: true, b2bSetupComplete: true);
  }

  void triggerUnrelatedRebuild() {
    state = state.copyWith(isPickup: !state.isPickup);
  }
}

Future<(_RecordingPosNotifier, GoRouter)> _pumpEmptyProfiles(
  WidgetTester tester, {
  required bool b2b,
}) async {
  final notifier = _RecordingPosNotifier();
  final webSocketService = WebSocketService();
  final offlineSyncService = OfflineSyncService(OfflineQueue(), Dio());
  final printerService = PosPrinterService(autoInit: false);
  addTearDown(webSocketService.dispose);
  addTearDown(offlineSyncService.dispose);
  final router = GoRouter(
    initialLocation: b2b ? '${AppRoutes.pos}?mode=b2b_order' : AppRoutes.pos,
    routes: [
      GoRoute(
        path: AppRoutes.pos,
        builder: (_, _) =>
            PosScreen(launchData: b2b ? const {'mode': 'b2b_order'} : null),
      ),
      GoRoute(
        path: AppRoutes.b2b,
        builder: (_, _) => const Scaffold(body: Text('B2B destination')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        posNotifierProvider.overrideWith((_) => notifier),
        userRolesFutureProvider.overrideWith(
          (_) async => const UserRoles(user: 'b2b-test', roles: []),
        ),
        requirePosShiftProvider.overrideWith((_) => false),
        activeShiftProvider.overrideWith((_) async => null),
        webSocketServiceProvider.overrideWithValue(webSocketService),
        offlineSyncServiceProvider.overrideWithValue(offlineSyncService),
        connectivityStatusProvider.overrideWith((_) => Stream.value(true)),
        courierBalancesProvider.overrideWith(
          (_) => CourierBalancesNotifier(_EmptyCourierRepository()),
        ),
        posPrinterServiceProvider.overrideWith((_) => printerService),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (notifier, router);
}

Future<_RecordingPosNotifier> _pumpB2bBinding(
  WidgetTester tester, {
  bool bindingShouldSucceed = false,
  bool includeLaunchCustomer = true,
  Map<String, dynamic>? launchSelectedCustomer,
  PosState? initialState,
}) async {
  final notifier = _RecordingPosNotifier(
    initialState:
        initialState ??
        PosState(
          profiles: const [
            {'name': 'Nasr city'},
          ],
          selectedProfile: const {'name': 'Nasr city'},
        ),
  )..bindingShouldSucceed = bindingShouldSucceed;
  final webSocketService = WebSocketService();
  final offlineSyncService = OfflineSyncService(OfflineQueue(), Dio());
  final printerService = PosPrinterService(autoInit: false);
  addTearDown(webSocketService.dispose);
  addTearDown(offlineSyncService.dispose);
  final router = GoRouter(
    initialLocation: '${AppRoutes.pos}?mode=b2b_order',
    routes: [
      GoRoute(
        path: AppRoutes.pos,
        builder: (_, _) => PosScreen(
          launchData: includeLaunchCustomer
              ? {
                  'mode': 'b2b_order',
                  'customer': 'B2B-CUSTOMER',
                  'order_purpose': 'B2B Supply',
                  'selected_customer':
                      launchSelectedCustomer ??
                      const {
                        'name': 'B2B-CUSTOMER',
                        'customer_name': 'B2B Customer',
                      },
                }
              : const {'mode': 'b2b_order'},
        ),
      ),
      GoRoute(
        path: AppRoutes.b2b,
        builder: (_, _) => const Scaffold(body: Text('B2B destination')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        posNotifierProvider.overrideWith((_) => notifier),
        userRolesFutureProvider.overrideWith(
          (_) async => const UserRoles(user: 'b2b-test', roles: []),
        ),
        requirePosShiftProvider.overrideWith((_) => false),
        activeShiftProvider.overrideWith((_) async => null),
        webSocketServiceProvider.overrideWithValue(webSocketService),
        offlineSyncServiceProvider.overrideWithValue(offlineSyncService),
        connectivityStatusProvider.overrideWith((_) => Stream.value(true)),
        courierBalancesProvider.overrideWith(
          (_) => CourierBalancesNotifier(_EmptyCourierRepository()),
        ),
        posPrinterServiceProvider.overrideWith((_) => printerService),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return notifier;
}

void main() {
  setUpAll(() async {
    await setUpTestHive(prefix: 'pos-empty-profiles-test');
    await dotenv.load(
      fileName: 'test/.env.not-present',
      isOptional: true,
      mergeWith: const {'ERP_BASE_URL': 'http://localhost'},
    );
  });
  tearDownAll(tearDownTestHive);

  group('POS empty profile state', () {
    testWidgets('shows retry instead of an endless spinner', (tester) async {
      final (notifier, _) = await _pumpEmptyProfiles(tester, b2b: false);

      expect(find.text('No POS Profiles Available'), findsOneWidget);
      expect(
        find.text('Contact your administrator to assign you to a POS profile'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Choose B2B account'), findsNothing);
      expect(notifier.loadProfilesCalls, 1);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(notifier.loadProfilesCalls, 2);
    });

    testWidgets('lets a B2B order return to account selection', (tester) async {
      await _pumpEmptyProfiles(tester, b2b: true);

      expect(find.text('No POS Profiles Available'), findsOneWidget);
      expect(find.text('Choose B2B account'), findsOneWidget);

      await tester.tap(find.text('Choose B2B account'));
      await tester.pumpAndSettle();

      expect(find.text('B2B destination'), findsOneWidget);
    });

    testWidgets('failed B2B binding waits for an explicit retry', (
      tester,
    ) async {
      final notifier = await _pumpB2bBinding(tester);

      expect(notifier.startB2bOrderCalls, 1);
      expect(notifier.policyCalls, 1);
      expect(find.text('Couldn’t prepare the B2B order'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);

      notifier.triggerUnrelatedRebuild();
      await tester.pumpAndSettle();

      expect(notifier.startB2bOrderCalls, 1);
      expect(notifier.policyCalls, 1);

      notifier.bindingShouldSucceed = true;
      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pump();
      await tester.pump();

      expect(notifier.startB2bOrderCalls, 1);
      expect(notifier.policyCalls, 2);
      expect(notifier.state.b2bSetupComplete, isTrue);
    });

    testWidgets(
      'retry after a successful launch uses the current B2B context',
      (tester) async {
        final notifier = await _pumpB2bBinding(
          tester,
          bindingShouldSucceed: true,
        );
        expect(notifier.state.b2bSetupComplete, isTrue);
        expect(notifier.startB2bOrderCalls, 1);
        expect(notifier.policyCalls, 1);

        notifier.state = notifier.state.copyWith(b2bSetupComplete: false);
        await tester.pumpAndSettle();
        expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);

        await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
        await tester.pumpAndSettle();

        expect(notifier.retryContextCalls, 1);
        expect(notifier.startB2bOrderCalls, 1);
        expect(notifier.policyCalls, 1);
        expect(notifier.state.b2bSetupComplete, isTrue);
      },
    );

    testWidgets('hash-restored draft retries without launch customer data', (
      tester,
    ) async {
      final notifier = await _pumpB2bBinding(
        tester,
        bindingShouldSucceed: true,
        includeLaunchCustomer: false,
        initialState: PosState(
          profiles: const [
            {'name': 'Nasr city'},
          ],
          selectedProfile: const {'name': 'Nasr city'},
          selectedCustomer: const {
            'name': 'B2B-CUSTOMER',
            'selected_shipping_address_territory_pos_profile': 'Nasr city',
          },
          isB2bOrder: true,
          b2bSetupComplete: false,
          boundB2bOrderPurpose: 'B2B Supply',
        ),
      );

      expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(notifier.retryContextCalls, 1);
      expect(notifier.startB2bOrderCalls, 0);
      expect(notifier.policyCalls, 0);
      expect(notifier.state.b2bSetupComplete, isTrue);
    });

    testWidgets(
      'pending same-customer launch replaces a different delivery branch',
      (tester) async {
        final notifier = await _pumpB2bBinding(
          tester,
          launchSelectedCustomer: const {
            'name': 'B2B-CUSTOMER',
            'customer_name': 'B2B Customer',
            'selected_shipping_address_name': 'DOKKI-ADDRESS',
            'selected_shipping_address_territory_pos_profile': 'Dokki',
          },
          initialState: PosState(
            profiles: const [
              {'name': 'Nasr city'},
              {'name': 'Dokki'},
            ],
            selectedProfile: const {'name': 'Nasr city'},
            selectedCustomer: const {
              'name': 'B2B-CUSTOMER',
              'selected_shipping_address_name': 'NASR-ADDRESS',
              'selected_shipping_address_territory_pos_profile': 'Nasr city',
            },
            isB2bOrder: true,
            b2bSetupComplete: false,
            boundB2bOrderPurpose: 'B2B Supply',
          ),
        );

        expect(notifier.startB2bOrderCalls, 1);
        expect(
          notifier.state.selectedCustomer?['selected_shipping_address_name'],
          'DOKKI-ADDRESS',
        );
        expect(notifier.policyCalls, 1);
      },
    );
  });
}
