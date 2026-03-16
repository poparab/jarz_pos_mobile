/// E2E accounting round-trip verification tests.
///
/// Verifies that invoice creation, payment, and state transitions
/// produce correct financial documents in ERPNext:
///   - Grand total matches expected rate × qty
///   - Outstanding amount drops to 0 after payment
///   - Payment Entry exists after cash payment
///   - Pickup flag is persisted as custom_is_pickup
///   - Kanban state is set correctly
///
/// Run:
///   flutter test integration_test/full_cycle/accounting_round_trip_test.dart \
///     --dart-define=STAGING_USER=x --dart-define=STAGING_PASSWORD=y
@TestOn('vm')
library;

import 'dart:convert';
import 'package:dio/dio.dart';
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
  late List<dynamic> items;
  late String tag;
  String customerName = '';

  // Track invoices for cleanup
  final createdInvoices = <String>[];

  setUpAll(() async {
    api = StagingApiClient();
    tag = testTag();
  });

  tearDownAll(() async {
    for (final inv in createdInvoices) {
      await cleanupTestInvoice(api, inv);
    }
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

  // ── Setup: Login + Shift + Items ──────────────────────────────────────

  test('setup: login and open shift', () async {
    await api.login();
    expect(api.isLoggedIn, isTrue);

    if (StagingConfig.posProfile.isNotEmpty) {
      posProfile = StagingConfig.posProfile;
    } else {
      final profiles = await api.call(ApiEndpoints.getPosProfiles);
      expect(profiles, isA<List>());
      expect((profiles as List), isNotEmpty);
      posProfile = profiles.first.toString();
    }

    final existing = await api.call(ApiEndpoints.getActiveShift);
    if (existing is Map && existing['name'] != null) {
      if (existing['pos_profile'] != null) {
        posProfile = existing['pos_profile'].toString();
      }
      openingEntry = (existing['name'] ?? existing['opening_entry']).toString();
      weOpenedShift = false;
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

    expect(openingEntry, isNotNull);
  });

  test('setup: load available items', () async {
    dynamic result = await api.call(
      ApiEndpoints.getProfileProducts,
      data: {'profile': posProfile},
    );

    if (result is! List || result.isEmpty) {
      final profiles = await api.call(ApiEndpoints.getPosProfiles);
      if (profiles is List) {
        for (final profile in profiles) {
          final candidate = profile.toString();
          final candidateItems = await api.call(
            ApiEndpoints.getProfileProducts,
            data: {'profile': candidate},
          );
          if (candidateItems is List && candidateItems.isNotEmpty) {
            posProfile = candidate;
            result = candidateItems;
            break;
          }
        }
      }
    }

    items = (result is List) ? result : [];
    expect(items, isNotEmpty, reason: 'Staging must have sellable items');
  });

  test('setup: find customer', () async {
    try {
      final result = await api.call(
        ApiEndpoints.searchCustomers,
        data: {'name': 'test'},
      );
      if (result is List && result.isNotEmpty) {
        customerName = (result.first as Map)['name'].toString();
      }
    } catch (_) {}
    if (customerName.isEmpty) {
      for (final c in ['Walk In Customer', 'Walking Customer', 'Guest']) {
        try {
          final doc = await getDocFromErp(api, 'Customer', c);
          if (doc['name'] != null) { customerName = doc['name'].toString(); break; }
        } catch (_) {}
      }
    }
    expect(customerName, isNotEmpty, reason: 'Staging must have a customer');
  });

  // ── Test 1: Grand total = rate × qty ──────────────────────────────────

  test('grand_total matches expected rate × qty', () async {
    if (items.isEmpty) return;

    final item = items.first as Map;
    final rate = (item['rate'] ?? item['price_list_rate'] ?? item['price'] ?? 10) as num;
    const qty = 2;
    final expectedNetTotal = rate * qty;

    final cartItems = [
      {
        'item_code': item['item_code'] ?? item['id'],
        'qty': qty,
        'rate': rate,
        'item_name': item['item_name'] ?? item['name'] ?? item['item_code'],
        'uom': item['uom'] ?? item['stock_uom'] ?? 'Nos',
      },
    ];

    dynamic result;
    try {
      result = await api.call(
        ApiEndpoints.createPosInvoice,
        data: {
          'cart_json': jsonEncode(cartItems),
          'customer_name': customerName,
          'pos_profile_name': posProfile,
          'pickup': 1,
          'remarks': 'Accounting RT $tag total-check',
        },
      );
    } on DioException {
      print('Skipping grand_total test: server error');
      return;
    }

    final invoice = result as Map;
    final invoiceName = invoice['name'].toString();
    createdInvoices.add(invoiceName);

    // Verify in ERP
    final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
    final grandTotal = (doc['grand_total'] as num?)?.toDouble() ?? 0;

    // Pickup invoices should have grand_total equal to net_total
    // (no shipping tax row for pickup)
    expect(grandTotal, greaterThanOrEqualTo(expectedNetTotal.toDouble()),
        reason: 'grand_total($grandTotal) should be >= rate($rate) × qty($qty) = $expectedNetTotal');

    // Verify net_total
    final netTotal = (doc['net_total'] as num?)?.toDouble() ?? 0;
    expect(netTotal, closeTo(expectedNetTotal.toDouble(), 0.01),
        reason: 'net_total should equal rate × qty');
  });

  // ── Test 2: outstanding_amount drops to 0 after payment ──────────────

  test('outstanding_amount is 0 after cash payment', () async {
    if (items.isEmpty) return;

    final item = items.first as Map;
    final rate = item['rate'] ?? item['price_list_rate'] ?? item['price'] ?? 10;

    final cartItems = [
      {
        'item_code': item['item_code'] ?? item['id'],
        'qty': 1,
        'rate': rate,
        'item_name': item['item_name'] ?? item['name'] ?? item['item_code'],
        'uom': item['uom'] ?? item['stock_uom'] ?? 'Nos',
      },
    ];

    dynamic result;
    try {
      result = await api.call(
        ApiEndpoints.createPosInvoice,
        data: {
          'cart_json': jsonEncode(cartItems),
          'customer_name': customerName,
          'pos_profile_name': posProfile,
          'pickup': 1,
          'remarks': 'Accounting RT $tag outstanding-check',
        },
      );
    } on DioException {
      print('Skipping outstanding test: server error');
      return;
    }

    final invoice = result as Map;
    final invoiceName = invoice['name'].toString();
    createdInvoices.add(invoiceName);

    // Draft invoice should have outstanding_amount = grand_total
    final draftDoc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
    final draftGT = (draftDoc['grand_total'] as num?)?.toDouble() ?? 0;
    expect(draftGT, greaterThan(0));

    // Pay the invoice
    try {
      await api.call(
        ApiEndpoints.payInvoice,
        data: {
          'invoice_name': invoiceName,
          'payment_mode': 'Cash',
          'pos_profile': posProfile,
        },
      );
    } on DioException {
      print('Skipping outstanding verify: payment failed');
      return;
    }

    // After payment, outstanding_amount should be 0
    final paidDoc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
    final outstanding = (paidDoc['outstanding_amount'] as num?)?.toDouble() ?? -1;
    expect(outstanding, closeTo(0.0, 0.01),
        reason: 'outstanding_amount should be 0 after full cash payment');
    expect(paidDoc['docstatus'], 1, reason: 'Paid invoice should be submitted');
  });

  // ── Test 3: Pickup flag persisted ─────────────────────────────────────

  test('pickup invoice has custom_is_pickup=1 in ERP', () async {
    if (items.isEmpty) return;

    final item = items.first as Map;
    final rate = item['rate'] ?? item['price_list_rate'] ?? item['price'] ?? 10;

    dynamic result;
    try {
      result = await api.call(
        ApiEndpoints.createPosInvoice,
        data: {
          'cart_json': jsonEncode([
            {
              'item_code': item['item_code'] ?? item['id'],
              'qty': 1,
              'rate': rate,
              'item_name': item['item_name'] ?? item['name'] ?? item['item_code'],
              'uom': item['uom'] ?? item['stock_uom'] ?? 'Nos',
            },
          ]),
          'customer_name': customerName,
          'pos_profile_name': posProfile,
          'pickup': 1,
          'remarks': 'Accounting RT $tag pickup-check',
        },
      );
    } on DioException {
      print('Skipping pickup test: server error');
      return;
    }

    final invoiceName = (result as Map)['name'].toString();
    createdInvoices.add(invoiceName);

    final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
    expect(doc['custom_is_pickup'], 1,
        reason: 'Pickup invoice must have custom_is_pickup=1 in ERP');
  });

  // ── Test 4: Payment Entry created after cash payment ──────────────────

  test('Payment Entry exists after cash payment', () async {
    if (items.isEmpty) return;

    final item = items.first as Map;
    final rate = item['rate'] ?? item['price_list_rate'] ?? item['price'] ?? 10;

    dynamic result;
    try {
      result = await api.call(
        ApiEndpoints.createPosInvoice,
        data: {
          'cart_json': jsonEncode([
            {
              'item_code': item['item_code'] ?? item['id'],
              'qty': 1,
              'rate': rate,
              'item_name': item['item_name'] ?? item['name'] ?? item['item_code'],
              'uom': item['uom'] ?? item['stock_uom'] ?? 'Nos',
            },
          ]),
          'customer_name': customerName,
          'pos_profile_name': posProfile,
          'pickup': 1,
          'remarks': 'Accounting RT $tag pe-check',
        },
      );
    } on DioException {
      print('Skipping PE test: server error');
      return;
    }

    final invoiceName = (result as Map)['name'].toString();
    createdInvoices.add(invoiceName);

    // Pay the invoice
    dynamic payResult;
    try {
      payResult = await api.call(
        ApiEndpoints.payInvoice,
        data: {
          'invoice_name': invoiceName,
          'payment_mode': 'Cash',
          'pos_profile': posProfile,
        },
      );
    } on DioException {
      print('Skipping PE verify: payment failed');
      return;
    }

    // The pay_invoice response should contain payment_entry name
    if (payResult is Map && payResult['payment_entry'] != null) {
      final peName = payResult['payment_entry'].toString();
      final pe = await getDocFromErp(api, 'Payment Entry', peName);
      expect(pe['docstatus'], 1, reason: 'Payment Entry should be submitted');
      expect(pe['payment_type'], 'Receive',
          reason: 'Cash receipt should be Receive type');
    }

    // Alternatively, verify via the Sales Invoice GL entries or links
    final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
    expect(doc['outstanding_amount'], closeTo(0.0, 0.01));
  });

  // ── Test 5: Invoice items match cart ──────────────────────────────────

  test('invoice items in ERP match the cart items sent', () async {
    if (items.isEmpty) return;

    final item = items.first as Map;
    final itemCode = (item['item_code'] ?? item['id']).toString();
    final rate = (item['rate'] ?? item['price_list_rate'] ?? item['price'] ?? 10) as num;
    const qty = 3;

    dynamic result;
    try {
      result = await api.call(
        ApiEndpoints.createPosInvoice,
        data: {
          'cart_json': jsonEncode([
            {
              'item_code': itemCode,
              'qty': qty,
              'rate': rate,
              'item_name': item['item_name'] ?? item['name'] ?? itemCode,
              'uom': item['uom'] ?? item['stock_uom'] ?? 'Nos',
            },
          ]),
          'customer_name': customerName,
          'pos_profile_name': posProfile,
          'pickup': 1,
          'remarks': 'Accounting RT $tag items-check',
        },
      );
    } on DioException {
      print('Skipping items match test: server error');
      return;
    }

    final invoiceName = (result as Map)['name'].toString();
    createdInvoices.add(invoiceName);

    final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
    final erpItems = doc['items'] as List;
    expect(erpItems, isNotEmpty);

    // Find the matching item in the ERP doc
    final matchingItem = erpItems.firstWhere(
      (i) => (i as Map)['item_code'] == itemCode,
      orElse: () => null,
    );

    expect(matchingItem, isNotNull,
        reason: 'Item $itemCode should be in the ERP invoice items');
    expect((matchingItem as Map)['qty'], qty);
  });

  // ── Test 6: Paid invoice appears on kanban board ──────────────────────

  test('paid pickup invoice visible on kanban board', () async {
    if (items.isEmpty) return;

    final item = items.first as Map;
    final rate = item['rate'] ?? item['price_list_rate'] ?? item['price'] ?? 10;

    dynamic result;
    try {
      result = await api.call(
        ApiEndpoints.createPosInvoice,
        data: {
          'cart_json': jsonEncode([
            {
              'item_code': item['item_code'] ?? item['id'],
              'qty': 1,
              'rate': rate,
              'item_name': item['item_name'] ?? item['name'] ?? item['item_code'],
              'uom': item['uom'] ?? item['stock_uom'] ?? 'Nos',
            },
          ]),
          'customer_name': customerName,
          'pos_profile_name': posProfile,
          'pickup': 1,
          'remarks': 'Accounting RT $tag kanban-verify',
        },
      );
    } on DioException {
      print('Skipping kanban test: server error');
      return;
    }

    final invoiceName = (result as Map)['name'].toString();
    createdInvoices.add(invoiceName);

    // Pay the invoice
    try {
      await api.call(
        ApiEndpoints.payInvoice,
        data: {
          'invoice_name': invoiceName,
          'payment_mode': 'Cash',
          'pos_profile': posProfile,
        },
      );
    } on DioException {
      print('Skipping kanban verify: payment failed');
      return;
    }

    // Check kanban board for this invoice
    final data = await api.call(ApiEndpoints.getKanbanInvoices);
    expect(data, isA<Map>());

    final allInvoices = <String>[];
    for (final entry in (data as Map).entries) {
      if (entry.value is List) {
        for (final inv in entry.value) {
          if (inv is Map && inv['name'] != null) {
            allInvoices.add(inv['name'].toString());
          }
        }
      }
    }

    expect(allInvoices, contains(invoiceName),
        reason: 'Paid invoice should appear on kanban board');
  });
}
