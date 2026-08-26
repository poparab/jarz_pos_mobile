import 'package:url_launcher/url_launcher.dart';

import '../data/models/visit_plan.dart';

/// Hand a route over to the phone's maps app.
///
/// The app draws the plan; it does not do turn-by-turn. Building a navigator
/// would mean a paid SDK and a worse one than the app already on the phone, so
/// the handoff is a Google Maps **universal URL** — free, no API key, and it
/// opens the installed Maps app (falling back to the browser) on Android, iOS
/// and web alike.
///
/// Two ways out, because they answer different questions:
///
/// * [navigateToStop] — "get me to the next door". This is what a rep uses all
///   day: one destination, live traffic, and the plan stays the index they come
///   back to. It is also the only shape that works for a 14-stop day.
/// * [navigateWholeRoute] — "show me the whole run". Google's directions URL
///   accepts an origin, a destination and a bounded list of waypoints, so long
///   routes are truncated rather than silently mangled; see [maxWaypoints].
abstract final class VisitNavigation {
  /// Google's documented ceiling for `waypoints` on the universal URL. Beyond
  /// this the URL is rejected or quietly trimmed, so we trim it ourselves and
  /// say so rather than letting the rep discover half a route in the car.
  static const int maxWaypoints = 9;

  static Future<void> _open(Uri uri) async {
    // Launch directly. Do NOT gate on canLaunchUrl: on Android 11+ it returns
    // false unless every scheme is declared in the manifest <queries>, which
    // silently blocks the launch. Same reasoning as LeadActions._open.
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return;
    } catch (_) {
      // externalApplication may be unavailable for this URI; fall through.
    }
    try {
      await launchUrl(uri);
    } catch (_) {
      // No handler available; nothing more we can do.
    }
  }

  static String _coord(double lat, double lng) =>
      '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}';

  /// Drive to one stop. Prefers its coordinates over its saved Maps link: the
  /// pin is the door, whereas a link can point at the brand's head office.
  static Future<void> navigateToStop(VisitStop stop) async {
    if (stop.hasLocation) {
      await _open(Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=${_coord(stop.latitude!, stop.longitude!)}'
        '&travelmode=driving',
      ));
      return;
    }
    if (stop.mapsUrl.trim().isNotEmpty) {
      await _open(Uri.parse(stop.mapsUrl.trim()));
    }
  }

  /// How many stops of [plan] a single whole-route handoff can carry.
  ///
  /// Origin and destination are free; everything between them is a waypoint.
  static int navigableStopCount(VisitPlan plan) {
    final routable = _routable(plan);
    return routable.length <= maxWaypoints + 2
        ? routable.length
        : maxWaypoints + 2;
  }

  /// Whether the whole route fits in one handoff.
  static bool fitsInOneHandoff(VisitPlan plan) =>
      _routable(plan).length <= maxWaypoints + 2;

  static List<VisitStop> _routable(VisitPlan plan) => plan.stops
      .where((s) => s.hasLocation && s.status != 'Cancelled')
      .toList();

  /// Open the whole run in Maps, in the plan's order.
  ///
  /// Returns the number of stops actually handed over, so the caller can tell
  /// the rep when a long day was truncated. Returns 0 when there is nothing
  /// routable — which is a normal answer for an empty plan, not an error.
  static Future<int> navigateWholeRoute(VisitPlan plan) async {
    final stops = _routable(plan);
    if (stops.isEmpty) return 0;

    final origin = plan.startLatitude != null && plan.startLongitude != null
        ? _coord(plan.startLatitude!, plan.startLongitude!)
        : _coord(stops.first.latitude!, stops.first.longitude!);

    // With no explicit start, the first stop IS the origin and must not also
    // appear as a waypoint — Maps would route you to your own doorstep first.
    final rest = plan.startLatitude != null && plan.startLongitude != null
        ? stops
        : stops.skip(1).toList();
    if (rest.isEmpty) {
      await _open(Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$origin'
        '&destination=$origin&travelmode=driving',
      ));
      return 1;
    }

    final capped = rest.take(maxWaypoints + 1).toList();
    final destination = capped.last;
    final waypoints = capped
        .sublist(0, capped.length - 1)
        .map((s) => _coord(s.latitude!, s.longitude!))
        .join('|');

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=$origin'
      '&destination=${_coord(destination.latitude!, destination.longitude!)}'
      '${waypoints.isEmpty ? '' : '&waypoints=$waypoints'}'
      '&travelmode=driving',
    );
    await _open(uri);
    return capped.length + (rest.length == stops.length ? 0 : 1);
  }

  static Future<void> call(String phone) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty) return;
    await _open(Uri(scheme: 'tel', path: cleaned));
  }
}
