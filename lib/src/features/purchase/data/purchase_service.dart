import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final dio = ref.watch(dioProvider);
  return PurchaseService(dio);
});

class PurchaseService {
  final Dio _dio;
  PurchaseService(this._dio);

  Future<List<Map<String, dynamic>>> getSuppliers(String search) async {
    final resp = await _dio.post(
      ApiEndpoints.getSuppliers,
      data: {'search': search},
    );
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) {
      return (payload['message'] as List).cast<Map<String, dynamic>>();
    }
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  Future<List<Map<String, dynamic>>> getRecentSuppliers() async {
    final resp = await _dio.post(
      ApiEndpoints.getRecentSuppliers,
      data: {},
    );
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) {
      return (payload['message'] as List).cast<Map<String, dynamic>>();
    }
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  Future<List<Map<String, dynamic>>> searchItems(String search) async {
    final resp = await _dio.post(
      ApiEndpoints.searchItems,
      data: {'search': search},
    );
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) {
      return (payload['message'] as List).cast<Map<String, dynamic>>();
    }
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  Future<Map<String, dynamic>> getItemDetails(String itemCode) async {
    final resp = await _dio.post(
      ApiEndpoints.getItemDetails,
      data: {'item_code': itemCode},
    );
    final payload = resp.data;
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected item details response');
  }

  Future<Map<String, dynamic>> getItemPrice(String itemCode, {String? uom}) async {
    final resp = await _dio.post(
      ApiEndpoints.getItemPrice,
      data: {'item_code': itemCode, if (uom != null) 'uom': uom},
    );
    final payload = resp.data;
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected price response');
  }

  Future<Map<String, dynamic>> createPurchaseInvoice({
    required String supplier,
    required String postingDate,
    required bool isPaid,
    required List<Map<String, dynamic>> items,
    String? company,
    String? paymentOption,
    double? shippingAmount,
    String? billNo,
    String? billDate,
    String? taxesTemplate,
    String? remarks,
    String? idempotencyKey,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.createPurchaseInvoice,
      data: {
        'supplier': supplier,
        'posting_date': postingDate,
        'is_paid': isPaid ? 1 : 0,
        'items': items,
        if (company != null) 'company': company,
        if (paymentOption != null) 'payment_option': paymentOption,
        if (shippingAmount != null) 'shipping_amount': shippingAmount,
        if (billNo != null && billNo.trim().isNotEmpty) 'bill_no': billNo.trim(),
        if (billDate != null) 'bill_date': billDate,
        if (taxesTemplate != null) 'taxes_template': taxesTemplate,
        if (remarks != null && remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
        // Makes a retried submit safe: the server returns the invoice created
        // the first time instead of buying the goods twice.
        if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      },
    );
    return _asMap(resp.data, 'create PI');
  }

  Future<Map<String, dynamic>> getPurchaseInvoices({
    int limit = 50,
    int page = 0,
    String? supplier,
    String? status,
    String? fromDate,
    String? toDate,
    String? search,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.getPurchaseInvoices,
      data: {
        'limit': limit,
        'page': page,
        if (supplier != null) 'supplier': supplier,
        if (status != null) 'status': status,
        if (fromDate != null) 'from_date': fromDate,
        if (toDate != null) 'to_date': toDate,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return _asMap(resp.data, 'get PI');
  }

  Future<Map<String, dynamic>> createSupplier({
    required String supplierName,
    String? supplierGroup,
    String? phone,
    String? taxId,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.createSupplier,
      data: {
        'supplier_name': supplierName,
        if (supplierGroup != null) 'supplier_group': supplierGroup,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (taxId != null && taxId.trim().isNotEmpty) 'tax_id': taxId.trim(),
      },
    );
    return _asMap(resp.data, 'create supplier');
  }

  Future<List<Map<String, dynamic>>> getSupplierGroups() async {
    final resp = await _dio.post(ApiEndpoints.getSupplierGroups, data: {});
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) {
      return (payload['message'] as List).cast<Map<String, dynamic>>();
    }
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  Future<Map<String, dynamic>> getPurchaseTaxesTemplates({String? company}) async {
    final resp = await _dio.post(
      ApiEndpoints.getPurchaseTaxesTemplates,
      data: {if (company != null) 'company': company},
    );
    return _asMap(resp.data, 'taxes templates');
  }

  /// Item Tax Templates a cart line can carry — the per-item VAT options.
  Future<List<Map<String, dynamic>>> getItemTaxTemplates({String? company}) async {
    final resp = await _dio.post(
      ApiEndpoints.getItemTaxTemplates,
      data: {if (company != null) 'company': company},
    );
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) {
      return (payload['message'] as List).cast<Map<String, dynamic>>();
    }
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  Future<Map<String, dynamic>> payPurchaseInvoice({
    required String purchaseInvoice,
    String? paymentOption,
    double? amount,
    String? postingDate,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.payPurchaseInvoice,
      data: {
        'purchase_invoice': purchaseInvoice,
        if (paymentOption != null) 'payment_option': paymentOption,
        if (amount != null) 'amount': amount,
        if (postingDate != null) 'posting_date': postingDate,
      },
    );
    return _asMap(resp.data, 'pay PI');
  }

  Future<Map<String, dynamic>> returnPurchaseInvoice({
    required String purchaseInvoice,
    List<Map<String, dynamic>>? items,
    String? reason,
    String? postingDate,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.returnPurchaseInvoice,
      data: {
        'purchase_invoice': purchaseInvoice,
        if (items != null) 'items': items,
        if (reason != null) 'reason': reason,
        if (postingDate != null) 'posting_date': postingDate,
      },
    );
    return _asMap(resp.data, 'return PI');
  }

  /// Frappe usually wraps a whitelisted return value in `message`, but not
  /// always — unwrap defensively rather than assuming one shape.
  Map<String, dynamic> _asMap(dynamic payload, String label) {
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected $label response');
  }
}
