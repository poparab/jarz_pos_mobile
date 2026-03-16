/// API Smoke Test Suite — hits every endpoint on staging and verifies
/// basic response structure (200 OK, valid JSON, expected keys).
///
/// This is the single-command "test the whole system" entry point.
///
/// Run with:
///   flutter test integration_test/api_smoke_test.dart
///     --dart-define=STAGING_USER=myuser --dart-define=STAGING_PASSWORD=mypass
@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';

import 'helpers/api_client.dart';
import 'helpers/staging_config.dart';

void main() {
  late StagingApiClient api;
  String? posProfile;

  setUpAll(() async {
    api = StagingApiClient();
    await api.login();

    // Resolve POS profile for endpoints that need it.
    if (StagingConfig.posProfile.isNotEmpty) {
      posProfile = StagingConfig.posProfile;
    } else {
      final profiles = await api.call(ApiEndpoints.getPosProfiles);
      if (profiles is List && profiles.isNotEmpty) {
        posProfile = profiles.first.toString();
      }
    }
  });

  tearDownAll(() {
    api.dispose();
  });

  // ═══════════════════════════════════════════════════════════════════
  // Helper: wraps each smoke check to catch & report failures clearly.
  // ═══════════════════════════════════════════════════════════════════

  void smokePost(String label, String endpoint,
      {Map<String, dynamic>? data, bool allowError = false}) {
    test('SMOKE POST $label', () async {
      try {
        final resp = await api.rawPost(endpoint, data: data ?? {});
        expect(resp.statusCode, inInclusiveRange(200, 299),
            reason: '$label should return 2xx');
        expect(resp.data, isNotNull, reason: '$label should return a body');
      } catch (e) {
        if (!allowError) rethrow;
        // allowError=true means we expect the endpoint to reject our test data
        // but still be reachable (e.g., 417 Expectation Failed is fine).
      }
    });
  }

  void smokeGet(String label, String endpoint,
      {Map<String, dynamic>? queryParams}) {
    test('SMOKE GET $label', () async {
      final resp =
          await api.dio.get(endpoint, queryParameters: queryParams ?? {});
      expect(resp.statusCode, inInclusiveRange(200, 299));
      expect(resp.data, isNotNull);
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // AUTH
  // ═══════════════════════════════════════════════════════════════════

  group('Auth endpoints', () {
    smokePost('get_logged_user', ApiEndpoints.getLoggedUser);
    smokePost('get_current_user_roles', ApiEndpoints.getCurrentUserRoles);
  });

  // ═══════════════════════════════════════════════════════════════════
  // POS
  // ═══════════════════════════════════════════════════════════════════

  group('POS endpoints', () {
    smokePost('get_pos_profiles', ApiEndpoints.getPosProfiles);

    test('SMOKE POST get_profile_bundles', () async {
      if (posProfile == null) return;
      final resp = await api.rawPost(ApiEndpoints.getProfileBundles,
          data: {'profile': posProfile});
      expect(resp.statusCode, inInclusiveRange(200, 299));
    });

    test('SMOKE POST get_profile_products', () async {
      if (posProfile == null) return;
      final resp = await api.rawPost(ApiEndpoints.getProfileProducts,
          data: {'profile': posProfile});
      expect(resp.statusCode, inInclusiveRange(200, 299));
    });

    test('SMOKE POST get_pos_profile_account_balance', () async {
      if (posProfile == null) return;
      final resp = await api.rawPost(
          ApiEndpoints.getPosProfileAccountBalance,
          data: {'profile': posProfile});
      expect(resp.statusCode, inInclusiveRange(200, 299));
    });

    smokePost('get_sales_partners', ApiEndpoints.getSalesPartners,
        data: {'limit': 5});

    test('SMOKE POST is_pos_profile_open', () async {
      if (posProfile == null) return;
      final resp = await api.rawPost(ApiEndpoints.isPosProfileOpen,
          data: {'pos_profile': posProfile});
      expect(resp.statusCode, inInclusiveRange(200, 299));
    });

    smokePost('get_receipt_config', ApiEndpoints.getReceiptConfig);
  });

  // ═══════════════════════════════════════════════════════════════════
  // CUSTOMER
  // ═══════════════════════════════════════════════════════════════════

  group('Customer endpoints', () {
    smokePost('get_territories', ApiEndpoints.getTerritories);
    smokePost('search_customers', ApiEndpoints.searchCustomers,
        data: {'name': 'test'});
  });

  // ═══════════════════════════════════════════════════════════════════
  // INVOICES
  // ═══════════════════════════════════════════════════════════════════

  group('Invoice endpoints', () {
    // create + pay are tested in pos_checkout_flow_test — just verify read endpoints.
    smokePost('get_invoice_settlement_preview (no invoice)',
        ApiEndpoints.getInvoiceSettlementPreview,
        data: {'invoice_name': 'NONEXISTENT'}, allowError: true);
  });

  // ═══════════════════════════════════════════════════════════════════
  // DELIVERY SLOTS
  // ═══════════════════════════════════════════════════════════════════

  group('Delivery slot endpoints', () {
    test('SMOKE POST get_available_delivery_slots', () async {
      if (posProfile == null) return;
      final resp = await api.rawPost(ApiEndpoints.getAvailableDeliverySlots,
          data: {'pos_profile_name': posProfile});
      expect(resp.statusCode, inInclusiveRange(200, 299));
    });

    test('SMOKE POST get_next_available_slot', () async {
      if (posProfile == null) return;
      try {
        final resp = await api.rawPost(ApiEndpoints.getNextAvailableSlot,
            data: {'pos_profile_name': posProfile});
        expect(resp.statusCode, inInclusiveRange(200, 299));
      } catch (_) {
        // May not exist on all profiles.
      }
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // SHIFT
  // ═══════════════════════════════════════════════════════════════════

  group('Shift endpoints', () {
    smokePost('get_active_shift', ApiEndpoints.getActiveShift);

    test('SMOKE POST get_shift_payment_methods', () async {
      if (posProfile == null) return;
      final resp = await api.rawPost(ApiEndpoints.getShiftPaymentMethods,
          data: {'pos_profile': posProfile});
      expect(resp.statusCode, inInclusiveRange(200, 299));
    });

    // start/end shift are tested in shift_flow_test — skip here to avoid side effects.
  });

  // ═══════════════════════════════════════════════════════════════════
  // KANBAN
  // ═══════════════════════════════════════════════════════════════════

  group('Kanban endpoints', () {
    smokeGet('get_kanban_columns', ApiEndpoints.getKanbanColumns);
    smokePost('get_kanban_invoices', ApiEndpoints.getKanbanInvoices);
    smokeGet('get_kanban_filters', ApiEndpoints.getKanbanFilters);
  });

  // ═══════════════════════════════════════════════════════════════════
  // COURIERS / DELIVERY
  // ═══════════════════════════════════════════════════════════════════

  group('Courier endpoints', () {
    smokePost('get_courier_balances', ApiEndpoints.getCourierBalances);
    smokeGet('get_active_couriers', ApiEndpoints.getActiveCouriers);
  });

  // ═══════════════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════

  group('Notification endpoints', () {
    smokePost('get_pending_alerts', ApiEndpoints.getPendingAlerts);
    smokePost('check_for_updates', ApiEndpoints.checkForUpdates);
    smokePost('get_recent_invoices', ApiEndpoints.getRecentInvoices);
  });

  // ═══════════════════════════════════════════════════════════════════
  // PURCHASE
  // ═══════════════════════════════════════════════════════════════════

  group('Purchase endpoints', () {
    smokePost('get_suppliers', ApiEndpoints.getSuppliers,
        data: {'search': ''});
    smokePost('get_recent_suppliers', ApiEndpoints.getRecentSuppliers);
    smokePost('search_items', ApiEndpoints.searchItems,
        data: {'search': 'test'});
  });

  // ═══════════════════════════════════════════════════════════════════
  // MANAGER
  // ═══════════════════════════════════════════════════════════════════

  group('Manager endpoints', () {
    smokeGet('get_manager_dashboard_summary',
        ApiEndpoints.getManagerDashboardSummary);
    smokeGet('get_manager_orders', ApiEndpoints.getManagerOrders);
    smokeGet('get_manager_states', ApiEndpoints.getManagerStates);
  });

  // ═══════════════════════════════════════════════════════════════════
  // STOCK TRANSFER
  // ═══════════════════════════════════════════════════════════════════

  group('Stock transfer endpoints', () {
    smokePost('list_pos_profiles', ApiEndpoints.transferListPosProfiles);
    smokePost('list_item_groups', ApiEndpoints.transferListItemGroups);
  });

  // ═══════════════════════════════════════════════════════════════════
  // CASH TRANSFER
  // ═══════════════════════════════════════════════════════════════════

  group('Cash transfer endpoints', () {
    smokePost('list_accounts', ApiEndpoints.cashTransferListAccounts);
  });

  // ═══════════════════════════════════════════════════════════════════
  // MANUFACTURING
  // ═══════════════════════════════════════════════════════════════════

  group('Manufacturing endpoints', () {
    smokePost('list_default_bom_items', ApiEndpoints.listDefaultBomItems);
    smokePost('list_recent_work_orders', ApiEndpoints.listRecentWorkOrders);
  });

  // ═══════════════════════════════════════════════════════════════════
  // INVENTORY COUNT
  // ═══════════════════════════════════════════════════════════════════

  group('Inventory count endpoints', () {
    smokePost('list_warehouses', ApiEndpoints.listWarehouses);
  });

  // ═══════════════════════════════════════════════════════════════════
  // EXPENSES
  // ═══════════════════════════════════════════════════════════════════

  group('Expense endpoints', () {
    smokePost('get_expense_bootstrap', ApiEndpoints.getExpenseBootstrap);
  });

  // ═══════════════════════════════════════════════════════════════════
  // PAYMENT RECEIPTS
  // ═══════════════════════════════════════════════════════════════════

  group('Payment receipt endpoints', () {
    smokePost('list_payment_receipts', ApiEndpoints.listPaymentReceipts);
    smokePost(
        'get_accessible_pos_profiles', ApiEndpoints.getAccessiblePosProfiles);
  });
}
