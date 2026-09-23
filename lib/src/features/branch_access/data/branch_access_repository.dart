import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../models/branch_access_models.dart';

final branchAccessRepositoryProvider = Provider<BranchAccessRepository>((ref) {
  return BranchAccessRepository(ref.watch(dioProvider));
});

/// HTTP repository for branch access (`jarz_pos.api.branch_access.*`).
///
/// Same shape as the roster repository: every endpoint is POST and answers in
/// Frappe's `{ "message": ... }` envelope. Refusals (branch open, not your
/// branch) arrive as HTTP errors and are left to propagate, so the screen can
/// show the server's own sentence.
class BranchAccessRepository {
  BranchAccessRepository(this._dio);

  final Dio _dio;

  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('message')) return data['message'];
    return data;
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  /// Branches, their open/closed state, and every person's access.
  Future<BranchAccessOverview> getOverview() async {
    final response = await _dio.post(
      ApiEndpoints.branchAccessOverview,
      data: {},
    );
    return BranchAccessOverview.fromJson(_asMap(_unwrap(response)));
  }

  /// Add ([allowed] true) or remove permanent POS access to one branch.
  Future<SetBranchAccessResult> setBranchAccess({
    required String user,
    required String posProfile,
    required bool allowed,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.branchAccessSet,
      data: {
        'user': user,
        'pos_profile': posProfile,
        'allowed': allowed ? 1 : 0,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    return SetBranchAccessResult.fromJson(_asMap(_unwrap(response)));
  }

  /// Give [user] access to [posProfile] for one branch day ([accessDate] is
  /// `YYYY-MM-DD`, today up to 14 days ahead).
  Future<DayAccessResult> grantDayAccess({
    required String user,
    required String posProfile,
    required String accessDate,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.branchAccessGrantDay,
      data: {
        'user': user,
        'pos_profile': posProfile,
        'access_date': accessDate,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    return DayAccessResult.fromJson(_asMap(_unwrap(response)));
  }

  Future<DayAccessResult> cancelDayAccess(String name) async {
    final response = await _dio.post(
      ApiEndpoints.branchAccessCancelDay,
      data: {'name': name},
    );
    return DayAccessResult.fromJson(_asMap(_unwrap(response)));
  }

  /// One page of the change history, newest first.
  Future<BranchAccessLogPage> getAccessLog({
    String? posProfile,
    String? user,
    int limit = 50,
    int start = 0,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.branchAccessLog,
      data: {
        if (posProfile != null && posProfile.isNotEmpty)
          'pos_profile': posProfile,
        if (user != null && user.isNotEmpty) 'user': user,
        'limit': limit,
        'start': start,
      },
    );
    return BranchAccessLogPage.fromJson(_asMap(_unwrap(response)));
  }
}
