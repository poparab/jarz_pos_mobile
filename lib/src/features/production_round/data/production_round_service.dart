import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import 'models/production_round.dart';

final productionRoundServiceProvider = Provider<ProductionRoundService>((ref) {
  return ProductionRoundService(ref.watch(dioProvider));
});

/// Read transport for the production round: what the factory should MAKE so
/// every branch holds a full cycle plus its backup. Its sibling,
/// `ReplenishmentService`, answers what to SEND out of what already exists.
class ProductionRoundService {
  ProductionRoundService(this._dio);

  final Dio _dio;

  /// Every parameter left null is omitted, so the server's defaults stay the
  /// single definition of the owner's planning model. Batch sizes are
  /// deliberately not exposed: they are a property of the recipe, not a knob.
  Future<ProductionRound> getRound({
    int? cycleDays,
    int? backupDays,
    int? salesWeeks,
    String? company,
  }) async {
    try {
      final resp = await _dio.get(
        ApiEndpoints.getProductionRound,
        queryParameters: {
          if (cycleDays != null) 'cycle_days': cycleDays,
          if (backupDays != null) 'backup_days': backupDays,
          if (salesWeeks != null) 'sales_weeks': salesWeeks,
          if (company != null) 'company': company,
        },
      );
      final payload = resp.data;
      final message = (payload is Map && payload['message'] is Map)
          ? Map<String, dynamic>.from(payload['message'] as Map)
          : (payload is Map
                ? Map<String, dynamic>.from(payload)
                : <String, dynamic>{});
      return ProductionRound.fromJson(message);
    } catch (error) {
      throw mapFrappeError(
        error,
        fallback: 'Failed to load the production round',
      );
    }
  }
}
