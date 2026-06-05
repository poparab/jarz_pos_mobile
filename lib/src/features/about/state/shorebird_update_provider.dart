import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/about_release_info_repository.dart';

class ShorebirdUpdateNotifier extends AsyncNotifier<ShorebirdPatchStatus> {
  @override
  Future<ShorebirdPatchStatus> build() async {
    final diagnostics = await const DefaultShorebirdStatusReader().readStatus();
    return diagnostics.status;
  }

  Future<void> recheckStatus() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final diagnostics = await const DefaultShorebirdStatusReader().readStatus();
      return diagnostics.status;
    });
  }
}

final shorebirdUpdateProvider =
    AsyncNotifierProvider<ShorebirdUpdateNotifier, ShorebirdPatchStatus>(
  ShorebirdUpdateNotifier.new,
);
