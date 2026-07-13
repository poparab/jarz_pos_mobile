import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/about/data/about_release_info_repository.dart';
import 'package:jarz_pos/src/features/about/state/shorebird_update_provider.dart';

void main() {
  group('shorebirdUpdateProvider', () {
    test('proactively downloads a ready patch and reports restartRequired',
        () async {
      final gateway = _FakeShorebirdUpdateGateway(
        statuses: [
          ShorebirdPatchStatus.updateAvailable,
          ShorebirdPatchStatus.restartRequired,
        ],
        downloadResult: true,
      );
      final container = ProviderContainer(
        overrides: [
          shorebirdUpdateGatewayProvider.overrideWithValue(gateway),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(shorebirdUpdateProvider.future);

      expect(result, ShorebirdPatchStatus.restartRequired);
      expect(gateway.downloadCalls, 1);
      expect(gateway.readCalls, 2);
    });

    test('stays updateAvailable when the download fails', () async {
      final gateway = _FakeShorebirdUpdateGateway(
        statuses: [ShorebirdPatchStatus.updateAvailable],
        downloadResult: false,
      );
      final container = ProviderContainer(
        overrides: [
          shorebirdUpdateGatewayProvider.overrideWithValue(gateway),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(shorebirdUpdateProvider.future);

      expect(result, ShorebirdPatchStatus.updateAvailable);
      expect(gateway.downloadCalls, 1);
    });

    test('does not download when already up to date', () async {
      final gateway = _FakeShorebirdUpdateGateway(
        statuses: [ShorebirdPatchStatus.upToDate],
        downloadResult: true,
      );
      final container = ProviderContainer(
        overrides: [
          shorebirdUpdateGatewayProvider.overrideWithValue(gateway),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(shorebirdUpdateProvider.future);

      expect(result, ShorebirdPatchStatus.upToDate);
      expect(gateway.downloadCalls, 0);
    });

    test('recheckStatus re-resolves and downloads a newly available patch',
        () async {
      final gateway = _FakeShorebirdUpdateGateway(
        statuses: [
          // Initial build: nothing to do.
          ShorebirdPatchStatus.upToDate,
          // After resume: a patch appears, gets downloaded, then restartRequired.
          ShorebirdPatchStatus.updateAvailable,
          ShorebirdPatchStatus.restartRequired,
        ],
        downloadResult: true,
      );
      final container = ProviderContainer(
        overrides: [
          shorebirdUpdateGatewayProvider.overrideWithValue(gateway),
        ],
      );
      addTearDown(container.dispose);

      final initial = await container.read(shorebirdUpdateProvider.future);
      expect(initial, ShorebirdPatchStatus.upToDate);

      await container.read(shorebirdUpdateProvider.notifier).recheckStatus();
      final after = container.read(shorebirdUpdateProvider).valueOrNull;

      expect(after, ShorebirdPatchStatus.restartRequired);
      expect(gateway.downloadCalls, 1);
    });
  });
}

/// Scripts a sequence of [readStatus] results. When the script is exhausted the
/// last status is repeated, so callers only need to enumerate the transitions
/// they care about.
class _FakeShorebirdUpdateGateway implements ShorebirdUpdateGateway {
  _FakeShorebirdUpdateGateway({
    required List<ShorebirdPatchStatus> statuses,
    required this.downloadResult,
  }) : _statuses = List.of(statuses);

  final List<ShorebirdPatchStatus> _statuses;
  final bool downloadResult;

  int readCalls = 0;
  int downloadCalls = 0;

  @override
  Future<ShorebirdDiagnostics> readStatus() async {
    readCalls++;
    final status = _statuses.length <= 1
        ? (_statuses.isEmpty ? ShorebirdPatchStatus.unknown : _statuses.first)
        : _statuses.removeAt(0);
    return ShorebirdDiagnostics(status: status);
  }

  @override
  Future<bool> downloadUpdate() async {
    downloadCalls++;
    return downloadResult;
  }
}
