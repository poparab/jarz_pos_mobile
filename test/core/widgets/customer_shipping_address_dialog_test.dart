import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/repositories/customer_address_repository.dart';
import 'package:jarz_pos/src/core/widgets/customer_shipping_address_dialog.dart';

Future<void> _pumpHost(WidgetTester tester, Future<Map<String, String>?>? Function() openDialog) async {
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
    testWidgets('should return selected saved address when saving existing selection', (tester) async {
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

      await tester.tap(find.text('Second Address, Giza'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final result = await dialogFuture;
      expect(result?['address_name'], 'ADDR-2');
      expect(result?['phone'], '01002');
      expect(result?.containsKey('address'), isFalse);
    });

    testWidgets('should return new address payload when adding a new address', (tester) async {
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

      await tester.enterText(find.byType(TextField).first, 'New Shipping Address');
      await tester.enterText(find.byType(TextField).last, '01009');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final result = await dialogFuture;
      expect(result?['address'], 'New Shipping Address');
      expect(result?['phone'], '01009');
      expect(result?.containsKey('address_name'), isFalse);
    });
  });
}