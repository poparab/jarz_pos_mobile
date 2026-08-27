import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/leads/data/models/lead.dart';
import 'package:jarz_pos/src/features/visits/data/models/visit_plan.dart';
import 'package:jarz_pos/src/features/visits/presentation/visit_navigation.dart';

/// Model + navigation tests for the visit planner.
///
/// The decoding half is the usual contract check against the shapes
/// `jarz_pos.api.visits` returns. The navigation half is the more interesting
/// one: the Google Maps handoff is a hand-built URL, and the two ways to get
/// it wrong — coordinate order, and silently exceeding the waypoint cap — both
/// fail in the car rather than on screen.

VisitStop _stop({
  String name = 'row1',
  String title = 'Cafe',
  String branch = '',
  double? lat = 30.0,
  double? lng = 31.0,
  String status = 'Planned',
}) =>
    VisitStop(
      name: name,
      title: title,
      branchName: branch,
      latitude: lat,
      longitude: lng,
      status: status,
    );

void main() {
  group('VisitPlan.fromJson', () {
    final json = <String, dynamic>{
      'name': 'VPL-2026-00007',
      'visit_date': '2026-08-29',
      'rep': 'rep@jarz.com',
      'rep_name': 'Sales Rep',
      'title': 'Maadi run',
      'status': 'Planned',
      'start_mode': 'Fixed Point',
      'start_label': 'Current location',
      'start_latitude': 29.96,
      'start_longitude': 31.25,
      'planned_start_time': '10:00:00',
      'default_visit_minutes': 25,
      'return_to_start': 1,
      'total_stops': 2,
      'total_distance_km': 18.4,
      'total_drive_minutes': 51,
      'total_duration_minutes': 101,
      'route_engine': 'osrm',
      'optimized_on': '2026-08-26 21:00:00',
      'notes': 'Start after the delivery run',
      'can_edit': true,
      'stops': [
        {
          'name': 'row1',
          'idx': 1,
          'reference_doctype': 'Lead',
          'reference_name': 'CRM-LEAD-0001',
          'title': 'Bean There',
          'branch_name': 'Maadi',
          'area': 'Maadi',
          'status': 'Visited',
          'latitude': 29.96,
          'longitude': 31.25,
          'planned_time': '10:00:00',
          'visit_minutes': 25,
          'locked': 1,
          'leg_km': 0.0,
          'leg_minutes': 0,
          'arrived_at': '2026-08-29 10:05:00',
          'outcome': 'Took two sample jars',
          'journey_note': 'JRN-2026-00099',
        },
        {
          'name': 'row2',
          'idx': 2,
          'reference_name': 'CRM-LEAD-0002',
          'title': 'Zamalek Roasters',
          'branch_name': 'Zamalek',
          'status': 'Planned',
          'latitude': 30.0614,
          'longitude': 31.2197,
          'leg_km': 18.4,
          'leg_minutes': 51,
        },
      ],
    };

    test('maps every field', () {
      final plan = VisitPlan.fromJson(json);
      expect(plan.name, 'VPL-2026-00007');
      expect(plan.visitDate, '2026-08-29');
      expect(plan.title, 'Maadi run');
      expect(plan.returnToStart, isTrue);
      expect(plan.totalDistanceKm, 18.4);
      expect(plan.routeEngine, 'osrm');
      expect(plan.stops, hasLength(2));
      expect(plan.stops.first.locked, isTrue);
      expect(plan.stops.first.journeyNote, 'JRN-2026-00099');
    });

    test('an empty payload decodes to safe defaults', () {
      final plan = VisitPlan.fromJson({'name': 'VPL-1'});
      expect(plan.stops, isEmpty);
      expect(plan.totalDistanceKm, 0);
      expect(plan.routeEngine, 'haversine');
      expect(plan.status, 'Draft');
    });

    test('reports whether the numbers are road distances', () {
      expect(VisitPlan.fromJson(json).hasRoadDistances, isTrue);
      expect(
        VisitPlan.fromJson({'name': 'x', 'route_engine': 'haversine'})
            .hasRoadDistances,
        isFalse,
      );
    });

    test('nextStop is the first unresolved stop in route order', () {
      final plan = VisitPlan.fromJson(json);
      expect(plan.nextStop?.name, 'row2');
    });

    test('nextStop is null once the day is done', () {
      final plan = VisitPlan(
        name: 'x',
        stops: [_stop(status: 'Visited'), _stop(name: 'b', status: 'Skipped')],
      );
      expect(plan.nextStop, isNull);
    });

    test('progress counts resolved stops and ignores cancelled ones', () {
      final plan = VisitPlan(
        name: 'x',
        stops: [
          _stop(name: 'a', status: 'Visited'),
          _stop(name: 'b', status: 'Planned'),
          _stop(name: 'c', status: 'Cancelled'),
        ],
      );
      expect(plan.progress, 0.5);
    });

    test('an empty plan reports zero progress rather than NaN', () {
      expect(const VisitPlan(name: 'x').progress, 0.0);
    });
  });

  group('VisitStop', () {
    test('displayTitle names the branch when it differs from the brand', () {
      expect(_stop(title: 'Bean There', branch: 'Maadi').displayTitle,
          'Bean There — Maadi');
    });

    test('displayTitle does not repeat the brand as its own branch', () {
      expect(_stop(title: 'Bean There', branch: 'bean there').displayTitle,
          'Bean There');
      expect(_stop(title: 'Bean There').displayTitle, 'Bean There');
    });

    test('a stop with no pin reports it', () {
      expect(_stop(lat: null, lng: null).hasLocation, isFalse);
      expect(_stop().hasLocation, isTrue);
    });

    test('toPayload carries the row name so identity survives a reorder', () {
      // Without `name` the server would treat every row as new on a reorder,
      // dropping the check-in, outcome and diary link with it.
      final payload = _stop(name: 'row9').toPayload();
      expect(payload['name'], 'row9');
      expect(payload['locked'], 0);
    });
  });

  group('VisitTarget', () {
    test('key distinguishes two doors of one brand', () {
      const maadi = VisitTarget(
          referenceName: 'LEAD-1',
          title: 'Bean There',
          branchName: 'Maadi',
          latitude: 29.9601,
          longitude: 31.2569);
      const zamalek = VisitTarget(
          referenceName: 'LEAD-1',
          title: 'Bean There',
          branchName: 'Zamalek',
          latitude: 30.0614,
          longitude: 31.2197);
      expect(maadi.key, isNot(zamalek.key));
      expect(maadi.key, 'Lead:LEAD-1:29.96010,31.25690');
    });

    test('two branches sharing a NAME are still two doors', () {
      // Chains name every branch after the chain. A label-keyed selection
      // merged them and the rep lost a real address off the route.
      const first = VisitTarget(
          referenceName: 'LEAD-9',
          branchName: 'T-LAB',
          latitude: 29.9601,
          longitude: 31.2569);
      const second = VisitTarget(
          referenceName: 'LEAD-9',
          branchName: 'T-LAB',
          latitude: 30.0614,
          longitude: 31.2197);
      expect(first.key, isNot(second.key));
    });

    test('the same pin under two names is one door', () {
      const a = VisitTarget(
          referenceName: 'LEAD-9',
          branchName: 'Maadi',
          latitude: 29.9601,
          longitude: 31.2569);
      const b = VisitTarget(
          referenceName: 'LEAD-9',
          branchName: 'Maadi Branch',
          latitude: 29.9601,
          longitude: 31.2569);
      expect(a.key, b.key);
    });

    test('carries its reasoning, not just a score', () {
      final target = VisitTarget.fromJson({
        'reference_name': 'LEAD-1',
        'priority': 132.5,
        'reasons': ['fit 60', 'never visited', 'follow-up 4d overdue'],
      });
      expect(target.priority, 132.5);
      expect(target.reasons, contains('never visited'));
      expect(target.neverVisited, isTrue);
    });
  });

  group('RouteEngineStatus', () {
    test('separates unconfigured from unreachable', () {
      const unconfigured = RouteEngineStatus(configured: false);
      const down =
          RouteEngineStatus(configured: true, reachable: false);
      expect(unconfigured.summary, 'Estimated distances');
      expect(down.summary, contains('unreachable'));
    });

    test('road distances are announced as such', () {
      const live = RouteEngineStatus(
          configured: true, reachable: true, engine: 'osrm');
      expect(live.usesRoadDistances, isTrue);
      expect(live.summary, 'Road distances');
    });
  });

  group('RoutePreview', () {
    final json = <String, dynamic>{
      'engine': 'haversine',
      'total_distance_km': 12.5,
      'total_drive_minutes': 34,
      'total_duration_minutes': 154,
      'skipped': 1,
      'order': [1, 0],
      'stops': [
        {
          'key': 'Lead:L1:29.96010,31.25690',
          'title': 'Bean There',
          'branch_name': 'Maadi',
          'area': 'Maadi',
          'reference_name': 'L1',
          'latitude': 29.9601,
          'longitude': 31.2569,
          'position': 1,
          'leg_km': 0.0,
          'leg_minutes': 0,
          'locked': 1,
        },
        {
          'key': 'Lead:L2:30.06140,31.21970',
          'title': 'Zamalek Roasters',
          'reference_name': 'L2',
          'latitude': 30.0614,
          'longitude': 31.2197,
          'position': 2,
          'leg_km': 12.5,
          'leg_minutes': 34,
        },
      ],
    };

    test('maps the ordered stops and the totals', () {
      final preview = RoutePreview.fromJson(json);
      expect(preview.stops, hasLength(2));
      expect(preview.totalDistanceKm, 12.5);
      expect(preview.totalDurationMinutes, 154);
      expect(preview.stops.first.position, 1);
      expect(preview.stops.last.legKm, 12.5);
    });

    test('surfaces doors that were skipped for having no pin', () {
      // Skipped rather than refused, but never silent: a stop missing from a
      // route is the exact failure this feature exists to avoid.
      expect(RoutePreview.fromJson(json).skipped, 1);
    });

    test('a Frappe Check arrives as 1 and still decodes', () {
      expect(RoutePreview.fromJson(json).stops.first.locked, isTrue);
    });

    test('an empty payload decodes to an empty day', () {
      final preview = RoutePreview.fromJson(const <String, dynamic>{});
      expect(preview.isEmpty, isTrue);
      expect(preview.totalDistanceKm, 0);
      expect(preview.engine, 'haversine');
    });

    test('reads the day length in hours, not three-digit minutes', () {
      expect(RoutePreview.fromJson(json).durationLabel, '2h 34m');
      expect(
        RoutePreview.fromJson({'total_duration_minutes': 120}).durationLabel,
        '2h',
      );
      expect(
        RoutePreview.fromJson({'total_duration_minutes': 45}).durationLabel,
        '45m',
      );
    });

    test('reports whether the numbers are road distances', () {
      expect(RoutePreview.fromJson(json).hasRoadDistances, isFalse);
      expect(
        RoutePreview.fromJson({'engine': 'osrm'}).hasRoadDistances,
        isTrue,
      );
    });

    test('a preview stop can be sent straight back as a plan stop', () {
      // The builder saves what the preview showed, so this payload has to be
      // the shape create_visit_plan accepts.
      final payload = RoutePreview.fromJson(json).stops.first.toStopPayload();
      expect(payload['reference_name'], 'L1');
      expect(payload['latitude'], 29.9601);
      expect(payload['branch_name'], 'Maadi');
      expect(payload['locked'], 1);
    });

    test('displayTitle disambiguates a branch from its brand', () {
      final preview = RoutePreview.fromJson(json);
      expect(preview.stops.first.displayTitle, 'Bean There — Maadi');
      expect(preview.stops.last.displayTitle, 'Zamalek Roasters');
    });
  });

  group('LeadLocation', () {
    test('decodes a branch pin from the catalog row', () {
      final lead = Lead.fromJson({
        'name': 'LEAD-1',
        'locations': [
          {
            'branch_name': 'Maadi',
            'area': 'Maadi',
            'latitude': 29.96,
            'longitude': 31.25,
            'maps_url': 'https://maps.example/1',
          }
        ],
      });
      expect(lead.locations, hasLength(1));
      expect(lead.locations.first.branchName, 'Maadi');
      expect(lead.locations.first.hasPin, isTrue);
    });

    test('a catalog row with no branches still decodes', () {
      final lead = Lead.fromJson({'name': 'LEAD-2'});
      expect(lead.locations, isEmpty);
    });

    test('(0, 0) is not a place', () {
      const nowhere = LeadLocation(latitude: 0, longitude: 0);
      expect(nowhere.hasPin, isFalse);
    });
  });

  group('VisitNavigation', () {
    VisitPlan planWith(int stops, {bool withStart = true}) => VisitPlan(
          name: 'x',
          startLatitude: withStart ? 30.0 : null,
          startLongitude: withStart ? 31.0 : null,
          stops: [
            for (var i = 0; i < stops; i++)
              _stop(name: 'row$i', lat: 30.0 + i * 0.01, lng: 31.0 + i * 0.01),
          ],
        );

    test('a short route fits in one handoff', () {
      expect(VisitNavigation.fitsInOneHandoff(planWith(5)), isTrue);
    });

    test('a long route does not, and says how much it can take', () {
      final plan = planWith(20);
      expect(VisitNavigation.fitsInOneHandoff(plan), isFalse);
      expect(
        VisitNavigation.navigableStopCount(plan),
        VisitNavigation.maxWaypoints + 2,
      );
    });

    test('cancelled and unlocated stops are not navigable', () {
      final plan = VisitPlan(
        name: 'x',
        stops: [
          _stop(name: 'a'),
          _stop(name: 'b', status: 'Cancelled'),
          _stop(name: 'c', lat: null, lng: null),
        ],
      );
      expect(VisitNavigation.navigableStopCount(plan), 1);
    });

    test('an empty plan is navigable zero stops, not an error', () {
      expect(VisitNavigation.navigableStopCount(const VisitPlan(name: 'x')), 0);
    });
  });
}
