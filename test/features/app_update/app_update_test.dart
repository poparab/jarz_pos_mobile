// ignore_for_file: overridden_fields

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/env/app_build_identity.dart';
import 'package:jarz_pos/src/core/network/app_upgrade_signal.dart';
import 'package:jarz_pos/src/core/network/dio_provider.dart';
import 'package:jarz_pos/src/features/app_update/data/app_update_service.dart';
import 'package:jarz_pos/src/features/app_update/presentation/app_update_gate.dart';
import 'package:jarz_pos/src/features/app_update/state/app_update_provider.dart';

/// Minimal Dio stand-in: the update check only ever issues a GET.
class _FakeDio with DioMixin implements Dio {
  _FakeDio();

  Response? nextResponse;
  DioException? nextError;
  Map<String, dynamic>? lastQuery;

  @override
  BaseOptions options = BaseOptions();

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    lastQuery = queryParameters;
    if (nextError != null) {
      throw nextError!;
    }
    return nextResponse! as Response<T>;
  }
}

Response<dynamic> _ok(Map<String, dynamic> message) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: <String, dynamic>{'message': message},
  );
}

/// A build identity the tests control, so nothing touches PackageInfo.
AppBuildIdentityLoader _identity({
  String platform = 'android',
  int? buildNumber = 1000,
}) {
  return () async => AppBuildIdentity(
        platform: platform,
        buildNumber: buildNumber,
        version: '1.0.0+${buildNumber ?? 0}',
      );
}

