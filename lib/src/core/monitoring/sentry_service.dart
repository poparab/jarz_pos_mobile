import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryRuntimeConfig {
  const SentryRuntimeConfig({
    required this.dsn,
    required this.environment,
    required this.release,
    required this.dist,
    required this.tracesSampleRate,
    required this.profilesSampleRate,
  });

  const SentryRuntimeConfig.disabled({String environment = 'local'})
    : this(
        dsn: '',
        environment: environment,
        release: '',
        dist: '',
        tracesSampleRate: 0,
        profilesSampleRate: 0,
      );

  final String dsn;
  final String environment;
  final String release;
  final String dist;
  final double tracesSampleRate;
  final double profilesSampleRate;

  bool get isEnabled => dsn.trim().isNotEmpty;

  static SentryRuntimeConfig fromEnvironment({required String appEnvironment}) {
    final normalizedEnvironment = _normalizeEnvironment(
      _readValue('SENTRY_ENVIRONMENT') ?? appEnvironment,
    );

    return SentryRuntimeConfig(
      dsn: (_readValue('SENTRY_DSN') ?? '').trim(),
      environment: normalizedEnvironment,
      release: (_readValue('SENTRY_RELEASE') ?? '').trim(),
      dist: (_readValue('SENTRY_DIST') ?? '').trim(),
      tracesSampleRate: _readDouble('SENTRY_TRACES_SAMPLE_RATE'),
      profilesSampleRate: _readDouble('SENTRY_PROFILES_SAMPLE_RATE'),
    );
  }

  static String? _readValue(String key) {
    final compileTimeValue = switch (key) {
      'SENTRY_DSN' => const String.fromEnvironment('SENTRY_DSN'),
      'SENTRY_ENVIRONMENT' => const String.fromEnvironment('SENTRY_ENVIRONMENT'),
      'SENTRY_RELEASE' => const String.fromEnvironment('SENTRY_RELEASE'),
      'SENTRY_DIST' => const String.fromEnvironment('SENTRY_DIST'),
      'SENTRY_TRACES_SAMPLE_RATE' => const String.fromEnvironment(
        'SENTRY_TRACES_SAMPLE_RATE',
      ),
      'SENTRY_PROFILES_SAMPLE_RATE' => const String.fromEnvironment(
        'SENTRY_PROFILES_SAMPLE_RATE',
      ),
      _ => '',
    }.trim();

    if (compileTimeValue.isNotEmpty) {
      return compileTimeValue;
    }

    return dotenv.maybeGet(key)?.trim();
  }

  static double _readDouble(String key) {
    final rawValue = _readValue(key);
    if (rawValue == null || rawValue.isEmpty) {
      return 0;
    }

    return double.tryParse(rawValue) ?? 0;
  }

  static String _normalizeEnvironment(String rawValue) {
    switch (rawValue.trim().toLowerCase()) {
      case 'prod':
      case 'production':
        return 'production';
      case 'staging':
      case 'testing':
      case 'test':
        return 'staging';
      case 'local':
        return 'local';
      default:
        return rawValue.trim().isEmpty ? 'local' : rawValue.trim();
    }
  }
}

/// Decides which events are expected, non-actionable noise.
///
/// The client polls a Frappe backend from phones that are frequently offline or
/// on flaky mobile data. Those failures are a normal operating condition, not
/// bugs: reporting them burns the Sentry quota and buries real crashes. Genuine
/// server faults (any `badResponse`, i.e. a 4xx/5xx the server actually
/// returned) are always kept.
class SentryNoiseFilter {
  const SentryNoiseFilter._();

  /// Dio failures that mean "the network/server was unreachable", never "the
  /// app or the backend is broken".
  static const Set<DioExceptionType> _transportFailureTypes =
      <DioExceptionType>{
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      };

  /// Connectivity signatures that surface as plain messages/exceptions rather
  /// than a typed [DioException] (dart:io, dart:html, and our own wrappers).
  static const List<String> _noiseMessageFragments = <String>[
    'failed host lookup',
    'socketexception',
    'xmlhttprequest error',
    'cannot reach server',
    // A user mistyping their password is not an application error.
    'invalid credentials',
  ];

  /// Returns true when [event] should not be sent to Sentry.
  static bool isNoise(SentryEvent event) {
    final throwable = event.throwable;

    if (throwable is DioException) {
      // A real server response is always actionable, even a 4xx.
      if (throwable.type == DioExceptionType.badResponse) {
        return false;
      }
      if (_transportFailureTypes.contains(throwable.type)) {
        return true;
      }
    }

    return _containsNoiseFragment(_eventText(event));
  }

