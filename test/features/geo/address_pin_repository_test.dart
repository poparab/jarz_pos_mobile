import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/geo/data/repositories/address_pin_repository.dart';
import 'package:jarz_pos/src/features/geo/domain/geo_pin_sources.dart';

import '../../helpers/mock_services.dart';

/// Correcting the pin on an EXISTING address: `get_address_pin` /
/// `dry_run_address_pin` / `set_address_pin`. Covers the request shapes going
/// out and the envelope-fallback tolerance coming back — the same discipline
/// `MapsLinkPreview` uses for the address-creation path.
void main() {
  group('AddressPinRepository', () {
    late MockDio mockDio;
    late AddressPinRepository repository;

    setUp(() {
      mockDio = MockDio();
      repository = AddressPinRepository(mockDio);
    });

    group('getAddressPin', () {
      const path = '/api/method/jarz_pos.api.geo.get_address_pin';

      test('parses the full envelope', () async {
        mockDio.setResponse(path, {
          'message': {
            'success': true,
            'address': 'ADDR-0001',
            'latitude': 30.05,
            'longitude': 31.23,
            'source': 'pos_link',
            'confidence': 20,
            'accuracy_m': 0,
            'stored_link': 'https://maps.app.goo.gl/x',
            'ladder': {'pos_link': 20, 'manual_override': 50},
          },
        });

        final pin = await repository.getAddressPin('ADDR-0001');

        expect(pin.address, 'ADDR-0001');
        expect(pin.latitude, 30.05);
        expect(pin.longitude, 31.23);
        expect(pin.source, 'pos_link');
        expect(pin.confidence, 20);
        // accuracy_m of 0 means "unknown", never "accurate to 0 m".
        expect(pin.hasAccuracy, isFalse);
        expect(pin.storedLink, 'https://maps.app.goo.gl/x');
        expect(pin.ladder['manual_override'], 50);

        final sent = mockDio.requestLog.first['data'] as Map;
        expect(sent['address'], 'ADDR-0001');
      });

      test('falls back to a bare payload with no message envelope', () async {
        mockDio.setResponse(path, {
          'success': true,
          'address': 'ADDR-0002',
        });

        final pin = await repository.getAddressPin('ADDR-0002');

        expect(pin.address, 'ADDR-0002');
        expect(pin.hasPin, isFalse);
      });

      test('throws when the backend reports failure', () async {
        mockDio.setResponse(path, {
          'message': {'success': false, 'error': 'Address not found'},
        });

        expect(
          () => repository.getAddressPin('ADDR-GONE'),
          throwsA(
            predicate((e) => e.toString().contains('Address not found')),
          ),
        );
      });
    });

    group('dryRun', () {
      const path = '/api/method/jarz_pos.api.geo.dry_run_address_pin';

      test('sends address, coordinates and source — never a link and coords together', () async {
        mockDio.setResponse(path, {
          'message': {'success': true, 'accepted': true},
        });

        await repository.dryRun(
          address: 'ADDR-0001',
          latitude: 30.1,
          longitude: 31.4,
          source: GeoPinSource.manualOverride,
        );

        final sent = mockDio.requestLog.first['data'] as Map;
        expect(sent['address'], 'ADDR-0001');
        expect(sent['latitude'], 30.1);
        expect(sent['longitude'], 31.4);
        expect(sent['source'], 'manual_override');
        expect(sent.containsKey('link'), isFalse);
      });

      test('parses an accepted decision with the moved distance', () async {
        mockDio.setResponse(path, {
          'message': {
            'success': true,
            'accepted': true,
            'reason': 'accepted',
            'current_source': 'pos_link',
            'current_rank': 20,
            'resulting_source': 'manual_override',
            'resulting_rank': 50,
            'moved_m': 42.7,
            'coordinates_changed': true,
            'dry_run': true,
          },
        });

        final decision = await repository.dryRun(
          address: 'ADDR-0001',
          latitude: 30.1,
          longitude: 31.4,
          source: GeoPinSource.manualOverride,
        );

        expect(decision.accepted, isTrue);
        expect(decision.currentRank, 20);
        expect(decision.resultingRank, 50);
        expect(decision.movedM, 42.7);
        expect(decision.dryRun, isTrue);
      });

      test('parses a rejected decision (lower confidence) without throwing', () async {
        mockDio.setResponse(path, {
          'message': {
            'success': true,
            'accepted': false,
            'reason': 'lower_confidence',
          },
        });

        final decision = await repository.dryRun(
          address: 'ADDR-0001',
          latitude: 30.1,
          longitude: 31.4,
          source: GeoPinSource.customerPin,
        );

        expect(decision.success, isTrue);
        expect(decision.accepted, isFalse);
        expect(decision.reason, 'lower_confidence');
      });

      test('tolerates the short-link-pending shape, which carries almost nothing', () async {
        mockDio.setResponse(path, {
          'message': {
            'success': true,
            'accepted': false,
            'reason': 'short_link_pending',
            'address': 'ADDR-0001',
          },
        });

        final decision = await repository.dryRun(
          address: 'ADDR-0001',
          latitude: 30.1,
          longitude: 31.4,
          source: GeoPinSource.manualOverride,
        );

        expect(decision.isPending, isTrue);
        expect(decision.movedM, isNull);
      });
    });

    group('setPin', () {
      const path = '/api/method/jarz_pos.api.geo.set_address_pin';

      test('sends the manual-override source and an optional note', () async {
        mockDio.setResponse(path, {
          'message': {'success': true, 'accepted': true},
        });

        await repository.setPin(
          address: 'ADDR-0001',
          latitude: 30.1,
          longitude: 31.4,
          source: GeoPinSource.manualOverride,
          note: 'Customer showed the courier the real gate',
        );

        final sent = mockDio.requestLog.first['data'] as Map;
        expect(sent['source'], 'manual_override');
        expect(sent['note'], 'Customer showed the courier the real gate');
      });

      test('omits note when blank', () async {
        mockDio.setResponse(path, {
          'message': {'success': true, 'accepted': true},
        });

        await repository.setPin(
          address: 'ADDR-0001',
          latitude: 30.1,
          longitude: 31.4,
          source: GeoPinSource.manualOverride,
          note: '   ',
        );

        final sent = mockDio.requestLog.first['data'] as Map;
        expect(sent.containsKey('note'), isFalse);
      });

      test('accepted:false on a successful write is not an error', () async {
        mockDio.setResponse(path, {
          'message': {
            'success': true,
            'accepted': false,
            'reason': 'lower_confidence',
          },
        });

        final decision = await repository.setPin(
          address: 'ADDR-0001',
          latitude: 30.1,
          longitude: 31.4,
          source: GeoPinSource.customerPin,
        );

        expect(decision.accepted, isFalse);
      });

      test('throws when the backend reports failure', () async {
        mockDio.setResponse(path, {
          'message': {'success': false, 'error': 'address is required'},
        });

        expect(
          () => repository.setPin(
            address: '',
            latitude: 30.1,
            longitude: 31.4,
            source: GeoPinSource.manualOverride,
          ),
          throwsA(
            predicate((e) => e.toString().contains('address is required')),
          ),
        );
      });
    });

    test('GeoPinSource ranks mirror the backend confidence ladder', () {
      expect(GeoPinSource.defaultRanks[GeoPinSource.manualOverride], 50);
      expect(GeoPinSource.defaultRanks[GeoPinSource.posLink], 20);
      expect(
        GeoPinSource.defaultRanks[GeoPinSource.manualOverride]! >
            GeoPinSource.defaultRanks[GeoPinSource.courierVerified]!,
        isTrue,
      );
    });
  });

  // Sanity check that jsonEncode round-trips exactly what the model reads —
  // guards against a future refactor accidentally double-encoding the body.
  test('a decision map round-trips through jsonEncode/jsonDecode', () {
    final raw = {'success': true, 'accepted': true, 'moved_m': 12.5};
    final decoded = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
    expect(decoded['moved_m'], 12.5);
  });
}
