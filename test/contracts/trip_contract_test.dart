// Contract tests for Delivery Trip API endpoints.
//
// Verifies that DeliveryTrip can deserialize the trip.json fixture.
// Refresh with snapshot_updater.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/trips/models/trip_models.dart';

void main() {
  const fixturesDir = 'test/contracts/fixtures';

  group('Trip Contract — trip response', () {
    test('fixture deserializes to DeliveryTrip without error', () {
      final raw = File('$fixturesDir/trip.json').readAsStringSync();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final trip = DeliveryTrip.fromJson(json);

      expect(trip.name, isNotEmpty,
          reason: 'Trip name must not be empty');
      expect(trip.tripDate, isNotEmpty,
          reason: 'trip_date must not be empty');
      expect(trip.courierPartyType, isNotEmpty,
          reason: 'courier_party_type must not be empty');
      expect(trip.status, isNotEmpty,
          reason: 'status must not be empty');
    });
  });
}
