// Shape checks for the pasted location link.
//
// This layer decides, without a network call, whether text is worth sending to
// the backend resolver at all. Getting it wrong is asymmetric: a false
// "unrecognised" blocks a real address outright, while a false "looks fine"
// costs one wasted round trip and still ends in a clear server error. The tests
// below lock that bias in.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/geo/domain/maps_link_input.dart';

void main() {
  group('normalize', () {
    test('pulls the URL out of a share-sheet forward', () {
      expect(
        MapsLinkInput.normalize('Here you go: https://maps.app.goo.gl/abc123'),
        'https://maps.app.goo.gl/abc123',
      );
    });

    test('drops trailing prose punctuation glued to the link', () {
      expect(
        MapsLinkInput.normalize('see https://maps.app.goo.gl/abc123.'),
        'https://maps.app.goo.gl/abc123',
      );
    });

    test('leaves a bare coordinate pair intact', () {
      expect(MapsLinkInput.normalize('  30.0444, 31.2357  '), '30.0444, 31.2357');
    });

    test('collapses internal whitespace on non-URL text', () {
      expect(MapsLinkInput.normalize('30.0444,\n31.2357'), '30.0444, 31.2357');
    });
  });

  group('parseCoordinates', () {
    test('parses a comma separated pair', () {
      final point = MapsLinkInput.parseCoordinates('30.0444, 31.2357');
      expect(point, isNotNull);
      expect(point!.latitude, closeTo(30.0444, 1e-9));
      expect(point.longitude, closeTo(31.2357, 1e-9));
    });

    test('parses a whitespace separated pair', () {
      expect(MapsLinkInput.parseCoordinates('30.0444 31.2357'), isNotNull);
    });

    test('parses negative values', () {
      final point = MapsLinkInput.parseCoordinates('-33.8688,151.2093');
      expect(point!.latitude, closeTo(-33.8688, 1e-9));
    });

    test('rejects out-of-range values', () {
      expect(MapsLinkInput.parseCoordinates('300.5, 31.2'), isNull);
      expect(MapsLinkInput.parseCoordinates('30.5, 999.2'), isNull);
    });

    test('rejects Null Island, which is what a failed parse looks like', () {
      expect(MapsLinkInput.parseCoordinates('0, 0'), isNull);
    });

    test('rejects a URL', () {
      expect(
        MapsLinkInput.parseCoordinates('https://maps.app.goo.gl/abc123'),
        isNull,
      );
    });

    test('rejects prose and phone numbers', () {
      expect(MapsLinkInput.parseCoordinates('behind the mosque'), isNull);
      expect(MapsLinkInput.parseCoordinates('01001234567'), isNull);
    });
  });

  group('looksResolvable', () {
    test('accepts a long Google Maps URL', () {
      expect(
        MapsLinkInput.looksResolvable(
          'https://www.google.com/maps/place/Cairo/@30.0444,31.2357,15z',
        ),
        isTrue,
      );
    });

    test('accepts a short maps.app.goo.gl link', () {
      expect(
        MapsLinkInput.looksResolvable('https://maps.app.goo.gl/abc123'),
        isTrue,
      );
    });

    test('accepts a scheme-less short link', () {
      expect(MapsLinkInput.looksResolvable('maps.app.goo.gl/abc123'), isTrue);
    });

    test('accepts bare coordinates', () {
      expect(MapsLinkInput.looksResolvable('30.0444, 31.2357'), isTrue);
    });

    test('rejects free text', () {
      expect(MapsLinkInput.looksResolvable('next to the pharmacy'), isFalse);
    });

    test('rejects empty input', () {
      expect(MapsLinkInput.looksResolvable('   '), isFalse);
    });
  });
}
