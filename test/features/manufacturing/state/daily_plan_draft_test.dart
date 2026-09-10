import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/manufacturing/data/daily_plan_service.dart';
import 'package:jarz_pos/src/features/manufacturing/state/daily_plan_providers.dart';

import '../../../helpers/mock_services.dart';

/// Which day the plan document is filed against.
///
/// The Plan tab carries a date bar, so a run can be recorded for yesterday.
/// The stock entry follows that bar. If the plan document does not, the intent
/// and the ledger sit on different days and the evening comparison — planned
/// against actual — silently compares two different days' work.
///
/// `save_plan` ignores `plan_date` entirely whenever a `name` is passed, so
/// "reuse the name we already have" is not a harmless optimisation across a
/// date change: it writes yesterday's numbers into today's document.
void main() {
  late MockDio dio;
  late ProviderContainer container;

  setUp(() {
    dio = MockDio();
    dio.setResponse(ApiEndpoints.dailyPlanPreview, {
      'message': {
        'mix': {'item_code': 'BASE-MIX', 'batch_qty': 12, 'uom': 'Kg'},
        'total_mix_qty': 6.0,
        'required_batches': 0.5,
        'run_detail': [
          {'size': 1.0, 'quality': 'acceptable'},
        ],
        'run_count': 1,
      },
    });
    container = ProviderContainer(
      overrides: [
        dailyPlanServiceProvider.overrideWithValue(DailyPlanService(dio)),
      ],
    );
    addTearDown(container.dispose);
  });

  /// The body of the most recent save, as the wire saw it.
  Map<String, dynamic> lastSave() {
    final save = dio.requestLog
        .where((entry) => entry['path'] == ApiEndpoints.dailyPlanSave)
        .last;
    return Map<String, dynamic>.from(save['data'] as Map);
  }

  void answerWith(String name, String planDate) {
    dio.setResponse(ApiEndpoints.dailyPlanSave, {
      'message': {'name': name, 'plan_date': planDate},
    });
  }

  test('a back-dated save files against that day, not today', () async {
    answerWith('DPP-0009', '2026-09-09');
    final notifier = container.read(dailyPlanDraftProvider.notifier);
    notifier.setQuantity('LOTUS-M', 60);

    await notifier.save(status: 'Planned', planDate: '2026-09-09');

    final body = lastSave();
    expect(body['plan_date'], '2026-09-09');
    // No name: the backend must find-or-create THAT day's plan. Sending a name
    // here is what would have dragged the numbers into today's document.
    expect(body.containsKey('name'), isFalse);
  });

  test('a clock time on the posting date is trimmed off', () async {
    answerWith('DPP-0009', '2026-09-09');
    final notifier = container.read(dailyPlanDraftProvider.notifier);
    notifier.setQuantity('LOTUS-M', 60);

    await notifier.save(planDate: '2026-09-09 14:30:00');

    expect(lastSave()['plan_date'], '2026-09-09');
  });

  test('saving the same day twice updates the one document', () async {
    answerWith('DPP-0009', '2026-09-09');
    final notifier = container.read(dailyPlanDraftProvider.notifier);
    notifier.setQuantity('LOTUS-M', 60);

    await notifier.save(planDate: '2026-09-09');
    notifier.setQuantity('LOTUS-M', 80);
    await notifier.save(planDate: '2026-09-09');

    // Second save reuses the name, so the morning's plan is amended rather
    // than a second plan being opened for the same day.
    expect(lastSave()['name'], 'DPP-0009');
    expect(lastSave()['plan_date'], '2026-09-09');
  });

  test('moving the date drops the name so the other day gets its own plan',
      () async {
    answerWith('DPP-0009', '2026-09-09');
    final notifier = container.read(dailyPlanDraftProvider.notifier);
    notifier.setQuantity('LOTUS-M', 60);
    await notifier.save(planDate: '2026-09-09');

    answerWith('DPP-0010', '2026-09-10');
    await notifier.save(planDate: '2026-09-10');

    expect(lastSave().containsKey('name'), isFalse);
    expect(lastSave()['plan_date'], '2026-09-10');

    // And the draft now belongs to the new day, so a third save at the same
    // date amends it instead of opening a third document.
    await notifier.save(planDate: '2026-09-10');
    expect(lastSave()['name'], 'DPP-0010');
  });

  test('no date at all keeps the old behaviour', () async {
    // The Today screen saves without a date and must go on reusing its name.
    answerWith('DPP-0009', '2026-09-09');
    final notifier = container.read(dailyPlanDraftProvider.notifier);
    notifier.setQuantity('LOTUS-M', 60);

    await notifier.save();
    await notifier.save();

    expect(lastSave()['name'], 'DPP-0009');
    expect(lastSave().containsKey('plan_date'), isFalse);
  });
}
