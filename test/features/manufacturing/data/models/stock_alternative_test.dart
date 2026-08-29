import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/base_batch_preview.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/base_item.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/basket_rollup.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/production_suggestion.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/stock_alternative.dart';

/// Wire-shape tests for the `available_elsewhere` / `alternatives` pair the
/// backend attaches to a shortage.
///
/// The one thing every case here is protecting: absent, zero-with-an-empty-list
/// and populated are THREE answers. Defaulting the fields to zero would fuse
/// the first two, and the UI would then claim "there is none anywhere" on every
/// server that never ran the lookup.
void main() {
  group('the three states, on every model that carries them', () {
    test('absent stays null on all four carriers', () {
      final limiting = LimitingComponent.fromJson(const {'item_code': 'RM-X'});
      final baseLimiting =
          BaseLimitingComponent.fromJson(const {'item_code': 'RM-X'});
      final previewComponent =
          BasePreviewComponent.fromJson(const {'item_code': 'RM-X'});
      final rollupComponent =
          RollupComponent.fromJson(const {'item_code': 'RM-X'});

      for (final pair in <(double?, List<StockAlternative>?)>[
        (limiting.availableElsewhere, limiting.alternatives),
        (baseLimiting.availableElsewhere, baseLimiting.alternatives),
        (previewComponent.availableElsewhere, previewComponent.alternatives),
        (rollupComponent.availableElsewhere, rollupComponent.alternatives),
      ]) {
        expect(pair.$1, isNull);
        expect(pair.$2, isNull);
      }
    });

    test('an explicit null is still "nobody looked", not a zero', () {
      final component = RollupComponent.fromJson(const {
        'item_code': 'RM-X',
        'available_elsewhere': null,
        'alternatives': null,
      });

      expect(component.availableElsewhere, isNull);
      expect(component.alternatives, isNull);
    });

    test('zero with an empty list survives as a real answer', () {
      final component = BasePreviewComponent.fromJson(const {
        'item_code': 'RM-X',
        'shortfall': 4.0,
        'available_elsewhere': 0.0,
        'alternatives': <Map<String, dynamic>>[],
      });

      expect(component.availableElsewhere, 0.0);
      expect(component.alternatives, isEmpty);
      expect(component.alternatives, isNotNull);
    });

    test('populated alternatives parse with their warehouses', () {
      final limiting = LimitingComponent.fromJson(const {
        'item_code': 'RM-LABEL',
        'item_name': 'Jar label',
        'uom': 'Nos',
        'source_warehouse': 'Raw Material - J',
        'required_qty': 8.0,
        'available_qty': 0.0,
        'reason': 'insufficient_stock',
        'available_elsewhere': 48.5,
        'alternatives': [
          {'warehouse': 'Stores - J', 'available_qty': 40.5},
          {'warehouse': 'Nasr City - J', 'available_qty': 8.0},
        ],
      });

      expect(limiting.availableElsewhere, 48.5);
      expect(limiting.alternatives, hasLength(2));
      expect(limiting.alternatives!.first.warehouse, 'Stores - J');
      expect(limiting.alternatives!.first.availableQty, 40.5);
    });

    test('integer JSON quantities coerce to double', () {
      // Frappe emits whole floats as ints; a hard `as double` would throw and
      // the whole shortage payload would fail to deserialise.
      final limiting = BaseLimitingComponent.fromJson(const {
        'item_code': 'RM-X',
        'available_elsewhere': 12,
        'alternatives': [
          {'warehouse': 'Stores - J', 'available_qty': 12},
        ],
      });

      expect(limiting.availableElsewhere, 12.0);
      expect(limiting.alternatives!.single.availableQty, 12.0);
      expect(limiting.alternatives!.single.availableQty, isA<double>());
    });

    test('a bare alternative row falls back to safe defaults', () {
      final alternative = StockAlternative.fromJson(const {});
      expect(alternative.warehouse, '');
      expect(alternative.availableQty, 0.0);
    });

    test('the new fields do not disturb the existing shortage shape', () {
      // The block must keep working exactly as before: a shortage with
      // alternatives is still a shortage.
      final rollup = BasketRollup.fromJson(const {
        'ok': false,
        'components': [
          {
            'item_code': 'RM-LABEL',
            'uom': 'Nos',
            'required_qty': 8.0,
            'available_qty': 0.0,
            'missing_qty': 8.0,
            'reason': 'insufficient_stock',
            'available_elsewhere': 40.5,
            'alternatives': [
              {'warehouse': 'Stores - J', 'available_qty': 40.5},
            ],
          },
        ],
        'shortages': [
          {
            'item_code': 'RM-LABEL',
            'missing_qty': 8.0,
            'available_elsewhere': 40.5,
            'alternatives': [
              {'warehouse': 'Stores - J', 'available_qty': 40.5},
            ],
          },
        ],
      });

      expect(rollup.hasShortages, isTrue);
      expect(rollup.components.single.isShort, isTrue);
      expect(rollup.shortages.single.alternatives, hasLength(1));
    });
  });
}
