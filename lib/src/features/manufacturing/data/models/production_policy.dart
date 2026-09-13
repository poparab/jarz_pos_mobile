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
    this.fetchedOn,
  });

  factory ProductionPolicy.fromJson(Map<String, dynamic> json) =>
      ProductionPolicy(
        maxBackDateDays: (json['max_backdate_days'] as num?)?.toInt() ?? 0,
        canBackDate: json['can_backdate'] == true,
        canExecute: json['can_execute'] == true,
        unlimitedBackDate: json['unlimited_backdate'] == true,
        serverDate: _parseDate(json['server_date']),
        fetchedOn: _dayOf(deviceNow()),
      );

  /// The device clock, swappable so a test can walk it past midnight.
  static DateTime Function() deviceNow = DateTime.now;

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

  /// The DEVICE's day when [serverDate] was read, or null for a policy that was
  /// not fetched (a fallback, a test fixture).
  ///
  /// The policy is fetched once per login and a floor tablet stays signed in
  /// overnight, so [serverDate] alone froze "today" at the day of login: the
  /// next morning an un-dated Make posted at yesterday's date, and no gate
  /// noticed, because every gate compares against the same frozen day.
  final DateTime? fetchedOn;

  /// Today according to whoever is authoritative — the server when it said,
  /// the device otherwise.
  ///
  /// The server's answer is carried forward by the whole days the device has
  /// seen pass since it was read. The OFFSET between the two clocks is kept, so
  /// a tablet set a day fast still lands on the server's calendar.
  DateTime today() {
    final fromServer = serverDate;
    if (fromServer == null) return _dayOf(deviceNow());
    final fetched = fetchedOn;
    if (fetched == null) return fromServer;
    final elapsed = _wholeDaysBetween(fetched, _dayOf(deviceNow()));
    if (elapsed <= 0) return fromServer;
    return DateTime(
      fromServer.year,
      fromServer.month,
      fromServer.day + elapsed,
    );
  }

  static DateTime _dayOf(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// Calendar days, counted in UTC so a daylight-saving change cannot turn a
  /// 23-hour day into zero.
  static int _wholeDaysBetween(DateTime from, DateTime to) => DateTime.utc(
    to.year,
    to.month,
    to.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

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
