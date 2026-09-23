import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/production_round/data/models/production_round.dart';
import 'package:jarz_pos/src/features/production_round/data/production_round_service.dart';
import 'package:jarz_pos/src/features/production_round/presentation/widgets/production_round_format.dart';

import '../../../helpers/mock_services.dart';
import '../production_round_fixture.dart';

void main() {
  group('ProductionRound.fromJson', () {
    late ProductionRound round;

    setUp(() => round = ProductionRound.fromJson(productionRoundFixture()));

    test('reads the header figures, ints and doubles alike', () {
      expect(round.cycleDays, 14);
      expect(round.backupDays, 7);
      expect(round.coverDays, 21);
      expect(round.salesWeeks, 8);
      expect(round.batchSizes, {'Medium': 120.0, 'Large': 77.0});
      expect(round.summary.batches['Medium'], 2.5);
      expect(round.summary.batches['Large'], 5.25);
      expect(round.summary.jars['Large'], 404.0);
      expect(round.summary.neededNowCount, 6);
      expect(round.summary.missingCount, 5);
      expect(round.summary.blockedCount, 9);
      expect(round.generatedAt, DateTime(2026, 9, 23, 18));
      expect(round.notices, ['BOM missing for Date Large']);
    });

    test('orders sizes Medium then Large', () {
      expect(round.sizes, ['Medium', 'Large']);
      expect(round.itemsOfSize('Large').map((i) => i.flavour), [
        'Blueberry',
        'Date',
      ]);
    });

    test('parses items, statuses and the per-branch rows', () {
      final blueberry = round.items.first;
      expect(blueberry.status, ProductionRoundStatus.now);
      expect(blueberry.isToMake, isTrue);
      expect(blueberry.isBlocked, isTrue);
      expect(blueberry.factoryOnHand, 76.0);
      expect(blueberry.totalFill, 139.0);
      expect(blueberry.jars, 77.0);

      final nasr = blueberry.branches.first;
      expect(nasr.daysOfCover, 0.2);
      expect(nasr.belowBackup, isTrue);
      expect(nasr.stockIsNegative, isFalse);

      // 0/1 flags and a null days_of_cover must not throw.
      final dokki = blueberry.branches[1];
      expect(dokki.daysOfCover, isNull);
      expect(dokki.belowBackup, isTrue);
      expect(dokki.stockIsNegative, isTrue);
      expect(dokki.onHand, -4.0);

      expect(round.items[1].status, ProductionRoundStatus.noSales);
      expect(round.items[3].status, ProductionRoundStatus.covered);
      expect(round.items[3].isToMake, isFalse);
    });

    test('prep keeps only rows that ask for work', () {
      expect(round.prepToDo.map((p) => p.itemCode), [
        'Butter Biscuit',
        'Cheese Mix',
      ]);
      expect(round.prep.first.batches, 0.91);
      expect(round.prep[1].madeFresh, isTrue);
    });

    test('materials: missing filter, lookup and coverage', () {
      expect(round.missingMaterials.map((m) => m.itemCode), ['Jar Lid 330']);
      final lid = round.materialFor('Jar Lid 330')!;
      expect(lid.missing, 230.0);
      expect(lid.coverage, closeTo(174 / 404, 1e-9));
      expect(round.materialFor('Sugar')!.coverage, 1.0);
      expect(round.materialFor('nope'), isNull);
    });

    test('an empty payload falls back to safe defaults', () {
      final empty = ProductionRound.fromJson(const {});
      expect(empty.items, isEmpty);
      expect(empty.materials, isEmpty);
      expect(empty.summary.batches, isEmpty);
      expect(empty.sizes, isEmpty);
      expect(empty.generatedAt, isNull);
    });

    test('null and malformed numbers do not blank the payload', () {
      final odd = ProductionRound.fromJson({
        'cycle_days': '21',
        'summary': {
          'batches': {'Medium': null},
          'needed_now_count': null,
        },
        'items': [
          {'item_code': 'X', 'batches': null, 'blocked_by': null},
          'not a map',
        ],
      });
      expect(odd.cycleDays, 21);
      expect(odd.summary.batches['Medium'], 0.0);
      expect(odd.summary.neededNowCount, 0);
      expect(odd.items, hasLength(1));
      expect(odd.items.single.batches, 0.0);
      expect(odd.items.single.blockedBy, isEmpty);
    });
  });

  group('formatting', () {
    test('batches drop trailing zeros', () {
      expect(fmtBatches(0.25), '0.25');
      expect(fmtBatches(0.5), '0.5');
      expect(fmtBatches(1), '1');
      expect(fmtBatches(1.5), '1.5');
      expect(fmtBatches(5.25), '5.25');
    });

    test('materials: Nos as integers, weights with up to 2 decimals', () {
      expect(fmtMaterialQty(404.0, 'Nos'), '404');
      expect(fmtMaterialQty(1120, 'Nos'), '1,120');
      expect(fmtMaterialQty(12.43, 'Kg'), '12.43 Kg');
      expect(fmtMaterialQty(18.456, 'Kg'), '18.46 Kg');
      expect(fmtMaterialQty(40, 'Kg'), '40 Kg');
    });
  });

  group('ProductionRoundService', () {
    test(
      'reads the message envelope and forwards only the set knobs',
      () async {
        final dio = MockDio();
        dio.setResponse(
          ApiEndpoints.getProductionRound,
          createSuccessResponse(data: productionRoundFixture()),
        );
        final round = await ProductionRoundService(
          dio,
        ).getRound(cycleDays: 21, salesWeeks: 12);

        expect(round.summary.jars['Medium'], 300.0);
        final query =
            dio.requestLog.single['queryParameters'] as Map<String, dynamic>;
        expect(query, {'cycle_days': 21, 'sales_weeks': 12});
      },
    );
  });
}
