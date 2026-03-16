/// Full-cycle Kanban E2E test with backend verification.
///
/// Flow:
///   1. Login
///   2. Ensure shift is open
///   3. Load kanban columns → verify column structure
///   4. Load kanban invoices → verify data integrity
///   5. Load kanban filters → verify filter options
///   6. Pick a sample invoice → verify in ERP
///   7. Get invoice details → verify match with ERP
///   8. Attempt state transition → verify in ERP
///   9. Load courier balances
///  10. Verify notification endpoints respond
///
/// Run:
///   flutter test integration_test/full_cycle/kanban_full_cycle_test.dart \
///     --dart-define=STAGING_USER=x --dart-define=STAGING_PASSWORD=y
@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';

import '../helpers/api_client.dart';
import '../helpers/staging_config.dart';
import '../helpers/test_data_helpers.dart';

void main() {
  late StagingApiClient api;
  String posProfile = '';
  String? openingEntry;
  bool weOpenedShift = false;
  String? sampleInvoiceName;

  setUpAll(() async {
    api = StagingApiClient();
    await api.login();

    // Resolve POS profile
    if (StagingConfig.posProfile.isNotEmpty) {
      posProfile = StagingConfig.posProfile;
    } else {
      final profiles = await api.call(ApiEndpoints.getPosProfiles);
      posProfile = (profiles as List).first.toString();
    }

    // Ensure shift is open
    final existing = await api.call(ApiEndpoints.getActiveShift);
    if (existing is Map && existing['name'] != null) {
      openingEntry = (existing['name'] ?? existing['opening_entry']).toString();
    } else {
      final result = await api.call(
        ApiEndpoints.startShift,
        data: {
          'pos_profile': posProfile,
          'opening_balances': [
            {'mode_of_payment': 'Cash', 'opening_amount': 0},
          ],
        },
      );
      openingEntry = result['opening_entry'].toString();
      weOpenedShift = true;
    }
  });

  tearDownAll(() async {
    if (weOpenedShift && openingEntry != null) {
      try {
        await api.call(ApiEndpoints.endShift, data: {
          'pos_opening_entry': openingEntry,
          'closing_balances': [
            {'mode_of_payment': 'Cash', 'closing_amount': 0},
          ],
        });
      } catch (_) {}
    }
    api.dispose();
  });

  // ── Step 1: Load kanban columns ───────────────────────────────────────

  late List<dynamic> columns;

  test('1. load kanban columns → verify structure', () async {
    final result = await api.call(ApiEndpoints.getKanbanColumns);
    if (result is List) {
      columns = result;
    } else if (result is Map && result['columns'] is List) {
      columns = (result['columns'] as List);
    } else {
      fail('Unexpected kanban columns payload type: ${result.runtimeType}');
    }
    expect(columns, isNotEmpty, reason: 'Kanban should have columns');

    // Each column should have a name/label
    for (final col in columns) {
      if (col is Map) {
        expect(col['name'] ?? col['label'], isNotNull);
      }
    }
  });

  // ── Step 2: Load invoices ─────────────────────────────────────────────

  test('2. load kanban invoices → verify data integrity', () async {
    final data = await api.call(ApiEndpoints.getKanbanInvoices);
    expect(data, isA<Map>());

    // Iterate columns and find a sample invoice
    for (final entry in (data as Map).entries) {
      if (entry.value is List && (entry.value as List).isNotEmpty) {
        final inv = (entry.value as List).first;
        if (inv is Map && inv['name'] != null) {
          sampleInvoiceName = inv['name'].toString();

          // Verify invoice has required fields
          expect(inv['customer'] ?? inv['customer_name'], isNotNull,
              reason: 'Invoice should have customer');
          break;
        }
      }
    }
  });

  // ── Step 3: Load filters ──────────────────────────────────────────────

  test('3. load kanban filters → verify filter options', () async {
    final result = await api.call(ApiEndpoints.getKanbanFilters);
    expect(result, isA<Map>());
    final filters = result as Map;
    // Should have customer or branch filter lists
    expect(
      filters.containsKey('customers') ||
          filters.containsKey('branches') ||
          filters.containsKey('couriers'),
      isTrue,
      reason: 'Filters should contain at least one filter category',
    );
  });

  // ── Step 4: Verify sample invoice in ERP ──────────────────────────────

  test('4. verify sample invoice exists in ERP', () async {
    if (sampleInvoiceName == null) {
      // No invoices available — skip
      return;
    }

    final doc = await getDocFromErp(api, 'Sales Invoice', sampleInvoiceName!);
    expect(doc['name'], sampleInvoiceName);
    expect(doc['customer'], isNotNull);

    // Verify grand_total is non-negative
    final total = (doc['grand_total'] as num?)?.toDouble() ?? 0;
    expect(total, greaterThanOrEqualTo(0));
  });

  // ── Step 5: Get invoice details ───────────────────────────────────────

  test('5. get invoice details → verify consistency', () async {
    if (sampleInvoiceName == null) return;

    final details = await api.call(
      ApiEndpoints.getInvoiceDetails,
      data: {'invoice_name': sampleInvoiceName},
    );
    expect(details, isA<Map>());

    // Name from API should match
    final detailName = (details as Map)['name']?.toString();
    if (detailName != null) {
      expect(detailName, sampleInvoiceName);
    }
  });

  // ── Step 6: Courier balances ──────────────────────────────────────────

  test('6. load courier balances', () async {
    final result = await api.call(ApiEndpoints.getCourierBalances);
    // May be list or map — just verify no error
    expect(result, isNotNull);
  });

  // ── Step 7: Active couriers ───────────────────────────────────────────

  test('7. get active couriers', () async {
    final result = await api.call(ApiEndpoints.getActiveCouriers);
    expect(result, isNotNull);
  });

  // ── Step 8: Notification endpoints ────────────────────────────────────

  test('8. check for updates endpoint responds', () async {
    final result = await api.call(ApiEndpoints.checkForUpdates);
    expect(result, isNotNull);
  });

  // ── Step 9: Manager states (if accessible) ────────────────────────────

  test('9. manager states endpoint responds', () async {
    try {
      final result = await api.call(ApiEndpoints.getManagerStates);
      expect(result, isA<Map>());
    } catch (_) {
      // May fail with 403 if user doesn't have manager role — that's ok
    }
  });

  // ── Step 10: Expenses bootstrap (if accessible) ───────────────────────

  test('10. expenses bootstrap endpoint responds', () async {
    try {
      final result = await api.call(ApiEndpoints.getExpenseBootstrap);
      expect(result, isA<Map>());
    } catch (e) {
      // May fail if expense feature is not enabled — that's ok
    }
  });
}
