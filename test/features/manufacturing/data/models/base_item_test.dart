import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/base_batch_preview.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/base_item.dart';

/// Wire-shape tests for `subassembly.get_base_items` and
/// `subassembly.preview_base_batch`.
void main() {
  group('BaseItemsPage.fromJson', () {
    test('parses a full row', () {
      final page = BaseItemsPage.fromJson(const {
        'company': 'Jarz',
        'generated_on': '2026-08-28 09:00:00',
        'demand_source': 'plan',
        'items': [
          {
            'item_code': 'BASE-FUDGE',
            'item_name': 'Fudge Cake',
            'item_group': 'Sub Assemblies',
            'stock_uom': 'Kg',
            'default_bom': 'BOM-BASE-FUDGE-001',
            'batch_yield': 9.52,
            'on_hand': 17.136,
            'stock_is_negative': false,
            'batches_on_hand': 1.8,
            'can_make_now_batches': 4,
            'limiting_component': {
              'item_code': 'RM-COCOA',
              'item_name': 'Cocoa',
              'available_qty': 8.0,
              'required_qty': 2.0,
              'is_missing_warehouse': false,
            },
            'run_sizes': [1, 1.5, 2],
            'has_sop': true,
            'sop_total_duration_mins': 95.0,
            'demand': {
              'qty_required': 30.464,
              'batches_required': 3.2,
              'shortfall_batches': 1.4,
              'driver': "today's plan",
            },
          },
        ],
        'summary': {
          'total': 5,
          'short_of_demand': 2,
          'blocked_by_materials': 1,
        },
      });

      expect(page.company, 'Jarz');
      expect(page.demandSource, BaseDemandSource.plan);
      expect(page.hasDemand, isTrue);
      expect(page.items, hasLength(1));
      expect(page.summary.shortOfDemand, 2);
      expect(page.summary.blockedByMaterials, 1);

      final item = page.items.single;
      expect(item.itemCode, 'BASE-FUDGE');
      expect(item.displayName, 'Fudge Cake');
      expect(item.batchYield, 9.52);
      expect(item.batchesOnHand, 1.8);
      expect(item.canMakeNowBatches, 4);
      expect(item.hasSop, isTrue);
      expect(item.sopTotalDurationMins, 95.0);
      expect(item.demand!.batchesRequired, 3.2);
      expect(item.demand!.shortfallBatches, 1.4);
      expect(item.demand!.isShort, isTrue);
      expect(item.demand!.driver, "today's plan");
    });

    test('run_sizes arriving as JSON ints become doubles', () {
      // `[1, 2]` is what a Python list of ints serialises to, and comparing an
      // int against the double batch count would never match.
      final page = BaseItemsPage.fromJson(const {
        'items': [
          {'item_code': 'BASE-A', 'run_sizes': [1, 2]},
        ],
      });
      expect(page.items.single.runSizes, const <double>[1.0, 2.0]);
      expect(page.items.single.runSizes!.first, isA<double>());
    });

    test('a sparse row falls back to safe defaults rather than throwing', () {
      final page = BaseItemsPage.fromJson(const {
        'items': [
          {'item_code': 'BASE-B'},
        ],
      });

      final item = page.items.single;
      expect(item.displayName, 'BASE-B');
      expect(item.batchYield, 1.0);
      expect(item.onHand, 0.0);
      expect(item.runSizes, isNull);
      expect(item.demand, isNull);
      expect(item.hasSop, isFalse);
    });

    test('a null capacity is not the same answer as a zero one', () {
      final skipped = BaseItem.fromJson(const {'item_code': 'A'});
      final blocked =
          BaseItem.fromJson(const {'item_code': 'A', 'can_make_now_batches': 0});

      expect(skipped.canMakeNowBatches, isNull);
      expect(skipped.isBlockedByMaterials, isFalse);
      expect(blocked.isBlockedByMaterials, isTrue);
    });

    test('an absent demand block is a normal answer', () {
      final page = BaseItemsPage.fromJson(const {
        'demand_source': 'none',
        'items': [
          {'item_code': 'BASE-C'},
        ],
      });
      expect(page.hasDemand, isFalse);
      expect(page.items.single.demand, isNull);
    });

    test('safeBatchYield refuses to let a zero yield collapse the maths', () {
      final zero = BaseItem.fromJson(const {'item_code': 'A', 'batch_yield': 0});
      expect(zero.batchYield, 0);
      expect(zero.safeBatchYield, 1.0);
    });

    test('is_missing_warehouse is read as its own flag', () {
      // The reason this model is not the sales board's `LimitingComponent`:
      // that one carries a `reason` string, and reusing it here would read
      // every warehouse gap as an ordinary shortage.
      final missing = BaseLimitingComponent.fromJson(const {
        'item_code': 'RM-X',
        'is_missing_warehouse': true,
      });
      expect(missing.isMissingWarehouse, isTrue);
      expect(missing.displayName, 'RM-X');
    });
  });

  group('BaseBatchPreview', () {
    BaseBatchPreview preview(Map<String, dynamic> overrides) =>
        BaseBatchPreview.fromJson({
          'item_code': 'BASE-FUDGE',
          'bom_name': 'BOM-BASE-FUDGE-001',
          'company': 'Jarz',
          'batches': 2.0,
          'batch_yield': 9.52,
          'item_qty': 19.04,
          'stock_uom': 'Kg',
          'has_shortage': false,
          'run_size_ok': true,
          'has_sop': true,
          ...overrides,
        });

    test('parses the contract shape', () {
      final result = preview(const {
        'components': [
          {
            'item_code': 'RM-COCOA',
            'item_name': 'Cocoa',
            'uom': 'Kg',
            'required_qty': 4.0,
            'available_qty': 10.0,
            'shortfall': 0.0,
            'source_warehouse': 'Stores - J',
          },
        ],
        'estimated_cost': 412.5,
      });

      expect(result.itemQty, 19.04);
      expect(result.batches, 2.0);
      expect(result.estimatedCost, 412.5);
      expect(result.components.single.sourceWarehouse, 'Stores - J');
      expect(result.components.single.isShort, isFalse);
      expect(result.worstShortage, isNull);
    });

    test('worstShortage names the component furthest from covering the run', () {
      // Not merely the first short line in BOM order — the one that actually
      // stops the mixer.
      final result = preview(const {
        'has_shortage': true,
        'components': [
          {
            'item_code': 'RM-SUGAR',
            'item_name': 'Sugar',
            'uom': 'Kg',
            'required_qty': 10.0,
            'available_qty': 9.0, // 90% covered
            'shortfall': 1.0,
          },
          {
            'item_code': 'RM-COCOA',
            'item_name': 'Cocoa',
            'uom': 'Kg',
            'required_qty': 10.0,
            'available_qty': 2.0, // 20% covered
            'shortfall': 8.0,
          },
        ],
      });

      expect(result.worstShortage!.itemCode, 'RM-COCOA');
      expect(result.worstShortage!.displayName, 'Cocoa');
    });

    test('achievableBatches offers a half, not a rounded-down whole', () {
      // A preview at 2 batches wanting 10 kg with 6.25 kg on hand covers 1.25
      // batches → 1 batch runnable... and the sibling covers 2.5, so the
      // tightest wins.
      final result = preview(const {
        'batches': 2.0,
        'has_shortage': true,
        'components': [
          {'item_code': 'A', 'required_qty': 10.0, 'available_qty': 12.5},
          {'item_code': 'B', 'required_qty': 4.0, 'available_qty': 20.0},
        ],
      });
      expect(result.achievableBatches, 2.5);
    });

    test('run_size_ok defaults to true when the server omits it', () {
      // Absent means "no opinion", and a warning nobody asked for is worse
      // than none.
      final result = BaseBatchPreview.fromJson(const {'item_code': 'A'});
      expect(result.runSizeOk, isTrue);
      expect(result.runSizes, isNull);
      expect(result.hasShortage, isFalse);
    });
  });
}
