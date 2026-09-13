// The compact in-field paste affordance used across the POS.
//
// Covers what a cashier actually does: paste into the middle of a search, over
// a selected word, into an empty field, from an empty clipboard, and on a web
// build whose clipboard read is refused.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/src/core/utils/pasted_text.dart';
import 'package:jarz_pos/src/core/widgets/paste_icon_button.dart';

final String _lre = String.fromCharCode(0x202A); // LEFT-TO-RIGHT EMBEDDING
final String _pdf = String.fromCharCode(0x202C); // POP DIRECTIONAL FORMATTING

/// Answers `Clipboard.getData` with [text] (null = empty clipboard), or throws
/// the web engine's `paste_fail` error when [fail] is set.
void _stubClipboard(WidgetTester tester, {String? text, bool fail = false}) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.getData') {
        if (fail) {
          throw PlatformException(
            code: 'paste_fail',
            message: 'Clipboard.getData failed.',
          );
        }
        return text == null ? null : <String, dynamic>{'text': text};
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
}

Future<void> _pump(WidgetTester tester, Widget button, {Widget? field}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Column(
          children: [if (field != null) field, button],
        ),
      ),
    ),
  );
}

void main() {
  group('PasteIconButton', () {
    testWidgets('inserts at the caret and moves the caret after the paste', (
      tester,
    ) async {
      _stubClipboard(tester, text: 'Nasr ');
      final controller = TextEditingController(text: 'Ahmed Ali')
        ..selection = const TextSelection.collapsed(offset: 6);
      final changes = <String>[];
      await _pump(
        tester,
        PasteIconButton(controller: controller, onChanged: changes.add),
      );

      await tester.tap(find.byKey(PasteIconButton.buttonKey));
      await tester.pump();

      // Surrounding whitespace is trimmed from the clipboard text.
      expect(controller.text, 'Ahmed NasrAli');
      expect(controller.selection, const TextSelection.collapsed(offset: 10));
      expect(changes, ['Ahmed NasrAli']);
    });

    testWidgets('replaces the current selection', (tester) async {
      _stubClipboard(tester, text: 'Heliopolis');
      final controller = TextEditingController(text: '12 Orabi St, Nasr City')
        ..selection = const TextSelection(baseOffset: 13, extentOffset: 22);
      await _pump(tester, PasteIconButton(controller: controller));

      await tester.tap(find.byKey(PasteIconButton.buttonKey));
      await tester.pump();

      expect(controller.text, '12 Orabi St, Heliopolis');
      expect(controller.selection.baseOffset, controller.text.length);
    });

    testWidgets('replace: true swaps the whole value', (tester) async {
      _stubClipboard(tester, text: '01001234567');
      final controller = TextEditingController(text: '0111');
      await _pump(
        tester,
        PasteIconButton(controller: controller, replace: true),
      );

      await tester.tap(find.byKey(PasteIconButton.buttonKey));
      await tester.pump();

      expect(controller.text, '01001234567');
    });

    testWidgets('an empty clipboard changes nothing and fires nothing', (
      tester,
    ) async {
      _stubClipboard(tester);
      final controller = TextEditingController(text: 'keep me');
      var fired = false;
      await _pump(
        tester,
        PasteIconButton(controller: controller, onChanged: (_) => fired = true),
      );

      await tester.tap(find.byKey(PasteIconButton.buttonKey));
      await tester.pump();

      expect(controller.text, 'keep me');
      expect(fired, isFalse);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a refused clipboard read shows a hint instead of throwing', (
      tester,
    ) async {
      _stubClipboard(tester, fail: true);
      final controller = TextEditingController();
      await _pump(tester, PasteIconButton(controller: controller));

      await tester.tap(find.byKey(PasteIconButton.buttonKey));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(controller.text, isEmpty);
      expect(find.textContaining('Ctrl+V'), findsOneWidget);
    });

    testWidgets('runs the field formatters over pasted text', (tester) async {
      _stubClipboard(tester, text: '$_lre+20 100-123 4567$_pdf');
      final controller = TextEditingController();
      final changes = <String>[];
      await _pump(
        tester,
        PasteIconButton(
          controller: controller,
          replace: true,
          inputFormatters: const [PhoneInputFormatter()],
          onChanged: changes.add,
        ),
      );

      await tester.tap(find.byKey(PasteIconButton.buttonKey));
      await tester.pump();

      expect(controller.text, '+201001234567');
      expect(changes, ['+201001234567']);
    });

    testWidgets('folds line breaks unless the field is multi-line', (
      tester,
    ) async {
      _stubClipboard(tester, text: 'Building 5\nFloor 3');
      final single = TextEditingController();
      final multi = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PasteIconButton(key: const Key('single'), controller: single),
                PasteIconButton(
                  key: const Key('multi'),
                  controller: multi,
                  multiline: true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('single')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('multi')));
      await tester.pump();

      expect(single.text, 'Building 5 Floor 3');
      expect(multi.text, 'Building 5\nFloor 3');
    });

    testWidgets('without a controller hands the cleaned text to onPasted', (
      tester,
    ) async {
      _stubClipboard(tester, text: '  ${_lre}PROMO10$_pdf \n');
      String? pasted;
      await _pump(tester, PasteIconButton(onPasted: (v) => pasted = v));

      await tester.tap(find.byKey(PasteIconButton.buttonKey));
      await tester.pump();

      expect(pasted, 'PROMO10');
    });

    testWidgets('a paste into a real TextField reaches its listeners', (
      tester,
    ) async {
      _stubClipboard(tester, text: '01001234567');
      final controller = TextEditingController();
      String? searched;
      await _pump(
        tester,
        const SizedBox.shrink(),
        field: TextField(
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: PasteIconButton(
              controller: controller,
              onChanged: (v) => searched = v,
            ),
          ),
        ),
      );

      expect(
        find.byTooltip(
          const DefaultMaterialLocalizations().pasteButtonLabel,
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(PasteIconButton.buttonKey));
      await tester.pump();

      expect(find.text('01001234567'), findsOneWidget);
      expect(searched, '01001234567');
    });

    testWidgets('disabled button does not read the clipboard', (tester) async {
      var reads = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.getData') reads++;
          return <String, dynamic>{'text': 'x'};
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final controller = TextEditingController();
      await _pump(
        tester,
        PasteIconButton(controller: controller, enabled: false),
      );

      await tester.tap(find.byKey(PasteIconButton.buttonKey));
      await tester.pump();

      expect(reads, 0);
      expect(controller.text, isEmpty);
    });
  });

  group('applyPastedText', () {
    test('appends when the field never had a caret', () {
      final next = applyPastedText(
        const TextEditingValue(text: 'abc'),
        'def',
      );
      expect(next.text, 'abcdef');
      expect(next.selection, const TextSelection.collapsed(offset: 6));
    });
  });
}
