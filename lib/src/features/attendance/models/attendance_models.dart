/// Attendance models — who was actually at the branch, against who was rostered.
///
/// Plain classes with hand-written `fromJson`, mirroring `roster_models.dart`
/// rather than the freezed models on the B2B side: the month payload is a
/// nested map keyed by ISO date, which freezed would not model any more
/// clearly than this does.
///
/// Everything here is a READ model. Attendance is derived server-side from
/// Employee Checkin + Shift Assignment + Day Off; the app never writes it.
library;

/// The status of one employee on one day, as `jarz_pos.api.attendance` reports it.
///
/// The wire values are the frozen contract's strings. [unknown] is NOT one of
/// them: it is the client's landing pad for a value this build has never heard
/// of, so a backend that grows a ninth status degrades to a muted "unknown"
/// chip instead of throwing inside a list builder.
enum AttendanceStatus {
  /// Rostered, first IN within the grace window.
  present,

  /// Rostered, first IN after the grace window.
  late,

  /// A check-in exists but lands outside the shift window (`offshift`), so the
  /// server could not match it to a shift start. Not "no data" — an arrival.
  lateUnmatched,

  /// Rostered, the day has passed, nobody checked in.
  absent,

  /// Rostered, today or later, nobody has checked in *yet*.
  pending,

  /// A Jarz Roster Day Off row covers the date.
  off,

  /// The shift type's holiday list covers the date.
  holiday,

  /// No Shift Assignment at all — nobody was expected. Deliberately distinct
  /// from [absent], which is somebody who was expected and did not come.
  notRostered,

  /// A status string this build does not know.
  unknown,
}

/// Wire string -> enum. Anything unrecognised (including null and '') becomes
/// [AttendanceStatus.unknown] rather than throwing.
AttendanceStatus attendanceStatusFromWire(dynamic raw) {
  switch (raw?.toString().trim().toLowerCase()) {
    case 'present':
      return AttendanceStatus.present;
    case 'late':
      return AttendanceStatus.late;
    case 'late_unmatched':
      return AttendanceStatus.lateUnmatched;
    case 'absent':
      return AttendanceStatus.absent;
    case 'pending':
      return AttendanceStatus.pending;
    case 'off':
      return AttendanceStatus.off;
    case 'holiday':
      return AttendanceStatus.holiday;
    case 'not_rostered':
      return AttendanceStatus.notRostered;
    default:
      return AttendanceStatus.unknown;
  }
}

/// Enum -> wire string, for round-tripping and for tests.
String attendanceStatusToWire(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return 'present';
    case AttendanceStatus.late:
      return 'late';
    case AttendanceStatus.lateUnmatched:
      return 'late_unmatched';
    case AttendanceStatus.absent:
      return 'absent';
    case AttendanceStatus.pending:
      return 'pending';
    case AttendanceStatus.off:
      return 'off';
    case AttendanceStatus.holiday:
      return 'holiday';
    case AttendanceStatus.notRostered:
      return 'not_rostered';
    case AttendanceStatus.unknown:
      return 'unknown';
  }
}

/// The eight statuses the contract can actually send, in reading order.
///
/// The legend is generated from this list, so a status that exists in the
/// resolver but is missing from the legend is a test failure rather than a
/// colour nobody can explain.
const List<AttendanceStatus> kAttendanceStatusOrder = <AttendanceStatus>[
  AttendanceStatus.present,
  AttendanceStatus.late,
  AttendanceStatus.lateUnmatched,
  AttendanceStatus.absent,
  AttendanceStatus.pending,
  AttendanceStatus.off,
  AttendanceStatus.holiday,
  AttendanceStatus.notRostered,
];

/// Which branches the caller is allowed to see.
class AttendanceScope {
  const AttendanceScope({
    required this.configured,
    required this.unrestricted,
    this.locations,
  });

  final bool configured;
  final bool unrestricted;
  final List<String>? locations;

  /// A manager who has a scope configured, but scoped to nothing — they will
  /// see an empty screen forever unless somebody notices, so the screen says
  /// so instead of drawing an innocent "nobody rostered".
  bool get isEmptyScope =>
      configured && !unrestricted && (locations?.isEmpty ?? true);

