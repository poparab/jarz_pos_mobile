import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../models/courier_setup_models.dart';

final courierSetupRepositoryProvider = Provider<CourierSetupRepository>((ref) {
  return CourierSetupRepository(ref.watch(dioProvider));
});

/// HTTP repository for courier onboarding (`jarz_courier.api.onboarding.*`).
///
/// Same door as user management. Refusals arrive as HTTP errors and are left
/// to propagate, so the screen can show the server's own sentence. A 404 means
/// jarz_courier is not installed: [isAvailable] turns that into `false`.
class CourierSetupRepository {
  CourierSetupRepository(this._dio);

  final Dio _dio;

  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('message')) return data['message'];
    return data;
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  Future<CourierCandidates> listCandidates() async {
    final response = await _dio.post(
      ApiEndpoints.courierListCandidates,
      data: {},
    );
    return CourierCandidates.fromJson(_asMap(_unwrap(response)));
  }

  /// True when the endpoint answers; false on any failure (jarz_courier not
  /// installed, not allowed, offline). Used only to decide whether to show the
  /// Couriers entry point, so it never throws.
  Future<bool> isAvailable() async {
    try {
      await listCandidates();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Sets up an existing [employee], or creates one from [fullName] and
  /// [mobileNo]. Returns the login id and the one-time PIN.
  Future<CourierSetupResult> setupCourier({
    String? employee,
    String? fullName,
    String? mobileNo,
    String? branch,
    String? posProfile,
  }) async {
    String? clean(String? v) {
      final t = v?.trim() ?? '';
      return t.isEmpty ? null : t;
    }

    final payload = <String, dynamic>{
      if (clean(employee) != null) 'employee': clean(employee),
      if (clean(fullName) != null) 'full_name': clean(fullName),
      if (clean(mobileNo) != null) 'mobile_no': clean(mobileNo),
      if (clean(branch) != null) 'branch': clean(branch),
      if (clean(posProfile) != null) 'pos_profile': clean(posProfile),
    };
    final response = await _dio.post(ApiEndpoints.courierSetup, data: payload);
    return CourierSetupResult.fromJson(_asMap(_unwrap(response)));
  }

  Future<CourierPinReset> resetPin(String user) async {
    final response = await _dio.post(
      ApiEndpoints.courierResetPin,
      data: {'user': user},
    );
    return CourierPinReset.fromJson(_asMap(_unwrap(response)));
  }

  Future<CourierDiagnosis> getSetup(String user) async {
    final response = await _dio.post(
      ApiEndpoints.courierGetSetup,
      data: {'user': user},
    );
    return CourierDiagnosis.fromJson(_asMap(_unwrap(response)));
  }
}
