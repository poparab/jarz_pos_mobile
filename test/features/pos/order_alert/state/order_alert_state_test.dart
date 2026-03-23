import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/order_alert/domain/invoice_alert.dart';
import 'package:jarz_pos/src/features/pos/order_alert/state/order_alert_state.dart';

InvoiceAlert _makeAlert(String id, {String status = 'Pending'}) {
  return InvoiceAlert.fromDynamic({
    'invoice_id': id,
    'pos_profile': 'P',
    'acceptance_status': status,
    'requires_acceptance': true,
  });
}

void main() {
  group('OrderAlertState constructor', () {
    test('defaults are correct', () {
      const s = OrderAlertState();
      expect(s.queue, isEmpty);
      expect(s.active, isNull);
      expect(s.isAcknowledging, isFalse);
      expect(s.isMuted, isFalse);
      expect(s.error, isNull);
      expect(s.lastSynced, isNull);
    });
  });

  group('OrderAlertState.hasActive', () {
    test('false when active is null', () {
      const s = OrderAlertState();
      expect(s.hasActive, isFalse);
    });

    test('true when active is set', () {
      final alert = _makeAlert('INV-1');
      final s = OrderAlertState(active: alert);
      expect(s.hasActive, isTrue);
    });
  });

  group('OrderAlertState.copyWith', () {
    test('preserves all fields when no args', () {
      final alert = _makeAlert('INV-1');
      final now = DateTime.now();
      final s = OrderAlertState(
        queue: [alert],
        active: alert,
        isAcknowledging: true,
        isMuted: true,
        error: 'some error',
        lastSynced: now,
      );

      final copy = s.copyWith();
      expect(copy.queue, hasLength(1));
      expect(copy.active?.invoiceId, 'INV-1');
      expect(copy.isAcknowledging, isTrue);
      expect(copy.isMuted, isTrue);
      expect(copy.error, 'some error');
      expect(copy.lastSynced, now);
    });

    test('overrides individual fields', () {
      final s = OrderAlertState(
        queue: [_makeAlert('A')],
        active: _makeAlert('A'),
        error: 'err',
      );

      final newAlert = _makeAlert('B');
      final copy = s.copyWith(
        queue: [newAlert],
        active: newAlert,
        isAcknowledging: true,
        isMuted: true,
        error: 'new error',
      );
      expect(copy.queue.first.invoiceId, 'B');
      expect(copy.active?.invoiceId, 'B');
      expect(copy.isAcknowledging, isTrue);
      expect(copy.isMuted, isTrue);
      expect(copy.error, 'new error');
    });

    test('clearError removes error', () {
      final s = OrderAlertState(error: 'something');
      final copy = s.copyWith(clearError: true);
      expect(copy.error, isNull);
    });

    test('clearError takes precedence over error param', () {
      final s = OrderAlertState(error: 'old');
      final copy = s.copyWith(error: 'new', clearError: true);
      expect(copy.error, isNull);
    });

    test('sets active to null explicitly using sentinel', () {
      final alert = _makeAlert('A');
      final s = OrderAlertState(active: alert);
      final copy = s.copyWith(active: null);
      expect(copy.active, isNull);
    });

    test('lastSynced can be updated', () {
      const s = OrderAlertState();
      final now = DateTime(2024, 6, 1);
      final copy = s.copyWith(lastSynced: now);
      expect(copy.lastSynced, now);
    });
  });
}
