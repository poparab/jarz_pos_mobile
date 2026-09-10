import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import 'models/branch_replenishment.dart';

final replenishmentServiceProvider = Provider<ReplenishmentService>((ref) {
  return ReplenishmentService(ref.watch(dioProvider));
});

/// Read transport for the branch replenishment plan.
///
/// Read only, deliberately: the send half reuses `submit_transfer` through
/// [StockTransferService] rather than growing a second client for the same
/// server method — two transports for one endpoint is how a payload shape
/// drifts between screens.
class ReplenishmentService {
  ReplenishmentService(this._dio);

  final Dio _dio;

  /// [coverDays] and [salesDays] are left null by the screen so the server's
  /// own defaults (14 and 30) stay the single definition of the owner's model.
  Future<ReplenishmentPlan> getPlan({
    int? coverDays,
    int? salesDays,
    String? company,
    String? sourceWarehouse,
  }) async {
    try {
      final resp = await _dio.get(
        ApiEndpoints.getBranchReplenishment,
        queryParameters: {
          if (coverDays != null) 'cover_days': coverDays,
          if (salesDays != null) 'sales_days': salesDays,
          if (company != null) 'company': company,
          if (sourceWarehouse != null) 'source_warehouse': sourceWarehouse,
        },
      );
      final payload = resp.data;
      final message = (payload is Map && payload['message'] is Map)
          ? Map<String, dynamic>.from(payload['message'] as Map)
          : (payload is Map
                ? Map<String, dynamic>.from(payload)
                : <String, dynamic>{});
      return ReplenishmentPlan.fromJson(message);
    } catch (error) {
      throw mapFrappeError(
        error,
        fallback: 'Failed to load what to send to the branches',
      );
    }
  }
}
