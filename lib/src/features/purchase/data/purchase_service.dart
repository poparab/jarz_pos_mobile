import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final dio = ref.watch(dioProvider);
  return PurchaseService(dio);
});

class PurchaseService {
  final Dio _dio;
  PurchaseService(this._dio);

  Future<List<Map<String, dynamic>>> getSuppliers(String search) async {
    final resp = await _dio.post(
      '/api/method/jarz_pos.api.purchase.get_suppliers',
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
      '/api/method/jarz_pos.api.purchase.get_recent_suppliers',
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
      '/api/method/jarz_pos.api.purchase.search_items',
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
      '/api/method/jarz_pos.api.purchase.get_item_details',
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
      '/api/method/jarz_pos.api.purchase.get_item_price',
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
  }) async {
    final resp = await _dio.post(
      '/api/method/jarz_pos.api.purchase.create_purchase_invoice',
      data: {
        'supplier': supplier,
        'posting_date': postingDate,
        'is_paid': isPaid ? 1 : 0,
        'items': items,
        if (company != null) 'company': company,
        if (paymentOption != null) 'payment_option': paymentOption,
        if (shippingAmount != null) 'shipping_amount': shippingAmount,
      },
    );
    final payload = resp.data;
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected create PI response');
  }
}
