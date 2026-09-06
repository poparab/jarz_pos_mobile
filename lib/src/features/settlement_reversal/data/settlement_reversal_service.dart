import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import 'models/recent_settlement.dart';
import 'models/unsettle_preview.dart';

final settlementReversalServiceProvider = Provider<SettlementReversalService>((ref) {
  final dio = ref.watch(dioProvider);
  return SettlementReversalService(dio);
});

/// Talks to the two `couriers.py` endpoints behind "reverse a settlement":
/// `get_unsettle_preview` and `unsettle_courier_settlement`. Both are
/// Journal-Entry-keyed and gated server-side on Admin / Line Manager tier;
/// this service does not re-check the role, it only calls the endpoints and
/// turns a refusal into a clean message via [mapFrappeError] — the same
/// mapper every other service in the app uses, so an "already reversed" or
/// "spans more than one branch" refusal shows up as its own sentence rather
/// than a stack trace.
class SettlementReversalService {
  final Dio _dio;
  SettlementReversalService(this._dio);

  Map<String, dynamic> _unwrap(dynamic payload, {required String fallback}) {
    if (payload is Map && payload['message'] is Map) {
      return Map<String, dynamic>.from(payload['message'] as Map);
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception(fallback);
  }

  /// Same envelope-unwrapping idiom as [_unwrap], but for an endpoint whose
  /// payload is a LIST rather than a map.
  List<dynamic> _unwrapList(dynamic payload, {required String fallback}) {
    if (payload is Map && payload['message'] is List) {
      return payload['message'] as List;
    }
    if (payload is List) return payload;
    throw Exception(fallback);
  }

  /// Past settlements the caller is allowed to see, newest first —
  /// branch-scoped exactly like `get_courier_balances`: passing [posProfile]
  /// narrows to one branch, omitting it returns every branch the caller
  /// belongs to. This is what "reverse a settlement" reads from; unlike the
  /// retired local Hive cache, a settlement made on another device (or before
  /// this feature shipped) shows up here too.
  Future<List<RecentSettlement>> listRecentSettlements({
    String? posProfile,
    int limit = 50,
    bool includeReversed = false,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.recentSettlements,
        data: {
          if (posProfile != null && posProfile.trim().isNotEmpty)
            'pos_profile': posProfile,
          'limit': limit,
          'include_reversed': includeReversed,
        },
      );
      final rows = _unwrapList(resp.data, fallback: 'Failed to load recent settlements');
      return rows
          .whereType<Map>()
          .map((e) => RecentSettlement.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to load recent settlements');
    }
  }

  /// Mints a preview + a `preview_token` valid for a few minutes that
  /// [commit] must present.
  Future<UnsettlePreview> preview({required String journalEntry}) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.unsettlePreview,
        data: {'journal_entry': journalEntry},
      );
      final data = _unwrap(resp.data, fallback: 'Failed to load reversal preview');
      return UnsettlePreview.fromMap(data, requestedJournalEntry: journalEntry);
    } catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to load reversal preview');
    }
  }

  /// Posts the reversing Journal Entry. [previewToken] must be the one the
  /// most recent [preview] call minted — a stale or mismatched token is
  /// refused server-side.
  Future<Map<String, dynamic>> commit({
    required String journalEntry,
    required String previewToken,
    String? reason,
  }) async {
    try {
      final resp = await _dio.post(
        ApiEndpoints.unsettleCommit,
        data: {
          'journal_entry': journalEntry,
          'preview_token': previewToken,
          if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        },
      );
      return _unwrap(resp.data, fallback: 'Failed to reverse the settlement');
    } catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to reverse the settlement');
    }
  }
}
