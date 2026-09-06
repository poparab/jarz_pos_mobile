import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/instapay_reconciliation/data/instapay_reconciliation_service.dart';

import '../../../helpers/mock_services.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  group('InstapayReconciliationService', () {
    late MockDio mockDio;
    late InstapayReconciliationService service;

    setUp(() {
      mockDio = MockDio();
      service = InstapayReconciliationService(mockDio);
    });

    // ── deliverOnlineUnconfirmed ──────────────────────────────────────

    group('deliverOnlineUnconfirmed', () {
      test('posts invoice_name + pos_profile and returns payload', () async {
        mockDio.setResponse(
          ApiEndpoints.deliverOnlineUnconfirmed,
          createSuccessResponse(data: {
            'success': true,
            'invoice': 'INV-001',
            'new_state': 'Out for Delivery',
            'payment_confirmation_status': 'Awaiting Payment',
            'delivery_note': 'DN-001',
            'delivery_note_reused': false,
          }),
        );

        final result = await service.deliverOnlineUnconfirmed(
          invoiceName: 'INV-001',
          posProfile: 'Nasr City',
        );

        expect(result['payment_confirmation_status'], 'Awaiting Payment');
        expect(result['new_state'], 'Out for Delivery');

        final req = mockDio.requestLog.single;
        expect(req['path'], ApiEndpoints.deliverOnlineUnconfirmed);
        expect(req['data']['invoice_name'], 'INV-001');
        expect(req['data']['pos_profile'], 'Nasr City');
      });
    });

    // ── fetchUnconfirmedOnlineOrders ──────────────────────────────────

    group('fetchUnconfirmedOnlineOrders', () {
      test('parses orders list from message envelope', () async {
        mockDio.setResponse(
          ApiEndpoints.listUnconfirmedOnlineOrders,
          createSuccessResponse(data: {
            'success': true,
            'orders': [
              {
                'invoice': 'INV-001',
                'customer': 'CUST-001',
                'customer_name': 'Ahmad',
                'amount': 250.5,
                'expected_reference': 'REF-9',
                'payment_method': 'Instapay',
                'courier_party_type': 'Supplier',
                'courier_party': 'SUP-001',
                'courier_name': 'Fast Courier',
                'age_seconds': 25000,
                'receipt_name': 'PPR-001',
                'receipt_status': 'Unconfirmed',
                'receipt_image_url': '/files/r.png',
                'can_confirm': 1,
              },
            ],
          }),
        );

        final result = await service.fetchUnconfirmedOnlineOrders(
          posProfile: 'Nasr City',
        );

        expect(result, hasLength(1));
        final order = result.first;
        expect(order.invoice, 'INV-001');
        expect(order.customerName, 'Ahmad');
        expect(order.amount, 250.5);
        expect(order.ageSeconds, 25000);
        expect(order.canConfirm, isTrue);
        expect(order.hasReceiptImage, isTrue);

        final req = mockDio.requestLog.single;
        expect(req['path'], ApiEndpoints.listUnconfirmedOnlineOrders);
        expect(req['data']['pos_profile'], 'Nasr City');
      });

      test('omits pos_profile when not provided', () async {
        mockDio.setResponse(
          ApiEndpoints.listUnconfirmedOnlineOrders,
          createSuccessResponse(data: {'success': true, 'orders': []}),
        );

        final result = await service.fetchUnconfirmedOnlineOrders();

        expect(result, isEmpty);
        final req = mockDio.requestLog.single;
        expect((req['data'] as Map).containsKey('pos_profile'), isFalse);
      });
    });

    // ── confirmOnlinePayment ──────────────────────────────────────────

    group('confirmOnlinePayment', () {
      test('posts all four params and returns payload', () async {
        mockDio.setResponse(
          ApiEndpoints.confirmOnlinePayment,
          createSuccessResponse(data: {
            'success': true,
            'invoice': 'INV-001',
            'payment_entry': 'PE-001',
            'payment_confirmation_status': 'Payment Confirmed',
            'amount': 250.5,
            'method': 'InstaPay',
          }),
        );

        final result = await service.confirmOnlinePayment(
          invoiceName: 'INV-001',
          posProfile: 'Nasr City',
          referenceNo: 'REF-9',
          receiptName: 'PPR-001',
        );

        expect(result['payment_confirmation_status'], 'Payment Confirmed');
        expect(result['payment_entry'], 'PE-001');

        final req = mockDio.requestLog.single;
        expect(req['path'], ApiEndpoints.confirmOnlinePayment);
        expect(req['data']['invoice_name'], 'INV-001');
        expect(req['data']['pos_profile'], 'Nasr City');
        expect(req['data']['reference_no'], 'REF-9');
        expect(req['data']['receipt_name'], 'PPR-001');
      });

      test('throws cleaned message on failure envelope', () async {
        mockDio.setResponse(
          ApiEndpoints.confirmOnlinePayment,
          createSuccessResponse(data: {
            'success': false,
            'error': 'Reference already used',
          }),
        );

        expect(
          () => service.confirmOnlinePayment(
            invoiceName: 'INV-001',
            posProfile: 'Nasr City',
            referenceNo: 'REF-9',
            receiptName: 'PPR-001',
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Reference already used'),
            ),
          ),
        );
      });
    });

    // ── fetchUnconfirmedPaymentEscalations ─────────────────────────────

    group('fetchUnconfirmedPaymentEscalations', () {
      test('parses escalated orders and sorts worst-first', () async {
        mockDio.setResponse(
          ApiEndpoints.unconfirmedPaymentEscalations,
          createSuccessResponse(data: {
            'success': true,
            'threshold_hours': 4,
            'orders': [
              {
                'invoice': 'INV-SHORT',
                'customer': 'CUST-1',
                'customer_name': 'Short',
                'branch': 'Nasr City',
                'amount': 120.0,
                'payment_method': 'InstaPay',
                'out_for_delivery_since': '2026-09-07 08:00:00',
                'out_for_delivery_seconds': 5000,
                'threshold_hours': 4,
                'already_alerted': 1,
              },
              {
                'invoice': 'INV-WORST',
                'customer': 'CUST-2',
                'customer_name': 'Worst',
                'branch': 'Maadi',
                'amount': 300.5,
                'payment_method': 'Mobile Wallet',
                'out_for_delivery_seconds': 90000,
                'threshold_hours': 4,
                'already_alerted': 0,
              },
            ],
          }),
        );

        final result = await service.fetchUnconfirmedPaymentEscalations(
          posProfile: 'Nasr City',
        );

        expect(result, hasLength(2));
        // Worst-first: the longer out-for-delivery duration comes first.
        expect(result.first.invoice, 'INV-WORST');
        expect(result.first.outForDeliverySeconds, 90000);
        expect(result.first.alreadyAlerted, isFalse);
        expect(result.last.invoice, 'INV-SHORT');
        expect(result.last.alreadyAlerted, isTrue);
        expect(result.last.branch, 'Nasr City');
        expect(result.last.thresholdHours, 4);

        final req = mockDio.requestLog.single;
        expect(req['path'], ApiEndpoints.unconfirmedPaymentEscalations);
        expect(req['data']['pos_profile'], 'Nasr City');
      });

      test('omits pos_profile when not provided and handles empty list',
          () async {
        mockDio.setResponse(
          ApiEndpoints.unconfirmedPaymentEscalations,
          createSuccessResponse(
              data: {'success': true, 'threshold_hours': 4, 'orders': []}),
        );

        final result = await service.fetchUnconfirmedPaymentEscalations();

        expect(result, isEmpty);
        final req = mockDio.requestLog.single;
        expect((req['data'] as Map).containsKey('pos_profile'), isFalse);
      });

      test('falls back to a bare (unwrapped) payload map', () async {
        mockDio.setResponse(
          ApiEndpoints.unconfirmedPaymentEscalations,
          {
            'success': true,
            'orders': [
              {
                'invoice': 'INV-BARE',
                'customer_name': 'Bare Payload',
                'amount': 42,
                'out_for_delivery_seconds': 100,
                'threshold_hours': 2,
              },
            ],
          },
        );

        final result = await service.fetchUnconfirmedPaymentEscalations();

        expect(result, hasLength(1));
        expect(result.single.invoice, 'INV-BARE');
        expect(result.single.amount, 42.0);
      });

      test('throws cleaned message on failure envelope', () async {
        mockDio.setResponse(
          ApiEndpoints.unconfirmedPaymentEscalations,
          createSuccessResponse(data: {
            'success': false,
            'error': 'Not permitted',
          }),
        );

        expect(
          () => service.fetchUnconfirmedPaymentEscalations(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Not permitted'),
            ),
          ),
        );
      });
    });

    // ── convertToCod ──────────────────────────────────────────────────

    group('convertToCod', () {
      test('posts invoice, profile, party fields and returns payload', () async {
        mockDio.setResponse(
          ApiEndpoints.convertOnlineOrderToCod,
          createSuccessResponse(data: {
            'success': true,
            'invoice': 'INV-001',
            'courier_transaction': 'CT-001',
            'payment_entry': 'PE-002',
            'journal_entry': 'JE-001',
            'payment_confirmation_status': 'Converted to Cash',
          }),
        );

        final result = await service.convertToCod(
          invoiceName: 'INV-001',
          posProfile: 'Nasr City',
          partyType: 'Supplier',
          party: 'SUP-001',
        );

        expect(result['payment_confirmation_status'], 'Converted to Cash');
        expect(result['journal_entry'], 'JE-001');

        final req = mockDio.requestLog.single;
        expect(req['path'], ApiEndpoints.convertOnlineOrderToCod);
        expect(req['data']['invoice_name'], 'INV-001');
        expect(req['data']['pos_profile'], 'Nasr City');
        expect(req['data']['party_type'], 'Supplier');
        expect(req['data']['party'], 'SUP-001');
      });
    });
  });
}
