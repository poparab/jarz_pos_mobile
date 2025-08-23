import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../../core/services/receipt_service.dart';
import '../../domain/models/delivery_slot.dart';

class PosRepository {
  PosRepository(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> getPosProfiles() async {
    try {
      final response = await _dio.post(
        '/api/method/jarz_pos.api.pos.get_pos_profiles',
      );

      if (response.statusCode == 200 && response.data['message'] != null) {
        final List<dynamic> profilesData = response.data['message'];

        // Convert profile names to profile objects with basic info
        List<Map<String, dynamic>> profiles = [];
        for (String profileName in profilesData) {
          profiles.add({
            'name': profileName,
            'title': profileName, // Use name as title for now
          });
        }
        return profiles;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch POS profiles: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBundles(String posProfile) async {
    try {
      final response = await _dio.post(
        '/api/method/jarz_pos.api.pos.get_profile_bundles',
        data: {'profile': posProfile},
      );

      if (response.statusCode == 200 && response.data['message'] != null) {
        final List<dynamic> bundlesData = response.data['message'];
        return bundlesData.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch bundles: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTerritories({String? search}) async {
    try {
      final response = await _dio.post(
        '/api/method/jarz_pos.api.customer.get_territories',
        data: search != null ? {'search': search} : {},
      );

      if (response.statusCode == 200 && response.data['message'] != null) {
        final List<dynamic> territoriesData = response.data['message'];
        return territoriesData.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch territories: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getItems(String posProfile) async {
    try {
      final response = await _dio.post(
        '/api/method/jarz_pos.api.pos.get_profile_products',
        data: {'profile': posProfile},
      );

      if (response.statusCode == 200 && response.data['message'] != null) {
        final List<dynamic> itemsData = response.data['message'];

        // Transform the item data to match our expected format
        List<Map<String, dynamic>> items = [];
        for (Map<String, dynamic> item in itemsData) {
          items.add({
            'name': item['id'],
            'item_name': item['name'],
            'item_group': item['item_group'],
            'rate': item['price'] ?? 0.0,
            'actual_qty': item['qty'] ?? 0.0,
            'stock_uom': 'Unit', // Default UOM
          });
        }
        return items;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    try {
      // Check if query contains only digits/phone characters (phone search) or contains letters (name search)
      final isPhoneSearch = RegExp(r'^[0-9+\-\s()]+$').hasMatch(query.trim());

      final response = await _dio.post(
        '/api/method/jarz_pos.api.customer.search_customers',
        data: isPhoneSearch ? {'phone': query} : {'name': query},
      );

      if (response.statusCode == 200 && response.data['message'] != null) {
        final List<dynamic> customersData = response.data['message'];
        return customersData.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search customers: $e');
    }
  }

  Future<Map<String, dynamic>> createCustomer({
    required String customerName,
    required String mobileNumber,
    required String territoryId,
    required String detailedAddress,
    String? locationLink,
  }) async {
    try {
      final response = await _dio.post(
        '/api/method/jarz_pos.api.customer.create_customer',
        data: FormData.fromMap({
          'customer_name': customerName,
          'mobile_no': mobileNumber,
          'customer_primary_address': detailedAddress,
          'territory_id': territoryId,
          if (locationLink != null && locationLink.isNotEmpty)
            'location_link': locationLink,
        }),
      );

      if (response.statusCode == 200 && response.data['message'] != null) {
        return response.data['message'] as Map<String, dynamic>;
      }
      throw Exception('Failed to create customer');
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  Future<Map<String, dynamic>> createInvoice({
    required String posProfile,
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? customer,
    String? requiredDeliveryDatetime,
  }) async {
    try {
      // Convert cart items to backend format (preserve discount fields if present)
      List<Map<String, dynamic>> cartItems = items.map((item) {
        final isBundle = item['type'] == 'bundle';
        final base = <String, dynamic>{
          'item_code': isBundle ? item['bundle_details']['bundle_id'] : item['item_code'],
          'qty': item['quantity'],
          'rate': item['rate'],
          'is_bundle': isBundle,
        };
        // Optional discount metadata
        if (item.containsKey('price_list_rate')) {
          base['price_list_rate'] = item['price_list_rate'];
        }
        if (item.containsKey('discount_amount')) {
          base['discount_amount'] = item['discount_amount'];
        }
        if (item.containsKey('discount_percentage')) {
          base['discount_percentage'] = item['discount_percentage'];
        }
        return base;
      }).toList();

      if (kDebugMode) {
        debugPrint('📦 CART ITEMS BEING SENT TO BACKEND:');
        for (int i = 0; i < cartItems.length; i++) {
          final item = cartItems[i];
          final isBundle = item['is_bundle'] == true;
          debugPrint(
            '   Item ${i + 1}: ${item['item_code']} - Qty: ${item['qty']}, Rate: ${item['rate']}, Bundle: $isBundle',
          );
        }
      }

      // Prepare request data
      Map<String, dynamic> requestData = {
        'cart_json': jsonEncode(cartItems),
        'customer_name': customer?['name'] ?? 'Walking Customer',
        'pos_profile_name': posProfile,
      };

      // Add delivery charges if customer has delivery income
      if (customer != null &&
          customer['delivery_income'] != null &&
          customer['delivery_income'] > 0) {
        requestData['delivery_charges_json'] = jsonEncode([
          {
            'charge_type': 'Delivery',
            'amount': customer['delivery_income'],
            'description':
                'Delivery charge for ${customer['territory'] ?? 'Unknown Territory'}',
          },
        ]);
      }

      // Add required delivery datetime if provided
      if (requiredDeliveryDatetime != null &&
          requiredDeliveryDatetime.isNotEmpty) {
        requestData['required_delivery_datetime'] = requiredDeliveryDatetime;
      }

      if (kDebugMode) {
        debugPrint('🚀 SENDING REQUEST TO BACKEND:');
        debugPrint(
          '   Endpoint: /api/method/jarz_pos.api.invoices.create_pos_invoice',
        );
        debugPrint('   Cart JSON: ${requestData['cart_json']}');
        debugPrint('   Customer: ${requestData['customer_name']}');
        debugPrint('   POS Profile: ${requestData['pos_profile_name']}');
      }

      final response = await _dio.post(
        '/api/method/jarz_pos.api.invoices.create_pos_invoice',
        data: requestData,
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('✅ INVOICE CREATION SUCCESS:');
          debugPrint('   Response: ${response.data['message']}');
        }
        return response.data['message'];
      }
      throw Exception('Failed to create invoice');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ INVOICE CREATION ERROR: $e');
      }
      throw Exception('Failed to create invoice: $e');
    }
  }

  Future<List<DeliverySlot>> getDeliverySlots(String posProfile) async {
    try {
      if (kDebugMode) {
        debugPrint('📡 API Call: getDeliverySlots for profile: $posProfile');
      }
      final response = await _dio.post(
        '/api/method/jarz_pos.api.delivery_slots.get_available_delivery_slots',
        data: {'pos_profile_name': posProfile},
      );

      if (kDebugMode) {
        debugPrint('📡 API Response Status: ${response.statusCode}');
        debugPrint('📡 API Response Data: ${response.data}');
      }

      if (response.statusCode == 200 && response.data['message'] != null) {
        final List<dynamic> slotsData = response.data['message'];
        if (kDebugMode) {
          debugPrint(
            '🎯 Converting ${slotsData.length} slots to DeliverySlot objects',
          );
        }
        return slotsData.map((slot) => DeliverySlot.fromJson(slot)).toList();
      }
      if (kDebugMode) {
        debugPrint('⚠️ No message in response or status code not 200');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error in getDeliverySlots: $e');
      }
      throw Exception('Failed to fetch delivery slots: $e');
    }
  }

  Future<DeliverySlot?> getNextAvailableSlot(String posProfile) async {
    try {
      final response = await _dio.post(
        '/api/method/jarz_pos.api.delivery_slots.get_next_available_slot',
        data: {'pos_profile_name': posProfile},
      );

      if (response.statusCode == 200 && response.data['message'] != null) {
        return DeliverySlot.fromJson(response.data['message']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch next available slot: $e');
    }
  }

  // Enhanced invoice creation with receipt printing
  Future<Map<String, dynamic>> createInvoiceWithReceipt({
    required String posProfile,
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? customer,
    String? requiredDeliveryDatetime,
    bool printReceipt = false, // default false; printing moved outside POS submit
  }) async {
    // Deprecated inline printing; retained for future Kanban use
    return createInvoice(
      posProfile: posProfile,
      items: items,
      customer: customer,
      requiredDeliveryDatetime: requiredDeliveryDatetime,
    );
  }

  // Print receipt for existing invoice
  Future<void> printInvoiceReceipt(Map<String, dynamic> invoice) async {
    try {
      if (await ReceiptService.canPrint()) {
        await ReceiptService.printReceipt(invoice);
        if (kDebugMode) {
          debugPrint('✅ RECEIPT: Reprinted successfully for ${invoice['name']}');
        }
      } else {
        throw Exception('Printing not available');
      }
    } catch (e) {
      throw Exception('Failed to print receipt: $e');
    }
  }

  // Share receipt as PDF
  Future<void> shareInvoiceReceipt(Map<String, dynamic> invoice) async {
    try {
      await ReceiptService.shareReceipt(invoice);
      if (kDebugMode) {
        debugPrint('✅ RECEIPT: Shared successfully for ${invoice['name']}');
      }
    } catch (e) {
      throw Exception('Failed to share receipt: $e');
    }
  }

  // Register payment for an invoice (Wallet / InstaPay / Cash)
  // Wallet & InstaPay: backend will AUTO-GENERATE referenceNo/referenceDate if omitted, but UI should collect real values.
  Future<Map<String, dynamic>> payInvoice({
    required String invoiceName,
    required String paymentMode, // wallet | instapay | cash
    String? posProfile, // required for cash
    String? referenceNo, // required for wallet & instapay
    String? referenceDate, // required for wallet & instapay
  }) async {
    try {
      final data = {
        'invoice_name': invoiceName,
        'payment_mode': paymentMode,
        if (posProfile != null) 'pos_profile': posProfile,
        if (referenceNo != null) 'reference_no': referenceNo,
        if (referenceDate != null) 'reference_date': referenceDate,
      };

      final response = await _dio.post(
        '/api/method/jarz_pos.api.invoices.pay_invoice',
        data: data,
      );

      if (response.statusCode == 200 && response.data['message'] != null) {
        return Map<String, dynamic>.from(response.data['message']);
      }
      throw Exception('Failed to register payment');
    } catch (e) {
      throw Exception('Failed to register payment: $e');
    }
  }

  // Check if printing is available
  Future<bool> canPrint() async {
    return await ReceiptService.canPrint();
  }

}

final posRepositoryProvider = Provider<PosRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PosRepository(dio);
});
