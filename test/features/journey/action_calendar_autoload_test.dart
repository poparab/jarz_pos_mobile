// The B2B action calendar must show current data without anyone pressing
// Refresh.
//
// Reported as "the items don't load automatically, I have to press the button
// or reopen the screen". Entering the screen was never the problem — the
// provider is autoDispose, so a fresh entry always fetches. The gap was
// everything that happens WITHOUT a fresh entry: tapping through to an account,
// logging a visit or ticking a promise off in there, and coming back to a
// calendar that was never disposed and so still showed the numbers the rep had
// just changed. Backgrounding the phone had the same shape — the grid's dots
// and its overdue colour are computed against the server's "today".
//
// These tests pin the two revalidation triggers the fix added.
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/app_routes.dart';
import 'package:jarz_pos/src/features/journey/data/journey_repository.dart';
import 'package:jarz_pos/src/features/journey/data/models/journey_action.dart';
import 'package:jarz_pos/src/features/journey/presentation/screens/action_calendar_screen.dart';

/// Today, ISO — the row has to land on the day the screen selects by default,
/// or there would be nothing on screen to tap.
String _todayIso() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

Map<String, dynamic> _payload() => {
  'scope': 'mine',
  'actions': [
    {
      'source': 'journey',
      'note': 'JN-001',
      'reference_doctype': 'Lead',
      'reference_name': 'LEAD-001',
      'title': 'Acme Co',
      'date': _todayIso(),
      'action': 'Call Acme',
      'entry_type': 'Call',
      'done': false,
      'overdue': false,
      'can_complete': true,
    },
  ],
  'counts': {'pending': 1, 'overdue': 0, 'done': 0},
};

class _FakeJourneyRepository extends JourneyRepository {
  _FakeJourneyRepository() : super(Dio());

  int calendarCalls = 0;

  @override
  Future<JourneyActionCalendar> getActionCalendar({
    required String fromDate,
    required String toDate,
    String scope = 'mine',
    bool includeDone = false,
  }) async {
    calendarCalls++;
    return JourneyActionCalendar.fromJson(_payload());
  }
}

/// Stands in for the B2B account screen the rows push into.
class _AccountStub extends StatelessWidget {
  const _AccountStub();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => context.pop(),
          child: const Text('back'),
        ),
      ),
    );
  }
}

Widget _wrap(_FakeJourneyRepository repo) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ActionCalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.b2bAccount,
        builder: (context, state) => const _AccountStub(),
      ),
    ],
  );
  return ProviderScope(
    overrides: [journeyRepositoryProvider.overrideWithValue(repo)],
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
  );
}

void main() {
  group('action calendar revalidation', () {
    testWidgets('fetches on entry without anyone pressing Refresh', (
      tester,
    ) async {
      final repo = _FakeJourneyRepository();
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(repo.calendarCalls, 1);
      expect(find.text('Call Acme'), findsOneWidget);
    });

    testWidgets('refetches on the way back from an account', (tester) async {
      final repo = _FakeJourneyRepository();
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();
      expect(repo.calendarCalls, 1);

      // The row sits under a full month grid, so it can start below the fold.
      await tester.ensureVisible(find.text('Call Acme'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Call Acme'));
      await tester.pumpAndSettle();
      expect(
        find.text('back'),
        findsOneWidget,
        reason: 'the row opens the account screen',
      );

      await tester.tap(find.text('back'));
      await tester.pumpAndSettle();

      // Without the fix the calendar was still mounted underneath, so its
      // cached month survived the round trip and this stayed at 1.
      expect(
        repo.calendarCalls,
        2,
        reason: 'returning from an account revalidates the month',
      );
    });

    testWidgets('refetches when the app is resumed', (tester) async {
      final repo = _FakeJourneyRepository();
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();
      expect(repo.calendarCalls, 1);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(
        repo.calendarCalls,
        2,
        reason: 'a phone that slept comes back to a refetched month',
      );
    });
  });
}
