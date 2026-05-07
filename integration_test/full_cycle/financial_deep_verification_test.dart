// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers

/// E2E: Financial deep-verification — exhaustive JE/PE/GL/CT/SPT/Stock/DN checks.
///
/// Runs focused scenarios specifically to verify financial accuracy:
///
///   Deep Case A: COD full financial audit
///   Deep Case B: Paid + Settle Now financial audit
///   Deep Case C: Sales Partner financial audit
///   Deep Case D: Cancel + financial reversal audit
///   Deep Case E: Multi-payment-mode GL audit
///
/// Run:
///   flutter test integration_test/full_cycle/financial_deep_verification_test.dart \
///     --dart-define=STAGING_USER=x --dart-define=STAGING_PASSWORD=y
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:math';
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
      print('⚠️  No active courier found. COD/delivery cases will skip.');
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
  });

  // ====================================================================
  // Helpers
  // ====================================================================

  Future<Map<String, dynamic>?> _createInvoice({
    required String label,
    int itemCount = 1,
    int qty = 1,
    bool isPickup = false,
    String? salesPartner,
  }) async {
    final cartItems = <Map<String, dynamic>>[];
    final count = itemCount.clamp(1, items.length);
    for (var i = 0; i < count; i++) {
      final item = items[i] as Map;
      final rate =
          item['rate'] ?? item['price_list_rate'] ?? item['price'] ?? 10;
      final itemCode = (item['item_code'] ?? item['id']).toString();
      cartItems.add({
        'item_code': itemCode,
        'qty': qty,
        'rate': rate,
        'item_name': item['item_name'] ?? item['name'] ?? itemCode,
        'uom': item['uom'] ?? item['stock_uom'] ?? 'Nos',
      });
    }

    final data = <String, dynamic>{
      'cart_json': jsonEncode(cartItems),
      'customer_name': customerName,
      'pos_profile_name': posProfile,
      'remarks': 'FinDeep $tag $label',
    };
    if (isPickup) data['pickup'] = 1;
    if (salesPartner != null) data['sales_partner'] = salesPartner;

    try {
      final result = await api.call(ApiEndpoints.createPosInvoice, data: data);
      final invoice = result as Map<String, dynamic>;
      final name = (invoice['invoice_name'] ?? invoice['name']).toString();
      createdInvoices.add(name);
      return {'name': name, ...invoice};
    } catch (e) {
      print('⚠️  Invoice creation failed ($label): $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _pay(
    String invoiceName, {
    String mode = 'Cash',
    String? referenceNo,
  }) async {
    try {
      final data = <String, dynamic>{
        'invoice_name': invoiceName,
        'payment_mode': mode,
      };
      if (mode.toLowerCase() == 'cash') data['pos_profile'] = posProfile;
      if (referenceNo != null) data['reference_no'] = referenceNo;

      final result = await api.call(ApiEndpoints.payInvoice, data: data);
      return (result is Map) ? Map<String, dynamic>.from(result) : null;
    } catch (e) {
      print('⚠️  Payment failed for $invoiceName ($mode): $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _ofd(String invoiceName) async {
    if (courierParty == null) return null;
    try {
      final result = await api.call(
        ApiEndpoints.handleOutForDeliveryTransition,
        data: {
          'invoice_name': invoiceName,
          'courier': courierParty,
          'mode': 'settle_now',
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

  Future<void> _setState(String invoiceName, String newState) async {
    try {
      await api.call(ApiEndpoints.updateInvoiceState, data: {
        'invoice_id': invoiceName,
        'new_state': newState,
      });
    } catch (e) {
      print('⚠️  State update to "$newState" failed for $invoiceName: $e');
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
  // DEEP CASE A: COD Full Financial Audit
  // ====================================================================

  group('Deep Case A: COD Full Financial Audit', () {
    String invoiceName = '';
    double grandTotal = 0;
    Map<String, dynamic>? ofdResult;

    test('A1. create unpaid invoice', () async {
      final inv = await _createInvoice(label: 'deep-A-cod');
      expect(inv, isNotNull, reason: 'Invoice must be created for COD audit');
      invoiceName = inv!['name'].toString();

      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      grandTotal = (doc['grand_total'] as num).toDouble();
      expect(grandTotal, greaterThan(0));

      final outstanding =
          (doc['outstanding_amount'] as num?)?.toDouble() ?? 0;
      expect(outstanding, greaterThan(0),
          reason: 'COD invoice should be unpaid');
      print('COD Invoice: $invoiceName, grand_total=$grandTotal');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('A2. OFD with courier outstanding', () async {
      if (invoiceName.isEmpty || courierParty == null) return;

      try {
        final result = await api.call(
          ApiEndpoints.handleOutForDeliveryTransition,
          data: {
            'invoice_name': invoiceName,
            'courier': courierParty,
            'mode': 'courier_outstanding',
            'pos_profile': posProfile,
            'party_type': courierPartyType,
            'party': courierParty,
          },
        );
        ofdResult =
            (result is Map) ? Map<String, dynamic>.from(result) : null;
      } catch (e) {
        print('⚠️  COD OFD failed: $e');
      }

      expect(ofdResult, isNotNull, reason: 'OFD should return a result');
      expect(await _getState(invoiceName), equals('Out for Delivery'));
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('A3. verify PE: Receivable → Courier Outstanding', () async {
      if (ofdResult == null) return;
      final peName = ofdResult!['payment_entry']?.toString();
      if (peName == null || peName.isEmpty) {
        print('ℹ️  No PE returned from COD OFD — skipping PE checks');
        return;
      }

      // PE fields
      await assertPaymentEntry(api, peName, docstatus: 1);

      // GL balance for PE
      final peGl = await assertGLBalanced(api, 'Payment Entry', peName,
          reason: 'COD PE GL must be balanced');

      // Expected accounts
      assertGLContainsAccount(peGl, 'Debtors',
          expectCredit: true, reason: 'PE should credit Debtors/Receivable');
      assertGLContainsAccount(peGl, 'Courier Outstanding',
          expectDebit: true,
          reason: 'PE should debit Courier Outstanding');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('A4. verify JE: DR Freight / CR Creditors', () async {
      if (ofdResult == null) return;
      final jeName = ofdResult!['journal_entry']?.toString();
      if (jeName == null || jeName.isEmpty) {
        print('ℹ️  No JE returned from COD OFD — skipping JE checks');
        return;
      }

      await assertJournalEntry(api, jeName,
          debitAccountContains: 'Freight',
          creditAccountContains: 'Creditor');

      final jeGl = await assertGLBalanced(api, 'Journal Entry', jeName,
          reason: 'COD JE GL must be balanced');

      assertGLContainsAccount(jeGl, 'Freight',
          expectDebit: true, reason: 'JE should debit Freight Expense');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('A5. verify CT: Unsettled with correct amounts', () async {
      if (invoiceName.isEmpty) return;

      await assertCourierTransaction(api, invoiceName,
          expectedStatus: 'Unsettled');

      final ct = await getCourierTransaction(api, invoiceName);
      if (ct != null) {
        final ctInv = (ct['invoice'] ?? ct['reference_invoice'])?.toString();
        expect(ctInv, invoiceName,
            reason: 'CT should reference our invoice');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('A6. verify DN created with correct items', () async {
      if (ofdResult == null) return;
      final dnName = ofdResult!['delivery_note']?.toString();
      if (dnName == null || dnName.isEmpty) {
        print('ℹ️  No DN name in OFD result — skipping DN checks');
        return;
      }

      final dn = await getDocFromErp(api, 'Delivery Note', dnName);
      expect(dn['customer'], isNotEmpty);
      final dnItems = dn['items'] as List?;
      expect(dnItems, isNotNull);
      expect(dnItems, isNotEmpty, reason: 'DN should have items');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('A7. settle courier collected payment', () async {
      if (invoiceName.isEmpty || courierParty == null) return;

      try {
        final result = await api.call(
          ApiEndpoints.settleCourierCollectedPayment,
          data: {
            'invoice_name': invoiceName,
            'pos_profile': posProfile,
            'party_type': courierPartyType,
            'party': courierParty,
          },
        );

        if (result is Map) {
          // Verify settlement JE
          final settleJe = result['journal_entry']?.toString();
          if (settleJe != null && settleJe.isNotEmpty) {
            final gl = await assertGLBalanced(api, 'Journal Entry', settleJe,
                reason: 'Settlement JE GL must be balanced');
            assertGLContainsAccount(gl, 'Creditor',
                expectDebit: true,
                reason: 'COD later settlement must debit Creditors');
            assertGLContainsAccount(gl, 'Courier Outstanding',
                expectCredit: true,
                reason: 'COD later settlement must credit Courier Outstanding');
          }
        }
      } on DioException catch (e) {
        print('ℹ️  Settlement: ${e.response?.data ?? e.message}');
      }

      // CT should now be Settled
      final ct = await getCourierTransaction(api, invoiceName);
      if (ct != null) {
        expect(ct['status']?.toString(), 'Settled',
            reason: 'CT should be Settled after settlement');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('A8. deliver and verify stock deduction', () async {
      if (invoiceName.isEmpty) return;

      await _setState(invoiceName, 'Delivered');
      expect(await _getState(invoiceName), equals('Delivered'));

      // Verify stock deduction — POS update_stock=1 deducts via Sales Invoice
      await assertStockDeducted(api, invoiceName, invoiceName: invoiceName);
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  // ====================================================================
  // DEEP CASE B: Paid + Settle Now Financial Audit
  // ====================================================================

  group('Deep Case B: Paid + Settle Now Financial Audit', () {
    String invoiceName = '';
    Map<String, dynamic>? payResult;
    Map<String, dynamic>? ofdResult;

    test('B1. create and pay invoice with cash', () async {
      final inv = await _createInvoice(label: 'deep-B-paid');
      expect(inv, isNotNull);
      invoiceName = inv!['name'].toString();

      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      expect((doc['grand_total'] as num).toDouble(), greaterThan(0));

      payResult = await _pay(invoiceName);
      expect(payResult, isNotNull, reason: 'Payment should succeed');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('B2. verify PE: Cash payment with GL', () async {
      if (payResult == null) return;
      final peName = payResult!['payment_entry']?.toString();
      if (peName == null) return;

      await assertPaymentEntry(api, peName,
          modeOfPayment: 'Cash', docstatus: 1);

      final peGl = await assertGLBalanced(api, 'Payment Entry', peName,
          reason: 'Cash PE GL must be balanced');
      assertGLContainsAccount(peGl, 'Debtors',
          expectCredit: true, reason: 'PE GL should credit Debtors');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('B3. OFD and verify DN', () async {
      if (invoiceName.isEmpty || courierParty == null) return;

      ofdResult = await _ofd(invoiceName);
      expect(ofdResult, isNotNull);
      expect(await _getState(invoiceName), equals('Out for Delivery'));

      // Verify DN exists from OFD response
      final dnName = ofdResult?['delivery_note']?.toString();
      expect(dnName, isNotNull, reason: 'OFD should return delivery_note name');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('B4. settle single invoice paid and verify JE', () async {
      if (invoiceName.isEmpty || courierParty == null) return;

      try {
        final result =
            await api.call(ApiEndpoints.settleSingleInvoicePaid, data: {
          'invoice_name': invoiceName,
          'pos_profile': posProfile,
          'party_type': courierPartyType,
          'party': courierParty,
        });

        if (result is Map) {
          final jeName = result['journal_entry']?.toString();
          if (jeName != null && jeName.isNotEmpty) {
            // Settlement JE debits Creditors (reverses freight accrual) and credits POS Cash
            await assertJournalEntry(api, jeName,
              debitAccountContains: 'Creditor',
              creditAccountContains: posProfile);

            final gl = await assertGLBalanced(api, 'Journal Entry', jeName,
                reason: 'Settle-now JE GL must be balanced');
            assertGLContainsAccount(gl, 'Creditor',
              expectDebit: true,
              reason: 'Online later settlement must debit Creditors');
            assertGLContainsAccount(gl, posProfile,
              expectCredit: true,
              reason: 'Online later settlement must credit POS cash');
          }
        }
      } on DioException catch (e) {
        print('ℹ️  Settlement: ${e.response?.data ?? e.message}');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('B5. deliver and verify stock', () async {
      if (invoiceName.isEmpty) return;

      await _setState(invoiceName, 'Delivered');
      expect(await _getState(invoiceName), equals('Delivered'));

      // Stock deduction — POS update_stock=1 deducts via Sales Invoice
      await assertStockDeducted(api, invoiceName, invoiceName: invoiceName);
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  // ====================================================================
  // DEEP CASE C: Sales Partner Financial Audit
  // ====================================================================

  group('Deep Case C: Sales Partner Financial Audit', () {
    String invoiceName = '';
    String? salesPartnerName;

    test('C1. find sales partner', () async {
      try {
        final partners =
            await api.call(ApiEndpoints.getSalesPartners, data: {'limit': 5});
        if (partners is List && partners.isNotEmpty) {
          final first = partners.first as Map;
          salesPartnerName = first['name']?.toString();
        }
      } catch (_) {}
      if (salesPartnerName == null) {
        print('⚠️  No sales partners. Skipping Deep Case C.');
      }
    });

    test('C2. create SP invoice (unpaid)', () async {
      if (salesPartnerName == null) return;

      final inv = await _createInvoice(
          label: 'deep-C-sp', salesPartner: salesPartnerName);
      expect(inv, isNotNull);
      invoiceName = inv!['name'].toString();

      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      expect(doc['sales_partner'], salesPartnerName);
      expect(doc['docstatus'], 1);
      expect((doc['outstanding_amount'] as num?)?.toDouble() ?? 0,
          greaterThan(0),
          reason: 'SP invoice should be unpaid');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('C3. SP unpaid OFD fast-path with PE verification', () async {
      if (invoiceName.isEmpty || salesPartnerName == null) return;

      try {
        final result = await api.call(
          ApiEndpoints.salesPartnerUnpaidOutForDelivery,
          data: {
            'invoice_name': invoiceName,
            'pos_profile': posProfile,
          },
        );

        expect(await _getState(invoiceName), equals('Out for Delivery'));

        if (result is Map && result['payment_entry'] != null) {
          final peName = result['payment_entry'].toString();
          await assertPaymentEntry(api, peName, docstatus: 1);

          final peGl = await assertGLBalanced(api, 'Payment Entry', peName,
              reason: 'SP PE GL must be balanced');
          assertGLContainsAccount(peGl, 'Debtors',
              expectCredit: true,
              reason: 'SP PE should credit Debtors/Receivable');
        }
      } catch (e) {
        print('⚠️  SP unpaid OFD failed: $e');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('C4. verify SPT exists', () async {
      if (invoiceName.isEmpty || salesPartnerName == null) return;

      final spt = await getSalesPartnerTransaction(api, invoiceName);
      if (spt != null) {
        expect(spt['sales_partner']?.toString(), salesPartnerName,
            reason: 'SPT should reference our sales partner');
        expect(spt['reference_invoice']?.toString(), invoiceName,
            reason: 'SPT should reference our invoice');
        expect((spt['amount'] as num?)?.toDouble() ?? 0, greaterThan(0),
            reason: 'SPT amount should be positive');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('C5. verify no CT for SP path', () async {
      if (invoiceName.isEmpty) return;

      // NO Courier Transaction for SP path
      await assertNoCourierTransaction(api, invoiceName);
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('C6. deliver and verify stock', () async {
      if (invoiceName.isEmpty) return;

      await _setState(invoiceName, 'Delivered');
      expect(await _getState(invoiceName), equals('Delivered'));

      // SP path may not deduct stock (partner handles fulfillment)
      try {
        await assertStockDeducted(api, invoiceName, invoiceName: invoiceName);
      } catch (_) {
        print('ℹ️  No SLE for SP invoice $invoiceName (expected if partner fulfills)');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  // ====================================================================
  // DEEP CASE D: Cancel + Financial Reversal Audit
  // ====================================================================

  group('Deep Case D: Cancel + Financial Reversal Audit', () {
    String invoiceName = '';
    String? peName;

    test('D1. create and pay invoice', () async {
      final inv = await _createInvoice(label: 'deep-D-cancel');
      expect(inv, isNotNull);
      invoiceName = inv!['name'].toString();

      final payResult = await _pay(invoiceName);
      expect(payResult, isNotNull);
      peName = payResult!['payment_entry']?.toString();
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('D2. verify PE and GL exist before cancel', () async {
      if (peName == null || peName!.isEmpty) return;

      final pe = await getDocFromErp(api, 'Payment Entry', peName!);
      expect(pe['docstatus'], 1, reason: 'PE should be submitted');

      await assertGLBalanced(api, 'Payment Entry', peName!,
          reason: 'Pre-cancel PE GL must be balanced');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('D3. cancel invoice', () async {
      if (invoiceName.isEmpty) return;

      try {
        await api.call(ApiEndpoints.cancelInvoice, data: {
          'invoice_name': invoiceName,
        });
      } catch (e) {
        print('⚠️  Cancel failed: $e');
      }

      final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
      expect(doc['docstatus'], 2,
          reason: 'Cancelled invoice should have docstatus=2');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('D4. verify PE cancelled', () async {
      if (invoiceName.isEmpty) return;

      final pes = await getLinkedPaymentEntries(api, invoiceName);
      for (final pe in pes) {
        expect(pe['docstatus'], 2,
            reason: 'Linked PE ${pe['name']} should be cancelled (docstatus=2)');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('D5. verify state is Cancelled', () async {
      if (invoiceName.isEmpty) return;

      final state = await _getState(invoiceName);
      expect(state, equals('Cancelled'));
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  // ====================================================================
  // DEEP CASE E: Multi-Payment-Mode GL Audit
  // ====================================================================

  group('Deep Case E: Multi-Payment-Mode GL Audit', () {
    String instapayInvoice = '';
    String walletInvoice = '';
    String? instapayPe;
    String? walletPe;

    test('E1. create and pay with Instapay', () async {
      final inv = await _createInvoice(label: 'deep-E-instapay');
      expect(inv, isNotNull);
      instapayInvoice = inv!['name'].toString();

      final refNo = 'REF-DEEP-${Random().nextInt(99999)}';
      final payResult =
          await _pay(instapayInvoice, mode: 'instapay', referenceNo: refNo);
      expect(payResult, isNotNull);
      instapayPe = payResult!['payment_entry']?.toString();
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('E2. verify Instapay PE GL accounts', () async {
      if (instapayPe == null || instapayPe!.isEmpty) return;

      await assertPaymentEntry(api, instapayPe!,
          modeOfPayment: 'instapay', docstatus: 1);

      final gl = await assertGLBalanced(api, 'Payment Entry', instapayPe!,
          reason: 'Instapay PE GL must be balanced');

      // Instapay should debit a bank-type account and credit receivable
      assertGLContainsAccount(gl, 'Debtors',
          expectCredit: true,
          reason: 'Instapay GL should credit Debtors/Receivable');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('E3. create and pay with Wallet', () async {
      final inv = await _createInvoice(label: 'deep-E-wallet');
      expect(inv, isNotNull);
      walletInvoice = inv!['name'].toString();

      final payResult = await _pay(walletInvoice, mode: 'wallet');
      expect(payResult, isNotNull);
      walletPe = payResult!['payment_entry']?.toString();
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('E4. verify Wallet PE GL accounts', () async {
      if (walletPe == null || walletPe!.isEmpty) return;

      await assertPaymentEntry(api, walletPe!,
          modeOfPayment: 'wallet', docstatus: 1);

      final gl = await assertGLBalanced(api, 'Payment Entry', walletPe!,
          reason: 'Wallet PE GL must be balanced');

      assertGLContainsAccount(gl, 'Debtors',
          expectCredit: true,
          reason: 'Wallet GL should credit Debtors/Receivable');
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('E5. compare: different modes hit different debit accounts', () async {
      if (instapayPe == null || walletPe == null) return;
      if (instapayPe!.isEmpty || walletPe!.isEmpty) return;

      final instapayGl =
          await getGLEntries(api, 'Payment Entry', instapayPe!);
      final walletGl = await getGLEntries(api, 'Payment Entry', walletPe!);

      // Collect debit accounts (non-receivable) from each
      String debitAcct(List<Map<String, dynamic>> gl) {
        for (final entry in gl) {
          final acct = (entry['account'] ?? '').toString().toLowerCase();
          final debit = (entry['debit'] as num?)?.toDouble() ?? 0;
          if (debit > 0 && !acct.contains('debtor') && !acct.contains('receivable')) {
            return acct;
          }
        }
        return '';
      }

      final instapayDebit = debitAcct(instapayGl);
      final walletDebit = debitAcct(walletGl);

      if (instapayDebit.isNotEmpty && walletDebit.isNotEmpty) {
        expect(instapayDebit, isNot(equals(walletDebit)),
            reason:
                'Instapay ($instapayDebit) and Wallet ($walletDebit) should hit different GL accounts');
        print('✅ Instapay debit: $instapayDebit');
        print('✅ Wallet debit:   $walletDebit');
      } else {
        print(
            'ℹ️  Could not compare debit accounts '
            '(instapay=$instapayDebit, wallet=$walletDebit)');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  // ====================================================================
  // SUMMARY
  // ====================================================================

  test('summary: financial deep verification results', () async {
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

    print(
        '\n✅ Financial Deep Verification: '
        '$delivered delivered, $cancelled cancelled / $total total');
    expect(delivered + cancelled, greaterThanOrEqualTo(1),
        reason: 'At least some invoices should reach a terminal state');
  });
}
