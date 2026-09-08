// The posting-moment picker: a date step followed by a time step.
//
// The behaviour under test is the one an accountant hits: a backdated document
// must carry the time they chose, and a half-made choice — cancelling either
// step — must change nothing at all.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/widgets/posting_date_confirmation_dialog.dart';

/// Opens the picker from a real element, because [pickPostingDateTime] guards
/// `context.mounted` between its two awaits and that guard only means anything
/// on a context that belongs to the tree.
Future<List<DateTime?>> _openPicker(
  WidgetTester tester, {
  required DateTime initial,
}) async {
  final results = <DateTime?>[];
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            key: const Key('openPostingPicker'),
            onPressed: () async {
              results.add(
                await pickPostingDateTime(
                  context,
                  initial: initial,
                  firstDate: DateTime(initial.year - 1),
                  lastDate: DateTime(initial.year + 1),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(const Key('openPostingPicker')));
  await tester.pumpAndSettle();
  return results;
}

Future<bool?> _confirm(
  WidgetTester tester, {
  required List<DateTime> dates,
  bool? includeTime,
}) async {
  bool? outcome;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            key: const Key('openConfirm'),
            onPressed: () async {
              outcome = await confirmPostingDatesBeforeSubmit(
                context,
                dates: dates,
                includeTime: includeTime,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(const Key('openConfirm')));
  await tester.pumpAndSettle();
  return outcome;
}

void main() {
  group('formatPostingDateTimeForApi', () {
    test('emits the datetime wire shape with zeroed seconds', () {
      expect(
        formatPostingDateTimeForApi(DateTime(2026, 9, 8, 14, 30, 45, 123)),
        '2026-09-08 14:30:00',
      );
    });

    test('pads every component to two digits', () {
      expect(
        formatPostingDateTimeForApi(DateTime(2026, 1, 2, 3, 4)),
        '2026-01-02 03:04:00',
      );
    });

    test('spells midnight out rather than dropping it', () {
      expect(
        formatPostingDateTimeForApi(DateTime(2026, 9, 8)),
        '2026-09-08 00:00:00',
      );
    });

    test('leaves the date-only formatter alone', () {
      // Other callers still want a pure date, and the backend reads that as
      // "no explicit time" — the two forms must stay distinguishable.
      expect(formatPostingDateForApi(DateTime(2026, 9, 8, 14, 30)),
          '2026-09-08');
    });
  });

  group('pickPostingDateTime', () {
    testWidgets('returns the picked day carrying the confirmed time',
        (tester) async {
      final results = await _openPicker(
        tester,
        initial: DateTime(2026, 9, 8, 14, 30),
      );

      expect(find.text('Select posting date'), findsOneWidget);
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // The second step is a picker of its own, not an afterthought on the
      // first — and it is seeded from `initial`, so confirming it keeps 14:30.
      expect(find.text('Select posting time'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(results, [DateTime(2026, 9, 15, 14, 30)]);
    });

    testWidgets('returns null when the date step is cancelled',
        (tester) async {
      final results = await _openPicker(
        tester,
        initial: DateTime(2026, 9, 8, 14, 30),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(results, [null]);
      expect(find.text('Select posting time'), findsNothing);
    });

    testWidgets('returns null when the time step is cancelled', (tester) async {
      // The trap this closes: a day chosen and a time refused is not "that day
      // at whatever time the field already held".
      final results = await _openPicker(
        tester,
        initial: DateTime(2026, 9, 8, 14, 30),
      );

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Select posting time'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(results, [null]);
    });
  });

  group('confirmPostingDatesBeforeSubmit', () {
    testWidgets('shows the clock time once one was chosen', (tester) async {
      await _confirm(
        tester,
        dates: [DateTime(2026, 9, 8, 14, 30)],
        includeTime: true,
      );

      expect(
        find.text('Posting date and time: 2026-09-08 14:30'),
        findsOneWidget,
      );
    });

    testWidgets('stays date-only when no time was chosen', (tester) async {
      // Confirming a midnight the operator never picked is the misinformation
      // this dialog exists to prevent.
      await _confirm(
        tester,
        dates: [DateTime(2026, 9, 8)],
        includeTime: false,
      );

      expect(find.text('Posting date: 2026-09-08'), findsOneWidget);
      expect(find.textContaining('00:00'), findsNothing);
    });

    testWidgets('falls back to the midnight heuristic without a flag',
        (tester) async {
      await _confirm(tester, dates: [DateTime(2026, 9, 8, 9, 5)]);

      expect(
        find.text('Posting date and time: 2026-09-08 09:05'),
        findsOneWidget,
      );
    });
  });
}
