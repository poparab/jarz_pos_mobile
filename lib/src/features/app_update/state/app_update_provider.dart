import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/env/app_build_identity.dart';
import '../../../core/network/app_upgrade_signal.dart';
import '../data/app_update_service.dart';

/// How often an app that is never backgrounded re-asks the server.
///
/// A POS tablet can stay in the foreground for a whole shift, so resume alone
/// would never fire and a floor raised mid-day would not land until closing.
const kAppUpdatePollInterval = Duration(minutes: 15);

/// Injectable so tests can supply a build number without a device.
final appBuildIdentityLoaderProvider = Provider<AppBuildIdentityLoader>(
  (ref) => loadAppBuildIdentity,
);

/// How often to re-ask, or `null` to poll only on launch and resume.
///
/// A seam rather than a constant so widget tests can switch the background
/// timer off; a pending periodic timer outlives the widget tree and trips
/// flutter_test's invariant check.
final appUpdatePollIntervalProvider = Provider<Duration?>(
  (ref) => kAppUpdatePollInterval,
);

final appBuildIdentityProvider = FutureProvider<AppBuildIdentity>((ref) {
  return ref.watch(appBuildIdentityLoaderProvider)();
});

class AppUpdateNotifier extends AsyncNotifier<AppUpdateRequirement> {
  Timer? _poll;
  bool _inFlight = false;

  @override
  Future<AppUpdateRequirement> build() async {
    AppUpgradeSignal.instance.refusal.addListener(_onRefusal);
    final interval = ref.watch(appUpdatePollIntervalProvider);
    if (interval != null) {
      _poll = Timer.periodic(interval, (_) => recheck());
    }
    ref.onDispose(() {
      AppUpgradeSignal.instance.refusal.removeListener(_onRefusal);
      _poll?.cancel();
    });

    return _resolve();
  }

  void _onRefusal() {
    final refusal = AppUpgradeSignal.instance.refusal.value;
    if (refusal != null) {
      state = AsyncData(_fromRefusal(refusal));
    }
  }

  /// Re-asks the server. Safe to call from anywhere, any number of times.
  ///
  /// Deliberately does not flip to [AsyncLoading]: the gate reads
  /// `valueOrNull`, and dropping the previous answer mid-check would flash the
  /// barrier away for a device that is already blocked.
  ///
  /// Drops any latched 426 first so the answer comes from the server rather
  /// than from history. That is what lets an admin undo a floor set too high
  /// without every running device needing a reinstall; a build that really is
  /// stale simply gets refused again.
  Future<void> recheck() async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    try {
      AppUpgradeSignal.instance.clear();
      final result = await _resolve();
      state = AsyncData(result);
    } finally {
      _inFlight = false;
    }
  }

  Future<AppUpdateRequirement> _resolve() async {
    final refusal = AppUpgradeSignal.instance.refusal.value;
    if (refusal != null) {
      return _fromRefusal(refusal);
    }

    final AppBuildIdentity identity;
    try {
      identity = await ref.read(appBuildIdentityProvider.future);
    } catch (_) {
      // No readable build identity means nothing to compare. Carry on.
      return AppUpdateRequirement.none;
    }

    if (!identity.isGatable) {
      return AppUpdateRequirement.none;
    }

    return ref.read(appUpdateServiceProvider).fetchRequirement(
          platform: identity.platform,
          buildNumber: identity.buildNumber,
        );
  }

  AppUpdateRequirement _fromRefusal(AppUpgradeRefusal refusal) {
    return AppUpdateRequirement(
      updateRequired: true,
      updateAvailable: true,
      minimumBuild: refusal.minimumBuild,
      latestBuild: refusal.minimumBuild,
      downloadUrl: refusal.downloadUrl,
      message: refusal.message,
    );
  }
}

final appUpdateProvider =
    AsyncNotifierProvider<AppUpdateNotifier, AppUpdateRequirement>(
  AppUpdateNotifier.new,
);

/// True only when the server has positively said this build may not run.
///
/// Reads `valueOrNull` so that loading and error states both resolve to
/// "not blocked": the gate must be raised by a definite answer, never by the
/// absence of one.
final appUpdateBlockedProvider = Provider<bool>((ref) {
  return ref.watch(appUpdateProvider).valueOrNull?.updateRequired ?? false;
});
