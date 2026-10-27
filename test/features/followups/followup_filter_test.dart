import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/followups/data/followup_filter.dart';
import 'package:jarz_pos/src/features/followups/data/models/followup_models.dart';

void main() {
  const call = FollowupRow(
    name: 'T1',
    customerName: 'Mona Ali',
    phone: '01012345678',
    step: 'day2',
    channel: FollowupChannel.call,
    isOverdue: true,
    customerType: 'Repeat',
    valueBand: 'High',
    customerSegment: 'Champions',
    rfmIsRegular: true,
    territory: 'Maadi',
  );
  const message = FollowupRow(
    name: 'T2',
    customerName: 'Omar Hassan',
    whatsappMsisdn: '201098765432',
    step: 'day32',
    customerType: 'New',
    valueBand: 'Low',
    territory: 'Nasr City',
  );
  const rows = [call, message];

  List<String> names(FollowupFilter f) =>
      f.apply(rows).map((r) => r.name).toList();

  test('no filter keeps everything', () {
    expect(FollowupFilter.none.isActive, isFalse);
    expect(names(FollowupFilter.none), ['T1', 'T2']);
  });

  test('each field narrows', () {
    expect(names(const FollowupFilter(channel: FollowupChannel.call)), ['T1']);
    expect(names(const FollowupFilter(overdueOnly: true)), ['T1']);
    expect(names(const FollowupFilter(customerType: 'New')), ['T2']);
    expect(names(const FollowupFilter(valueBand: 'High')), ['T1']);
    expect(names(const FollowupFilter(regularOnly: true)), ['T1']);
    expect(names(const FollowupFilter(step: 'day32')), ['T2']);
    expect(names(const FollowupFilter(segment: 'Champions')), ['T1']);
    expect(names(const FollowupFilter(territory: 'Nasr City')), ['T2']);
  });

  test('search by name and by phone in either format', () {
    expect(names(const FollowupFilter(query: 'omar')), ['T2']);
    expect(names(const FollowupFilter(query: '+20 101 234')), ['T1']);
    expect(names(const FollowupFilter(query: '01098765')), ['T2']);
    expect(names(const FollowupFilter(query: 'nobody')), isEmpty);
  });

  test('copyWith clears nullable fields only when asked', () {
    const f = FollowupFilter(channel: FollowupChannel.call, territory: 'Maadi');
    expect(f.copyWith(overdueOnly: true).channel, FollowupChannel.call);
    expect(f.copyWith(clearChannel: true).channel, isNull);
    expect(f.copyWith(clearTerritory: true).territory, isNull);
    expect(
      f.copyWith(clearChannel: true, clearTerritory: true).isActive,
      isFalse,
    );
  });

  test('options list distinct values, steps in plan order', () {
    final o = FollowupFilterOptions.of(const [
      message,
      call,
      FollowupRow(name: 'T3', step: '3h'),
    ]);
    expect(o.steps, ['3h', 'day2', 'day32']);
    expect(o.segments, ['Champions']);
    expect(o.territories, ['Maadi', 'Nasr City']);
  });
}
