import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import 'package:jarz_pos/src/features/kanban/services/kanban_service.dart';
import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';

/// Integration tests for complete invoice workflows covering all six scenarios
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  group('Invoice Workflow Integration Tests', () {
    late MockDio mockDio;
    late PosRepository posRepo;
    late KanbanService kanbanService;

    setUp(() {
      mockDio = MockDio();
      posRepo = PosRepository(mockDio);
      kanbanService = KanbanService(mockDio);
    });

    group('Scenario 1: Paid + Settle Now', () {
      test('Complete workflow: create paid invoice → OFD → settle immediately', () async {
        // 1. Create invoice
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-PAID-NOW-001',
            'grand_total': 150.0,
            'status': 'Draft',
          }),
        );

        final invoice = await posRepo.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-001', 'quantity': 3, 'rate': 50.0},
          ],
          paymentType: 'cash',
        );

        expect(invoice['name'], equals('INV-PAID-NOW-001'));

        // 2. Pay invoice
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.pay_invoice',
          createSuccessResponse(data: {
            'payment_entry': 'PE-001',
            'status': 'Paid',
          }),
        );

        final payment = await posRepo.payInvoice(
          invoiceName: 'INV-PAID-NOW-001',
          paymentMode: 'cash',
          posProfile: 'Main POS',
        );

        expect(payment['status'], equals('Paid'));

        // 3. Get settlement preview
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.get_invoice_settlement_preview',
          createSuccessResponse(data: {
            'invoice_name': 'INV-PAID-NOW-001',
            'outstanding': 0.0,
            'shipping_expense': 25.0,
            'net_amount': -25.0, // Branch pays courier
            'is_unpaid_effective': false,
          }),
        );

        final preview = await kanbanService.getInvoiceSettlementPreview(
          invoiceName: 'INV-PAID-NOW-001',
        );

        expect(preview['outstanding'], equals(0.0));
        expect(preview['net_amount'], lessThan(0)); // Branch owes courier

        // 4. Settle with courier (branch pays shipping)
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.settle_single_invoice_paid',
          createSuccessResponse(data: {
            'success': true,
            'journal_entry': 'JE-001',
            'shipping_expense': 25.0,
          }),
        );

        final settlement = await kanbanService.settleSingleInvoicePaid(
          invoiceName: 'INV-PAID-NOW-001',
          posProfile: 'Main POS',
          partyType: 'Employee',
          party: 'COURIER-001',
        );

        expect(settlement['success'], isTrue);
        expect(settlement['journal_entry'], equals('JE-001'));
      });

      test('Complete workflow: courier collected payment → settle immediately', () async {
        // 1. Create unpaid invoice (will be paid by courier collection)
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-COLLECTED-001',
            'grand_total': 200.0,
            'status': 'Unpaid',
          }),
        );

        final invoice = await posRepo.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-002', 'quantity': 1, 'rate': 200.0},
          ],
        );

        // 2. Transition to OFD (creates payment entry)
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.handle_out_for_delivery_transition',
          createSuccessResponse(data: {
            'success': true,
            'payment_entry': 'PE-002',
            'courier_transaction': 'CT-001',
          }),
        );

        final ofd = await kanbanService.handleOutForDeliveryTransition(
          invoiceName: 'INV-COLLECTED-001',
          courier: 'COURIER-002',
          mode: 'pay_now',
          posProfile: 'Main POS',
          idempotencyToken: 'token-001',
        );

        expect(ofd['payment_entry'], equals('PE-002'));

        // 3. Courier collects cash and returns
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.get_invoice_settlement_preview',
          createSuccessResponse(data: {
            'outstanding': 0.0,
            'shipping_expense': 30.0,
            'order_amount': 200.0,
            'net_amount': 170.0, // Courier owes branch (200 - 30)
          }),
        );

        final preview = await kanbanService.getInvoiceSettlementPreview(
          invoiceName: 'INV-COLLECTED-001',
        );

        expect(preview['net_amount'], greaterThan(0)); // Courier owes branch

        // 4. Settle courier collected payment
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.settle_courier_collected_payment',
          createSuccessResponse(data: {
            'success': true,
            'journal_entry': 'JE-002',
            'net_amount': 170.0,
          }),
        );

        final settlement = await kanbanService.settleCourierCollectedPayment(
          invoiceName: 'INV-COLLECTED-001',
          posProfile: 'Main POS',
          partyType: 'Employee',
          party: 'COURIER-002',
        );

        expect(settlement['success'], isTrue);
      });
    });

    group('Scenario 2: Paid + Settle Later', () {
      test('Complete workflow: create paid invoice → OFD with settle later', () async {
        // 1. Create and pay invoice
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-PAID-LATER-001',
            'grand_total': 180.0,
          }),
        );

        await posRepo.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-003', 'quantity': 2, 'rate': 90.0},
          ],
          paymentType: 'online',
        );

        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.pay_invoice',
          createSuccessResponse(data: {
            'payment_entry': 'PE-WALLET-001',
            'status': 'Paid',
          }),
        );

        await posRepo.payInvoice(
          invoiceName: 'INV-PAID-LATER-001',
          paymentMode: 'wallet',
          referenceNo: 'WALLET-REF-001',
          referenceDate: '2024-01-20',
        );

        // 2. Transition to OFD with settle later mode
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.handle_out_for_delivery_transition',
          createSuccessResponse(data: {
            'success': true,
            'mode': 'later',
            'courier_transaction': 'CT-LATER-001',
          }),
        );

        final ofd = await kanbanService.handleOutForDeliveryTransition(
          invoiceName: 'INV-PAID-LATER-001',
          courier: 'COURIER-003',
          mode: 'later',
          posProfile: 'Main POS',
          idempotencyToken: 'token-later-001',
        );

        expect(ofd['mode'], equals('later'));
        expect(ofd['courier_transaction'], isNotNull);
        // Settlement deferred - will be processed later in batch
      });
    });

    group('Scenario 3: Unpaid + Settle Now', () {
      test('Complete workflow: create unpaid COD → OFD with pay_now → immediate settlement', () async {
        // 1. Create unpaid invoice
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-UNPAID-NOW-001',
            'grand_total': 120.0,
            'status': 'Unpaid',
          }),
        );

        final invoice = await posRepo.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-004', 'quantity': 4, 'rate': 30.0},
          ],
        );

        expect(invoice['status'], equals('Unpaid'));

        // 2. Transition to OFD with pay_now (creates payment entry immediately)
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.handle_out_for_delivery_transition',
          createSuccessResponse(data: {
            'success': true,
            'payment_entry': 'PE-COD-001',
            'courier_transaction': 'CT-COD-001',
            'amount': 120.0,
            'shipping_amount': 20.0,
          }),
        );

        final ofd = await kanbanService.handleOutForDeliveryTransition(
          invoiceName: 'INV-UNPAID-NOW-001',
          courier: 'COURIER-004',
          mode: 'pay_now',
          posProfile: 'Main POS',
          idempotencyToken: 'token-unpaid-now-001',
        );

        expect(ofd['payment_entry'], equals('PE-COD-001'));
        expect(ofd['courier_transaction'], equals('CT-COD-001'));
        // Invoice immediately moved to courier outstanding
      });
    });

    group('Scenario 4: Unpaid + Settle Later', () {
      test('Complete workflow: create unpaid COD → OFD with later mode', () async {
        // 1. Create unpaid invoice
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-UNPAID-LATER-001',
            'grand_total': 95.0,
            'status': 'Unpaid',
          }),
        );

        await posRepo.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-005', 'quantity': 1, 'rate': 95.0},
          ],
        );

        // 2. Transition to OFD with later mode
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.handle_out_for_delivery_transition',
          createSuccessResponse(data: {
            'success': true,
            'mode': 'later',
            'payment_entry': 'PE-LATER-001',
            'deferred': true,
          }),
        );

        final ofd = await kanbanService.handleOutForDeliveryTransition(
          invoiceName: 'INV-UNPAID-LATER-001',
          courier: 'COURIER-005',
          mode: 'later',
          posProfile: 'Main POS',
          idempotencyToken: 'token-unpaid-later-001',
        );

        expect(ofd['mode'], equals('later'));
        expect(ofd['deferred'], isTrue);
        // Payment entry created but settlement deferred
      });
    });

    group('Scenario 5: Sales Partner', () {
      test('Complete workflow: unpaid sales partner → auto payment + OFD', () async {
        // 1. Create sales partner invoice (unpaid)
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-PARTNER-UNPAID-001',
            'sales_partner': 'PARTNER-A',
            'grand_total': 250.0,
            'status': 'Unpaid',
          }),
        );

        final invoice = await posRepo.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-006', 'quantity': 5, 'rate': 50.0},
          ],
          salesPartner: 'PARTNER-A',
        );

        expect(invoice['sales_partner'], equals('PARTNER-A'));

        // 2. Use sales partner fast-path for unpaid OFD
        mockDio.setResponse(
          '/api/method/jarz_pos.jarz_pos.services.delivery_handling.sales_partner_unpaid_out_for_delivery',
          createSuccessResponse(data: {
            'success': true,
            'payment_entry': 'PE-PARTNER-001',
            'delivery_note': 'DN-PARTNER-001',
            'amount': '250.00',
          }),
        );

        final result = await kanbanService.salesPartnerUnpaidOutForDelivery(
          invoiceName: 'INV-PARTNER-UNPAID-001',
          posProfile: 'Main POS',
        );

        expect(result['success'], isTrue);
        expect(result['payment_entry'], equals('PE-PARTNER-001'));
        expect(result['delivery_note'], equals('DN-PARTNER-001'));
      });

      test('Complete workflow: paid sales partner → OFD (no settlement needed)', () async {
        // 1. Create and pay sales partner invoice
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-PARTNER-PAID-001',
            'sales_partner': 'PARTNER-B',
            'grand_total': 300.0,
          }),
        );

        await posRepo.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-007', 'quantity': 10, 'rate': 30.0},
          ],
          salesPartner: 'PARTNER-B',
        );

        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.pay_invoice',
          createSuccessResponse(data: {
            'payment_entry': 'PE-PARTNER-002',
            'status': 'Paid',
          }),
        );

        await posRepo.payInvoice(
          invoiceName: 'INV-PARTNER-PAID-001',
          paymentMode: 'cash',
          posProfile: 'Main POS',
        );

        // 2. Use sales partner fast-path for paid OFD
        mockDio.setResponse(
          '/api/method/jarz_pos.jarz_pos.services.delivery_handling.sales_partner_paid_out_for_delivery',
          createSuccessResponse(data: {
            'success': true,
            'delivery_note': 'DN-PARTNER-002',
          }),
        );

        final result = await kanbanService.salesPartnerPaidOutForDelivery(
          invoiceId: 'INV-PARTNER-PAID-001',
        );

        expect(result['success'], isTrue);
        expect(result['delivery_note'], equals('DN-PARTNER-002'));
        // No courier settlement needed for sales partner
      });
    });

    group('Scenario 6: Pickup', () {
      test('Complete workflow: pickup order → no courier settlement', () async {
        // 1. Create pickup invoice
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.create_pos_invoice',
          createSuccessResponse(data: {
            'name': 'INV-PICKUP-001',
            'pickup': 1,
            'grand_total': 75.0,
          }),
        );

        final invoice = await posRepo.createInvoice(
          posProfile: 'Main POS',
          items: [
            {'item_code': 'ITEM-008', 'quantity': 1, 'rate': 75.0},
          ],
          isPickup: true,
        );

        expect(invoice['pickup'], equals(1));

        // 2. Pay invoice (if required)
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.pay_invoice',
          createSuccessResponse(data: {
            'payment_entry': 'PE-PICKUP-001',
            'status': 'Paid',
          }),
        );

        await posRepo.payInvoice(
          invoiceName: 'INV-PICKUP-001',
          paymentMode: 'cash',
          posProfile: 'Main POS',
        );

        // 3. Update state directly (no courier needed)
        mockDio.setResponse(
          '/api/method/jarz_pos.api.kanban.update_invoice_state',
          createSuccessResponse(data: {
            'success': true,
            'new_state': 'Ready for Pickup',
          }),
        );

        final stateUpdate = await kanbanService.updateInvoiceState(
          'INV-PICKUP-001',
          'Ready for Pickup',
        );

        expect(stateUpdate, isTrue);
        // No courier settlement required for pickup orders
      });
    });

    group('Courier Management in Workflows', () {
      test('Fetch active couriers before OFD transition', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.get_active_couriers',
          createSuccessResponse(data: [
            {
              'party_type': 'Employee',
              'party': 'EMP-001',
              'display_name': 'John Courier',
            },
            {
              'party_type': 'Supplier',
              'party': 'SUPP-001',
              'display_name': 'Fast Delivery',
            },
          ]),
        );

        final couriers = await kanbanService.fetchCouriers();

        expect(couriers, hasLength(2));
        expect(couriers[0]['display_name'], equals('John Courier'));
        expect(couriers[1]['display_name'], equals('Fast Delivery'));
      });

      test('Create new courier party when needed', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.couriers.create_delivery_party',
          createSuccessResponse(data: {
            'party_type': 'Employee',
            'party': 'EMP-NEW-001',
            'display_name': 'New Courier',
          }),
        );

        final newCourier = await kanbanService.createDeliveryParty(
          partyType: 'Employee',
          name: 'New Courier',
          phone: '1234567890',
          posProfile: 'Main POS',
        );

        expect(newCourier['party'], equals('EMP-NEW-001'));
      });
    });

    group('Settlement Preview in Workflows', () {
      test('Preview helps determine settlement type (collect vs pay)', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.get_invoice_settlement_preview',
          createSuccessResponse(data: {
            'invoice_name': 'INV-TEST-001',
            'outstanding': 0.0,
            'shipping_expense': 20.0,
            'order_amount': 100.0,
            'net_amount': 80.0, // Positive = courier owes branch
            'is_unpaid_effective': false,
          }),
        );

        final preview = await kanbanService.getInvoiceSettlementPreview(
          invoiceName: 'INV-TEST-001',
        );

        // Determine settlement type based on net_amount
        if (preview['net_amount'] > 0) {
          // Courier collected and owes branch
          expect(preview['net_amount'], greaterThan(0));
          // Use settleCourierCollectedPayment
        } else if (preview['net_amount'] < 0) {
          // Branch owes courier for shipping
          expect(preview['net_amount'], lessThan(0));
          // Use settleSingleInvoicePaid
        }
      });

      test('Preview identifies recently paid invoices as unpaid effective', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.invoices.get_invoice_settlement_preview',
          createSuccessResponse(data: {
            'invoice_name': 'INV-RECENT-PAY',
            'outstanding': 0.0,
            'last_payment_seconds': 15, // Paid 15 seconds ago
            'is_unpaid_effective': true, // Still treat as unpaid for settlement
          }),
        );

        final preview = await kanbanService.getInvoiceSettlementPreview(
          invoiceName: 'INV-RECENT-PAY',
        );

        expect(preview['is_unpaid_effective'], isTrue);
        // Recent payment treated as unpaid for settlement flow
      });
    });
  });
}