  /// Collects the places a connectivity signature can hide.
  static String _eventText(SentryEvent event) {
    final buffer = StringBuffer()..write(event.throwable?.toString() ?? '');

    final message = event.message;
    if (message != null) {
      buffer
        ..write(' ')
        ..write(message.formatted);
    }

    for (final exception in event.exceptions ?? const <SentryException>[]) {
      buffer
        ..write(' ')
        ..write(exception.type ?? '')
        ..write(' ')
        ..write(exception.value ?? '');
    }

    return buffer.toString().toLowerCase();
  }

  static bool _containsNoiseFragment(String text) {
    if (text.isEmpty) {
      return false;
    }
    for (final fragment in _noiseMessageFragments) {
      if (text.contains(fragment)) {
        return true;
      }
    }
    return false;
  }
}

class SentryService {
  SentryService._();

  static final SentryService instance = SentryService._();

  SentryRuntimeConfig _config = const SentryRuntimeConfig.disabled();
  bool _initialized = false;

  SentryRuntimeConfig get config => _config;
  bool get isEnabled => _initialized && _config.isEnabled;

  Future<void> initialize({
    required SentryRuntimeConfig config,
    required Future<void> Function() appRunner,
  }) async {
    _config = config;

    if (!config.isEnabled) {
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = config.dsn;
        options.environment = config.environment;
        if (config.release.isNotEmpty) {
          options.release = config.release;
        }
        if (config.dist.isNotEmpty) {
          options.dist = config.dist;
        }
        options.sendDefaultPii = false;
        options.tracesSampleRate = config.tracesSampleRate;
        options.profilesSampleRate = config.profilesSampleRate;
        // Drop expected offline/connectivity noise before it leaves the device.
        options.beforeSend = (event, hint) =>
            SentryNoiseFilter.isNoise(event) ? null : event;
      },
      appRunner: () async {
        _initialized = true;
        await appRunner();
      },
    );
  }

  Future<void> captureException({
    required String source,
    required Object error,
    StackTrace? stackTrace,
    String? summary,
    Map<String, Object?> details = const <String, Object?>{},
    bool fatal = false,
  }) async {
    if (!isEnabled) {
      return;
    }

    final safeStackTrace = stackTrace ?? StackTrace.current;
    await Sentry.captureException(
      error,
      stackTrace: safeStackTrace,
      withScope: (scope) {
        _applyScope(
          scope,
          source: source,
          summary: summary,
          details: details,
          fatal: fatal,
        );
      },
    );
  }

  Future<void> captureMessage({
    required String source,
    required String message,
    String? summary,
    StackTrace? stackTrace,
    Map<String, Object?> details = const <String, Object?>{},
    bool fatal = false,
  }) async {
    if (!isEnabled) {
      return;
    }

    await Sentry.captureMessage(
      message,
      level: fatal ? SentryLevel.fatal : SentryLevel.error,
      withScope: (scope) {
        _applyScope(
          scope,
          source: source,
          summary: summary,
          details: details,
          fatal: fatal,
        );
        if (stackTrace != null) {
          scope.setContexts('jarz_stack_trace', <String, Object?>{
            'value': stackTrace.toString(),
          });
        }
      },
    );
  }

  void addHttpBreadcrumb({
    required String method,
    required String path,
    int? statusCode,
    String? category,
    bool failed = false,
  }) {
    if (!isEnabled) {
      return;
    }

    Sentry.addBreadcrumb(
      Breadcrumb(
        type: 'http',
        category: category ?? 'http.client',
        level: failed ? SentryLevel.error : SentryLevel.info,
        message: '$method $path',
        data: <String, Object?>{
          'method': method,
          'path': path,
          if (statusCode != null) 'status_code': statusCode,
        },
      ),
    );
  }

  void _applyScope(
    Scope scope, {
    required String source,
    String? summary,
    required Map<String, Object?> details,
    required bool fatal,
  }) {
    scope.level = fatal ? SentryLevel.fatal : SentryLevel.error;
    scope.setTag('source', source);
    scope.setTag('environment', _config.environment);
    if (summary != null && summary.trim().isNotEmpty) {
      scope.setContexts('jarz_summary', <String, Object?>{'value': summary.trim()});
    }
    if (details.isNotEmpty) {
      scope.setContexts('jarz_error', details);
    }
  }
}