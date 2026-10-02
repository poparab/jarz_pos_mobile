import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import 'models/customer_deal_models.dart';

final customerDealsRepositoryProvider = Provider<CustomerDealsRepository>((
  ref,
) {
  return CustomerDealsRepository(ref.watch(dioProvider));
});

/// The read and write calls behind the "Special prices" card
/// (`jarz_pos.api.customer_deals.*`). Reads: managers and B2B reps. Writes:
/// full managers only; the server refuses anyone else.
class CustomerDealsRepository {
  final Dio _dio;
  CustomerDealsRepository(this._dio);

  Map<String, dynamic> _unwrap(Response response) {
    final data = response.data;
    final payload = data is Map && data.containsKey('message')
        ? data['message']
        : data;
    return Map<String, dynamic>.from(payload as Map);
  }

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<CustomerDeals> getCustomerDeals(String customer) async {
    final response = await _dio.post(
      ApiEndpoints.getCustomerDeals,
      data: {'customer': customer},
    );
    return CustomerDeals.fromJson(_unwrap(response));
  }

  /// Creates a deal, or replaces the dates and prices of [deal].
  Future<CustomerDeal> saveCustomerDeal({
    required String customer,
    required DateTime validFrom,
    required DateTime validUpto,
    required List<CustomerDealLine> items,
    String? notes,
    String? deal,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.saveCustomerDeal,
      data: {
        'customer': customer,
        'valid_from': _iso(validFrom),
        'valid_upto': _iso(validUpto),
        'items': items.map((e) => e.toPayload()).toList(),
        'notes': notes ?? '',
        if (deal != null) 'deal': deal,
      },
    );
    return CustomerDeal.fromJson(_unwrap(response));
  }

  /// Stops a deal from today on.
  Future<CustomerDeal> endCustomerDeal(String deal) async {
    final response = await _dio.post(
      ApiEndpoints.endCustomerDeal,
      data: {'deal': deal},
    );
    return CustomerDeal.fromJson(_unwrap(response));
  }
}

/// One customer's deals plus what a new deal can price.
final customerDealsProvider = FutureProvider.autoDispose
    .family<CustomerDeals, String>((ref, customer) async {
      return ref
          .watch(customerDealsRepositoryProvider)
          .getCustomerDeals(customer);
    });
