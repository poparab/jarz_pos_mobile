// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'credit_models.dart';

part 'settlement_models.freezed.dart';
part 'settlement_models.g.dart';

/// Wire models for `jarz_pos.api.settlement_terms.*`.
///
/// Settlement terms are a SCHEDULE and a set of REMINDERS, never a gate:
/// nothing here blocks an order. A shop that pays "invoice after invoice", on
/// Thursdays, or on the 15th and the last day of the month gets a nudge to the
/// responsible manager and a place in the Collections list — that is all.
///
/// Money goes through [creditDouble] for the same reason as the rest of the
/// credit feature: a serialised Decimal reaches us as a String.

/// The five cycles, spelled exactly as the DocType's Select options. These
/// strings go back to the server verbatim.
class SettlementCycle {
  static const onDelivery = 'On Delivery';
  static const invoiceAfterInvoice = 'Invoice after Invoice';
  static const weekly = 'Weekly';
  static const daysOfMonth = 'Days of Month';
  static const everyNDays = 'Every N Days';

  static const all = [
    invoiceAfterInvoice,
    weekly,
    daysOfMonth,
    everyNDays,
    onDelivery,
  ];

  /// The cycles that have calendar dates (and therefore a "next due date").
  static bool isDated(String cycle) =>
      cycle == weekly || cycle == daysOfMonth || cycle == everyNDays;
}

/// `status.state` / `rows[].state`, most urgent first.
class SettlementState {
  static const overdue = 'overdue';
  static const dueToday = 'due_today';
  static const dueSoon = 'due_soon';

  /// Collections only: an open credit balance on a shop with no terms.
  static const unscheduled = 'unscheduled';
  static const ok = 'ok';

  /// No open balance at all.
  static const none = 'none';

  static const ordered = [overdue, dueToday, dueSoon, unscheduled, ok, none];

  /// Sort rank; an unknown state sorts last rather than first.
  static int rank(String state) {
    final index = ordered.indexOf(state);
    return index < 0 ? ordered.length : index;
  }
}

/// Weekday tokens in the order the chips render them. `DateTime.weekday` is
/// 1 = Monday, so `weekdayTokens[d - 1]` is the token for weekday `d`.
const weekdayTokens = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// The `month_days` token for "the last day of the month".
const monthDayLast = 'last';

/// One customer's settlement terms record.
@freezed
class SettlementTerms with _$SettlementTerms {
  const SettlementTerms._();

  const factory SettlementTerms({
    @JsonKey(fromJson: settlementString) @Default('') String customer,

    /// Absent reads as enabled: the record exists to send reminders.
    @JsonKey(fromJson: settlementBoolDefaultTrue) @Default(true) bool enabled,
    @JsonKey(fromJson: settlementString) @Default('') String cycle,

    /// Comma list of `Mon..Sun`. A JSON list is accepted too.
    @JsonKey(fromJson: settlementCsv) @Default('') String weekdays,
    @JsonKey(name: 'week_interval', fromJson: settlementIntDefaultOne)
    @Default(1)
    int weekInterval,

    /// Comma list of `1..31` and/or `last`. A JSON list is accepted too.
    @JsonKey(name: 'month_days', fromJson: settlementCsv)
    @Default('')
    String monthDays,
    @JsonKey(name: 'interval_days', fromJson: creditIntOrNull)
    int? intervalDays,
    @JsonKey(name: 'anchor_date', fromJson: settlementString)
    @Default('')
    String anchorDate,
    @JsonKey(name: 'remind_days_before', fromJson: creditIntOrNull)
    int? remindDaysBefore,
    @JsonKey(name: 'overdue_repeat_days', fromJson: creditIntOrNull)
    int? overdueRepeatDays,
    @JsonKey(name: 'responsible_user', fromJson: settlementString)
    @Default('')
    String responsibleUser,
    @JsonKey(fromJson: settlementString) @Default('') String notes,

    /// False when the server answered with an empty template for a customer
    /// that has no record yet.
    @JsonKey(fromJson: settlementBoolDefaultTrue) @Default(true) bool exists,
  }) = _SettlementTerms;

