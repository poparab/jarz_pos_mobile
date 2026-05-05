import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/presentation/widgets/bundle_selection_widget.dart';

void main() {
  group('BundleSelectionWidget', () {
    testWidgets(
      'should render bundle items and allow selecting them when payload mixes strings and numbers',
      (tester) async {
        final bundle = {
          'name': 'Jarz Signature Trio',
          'price': 480.0,
          'item_groups': [
            {
              'group_name': 'Large',
              'quantity': 3,
              'items': [
                {
                  'id': 'blueberry-large',
                  'name': 'Blueberry Large',
                  'price': '160.0',
                  'qty': '14',
                },
                {
                  'id': 'molten-large',
                  'name': 'Molten Large',
                  'price': 195.0,
                  'actual_qty': 5,
                },
              ],
            },
          ],
        };

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: BundleSelectionWidget(
                bundle: bundle,
                onCancel: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Blueberry Large'), findsOneWidget);
        expect(find.text('\$160.00'), findsOneWidget);
        expect(find.text('0/3'), findsOneWidget);

        await tester.tap(find.text('Blueberry Large'));
        await tester.pumpAndSettle();

        expect(find.text('1/3'), findsOneWidget);
      },
    );

    testWidgets(
      'should keep duplicate same-name groups isolated by section key',
      (tester) async {
        Map<String, List<Map<String, dynamic>>>? submittedSelections;
        final bundle = {
          'name': 'Jarz Large Bundle',
          'price': 640.0,
          'item_groups': [
            {
              'group_name': 'Large',
              'group_key': 'bundle-group-1',
              'quantity': 1,
              'items': [
                {
                  'id': 'blueberry-large',
                  'name': 'Blueberry Large',
                  'price': 160.0,
                  'qty': 10,
                },
              ],
            },
            {
              'group_name': 'Large',
              'group_key': 'bundle-group-2',
              'quantity': 1,
              'items': [
                {
                  'id': 'pistachio-large',
                  'name': 'Pistachio Large',
                  'price': 170.0,
                  'qty': 10,
                },
              ],
            },
          ],
        };

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: BundleSelectionWidget(
                bundle: bundle,
                onCancel: () {},
                isEditing: true,
                onBundleSelected: (selections) {
                  submittedSelections = selections;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Blueberry Large').first);
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('Pistachio Large'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Pistachio Large'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Update Bundle'));
        await tester.pumpAndSettle();

        expect(submittedSelections, isNotNull);
        expect(submittedSelections!.keys, containsAll(['bundle-group-1', 'bundle-group-2']));
        expect(submittedSelections!['bundle-group-1'], hasLength(1));
        expect(submittedSelections!['bundle-group-2'], hasLength(1));
      },
    );

    testWidgets(
      'should block selecting the same item in a later group when earlier groups already consumed its full stock',
      (tester) async {
        final bundle = {
          'name': 'Jarz Large Bundle',
          'price': 960.0,
          'item_groups': [
            {
              'group_name': 'Large x5',
              'group_key': 'bundle-group-1',
              'quantity': 5,
              'items': [
                {
                  'id': 'blueberry-large',
                  'name': 'Blueberry Large',
                  'price': 160.0,
                  'qty': 5,
                },
              ],
            },
            {
              'group_name': 'Large x1',
              'group_key': 'bundle-group-2',
              'quantity': 1,
              'items': [
                {
                  'id': 'blueberry-large',
                  'name': 'Blueberry Large',
                  'price': 160.0,
                  'qty': 5,
                },
              ],
            },
          ],
        };

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: BundleSelectionWidget(
                bundle: bundle,
                onCancel: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final blueberryCards = find.text('Blueberry Large');
        for (var index = 0; index < 5; index++) {
          await tester.tap(blueberryCards.first);
          await tester.pumpAndSettle();
        }

        expect(find.text('5/5'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Large x1'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        expect(find.text('0/1'), findsOneWidget);

        await tester.tap(find.text('Blueberry Large').last);
        await tester.pumpAndSettle();

        expect(find.text('0/1'), findsOneWidget);
      },
    );
  });
}