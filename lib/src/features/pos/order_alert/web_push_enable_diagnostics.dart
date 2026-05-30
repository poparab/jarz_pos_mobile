class WebPushEnableDiagnostics {
  const WebPushEnableDiagnostics({
    required this.currentPath,
    required this.basePath,
    required this.serviceWorkerScope,
    required this.serviceWorkerUrl,
    required this.webPushEnabled,
    required this.firebaseOptionsReady,
    required this.firebaseInitialized,
    this.failingStep,
    this.permissionStatus,
    this.notificationSupported,
    this.serviceWorkerSupported,
    this.existingRegistrationScope,
    this.readyRegistrationScope,
    this.messagingLibraryAvailable,
    this.messagingResolved,
    this.tokenState,
    this.failureReason,
    this.errorSummary,
  });

  final String currentPath;
  final String basePath;
  final String serviceWorkerScope;
  final String serviceWorkerUrl;
  final bool webPushEnabled;
  final bool firebaseOptionsReady;
  final bool firebaseInitialized;
  final String? failingStep;
  final String? permissionStatus;
  final bool? notificationSupported;
  final bool? serviceWorkerSupported;
  final String? existingRegistrationScope;
  final String? readyRegistrationScope;
  final bool? messagingLibraryAvailable;
  final bool? messagingResolved;
  final String? tokenState;
  final String? failureReason;
  final String? errorSummary;

  WebPushEnableDiagnostics copyWith({
    String? currentPath,
    String? basePath,
    String? serviceWorkerScope,
    String? serviceWorkerUrl,
    bool? webPushEnabled,
    bool? firebaseOptionsReady,
    bool? firebaseInitialized,
    String? failingStep,
    String? permissionStatus,
    bool? notificationSupported,
    bool? serviceWorkerSupported,
    String? existingRegistrationScope,
    String? readyRegistrationScope,
    bool? messagingLibraryAvailable,
    bool? messagingResolved,
    String? tokenState,
    String? failureReason,
    String? errorSummary,
    bool clearExistingRegistrationScope = false,
    bool clearReadyRegistrationScope = false,
    bool clearFailureReason = false,
    bool clearErrorSummary = false,
  }) {
    return WebPushEnableDiagnostics(
      currentPath: currentPath ?? this.currentPath,
      basePath: basePath ?? this.basePath,
      serviceWorkerScope: serviceWorkerScope ?? this.serviceWorkerScope,
      serviceWorkerUrl: serviceWorkerUrl ?? this.serviceWorkerUrl,
      webPushEnabled: webPushEnabled ?? this.webPushEnabled,
      firebaseOptionsReady: firebaseOptionsReady ?? this.firebaseOptionsReady,
      firebaseInitialized: firebaseInitialized ?? this.firebaseInitialized,
      failingStep: failingStep ?? this.failingStep,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      notificationSupported: notificationSupported ?? this.notificationSupported,
      serviceWorkerSupported: serviceWorkerSupported ?? this.serviceWorkerSupported,
      existingRegistrationScope: clearExistingRegistrationScope
          ? null
          : (existingRegistrationScope ?? this.existingRegistrationScope),
      readyRegistrationScope: clearReadyRegistrationScope
          ? null
          : (readyRegistrationScope ?? this.readyRegistrationScope),
      messagingLibraryAvailable:
          messagingLibraryAvailable ?? this.messagingLibraryAvailable,
      messagingResolved: messagingResolved ?? this.messagingResolved,
      tokenState: tokenState ?? this.tokenState,
      failureReason: clearFailureReason ? null : (failureReason ?? this.failureReason),
      errorSummary: clearErrorSummary ? null : (errorSummary ?? this.errorSummary),
    );
  }

  String toCompactSummary() {
    final parts = <String>[
      'path $currentPath',
      'base $basePath',
      'step ${failingStep ?? 'complete'}',
      'permission ${permissionStatus ?? 'unknown'}',
      'firebase ${_boolState(firebaseInitialized)}/${_boolState(firebaseOptionsReady)}',
      'notify ${_boolState(notificationSupported)}',
      'sw ${_boolState(serviceWorkerSupported)}',
      'scope $serviceWorkerScope',
    ];

    if (existingRegistrationScope != null && existingRegistrationScope!.isNotEmpty) {
      parts.add('existing $existingRegistrationScope');
    }
    if (readyRegistrationScope != null && readyRegistrationScope!.isNotEmpty) {
      parts.add('ready $readyRegistrationScope');
    }

    parts.add('msg ${_boolState(messagingLibraryAvailable)}/${_boolState(messagingResolved)}');
    parts.add('token ${tokenState ?? 'unknown'}');

    if (failureReason != null && failureReason!.isNotEmpty) {
      parts.add('reason $failureReason');
    }
    if (errorSummary != null && errorSummary!.isNotEmpty) {
      parts.add(_shortError(errorSummary!));
    }

    return parts.join('; ');
  }

  String toUserMessage() {
    return 'Web push diagnostics: ${toCompactSummary()}.';
  }

  static String _boolState(bool? value) {
    if (value == null) {
      return 'unknown';
    }
    return value ? 'yes' : 'no';
  }

  static String _shortError(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.length <= 120) {
      return 'error $normalized';
    }
    return 'error ${normalized.substring(0, 117)}...';
  }
}