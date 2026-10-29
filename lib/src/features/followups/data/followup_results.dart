// Pure helpers behind the follow-up results screen: the date range, the
// message filter, the reply and order lists. No widgets here so every rule is
// unit-testable.
import 'package:intl/intl.dart';

import 'models/followup_models.dart';

/// The quick ranges of the results page.
enum FollowupRangePreset { last7, last30, thisMonth, custom }

/// A date range, as the `from_date` / `to_date` the API takes.
class FollowupRange {
  final FollowupRangePreset preset;
  final DateTime from;
  final DateTime to;

  const FollowupRange._(this.preset, this.from, this.to);

  /// A preset resolved against [now] (date part only).
  factory FollowupRange.preset(FollowupRangePreset preset, {DateTime? now}) {
    final today = _day(now ?? DateTime.now());
    switch (preset) {
      case FollowupRangePreset.last30:
        return FollowupRange._(preset, _addDays(today, -29), today);
      case FollowupRangePreset.thisMonth:
        return FollowupRange._(
          preset,
          DateTime(today.year, today.month),
          today,
        );
      case FollowupRangePreset.last7:
      case FollowupRangePreset.custom:
        return FollowupRange._(
          FollowupRangePreset.last7,
          _addDays(today, -6),
          today,
        );
    }
  }

  factory FollowupRange.custom(DateTime from, DateTime to) {
    var a = _day(from);
    var b = _day(to);
    if (b.isBefore(a)) {
      final t = a;
      a = b;
      b = t;
    }
    return FollowupRange._(FollowupRangePreset.custom, a, b);
  }

  static final DateFormat _fmt = DateFormat('yyyy-MM-dd');

  String get fromDate => _fmt.format(from);
  String get toDate => _fmt.format(to);

  @override
  bool operator ==(Object other) =>
      other is FollowupRange &&
      other.preset == preset &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(preset, from, to);

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  // Calendar arithmetic, not Duration: a DST change must not shift the day.
  static DateTime _addDays(DateTime d, int days) =>
      DateTime(d.year, d.month, d.day + days);
}

/// What became of a message, for the outcome filter chips.
enum FollowupMessageOutcome { replied, ordered, usedCode, noResponse }

/// The Messages tab filter. Within one group the chips are OR, between groups
/// AND; an empty group does not filter.
class FollowupMessageFilter {
  final String query;
  final Set<String> steps;

  /// `delivered` (delivered or read), `read`, `failed`.
  final Set<String> statuses;
  final Set<FollowupMessageOutcome> outcomes;

  /// One customer by ID, matched exactly ("all messages to this customer"), so
  /// two customers sharing a name never merge. [customerName] is its label.
  final String customer;
  final String customerName;

  const FollowupMessageFilter({
    this.query = '',
    this.steps = const <String>{},
    this.statuses = const <String>{},
    this.outcomes = const <FollowupMessageOutcome>{},
    this.customer = '',
    this.customerName = '',
  });

  bool get isActive =>
      query.trim().isNotEmpty ||
      steps.isNotEmpty ||
      statuses.isNotEmpty ||
      outcomes.isNotEmpty ||
      customer.isNotEmpty;

  FollowupMessageFilter copyWith({
    String? query,
    Set<String>? steps,
    Set<String>? statuses,
    Set<FollowupMessageOutcome>? outcomes,
    String? customer,
    String? customerName,
  }) => FollowupMessageFilter(
    query: query ?? this.query,
    steps: steps ?? this.steps,
    statuses: statuses ?? this.statuses,
    outcomes: outcomes ?? this.outcomes,
    customer: customer ?? this.customer,
    customerName: customerName ?? this.customerName,
  );

  /// Toggles [value] in [set], returning a new set.
  static Set<T> toggle<T>(Set<T> set, T value) =>
      set.contains(value) ? ({...set}..remove(value)) : {...set, value};
}

/// Digits only, so `0101 234-5678` finds `01012345678`.
String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');

bool _matchesQuery(FollowupSentItem item, String rawQuery) {
  final q = rawQuery.trim().toLowerCase();
  if (q.isEmpty) return true;
  bool has(String v) => v.toLowerCase().contains(q);
  if (has(item.customerName) ||
      has(item.customer) ||
      has(item.phone) ||
      has(item.offerCode) ||
      has(item.reorderInvoice) ||
      has(item.orderNo)) {
    return true;
  }
  for (final o in item.orders) {
    if (has(o.invoice) || has(o.wooOrderId)) return true;
  }
  final qDigits = _digits(q);
  return qDigits.length >= 3 && _digits(item.phone).contains(qDigits);
}

