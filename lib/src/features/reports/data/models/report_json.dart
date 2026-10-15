/// Shorthand for a decoded JSON object. Used for the loosely-typed analytics
/// rows whose exact shape each dashboard screen resolves at render time.
///
/// Also keeps Freezed's `@Default` annotation parser away from nested
/// `List<Map<String, dynamic>>` generics (the `>>` trips it up).
typedef JsonMap = Map<String, dynamic>;

/// Tolerant readers for the hand-written report models.
///
/// The reports backend is written in Python and evolves additively, so a key
/// can be missing (older server), `null`, a number sent as a string, or an
/// int where a float is expected. Every reader here accepts all of those and
/// falls back to a neutral value instead of throwing, so one odd field never
/// blanks a whole dashboard.
abstract final class ReportJson {
  /// [v] as a map, or an empty map.
  static JsonMap map(Object? v) =>
      v is Map ? Map<String, dynamic>.from(v) : const <String, dynamic>{};

  /// [v] as a list of maps (non-map entries dropped), or an empty list.
  static List<JsonMap> list(Object? v) => v is List
      ? v
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList(growable: false)
      : const <JsonMap>[];

  /// [v] parsed with [parse] per map entry.
  static List<T> listOf<T>(Object? v, T Function(JsonMap) parse) =>
      list(v).map(parse).toList(growable: false);

  /// [v] as a list of non-empty strings, or an empty list.
  static List<String> strings(Object? v) => v is List
      ? v
            .where((e) => e != null)
            .map((e) => '$e')
            .where((s) => s.trim().isNotEmpty)
            .toList(growable: false)
      : const <String>[];

  /// [v] as a double; null / unparsable → [fallback].
  static double dbl(Object? v, [double fallback = 0]) =>
      dblOrNull(v) ?? fallback;

  /// [v] as a double, or null when absent / unparsable.
  static double? dblOrNull(Object? v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  /// [v] as an int; null / unparsable → [fallback].
  static int integer(Object? v, [int fallback = 0]) => intOrNull(v) ?? fallback;

  /// [v] as an int, or null when absent / unparsable.
  static int? intOrNull(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final t = v.trim();
      return int.tryParse(t) ?? double.tryParse(t)?.toInt();
    }
    return null;
  }

  /// [v] as a string; null / blank → [fallback].
  static String str(Object? v, [String fallback = '']) =>
      strOrNull(v) ?? fallback;

  /// [v] as a trimmed string, or null when absent / blank.
  static String? strOrNull(Object? v) {
    if (v == null) return null;
    final s = '$v'.trim();
    return s.isEmpty ? null : s;
  }

  /// [v] as a bool: accepts bool, 0/1 and "true"/"1"/"yes".
  static bool boolean(Object? v, [bool fallback = false]) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final t = v.trim().toLowerCase();
      if (const {'1', 'true', 'yes'}.contains(t)) return true;
      if (const {'0', 'false', 'no', ''}.contains(t)) return false;
    }
    return fallback;
  }

  /// [v] as a DateTime (ISO or `YYYY-MM-DD[ HH:MM:SS]`), or null.
  static DateTime? dateTimeOrNull(Object? v) {
    final s = strOrNull(v);
    if (s == null) return null;
    return DateTime.tryParse(s) ?? DateTime.tryParse(s.replaceFirst(' ', 'T'));
  }
}
