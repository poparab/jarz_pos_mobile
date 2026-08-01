import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/basket_rollup.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/production_suggestion.dart';

void main() {
  group('ProductionSuggestion.fromJson', () {
    test('parses the documented backend shape', () {
      final json = {
        'item_code': 'PIST-CAKE',
        'item_name': 'Pistachio cake',
        'stock_uom': 'Nos',
        'default_bom': 'BOM-PIST-CAKE',
        'bom_qty': 10.0,
        'on_hand': 20.0,
        'velocity_30d': 4.0,
        'velocity_60d': 5.0,
        'velocity_trend': 'Rising',
        'season_multiplier': 1.8,
        'effective_velocity': 9.0,
        'target_days': 10,
        'target_days_source': 'default',
        'days_of_cover': 2.22,
        'status': 'critical',
        'suggested_batches': 7,
        'suggested_units': 70.0,
        'can_make_now_batches': 3,
        'limiting_component': {
          'item_code': 'PIST-SPR',
          'item_name': 'Pistachio spread',
          'uom': 'Kg',
          'available_qty': 5.5,
          'reason': 'insufficient_stock',
        },
      };

      final suggestion = ProductionSuggestion.fromJson(json);

      expect(suggestion.itemCode, 'PIST-CAKE');
      expect(suggestion.status, ProductionStatus.critical);
      expect(suggestion.suggestedBatches, 7);
      expect(suggestion.canMakeNowBatches, 3);
      expect(suggestion.limitingComponent?.itemCode, 'PIST-SPR');
      expect(suggestion.seasonMultiplier, 1.8);
    });

    test('a null days_of_cover survives as null, not zero', () {
      // Null is "never sells" and must stay distinguishable from a real 0.
      final suggestion = ProductionSuggestion.fromJson({
        'item_code': 'DEAD',
        'days_of_cover': null,
        'status': 'no_velocity',
      });

      expect(suggestion.daysOfCover, isNull);
      expect(suggestion.hasNoVelocity, isTrue);
    });

    test('integer JSON numbers coerce to double', () {
      // Frappe emits whole floats as ints; a hard `as double` would throw.
      final suggestion = ProductionSuggestion.fromJson({
        'item_code': 'X',
        'on_hand': 20,
        'bom_qty': 10,
        'days_of_cover': 3,
      });

      expect(suggestion.onHand, 20.0);
      expect(suggestion.bomQty, 10.0);
      expect(suggestion.daysOfCover, 3.0);
    });

    test('a sparse payload falls back to defaults instead of throwing', () {
      final suggestion = ProductionSuggestion.fromJson({'item_code': 'X'});

      expect(suggestion.itemName, '');
      expect(suggestion.suggestedBatches, 0);
      expect(suggestion.canMakeNowBatches, isNull);
      expect(suggestion.limitingComponent, isNull);
    });
  });

  group('achievableBatches', () {
    test('is the suggestion when materials are not the constraint', () {
      const suggestion = ProductionSuggestion(
        suggestedBatches: 5,
        canMakeNowBatches: 9,
      );
      expect(suggestion.achievableBatches, 5);
      expect(suggestion.isCappedByMaterials, isFalse);
    });

    test('is the capacity when materials are the constraint', () {
      const suggestion = ProductionSuggestion(
        suggestedBatches: 5,
        canMakeNowBatches: 3,
      );
      expect(suggestion.achievableBatches, 3);
      expect(suggestion.isCappedByMaterials, isTrue);
    });

    test('unknown capacity means unconstrained', () {
      const suggestion = ProductionSuggestion(suggestedBatches: 5);
      expect(suggestion.achievableBatches, 5);
      expect(suggestion.isCappedByMaterials, isFalse);
    });

    test('zero capacity blocks the line entirely', () {
      const suggestion = ProductionSuggestion(
        suggestedBatches: 5,
        canMakeNowBatches: 0,
      );
      expect(suggestion.achievableBatches, 0);
      expect(suggestion.isCappedByMaterials, isTrue);
    });
  });

  group('isActionable', () {
    test('critical and low with work to do are actionable', () {
      for (final status in [ProductionStatus.critical, ProductionStatus.low]) {
        expect(
          ProductionSuggestion(status: status, suggestedBatches: 1).isActionable,
          isTrue,
          reason: status,
        );
      }
    });

    test('covered, overstocked and never-sold are not', () {
      for (final status in [
        ProductionStatus.ok,
        ProductionStatus.overstocked,
        ProductionStatus.noVelocity,
      ]) {
        expect(
          ProductionSuggestion(status: status, suggestedBatches: 3).isActionable,
          isFalse,
          reason: status,
        );
      }
    });

    test('a critical item with nothing to make is not actionable', () {
      const suggestion = ProductionSuggestion(
        status: ProductionStatus.critical,
        suggestedBatches: 0,
      );
      expect(suggestion.isActionable, isFalse);
    });
  });

  group('ProductionSuggestionsPage', () {
    test('parses the envelope and summarises', () {
      final page = ProductionSuggestionsPage.fromJson({
        'company': 'Jarz Co',
        'season': {'name': 'Ramadan', 'multiplier': 1.8},
        'default_target_days': 10,
        'thresholds': {
          'critical_days': 5,
          'watch_days': 14,
          'overstock_days': 90,
        },
        'velocity_updated_on': '2026-07-28 03:00:00',
        'items': [
          {'item_code': 'A', 'status': 'critical', 'suggested_batches': 2},
        ],
        'summary': {
          'critical': 1,
          'low': 2,
          'total_suggested_batches': 9,
          'capped_by_materials': 1,
        },
      });

      expect(page.season.name, 'Ramadan');
      expect(page.season.multiplier, 1.8);
      expect(page.thresholds.criticalDays, 5);
      expect(page.items, hasLength(1));
      expect(page.summary.actionable, 3);
      expect(page.summary.cappedByMaterials, 1);
    });

    test('an empty payload yields a usable page', () {
      final page = ProductionSuggestionsPage.fromJson(const {});
      expect(page.items, isEmpty);
      expect(page.season.multiplier, 1.0);
      expect(page.defaultTargetDays, 7);
      expect(page.velocityUpdatedOn, isNull);
    });
  });

  group('BasketRollup', () {
    test('parses shortages with their contributing lines', () {
      final rollup = BasketRollup.fromJson({
        'ok': false,
        'components': [
          {
            'item_code': 'FLOUR',
            'item_name': 'Flour',
            'uom': 'Kg',
            'source_warehouse': 'Raw Material - J',
            'required_qty': 12.0,
            'available_qty': 10.0,
            'missing_qty': 2.0,
            'reason': 'insufficient_stock',
            'contributing_lines': [
              {'line_index': 0, 'item_code': 'CAKE-A', 'required_qty': 6.0},
              {'line_index': 1, 'item_code': 'CAKE-B', 'required_qty': 6.0},
            ],
          },
        ],
        'shortages': [
          {
            'item_code': 'FLOUR',
            'missing_qty': 2.0,
            'reason': 'insufficient_stock',
          },
        ],
        'max_feasible_scale': 0.83,
      });

      expect(rollup.ok, isFalse);
      expect(rollup.hasShortages, isTrue);
      expect(rollup.components.first.isSharedAcrossLines, isTrue);
      expect(rollup.components.first.contributingLines, hasLength(2));
      expect(rollup.maxFeasibleScale, 0.83);
    });

    test('a feasible basket parses as ok with no shortages', () {
      final rollup = BasketRollup.fromJson({
        'ok': true,
        'components': [
          {'item_code': 'FLOUR', 'required_qty': 4.0, 'available_qty': 100.0},
        ],
        'shortages': const [],
        'max_feasible_scale': 1.0,
      });

      expect(rollup.hasShortages, isFalse);
      expect(rollup.components.first.isShort, isFalse);
      expect(rollup.components.first.isSharedAcrossLines, isFalse);
    });

    test('a missing source warehouse is flagged distinctly from a shortfall', () {
      final component = RollupComponent.fromJson({
        'item_code': 'FLOUR',
        'required_qty': 4.0,
        'available_qty': 0.0,
        'reason': 'missing_source_warehouse',
      });

      expect(component.isMissingWarehouse, isTrue);
      expect(component.isShort, isTrue);
    });
  });
}
