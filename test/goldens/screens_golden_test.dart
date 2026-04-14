// Golden tests — visual regression snapshots.
//
// Run to GENERATE baselines (first time or after intentional UI changes):
//   flutter test --update-goldens test/goldens/
//
// Run to VERIFY against existing baselines (CI / normal test run):
//   flutter test test/goldens/
//
// Baselines (.png files under test/goldens/goldens/) are committed to git.
// A golden mismatch means the UI changed unexpectedly — review the diff
// before running --update-goldens.
//
// All screens are rendered at a fixed 800×1280 viewport (tablet) so the
// baseline is identical on every machine regardless of display density.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/router.dart';
import 'package:jarz_pos/src/features/auth/data/auth_repository.dart';
import 'package:jarz_pos/src/features/auth/presentation/login_screen.dart';
import 'package:jarz_pos/src/features/auth/state/login_notifier.dart';
import 'package:jarz_pos/src/features/pos/presentation/screens/pos_home_screen.dart';

import '../helpers/mock_services.dart';
import '../helpers/test_helpers.dart';

// ── Shared helpers ────────────────────────────────────────────────────────────

/// Pump a [child] widget inside a full [MaterialApp] with localization support
/// and a fixed 800×1280 logical-pixel viewport.
Future<void> pumpGoldenWidget(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
}) async {
  // Lock the surface to a deterministic tablet size.
  tester.view.physicalSize = const Size(800, 1280);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
  // Settle async providers and animations.
  await tester.pumpAndSettle();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  // ── Login Screen ─────────────────────────────────────────────────────

  testWidgets('golden: LoginScreen — initial idle state', (tester) async {
    await pumpGoldenWidget(
      tester,
      const LoginScreen(),
      overrides: [
        // Override auth repo with a fake that never completes — we only want
        // the idle (non-loading) initial render.
        authRepositoryProvider.overrideWith(
          (ref) => FakeIdleAuthRepository(),
        ),
        currentAuthStateProvider.overrideWith((ref) => false),
      ],
    );

    await expectLater(
      find.byType(LoginScreen),
      matchesGoldenFile('goldens/login_screen_idle.png'),
    );
  });

  // ── POS Home Screen ───────────────────────────────────────────────────

  testWidgets('golden: PosHomeScreen — home menu', (tester) async {
    await pumpGoldenWidget(
      tester,
      const PosHomeScreen(),
    );

    await expectLater(
      find.byType(PosHomeScreen),
      matchesGoldenFile('goldens/pos_home_screen.png'),
    );
  });
}

// ── Fakes ─────────────────────────────────────────────────────────────────────

class FakeIdleAuthRepository extends AuthRepository {
  FakeIdleAuthRepository() : super(createMockDio(), MockSessionManager());

  @override
  Future<bool> login(String username, String password) async => false;

  @override
  Future<void> logout() async {}
}
