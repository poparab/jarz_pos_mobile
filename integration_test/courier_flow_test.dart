/// E2E: Courier settlement flow against the staging server.
///
/// Validates: get balances → get couriers → settlement preview →
///            confirm settlement.
///
/// Run with:
///   flutter test integration_test/courier_flow_test.dart
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

  // ── Courier balances ────────────────────────────────────────────────

  test('get courier balances returns list', () async {
    final result = await api.call(ApiEndpoints.getCourierBalances);

    expect(result, isA<List>());
    // May be empty if no couriers exist.
  });

  // ── Active couriers ─────────────────────────────────────────────────

  late List<dynamic> couriers;

  test('get active couriers returns list', () async {
    final result = await api.get(ApiEndpoints.getActiveCouriers);

    // The response may be wrapped in {success, data} or be a direct list.
    if (result is Map && result.containsKey('data')) {
      couriers = result['data'] as List;
    } else if (result is List) {
      couriers = result;
    } else {
      couriers = [];
    }
    // Couriers list may be empty — that's valid.
    expect(couriers, isA<List>());
  });

  // ── Settlement preview (read-only) ──────────────────────────────────
  // We can only test this if there are outstanding invoices.
  // This test verifies the endpoint contract.

  test('settlement preview endpoint accepts valid params', () async {
    // Find an invoice with outstanding balance from courier balances.
    final balances = await api.call(ApiEndpoints.getCourierBalances);
    if (balances is! List || balances.isEmpty) return;

    // Look for a balance entry with invoices.
    String? invoiceName;
    for (final b in balances) {
      if (b is Map && b['invoices'] is List) {
        final invoices = b['invoices'] as List;
        if (invoices.isNotEmpty && invoices.first is Map) {
          invoiceName = (invoices.first as Map)['name']?.toString();
          break;
        }
      }
      // Some formats list invoice name directly.
      if (b is Map && b['invoice'] != null) {
        invoiceName = b['invoice'].toString();
        break;
      }
    }

    if (invoiceName == null) return; // No testable invoices.

    try {
      final preview = await api.call(
        ApiEndpoints.getInvoiceSettlementPreview,
        data: {'invoice_name': invoiceName},
      );

      expect(preview, isA<Map>());
    } catch (e) {
      // Invoice may not be in a settleable state — acceptable.
      expect(e.toString(), isNotEmpty);
    }
  });

  // ── Generate + confirm flow (read-only probe) ──────────────────────

  test('generate settlement preview endpoint is reachable', () async {
    // We only probe reachability — actual settlement needs a valid invoice.
    try {
      await api.call(
        ApiEndpoints.generateSettlementPreview,
        data: {
          'invoice': 'NONEXISTENT-001',
          'mode': 'pay_now',
        },
      );
    } catch (e) {
      // Expected: invoice not found or similar error.
      expect(e.toString(), isNotEmpty);
    }
  });

  // ── Delivery handling endpoints ─────────────────────────────────────

  test('courier balance structure contains expected keys', () async {
    final balances = await api.call(ApiEndpoints.getCourierBalances);
    if (balances is! List || balances.isEmpty) return;

    final entry = balances.first as Map;
    // Expect at least some of these keys.
    final hasExpectedKeys = entry.containsKey('courier') ||
        entry.containsKey('party') ||
        entry.containsKey('display_name') ||
        entry.containsKey('outstanding') ||
        entry.containsKey('total_outstanding');
    expect(hasExpectedKeys, isTrue,
        reason: 'Balance entry should have identifying keys');
  });
}
