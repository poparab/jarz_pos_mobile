import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:jarz_pos/src/core/monitoring/sentry_service.dart';
import 'package:jarz_pos/src/features/about/data/about_release_info_repository.dart';
import 'package:jarz_pos/src/features/about/presentation/providers/about_release_info_provider.dart';

void main() {
  group('aboutReleaseInfoProvider', () {
    test('should resolve release info from the repository override', () async {
      // Arrange
      final repository = AboutReleaseInfoRepository(
        loadPackageInfo: () async => PackageInfo(
          appName: 'Jarz POS',
          packageName: 'com.orderjarz.pos',
          version: '1.2.3',
          buildNumber: '42',
        ),
        shorebirdStatusReader: const _FakeShorebirdStatusReader(
          ShorebirdDiagnostics(status: ShorebirdPatchStatus.restartRequired),
        ),
        platformLabelReader: () => 'Android',
        sentryConfigLoader: (appEnvironment) =>
            const SentryRuntimeConfig.disabled(environment: 'staging'),
      );
      final container = ProviderContainer(
        overrides: [
          aboutReleaseInfoRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final result = await container.read(aboutReleaseInfoProvider.future);

      // Assert
      expect(result.buildNumber, '42');
      expect(result.environment, 'staging');
      expect(result.shorebird.status, ShorebirdPatchStatus.restartRequired);
    });
  });
}

class _FakeShorebirdStatusReader implements ShorebirdStatusReader {
  const _FakeShorebirdStatusReader(this.result);

  final ShorebirdDiagnostics result;

  @override
  Future<ShorebirdDiagnostics> readStatus() async => result;
}
