// "Active customers": the default B2B landing screen (Active-stage accounts only).
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/app_routes.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/b2b/data/b2b_repository.dart';
import 'package:jarz_pos/src/features/b2b/data/models/b2b_active_accounts.dart';
import 'package:jarz_pos/src/features/b2b/presentation/screens/b2b_active_accounts_screen.dart';
import 'package:jarz_pos/src/features/b2b/state/b2b_active_accounts_notifier.dart';

const _payload = <String, dynamic>{
  'today': '2026-10-18',
  'period_days': 30,
  'period_start': '2026-09-19',
  'summary': {
    'accounts': 2,
    'period_orders': 5,
    'period_billed': 4200, // int on purpose
    'prev_period_billed': 3000.0,
    'period_change_pct': 40.0,
    'outstanding': 750.5,
    'reorder_due': 1,
    'needs_attention': 1,
  },
  'accounts': [
    {
      'doctype': 'Lead',
      'name': 'LEAD-001',
      'title': 'Acme Bakery',
      'customer': 'CUST-1',
      'customer_name': 'Acme Bakery Co',
      'owner': 'rep@x.com',
      'mobile_no': '01000000000',
      'territory': 'Nasr City',
      'orders': 12,
      'billed': 15000, // int
      'avg_order_value': 1250.5, // double
      'period_orders': 4,
      'period_billed': 4000,
      'prev_period_billed': 2500,
      'period_change_pct': 60,
      'first_order_date': '2026-01-02',
      'last_order_date': '2026-10-10',
      'days_since_last_order': 8,
      'avg_order_cycle_days': 7.5,
      'predicted_next_order': '2026-10-17',
      'reorder_status': 'overdue',
      'outstanding': 750.5,
      'oldest_unpaid_days': 21,
      'label_alert': 1,
      'last_journey_date': '2026-10-09',
      'last_journey_note': 'Asked for new flavours',
      'next_action_date': '2026-10-20',
      'next_action': 'Visit shop',
      'alerts': ['reorder_overdue', 'old_unpaid', 'labels'],
    },
    {
      // Everything optional is missing / null.
      'doctype': 'Opportunity',
      'name': 'OPP-002',
      'title': 'Zed Cafe',
      'customer': null,
      'customer_name': null,
      'mobile_no': null,
      'territory': null,
      'orders': 0,
      'billed': 0,
      'avg_order_value': 0,
      'period_orders': 0,
      'period_billed': 0,
      'prev_period_billed': 0,
      'period_change_pct': null,
      'last_order_date': null,
      'days_since_last_order': null,
      'reorder_status': null,
      'outstanding': 0,
      'oldest_unpaid_days': null,
      'label_alert': 0,
      'alerts': ['no_customer'],
    },
  ],
};

class _FakeB2bRepository extends B2bRepository {
  _FakeB2bRepository() : super(Dio());
}