ProviderContainer _container({
  required _FakeDio dio,
  AppBuildIdentityLoader? identity,
}) {
  final container = ProviderContainer(
    overrides: [
      dioProvider.overrideWithValue(dio),
      appBuildIdentityLoaderProvider.overrideWithValue(
        identity ?? _identity(),
      ),
      // No background poll: a pending periodic timer outlives the widget tree
      // and trips flutter_test's invariant check. Launch and resume are what
      // these tests exercise anyway.
      appUpdatePollIntervalProvider.overrideWithValue(null),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  setUp(() => AppUpgradeSignal.instance.clear());
  tearDown(() => AppUpgradeSignal.instance.clear());

  group('AppUpdateRequirement.fromJson', () {
    test('reads the server verdict', () {
      final requirement = AppUpdateRequirement.fromJson(const {
        'update_required': true,
        'update_available': true,
        'minimum_build': 1200,
        'latest_build': 1300,
        'download_url': 'https://erp.example.com/pos/download/',
        'message': 'Install the new build.',
      });

      expect(requirement.updateRequired, isTrue);
      expect(requirement.minimumBuild, 1200);
      expect(requirement.latestBuild, 1300);
      expect(requirement.downloadUrl, 'https://erp.example.com/pos/download/');
    });

    test('a missing or malformed field never reads as blocked', () {
      final requirement = AppUpdateRequirement.fromJson(const {
        'minimum_build': 'not-a-number',
      });

      expect(requirement.updateRequired, isFalse);
      expect(requirement.minimumBuild, 0);
      expect(requirement.downloadUrl, isEmpty);
    });
  });

  group('AppBuildIdentity', () {
    test('only Android with a readable build is gatable', () {
      expect(
        const AppBuildIdentity(
          platform: 'android',
          buildNumber: 12,
          version: '1.0.0+12',
        ).isGatable,
        isTrue,
      );
      expect(
        const AppBuildIdentity(
          platform: 'web',
          buildNumber: 12,
          version: '1.0.0+12',
        ).isGatable,
        isFalse,
      );
      expect(
        const AppBuildIdentity(
          platform: 'android',
          buildNumber: null,
          version: '1.0.0',
        ).isGatable,
        isFalse,
      );
    });
  });

  group('AppUpdateService', () {
    test('sends the platform and build the server gates on', () async {
      final dio = _FakeDio()..nextResponse = _ok(const {'update_required': false});

      await AppUpdateService(dio)
          .fetchRequirement(platform: 'android', buildNumber: 1000);

      expect(dio.lastQuery?['platform'], 'android');
      expect(dio.lastQuery?['build_number'], '1000');
    });

    test('a network failure degrades to "carry on", not "locked out"', () async {
      final dio = _FakeDio()
        ..nextError = DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionError,
        );

      final requirement = await AppUpdateService(dio)
          .fetchRequirement(platform: 'android', buildNumber: 1000);

      expect(requirement.updateRequired, isFalse);
    });

    test('a non-JSON body degrades the same way', () async {
      final dio = _FakeDio()
        ..nextResponse = Response<dynamic>(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 200,
          data: '<html>proxy error</html>',
        );

      final requirement = await AppUpdateService(dio)
          .fetchRequirement(platform: 'android', buildNumber: 1000);

      expect(requirement.updateRequired, isFalse);
    });
  });

  group('readUpgradeRefusal', () {
    test('pulls the refusal details out of a 426 body', () {
      final refusal = readUpgradeRefusal(const {
        'minimum_build': 1200,
        'download_url': 'https://erp.example.com/pos/download/',
        'message': 'Too old.',
      });

      expect(refusal.minimumBuild, 1200);
      expect(refusal.downloadUrl, 'https://erp.example.com/pos/download/');
      expect(refusal.message, 'Too old.');
    });

    test('survives a proxy replacing the body with HTML', () {
      final refusal = readUpgradeRefusal('<html>502</html>');

      expect(refusal.minimumBuild, 0);
      expect(refusal.downloadUrl, isEmpty);
    });
  });

  group('appUpdateBlockedProvider', () {
    test('blocks when the server says the build is below the floor', () async {
      final dio = _FakeDio()
        ..nextResponse = _ok(const {
          'update_required': true,
          'minimum_build': 1200,
          'download_url': 'https://erp.example.com/pos/download/',
        });
      final container = _container(dio: dio);

      await container.read(appUpdateProvider.future);

      expect(container.read(appUpdateBlockedProvider), isTrue);
    });

    test('does not block while the answer is still in flight', () {
      final dio = _FakeDio()..nextResponse = _ok(const {'update_required': true});
      final container = _container(dio: dio);

      // Read before awaiting: the barrier must go up on a definite "no",
      // never on the absence of an answer.
      expect(container.read(appUpdateBlockedProvider), isFalse);
    });

    test('never calls the server on a platform with no APK to install', () async {
      final dio = _FakeDio();
      final container = _container(
        dio: dio,
        identity: _identity(platform: 'web'),
      );

      final requirement = await container.read(appUpdateProvider.future);

      expect(requirement.updateRequired, isFalse);
      expect(dio.lastQuery, isNull);
    });

    test('a 426 seen on any request raises the gate', () async {
      final dio = _FakeDio()..nextResponse = _ok(const {'update_required': false});
      final container = _container(dio: dio);
      await container.read(appUpdateProvider.future);
      expect(container.read(appUpdateBlockedProvider), isFalse);

      AppUpgradeSignal.instance.report(
        const AppUpgradeRefusal(
          minimumBuild: 1200,
          downloadUrl: 'https://erp.example.com/pos/download/',
          message: 'Too old.',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(container.read(appUpdateBlockedProvider), isTrue);
    });

    test('a re-check clears a latched 426 and re-asks the server', () async {
      final dio = _FakeDio()..nextResponse = _ok(const {'update_required': false});
      final container = _container(dio: dio);
      await container.read(appUpdateProvider.future);

      AppUpgradeSignal.instance.report(
        const AppUpgradeRefusal(
          minimumBuild: 1200,
          downloadUrl: '',
          message: '',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(container.read(appUpdateBlockedProvider), isTrue);

      // An admin lowers the floor again; the device must recover without a
      // reinstall.
      dio.nextResponse = _ok(const {'update_required': false});
      await container.read(appUpdateProvider.notifier).recheck();

      expect(container.read(appUpdateBlockedProvider), isFalse);
    });
  });

  group('AppUpdateGate', () {
    Widget wrap(ProviderContainer container, Widget child) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppUpdateGate(child: child),
        ),
      );
    }

    testWidgets('renders the app untouched when the build is allowed',
        (tester) async {
      final dio = _FakeDio()..nextResponse = _ok(const {'update_required': false});
      final container = _container(dio: dio);
      await container.read(appUpdateProvider.future);

      await tester.pumpWidget(
        wrap(container, const Scaffold(body: Text('POS'))),
      );
      await tester.pump();

      expect(find.text('POS'), findsOneWidget);
    });

    testWidgets('replaces the app with a blocking screen when refused',
        (tester) async {
      final dio = _FakeDio()
        ..nextResponse = _ok(const {
          'update_required': true,
          'minimum_build': 1200,
          'download_url': 'https://erp.example.com/pos/download/',
        });
      final container = _container(dio: dio);
      await container.read(appUpdateProvider.future);

      await tester.pumpWidget(
        wrap(container, const Scaffold(body: Text('POS'))),
      );
      await tester.pump();

      expect(find.text('POS'), findsNothing);
      expect(find.text('Update Required'), findsOneWidget);
      expect(find.text('Download Update'), findsOneWidget);
    });

    testWidgets('shows the installed and required build numbers',
        (tester) async {
      final dio = _FakeDio()
        ..nextResponse = _ok(const {
          'update_required': true,
          'minimum_build': 1200,
        });
      final container = _container(dio: dio);
      await container.read(appUpdateProvider.future);
      await container.read(appBuildIdentityProvider.future);

      await tester.pumpWidget(
        wrap(container, const Scaffold(body: Text('POS'))),
      );
      await tester.pump();

      expect(
        find.textContaining('1000'),
        findsOneWidget,
        reason: 'the installed build must be readable off the screen',
      );
      expect(find.textContaining('1200'), findsOneWidget);
    });

    testWidgets('the back button cannot dismiss the blocking screen',
        (tester) async {
      final dio = _FakeDio()
        ..nextResponse = _ok(const {'update_required': true, 'minimum_build': 1200});
      final container = _container(dio: dio);
      await container.read(appUpdateProvider.future);

      await tester.pumpWidget(
        wrap(container, const Scaffold(body: Text('POS'))),
      );
      await tester.pump();

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);
    });

    testWidgets('a message from settings replaces the generic text',
        (tester) async {
      final dio = _FakeDio()
        ..nextResponse = _ok(const {
          'update_required': true,
          'minimum_build': 1200,
          'message': 'Shift close changed - install build 1200.',
        });
      final container = _container(dio: dio);
      await container.read(appUpdateProvider.future);

      await tester.pumpWidget(
        wrap(container, const Scaffold(body: Text('POS'))),
      );
      await tester.pump();

      expect(
        find.text('Shift close changed - install build 1200.'),
        findsOneWidget,
      );
    });
  });
}
