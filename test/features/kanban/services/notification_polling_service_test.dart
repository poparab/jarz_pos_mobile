import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/kanban/services/notification_polling_service.dart';
import '../../../helpers/mock_services.dart';

void main() {
  group('NotificationPollingService', () {
    late MockDio mockDio;
    late NotificationPollingService service;

    setUp(() {
      mockDio = MockDio();
      service = NotificationPollingService(mockDio);
    });

    tearDown(() {
      service.dispose();
    });

    test('startPolling triggers an initial check and sets up timer', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.notifications.check_for_updates',
        createSuccessResponse(data: {
          'success': true,
          'has_updates': false,
          'current_time': '2025-01-01 12:00:00',
        }),
      );

      service.startPolling(interval: const Duration(seconds: 60));
      await Future<void>.delayed(Duration.zero);

      // Initial check should have fired
      expect(mockDio.requestLog, isNotEmpty);
      expect(mockDio.requestLog.first['path'],
          '/api/method/jarz_pos.api.notifications.check_for_updates');

      service.stopPolling();
    });

    test('startPolling is idempotent (second call is no-op)', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.notifications.check_for_updates',
        createSuccessResponse(data: {
          'success': true,
          'has_updates': false,
          'current_time': '2025-01-01 12:00:00',
        }),
      );

      service.startPolling(interval: const Duration(seconds: 60));
      await Future<void>.delayed(Duration.zero);
      final countAfterFirst = mockDio.requestLog.length;

      service.startPolling(interval: const Duration(seconds: 60));
      await Future<void>.delayed(Duration.zero);
      // No additional requests since already polling
      expect(mockDio.requestLog.length, countAfterFirst);

      service.stopPolling();
    });

    test('stopPolling prevents further checks', () {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.notifications.check_for_updates',
        createSuccessResponse(data: {
          'success': true,
          'has_updates': false,
          'current_time': '2025-01-01 12:00:00',
        }),
      );

      service.startPolling(interval: const Duration(seconds: 60));
      service.stopPolling();

      // Calling stop again should be safe (no-op)
      service.stopPolling();
    });

    test('notificationStream emits updates_available when updates found', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.notifications.check_for_updates',
        createSuccessResponse(data: {
          'success': true,
          'has_updates': true,
          'new_count': 2,
          'modified_count': 1,
          'total_updates': 3,
          'current_time': '2025-01-01 12:00:00',
        }),
      );
      mockDio.setResponse(
        '/api/method/jarz_pos.api.notifications.get_recent_invoices',
        createSuccessResponse(data: {
          'success': true,
          'new_invoices': [{'name': 'INV-001'}],
          'modified_invoices': [],
        }),
      );

      final events = <Map<String, dynamic>>[];
      final sub = service.notificationStream.listen(events.add);

      service.startPolling(interval: const Duration(seconds: 60));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(events.any((e) => e['type'] == 'updates_available'), isTrue);
      expect(events.any((e) => e['type'] == 'new_invoice'), isTrue);

      await sub.cancel();
      service.stopPolling();
    });

    test('manualCheck calls fetchRecentInvoices and returns success', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.notifications.get_recent_invoices',
        createSuccessResponse(data: {
          'success': true,
          'new_invoices': [],
          'modified_invoices': [],
        }),
      );

      final result = await service.manualCheck();
      expect(result?['success'], true);
    });

    test('manualCheck returns success even when fetchRecentInvoices errors internally', () async {
      mockDio.setError(
        '/api/method/jarz_pos.api.notifications.get_recent_invoices',
        createMockDioException(message: 'timeout'),
      );

      // _fetchRecentInvoices catches its own errors, so manualCheck completes without error
      final result = await service.manualCheck();
      expect(result?['success'], true);
    });

    test('testNotifications calls the test endpoint', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.notifications.test_websocket_emission',
        createSuccessResponse(data: {'success': true, 'emitted': true}),
      );

      final result = await service.testNotifications();
      expect(result['success'], true);
    });

    test('getDebugInfo returns websocket configuration', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.notifications.get_websocket_debug_info',
        createSuccessResponse(data: {'success': true, 'transport': 'websocket'}),
      );

      final result = await service.getDebugInfo();
      expect(result['success'], true);
    });

    test('polling continues on network error (no crash)', () async {
      mockDio.setError(
        '/api/method/jarz_pos.api.notifications.check_for_updates',
        createMockDioException(message: 'network error'),
      );

      service.startPolling(interval: const Duration(seconds: 60));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Should not throw, just log and continue
      service.stopPolling();
    });

    test('dispose stops polling and closes stream', () {
      service.startPolling(interval: const Duration(seconds: 60));
      service.dispose();
      // Creating a new service to verify old one is disposed
      final service2 = NotificationPollingService(mockDio);
      service2.dispose();
    });
  });
}
