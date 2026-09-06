import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/localization/locale_notifier.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/manager/state/manager_providers.dart';
import 'package:jarz_pos/src/features/shift/state/shift_notifier.dart';
import 'package:jarz_pos/src/features/woo_sync/data/models/woo_sync_dashboard.dart';
import 'package:jarz_pos/src/features/woo_sync/data/models/woo_sync_event.dart';
import 'package:jarz_pos/src/features/woo_sync/data/repositories/woo_sync_repository.dart';
import 'package:jarz_pos/src/features/woo_sync/presentation/screens/woo_sync_screen.dart';

/// A repository double the console provider can call without a live Dio.
class _FakeWooSyncRepository extends WooSyncRepository {
  _FakeWooSyncRepository({required this.dashboard, required this.events}) : super(Dio());

  final WooSyncDashboard dashboard;
  final List<WooSyncEvent> events;

  @override
  Future<WooSyncDashboard> getDashboard({int windowHours = 24, int limit = 20}) async => dashboard;

  @override
  Future<List<WooSyncEvent>> getEvents({
    String? status,
    String? direction,
    String? eventType,
    String? objectType,
    String? localDoctype,
    String? reviewState,
    String? search,
    int limit = 50,
  }) async => events;
}

const _testRoles = UserRoles(
  user: 'operator@example.com',
  roles: ['WooCommerce Sync Operator'],
);

Future<void> _pumpWooSyncScreen(
  WidgetTester tester, {
  required WooSyncDashboard dashboard,
  List<WooSyncEvent> events = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userRolesFutureProvider.overrideWith((ref) async => _testRoles),
        managerAccessProvider.overrideWith((ref) async => false),
        requirePosShiftProvider.overrideWith((ref) => false),
        activeShiftProvider.overrideWith((ref) async => null),
        localeNotifierProvider.overrideWith((ref) => LocaleNotifier(null)),
        wooSyncRepositoryProvider.overrideWithValue(
          _FakeWooSyncRepository(dashboard: dashboard, events: events),
        ),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: WooSyncScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  group('WooSyncScreen', () {
    testWidgets('renders the breaker-open banner prominently when the breaker is open', (tester) async {
      final dashboard = WooSyncDashboard.fromJson({
        'breaker': {'failure_count': 6, 'open_until': '2026-09-07T12:00:00', 'is_open': true},
        'backlog': {'pending': 2, 'needs_attention': 3},
      });

      await _pumpWooSyncScreen(tester, dashboard: dashboard);

      // The open-state title and its failure-count summary must both be on
      // screen — this is the one thing the console must not let an operator
      // miss.
      expect(find.text('Outbound sync paused'), findsOneWidget);
      expect(find.textContaining('recent failures'), findsOneWidget);
      expect(find.text('Outbound sync healthy'), findsNothing);
    });

    testWidgets('renders the breaker-closed state distinctly when the breaker is closed', (tester) async {
      final dashboard = WooSyncDashboard.fromJson({
        'breaker': {'failure_count': 0, 'open_until': null, 'is_open': false},
        'backlog': {'pending': 0},
      });

      await _pumpWooSyncScreen(tester, dashboard: dashboard);

      expect(find.text('Outbound sync healthy'), findsOneWidget);
      expect(find.text('Outbound sync paused'), findsNothing);
    });

    testWidgets('shows the not-permitted state when the operator role is missing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRolesFutureProvider.overrideWith(
              (ref) async => const UserRoles(user: 'cashier@example.com', roles: []),
            ),
            managerAccessProvider.overrideWith((ref) async => false),
            requirePosShiftProvider.overrideWith((ref) => false),
            activeShiftProvider.overrideWith((ref) async => null),
            localeNotifierProvider.overrideWith((ref) => LocaleNotifier(null)),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: WooSyncScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Not permitted'), findsOneWidget);
      expect(find.text('Outbound sync paused'), findsNothing);
      expect(find.text('Outbound sync healthy'), findsNothing);
    });

    testWidgets('lists events and surfaces the bulk-limit message instead of calling the server', (tester) async {
      final dashboard = WooSyncDashboard.fromJson({
        'breaker': {'is_open': false},
        'backlog': {},
      });
      final events = List.generate(
        101,
        (i) => WooSyncEvent.fromJson({
          'name': 'WSE-$i',
          'direction': 'Outbound',
          'event_type': 'order.created',
          'status': 'Failed',
          'priority': 'Normal',
          'attempt_count': 1,
          'max_attempts': 5,
        }),
      );

      await _pumpWooSyncScreen(tester, dashboard: dashboard, events: events);

      // The list itself is virtualized (only the visible slice is realized),
      // so assert on the header count rather than an individual row's text —
      // that count is the one thing that must reflect the full 101 fetched.
      expect(find.text('101 events'), findsOneWidget);
      expect(find.text('No sync events match these filters.'), findsNothing);

      await tester.ensureVisible(find.text('Select all'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select all'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Retry selected'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retry selected'));
      await tester.pumpAndSettle();

      expect(find.textContaining('limited to 100 events'), findsOneWidget);
    });
  });
}
