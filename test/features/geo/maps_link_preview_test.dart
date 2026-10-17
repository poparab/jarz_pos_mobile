import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/geo/data/models/maps_link_preview.dart';

void main() {
  group('MapsLinkPreview swapped / distance-reference fields', () {
    test('parses the swapped payload', () {
      final preview = MapsLinkPreview.fromJson({
        'success': true,
        'latitude': 30.0444,
        'longitude': 31.2357,
        'precision': 'pos_link',
        'distance_from_branch_m': 4200,
        'distance_reference': 'pos_profile',
        'swapped': true,
        'typed_latitude': '31.2357',
        'typed_longitude': 30.0444,
        'swap_reference': 'Cairo',
        'precision_note': 'قرأنا الزوج كخط الطول ثم العرض',
      });

      expect(preview.isResolved, isTrue);
      expect(preview.swapped, isTrue);
      expect(preview.typedLatitude, 31.2357);
      expect(preview.typedLongitude, 30.0444);
      expect(preview.swapReference, 'Cairo');
      expect(preview.precisionNote, 'قرأنا الزوج كخط الطول ثم العرض');
      expect(preview.distanceReference, 'pos_profile');
      expect(preview.distanceFromBranchM, 4200);
    });

    test('accepts truthy string / number forms of swapped', () {
      for (final raw in <Object>['true', '1', 1, true]) {
        expect(
          MapsLinkPreview.fromJson({'success': true, 'swapped': raw}).swapped,
          isTrue,
          reason: '$raw',
        );
      }
      expect(
        MapsLinkPreview.fromJson({'success': true, 'swapped': false}).swapped,
        isFalse,
      );
    });

    test('an older backend without the keys parses with safe defaults', () {
      final preview = MapsLinkPreview.fromJson({
        'success': true,
        'latitude': 30.0444,
        'longitude': 31.2357,
        'distance_from_branch_m': 1000,
      });

      expect(preview.isResolved, isTrue);
      expect(preview.swapped, isFalse);
      expect(preview.typedLatitude, isNull);
      expect(preview.typedLongitude, isNull);
      expect(preview.swapReference, isNull);
      expect(preview.precisionNote, isNull);
      expect(preview.distanceReference, isNull);
    });

    test('blank or junk values degrade to null, never throw', () {
      final preview = MapsLinkPreview.fromJson({
        'success': true,
        'typed_latitude': 'abc',
        'typed_longitude': null,
        'precision_note': '   ',
        'distance_reference': '',
      });
      expect(preview.typedLatitude, isNull);
      expect(preview.typedLongitude, isNull);
      expect(preview.precisionNote, isNull);
      expect(preview.distanceReference, isNull);
    });

    test('toJson round-trips the new fields', () {
      final original = MapsLinkPreview.fromJson({
        'success': true,
        'latitude': 30.0444,
        'longitude': 31.2357,
        'swapped': true,
        'typed_latitude': 31.2357,
        'typed_longitude': 30.0444,
        'swap_reference': 'Cairo',
        'precision_note': 'note',
        'distance_reference': 'cairo_fallback',
      });
      final copy = MapsLinkPreview.fromJson(original.toJson());

      expect(copy.swapped, isTrue);
      expect(copy.typedLatitude, 31.2357);
      expect(copy.typedLongitude, 30.0444);
      expect(copy.swapReference, 'Cairo');
      expect(copy.precisionNote, 'note');
      expect(copy.distanceReference, 'cairo_fallback');
    });

    test('the failure constructor is never swapped', () {
      const failed = MapsLinkPreview.failure('boom');
      expect(failed.swapped, isFalse);
      expect(failed.distanceReference, isNull);
    });
  });
}
