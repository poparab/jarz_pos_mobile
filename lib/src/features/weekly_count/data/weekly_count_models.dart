/// Wire models for `jarz_pos.api.branch_weekly_count`.
///
/// Plain classes rather than freezed: the payloads are read-only snapshots,
/// and keeping them hand-written means no build_runner step for this feature.
library;

int _asInt(dynamic v, [int fallback = 0]) {
  if (v is num) return v.toInt();
  return int.tryParse('${v ?? ''}') ?? fallback;
}

int? _asIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  final parsed = num.tryParse('$v');
  return parsed?.toInt();
}

double? _asDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse('$v');
}

bool _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return false;
}

String? _asStringOrNull(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

String _asString(dynamic v) => v?.toString() ?? '';

Map<String, dynamic>? _asMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : null;

List<Map<String, dynamic>> _asMapList(dynamic v) => (v is List ? v : const [])
    .whereType<Map>()
    .map((e) => Map<String, dynamic>.from(e))
    .toList(growable: false);

/// A branch's weekly-count state for the current week.
enum WeeklyCountState {
  due,
  pendingApproval,
  done,
  rejected,

  /// A value this build does not know. Treated like [due] for the sheet (the
  /// server refuses anything it should not accept) but never shown as done.
  unknown;

  static WeeklyCountState parse(dynamic raw) {
    switch (_asString(raw).trim().toLowerCase()) {
      case 'due':
        return WeeklyCountState.due;
      case 'pending_approval':
        return WeeklyCountState.pendingApproval;
      case 'done':
        return WeeklyCountState.done;
      case 'rejected':
        return WeeklyCountState.rejected;
      default:
        return WeeklyCountState.unknown;
    }
  }

  /// Still has to be counted this week.
  bool get needsCount =>
      this == WeeklyCountState.due || this == WeeklyCountState.rejected;
}

/// Document statuses as the server spells them.
abstract final class WeeklyCountDocStatus {
  static const pendingApproval = 'Pending Approval';
  static const approved = 'Approved';
  static const rejected = 'Rejected';
  static const cancelled = 'Cancelled';
}

/// The `count` block inside a status/sheet branch: this week's latest count.
class WeeklyCountRef {
  final String name;
  final String status;
  final String? countedBy;
  final String? countedByName;
  final String? countedAt;
  final String? approvedByName;
  final String? rejectionReason;

  const WeeklyCountRef({
    required this.name,
    required this.status,
    this.countedBy,
    this.countedByName,
    this.countedAt,
    this.approvedByName,
    this.rejectionReason,
  });

  /// Who to name on a card: the full name, else the login.
  String get counterLabel => countedByName ?? countedBy ?? '';

  static WeeklyCountRef? fromJson(dynamic raw) {
    final json = _asMap(raw);
    if (json == null) return null;
    return WeeklyCountRef(
      name: _asString(json['name']),
      status: _asString(json['status']),
      countedBy: _asStringOrNull(json['counted_by']),
      countedByName: _asStringOrNull(json['counted_by_name']),
      countedAt: _asStringOrNull(json['counted_at']),
      approvedByName: _asStringOrNull(json['approved_by_name']),
      rejectionReason: _asStringOrNull(json['rejection_reason']),
    );
  }
}

/// One branch the caller may count.
class WeeklyCountBranch {
  final String posProfile;
  final String warehouse;
  final bool isMember;
  final WeeklyCountState state;
  final bool lastDay;
  final bool missedLastWeek;
  final WeeklyCountRef? count;

  const WeeklyCountBranch({
    required this.posProfile,
    required this.warehouse,
    required this.isMember,
    required this.state,
    required this.lastDay,
    required this.missedLastWeek,
    this.count,
  });

  /// The banner goes red: last day, last week missed, or a rejected count.
  bool get urgent =>
      lastDay || missedLastWeek || state == WeeklyCountState.rejected;

  factory WeeklyCountBranch.fromJson(Map<String, dynamic> json) {
    return WeeklyCountBranch(
      posProfile: _asString(json['pos_profile']),
      warehouse: _asString(json['warehouse']),
      isMember: _asBool(json['is_member']),
      state: WeeklyCountState.parse(json['state']),
      lastDay: _asBool(json['last_day']),
      missedLastWeek: _asBool(json['missed_last_week']),
      count: WeeklyCountRef.fromJson(json['count']),
    );
  }
}

/// `get_weekly_count_status`.
class WeeklyCountStatus {
  final String weekStart;
  final String dueDate;
  final String today;
  final int daysLeft;
  final bool isApprover;
  final int pendingApprovalCount;
  final List<WeeklyCountBranch> branches;
  final DateTime fetchedAt;

  const WeeklyCountStatus({
    required this.weekStart,
    required this.dueDate,
    required this.today,
    required this.daysLeft,
    required this.isApprover,
    required this.pendingApprovalCount,
    required this.branches,
    required this.fetchedAt,
  });

  factory WeeklyCountStatus.fromJson(Map<String, dynamic> json) {
    return WeeklyCountStatus(
      weekStart: _asString(json['week_start']),
      dueDate: _asString(json['due_date']),
      today: _asString(json['today']),
      daysLeft: _asInt(json['days_left']),
      isApprover: _asBool(json['is_approver']),
      pendingApprovalCount: _asInt(json['pending_approval_count']),
      branches: _asMapList(json['branches'])
          .map(WeeklyCountBranch.fromJson)
          .where((b) => b.posProfile.isNotEmpty)
          .toList(growable: false),
      fetchedAt: DateTime.now(),
    );
  }

  List<WeeklyCountBranch> get memberBranches =>
      branches.where((b) => b.isMember).toList(growable: false);

  /// Member branches that still owe this week's count — what the banner and
  /// the drawer dot are about. Non-member branches (a global user's view of
  /// every branch) never raise the banner.
  List<WeeklyCountBranch> get dueMemberBranches => branches
      .where((b) => b.isMember && b.state.needsCount)
      .toList(growable: false);

  bool get hasDue => dueMemberBranches.isNotEmpty;

  bool get urgent => dueMemberBranches.any((b) => b.urgent);

  bool get hasRejected =>
      dueMemberBranches.any((b) => b.state == WeeklyCountState.rejected);

  /// Anyone with at least one branch to count sees the drawer entry.
  bool get canCount => branches.isNotEmpty;

  WeeklyCountBranch? branchNamed(String posProfile) {
    for (final b in branches) {
      if (b.posProfile == posProfile) return b;
    }
    return null;
  }
}

/// One item on the count sheet. No quantities: the count is blind.
class WeeklyCountSheetItem {
  final String itemCode;
  final String itemName;
  final String stockUom;
  final String? image;

  const WeeklyCountSheetItem({
    required this.itemCode,
    required this.itemName,
    required this.stockUom,
    this.image,
  });

  factory WeeklyCountSheetItem.fromJson(Map<String, dynamic> json) {
    final code = _asString(json['item_code']);
    return WeeklyCountSheetItem(
      itemCode: code,
      itemName: _asStringOrNull(json['item_name']) ?? code,
      stockUom: _asString(json['stock_uom']),
      image: _asStringOrNull(json['image']),
    );
  }
}

class WeeklyCountSection {
  final String key;
  final String title;
  final List<WeeklyCountSheetItem> items;

  const WeeklyCountSection({
    required this.key,
    required this.title,
    required this.items,
  });

  factory WeeklyCountSection.fromJson(Map<String, dynamic> json) {
    final key = _asString(json['key']);
    return WeeklyCountSection(
      key: key,
      title: _asStringOrNull(json['title']) ?? key,
      items: _asMapList(json['items'])
          .map(WeeklyCountSheetItem.fromJson)
          .where((i) => i.itemCode.isNotEmpty)
          .toList(growable: false),
    );
  }
}

/// `get_weekly_count_sheet`.
class WeeklyCountSheet {
  final String posProfile;
  final String warehouse;
  final String weekStart;
  final String dueDate;
  final bool isApprover;
  final WeeklyCountState state;
  final WeeklyCountRef? count;
  final int totalItems;
  final List<WeeklyCountSection> sections;

  const WeeklyCountSheet({
    required this.posProfile,
    required this.warehouse,
    required this.weekStart,
    required this.dueDate,
    required this.isApprover,
    required this.state,
    required this.count,
    required this.totalItems,
    required this.sections,
  });

  factory WeeklyCountSheet.fromJson(Map<String, dynamic> json) {
    final sections = _asMapList(json['sections'])
        .map(WeeklyCountSection.fromJson)
        .where((s) => s.items.isNotEmpty)
        .toList(growable: false);
    final itemCount = sections.fold<int>(0, (n, s) => n + s.items.length);
    return WeeklyCountSheet(
      posProfile: _asString(json['pos_profile']),
      warehouse: _asString(json['warehouse']),
      weekStart: _asString(json['week_start']),
      dueDate: _asString(json['due_date']),
      isApprover: _asBool(json['is_approver']),
      state: WeeklyCountState.parse(json['state']),
      count: WeeklyCountRef.fromJson(json['count']),
      totalItems: _asInt(json['total_items'], itemCount),
      sections: sections,
    );
  }

  /// Every item in sheet order. An item code listed in two sections (it
  /// should not happen) is kept once, where it first appears.
  List<WeeklyCountSheetItem> get allItems {
    final seen = <String>{};
    return [
      for (final s in sections)
        for (final i in s.items)
          if (seen.add(i.itemCode)) i,
    ];
  }

  List<String> get itemCodes => [for (final i in allItems) i.itemCode];
}

/// `submit_weekly_count`.
class WeeklyCountSubmitResult {
  final bool ok;
  final String name;
  final String status;
  final bool autoApproved;
  final String? stockReconciliation;
  final int? differencesCount;
  final int totalItems;

  const WeeklyCountSubmitResult({
    required this.ok,
    required this.name,
    required this.status,
    required this.autoApproved,
    this.stockReconciliation,
    this.differencesCount,
    required this.totalItems,
  });

  /// Stock already moved: auto-approved, or the server says Approved.
  bool get posted => autoApproved || status == WeeklyCountDocStatus.approved;

  factory WeeklyCountSubmitResult.fromJson(Map<String, dynamic> json) {
    return WeeklyCountSubmitResult(
      ok: json['ok'] == null ? true : _asBool(json['ok']),
      name: _asString(json['name']),
      status: _asString(json['status']),
      autoApproved: _asBool(json['auto_approved']),
      stockReconciliation: _asStringOrNull(json['stock_reconciliation']),
      differencesCount: _asIntOrNull(json['differences_count']),
      totalItems: _asInt(json['total_items']),
    );
  }
}

/// One row of `list_weekly_counts`, and the header of `get_weekly_count`.
class WeeklyCountSummary {
  final String name;
  final String posProfile;
  final String weekStart;
  final String status;
  final String? countedBy;
  final String? countedByName;
  final String? countedAt;
  final String? approvedByName;
  final String? approvedAt;
  final String? rejectionReason;
  final int totalItems;

  /// Null for a non-approver: the count is blind for them.
  final int? differencesCount;
  final String? stockReconciliation;

  const WeeklyCountSummary({
    required this.name,
    required this.posProfile,
    required this.weekStart,
    required this.status,
    this.countedBy,
    this.countedByName,
    this.countedAt,
    this.approvedByName,
    this.approvedAt,
    this.rejectionReason,
    required this.totalItems,
    this.differencesCount,
    this.stockReconciliation,
  });

  bool get isPending => status == WeeklyCountDocStatus.pendingApproval;

  String get counterLabel => countedByName ?? countedBy ?? '';

  factory WeeklyCountSummary.fromJson(Map<String, dynamic> json) {
    return WeeklyCountSummary(
      name: _asString(json['name']),
      posProfile: _asString(json['pos_profile']),
      weekStart: _asString(json['week_start']),
      status: _asString(json['status']),
      countedBy: _asStringOrNull(json['counted_by']),
      countedByName: _asStringOrNull(json['counted_by_name']),
      countedAt: _asStringOrNull(json['counted_at']),
      approvedByName: _asStringOrNull(json['approved_by_name']),
      approvedAt: _asStringOrNull(json['approved_at']),
      rejectionReason: _asStringOrNull(json['rejection_reason']),
      totalItems: _asInt(json['total_items']),
      differencesCount: _asIntOrNull(json['differences_count']),
      stockReconciliation: _asStringOrNull(json['stock_reconciliation']),
    );
  }
}

/// A line of `get_weekly_count`.
class WeeklyCountLine {
  final String itemCode;
  final String itemName;
  final String itemGroup;
  final String stockUom;
  final double countedQty;

  /// Null for a non-approver.
  final double? systemQty;
  final double? difference;

  const WeeklyCountLine({
    required this.itemCode,
    required this.itemName,
    required this.itemGroup,
    required this.stockUom,
    required this.countedQty,
    this.systemQty,
    this.difference,
  });

  /// The difference as sent, or derived when only the system qty came back.
  double? get effectiveDifference =>
      difference ?? (systemQty == null ? null : countedQty - systemQty!);

  bool get hasDifference {
    final d = effectiveDifference;
    return d != null && d.abs() > 1e-9;
  }

  factory WeeklyCountLine.fromJson(Map<String, dynamic> json) {
    final code = _asString(json['item_code']);
    return WeeklyCountLine(
      itemCode: code,
      itemName: _asStringOrNull(json['item_name']) ?? code,
      itemGroup: _asString(json['item_group']),
      stockUom: _asString(json['stock_uom']),
      countedQty: _asDoubleOrNull(json['counted_qty']) ?? 0,
      systemQty: _asDoubleOrNull(json['system_qty']),
      difference: _asDoubleOrNull(json['difference']),
    );
  }
}

/// `get_weekly_count`.
class WeeklyCountDetail {
  final WeeklyCountSummary header;
  final bool canApprove;
  final List<WeeklyCountLine> lines;

  const WeeklyCountDetail({
    required this.header,
    required this.canApprove,
    required this.lines,
  });

  /// The caller sees system quantities only when the server sent them.
  bool get showsSystemQty => lines.any((l) => l.systemQty != null);

  List<WeeklyCountLine> get differenceLines =>
      lines.where((l) => l.hasDifference).toList(growable: false);

  List<WeeklyCountLine> get unchangedLines =>
      lines.where((l) => !l.hasDifference).toList(growable: false);

  factory WeeklyCountDetail.fromJson(Map<String, dynamic> json) {
    final lines = _asMapList(
      json['lines'],
    ).map(WeeklyCountLine.fromJson).toList(growable: false);
    final header = WeeklyCountSummary.fromJson(json);
    return WeeklyCountDetail(
      header: header.totalItems == 0 && lines.isNotEmpty
          ? WeeklyCountSummary(
              name: header.name,
              posProfile: header.posProfile,
              weekStart: header.weekStart,
              status: header.status,
              countedBy: header.countedBy,
              countedByName: header.countedByName,
              countedAt: header.countedAt,
              approvedByName: header.approvedByName,
              approvedAt: header.approvedAt,
              rejectionReason: header.rejectionReason,
              totalItems: lines.length,
              differencesCount: header.differencesCount,
              stockReconciliation: header.stockReconciliation,
            )
          : header,
      canApprove: _asBool(json['can_approve']),
      lines: lines,
    );
  }
}
