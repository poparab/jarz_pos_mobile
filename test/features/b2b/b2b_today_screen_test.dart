import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/b2b/data/b2b_repository.dart';
import 'package:jarz_pos/src/features/b2b/data/models/b2b_models.dart';
import 'package:jarz_pos/src/features/b2b/presentation/screens/b2b_today_screen.dart';
import 'package:jarz_pos/src/features/b2b/state/b2b_today_notifier.dart';

class _FakeB2bRepository extends B2bRepository {
  _FakeB2bRepository() : super(Dio());

  final List<String> completeCalls = [];

  @override
  Future<void> completeFollowup({
    required String doctype,
    required String name,
  }) async {
    completeCalls.add('$doctype:$name');
  }
}

B2bFollowups _followups({required String date}) => B2bFollowups(
      todos: [
        FollowupItem(
          name: 'TODO-1',
          referenceType: 'Lead',
          referenceName: 'LEAD-001',
          description: 'Call Acme Co',
          date: date,
        ),
      ],
      reorderDue: const [],
    );

Widget _wrap({
  required B2bFollowups followups,
  required _FakeB2bRepository repo,
}) {
  return ProviderScope(
    overrides: [
      b2bRepositoryProvider.overrideWithValue(repo),
      b2bTodayProvider.overrideWith((ref) async => followups),
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
      home: B2bTodayScreen(),
    ),
  );
}

void main() {
  group('isFollowupOverdue', () {
    final now = DateTime(2026, 7, 11);

    test('a past date is overdue', () {
      expect(isFollowupOverdue('2026-07-01', now: now), isTrue);
    });

    test('today is NOT overdue', () {
      expect(isFollowupOverdue('2026-07-11', now: now), isFalse);
    });

    test('a future date is NOT overdue', () {
      expect(isFollowupOverdue('2026-07-20', now: now), isFalse);
    });

    test('null / empty / unparseable dates are not overdue', () {
      expect(isFollowupOverdue(null, now: now), isFalse);
      expect(isFollowupOverdue('', now: now), isFalse);
      expect(isFollowupOverdue('not-a-date', now: now), isFalse);
    });
  });

  group('B2bTodayScreen follow-ups', () {
    testWidgets('tapping "Done" calls complete_followup with the reference',
        (tester) async {
      final repo = _FakeB2bRepository();
      await tester.pumpWidget(
        _wrap(followups: _followups(date: '2026-07-20'), repo: repo),
      );
      await tester.pumpAndSettle();

      expect(find.text('Call Acme Co'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pump();

      expect(repo.completeCalls.single, 'Lead:LEAD-001');
    });

    testWidgets('an overdue follow-up is highlighted', (tester) async {
      final repo = _FakeB2bRepository();
      // A clearly-past date relative to any realistic test run.
      await tester.pumpWidget(
        _wrap(followups: _followups(date: '2000-01-01'), repo: repo),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('overdue'), findsOneWidget);
    });
  });
}
