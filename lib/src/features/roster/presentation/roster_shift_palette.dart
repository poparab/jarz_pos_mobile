import 'package:flutter/material.dart';

import '../models/roster_models.dart';

/// Colour and short code for one shift type.
///
/// The code is what makes the colour survivable: two shift types that a manager
/// cannot tell apart by hue — colour-blindness, glare, a cheap screen, or simply
/// two similar blues — are still one glyph apart in the corner of the cell.
@immutable
class RosterShiftStyle {
  const RosterShiftStyle({
    required this.shiftType,
    required this.color,
    required this.code,
    required this.fromBackend,
  });

  final String shiftType;

  /// The fill for a working cell of this shift type.
  final Color color;

  /// A 1–2 character token, unique across the palette.
  final String code;

  /// True when the colour came from the Shift Type record in Desk rather than
  /// from the fallback palette — surfaced so the legend can be honest about
  /// which colours somebody chose and which the app invented.
  final bool fromBackend;

  /// Text/icon colour that stays legible on [color], whatever Desk was set to.
  Color get onColor => RosterShiftPalette.readableOn(color);
}

/// Every shift type in a month, each with a colour that is its own.
///
/// Replaces the previous `name.hashCode % 8`, which had no idea what other
/// shift types existed: two of them landing on the same pastel was undetectable,
/// and since the cell's only other text was the hours, two colliding 12h shifts
/// were identical in both channels at once.
///
/// Assignment here is made over the whole catalog at once:
/// * a colour configured on the Shift Type in Desk always wins — a human said
///   what this shift looks like, and the app has no business overruling them;
/// * every remaining type takes the next palette entry not already spoken for,
///   so no two types in the same month can share a fill;
/// * if a month somehow has more shift types than palette entries, extra hues
///   are generated on the golden angle rather than wrapping round and colliding.
///
/// The order is the sorted type name, not the server's list order, so a shift
/// keeps its colour between months and between devices.
class RosterShiftPalette {
  const RosterShiftPalette._(this._byType, this.entries);

  final Map<String, RosterShiftStyle> _byType;

  /// Every style, in the same sorted order used to assign them — the legend's
  /// "Shifts" strip renders straight from this.
  final List<RosterShiftStyle> entries;

  /// Distinguishable at a glance and legible with either black or white ink.
  /// Deliberately not the old pastel set: an 0xFFFFF9C4 wash with `outline`
  /// text on top was unreadable in daylight before it was ambiguous.
  static const fallbackPalette = <Color>[
    Color(0xFF1B6CA8), // blue
    Color(0xFF2E933C), // green
    Color(0xFFE07A00), // orange
    Color(0xFF7B2CBF), // purple
    Color(0xFF00838F), // teal
    Color(0xFFB5179E), // magenta
    Color(0xFF5C4033), // brown
    Color(0xFF4B6A88), // slate
    Color(0xFF8D6E00), // olive
    Color(0xFFC2185B), // rose
  ];

  /// Shown in the legend's "Working" entry when a month has no shift types at
  /// all, so the entry still looks like the cell it describes.
  static const neutralShiftColor = Color(0xFF4B6A88);

  /// Builds the palette for a whole month.
  ///
  /// Takes the shift types from the catalog *and* from the cells, because a
  /// shift type that has been retired in Desk still appears on days already
  /// worked; leaving those out would mean the grid could draw a colour the
  /// palette had never heard of.
  factory RosterShiftPalette.fromMonth(RosterMonth month) {
    final extras = <String>{};
    for (final employee in month.employees) {
      for (final cell in employee.days.values) {
        final type = (cell.shiftType ?? '').trim();
        if (type.isNotEmpty) extras.add(type);
        final cover = (cell.dayOff?.coverShiftType ?? '').trim();
        if (cover.isNotEmpty) extras.add(cover);
      }
    }
    return RosterShiftPalette.from(
      catalog: month.shiftCatalog,
      extraShiftTypes: extras,
    );
  }

