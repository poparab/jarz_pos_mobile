import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/frappe_error_message.dart';
import '../models/maps_link_preview.dart';

/// Geo lookups that only the backend can answer.
///
/// Short `maps.app.goo.gl` links only yield coordinates by following the
/// redirect, and "how far is this from the branch?" needs the branch record —
/// neither is knowable client-side, so both live behind one preview call.
class GeoRepository {
  GeoRepository(this._dio);

  final Dio _dio;

  /// Request key the backend reads the pasted text from.
  ///
  /// Frappe drops form keys that are not in the whitelisted function's
  /// signature, so a rename on the backend surfaces as "nothing resolved"
  /// rather than an error — keep this in one place so the fix is one line.
  static const String linkParam = 'link';

  /// Resolve [link] to a point without writing anything.
  ///
  /// Never throws for a server-reported failure: an unparseable link is a
  /// normal outcome of a paste and comes back as a [MapsLinkPreview] with
  /// `success == false`. Only genuine transport failures throw, so the caller
  /// can tell "your link is wrong" apart from "the network is down".
  Future<MapsLinkPreview> previewMapsLink(String link) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.previewMapsLink,
        data: {linkParam: link},
      );

      final message = response.data is Map
          ? (response.data as Map)['message']
          : null;
      if (message is Map) {
        return MapsLinkPreview.fromJson(Map<String, dynamic>.from(message));
      }
      throw Exception('Failed to resolve location link');
    } on DioException catch (e) {
      // Frappe answers `frappe.throw` with HTTP 417 and the real reason in the
      // payload — that is a rejected link, not a dead network, so surface it
      // as a failed preview the field can render inline.
      if (e.response != null) {
        return MapsLinkPreview.failure(
          extractFrappeErrorMessage(
            e.response?.data ?? e,
            fallback: 'Failed to resolve location link',
          ),
        );
      }
      throw mapFrappeError(e, fallback: 'Failed to resolve location link');
    } catch (e) {
      throw mapFrappeError(e, fallback: 'Failed to resolve location link');
    }
  }
}

final geoRepositoryProvider = Provider<GeoRepository>((ref) {
  return GeoRepository(ref.watch(dioProvider));
});
