import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import 'models/daily_plan.dart';

final dailyPlanServiceProvider = Provider<DailyPlanService>((ref) {
  return DailyPlanService(ref.watch(dioProvider));
});

/// Transport for the Daily Production Plan.
///
/// Kept out of [ManufacturingService], which is already large and answers a
/// different question — that one drives Work Orders, this one drives the day's
/// jar target.
class DailyPlanService {
  DailyPlanService(this._dio);

  final Dio _dio;

  Map<String, dynamic> _unwrap(Object? payload, String what) {
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected $what response');
  }

  Future<DailyPlanTemplate> getTemplate({String? planDate}) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.dailyPlanTemplate,
        data: {if (planDate != null) 'plan_date': planDate},
      );
      return DailyPlanTemplate.fromJson(_unwrap(resp.data, 'plan template'));
    } catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to load the daily plan');
    }
  }

  /// Recomputes the batch split for a set of jar quantities without saving.
  ///
  /// [includeMaterials] is off while the user is typing: the roll-up explodes
  /// every BOM in the basket, which is far too heavy for a per-keystroke call.
  Future<DailyPlanPreview> preview(
    Map<String, int> quantities, {
    bool includeMaterials = false,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.dailyPlanPreview,
        data: {
          'lines': quantities.entries
              .map((e) => {'item_code': e.key, 'planned_qty': e.value})
              .toList(),
          'include_materials': includeMaterials ? 1 : 0,
        },
      );
      return DailyPlanPreview.fromJson(_unwrap(resp.data, 'plan preview'));
    } catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to calculate the plan');
    }
  }

  Future<DailyPlan> save({
    required Map<String, int> quantities,
    String? name,
    String? planDate,
    String? status,
    String? notes,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.dailyPlanSave,
        data: {
          'lines': quantities.entries
              .map((e) => {'item_code': e.key, 'planned_qty': e.value})
              .toList(),
          if (name != null) 'name': name,
          if (planDate != null) 'plan_date': planDate,
          if (status != null) 'status': status,
          if (notes != null) 'notes': notes,
        },
      );
      return DailyPlan.fromJson(_unwrap(resp.data, 'save plan'));
    } catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to save the plan');
    }
  }

  /// End of day. [actuals] carries a null for anything not counted, which the
  /// server keeps distinct from a counted zero.
  Future<DailyPlan> close({
    required String name,
    required Map<String, int?> actuals,
    double? actualBatchesRun,
    String? notes,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.dailyPlanClose,
        data: {
          'name': name,
          'lines': actuals.entries
              .map((e) => {'item_code': e.key, 'actual_qty': e.value})
              .toList(),
          if (actualBatchesRun != null) 'actual_batches_run': actualBatchesRun,
          if (notes != null) 'notes': notes,
        },
      );
      return DailyPlan.fromJson(_unwrap(resp.data, 'close plan'));
    } catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to close the plan');
    }
  }

  /// Calls the day off entirely.
  ///
  /// Distinct from [close], which records what was actually made. Closing a day
  /// that never ran with zero counts would say the floor tried and produced
  /// nothing, dragging down the realised-units-per-batch figure the plan exists
  /// to measure. Cancelling also frees the date to be planned again.
  Future<DailyPlan> cancel({
    required String name,
    required String reason,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.dailyPlanCancel,
        data: {'name': name, 'reason': reason},
      );
      return DailyPlan.fromJson(_unwrap(resp.data, 'cancel plan'));
    } catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to cancel the plan');
    }
  }

  Future<DailyPlan> getPlan(String name) async {
    try {
      final resp = await _dio.post(ApiEndpoints.dailyPlanGet, data: {'name': name});
      return DailyPlan.fromJson(_unwrap(resp.data, 'plan'));
    } catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to load the plan');
    }
  }

  Future<BomReadiness> checkBomReadiness() async {
    try {
      final resp = await _dio.post(ApiEndpoints.dailyPlanBomReadiness, data: {});
      return BomReadiness.fromJson(_unwrap(resp.data, 'BOM readiness'));
    } catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to check BOM readiness');
    }
  }
}
