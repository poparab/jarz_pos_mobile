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
  });
}