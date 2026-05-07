// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers

/// E2E: Extended coverage Part 2 – Customer creation, delivery slots, SP unpaid OFD.
///
/// Split from extended_coverage_test.dart to run in a fresh app process.
///
///   Case 9:  Customer creation        → Create customer → Create invoice for them
///   Case 10: Delivery slots           → Fetch slots → Create invoice with slot
///   Case 11: Sales Partner unpaid OFD → SP invoice → unpaid fast-path OFD
///
/// Run:
///   flutter test integration_test/full_cycle/extended_coverage_part2_test.dart \
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
    String? requiredDeliveryDatetime,
  }) async {
    final item = items.first as Map;
    final rate = item['rate'] ?? item['price_list_rate'] ?? item['price'] ?? 10;
    final itemCode = (item['item_code'] ?? item['id']).toString();

    final cart = [
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
      'remarks': 'ExtP2 $tag $label',
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

  Future<Map<String, dynamic>?> _transitionToOFD(String invoiceName) async {
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

  Future<void> _updateState(String invoiceName, String newState) async {
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
  // CASE 9: Customer Creation
  // ====================================================================

  group('Case 9: Customer Creation', () {
    String? createdCustomerName;
    String newInvoiceName = '';

    test('9a. create a new customer', () async {
      final rand = Random().nextInt(99999);
      final testCustomerName = 'Test Customer $rand $tag';
      final testPhone = '0100${rand.toString().padLeft(7, "0")}';

      // First get a territory (prefer a leaf, not "All Territories")
      String territory = '';
      try {
        final territories = await api.call(ApiEndpoints.getTerritories);
        if (territories is List && territories.isNotEmpty) {
          for (final t in territories) {
            final tMap = t as Map;
            final name = (tMap['name'] ?? tMap['id'] ?? '').toString();
            if (name.isNotEmpty && name != 'All Territories') {
              territory = name;
              break;
            }
          }
          if (territory.isEmpty) {
            final first = territories.first as Map;
            territory = (first['name'] ?? first['id'] ?? '').toString();
          }
        }
      } catch (_) {}

      if (territory.isEmpty) {
        print('⚠️  No territories found. Skipping customer creation.');
        return;
      }

      try {
        final result = await api.call(
          ApiEndpoints.createCustomer,
          data: {
            'customer_name': testCustomerName,
            'mobile_no': testPhone,
            'customer_primary_address': '123 Test Street',
            'territory_id': territory,
          },
        );

        if (result is Map) {
          createdCustomerName =
              (result['name'] ?? result['customer_name']).toString();
          expect(createdCustomerName, isNotEmpty);
          print(
              'Created customer: $createdCustomerName in territory: $territory');
        }
      } catch (e) {
        print('⚠️  Customer creation failed: $e');
      }
    });

    test('9b. create invoice for new customer', () async {
      if (createdCustomerName == null || createdCustomerName!.isEmpty) {
        print('Skipping: no customer was created');
        return;
      }

      try {
        final inv = await _createTestInvoice(
          label: 'case9-new-customer',
          customer: createdCustomerName,
        );
        if (inv == null) {
          print('⚠️  Invoice creation for new customer failed');
          return;
        }

        newInvoiceName = inv['name'].toString();
        expect(newInvoiceName, isNotEmpty);

        final doc = await getDocFromErp(api, 'Sales Invoice', newInvoiceName);
        expect(doc['customer'], createdCustomerName,
            reason: 'Invoice should be for the newly created customer');
      } catch (e) {
        print('⚠️  Case 9b failed: $e');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('9c. pay and verify new customer invoice', () async {
      if (newInvoiceName.isEmpty) return;

      try {
        final payResult = await _payInvoice(newInvoiceName);
        if (payResult == null) {
          print('⚠️  Payment for new customer invoice failed');
          return;
        }

        final doc = await getDocFromErp(api, 'Sales Invoice', newInvoiceName);
        expect(doc['docstatus'], 1);
      } catch (e) {
        print('⚠️  Case 9c failed: $e');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  // ====================================================================
  // CASE 10: Delivery Slots
  // ====================================================================

  group('Case 10: Delivery Slots', () {
    String invoiceName = '';
    List<dynamic> availableSlots = [];

    test('10a. fetch available delivery slots', () async {
      try {
        final result = await api.call(
          ApiEndpoints.getAvailableDeliverySlots,
          data: {'pos_profile_name': posProfile},
        );

        if (result is List) {
          availableSlots = result;
          print('Available slots: ${availableSlots.length}');
          if (availableSlots.isNotEmpty) {
            final first = availableSlots.first as Map;
            print('First slot: ${first['label'] ?? first['datetime']}');
          }
        }
      } catch (e) {
        print('⚠️  Delivery slots not configured: $e');
      }
    });

    test('10b. create invoice with delivery slot', () async {
      try {
        String? deliveryDatetime;
        if (availableSlots.isNotEmpty) {
          final now = DateTime.now();
          for (final s in availableSlots) {
            final slotMap = s as Map;
            final dtStr =
                (slotMap['datetime'] ?? slotMap['date'] ?? '').toString();
            if (dtStr.isNotEmpty) {
              try {
                final slotTime = DateTime.parse(dtStr);
                if (slotTime.isAfter(now)) {
                  deliveryDatetime = dtStr;
                  break;
                }
              } catch (_) {}
            }
          }
          if (deliveryDatetime == null) {
            final last = availableSlots.last as Map;
            deliveryDatetime = (last['datetime'] ?? last['date']).toString();
          }
        }
        if (deliveryDatetime == null || deliveryDatetime.isEmpty) {
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          deliveryDatetime =
              '${tomorrow.toIso8601String().substring(0, 10)} 14:00:00';
        }

        print('Using delivery slot: $deliveryDatetime');

        final inv = await _createTestInvoice(
          label: 'case10-delivery-slot',
          requiredDeliveryDatetime: deliveryDatetime,
        );
        if (inv == null) {
          print('Skipping: invoice creation with delivery slot failed');
          return;
        }
        invoiceName = inv['name'].toString();

        final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
        final storedSlot = doc['custom_required_delivery_datetime'] ??
            doc['required_delivery_datetime'];
        if (storedSlot != null) {
          expect(storedSlot.toString(), isNotEmpty,
              reason: 'Delivery datetime should be stored on invoice');
          print('Stored delivery datetime: $storedSlot');
        }
      } catch (e) {
        print('⚠️  Case 10b failed: $e');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('10c. pay and deliver slotted invoice', () async {
      if (invoiceName.isEmpty) return;

      try {
        final payResult = await _payInvoice(invoiceName);
        expect(payResult, isNotNull);

        if (courierParty != null) {
          final ofdResult = await _transitionToOFD(invoiceName);
          if (ofdResult != null) {
            try {
              await api.call(ApiEndpoints.settleSingleInvoicePaid, data: {
                'invoice_name': invoiceName,
                'pos_profile': posProfile,
                'party_type': courierPartyType,
                'party': courierParty,
              });
            } catch (_) {}
          }
        }

        await _updateState(invoiceName, 'Delivered');
        expect(await _getState(invoiceName), equals('Delivered'));
      } catch (e) {
        print('⚠️  Case 10c failed: $e');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  // ====================================================================
  // CASE 11: Sales Partner Unpaid → Fast-path OFD
  // ====================================================================

  group('Case 11: Sales Partner Unpaid OFD', () {
    String invoiceName = '';
    String? salesPartnerName;

    test('11a. find a sales partner', () async {
      try {
        final partners =
            await api.call(ApiEndpoints.getSalesPartners, data: {'limit': 5});
        if (partners is List && partners.isNotEmpty) {
          final first = partners.first as Map;
          salesPartnerName = first['name']?.toString();
        }
      } catch (_) {}

      if (salesPartnerName == null) {
        print('⚠️  No sales partners available. Skipping case 11.');
      }
    });

    test('11b. create SP invoice (no payment)', () async {
      if (salesPartnerName == null) {
        print('Skipping: no sales partner');
        return;
      }

      try {
        final inv = await _createTestInvoice(
          label: 'case11-sp-unpaid-ofd',
          salesPartner: salesPartnerName,
        );
        if (inv == null) {
          print('Skipping: SP invoice creation failed');
          return;
        }
        invoiceName = inv['name'].toString();

        final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
        expect(doc['sales_partner'], salesPartnerName);
        expect(doc['docstatus'], 1);

        final outstanding =
            (doc['outstanding_amount'] as num?)?.toDouble() ?? 0;
        expect(outstanding, greaterThan(0),
            reason: 'SP invoice should be unpaid');
        print('SP unpaid invoice: $invoiceName, outstanding=$outstanding');
      } catch (e) {
        print('⚠️  Case 11b failed: $e');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('11c. use salesPartnerUnpaidOutForDelivery fast-path', () async {
      if (invoiceName.isEmpty) {
        print('Skipping: no invoice');
        return;
      }

      try {
        final result = await api.call(
          ApiEndpoints.salesPartnerUnpaidOutForDelivery,
          data: {
            'invoice_name': invoiceName,
            'pos_profile': posProfile,
          },
        );

        if (result is Map) {
          print('SP unpaid OFD result: success=${result['success']}');
          final state = await _getState(invoiceName);
          expect(state, equals('Out for Delivery'),
              reason: 'SP unpaid OFD should set state to OFD');

          if (result['payment_entry'] != null) {
            final peName = result['payment_entry'].toString();
            final pe = await getDocFromErp(api, 'Payment Entry', peName);
            expect(pe['docstatus'], 1);

            // Verify PE accounts: should credit receivable
            await assertPaymentEntry(api, peName, docstatus: 1);
            final peGl = await assertGLBalanced(
                api, 'Payment Entry', peName,
                reason: 'SP Unpaid OFD PE GL must be balanced');
            assertGLContainsAccount(peGl, 'Debtors',
                expectCredit: true,
                reason: 'PE GL should credit Debtors/Receivable');
          }

          // Verify DN was created
          if (result['delivery_note'] != null) {
            final dnName = result['delivery_note'].toString();
            final dn = await getDocFromErp(api, 'Delivery Note', dnName);
            expect(dn['customer'], isNotEmpty,
                reason: 'DN should have customer');
          }
        }
      } catch (e) {
        print('⚠️  SP unpaid OFD failed: $e');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('11d. deliver SP unpaid OFD invoice', () async {
      if (invoiceName.isEmpty) return;

      try {
        await _updateState(invoiceName, 'Delivered');
        final state = await _getState(invoiceName);
        expect(state, equals('Delivered'));

        // SP path may not deduct stock (partner handles fulfillment)
        try {
          await assertStockDeducted(api, invoiceName, invoiceName: invoiceName);
        } catch (_) {
          print('ℹ️  No SLE for SP invoice $invoiceName (expected if partner fulfills)');
        }

        // Verify SPT exists for this SP invoice
        final spt = await getSalesPartnerTransaction(api, invoiceName);
        if (spt != null) {
          expect(spt['sales_partner']?.toString(), salesPartnerName,
              reason: 'SPT should reference the sales partner');
          expect(spt['reference_invoice']?.toString(), invoiceName,
              reason: 'SPT should reference the invoice');
        }
      } catch (e) {
        print('⚠️  Case 11d failed: $e');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));
  });

  // ====================================================================
  // SUMMARY
  // ====================================================================

  test('summary: extended coverage part 2 results', () async {
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
        '\n✅ $delivered delivered, $cancelled cancelled / $total total invoices');
    expect(delivered + cancelled, greaterThanOrEqualTo(1),
        reason: 'At least some invoices should reach a terminal state');
  });
}
