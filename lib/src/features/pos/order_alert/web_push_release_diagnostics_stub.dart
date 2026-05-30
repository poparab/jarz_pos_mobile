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

  static Future<WebPushReleaseDiagnostics> load() async {
    return const WebPushReleaseDiagnostics(
      errorMessage: 'Release diagnostics are only available in the web app.',
    );
  }

  String toUserMessage() {
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return 'Diagnostics: $errorMessage';
    }

    return 'Diagnostics unavailable on this platform.';
  }
}