  factory AttendanceScope.fromJson(Map<String, dynamic> json) =>
      AttendanceScope(
        configured: json['configured'] == true,
        unrestricted: json['unrestricted'] == true,
        locations: (json['locations'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
      );
}

class AttendanceShiftLocation {
  const AttendanceShiftLocation({
    required this.shiftLocation,
    required this.checkinRadius,
    this.latitude,
    this.longitude,
  });

  final String shiftLocation;
  final int checkinRadius;
  final double? latitude;
  final double? longitude;

  factory AttendanceShiftLocation.fromJson(Map<String, dynamic> json) =>
      AttendanceShiftLocation(
        shiftLocation: (json['shift_location'] ?? '').toString(),
        checkinRadius: _toInt(json['checkin_radius']),
        latitude: _toDoubleOrNull(json['latitude']),
        longitude: _toDoubleOrNull(json['longitude']),
      );
}

/// What the screen needs before it can draw anything.
class AttendanceBootstrap {
  const AttendanceBootstrap({
    required this.hrmsAvailable,
    required this.shiftLocations,
    required this.scope,
    required this.graceMinutes,
    required this.statuses,
    required this.checkinEnforced,
    this.notice,
  });

  final bool hrmsAvailable;
  final List<AttendanceShiftLocation> shiftLocations;
  final AttendanceScope scope;

  /// Minutes after the scheduled start that still count as on time.
  final int graceMinutes;

  /// The status vocabulary the server believes in. Compared against
  /// [kAttendanceStatusOrder] only for diagnostics — the client never renders
  /// a status it cannot style.
  final List<String> statuses;
  final bool checkinEnforced;
  final String? notice;

  factory AttendanceBootstrap.fromJson(Map<String, dynamic> json) =>
      AttendanceBootstrap(
        hrmsAvailable: json['hrms_available'] != false,
        shiftLocations:
            (json['shift_locations'] as List<dynamic>? ?? const [])
                .whereType<Map>()
                .map(
                  (e) => AttendanceShiftLocation.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList(),
        scope: AttendanceScope.fromJson(
          Map<String, dynamic>.from(json['scope'] as Map? ?? const {}),
        ),
        graceMinutes: _toInt(json['grace_minutes']),
        statuses: (json['statuses'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        checkinEnforced: json['checkin_enforced'] == true,
        notice: _nullIfBlank(json['notice']),
      );
}

/// A granted day off, and who absorbed it.
class AttendanceDayOff {
  const AttendanceDayOff({
    required this.offType,
    this.coveredBy,
    this.coveredByName,
  });

  final String offType;
  final String? coveredBy;
  final String? coveredByName;

  bool get isCovered => (coveredBy ?? '').isNotEmpty;

  factory AttendanceDayOff.fromJson(Map<String, dynamic> json) =>
      AttendanceDayOff(
        offType: (json['off_type'] ?? '').toString(),
        coveredBy: _nullIfBlank(json['covered_by']),
        coveredByName: _nullIfBlank(json['covered_by_name']),
      );
}

/// One person on one day: what was scheduled, and what actually happened.
///
/// The same shape is returned by `get_month` (as a map value), `get_day` (as
/// part of a row) and `get_employee` (as a list entry), so it is parsed in one
/// place — a field the three endpoints disagreed about would show up here
/// rather than three times over.
class AttendanceCell {
  const AttendanceCell({
    required this.date,
    required this.status,
    required this.rawStatus,
    this.shiftType,
    this.shiftLocation,
    this.scheduledStart,
    this.scheduledEnd,
    this.firstIn,
    this.lastOut,
    this.lateMinutes,
    this.workedHours,
    this.checkinCount = 0,
    this.offshift = false,
    this.geoOk,
    this.dayOff,
    this.isCover = false,
  });

  final String date;
  final AttendanceStatus status;

  /// The exact string the server sent. Kept so an unknown status can be shown
  /// verbatim in the day sheet instead of vanishing into "unknown".
  final String rawStatus;

  final String? shiftType;
  final String? shiftLocation;

  /// `HH:mm`, server-local. Never parsed into a `DateTime` with a zone.
  final String? scheduledStart;
  final String? scheduledEnd;

  /// `YYYY-MM-DD HH:mm:ss`, server-local.
  final String? firstIn;
  final String? lastOut;

  /// Signed on a cell: negative means they arrived early.
  final int? lateMinutes;
  final double? workedHours;
  final int checkinCount;
  final bool offshift;
  final bool? geoOk;
  final AttendanceDayOff? dayOff;
  final bool isCover;

  bool get hasCheckin => checkinCount > 0;

  /// Lateness that counts. Early arrivals are not negative lateness for any
  /// purpose the screen has — they are simply "not late".
  int get lateMinutesPositive {
    final value = lateMinutes ?? 0;
    return value > 0 ? value : 0;
  }

  /// Somebody was expected on this day.
  bool get isRostered =>
      status != AttendanceStatus.notRostered &&
      status != AttendanceStatus.off &&
      status != AttendanceStatus.holiday &&
      status != AttendanceStatus.unknown;

  factory AttendanceCell.fromJson(
    Map<String, dynamic> json, {
    String? fallbackDate,
  }) {
    final off = json['day_off'];
    return AttendanceCell(
      date: _nullIfBlank(json['date']) ?? fallbackDate ?? '',
      status: attendanceStatusFromWire(json['status']),
      rawStatus: (json['status'] ?? '').toString(),
      shiftType: _nullIfBlank(json['shift_type']),
      shiftLocation: _nullIfBlank(json['shift_location']),
      scheduledStart: _nullIfBlank(json['scheduled_start']),
      scheduledEnd: _nullIfBlank(json['scheduled_end']),
      firstIn: _nullIfBlank(json['first_in']),
      lastOut: _nullIfBlank(json['last_out']),
      lateMinutes: _toIntOrNull(json['late_minutes']),
      workedHours: _toDoubleOrNull(json['worked_hours']),
      checkinCount: _toInt(json['checkin_count']),
      offshift: json['offshift'] == true || json['offshift'] == 1,
      geoOk: _toBoolOrNull(json['geo_ok']),
      dayOff: off is Map
          ? AttendanceDayOff.fromJson(Map<String, dynamic>.from(off))
          : null,
      isCover: json['is_cover'] == true || json['is_cover'] == 1,
    );
  }
}

/// Per-employee and whole-month totals from `get_month` / `get_employee`.
class AttendanceTotals {
  const AttendanceTotals({
    this.employees,
    this.rosteredDays = 0,
    this.presentDays = 0,
    this.lateDays = 0,
    this.lateUnmatchedDays = 0,
    this.absentDays = 0,
    this.pendingDays = 0,
    this.offDays = 0,
    this.workedHours = 0,
    this.lateMinutes = 0,
    this.attendanceRate = 0,
    this.punctualityRate = 0,
  });

  /// Only present on the month-level totals.
  final int? employees;

  final int rosteredDays;
  final int presentDays;
  final int lateDays;

  /// Days with a check-in the server could not match to a shift start.
  ///
  /// Defaults to 0 rather than being required, so a phone running against a
  /// backend from before this counter existed reads a short total instead of
  /// throwing. [addsUp] is then false, which is the honest answer.
  final int lateUnmatchedDays;

  final int absentDays;

  /// Rostered days that are today or later, with no check-in yet. Excluded
  /// from [addsUp] by the server's own definition.
  final int pendingDays;

  final int offDays;
  final double workedHours;

  /// Sum of positive lateness only.
  final int lateMinutes;

  /// 0..1. The server sends 0.0 when nothing was rostered, so the client never
  /// divides by zero itself.
  final double attendanceRate;
  final double punctualityRate;

  /// Days somebody actually turned up — the numerator of [attendanceRate].
  int get attendedDays => presentDays + lateDays + lateUnmatchedDays;

  /// The denominator of [punctualityRate]: everybody who showed, on time or
  /// not. `late_unmatched` belongs here — they did arrive.
  int get punctualityDenominator => attendedDays;

  /// The invariant the backend asserts in its own tests:
  /// `rostered == present + late + late_unmatched + absent` (pending excluded
  /// by design). Checked on the client too, because the screen prints these
  /// numbers next to each other and a reader will add them up.
  bool get addsUp =>
      rosteredDays == presentDays + lateDays + lateUnmatchedDays + absentDays;

  factory AttendanceTotals.fromJson(Map<String, dynamic> json) =>
      AttendanceTotals(
        employees: _toIntOrNull(json['employees']),
        rosteredDays: _toInt(json['rostered_days']),
        presentDays: _toInt(json['present_days']),
        lateDays: _toInt(json['late_days']),
        lateUnmatchedDays: _toInt(json['late_unmatched_days']),
        absentDays: _toInt(json['absent_days']),
        pendingDays: _toInt(json['pending_days']),
        offDays: _toInt(json['off_days']),
        workedHours: _toDouble(json['worked_hours']),
        lateMinutes: _toInt(json['late_minutes']),
        attendanceRate: _toDouble(json['attendance_rate']),
        punctualityRate: _toDouble(json['punctuality_rate']),
      );
}

/// One row of the month grid.
class AttendanceEmployeeMonth {
  const AttendanceEmployeeMonth({
    required this.employee,
    required this.employeeName,
    required this.days,
    required this.totals,
    this.designation,
    this.department,
    this.shiftLocations = const [],
    this.isCourier = false,
  });

  final String employee;
  final String employeeName;
  final String? designation;
  final String? department;
  final List<String> shiftLocations;
  final bool isCourier;

  /// Keyed by ISO date so a 28-, 30- and 31-day month all render from one shape.
  final Map<String, AttendanceCell> days;
  final AttendanceTotals totals;

  AttendanceCell? cellFor(String date) => days[date];

  /// Did this person clock in at all this month?
  bool get hasAnyCheckin => days.values.any((cell) => cell.hasCheckin);

  factory AttendanceEmployeeMonth.fromJson(Map<String, dynamic> json) {
    final rawDays = Map<String, dynamic>.from(json['days'] as Map? ?? const {});
    return AttendanceEmployeeMonth(
      employee: (json['employee'] ?? '').toString(),
      employeeName: (json['employee_name'] ?? '').toString(),
      designation: _nullIfBlank(json['designation']),
      department: _nullIfBlank(json['department']),
      shiftLocations: (json['shift_locations'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      isCourier: json['is_courier'] == true,
      days: rawDays.map(
        (key, value) => MapEntry(
          key,
          AttendanceCell.fromJson(
            Map<String, dynamic>.from(value as Map),
            fallbackDate: key,
          ),
        ),
      ),
      totals: AttendanceTotals.fromJson(
        Map<String, dynamic>.from(json['totals'] as Map? ?? const {}),
      ),
    );
  }
}

/// `jarz_pos.api.attendance.get_month`.
class AttendanceMonth {
  const AttendanceMonth({
    required this.month,
    required this.monthStart,
    required this.monthEnd,
    required this.employees,
    required this.totals,
    required this.scope,
    required this.graceMinutes,
    required this.hrmsAvailable,
    this.notice,
  });

  final String month;
  final String monthStart;
  final String monthEnd;
  final List<AttendanceEmployeeMonth> employees;
  final AttendanceTotals totals;
  final AttendanceScope scope;
  final int graceMinutes;
  final bool hrmsAvailable;
  final String? notice;

  /// Every ISO date in the month, in order — the grid's column headers.
  ///
  /// Taken from the union of all rows rather than the first row: one employee
  /// hired mid-month must not shorten everybody else's calendar.
  List<String> get dates {
    final keys = <String>{};
    for (final employee in employees) {
      keys.addAll(employee.days.keys);
    }
    final sorted = keys.toList()..sort();
    return sorted;
  }

  /// Nobody clocked in, all month.
  ///
  /// The honest default today: check-in is not in use yet, so a month of
  /// `absent` cells means "no data", not "the whole team stayed home". The
  /// screen has to say which.
  bool get hasAnyCheckin => employees.any((e) => e.hasAnyCheckin);

  factory AttendanceMonth.fromJson(Map<String, dynamic> json) =>
      AttendanceMonth(
        month: (json['month'] ?? '').toString(),
        monthStart: (json['month_start'] ?? '').toString(),
        monthEnd: (json['month_end'] ?? '').toString(),
        hrmsAvailable: json['hrms_available'] != false,
        notice: _nullIfBlank(json['notice']),
        graceMinutes: _toInt(json['grace_minutes']),
        employees: (json['employees'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (e) =>
                  AttendanceEmployeeMonth.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
        totals: AttendanceTotals.fromJson(
          Map<String, dynamic>.from(json['totals'] as Map? ?? const {}),
        ),
        scope: AttendanceScope.fromJson(
          Map<String, dynamic>.from(json['scope'] as Map? ?? const {}),
        ),
      );
}

/// Head-count totals for one branch on one day, or for the whole day.
class AttendanceDayTotals {
  const AttendanceDayTotals({
    this.rostered = 0,
    this.present = 0,
    this.late = 0,
    this.lateUnmatched = 0,
    this.absent = 0,
    this.pending = 0,
    this.off = 0,
  });

  final int rostered;
  final int present;
  final int late;

  /// Defaults to 0 so an older backend parses; the header then simply does not
  /// add up, which [addsUp] reports rather than hides.
  final int lateUnmatched;

  final int absent;
  final int pending;
  final int off;

  /// The server's invariant for a day:
  /// `rostered == present + late + late_unmatched + absent + pending`.
  /// `off` sits outside it — an approved day off is not a rostered day.
  bool get addsUp =>
      rostered == present + late + lateUnmatched + absent + pending;

  factory AttendanceDayTotals.fromJson(Map<String, dynamic> json) =>
      AttendanceDayTotals(
        rostered: _toInt(json['rostered']),
        present: _toInt(json['present']),
        late: _toInt(json['late']),
        lateUnmatched: _toInt(json['late_unmatched']),
        absent: _toInt(json['absent']),
        pending: _toInt(json['pending']),
        off: _toInt(json['off']),
      );
}

/// One person's line in the day view. The day's facts live on [cell]; the
/// person's identity lives here.
class AttendanceDayRow {
  const AttendanceDayRow({
    required this.employee,
    required this.employeeName,
    required this.cell,
    this.designation,
    this.isCourier = false,
  });

  final String employee;
  final String employeeName;
  final String? designation;
  final bool isCourier;
  final AttendanceCell cell;

  AttendanceStatus get status => cell.status;

  /// [date] is the response-level date, and is used ONLY when the row does not
  /// carry its own.
  ///
  /// Rows now carry `date` — the shift's date, which is the grouping key — so
  /// a night shift whose second half falls on the next calendar day keeps the
  /// day it was rostered for. Stamping the response date over it (what this
  /// did before the backend added the field) is exactly the bug that would
  /// have moved those rows.
  factory AttendanceDayRow.fromJson(
    Map<String, dynamic> json, {
    required String date,
  }) => AttendanceDayRow(
    employee: (json['employee'] ?? '').toString(),
    employeeName: (json['employee_name'] ?? '').toString(),
    designation: _nullIfBlank(json['designation']),
    isCourier: json['is_courier'] == true,
    cell: AttendanceCell.fromJson(json, fallbackDate: date),
  );
}

/// One branch's section of the day view.
class AttendanceBranchDay {
  const AttendanceBranchDay({
    required this.shiftLocation,
    required this.totals,
    required this.rows,
  });

  /// Null is a real value: check-ins the server could not attribute to any
  /// branch. It renders last, under an explicit label — never as a blank
  /// heading, which is how "no branch resolved" gets mistaken for a branch
  /// whose name failed to load.
  final String? shiftLocation;
  final AttendanceDayTotals totals;
  final List<AttendanceDayRow> rows;

  bool get isUnresolvedBranch => (shiftLocation ?? '').isEmpty;

  /// The header recomputed from the rows underneath it.
  ///
  /// The server's own totals are what the header shows while they add up. When
  /// they do not — an older backend with no `late_unmatched` counter — the
  /// header falls back to this, because a head-count that disagrees with the
  /// list below it is worse than no server number at all: somebody counts the
  /// rows, finds one missing, and stops believing the screen.
  ///
  /// `holiday` is folded into `off`: both mean "not expected today", and the
  /// contract's day totals have no holiday bucket of their own.
  AttendanceDayTotals countedFromRows() {
    var present = 0;
    var late = 0;
    var lateUnmatched = 0;
    var absent = 0;
    var pending = 0;
    var off = 0;
    for (final row in rows) {
      switch (row.status) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.late:
          late++;
        case AttendanceStatus.lateUnmatched:
          lateUnmatched++;
        case AttendanceStatus.absent:
          absent++;
        case AttendanceStatus.pending:
          pending++;
        case AttendanceStatus.off:
        case AttendanceStatus.holiday:
          off++;
        case AttendanceStatus.notRostered:
        case AttendanceStatus.unknown:
          break;
      }
    }
    return AttendanceDayTotals(
      rostered: present + late + lateUnmatched + absent + pending,
      present: present,
      late: late,
      lateUnmatched: lateUnmatched,
      absent: absent,
      pending: pending,
      off: off,
    );
  }

  /// What the header should print: the server's totals while they are
  /// self-consistent, the rows' own tally otherwise.
  AttendanceDayTotals get headerTotals =>
      totals.addsUp ? totals : countedFromRows();

  factory AttendanceBranchDay.fromJson(
    Map<String, dynamic> json, {
    required String date,
  }) => AttendanceBranchDay(
    shiftLocation: _nullIfBlank(json['shift_location']),
    totals: AttendanceDayTotals.fromJson(
      Map<String, dynamic>.from(json['totals'] as Map? ?? const {}),
    ),
    rows: (json['rows'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (e) =>
              AttendanceDayRow.fromJson(Map<String, dynamic>.from(e), date: date),
        )
        .toList(),
  );
}

/// `jarz_pos.api.attendance.get_day`.
class AttendanceDay {
  const AttendanceDay({
    required this.date,
    required this.branches,
    required this.totals,
    required this.scope,
    required this.graceMinutes,
    required this.hrmsAvailable,
    this.notice,
  });

  final String date;

  /// Server order is preserved verbatim (branches by name, the null bucket
  /// last, rows worst-first) — re-sorting on the client would silently diverge
  /// from the contract's stated order.
  final List<AttendanceBranchDay> branches;
  final AttendanceDayTotals totals;
  final AttendanceScope scope;
  final int graceMinutes;
  final bool hrmsAvailable;
  final String? notice;

  bool get hasAnyCheckin =>
      branches.any((b) => b.rows.any((r) => r.cell.hasCheckin));

  bool get hasAnyRow => branches.any((b) => b.rows.isNotEmpty);

  factory AttendanceDay.fromJson(Map<String, dynamic> json) {
    final date = (json['date'] ?? '').toString();
    return AttendanceDay(
      date: date,
      hrmsAvailable: json['hrms_available'] != false,
      notice: _nullIfBlank(json['notice']),
      graceMinutes: _toInt(json['grace_minutes']),
      branches: (json['branches'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (e) => AttendanceBranchDay.fromJson(
              Map<String, dynamic>.from(e),
              date: date,
            ),
          )
          .toList(),
      totals: AttendanceDayTotals.fromJson(
        Map<String, dynamic>.from(json['totals'] as Map? ?? const {}),
      ),
      scope: AttendanceScope.fromJson(
        Map<String, dynamic>.from(json['scope'] as Map? ?? const {}),
      ),
    );
  }
}

/// One line of `get_employee.by_branch` — how a person's month splits across
/// the branches they actually stood in.
class AttendanceBranchBreakdown {
  const AttendanceBranchBreakdown({
    required this.shiftLocation,
    required this.rosteredDays,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.workedHours,
  });

  final String? shiftLocation;
  final int rosteredDays;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final double workedHours;

  bool get isUnresolvedBranch => (shiftLocation ?? '').isEmpty;

  factory AttendanceBranchBreakdown.fromJson(Map<String, dynamic> json) =>
      AttendanceBranchBreakdown(
        shiftLocation: _nullIfBlank(json['shift_location']),
        rosteredDays: _toInt(json['rostered_days']),
        presentDays: _toInt(json['present_days']),
        lateDays: _toInt(json['late_days']),
        absentDays: _toInt(json['absent_days']),
        workedHours: _toDouble(json['worked_hours']),
      );
}

/// A raw Employee Checkin row, shown unaggregated so a disputed day can be
/// checked against the actual punches.
class AttendanceCheckin {
  const AttendanceCheckin({
    required this.name,
    required this.time,
    this.logType,
    this.shift,
    this.offshift = false,
    this.latitude,
    this.longitude,
    this.geoOk,
  });

  final String name;

  /// `YYYY-MM-DD HH:mm:ss`, server-local, rendered as sent.
  final String time;
  final String? logType;
  final String? shift;
  final bool offshift;
  final double? latitude;
  final double? longitude;
  final bool? geoOk;

  bool get hasCoordinates => latitude != null && longitude != null;

  factory AttendanceCheckin.fromJson(Map<String, dynamic> json) =>
      AttendanceCheckin(
        name: (json['name'] ?? '').toString(),
        time: (json['time'] ?? '').toString(),
        logType: _nullIfBlank(json['log_type']),
        shift: _nullIfBlank(json['shift']),
        offshift: json['offshift'] == true || json['offshift'] == 1,
        latitude: _toDoubleOrNull(json['latitude']),
        longitude: _toDoubleOrNull(json['longitude']),
        geoOk: _toBoolOrNull(json['geo_ok']),
      );
}

/// `jarz_pos.api.attendance.get_employee`.
class AttendanceEmployeeDetail {
  const AttendanceEmployeeDetail({
    required this.employee,
    required this.employeeName,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.totals,
    required this.byBranch,
    required this.checkins,
    required this.graceMinutes,
    required this.hrmsAvailable,
    required this.scope,
    this.designation,
    this.department,
    this.isCourier = false,
    this.shiftLocations = const [],
    this.notice,
  });

  final String employee;
  final String employeeName;
  final String? designation;
  final String? department;
  final bool isCourier;
  final List<String> shiftLocations;
  final String fromDate;
  final String toDate;
  final int graceMinutes;

  /// Ascending by date, one entry per calendar day in range.
  final List<AttendanceCell> days;
  final AttendanceTotals totals;
  final List<AttendanceBranchBreakdown> byBranch;
  final List<AttendanceCheckin> checkins;
  final bool hrmsAvailable;

  /// Same shape as the other endpoints'.
  ///
  /// Carried here so this tab can tell "your account is scoped to no branch"
  /// apart from "this person has no days in the range" — two empty screens
  /// that ask for completely different things to be done about them.
  final AttendanceScope scope;

  final String? notice;

  bool get hasAnyCheckin => checkins.isNotEmpty;

  /// True when this person's days span more than one branch — the case the
  /// by-branch breakdown exists for.
  bool get movedBetweenBranches => byBranch.length > 1;

  factory AttendanceEmployeeDetail.fromJson(Map<String, dynamic> json) =>
      AttendanceEmployeeDetail(
        employee: (json['employee'] ?? '').toString(),
        employeeName: (json['employee_name'] ?? '').toString(),
        designation: _nullIfBlank(json['designation']),
        department: _nullIfBlank(json['department']),
        isCourier: json['is_courier'] == true,
        shiftLocations: (json['shift_locations'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        fromDate: (json['from_date'] ?? '').toString(),
        toDate: (json['to_date'] ?? '').toString(),
        graceMinutes: _toInt(json['grace_minutes']),
        hrmsAvailable: json['hrms_available'] != false,
        notice: _nullIfBlank(json['notice']),
        days: (json['days'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((e) => AttendanceCell.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        totals: AttendanceTotals.fromJson(
          Map<String, dynamic>.from(json['totals'] as Map? ?? const {}),
        ),
        byBranch: (json['by_branch'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (e) => AttendanceBranchBreakdown.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList(),
        checkins: (json['checkins'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((e) => AttendanceCheckin.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        scope: AttendanceScope.fromJson(
          Map<String, dynamic>.from(json['scope'] as Map? ?? const {}),
        ),
      );
}

/// How `get_summary` groups its rows.
enum AttendanceGroupBy { branch, employee, day }

String attendanceGroupByToWire(AttendanceGroupBy groupBy) {
  switch (groupBy) {
    case AttendanceGroupBy.branch:
      return 'branch';
    case AttendanceGroupBy.employee:
      return 'employee';
    case AttendanceGroupBy.day:
      return 'day';
  }
}

AttendanceGroupBy attendanceGroupByFromWire(dynamic raw) {
  switch (raw?.toString().trim().toLowerCase()) {
    case 'employee':
      return AttendanceGroupBy.employee;
    case 'day':
      return AttendanceGroupBy.day;
    default:
      return AttendanceGroupBy.branch;
  }
}

/// One row of the summary table.
///
/// Also used for the table's totals line: the contract says the totals carry
/// "the same numeric keys as rows", minus the identity ones, so parsing them
/// through the same class keeps the two from drifting apart.
class AttendanceSummaryRow {
  const AttendanceSummaryRow({
    required this.label,
    this.key,
    this.employee,
    this.shiftLocation,
    this.rosteredDays = 0,
    this.presentDays = 0,
    this.lateDays = 0,
    this.lateUnmatchedDays = 0,
    this.absentDays = 0,
    this.pendingDays = 0,
    this.offDays = 0,
    this.workedHours = 0,
    this.lateMinutes = 0,
    this.avgLateMinutes = 0,
    this.attendanceRate = 0,
    this.punctualityRate = 0,
    this.employees = 0,
  });

  /// Null when the group itself is the unresolved-branch bucket.
  final String? key;

  /// What to print. Blank for the totals line, which the table labels itself.
  final String label;
  final String? employee;
  final String? shiftLocation;
  final int rosteredDays;
  final int presentDays;
  final int lateDays;
  final int lateUnmatchedDays;
  final int absentDays;
  final int pendingDays;
  final int offDays;
  final double workedHours;
  final int lateMinutes;
  final double avgLateMinutes;
  final double attendanceRate;
  final double punctualityRate;
  final int employees;

  /// A branch row whose key is null — "no branch resolved".
  bool get isUnresolvedBranch => key == null && (shiftLocation ?? '').isEmpty;

  /// Everybody who turned up, on time or not — the numerator of
  /// [attendanceRate] and the denominator of [punctualityRate].
  int get attendedDays => presentDays + lateDays + lateUnmatchedDays;

  /// `rostered == present + late + late_unmatched + absent`, pending excluded,
  /// as the backend asserts it.
  bool get addsUp =>
      rosteredDays == presentDays + lateDays + lateUnmatchedDays + absentDays;

  factory AttendanceSummaryRow.fromJson(Map<String, dynamic> json) =>
      AttendanceSummaryRow(
        key: _nullIfBlank(json['key']),
        label: (json['label'] ?? '').toString(),
        employee: _nullIfBlank(json['employee']),
        shiftLocation: _nullIfBlank(json['shift_location']),
        rosteredDays: _toInt(json['rostered_days']),
        presentDays: _toInt(json['present_days']),
        lateDays: _toInt(json['late_days']),
        lateUnmatchedDays: _toInt(json['late_unmatched_days']),
        absentDays: _toInt(json['absent_days']),
        pendingDays: _toInt(json['pending_days']),
        offDays: _toInt(json['off_days']),
        workedHours: _toDouble(json['worked_hours']),
        lateMinutes: _toInt(json['late_minutes']),
        avgLateMinutes: _toDouble(json['avg_late_minutes']),
        attendanceRate: _toDouble(json['attendance_rate']),
        punctualityRate: _toDouble(json['punctuality_rate']),
        employees: _toInt(json['employees']),
      );
}

/// `jarz_pos.api.attendance.get_summary`.
class AttendanceSummary {
  const AttendanceSummary({
    required this.fromDate,
    required this.toDate,
    required this.groupBy,
    required this.rows,
    required this.totals,
    required this.scope,
    required this.graceMinutes,
    required this.hrmsAvailable,
    this.notice,
  });

  final String fromDate;
  final String toDate;
  final AttendanceGroupBy groupBy;
  final List<AttendanceSummaryRow> rows;
  final AttendanceSummaryRow totals;
  final AttendanceScope scope;
  final int graceMinutes;
  final bool hrmsAvailable;
  final String? notice;

  /// Nobody clocked in anywhere in the range.
  bool get hasAnyAttendance =>
      rows.any((r) => r.presentDays > 0 || r.lateDays > 0);

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) =>
      AttendanceSummary(
        fromDate: (json['from_date'] ?? '').toString(),
        toDate: (json['to_date'] ?? '').toString(),
        groupBy: attendanceGroupByFromWire(json['group_by']),
        hrmsAvailable: json['hrms_available'] != false,
        notice: _nullIfBlank(json['notice']),
        graceMinutes: _toInt(json['grace_minutes']),
        rows: (json['rows'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (e) => AttendanceSummaryRow.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
        totals: AttendanceSummaryRow.fromJson(
          Map<String, dynamic>.from(json['totals'] as Map? ?? const {}),
        ),
        scope: AttendanceScope.fromJson(
          Map<String, dynamic>.from(json['scope'] as Map? ?? const {}),
        ),
      );
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

/// Distinguishes "the server sent 0" from "the server sent null".
///
/// It matters: `worked_hours: 0` is a day somebody stood at the branch and left
/// immediately, while `worked_hours: null` is a day with no second punch at
/// all. Collapsing both to 0 would make the second one unanswerable.
double? _toDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _toIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

/// `geo_ok` is a tri-state: true (inside the fence), false (outside it), null
/// (no coordinates recorded). "No coordinates" must not read as "outside".
bool? _toBoolOrNull(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().trim().toLowerCase();
  if (text.isEmpty || text == 'null') return null;
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return null;
}

String? _nullIfBlank(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
