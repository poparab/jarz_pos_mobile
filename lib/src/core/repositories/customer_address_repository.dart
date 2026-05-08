import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_endpoints.dart';
import '../network/dio_provider.dart';
import '../network/frappe_error_message.dart';

/// Shared repository for all customer address operations.
///
/// Used by both the POS screen and the Kanban screen so the API calls are
/// never duplicated.
class CustomerAddressRepository {
  CustomerAddressRepository(this._dio);

  final Dio _dio;

  Exception _friendly(Object error, {required String fallback}) =>
      mapFrappeError(error, fallback: fallback);

  // ── read ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAddresses({
    required String customer,
    String? invoice,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.getCustomerShippingAddresses,
        data: {
          'customer': customer,
          if (invoice != null && invoice.isNotEmpty) 'invoice': invoice,
        },
      );
      final msg = resp.data['message'];
      if (msg is Map) return Map<String, dynamic>.from(msg);
      throw Exception('Failed to load shipping addresses');
    } catch (e) {
      throw _friendly(e, fallback: 'Failed to load shipping addresses');
    }
  }

  // ── create ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> saveAddress({
    required String customer,
    required String phone,
    String? invoice,
    String? addressName,
    String? address,
    String? territory,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.saveCustomerShippingAddress,
        data: {
          'customer': customer,
          'phone': phone,
          if (invoice != null && invoice.isNotEmpty) 'invoice': invoice,
          if (addressName != null && addressName.isNotEmpty)
            'address_name': addressName,
          if (address != null && address.isNotEmpty) 'address': address,
          if (territory != null && territory.isNotEmpty) 'territory': territory,
          'set_as_primary': 1,
        },
      );
      final msg = resp.data['message'];
      if (msg is Map && msg['success'] == true) {
        return Map<String, dynamic>.from(msg);
      }
      throw Exception(
          extractFrappeErrorMessage(msg, fallback: 'Failed to save address'));
    } catch (e) {
      throw _friendly(e, fallback: 'Failed to save address');
    }
  }

  // ── update ──────────────────────────────────────────────────────────────

  /// Edit fields on an existing saved address.
  Future<Map<String, dynamic>> updateAddress({
    required String customer,
    required String addressName,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? phone,
    String? pincode,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.updateCustomerShippingAddress,
        data: {
          'customer': customer,
          'address_name': addressName,
          if (addressLine1 != null && addressLine1.isNotEmpty)
            'address_line1': addressLine1,
          if (addressLine2 != null) 'address_line2': addressLine2,
          if (city != null && city.isNotEmpty) 'city': city,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
        },
      );
      final msg = resp.data['message'];
      if (msg is Map) return Map<String, dynamic>.from(msg);
      throw Exception(
          extractFrappeErrorMessage(msg, fallback: 'Failed to update address'));
    } catch (e) {
      throw _friendly(e, fallback: 'Failed to update address');
    }
  }

  // ── delete ──────────────────────────────────────────────────────────────

  /// Delete an address.  Returns ``{"success": true, "address_book": {...}}``.
  /// Throws a [CustomerAddressInUseException] when the server reports blocking
  /// invoices so the caller can show a friendly in-use error.
  Future<Map<String, dynamic>> deleteAddress({
    required String customer,
    required String addressName,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.deleteCustomerShippingAddress,
        data: {
          'customer': customer,
          'address_name': addressName,
        },
      );
      final msg = resp.data['message'];
      if (msg is Map && msg['success'] == true) {
        return Map<String, dynamic>.from(msg);
      }
      final errText = extractFrappeErrorMessage(msg,
          fallback: 'Failed to delete address');
      throw Exception(errText);
    } on DioException catch (e) {
      // Frappe throws HTTP 417 for frappe.throw(); extract the message.
      final errText = extractFrappeErrorMessage(e.response?.data,
          fallback: 'Failed to delete address');
      throw Exception(errText);
    } catch (e) {
      throw _friendly(e, fallback: 'Failed to delete address');
    }
  }

  // ── territories ─────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getTerritories({String? search}) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.getTerritories,
        data: search != null ? {'search': search} : {},
      );
      if (resp.statusCode == 200 && resp.data['message'] != null) {
        final list = resp.data['message'];
        if (list is List) return list.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw _friendly(e, fallback: 'Failed to fetch territories');
    }
  }

  // ── change on invoice ───────────────────────────────────────────────────

  /// Re-link a submitted invoice to a different address and recompute shipping
  /// when the territory changes.
  Future<Map<String, dynamic>> changeInvoiceShippingAddress({
    required String invoiceName,
    required String addressName,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.changeInvoiceShippingAddress,
        data: {
          'invoice_name': invoiceName,
          'address_name': addressName,
        },
      );
      final msg = resp.data['message'];
      if (msg is Map && msg['success'] == true) {
        return Map<String, dynamic>.from(msg);
      }
      final errText = extractFrappeErrorMessage(msg,
          fallback: 'Failed to change invoice address');
      throw Exception(errText);
    } on DioException catch (e) {
      final errText = extractFrappeErrorMessage(e.response?.data,
          fallback: 'Failed to change invoice address');
      throw Exception(errText);
    } catch (e) {
      throw _friendly(e, fallback: 'Failed to change invoice address');
    }
  }
}

final customerAddressRepositoryProvider =
    Provider<CustomerAddressRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CustomerAddressRepository(dio);
});
