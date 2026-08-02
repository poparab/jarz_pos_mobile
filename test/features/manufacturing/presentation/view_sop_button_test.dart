import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/widgets/view_sop_button.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders nothing for an item with no SOP', (tester) async {
    await _pump(tester, ViewSopButton(hasSop: false, onTap: () {}));

    expect(find.text('View SOP'), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('shows the scaled duration alongside the label', (tester) async {
    await _pump(tester, ViewSopButton(onTap: () {}, totalDurationMins: 45));

    expect(find.text('View SOP · 45 min'), findsOneWidget);
  });

  testWidgets('taps through to the caller', (tester) async {
    var taps = 0;
    await _pump(tester, ViewSopButton(onTap: () => taps++));

    await tester.tap(find.text('View SOP'));
    await tester.pumpAndSettle();

    expect(taps, 1);
  });

  testWidgets('the dense form is an icon with the label as its tooltip',
      (tester) async {
    await _pump(tester, ViewSopButton(onTap: () {}, dense: true));

    expect(find.byType(IconButton), findsOneWidget);
    expect(find.text('View SOP'), findsNothing);
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).tooltip,
      'View SOP',
    );
  });
}
