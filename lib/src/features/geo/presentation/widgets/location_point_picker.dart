import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/localization/localization_extensions.dart';
import 'location_preview_map.dart';

/// Full-screen "tap to drop a pin" picker for correcting an address pin by
/// hand, when there is no Maps link to paste.
///
/// Deliberately reuses [locationTileProviderProvider] and the same OSM tile
/// template as [LocationPreviewMap] rather than standing up a second map
/// stack — the only thing this widget adds over that read-only preview is a
/// tap handler and a confirm bar.
class LocationPointPicker extends ConsumerStatefulWidget {
  const LocationPointPicker({super.key, this.initial});

  /// Existing pin to centre on, when correcting one that already has a point.
  final LatLng? initial;

  /// Cairo — the reasonable default centre when there is no existing pin to
  /// start from.
  static const LatLng fallbackCenter = LatLng(30.0444, 31.2357);

  @override
  ConsumerState<LocationPointPicker> createState() =>
      _LocationPointPickerState();
}

class _LocationPointPickerState extends ConsumerState<LocationPointPicker> {
  late LatLng _point = widget.initial ?? LocationPointPicker.fallbackCenter;
  final MapController _controller = MapController();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addressPinPickOnMap)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: _point,
              initialZoom: 16,
              minZoom: 4,
              maxZoom: 19,
              onTap: (tapPosition, point) => setState(() => _point = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.jarz.pos',
                maxZoom: 19,
                tileProvider: ref.watch(locationTileProviderProvider),
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _point,
                    width: 40,
                    height: 40,
                    alignment: Alignment.topCenter,
                    child: Icon(
                      Icons.location_on,
                      size: 36,
                      color: theme.colorScheme.error,
                      shadows: const [
                        Shadow(
                          color: Colors.black38,
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
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_point.latitude.toStringAsFixed(6)}, '
                        '${_point.longitude.toStringAsFixed(6)}',
                        textDirection: TextDirection.ltr,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      key: const ValueKey('location_point_picker_confirm'),
                      onPressed: () => Navigator.of(context).pop(_point),
                      child: Text(l10n.addressPinUseThisPoint),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Push [LocationPointPicker] and return the tapped point, or null on cancel.
Future<LatLng?> showLocationPointPicker(
  BuildContext context, {
  LatLng? initial,
}) {
  return Navigator.of(context).push<LatLng>(
    MaterialPageRoute(builder: (_) => LocationPointPicker(initial: initial)),
  );
}
