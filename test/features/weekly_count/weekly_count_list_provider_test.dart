// The approvals list: pending counts are fetched on their own, so a busy week
// of recent counts can never push a pending one off the screen.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/src/features/weekly_count/data/weekly_count_models.dart';
import 'package:jarz_pos/src/features/weekly_count/data/weekly_count_service.dart';
import 'package:jarz_pos/src/features/weekly_count/presentation/weekly_count_providers.dart';

WeeklyCountSummary _row(String name, String status) =>
    WeeklyCountSummary.fromJson({
      'name': name,
      'pos_profile': 'Maadi',
      'week_start': '2026-10-17',
      'status': status,
    });

class _ListCall {
  _ListCall(this.status, this.limit);
  final String? status;
  final int limit;
}

class _FakeService extends WeeklyCountService {
  _FakeService({required this.pending, required this.recent}) : super(Dio());

  final List<WeeklyCountSummary> pending;
  final List<WeeklyCountSummary> recent;
  final List<_ListCall> calls = [];

  @override
  Future<List<WeeklyCountSummary>> list({
    String? status,
    String? posProfile,
    int limit = 50,
  }) async {
    calls.add(_ListCall(status, limit));
    return status == WeeklyCountDocStatus.pendingApproval ? pending : recent;
  }
}

void main() {
  test('merge keeps pending first and drops the duplicates', () {
    final merged = mergeWeeklyCountLists(
      pending: [_row('P1', 'Pending Approval'), _row('P2', 'Pending Approval')],
      recent: [
        _row('A1', 'Approved'),
        _row('P2', 'Pending Approval'),
        _row('R1', 'Rejected'),
      ],
    );
    expect([for (final r in merged) r.name], ['P1', 'P2', 'A1', 'R1']);
  });

  test('fetches pending (limit 200) apart from the recent history', () async {
    // 50 recent rows, none of them the old pending count.
    final recent = [for (var i = 0; i < 50; i++) _row('A$i', 'Approved')];
    final service = _FakeService(
      pending: [_row('OLD-PENDING', 'Pending Approval')],
      recent: recent,
    );
    final container = ProviderContainer(
      overrides: [weeklyCountServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
    // autoDispose: hold a listener so it lives through the await.
    container.listen(weeklyCountListProvider, (_, _) {});

    final rows = await container.read(weeklyCountListProvider.future);

    expect(rows.first.name, 'OLD-PENDING');
    expect(rows, hasLength(51));
    final pendingCall = service.calls.singleWhere(
      (c) => c.status == WeeklyCountDocStatus.pendingApproval,
    );
    expect(pendingCall.limit, 200);
    final recentCall = service.calls.singleWhere((c) => c.status == null);
    expect(recentCall.limit, 50);
  });
}
