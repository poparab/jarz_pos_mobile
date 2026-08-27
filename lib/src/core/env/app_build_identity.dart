import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Who this build is, in the two terms the server gates on.
///
/// [buildNumber] is the revision count CI stamps into every APK
/// (`tool/release_metadata.dart`), so it increases monotonically across
/// releases and compares as a plain integer. A locally-run debug build falls
/// back to pubspec's `+1`, which is why [isGatable] also insists on a release
/// platform: a developer's laptop build must never be blocked.
@immutable
class AppBuildIdentity {
  const AppBuildIdentity({
    required this.platform,
    required this.buildNumber,
    required this.version,
  });

  /// Lowercase platform token the server matches on: `android`, `ios`, `web`.
  final String platform;

  /// Parsed build number, or `null` when it is not a usable integer.
  final int? buildNumber;

  /// Human-readable `1.0.0+1234`, reported to the device registry.
  final String version;

  /// Whether this build can meaningfully be compared against a floor.
  ///
  /// Only Android is installed by hand from an APK, so only Android can be
  /// stale in a way an update screen can fix. Web is whatever the server just
  /// served, and iOS goes through the courier web build.
  bool get isGatable => platform == 'android' && buildNumber != null;

  static AppBuildIdentity fromPackageInfo(PackageInfo info) {
    return AppBuildIdentity(
      platform: currentPlatformToken(),
      buildNumber: int.tryParse(info.buildNumber.trim()),
      version: '${info.version}+${info.buildNumber}',
    );
  }

  static String currentPlatformToken() {
    if (kIsWeb) {
      return 'web';
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.linux => 'linux',
      TargetPlatform.windows => 'windows',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }
}

typedef AppBuildIdentityLoader = Future<AppBuildIdentity> Function();

Future<AppBuildIdentity> loadAppBuildIdentity() async {
  final info = await PackageInfo.fromPlatform();
  return AppBuildIdentity.fromPackageInfo(info);
}
