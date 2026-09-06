/// Everything the pin-correction screen needs about one Address' delivery pin.
///
/// Matches `jarz_pos.api.geo.get_address_pin`. Hand-written, matching the rest
/// of the geo feature's models (see `MapsLinkPreview`): every field tolerates a
/// missing or older backend rather than throwing, because a read that cannot be
/// fully parsed must degrade to "pin unknown", not crash the correction flow.
library;

class AddressPin {
  const AddressPin({
    required this.address,
    this.latitude,
    this.longitude,
    this.source,
    this.confidence = 0,
    this.accuracyM,
    this.verifiedOn,
    this.storedLink,
    this.ladder = const {},
  });

  final String address;
  final double? latitude;
  final double? longitude;

  /// `custom_geo_source` — where the pin on file came from.
  final String? source;

  /// `custom_geo_confidence` — the ladder rank stamped at write time.
  final int confidence;

  /// Metres, when the source that set the current pin measured one. The
  /// backend's `custom_geo_accuracy_m` column defaults to 0 for "no accuracy
  /// reported", which is why [hasAccuracy] exists instead of a null check.
  final double? accuracyM;

  /// Set only for a `courier_verified` pin.
  final String? verifiedOn;

  /// The legacy pasted-link text still sitting in `address_line2`, echoed
  /// read-only — nothing in this screen rewrites it.
  final String? storedLink;

  /// The server's confidence ladder, `{source: rank}`. Preferred over the
  /// client-side `GeoPinSource.defaultRanks` copy when present.
  final Map<String, int> ladder;

  bool get hasPin => latitude != null && longitude != null;

  /// True only when the accuracy column carries a real measurement — see
  /// `geo_resolution.accuracy_is_known` on the backend for why 0 means
  /// "unknown", never "accurate to 0 m".
  bool get hasAccuracy => (accuracyM ?? 0) > 0;

  factory AddressPin.fromJson(Map<String, dynamic> json) => AddressPin(
    address: (json['address'] ?? '').toString(),
    latitude: _toDouble(json['latitude']),
    longitude: _toDouble(json['longitude']),
    source: _nullIfBlank(json['source']),
    confidence: _toInt(json['confidence']),
    accuracyM: _toDouble(json['accuracy_m']),
    verifiedOn: _nullIfBlank(json['verified_on']),
    storedLink: _nullIfBlank(json['stored_link']),
    ladder: _toLadder(json['ladder']),
  );
}

Map<String, int> _toLadder(dynamic raw) {
  if (raw is! Map) return const {};
  return raw.map((key, value) => MapEntry(key.toString(), _toInt(value)));
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _nullIfBlank(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
