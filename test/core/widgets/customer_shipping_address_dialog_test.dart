import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/repositories/customer_address_repository.dart';
import 'package:jarz_pos/src/core/widgets/customer_shipping_address_dialog.dart';

Future<void> _pumpHost(
  WidgetTester tester,
  Future<Map<String, String>?>? Function() openDialog,
) async {
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
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => openDialog(),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  group('CustomerShippingAddressDialog', () {
    testWidgets(
      'should return selected saved address when saving existing selection',
      (tester) async {
        Future<Map<String, String>?>? dialogFuture;

        await _pumpHost(tester, () {
          dialogFuture = CustomerShippingAddressDialog.show(
            tester.element(find.text('open')),
            customerName: 'Jane Doe',
            customer: 'jane-doe',
            territories: const [],
            repository: CustomerAddressRepository(Dio()),
            addresses: const [
              {
                'name': 'ADDR-1',
                'full_address': 'First Address, Cairo',
                'phone': '01001',
                'is_primary_address': true,
              },
              {
                'name': 'ADDR-2',
                'full_address': 'Second Address, Giza',
                'phone': '01002',
                'is_primary_address': false,
              },
            ],
            initialSelectedAddressName: 'ADDR-1',
            initialPhone: '01001',
          );
          return dialogFuture!;
        });

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        await tester.tap(find.textContaining('Second Address, Giza'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        final result = await dialogFuture;
        expect(result?['address_name'], 'ADDR-2');
        expect(result?['phone'], '01002');
        expect(result?.containsKey('address'), isFalse);
      },
    );

    testWidgets('should return new address payload when adding a new address', (
      tester,
    ) async {
      Future<Map<String, String>?>? dialogFuture;

      await _pumpHost(tester, () {
        dialogFuture = CustomerShippingAddressDialog.show(
          tester.element(find.text('open')),
          customerName: 'Jane Doe',
          customer: 'jane-doe',
          territories: const [],
          repository: CustomerAddressRepository(Dio()),
          addresses: const [],
          initialSelectedAddressName: '',
          initialPhone: '01001',
        );
        return dialogFuture!;
      });

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Keyed, not positional: the dialog also carries a Maps-link field, so
      // `find.byType(TextField).last` no longer means "the phone field".
      await tester.enterText(
        find.byKey(CustomerShippingAddressDialog.newAddressFieldKey),
        'New Shipping Address',
      );
      await tester.enterText(
        find.byKey(CustomerShippingAddressDialog.phoneFieldKey),
        '01009',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final result = await dialogFuture;
      expect(result?['address'], 'New Shipping Address');
      expect(result?['phone'], '01009');
      expect(result?.containsKey('address_name'), isFalse);
    });

    testWidgets('requires and returns a named B2B delivery branch', (
      tester,
    ) async {
      Future<Map<String, String>?>? dialogFuture;

      await _pumpHost(tester, () {
        dialogFuture = CustomerShippingAddressDialog.show(
          tester.element(find.text('open')),
          customerName: 'ILO Specialty Coffee',
          customer: 'ilo specialty coffee',
          territories: const [
            {'name': 'EGMADINATY', 'territory_name': 'Madinaty'},
          ],
          repository: CustomerAddressRepository(Dio()),
          addresses: const [],
          initialSelectedAddressName: '',
          initialPhone: '01001',
          requireBranchName: true,
        );
        return dialogFuture!;
      });

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(CustomerShippingAddressDialog.newAddressFieldKey),
        'Madinaty All Seasons Park',
      );
      await tester.tap(find.text('Save'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Enter a delivery branch name.'), findsOneWidget);
      ScaffoldMessenger.of(
        tester.element(find.byType(AlertDialog)),
      ).hideCurrentSnackBar();
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(CustomerShippingAddressDialog.branchNameFieldKey),
        'All Seasons Park',
      );
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('Please select a territory.'), findsOneWidget);

      await tester.tap(find.text('Territory'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Madinaty').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final result = await dialogFuture;
      expect(result?['branch_name'], 'All Seasons Park');
      expect(result?['address'], 'Madinaty All Seasons Park');
    });

    testWidgets('blocks an unresolved legacy branch until it is edited', (
      tester,
    ) async {
      await _pumpHost(tester, () {
        return CustomerShippingAddressDialog.show(
          tester.element(find.text('open')),
          customerName: 'ILO Specialty Coffee',
          customer: 'ilo specialty coffee',
          territories: const [],
          repository: CustomerAddressRepository(Dio()),
          addresses: const [
            {
              'name': 'ILO-LEGACY',
              'branch_name': 'Legacy branch',
              'full_address': 'Madinaty',
              'city': 'EGMADINATY',
              'territory_missing': true,
            },
          ],
          initialSelectedAddressName: '',
          initialPhone: '01001',
          requireBranchName: true,
        );
      });

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Legacy branch'));
      await tester.pump();

      expect(
        find.text(
          'Edit this branch and choose its delivery territory before ordering.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('edit rejects a blank or unmatched B2B territory', (
      tester,
    ) async {
      await _pumpHost(tester, () {
        return CustomerShippingAddressDialog.show(
          tester.element(find.text('open')),
          customerName: 'ILO Specialty Coffee',
          customer: 'ilo specialty coffee',
          territories: const [
            {'name': 'EGMADINATY', 'territory_name': 'Madinaty'},
          ],
          repository: CustomerAddressRepository(Dio()),
          addresses: const [
            {
              'name': 'ILO-LEGACY',
              'branch_name': 'Legacy branch',
              'address_line1': 'Madinaty',
              'city': 'Unknown',
              'territory_missing': true,
            },
          ],
          initialSelectedAddressName: '',
          initialPhone: '01001',
          requireBranchName: true,
        );
      });

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit Address'));
      await tester.pump();
      final saveButton = find.widgetWithText(ElevatedButton, 'Save');
      tester.widget<ElevatedButton>(saveButton).onPressed!();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Please select a territory.'), findsOneWidget);
    });
  });
}
