import 'models/followup_models.dart';

/// Client-side narrowing of today's follow-up list, so the sender can work
/// one kind of customer at a time (calls only, high-value repeat buyers in one
/// territory, ...). Every field left null / empty matches everything.
class FollowupFilter {
  final String query;
  final FollowupChannel? channel;
  final bool overdueOnly;

  /// `New` | `Repeat`.
  final String? customerType;

  /// `High` | `Low`.
  final String? valueBand;
  final bool regularOnly;
  final String? step;
  final String? segment;
  final String? territory;

  const FollowupFilter({
    this.query = '',
    this.channel,
    this.overdueOnly = false,
    this.customerType,
    this.valueBand,
    this.regularOnly = false,
    this.step,
    this.segment,
    this.territory,
  });

  static const none = FollowupFilter();

  bool get isActive =>
      query.trim().isNotEmpty ||
      channel != null ||
      overdueOnly ||
      customerType != null ||
      valueBand != null ||
      regularOnly ||
      step != null ||
      segment != null ||
      territory != null;

  /// A copy with the given fields replaced. Pass `clear*: true` to reset a
  /// nullable field, since `null` already means "keep".
  FollowupFilter copyWith({
    String? query,
    FollowupChannel? channel,
    bool clearChannel = false,
    bool? overdueOnly,
    String? customerType,
    bool clearCustomerType = false,
    String? valueBand,
    bool clearValueBand = false,
    bool? regularOnly,
    String? step,
    bool clearStep = false,
    String? segment,
    bool clearSegment = false,
    String? territory,
    bool clearTerritory = false,
  }) =>
      FollowupFilter(
        query: query ?? this.query,
        channel: clearChannel ? null : (channel ?? this.channel),
        overdueOnly: overdueOnly ?? this.overdueOnly,
        customerType:
            clearCustomerType ? null : (customerType ?? this.customerType),
        valueBand: clearValueBand ? null : (valueBand ?? this.valueBand),
        regularOnly: regularOnly ?? this.regularOnly,
        step: clearStep ? null : (step ?? this.step),
        segment: clearSegment ? null : (segment ?? this.segment),
        territory: clearTerritory ? null : (territory ?? this.territory),
      );

  bool matches(FollowupRow row) {
    if (channel != null && row.channel != channel) return false;
    if (overdueOnly && !row.isOverdue) return false;
    if (customerType != null &&
        row.customerType.toLowerCase() != customerType!.toLowerCase()) {
      return false;
    }
    if (valueBand != null &&
        row.valueBand.toLowerCase() != valueBand!.toLowerCase()) {
      return false;
    }
    if (regularOnly && !row.rfmIsRegular) return false;
    if (step != null && row.step.toLowerCase() != step!.toLowerCase()) {
      return false;
    }
    if (segment != null && (row.customerSegment ?? '') != segment) return false;
    if (territory != null && row.territory.trim() != territory) return false;
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final digits = q.replaceAll(RegExp(r'\D'), '');
      final text = '${row.customerName} ${row.customer} ${row.invoice}'
          .toLowerCase();
      final phoneDigits =
          '${row.phone} ${row.whatsappMsisdn}'.replaceAll(RegExp(r'\D'), '');
      final byText = text.contains(q);
      // "010..." should find "2010..." and the reverse, so compare without
      // the leading zero / country code.
      final core = digits.replaceFirst(RegExp(r'^(20|0)'), '');
      final byPhone = core.length >= 3 && phoneDigits.contains(core);
      if (!byText && !byPhone) return false;
    }
    return true;
  }

  List<FollowupRow> apply(List<FollowupRow> rows) =>
      isActive ? rows.where(matches).toList(growable: false) : rows;
}

/// The distinct values present in [rows], for the filter menus.
class FollowupFilterOptions {
  final List<String> steps;
  final List<String> segments;
  final List<String> territories;

  const FollowupFilterOptions({
    this.steps = const [],
    this.segments = const [],
    this.territories = const [],
  });

  factory FollowupFilterOptions.of(List<FollowupRow> rows) {
    final steps = <String>{};
    final segments = <String>{};
    final territories = <String>{};
    for (final r in rows) {
      if (r.step.isNotEmpty) steps.add(r.step);
      final seg = r.customerSegment;
      if (seg != null && seg.isNotEmpty) segments.add(seg);
      final t = r.territory.trim();
      if (t.isNotEmpty) territories.add(t);
    }
    int stepOrder(String s) {
      if (s.toLowerCase() == '3h') return 0;
      final m = RegExp(r'^day(\d+)$').firstMatch(s.toLowerCase());
      return m == null ? 9999 : int.parse(m.group(1)!);
    }

    return FollowupFilterOptions(
      steps: steps.toList()..sort((a, b) => stepOrder(a) - stepOrder(b)),
      segments: segments.toList()..sort(),
      territories: territories.toList()..sort(),
    );
  }
}
