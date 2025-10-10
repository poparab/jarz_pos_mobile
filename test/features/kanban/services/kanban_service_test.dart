import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/kanban/services/kanban_service.dart';
import '../../../helpers/mock_services.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  group('KanbanService - Invoice Scenarios', () {
    late MockDio mockDio;
    late KanbanService service;

    setUp(() {
      mockDio = MockDio();
      service = KanbanService(mockDio);
    });

    group('Sales Partner Invoices', () {
      test('salesPartnerUnpaidOutForDelivery - creates payment and DN for unpaid sales partner invoice', () async {
        final expectedResponse = {
          'success': true,
          'payment_entry': 'PE-001',
          'delivery_note': 'DN-001',
          'amount': '100.00',
          'invoice': 'INV-001',
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.jarz_pos.services.delivery_handling.sales_partner_unpaid_out_for_delivery',
          createSuccessResponse(data: expectedResponse),
        );

        final result = await service.salesPartnerUnpaidOutForDelivery(
          invoiceName: 'INV-001',
          posProfile: 'Main POS',
        );

        expect(result['success'], isTrue);
        expect(result['payment_entry'], equals('PE-001'));
        expect(result['delivery_note'], equals('DN-001'));
        expect(result['amount'], equals('100.00'));
      });

      test('salesPartnerUnpaidOutForDelivery - supports custom mode of payment', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.jarz_pos.services.delivery_handling.sales_partner_unpaid_out_for_delivery',
          createSuccessResponse(data: {'success': true}),
        );

        await service.salesPartnerUnpaidOutForDelivery(
          invoiceName: 'INV-001',
          posProfile: 'Main POS',
          modeOfPayment: 'Wallet',
        );

        final requests = mockDio.requestLog;
        expect(requests.last['data']['mode_of_payment'], equals('Wallet'));
      });

      test('salesPartnerUnpaidOutForDelivery - throws on error response', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.jarz_pos.services.delivery_handling.sales_partner_unpaid_out_for_delivery',
          createSuccessResponse(data: {
            'success': false,
            'error': 'Payment creation failed',
          }),
        );

        expect(
          () => service.salesPartnerUnpaidOutForDelivery(
            invoiceName: 'INV-001',
            posProfile: 'Main POS',
          ),
          throwsException,
        );
      });

      test('salesPartnerPaidOutForDelivery - creates DN for already paid sales partner invoice', () async {
        final expectedResponse = {
          'success': true,
          'delivery_note': 'DN-002',
          'invoice': 'INV-002',
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.jarz_pos.services.delivery_handling.sales_partner_paid_out_for_delivery',
          createSuccessResponse(data: expectedResponse),
        );

        final result = await service.salesPartnerPaidOutForDelivery(
          invoiceId: 'INV-002',
        );

        expect(result['success'], isTrue);
        expect(result['delivery_note'], equals('DN-002'));
      });

      test('salesPartnerPaidOutForDelivery - throws on error response', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.jarz_pos.services.delivery_handling.sales_partner_paid_out_for_delivery',
          createSuccessResponse(data: {
            'success': false,
            'error': 'Delivery note creation failed',
          }),
        );

        expect(
          () => service.salesPartnerPaidOutForDelivery(invoiceId: 'INV-002'),
          throwsException,
        );
      });
    });

    group('Pickup Invoices', () {
      test('updateInvoiceState - handles pickup invoice state changes directly', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.kanban.update_invoice_state',
          createSuccessResponse(data: {
            'success': true,
            'invoice_id': 'INV-PICKUP-001',
            'new_state': 'Ready for Pickup',
          }),
        );

        final result = await service.updateInvoiceState('INV-PICKUP-001', 'Ready for Pickup');

        expect(result, isTrue);
        final requests = mockDio.requestLog;
        expect(requests.last['data']['invoice_id'], equals('INV-PICKUP-001'));
        expect(requests.last['data']['new_state'], equals('Ready for Pickup'));
      });
    });

    group('Paid Invoices - Settle Now', () {
      test('settleCourierCollectedPayment - handles when courier collected payment from customer', () async {
        final expectedResponse = {
          'success': true,
          'journal_entry': 'JE-001',
          'net_amount': 50.00,
          'order_amount': 150.00,
          'shipping_expense': 100.00,
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.settle_courier_collected_payment',
          createSuccessResponse(data: expectedResponse),
        );

        final result = await service.settleCourierCollectedPayment(
          invoiceName: 'INV-PAID-001',
          posProfile: 'Main POS',
          partyType: 'Employee',
          party: 'EMP-001',
        );

        expect(result['success'], isTrue);
        expect(result['journal_entry'], equals('JE-001'));
        expect(result['net_amount'], equals(50.00));
      });

      test('settleSingleInvoicePaid - handles when branch pays courier shipping expense', () async {
        final expectedResponse = {
          'success': true,
          'journal_entry': 'JE-002',
          'shipping_expense': 20.00,
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.settle_single_invoice_paid',
          createSuccessResponse(data: expectedResponse),
        );

        final result = await service.settleSingleInvoicePaid(
          invoiceName: 'INV-PAID-002',
          posProfile: 'Main POS',
          partyType: 'Supplier',
          party: 'SUPP-001',
        );

        expect(result['success'], isTrue);
        expect(result['journal_entry'], equals('JE-002'));
      });

      test('settleCourierCollectedPayment - sends correct parameters', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.settle_courier_collected_payment',
          createSuccessResponse(data: {'success': true}),
        );

        await service.settleCourierCollectedPayment(
          invoiceName: 'INV-003',
          posProfile: 'Branch POS',
          partyType: 'Employee',
          party: 'EMP-002',
        );

        final requests = mockDio.requestLog;
        expect(requests.last['data']['invoice_name'], equals('INV-003'));
        expect(requests.last['data']['pos_profile'], equals('Branch POS'));
        expect(requests.last['data']['party_type'], equals('Employee'));
        expect(requests.last['data']['party'], equals('EMP-002'));
      });

      test('settleSingleInvoicePaid - throws on settlement failure', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.settle_single_invoice_paid',
          createSuccessResponse(data: {
            'error': 'Insufficient balance',
          }),
        );

        expect(
          () => service.settleSingleInvoicePaid(
            invoiceName: 'INV-004',
            posProfile: 'Main POS',
            partyType: 'Employee',
            party: 'EMP-003',
          ),
          throwsException,
        );
      });
    });

    group('Paid Invoices - Settle Later', () {
      test('handleOutForDeliveryTransition - supports settle later mode', () async {
        final expectedResponse = {
          'success': true,
          'courier_transaction': 'CT-001',
          'invoice': 'INV-PAID-LATER-001',
          'mode': 'later',
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.handle_out_for_delivery_transition',
          createSuccessResponse(data: expectedResponse),
        );

        final result = await service.handleOutForDeliveryTransition(
          invoiceName: 'INV-PAID-LATER-001',
          courier: 'COURIER-001',
          mode: 'later',
          posProfile: 'Main POS',
          idempotencyToken: 'token-123',
        );

        expect(result['success'], isTrue);
        expect(result['mode'], equals('later'));
        expect(result['courier_transaction'], equals('CT-001'));
      });

      test('handleOutForDeliveryTransition - includes optional party info for settle later', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.handle_out_for_delivery_transition',
          createSuccessResponse(data: {'success': true}),
        );

        await service.handleOutForDeliveryTransition(
          invoiceName: 'INV-005',
          courier: 'COURIER-002',
          mode: 'later',
          posProfile: 'Main POS',
          idempotencyToken: 'token-456',
          partyType: 'Employee',
          party: 'EMP-004',
        );

        final requests = mockDio.requestLog;
        expect(requests.last['data']['party_type'], equals('Employee'));
        expect(requests.last['data']['party'], equals('EMP-004'));
        expect(requests.last['data']['mode'], equals('later'));
      });
    });

    group('Unpaid Invoices - Settle Now', () {
      test('handleOutForDeliveryTransition - handles unpaid with pay_now mode', () async {
        final expectedResponse = {
          'success': true,
          'payment_entry': 'PE-002',
          'courier_transaction': 'CT-002',
          'amount': 200.00,
          'shipping_amount': 25.00,
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.handle_out_for_delivery_transition',
          createSuccessResponse(data: expectedResponse),
        );

        final result = await service.handleOutForDeliveryTransition(
          invoiceName: 'INV-UNPAID-001',
          courier: 'COURIER-003',
          mode: 'pay_now',
          posProfile: 'Main POS',
          idempotencyToken: 'token-789',
        );

        expect(result['success'], isTrue);
        expect(result['payment_entry'], equals('PE-002'));
        expect(result['courier_transaction'], equals('CT-002'));
      });

      test('markCourierOutstanding - creates payment entry for unpaid invoice', () async {
        final expectedResponse = {
          'payment_entry': 'PE-003',
          'courier_transaction': 'CT-003',
          'amount': 150.00,
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.mark_courier_outstanding',
          createSuccessResponse(data: expectedResponse),
        );

        final result = await service.markCourierOutstanding(
          invoiceName: 'INV-UNPAID-002',
          courier: 'COURIER-004',
        );

        expect(result['success'], isTrue); // Added by normalization
        expect(result['payment_entry'], equals('PE-003'));
        expect(result['courier_transaction'], equals('CT-003'));
      });

      test('markCourierOutstanding - includes party info when provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.mark_courier_outstanding',
          createSuccessResponse(data: {'payment_entry': 'PE-004'}),
        );

        await service.markCourierOutstanding(
          invoiceName: 'INV-UNPAID-003',
          courier: 'COURIER-005',
          partyType: 'Supplier',
          party: 'SUPP-002',
        );

        final requests = mockDio.requestLog;
        expect(requests.last['data']['party_type'], equals('Supplier'));
        expect(requests.last['data']['party'], equals('SUPP-002'));
      });

      test('markCourierOutstanding - handles string response as success', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.mark_courier_outstanding',
          createSuccessResponse(data: 'OK'),
        );

        final result = await service.markCourierOutstanding(
          invoiceName: 'INV-UNPAID-004',
          courier: 'COURIER-006',
        );

        expect(result['success'], isTrue);
        expect(result['message'], equals('OK'));
      });
    });

    group('Unpaid Invoices - Settle Later', () {
      test('handleOutForDeliveryTransition - handles unpaid with later mode', () async {
        final expectedResponse = {
          'success': true,
          'payment_entry': 'PE-005',
          'courier_transaction': 'CT-005',
          'mode': 'later',
          'deferred': true,
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.handle_out_for_delivery_transition',
          createSuccessResponse(data: expectedResponse),
        );

        final result = await service.handleOutForDeliveryTransition(
          invoiceName: 'INV-UNPAID-LATER-001',
          courier: 'COURIER-007',
          mode: 'later',
          posProfile: 'Main POS',
          idempotencyToken: 'token-abc',
        );

        expect(result['success'], isTrue);
        expect(result['mode'], equals('later'));
        expect(result['payment_entry'], equals('PE-005'));
      });
    });

    group('Settlement Preview', () {
      test('getInvoiceSettlementPreview - returns preview data for invoice', () async {
        final expectedPreview = {
          'invoice_name': 'INV-001',
          'outstanding': 100.00,
          'shipping_expense': 20.00,
          'net_amount': 80.00,
          'party_type': 'Employee',
          'party': 'EMP-001',
          'last_payment_seconds': 5,
          'is_unpaid_effective': false,
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.get_invoice_settlement_preview',
          createSuccessResponse(data: expectedPreview),
        );

        final result = await service.getInvoiceSettlementPreview(
          invoiceName: 'INV-001',
        );

        expect(result['invoice_name'], equals('INV-001'));
        expect(result['outstanding'], equals(100.00));
        expect(result['net_amount'], equals(80.00));
      });

      test('getInvoiceSettlementPreview - includes party info when provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.get_invoice_settlement_preview',
          createSuccessResponse(data: {}),
        );

        await service.getInvoiceSettlementPreview(
          invoiceName: 'INV-002',
          partyType: 'Supplier',
          party: 'SUPP-001',
        );

        final requests = mockDio.requestLog;
        expect(requests.last['queryParameters']?['party_type'], equals('Supplier'));
        expect(requests.last['queryParameters']?['party'], equals('SUPP-001'));
      });

      test('getInvoiceSettlementPreview - throws on invalid response', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.get_invoice_settlement_preview',
          createSuccessResponse(data: null),
        );

        expect(
          () => service.getInvoiceSettlementPreview(invoiceName: 'INV-003'),
          throwsException,
        );
      });
    });

    group('Courier Management', () {
      test('fetchCouriers - returns list of active couriers', () async {
        final couriersData = [
          {
            'party_type': 'Employee',
            'party': 'EMP-001',
            'display_name': 'John Courier',
            'branch': 'Main Branch',
          },
          {
            'party_type': 'Supplier',
            'party': 'SUPP-001',
            'display_name': 'Fast Delivery Inc',
          },
        ];

        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.get_active_couriers',
          createSuccessResponse(data: couriersData),
        );

        final result = await service.fetchCouriers();

        expect(result, hasLength(2));
        expect(result[0]['party_type'], equals('Employee'));
        expect(result[0]['display_name'], equals('John Courier'));
        expect(result[0]['courier_name'], equals('John Courier')); // Legacy key
        expect(result[1]['party_type'], equals('Supplier'));
      });

      test('createDeliveryParty - creates new courier party', () async {
        final expectedResponse = {
          'party_type': 'Employee',
          'party': 'EMP-NEW-001',
          'display_name': 'New Courier',
          'phone': '1234567890',
          'branch': 'Branch A',
        };

        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.create_delivery_party',
          createSuccessResponse(data: expectedResponse),
        );

        final result = await service.createDeliveryParty(
          partyType: 'Employee',
          name: 'New Courier',
          phone: '1234567890',
          posProfile: 'Branch A POS',
        );

        expect(result['party_type'], equals('Employee'));
        expect(result['party'], equals('EMP-NEW-001'));
        expect(result['display_name'], equals('New Courier'));
      });

      test('createDeliveryParty - supports first/last name', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.create_delivery_party',
          createSuccessResponse(data: {
            'party_type': 'Employee',
            'party': 'EMP-002',
            'display_name': 'Jane Doe',
          }),
        );

        await service.createDeliveryParty(
          partyType: 'Employee',
          firstName: 'Jane',
          lastName: 'Doe',
          phone: '9876543210',
        );

        final requests = mockDio.requestLog;
        expect(requests.last['data']['first_name'], equals('Jane'));
        expect(requests.last['data']['last_name'], equals('Doe'));
      });
    });

    group('Idempotency', () {
      test('generateIdempotencyToken - creates unique tokens', () {
        final token1 = service.generateIdempotencyToken();
        final token2 = service.generateIdempotencyToken();

        expect(token1, isNotEmpty);
        expect(token2, isNotEmpty);
        expect(token1, isNot(equals(token2)));
        expect(token1, startsWith('ofd-'));
      });

      test('handleOutForDeliveryTransition - uses provided idempotency token', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.handle_out_for_delivery_transition',
          createSuccessResponse(data: {'success': true}),
        );

        const customToken = 'custom-token-12345';
        await service.handleOutForDeliveryTransition(
          invoiceName: 'INV-006',
          courier: 'COURIER-008',
          mode: 'pay_now',
          posProfile: 'Main POS',
          idempotencyToken: customToken,
        );

        final requests = mockDio.requestLog;
        expect(requests.last['data']['idempotency_token'], equals(customToken));
      });
    });

    group('Error Handling', () {
      test('throws exception on network error', () async {
        mockDio.setError(
          '/api/method/jarz_pos.api.couriers.settle_single_invoice_paid',
          createMockDioException(message: 'Network timeout'),
        );

        expect(
          () => service.settleSingleInvoicePaid(
            invoiceName: 'INV-ERR-001',
            posProfile: 'Main POS',
            partyType: 'Employee',
            party: 'EMP-001',
          ),
          throwsA(isA<DioException>()),
        );
      });

      test('handles API errors gracefully', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.handle_out_for_delivery_transition',
          createSuccessResponse(data: {
            'success': false,
            'error': 'Invoice already processed',
          }),
        );

        expect(
          () => service.handleOutForDeliveryTransition(
            invoiceName: 'INV-ERR-002',
            courier: 'COURIER-009',
            mode: 'pay_now',
            posProfile: 'Main POS',
            idempotencyToken: 'token-err',
          ),
          throwsException,
        );
      });
    });
  });
}
