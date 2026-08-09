import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';
import 'package:jarz_pos/src/features/kanban/widgets/kanban_filters_widget.dart';

Future<void> _pumpKanbanFilters(
  WidgetTester tester,
  KanbanFilters filters, {
  List<CustomerOption> customers = const [],
  ValueChanged<KanbanFilters>? onFiltersChanged,
  int resultCount = 0,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: KanbanFiltersWidget(
          filters: filters,
          customers: customers,
          resultCount: resultCount,
          onFiltersChanged: onFiltersChanged ?? (_) {},
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

/// The chip's own delete affordance, as opposed to the search field's clear
/// button — both render a close glyph.
Finder _chipDeleteIcon() => find.descendant(
      of: find.byType(InputChip),
      matching: find.byIcon(Icons.close),
    );

void main() {
  group('KanbanFiltersWidget', () {
    testWidgets('shows every active filter value without opening anything',
        (tester) async {
      await _pumpKanbanFilters(
        tester,
        const KanbanFilters(
          searchTerm: 'Ali',
          customer: 'CUST-AHMED',
          status: 'Paid',
        ),
        customers: [
          CustomerOption(customer: 'CUST-AHMED', customerName: 'Ahmed'),
        ],
      );

      expect(find.text('Ali'), findsOneWidget); // search field
      expect(find.text('Ahmed'), findsOneWidget); // customer chip
      expect(find.text('مدفوع'), findsOneWidget); // status chip
    });

    testWidgets('reports how many orders matched', (tester) async {
      await _pumpKanbanFilters(
        tester,
        const KanbanFilters(searchTerm: 'Ali'),
        resultCount: 3,
      );

      expect(find.text('3 طلبات مطابقة'), findsOneWidget);
    });

    testWidgets('search is debounced, then fires once', (tester) async {
      final emitted = <KanbanFilters>[];

      await _pumpKanbanFilters(
        tester,
        const KanbanFilters(),
        onFiltersChanged: emitted.add,
      );

      await tester.enterText(find.byType(TextField).first, 'Ali');
      await tester.pump(const Duration(milliseconds: 100));
      expect(emitted, isEmpty, reason: 'must not fetch mid-keystroke');

      await tester.pump(const Duration(milliseconds: 400));
      expect(emitted.single.searchTerm, 'Ali');
    });

    testWidgets('search clear button resets the search filter', (tester) async {
      KanbanFilters? changedFilters;

      await _pumpKanbanFilters(
        tester,
        const KanbanFilters(searchTerm: 'Ali'),
        onFiltersChanged: (filters) => changedFilters = filters,
      );

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('Ali'), findsNothing);
      expect(changedFilters?.searchTerm, isEmpty);
    });

    testWidgets('customer picker stores selected customer id and shows display name',
        (tester) async {
      KanbanFilters? changedFilters;

      await _pumpKanbanFilters(
        tester,
        const KanbanFilters(),
        customers: [
          CustomerOption(customer: 'CUST-1', customerName: 'Alice Johnson'),
          CustomerOption(customer: 'CUST-2', customerName: 'Bob Smith'),
        ],
        onFiltersChanged: (filters) => changedFilters = filters,
      );

      await tester.tap(find.text('كل العملاء'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'Alice');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alice Johnson'));
      await tester.pumpAndSettle();

      expect(changedFilters?.customer, 'CUST-1');
      expect(find.text('Alice Johnson'), findsOneWidget);
    });

    testWidgets('removing customer chip clears the customer filter',
        (tester) async {
      KanbanFilters? changedFilters;

      await _pumpKanbanFilters(
        tester,
        const KanbanFilters(customer: 'CUST-1'),
        customers: [
          CustomerOption(customer: 'CUST-1', customerName: 'Alice Johnson'),
        ],
        onFiltersChanged: (filters) => changedFilters = filters,
      );

      expect(find.text('Alice Johnson'), findsOneWidget);
      await tester.tap(_chipDeleteIcon());
      await tester.pumpAndSettle();

      expect(changedFilters?.customer, isNull);
    });

    testWidgets('a date preset applies a range without the calendar',
        (tester) async {
      KanbanFilters? changedFilters;

      await _pumpKanbanFilters(
        tester,
        const KanbanFilters(),
        onFiltersChanged: (filters) => changedFilters = filters,
      );

      await tester.tap(find.text('كل التواريخ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('النهاردة'));
      await tester.pumpAndSettle();

      final now = DateTime.now();
      expect(changedFilters?.dateFrom, DateTime(now.year, now.month, now.day));
      expect(changedFilters?.dateTo, DateTime(now.year, now.month, now.day));
    });

    testWidgets('clear all resets every dimension at once', (tester) async {
      KanbanFilters? changedFilters;

      await _pumpKanbanFilters(
        tester,
        KanbanFilters(
          searchTerm: 'Ali',
          customer: 'CUST-1',
          status: 'Paid',
          dateFrom: DateTime(2026, 1, 1),
          amountFrom: 50,
        ),
        onFiltersChanged: (filters) => changedFilters = filters,
      );

      await tester.tap(find.text('مسح الكل'));
      await tester.pumpAndSettle();

      expect(changedFilters, const KanbanFilters());
      expect(changedFilters?.hasFilters, isFalse);
    });

    testWidgets('a filter cleared by the board wins over an in-flight keystroke',
        (tester) async {
      // Regression: the debounce timer used to survive an external reset and
      // put the search term straight back a moment later.
      final emitted = <KanbanFilters>[];
      var filters = const KanbanFilters(customer: 'CUST-1');

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: Column(
                children: [
                  KanbanFiltersWidget(
                    filters: filters,
                    customers: const [],
                    onFiltersChanged: emitted.add,
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => filters = const KanbanFilters()),
                    child: const Text('reset'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Ali');
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('reset'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(emitted, isEmpty);
      expect(find.text('Ali'), findsNothing);
    });
  });
}
