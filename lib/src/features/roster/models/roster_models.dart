/// Shift-distribution models — the month calendar a line manager rosters in.
///
/// Plain classes with hand-written `fromJson`, matching the shift-monitor and
/// manager features rather than the freezed models used on the B2B side. The
/// payload here is a nested map keyed by ISO date, which freezed would not
/// model any more clearly than this does.
library;

/// One Shift Type, with the length the backend computed for it.
///
/// The hours are computed server-side and never stored, because every branch
/// shift crosses midnight (12:30 → 01:00) and doing that subtraction on the
/// client would put the wrapping bug in two places instead of none.
class RosterShift {
  const RosterShift({
    required this.shiftType,
    required this.startTime,
    required this.endTime,
    required this.hours,
    this.color,
  });

  final String shiftType;
  final String startTime;
  final String endTime;
  final double hours;
  final String? color;

  /// "12:30 → 01:00 · 12.5h" for the picker subtitle.
  String get window {
    final start = _hhmm(startTime);
    final end = _hhmm(endTime);
    if (start.isEmpty || end.isEmpty) return '';
    return '$start → $end';
  }

  static String _hhmm(String raw) {
    if (raw.isEmpty) return '';
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  factory RosterShift.fromJson(Map<String, dynamic> json) => RosterShift(
    shiftType: (json['shift_type'] ?? '').toString(),
    startTime: (json['start_time'] ?? '').toString(),
    endTime: (json['end_time'] ?? '').toString(),
    hours: _toDouble(json['hours']),
    color: json['color']?.toString(),
  );
}

class RosterLocation {
  const RosterLocation({required this.shiftLocation, required this.radius});

  final String shiftLocation;
  final int radius;

  factory RosterLocation.fromJson(Map<String, dynamic> json) => RosterLocation(
    shiftLocation: (json['shift_location'] ?? '').toString(),
    radius: _toInt(json['checkin_radius']),
  );
}

/// A granted day off, and who absorbed it.
class RosterDayOff {
  const RosterDayOff({
    required this.name,
    required this.offType,
    this.coveredBy,
    this.coveredByName,
    this.coverShiftType,
    this.notes,
  });

  final String name;
  final String offType;
  final String? coveredBy;
  final String? coveredByName;
  final String? coverShiftType;
  final String? notes;

  bool get isCovered => (coveredBy ?? '').isNotEmpty;

  factory RosterDayOff.fromJson(Map<String, dynamic> json) => RosterDayOff(
    name: (json['name'] ?? '').toString(),
    offType: (json['off_type'] ?? '').toString(),
    coveredBy: _nullIfBlank(json['covered_by']),
    coveredByName: _nullIfBlank(json['covered_by_name']),
    coverShiftType: _nullIfBlank(json['cover_shift_type']),
    notes: _nullIfBlank(json['notes']),
  );
}

/// One person on one day.
class RosterCell {
  const RosterCell({
    required this.date,
    this.shiftType,
    this.shiftLocation,
    this.hours = 0,
    this.isHoliday = false,
    this.dayOff,
  });

  final String date;
  final String? shiftType;
  final String? shiftLocation;
  final double hours;
  final bool isHoliday;
  final RosterDayOff? dayOff;

  bool get isOff => dayOff != null;
  bool get isWorking => (shiftType ?? '').isNotEmpty;

  /// A day that is neither worked nor an explicit day off.
  ///
  /// Worth its own name on the client because it is the state the check-in gate
  /// treats as "not on the roster" — the person is turned away, but nobody
  /// decided that, so the screen flags it rather than drawing an innocent blank.
  bool get isUnrostered => !isWorking && !isOff && !isHoliday;

  factory RosterCell.fromJson(Map<String, dynamic> json) {
    final off = json['day_off'];
    return RosterCell(
      date: (json['date'] ?? '').toString(),
      shiftType: _nullIfBlank(json['shift_type']),
      shiftLocation: _nullIfBlank(json['shift_location']),
      hours: _toDouble(json['hours']),
      isHoliday: json['is_holiday'] == true || json['is_holiday'] == 1,
      dayOff: off is Map
          ? RosterDayOff.fromJson(Map<String, dynamic>.from(off))
          : null,
    );
  }
}

class RosterEmployee {
  const RosterEmployee({
    required this.employee,
    required this.employeeName,
    required this.days,
    this.designation,
    this.department,
    this.shiftLocations = const [],
    this.standardHours = 0,
    this.isCourier = false,
    this.overtimeMultiplier = 1,
  });

