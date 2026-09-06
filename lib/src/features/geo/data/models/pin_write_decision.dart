/// Outcome of `dry_run_address_pin` / `set_address_pin` — the confidence-ladder
/// decision for one proposed pin write on an EXISTING address.
///
/// Both endpoints share this shape (`geo_resolution.evaluate_pin_write`), so one
/// model serves both the preview and the commit response. Every field is
/// nullable because a short link that only queued a background resolve comes
/// back with just [reason] set and nothing else — the decision could not be
/// made inline, and the model must say so rather than fabricate zeros.
library;

class PinWriteDecision {
  const PinWriteDecision({
    required this.success,
    this.accepted,
    this.reason,
    this.address,
    this.source,
    this.incomingRank,
    this.currentSource,
    this.currentRank,
    this.resultingSource,
    this.resultingRank,
    this.latitude,
    this.longitude,
    this.accuracyM,
    this.currentLatitude,
    this.currentLongitude,
    this.coordinatesChanged,
    this.movedM,
    this.precision,
    this.dryRun = false,
    this.error,
  });

  /// Transport-level success. `false` only for a request-shape error (missing
  /// address, etc) — a routine "kept the existing pin" is `success: true,
  /// accepted: false`.
  final bool success;

  /// Whether this write would (or did) actually change the stored pin. `null`
  /// only for the short-link-pending shape, where nothing was decided yet.
  final bool? accepted;

  /// `accepted`, `lower_confidence`, `short_link_pending`, `invalid_coordinates`,
  /// `unknown_source`, `address_not_found`, … — see `evaluate_pin_write`.
  final String? reason;

  final String? address;

  /// The source the caller proposed with (echoed back).
  final String? source;
  final int? incomingRank;

  /// The pin's source/rank BEFORE this write.
  final String? currentSource;
  final int? currentRank;

  /// The ladder's pick between current and incoming — equals [source] only
  /// when [accepted] is true.
  final String? resultingSource;
  final int? resultingRank;

  final double? latitude;
  final double? longitude;
  final double? accuracyM;

  final double? currentLatitude;
  final double? currentLongitude;
  final bool? coordinatesChanged;

  /// Straight-line distance between the old and new pin, in metres.
  final double? movedM;

  /// Precision label from parsing a link, present only on the link path.
  final String? precision;

  /// Echoed by the dry-run endpoint; always false for a real commit.
  final bool dryRun;

  final String? error;

  /// A short link that could not be resolved inline — queued for a background
  /// worker instead. Neither accepted nor rejected; there is nothing further
  /// this response can preview.
  bool get isPending =>
      reason == 'short_link_pending' || reason == 'short_link_unqueued';

  factory PinWriteDecision.fromJson(Map<String, dynamic> json) =>
      PinWriteDecision(
        success: _toBool(json['success']),
        accepted: json['accepted'] == null ? null : _toBool(json['accepted']),
        reason: _nullIfBlank(json['reason']),
        address: _nullIfBlank(json['address']),
        source: _nullIfBlank(json['source']),
        incomingRank: _toIntOrNull(json['incoming_rank']),
        currentSource: _nullIfBlank(json['current_source']),
        currentRank: _toIntOrNull(json['current_rank']),
        resultingSource: _nullIfBlank(json['resulting_source']),
        resultingRank: _toIntOrNull(json['resulting_rank']),
        latitude: _toDouble(json['latitude']),
        longitude: _toDouble(json['longitude']),
        accuracyM: _toDouble(json['accuracy_m']),
        currentLatitude: _toDouble(json['current_latitude']),
        currentLongitude: _toDouble(json['current_longitude']),
        coordinatesChanged: json['coordinates_changed'] == null
            ? null
            : _toBool(json['coordinates_changed']),
        movedM: _toDouble(json['moved_m']),
        precision: _nullIfBlank(json['precision']),
        dryRun: _toBool(json['dry_run']),
        error: _nullIfBlank(json['error']),
      );
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    return const ['1', 'true', 'yes', 'y'].contains(value.trim().toLowerCase());
  }
  return false;
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}

int? _toIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

String? _nullIfBlank(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
