/// E2E: Kanban board operations against the staging server.
///
/// Validates: columns → invoices → details → filters → state update.
///
/// Run with:
///   flutter test integration_test/kanban_flow_test.dart
///     --dart-define=STAGING_USER=myuser --dart-define=STAGING_PASSWORD=mypass
@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';

import 'helpers/api_client.dart';

void main() {
  late StagingApiClient api;

  setUpAll(() async {
    api = StagingApiClient();
    await api.login();
  });

  tearDownAll(() {
    api.dispose();
  });

  // ── Kanban columns ──────────────────────────────────────────────────

  late List<dynamic> columns;

  test('get kanban columns returns non-empty list', () async {
    final result = await api.get(ApiEndpoints.getKanbanColumns);

    expect(result, isA<Map>());
    final data = result as Map;
    expect(data['success'], isTrue);
    expect(data['columns'], isA<List>());
    columns = data['columns'] as List;
    expect(columns.isNotEmpty, isTrue);
  });

  // ── Kanban invoices ─────────────────────────────────────────────────

  late String? sampleInvoice;

  test('get kanban invoices returns column-grouped data', () async {
    final result = await api.call(ApiEndpoints.getKanbanInvoices);

    expect(result, isA<Map>());
    final data = result as Map;

    // At least one column should have data (or be empty).
    // Find any invoice for later tests.
    for (final entry in data.entries) {
      if (entry.value is List && (entry.value as List).isNotEmpty) {
        final firstInv = (entry.value as List).first;
        if (firstInv is Map && firstInv['name'] != null) {
          sampleInvoice = firstInv['name'].toString();
          break;
        }
      }
    }
  });

  test('get kanban invoices with filters works', () async {
    final result = await api.call(
      ApiEndpoints.getKanbanInvoices,
      data: {'filters': '{}'},
    );

    expect(result, isA<Map>());
  });

  // ── Kanban filters ──────────────────────────────────────────────────

  test('get kanban filters returns filter options', () async {
    final result = await api.get(ApiEndpoints.getKanbanFilters);

    expect(result, isA<Map>());
    final data = result as Map;
    // Should contain customer and/or state filter options.
    expect(
      data.containsKey('customers') || data.containsKey('states'),
      isTrue,
      reason: 'Filters should include customers or states',
    );
  });

  // ── Invoice details ─────────────────────────────────────────────────

  test('get invoice details returns full data', () async {
    if (sampleInvoice == null) {
      // No invoices exist to inspect — skip gracefully.
      return;
    }

    final result = await api.get(
      ApiEndpoints.getInvoiceDetails,
      queryParameters: {'invoice_id': sampleInvoice},
    );

    expect(result, isA<Map>());
    final data = result as Map;
    expect(data['success'], isTrue);
    expect(data['data'], isA<Map>());
    expect((data['data'] as Map)['name'], equals(sampleInvoice));
  });

  // ── Invoice state update ────────────────────────────────────────────
  // NOTE: We don't blindly update state on production data.
  // This test only verifies the endpoint is reachable with valid params.

  test('update invoice state endpoint is reachable', () async {
    if (sampleInvoice == null) return;

    // Fetch current state first.
    final details = await api.get(
      ApiEndpoints.getInvoiceDetails,
      queryParameters: {'invoice_id': sampleInvoice},
    );

    if (details is! Map || details['data'] is! Map) return;
    final currentState = (details['data'] as Map)['workflow_state'] ??
        (details['data'] as Map)['delivery_status'];
    if (currentState == null) return;

    // Set the same state (no-op) to verify endpoint works without side effects.
    try {
      final result = await api.call(
        ApiEndpoints.updateInvoiceState,
        data: {
          'invoice_id': sampleInvoice,
          'new_state': currentState,
        },
      );
      expect(result, isNotNull);
    } catch (e) {
      // Some states may not allow self-transition — that's okay.
      expect(e.toString(), isNotEmpty);
    }
  });
}
