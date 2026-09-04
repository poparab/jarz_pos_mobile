import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/session_expired_signal.dart';
import 'package:jarz_pos/src/core/router.dart';
import 'package:jarz_pos/src/features/auth/presentation/session_expired_gate.dart';
import 'package:jarz_pos/src/features/auth/state/login_notifier.dart';

/// Stands in for the real notifier, which would reach the network. It mimics
/// the only two things the gate depends on: the auth flag goes false and the
/// signal is consumed.
class _FakeLoginNotifier extends LoginNotifier {
  int logoutCalls = 0;

  @override
  Future<bool> build() async => false;

  @override
  Future<void> logout() async {
    logoutCalls++;
    ref.read(currentAuthStateProvider.notifier).state = false;
    SessionExpiredSignal.instance.clear();
  }
}

void main() {
  late _FakeLoginNotifier login;

  setUp(() {
    SessionExpiredSignal.instance.clear();
    login = _FakeLoginNotifier();
  });

  tearDown(SessionExpiredSignal.instance.clear);

  Future<ProviderContainer> pumpGate(
    WidgetTester tester, {
    required bool authenticated,
  }) async {
    final container = ProviderContainer(
      overrides: [
        // currentAuthStateProvider derives from this; overriding it keeps the
        // flag deterministic instead of running the real startup probe.
        authStateProvider.overrideWith((ref) => authenticated),
        loginNotifierProvider.overrideWith(() => login),
      ],
    );
    addTearDown(container.dispose);
    container.read(currentAuthStateProvider.notifier).state = authenticated;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SessionExpiredGate(child: Scaffold(body: Text('app'))),
        ),
      ),
    );
    return container;
  }

  testWidgets('signs the user out and says why when the session dies', (
    tester,
  ) async {
    final container = await pumpGate(tester, authenticated: true);

    SessionExpiredSignal.instance.report();
    await tester.pumpAndSettle();

    expect(login.logoutCalls, 1);
    expect(container.read(currentAuthStateProvider), isFalse);
    expect(
      find.text('Your session ended. Please sign in again.'),
      findsOneWidget,
    );
  });

  // The regression this whole change could have introduced. `endSession()`
  // kills the backend session at shift close on purpose and keeps the operator
  // on the closing summary; the next alert poll gets a Guest 403. If the gate
  // acted on it, the summary would vanish before anyone read it.
  testWidgets('stands down while the shift-end flow owns the flip', (
    tester,
  ) async {
    final container = await pumpGate(tester, authenticated: true);

    SessionExpiredSignal.instance.deferClientFlip();
    SessionExpiredSignal.instance.report();
    await tester.pumpAndSettle();

    expect(login.logoutCalls, 0);
    expect(container.read(currentAuthStateProvider), isTrue);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('consumes the signal silently when already signed out', (
    tester,
  ) async {
    // A 401 from the login form itself must not raise "your session ended".
    await pumpGate(tester, authenticated: false);

    SessionExpiredSignal.instance.report();
    await tester.pumpAndSettle();

    expect(login.logoutCalls, 0);
    expect(SessionExpiredSignal.instance.expired.value, isFalse);
    expect(
      find.text('Your session ended. Please sign in again.'),
      findsNothing,
    );
  });

  testWidgets('signs out only once for a signal that latches', (tester) async {
    await pumpGate(tester, authenticated: true);

    SessionExpiredSignal.instance.report();
    SessionExpiredSignal.instance.report();
    await tester.pumpAndSettle();

    expect(login.logoutCalls, 1);
  });

  testWidgets('honours a latch that was set before it mounted', (tester) async {
    // Cold start restoring a saved session the server had already dropped.
    SessionExpiredSignal.instance.report();

    final container = await pumpGate(tester, authenticated: true);
    await tester.pumpAndSettle();

    expect(login.logoutCalls, 1);
    expect(container.read(currentAuthStateProvider), isFalse);
  });
}
