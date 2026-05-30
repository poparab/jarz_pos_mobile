// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;

import '../../../core/monitoring/sentry_service.dart';
import 'web_push_paths.dart';

class WebPushReleaseDiagnostics {
  const WebPushReleaseDiagnostics({
    this.liveCommit,
    this.liveMainHash,
    this.currentRelease,
    this.errorMessage,
  });

  final String? liveCommit;
  final String? liveMainHash;
  final String? currentRelease;
  final String? errorMessage;

  static Future<WebPushReleaseDiagnostics> load({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final currentRelease = SentryService.instance.config.release.trim();
    try {
      final metadataUrl = '${buildWebAppAssetUrl(
        normalizeWebAppBasePath(Uri.base.path),
        'release-metadata.json',
      )}?ts=${DateTime.now().millisecondsSinceEpoch}';
      final response = await html.HttpRequest.request(
        metadataUrl,
        method: 'GET',
        requestHeaders: const {'Cache-Control': 'no-cache'},
      ).timeout(timeout);

      final body = (response.responseText ?? '').replaceFirst('\ufeff', '').trim();
      if (body.isEmpty) {
        return WebPushReleaseDiagnostics(
          currentRelease: currentRelease,
          errorMessage: 'live release metadata was empty',
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        return WebPushReleaseDiagnostics(
          currentRelease: currentRelease,
          errorMessage: 'live release metadata was not an object',
        );
      }

      return WebPushReleaseDiagnostics(
        liveCommit: decoded['commit_sha']?.toString(),
        liveMainHash: decoded['main_dart_js_sha256']?.toString(),
        currentRelease: currentRelease,
      );
    } catch (error) {
      return WebPushReleaseDiagnostics(
        currentRelease: currentRelease,
        errorMessage: error.toString(),
      );
    }
  }

  String toUserMessage() {
    final liveLabel = _short(liveCommit) ?? 'unknown';
    final hashLabel = _short(liveMainHash) ?? 'unknown';
    final currentLabel = _short(currentRelease);
    final currentPart = currentLabel == null ? '' : '; app release $currentLabel';
    final errorPart = errorMessage == null || errorMessage!.isEmpty
        ? ''
        : '; diagnostic error: $errorMessage';

    return 'Diagnostics: live web $liveLabel, bundle $hashLabel$currentPart$errorPart.';
  }

  static String? _short(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized.length <= 7 ? normalized : normalized.substring(0, 7);
  }
}