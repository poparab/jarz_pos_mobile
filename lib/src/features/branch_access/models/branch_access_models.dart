/// Branch access models — who may open which branch's POS.
///
/// Plain classes with hand-written, defensive `fromJson` (the roster feature's
/// style): every field tolerates absence, a null, or a 0/1 in place of a bool,
/// so a backend that adds or omits a key does not take the screen down.
library;

/// The shift currently open on a branch. While one exists the server refuses
/// every membership change on that branch.
class BranchOpenShift {
  const BranchOpenShift({
    required this.name,
    this.user,
    this.userFullName,
    this.since,
  });

  final String name;
  final String? user;
  final String? userFullName;

  /// Server-local datetime string (`YYYY-MM-DD HH:MM:SS`), as Frappe sends it.
  final String? since;

  /// Who holds the shift, best name first.
  String get holder => userFullName ?? user ?? '';

  DateTime? get sinceTime => since == null ? null : DateTime.tryParse(since!);

  factory BranchOpenShift.fromJson(Map<String, dynamic> json) =>
      BranchOpenShift(
        name: (json['name'] ?? '').toString(),
        user: _nullIfBlank(json['user']),
        userFullName: _nullIfBlank(json['user_full_name']),
        since: _nullIfBlank(json['since']),
      );
}

/// One enabled POS Profile, as the caller sees it.
class BranchAccessBranch {
  const BranchAccessBranch({
    required this.posProfile,
    this.shiftLocation,
    this.manageable = false,
    this.openShift,
  });

  final String posProfile;
  final String? shiftLocation;

  /// Whether the caller may change membership on this branch at all.
  final bool manageable;
  final BranchOpenShift? openShift;

  bool get isOpen => openShift != null;

  /// Manageable and closed — the only state in which a change can succeed.
  bool get isEditable => manageable && !isOpen;

  factory BranchAccessBranch.fromJson(Map<String, dynamic> json) {
    final open = json['open_shift'];
    return BranchAccessBranch(
      posProfile: (json['pos_profile'] ?? '').toString(),
      shiftLocation: _nullIfBlank(json['shift_location']),
      manageable: _toBool(json['manageable']),
      openShift: open is Map
          ? BranchOpenShift.fromJson(Map<String, dynamic>.from(open))
          : null,
    );
  }
}

/// One day's POS access (`Jarz POS Day Access`).
class DayAccess {
  const DayAccess({
    required this.name,
    required this.posProfile,
    required this.accessDate,
    required this.status,
    this.startsAt,
    this.expiresAt,
    this.rowAdded = false,
  });

  final String name;
  final String posProfile;

  /// ISO date (`YYYY-MM-DD`).
  final String accessDate;

  /// `Scheduled` | `Active` | `Ended` | `Cancelled`.
  final String status;
  final String? startsAt;
  final String? expiresAt;

  /// True only when THIS grant inserted the POS Profile User row. False means
  /// the person already had permanent access, so the membership is not
  /// temporary even though a grant exists.
  final bool rowAdded;

  bool get isActive => status == 'Active';
  bool get isScheduled => status == 'Scheduled';

  factory DayAccess.fromJson(Map<String, dynamic> json) => DayAccess(
    name: (json['name'] ?? '').toString(),
    posProfile: (json['pos_profile'] ?? '').toString(),
    accessDate: (json['access_date'] ?? '').toString(),
    status: (json['status'] ?? '').toString(),
    startsAt: _nullIfBlank(json['starts_at']),
    expiresAt: _nullIfBlank(json['expires_at']),
    rowAdded: _toBool(json['row_added']),
  );
}

/// What one person's chip on one branch should say.
enum BranchMembershipState {
  /// Permanent POS Profile User row.
  member,

  /// The row exists only because an Active day access inserted it.
  dayAccessActive,

  /// No row yet; a Scheduled day access will add one.
  dayAccessScheduled,

  /// No access to this branch.
  none,
}

class BranchAccessUser {
  const BranchAccessUser({
    required this.user,
    required this.fullName,
    this.employee,
    this.employeeName,
    this.enabled = true,
    this.isSelf = false,
    this.editable,
    this.branches = const [],
    this.dayAccess = const [],
  });

  final String user;
  final String fullName;
  final String? employee;
  final String? employeeName;
  final bool enabled;
  final bool isSelf;

  /// Whether the caller may change this person's access at all. False for a
  /// line manager's own row and for a manager / line manager target. Null
  /// when the backend does not send it (older server): callers then fall
  /// back to the own-row rule alone.
  final bool? editable;

  /// Whether the caller is barred from changing this person's access.
  bool isLockedFor({required bool canManageAll}) {
    final flag = editable;
    if (flag != null) return !flag;
    return isSelf && !canManageAll;
  }

  /// Current POS Profile User memberships (enabled profiles only). Includes
  /// rows that exist only because of an Active day access.
  final List<String> branches;

  /// Scheduled and Active day accesses only.
  final List<DayAccess> dayAccess;

  String get displayName => fullName.isNotEmpty ? fullName : user;

  List<DayAccess> dayAccessFor(String posProfile) =>
      dayAccess.where((d) => d.posProfile == posProfile).toList();

  /// Whether the row for [posProfile] is there only because a day access put it
  /// there — i.e. it will disappear when that day ends.
  bool isTemporaryOn(String posProfile) =>
      branches.contains(posProfile) &&
      dayAccess.any(
        (d) => d.posProfile == posProfile && d.isActive && d.rowAdded,
      );

  bool isPermanentOn(String posProfile) =>
      branches.contains(posProfile) && !isTemporaryOn(posProfile);

