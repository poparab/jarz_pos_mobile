import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import 'models/followup_models.dart';

final followupsRepositoryProvider = Provider<FollowupsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return FollowupsRepository(dio);
});

/// Talks to the four `jarz_pos.api.customer_followups` endpoints behind the
/// sender's daily follow-up list.
class FollowupsRepository {
  final Dio _dio;
  FollowupsRepository(this._dio);

  /// The `message` payload, or the bare body when it is not enveloped.
  dynamic _payload(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('message')) return data['message'];
    return data;
  }

  /// `get_followups_today` — summary plus every overdue / due-today touch.
  Future<FollowupsToday> fetchToday() async {
    final response = await _dio.post(ApiEndpoints.followupsToday, data: {});
    return FollowupsToday.fromJson(_payload(response));
  }

  /// `log_touch`. [reached] is sent for Calls only.
  Future<FollowupLogResult> logTouch({
    required String name,
    required FollowupOutcome outcome,
    FollowupReach? reached,
    String? notes,
  }) async {
    final trimmedNotes = notes?.trim() ?? '';
    final response = await _dio.post(
      ApiEndpoints.followupLogTouch,
      data: {
        'name': name,
        'outcome': outcome.wire,
        if (reached != null) 'reached': reached.wire,
        if (trimmedNotes.isNotEmpty) 'notes': trimmedNotes,
      },
    );
    return FollowupLogResult.fromJson(_payload(response));
  }

  /// `skip_touch` with an optional [reason].
  Future<void> skipTouch({required String name, String? reason}) async {
    final trimmed = reason?.trim() ?? '';
    await _dio.post(
      ApiEndpoints.followupSkipTouch,
      data: {
        'name': name,
        if (trimmed.isNotEmpty) 'reason': trimmed,
      },
    );
  }

  /// `get_followup_stats` for `from_date`..`to_date` (inclusive, `YYYY-MM-DD`).
  Future<FollowupStats> fetchStats({
    required String fromDate,
    required String toDate,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.followupStats,
      data: {'from_date': fromDate, 'to_date': toDate},
    );
    return FollowupStats.fromJson(_payload(response));
  }
}
