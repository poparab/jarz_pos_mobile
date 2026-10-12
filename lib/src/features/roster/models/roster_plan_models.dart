/// Rota plan wizard models — `roster.get_plan_defaults` and
/// `roster.apply_plan` (Feature: roster-bulk-wizard).
///
/// Plain classes with hand-written `fromJson`, in the style of
/// `roster_models.dart`. Every field tolerates being missing or null: the
/// wizard ships alongside the backend, and an older or partial response must
/// degrade to "nothing pre-filled", never to a crash.
library;

/// The seven weekdays in the order the wizard shows them: Saturday first,
/// because the Egyptian working week starts on Saturday (see
/// `rosterWeeksOfMonth`). The VALUES are the English full names the backend
/// expects (HRMS "Assignment Rule Day"), whatever language the screen is in.
const List<String> rosterPlanWeekdays = <String>[
  'Saturday',
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
];

/// A standing cover: on [weekday], [coveredBy] works the absent person's day
/// on [coverShiftType].
class RosterPlanCover {
  const RosterPlanCover({
    required this.weekday,
    this.coveredBy,
    this.coveredByName,
    this.coverShiftType,
  });

  final String weekday;
  final String? coveredBy;
  final String? coveredByName;
  final String? coverShiftType;

  factory RosterPlanCover.fromJson(Map<String, dynamic> json) =>
      RosterPlanCover(
        weekday: (json['weekday'] ?? '').toString(),
        coveredBy: _nullIfBlank(json['covered_by']),
        coveredByName: _nullIfBlank(json['covered_by_name']),
        coverShiftType: _nullIfBlank(json['cover_shift_type']),
      );
}

/// One person's current week, as the server reads it: the wizard's pre-fill.
class RosterPlanDefaultsEmployee {
  const RosterPlanDefaultsEmployee({
    required this.employee,
    required this.employeeName,
    this.designation,
    this.isCourier = false,
    this.shiftLocation,
    this.shiftType,
    this.offDays = const [],
    this.useFridayVariant = false,
    this.fridayShiftType,
    this.covers = const [],
    this.hasStandingRota = false,
  });

  final String employee;
  final String employeeName;
  final String? designation;
  final bool isCourier;
  final String? shiftLocation;
  final String? shiftType;

  /// English weekday names; empty when they have no standing rota.
  final List<String> offDays;
  final bool useFridayVariant;
  final String? fridayShiftType;
  final List<RosterPlanCover> covers;
  final bool hasStandingRota;

  /// The name to show: the employee name, else the ID.
  String get displayName =>
      employeeName.trim().isEmpty ? employee : employeeName;

