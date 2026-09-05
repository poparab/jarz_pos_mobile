import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/widgets/history_sheet.dart';

/// Four modules share this sheet, so a regression here is a regression in all
/// of Stock Transfer, Cash Transfer, Inventory Count and Shift at once.
Future<void> _open(
  WidgetTester tester, {
  required Future<HistoryPage<String>> Function(HistoryQuery query) fetch,
  String? searchHint,
  bool showDateRange = false,
  Widget Function(BuildContext, VoidCallback)? filterBuilder,
  int pageSize = 30,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: HistorySheet<String>(
          title: 'History',
          emptyMessage: 'Nothing yet',
          searchHint: searchHint,
          showDateRange: showDateRange,
          filterBuilder: filterBuilder,
          pageSize: pageSize,
          fetch: fetch,
          itemBuilder: (context, item) => ListTile(title: Text(item)),
        ),
      ),
    ),
  );
}

void main() {
  group('HistorySheet', () {
    testWidgets('shows a spinner first, then the rows', (tester) async {
      final gate = Completer<HistoryPage<String>>();
      await _open(tester, fetch: (_) => gate.future);

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      gate.complete(const HistoryPage(items: ['a', 'b'], total: 2));
      await tester.pumpAndSettle();

      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows the module\'s empty message for no rows', (tester) async {
      await _open(tester,
          fetch: (_) async => const HistoryPage(items: [], total: 0));
      await tester.pumpAndSettle();

      expect(find.text('Nothing yet'), findsOneWidget);
    });

    testWidgets('surfaces a failure and retries on demand', (tester) async {
      var attempts = 0;
      await _open(tester, fetch: (_) async {
        attempts++;
        if (attempts == 1) throw Exception('boom');
        return const HistoryPage(items: ['recovered'], total: 1);
      });
      await tester.pumpAndSettle();

      // 'boom' is not user copy, so the sheet shows the localised line and
      // keeps the raw text for diagnostics only.
      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(find.text(l10n.userErrorUnexpected), findsOneWidget);
      expect(find.textContaining('boom'), findsNothing);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(find.text('recovered'), findsOneWidget);
      expect(attempts, 2);
    });

    testWidgets('asks for the next page only while rows remain', (tester) async {
      final requested = <int>[];
      await _open(
        tester,
        pageSize: 20,
        fetch: (query) async {
          requested.add(query.page);
          return HistoryPage(
            items: List.generate(20, (i) => 'row ${query.page * 20 + i}'),
            // 25 in total, so page 1 completes the set and page 2 must never
            // be asked for.
            total: 25,
          );
        },
      );
      await tester.pumpAndSettle();
      expect(requested, [0]);

      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(requested, [0, 1], reason: 'scrolling near the end loads page 1');

      await tester.drag(find.byType(ListView), const Offset(0, -4000));
      await tester.pumpAndSettle();
      expect(requested, [0, 1],
          reason: '40 rows already exceed the reported total of 25');
    });

    testWidgets('debounces search and resets to the first page',
        (tester) async {
      final queries = <HistoryQuery>[];
      await _open(
        tester,
        searchHint: 'Find',
        pageSize: 20,
        // Two pages exactly, so paging cannot cascade while the assertions
        // about the search itself are being made.
        fetch: (query) async {
          queries.add(query);
          return HistoryPage(
            items: List.generate(20, (i) => 'row ${query.page}-$i'),
            total: 40,
          );
        },
      );
      await tester.pumpAndSettle();

      // Move off page 0 first, so a reset is observable.
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(queries.last.page, greaterThan(0));

      await tester.enterText(find.byType(TextField), 'jar');
      await tester.pump(const Duration(milliseconds: 100));
      expect(queries.last.search, isNull, reason: 'still inside the debounce');

      // Past the 350ms debounce. `pumpAndSettle` alone would not get here:
      // nothing schedules a frame while the timer is pending, so it returns
      // before the timer ever fires.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      final firstSearched =
          queries.firstWhere((q) => q.search == 'jar', orElse: () => queries.last);
      expect(firstSearched.search, 'jar');
      expect(firstSearched.page, 0, reason: 'a new filter starts at page 0');
    });

    testWidgets('a late response for an old filter cannot overwrite a new one',
        (tester) async {
      // The trap this guards: type "a", the slow request for "a" is still in
      // flight when "ab" returns, and the stale rows land last.
      final gates = <String, Completer<HistoryPage<String>>>{};
      await _open(
        tester,
        searchHint: 'Find',
        fetch: (query) {
          final key = query.search ?? '';
          final completer = Completer<HistoryPage<String>>();
          gates[key] = completer;
          return completer.future;
        },
      );
      await tester.pump();
      gates['']!.complete(const HistoryPage(items: ['initial'], total: 1));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump(const Duration(milliseconds: 400));

      gates['ab']!.complete(const HistoryPage(items: ['fresh'], total: 1));
      await tester.pumpAndSettle();
      gates['a']!.complete(const HistoryPage(items: ['stale'], total: 1));
      await tester.pumpAndSettle();

      expect(find.text('fresh'), findsOneWidget);
      expect(find.text('stale'), findsNothing);
    });

    testWidgets('hides search when a module has nothing to search on',
        (tester) async {
      await _open(tester,
          fetch: (_) async => const HistoryPage(items: ['x'], total: 1));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('renders a module filter and refetches when it changes',
        (tester) async {
      var mineOnly = false;
      var calls = 0;
      await _open(
        tester,
        fetch: (_) async {
          calls++;
          return HistoryPage(items: ['mineOnly=$mineOnly'], total: 1);
        },
        filterBuilder: (context, refresh) => FilterChip(
          label: const Text('Mine only'),
          selected: mineOnly,
          onSelected: (value) {
            mineOnly = value;
            refresh();
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.text('mineOnly=false'), findsOneWidget);

      await tester.tap(find.text('Mine only'));
      await tester.pumpAndSettle();

      expect(calls, 2);
      expect(find.text('mineOnly=true'), findsOneWidget);
    });
  });
}
