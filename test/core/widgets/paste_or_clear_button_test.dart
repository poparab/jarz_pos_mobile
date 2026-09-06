// The in-field paste/clear affordance.
//
// The behaviour under test is the one staff hit on a phone: fill an address
// field from the clipboard without ever opening the keyboard, and wipe a bad
// paste with the same single tap.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/widgets/paste_or_clear_button.dart';

/// Answers `Clipboard.getData` with [text]; a null [text] stands for an empty
/// clipboard, which is what a fresh simulator reports.
void _stubClipboard(WidgetTester tester, String? text) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.getData') {
        return text == null ? null : <String, dynamic>{'text': text};
      }
      if (call.method == 'Clipboard.setData') return null;
      return null;
    },
  );
}

Future<void> _pumpField(
  WidgetTester tester,
  TextEditingController controller, {
  ValueChanged<String>? onChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: TextField(
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: PasteOrClearButton(
              controller: controller,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('pastes the clipboard into an empty field in one tap', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    _stubClipboard(tester, '12 Ahmed Orabi St, Nasr City');

    final changes = <String>[];
    await _pumpField(tester, controller, onChanged: changes.add);

    expect(find.byKey(PasteOrClearButton.pasteKey), findsOneWidget);
    expect(find.byKey(PasteOrClearButton.clearKey), findsNothing);

    await tester.tap(find.byKey(PasteOrClearButton.pasteKey));
    await tester.pumpAndSettle();

    expect(controller.text, '12 Ahmed Orabi St, Nasr City');
    // The host is told by hand — a programmatic controller write never fires
    // the field's own onChanged.
    expect(changes, ['12 Ahmed Orabi St, Nasr City']);
    // Caret parked at the end, so typing a flat number continues the address.
    expect(controller.selection.baseOffset, controller.text.length);
  });

  testWidgets('swaps to clear once the field holds text, and wipes it', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'wrong address');
    addTearDown(controller.dispose);
    _stubClipboard(tester, 'unused');

    final changes = <String>[];
    await _pumpField(tester, controller, onChanged: changes.add);

    expect(find.byKey(PasteOrClearButton.pasteKey), findsNothing);

    await tester.tap(find.byKey(PasteOrClearButton.clearKey));
    await tester.pumpAndSettle();

    expect(controller.text, isEmpty);
    expect(changes, ['']);
    // Cleared field offers paste again, so a re-paste is one more tap.
    expect(find.byKey(PasteOrClearButton.pasteKey), findsOneWidget);
  });

  testWidgets('an empty clipboard leaves the field untouched', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    _stubClipboard(tester, null);

    final changes = <String>[];
    await _pumpField(tester, controller, onChanged: changes.add);

    await tester.tap(find.byKey(PasteOrClearButton.pasteKey));
    await tester.pumpAndSettle();

    expect(controller.text, isEmpty);
    expect(changes, isEmpty);
  });
}
