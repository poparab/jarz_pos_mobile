import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../leads/presentation/leads_theme.dart';
import '../../data/models/visit_plan.dart';

/// The day drawn on a map: the stops, numbered, joined in visiting order.
///
/// Two things it deliberately does NOT do. It does not cluster — a day is a
/// dozen pins, and hiding two of them behind a "3" on the one screen where the
/// rep is checking the *sequence* would defeat the purpose. And it does not
/// re-fit the camera on every rebuild, only when the set of stops actually
/// changes, so a check-in does not yank the map out from under a finger.
///
/// [VisitPlan.geometry] is the road path when OSRM drew one. Without it the
/// polyline is straight segments between stops — visibly an approximation,
/// which is honest: the totals are approximations too in that case.
class RouteMap extends StatefulWidget {
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
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  final MapController _controller = MapController();
  String _fittedSignature = '';
  bool _ready = false;

  /// What the camera was fitted to. Positions only — a status change must not
  /// count as a new shape, or every check-in would re-frame the map.
  String get _signature => widget.plan.stops
      .where((s) => s.hasLocation)
      .map((s) => '${s.latitude},${s.longitude}')
      .join(';');

  List<LatLng> get _points => [
        for (final stop in widget.plan.stops)
          if (stop.hasLocation && stop.status != 'Cancelled')
            LatLng(stop.latitude!, stop.longitude!),
      ];

  LatLng? get _start {
    final lat = widget.plan.startLatitude;
    final lng = widget.plan.startLongitude;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  void _fitIfNeeded() {
    if (!_ready) return;
    final signature = _signature;
    if (signature == _fittedSignature || signature.isEmpty) return;
    final all = [..._points, if (_start != null) _start!];
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
  void didUpdateWidget(covariant RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitIfNeeded());
  }

  @override
  Widget build(BuildContext context) {
    final points = _points;
    final geometry = widget.plan.geometry;
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
              : (_start ?? const LatLng(30.0444, 31.2357)),
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
                  points: [if (_start != null) _start!, ...line],
                  strokeWidth: 4,
                  color: LeadsTheme.sahelBlue.withValues(alpha: 0.75),
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              if (_start != null)
                Marker(
                  point: _start!,
                  width: 26,
                  height: 26,
                  child: const _StartMarker(),
                ),
              ..._stopMarkers(),
            ],
          ),
        ],
      ),
    );
  }

  List<Marker> _stopMarkers() {
    final markers = <Marker>[];
    var position = 0;
    for (final stop in widget.plan.stops) {
      if (!stop.hasLocation || stop.status == 'Cancelled') continue;
      position += 1;
      markers.add(
        Marker(
          point: LatLng(stop.latitude!, stop.longitude!),
          width: 30,
          height: 30,
          child: GestureDetector(
            onTap: widget.onStopTap == null
                ? null
                : () => widget.onStopTap!(stop),
            child: _StopMarker(position: position, status: stop.status),
          ),
        ),
      );
    }
    return markers;
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
