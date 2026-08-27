import 'package:flutter/foundation.dart';

/// What the server said when it refused this build: HTTP 426 Upgrade Required.
@immutable
class AppUpgradeRefusal {
  const AppUpgradeRefusal({
    required this.minimumBuild,
    required this.downloadUrl,
    required this.message,
  });

  final int minimumBuild;
  final String downloadUrl;
  final String message;
}

/// One-way channel from the Dio interceptor to the update gate.
///
/// The interceptor is built inside `dioProvider` without a `Ref`, so it cannot
/// write Riverpod state directly. It publishes here instead, and the gate
/// notifier - which does have a Ref - listens and raises the barrier.
///
/// Lives in `core` rather than beside the gate so the interceptor does not
/// have to import a feature, and carries only primitives for the same reason.
///
/// A singleton because the interceptor outlives any particular widget tree and
/// there is only ever one Dio.
class AppUpgradeSignal {
  AppUpgradeSignal._();

  static final AppUpgradeSignal instance = AppUpgradeSignal._();

  /// Latched, so one 426 keeps the barrier up even if later requests fail for
  /// unrelated reasons. Cleared only by an explicit re-check, which then asks
  /// the server again from scratch - the escape hatch for a floor raised by
  /// mistake, which would otherwise strand every running device until it was
  /// reinstalled.
  final ValueNotifier<AppUpgradeRefusal?> refusal =
      ValueNotifier<AppUpgradeRefusal?>(null);

  void report(AppUpgradeRefusal value) => refusal.value = value;

  void clear() => refusal.value = null;
}
