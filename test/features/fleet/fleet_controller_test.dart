import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/fleet/data/fleet_repository.dart';
import 'package:jarz_pos/src/features/fleet/data/models/fleet_models.dart';
import 'package:jarz_pos/src/features/fleet/state/fleet_providers.dart';

class _FakeFleetRepository extends FleetRepository {
  _FakeFleetRepository({this.error, this.couriers = const []}) : super(Dio());

  Object? error;
  List<Map<String, dynamic>> couriers;

  int calls = 0;
  final List<String?> branches = [];

  @override
  Future<FleetSnapshot> getLivePositions({String? branch}) async {
    calls++;
    branches.add(branch);
    final failure = error;
    if (failure != null) throw failure;
    return FleetSnapshot.fromJson({
      'success': true,
      'ttl_seconds': 900,
      'branches': [
        {
          'branch': 'Nasr city',
          'as_of': '2026-08-08 19:40:00',
          'ttl_seconds': 900,
          'couriers': couriers,
        },
      ],
    }, fetchedAt: DateTime(2026, 8, 8, 19, 40));
  }
}

final _oneCourier = [
  {
    'courier': 'COUR-1',
    'lat': 30.0,
    'lng': 31.0,
    'ts': '2026-08-08 19:39:00',
  },
];

/// Runs [body] against a live controller and always tears its timer down.
///
/// The controller is built directly rather than through
/// `fleetControllerProvider`: that provider is `autoDispose`, so a container
/// `read` with no listener disposes it again immediately and the polling under
/// test never happens. Provider wiring is covered by the screen tests, which
/// hold a real listener.
Future<void> _withController(
  _FakeFleetRepository repository,
  Future<void> Function(FleetController controller) body, {
  String? branch,
}) async {
  final controller = FleetController(repository: repository, branch: branch);
  try {
    await body(controller);
  } finally {
    controller.dispose();
  }
}

void main() {
  // `testWidgets` supplies a fake clock, so `tester.pump(duration)` drives the
  // poll timer deterministically instead of sleeping in real time.
  testWidgets('loads once as soon as it is created', (tester) async {
    final repository = _FakeFleetRepository(couriers: _oneCourier);

    await _withController(repository, (controller) async {
      await tester.pump();

      expect(repository.calls, 1);
      expect(controller.state.snapshot, isNotNull);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.isRefreshing, isFalse);
    });
  });

  testWidgets('polls on the interval while active', (tester) async {
    final repository = _FakeFleetRepository();

    await _withController(repository, (controller) async {
      await tester.pump();
      expect(repository.calls, 1);

      await tester.pump(kFleetPollInterval);
      expect(repository.calls, 2);

      await tester.pump(kFleetPollInterval);
      expect(repository.calls, 3);
    });
  });

  testWidgets('stops polling entirely when the screen is hidden', (
    tester,
  ) async {
    final repository = _FakeFleetRepository();

    await _withController(repository, (controller) async {
      await tester.pump();
      expect(repository.calls, 1);

      controller.setActive(false);
      expect(controller.isPolling, isFalse);

      // A dispatcher leaves this screen open all day; while it is covered or
      // backgrounded it must cost the server nothing.
      await tester.pump(kFleetPollInterval * 5);
      expect(repository.calls, 1);

      // Coming back catches up at once instead of waiting a whole interval.
      controller.setActive(true);
      await tester.pump();
      expect(repository.calls, 2);
      expect(controller.isPolling, isTrue);
    });
  });

  testWidgets('a 403 is terminal and stops the poll', (tester) async {
    final repository = _FakeFleetRepository(
      error: const FleetPermissionDeniedException(),
    );

    await _withController(repository, (controller) async {
      await tester.pump();

      expect(controller.state.isPermissionDenied, isTrue);
      expect(controller.isPolling, isFalse);

      await tester.pump(kFleetPollInterval * 3);
      // Retrying can never turn a non-supervisor into one.
      expect(repository.calls, 1);
    });
  });

  testWidgets('a failed poll keeps the last known positions', (tester) async {
    final repository = _FakeFleetRepository(couriers: _oneCourier);

    await _withController(repository, (controller) async {
      await tester.pump();
      final first = controller.state.snapshot;
      expect(first, isNotNull);

      repository.error = Exception('network down');
      await tester.pump(kFleetPollInterval);

      // The map must not blank out: the dots stay put and age towards stale on
      // their own, which is the honest reading when the server goes quiet.
      expect(controller.state.snapshot, same(first));
      expect(controller.state.error, isNotNull);
      expect(controller.state.isShowingStaleAfterFailure, isTrue);
      // A plain network failure is transient, so polling continues.
      expect(controller.isPolling, isTrue);
    });
  });

  testWidgets('a later success clears the error', (tester) async {
    final repository = _FakeFleetRepository(error: Exception('boom'));

    await _withController(repository, (controller) async {
      await tester.pump();
      expect(controller.state.error, isNotNull);

      repository.error = null;
      await controller.refresh();
      await tester.pump();

      expect(controller.state.error, isNull);
      expect(controller.state.snapshot, isNotNull);
      expect(controller.state.isShowingStaleAfterFailure, isFalse);
    });
  });

  testWidgets('passes the branch scope straight through', (tester) async {
    final repository = _FakeFleetRepository();

    await _withController(repository, branch: 'Nasr city', (controller) async {
      await tester.pump();
      expect(repository.branches, ['Nasr city']);
    });
  });

  testWidgets('disposing cancels the timer', (tester) async {
    final repository = _FakeFleetRepository();
    final controller = FleetController(repository: repository);
    await tester.pump();
    expect(controller.isPolling, isTrue);

    controller.dispose();
    expect(controller.isPolling, isFalse);
  });

  group('repository', () {
    test('maps a 403 to the terminal permission error', () async {
      final dio = Dio();
      dio.httpClientAdapter = _StatusAdapter(403);

      await expectLater(
        FleetRepository(dio).getLivePositions(),
        throwsA(isA<FleetPermissionDeniedException>()),
      );
    });

    test('leaves other failures alone', () async {
      final dio = Dio();
      dio.httpClientAdapter = _StatusAdapter(500);

      await expectLater(
        FleetRepository(dio).getLivePositions(),
        throwsA(isA<DioException>()),
      );
    });
  });
}

class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.statusCode);

  final int statusCode;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString('{"exc_type":"PermissionError"}', statusCode);
  }
}
