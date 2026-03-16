/// E2E: POS checkout flow against the staging server.
///
/// Validates: load profiles → load items → search/create customer →
///            create invoice → pay invoice → verify.
///
/// Run with:
///   flutter test integration_test/pos_checkout_flow_test.dart
///     --dart-define=STAGING_USER=myuser --dart-define=STAGING_PASSWORD=mypass
@TestOn('vm')
library;

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';

import 'helpers/api_client.dart';
import 'helpers/staging_config.dart';

void main() {
  late StagingApiClient api;
  String? posProfile;
  String? openingEntry;

  setUpAll(() async {
    api = StagingApiClient();
    await api.login();

    // Resolve POS profile.
    if (StagingConfig.posProfile.isNotEmpty) {
      posProfile = StagingConfig.posProfile;
    } else {
      final profiles = await api.call(ApiEndpoints.getPosProfiles);
      posProfile = (profiles as List).first.toString();
    }

    // Ensure a shift is open for POS operations.
    final existing = await api.call(ApiEndpoints.getActiveShift);
    if (existing is Map) {
      openingEntry =
          (existing['name'] ?? existing['opening_entry']).toString();
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
    }
  });

  tearDownAll(() async {
    // Close the shift we opened (if we opened one).
    if (openingEntry != null) {
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

  // ── POS profiles ────────────────────────────────────────────────────

  test('get POS profiles returns non-empty list', () async {
    final profiles = await api.call(ApiEndpoints.getPosProfiles);
    expect(profiles, isA<List>());
    expect((profiles as List).isNotEmpty, isTrue);
  });

  // ── Items ───────────────────────────────────────────────────────────

  late List<dynamic> items;

  test('get profile products returns item list', () async {
    final result = await api.call(
      ApiEndpoints.getProfileProducts,
      data: {'profile': posProfile},
    );

    expect(result, isA<List>());
    items = result as List;
    expect(items.isNotEmpty, isTrue, reason: 'Profile should have items');

    final firstItem = items.first as Map;
    expect(firstItem.containsKey('item_code'), isTrue);
  });

  // ── Bundles ─────────────────────────────────────────────────────────

  test('get profile bundles returns list', () async {
    final bundles = await api.call(
      ApiEndpoints.getProfileBundles,
      data: {'profile': posProfile},
    );

    expect(bundles, isA<List>());
    // Bundles may be empty, that's fine.
  });

  // ── Customer search ─────────────────────────────────────────────────

  late String customerName;

  test('search customers returns results', () async {
    final result = await api.call(
      ApiEndpoints.searchCustomers,
      data: {'name': 'test'},
    );

    expect(result, isA<List>());
    if ((result as List).isNotEmpty) {
      final first = result.first as Map;
      expect(first.containsKey('name'), isTrue);
      customerName = first['name'].toString();
    } else {
      // Fallback: use a generic customer name.
      customerName = 'Walk In Customer';
    }
  });

  // ── Delivery slots ──────────────────────────────────────────────────

  test('get delivery slots returns list', () async {
    final slots = await api.call(
      ApiEndpoints.getAvailableDeliverySlots,
      data: {'pos_profile_name': posProfile},
    );

    expect(slots, isA<List>());
    // Slots may be empty if no delivery config.
  });

  // ── Create invoice ──────────────────────────────────────────────────

  late String invoiceName;

  test('create POS invoice succeeds', () async {
    // Pick the first item.
    final item = items.first as Map;
    final cartItems = [
      {
        'item_code': item['item_code'],
        'qty': 1,
        'rate': item['rate'] ?? item['price_list_rate'] ?? 10,
        'item_name': item['item_name'] ?? item['item_code'],
        'uom': item['uom'] ?? item['stock_uom'] ?? 'Nos',
      }
    ];

    final result = await api.call(
      ApiEndpoints.createPosInvoice,
      data: {
        'cart_json': jsonEncode(cartItems),
        'customer_name': customerName,
        'pos_profile_name': posProfile,
        'pickup': true,
      },
    );

    expect(result, isA<Map>());
    final invoice = result as Map;
    expect(invoice['name'], isNotNull, reason: 'Invoice should have a name');
    invoiceName = invoice['name'].toString();
  });

  // ── Pay invoice ─────────────────────────────────────────────────────

  test('pay invoice with Cash succeeds', () async {
    final result = await api.call(
      ApiEndpoints.payInvoice,
      data: {
        'invoice_name': invoiceName,
        'payment_mode': 'Cash',
        'pos_profile': posProfile,
      },
    );

    expect(result, isNotNull);
  });

  // ── Verify invoice appears on kanban ────────────────────────────────

  test('invoice appears in kanban invoices', () async {
    final data = await api.call(ApiEndpoints.getKanbanInvoices);

    expect(data, isA<Map>());
    // Search all columns for our invoice.
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
        reason: 'Created invoice should appear on kanban board');
  });

  // ── Account balance ─────────────────────────────────────────────────

  test('get POS profile account balance returns data', () async {
    final balance = await api.call(
      ApiEndpoints.getPosProfileAccountBalance,
      data: {'profile': posProfile},
    );

    expect(balance, isNotNull);
  });
}
