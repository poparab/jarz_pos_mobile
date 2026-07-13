import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/about_release_info_repository.dart';

/// Injectable gateway so the notifier can be driven in tests without a device.
final shorebirdUpdateGatewayProvider = Provider<ShorebirdUpdateGateway>(
  (ref) => const DefaultShorebirdUpdateGateway(),
);

class ShorebirdUpdateNotifier extends AsyncNotifier<ShorebirdPatchStatus> {
  // Guards against overlapping downloads when a resume-triggered recheck races
  // the initial build.
  bool _downloading = false;

  ShorebirdUpdateGateway get _gateway =>
      ref.read(shorebirdUpdateGatewayProvider);

  @override
  Future<ShorebirdPatchStatus> build() => _resolveStatus();

  Future<void> recheckStatus() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_resolveStatus);
  }

  /// Reads the current patch status and, when a patch is available but not yet
  /// downloaded ([ShorebirdPatchStatus.updateAvailable]), pulls it immediately
  /// so the app surfaces "restart to apply" without waiting for the next
  /// launch. A POS device kept open all day would otherwise never download the
  /// patch (Shorebird's background fetch runs on launch), leaving it stale.
  Future<ShorebirdPatchStatus> _resolveStatus() async {
    final diagnostics = await _gateway.readStatus();
    if (diagnostics.status != ShorebirdPatchStatus.updateAvailable ||
        _downloading) {
      return diagnostics.status;
    }

    _downloading = true;
    try {
      final downloaded = await _gateway.downloadUpdate();
      if (!downloaded) {
        return diagnostics.status;
      }
      final afterDownload = await _gateway.readStatus();
      return afterDownload.status;
    } finally {
      _downloading = false;
    }
  }
}

final shorebirdUpdateProvider =
    AsyncNotifierProvider<ShorebirdUpdateNotifier, ShorebirdPatchStatus>(
  ShorebirdUpdateNotifier.new,
);
