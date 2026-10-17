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
        reason = null;

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

  /// Backend reason for a link whose point lies outside the delivery area.
  static const String outsideServiceArea = 'outside_service_area';

  bool get isOutsideServiceArea => reason == outsideServiceArea;

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
