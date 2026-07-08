/// Sanitizes backend alert `message` strings for display.
///
/// The analytics endpoints emit messages containing light HTML markup
/// (e.g. `Territory <b>Cairo</b> lost <b>EGP 10</b>`) plus occasional Arabic.
/// Rendered verbatim these show the literal tags. [stripHtml] removes the tags
/// and unescapes the common HTML entities so the feed reads as plain,
/// RTL-safe text. It intentionally does no layout work — the caller keeps its
/// existing `Text`/`Directionality`, so Arabic still lays out right-to-left.
String stripHtml(String input) {
  if (input.isEmpty) return input;
  var out = input.replaceAll(RegExp(r'<[^>]+>'), '');
  out = out
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&#39;', "'")
      .replaceAll('&quot;', '"')
      // Unescape `&amp;` last so double-encoded entities resolve one level.
      .replaceAll('&amp;', '&');
  return out.trim();
}
