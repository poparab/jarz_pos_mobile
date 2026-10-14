import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/user_service.dart';
import '../data/courier_alert_models.dart';
import '../data/courier_alerts_repository.dart';

/// Open/high totals for the drawer badge.
///
/// `autoDispose` so each drawer open re-asks instead of freezing the first
/// read of the session. Callers outside the courier-map tier never reach the
/// network: the endpoint would answer 403, and a badge nobody can act on is
/// noise. A failed read yields no badge (see the drawer tile), because a stale
/// number is worse than none.
final courierAlertCountsProvider =
    FutureProvider.autoDispose<CourierAlertCounts>((ref) async {
      if (!ref.watch(canViewLiveCourierMapProvider)) {
        return CourierAlertCounts.zero;
      }
      return ref.watch(courierAlertsRepositoryProvider).getCounts();
    });

/// Open-only (default) versus every status.
final courierAlertsOpenOnlyProvider = StateProvider.autoDispose<bool>(
  (ref) => true,
);

/// The list the Courier Alerts screen shows for the current filter.
final courierAlertsProvider =
    FutureProvider.autoDispose<CourierAlertsResult>((ref) async {
      final openOnly = ref.watch(courierAlertsOpenOnlyProvider);
      return ref
          .watch(courierAlertsRepositoryProvider)
          .listAlerts(openOnly: openOnly);
    });