Widget _wrapWith({
  required Widget home,
  required B2bActiveAccounts data,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      b2bRepositoryProvider.overrideWithValue(_FakeB2bRepository()),
      b2bActiveAccountsProvider.overrideWith((ref) async => data),
      userRolesFutureProvider.overrideWith(
        (ref) async => const UserRoles(user: 'rep@x.com', roles: []),
      ),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

void main() {
  group('B2bActiveAccounts.fromJson', () {
    final parsed = B2bActiveAccounts.fromJson(
      Map<String, dynamic>.from(_payload),
    );

    test('parses the envelope and summary (int and double mix)', () {
      expect(parsed.today, '2026-10-18');
      expect(parsed.periodDays, 30);
      expect(parsed.summary.accounts, 2);
      expect(parsed.summary.periodBilled, 4200.0);
      expect(parsed.summary.prevPeriodBilled, 3000.0);
      expect(parsed.summary.periodChangePct, 40.0);
      expect(parsed.summary.outstanding, 750.5);
      expect(parsed.summary.reorderDue, 1);
      expect(parsed.summary.needsAttention, 1);
      expect(parsed.accounts, hasLength(2));
    });

    test('parses a fully populated account', () {
      final a = parsed.accounts.first;
      expect(a.doctype, 'Lead');
      expect(a.title, 'Acme Bakery');
      expect(a.customerName, 'Acme Bakery Co');
      expect(a.mobileNo, '01000000000');
      expect(a.billed, 15000.0);
      expect(a.avgOrderValue, 1250.5);
      expect(a.periodChangePct, 60.0);
      expect(a.daysSinceLastOrder, 8);
      expect(a.avgOrderCycleDays, 7.5);
      expect(a.reorderStatus, B2bReorderStatus.overdue);
      expect(a.oldestUnpaidDays, 21);
      expect(a.labelAlert, 1);
      expect(a.nextAction, 'Visit shop');
      expect(a.alerts, contains(B2bActiveAlert.oldUnpaid));
      expect(a.needsAttention, isTrue);
      expect(a.reorderDue, isTrue);
    });

    test('tolerates nulls and missing keys', () {
      final a = parsed.accounts.last;
      expect(a.customer, isNull);
      expect(a.mobileNo, isNull);
      expect(a.territory, isNull);
      expect(a.periodChangePct, isNull);
      expect(a.lastOrderDate, isNull);
      expect(a.daysSinceLastOrder, isNull);
      expect(a.reorderStatus, isNull);
      expect(a.nextAction, isNull);
      expect(a.lastJourneyNote, isNull);
      expect(a.reorderDue, isFalse);
      expect(a.hasAlert(B2bActiveAlert.noCustomer), isTrue);
    });

    test('an empty / malformed payload yields an empty result', () {
      final empty = B2bActiveAccounts.fromJson(const {});
      expect(empty.accounts, isEmpty);
      expect(empty.periodDays, 30);
      expect(empty.summary.accounts, 0);
      expect(empty.summary.periodChangePct, isNull);

      final odd = B2bActiveAccounts.fromJson({
        'summary': 'nope',
        'accounts': [
          {'name': 'X', 'title': null, 'orders': '3', 'billed': '10.5'},
          'garbage',
        ],
      });
      expect(odd.accounts, hasLength(1));
      expect(odd.accounts.single.title, 'X'); // falls back to name
      expect(odd.accounts.single.orders, 3);
      expect(odd.accounts.single.billed, 10.5);
    });
  });

  group('B2bActiveAccountsScreen', () {
    final data = B2bActiveAccounts.fromJson(
      Map<String, dynamic>.from(_payload),
    );

    testWidgets('shows the summary, the cards and the pipeline button', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360 * 3, 1600 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrapWith(home: const B2bActiveAccountsScreen(), data: data),
      );
      await tester.pumpAndSettle();

      expect(find.text('Active customers'), findsOneWidget);
      // Summary tiles.
      expect(find.text('Active accounts'), findsOneWidget);
      expect(find.text('Billed, last 30 days'), findsOneWidget);
      expect(find.text('Needs attention'), findsOneWidget);
      expect(find.text('Reorder due'), findsOneWidget);
      expect(find.byKey(const Key('b2b_active_kpi_billed')), findsOneWidget);
      // Up arrow share of the billed tile (40%).
      expect(find.text('40%'), findsOneWidget);

      // Cards.
      expect(find.text('Acme Bakery'), findsOneWidget);
      expect(find.text('Zed Cafe'), findsOneWidget);
      expect(find.text('Reorder overdue'), findsOneWidget);
      expect(find.text('Old unpaid invoice'), findsOneWidget);
      expect(find.text('Labels alert'), findsOneWidget);
      expect(find.text('No customer linked'), findsOneWidget);
      expect(find.text('No orders yet'), findsOneWidget);
      expect(find.textContaining('Visit shop'), findsOneWidget);
      // Call button only on the account with a number.
      expect(find.byKey(const Key('b2b_active_call_LEAD-001')), findsOneWidget);
      expect(find.byKey(const Key('b2b_active_call_OPP-002')), findsNothing);

      // Pipeline button (in the body and in the app bar).
      expect(
        find.byKey(const Key('b2b_active_pipeline_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('b2b_active_pipeline_action')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('search filters by title and territory', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 1600 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrapWith(home: const B2bActiveAccountsScreen(), data: data),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('b2b_active_search')), 'zed');
      await tester.pump();
      expect(find.text('Zed Cafe'), findsOneWidget);
      expect(find.text('Acme Bakery'), findsNothing);

      await tester.enterText(
        find.byKey(const Key('b2b_active_search')),
        'nasr',
      );
      await tester.pump();
      expect(find.text('Acme Bakery'), findsOneWidget);
      expect(find.text('Zed Cafe'), findsNothing);

      await tester.enterText(find.byKey(const Key('b2b_active_search')), 'zzz');
      await tester.pump();
      expect(find.text('No customers match your search'), findsOneWidget);
    });

    testWidgets('tapping the "Reorder due" tile filters the list', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 1600 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrapWith(home: const B2bActiveAccountsScreen(), data: data),
      );
      await tester.pumpAndSettle();

      // (Both accounts carry an alert, so "Needs attention" would not narrow.)
      // only Acme is overdue.
      await tester.tap(find.byKey(const Key('b2b_active_kpi_reorder')));
      await tester.pump();
      expect(find.text('Acme Bakery'), findsOneWidget);
      expect(find.text('Zed Cafe'), findsNothing);

      // Tapping again clears it.
      await tester.tap(find.byKey(const Key('b2b_active_kpi_reorder')));
      await tester.pump();
      expect(find.text('Zed Cafe'), findsOneWidget);
    });

    testWidgets('empty state offers the pipeline board', (tester) async {
      await tester.pumpWidget(
        _wrapWith(
          home: const B2bActiveAccountsScreen(),
          data: const B2bActiveAccounts(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No active customers yet'), findsOneWidget);
      expect(
        find.byKey(const Key('b2b_active_empty_pipeline_button')),
        findsOneWidget,
      );
    });

    testWidgets('the pipeline button navigates to the board route', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360 * 3, 1600 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final router = GoRouter(
        initialLocation: AppRoutes.b2b,
        routes: [
          GoRoute(
            path: AppRoutes.b2b,
            builder: (_, _) => const B2bActiveAccountsScreen(),
          ),
          GoRoute(
            path: AppRoutes.b2bPipeline,
            builder: (_, _) => const Scaffold(body: Text('PIPELINE BOARD')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            b2bRepositoryProvider.overrideWithValue(_FakeB2bRepository()),
            b2bActiveAccountsProvider.overrideWith((ref) async => data),
            userRolesFutureProvider.overrideWith(
              (ref) async => const UserRoles(user: 'rep@x.com', roles: []),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('b2b_active_pipeline_button')));
      await tester.pumpAndSettle();
      expect(find.text('PIPELINE BOARD'), findsOneWidget);
    });

    testWidgets('renders in Arabic (RTL) at phone width without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360 * 3, 1600 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrapWith(
          home: const B2bActiveAccountsScreen(),
          data: data,
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('العملاء النشطون'), findsOneWidget);
      expect(find.text('Acme Bakery'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
