import 'package:flutter/material.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import '../data/courier_alert_models.dart';

/// Severity colours: red for High (act now), amber for Medium, grey for Low.
Color courierAlertSeverityColor(CourierAlertSeverity severity) {
  switch (severity) {
    case CourierAlertSeverity.high:
      return const Color(0xFFB3261E);
    case CourierAlertSeverity.medium:
      return const Color(0xFFE08A00);
    case CourierAlertSeverity.low:
      return const Color(0xFF607D8B);
  }
}

String courierAlertSeverityLabel(
  AppLocalizations l10n,
  CourierAlertSeverity severity,
) {
  switch (severity) {
    case CourierAlertSeverity.high:
      return l10n.courierAlertsSeverityHigh;
    case CourierAlertSeverity.medium:
      return l10n.courierAlertsSeverityMedium;
    case CourierAlertSeverity.low:
      return l10n.courierAlertsSeverityLow;
  }
}

String courierAlertStatusLabel(
  AppLocalizations l10n,
  CourierAlertStatus status,
) {
  switch (status) {
    case CourierAlertStatus.open:
      return l10n.courierAlertsStatusOpen;
    case CourierAlertStatus.reviewed:
      return l10n.courierAlertsStatusReviewed;
    case CourierAlertStatus.dismissed:
      return l10n.courierAlertsStatusDismissed;
  }
}

/// The localized name of an anomaly type; an unknown type from a newer server
/// is shown as the raw string rather than hidden.
String courierAlertTypeLabel(AppLocalizations l10n, String anomalyType) {
  switch (anomalyType) {
    case 'Detour':
      return l10n.courierAlertTypeDetour;
    case 'Excessive Idle':
      return l10n.courierAlertTypeExcessiveIdle;
    case 'Speeding':
      return l10n.courierAlertTypeSpeeding;
    case 'Delivered Far From Pin':
      return l10n.courierAlertTypeDeliveredFarFromPin;
    case 'Ping Gap':
      return l10n.courierAlertTypePingGap;
    case 'Mock GPS':
      return l10n.courierAlertTypeMockGps;
    case 'Unexpected Stop':
      return l10n.courierAlertTypeUnexpectedStop;
    case 'Stale Ping':
      return l10n.courierAlertTypeStalePing;
    case 'Tracker Mode Changed':
      return l10n.courierAlertTypeTrackerModeChanged;
    case 'Tracking Lost':
      return l10n.courierAlertTypeTrackingLost;
    case 'Action Refused':
      return l10n.courierAlertTypeActionRefused;
    case 'Delivery Code Failed':
      return l10n.courierAlertTypeDeliveryCodeFailed;
    default:
      return anomalyType.isEmpty ? '-' : anomalyType;
  }
}

/// Whether [anomalyType] is one the app has a translated label for. Used to
/// decide if the raw English name adds anything as a second line.
bool courierAlertTypeIsKnown(String anomalyType) =>
    knownCourierAnomalyTypes.contains(anomalyType);
