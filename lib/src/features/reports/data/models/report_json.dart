/// Shorthand for a decoded JSON object. Used for the loosely-typed analytics
/// rows whose exact shape each dashboard screen resolves at render time.
///
/// Also keeps Freezed's `@Default` annotation parser away from nested
/// `List<Map<String, dynamic>>` generics (the `>>` trips it up).
typedef JsonMap = Map<String, dynamic>;
