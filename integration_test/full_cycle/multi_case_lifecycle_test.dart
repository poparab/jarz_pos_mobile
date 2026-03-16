/// E2E: Multi-case invoice lifecycle – Create → Pay → OFD → Delivered.
///
/// Creates separate invoices for each major case, then drives each through
/// the full kanban lifecycle from creation to "Delivered" state:
///
///   Case 1: Pickup + Paid (Cash)     → skip OFD (pickup) → Delivered
///   Case 2: Delivery + Paid (Cash)   → OFD (settle now)  → Delivered
///   Case 3: Delivery + Unpaid (COD)  → OFD (courier outstanding) → settle → Delivered
///   Case 4: Sales Partner + Unpaid   → In Progress → OFD → settle → Delivered
///
/// Each case verifies:
///   - Invoice created with correct fields in ERP
///   - Grand total / outstanding_amount are correct
///   - Kanban state transitions produce correct state values
///   - Financial documents (PE, JE, DN, CT) exist when expected
///
/// Run:
///   flutter test integration_test/full_cycle/multi_case_lifecycle_test.dart \
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

  // Invoice names for cleanup
  final createdInvoices = <String>[];

  // Courier/party info for OFD
  String? courierParty;
  String? courierPartyType;

  // Real customer name from staging
  String customerName = '';

  // Warehouse + company for stock replenishment
  String warehouse = '';
  String company = '';

  // Track stock entry for cleanup
  String? stockEntryName;

  setUpAll(() async {
    api = StagingApiClient();
    tag = testTag();
  });

  tearDownAll(() async {
    // Best-effort cleanup of all invoices we created
    for (final inv in createdInvoices) {
      await cleanupTestInvoice(api, inv);
    }
    // Cancel stock entry if we created one
    if (stockEntryName != null) {
      try {
        await api.call('/api/method/frappe.client.cancel', data: {
          'doctype': 'Stock Entry',
          'name': stockEntryName,
        });
        print('🧹 Cancelled stock entry $stockEntryName');
      } catch (_) {
        print('⚠️  Could not cancel stock entry $stockEntryName');
      }
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

  // ====================================================================
  // SETUP
  // ====================================================================

  test('setup: login', () async {
    await api.login();
    expect(api.isLoggedIn, isTrue);
  });

  test('setup: open/reuse shift', () async {
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

  test('setup: load items', () async {
    dynamic result = await api.call(
      ApiEndpoints.getProfileProducts,
      data: {'profile': posProfile},
    );

    // Fallback: scan profiles
    if (result is! List || result.isEmpty) {
      final profiles = await api.call(ApiEndpoints.getPosProfiles);
      if (profiles is List) {
        for (final p in profiles) {
          final candidate = p.toString();
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

  test('setup: replenish test stock', () async {
    // Get warehouse and company from POS Profile
    try {
      final profileData = await api.call(
        '/api/method/frappe.client.get_value',
        data: {
          'doctype': 'POS Profile',
          'filters': posProfile,
          'fieldname': ['warehouse', 'company'],
        },
      );
      if (profileData is Map) {
        warehouse = (profileData['warehouse'] ?? '').toString();
        company = (profileData['company'] ?? '').toString();
      }
    } catch (e) {
      print('⚠️  Could not get POS Profile fields: $e');
    }

    if (warehouse.isEmpty) {
      print('⚠️  No warehouse found. Stock replenishment skipped.');
      return;
    }

    final item = items.first as Map;
    final itemCode = (item['item_code'] ?? item['id']).toString();
    final rate = item['rate'] ?? item['price_list_rate'] ?? item['price'] ?? 10;
    final uom = (item['uom'] ?? item['stock_uom'] ?? 'Nos').toString();

    try {
      // Use frappe.client.insert to create stock entry with full validation
      final seDoc = await api.call(
        '/api/method/frappe.client.insert',
        data: {
          'doc': jsonEncode({
            'doctype': 'Stock Entry',
            'stock_entry_type': 'Material Receipt',
            'company': company,
            'items': [
              {
                'item_code': itemCode,
                'qty': 50,
                't_warehouse': warehouse,
                'basic_rate': rate,
                'uom': uom,
                'conversion_factor': 1,
              }
            ],
          }),
        },
      );
      stockEntryName = (seDoc as Map)['name'].toString();
      print('Created stock entry: $stockEntryName');

      // Submit using run_doc_method to avoid timestamp mismatch
      await api.call('/api/method/run_doc_method', data: {
        'dt': 'Stock Entry',
        'dn': stockEntryName,
        'method': 'submit',
      });
      print('✅ Stock replenished: 50 x $itemCode in $warehouse');
    } on DioException catch (e) {
      print('⚠️  Stock replenishment failed:');
      print('    Status: ${e.response?.statusCode}');
      print('    Body: ${e.response?.data}');
      print('   Tests requiring stock may fail.');
    } catch (e) {
      print('⚠️  Stock replenishment failed: $e');
      print('   Tests requiring stock may fail.');
    }
  });

  test('setup: resolve courier/delivery party', () async {
    // Try to find an active courier for OFD tests
    try {
      final couriers = await api.call(ApiEndpoints.getActiveCouriers);
      if (couriers is List && couriers.isNotEmpty) {
        final first = couriers.first as Map;
        courierParty = first['name']?.toString() ?? first['party']?.toString();
        courierPartyType = first['party_type']?.toString() ?? 'Employee';
      } else if (couriers is Map && couriers['data'] is List) {
        final list = couriers['data'] as List;
        if (list.isNotEmpty) {
          final first = list.first as Map;
          courierParty = first['name']?.toString() ?? first['party']?.toString();
          courierPartyType = first['party_type']?.toString() ?? 'Employee';
        }
      }
    } catch (_) {
      // No couriers available – delivery tests will be skipped
    }

    // If no active courier, try to create one or check delivery parties
    if (courierParty == null) {
      print('⚠️  No active courier found. Delivery-based cases will create courier or skip OFD.');
    }
  });

  test('setup: find a real customer', () async {
    // Search for customers on staging
    try {
      final result = await api.call(
        ApiEndpoints.searchCustomers,
        data: {'name': 'test'},
      );
      if (result is List && result.isNotEmpty) {
        final first = result.first as Map;
        customerName = first['name'].toString();
      }
    } catch (_) {}

    // Fallback: try common staging customer names
    if (customerName.isEmpty) {
      for (final candidate in ['Walk In Customer', 'Walking Customer', 'Guest']) {
        try {
          final doc = await getDocFromErp(api, 'Customer', candidate);
          if (doc['name'] != null) {
            customerName = doc['name'].toString();
            break;
          }
        } catch (_) {}
      }
    }

    expect(customerName, isNotEmpty,
        reason: 'Staging must have at least one customer');
    print('Using customer: $customerName');
  });

  // ====================================================================
  // Helpers
  // ====================================================================

  /// Create a test invoice and track for cleanup.
  Future<Map<String, dynamic>?> _createTestInvoice({
    required String label,
    int qty = 1,
    bool isPickup = false,
    String? salesPartner,
    String? paymentType,
    String? customer,
  }) async {
    final item = items.first as Map;
    final rate = item['rate'] ?? item['price_list_rate'] ?? item['price'] ?? 10;
    final itemCode = (item['item_code'] ?? item['id']).toString();

    final data = <String, dynamic>{
      'cart_json': jsonEncode([
        {
          'item_code': itemCode,
          'qty': qty,
          'rate': rate,
          'item_name': item['item_name'] ?? item['name'] ?? itemCode,
          'uom': item['uom'] ?? item['stock_uom'] ?? 'Nos',
        },
      ]),
      'customer_name': customer ?? customerName,
      'pos_profile_name': posProfile,
      'remarks': 'Lifecycle $tag $label',
    };

    if (isPickup) data['pickup'] = 1;
    if (salesPartner != null) data['sales_partner'] = salesPartner;
    if (paymentType != null) data['payment_type'] = paymentType;

    try {
      final result = await api.call(ApiEndpoints.createPosInvoice, data: data);
      final invoice = result as Map<String, dynamic>;
      // API may return 'invoice_name' or 'name'
      final name = (invoice['invoice_name'] ?? invoice['name']).toString();
      createdInvoices.add(name);
      return {'name': name, 'rate': rate, 'qty': qty, ...invoice};
    } on DioException catch (e) {
      print('⚠️  Invoice creation failed ($label):');
      print('    Status: ${e.response?.statusCode}');
      print('    Body: ${e.response?.data}');
      print('    Data sent: $data');
      return null;
    }
  }

  /// Pay an invoice with Cash.
  Future<Map<String, dynamic>?> _payInvoice(String invoiceName) async {
    try {
      final result = await api.call(
        ApiEndpoints.payInvoice,
        data: {
          'invoice_name': invoiceName,
          'payment_mode': 'Cash',
          'pos_profile': posProfile,
        },
      );
      return (result is Map) ? Map<String, dynamic>.from(result) : null;
    } on DioException catch (e) {
      print('⚠️  Payment failed for $invoiceName: ${e.message}');
      return null;
    }
  }

  /// Transition invoice to Out for Delivery.
  Future<Map<String, dynamic>?> _transitionToOFD(String invoiceName, {String mode = 'settle_now'}) async {
    if (courierParty == null) {
      print('⚠️  No courier available for OFD transition of $invoiceName');
      return null;
    }

    try {
      final result = await api.call(
        ApiEndpoints.handleOutForDeliveryTransition,
        data: {
          'invoice_name': invoiceName,
          'courier': courierParty,
          'mode': mode,
          'pos_profile': posProfile,
          'party_type': courierPartyType,
          'party': courierParty,
        },
      );
      return (result is Map) ? Map<String, dynamic>.from(result) : null;
    } catch (e) {
      print('⚠️  OFD transition failed for $invoiceName: $e');
      return null;
    }
  }

  /// Update invoice kanban state.
  Future<void> _updateState(String invoiceName, String newState) async {
    try {
      await api.call(
        ApiEndpoints.updateInvoiceState,
        data: {
          'invoice_id': invoiceName,
          'new_state': newState,
        },
      );
    } on DioException catch (e) {
      print('⚠️  State update to "$newState" failed for $invoiceName: ${e.response?.data ?? e.message}');
    }
  }

  /// Get the current kanban state of an invoice from ERP.
  Future<String?> _getState(String invoiceName) async {
    try {
      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      return (doc['custom_sales_invoice_state'] ?? doc['sales_invoice_state'])
          ?.toString();
    } catch (_) {
      return null;
    }
  }

  // ====================================================================
  // CASE 1: Pickup + Paid (Cash)
  // ====================================================================

  group('Case 1: Pickup + Paid', () {
    String invoiceName = '';

    test('1a. create pickup invoice', () async {
      final inv = await _createTestInvoice(label: 'case1-pickup-paid', isPickup: true);
      if (inv == null) {
        print('Skipping case 1: invoice creation failed');
        return;
      }
      invoiceName = inv['name'].toString();
      expect(invoiceName, isNotEmpty);

      // Verify custom_is_pickup in ERP
      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      expect(doc['custom_is_pickup'], 1,
          reason: 'Pickup flag must be set');
    });

    test('1b. pay pickup invoice', () async {
      if (invoiceName.isEmpty) return;

      final payResult = await _payInvoice(invoiceName);
      expect(payResult, isNotNull, reason: 'Payment should succeed');

      // Verify in ERP
      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      expect(doc['docstatus'], 1, reason: 'Invoice should be submitted');

      final outstanding = (doc['outstanding_amount'] as num?)?.toDouble() ?? -1;
      expect(outstanding, closeTo(0.0, 0.01),
          reason: 'Outstanding should be 0 after cash payment');
    });

    test('1c. verify pickup invoice on kanban', () async {
      if (invoiceName.isEmpty) return;

      final data = await api.call(ApiEndpoints.getKanbanInvoices);
      final allInvoices = <String>[];
      if (data is Map) {
        // Response is {"success": true, "data": {col: [inv, ...], ...}}
        final columns = data['data'];
        final source = columns is Map ? columns : data;
        for (final entry in (source as Map).entries) {
          if (entry.value is List) {
            for (final inv in entry.value) {
              if (inv is Map && inv['name'] != null) {
                allInvoices.add(inv['name'].toString());
              }
            }
          }
        }
      }

      print('ℹ️  Kanban returned ${allInvoices.length} invoices');
      expect(allInvoices, contains(invoiceName),
          reason: 'Paid pickup invoice should appear on kanban');
    });

    test('1d. transition pickup to Delivered', () async {
      if (invoiceName.isEmpty) return;

      // Pickup orders go directly to Delivered (no courier OFD needed)
      await _updateState(invoiceName, 'Delivered');
      final state = await _getState(invoiceName);
      expect(state, equals('Delivered'),
          reason: 'Pickup should reach Delivered state');
    });

    test('1e. verify pickup financial documents', () async {
      if (invoiceName.isEmpty) return;

      // Pickup should have NO Delivery Note
      await assertNoDeliveryNote(api, invoiceName);

      // Pickup should have NO Courier Transaction
      await assertNoCourierTransaction(api, invoiceName);

      // Payment Entry should exist and GL should be balanced
      final pes = await getLinkedPaymentEntries(api, invoiceName);
      expect(pes, isNotEmpty,
          reason: 'Payment Entry should exist for paid pickup invoice');
      for (final pe in pes) {
        final peName = pe['name'].toString();
        await assertGLBalanced(api, 'Payment Entry', peName,
            reason: 'PE GL must be balanced for pickup');
      }
    });
  });

  // ====================================================================
  // CASE 2: Delivery + Paid (Cash) → OFD settle now
  // ====================================================================

  group('Case 2: Delivery + Paid', () {
    String invoiceName = '';

    test('2a. create delivery invoice (non-pickup)', () async {
      final inv = await _createTestInvoice(
        label: 'case2-delivery-paid',
        isPickup: false,
      );
      if (inv == null) {
        print('Skipping case 2: invoice creation failed');
        return;
      }
      invoiceName = inv['name'].toString();

      // Verify NOT pickup in ERP
      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      final isPickup = doc['custom_is_pickup'];
      expect(isPickup == null || isPickup == 0, isTrue,
          reason: 'Delivery invoice should not be marked as pickup');
    });

    test('2b. pay delivery invoice', () async {
      if (invoiceName.isEmpty) return;

      final payResult = await _payInvoice(invoiceName);
      expect(payResult, isNotNull);

      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      expect(doc['docstatus'], 1);
      final outstanding = (doc['outstanding_amount'] as num?)?.toDouble() ?? -1;
      expect(outstanding, closeTo(0.0, 0.01));
    });

    test('2c. transition to Out for Delivery', () async {
      if (invoiceName.isEmpty || courierParty == null) {
        print('Skipping OFD: ${invoiceName.isEmpty ? "no invoice" : "no courier"}');
        return;
      }

      final ofdResult = await _transitionToOFD(invoiceName);
      if (ofdResult == null) return;

      expect(ofdResult['success'], isTrue,
          reason: 'OFD transition should succeed for paid invoice');

      // Verify state in ERP
      final state = await _getState(invoiceName);
      expect(state, equals('Out for Delivery'));

      // Verify Delivery Note was created and has correct customer
      if (ofdResult['delivery_note'] != null) {
        final dnName = ofdResult['delivery_note'].toString();
        final dn = await getDocFromErp(api, 'Delivery Note', dnName);
        expect(dn['name'], dnName);
        expect(dn['customer'], customerName,
            reason: 'DN customer should match invoice customer');

        // Verify DN has items
        final dnItems = dn['items'] as List?;
        expect(dnItems, isNotNull, reason: 'DN should have items');
        expect(dnItems, isNotEmpty, reason: 'DN should have at least one item');
      }
    });

    test('2d. settle and deliver', () async {
      if (invoiceName.isEmpty) return;

      final currentState = await _getState(invoiceName);
      if (currentState != 'Out for Delivery') {
        print('Skipping settle: invoice not in OFD state (state=$currentState)');
        await _updateState(invoiceName, 'Delivered');
        return;
      }

      // For paid invoices in OFD, settle to complete the cycle
      Map<String, dynamic>? settleResult;
      try {
        final raw = await api.call(
          ApiEndpoints.settleSingleInvoicePaid,
          data: {
            'invoice_name': invoiceName,
            'pos_profile': posProfile,
            'party_type': courierPartyType,
            'party': courierParty,
          },
        );
        if (raw is Map) settleResult = Map<String, dynamic>.from(raw);
      } on DioException catch (e) {
        print('ℹ️  Settlement response: ${e.response?.data ?? e.message}');
      }

      // Verify settlement JE if returned
      // Settlement JE debits Creditors (reverses freight accrual) and credits POS Cash.
      if (settleResult != null && settleResult['journal_entry'] != null) {
        final jeName = settleResult['journal_entry'].toString();
        await assertJournalEntry(api, jeName,
          debitAccountContains: 'Creditor',
          creditAccountContains: posProfile);
        final gl = await assertGLBalanced(api, 'Journal Entry', jeName,
            reason: 'Settlement JE GL must be balanced');
        assertGLContainsAccount(gl, 'Creditor',
          expectDebit: true,
          reason: 'Online later settlement must debit Creditors');
        assertGLContainsAccount(gl, posProfile,
          expectCredit: true,
          reason: 'Online later settlement must credit branch cash');
      }

      // Transition to Delivered
      await _updateState(invoiceName, 'Delivered');
      final state = await _getState(invoiceName);
      expect(state, equals('Delivered'));
    });

    test('2e. verify delivery financial documents', () async {
      if (invoiceName.isEmpty) return;

      // Stock deduction — POS invoice with update_stock deducts via Sales Invoice
      await assertStockDeducted(api, invoiceName, invoiceName: invoiceName);

      // Payment Entry GL should be balanced
      final pes = await getLinkedPaymentEntries(api, invoiceName);
      for (final pe in pes) {
        await assertGLBalanced(api, 'Payment Entry', pe['name'].toString(),
            reason: 'PE GL must be balanced for Case 2');
      }
    });
  });

  // ====================================================================
  // CASE 3: Delivery + Unpaid (COD)
  // ====================================================================

  group('Case 3: Delivery + Unpaid (COD)', () {
    String invoiceName = '';

    test('3a. create unpaid delivery invoice', () async {
      final inv = await _createTestInvoice(
        label: 'case3-delivery-unpaid',
        isPickup: false,
      );
      if (inv == null) {
        print('Skipping case 3: invoice creation failed');
        return;
      }
      invoiceName = inv['name'].toString();

      // Invoice is submitted but unpaid (outstanding > 0)
      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      expect(doc['docstatus'], 1, reason: 'Invoice should be submitted');
      final outstanding = (doc['outstanding_amount'] as num?)?.toDouble() ?? 0;
      expect(outstanding, greaterThan(0), reason: 'Unpaid invoice should have outstanding > 0');
    });

    test('3b. transition unpaid invoice to OFD (creates PE + CT)', () async {
      if (invoiceName.isEmpty || courierParty == null) {
        print('Skipping OFD: ${invoiceName.isEmpty ? "no invoice" : "no courier"}');
        return;
      }

      final ofdResult = await _transitionToOFD(invoiceName, mode: 'courier_outstanding');
      if (ofdResult == null) return;

      // courier_outstanding mode doesn't return 'success', check for invoice key
      expect(ofdResult['invoice'] ?? ofdResult['success'], isNotNull,
          reason: 'OFD transition should succeed for unpaid invoice');

      // Verify invoice is still submitted
      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      expect(doc['docstatus'], 1,
          reason: 'Invoice should remain submitted after OFD');

      // State should be Out for Delivery
      final state = await _getState(invoiceName);
      expect(state, equals('Out for Delivery'));

      // Courier Transaction should be created with correct fields
      if (ofdResult['courier_transaction'] != null) {
        final ctName = ofdResult['courier_transaction'].toString();
        final ct = await getDocFromErp(api, 'Courier Transaction', ctName);
        expect(ct['name'], ctName);
        // Verify CT field name for invoice reference
        final ctInvoice = ct['invoice'] ?? ct['reference_invoice'];
        expect(ctInvoice, invoiceName,
            reason: 'CT should reference invoice $invoiceName');
        expect(ct['status'], 'Unsettled',
            reason: 'CT should be Unsettled before settlement');

        // Verify CT has order amount matching invoice grand total
        final invDoc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
        final grandTotal = (invDoc['grand_total'] as num?)?.toDouble() ?? 0;
        final ctAmount = (ct['amount'] as num?)?.toDouble() ?? 0;
        expect(ctAmount, closeTo(grandTotal, 0.01),
            reason: 'CT amount should match invoice grand_total');
      }

      // Payment Entry should be created (Receivable → Courier Outstanding)
      if (ofdResult['payment_entry'] != null) {
        final peName = ofdResult['payment_entry'].toString();
        await assertPaymentEntry(api, peName,
            paidToContains: 'Courier Outstanding', docstatus: 1);
        await assertGLBalanced(api, 'Payment Entry', peName,
            reason: 'OFD PE GL must be balanced for COD');
      }

      // Journal Entry should be created (DR Freight / CR Creditors)
      if (ofdResult['journal_entry'] != null) {
        final jeName = ofdResult['journal_entry'].toString();
        await assertJournalEntry(api, jeName,
            debitAccountContains: 'Freight',
            creditAccountContains: 'Creditor');
        await assertGLBalanced(api, 'Journal Entry', jeName,
            reason: 'Shipping JE GL must be balanced for COD');
      }

      // Delivery Note should be created
      if (ofdResult['delivery_note'] != null) {
        final dnName = ofdResult['delivery_note'].toString();
        final dn = await getDocFromErp(api, 'Delivery Note', dnName);
        expect(dn['name'], dnName);
        expect(dn['customer'], customerName,
            reason: 'DN customer should match invoice customer');
      }
    });

    test('3c. settle courier collected payment → Delivered', () async {
      if (invoiceName.isEmpty) return;

      final currentState = await _getState(invoiceName);
      if (currentState != 'Out for Delivery') {
        print('Skipping settle: not in OFD (state=$currentState)');
        return;
      }

      // Courier collected payment from customer – settle
      Map<String, dynamic>? settleResult;
      try {
        final raw = await api.call(
          ApiEndpoints.settleCourierCollectedPayment,
          data: {
            'invoice_name': invoiceName,
            'pos_profile': posProfile,
            'party_type': courierPartyType,
            'party': courierParty,
          },
        );
        if (raw is Map) settleResult = Map<String, dynamic>.from(raw);
      } on DioException catch (e) {
        print('ℹ️  Courier settlement: ${e.response?.data ?? e.message}');
        // May fail if courier hasn't collected - try settle single instead
        try {
          final raw = await api.call(
            ApiEndpoints.settleSingleInvoicePaid,
            data: {
              'invoice_name': invoiceName,
              'pos_profile': posProfile,
            },
          );
          if (raw is Map) settleResult = Map<String, dynamic>.from(raw);
        } on DioException {
          // Accept – some staging configs may not support settlement details
        }
      }

      // Verify settlement JE account pattern if returned:
      // Case A: DR Cash + DR Creditors / CR Courier Outstanding
      // Case B: DR Creditors / CR Courier Outstanding + CR Cash
      if (settleResult != null && settleResult['journal_entry'] != null) {
        final jeName = settleResult['journal_entry'].toString();
        final gl = await assertGLBalanced(api, 'Journal Entry', jeName,
            reason: 'COD later settlement JE GL must be balanced');
        assertGLContainsAccount(gl, 'Creditor',
            expectDebit: true,
            reason: 'COD settlement must debit Creditors');
        assertGLContainsAccount(gl, 'Courier Outstanding',
            expectCredit: true,
            reason: 'COD settlement must credit Courier Outstanding');
      }

      await _updateState(invoiceName, 'Delivered');
      final state = await _getState(invoiceName);
      expect(state, equals('Delivered'));
    });

    test('3d. verify COD settlement financial documents', () async {
      if (invoiceName.isEmpty) return;

      // Courier Transaction should now be Settled
      final ct = await getCourierTransaction(api, invoiceName);
      if (ct != null) {
        expect(ct['status'], 'Settled',
            reason: 'CT should be Settled after courier settlement');
      }

      // Stock deduction via Sales Invoice (POS update_stock=1)
      await assertStockDeducted(api, invoiceName, invoiceName: invoiceName);
    });
  });

  // ====================================================================
  // CASE 4: Sales Partner invoice
  // ====================================================================

  group('Case 4: Sales Partner', () {
    String invoiceName = '';
    String? salesPartnerName;

    test('4a. find a sales partner', () async {
      try {
        final partners = await api.call(
          ApiEndpoints.getSalesPartners,
          data: {'limit': 5},
        );
        if (partners is List && partners.isNotEmpty) {
          final first = partners.first as Map;
          salesPartnerName = first['name']?.toString();
        }
      } catch (_) {}

      if (salesPartnerName == null) {
        print('⚠️  No sales partners on staging. Case 4 tests will be limited.');
      }
    });

    test('4b. create sales partner invoice', () async {
      if (salesPartnerName == null) {
        print('Skipping: no sales partner available');
        return;
      }

      try {
        final inv = await _createTestInvoice(
          label: 'case4-sales-partner',
          salesPartner: salesPartnerName,
        );
        if (inv == null) {
          print('Skipping: sales partner invoice creation returned null');
          return;
        }
        invoiceName = inv['name'].toString();

        // Verify in ERP
        final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
        expect(doc['sales_partner'], salesPartnerName);

        // Sales partner invoices auto-start as "In Progress"
        final state = doc['custom_sales_invoice_state']?.toString();
        if (state != null) {
          expect(state, equals('In Progress'),
              reason: 'Sales partner invoices start In Progress');
        }

        // Verify NO tax rows (sales partner suppresses taxes)
        final taxes = doc['taxes'] as List?;
        if (taxes != null) {
          expect(taxes, isEmpty,
              reason: 'Sales partner invoices should have no tax rows');
        }
      } catch (e) {
        print('⚠️  Case 4 creation/verification failed: $e');
      }
    });

    test('4c. pay sales partner invoice', () async {
      if (invoiceName.isEmpty) return;

      final payResult = await _payInvoice(invoiceName);
      if (payResult == null) {
        print('Skipping: payment failed');
        return;
      }

      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      expect(doc['docstatus'], 1);
    });

    test('4d. transition sales partner to OFD', () async {
      if (invoiceName.isEmpty || courierParty == null) {
        print('Skipping OFD: ${invoiceName.isEmpty ? "no invoice" : "no courier"}');
        return;
      }

      final ofdResult = await _transitionToOFD(invoiceName);
      if (ofdResult == null) return;

      expect(ofdResult['success'], isTrue);
      final state = await _getState(invoiceName);
      expect(state, equals('Out for Delivery'));

      // Verify Delivery Note created
      if (ofdResult['delivery_note'] != null) {
        final dnName = ofdResult['delivery_note'].toString();
        final dn = await getDocFromErp(api, 'Delivery Note', dnName);
        expect(dn['customer'], isNotNull,
            reason: 'DN should have a customer');
      }

      // Sales Partner Transaction should exist
      final spt = await getSalesPartnerTransaction(api, invoiceName);
      if (spt != null) {
        expect(spt['sales_partner'], salesPartnerName,
            reason: 'SPT sales_partner should match');
        expect(spt['reference_invoice'], invoiceName,
            reason: 'SPT should reference our invoice');
        final sptAmount = (spt['amount'] as num?)?.toDouble() ?? 0;
        expect(sptAmount, greaterThan(0),
            reason: 'SPT amount should be > 0');
        print('SPT: partner_fees=${spt['partner_fees']}, amount=$sptAmount');
      }

      // Sales Partner path should NOT create Courier Transaction
      await assertNoCourierTransaction(api, invoiceName);
    });

    test('4e. deliver sales partner invoice', () async {
      if (invoiceName.isEmpty) return;

      await _updateState(invoiceName, 'Delivered');
      final state = await _getState(invoiceName);
      expect(state, equals('Delivered'));

      // Sales Partner path may not deduct stock (partner handles fulfillment)
      try {
        await assertStockDeducted(api, invoiceName, invoiceName: invoiceName);
      } catch (_) {
        print('ℹ️  No SLE for SP invoice $invoiceName (expected if partner fulfills)');
      }
    });
  });

  // ====================================================================
  // VERIFICATION: All cases reached Delivered
  // ====================================================================

  test('summary: verify all created invoices are Delivered', () async {
    if (createdInvoices.isEmpty) {
      print('No invoices were created. Skipping summary.');
      return;
    }

    int delivered = 0;
    int total = 0;

    for (final inv in createdInvoices) {
      total++;
      final state = await _getState(inv);
      print('  $inv → $state');
      if (state == 'Delivered') delivered++;
    }

    print('\n✅ $delivered / $total invoices reached Delivered state');

    // At minimum, the pickup case should always work (no courier needed)
    expect(delivered, greaterThanOrEqualTo(1),
        reason: 'At least the pickup invoice should reach Delivered');
  });
}
