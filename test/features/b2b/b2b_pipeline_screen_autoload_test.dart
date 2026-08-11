// The B2B pipeline board must load without anyone pressing Refresh.
//
// The reported bug: `b2bPipelineProvider` is a keep-alive AsyncNotifier that
// nothing invalidates, so its `build()` ran exactly ONCE per app process.
// Whatever that first attempt produced was then frozen for the rest of the
// session — including an error from a cold start before the session cookie was
// attached, which is the path a B2B rep hits every time, since the router lands
// them on this board straight after login. The header Refresh button was the
// only way out.
//
// These tests pin the two halves of the fix: entering the screen re-fetches,
// and a board that failed to load recovers by itself on the next entry.
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/b2b/data/b2b_repository.dart';
import 'package:jarz_pos/src/features/b2b/data/models/b2b_models.dart';
import 'package:jarz_pos/src/features/b2b/presentation/screens/b2b_pipeline_screen.dart';
import 'package:jarz_pos/src/features/b2b/state/b2b_pipeline_notifier.dart';

const _payload = {
  'stages': ['Lead', 'Qualify', 'Sample'],
  'columns': {
    'Lead': [
      {
        'doctype': 'Lead',
        'name': 'LEAD-001',
        'title': 'Acme Co',
        'stage': 'Lead',
      },
    ],
  },
};

class _FakeB2bRepository extends B2bRepository {
  _FakeB2bRepository() : super(Dio());

  int pipelineCalls = 0;
  bool shouldThrow = false;

  @override
  Future<B2bPipeline> getPipeline() async {
    pipelineCalls++;
    if (shouldThrow) throw Exception('session not ready');
    return B2bPipeline.fromJson(Map<String, dynamic>.from(_payload));
  }
}

/// A minimal B2B rep. Roles only decide whether the mode-switch menu shows.
const _roles = UserRoles(user: 'rep@x.com', roles: ['B2B Sales Rep']);

/// The cards read l10n, so the shell must supply the delegates.
Widget _app([Widget home = const B2bPipelineScreen()]) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

Widget _wrap(_FakeB2bRepository repo) {
  return ProviderScope(
    overrides: [
      b2bRepositoryProvider.overrideWithValue(repo),
      // The screen reads roles only to decide whether to show the mode switch.
      userRolesFutureProvider.overrideWith((ref) async => _roles),
    ],
    child: _app(),
  );
}

void main() {
  group('B2B pipeline auto-load', () {
    testWidgets('fetches on entry without anyone pressing Refresh',
        (tester) async {
      final repo = _FakeB2bRepository();
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(repo.pipelineCalls, greaterThan(0),
          reason: 'the board must load itself when the screen opens');
      expect(find.text('Acme Co'), findsOneWidget);
    });

    testWidgets('a board that failed to load recovers on the next entry',
        (tester) async {
      // Reproduces the cold-start failure, then proves that simply coming back
      // to the screen fixes it — which is what used to require the button.
      final repo = _FakeB2bRepository()..shouldThrow = true;
      final container = ProviderContainer(
        overrides: [
          b2bRepositoryProvider.overrideWithValue(repo),
          userRolesFutureProvider.overrideWith((ref) async => _roles),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(b2bPipelineProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(b2bPipelineProvider).hasError, isTrue);

      // The condition clears (session attached, network back) and the rep
      // opens the board again.
      repo.shouldThrow = false;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _app(),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(b2bPipelineProvider).hasError, isFalse);
      expect(find.text('Acme Co'), findsOneWidget);
    });

    testWidgets('re-entering re-fetches rather than showing a frozen board',
        (tester) async {
      final repo = _FakeB2bRepository();
      final container = ProviderContainer(
        overrides: [
          b2bRepositoryProvider.overrideWithValue(repo),
          userRolesFutureProvider.overrideWith((ref) async => _roles),
        ],
      );
      addTearDown(container.dispose);

      Widget app() => UncontrolledProviderScope(
            container: container,
            child: _app(),
          );

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final afterFirst = repo.pipelineCalls;

      // Leave, then come back.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _app(const SizedBox.shrink()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(repo.pipelineCalls, greaterThan(afterFirst),
          reason: 're-entering the board must revalidate it');
    });
  });
}
