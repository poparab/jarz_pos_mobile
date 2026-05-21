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
          onFiltersChanged: onFiltersChanged ?? (_) {},
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  group('KanbanFiltersWidget', () {
    testWidgets('should render Arabic active filter labels when filters are applied', (tester) async {
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

      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pumpAndSettle();

      expect(find.text('بحث: Ali'), findsOneWidget);
      expect(find.text('العميل: Ahmed'), findsOneWidget);
      expect(find.text('الحالة: مدفوع'), findsOneWidget);
    });

    testWidgets('search clear button resets the search filter', (tester) async {
      KanbanFilters? changedFilters;

      await _pumpKanbanFilters(
        tester,
        const KanbanFilters(searchTerm: 'Ali'),
        onFiltersChanged: (filters) => changedFilters = filters,
      );

      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.clear).first);
      await tester.pumpAndSettle();

      expect(find.text('Ali'), findsNothing);
      expect(changedFilters?.searchTerm, isEmpty);
    });

    testWidgets('customer picker stores selected customer id and shows display name', (tester) async {
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

      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pumpAndSettle();

      await tester.tap(find.text('كل العملاء'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'Alice');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alice Johnson'));
      await tester.pumpAndSettle();

      expect(changedFilters?.customer, 'CUST-1');
      expect(find.text('Alice Johnson'), findsOneWidget);
    });

    testWidgets('removing customer chip clears the customer filter', (tester) async {
      KanbanFilters? changedFilters;

      await _pumpKanbanFilters(
        tester,
        const KanbanFilters(customer: 'CUST-1'),
        customers: [
          CustomerOption(customer: 'CUST-1', customerName: 'Alice Johnson'),
        ],
        onFiltersChanged: (filters) => changedFilters = filters,
      );

      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pumpAndSettle();

      expect(find.text('العميل: Alice Johnson'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(changedFilters?.customer, isNull);
    });
  });
}