  factory SettlementTerms.fromJson(Map<String, dynamic> json) =>
      _$SettlementTermsFromJson(json);

  /// Weekday tokens in Mon..Sun order, unknown tokens dropped.
  List<String> get weekdayList => normalizeWeekdays(weekdays.split(','));

  /// Month days in ascending order with `last` at the end.
  List<String> get monthDayList => normalizeMonthDays(monthDays.split(','));

  /// Server default when the record never set it.
  int get effectiveRemindDaysBefore => remindDaysBefore ?? 1;

  int get effectiveOverdueRepeatDays => overdueRepeatDays ?? 2;
}

/// `compute_status` output.
@freezed
class SettlementStatus with _$SettlementStatus {
  const SettlementStatus._();

  const factory SettlementStatus({
    @JsonKey(fromJson: settlementString) @Default('') String state,
    @JsonKey(name: 'next_due_date', fromJson: settlementString)
    @Default('')
    String nextDueDate,
    @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
    @Default(0.0)
    double nextDueAmount,
    @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
    @Default(0.0)
    double dueNowAmount,
    @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
    @Default(0.0)
    double overdueAmount,
    @JsonKey(name: 'open_balance', fromJson: creditDouble)
    @Default(0.0)
    double openBalance,
    @JsonKey(name: 'oldest_overdue_date', fromJson: settlementString)
    @Default('')
    String oldestOverdueDate,
    @JsonKey(name: 'upcoming_dates', fromJson: settlementStringList)
    @Default(<String>[])
    List<String> upcomingDates,

    /// Invoice after Invoice only: the newest invoice's outstanding, which the
    /// shop settles when the NEXT order arrives.
    @JsonKey(name: 'collect_on_next_delivery', fromJson: creditDoubleOrNull)
    double? collectOnNextDelivery,
  }) = _SettlementStatus;

  factory SettlementStatus.fromJson(Map<String, dynamic> json) =>
      _$SettlementStatusFromJson(json);

  bool get hasNextDue => nextDueDate.trim().isNotEmpty;
}

/// `get_settlement_terms` / `save_settlement_terms`.
@freezed
class SettlementTermsResponse with _$SettlementTermsResponse {
  const SettlementTermsResponse._();

  const factory SettlementTermsResponse({
    @Default(true) bool success,
    @JsonKey(fromJson: settlementString) @Default('') String customer,
    @JsonKey(name: 'customer_name', fromJson: settlementString)
    @Default('')
    String customerName,

    /// Null when the customer has no record.
    SettlementTerms? terms,

    /// The server's English sentence. The UI prefers a localized sentence
    /// built from [terms] and falls back to this one.
    @JsonKey(fromJson: settlementString) @Default('') String description,
    @Default(SettlementStatus()) SettlementStatus status,
    @JsonKey(fromJson: settlementString) @Default('') String currency,

    /// Write gate; absent means read-only.
    @JsonKey(name: 'can_edit', fromJson: creditBool)
    @Default(false)
    bool canEdit,
  }) = _SettlementTermsResponse;

  factory SettlementTermsResponse.fromJson(Map<String, dynamic> json) =>
      _$SettlementTermsResponseFromJson(json);

  /// A real, saved record — not null and not an empty template.
  bool get hasTerms {
    final value = terms;
    return value != null && value.exists && value.cycle.trim().isNotEmpty;
  }
}

/// One row of `get_collections_due`.
///
/// The row's own keys only — `counts` lives on the envelope, and reading a
/// summary key on a row is the exact defect that emptied the credit accounts
/// list in its first week.
@freezed
class CollectionDueRow with _$CollectionDueRow {
  const CollectionDueRow._();

