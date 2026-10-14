import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/courier_setup_repository.dart';
import '../models/courier_setup_models.dart';

/// Whether the courier-setup endpoints exist for this caller.
///
/// False (and the Couriers entry stays hidden) when jarz_courier is not
/// installed on the site or the caller is not allowed to use it. Only watched
/// from the Users screen, so it is asked once per visit.
final courierSetupAvailableProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  return ref.watch(courierSetupRepositoryProvider).isAvailable();
});

/// Employees with their courier-setup state, plus the branch list.
final courierCandidatesProvider = FutureProvider.autoDispose<CourierCandidates>(
  (ref) async {
    return ref.watch(courierSetupRepositoryProvider).listCandidates();
  },
);

/// Free-text filter on the candidates list.
final courierCandidatesSearchProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);
