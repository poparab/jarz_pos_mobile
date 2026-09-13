// Normalisation of pasted phone numbers, digits and search queries.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/src/core/utils/pasted_text.dart';

final String _lre = String.fromCharCode(0x202A);
final String _pdf = String.fromCharCode(0x202C);
final String _rlm = String.fromCharCode(0x200F);

/// Arabic-Indic digits for an ASCII digit string.
String _arabic(String ascii) => String.fromCharCodes(
  ascii.codeUnits.map((u) => u >= 0x30 && u <= 0x39 ? 0x0660 + u - 0x30 : u),
);

/// Extended (Persian) Arabic-Indic digits for an ASCII digit string.
String _persian(String ascii) => String.fromCharCodes(
  ascii.codeUnits.map((u) => u >= 0x30 && u <= 0x39 ? 0x06F0 + u - 0x30 : u),
);

TextEditingValue _format(TextInputFormatter f, String text, {int? caret}) {
  return f.formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: caret ?? text.length),
    ),
  );
}

void main() {
  group('PastedText', () {
    test('normalizeDigits maps Arabic-Indic and Persian digits', () {
      expect(PastedText.normalizeDigits(_arabic('01001234567')), '01001234567');
      expect(PastedText.normalizeDigits(_persian('0123456789')), '0123456789');
      expect(PastedText.normalizeDigits('Ahmed 12'), 'Ahmed 12');
    });

    test('stripInvisible removes bidi marks a WhatsApp copy carries', () {
      expect(
        PastedText.stripInvisible('$_lre+20 100 123 4567$_pdf$_rlm'),
        '+20 100 123 4567',
      );
    });

    test('normalizePhone keeps a leading plus and digits only', () {
      expect(
        PastedText.normalizePhone('$_lre+20 (100) 123-4567$_pdf'),
        '+201001234567',
      );
      expect(PastedText.normalizePhone(_arabic('010 0123 4567')), '01001234567');
      expect(PastedText.normalizePhone('010+1'), '0101');
    });

    test('normalizePhone(keepSpaces) keeps single group spaces', () {
      expect(
        PastedText.normalizePhone('+20  100-123 4567', keepSpaces: true),
        '+20 100123 4567',
      );
    });

    test('normalizeSearchQuery collapses phones but not names', () {
      expect(
        PastedText.normalizeSearchQuery('$_lre${_arabic('0100 123 4567')}$_pdf'),
        '01001234567',
      );
      expect(PastedText.normalizeSearchQuery('Ahmed Ali'), 'Ahmed Ali');
      expect(PastedText.normalizeSearchQuery('#12345'), '#12345');
      expect(PastedText.normalizeSearchQuery('Ali ${_arabic('2')}'), 'Ali 2');
    });

    test('sanitize trims and folds line breaks for single-line fields', () {
      expect(PastedText.sanitize('  a\r\nb \n'), 'a b');
      expect(PastedText.sanitize('a\r\nb', multiline: true), 'a\nb');
    });
  });

  group('PhoneInputFormatter', () {
    test('converts a pasted Arabic number instead of deleting it', () {
      // The old `[0-9+ ]` allow-list turned this paste into an empty field.
      final out = _format(const PhoneInputFormatter(), _arabic('01001234567'));
      expect(out.text, '01001234567');
      expect(out.selection, const TextSelection.collapsed(offset: 11));
    });

    test('keeps the caret after the same digit when separators go', () {
      // Caret after "010-" (offset 4) lands after "010" (offset 3).
      final out = _format(const PhoneInputFormatter(), '010-123', caret: 4);
      expect(out.text, '010123');
      expect(out.selection, const TextSelection.collapsed(offset: 3));
    });

    test('leaves already-clean input untouched', () {
      const value = TextEditingValue(
        text: '0100',
        selection: TextSelection.collapsed(offset: 2),
      );
      expect(
        const PhoneInputFormatter().formatEditUpdate(
          TextEditingValue.empty,
          value,
        ),
        same(value),
      );
    });
  });

  group('SearchQueryInputFormatter', () {
    test('pasted phone with separators becomes a phone query', () {
      final out = _format(
        const SearchQueryInputFormatter(),
        '$_lre+20 100 123 4567$_pdf',
      );
      expect(out.text, '+201001234567');
      expect(out.selection.baseOffset, out.text.length);
    });

    test('a name keeps its spaces and caret', () {
      final out = _format(
        const SearchQueryInputFormatter(),
        'Ahmed Ali',
        caret: 3,
      );
      expect(out.text, 'Ahmed Ali');
      expect(out.selection, const TextSelection.collapsed(offset: 3));
    });
  });
}
