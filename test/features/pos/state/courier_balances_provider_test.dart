import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/data/models/courier_balance.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/courier_repository.dart';
import 'package:jarz_pos/src/features/pos/state/courier_balances_provider.dart';
import 'package:jarz_pos/src/core/network/courier_service.dart';

// Fake CourierService that returns controllable data
class _FakeCourierService extends CourierService {
  _FakeCourierService() : super(Dio());

  List<Map<String, dynamic>> balancesResult = [];
  bool shouldThrow = false;

  @override
  Future<List<dynamic>> getBalances() async {
    if (shouldThrow) throw Exception('balances error');
    return balancesResult;
  }
}

void main() {
  group('CourierBalancesState', () {
    test('initial() returns empty non-loading state', () {
      final s = CourierBalancesState.initial();
      expect(s.loading, false);
      expect(s.balances, isEmpty);
      expect(s.error, isNull);
    });

    test('hasUnsettled returns true when balance > threshold', () {
      final s = CourierBalancesState(
        loading: false,
        balances: [
          CourierBalance.fromMap({
            'courier': 'EMP-1',
            'balance': 100.0,
            'details': [],
          }),
        ],
      );
      expect(s.hasUnsettled, true);
    });

    test('hasUnsettled returns false when all balances near zero', () {
      final s = CourierBalancesState(
        loading: false,
        balances: [
          CourierBalance.fromMap({
            'courier': 'EMP-1',
            'balance': 0.00001,
            'details': [],
          }),
        ],
      );
      expect(s.hasUnsettled, false);
    });

    test('unsettledCount counts only non-zero balances', () {
      final s = CourierBalancesState(
        loading: false,
        balances: [
          CourierBalance.fromMap({'courier': 'A', 'balance': 50, 'details': []}),
          CourierBalance.fromMap({'courier': 'B', 'balance': 0, 'details': []}),
          CourierBalance.fromMap({'courier': 'C', 'balance': -20, 'details': []}),
        ],
      );
      expect(s.unsettledCount, 2);
    });

    test('copyWith overrides and preserves fields', () {
      final s = CourierBalancesState(
        loading: true,
        balances: [],
        error: 'err',
      );
      final copy = s.copyWith(loading: false);
      expect(copy.loading, false);
      expect(copy.balances, isEmpty);
      // error is set via named param (null default clears it)
      expect(copy.error, isNull);
    });

    test('copyWith preserves error when explicitly provided', () {
      final s = CourierBalancesState(loading: false, balances: []);
      final copy = s.copyWith(error: 'new error');
      expect(copy.error, 'new error');
    });
  });

  group('CourierBalancesNotifier', () {
    test('load() sets balances on success', () async {
      final fake = _FakeCourierService();
      fake.balancesResult = [
        {'courier': 'EMP-1', 'balance': 200, 'details': [], 'party_type': 'Employee', 'party': 'EMP-1'},
      ];
      final repo = CourierRepository(fake);
      final notifier = CourierBalancesNotifier(repo);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.loading, false);
      expect(notifier.state.balances, hasLength(1));
      expect(notifier.state.balances.first.courier, 'EMP-1');
      expect(notifier.state.error, isNull);
    });

    test('load() sets error on failure', () async {
      final fake = _FakeCourierService();
      fake.shouldThrow = true;
      final repo = CourierRepository(fake);
      final notifier = CourierBalancesNotifier(repo);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.loading, false);
      expect(notifier.state.error, isNotNull);
      expect(notifier.state.balances, isEmpty);
    });

    test('load() can be called again to refresh', () async {
      final fake = _FakeCourierService();
      fake.balancesResult = [
        {'courier': 'A', 'balance': 10, 'details': []},
      ];
      final repo = CourierRepository(fake);
      final notifier = CourierBalancesNotifier(repo);
      await Future<void>.delayed(Duration.zero);

      fake.balancesResult = [
        {'courier': 'A', 'balance': 10, 'details': []},
        {'courier': 'B', 'balance': 20, 'details': []},
      ];
      await notifier.load();

      expect(notifier.state.balances, hasLength(2));
    });
  });
}
