/// Pure, network-free helpers for the pasted "location link" field.
///
/// Staff paste whatever the Maps share sheet gave them: a long
/// `https://www.google.com/maps/place/...@30.04,31.23,17z/...` URL, a short
/// `https://maps.app.goo.gl/xxxx` redirect, sometimes a WhatsApp forward with
/// prose wrapped around the link, and sometimes just `30.0444, 31.2357`.
///
/// Only the *shape* of the input is decided here. Resolving a short link to a
/// point is the backend's job — it is the only side that can follow the
/// redirect — so nothing in this file touches the network. That keeps the
/// "this isn't a link at all" rejection instant and free, and keeps the whole
/// thing unit-testable without a server.
library;

import 'package:latlong2/latlong.dart';

/// Shape checks and normalisation for the location-link field.
abstract final class MapsLinkInput {
  /// Furthest a customer pin may plausibly sit from the branch, in metres.
  ///
  /// A pasted link that resolves beyond this is almost always the wrong link
  /// (a shared restaurant abroad, a stale clipboard, a Maps "your timeline"
  /// URL) rather than a real delivery address, so the field refuses it instead
  /// of quietly stamping coordinates a courier will drive towards.
  ///
  /// 150 km comfortably covers Greater Cairo plus the North Coast runs while
  /// still catching another country.
  static const double defaultMaxDistanceFromBranchM = 150000;

  /// Hosts that mean "this text is a map link" even without a URL scheme.
  static const _mapHostHints = <String>[
    'goo.gl',
    'google.com/maps',
    'google.com.eg/maps',
    'maps.app',
    'maps.google',
    'openstreetmap',
    'osm.org',
    'waze.com',
    'bing.com/maps',
    'apple.com/maps',
  ];

  static final RegExp _urlPattern = RegExp(r'https?://\S+', caseSensitive: false);

  /// `30.0444, 31.2357` — comma, semicolon or plain whitespace separated.
  static final RegExp _coordinatePattern = RegExp(
    r'^([+-]?\d{1,2}(?:\.\d+)?)\s*[,;\s]\s*([+-]?\d{1,3}(?:\.\d+)?)$',
  );

  /// Strip the noise a share sheet wraps around the link.
  ///
  /// Returns the first URL found in [raw] when there is one (WhatsApp forwards
  /// arrive as "Check this out: https://maps.app.goo.gl/x"), otherwise the
  /// trimmed text with internal whitespace collapsed.
  static String normalize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    final url = _urlPattern.firstMatch(trimmed)?.group(0);
    if (url != null) {
      // Trailing punctuation from prose ("…goo.gl/abc.") is not part of the URL.
      return url.replaceAll(RegExp(r'[,.;:)\]]+$'), '');
    }

    return trimmed.replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Parse a bare `lat,lng` pair typed or pasted by hand.
  ///
  /// Returns null for anything that is not exactly two in-range numbers — a
  /// URL, prose, or a swapped pair outside the valid ranges.
  static LatLng? parseCoordinates(String raw) {
    final match = _coordinatePattern.firstMatch(normalize(raw));
    if (match == null) return null;

    final lat = double.tryParse(match.group(1)!);
    final lng = double.tryParse(match.group(2)!);
    if (lat == null || lng == null) return null;
    if (lat.abs() > 90 || lng.abs() > 180) return null;
    // 0,0 is Null Island — always a parse artefact, never a delivery address.
    if (lat == 0 && lng == 0) return null;

    return LatLng(lat, lng);
  }

  /// Whether [raw] is worth sending to the backend resolver at all.
  ///
  /// Deliberately permissive: the backend is the authority on what it can
  /// parse, and a false "unrecognised" on a link that would have resolved is
  /// far more expensive than one wasted round trip. This only rejects input
  /// that is plainly not a location — free text, a phone number, a name.
  static bool looksResolvable(String raw) {
    final value = normalize(raw);
    if (value.isEmpty) return false;
    if (parseCoordinates(value) != null) return true;
    if (value.contains('://')) return true;

    final lower = value.toLowerCase();
    return _mapHostHints.any(lower.contains);
  }
}
