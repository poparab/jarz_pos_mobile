import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/lead.dart';
import '../leads_theme.dart';

/// Reusable OpenStreetMap-backed map that plots leads with valid coordinates.
class LeadMap extends StatelessWidget {
  const LeadMap({
    super.key,
    required this.leads,
    required this.onMarkerTap,
    this.center = const LatLng(30.05, 31.24), // Cairo
    this.initialZoom = 10,
  });

  final List<Lead> leads;
  final void Function(Lead lead) onMarkerTap;
  final LatLng center;
  final double initialZoom;

  @override
  Widget build(BuildContext context) {
    final located = leads
        .where((l) => l.latitude != null && l.longitude != null)
        .toList();

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: initialZoom,
        minZoom: 4,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.jarz.pos',
          maxZoom: 19,
        ),
        MarkerLayer(
          markers: [
            for (final lead in located)
              Marker(
                point: LatLng(lead.latitude!, lead.longitude!),
                width: 36,
                height: 36,
                alignment: Alignment.topCenter,
                child: _LeadMarker(
                  lead: lead,
                  onTap: () => onMarkerTap(lead),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _LeadMarker extends StatelessWidget {
  const _LeadMarker({required this.lead, required this.onTap});

  final Lead lead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tier = LeadsTheme.tierColors(lead.tier);
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        Icons.location_on,
        color: tier.bg == Colors.white ? LeadsTheme.berryPink : tier.bg,
        size: 32,
        shadows: const [
          Shadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}