  final String employee;
  final String employeeName;
  final String? designation;
  final String? department;
  final List<String> shiftLocations;
  final double standardHours;
  final bool isCourier;
  final double overtimeMultiplier;

  /// Keyed by ISO date so a 28-, 30- and 31-day month all render from one shape.
  final Map<String, RosterCell> days;

  RosterCell? cellFor(String date) => days[date];

  String get primaryLocation =>
      shiftLocations.isEmpty ? '' : shiftLocations.first;

  factory RosterEmployee.fromJson(Map<String, dynamic> json) {
    final rawDays = Map<String, dynamic>.from(json['days'] as Map? ?? const {});
    return RosterEmployee(
      employee: (json['employee'] ?? '').toString(),
      employeeName: (json['employee_name'] ?? '').toString(),
      designation: _nullIfBlank(json['designation']),
      department: _nullIfBlank(json['department']),
      shiftLocations: (json['shift_locations'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      standardHours: _toDouble(json['standard_hours']),
      isCourier: json['is_courier'] == true,
      overtimeMultiplier: _toDouble(json['overtime_multiplier']),
      days: rawDays.map(
        (key, value) => MapEntry(
          key,
          RosterCell.fromJson(Map<String, dynamic>.from(value as Map)),
        ),
      ),
    );
  }
}

/// A day somebody is off with nobody named as covering.
class RosterGap {
  const RosterGap({
    required this.employee,
    required this.date,
    this.offType,
    this.shiftLocation,
  });

  final String employee;
  final String date;
  final String? offType;
  final String? shiftLocation;

  factory RosterGap.fromJson(Map<String, dynamic> json) => RosterGap(
    employee: (json['employee'] ?? '').toString(),
    date: (json['off_date'] ?? '').toString(),
    offType: _nullIfBlank(json['off_type']),
    shiftLocation: _nullIfBlank(json['shift_location']),
  );
}

class RosterScope {
  const RosterScope({
    required this.configured,
    required this.unrestricted,
    this.locations,
  });

  final bool configured;
  final bool unrestricted;
  final List<String>? locations;

  factory RosterScope.fromJson(Map<String, dynamic> json) => RosterScope(
    configured: json['configured'] == true,
    unrestricted: json['unrestricted'] == true,
    locations: (json['locations'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList(),
  );
}

class RosterMonth {
  const RosterMonth({
    required this.month,
    required this.monthStart,
    required this.monthEnd,
    required this.employees,
    required this.shiftCatalog,
    required this.shiftLocations,
    required this.gaps,
    required this.scope,
    required this.hrmsAvailable,
    this.notice,
  });

  final String month;
  final String monthStart;
  final String monthEnd;
  final List<RosterEmployee> employees;
  final List<RosterShift> shiftCatalog;
  final List<RosterLocation> shiftLocations;
  final List<RosterGap> gaps;
  final RosterScope scope;
  final bool hrmsAvailable;
  final String? notice;

  /// Every ISO date in the month, in order — the calendar's column headers.
  List<String> get dates {
    if (employees.isEmpty) return const [];
    final keys = employees.first.days.keys.toList()..sort();
    return keys;
  }

  factory RosterMonth.fromJson(Map<String, dynamic> json) => RosterMonth(
    month: (json['month'] ?? '').toString(),
    monthStart: (json['month_start'] ?? '').toString(),
    monthEnd: (json['month_end'] ?? '').toString(),
    hrmsAvailable: json['hrms_available'] != false,
    notice: _nullIfBlank(json['notice']),
    employees: (json['employees'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => RosterEmployee.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    shiftCatalog: (json['shift_catalog'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => RosterShift.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    shiftLocations: (json['shift_locations'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => RosterLocation.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    gaps: (json['uncovered'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => RosterGap.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    scope: RosterScope.fromJson(
      Map<String, dynamic>.from(json['scope'] as Map? ?? const {}),
    ),
  );
}

/// One person's month, as payroll reads it.
class RosterHoursRow {
  const RosterHoursRow({
    required this.employee,
    required this.employeeName,
    required this.standardHours,
    required this.overtimeMultiplier,
    required this.workedDays,
    required this.offDays,
    required this.coverDays,
    required this.workedHours,
    required this.baseHours,
    required this.overtimeHours,
    required this.creditedOvertimeHours,
    required this.creditedHours,
    this.designation,
    this.isCourier = false,
  });

  final String employee;
  final String employeeName;
  final String? designation;
  final bool isCourier;
  final double standardHours;
  final double overtimeMultiplier;
  final int workedDays;
  final int offDays;
  final int coverDays;

  /// Hours actually stood at the branch.
  final double workedHours;
  final double baseHours;
  final double overtimeHours;

  /// Overtime after the multiplier — 2× for couriers, 1× for everyone else.
  final double creditedOvertimeHours;

  /// What payroll pays for: base + credited overtime. Differs from
  /// [workedHours] for anyone who did a cover day, which is the whole point.
  final double creditedHours;

  factory RosterHoursRow.fromJson(Map<String, dynamic> json) => RosterHoursRow(
    employee: (json['employee'] ?? '').toString(),
    employeeName: (json['employee_name'] ?? '').toString(),
    designation: _nullIfBlank(json['designation']),
    isCourier: json['is_courier'] == true,
    standardHours: _toDouble(json['standard_hours']),
    overtimeMultiplier: _toDouble(json['overtime_multiplier']),
    workedDays: _toInt(json['worked_days']),
    offDays: _toInt(json['off_days']),
    coverDays: _toInt(json['cover_days']),
    workedHours: _toDouble(json['worked_hours']),
    baseHours: _toDouble(json['base_hours']),
    overtimeHours: _toDouble(json['overtime_hours']),
    creditedOvertimeHours: _toDouble(json['credited_overtime_hours']),
    creditedHours: _toDouble(json['credited_hours']),
  );
}

class RosterHours {
  const RosterHours({
    required this.month,
    required this.rows,
    required this.totalWorkedHours,
    required this.totalOvertimeHours,
    required this.totalCreditedHours,
  });

  final String month;
  final List<RosterHoursRow> rows;
  final double totalWorkedHours;
  final double totalOvertimeHours;
  final double totalCreditedHours;

  factory RosterHours.fromJson(Map<String, dynamic> json) {
    final totals = Map<String, dynamic>.from(
      json['totals'] as Map? ?? const {},
    );
    return RosterHours(
      month: (json['month'] ?? '').toString(),
      rows: (json['rows'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => RosterHoursRow.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      totalWorkedHours: _toDouble(totals['worked_hours']),
      totalOvertimeHours: _toDouble(totals['overtime_hours']),
      totalCreditedHours: _toDouble(totals['credited_hours']),
    );
  }
}

/// What the screen needs before it can draw anything.
class RosterBootstrap {
  const RosterBootstrap({
    required this.hrmsAvailable,
    required this.shiftCatalog,
    required this.shiftLocations,
    required this.offTypes,
    required this.scope,
  });

  final bool hrmsAvailable;
  final List<RosterShift> shiftCatalog;
  final List<RosterLocation> shiftLocations;
  final List<String> offTypes;
  final RosterScope scope;

  factory RosterBootstrap.fromJson(Map<String, dynamic> json) =>
      RosterBootstrap(
        hrmsAvailable: json['hrms_available'] != false,
        shiftCatalog: (json['shift_catalog'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((e) => RosterShift.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        shiftLocations: (json['shift_locations'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((e) => RosterLocation.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        offTypes: (json['off_types'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        scope: RosterScope.fromJson(
          Map<String, dynamic>.from(json['scope'] as Map? ?? const {}),
        ),
      );
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _nullIfBlank(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
