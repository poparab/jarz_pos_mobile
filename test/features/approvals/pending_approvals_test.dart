// The side-menu pending-approvals indicator.
//
// What a manager relies on: the menu button on any screen shows how many
// things wait on them, the side menu lists each queue with its count, and
// nothing appears at all when nothing waits or the user approves nothing.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/approvals/data/pending_approvals_repository.dart';
import 'package:jarz_pos/src/features/approvals/models/pending_approvals.dart';
import 'package:jarz_pos/src/features/approvals/presentation/pending_approvals_widgets.dart';

class _FakeRepository implements PendingApprovalsRepository {
  final Map<String, dynamic> json;
  _FakeRepository(this.json);

  @override
  Future<PendingApprovals> fetch() async => PendingApprovals.fromJson(json);
}

Future<void> _pump(WidgetTester tester, Map<String, dynamic> json) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pendingApprovalsRepositoryProvider.overrideWithValue(
          _FakeRepository(json),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        // The same hook the app installs in app.dart.
        theme: ThemeData(
          actionIconTheme: ActionIconThemeData(
            drawerButtonIconBuilder: (_) => const PendingApprovalsMenuIcon(),
          ),
        ),
        home: Scaffold(
          appBar: AppBar(title: const Text('Any screen')),
          drawer: const Drawer(
            child: Column(children: [PendingApprovalsDrawerSection()]),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Tear the scope down so the provider's poll timer is cancelled.
Future<void> _dispose(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox.shrink());

const _manager = {
  'eligible': true,
  'total': 29,
  'queues': [
    {'key': 'expenses', 'count': 1, 'oldest_month': '2026-08'},
    {'key': 'employee_advances', 'count': 0, 'oldest_month': null},
    {'key': 'payment_receipts', 'count': 28},
    {'key': 'some_future_queue', 'count': 4},
  ],
};

void main() {
  group('PendingApprovals.fromJson', () {
    test('drops unknown queues and sums only what it can show', () {
      final parsed = PendingApprovals.fromJson(_manager);
      expect(parsed.eligible, isTrue);
      expect(parsed.queues.map((q) => q.key), [
        'expenses',
        'employee_advances',
        'payment_receipts',
      ]);
      expect(parsed.waiting.map((q) => q.key), [
        'expenses',
        'payment_receipts',
      ]);
      expect(parsed.total, 29);
      expect(parsed.queues.first.oldestMonth, '2026-08');
      expect(parsed.queues[1].oldestMonth, isNull);
    });
  });

  testWidgets('menu button carries the total on any screen', (tester) async {
    await _pump(tester, _manager);
    expect(find.byType(Badge), findsOneWidget);
    expect(find.text('29'), findsOneWidget);
    await _dispose(tester);
  });

  testWidgets('side menu lists each waiting queue with its count', (
    tester,
  ) async {
    await _pump(tester, _manager);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Needs your action'), findsOneWidget);
    expect(find.text('Expense requests to approve'), findsOneWidget);
    expect(find.text('Payment receipts to confirm'), findsOneWidget);
    // A zero queue is not a row.
    expect(find.text('Salary advances to approve'), findsNothing);
    expect(find.text('28'), findsOneWidget);
    await _dispose(tester);
  });

  testWidgets('nothing shows when nothing waits', (tester) async {
    await _pump(tester, {
      'eligible': true,
      'total': 0,
      'queues': [
        {'key': 'expenses', 'count': 0},
      ],
    });
    expect(find.byType(Badge), findsNothing);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('Needs your action'), findsNothing);
    await _dispose(tester);
  });

  testWidgets('a user who approves nothing sees the plain menu', (
    tester,
  ) async {
    await _pump(tester, {'eligible': false, 'total': 0, 'queues': []});
    expect(find.byType(Badge), findsNothing);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    await _dispose(tester);
  });
}
