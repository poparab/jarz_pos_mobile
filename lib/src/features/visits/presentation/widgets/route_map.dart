import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../leads/presentation/leads_theme.dart';
import '../../data/models/visit_plan.dart';

/// One place on a drawn route, independent of where it came from.
///
/// The saved-plan map and the live builder preview draw the same picture from
/// different types, so the picture takes this instead of either of them. Two
/// map implementations would drift, and the one a rep checks the sequence on
/// is not the place to discover that.
class RouteMapStop {
  const RouteMapStop({
    required this.latitude,
    required this.longitude,
    this.status = 'Planned',
  });

  final double latitude;
  final double longitude;
  final String status;
}

/// The day drawn on a map: the stops, numbered, joined in visiting order.
///
/// Two things it deliberately does NOT do. It does not cluster — a day is a
/// dozen pins, and hiding two of them behind a "3" on the one screen where the
/// rep is checking the *sequence* would defeat the purpose. And it does not
/// re-fit the camera on every rebuild, only when the set of positions actually
/// changes, so a check-in does not yank the map out from under a finger.
class RouteMapView extends StatefulWidget {
  const RouteMapView({
    super.key,
    required this.stops,
    this.start,
    this.geometry,
    this.height = 240,
    this.onStopTap,
  });

  final List<RouteMapStop> stops;
  final LatLng? start;

  /// Road path through the stops, `[[lat, lng], ...]`. Null draws straight
  /// segments instead — visibly an approximation, which is honest, because the
  /// totals are approximations in that case too.
  final List<List<double>>? geometry;

  final double height;
  final ValueChanged<int>? onStopTap;

  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> {
  final MapController _controller = MapController();
  String _fittedSignature = '';
  bool _ready = false;

  /// What the camera was fitted to. Positions only — a status change must not
  /// count as a new shape, or every check-in would re-frame the map.
  String get _signature =>
      widget.stops.map((s) => '${s.latitude},${s.longitude}').join(';');

  List<LatLng> get _points =>
      [for (final s in widget.stops) LatLng(s.latitude, s.longitude)];

  void _fitIfNeeded() {
    if (!_ready) return;
    final signature = _signature;
    if (signature == _fittedSignature || signature.isEmpty) return;
    final all = [..._points, if (widget.start != null) widget.start!];
    if (all.isEmpty) return;
    _fittedSignature = signature;
    if (all.length == 1) {
      _controller.move(all.first, 14);
      return;
    }
    _controller.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(all),
        padding: const EdgeInsets.all(40),
        maxZoom: 15,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant RouteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitIfNeeded());
  }

  @override
  Widget build(BuildContext context) {
    final points = _points;
    final geometry = widget.geometry;
    final line = geometry != null && geometry.length > 1
        ? [for (final pair in geometry) LatLng(pair[0], pair[1])]
        : points;

    return SizedBox(
      height: widget.height,
      child: FlutterMap(
        mapController: _controller,
        options: MapOptions(
          initialCenter: points.isNotEmpty
              ? points.first
              : (widget.start ?? const LatLng(30.0444, 31.2357)),
          initialZoom: 12,
          minZoom: 4,
          maxZoom: 18,
          onMapReady: () {
            _ready = true;
            _fitIfNeeded();
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.jarz.pos',
            maxZoom: 19,
          ),
          if (line.length > 1)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [if (widget.start != null) widget.start!, ...line],
                  strokeWidth: 4,
                  color: LeadsTheme.sahelBlue.withValues(alpha: 0.75),
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              if (widget.start != null)
                Marker(
                  point: widget.start!,
                  width: 26,
                  height: 26,
                  child: const _StartMarker(),
                ),
              for (var i = 0; i < widget.stops.length; i++)
                Marker(
                  point: LatLng(
                      widget.stops[i].latitude, widget.stops[i].longitude),
                  width: 30,
                  height: 30,
                  child: GestureDetector(
                    onTap: widget.onStopTap == null
                        ? null
                        : () => widget.onStopTap!(i),
                    child: _StopMarker(
                      position: i + 1,
                      status: widget.stops[i].status,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The saved plan's map. A thin adapter over [RouteMapView].
class RouteMap extends StatelessWidget {
  const RouteMap({
    super.key,
    required this.plan,
    this.height = 240,
    this.onStopTap,
  });

  final VisitPlan plan;
  final double height;
  final ValueChanged<VisitStop>? onStopTap;

  @override
  Widget build(BuildContext context) {
    final drawn = plan.stops
        .where((s) => s.hasLocation && s.status != 'Cancelled')
        .toList();
    final lat = plan.startLatitude;
    final lng = plan.startLongitude;
    return RouteMapView(
      stops: [
        for (final s in drawn)
          RouteMapStop(
            latitude: s.latitude!,
            longitude: s.longitude!,
            status: s.status,
          ),
      ],
      start: (lat != null && lng != null) ? LatLng(lat, lng) : null,
      geometry: plan.geometry,
      height: height,
      onStopTap: onStopTap == null
          ? null
          : (index) {
              if (index >= 0 && index < drawn.length) onStopTap!(drawn[index]);
            },
    );
  }
}

class _StartMarker extends StatelessWidget {
  const _StartMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: LeadsTheme.sahelBlue, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: const Icon(Icons.trip_origin, size: 14, color: LeadsTheme.sahelBlue),
    );
  }
}

/// A numbered pin. The NUMBER is the point of this map — a rep is checking the
/// order, not the geography, and an unnumbered dot answers the wrong question.
class _StopMarker extends StatelessWidget {
  const _StopMarker({required this.position, required this.status});

  final int position;
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Visited' => const Color(0xFF2E7D32),
      'Skipped' => const Color(0xFF9E9E9E),
      _ => LeadsTheme.sahelBlue,
    };
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        '$position',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
