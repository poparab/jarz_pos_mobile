import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';
import 'package:jarz_pos/src/features/kanban/widgets/kanban_filters_widget.dart';

Future<void> _pumpKanbanFilters(WidgetTester tester, KanbanFilters filters) async {
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
          customers: const [],
          onFiltersChanged: (_) {},
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
          customer: 'Ahmed',
          status: 'Paid',
        ),
      );

      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pumpAndSettle();

      expect(find.text('بحث: Ali'), findsOneWidget);
      expect(find.text('العميل: Ahmed'), findsOneWidget);
      expect(find.text('الحالة: مدفوع'), findsOneWidget);
    });
  });
}