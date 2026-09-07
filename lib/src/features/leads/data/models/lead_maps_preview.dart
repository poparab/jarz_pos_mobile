/// A read-only preview of a Google Maps place before a lead is saved.
///
/// The backend deliberately returns a tolerant, additive payload: coordinates
/// may be available without place metadata, and a valid link may be preserved
/// even when Google does not expose the rest of the place details. Keeping this
/// model hand-written lets older/newer backend payloads degrade safely instead
/// of taking the lead form down.
class LeadMapsPreview {
  const LeadMapsPreview({
    required this.success,
    required this.resolved,
    required this.url,
    required this.canonicalUrl,
    this.shortLink = false,
    this.pending = false,
    this.requestId,
    this.metadataSource = '',
    this.warnings = const <String>[],
    this.reason,
    this.latitude,
    this.longitude,
    this.precision,
    this.accuracyM,
    this.placeId,
    this.placeName,
    this.phone,
    this.website,
    this.formattedAddress,
    this.addressLine1,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.primaryArea,
    this.primaryAreaConfidence = '',
    this.primaryAreaSource = '',
    this.areaCandidates = const <String>[],
  });

  final bool success;
  final bool resolved;
  final String url;
  final String canonicalUrl;
  final bool shortLink;
  final bool pending;
  final String? requestId;
  final String metadataSource;
  final List<String> warnings;
  final String? reason;
  final double? latitude;
  final double? longitude;
  final String? precision;
  final double? accuracyM;
  final String? placeId;
  final String? placeName;
  final String? phone;
  final String? website;
  final String? formattedAddress;
  final String? addressLine1;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final String? primaryArea;

  /// ``high`` | ``medium`` | ``low`` | ``''``. Only meaningful when
  /// [primaryAreaIsEstimated]: Google's own answer carries no confidence
  /// because it is not a guess.
  final String primaryAreaConfidence;

  /// ``nearby_leads`` when the area was inferred from the pin's neighbours
  /// rather than returned by Google.
  final String primaryAreaSource;

  /// Runner-up areas for the same pin, best first. Lets the form offer a
  /// one-tap correction instead of making the rep retype a 60-value
  /// vocabulary they cannot see.
  final List<String> areaCandidates;

  /// True when the area is our inference, not Google's data. The form says
  /// so, because an estimate presented as fact is one a rep stops checking.
  bool get primaryAreaIsEstimated => primaryAreaSource == 'nearby_leads';

  bool get hasCoordinates {
    final lat = latitude;
    final lng = longitude;
    return resolved &&
        lat != null &&
        lng != null &&
        lat.abs() <= 90 &&
        lng.abs() <= 180 &&
        !(lat == 0 && lng == 0);
  }

  bool get hasPlaceDetails => <String?>[
    placeName,
    phone,
    website,
    formattedAddress,
    addressLine1,
    city,
    state,
    country,
    pincode,
    primaryArea,
      ].any((value) => value != null && value.trim().isNotEmpty);

  factory LeadMapsPreview.fromJson(Map<String, dynamic> json) {
    final suggestions = json['suggestions'] is Map
        ? Map<String, dynamic>.from(json['suggestions'] as Map)
        : const <String, dynamic>{};

    dynamic pick(String key) => json[key] ?? suggestions[key];
    final url = _text(json['url']) ?? _text(suggestions['maps_url']) ?? '';

    return LeadMapsPreview(
      success: _flag(json['success']),
      resolved: _flag(json['resolved']),
      url: url,
      canonicalUrl: _text(json['canonical_url']) ?? url,
      shortLink: _flag(json['short_link']),
      pending: _flag(json['pending']),
      requestId: _text(json['request_id']),
      metadataSource: _text(json['metadata_source']) ?? '',
      warnings: (json['warnings'] as List? ?? const <dynamic>[])
          .map((value) => value.toString().trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false),
      reason: _text(json['reason']),
      latitude: _number(pick('latitude')),
      longitude: _number(pick('longitude')),
      precision: _text(json['precision']),
      accuracyM: _number(json['accuracy_m']),
      placeId: _text(json['place_id']),
      placeName: _text(pick('place_name')) ?? _text(suggestions['lead_name']),
      phone: _text(pick('phone')),
      website: _text(pick('website')),
      formattedAddress: _text(pick('formatted_address')),
      addressLine1: _text(pick('address_line1')),
      city: _text(pick('city')),
      state: _text(pick('state')),
      country: _text(pick('country')),
      pincode: _text(pick('pincode')),
      primaryArea: _text(pick('primary_area')),
      primaryAreaConfidence: _text(json['primary_area_confidence']) ?? '',
      primaryAreaSource: _text(json['primary_area_source']) ?? '',
      areaCandidates: (json['area_candidates'] as List? ?? const <dynamic>[])
          .map((value) => value.toString().trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false),
    );
  }

  static bool _flag(dynamic raw) {
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    return const <String>{
      '1',
      'true',
      'yes',
      'y',
    }.contains(raw?.toString().trim().toLowerCase());
  }

  static double? _number(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString().trim() ?? '');
  }

  static String? _text(dynamic raw) {
    final value = raw?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }
}
