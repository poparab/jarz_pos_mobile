import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import '../../../helpers/mock_services.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  group('PosRepository - Invoice Creation Scenarios', () {
    late MockDio mockDio;
    late PosRepository repository;

    setUp(() {
      mockDio = MockDio();
      repository = PosRepository(mockDio);
    });

    group('Sales Partner Invoices', () {
      test('createInvoice - creates invoice with sales partner', () async {
        final items = [
          {
            'item_code': 'ITEM-001',
            'quantity': 2,
            'rate': 50.0,
            'amount': 100.0,
          },
        ];

        final expectedResponse = {
          'name': 'INV-PARTNER-001',
          'sales_partner': 'PARTNER-A',
          'grand_total': 100.0,
          'status': 'Draft',
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: expectedResponse),
        );

        final result = await repository.createInvoice(
          posProfile: 'Main POS',
          items: items,
          salesPartner: 'PARTNER-A',
        );

        expect(result['name'], equals('INV-PARTNER-001'));
        expect(result['sales_partner'], equals('PARTNER-A'));
        
        final requests = mockDio.requestLog;
        expect(requests.last['data']['sales_partner'], equals('PARTNER-A'));
      });

      test('createInvoice - sales partner invoice can be paid or unpaid', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-PARTNER-002',
            'sales_partner': 'PARTNER-B',
          }),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-001', 'quantity': 1, 'rate': 50.0},
          ],
          salesPartner: 'PARTNER-B',
          paymentType: 'cash', // Advisory - backend determines if paid immediately
        );

        final requests = mockDio.requestLog;
        expect(requests.last['data']['payment_type'], equals('cash'));
      });
    });

    group('Pickup Invoices', () {
      test('createInvoice - creates pickup invoice with isPickup flag', () async {
        final items = [
          {
            'item_code': 'ITEM-002',
            'quantity': 1,
            'rate': 75.0,
            'amount': 75.0,
          },
        ];

        final expectedResponse = {
          'name': 'INV-PICKUP-001',
          'pickup': 1,
          'grand_total': 75.0,
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: expectedResponse),
        );

        final result = await repository.createInvoice(
          posProfile: 'Main POS',
          items: items,
          isPickup: true,
        );

        expect(result['name'], equals('INV-PICKUP-001'));
        expect(result['pickup'], equals(1));
        
        final requests = mockDio.requestLog;
        expect(requests.last['data']['pickup'], equals(1));
      });

      test('createInvoice - pickup invoices do not require courier', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-PICKUP-002',
            'pickup': 1,
          }),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-003', 'quantity': 2, 'rate': 30.0},
          ],
          isPickup: true,
        );

        final requests = mockDio.requestLog;
        expect(requests.last['data']['pickup'], equals(1));
        // No courier field should be sent
        expect(requests.last['data'].containsKey('courier'), isFalse);
      });
    });

    group('Payment Type - Cash vs Online', () {
      test('createInvoice - supports cash payment type indicator', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-CASH-001',
            'payment_type': 'cash',
          }),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-004', 'quantity': 1, 'rate': 100.0},
          ],
          paymentType: 'cash',
        );

        final requests = mockDio.requestLog;
        expect(requests.last['data']['payment_type'], equals('cash'));
      });

      test('createInvoice - supports online payment type indicator', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-ONLINE-001',
            'payment_type': 'online',
          }),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-005', 'quantity': 3, 'rate': 25.0},
          ],
          paymentType: 'online',
        );

        final requests = mockDio.requestLog;
        expect(requests.last['data']['payment_type'], equals('online'));
      });

      test('createInvoice - payment type is optional', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-NO-PAYMENT-TYPE',
          }),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-006', 'quantity': 1, 'rate': 50.0},
          ],
          // No payment type specified
        );

        final requests = mockDio.requestLog;
        expect(requests.last['data'].containsKey('payment_type'), isFalse);
      });
    });

    group('Invoice Payment - Paid vs Unpaid', () {
      test('payInvoice - pays unpaid invoice with cash', () async {
        final expectedResponse = {
          'payment_entry': 'PE-CASH-001',
          'invoice_name': 'INV-UNPAID-001',
          'paid_amount': 150.0,
          'status': 'Paid',
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.pay_invoice',
          createSuccessResponse(data: expectedResponse),
        );

        final result = await repository.payInvoice(
          invoiceName: 'INV-UNPAID-001',
          paymentMode: 'cash',
          posProfile: 'Main POS',
        );

        expect(result['payment_entry'], equals('PE-CASH-001'));
        expect(result['status'], equals('Paid'));
        
        final requests = mockDio.requestLog;
        expect(requests.last['data']['payment_mode'], equals('cash'));
        expect(requests.last['data']['pos_profile'], equals('Main POS'));
      });

      test('payInvoice - pays unpaid invoice with wallet', () async {
        final expectedResponse = {
          'payment_entry': 'PE-WALLET-001',
          'invoice_name': 'INV-UNPAID-002',
          'paid_amount': 200.0,
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.pay_invoice',
          createSuccessResponse(data: expectedResponse),
        );

        final result = await repository.payInvoice(
          invoiceName: 'INV-UNPAID-002',
          paymentMode: 'wallet',
          referenceNo: 'REF-WALLET-001',
          referenceDate: '2024-01-15',
        );

        expect(result['payment_entry'], equals('PE-WALLET-001'));
        
        final requests = mockDio.requestLog;
        expect(requests.last['data']['payment_mode'], equals('wallet'));
        expect(requests.last['data']['reference_no'], equals('REF-WALLET-001'));
        expect(requests.last['data']['reference_date'], equals('2024-01-15'));
      });

      test('payInvoice - pays unpaid invoice with instapay', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.pay_invoice',
          createSuccessResponse(data: {
            'payment_entry': 'PE-INSTAPAY-001',
          }),
        );

        await repository.payInvoice(
          invoiceName: 'INV-UNPAID-003',
          paymentMode: 'instapay',
          referenceNo: 'REF-INSTAPAY-001',
          referenceDate: '2024-01-16',
        );

        final requests = mockDio.requestLog;
        expect(requests.last['data']['payment_mode'], equals('instapay'));
      });

      test('payInvoice - throws exception when payment fails', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.pay_invoice',
          createSuccessResponse(data: null),
        );

        expect(
          () => repository.payInvoice(
            invoiceName: 'INV-FAIL',
            paymentMode: 'cash',
          ),
          throwsException,
        );
      });
    });

    group('Combined Scenarios - Real World Use Cases', () {
      test('Scenario 1: Paid + Settle Now - Regular delivery with immediate payment', () async {
        // Step 1: Create invoice with cash payment
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-SCENARIO-1',
            'grand_total': 120.0,
          }),
        );

        final invoice = await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-007', 'quantity': 1, 'rate': 120.0},
          ],
          paymentType: 'cash',
        );

        expect(invoice['name'], equals('INV-SCENARIO-1'));

        // Step 2: Pay invoice
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.pay_invoice',
          createSuccessResponse(data: {
            'payment_entry': 'PE-001',
            'status': 'Paid',
          }),
        );

        final payment = await repository.payInvoice(
          invoiceName: 'INV-SCENARIO-1',
          paymentMode: 'cash',
          posProfile: 'Main POS',
        );

        expect(payment['status'], equals('Paid'));
        // Now ready for courier assignment and immediate settlement
      });

      test('Scenario 2: Paid + Settle Later - Pre-paid online order', () async {
        // Step 1: Create invoice marked as online payment
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-SCENARIO-2',
            'payment_type': 'online',
          }),
        );

        final invoice = await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-008', 'quantity': 2, 'rate': 60.0},
          ],
          paymentType: 'online',
        );

        // Step 2: Register online payment
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.pay_invoice',
          createSuccessResponse(data: {
            'payment_entry': 'PE-WALLET-002',
            'status': 'Paid',
          }),
        );

        final payment = await repository.payInvoice(
          invoiceName: 'INV-SCENARIO-2',
          paymentMode: 'wallet',
          referenceNo: 'WALLET-REF-123',
          referenceDate: '2024-01-20',
        );

        expect(payment['status'], equals('Paid'));
        // Settlement will be deferred (settle later)
      });

      test('Scenario 3: Unpaid + Settle Now - COD with immediate courier dispatch', () async {
        // Create unpaid invoice
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-SCENARIO-3',
            'status': 'Unpaid',
          }),
        );

        final invoice = await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-009', 'quantity': 1, 'rate': 200.0},
          ],
        );

        expect(invoice['status'], equals('Unpaid'));
        // Backend will create Payment Entry during OFD transition with pay_now mode
      });

      test('Scenario 4: Unpaid + Settle Later - COD with deferred settlement', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-SCENARIO-4',
            'status': 'Unpaid',
          }),
        );

        final invoice = await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-010', 'quantity': 3, 'rate': 45.0},
          ],
        );

        expect(invoice['status'], equals('Unpaid'));
        // Backend will handle Payment Entry during settle later flow
      });

      test('Scenario 5: Sales Partner - Special handling', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-SCENARIO-5',
            'sales_partner': 'PARTNER-X',
            'status': 'Unpaid',
          }),
        );

        final invoice = await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-011', 'quantity': 5, 'rate': 20.0},
          ],
          salesPartner: 'PARTNER-X',
        );

        expect(invoice['sales_partner'], equals('PARTNER-X'));
        // Sales partner invoices use dedicated backend endpoints
      });

      test('Scenario 6: Pickup - No courier settlement', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-SCENARIO-6',
            'pickup': 1,
          }),
        );

        final invoice = await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-012', 'quantity': 2, 'rate': 35.0},
          ],
          isPickup: true,
        );

        expect(invoice['pickup'], equals(1));
        // Pickup orders transition through states without courier settlement
      });
    });

    group('Delivery Scheduling', () {
      test('createInvoice - includes required delivery datetime for scheduled orders', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-SCHEDULED-001',
            'required_delivery_datetime': '2024-02-01 14:00:00',
          }),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-013', 'quantity': 1, 'rate': 90.0},
          ],
          requiredDeliveryDatetime: '2024-02-01 14:00:00',
        );

        final requests = mockDio.requestLog;
        expect(
          requests.last['data']['required_delivery_datetime'],
          equals('2024-02-01 14:00:00'),
        );
      });
    });

    group('Customer Association', () {
      test('createInvoice - includes customer information', () async {
        final customer = {
          'name': 'CUST-001',
          'customer_name': 'John Doe',
          'territory': 'Metro',
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-WITH-CUSTOMER',
            'customer': 'CUST-001',
          }),
        );

        await repository.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-014', 'quantity': 1, 'rate': 55.0},
          ],
          customer: customer,
        );

        final requests = mockDio.requestLog;
        expect(requests.last['data']['customer_name'], equals('CUST-001'));
      });
    });
  });
}
