import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/purchase/domain/request_allocation.dart';

/// Allocation decides which team request gets credited as received. Getting it
/// wrong closes a request nobody fulfilled, so every branch is covered here.
void main() {
  RequestAllocationTarget target(String id, double qty) =>
      RequestAllocationTarget(
        materialRequest: 'MAT-MR-${id.padLeft(4, '0')}',
        materialRequestItem: 'row-$id',
        outstandingQty: qty,
      );

  group('allocateAcrossRequests', () {
    test('an unrequested purchase is a single unlinked row', () {
      final rows = allocateAcrossRequests(10, const []);
      expect(rows, hasLength(1));
      expect(rows.single.qty, 10);
      expect(rows.single.isLinked, isFalse);
    });

    test('buying exactly what was requested fills every target', () {
      final rows = allocateAcrossRequests(40, [target('1', 25), target('2', 15)]);
      expect(rows, hasLength(2));
      expect(rows[0].qty, 25);
      expect(rows[0].materialRequestItem, 'row-1');
      expect(rows[1].qty, 15);
      expect(rows[1].materialRequestItem, 'row-2');
      expect(rows.every((r) => r.isLinked), isTrue);
    });

    test('buying less fills targets in order and leaves the rest outstanding',
        () {
      // 30 of 40 requested: the first request is satisfied, the second gets
      // only part and stays on the buying list.
      final rows = allocateAcrossRequests(30, [target('1', 25), target('2', 15)]);
      expect(rows, hasLength(2));
      expect(rows[0].qty, 25);
      expect(rows[1].qty, 5);
      expect(rows[1].materialRequestItem, 'row-2');
    });

    test('buying much less touches only the first target', () {
      final rows = allocateAcrossRequests(10, [target('1', 25), target('2', 15)]);
      expect(rows, hasLength(1));
      expect(rows.single.qty, 10);
      expect(rows.single.materialRequestItem, 'row-1');
    });

    test('surplus becomes an unlinked row, never credited to a request', () {
      // Crediting the surplus would close a request as having received more
      // than it asked for.
      final rows = allocateAcrossRequests(50, [target('1', 25), target('2', 15)]);
      expect(rows, hasLength(3));
      expect(rows[0].qty, 25);
      expect(rows[1].qty, 15);
      expect(rows[2].qty, closeTo(10, 0.0001));
      expect(rows[2].isLinked, isFalse);
    });

    test('total allocated always equals what was purchased', () {
      for (final purchased in [1.0, 10.0, 39.9, 40.0, 40.1, 100.0]) {
        final rows =
            allocateAcrossRequests(purchased, [target('1', 25), target('2', 15)]);
        final total = rows.fold<double>(0, (sum, row) => sum + row.qty);
        expect(total, closeTo(purchased, 0.0001),
            reason: 'purchased $purchased must be fully accounted for');
      }
    });

    test('zero and negative purchases allocate nothing', () {
      expect(allocateAcrossRequests(0, [target('1', 25)]), isEmpty);
      expect(allocateAcrossRequests(-5, [target('1', 25)]), isEmpty);
    });

    test('targets with nothing outstanding are skipped', () {
      final rows = allocateAcrossRequests(10, [target('1', 0), target('2', 15)]);
      expect(rows, hasLength(1));
      expect(rows.single.materialRequestItem, 'row-2');
    });

    test('fractional quantities do not leave a phantom surplus row', () {
      // Float arithmetic would otherwise leave a ~1e-15 remainder and emit a
      // meaningless extra invoice row.
      final rows = allocateAcrossRequests(0.3, [target('1', 0.1), target('2', 0.2)]);
      expect(rows, hasLength(2));
      expect(rows.every((r) => r.isLinked), isTrue);
    });

    test('a single target absorbing the whole purchase yields one row', () {
      final rows = allocateAcrossRequests(25, [target('1', 25)]);
      expect(rows, hasLength(1));
      expect(rows.single.qty, 25);
      expect(rows.single.materialRequest, 'MAT-MR-0001');
    });
  });
}
