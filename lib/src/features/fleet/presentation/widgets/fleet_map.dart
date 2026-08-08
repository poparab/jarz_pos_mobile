import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/fleet_models.dart';
import '../fleet_labels.dart';

/// OpenStreetMap-backed map plotting one marker per located courier.
///
/// Same `flutter_map` + OSM stack the leads map and the address preview already
/// use — the app ships no Google Maps SDK, and adding one would force a full
/// APK and break Shorebird patching.
class FleetMap extends StatelessWidget {
  const FleetMap({
    super.key,
    required this.couriers,
    required this.now,
    required this.selectedId,
    required this.onMarkerTap,
    this.tileProvider,
    this.fallbackCenter = const LatLng(30.05, 31.24), // Cairo
  });

  /// Only couriers with a usable fix; unlocated ones are surfaced elsewhere.
  final List<CourierPosition> couriers;

  /// Clock used to age every fix. Passed in so the caller's ticker (not the
  /// poll) controls how often the labels move.
  final DateTime now;

  final String? selectedId;
  final void Function(CourierPosition courier) onMarkerTap;
  final TileProvider? tileProvider;
  final LatLng fallbackCenter;

  @override
  Widget build(BuildContext context) {
    final points = [
      for (final courier in couriers)
        if (courier.point != null) courier.point!,
    ];

    return FlutterMap(
      options: MapOptions(
        initialCenter: points.isNotEmpty ? points.first : fallbackCenter,
        initialZoom: 13,
        minZoom: 4,
        maxZoom: 18,
        // Only fit when there is a real extent. A single point produces a
        // degenerate bounds that CameraFit resolves to an absurd zoom.
        initialCameraFit: points.length > 1
            ? CameraFit.bounds(
                bounds: LatLngBounds.fromPoints(points),
                padding: const EdgeInsets.all(56),
                maxZoom: 16,
              )
            : null,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.jarz.pos',
          maxZoom: 19,
          tileProvider: tileProvider,
        ),
        MarkerLayer(
          markers: [
            for (final courier in _paintOrder(couriers))
              Marker(
                point: courier.point!,
                width: 132,
                height: 54,
                // Anchors the widget's bottom edge on the point, so the pin
                // tip sits where the courier actually is.
                alignment: Alignment.topCenter,
                child: _CourierMarker(
                  courier: courier,
                  now: now,
                  isSelected: courier.id == selectedId,
                  onTap: () => onMarkerTap(courier),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Draws the freshest first so the ones you must *not* trust end up on top
  /// and legible when markers overlap.
  List<CourierPosition> _paintOrder(List<CourierPosition> input) {
    final ordered = [...input];
    ordered.sort((a, b) {
      final aRank = a.freshnessAt(now)?.index ?? -1;
      final bRank = b.freshnessAt(now)?.index ?? -1;
      return aRank.compareTo(bRank);
    });
    return ordered;
  }
}

class _CourierMarker extends StatelessWidget {
  const _CourierMarker({
    required this.courier,
    required this.now,
    required this.isSelected,
    required this.onTap,
  });

  final CourierPosition courier;
  final DateTime now;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final freshness = courier.freshnessAt(now);
    final color = freshness == null
        ? kFleetUnknownColor
        : fleetFreshnessColor(freshness);
    final age = fleetShortAge(l10n, courier.ageAt(now));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // The age rides on the label itself: colour alone would leave a
          // colour-blind dispatcher with no way to tell live from stale.
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(9),
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 3),
                ],
              ),
              child: Text(
                '${courier.displayName} · $age',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 1),
          Icon(
            Icons.location_on,
            color: color,
            size: isSelected ? 32 : 28,
            shadows: const [
              Shadow(color: Colors.black38, blurRadius: 3, offset: Offset(0, 1)),
            ],
          ),
        ],
      ),
    );
  }
}
