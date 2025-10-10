import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import '../../../helpers/mock_services.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('PosRepository', () {
    late MockDio mockDio;
    late PosRepository repository;

    setUp(() {
      mockDio = MockDio();
      repository = PosRepository(mockDio);
    });

    group('getPosProfiles', () {
      test('returns list of POS profiles', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.pos.get_pos_profiles',
          createSuccessResponse(
            data: ['Main POS', 'Branch POS'],
          ),
        );

        final result = await repository.getPosProfiles();

        expect(result, hasLength(2));
        expect(result[0]['name'], equals('Main POS'));
        expect(result[0]['title'], equals('Main POS'));
        expect(result[1]['name'], equals('Branch POS'));
      });

      test('returns empty list when no profiles exist', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.pos.get_pos_profiles',
          createSuccessResponse(data: []),
        );

        final result = await repository.getPosProfiles();

        expect(result, isEmpty);
      });

      test('throws exception on API error', () async {
        mockDio.setError(
          '/api/method/jarz_pos.api.pos.get_pos_profiles',
          createMockDioException(message: 'API Error'),
        );

        expect(
          () => repository.getPosProfiles(),
          throwsException,
        );
      });

      test('handles null message gracefully', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.pos.get_pos_profiles',
          {'message': null},
        );

        final result = await repository.getPosProfiles();

        expect(result, isEmpty);
      });
    });

    group('getBundles', () {
      test('returns list of bundles for profile', () async {
        final bundles = [
          {
            'name': 'Bundle 1',
            'price': 100.0,
            'free_shipping': 1,
          },
          {
            'name': 'Bundle 2',
            'price': 200.0,
            'free_shipping': 0,
          },
        ];

        mockDio.setResponse(
          '/api/method/jarz_pos.api.pos.get_profile_bundles',
          createSuccessResponse(data: bundles),
        );

        final result = await repository.getBundles('Main POS');

        expect(result, hasLength(2));
        expect(result[0]['name'], equals('Bundle 1'));
        expect(result[0]['free_shipping'], isTrue); // Normalized to bool
        expect(result[1]['free_shipping'], isFalse);
      });

      test('normalizes free_shipping from various formats', () async {
        final bundles = [
          {'name': 'B1', 'free_shipping': true},
          {'name': 'B2', 'free_shipping': false},
          {'name': 'B3', 'free_shipping': 1},
          {'name': 'B4', 'free_shipping': 0},
          {'name': 'B5', 'free_shipping': '1'},
          {'name': 'B6', 'free_shipping': 'true'},
        ];

        mockDio.setResponse(
          '/api/method/jarz_pos.api.pos.get_profile_bundles',
          createSuccessResponse(data: bundles),
        );

        final result = await repository.getBundles('Main POS');

        expect(result[0]['free_shipping'], isTrue);
        expect(result[1]['free_shipping'], isFalse);
        expect(result[2]['free_shipping'], isTrue);
        expect(result[3]['free_shipping'], isFalse);
        expect(result[4]['free_shipping'], isTrue);
        expect(result[5]['free_shipping'], isTrue);
      });

      test('sends profile parameter correctly', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.pos.get_profile_bundles',
          createSuccessResponse(data: []),
        );

        await repository.getBundles('Test Profile');

        final requests = mockDio.requestLog;
        expect(requests.first['data']['profile'], equals('Test Profile'));
      });

      test('throws exception on API error', () async {
        mockDio.setError(
          '/api/method/jarz_pos.api.pos.get_profile_bundles',
          createMockDioException(message: 'Network error'),
        );

        expect(
          () => repository.getBundles('Main POS'),
          throwsException,
        );
      });
    });

    group('getTerritories', () {
      test('returns list of territories without search', () async {
        final territories = [
          {'name': 'North', 'territory_name': 'North Region'},
          {'name': 'South', 'territory_name': 'South Region'},
        ];

        mockDio.setResponse(
          '/api/method/jarz_pos.api.customer.get_territories',
          createSuccessResponse(data: territories),
        );

        final result = await repository.getTerritories();

        expect(result, hasLength(2));
        expect(result[0]['name'], equals('North'));
      });

      test('sends search parameter when provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.customer.get_territories',
          createSuccessResponse(data: []),
        );

        await repository.getTerritories(search: 'north');

        final requests = mockDio.requestLog;
        expect(requests.first['data']['search'], equals('north'));
      });

      test('sends empty data when search is null', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.customer.get_territories',
          createSuccessResponse(data: []),
        );

        await repository.getTerritories();

        final requests = mockDio.requestLog;
        expect(requests.first['data'], isEmpty);
      });

      test('throws exception on API error', () async {
        mockDio.setError(
          '/api/method/jarz_pos.api.customer.get_territories',
          createMockDioException(message: 'Server error'),
        );

        expect(
          () => repository.getTerritories(),
          throwsException,
        );
      });
    });

    group('getItems', () {
      test('transforms item data to expected format', () async {
        final apiItems = [
          {
            'id': 'ITEM-001',
            'name': 'Product A',
            'item_group': 'Electronics',
            'price': 100.0,
            'qty': 10.0,
          },
        ];

        mockDio.setResponse(
          '/api/method/jarz_pos.api.pos.get_profile_products',
          createSuccessResponse(data: apiItems),
        );

        final result = await repository.getItems('Main POS');

        expect(result, hasLength(1));
        expect(result[0]['name'], equals('ITEM-001'));
        expect(result[0]['item_name'], equals('Product A'));
        expect(result[0]['item_group'], equals('Electronics'));
        expect(result[0]['rate'], equals(100.0));
        expect(result[0]['actual_qty'], equals(10.0));
        expect(result[0]['stock_uom'], equals('Unit'));
      });

      test('handles missing price and qty with defaults', () async {
        final apiItems = [
          {
            'id': 'ITEM-001',
            'name': 'Product A',
            'item_group': 'Electronics',
          },
        ];

        mockDio.setResponse(
          '/api/method/jarz_pos.api.pos.get_profile_products',
          createSuccessResponse(data: apiItems),
        );

        final result = await repository.getItems('Main POS');

        expect(result[0]['rate'], equals(0.0));
        expect(result[0]['actual_qty'], equals(0.0));
      });

      test('sends profile parameter correctly', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.pos.get_profile_products',
          createSuccessResponse(data: []),
        );

        await repository.getItems('Branch POS');

        final requests = mockDio.requestLog;
        expect(requests.first['data']['profile'], equals('Branch POS'));
      });

      test('throws exception on API error', () async {
        mockDio.setError(
          '/api/method/jarz_pos.api.pos.get_profile_products',
          createMockDioException(message: 'Failed to load items'),
        );

        expect(
          () => repository.getItems('Main POS'),
          throwsException,
        );
      });
    });
  });
}
