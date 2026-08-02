import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/sop.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/widgets/sop_capture_field.dart';
import 'package:jarz_pos/src/features/manufacturing/state/sop_providers.dart';

/// Captured values, in order. `null` means "the field refused to record".
late List<double?> captured;

Future<void> _pumpNumeric(
  WidgetTester tester, {
  double? min,
  double? max,
  String captureType = SopCapture.temperature,
  SopStepProgress progress = const SopStepProgress(),
}) async {
  captured = <double?>[];

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SopCaptureField(
            step: SopStep(
              stepNo: 3,
              title: 'Proof the dough',
              captureType: captureType,
              captureMin: min,
              captureMax: max,
            ),
            progress: progress,
            // No Work Order: nothing is posted, so the test needs no network.
            workOrder: null,
            onValueCaptured: captured.add,
            onPhotoCaptured: ({String? fileUrl, String? localPath}) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TextField _field(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField));

void main() {
  testWidgets('an out-of-range reading is refused and flagged', (tester) async {
    await _pumpNumeric(tester, min: 60, max: 80);

    // The allowed range is shown up front rather than only after a mistake.
    expect(_field(tester).decoration?.helperText, 'Allowed range 60 to 80');

    await tester.enterText(find.byType(TextField), '10');
    await tester.pump();

    expect(_field(tester).decoration?.errorText, 'Allowed range 60 to 80');
    expect(_field(tester).decoration?.helperText, isNull);
    // Nothing recorded: the step stays unsatisfied and Next stays disabled.
    expect(captured, [null]);
  });

  testWidgets('an in-range reading is recorded', (tester) async {
    await _pumpNumeric(tester, min: 60, max: 80);

    await tester.enterText(find.byType(TextField), '72.5');
    await tester.pump();

    expect(_field(tester).decoration?.errorText, isNull);
    expect(captured, [72.5]);
  });

  testWidgets('leaving the range clears a reading that was already valid',
      (tester) async {
    await _pumpNumeric(tester, min: 60, max: 80);

    await tester.enterText(find.byType(TextField), '70');
    await tester.pump();
    expect(captured.last, 70);

    await tester.enterText(find.byType(TextField), '700');
    await tester.pump();

    expect(_field(tester).decoration?.errorText, 'Allowed range 60 to 80');
    expect(captured.last, isNull);
  });

  testWidgets('clearing the field records nothing without shouting about it',
      (tester) async {
    await _pumpNumeric(tester, min: 60, max: 80);

    await tester.enterText(find.byType(TextField), '70');
    await tester.pump();
    expect(captured.last, 70);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    // A half-typed or wiped entry is not an error, it is just not recorded.
    expect(_field(tester).decoration?.errorText, isNull);
    expect(captured.last, isNull);
  });

  testWidgets('a one-sided range still validates', (tester) async {
    // Only a floor: "at least 75 °C", no ceiling.
    await _pumpNumeric(tester, min: 75);

    await tester.enterText(find.byType(TextField), '70');
    await tester.pump();
    expect(_field(tester).decoration?.errorText, 'Allowed range 75 to –');
    expect(captured.last, isNull);

    await tester.enterText(find.byType(TextField), '90');
    await tester.pump();
    expect(_field(tester).decoration?.errorText, isNull);
    expect(captured.last, 90);
  });

  testWidgets('an unbounded reading is accepted as typed', (tester) async {
    await _pumpNumeric(tester, captureType: SopCapture.number);

    expect(_field(tester).decoration?.helperText, isNull);

    await tester.enterText(find.byType(TextField), '4');
    await tester.pump();

    expect(captured, [4]);
  });

  testWidgets('a temperature below zero is typeable', (tester) async {
    await _pumpNumeric(tester, min: -30, max: 0);

    await tester.enterText(find.byType(TextField), '-18');
    await tester.pump();

    expect(_field(tester).decoration?.errorText, isNull);
    expect(captured.last, -18);
  });

  testWidgets('an existing reading is shown when the step is revisited',
      (tester) async {
    await _pumpNumeric(
      tester,
      min: 60,
      max: 80,
      progress: const SopStepProgress(confirmed: true, value: 72),
    );

    expect(find.text('72'), findsOneWidget);
  });
}
