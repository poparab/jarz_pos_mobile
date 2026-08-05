import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// Tile source for every location preview.
///
/// Null in the app, which leaves `flutter_map` on its network provider. Widget
/// tests override it with a local provider so no test reaches a tile server —
/// the network provider wraps a retrying HTTP client whose backoff timers
/// outlive the test.
final locationTileProviderProvider = Provider<TileProvider?>((ref) => null);

/// Small non-interactive OpenStreetMap thumbnail with a single marker.
///
/// Same OSM/`flutter_map` stack as the leads map — the app ships no Google Maps
/// SDK, and adding one would force a full APK build and break Shorebird
/// patching for a preview thumbnail.
///
/// Interaction is disabled on purpose: this lives inside scrollable forms and
/// dialogs, where a pannable map swallows the drag and traps the user.
class LocationPreviewMap extends StatelessWidget {
  const LocationPreviewMap({
    super.key,
    required this.point,
    this.height = 140,
    this.zoom = 16,
    this.tileProvider,
  });

  final LatLng point;
  final double height;
  final double zoom;

  /// Injectable tile source. Left null in the app so `flutter_map`'s network
  /// provider is used; widget tests pass a local one so no test ever reaches
  /// for a tile server (and no retry timer outlives the test).
  final TileProvider? tileProvider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: zoom,
            minZoom: 4,
            maxZoom: 18,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
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
                Marker(
                  point: point,
                  width: 36,
                  height: 36,
                  alignment: Alignment.topCenter,
                  child: Icon(
                    Icons.location_on,
                    size: 32,
                    color: theme.colorScheme.primary,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
