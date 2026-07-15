import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:jarz_pos/src/core/debug/app_error_console.dart';
import 'package:jarz_pos/src/core/debug/app_error_reporter.dart';
import 'package:jarz_pos/src/core/router.dart';

/// Mirrors production: `AppErrorConsole` is mounted from `MaterialApp.builder`,
/// which puts its context ABOVE the router's navigator. `Navigator.of` therefore
/// finds nothing from that context, and Flutter's internal `navigator!` threw
/// "Null check operator used on a null value" in release, where the friendlier
/// debug assert is compiled out.
Widget _appWithConsoleInBuilder() {
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('home'))),
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    builder: (context, child) =>
        AppErrorConsole(child: child ?? const SizedBox.shrink()),
  );
}

void main() {
  setUp(AppErrorReporter.instance.clear);
  tearDown(AppErrorReporter.instance.clear);

  group('AppErrorConsole', () {
    testWidgets('shows no badge while there are no errors', (tester) async {
      await tester.pumpWidget(_appWithConsoleInBuilder());
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
      expect(find.byIcon(Icons.bug_report_outlined), findsNothing);
    });

    testWidgets('surfaces a badge once an error is recorded', (tester) async {
      await tester.pumpWidget(_appWithConsoleInBuilder());
      await tester.pumpAndSettle();

      AppErrorReporter.instance.capture(
        source: 'Test',
        error: Exception('boom'),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 error'), findsOneWidget);
    });

    testWidgets(
      'opens the diagnostics sheet from above the navigator without crashing',
      (tester) async {
        await tester.pumpWidget(_appWithConsoleInBuilder());
        await tester.pumpAndSettle();

        AppErrorReporter.instance.capture(
          source: 'Test',
          error: Exception('boom'),
          summary: 'a summary',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.bug_report_outlined));
        await tester.pumpAndSettle();

        // Previously this threw before the sheet could ever render.
        expect(tester.takeException(), isNull);
        expect(find.text('Diagnostics'), findsOneWidget);
      },
    );

    testWidgets('does nothing instead of throwing when no navigator exists', (
      tester,
    ) async {
      // No MaterialApp/Navigator anywhere: the diagnostics UI must never be the
      // thing that crashes the app.
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: AppErrorConsole(child: SizedBox.shrink()),
        ),
      );

      AppErrorReporter.instance.capture(
        source: 'Test',
        error: Exception('boom'),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.bug_report_outlined));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
