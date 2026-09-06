import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/partner_settlements/data/partner_settlements_service.dart';

import '../../../helpers/mock_services.dart';

void main() {
  group('PartnerSettlementsService', () {
    late MockDio mockDio;
    late PartnerSettlementsService service;

    setUp(() {
      mockDio = MockDio();
      service = PartnerSettlementsService(mockDio);
    });

    group('getDeliveryPartnerBalances', () {
      const path =
          '/api/method/jarz_pos.api.delivery_partners.get_delivery_partner_balances';

      test('unwraps rows from the message envelope', () async {
        mockDio.setResponse(path, {
          'message': [
            {
              'delivery_partner': 'DP-001',
              'partner_name': 'Bosta',
              'order_count': 5,
              'total_fee': 250.0,
            },
          ],
        });

        final result = await service.getDeliveryPartnerBalances();

        expect(result, hasLength(1));
        expect(result.first['delivery_partner'], equals('DP-001'));
        expect(result.first['total_fee'], equals(250.0));
      });

      test('accepts a bare list payload', () async {
        mockDio.setResponse(path, [
          {'delivery_partner': 'DP-002', 'total_fee': 10.0},
        ]);

        final result = await service.getDeliveryPartnerBalances();

        expect(result, hasLength(1));
        expect(result.first['delivery_partner'], equals('DP-002'));
      });

      test('falls back to an empty list on an unexpected shape', () async {
        mockDio.setResponse(path, {'unexpected': 'format'});

        final result = await service.getDeliveryPartnerBalances();

        expect(result, isEmpty);
      });
    });

    group('getDeliveryPartnerUnsettledDetails', () {
      const path =
          '/api/method/jarz_pos.api.delivery_partners.get_delivery_partner_unsettled_details';

      test('sends delivery_partner and unwraps the trip rows', () async {
        mockDio.setResponse(path, {
          'message': [
            {'name': 'CT-0001', 'fee': 20.0, 'invoice': 'ACC-SINV-0001'},
            {'name': 'CT-0002', 'fee': 15.0, 'invoice': 'ACC-SINV-0002'},
          ],
        });

        final result =
            await service.getDeliveryPartnerUnsettledDetails('DP-001');

        expect(result, hasLength(2));
        final requests = mockDio.requestLog;
        expect(requests.first['data']['delivery_partner'], equals('DP-001'));
      });
    });

    group('settleDeliveryPartner', () {
      const path =
          '/api/method/jarz_pos.api.delivery_partners.settle_delivery_partner';

      test('sends the selected transactions and extra charges as JSON strings',
          () async {
        mockDio.setResponse(path, {
          'message': {
            'success': true,
            'journal_entry': 'ACC-JV-0099',
            'total_paid': 235.0,
          },
        });

        final result = await service.settleDeliveryPartner(
          deliveryPartner: 'DP-001',
          courierTransactions: const ['CT-0001', 'CT-0002'],
          extraCharges: const [
            {'description': 'Subscription', 'amount': 50.0},
          ],
        );

        expect(result['journal_entry'], equals('ACC-JV-0099'));

        final data = mockDio.requestLog.first['data'] as Map;
        expect(data['delivery_partner'], equals('DP-001'));
        expect(data.containsKey('bank_account'), isFalse);

        final sentTransactions =
            jsonDecode(data['courier_transactions'] as String) as List;
        expect(sentTransactions, equals(['CT-0001', 'CT-0002']));

        final sentCharges =
            jsonDecode(data['extra_charges'] as String) as List;
        expect(sentCharges, hasLength(1));
        expect(sentCharges.first['description'], equals('Subscription'));
        expect(sentCharges.first['amount'], equals(50.0));
      });

      test('omits bank_account when not provided, sends it when it is',
          () async {
        mockDio.setResponse(path, {
          'message': {'success': true},
        });

        await service.settleDeliveryPartner(
          deliveryPartner: 'DP-001',
          bankAccount: 'Bank - Main',
          courierTransactions: const [],
        );

        final data = mockDio.requestLog.first['data'] as Map;
        expect(data['bank_account'], equals('Bank - Main'));
        expect(jsonDecode(data['courier_transactions'] as String), isEmpty);
        expect(jsonDecode(data['extra_charges'] as String), isEmpty);
      });

      test('handles a direct map response', () async {
        mockDio.setResponse(path, {'success': true, 'journal_entry': 'JV-1'});

        final result = await service.settleDeliveryPartner(
          deliveryPartner: 'DP-001',
          courierTransactions: const ['CT-0001'],
        );

        expect(result['journal_entry'], equals('JV-1'));
      });

      test('throws on an unexpected response format', () async {
        mockDio.setResponse(path, 'unexpected string response');

        expect(
          () => service.settleDeliveryPartner(
            deliveryPartner: 'DP-001',
            courierTransactions: const ['CT-0001'],
          ),
          throwsException,
        );
      });
    });

    group('getSalesPartnerBalances', () {
      const path =
          '/api/method/jarz_pos.api.sales_partners.get_sales_partner_balances';

      test('unwraps the aggregated per-partner rows', () async {
        mockDio.setResponse(path, {
          'message': [
            {
              'sales_partner': 'Talabat',
              'order_count': 12,
              'total_base': 100.0,
              'total_vat': 14.0,
              'total_fees': 114.0,
            },
          ],
        });

        final result = await service.getSalesPartnerBalances();

        expect(result, hasLength(1));
        expect(result.first['sales_partner'], equals('Talabat'));
        expect(result.first['total_fees'], equals(114.0));
      });

      test('returns an empty list on an unexpected shape', () async {
        mockDio.setResponse(path, 'nope');

        final result = await service.getSalesPartnerBalances();

        expect(result, isEmpty);
      });
    });

    group('settleSalesPartner', () {
      const path =
          '/api/method/jarz_pos.api.sales_partners.settle_sales_partner';

      test('sends sales_partner and unwraps the JE summary', () async {
        mockDio.setResponse(path, {
          'message': {
            'success': true,
            'journal_entry': 'ACC-JV-0100',
            'settled_count': 12,
          },
        });

        final result =
            await service.settleSalesPartner(salesPartner: 'Talabat');

        expect(result['journal_entry'], equals('ACC-JV-0100'));
        final data = mockDio.requestLog.first['data'] as Map;
        expect(data['sales_partner'], equals('Talabat'));
        expect(data.containsKey('pos_profile'), isFalse);
      });

      test('sends pos_profile when provided', () async {
        mockDio.setResponse(path, {
          'message': {'success': true},
        });

        await service.settleSalesPartner(
          salesPartner: 'Talabat',
          posProfile: 'Main Branch',
        );

        final data = mockDio.requestLog.first['data'] as Map;
        expect(data['pos_profile'], equals('Main Branch'));
      });
    });
  });
}
