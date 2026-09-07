/// What the server will actually accept from this user on the Production Board.
///
/// The app used to hardcode a three-day backdating window while the server read
/// its own ceiling from `Jarz POS Settings`, and the two disagreed silently: on
/// production that setting reads 0, so the picker offered yesterday and every
/// post of it was refused. A window the client invents is a window the client
/// can be wrong about — so it is read, not assumed.
class ProductionPolicy {
  const ProductionPolicy({
    this.maxBackDateDays = 0,
    this.canBackDate = false,
    this.canExecute = false,
    this.unlimitedBackDate = false,
    this.serverDate,
  });

  factory ProductionPolicy.fromJson(Map<String, dynamic> json) =>
      ProductionPolicy(
        maxBackDateDays: (json['max_backdate_days'] as num?)?.toInt() ?? 0,
        canBackDate: json['can_backdate'] == true,
        canExecute: json['can_execute'] == true,
        unlimitedBackDate: json['unlimited_backdate'] == true,
        serverDate: _parseDate(json['server_date']),
      );

  /// How many days before today a manager may post production.
  ///
  /// Zero is a real answer — "today only" — and must not be read as "unset".
  final int maxBackDateDays;

  /// Whether this account may post an earlier date at all. Operators may not:
  /// backdating is how stock and COGS reach a closed period.
  final bool canBackDate;

  final bool canExecute;

  /// A System Manager is bound only by "not the future", never by
  /// [maxBackDateDays] — clamping their picker to it would refuse a date the
  /// server would have accepted.
  final bool unlimitedBackDate;

  /// The server's own today.
  ///
  /// The posting-date gate is evaluated against the server clock, so the picker
  /// has to be built from it too: a tablet a day fast would otherwise offer as
  /// its last selectable day a date the server calls the future.
  final DateTime? serverDate;

  /// Today according to whoever is authoritative — the server when it said,
  /// the device otherwise.
  DateTime today() {
    final fromServer = serverDate;
    if (fromServer != null) return fromServer;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// The earliest date this user may post, or [today] when they may not
  /// backdate at all.
  DateTime earliestPostable() {
    final base = today();
    if (!canBackDate) return base;
    // Unbounded in practice, but a picker needs a first date. Ten years is far
    // enough to be "no limit" and finite enough to build a calendar from.
    if (unlimitedBackDate) return base.subtract(const Duration(days: 3650));
    return base.subtract(Duration(days: maxBackDateDays));
  }

  /// Whether [date] falls on an earlier day than the server's today.
  bool isBackDated(DateTime date) =>
      DateTime(date.year, date.month, date.day).isBefore(today());

  static DateTime? _parseDate(Object? raw) {
    final text = raw?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
}
