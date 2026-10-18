import 'package:latlong2/latlong.dart';

/// Result of `jarz_pos.api.geo.preview_maps_link` — a read-only resolve of a
/// pasted Maps link into a point, plus how far that point sits from the branch.
///
/// Hand-written rather than Freezed to match the rest of this app's models, and
/// deliberately tolerant: every numeric field may arrive as a num, a numeric
/// string, or be absent on an older backend. A payload we cannot read must
/// degrade to "not resolved" and let the field show an error — never throw and
/// take the surrounding form down with it.
class MapsLinkPreview {
  const MapsLinkPreview({
    required this.success,
    this.latitude,
    this.longitude,
    this.precision,
    this.distanceFromBranchM,
    this.error,
    this.pending = false,
    this.requestId,
    this.resolved,
    this.reason,
    this.swapped = false,
    this.typedLatitude,
    this.typedLongitude,
    this.swapReference,
    this.precisionNote,
    this.distanceReference,
  });

  /// A local failure that never reached (or never parsed from) the server.
  const MapsLinkPreview.failure(String this.error)
      : success = false,
        latitude = null,
        longitude = null,
        precision = null,
        distanceFromBranchM = null,
        pending = false,
        requestId = null,
        resolved = false,
        reason = null,
        swapped = false,
        typedLatitude = null,
        typedLongitude = null,
        swapReference = null,
        precisionNote = null,
        distanceReference = null;

  final bool success;
  final double? latitude;
  final double? longitude;

  /// How the backend arrived at the point — the `custom_geo_source` label from
  /// the confidence ladder (`pos_link`, `customer_pin`, …). Carried through to
  /// the caller so the save request can stamp it; never rendered raw, because
  /// the ladder may grow values this build has no string for.
  final String? precision;

  /// Straight-line distance from the branch, in metres.
  final double? distanceFromBranchM;

  /// Server-supplied failure text. Present only when [success] is false.
  final String? error;

  /// True while a short link is still being expanded in a background job.
  ///
  /// A short link — which is all the Android share sheet ever produces — has no
  /// coordinates in it, and following its redirects inside the request would
  /// let any paste hold a web worker. So the server answers with a ticket and
  /// the repository polls; this flag plus [requestId] is that ticket. Neither
  /// resolved nor failed: a caller that treats it as either shows the wrong
  /// thing for the most common input the field receives.
  final bool pending;

  /// Ticket to poll while [pending]. Null on any terminal answer.
  final String? requestId;

  /// The server's own verdict. `success` only says the request worked; a link
  /// that parsed but was refused (a point outside Egypt) answers
  /// `success: true, resolved: false`. Null on a backend that predates the key.
  final bool? resolved;

  /// Machine-readable refusal (`no_coordinates_in_link`,
  /// `outside_service_area`, …). Mapped to a localised message, never shown.
  final String? reason;

  /// True when the server read the typed pair as `longitude, latitude` and
  /// flipped it. [latitude]/[longitude] hold the corrected point; the pair as
  /// typed is in [typedLatitude]/[typedLongitude]. False on an older backend.
  final bool swapped;

  /// The coordinates exactly as typed, before any flip. Only sent with
  /// [swapped].
  final double? typedLatitude;
  final double? typedLongitude;

  /// What the server compared against to decide a flip was needed (a label
  /// such as the branch or territory). Informational only.
  final String? swapReference;

  /// Server-translated sentence explaining a flip (or a precision caveat).
  final String? precisionNote;

  /// What [distanceFromBranchM] was measured from: `pos_profile`, `territory`
  /// or `cairo_fallback`. Null on an older backend.
  final String? distanceReference;

  /// Backend reason for a link whose point lies outside the delivery area.
  static const String outsideServiceArea = 'outside_service_area';

  bool get isOutsideServiceArea => reason == outsideServiceArea;

  /// Backend reason for a link that names a Maps place (a shop shared from
  /// Maps) but carries no point: only a dropped-pin share can be read.
  static const String placeLinkNoPin = 'place_link_no_pin';

  bool get isPlaceLink => reason == placeLinkNoPin;

  factory MapsLinkPreview.fromJson(Map<String, dynamic> json) {
    return MapsLinkPreview(
      success: _parseBool(json['success']),
      latitude: _parseDouble(json['latitude'] ?? json['lat']),
      longitude: _parseDouble(json['longitude'] ?? json['lng'] ?? json['lon']),
      precision: _nonEmpty(json['precision'] ?? json['geo_source']),
      distanceFromBranchM: _parseDouble(
        json['distance_from_branch_m'] ?? json['distance_from_branch'],
      ),
      error: _nonEmpty(json['error'] ?? json['message']),
      pending: _parseBool(json['pending']),
      requestId: _nonEmpty(json['request_id']),
      resolved: json.containsKey('resolved') ? _parseBool(json['resolved']) : null,
      reason: _nonEmpty(json['reason']),
      swapped: _parseBool(json['swapped']),
      typedLatitude: _parseDouble(json['typed_latitude']),
      typedLongitude: _parseDouble(json['typed_longitude']),
      swapReference: _nonEmpty(json['swap_reference']),
      precisionNote: _nonEmpty(json['precision_note']),
      distanceReference: _nonEmpty(json['distance_reference']),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'latitude': latitude,
        'longitude': longitude,
        'precision': precision,
        'distance_from_branch_m': distanceFromBranchM,
        'error': error,
        'pending': pending,
        'request_id': requestId,
        'resolved': resolved,
        'reason': reason,
        'swapped': swapped,
        'typed_latitude': typedLatitude,
        'typed_longitude': typedLongitude,
        'swap_reference': swapReference,
        'precision_note': precisionNote,
        'distance_reference': distanceReference,
      };

  /// True only when the server both reported success and handed back a usable
  /// point. `success: true` with null coordinates is treated as a failure —
  /// stamping a half-resolved address is worse than asking staff to retry.
  /// An explicit `resolved: false` wins over any coordinates in the payload.
  bool get isResolved => success && resolved != false && point != null;

  /// The resolved point, or null when the payload carries no usable pair.
  LatLng? get point {
    final lat = latitude;
    final lng = longitude;
    if (lat == null || lng == null) return null;
    if (lat.abs() > 90 || lng.abs() > 180) return null;
    // Null Island is what a failed parse looks like numerically.
    if (lat == 0 && lng == 0) return null;
    return LatLng(lat, lng);
  }

  static bool _parseBool(dynamic raw) {
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    if (raw is String) {
      return const ['1', 'true', 'yes', 'y'].contains(raw.trim().toLowerCase());
    }
    return false;
  }

  static double? _parseDouble(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString().trim());
  }

  static String? _nonEmpty(dynamic raw) {
    final value = raw?.toString().trim();
    return (value == null || value.isEmpty) ? null : value;
  }
}
