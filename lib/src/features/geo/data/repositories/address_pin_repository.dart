import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/frappe_error_message.dart';
import '../models/address_pin.dart';
import '../models/pin_write_decision.dart';

final addressPinRepositoryProvider = Provider<AddressPinRepository>((ref) {
  return AddressPinRepository(ref.watch(dioProvider));
});

/// HTTP repository for `jarz_pos.api.geo.get_address_pin` /
/// `dry_run_address_pin` / `set_address_pin` — correcting the pin on an
/// EXISTING address.
///
/// Distinct from `GeoRepository`, which only resolves a link at
/// address-creation time (`preview_maps_link`) and writes nothing. All three
/// endpoints here return Frappe's `{ "message": ... }` envelope, unwrapped
/// exactly like the roster and visits repositories.
class AddressPinRepository {
  AddressPinRepository(this._dio);

  final Dio _dio;

  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('message')) return data['message'];
    return data;
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  /// Everything the editor needs about the address' current pin.
  Future<AddressPin> getAddressPin(String address) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.getAddressPin,
        data: {'address': address},
      );
      final message = _asMap(_unwrap(response));
      if (message['success'] == false) {
        throw Exception(
          message['error']?.toString() ?? 'Failed to load address pin',
        );
      }
      return AddressPin.fromJson(message);
    } on DioException catch (e) {
      throw mapFrappeError(e, fallback: 'Failed to load address pin');
    }
  }

  /// Resolve + run the confidence-ladder decision. Writes nothing.
  ///
  /// Supply either [link] (a pasted Maps link) OR an explicit [latitude] /
  /// [longitude] pair, never both — matching `dry_run_address_pin`'s own
  /// either/or contract.
  Future<PinWriteDecision> dryRun({
    required String address,
    String? link,
    double? latitude,
    double? longitude,
    required String source,
    double? accuracyM,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.dryRunAddressPin,
        data: _writeBody(
          address: address,
          link: link,
          latitude: latitude,
          longitude: longitude,
          source: source,
          accuracyM: accuracyM,
        ),
      );
      final message = _asMap(_unwrap(response));
      if (message['success'] == false) {
        throw Exception(
          message['error']?.toString() ?? 'Failed to preview pin change',
        );
      }
      return PinWriteDecision.fromJson(message);
    } on DioException catch (e) {
      throw mapFrappeError(e, fallback: 'Failed to preview pin change');
    }
  }

  /// Commit the pin. Same request shape as [dryRun]. `accepted: false` in a
  /// `success: true` reply is a normal outcome — a worse pin was refused — not
  /// an error; only a transport failure or `success: false` throws.
  Future<PinWriteDecision> setPin({
    required String address,
    String? link,
    double? latitude,
    double? longitude,
    required String source,
    double? accuracyM,
    String? note,
  }) async {
    try {
      final body = _writeBody(
        address: address,
        link: link,
        latitude: latitude,
        longitude: longitude,
        source: source,
        accuracyM: accuracyM,
      );
      if (note != null && note.trim().isNotEmpty) {
        body['note'] = note.trim();
      }
      final response = await _dio.post(ApiEndpoints.setAddressPin, data: body);
      final message = _asMap(_unwrap(response));
      if (message['success'] == false) {
        throw Exception(
          message['error']?.toString() ?? 'Failed to save address pin',
        );
      }
      return PinWriteDecision.fromJson(message);
    } on DioException catch (e) {
      throw mapFrappeError(e, fallback: 'Failed to save address pin');
    }
  }

  Map<String, dynamic> _writeBody({
    required String address,
    String? link,
    double? latitude,
    double? longitude,
    required String source,
    double? accuracyM,
  }) => {
    'address': address,
    if (link != null && link.trim().isNotEmpty) 'link': link.trim(),
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'source': source,
    if (accuracyM != null) 'accuracy_m': accuracyM,
  };
}
