import 'package:flutter/services.dart';

/// Normalisation for text that arrives by paste rather than by typing.
///
/// Text copied out of WhatsApp, the contacts app or an Arabic-locale phone is
/// rarely what it looks like on screen:
///
/// * phone numbers are wrapped in invisible bidi controls (U+202A … U+202C,
///   U+200E/U+200F) so they render left-to-right inside Arabic text;
/// * digits are often Arabic-Indic (`٠١٢٣`) or Extended/Persian (`۰۱۲۳`);
/// * numbers carry readability separators (`+20 100-123 4567`).
///
/// None of that is visible, but all of it breaks an exact match: the POS phone
/// detector (`^[0-9+\-\s()]+$`) sees a bidi mark and searches by *name*, and a
/// digits-only formatter silently deletes every Arabic digit — so the paste
/// "did nothing". These helpers fold such input into what the field expects
/// instead of rejecting it.
abstract final class PastedText {
  /// Zero-width and bidi-control characters that never carry meaning in a
  /// form field: LRM/RLM, the embedding/override/isolate controls, ZWSP and
  /// the BOM.
  static final RegExp _invisible = RegExp(
    '[\u200B\u200E\u200F\u202A-\u202E\u2066-\u2069\uFEFF]',
  );

  static final RegExp _phoneLike = RegExp(r'^[0-9+\-\s().]+$');
  static final RegExp _digit = RegExp('[0-9]');

  /// Removes invisible bidi/zero-width characters.
  static String stripInvisible(String input) => input.replaceAll(_invisible, '');

  /// Maps Arabic-Indic (U+0660–0669) and Extended Arabic-Indic (U+06F0–06F9)
  /// digits to ASCII `0-9`. Every other character is left untouched.
  static String normalizeDigits(String input) {
    StringBuffer? buffer;
    for (var i = 0; i < input.length; i++) {
      final unit = input.codeUnitAt(i);
      int? ascii;
      if (unit >= 0x0660 && unit <= 0x0669) {
        ascii = 0x30 + (unit - 0x0660);
      } else if (unit >= 0x06F0 && unit <= 0x06F9) {
        ascii = 0x30 + (unit - 0x06F0);
      }
      if (ascii != null) {
        buffer ??= StringBuffer(input.substring(0, i));
        buffer.writeCharCode(ascii);
      } else {
        buffer?.writeCharCode(unit);
      }
    }
    return buffer?.toString() ?? input;
  }

  /// What any field should receive from the clipboard: invisible controls
  /// removed, surrounding whitespace trimmed and, unless [multiline], line
  /// breaks folded into single spaces (a programmatic write bypasses the
  /// single-line formatter `TextField` applies to typed input).
  static String sanitize(String input, {bool multiline = false}) {
    var text = stripInvisible(input).replaceAll('\r\n', '\n');
    if (!multiline) {
      text = text.replaceAll(RegExp(r'\s*\n\s*'), ' ');
    }
    return text.trim();
  }

  /// A phone number reduced to a leading `+` (if any) and ASCII digits.
  /// With [keepSpaces], single spaces between digit groups survive — for
  /// fields that historically stored `+20 100 123 4567` as written.
  static String normalizePhone(String input, {bool keepSpaces = false}) {
    final source = normalizeDigits(stripInvisible(input));
    final buffer = StringBuffer();
    for (var i = 0; i < source.length; i++) {
      final ch = source[i];
      final unit = ch.codeUnitAt(0);
      if (unit >= 0x30 && unit <= 0x39) {
        buffer.write(ch);
      } else if (ch == '+' && buffer.isEmpty) {
        buffer.write(ch);
      } else if (keepSpaces && ch == ' ' && buffer.isNotEmpty) {
        final text = buffer.toString();
        if (!text.endsWith(' ') && text != '+') buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  /// True when [input] is made only of phone characters and holds a digit —
  /// the same test the POS customer search uses to pick a phone lookup.
  static bool looksLikePhone(String input) {
    final text = input.trim();
    return text.isNotEmpty && _phoneLike.hasMatch(text) && _digit.hasMatch(text);
  }

  /// Search-box normalisation: invisible characters dropped and digits made
  /// ASCII always; separators collapsed only when the whole query is a phone
  /// number, so a name search keeps its spaces.
  static String normalizeSearchQuery(String input) {
    final text = normalizeDigits(stripInvisible(input));
    if (!looksLikePhone(text)) return text;
    return normalizePhone(text);
  }
}

/// Shared cursor bookkeeping: applies [transform] to the new text and keeps the
/// caret after the same logical characters.
TextEditingValue _transformKeepingCursor(
  TextEditingValue value,
  String Function(String) transform,
) {
  final transformed = transform(value.text);
  if (transformed == value.text) return value;

  final selection = value.selection;
  if (!selection.isValid) {
    return TextEditingValue(
      text: transformed,
      selection: TextSelection.collapsed(offset: transformed.length),
    );
  }
  int map(int offset) {
    final clamped = offset.clamp(0, value.text.length);
    return transform(value.text.substring(0, clamped)).length.clamp(
      0,
      transformed.length,
    );
  }

  return TextEditingValue(
    text: transformed,
    selection: TextSelection(
      baseOffset: map(selection.baseOffset),
      extentOffset: map(selection.extentOffset),
    ),
  );
}

/// Phone fields: accepts whatever is pasted or typed and keeps a leading `+`
/// plus ASCII digits. Arabic-Indic digits are converted rather than dropped,
/// and dashes, dots, parentheses, bidi marks and (unless [keepSpaces]) spaces
/// are removed.
class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter({this.keepSpaces = false});

  /// Keep single spaces between digit groups instead of removing them.
  final bool keepSpaces;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _transformKeepingCursor(
      newValue,
      (text) => PastedText.normalizePhone(text, keepSpaces: keepSpaces),
    );
  }
}

/// Free-text search fields that may receive a pasted phone number: see
/// [PastedText.normalizeSearchQuery].
class SearchQueryInputFormatter extends TextInputFormatter {
  const SearchQueryInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Prefix-mapping the cursor is only exact for per-character transforms;
    // the phone collapse depends on the whole string, so place the caret at
    // the end whenever the collapse actually changed something.
    final normalized = PastedText.normalizeSearchQuery(newValue.text);
    if (normalized == newValue.text) return newValue;
    final digitsOnly = PastedText.normalizeDigits(
      PastedText.stripInvisible(newValue.text),
    );
    if (digitsOnly == normalized) {
      return _transformKeepingCursor(
        newValue,
        (s) => PastedText.normalizeDigits(PastedText.stripInvisible(s)),
      );
    }
    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }
}
