import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jarz_pos/src/features/pos/order_alert/data/order_alert_service.dart';
import 'package:jarz_pos/src/features/pos/order_alert/domain/invoice_alert.dart';
import 'package:jarz_pos/src/features/pos/order_alert/state/order_alert_controller.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';

// ── Fakes ────────────────────────────────────────────────────────────────

class _FakeOrderAlertService extends OrderAlertService {
  _FakeOrderAlertService() : super(Dio());

  final List<String> acknowledgedInvoices = [];
  List<InvoiceAlert> pendingAlerts = [];
  bool shouldThrow = false;

  @override
  Future<void> acknowledgeInvoice(String invoiceName) async {
    if (shouldThrow) throw Exception('ack failed');
    acknowledgedInvoices.add(invoiceName);
  }

  @override
  Future<List<InvoiceAlert>> getPendingAlerts() async {
    if (shouldThrow) throw Exception('sync failed');
    return pendingAlerts;
  }

  @override
  Future<void> registerDevice({
    required String token,
    String? platform,
    String? deviceName,
    String? appVersion,
    List<String>? posProfiles,
  }) async {
    if (shouldThrow) throw Exception('register failed');
  }
}

class _FakePosRepository extends PosRepository {
  _FakePosRepository() : super(Dio());

  bool posProfileOpen = true;
  String? lastCheckedProfile;

  @override
  Future<Map<String, dynamic>> isPosProfileOpen(String posProfile) async {
    lastCheckedProfile = posProfile;
    return {'is_open': posProfileOpen, 'message': 'test'};
  }
}

