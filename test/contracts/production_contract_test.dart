// Contract tests for the Production Board API.
//
// Asserts the Dart models still deserialize the shape the backend actually
// returns. A failure here means either `jarz_pos.api.production` changed its
// response, or a model changed without the fixture being refreshed.
//
// Refresh the fixture with: dart test/contracts/snapshot_updater.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/production_suggestion.dart';

void main() {
  const fixturesDir = 'test/contracts/fixtures';

  group('Production Contract — get_production_suggestions', () {
    late Map<String, dynamic> raw;
    late ProductionSuggestionsPage page;

    setUpAll(() {
      raw = jsonDecode(
        File('$fixturesDir/production_suggestions.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      page = ProductionSuggestionsPage.fromJson(raw);
    });

    test('fixture deserializes without error', () {
      expect(page.items, isNotEmpty);
      expect(page.company, isNotEmpty);
    });

    test('planning context the board depends on is present', () {
      // Without these the Plan tab cannot explain any of its numbers.
      for (final key in const [
        'season',
        'default_target_days',
        'thresholds',
        'summary',
        'items',
      ]) {
        expect(raw.containsKey(key), isTrue, reason: '"$key" must be present');
      }
      expect(page.thresholds.criticalDays, greaterThan(0));
      expect(page.thresholds.watchDays,
          greaterThanOrEqualTo(page.thresholds.criticalDays));
      expect(page.defaultTargetDays, greaterThan(0));
    });

    test('every item carries the fields the row renders', () {
      for (final item in raw['items'] as List) {
        final map = item as Map<String, dynamic>;
        for (final key in const [
          'item_code',
          'stock_uom',
          'default_bom',
          'bom_qty',
          'on_hand',
          'velocity_60d',
          'effective_velocity',
          'target_days',
          'days_of_cover',
          'status',
          'suggested_batches',
          'suggested_units',
          'can_make_now_batches',
        ]) {
          expect(map.containsKey(key), isTrue,
              reason: '"$key" missing on ${map['item_code']}');
        }
      }
    });

    test('days_of_cover is nullable and null means never sold', () {
      // The backend must not substitute a 999 sentinel here — that is what the
      // stored jarz_days_of_stock field does, and it makes "never sold"
      // indistinguishable from "enormous pile".
      final noVelocity = page.items.firstWhere((i) => i.hasNoVelocity);
      expect(noVelocity.daysOfCover, isNull);
      expect(noVelocity.suggestedBatches, 0);
    });

    test('a negative-stock item is flagged and its suggestion is not inflated',
        () {
      final negative = page.items.firstWhere((i) => i.stockIsNegative);

      expect(negative.onHand, lessThan(0));
      // Cover clamps at zero — "-4.6 days of cover" means nothing to somebody
      // deciding what to make.
      expect(negative.daysOfCover, 0.0);
      // The suggestion covers forward demand only; the hole is a counting
      // problem, not a backlog to produce against.
      final forwardDemandOnly =
          (negative.targetDays * negative.effectiveVelocity) / negative.bomQty;
      expect(negative.suggestedBatches, forwardDemandOnly.ceil());
    });

    test('status values match the buckets the UI knows how to render', () {
      const known = {
        ProductionStatus.critical,
        ProductionStatus.low,
        ProductionStatus.ok,
        ProductionStatus.overstocked,
        ProductionStatus.noVelocity,
      };
      for (final item in page.items) {
        expect(known, contains(item.status),
            reason: 'unknown status "${item.status}" on ${item.itemCode}');
      }
    });

    test('a materials-capped item exposes the component that caps it', () {
      final capped = page.items.where((i) => i.isCappedByMaterials);
      expect(capped, isNotEmpty,
          reason: 'fixture should cover the capped case');
      for (final item in capped) {
        expect(item.limitingComponent, isNotNull,
            reason: '${item.itemCode} is capped but names no component');
        expect(item.achievableBatches, lessThan(item.suggestedBatches));
      }
    });

    test('summary counts agree with the item list', () {
      final summary = page.summary;
      int count(String status) =>
          page.items.where((i) => i.status == status).length;

      expect(summary.critical, count(ProductionStatus.critical));
      expect(summary.overstocked, count(ProductionStatus.overstocked));
      expect(summary.noVelocity, count(ProductionStatus.noVelocity));
      expect(
        summary.totalSuggestedBatches,
        page.items.fold<int>(0, (sum, i) => sum + i.suggestedBatches),
      );
    });
  });
}
