import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/network/courier_service.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  group('CourierService', () {
    late MockDio mockDio;
    late CourierService service;

    setUp(() {
      mockDio = MockDio();
      service = CourierService(mockDio);
    });

    // ── getBalances ───────────────────────────────────────────────────

    group('getBalances', () {
      test('returns list from Frappe message envelope', () async {
        mockDio.setResponse(
          ApiEndpoints.getCourierBalances,
          createSuccessResponse(data: [
            {'courier': 'Ahmad', 'outstanding': 500},
            {'courier': 'Salem', 'outstanding': 200},
          ]),
        );

        final result = await service.getBalances();

        expect(result, hasLength(2));
        expect(result[0]['courier'], 'Ahmad');
        expect(result[1]['outstanding'], 200);
      });

      test('returns empty list when message is empty', () async {
        mockDio.setResponse(
          ApiEndpoints.getCourierBalances,
          createSuccessResponse(data: []),
        );

        final result = await service.getBalances();
        expect(result, isEmpty);
      });

      test('returns empty list when response is not a list/map', () async {
        mockDio.setResponse(ApiEndpoints.getCourierBalances, 'unexpected');

        final result = await service.getBalances();
        expect(result, isEmpty);
      });
    });

    // ── getSettlementPreview ──────────────────────────────────────────

    group('getSettlementPreview', () {
      test('returns preview map from message', () async {
        mockDio.setResponse(
          ApiEndpoints.getInvoiceSettlementPreview,
          createSuccessResponse(data: {
            'invoice': 'INV-001',
            'outstanding': 500,
            'paid_amount': 0,
          }),
        );

        final result = await service.getSettlementPreview(invoice: 'INV-001');

        expect(result['invoice'], 'INV-001');
        expect(result['outstanding'], 500);
      });

      test('sends optional party fields', () async {
        mockDio.setResponse(
          ApiEndpoints.getInvoiceSettlementPreview,
          createSuccessResponse(data: {'invoice': 'INV-001'}),
        );

        await service.getSettlementPreview(
          invoice: 'INV-001',
          partyType: 'Employee',
          party: 'EMP-001',
        );

        final req = mockDio.requestLog.first;
        expect(req['data']['party_type'], 'Employee');
        expect(req['data']['party'], 'EMP-001');
      });

      test('throws on unexpected response', () async {
        mockDio.setResponse(
          ApiEndpoints.getInvoiceSettlementPreview,
          'bad response',
        );

        expect(
          () => service.getSettlementPreview(invoice: 'X'),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ── generateSettlementPreview ─────────────────────────────────────

    group('generateSettlementPreview', () {
      test('returns preview with token', () async {
        mockDio.setResponse(
          ApiEndpoints.generateSettlementPreview,
          createSuccessResponse(data: {
            'preview_token': 'tok_abc123',
            'invoice': 'INV-001',
            'amount': 500,
          }),
        );

        final result = await service.generateSettlementPreview(
          invoice: 'INV-001',
          mode: 'pay_now',
        );

        expect(result['preview_token'], 'tok_abc123');
        expect(result['amount'], 500);
      });

      test('sends all parameters', () async {
        mockDio.setResponse(
          ApiEndpoints.generateSettlementPreview,
          createSuccessResponse(data: {'preview_token': 'tok'}),
        );

        await service.generateSettlementPreview(
          invoice: 'INV-001',
          partyType: 'Supplier',
          party: 'SUP-001',
          mode: 'settle_later',
          recentPaymentSeconds: 60,
        );

        final req = mockDio.requestLog.first;
        expect(req['data']['invoice'], 'INV-001');
        expect(req['data']['party_type'], 'Supplier');
        expect(req['data']['party'], 'SUP-001');
        expect(req['data']['mode'], 'settle_later');
        expect(req['data']['recent_payment_seconds'], 60);
      });
    });

    // ── confirmSettlement ─────────────────────────────────────────────

    group('confirmSettlement', () {
      test('returns confirmation map on success', () async {
        mockDio.setResponse(
          ApiEndpoints.confirmSettlement,
          createSuccessResponse(data: {
            'success': true,
            'journal_entry': 'JE-001',
          }),
        );

        final result = await service.confirmSettlement(
          invoice: 'INV-001',
          previewToken: 'tok_abc',
          mode: 'pay_now',
        );

        expect(result['success'], true);
        expect(result['journal_entry'], 'JE-001');
      });

      test('sends required and optional parameters', () async {
        mockDio.setResponse(
          ApiEndpoints.confirmSettlement,
          createSuccessResponse(data: {'success': true}),
        );

        await service.confirmSettlement(
          invoice: 'INV-001',
          previewToken: 'tok',
          mode: 'pay_now',
          posProfile: 'Main Store',
          partyType: 'Employee',
          party: 'EMP-001',
          paymentMode: 'Cash',
          courier: 'Ahmad',
        );

        final req = mockDio.requestLog.first;
        expect(req['data']['invoice'], 'INV-001');
        expect(req['data']['preview_token'], 'tok');
        expect(req['data']['mode'], 'pay_now');
        expect(req['data']['pos_profile'], 'Main Store');
        expect(req['data']['party_type'], 'Employee');
        expect(req['data']['party'], 'EMP-001');
        expect(req['data']['payment_mode'], 'Cash');
        expect(req['data']['courier'], 'Ahmad');
      });

      test('does not send courier when empty string', () async {
        mockDio.setResponse(
          ApiEndpoints.confirmSettlement,
          createSuccessResponse(data: {'success': true}),
        );

        await service.confirmSettlement(
          invoice: 'INV-001',
          previewToken: 'tok',
          mode: 'pay_now',
          courier: '',
        );

        final req = mockDio.requestLog.first;
        expect(req['data'].containsKey('courier'), false);
      });

      test('throws on unexpected response format', () async {
        mockDio.setResponse(ApiEndpoints.confirmSettlement, 'bad');

        expect(
          () => service.confirmSettlement(
            invoice: 'X',
            previewToken: 'tok',
            mode: 'pay_now',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
