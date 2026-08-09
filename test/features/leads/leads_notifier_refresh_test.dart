// How the leads catalog revalidates.
//
// Every filter in this feature — tier, stage, suitability — runs client-side
// against a Hive-cached catalog, so the filters are only ever as truthful as
// the last fetch. That makes automatic revalidation load-bearing rather than a
// nicety, and it puts two requirements on refresh():
//
//   * it must not blank the list while it runs, or the automatic calls would
//     flash a spinner over a rep's screen every time they open the page;
//   * a failed background revalidation must not destroy a catalog the rep is
//     already reading.
//
// Hive is pointed at a scratch directory per test. Leaving it uninitialised
// looks tempting — the notifier wraps every cache read and write — but Hive
// reports the failure through an unobserved async error that the test binding
// then fails the test on, regardless of the catch. A real temp box also makes
// these tests exercise the cache write the production path actually performs.
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:jarz_pos/src/features/leads/data/leads_repository.dart';
import 'package:jarz_pos/src/features/leads/data/models/lead.dart';
import 'package:jarz_pos/src/features/leads/state/leads_notifier.dart';

/// A repository whose every call is scripted, so a test can make the second
/// fetch fail without touching Dio.
class _FakeLeadsRepository implements LeadsRepository {
  _FakeLeadsRepository(this._responses);

  final List<Object> _responses; // List<Lead> to return, or Object to throw
  int calls = 0;

  @override
  Future<List<Lead>> getLeads({String? category, String? status}) async {
    final response = _responses[calls.clamp(0, _responses.length - 1)];
    calls++;
    if (response is List<Lead>) return response;
    throw response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not used in these tests');
}

const _first = [Lead(name: 'L-1', leadName: 'First')];
const _second = [
  Lead(name: 'L-1', leadName: 'First'),
  Lead(name: 'L-2', leadName: 'Second'),
];

ProviderContainer _containerFor(_FakeLeadsRepository repo) {
  final container = ProviderContainer(
    overrides: [leadsRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  late Directory hiveDir;

  setUp(() {
    hiveDir = Directory.systemTemp.createTempSync('leads_notifier_test');
    Hive.init(hiveDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (hiveDir.existsSync()) hiveDir.deleteSync(recursive: true);
  });

  group('LeadsNotifier.refresh', () {
    test('picks up server-side changes without any manual action', () async {
      final repo = _FakeLeadsRepository([_first, _second]);
      final container = _containerFor(repo);

      expect(await container.read(leadsProvider.future), _first);

      await container.read(leadsProvider.notifier).refresh();

      expect(container.read(leadsProvider).value, _second);
      expect(repo.calls, 2);
    });

    test('keeps the current rows visible while revalidating', () async {
      final repo = _FakeLeadsRepository([_first, _second]);
      final container = _containerFor(repo);
      await container.read(leadsProvider.future);

      final pending = container.read(leadsProvider.notifier).refresh();

      // Mid-flight the state is loading BUT still carries the old rows, which
      // is what stops the list blanking to a spinner on every auto-refresh.
      final midFlight = container.read(leadsProvider);
      expect(midFlight.isLoading, isTrue);
      expect(midFlight.value, _first,
          reason: 'a bare AsyncValue.loading() would have dropped the rows');

      await pending;
    });

    test('a failed revalidation keeps the last good catalog', () async {
      final repo = _FakeLeadsRepository([_first, Exception('network down')]);
      final container = _containerFor(repo);
      await container.read(leadsProvider.future);

      await container.read(leadsProvider.notifier).refresh();

      final state = container.read(leadsProvider);
      expect(state.hasError, isFalse,
          reason: 'a background failure must not blank a list being read');
      expect(state.value, _first);
    });

    test('an error still surfaces when there is nothing to fall back on',
        () async {
      final repo = _FakeLeadsRepository([Exception('network down')]);
      final container = _containerFor(repo);

      await expectLater(
        container.read(leadsProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(leadsProvider).hasError, isTrue);
    });

    test('repeated refreshes are safe and each one re-fetches', () async {
      final repo = _FakeLeadsRepository([_first, _second, _second]);
      final container = _containerFor(repo);
      await container.read(leadsProvider.future);

      await container.read(leadsProvider.notifier).refresh();
      await container.read(leadsProvider.notifier).refresh();

      expect(repo.calls, 3);
      expect(container.read(leadsProvider).value, _second);
    });
  });
}
