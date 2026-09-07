import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/frappe_error_message.dart';
import '../models/maps_link_preview.dart';

/// Injected so widget tests can poll a ticket without real elapsed time.
typedef PollWait = Future<void> Function(Duration duration);

Future<void> _defaultPollWait(Duration duration) =>
    Future<void>.delayed(duration);

/// Geo lookups that only the backend can answer.
///
/// Short `maps.app.goo.gl` links only yield coordinates by following the
/// redirect, and "how far is this from the branch?" needs the branch record —
/// neither is knowable client-side, so both live behind one preview call.
class GeoRepository {
  GeoRepository(this._dio, {PollWait pollWait = _defaultPollWait})
      : _pollWait = pollWait;

  final Dio _dio;
  final PollWait _pollWait;

  /// Request key the ticket poll is sent under. Same signature-binding trap as
  /// [linkParam]: Frappe drops a form key the whitelisted function does not
  /// declare, so a rename here reads as "the ticket never finished".
  static const String requestIdParam = 'request_id';

  /// Poll schedule for a short link's background expansion.
  ///
  /// Front-loaded because a redirect chain usually answers in well under a
  /// second, then backed off so a stalled shortener does not turn into a burst
  /// of requests. Total budget ~7.5s, after which the field says the link could
  /// not be read — the same wording as an outright failure, because from the
  /// user's side it is one.
  static const _pollIntervals = <Duration>[
    Duration(milliseconds: 400),
    Duration(milliseconds: 600),
    Duration(seconds: 1),
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 2),
  ];

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
      var preview = _read(
        await _dio.post(ApiEndpoints.previewMapsLink, data: {linkParam: link}),
      );

      // A short link (`maps.app.goo.gl/…`, `share.google/…`) carries no
      // coordinates until its redirect chain is followed, and the backend
      // refuses to do that inside the request — it queues the expansion and
      // hands back a ticket. Polling it here is what makes the field work for
      // the link the share sheet actually produces; without this loop every
      // such paste reported "could not read a location from this link".
      for (final interval in _pollIntervals) {
        final requestId = preview.requestId;
        if (!preview.pending || requestId == null || requestId.isEmpty) {
          return preview;
        }
        await _pollWait(interval);
        preview = _read(
          await _dio.post(
            ApiEndpoints.previewMapsLink,
            data: {requestIdParam: requestId},
          ),
        );
      }
      return preview;
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

  MapsLinkPreview _read(Response<dynamic> response) {
    final message = response.data is Map
        ? (response.data as Map)['message']
        : null;
    if (message is Map) {
      return MapsLinkPreview.fromJson(Map<String, dynamic>.from(message));
    }
    throw Exception('Failed to resolve location link');
  }
}

final geoRepositoryProvider = Provider<GeoRepository>((ref) {
  return GeoRepository(ref.watch(dioProvider));
});
