import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/sop.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/sop_execute_screen.dart';
import 'package:jarz_pos/src/features/manufacturing/state/sop_providers.dart';

SopDocument _document({
  List<SopStep> steps = const <SopStep>[],
  List<String> unresolvedTokens = const <String>[],
  bool hasSop = true,
}) {
  return SopDocument(
    hasSop: hasSop,
    sop: 'SOP-0001',
    version: 2,
    itemCode: 'CAKE-A',
    itemName: 'Molten Jar',
    batches: 3,
    totalDurationMins: 45,
    steps: steps,
    unresolvedTokens: unresolvedTokens,
  );
}

Future<void> _pump(WidgetTester tester, SopDocument document) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sopForWorkOrderProvider.overrideWith((ref, arg) async => document),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SopExecuteScreen(
          args: SopLaunchArgs(workOrder: 'WO-0001', itemName: 'Molten Jar'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// `FilledButton.icon` builds a private subclass, which `find.byType` (an exact
/// runtime-type match) would miss.
Finder _filledButton(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((w) => w is FilledButton),
    );

VoidCallback? _onPressed(WidgetTester tester, String label) =>
    tester.widget<FilledButton>(_filledButton(label).first).onPressed;

void main() {
  testWidgets('renders one step at a time and blocks Next until confirmed',
      (tester) async {
    await _pump(
      tester,
      _document(
        steps: const [
          SopStep(
            stepNo: 1,
            title: 'Melt the chocolate',
            instructionText: 'Melt 900 g of dark chocolate.',
          ),
          SopStep(
            stepNo: 2,
            title: 'Fold the batter',
            instructionText: 'Fold gently until combined.',
          ),
        ],
      ),
    );

    expect(find.text('Step 1 of 2'), findsOneWidget);
    expect(find.text('Melt the chocolate'), findsOneWidget);
    // The next step is not on screen — one step per page.
    expect(find.text('Fold gently until combined.'), findsNothing);
    // Quantities arrive already substituted; no token is left in the prose.
    expect(find.text('Melt 900 g of dark chocolate.'), findsOneWidget);

    expect(_onPressed(tester, 'Next'), isNull);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(_onPressed(tester, 'Next'), isNotNull);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2 of 2'), findsOneWidget);
    expect(find.text('Fold gently until combined.'), findsOneWidget);
  });

  testWidgets('surfaces the batch scaling and the SOP version', (tester) async {
    await _pump(
      tester,
      _document(
        steps: const [SopStep(stepNo: 1, title: 'Weigh', instructionText: 'x')],
      ),
    );

    expect(find.textContaining('Scaled for 3 batches'), findsOneWidget);
    expect(find.textContaining('Version 2'), findsOneWidget);
    expect(find.textContaining('About 45 min total'), findsOneWidget);
  });

  testWidgets('shouts about tokens the server could not resolve',
      (tester) async {
    await _pump(
      tester,
      _document(
        steps: const [SopStep(stepNo: 1, title: 'Weigh', instructionText: 'x')],
        unresolvedTokens: ['{{item:RM-TYPPO}}'],
      ),
    );

    expect(
      find.text('1 instruction reference(s) could not be resolved'),
      findsOneWidget,
    );
    expect(find.text('{{item:RM-TYPPO}}'), findsOneWidget);
  });

  testWidgets('an item with no SOP says so instead of showing a blank pager',
      (tester) async {
    await _pump(tester, _document(hasSop: false));

    expect(find.text('No work instructions for this item'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
  });

  testWidgets('the last step offers Finish only once every step is satisfied',
      (tester) async {
    await _pump(
      tester,
      _document(
        steps: const [
          SopStep(
            stepNo: 1,
            title: 'Weigh',
            instructionText: 'x',
            requiresConfirmation: false,
          ),
        ],
      ),
    );

    // Nothing to confirm on this step, so it is satisfied on arrival.
    expect(_onPressed(tester, 'Finish instructions'), isNotNull);
    expect(find.text('Next'), findsNothing);
  });
}