  factory RosterShiftPalette.from({
    required List<RosterShift> catalog,
    Iterable<String> extraShiftTypes = const <String>[],
  }) {
    final configured = <String, Color>{};
    final names = <String>{};

    for (final shift in catalog) {
      final name = shift.shiftType.trim();
      if (name.isEmpty) continue;
      names.add(name);
      final parsed = parseHexColor(shift.color);
      if (parsed != null) configured[name] = parsed;
    }
    for (final extra in extraShiftTypes) {
      final name = extra.trim();
      if (name.isNotEmpty) names.add(name);
    }

    final ordered = names.toList()
      ..sort((a, b) {
        final byLower = a.toLowerCase().compareTo(b.toLowerCase());
        return byLower != 0 ? byLower : a.compareTo(b);
      });

    final taken = <int>{for (final color in configured.values) _key(color)};
    final usedCodes = <String>{};
    final styles = <RosterShiftStyle>[];
    var cursor = 0;

    for (final name in ordered) {
      final fromBackend = configured.containsKey(name);
      Color color;
      if (fromBackend) {
        color = configured[name]!;
      } else {
        color = _nextFreeColor(taken, cursor);
        cursor++;
        taken.add(_key(color));
      }
      final code = _codeFor(name, usedCodes);
      usedCodes.add(code);
      styles.add(
        RosterShiftStyle(
          shiftType: name,
          color: color,
          code: code,
          fromBackend: fromBackend,
        ),
      );
    }

    return RosterShiftPalette._(
      {for (final style in styles) style.shiftType: style},
      List.unmodifiable(styles),
    );
  }

  /// The style for [shiftType].
  ///
  /// Falls back to a generated-but-stable style rather than returning null, so
  /// a cell naming a shift type nobody told us about still draws something a
  /// manager can ask about instead of crashing the grid.
  RosterShiftStyle styleFor(String? shiftType) {
    final name = (shiftType ?? '').trim();
    final known = _byType[name];
    if (known != null) return known;
    if (name.isEmpty) {
      return const RosterShiftStyle(
        shiftType: '',
        color: neutralShiftColor,
        code: '?',
        fromBackend: false,
      );
    }
    var hash = 0;
    for (final unit in name.toLowerCase().codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return RosterShiftStyle(
      shiftType: name,
      color: fallbackPalette[hash % fallbackPalette.length],
      code: _codeFor(name, const <String>{}),
      fromBackend: false,
    );
  }

  bool get isEmpty => entries.isEmpty;

  /// What the legend's "Working" swatch should look like for this month.
  Color get representativeColor =>
      entries.isEmpty ? neutralShiftColor : entries.first.color;

  /// Parses `#RRGGBB`, `#AARRGGBB` or bare hex; null when unusable.
  ///
  /// A mistyped colour on a Shift Type in Desk degrades to the fallback palette
  /// instead of taking the screen down with it.
  static Color? parseHexColor(String? value) {
    var hex = (value ?? '').trim();
    if (hex.isEmpty) return null;
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
    }
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return null;
    if (!RegExp(r'^[0-9a-fA-F]{8}$').hasMatch(hex)) return null;
    final parsed = int.tryParse(hex, radix: 16);
    return parsed == null ? null : Color(parsed);
  }

  /// Black or white, whichever stays readable on [background].
  ///
  /// The whole point of honouring the Desk colour is that the app cannot know
  /// in advance whether it is getting a near-black navy or a pale lemon, so the
  /// ink is derived from the fill instead of assumed.
  static Color readableOn(Color background) =>
      background.computeLuminance() > 0.48
      ? const Color(0xFF1B1B1B)
      : const Color(0xFFFFFFFF);

  static int _key(Color color) => color.toARGB32();

  static Color _nextFreeColor(Set<int> taken, int cursor) {
    for (var i = 0; i < fallbackPalette.length; i++) {
      final candidate = fallbackPalette[(cursor + i) % fallbackPalette.length];
      if (!taken.contains(_key(candidate))) return candidate;
    }
    // More shift types than palette entries: walk the golden angle so the
    // extras stay far apart from each other instead of wrapping onto a colour
    // that is already in use.
    for (var step = 0; step < 360; step++) {
      final hue = (137.508 * (cursor + step)) % 360;
      final candidate = HSLColor.fromAHSL(1, hue, 0.55, 0.42).toColor();
      if (!taken.contains(_key(candidate))) return candidate;
    }
    return neutralShiftColor;
  }

  /// A short, unique token for a shift type.
  ///
  /// Latin names get their initial; Arabic (or any other script) gets its first
  /// character, which is still a perfectly good "these two are different" mark.
  /// Clashes are broken with a digit rather than by silently reusing a letter.
  static String _codeFor(String name, Set<String> used) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final first = trimmed.characters.first;
    final base = RegExp(r'^[a-zA-Z0-9]$').hasMatch(first)
        ? first.toUpperCase()
        : first;
    if (!used.contains(base)) return base;
    for (var i = 2; i < 100; i++) {
      final candidate = '$base$i';
      if (!used.contains(candidate)) return candidate;
    }
    return base;
  }
}
