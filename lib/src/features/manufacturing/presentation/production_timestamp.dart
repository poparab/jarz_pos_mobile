/// How a production posting moment is put on the wire.
///
/// The two functions here look similar and are deliberately NOT the same, so
/// they live side by side where the difference is visible. Both were private
/// to their own screen until a review pointed out that the property they guard
/// — a Manufacture entry must never be stamped before the Material Transfer
/// that fed it, or ERPNext refuses it for negative WIP — had no test at all.
library;

String _two(int v) => v.toString().padLeft(2, '0');

String _date(DateTime value) =>
    '${value.year}-${_two(value.month)}-${_two(value.day)}';

/// The FINISH side: `scheduled_at` for a batch being completed, or null.
///
/// **Today with no chosen time returns null, deliberately.** Before the finish
/// sheet had a date at all it sent nothing and the server stamped
/// `now_datetime()` — its own clock, to the microsecond. A device-derived time
/// would be a regression twice over, and both ways end with the Manufacture
/// entry landing before the transfer that fed it:
///   * the device clock is not the server's, and two tablets finish each
///     other's batches here, so one set to another timezone stamps hours early;
///   * truncating to the minute throws away up to 59 s, and start-then-finish
///     inside one minute is the normal shape of recording a run that already
///     happened.
///
/// A PAST day with no chosen time still needs an explicit stamp, and 23:59 is
/// the safe end of it: after any transfer posted that day, whenever it was.
///
/// [explicitTime] must come from whether the operator actually picked a clock
/// time — never from "a date is set". The picker seeds from a bare day and the
/// basket is persisted, so a defaulted or restored value reads as midnight, and
/// honouring that would post the batch at the start of the day.
String? finishScheduledAt(
  DateTime day,
  DateTime today, {
  required bool explicitTime,
}) {
  if (explicitTime) {
    return '${_date(day)} ${_two(day.hour)}:${_two(day.minute)}:00';
  }
  // Day-granular on purpose: [day] may carry a clock component from a default,
  // and comparing that against midnight would read today as a past day.
  if (!DateTime(day.year, day.month, day.day).isBefore(today)) return null;
  return '${_date(day)} 23:59:00';
}

/// The START side: `scheduled_at` for a batch being submitted. Never null.
///
/// Unlike the finish side this always names a time, because the start entry has
/// nothing ordered before it to collide with. Without a chosen time it uses the
/// clock component of *now*, so a same-day batch posts at the time it was
/// actually submitted and a back-dated one lands mid-morning rather than at
/// midnight.
String startScheduledAt(
  DateTime date, {
  required bool explicitTime,
  DateTime? now,
}) {
  final clock = explicitTime ? date : (now ?? DateTime.now());
  return '${_date(date)} ${_two(clock.hour)}:${_two(clock.minute)}:00';
}
