import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
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
        // Normalize free_shipping to bool for Dart side
        return bundlesData.map<Map<String, dynamic>>((raw) {
          final m = Map<String, dynamic>.from(raw as Map);
          final fs = m['free_shipping'];
          m['free_shipping'] = (fs is bool)
              ? fs
              : ((fs is num) ? (fs != 0) : (fs?.toString() == '1' || fs?.toString().toLowerCase() == 'true'));
          return m;
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch bundles: $e');
    }
  }

  Future<Map<String, dynamic>> getPosProfileAccountBalance(String posProfile) async {
    try {
      final response = await _dio.post(
        '/api/method/jarz_pos.api.pos.get_pos_profile_account_balance',
        data: {'profile': posProfile},
      );

      if (response.statusCode == 200 && response.data['message'] != null) {
        return Map<String, dynamic>.from(response.data['message'] as Map);
      }
      throw Exception('Failed to fetch POS account balance');
    } catch (e) {
      throw Exception('Failed to fetch POS account balance: $e');
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

  Future<List<Map<String, dynamic>>> getSalesPartners({String? search, int limit = 10}) async {
    try {
      final response = await _dio.post(
        '/api/method/jarz_pos.api.pos.get_sales_partners',
        data: {
          if (search != null && search.isNotEmpty) 'search': search,
          'limit': limit,
        },
      );
      if (response.statusCode == 200 && response.data['message'] != null) {
        final List<dynamic> data = response.data['message'];
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch sales partners: $e');
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
      throw ApiException('Failed to create customer');
    } on DioException catch (e) {
      // Try to extract a friendly error from Frappe/ERPNext error payload
      final data = e.response?.data;
      String? exceptionType;
      String? message;
      if (data is Map) {
        exceptionType = data['exception']?.toString();
        // Frappe can return nested messages; prefer explicit message if present
        message = data['message']?.toString();
        // Sometimes error text is under _error_message or _server_messages
        message ??= data['_error_message']?.toString();
        message ??= data['_server_messages']?.toString();
      }
      // Fallback to Dio error message
      message ??= e.message;

      // Specific friendly mapping: duplicate customer
      if ((exceptionType == 'ValidationError' || exceptionType == 'frappe.exceptions.ValidationError') &&
          message != null && message.toLowerCase().contains('already exists')) {
        // Try to extract the conflicted name if present within quotes without using RegExp
        String? conflictedName;
        try {
          final lowerMsg = message.toLowerCase();
          final namePos = lowerMsg.indexOf('name');
          if (namePos >= 0) {
            final tail = message.substring(namePos);
            int firstQuoteIndex = -1;
            String? quoteChar;
            for (final q in ['"', "'"]) {
              final i = tail.indexOf(q);
              if (i >= 0 && (firstQuoteIndex == -1 || i < firstQuoteIndex)) {
                firstQuoteIndex = i;
                quoteChar = q;
              }
            }
            if (firstQuoteIndex >= 0 && quoteChar != null) {
              final start = firstQuoteIndex + 1;
              final end = tail.indexOf(quoteChar, start);
              if (end > start) {
                conflictedName = tail.substring(start, end);
              }
            }
          }
        } catch (_) {}
        final friendly = conflictedName != null
            ? "Customer '$conflictedName' already exists. Please search and select it, or use a different name."
            : 'Customer already exists. Please search and select it, or use a different name.';
        throw ApiException(friendly, code: 'DUPLICATE_CUSTOMER');
      }

      // Generic friendly
      throw ApiException(message ?? 'Failed to create customer');
    } catch (e) {
      throw ApiException('Failed to create customer');
    }
  }

  Future<Map<String, dynamic>> createInvoice({
    required String posProfile,
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? customer,
    String? requiredDeliveryDatetime,
    String? salesPartner,
    String? paymentType, // 'cash' | 'online' (optional, advisory)
    bool isPickup = false,
    String? paymentMethod, // 'Cash' | 'Instapay' | 'Mobile Wallet'
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
        if (isBundle) {
          final rawSelections = item['bundle_details']?['selected_items']
              as Map<String, dynamic>?;
          if (rawSelections != null) {
            final normalizedSelections = <String, List<Map<String, dynamic>>>{};
            rawSelections.forEach((groupName, entries) {
              final entryList = (entries as List)
                  .map<Map<String, dynamic>>(
                    (entry) => Map<String, dynamic>.from(
                      entry as Map,
                    ),
                  )
                  .toList();
              final key = groupName.toString();
              normalizedSelections[key] = entryList;
            });
            base['selected_items'] = normalizedSelections;
          }
        }
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

      // Add delivery charges if customer has delivery income (but NOT when sales partner is selected)
      final bool partnerActive = salesPartner != null && salesPartner.isNotEmpty;
      if (!partnerActive &&
          customer != null &&
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

      // Pickup flag: informs backend to suppress shipping logic and mark invoice as pickup
      if (isPickup) {
        requestData['pickup'] = 1;
      }

      if (salesPartner != null && salesPartner.isNotEmpty) {
        requestData['sales_partner'] = salesPartner;
      }

      // Optional advisory flag for backend – lets server record intended payment channel
      if (paymentType != null && paymentType.isNotEmpty) {
        requestData['payment_type'] = paymentType; // values: 'cash' | 'online'
      }

      // Payment method field (Cash, Instapay, Mobile Wallet)
      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        requestData['payment_method'] = paymentMethod;
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
    // Legacy always-false after removal of PDF receipt system.
    return false;
  }

}

class ApiException implements Exception {
  final String message;
  final String? code;
  ApiException(this.message, {this.code});
  @override
  String toString() => message;
}

final posRepositoryProvider = Provider<PosRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PosRepository(dio);
});
