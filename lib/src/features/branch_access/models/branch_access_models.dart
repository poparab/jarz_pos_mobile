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
    this.homeBranch,
    this.homeLocation,
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

  /// POS Profile of the branch the person's standing weekly schedule places
  /// them at. Null when they have no schedule, or the server is older.
  final String? homeBranch;

  /// Shift Location name behind [homeBranch].
  final String? homeLocation;

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
        homeBranch: _nullIfBlank(json['home_branch']),
        homeLocation: _nullIfBlank(json['home_location']),
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

/// What a day access did to that day's rostered shift.
///
/// `grant_day_access` moves the shift to the borrowed branch so check-in works
/// there ([moved]); `cancel_day_access` puts it back ([restored]). When it
/// could not (no shift that day, a day off), [reason] says why - and check-in
/// at the borrowed branch will still be refused.
class DayAccessRoster {
  const DayAccessRoster({
    this.moved = false,
    this.restored = false,
    this.shiftType,
    this.shiftLocation,
    this.previousLocation,
    this.reason,
  });

  final bool moved;
  final bool restored;
  final String? shiftType;
  final String? shiftLocation;
  final String? previousLocation;
  final String? reason;

  factory DayAccessRoster.fromJson(Map<String, dynamic> json) =>
      DayAccessRoster(
        moved: _toBool(json['moved']),
        restored: _toBool(json['restored']),
        shiftType: _nullIfBlank(json['shift_type']),
        shiftLocation: _nullIfBlank(json['shift_location']),
        previousLocation: _nullIfBlank(json['previous_location']),
        reason: _nullIfBlank(json['reason']),
      );
}

/// `grant_day_access` / `cancel_day_access`.
class DayAccessResult {
  const DayAccessResult({this.dayAccess, this.message, this.roster});

  final DayAccess? dayAccess;

  /// The server's own sentence, shown as-is.
  final String? message;

  /// Null when the server does not send it (older server).
  final DayAccessRoster? roster;

  /// After a grant: why that day's shift could not be moved to the borrowed
  /// branch (so check-in there will still be refused), or null when it was
  /// moved or the server did not say.
  String? get grantRosterWarning {
    final r = roster;
    if (r == null || r.moved) return null;
    return r.reason;
  }

  /// After a cancel: why the shift could not be put back, or null.
  String? get cancelRosterWarning => roster?.reason;

  factory DayAccessResult.fromJson(Map<String, dynamic> json) {
    final raw = json['day_access'];
    final roster = json['roster'];
    return DayAccessResult(
      dayAccess: raw is Map
          ? DayAccess.fromJson(Map<String, dynamic>.from(raw))
          : null,
      message: _nullIfBlank(json['message']),
      roster: roster is Map
          ? DayAccessRoster.fromJson(Map<String, dynamic>.from(roster))
          : null,
    );
  }
}

/// The roster half of `move_branch`.
class MoveBranchRoster {
  const MoveBranchRoster({
    this.fromDate,
    this.shiftLocation,
    this.previousLocation,
    this.schedulesUpdated = 0,
    this.assignmentsMoved = 0,
    this.reason,
  });

  /// `YYYY-MM-DD` the schedule moved from (today, or tomorrow when the person
  /// already checked in today).
  final String? fromDate;
  final String? shiftLocation;
  final String? previousLocation;
  final int schedulesUpdated;
  final int assignmentsMoved;

  /// Why the schedule could not be moved, when it could not.
  final String? reason;

  factory MoveBranchRoster.fromJson(Map<String, dynamic> json) =>
      MoveBranchRoster(
        fromDate: _nullIfBlank(json['from_date']),
        shiftLocation: _nullIfBlank(json['shift_location']),
        previousLocation: _nullIfBlank(json['previous_location']),
        schedulesUpdated: _toInt(json['schedules_updated']),
        assignmentsMoved: _toInt(json['assignments_moved']),
        reason: _nullIfBlank(json['reason']),
      );
}

/// `move_branch` - a permanent move to another branch.
class MoveBranchResult {
  const MoveBranchResult({
    this.success = true,
    this.user = '',
    this.toPosProfile = '',
    this.fromPosProfile,
    this.message,
    this.roster,
  });

  final bool success;
  final String user;
  final String toPosProfile;
  final String? fromPosProfile;

  /// The server's own sentence, shown as-is.
  final String? message;
  final MoveBranchRoster? roster;

  factory MoveBranchResult.fromJson(Map<String, dynamic> json) {
    final roster = json['roster'];
    return MoveBranchResult(
      success: json['success'] == null ? true : _toBool(json['success']),
      user: (json['user'] ?? '').toString(),
      toPosProfile: (json['to_pos_profile'] ?? '').toString(),
      fromPosProfile: _nullIfBlank(json['from_pos_profile']),
      message: _nullIfBlank(json['message']),
      roster: roster is Map
          ? MoveBranchRoster.fromJson(Map<String, dynamic>.from(roster))
          : null,
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

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '') ?? 0;
}

String? _nullIfBlank(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