  const factory CollectionDueRow({
    @JsonKey(fromJson: settlementString) @Default('') String customer,
    @JsonKey(name: 'customer_name', fromJson: settlementString)
    @Default('')
    String customerName,

    /// Empty for an `unscheduled` shop (open credit, no terms).
    @JsonKey(fromJson: settlementString) @Default('') String cycle,
    @JsonKey(fromJson: settlementString) @Default('') String description,
    @JsonKey(fromJson: settlementString) @Default('') String state,
    @JsonKey(name: 'next_due_date', fromJson: settlementString)
    @Default('')
    String nextDueDate,
    @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
    @Default(0.0)
    double nextDueAmount,
    @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
    @Default(0.0)
    double dueNowAmount,
    @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
    @Default(0.0)
    double overdueAmount,
    @JsonKey(name: 'open_balance', fromJson: creditDouble)
    @Default(0.0)
    double openBalance,
    @JsonKey(name: 'responsible_user', fromJson: settlementString)
    @Default('')
    String responsibleUser,
  }) = _CollectionDueRow;

  factory CollectionDueRow.fromJson(Map<String, dynamic> json) =>
      _$CollectionDueRowFromJson(json);

  String get displayName {
    final trimmed = customerName.trim();
    return trimmed.isNotEmpty ? trimmed : customer.trim();
  }
}

@freezed
class CollectionsDueCounts with _$CollectionsDueCounts {
  const CollectionsDueCounts._();

  const factory CollectionsDueCounts({
    @JsonKey(fromJson: creditInt) @Default(0) int overdue,
    @JsonKey(name: 'due_today', fromJson: creditInt) @Default(0) int dueToday,
    @JsonKey(name: 'due_soon', fromJson: creditInt) @Default(0) int dueSoon,
  }) = _CollectionsDueCounts;

  factory CollectionsDueCounts.fromJson(Map<String, dynamic> json) =>
      _$CollectionsDueCountsFromJson(json);

  int countFor(String state) => switch (state) {
        SettlementState.overdue => overdue,
        SettlementState.dueToday => dueToday,
        SettlementState.dueSoon => dueSoon,
        _ => 0,
      };
}

/// `get_collections_due`.
@freezed
class CollectionsDue with _$CollectionsDue {
  const CollectionsDue._();

  const factory CollectionsDue({
    @Default(true) bool success,
    @JsonKey(fromJson: settlementString) @Default('') String currency,
    @Default(<CollectionDueRow>[]) List<CollectionDueRow> rows,
    @Default(CollectionsDueCounts()) CollectionsDueCounts counts,
  }) = _CollectionsDue;

  factory CollectionsDue.fromJson(Map<String, dynamic> json) =>
      _$CollectionsDueFromJson(json);

  /// Rows grouped by state in urgency order; empty groups omitted. The server
  /// already sorts, but grouping here keeps the headers right whatever order
  /// arrives.
  List<MapEntry<String, List<CollectionDueRow>>> get grouped {
    final byState = <String, List<CollectionDueRow>>{};
    for (final row in rows) {
      if (row.state == SettlementState.none) continue;
      byState.putIfAbsent(row.state, () => []).add(row);
    }
    final keys = byState.keys.toList()
      ..sort((a, b) => SettlementState.rank(a).compareTo(SettlementState.rank(b)));
    return [for (final key in keys) MapEntry(key, byState[key]!)];
  }
}

/// What the edit sheet sends to `save_settlement_terms`.
///
/// A plain value class rather than a freezed model: it only ever travels OUT,
/// and [toPayload] is the whole contract — tested per cycle.
///
/// Fields that do not belong to the chosen cycle are OMITTED, not sent empty:
/// the server's arguments default to None, so an omitted weekday list on a
/// "Days of Month" shop clears the stale value instead of an empty string
/// failing the Int/list parsing.
class SettlementTermsDraft {
  final String customer;
  final String cycle;
  final bool enabled;
  final List<String> weekdays;
  final int weekInterval;
  final List<String> monthDays;
  final int? intervalDays;
  final String? anchorDate;
  final int remindDaysBefore;
  final int overdueRepeatDays;
  final String? responsibleUser;
  final String? notes;

