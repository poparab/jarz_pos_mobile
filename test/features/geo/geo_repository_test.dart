import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/geo/data/repositories/geo_repository.dart';

import '../../helpers/mock_services.dart';

/// `preview_maps_link`, including the ticket poll that makes it work at all for
/// the link staff actually paste.
///
/// The Android share sheet produces a shortener — `maps.app.goo.gl/…`,
/// `share.google/…` — and a shortener carries no coordinates until its redirect
/// chain is followed. The backend refuses to follow it inside the request (an
/// inline redirect fetch lets any paste occupy a web worker), so it answers
/// with `pending` plus a `request_id` and expands in a background job. Without
/// the poll below the field reported "could not read a location from this link"
/// for every normal paste, which is precisely how it was reported from the
/// floor.
void main() {
  const path = '/api/method/jarz_pos.api.geo.preview_maps_link';

  group('GeoRepository.previewMapsLink', () {
    late MockDio mockDio;

    setUp(() => mockDio = MockDio());

    GeoRepository build({void Function(int attempt)? onWait}) {
      var attempt = 0;
      return GeoRepository(
        mockDio,
        pollWait: (_) async => onWait?.call(++attempt),
      );
    }

    test('a long URL resolves on the first call and never polls', () async {
      mockDio.setResponse(path, {
        'message': {
          'success': true,
          'resolved': true,
          'pending': false,
          'latitude': 30.0444,
          'longitude': 31.2357,
          'precision': 'pin',
        },
      });

      final preview = await build().previewMapsLink(
        'https://www.google.com/maps/place/X/@30.0444,31.2357,17z',
      );

      expect(preview.isResolved, isTrue);
      expect(preview.pending, isFalse);
      expect(preview.point?.latitude, closeTo(30.0444, 1e-6));
      expect(mockDio.requestLog.length, 1);
      expect(
        (mockDio.requestLog.single['data'] as Map)[GeoRepository.linkParam],
        'https://www.google.com/maps/place/X/@30.0444,31.2357,17z',
      );
    });

    test('polls a short link ticket until the worker answers', () async {
      mockDio.setResponse(path, {
        'message': {
          'success': true,
          'resolved': false,
          'pending': true,
          'short_link': true,
          'request_id': 'a' * 32,
          'reason': 'short_link_pending',
        },
      });

      // The wait hook doubles as the script: the ticket is still pending on the
      // first poll and carries the expanded point on the second.
      final repository = build(
        onWait: (attempt) {
          if (attempt < 2) return;
          mockDio.setResponse(path, {
            'message': {
              'success': true,
              'resolved': true,
              'pending': false,
              'request_id': 'a' * 32,
              'latitude': 30.05,
              'longitude': 31.24,
              'precision': 'pin',
            },
          });
        },
      );

      final preview = await repository.previewMapsLink(
        'https://maps.app.goo.gl/aBcDeF123',
      );

      expect(preview.isResolved, isTrue);
      expect(preview.point?.longitude, closeTo(31.24, 1e-6));
      // First call carries the link; every one after it carries the ticket, so
      // a poll can never spend another expansion from the user's budget.
      expect(mockDio.requestLog.length, 3);
      for (final request in mockDio.requestLog.skip(1)) {
        final data = request['data'] as Map;
        expect(data[GeoRepository.requestIdParam], 'a' * 32);
        expect(data.containsKey(GeoRepository.linkParam), isFalse);
      }
    });

    test('gives up after the poll budget and reports it unresolved', () async {
      mockDio.setResponse(path, {
        'message': {
          'success': true,
          'resolved': false,
          'pending': true,
          'short_link': true,
          'request_id': 'b' * 32,
        },
      });

      final preview = await build().previewMapsLink(
        'https://share.google/aBcDeF123',
      );

      // Still pending, but not resolved — the field shows its error rather than
      // waiting on a shortener that is not going to answer.
      expect(preview.isResolved, isFalse);
      expect(preview.pending, isTrue);
    });

    test('a pending ticket with no id is terminal, not an infinite poll', () async {
      mockDio.setResponse(path, {
        'message': {'success': true, 'resolved': false, 'pending': true},
      });

      final preview = await build().previewMapsLink(
        'https://maps.app.goo.gl/aBcDeF123',
      );

      expect(preview.isResolved, isFalse);
      expect(mockDio.requestLog.length, 1);
    });

    test('an expired ticket comes back as a plain failure', () async {
      mockDio.setResponse(path, {
        'message': {
          'success': false,
          'resolved': false,
          'pending': false,
          'reason': 'request_expired',
        },
      });

      final preview = await build().previewMapsLink(
        'https://maps.app.goo.gl/aBcDeF123',
      );

      expect(preview.success, isFalse);
      expect(preview.isResolved, isFalse);
    });
  });
}
