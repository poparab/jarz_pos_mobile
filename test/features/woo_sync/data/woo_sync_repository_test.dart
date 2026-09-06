import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/woo_sync/data/repositories/woo_sync_repository.dart';
import '../../../helpers/mock_services.dart';

void main() {
  group('WooSyncRepository', () {
    late MockDio mockDio;
    late WooSyncRepository repo;

    setUp(() {
      mockDio = MockDio();
      repo = WooSyncRepository(mockDio);
    });

    group('getDashboard', () {
      test('parses the full dashboard shape from the message envelope', () async {
        mockDio.setResponse(ApiEndpoints.wooSyncDashboard, {
          'message': {
            'generated_at': '2026-09-07T10:00:00',
            'window_hours': 24,
            'settings': {'enable_outbound_orders': true},
            'breaker': {
              'failure_count': 4,
              'open_until': '2026-09-07T11:00:00',
              'is_open': true,
            },
            'shadow_failures': {},
            'backlog': {
              'pending': 3,
              'retry_scheduled': 1,
              'processing': 0,
              'needs_attention': 5,
              'due_now': 2,
              'oldest_due': '2026-09-07T09:00:00',
              'expired_processing': 0,
            },
            'status_counts': {'Pending': 3, 'Failed': 2},
            'review_state_counts': {'Open': 2},
            'direction_counts': {'Outbound': 5},
            'event_type_counts': {'order.created': 3},
            'attention_events': [
              {
                'name': 'WSE-0001',
                'direction': 'Outbound',
                'event_type': 'order.created',
                'status': 'Failed',
                'priority': 'Normal',
                'attempt_count': 3,
                'max_attempts': 5,
              },
            ],
            'recent_events': [],
          },
        });

        final dashboard = await repo.getDashboard();

        expect(dashboard.windowHours, 24);
        expect(dashboard.breaker.isOpen, isTrue);
        expect(dashboard.breaker.failureCount, 4);
        expect(dashboard.breaker.openUntil, '2026-09-07T11:00:00');
        expect(dashboard.backlog.pending, 3);
        expect(dashboard.backlog.needsAttention, 5);
        expect(dashboard.statusCounts['Failed'], 2);
        expect(dashboard.attentionEvents, hasLength(1));
        expect(dashboard.attentionEvents.first.name, 'WSE-0001');
        expect(dashboard.attentionEvents.first.needsAttention, isTrue);
      });

      test('falls back to defaults on a bare/unexpected payload', () async {
        mockDio.setResponse(ApiEndpoints.wooSyncDashboard, 'nope');

        final dashboard = await repo.getDashboard();

        expect(dashboard.breaker.isOpen, isFalse);
        expect(dashboard.backlog.pending, 0);
        expect(dashboard.attentionEvents, isEmpty);
      });

      test('unwraps a bare payload without a message envelope', () async {
        mockDio.setResponse(ApiEndpoints.wooSyncDashboard, {
          'window_hours': 48,
          'backlog': {'pending': 7},
        });

        final dashboard = await repo.getDashboard();

        expect(dashboard.windowHours, 48);
        expect(dashboard.backlog.pending, 7);
      });
    });

    group('getEvents', () {
      test('parses the event list and encodes filters as a JSON string', () async {
        mockDio.setResponse(ApiEndpoints.wooSyncEvents, {
          'message': [
            {
              'name': 'WSE-0002',
              'direction': 'Inbound',
              'event_type': 'customer.updated',
              'status': 'NeedsReview',
              'priority': 'High',
              'attempt_count': 1,
              'max_attempts': 5,
              'local_doctype': 'Sales Invoice',
              'local_docname': 'ACC-SINV-0099',
              'review_state': 'Open',
              'manual_review_reason': 'ambiguous customer match',
              'last_error': '',
              'is_retention_exempt': 0,
            },
          ],
        });

        final events = await repo.getEvents(status: 'NeedsReview', search: 'ACC-SINV');

        expect(events, hasLength(1));
        final event = events.first;
        expect(event.name, 'WSE-0002');
        expect(event.reviewState, 'Open');
        expect(event.hasLocalInvoice, isTrue);
        expect(event.needsAttention, isTrue);
        expect(event.isRetryable, isTrue);

        final sentData = mockDio.requestLog.first['data'] as Map;
        expect(sentData['filters'], isA<String>());
        expect(sentData['filters'], contains('"status":"NeedsReview"'));
        expect(sentData['filters'], contains('"search":"ACC-SINV"'));
      });

      test('returns an empty list on an unexpected payload shape', () async {
        mockDio.setResponse(ApiEndpoints.wooSyncEvents, {'message': 'nope'});

        final events = await repo.getEvents();

        expect(events, isEmpty);
      });
    });

    group('bulk operations', () {
      test('retryEvents encodes event_names as a JSON array string', () async {
        mockDio.setResponse(ApiEndpoints.wooSyncRetryEvents, {
          'message': {'success': true, 'count': 2},
        });

        final names = ['WSE-0001', 'WSE-0002'];
        final result = await repo.retryEvents(names);

        expect(result['count'], 2);
        final sentData = mockDio.requestLog.first['data'] as Map;
        expect(sentData['event_names'], isA<String>());
        expect(sentData['event_names'], contains('WSE-0001'));
        expect(sentData['event_names'], contains('WSE-0002'));
      });

      test('retryEvents rejects more than the 100-name server cap before calling the server', () async {
        final tooMany = List.generate(101, (i) => 'WSE-$i');

        expect(() => repo.retryEvents(tooMany), throwsA(isA<ArgumentError>()));
        expect(mockDio.requestLog, isEmpty);
      });

      test('retryEvents accepts exactly the 100-name cap', () async {
        mockDio.setResponse(ApiEndpoints.wooSyncRetryEvents, {
          'message': {'success': true, 'count': 100},
        });
        final exactly100 = List.generate(100, (i) => 'WSE-$i');

        final result = await repo.retryEvents(exactly100);

        expect(result['count'], 100);
      });

      test('retryEvents rejects an empty selection', () async {
        expect(() => repo.retryEvents(const []), throwsA(isA<ArgumentError>()));
      });

      test('setReviewStateBulk sends event_names, review_state and notes', () async {
        mockDio.setResponse(ApiEndpoints.wooSyncSetReviewStateBulk, {
          'message': {'success': true, 'count': 2},
        });

        await repo.setReviewStateBulk(
          ['WSE-0001', 'WSE-0002'],
          'Investigating',
          resolutionNotes: 'looked at both, following up with the store',
        );

        final sentData = mockDio.requestLog.first['data'] as Map;
        expect(sentData['review_state'], 'Investigating');
        expect(sentData['resolution_notes'], 'looked at both, following up with the store');
        expect(sentData['event_names'], contains('WSE-0001'));
      });

      test('setReviewStateBulk rejects more than the 100-name server cap', () async {
        final tooMany = List.generate(150, (i) => 'WSE-$i');

        expect(
          () => repo.setReviewStateBulk(tooMany, 'Resolved'),
          throwsA(isA<ArgumentError>()),
        );
        expect(mockDio.requestLog, isEmpty);
      });
    });

    group('single-event operations', () {
      test('retryEvent sends event_name', () async {
        mockDio.setResponse(ApiEndpoints.wooSyncRetryEvent, {
          'message': {'success': true},
        });

        await repo.retryEvent('WSE-0001');

        expect(mockDio.requestLog.first['data']['event_name'], 'WSE-0001');
      });

      test('processEventNow sends event_name', () async {
        mockDio.setResponse(ApiEndpoints.wooSyncProcessNow, {
          'message': {'success': true},
        });

        await repo.processEventNow('WSE-0001');

        expect(mockDio.requestLog.first['data']['event_name'], 'WSE-0001');
      });

      test('setReviewState sends event_name, review_state and optional notes', () async {
        mockDio.setResponse(ApiEndpoints.wooSyncSetReviewState, {
          'message': {'success': true, 'review_state': 'Resolved'},
        });

        final result = await repo.setReviewState('WSE-0001', 'Resolved', resolutionNotes: 'fixed');

        expect(result['review_state'], 'Resolved');
        final sentData = mockDio.requestLog.first['data'] as Map;
        expect(sentData['event_name'], 'WSE-0001');
        expect(sentData['review_state'], 'Resolved');
        expect(sentData['resolution_notes'], 'fixed');
      });

      test('setReviewState omits resolution_notes when not provided', () async {
        mockDio.setResponse(ApiEndpoints.wooSyncSetReviewState, {
          'message': {'success': true},
        });

        await repo.setReviewState('WSE-0001', 'Open');

        final sentData = mockDio.requestLog.first['data'] as Map;
        expect(sentData.containsKey('resolution_notes'), isFalse);
      });
    });

    group('console-level actions', () {
      test('runWorker posts batch_size only when provided', () async {
        mockDio.setResponse(ApiEndpoints.wooSyncRunWorker, {
          'message': {'processed': 10},
        });

        await repo.runWorker();
        expect(mockDio.requestLog.first['data'].containsKey('batch_size'), isFalse);

        mockDio.clearLog();
        await repo.runWorker(batchSize: 50);
        expect(mockDio.requestLog.first['data']['batch_size'], 50);
      });

      test('clearOutboundBreaker returns the released row count', () async {
        mockDio.setResponse(ApiEndpoints.wooSyncClearBreaker, {
          'message': {'success': true, 'released_rows': 12},
        });

        final result = await repo.clearOutboundBreaker();

        expect(result['released_rows'], 12);
      });
    });

    group('pushSalesInvoice', () {
      test('sends invoice_name and returns the push result', () async {
        mockDio.setResponse(ApiEndpoints.wooPushSalesInvoice, {
          'message': {'success': true, 'woo_order_id': 555},
        });

        final result = await repo.pushSalesInvoice('ACC-SINV-0099');

        expect(result['woo_order_id'], 555);
        expect(mockDio.requestLog.first['data']['invoice_name'], 'ACC-SINV-0099');
      });
    });

    group('getDuplicateReview', () {
      test('parses groups with their candidates shape', () async {
        mockDio.setResponse(ApiEndpoints.wooDuplicateReview, {
          'message': [
            {
              'group_id': '+201234567890',
              'phone': '+201234567890',
              'size': 2,
              'reason': 'different names and no exclusively-shared woo_customer_id',
              'members': [],
              'candidates': [
                {
                  'name': 'CUST-0001',
                  'customer_name': 'Ahmed Ali',
                  'phone': '+201234567890',
                  'email': 'ahmed@example.com',
                  'created': '2026-01-01T00:00:00',
                  'disabled': 0,
                  'woo_customer_id': '42',
                  'invoice_count': 5,
                  'submitted_invoice_count': 4,
                  'revenue': 1200.5,
                },
                {
                  'name': 'CUST-0002',
                  'customer_name': 'Ahmed Ali Two',
                  'phone': '+201234567890',
                  'email': '',
                  'created': '2026-02-01T00:00:00',
                  'disabled': 1,
                  'woo_customer_id': '',
                  'invoice_count': 0,
                  'submitted_invoice_count': 0,
                  'revenue': 0.0,
                },
              ],
            },
          ],
        });

        final groups = await repo.getDuplicateReview();

        expect(groups, hasLength(1));
        final group = groups.first;
        expect(group.groupId, '+201234567890');
        expect(group.size, 2);
        expect(group.reason, contains('different names'));
        expect(group.candidates, hasLength(2));
        expect(group.candidates.first.customerName, 'Ahmed Ali');
        expect(group.candidates.first.invoiceCount, 5);
        expect(group.candidates.first.disabled, isFalse);
        expect(group.candidates.last.disabled, isTrue);
        expect(group.candidates.last.wooCustomerId, isEmpty);
      });

      test('returns an empty list on an unexpected payload', () async {
        mockDio.setResponse(ApiEndpoints.wooDuplicateReview, {'message': {}});

        final groups = await repo.getDuplicateReview();

        expect(groups, isEmpty);
      });
    });
  });
}
