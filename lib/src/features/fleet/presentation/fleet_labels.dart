import 'package:flutter/material.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';

import '../data/models/fleet_models.dart';

/// Colours for the three staleness buckets.
///
/// Deliberately traffic-light: this is the one thing a dispatcher reads at a
/// glance, and getting it wrong means routing an order to a courier who was
/// last seen fifteen minutes and several kilometres ago.
Color fleetFreshnessColor(FleetFreshness freshness) {
  return switch (freshness) {
    FleetFreshness.fresh => const Color(0xFF2E7D32), // green 800
    FleetFreshness.ageing => const Color(0xFFEF6C00), // orange 800
    FleetFreshness.stale => const Color(0xFFC62828), // red 800
  };
}

/// Colour for a courier with no usable fix at all.
const Color kFleetUnknownColor = Color(0xFF616161); // grey 700

String fleetFreshnessLabel(AppLocalizations l10n, FleetFreshness freshness) {
  return switch (freshness) {
    FleetFreshness.fresh => l10n.fleetFreshnessFresh,
    FleetFreshness.ageing => l10n.fleetFreshnessAgeing,
    FleetFreshness.stale => l10n.fleetFreshnessStale,
  };
}

/// "3 min ago" — an absolute timestamp is useless at a glance on this screen.
///
/// Rounds down, so a fix is never described as younger than it is.
String fleetRelativeAge(AppLocalizations l10n, Duration? age) {
  if (age == null) return l10n.fleetAgeUnknown;
  if (age.inMinutes < 1) return l10n.fleetAgeJustNow;
  if (age.inMinutes < 60) return l10n.fleetAgeMinutes(age.inMinutes);
  if (age.inHours < 24) return l10n.fleetAgeHours(age.inHours);
  return l10n.fleetAgeDays(age.inDays);
}

/// Compact form for the map marker chip, where space is tight.
String fleetShortAge(AppLocalizations l10n, Duration? age) {
  if (age == null) return l10n.fleetAgeUnknown;
  if (age.inMinutes < 1) return l10n.fleetAgeShortNow;
  if (age.inMinutes < 60) return l10n.fleetAgeShortMinutes(age.inMinutes);
  if (age.inHours < 24) return l10n.fleetAgeShortHours(age.inHours);
  return l10n.fleetAgeShortDays(age.inDays);
}
