/// Recognising the server's "this unit has no conversion" refusal.
///
/// The purchase API refuses a line whose unit the Item cannot convert to its
/// stock unit, with an English sentence:
///
///   "{item_code} has no conversion from {uom} to {stock_uom}. Pick another
///   unit or add the conversion on the Item."
///
/// The shared error presenter drops English server sentences in the Arabic
/// UI, so the buyer would only see a generic failure and never learn which
/// line to fix. This pulls the item and the two units out of the error so the
/// screen can name them with localized strings.
library;

import 'dart:convert';

import 'package:dio/dio.dart';

/// The item and units named by a "no conversion" refusal.
class MissingUomConversion {
  final String itemCode;
  final String uom;
  final String stockUom;

  const MissingUomConversion({
    required this.itemCode,
    required this.uom,
    required this.stockUom,
  });

  @override
  bool operator ==(Object other) =>
      other is MissingUomConversion &&
      other.itemCode == itemCode &&
      other.uom == uom &&
      other.stockUom == stockUom;

  @override
  int get hashCode => Object.hash(itemCode, uom, stockUom);

  @override
  String toString() =>
      'MissingUomConversion(itemCode: $itemCode, uom: $uom, stockUom: $stockUom)';
}

/// The sentence, after tags and entities are removed. The item may not
/// contain ": " — that is what lets a "Purchase failed: " or
/// "ValidationError: " wrapper in front of it be skipped.
final RegExp _sentence = RegExp(
  r'(?:^|:\s+)((?:(?!:\s)[^\n])+?)\s+has\s+no\s+conversion\s+from\s+(.+?)\s+to\s+(.+?)\s*(?:\.\s*Pick\s+another\s+unit|\.?\s*$)',
  multiLine: true,
  caseSensitive: false,
);

/// Returns the refused item and units, or `null` when [error] is anything
/// other than the "no conversion" refusal.
///
/// Accepts a [DioException] carrying the Frappe body (`_server_messages`,
/// `exception`, `message`, `exc`), a decoded or raw JSON body, or any object
/// whose `toString()` contains the sentence.
MissingUomConversion? parseMissingUomConversion(Object? error) {
  for (final text in _texts(error, 0)) {
    final match = _sentence.firstMatch(_plain(text));
    if (match == null) continue;
    final item = _trimQuotes(match.group(1)!);
    final uom = _trimQuotes(match.group(2)!);
    final stockUom = _trimQuotes(match.group(3)!);
    if (item.isEmpty || uom.isEmpty || stockUom.isEmpty) continue;
    return MissingUomConversion(itemCode: item, uom: uom, stockUom: stockUom);
  }
  return null;
}

Iterable<String> _texts(Object? value, int depth) sync* {
  if (value == null || depth > 6) return;
  if (value is DioException) {
    yield* _texts(value.response?.data, depth + 1);
    if (value.message != null) yield value.message!;
    if (value.error != null) yield* _texts(value.error, depth + 1);
    return;
  }
  if (value is Response) {
    yield* _texts(value.data, depth + 1);
    return;
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      Object? decoded;
      try {
        decoded = jsonDecode(trimmed);
      } catch (_) {
        decoded = null;
      }
      if (decoded != null) {
        yield* _texts(decoded, depth + 1);
        return;
      }
    }
    yield trimmed;
    return;
  }
  if (value is Map) {
    // Frappe puts the user-facing sentence in `_server_messages`; the
    // `exception` string carries it too, behind the exception class name.
    for (final key in const [
      '_server_messages',
      'message',
      '_error_message',
      'exception',
      'exc',
      'error',
      'detail',
      'data',
    ]) {
      if (value.containsKey(key)) yield* _texts(value[key], depth + 1);
    }
    return;
  }
  if (value is Iterable) {
    for (final item in value.take(20)) {
      yield* _texts(item, depth + 1);
    }
    return;
  }
  yield value.toString();
}

/// Frappe may bold the values or escape them; match on the plain text.
String _plain(String text) => text
    .replaceAll(RegExp(r'<[^>]*>'), '')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&#x27;', "'")
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&');

String _trimQuotes(String text) =>
    text.trim().replaceAll(RegExp(r'''^["'“”‘’]+|["'“”‘’]+$'''), '').trim();
