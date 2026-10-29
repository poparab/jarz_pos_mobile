import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/followups/data/followups_repository.dart';
import 'package:jarz_pos/src/features/followups/data/models/followup_models.dart';
import 'package:jarz_pos/src/features/followups/presentation/screens/followup_results_screen.dart';

class _FakeRepo implements FollowupsRepository {
  _FakeRepo(this.report);

  final FollowupSentReport report;
  final List<String> sentRanges = [];

  @override
  Future<FollowupSentReport> fetchSentReport({
    required String fromDate,
    required String toDate,
  }) async {
    sentRanges.add('$fromDate..$toDate');
    return report;
  }

  @override
  Future<FollowupStats> fetchStats({
    required String fromDate,
    required String toDate,
  }) async => FollowupStats.fromJson({
    'total': 12,
    'calls_done': 9,
    'calls_reached': 6,
    'by_outcome': {'Happy': 4},
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

FollowupSentReport _report() => FollowupSentReport.fromJson({
  'totals': {
    'sent': 4,
    'delivered': 3,
    'read': 2,
    'failed': 1,
    'replied': 2,
    'reordered': 2,
  },
  'by_step': {
    'day32': {'sent': 3, 'delivered': 2, 'read': 1, 'reordered': 1},
    '3h': {'sent': 1, 'delivered': 1, 'read': 1, 'reordered': 1},
  },
  'by_day': {'2026-10-27': 4},
  'cancelled': {'Order cancelled': 2},
  'items_total': 4,
  'customers': 4,
  'money': {
    'currency': 'EGP',
    'message_cost_each': 1,
    'billable_messages': 3,
    'messages_cost': 3,
    'discount_cost': 47,
    'total_cost': 50,
    'orders': 2,
    'revenue': 500,
    'orders_with_code': 1,
    'revenue_with_code': 300,
    'net': 450,
    'roi': 10,
    'cost_per_order': 25,
  },
  'codes': {'issued': 2, 'used': 1, 'unused': 1, 'expired': 0},
  'items': [
    {
      'name': 'FUT-1',
      'customer': 'C1',
      'customer_name': 'Mona Ali',
      'phone': '01012345678',
      'step': 'day32',
      'sent_at': '2026-10-27 10:00:00',
      'wa_status': 'read',
      'offer_code': 'JRZ-MONA',
      'tier': 'vip',
      'code_status': 'used',
      'code_discount': 47,
      'replied': 1,
      'reply_count': 2,
      'replies': [
        {
          'at': '2026-10-27 11:00:00',
          'text': 'Thank you so much',
          'type': 'text',
        },
        {'at': '2026-10-27 11:02:00', 'text': '', 'type': 'audio'},
      ],
      'reorder_invoice': 'SINV-1',
      'reorder_total': 300,
      'orders': [
        {
          'invoice': 'SINV-1',
          'at': '2026-10-28 09:00:00',
          'grand_total': 300,
          'used_code': 1,
        },
      ],
    },
    {
      'name': 'FUT-2',
      'customer': 'C2',
      'customer_name': 'Omar Said',
      'phone': '01199998888',
      'step': 'day32',
      'sent_at': '2026-10-27 10:05:00',
      'wa_status': 'failed',
      'error': 'Template rejected',
    },
    {
      'name': 'FUT-3',
      'customer': 'C3',
      'customer_name': 'Sara Hany',
      'phone': '01255556666',
      'step': '3h',
      'sent_at': '2026-10-27 10:10:00',
      'wa_status': 'delivered',
      'reorder_invoice': 'SINV-2',
      'reorder_total': 200,
      'orders': [
        {'invoice': 'SINV-2', 'at': '2026-10-27 18:00:00', 'grand_total': 200},
      ],
    },
    {
      'name': 'FUT-4',
      'customer': 'C4',
      'customer_name': 'Hoda Nabil',
      'phone': '01077778888',
      'step': 'day32',
      'sent_at': '2026-10-27 10:15:00',
      'wa_status': 'delivered',
      'replied': 1,
      'reply_count': 1,
      'replies': [
        {
          'at': '2026-10-27 12:00:00',
          'text': 'STOP',
          'type': 'text',
          'is_stop': 1,
        },
      ],
    },
  ],
});

Future<_FakeRepo> _pump(
  WidgetTester tester, {
  FollowupSentReport? report,
  Locale locale = const Locale('en'),
  Size size = const Size(800, 1600),
}) async {
  final repo = _FakeRepo(report ?? _report());
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [followupsRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const FollowupResultsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(TabBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the five tabs and the range chips', (tester) async {
    await _pump(tester);
    expect(find.text('Follow-up results'), findsOneWidget);
    for (final t in ['Overview', 'Messages', 'Replies', 'Orders', 'Calls']) {
      expect(
        find.descendant(of: find.byType(TabBar), matching: find.text(t)),
        findsOneWidget,
        reason: t,
      );
    }
    for (final c in ['7 days', '30 days', 'This month', 'Custom']) {
      expect(find.text(c), findsOneWidget, reason: c);
    }
  });

  testWidgets('overview shows cost versus orders, funnel and codes', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('Cost vs. orders'), findsOneWidget);
    expect(find.text('×10.0'), findsOneWidget);
    expect(find.text('Total cost'), findsOneWidget);
    expect(find.textContaining('EGP'), findsWidgets);
    expect(find.text('From message to order'), findsOneWidget);
    expect(find.text('Codes'), findsOneWidget);
    expect(find.text('Not used yet'), findsOneWidget);
  });

  testWidgets('overview hides the cost and code cards for an older server', (
    tester,
  ) async {
    await _pump(
      tester,
      report: FollowupSentReport.fromJson({
        'totals': {'sent': 1},
        'items': const [],
      }),
    );
    expect(find.text('Cost vs. orders'), findsNothing);
    expect(find.text('Codes'), findsNothing);
    expect(find.text('From message to order'), findsOneWidget);
  });

  testWidgets('messages tab lists cards, filters and opens the detail sheet', (
    tester,
  ) async {
    await _pump(tester);
    await _openTab(tester, 'Messages');

    expect(find.text('4 of 4 messages'), findsOneWidget);
    expect(find.text('Mona Ali'), findsOneWidget);
    expect(find.text('Omar Said'), findsOneWidget);
    expect(find.text('Thank you so much'), findsNothing);
    // The preview is the latest reply, the voice note.
    expect(find.text('[voice note]'), findsOneWidget);
    expect(find.text('Template rejected'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'omar');
    await tester.pumpAndSettle();
    expect(find.text('1 of 4 messages'), findsOneWidget);
    expect(find.text('Mona Ali'), findsNothing);

    await tester.tap(
      find.byTooltip('Clear filters').evaluate().isEmpty
          ? find.text('Clear filters')
          : find.byTooltip('Clear filters'),
    );
    await tester.pumpAndSettle();
    expect(find.text('4 of 4 messages'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Failed'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 4 messages'), findsOneWidget);
    expect(find.text('Omar Said'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mona Ali'));
    await tester.pumpAndSettle();
    expect(find.text('Thank you so much'), findsOneWidget);
    expect(find.text('[voice note]'), findsWidgets);
    expect(find.text('Show all messages to this customer'), findsOneWidget);

    await tester.tap(find.text('Show all messages to this customer'));
    await tester.pumpAndSettle();
    expect(find.text('Show all messages to this customer'), findsNothing);
    expect(find.text('1 of 4 messages'), findsOneWidget);
    expect(find.text('Mona Ali'), findsWidgets);
  });

  testWidgets('messages tab notes when the server capped the list', (
    tester,
  ) async {
    await _pump(
      tester,
      report: FollowupSentReport.fromJson({
        'items_total': 1500,
        'items': [
          {'name': 'FUT-1', 'customer_name': 'Mona', 'step': 'day32'},
        ],
      }),
    );
    await _openTab(tester, 'Messages');
    expect(find.text('1 of 1,500 messages'), findsOneWidget);
    expect(find.textContaining('latest 1 of 1,500'), findsOneWidget);
  });

  testWidgets('replies tab shows what customers said, stop flagged', (
    tester,
  ) async {
    await _pump(tester);
    await _openTab(tester, 'Replies');
    expect(find.text('Mona Ali'), findsOneWidget);
    expect(find.text('Hoda Nabil'), findsOneWidget);
    expect(find.text('Omar Said'), findsNothing);
    expect(find.text('Thank you so much'), findsOneWidget);
    expect(find.text('[voice note]'), findsOneWidget);
    expect(find.text('STOP'), findsOneWidget);
    expect(find.text('Asked to stop messages'), findsOneWidget);
  });

  testWidgets('orders tab lists distinct orders with a total', (tester) async {
    await _pump(tester);
    await _openTab(tester, 'Orders');
    expect(find.textContaining('2 orders'), findsOneWidget);
    expect(find.text('SINV-1'), findsOneWidget);
    expect(find.text('SINV-2'), findsOneWidget);
    expect(find.text('Used the code'), findsOneWidget);
    expect(find.textContaining('After: Day 32'), findsOneWidget);
    expect(find.textContaining('After: After 3 hours'), findsOneWidget);
  });

  testWidgets('calls tab shows the call stats', (tester) async {
    await _pump(tester);
    await _openTab(tester, 'Calls');
    expect(find.text('Calls made'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
  });

  testWidgets('changing the range refetches with the new dates', (
    tester,
  ) async {
    final repo = await _pump(tester);
    expect(repo.sentRanges, hasLength(1));
    await tester.tap(find.text('30 days'));
    await tester.pumpAndSettle();
    expect(repo.sentRanges, hasLength(2));
    expect(repo.sentRanges.last, isNot(repo.sentRanges.first));
  });

  testWidgets('renders in Arabic on a phone width without overflow', (
    tester,
  ) async {
    await _pump(tester, locale: const Locale('ar'), size: const Size(360, 740));
    expect(find.text('نتائج المتابعة'), findsOneWidget);
    await _openTab(tester, 'الرسايل');
    expect(find.text('Mona Ali'), findsOneWidget);
    expect(find.text('الرسايل'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
