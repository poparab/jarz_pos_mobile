import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/fleet/data/models/fleet_models.dart';

/// A response shaped exactly like the documented `get_live_positions` envelope.
Map<String, dynamic> _envelope({
  List<Map<String, dynamic>> couriers = const [],
  String asOf = '2026-08-08 19:40:00',
  int ttlSeconds = 900,
}) {
  return {
    'success': true,
    'count': couriers.length,
    'ttl_seconds': ttlSeconds,
    'branches': [
      {
        'branch': 'Nasr city',
        'as_of': asOf,
        'ttl_seconds': ttlSeconds,
        'count': couriers.length,
        'couriers': couriers,
      },
    ],
  };
}

final _fetchedAt = DateTime(2026, 8, 8, 19, 40, 0);

void main() {
  group('position parsing', () {
    test('accepts the current lat/lng spelling', () {
      final snapshot = FleetSnapshot.fromJson(
        _envelope(
          couriers: [
            {
              'courier': 'COUR-001',
              'courier_name': 'Ahmed',
              'lat': 30.05,
              'lng': 31.24,
              'ts': '2026-08-08 19:37:00',
              'accuracy_m': 12.5,
            },
          ],
        ),
        fetchedAt: _fetchedAt,
      );

      final courier = snapshot.located.single;
      expect(courier.id, 'COUR-001');
      expect(courier.displayName, 'Ahmed');
      expect(courier.branch, 'Nasr city');
      expect(courier.point!.latitude, 30.05);
      expect(courier.point!.longitude, 31.24);
      expect(courier.accuracyMeters, 12.5);
    });

    test('accepts the older latitude/longitude spelling', () {
      // The backend takes both on the way in, and an older app build in the
      // wild still posts the long form — so it can come back out either way.
      final snapshot = FleetSnapshot.fromJson(
        _envelope(
          couriers: [
            {
              'courier': 'COUR-002',
              'latitude': 30.06,
              'longitude': 31.25,
              'ts': '2026-08-08 19:39:00',
            },
          ],
        ),
        fetchedAt: _fetchedAt,
      );

      final courier = snapshot.located.single;
      expect(courier.point!.latitude, 30.06);
      expect(courier.point!.longitude, 31.25);
    });

    test('parses numeric strings', () {
      final snapshot = FleetSnapshot.fromJson(
        _envelope(
          couriers: [
            {
              'courier': 'COUR-003',
              'lat': '30.07',
              'lng': '31.26',
              'accuracy_m': '8',
              'ts': '2026-08-08 19:39:00',
            },
          ],
        ),
        fetchedAt: _fetchedAt,
      );

      final courier = snapshot.located.single;
      expect(courier.point!.latitude, 30.07);
      expect(courier.accuracyMeters, 8);
    });

    test('keeps a courier whose position is missing instead of throwing', () {
      final snapshot = FleetSnapshot.fromJson(
        _envelope(
          couriers: [
            {'courier': 'COUR-004', 'courier_name': 'Mona'},
          ],
        ),
        fetchedAt: _fetchedAt,
      );

      expect(snapshot.located, isEmpty);
      expect(snapshot.unlocated.single.displayName, 'Mona');
      expect(snapshot.unlocated.single.hasFix, isFalse);
    });

    test('treats unparseable, out-of-range and 0/0 fixes as absent', () {
      final snapshot = FleetSnapshot.fromJson(
        _envelope(
          couriers: [
            {'courier': 'A', 'lat': 'not-a-number', 'lng': 'x'},
            {'courier': 'B', 'lat': 999, 'lng': 31.2},
            {'courier': 'C', 'lat': 30.1, 'lng': 500},
            {'courier': 'D', 'lat': 0, 'lng': 0},
            {'courier': 'E', 'lat': null, 'lng': null},
          ],
        ),
        fetchedAt: _fetchedAt,
      );

      expect(snapshot.couriers, hasLength(5));
      expect(snapshot.located, isEmpty);
    });

    test('falls back to the id when no name is supplied', () {
      final snapshot = FleetSnapshot.fromJson(
        _envelope(
          couriers: [
            {'party': 'Sayed Ali', 'lat': 30.0, 'lng': 31.0},
          ],
        ),
        fetchedAt: _fetchedAt,
      );

      expect(snapshot.located.single.displayName, 'Sayed Ali');
      expect(snapshot.located.single.id, 'Sayed Ali');
    });

    test('degrades to one ungrouped branch when branches is absent', () {
      final snapshot = FleetSnapshot.fromJson({
        'success': true,
        'ttl_seconds': 900,
        'as_of': '2026-08-08 19:40:00',
        'couriers': [
          {'courier': 'COUR-009', 'lat': 30.0, 'lng': 31.0},
        ],
      }, fetchedAt: _fetchedAt);

      expect(snapshot.located, hasLength(1));
      expect(snapshot.located.single.branch, isEmpty);
    });

    test('falls back to the default TTL when the payload omits it', () {
      final snapshot = FleetSnapshot.fromJson({
        'success': true,
        'branches': [
          {
            'branch': 'Nasr city',
            'couriers': [
              {'courier': 'X', 'lat': 30.0, 'lng': 31.0},
            ],
          },
        ],
      }, fetchedAt: _fetchedAt);

      expect(snapshot.ttl, kFleetDefaultTtl);
      expect(snapshot.located.single.ttl, kFleetDefaultTtl);
    });
  });

  group('fix age', () {
    test('is measured server-side, so a wrong device clock cannot lie', () {
      // as_of - ts = 3 minutes. The device clock is deliberately hours out.
      final snapshot = FleetSnapshot.fromJson(
        _envelope(
          asOf: '2026-08-08 19:40:00',
          couriers: [
            {
              'courier': 'COUR-005',
              'lat': 30.0,
              'lng': 31.0,
              'ts': '2026-08-08 19:37:00',
            },
          ],
        ),
        fetchedAt: DateTime(2026, 8, 8, 12, 0, 0),
      );

      final courier = snapshot.located.single;
      // "Now" is one minute after the response landed on this wrong clock.
      final age = courier.ageAt(DateTime(2026, 8, 8, 12, 1, 0));
      expect(age, const Duration(minutes: 4));
    });

    test('keeps counting up as local time passes without a new poll', () {
      final snapshot = FleetSnapshot.fromJson(
        _envelope(
          couriers: [
            {
              'courier': 'COUR-006',
              'lat': 30.0,
              'lng': 31.0,
              'ts': '2026-08-08 19:39:00',
            },
          ],
        ),
        fetchedAt: _fetchedAt,
      );
      final courier = snapshot.located.single;

      expect(courier.ageAt(_fetchedAt), const Duration(minutes: 1));
      expect(
        courier.ageAt(_fetchedAt.add(const Duration(minutes: 9))),
        const Duration(minutes: 10),
      );
    });

    test('falls back to the device clock when as_of is unusable', () {
      final snapshot = FleetSnapshot.fromJson(
        _envelope(
          asOf: 'nonsense',
          couriers: [
            {
              'courier': 'COUR-007',
              'lat': 30.0,
              'lng': 31.0,
              'ts': '2026-08-08 19:35:00',
            },
          ],
        ),
        fetchedAt: _fetchedAt,
      );

      expect(
        snapshot.located.single.ageAt(DateTime(2026, 8, 8, 19, 40, 0)),
        const Duration(minutes: 5),
      );
    });

    test('never reports a negative age', () {
      final snapshot = FleetSnapshot.fromJson(
        _envelope(
          asOf: '2026-08-08 19:40:00',
          couriers: [
            {
              'courier': 'COUR-008',
              'lat': 30.0,
              'lng': 31.0,
              'ts': '2026-08-08 19:45:00',
            },
          ],
        ),
        fetchedAt: _fetchedAt,
      );

      expect(snapshot.located.single.ageAt(_fetchedAt), Duration.zero);
    });

    test('is null when the fix carried no timestamp', () {
      final snapshot = FleetSnapshot.fromJson(
        _envelope(
          couriers: [
            {'courier': 'COUR-010', 'lat': 30.0, 'lng': 31.0},
          ],
        ),
        fetchedAt: _fetchedAt,
      );

      expect(snapshot.located.single.ageAt(_fetchedAt), isNull);
      expect(snapshot.located.single.freshnessAt(_fetchedAt), isNull);
    });
  });

  group('freshness bucketing', () {
    const ttl = Duration(seconds: 900);

    test('splits the TTL into thirds', () {
      expect(
        fleetFreshnessFor(const Duration(minutes: 1), ttl),
        FleetFreshness.fresh,
      );
      expect(
        fleetFreshnessFor(const Duration(minutes: 4, seconds: 59), ttl),
        FleetFreshness.fresh,
      );
      expect(
        fleetFreshnessFor(const Duration(minutes: 5), ttl),
        FleetFreshness.ageing,
      );
      expect(
        fleetFreshnessFor(const Duration(minutes: 9, seconds: 59), ttl),
        FleetFreshness.ageing,
      );
      expect(
        fleetFreshnessFor(const Duration(minutes: 10), ttl),
        FleetFreshness.stale,
      );
      // Past the TTL entirely: Redis has already dropped it.
      expect(
        fleetFreshnessFor(const Duration(minutes: 20), ttl),
        FleetFreshness.stale,
      );
    });

    test('respects a shorter server-supplied TTL', () {
      const shortTtl = Duration(seconds: 300);
      expect(
        fleetFreshnessFor(const Duration(minutes: 3), shortTtl),
        FleetFreshness.ageing,
      );
      expect(
        fleetFreshnessFor(const Duration(minutes: 3), ttl),
        FleetFreshness.fresh,
      );
    });

    test('treats a nonsense TTL as the default rather than making all stale', () {
      expect(
        fleetFreshnessFor(const Duration(minutes: 1), Duration.zero),
        FleetFreshness.fresh,
      );
    });

    test('legend thresholds match the buckets', () {
      expect(
        fleetFreshnessThreshold(FleetFreshness.ageing, ttl).inMinutes,
        5,
      );
      expect(fleetFreshnessThreshold(FleetFreshness.stale, ttl).inMinutes, 10);
    });

    test('worst freshness drives the header warning', () {
      final snapshot = FleetSnapshot.fromJson(
        _envelope(
          couriers: [
            {
              'courier': 'fresh',
              'lat': 30.0,
              'lng': 31.0,
              'ts': '2026-08-08 19:39:00',
            },
            {
              'courier': 'stale',
              'lat': 30.1,
              'lng': 31.1,
              'ts': '2026-08-08 19:25:00',
            },
          ],
        ),
        fetchedAt: _fetchedAt,
      );

      expect(snapshot.worstFreshnessAt(_fetchedAt), FleetFreshness.stale);
    });
  });

  group('empty reasons', () {
    test('no courier at all is a staffing problem', () {
      final snapshot = FleetSnapshot.fromJson(
        _envelope(),
        fetchedAt: _fetchedAt,
      );
      expect(snapshot.emptyReason, FleetEmptyReason.noCouriers);
    });

    test('an empty branch list is also "no couriers"', () {
      final snapshot = FleetSnapshot.fromJson({
        'success': true,
        'count': 0,
        'ttl_seconds': 900,
        'branches': <dynamic>[],
      }, fetchedAt: _fetchedAt);
      expect(snapshot.emptyReason, FleetEmptyReason.noCouriers);
    });

    test('couriers with no usable fix is a device problem', () {
      final snapshot = FleetSnapshot.fromJson(
        _envelope(
          couriers: [
            {'courier': 'COUR-011', 'courier_name': 'Hany'},
          ],
        ),
        fetchedAt: _fetchedAt,
      );
      expect(snapshot.emptyReason, FleetEmptyReason.noPositions);
    });

    test('is null once one courier can be drawn', () {
      final snapshot = FleetSnapshot.fromJson(
        _envelope(
          couriers: [
            {'courier': 'a', 'lat': 30.0, 'lng': 31.0},
            {'courier': 'b'},
          ],
        ),
        fetchedAt: _fetchedAt,
      );
      expect(snapshot.emptyReason, isNull);
      expect(snapshot.located, hasLength(1));
      expect(snapshot.unlocated, hasLength(1));
    });
  });
}
