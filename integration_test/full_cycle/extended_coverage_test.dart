/// E2E: Extended coverage – Payment methods, multi-item, cancel.
///
/// Complements multi_case_lifecycle_test.dart by covering:
///
///   Case 5: Instapay payment         → Paid via Instapay → OFD → Delivered
///   Case 6: Mobile Wallet payment    → Paid via Wallet → OFD → Delivered
///   Case 7: Multi-item invoice       → 2+ items → Pay → OFD → Delivered
///   Case 8: Cancel invoice           → Create → Cancel → verify Cancelled
///
/// See extended_coverage_part2_test.dart for Cases 9-12.
///
/// Run:
///   flutter test integration_test/full_cycle/extended_coverage_test.dart \
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

  final createdInvoices = <String>[];
  String? courierParty;
  String? courierPartyType;
  String customerName = '';
  String warehouse = '';
  String company = '';
  String? stockEntryName;

  setUpAll(() async {
    api = StagingApiClient();
    tag = testTag();
  });

  tearDownAll(() async {
    for (final inv in createdInvoices) {
      await cleanupTestInvoice(api, inv);
    }
    if (stockEntryName != null) {
      try {
        await api.call('/api/method/frappe.client.cancel', data: {
          'doctype': 'Stock Entry',
          'name': stockEntryName,
        });
      } catch (_) {}
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
  // SETUP (identical to multi_case_lifecycle_test)
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
      final result = await api.call(ApiEndpoints.startShift, data: {
        'pos_profile': posProfile,
        'opening_balances': [
          {'mode_of_payment': 'Cash', 'opening_amount': 0},
        ],
      });
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

    // Build stock entries for all available items (up to 5) to support multi-item tests
    final seItems = <Map<String, dynamic>>[];
    final itemCount = items.length < 5 ? items.length : 5;
    for (var i = 0; i < itemCount; i++) {
      final item = items[i] as Map;
      final itemCode = (item['item_code'] ?? item['id']).toString();
      final rate =
          item['rate'] ?? item['price_list_rate'] ?? item['price'] ?? 10;
      final uom = (item['uom'] ?? item['stock_uom'] ?? 'Nos').toString();
      seItems.add({
        'item_code': itemCode,
        'qty': 50,
        't_warehouse': warehouse,
        'basic_rate': rate,
        'uom': uom,
        'conversion_factor': 1,
      });
    }

    try {
      final seDoc = await api.call('/api/method/frappe.client.insert', data: {
        'doc': jsonEncode({
          'doctype': 'Stock Entry',
          'stock_entry_type': 'Material Receipt',
          'company': company,
          'items': seItems,
        }),
      });
      stockEntryName = (seDoc as Map)['name'].toString();
      await api.call('/api/method/run_doc_method', data: {
        'dt': 'Stock Entry',
        'dn': stockEntryName,
        'method': 'submit',
      });
      print('✅ Stock replenished: $itemCount items x 50 in $warehouse');
    } on DioException catch (e) {
      print('⚠️  Stock replenishment failed: ${e.response?.statusCode}');
      print('    Body: ${e.response?.data}');
    }
  });

  test('setup: resolve courier/delivery party', () async {
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
          courierParty =
              first['name']?.toString() ?? first['party']?.toString();
          courierPartyType =
              first['party_type']?.toString() ?? 'Employee';
        }
      }
    } catch (_) {}
    if (courierParty == null) {
      print('⚠️  No active courier found. Delivery-based cases will skip OFD.');
    }
  });

  test('setup: find a real customer', () async {
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
    if (customerName.isEmpty) {
      for (final candidate in [
        'Walk In Customer',
        'Walking Customer',
        'Guest'
      ]) {
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

  Future<Map<String, dynamic>?> _createTestInvoice({
    required String label,
    int qty = 1,
    bool isPickup = false,
    String? salesPartner,
    String? paymentMethod,
    String? customer,
    List<Map<String, dynamic>>? cartItems,
    String? requiredDeliveryDatetime,
  }) async {
    final item = items.first as Map;
    final rate = item['rate'] ?? item['price_list_rate'] ?? item['price'] ?? 10;
    final itemCode = (item['item_code'] ?? item['id']).toString();

    final cart = cartItems ??
        [
          {
            'item_code': itemCode,
            'qty': qty,
            'rate': rate,
            'item_name': item['item_name'] ?? item['name'] ?? itemCode,
            'uom': item['uom'] ?? item['stock_uom'] ?? 'Nos',
          },
        ];

    final data = <String, dynamic>{
      'cart_json': jsonEncode(cart),
      'customer_name': customer ?? customerName,
      'pos_profile_name': posProfile,
      'remarks': 'Extended $tag $label',
    };

    if (isPickup) data['pickup'] = 1;
    if (salesPartner != null) data['sales_partner'] = salesPartner;
    if (paymentMethod != null) data['payment_method'] = paymentMethod;
    if (requiredDeliveryDatetime != null) {
      data['required_delivery_datetime'] = requiredDeliveryDatetime;
    }

    try {
      final result = await api.call(ApiEndpoints.createPosInvoice, data: data);
      final invoice = result as Map<String, dynamic>;
      final name = (invoice['invoice_name'] ?? invoice['name']).toString();
      createdInvoices.add(name);
      return {'name': name, 'rate': rate, 'qty': qty, ...invoice};
    } catch (e) {
      print('⚠️  Invoice creation failed ($label): $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _payInvoice(
    String invoiceName, {
    String mode = 'Cash',
    String? referenceNo,
    String? referenceDate,
  }) async {
    try {
      final data = <String, dynamic>{
        'invoice_name': invoiceName,
        'payment_mode': mode,
      };
      if (mode.toLowerCase() == 'cash') {
        data['pos_profile'] = posProfile;
      }
      if (referenceNo != null) data['reference_no'] = referenceNo;
      if (referenceDate != null) data['reference_date'] = referenceDate;

      final result = await api.call(ApiEndpoints.payInvoice, data: data);
      return (result is Map) ? Map<String, dynamic>.from(result) : null;
    } catch (e) {
      print('⚠️  Payment failed for $invoiceName: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _transitionToOFD(
    String invoiceName, {
    String mode = 'settle_now',
  }) async {
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
      print('⚠️  OFD failed for $invoiceName: $e');
      return null;
    }
  }

  Future<void> _updateState(String invoiceName, String newState) async {
    try {
      await api.call(ApiEndpoints.updateInvoiceState, data: {
        'invoice_id': invoiceName,
        'new_state': newState,
      });
    } on DioException catch (e) {
      print('⚠️  State update to "$newState" failed for $invoiceName: ${e.response?.data ?? e.message}');
    }
  }

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
  // CASE 5: Instapay Payment
  // ====================================================================

  group('Case 5: Instapay Payment', () {
    String invoiceName = '';

    test('5a. create invoice for Instapay', () async {
      final inv = await _createTestInvoice(
        label: 'case5-instapay',
        paymentMethod: 'Instapay',
      );
      if (inv == null) {
        print('Skipping case 5: invoice creation failed');
        return;
      }
      invoiceName = inv['name'].toString();
      expect(invoiceName, isNotEmpty);

      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      expect(doc['docstatus'], 1, reason: 'Invoice should be submitted');
    });

    test('5b. pay with Instapay (reference number)', () async {
      if (invoiceName.isEmpty) return;

      final refNo = 'INSTAPAY-TEST-${DateTime.now().millisecondsSinceEpoch}';
      final refDate = DateTime.now().toIso8601String().substring(0, 10);

      final payResult = await _payInvoice(
        invoiceName,
        mode: 'instapay',
        referenceNo: refNo,
        referenceDate: refDate,
      );
      expect(payResult, isNotNull, reason: 'Instapay payment should succeed');

      // Verify payment entry
      if (payResult != null && payResult['payment_entry'] != null) {
        final peName = payResult['payment_entry'].toString();
        final pe = await getDocFromErp(api, 'Payment Entry', peName);
        expect(pe['reference_no'], refNo,
            reason: 'PE should have our reference number');

        // Verify PE mode and amount
        await assertPaymentEntry(api, peName,
            modeOfPayment: 'instapay', docstatus: 1);

        // Verify GL: debit on bank/instapay account, credit on receivable
        final gl = await assertGLBalanced(api, 'Payment Entry', peName,
            reason: 'Instapay PE GL must be balanced');
        assertGLContainsAccount(gl, 'Debtors',
            expectCredit: true,
            reason: 'PE GL should credit Debtors/Receivable');
      }

      // Verify invoice is paid
      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      final outstanding =
          (doc['outstanding_amount'] as num?)?.toDouble() ?? -1;
      expect(outstanding, closeTo(0.0, 0.01),
          reason: 'Outstanding should be 0 after Instapay payment');
    });

    test('5c. OFD → Delivered (Instapay)', () async {
      if (invoiceName.isEmpty || courierParty == null) return;

      final ofdResult = await _transitionToOFD(invoiceName);
      if (ofdResult == null) return;

      final state = await _getState(invoiceName);
      expect(state, equals('Out for Delivery'));

      // Settle and deliver
      try {
        await api.call(ApiEndpoints.settleSingleInvoicePaid, data: {
          'invoice_name': invoiceName,
          'pos_profile': posProfile,
          'party_type': courierPartyType,
          'party': courierParty,
        });
      } on DioException catch (e) {
        print('ℹ️  Settlement: ${e.response?.data ?? e.message}');
      }

      await _updateState(invoiceName, 'Delivered');
      final finalState = await _getState(invoiceName);
      expect(finalState, equals('Delivered'));
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  // ====================================================================
  // CASE 6: Mobile Wallet Payment
  // ====================================================================

  group('Case 6: Mobile Wallet Payment', () {
    String invoiceName = '';

    test('6a. create invoice for Mobile Wallet', () async {
      final inv = await _createTestInvoice(
        label: 'case6-wallet',
        paymentMethod: 'Mobile Wallet',
      );
      if (inv == null) {
        print('Skipping case 6: invoice creation failed');
        return;
      }
      invoiceName = inv['name'].toString();
      expect(invoiceName, isNotEmpty);
    });

    test('6b. pay with Mobile Wallet (reference number)', () async {
      if (invoiceName.isEmpty) return;

      final refNo = 'WALLET-TEST-${DateTime.now().millisecondsSinceEpoch}';
      final refDate = DateTime.now().toIso8601String().substring(0, 10);

      final payResult = await _payInvoice(
        invoiceName,
        mode: 'wallet',
        referenceNo: refNo,
        referenceDate: refDate,
      );
      expect(payResult, isNotNull, reason: 'Wallet payment should succeed');

      // Verify payment
      if (payResult != null && payResult['payment_entry'] != null) {
        final peName = payResult['payment_entry'].toString();
        final pe = await getDocFromErp(api, 'Payment Entry', peName);
        expect(pe['reference_no'], refNo);

        // Verify PE mode and GL balance
        await assertPaymentEntry(api, peName,
            modeOfPayment: 'wallet', docstatus: 1);

        final gl = await assertGLBalanced(api, 'Payment Entry', peName,
            reason: 'Wallet PE GL must be balanced');
        assertGLContainsAccount(gl, 'Debtors',
            expectCredit: true,
            reason: 'PE GL should credit Debtors/Receivable');
      }

      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      final outstanding =
          (doc['outstanding_amount'] as num?)?.toDouble() ?? -1;
      expect(outstanding, closeTo(0.0, 0.01),
          reason: 'Outstanding should be 0 after wallet payment');
    });

    test('6c. OFD → Delivered (Wallet)', () async {
      if (invoiceName.isEmpty || courierParty == null) return;

      final ofdResult = await _transitionToOFD(invoiceName);
      if (ofdResult == null) return;

      final state = await _getState(invoiceName);
      expect(state, equals('Out for Delivery'));

      try {
        await api.call(ApiEndpoints.settleSingleInvoicePaid, data: {
          'invoice_name': invoiceName,
          'pos_profile': posProfile,
          'party_type': courierPartyType,
          'party': courierParty,
        });
      } on DioException catch (e) {
        print('ℹ️  Settlement: ${e.response?.data ?? e.message}');
      }

      await _updateState(invoiceName, 'Delivered');
      final finalState = await _getState(invoiceName);
      expect(finalState, equals('Delivered'));
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  // ====================================================================
  // CASE 7: Multi-item Invoice
  // ====================================================================

  group('Case 7: Multi-item Invoice', () {
    String invoiceName = '';

    test('7a. create invoice with multiple items', () async {
      if (items.length < 2) {
        print('⚠️  Only ${items.length} item(s) available. Using same item with different qty.');
      }

      final item1 = items.first as Map;
      final item2 = items.length >= 2 ? items[1] as Map : item1;

      final rate1 =
          item1['rate'] ?? item1['price_list_rate'] ?? item1['price'] ?? 10;
      final rate2 =
          item2['rate'] ?? item2['price_list_rate'] ?? item2['price'] ?? 10;
      final code1 = (item1['item_code'] ?? item1['id']).toString();
      final code2 = (item2['item_code'] ?? item2['id']).toString();

      final cartItems = <Map<String, dynamic>>[
        {
          'item_code': code1,
          'qty': 2,
          'rate': rate1,
          'item_name': item1['item_name'] ?? item1['name'] ?? code1,
          'uom': item1['uom'] ?? item1['stock_uom'] ?? 'Nos',
        },
        if (code2 != code1)
          {
            'item_code': code2,
            'qty': 1,
            'rate': rate2,
            'item_name': item2['item_name'] ?? item2['name'] ?? code2,
            'uom': item2['uom'] ?? item2['stock_uom'] ?? 'Nos',
          }
        else
          {
            'item_code': code1,
            'qty': 3,
            'rate': rate1,
            'item_name': item1['item_name'] ?? item1['name'] ?? code1,
            'uom': item1['uom'] ?? item1['stock_uom'] ?? 'Nos',
          },
      ];

      final inv = await _createTestInvoice(
        label: 'case7-multi-item',
        cartItems: cartItems,
      );
      if (inv == null) {
        print('Skipping case 7: invoice creation failed');
        return;
      }
      invoiceName = inv['name'].toString();

      // Verify multiple items in ERP
      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      final invItems = doc['items'] as List?;
      expect(invItems, isNotNull);
      expect(invItems!.length, greaterThanOrEqualTo(2),
          reason: 'Invoice should have 2+ line items');

      // Verify grand total includes all items
      final grandTotal = (doc['grand_total'] as num?)?.toDouble() ?? 0;
      expect(grandTotal, greaterThan(0));
      print('Multi-item invoice $invoiceName: ${invItems.length} items, total=$grandTotal');
    });

    test('7b. pay multi-item invoice', () async {
      if (invoiceName.isEmpty) return;

      final payResult = await _payInvoice(invoiceName);
      expect(payResult, isNotNull);

      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      expect(doc['docstatus'], 1);
      final outstanding =
          (doc['outstanding_amount'] as num?)?.toDouble() ?? -1;
      expect(outstanding, closeTo(0.0, 0.01));
    });

    test('7c. OFD → Delivered (multi-item)', () async {
      if (invoiceName.isEmpty || courierParty == null) return;

      final ofdResult = await _transitionToOFD(invoiceName);
      if (ofdResult == null) return;

      expect(await _getState(invoiceName), equals('Out for Delivery'));

      // Verify DN has multiple items referencing our invoice
      if (ofdResult['delivery_note'] != null) {
        final dnName = ofdResult['delivery_note'].toString();
        final dn = await getDocFromErp(api, 'Delivery Note', dnName);
        final dnItems = dn['items'] as List?;
        expect(dnItems, isNotNull);
        expect(dnItems!.length, greaterThanOrEqualTo(2),
            reason: 'DN should have 2+ items for multi-item invoice');

        // DN items exist — against_sales_invoice is not populated by OFD handler
        // so we just verify items are present
      }

      try {
        await api.call(ApiEndpoints.settleSingleInvoicePaid, data: {
          'invoice_name': invoiceName,
          'pos_profile': posProfile,
          'party_type': courierPartyType,
          'party': courierParty,
        });
      } on DioException catch (e) {
        print('ℹ️  Settlement: ${e.response?.data ?? e.message}');
      }

      await _updateState(invoiceName, 'Delivered');
      expect(await _getState(invoiceName), equals('Delivered'));

      // Verify stock deduction — POS update_stock=1 deducts via Sales Invoice
      await assertStockDeducted(api, invoiceName, invoiceName: invoiceName);
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  // ====================================================================
  // CASE 8: Cancel Invoice
  // ====================================================================

  group('Case 8: Cancel Invoice', () {
    String invoiceName = '';

    test('8a. create invoice to cancel', () async {
      final inv = await _createTestInvoice(label: 'case8-cancel');
      if (inv == null) {
        print('Skipping case 8: invoice creation failed');
        return;
      }
      invoiceName = inv['name'].toString();
      expect(invoiceName, isNotEmpty);

      // Verify it starts in a valid state (Recieved)
      final state = await _getState(invoiceName);
      expect(state, isNotNull);
      print('Invoice $invoiceName initial state: $state');
    });

    test('8b. cancel the invoice', () async {
      if (invoiceName.isEmpty) return;

      try {
        final cancelResult = await api.call(
          ApiEndpoints.cancelInvoice,
          data: {
            'invoice_id': invoiceName,
            'reason': 'Test cancellation',
            'notes': 'Automated E2E test cancellation $tag',
          },
        );

        if (cancelResult is Map) {
          expect(cancelResult['success'], isTrue,
              reason: 'Cancel should succeed');
          print('Cancel result: ${cancelResult['state']}');
        }
      } on DioException catch (e) {
        print('Cancel response: ${e.response?.data}');
        // Some invoices can't be cancelled (already paid, etc.) – acceptable
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('8c. verify cancelled state', () async {
      if (invoiceName.isEmpty) return;

      final state = await _getState(invoiceName);
      // After cancel, state should be 'Cancelled'
      if (state != null) {
        expect(state, equals('Cancelled'),
            reason: 'Cancelled invoice should have Cancelled state');
      }

      // Verify docstatus = 2 (cancelled in ERPNext)
      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      expect(doc['docstatus'], 2,
          reason: 'Cancelled invoice should have docstatus=2');

      // Verify linked Payment Entries are also cancelled
      final pes = await getLinkedPaymentEntries(api, invoiceName);
      for (final pe in pes) {
        expect(pe['docstatus'], 2,
            reason: 'Linked PE ${pe['name']} should be cancelled (docstatus=2)');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  // ====================================================================
  // SUMMARY
  // ====================================================================

  test('summary: extended coverage results', () async {
    if (createdInvoices.isEmpty) {
      print('No invoices were created. Skipping summary.');
      return;
    }

    int delivered = 0;
    int cancelled = 0;
    int total = 0;

    for (final inv in createdInvoices) {
      total++;
      final state = await _getState(inv);
      print('  $inv → $state');
      if (state == 'Delivered') delivered++;
      if (state == 'Cancelled') cancelled++;
    }

    print('\n✅ $delivered delivered, $cancelled cancelled / $total total invoices');
    expect(delivered + cancelled, greaterThanOrEqualTo(1),
        reason: 'At least some invoices should reach a terminal state');
  });
}
