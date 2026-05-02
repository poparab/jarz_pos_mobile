import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/models/delivery_slot.dart';

class PosRepository {
  PosRepository(this._dio);

  final Dio _dio;

  bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }

    final normalized = value?.toString().trim().toLowerCase();
    return normalized == '1' ||
        normalized == 'true' ||
        normalized == 'yes' ||
        normalized == 'y';
  }

  bool _isExplicitlyDisabled(Map<String, dynamic> data) {
    const disabledKeys = ['disabled', 'is_disabled', 'enabled'];

    for (final key in disabledKeys) {
      if (!data.containsKey(key)) {
        continue;
      }

      final value = data[key];
      if (key == 'enabled') {
        return !_asBool(value);
      }
      return _asBool(value);
    }

    return false;
  }

  String _stringValue(Map<String, dynamic> data, String key) {
    return (data[key] ?? '').toString().trim();
  }

  String _firstNonEmptyString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = _stringValue(data, key);
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  double? _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value == null) {
      return null;
    }

    return double.tryParse(value.toString().trim());
  }

  int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value == null) {
      return null;
    }

    return int.tryParse(value.toString().trim()) ??
        double.tryParse(value.toString().trim())?.toInt();
  }

  Map<String, dynamic>? _normalizedBundleItem(Map<String, dynamic> rawItem) {
    if (_isExplicitlyDisabled(rawItem)) {
      return null;
    }

    final item = Map<String, dynamic>.from(rawItem);
    final itemId = _firstNonEmptyString(item, const ['id', 'item_code']);
    final itemName = _firstNonEmptyString(
      item,
      const ['name', 'item_name', 'title'],
    );

    item['id'] = itemId;
    item['name'] = itemName;

    final price = _asDouble(item['price'] ?? item['rate'] ?? item['price_list_rate']);
    if (price != null) {
      item['price'] = price;
    }

    final stockQty = _asDouble(
      item['qty'] ??
          item['actual_qty'] ??
          item['stock_qty'] ??
          item['available_qty'],
    );
    if (stockQty != null) {
      item['qty'] = stockQty;
      item['actual_qty'] = stockQty;
    }

    if (!_hasUsableItemIdentity(item)) {
      return null;
    }

    return item;
  }

  bool _hasUsableItemIdentity(Map<String, dynamic> item) {
    return _stringValue(item, 'id').isNotEmpty &&
        _stringValue(item, 'name').isNotEmpty;
  }

  bool _hasUsableBundleIdentity(Map<String, dynamic> bundle) {
    return _stringValue(bundle, 'id').isNotEmpty &&
        _stringValue(bundle, 'name').isNotEmpty;
  }

  List<Map<String, dynamic>> _normalizedBundleGroups(
    Map<String, dynamic> bundle,
  ) {
    final rawGroups = bundle['item_groups'];
    if (rawGroups is! List) {
      return const [];
    }

    final normalizedGroups = <Map<String, dynamic>>[];
    for (final rawGroup in rawGroups) {
      if (rawGroup is! Map) {
        continue;
      }

      final group = Map<String, dynamic>.from(rawGroup);
      final groupName = _firstNonEmptyString(
        group,
        const ['group_name', 'item_group', 'title'],
      );
      if (groupName.isEmpty) {
        continue;
      }

      final rawQuantity = _asInt(group['quantity'] ?? group['required_quantity']);
      if (rawQuantity != null && rawQuantity <= 0) {
        continue;
      }
      final quantity = rawQuantity ?? 1;

      final rawItems = group['items'] ?? group['bundle_items'];
      if (rawItems is! List) {
        continue;
      }

      final validItems = <Map<String, dynamic>>[];
      for (final rawItem in rawItems) {
        if (rawItem is! Map) {
          continue;
        }

        final item = _normalizedBundleItem(Map<String, dynamic>.from(rawItem));
        if (item == null) {
          continue;
        }
        validItems.add(item);
      }

      if (validItems.isEmpty) {
        continue;
      }

      group['group_name'] = groupName;
      group['quantity'] = quantity;
      group['items'] = validItems;
      normalizedGroups.add(group);
    }

    return normalizedGroups;
  }

  Future<List<Map<String, dynamic>>> getPosProfiles() async {
    try {
      final response = await _dio.post(
        ApiEndpoints.getPosProfiles,
      );

      if (response.statusCode == 200 && response.data['message'] != null) {
        final List<dynamic> profilesData = response.data['message'];

        // Convert profile names/objects to profile objects with basic info
        List<Map<String, dynamic>> profiles = [];
        for (final item in profilesData) {
          if (item is String) {
            // Legacy format: just a name string
            profiles.add({
              'name': item,
              'title': item,
            });
          } else if (item is Map) {
            // New format: {name, allow_delivery_partner, ...}
            final name = (item['name'] ?? '').toString();
            profiles.add({
              'name': name,
              'title': name,
              'allow_delivery_partner': item['allow_delivery_partner'] == true,
            });
          }
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
        ApiEndpoints.getProfileBundles,
        data: {'profile': posProfile},
      );

      if (response.statusCode == 200 && response.data['message'] != null) {
        final List<dynamic> bundlesData = response.data['message'];
        return bundlesData.whereType<Map>().map((raw) {
          final bundle = Map<String, dynamic>.from(raw);
          if (_isExplicitlyDisabled(bundle) || !_hasUsableBundleIdentity(bundle)) {
            return null;
          }

          final itemGroups = _normalizedBundleGroups(bundle);
          if (itemGroups.isEmpty) {
            return null;
          }

          bundle['free_shipping'] = _asBool(bundle['free_shipping']);
          bundle['item_groups'] = itemGroups;
          return bundle;
        }).whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch bundles: $e');
    }
  }

  Future<Map<String, dynamic>> getPosProfileAccountBalance(String posProfile) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.getPosProfileAccountBalance,
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
        ApiEndpoints.getTerritories,
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
        ApiEndpoints.getProfileProducts,
        data: {'profile': posProfile},
      );

      if (response.statusCode == 200 && response.data['message'] != null) {
        final List<dynamic> itemsData = response.data['message'];

        // Transform the item data to match our expected format
        List<Map<String, dynamic>> items = [];
        for (final rawItem in itemsData.whereType<Map>()) {
          final item = Map<String, dynamic>.from(rawItem);
          if (_isExplicitlyDisabled(item) || !_hasUsableItemIdentity(item)) {
            continue;
          }

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
        ApiEndpoints.getSalesPartners,
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
        ApiEndpoints.searchCustomers,
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
    String? secondaryMobile,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createCustomer,
        data: FormData.fromMap({
          'customer_name': customerName,
          'mobile_no': mobileNumber,
          'customer_primary_address': detailedAddress,
          'territory_id': territoryId,
          if (locationLink != null && locationLink.isNotEmpty)
            'location_link': locationLink,
          if (secondaryMobile != null && secondaryMobile.isNotEmpty)
            'secondary_mobile': secondaryMobile,
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

      // Specific friendly mapping: duplicate customer/mobile
      if ((exceptionType == 'ValidationError' || exceptionType == 'frappe.exceptions.ValidationError') &&
          message != null && message.toLowerCase().contains('already exists')) {
        final lowerMsg = message.toLowerCase();

        // Mobile/phone uniqueness violation
        if (lowerMsg.contains('mobile') || lowerMsg.contains('phone')) {
          throw ApiException(
            'A customer with this phone number already exists. Please search and select it.',
            code: 'DUPLICATE_CUSTOMER_MOBILE',
          );
        }

        // Name-based duplication (still possible if backend changes back)
        String? conflictedName;
        try {
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
    String? deliveryEndDatetime,
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

      // Add delivery end datetime for correct duration calculation
      if (deliveryEndDatetime != null && deliveryEndDatetime.isNotEmpty) {
        requestData['delivery_end_datetime'] = deliveryEndDatetime;
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
          '   Endpoint: ${ApiEndpoints.createPosInvoice}',
        );
        debugPrint('   Cart JSON: ${requestData['cart_json']}');
        debugPrint('   Customer: ${requestData['customer_name']}');
        debugPrint('   POS Profile: ${requestData['pos_profile_name']}');
      }

      final response = await _dio.post(
        ApiEndpoints.createPosInvoice,
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
        ApiEndpoints.getAvailableDeliverySlots,
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
        ApiEndpoints.getNextAvailableSlot,
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
        ApiEndpoints.payInvoice,
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

  /// Check if a POS Profile is currently open based on its timetable
  Future<Map<String, dynamic>> isPosProfileOpen(String posProfile) async {
    try {
      // Validate input
      if (posProfile.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ isPosProfileOpen: POS profile is empty, defaulting to open');
        }
        return {'is_open': true, 'message': 'No POS profile specified'};
      }

      final response = await _dio.post(
        ApiEndpoints.isPosProfileOpen,
        data: {'pos_profile': posProfile},
      );

      if (response.statusCode == 200 && response.data['message'] != null) {
        return Map<String, dynamic>.from(response.data['message']);
      }
      throw Exception('Failed to check POS profile timetable');
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ DioException in isPosProfileOpen: ${e.message}');
      }
      // If there's a server error or network issue, default to "open" 
      // to avoid blocking critical operations like order transfers
      return {
        'is_open': true, 
        'message': 'Error checking timetable: ${e.message}. Defaulting to open.'
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error in isPosProfileOpen: $e');
      }
      // Default to open to avoid blocking operations
      return {'is_open': true, 'message': 'Error checking timetable. Defaulting to open.'};
    }
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
