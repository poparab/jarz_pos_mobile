import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/labels/models/label_models.dart';
import 'package:jarz_pos/src/features/labels/presentation/widgets/label_card.dart';
import 'package:jarz_pos/src/features/labels/presentation/widgets/label_sheets.dart';

CustomerLabel _label({
  required String name,
  required String title,
  String storageLocation = 'Dokki - J',
  int suggestedSheets = 3,
  String status = 'Reorder Now',
}) {
  return CustomerLabel.fromJson({
    'name': name,
    'customer': 'CUST-A',
    'customer_name': 'Cafe X',
    'label_title': title,
    'item': '$title Jar',
    'size': 'Medium',
    'storage_location': storageLocation,
    'enabled': 1,
    'we_print': 1,
    'tracked': 1,
    'labels_per_unit': 1,
    'labels_per_sheet': 21,
    'default_print_sheets': 2,
    'on_hand_qty': 10,
    'min_stock_qty': 0,
    'suggested_print_sheets': suggestedSheets,
    'suggested_print_qty': suggestedSheets * 21,
    'avg_daily_usage': 5.0,
    'days_of_cover': 2.0,
    'status': status,
    'needs_attention': status != 'OK',
    'lead_days': 4,
    'open_print_orders': const [],
  });
}

Widget _host(Widget child) => ProviderScope(
      child: MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  group('LabelCustomerCard', () {
    testWidgets('starts collapsed with a one-line status, expands on tap',
        (tester) async {
      final group = groupLabelsByCustomer([
        _label(name: 'L1', title: 'Mango'),
        _label(name: 'L2', title: 'Lotus', status: 'OK'),
      ]).single;
      var expanded = false;
      await tester.pumpWidget(
        _host(StatefulBuilder(
          builder: (context, setState) => LabelCustomerCard(
            group: group,
            expanded: expanded,
            onOpen: (_) {},
            onToggle: () => setState(() => expanded = !expanded),
            onQuickOrder: () {},
          ),
        )),
      );

      expect(find.text('Cafe X'), findsOneWidget);
      expect(find.textContaining('need'), findsOneWidget);
      expect(find.text('Lotus'), findsNothing);

      await tester.tap(find.text('Cafe X'));
      await tester.pumpAndSettle();
      expect(find.text('Lotus'), findsOneWidget);
    });
  });

  group('QuickOrderSheet', () {
    Future<QuickOrderRequest?> run(
      WidgetTester tester,
      List<CustomerLabel> labels,
      Future<void> Function() interact,
    ) async {
      QuickOrderRequest? result;
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showModalBottomSheet<QuickOrderRequest>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => QuickOrderSheet(
                        customerName: 'Cafe X',
                        labels: labels,
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await interact();
      return result;
    }

    testWidgets('one branch is picked for you; steppers build the order',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.reset);

      final result = await run(
        tester,
        [
          _label(name: 'L1', title: 'Mango'),
          _label(name: 'L2', title: 'Lotus'),
        ],
        () async {
          // Single branch: shown as text, no chips to pick.
          expect(find.text('Dokki'), findsOneWidget);
          expect(find.byType(FilterChip), findsNothing);
          await tester.tap(find.byIcon(Icons.add_circle).first);
          await tester.pump();
          await tester.tap(find.byIcon(Icons.add_circle).first);
          await tester.pump();
          await tester.tap(find.text('Record order · 2 sheets'));
          await tester.pumpAndSettle();
        },
      );

      expect(result, isNotNull);
      expect(result!.sheetsByLabel, {'L1': 2});
      expect(result.requestedOn, isNotNull);
    });

    testWidgets('two branches: every branch selected, the count goes to both',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.reset);

      final result = await run(
        tester,
        [
          _label(name: 'D1', title: 'Mango', storageLocation: 'Dokki - J'),
          _label(name: 'O1', title: 'Mango', storageLocation: 'October - J'),
        ],
        () async {
          expect(find.byType(FilterChip), findsNWidgets(2));
          await tester.tap(find.text('Fill suggested'));
          await tester.pump();
          expect(find.text('× 2 branches'), findsOneWidget);
          await tester.tap(find.text('Record order · 6 sheets'));
          await tester.pumpAndSettle();
        },
      );

      expect(result!.sheetsByLabel, {'D1': 3, 'O1': 3});
    });
  });
}
