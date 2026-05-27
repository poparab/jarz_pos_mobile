import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/trips/services/trip_service.dart';
import '../../../helpers/mock_services.dart';

void main() {
  group('TripService', () {
    late MockDio mockDio;
    late TripService service;

    setUp(() {
      mockDio = MockDio();
      service = TripService(mockDio);
    });

    test('createTrip sends expected payload and parses response', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.trips.create_delivery_trip',
        createSuccessResponse(data: {
          'success': true,
          'name': 'TRIP-00001',
          'trip_date': '2026-03-24',
          'courier_party_type': 'Employee',
          'courier_party': 'EMP-001',
          'courier_display_name': 'Courier A',
          'status': 'Created',
          'total_orders': 2,
          'total_amount': 250,
          'invoices': [],
        }),
      );

      final trip = await service.createTrip(
        invoiceNames: const ['SINV-1', 'SINV-2'],
        partyType: 'Employee',
        party: 'EMP-001',
        posProfile: 'POS-001',
      );

      expect(trip.name, 'TRIP-00001');
      expect(trip.totalOrders, 2);
      expect(trip.status, 'Created');

      final req = mockDio.requestLog.last;
      expect(req['path'], '/api/method/jarz_pos.api.trips.create_delivery_trip');
      expect(req['data']['party_type'], 'Employee');
      expect(req['data']['party'], 'EMP-001');
      expect(req['data']['pos_profile'], 'POS-001');
    });

    test('getTrips parses list response', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.trips.get_delivery_trips',
        createSuccessResponse(data: {
          'success': true,
          'data': [
            {
              'name': 'TRIP-00002',
              'trip_date': '2026-03-24',
              'courier_party_type': 'Supplier',
              'courier_party': 'SUP-1',
              'courier_display_name': 'Supplier Courier',
              'status': 'Out for Delivery',
              'total_orders': 1,
              'total_amount': 120,
            }
          ]
        }),
      );

      final trips = await service.getTrips(status: 'Out for Delivery');
      expect(trips, hasLength(1));
      expect(trips.first.name, 'TRIP-00002');
      expect(trips.first.isOutForDelivery, isTrue);

      final req = mockDio.requestLog.last;
      expect(req['queryParameters']['status'], 'Out for Delivery');
    });

    test('getTripDetails parses trip details', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.trips.get_trip_details',
        createSuccessResponse(data: {
          'success': true,
          'trip': {
            'name': 'TRIP-00003',
            'trip_date': '2026-03-24',
            'courier_party_type': 'Employee',
            'courier_party': 'EMP-2',
            'courier_display_name': 'Courier B',
            'status': 'Created',
            'total_orders': 1,
            'total_amount': 90,
            'invoices': [
              {
                'invoice': 'SINV-10',
                'customer_name': 'Customer One',
                'territory': 'Main',
                'grand_total': 90,
                'shipping_expense': 10,
                'invoice_status': 'Ready',
              }
            ],
          }
        }),
      );

      final trip = await service.getTripDetails('TRIP-00003');
      expect(trip.name, 'TRIP-00003');
      expect(trip.invoices, hasLength(1));
      expect(trip.invoices.first.invoice, 'SINV-10');
    });

    test('sendForDelivery returns success map', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.trips.send_trip_for_delivery',
        createSuccessResponse(data: {
          'success': true,
          'trip': 'TRIP-00004',
          'status': 'Out for Delivery',
          'processed': [
            {'invoice': 'SINV-1'}
          ],
          'skipped': [],
        }),
      );

      final result = await service.sendForDelivery('TRIP-00004');
      expect(result['success'], isTrue);
      expect(result['status'], 'Out for Delivery');

      final req = mockDio.requestLog.last;
      expect(req['data']['trip_name'], 'TRIP-00004');
    });
  });
}