InvoiceAlert _alert(String id, {bool requires = true, String status = 'Pending'}) {
  return InvoiceAlert.fromDynamic({
    'invoice_id': id,
    'pos_profile': 'TestProfile',
    'acceptance_status': status,
    'requires_acceptance': requires,
    'grand_total': 100,
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeOrderAlertService service;
  late _FakePosRepository posRepo;
  late OrderAlertController controller;

  // Capture native channel calls instead of crashing
  final List<String> nativeChannelCalls = [];

  setUp(() {
    nativeChannelCalls.clear();
    SharedPreferences.setMockInitialValues({});
    service = _FakeOrderAlertService();
    posRepo = _FakePosRepository();
    controller = OrderAlertController(service, posRepo);

    // Mock the native MethodChannel so calls don't crash
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const channel = MethodChannel('order_alert_native');
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      nativeChannelCalls.add(call.method);
      return null;
    });
  });

  tearDown(() {
    controller.dispose();
  });

  // ── enqueueAlert ──────────────────────────────────────────────────────

  group('enqueueAlert', () {
    test('adds alert to queue and sets active', () async {
      final alert = _alert('INV-1');
      await controller.enqueueAlert(alert);

      expect(controller.state.queue, hasLength(1));
      expect(controller.state.active?.invoiceId, 'INV-1');
      expect(controller.state.hasActive, isTrue);
    });

    test('skips alert that does not require acceptance', () async {
      final alert = _alert('INV-1', requires: false);
      await controller.enqueueAlert(alert);

      expect(controller.state.queue, isEmpty);
      expect(controller.state.active, isNull);
    });

    test('updates existing alert in queue by invoiceId', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      expect(controller.state.queue, hasLength(1));

      // Enqueue same id again with different status
      final updated = _alert('INV-1', status: 'Updated');
      await controller.enqueueAlert(updated);

      expect(controller.state.queue, hasLength(1));
      expect(controller.state.active?.acceptanceStatus, 'Updated');
    });

    test('second alert added to queue but does not change active', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      await controller.enqueueAlert(_alert('INV-2'));

      expect(controller.state.queue, hasLength(2));
      expect(controller.state.active?.invoiceId, 'INV-1');
    });

    test('clears error on enqueue', () async {
      // Force an error state first via a failed acknowledge
      service.shouldThrow = true;
      await controller.enqueueAlert(_alert('INV-X'));
      service.shouldThrow = false;
      try {
        await controller.acknowledgeActive();
      } catch (_) {}
      // Controller might have error set. Enqueue should clear it.
      await controller.enqueueAlert(_alert('INV-Y'));
      expect(controller.state.error, isNull);
    });

    test('updates queue without native effects when suppressed', () async {
      final alert = _alert('INV-1');
      await controller.enqueueAlert(alert, triggerNativeEffects: false);

      expect(controller.state.queue, hasLength(1));
      expect(controller.state.active?.invoiceId, 'INV-1');
      expect(nativeChannelCalls, isEmpty);
    });

    test('uses effective branch for timetable checks', () async {
      final alert = InvoiceAlert.fromDynamic({
        'invoice_id': 'INV-1',
        'pos_profile': 'Dokki',
        'custom_kanban_profile': 'Nasr city',
        'effective_pos_profile': 'Heliopolis',
        'acceptance_status': 'Pending',
        'requires_acceptance': true,
        'grand_total': 100,
      });

      await controller.enqueueAlert(alert);

      expect(posRepo.lastCheckedProfile, 'Heliopolis');
    });
  });

  // ── hasInvoice ────────────────────────────────────────────────────────

  group('hasInvoice', () {
    test('returns true for enqueued invoice', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      expect(controller.hasInvoice('INV-1'), isTrue);
    });

    test('returns false for unknown invoice', () {
      expect(controller.hasInvoice('NOPE'), isFalse);
    });
  });

  // ── acknowledgeActive ─────────────────────────────────────────────────

  group('acknowledgeActive', () {
    test('does nothing when no active alert', () async {
      await controller.acknowledgeActive();
      expect(service.acknowledgedInvoices, isEmpty);
    });

    test('calls service and removes active from queue', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      service.pendingAlerts = []; // sync returns empty
      await controller.acknowledgeActive();

      expect(service.acknowledgedInvoices, ['INV-1']);
      expect(controller.state.queue, isEmpty);
      expect(controller.state.active, isNull);
    });

    test('sets error on failure', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      service.shouldThrow = true;
      await controller.acknowledgeActive();

      expect(controller.state.error, isNotNull);
      expect(controller.state.isAcknowledging, isFalse);
    });

    test('advances to next alert when multiple queued', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      await controller.enqueueAlert(_alert('INV-2'));
      service.pendingAlerts = [_alert('INV-2')]; // server still has INV-2
      await controller.acknowledgeActive();

      expect(service.acknowledgedInvoices, ['INV-1']);
      expect(controller.state.active?.invoiceId, 'INV-2');
      expect(controller.state.queue, hasLength(1));
    });
  });

  // ── syncPendingAlerts ─────────────────────────────────────────────────

  group('syncPendingAlerts', () {
    test('populates state from server', () async {
      service.pendingAlerts = [_alert('S-1'), _alert('S-2')];
      await controller.syncPendingAlerts();

      expect(controller.state.queue, hasLength(2));
      expect(controller.state.active?.invoiceId, 'S-1');
      expect(controller.state.lastSynced, isNotNull);
    });

    test('clears queue when server returns empty', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      service.pendingAlerts = [];
      await controller.syncPendingAlerts();

      expect(controller.state.queue, isEmpty);
      expect(controller.state.active, isNull);
      expect(controller.state.isMuted, isFalse);
    });

    test('preserves existing active if still in server list', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      await controller.enqueueAlert(_alert('INV-2'));
      // Server still has both
      service.pendingAlerts = [_alert('INV-2'), _alert('INV-1')];
      await controller.syncPendingAlerts();

      // Active should remain INV-1 since it was already active
      expect(controller.state.active?.invoiceId, 'INV-1');
    });

    test('sets error on failure', () async {
      service.shouldThrow = true;
      await controller.syncPendingAlerts();

      expect(controller.state.error, isNotNull);
      expect(controller.state.lastSynced, isNotNull);
    });

    test('is idempotent (guard against concurrent calls)', () async {
      // The _loadingPending guard prevents re-entrant calls.
      // We just verify it doesn't crash.
      service.pendingAlerts = [_alert('A')];
      await controller.syncPendingAlerts();
      await controller.syncPendingAlerts();
      expect(controller.state.queue, hasLength(1));
    });
  });

  // ── handleInvoiceAccepted ─────────────────────────────────────────────

  group('handleInvoiceAccepted', () {
    test('removes invoice and stops alarm', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      await controller.handleInvoiceAccepted('INV-1');

      expect(controller.state.queue, isEmpty);
      expect(controller.state.active, isNull);
      expect(nativeChannelCalls, contains('stopAlarm'));
    });

    test('no-op if invoice not in queue', () async {
      await controller.handleInvoiceAccepted('UNKNOWN');
      // Should not crash
      expect(controller.state.queue, isEmpty);
    });

    test('advances active to next after removal', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      await controller.enqueueAlert(_alert('INV-2'));
      await controller.handleInvoiceAccepted('INV-1');

      expect(controller.state.active?.invoiceId, 'INV-2');
    });
  });

  // ── clearError ────────────────────────────────────────────────────────

  group('clearError', () {
    test('clears existing error', () async {
      service.shouldThrow = true;
      await controller.syncPendingAlerts();
      expect(controller.state.error, isNotNull);

      controller.clearError();
      expect(controller.state.error, isNull);
    });

    test('no-op when no error', () {
      controller.clearError();
      expect(controller.state.error, isNull);
    });
  });

  // ── shouldRegisterToken ───────────────────────────────────────────────

  group('shouldRegisterToken', () {
    test('returns true when no previous token stored', () async {
      final result = await controller.shouldRegisterToken(
        'newToken', 'user1', ['ProfileA'],
      );
      expect(result, isTrue);
    });

    test('returns false when same token/user/profiles', () async {
      await controller.markTokenRegistered('tok', 'user1', ['P1']);
      final result = await controller.shouldRegisterToken('tok', 'user1', ['P1']);
      expect(result, isFalse);
    });

    test('returns true when token changed', () async {
      await controller.markTokenRegistered('oldTok', 'user1', ['P1']);
      final result = await controller.shouldRegisterToken('newTok', 'user1', ['P1']);
      expect(result, isTrue);
    });

    test('returns true when user changed', () async {
      await controller.markTokenRegistered('tok', 'user1', ['P1']);
      final result = await controller.shouldRegisterToken('tok', 'user2', ['P1']);
      expect(result, isTrue);
    });

    test('returns true when profiles changed', () async {
      await controller.markTokenRegistered('tok', 'user1', ['P1']);
      final result = await controller.shouldRegisterToken('tok', 'user1', ['P1', 'P2']);
      expect(result, isTrue);
    });

    test('normalizes profile order for comparison', () async {
      await controller.markTokenRegistered('tok', 'user1', ['B', 'A']);
      final result = await controller.shouldRegisterToken('tok', 'user1', ['A', 'B']);
      expect(result, isFalse);
    });
  });

  // ── markTokenRegistered / resetTokenCache ─────────────────────────────

  group('token cache', () {
    test('markTokenRegistered persists and resetTokenCache clears', () async {
      await controller.markTokenRegistered('tok', 'user', ['P']);
      expect(
        await controller.shouldRegisterToken('tok', 'user', ['P']),
        isFalse,
      );

      await controller.resetTokenCache();
      expect(
        await controller.shouldRegisterToken('tok', 'user', ['P']),
        isTrue,
      );
    });
  });

  // ── getGlobalMuteState / setGlobalMuteState ───────────────────────────

  group('global mute state', () {
    test('defaults to false', () async {
      expect(await controller.getGlobalMuteState(), isFalse);
    });

    test('setGlobalMuteState true stops alarm and mutes state', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      nativeChannelCalls.clear();

      await controller.setGlobalMuteState(true);
      expect(await controller.getGlobalMuteState(), isTrue);
      expect(controller.state.isMuted, isTrue);
      expect(nativeChannelCalls, contains('stopAlarm'));
    });

    test('setGlobalMuteState false unmutes state', () async {
      await controller.setGlobalMuteState(true);
      await controller.setGlobalMuteState(false);

      expect(await controller.getGlobalMuteState(), isFalse);
      expect(controller.state.isMuted, isFalse);
    });
  });

  // ── clearAll ──────────────────────────────────────────────────────────

  group('clearAll', () {
    test('stops alarm and resets state', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      nativeChannelCalls.clear();

      await controller.clearAll();
      expect(controller.state.queue, isEmpty);
      expect(controller.state.active, isNull);
      expect(controller.state.isAcknowledging, isFalse);
      expect(controller.state.isMuted, isFalse);
      expect(nativeChannelCalls, contains('stopAlarm'));
    });
  });

  // ── muteActiveAlert / unmuteAlerts ────────────────────────────────────

  group('muteActiveAlert', () {
    test('stops alarm and sets isMuted', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      nativeChannelCalls.clear();

      await controller.muteActiveAlert();
      expect(controller.state.isMuted, isTrue);
      expect(nativeChannelCalls, contains('stopAlarm'));
    });

    test('no-op when no active alert', () async {
      await controller.muteActiveAlert();
      expect(controller.state.isMuted, isFalse);
    });

    test('no-op when already muted', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      await controller.muteActiveAlert();
      nativeChannelCalls.clear();

      await controller.muteActiveAlert();
      expect(nativeChannelCalls, isEmpty);
    });
  });

  group('unmuteAlerts', () {
    test('unmutes and starts alarm when active', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      await controller.muteActiveAlert();
      nativeChannelCalls.clear();

      await controller.unmuteAlerts();
      expect(controller.state.isMuted, isFalse);
      expect(nativeChannelCalls, contains('startAlarm'));
    });

    test('no-op when not muted', () async {
      await controller.unmuteAlerts();
      expect(controller.state.isMuted, isFalse);
    });

    test('does not start alarm when POS profile is closed', () async {
      await controller.enqueueAlert(_alert('INV-1'));
      await controller.muteActiveAlert();
      posRepo.posProfileOpen = false;
      nativeChannelCalls.clear();

      await controller.unmuteAlerts();
      expect(controller.state.isMuted, isFalse);
      expect(nativeChannelCalls, isNot(contains('startAlarm')));
    });
  });
}
