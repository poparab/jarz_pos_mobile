import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import '../../../helpers/mock_services.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  group('PosRepository - Bundle, Discount & Delivery Charges', () {
    late MockDio mockDio;
    late PosRepository repository;

    setUp(() {
      mockDio = MockDio();
      repository = PosRepository(mockDio);
    });

    // ---------------------------------------------------------------
    // Bundle Items
    // ---------------------------------------------------------------
    group('Bundle Item Creation', () {
      test('bundle item sends is_bundle true and selected_items map', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-BUNDLE-001'}),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {
              'type': 'bundle',
              'bundle_details': {
                'bundle_id': 'BUNDLE-MEAL',
                'selected_items': {
                  'Main Course': [
                    {'id': 'ITEM-BURGER', 'item_name': 'Burger'},
                  ],
                  'Side': [
                    {'id': 'ITEM-FRIES', 'item_name': 'Fries'},
                  ],
                },
              },
              'quantity': 1,
              'rate': 120.0,
            },
          ],
        );

        final req = mockDio.requestLog.last;
        final cartJson = jsonDecode(req['data']['cart_json']) as List;
        expect(cartJson.length, 1);

        final bundle = cartJson[0];
        expect(bundle['item_code'], equals('BUNDLE-MEAL'));
        expect(bundle['is_bundle'], isTrue);
        expect(bundle['qty'], equals(1));
        expect(bundle['rate'], equals(120.0));

        // Verify selected_items structure
        final selections = bundle['selected_items'] as Map<String, dynamic>;
        expect(selections.containsKey('Main Course'), isTrue);
        expect(selections.containsKey('Side'), isTrue);
        expect(
          (selections['Main Course'] as List).first['id'],
          equals('ITEM-BURGER'),
        );
        expect((selections['Side'] as List).first['id'], equals('ITEM-FRIES'));
      });

      test('bundle with multiple selections per group', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-BUNDLE-002'}),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {
              'type': 'bundle',
              'bundle_details': {
                'bundle_id': 'BUNDLE-FAMILY',
                'selected_items': {
                  'Drinks': [
                    {'id': 'DRINK-COLA', 'item_name': 'Cola'},
                    {'id': 'DRINK-JUICE', 'item_name': 'Juice'},
                  ],
                },
              },
              'quantity': 2,
              'rate': 200.0,
            },
          ],
        );

        final cartJson =
            jsonDecode(mockDio.requestLog.last['data']['cart_json']) as List;
        final selections =
            cartJson[0]['selected_items'] as Map<String, dynamic>;
        expect((selections['Drinks'] as List).length, equals(2));
      });

      test('bundle qty is sent correctly', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-BUNDLE-QTY'}),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {
              'type': 'bundle',
              'bundle_details': {
                'bundle_id': 'BUNDLE-DUO',
                'selected_items': {
                  'Item': [
                    {'id': 'A1', 'item_name': 'Item A'},
                  ],
                },
              },
              'quantity': 3,
              'rate': 150.0,
            },
          ],
        );

        final cartJson =
            jsonDecode(mockDio.requestLog.last['data']['cart_json']) as List;
        expect(cartJson[0]['qty'], equals(3));
      });
    });

    // ---------------------------------------------------------------
    // Mixed Cart (regular items + bundles)
    // ---------------------------------------------------------------
    group('Mixed Cart', () {
      test('cart with both regular items and bundles', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-MIXED'}),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-REG', 'quantity': 2, 'rate': 50.0},
            {
              'type': 'bundle',
              'bundle_details': {
                'bundle_id': 'BUNDLE-X',
                'selected_items': {
                  'Group': [
                    {'id': 'BX-1', 'item_name': 'Sub Item'},
                  ],
                },
              },
              'quantity': 1,
              'rate': 300.0,
            },
          ],
        );

        final cartJson =
            jsonDecode(mockDio.requestLog.last['data']['cart_json']) as List;
        expect(cartJson.length, equals(2));

        // Regular item
        expect(cartJson[0]['item_code'], equals('ITEM-REG'));
        expect(cartJson[0]['is_bundle'], isFalse);

        // Bundle item
        expect(cartJson[1]['item_code'], equals('BUNDLE-X'));
        expect(cartJson[1]['is_bundle'], isTrue);
      });
    });

    // ---------------------------------------------------------------
    // Discount Fields Transmission
    // ---------------------------------------------------------------
    group('Discount Fields', () {
      test('discount_percentage preserved in cart_json', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-DISC-PCT'}),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {
              'item_code': 'ITEM-D1',
              'quantity': 1,
              'rate': 80.0,
              'price_list_rate': 100.0,
              'discount_percentage': 20.0,
            },
          ],
        );

        final cartJson =
            jsonDecode(mockDio.requestLog.last['data']['cart_json']) as List;
        expect(cartJson[0]['price_list_rate'], equals(100.0));
        expect(cartJson[0]['discount_percentage'], equals(20.0));
      });

      test('discount_amount preserved in cart_json', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-DISC-AMT'}),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {
              'item_code': 'ITEM-D2',
              'quantity': 1,
              'rate': 160.0,
              'price_list_rate': 200.0,
              'discount_amount': 40.0,
            },
          ],
        );

        final cartJson =
            jsonDecode(mockDio.requestLog.last['data']['cart_json']) as List;
        expect(cartJson[0]['price_list_rate'], equals(200.0));
        expect(cartJson[0]['discount_amount'], equals(40.0));
      });

      test('no discount fields when not provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-NO-DISC'}),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-FULL', 'quantity': 1, 'rate': 100.0},
          ],
        );

        final cartJson =
            jsonDecode(mockDio.requestLog.last['data']['cart_json']) as List;
        expect(cartJson[0].containsKey('discount_percentage'), isFalse);
        expect(cartJson[0].containsKey('discount_amount'), isFalse);
        expect(cartJson[0].containsKey('price_list_rate'), isFalse);
      });

      test(
        'both discount_percentage and discount_amount can coexist',
        () async {
          mockDio.setResponse(
            '/api/method/jarz_pos.api.invoices.create_pos_invoice',
            createSuccessResponse(data: {'name': 'INV-DISC-BOTH'}),
          );

          await repository.createInvoice(
            posProfile: 'Main POS',
            items: [
              {
                'item_code': 'ITEM-D3',
                'quantity': 2,
                'rate': 80.0,
                'price_list_rate': 100.0,
                'discount_percentage': 20.0,
                'discount_amount': 20.0,
              },
            ],
          );

          final cartJson =
              jsonDecode(mockDio.requestLog.last['data']['cart_json']) as List;
          expect(cartJson[0]['discount_percentage'], equals(20.0));
          expect(cartJson[0]['discount_amount'], equals(20.0));
          expect(cartJson[0]['price_list_rate'], equals(100.0));
        },
      );
    });

    // ---------------------------------------------------------------
    // Delivery Charges JSON
    // ---------------------------------------------------------------
    group('Delivery Charges JSON', () {
      test(
        'delivery_charges_json sent when customer has delivery_income',
        () async {
          mockDio.setResponse(
            '/api/method/jarz_pos.api.invoices.create_pos_invoice',
            createSuccessResponse(data: {'name': 'INV-DEL-001'}),
          );

          await repository.createInvoice(
            posProfile: 'Main POS',
            items: [
              {'item_code': 'ITEM-A', 'quantity': 1, 'rate': 50.0},
            ],
            customer: {
              'name': 'CUST-001',
              'delivery_income': 30.0,
              'territory': 'Cairo',
            },
          );

          final req = mockDio.requestLog.last;
          expect(req['data'].containsKey('delivery_charges_json'), isTrue);

          final charges =
              jsonDecode(req['data']['delivery_charges_json']) as List;
          expect(charges.length, equals(1));
          expect(charges[0]['charge_type'], equals('Delivery'));
          expect(charges[0]['amount'], equals(30.0));
          expect(charges[0]['description'], contains('Cairo'));
        },
      );

      test(
        'delivery_charges_json NOT sent when sales partner active',
        () async {
          mockDio.setResponse(
            '/api/method/jarz_pos.api.invoices.create_pos_invoice',
            createSuccessResponse(data: {'name': 'INV-DEL-PARTNER'}),
          );

          await repository.createInvoice(
            posProfile: 'Main POS',
            items: [
              {'item_code': 'ITEM-A', 'quantity': 1, 'rate': 50.0},
            ],
            customer: {
              'name': 'CUST-002',
              'delivery_income': 30.0,
              'territory': 'Cairo',
            },
            salesPartner: 'PARTNER-A',
          );

          final req = mockDio.requestLog.last;
          expect(
            req['data'].containsKey('delivery_charges_json'),
            isFalse,
            reason: 'Sales partner should suppress delivery charges',
          );
        },
      );

      test(
        'delivery_charges_json NOT sent when delivery_income is zero',
        () async {
          mockDio.setResponse(
            '/api/method/jarz_pos.api.invoices.create_pos_invoice',
            createSuccessResponse(data: {'name': 'INV-DEL-ZERO'}),
          );

          await repository.createInvoice(
            posProfile: 'Main POS',
            items: [
              {'item_code': 'ITEM-A', 'quantity': 1, 'rate': 50.0},
            ],
            customer: {
              'name': 'CUST-003',
              'delivery_income': 0,
              'territory': 'Cairo',
            },
          );

          final req = mockDio.requestLog.last;
          expect(req['data'].containsKey('delivery_charges_json'), isFalse);
        },
      );

      test(
        'delivery_charges_json NOT sent when delivery_income is null',
        () async {
          mockDio.setResponse(
            '/api/method/jarz_pos.api.invoices.create_pos_invoice',
            createSuccessResponse(data: {'name': 'INV-DEL-NULL'}),
          );

          await repository.createInvoice(
            posProfile: 'Main POS',
            items: [
              {'item_code': 'ITEM-A', 'quantity': 1, 'rate': 50.0},
            ],
            customer: {'name': 'CUST-004', 'territory': 'Cairo'},
          );

          final req = mockDio.requestLog.last;
          expect(req['data'].containsKey('delivery_charges_json'), isFalse);
        },
      );

      test('delivery_charges_json NOT sent when no customer', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-DEL-NO-CUST'}),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-A', 'quantity': 1, 'rate': 50.0},
          ],
        );

        final req = mockDio.requestLog.last;
        expect(req['data'].containsKey('delivery_charges_json'), isFalse);
      });

      test('delivery_charges_json description includes territory', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-DEL-TERR'}),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-A', 'quantity': 1, 'rate': 50.0},
          ],
          customer: {
            'name': 'CUST-005',
            'delivery_income': 45.0,
            'territory': 'Maadi',
          },
        );

        final charges =
            jsonDecode(mockDio.requestLog.last['data']['delivery_charges_json'])
                as List;
        expect(charges[0]['description'], contains('Maadi'));
      });

      test(
        'delivery_charges_json uses selected shipping address territory',
        () async {
          mockDio.setResponse(
            '/api/method/jarz_pos.api.invoices.create_pos_invoice',
            createSuccessResponse(data: {'name': 'INV-DEL-ADDR'}),
          );

          await repository.createInvoice(
            posProfile: 'Nasr city',
            items: [
              {'item_code': 'ITEM-A', 'quantity': 1, 'rate': 50.0},
            ],
            customer: {
              'name': 'CUST-007',
              'delivery_income': 45.0,
              'territory': 'EGHADAYEQAH',
              'selected_shipping_address_name': 'ADDR-NSR',
              'selected_shipping_address_territory': 'EGNASRCITY',
              'selected_shipping_address_delivery_income': 50.0,
            },
          );

          final req = mockDio.requestLog.last;
          expect(req['data']['shipping_address_name'], 'ADDR-NSR');
          final charges =
              jsonDecode(req['data']['delivery_charges_json']) as List;
          expect(charges[0]['amount'], 50.0);
          expect(charges[0]['description'], contains('EGNASRCITY'));
        },
      );

      test(
        'delivery_charges_json uses Unknown Territory when territory missing',
        () async {
          mockDio.setResponse(
            '/api/method/jarz_pos.api.invoices.create_pos_invoice',
            createSuccessResponse(data: {'name': 'INV-DEL-NO-TERR'}),
          );

          await repository.createInvoice(
            posProfile: 'Main POS',
            items: [
              {'item_code': 'ITEM-A', 'quantity': 1, 'rate': 50.0},
            ],
            customer: {'name': 'CUST-006', 'delivery_income': 20.0},
          );

          final charges =
              jsonDecode(
                    mockDio.requestLog.last['data']['delivery_charges_json'],
                  )
                  as List;
          expect(charges[0]['description'], contains('Unknown Territory'));
        },
      );
    });

    // ---------------------------------------------------------------
    // Payment Method Field
    // ---------------------------------------------------------------
    group('Payment Method', () {
      test('payment_method sent when provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-PM-001'}),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-A', 'quantity': 1, 'rate': 50.0},
          ],
          paymentMethod: 'Cash',
        );

        expect(
          mockDio.requestLog.last['data']['payment_method'],
          equals('Cash'),
        );
      });

      test('payment_method not sent when null', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-PM-NULL'}),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-A', 'quantity': 1, 'rate': 50.0},
          ],
        );

        expect(
          mockDio.requestLog.last['data'].containsKey('payment_method'),
          isFalse,
        );
      });

      test('payment_method Instapay', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-PM-INSTA'}),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-A', 'quantity': 1, 'rate': 50.0},
          ],
          paymentMethod: 'Instapay',
        );

        expect(
          mockDio.requestLog.last['data']['payment_method'],
          equals('Instapay'),
        );
      });

      test('payment_method Mobile Wallet', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-PM-WALLET'}),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-A', 'quantity': 1, 'rate': 50.0},
          ],
          paymentMethod: 'Mobile Wallet',
        );

        expect(
          mockDio.requestLog.last['data']['payment_method'],
          equals('Mobile Wallet'),
        );
      });
    });

    // ---------------------------------------------------------------
    // Customer Name Fallback
    // ---------------------------------------------------------------
    group('Customer Name Handling', () {
      test('customer name sent from customer map', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-CUST-NAME'}),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-A', 'quantity': 1, 'rate': 50.0},
          ],
          customer: {'name': 'CUST-SPECIFIC'},
        );

        expect(
          mockDio.requestLog.last['data']['customer_name'],
          equals('CUST-SPECIFIC'),
        );
      });

      test('defaults to Walking Customer when no customer', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-WALK'}),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-A', 'quantity': 1, 'rate': 50.0},
          ],
        );

        expect(
          mockDio.requestLog.last['data']['customer_name'],
          equals('Walking Customer'),
        );
      });
    });

    // ---------------------------------------------------------------
    // POS Profile Name
    // ---------------------------------------------------------------
    group('POS Profile', () {
      test('pos_profile_name is sent correctly', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {'name': 'INV-PROFILE'}),
        );

        await repository.createInvoice(
          posProfile: 'Branch Cairo POS',
          items: [
            {'item_code': 'ITEM-A', 'quantity': 1, 'rate': 50.0},
          ],
        );

        expect(
          mockDio.requestLog.last['data']['pos_profile_name'],
          equals('Branch Cairo POS'),
        );
      });
    });
  });
}
