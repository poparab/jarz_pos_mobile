import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/kanban/services/kanban_service.dart';
import '../../../helpers/mock_services.dart';

void main() {
  group('KanbanService New Features', () {
    late MockDio mockDio;
    late KanbanService service;

    setUp(() {
      mockDio = MockDio();
      service = KanbanService(mockDio);
    });

    test('getSubTerritories returns parsed list', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.territories.get_sub_territories',
        createSuccessResponse(data: {
          'success': true,
          'data': [
            {
              'name': 'T-CH-1',
              'territory_name': 'Sub A',
              'delivery_expense': 20,
              'delivery_income': 30,
            }
          ]
        }),
      );

      final items = await service.getSubTerritories('Main Territory');
      expect(items, hasLength(1));
      expect(items.first['territory_name'], 'Sub A');

      final req = mockDio.requestLog.last;
      expect(req['queryParameters']['territory_name'], 'Main Territory');
    });

    test('setInvoiceSubTerritory posts invoice and sub-territory', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.territories.set_invoice_sub_territory',
        createSuccessResponse(data: {
          'success': true,
          'sub_territory': 'Sub A',
          'delivery_expense': 25,
        }),
      );

      final result = await service.setInvoiceSubTerritory('SINV-1', 'Sub A');
      expect(result['success'], isTrue);
      expect(result['sub_territory'], 'Sub A');

      final req = mockDio.requestLog.last;
      expect(req['data']['invoice_name'], 'SINV-1');
      expect(req['data']['sub_territory'], 'Sub A');
    });

    test('requestCustomShipping posts amount and reason', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.custom_shipping.request_custom_shipping',
        createSuccessResponse(data: {
          'success': true,
          'request': 'CSR-00001',
          'requested_amount': 40,
        }),
      );

      final result = await service.requestCustomShipping(
        invoiceName: 'SINV-11',
        amount: 40,
        reason: 'Far delivery location and extra route cost',
      );

      expect(result['success'], isTrue);
      expect(result['request'], 'CSR-00001');

      final req = mockDio.requestLog.last;
      expect(req['data']['invoice_name'], 'SINV-11');
      expect(req['data']['amount'], 40);
    });

    test('approve and reject custom shipping call expected endpoints', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.custom_shipping.approve_custom_shipping',
        createSuccessResponse(data: {'success': true}),
      );
      mockDio.setResponse(
        '/api/method/jarz_pos.api.custom_shipping.reject_custom_shipping',
        createSuccessResponse(data: {'success': true}),
      );

      final approveRes = await service.approveCustomShipping('CSR-00002');
      final rejectRes = await service.rejectCustomShipping('CSR-00003', reason: 'Not justified');

      expect(approveRes['success'], isTrue);
      expect(rejectRes['success'], isTrue);

      expect(mockDio.requestLog[0]['path'], '/api/method/jarz_pos.api.custom_shipping.approve_custom_shipping');
      expect(mockDio.requestLog[1]['path'], '/api/method/jarz_pos.api.custom_shipping.reject_custom_shipping');
      expect(mockDio.requestLog[1]['data']['rejection_reason'], 'Not justified');
    });
  });
}