  const SettlementTermsDraft({
    required this.customer,
    required this.cycle,
    this.enabled = true,
    this.weekdays = const [],
    this.weekInterval = 1,
    this.monthDays = const [],
    this.intervalDays,
    this.anchorDate,
    this.remindDaysBefore = 1,
    this.overdueRepeatDays = 2,
    this.responsibleUser,
    this.notes,
  });

  Map<String, dynamic> toPayload() {
    final anchor = anchorDate?.trim() ?? '';
    final user = responsibleUser?.trim() ?? '';
    final note = notes?.trim() ?? '';
    return {
      'customer': customer,
      'cycle': cycle,
      'enabled': enabled ? 1 : 0,
      if (cycle == SettlementCycle.weekly) ...{
        'weekdays': normalizeWeekdays(weekdays).join(','),
        'week_interval': weekInterval < 1 ? 1 : weekInterval,
        if (weekInterval > 1 && anchor.isNotEmpty) 'anchor_date': anchor,
      },
      if (cycle == SettlementCycle.daysOfMonth)
        'month_days': normalizeMonthDays(monthDays).join(','),
      if (cycle == SettlementCycle.everyNDays) ...{
        'interval_days': intervalDays,
        if (anchor.isNotEmpty) 'anchor_date': anchor,
      },
      'remind_days_before': remindDaysBefore < 0 ? 0 : remindDaysBefore,
      'overdue_repeat_days': overdueRepeatDays < 1 ? 1 : overdueRepeatDays,
      if (user.isNotEmpty) 'responsible_user': user,
      if (note.isNotEmpty) 'notes': note,
    };
  }
}

// ── Normalisers ──────────────────────────────────────────────────────────

/// Mon..Sun order, de-duplicated, case-insensitive, unknown tokens dropped.
List<String> normalizeWeekdays(Iterable<String> raw) {
  final wanted = raw.map((d) => d.trim().toLowerCase()).toSet();
  return [
    for (final token in weekdayTokens)
      if (wanted.contains(token.toLowerCase()) ||
          wanted.any((w) => w.length > 3 && w.startsWith(token.toLowerCase())))
        token,
  ];
}

/// Numeric days ascending (1..31), then `last`; anything else dropped.
List<String> normalizeMonthDays(Iterable<String> raw) {
  final numbers = <int>{};
  var last = false;
  for (final value in raw) {
    final token = value.trim().toLowerCase();
    if (token.isEmpty) continue;
    if (token == monthDayLast) {
      last = true;
      continue;
    }
    final day = int.tryParse(token);
    if (day != null && day >= 1 && day <= 31) numbers.add(day);
  }
  final sorted = numbers.toList()..sort();
  return [for (final d in sorted) '$d', if (last) monthDayLast];
}

// ── Tolerant readers ─────────────────────────────────────────────────────

String settlementString(Object? value) {
  if (value == null) return '';
  return value.toString().trim();
}

bool settlementBoolDefaultTrue(Object? value) {
  if (value == null) return true;
  return creditBool(value);
}

int settlementIntDefaultOne(Object? value) {
  final parsed = creditIntOrNull(value);
  return parsed == null || parsed < 1 ? 1 : parsed;
}

/// A comma string or a JSON list, returned as a trimmed comma string.
String settlementCsv(Object? value) {
  if (value == null) return '';
  if (value is List) {
    return value
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .join(',');
  }
  return value
      .toString()
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .join(',');
}

List<String> settlementStringList(Object? value) {
  if (value is List) {
    return value
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }
  if (value is String && value.trim().isNotEmpty) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return const [];
}