bool _matchesStatus(FollowupSentItem item, Set<String> statuses) {
  if (statuses.isEmpty) return true;
  final st = item.waStatus.toLowerCase();
  return statuses.any(
    (s) => switch (s) {
      'delivered' => st == 'delivered' || st == 'read',
      _ => st == s,
    },
  );
}

bool _matchesOutcome(
  FollowupSentItem item,
  Set<FollowupMessageOutcome> outcomes,
) {
  if (outcomes.isEmpty) return true;
  return outcomes.any(
    (o) => switch (o) {
      FollowupMessageOutcome.replied => item.replied,
      FollowupMessageOutcome.ordered => item.reordered,
      FollowupMessageOutcome.usedCode => item.codeUsed,
      FollowupMessageOutcome.noResponse => !item.replied && !item.reordered,
    },
  );
}

/// The messages that pass [filter], in their original order.
List<FollowupSentItem> filterSentItems(
  List<FollowupSentItem> items,
  FollowupMessageFilter filter,
) {
  if (!filter.isActive) return items;
  return [
    for (final item in items)
      if ((filter.customer.isEmpty || item.customer == filter.customer) &&
          _matchesQuery(item, filter.query) &&
          (filter.steps.isEmpty || filter.steps.contains(item.step)) &&
          _matchesStatus(item, filter.statuses) &&
          _matchesOutcome(item, filter.outcomes))
        item,
  ];
}

/// Distinct steps present in [items], in a stable order (`3h` first, then by
/// day number, anything else alphabetically).
List<String> sentItemSteps(List<FollowupSentItem> items) {
  final steps = {
    for (final i in items)
      if (i.step.isNotEmpty) i.step,
  }.toList();
  int rank(String s) {
    if (s.toLowerCase() == '3h') return -1;
    final m = RegExp(r'(\d+)').firstMatch(s);
    return m == null ? 100000 : int.parse(m.group(1)!);
  }

  steps.sort((a, b) {
    final c = rank(a).compareTo(rank(b));
    return c != 0 ? c : a.compareTo(b);
  });
  return steps;
}

/// Messages with at least one reply, the one with the latest reply first.
List<FollowupSentItem> repliedItems(List<FollowupSentItem> items) {
  String latest(FollowupSentItem i) {
    var at = '';
    for (final r in i.replies) {
      if (r.at.compareTo(at) > 0) at = r.at;
    }
    return at.isEmpty ? i.sentAt : at;
  }

  final out = [
    for (final i in items)
      if (i.replied) i,
  ];
  out.sort((a, b) => latest(b).compareTo(latest(a)));
  return out;
}

/// An order with the follow-up message that preceded it.
class FollowupOrderRow {
  final FollowupSentOrder order;
  final FollowupSentItem item;

  const FollowupOrderRow(this.order, this.item);
}

/// Every distinct order across [items], newest first. One invoice can follow
/// two messages; it is listed once, against the latest message sent before it
/// (the one closest to the order), and marked as using a code when any of the
/// duplicates says so.
List<FollowupOrderRow> distinctOrders(List<FollowupSentItem> items) {
  final byInvoice = <String, FollowupOrderRow>{};
  for (final item in items) {
    for (final order in item.orders) {
      final key = order.invoice.isNotEmpty ? order.invoice : order.wooOrderId;
      if (key.isEmpty) continue;
      final existing = byInvoice[key];
      if (existing == null) {
        byInvoice[key] = FollowupOrderRow(order, item);
        continue;
      }
      final newer = item.sentAt.compareTo(existing.item.sentAt) > 0;
      final merged = FollowupSentOrder(
        invoice: existing.order.invoice,
        at: existing.order.at,
        grandTotal: existing.order.grandTotal,
        wooOrderId: existing.order.wooOrderId.isNotEmpty
            ? existing.order.wooOrderId
            : order.wooOrderId,
        usedCode: existing.order.usedCode || order.usedCode,
      );
      byInvoice[key] = FollowupOrderRow(merged, newer ? item : existing.item);
    }
  }
  return byInvoice.values.toList()
    ..sort((a, b) => b.order.at.compareTo(a.order.at));
}

/// Sum of the amounts of [rows].
double ordersTotal(List<FollowupOrderRow> rows) =>
    rows.fold<double>(0, (sum, r) => sum + r.order.grandTotal);