  BranchMembershipState stateOn(String posProfile) {
    if (isPermanentOn(posProfile)) return BranchMembershipState.member;
    if (isTemporaryOn(posProfile)) {
      return BranchMembershipState.dayAccessActive;
    }
    if (dayAccessFor(posProfile).any((d) => d.isScheduled || d.isActive)) {
      return BranchMembershipState.dayAccessScheduled;
    }
    return BranchMembershipState.none;
  }

  /// Case-insensitive match on every name the manager might type.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [
      fullName,
      user,
      employee ?? '',
      employeeName ?? '',
    ].any((value) => value.toLowerCase().contains(q));
  }

  factory BranchAccessUser.fromJson(Map<String, dynamic> json) =>
      BranchAccessUser(
        user: (json['user'] ?? '').toString(),
        fullName: (json['full_name'] ?? '').toString(),
        employee: _nullIfBlank(json['employee']),
        employeeName: _nullIfBlank(json['employee_name']),
        enabled: json['enabled'] == null ? true : _toBool(json['enabled']),
        isSelf: _toBool(json['is_self']),
        editable: json['editable'] == null ? null : _toBool(json['editable']),
        branches: (json['branches'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        dayAccess: (json['day_access'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((e) => DayAccess.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

/// `get_branch_access` — the whole screen in one call.
class BranchAccessOverview {
  const BranchAccessOverview({
    required this.canManageAll,
    required this.branches,
    required this.users,
  });

  final bool canManageAll;
  final List<BranchAccessBranch> branches;
  final List<BranchAccessUser> users;

  BranchAccessBranch? branch(String posProfile) {
    for (final b in branches) {
      if (b.posProfile == posProfile) return b;
    }
    return null;
  }

  factory BranchAccessOverview.fromJson(Map<String, dynamic> json) =>
      BranchAccessOverview(
        canManageAll: _toBool(json['can_manage_all']),
        branches: (json['branches'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (e) => BranchAccessBranch.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
        users: (json['users'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((e) => BranchAccessUser.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

/// `set_branch_access`.
class SetBranchAccessResult {
  const SetBranchAccessResult({
    required this.changed,
    required this.user,
    required this.posProfile,
    required this.allowed,
  });

  /// False when the person was already in the requested state (nothing logged).
  final bool changed;
  final String user;
  final String posProfile;
  final bool allowed;

  factory SetBranchAccessResult.fromJson(Map<String, dynamic> json) =>
      SetBranchAccessResult(
        changed: _toBool(json['changed']),
        user: (json['user'] ?? '').toString(),
        posProfile: (json['pos_profile'] ?? '').toString(),
        allowed: _toBool(json['allowed']),
      );
}

/// `grant_day_access` / `cancel_day_access`.
class DayAccessResult {
  const DayAccessResult({this.dayAccess, this.message});

  final DayAccess? dayAccess;

  /// The server's own sentence, shown as-is.
  final String? message;

  factory DayAccessResult.fromJson(Map<String, dynamic> json) {
    final raw = json['day_access'];
    return DayAccessResult(
      dayAccess: raw is Map
          ? DayAccess.fromJson(Map<String, dynamic>.from(raw))
          : null,
      message: _nullIfBlank(json['message']),
    );
  }
}

/// One `Jarz Branch Access Log` row.
class BranchAccessLogEntry {
  const BranchAccessLogEntry({
    required this.name,
    required this.creation,
    required this.user,
    required this.posProfile,
    required this.action,
    this.userFullName,
    this.employeeName,
    this.source,
    this.notes,
    this.changedBy,
    this.changedByName,
    this.dayAccess,
  });

  final String name;
  final String creation;
  final String user;
  final String? userFullName;
  final String? employeeName;
  final String posProfile;

  /// `Added` | `Removed` | `Day Access Scheduled` | `Day Access Started` |
  /// `Day Access Ended` | `Day Access Cancelled`.
  final String action;

  /// `Branch Access Screen` | `Shift Assignment` | `Day Off Cover` | `Scheduler`.
  final String? source;
  final String? notes;
  final String? changedBy;
  final String? changedByName;
  final String? dayAccess;

  String get subjectName => userFullName ?? employeeName ?? user;
  String get actorName => changedByName ?? changedBy ?? '';
  DateTime? get creationTime => DateTime.tryParse(creation);

  factory BranchAccessLogEntry.fromJson(Map<String, dynamic> json) =>
      BranchAccessLogEntry(
        name: (json['name'] ?? '').toString(),
        creation: (json['creation'] ?? '').toString(),
        user: (json['user'] ?? '').toString(),
        userFullName: _nullIfBlank(json['user_full_name']),
        employeeName: _nullIfBlank(json['employee_name']),
        posProfile: (json['pos_profile'] ?? '').toString(),
        action: (json['action'] ?? '').toString(),
        source: _nullIfBlank(json['source']),
        notes: _nullIfBlank(json['notes']),
        changedBy: _nullIfBlank(json['changed_by']),
        changedByName: _nullIfBlank(json['changed_by_name']),
        dayAccess: _nullIfBlank(json['day_access']),
      );
}

class BranchAccessLogPage {
  const BranchAccessLogPage({required this.rows, required this.hasMore});

  final List<BranchAccessLogEntry> rows;
  final bool hasMore;

  factory BranchAccessLogPage.fromJson(Map<String, dynamic> json) =>
      BranchAccessLogPage(
        rows: (json['rows'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (e) =>
                  BranchAccessLogEntry.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
        hasMore: _toBool(json['has_more']),
      );
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().trim().toLowerCase() ?? '';
  return text == 'true' || text == '1';
}

String? _nullIfBlank(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
