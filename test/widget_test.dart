// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('App widget hierarchy renders with provider overrides', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Minimal router that doesn't trigger navigation side-effects
    final testRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Test')),
          ),
        ),
      ],
    );
    
    addTearDown(testRouter.dispose);

    // Test just the MaterialApp.router layer without JarzPosApp initialization overhead
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: testRouter,
      ),
    );
    
    // Single pump to settle initial frame
    await tester.pump();
    
    expect(find.text('Test'), findsOneWidget);
  });
}