  factory RosterPlanDefaultsEmployee.fromJson(Map<String, dynamic> json) =>
      RosterPlanDefaultsEmployee(
        employee: (json['employee'] ?? '').toString(),
        employeeName: (json['employee_name'] ?? '').toString(),
        designation: _nullIfBlank(json['designation']),
        isCourier: _isTrue(json['is_courier']),
        shiftLocation: _nullIfBlank(json['shift_location']),
        shiftType: _nullIfBlank(json['shift_type']),
        offDays: _weekdays(json['off_days']),
        useFridayVariant: _isTrue(json['use_friday_variant']),
        fridayShiftType: _nullIfBlank(json['friday_shift_type']),
        covers: (json['covers'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((e) => RosterPlanCover.fromJson(Map<String, dynamic>.from(e)))
            .where((c) => c.weekday.isNotEmpty)
            .toList(),
        hasStandingRota: _isTrue(json['has_standing_rota']),
      );
}

class RosterPlanDefaults {
  const RosterPlanDefaults({this.suggestedStart, this.employees = const []});

  /// `YYYY-MM-DD`, the first day of next month in the site's timezone.
  final String? suggestedStart;
  final List<RosterPlanDefaultsEmployee> employees;

  factory RosterPlanDefaults.fromJson(Map<String, dynamic> json) =>
      RosterPlanDefaults(
        suggestedStart: _nullIfBlank(json['suggested_start']),
        employees: (json['employees'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (e) => RosterPlanDefaultsEmployee.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .where((e) => e.employee.isNotEmpty)
            .toList(),
      );
}

enum RosterPlanSeverity { error, warning, info }

/// A problem (or note) the preview found.
class RosterPlanIssue {
  const RosterPlanIssue({
    required this.code,
    required this.severity,
    required this.message,
    this.employee,
    this.employeeName,
    this.date,
  });

  final String code;
  final RosterPlanSeverity severity;
  final String message;
  final String? employee;
  final String? employeeName;
  final String? date;

  bool get isError => severity == RosterPlanSeverity.error;
  bool get isWarning => severity == RosterPlanSeverity.warning;

  factory RosterPlanIssue.fromJson(Map<String, dynamic> json) =>
      RosterPlanIssue(
        code: (json['code'] ?? '').toString(),
        severity: _severity(json['severity']),
        message: (json['message'] ?? '').toString(),
        employee: _nullIfBlank(json['employee']),
        employeeName: _nullIfBlank(json['employee_name']),
        date: _nullIfBlank(json['date']),
      );

  /// An unknown severity is read as a warning: shown, never silently dropped,
  /// and never blocking Apply on a word this client does not know.
  static RosterPlanSeverity _severity(dynamic value) {
    switch ((value ?? '').toString().trim().toLowerCase()) {
      case 'error':
        return RosterPlanSeverity.error;
      case 'info':
        return RosterPlanSeverity.info;
      default:
        return RosterPlanSeverity.warning;
    }
  }
}

/// A day in the period that somebody edited by hand.
class RosterPlanManualDay {
  const RosterPlanManualDay({
    required this.date,
    required this.kind,
    this.current,
  });

  final String date;

  /// `shift` | `day_off` | `cover` | `empty`.
  final String kind;

  /// Human text from the server: the shift, "Off", `Covering <name>`.
  final String? current;

  factory RosterPlanManualDay.fromJson(Map<String, dynamic> json) =>
      RosterPlanManualDay(
        date: (json['date'] ?? '').toString(),
        kind: (json['kind'] ?? '').toString(),
        current: _nullIfBlank(json['current']),
      );
}

class RosterPlanResultRow {
  const RosterPlanResultRow({
    required this.employee,
    required this.employeeName,
    this.shiftType,
    this.fridayShiftType,
    this.shiftLocation,
    this.shiftDays = 0,
    this.dayOffs = 0,
    this.covers = 0,
    this.manualDays = const [],
    this.issues = const [],
  });

  final String employee;
  final String employeeName;
  final String? shiftType;
  final String? fridayShiftType;
  final String? shiftLocation;
  final int shiftDays;
  final int dayOffs;
  final int covers;
  final List<RosterPlanManualDay> manualDays;
  final List<RosterPlanIssue> issues;

  String get displayName =>
      employeeName.trim().isEmpty ? employee : employeeName;

  factory RosterPlanResultRow.fromJson(Map<String, dynamic> json) =>
      RosterPlanResultRow(
        employee: (json['employee'] ?? '').toString(),
        employeeName: (json['employee_name'] ?? '').toString(),
        shiftType: _nullIfBlank(json['shift_type']),
        fridayShiftType: _nullIfBlank(json['friday_shift_type']),
        shiftLocation: _nullIfBlank(json['shift_location']),
        shiftDays: _toInt(json['shift_days']),
        dayOffs: _toInt(json['day_offs']),
        covers: _toInt(json['covers']),
        manualDays: (json['manual_days'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (e) => RosterPlanManualDay.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
        issues: (json['issues'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((e) => RosterPlanIssue.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class RosterPlanSummary {
  const RosterPlanSummary({
    this.people = 0,
    this.shiftDays = 0,
    this.dayOffs = 0,
    this.covers = 0,
    this.manualKept = 0,
    this.manualReplaced = 0,
    this.errors = 0,
    this.warnings = 0,
  });

  final int people;
  final int shiftDays;
  final int dayOffs;
  final int covers;
  final int manualKept;
  final int manualReplaced;
  final int errors;
  final int warnings;

  factory RosterPlanSummary.fromJson(Map<String, dynamic> json) =>
      RosterPlanSummary(
        people: _toInt(json['people']),
        shiftDays: _toInt(json['shift_days']),
        dayOffs: _toInt(json['day_offs']),
        covers: _toInt(json['covers']),
        manualKept: _toInt(json['manual_kept']),
        manualReplaced: _toInt(json['manual_replaced']),
        errors: _toInt(json['errors']),
        warnings: _toInt(json['warnings']),
      );
}

/// The preview (dry run) or the outcome of applying — the same shape.
class RosterPlanResult {
  const RosterPlanResult({
    required this.dryRun,
    required this.applied,
    this.start,
    this.end,
    this.summary = const RosterPlanSummary(),
    this.rows = const [],
    this.issues = const [],
  });

  final bool dryRun;
  final bool applied;
  final String? start;
  final String? end;
  final RosterPlanSummary summary;
  final List<RosterPlanResultRow> rows;

  /// Every issue, flattened across rows.
  final List<RosterPlanIssue> issues;

  List<RosterPlanIssue> get errors =>
      issues.where((i) => i.severity == RosterPlanSeverity.error).toList();
  List<RosterPlanIssue> get warnings =>
      issues.where((i) => i.severity == RosterPlanSeverity.warning).toList();
  List<RosterPlanIssue> get notes =>
      issues.where((i) => i.severity == RosterPlanSeverity.info).toList();

  /// Apply is refused server-side while any error exists; the button refuses
  /// first. The summary count is honoured too, in case the server counted an
  /// error it did not list.
  bool get hasErrors => errors.isNotEmpty || summary.errors > 0;

  List<RosterPlanResultRow> get rowsWithManualDays =>
      rows.where((r) => r.manualDays.isNotEmpty).toList();

  factory RosterPlanResult.fromJson(Map<String, dynamic> json) {
    final rows = (json['rows'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => RosterPlanResultRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    var issues = (json['issues'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => RosterPlanIssue.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    // Only the per-row lists came back: rebuild the flat list from them, so a
    // row-level error still blocks Apply.
    if (issues.isEmpty) {
      issues = [
        for (final row in rows)
          for (final issue in row.issues)
            RosterPlanIssue(
              code: issue.code,
              severity: issue.severity,
              message: issue.message,
              employee: issue.employee ?? row.employee,
              employeeName: issue.employeeName ?? row.displayName,
              date: issue.date,
            ),
      ];
    }
    return RosterPlanResult(
      dryRun: json['dry_run'] == null ? true : _isTrue(json['dry_run']),
      applied: _isTrue(json['applied']),
      start: _nullIfBlank(json['start']),
      end: _nullIfBlank(json['end']),
      summary: RosterPlanSummary.fromJson(
        Map<String, dynamic>.from(json['summary'] as Map? ?? const {}),
      ),
      rows: rows,
      issues: issues,
    );
  }
}

List<String> _weekdays(dynamic value) {
  if (value is! List) return const [];
  final wanted = {for (final v in value) v.toString().trim().toLowerCase()};
  // Normalised to the canonical spelling and the wizard's Saturday-first order.
  return rosterPlanWeekdays
      .where((d) => wanted.contains(d.toLowerCase()))
      .toList();
}

bool _isTrue(dynamic value) =>
    value == true || value == 1 || value == '1' || value == 'true';

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _nullIfBlank(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
