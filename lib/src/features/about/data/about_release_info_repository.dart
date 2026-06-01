import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import '../../../core/env/env.dart';
import '../../../core/monitoring/sentry_service.dart';

typedef PackageInfoLoader = Future<PackageInfo> Function();
typedef CurrentHostReader = String Function();
typedef NowProvider = DateTime Function();
typedef PlatformLabelReader = String Function();
typedef SentryConfigLoader =
    SentryRuntimeConfig Function(String appEnvironment);

class AboutReleaseInfoRepository {
  AboutReleaseInfoRepository({
    PackageInfoLoader? loadPackageInfo,
    ShorebirdStatusReader? shorebirdStatusReader,
    CurrentHostReader? currentHostReader,
    NowProvider? now,
    PlatformLabelReader? platformLabelReader,
    SentryConfigLoader? sentryConfigLoader,
  }) : _loadPackageInfo = loadPackageInfo ?? (() => PackageInfo.fromPlatform()),
       _shorebirdStatusReader =
           shorebirdStatusReader ?? DefaultShorebirdStatusReader(),
       _currentHostReader = currentHostReader ?? _defaultCurrentHostReader,
       _now = now ?? DateTime.now,
       _platformLabelReader = platformLabelReader ?? readAboutPlatformLabel,
       _sentryConfigLoader =
           sentryConfigLoader ??
           ((appEnvironment) => SentryRuntimeConfig.fromEnvironment(
             appEnvironment: appEnvironment,
           ));

  final PackageInfoLoader _loadPackageInfo;
  final ShorebirdStatusReader _shorebirdStatusReader;
  final CurrentHostReader _currentHostReader;
  final NowProvider _now;
  final PlatformLabelReader _platformLabelReader;
  final SentryConfigLoader _sentryConfigLoader;

  Future<AboutReleaseInfo> fetchReleaseInfo() async {
    final packageInfo = await _loadPackageInfo();
    final appEnvironment = resolveEnvName(currentHost: _currentHostReader());
    final sentryConfig = _sentryConfigLoader(appEnvironment);
    final shorebirdDiagnostics = await _shorebirdStatusReader.readStatus();

    return AboutReleaseInfo(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      buildName: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      platformLabel: _platformLabelReader(),
      environment: sentryConfig.environment,
      releaseId: sentryConfig.release,
      releaseDist: sentryConfig.dist,
      shorebird: shorebirdDiagnostics,
      lastCheckedAt: _now(),
    );
  }

  static String _defaultCurrentHostReader() => Uri.base.host;
}

class AboutReleaseInfo {
  const AboutReleaseInfo({
    required this.appName,
    required this.packageName,
    required this.buildName,
    required this.buildNumber,
    required this.platformLabel,
    required this.environment,
    required this.releaseId,
    required this.releaseDist,
    required this.shorebird,
    required this.lastCheckedAt,
  });

  final String appName;
  final String packageName;
  final String buildName;
  final String buildNumber;
  final String platformLabel;
  final String environment;
  final String releaseId;
  final String releaseDist;
  final ShorebirdDiagnostics shorebird;
  final DateTime lastCheckedAt;
}

enum ShorebirdPatchStatus {
  upToDate,
  updateAvailable,
  restartRequired,
  unavailable,
  unknown,
}

class ShorebirdDiagnostics {
  const ShorebirdDiagnostics({
    required this.status,
    this.currentPatchNumber,
    this.nextPatchNumber,
    this.errorMessage,
  });

  final ShorebirdPatchStatus status;
  final int? currentPatchNumber;
  final int? nextPatchNumber;
  final String? errorMessage;
}

abstract class ShorebirdStatusReader {
  Future<ShorebirdDiagnostics> readStatus();
}

class DefaultShorebirdStatusReader implements ShorebirdStatusReader {
  const DefaultShorebirdStatusReader();

  @override
  Future<ShorebirdDiagnostics> readStatus() async {
    if (!_supportsShorebird()) {
      return const ShorebirdDiagnostics(
        status: ShorebirdPatchStatus.unavailable,
      );
    }

    final codePush = ShorebirdCodePush();
    if (!codePush.isShorebirdAvailable()) {
      // The app was not built with `shorebird release` (no Shorebird engine is
      // embedded), so there is no updater to query. Report this as unavailable
      // instead of letting the queries below throw and surface as "unknown".
      return const ShorebirdDiagnostics(
        status: ShorebirdPatchStatus.unavailable,
      );
    }

    try {
      final currentPatchNumber = await codePush.currentPatchNumber();
      final nextPatchNumber = await codePush.nextPatchNumber();
      final restartRequired = await codePush.isNewPatchReadyToInstall();
      final updateAvailable = restartRequired
          ? false
          : await codePush.isNewPatchAvailableForDownload();

      return ShorebirdDiagnostics(
        status: restartRequired
            ? ShorebirdPatchStatus.restartRequired
            : updateAvailable
            ? ShorebirdPatchStatus.updateAvailable
            : ShorebirdPatchStatus.upToDate,
        currentPatchNumber: currentPatchNumber,
        nextPatchNumber: nextPatchNumber,
      );
    } catch (error) {
      return ShorebirdDiagnostics(
        status: ShorebirdPatchStatus.unknown,
        errorMessage: error.toString(),
      );
    }
  }

  bool _supportsShorebird() {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }
}

String readAboutPlatformLabel() {
  if (kIsWeb) {
    return 'Web';
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'Android',
    TargetPlatform.iOS => 'iOS',
    TargetPlatform.macOS => 'macOS',
    TargetPlatform.linux => 'Linux',
    TargetPlatform.windows => 'Windows',
    TargetPlatform.fuchsia => 'Fuchsia',
  };
}
