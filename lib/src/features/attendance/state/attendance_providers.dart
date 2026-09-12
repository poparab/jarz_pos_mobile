import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/attendance_repository.dart';
import '../models/attendance_models.dart';

// ── Shared filters ─────────────────────────────────────────────────────

/// The month being looked at, as `YYYY-MM`.
///
/// Seeded from the device clock only as an opening guess; every request sends
/// the string explicitly, so the server's idea of "now" and the phone's cannot
/// drift apart mid-session. Same contract as `rosterMonthProvider`.
final attendanceMonthProvider = StateProvider<String>((ref) {
  return attendanceMonthOf(DateTime.now());
});

/// Branch filter, shared by the Month, Day and Summary tabs. Null means
/// "every branch I can see".
final attendanceLocationFilterProvider = StateProvider<String?>((ref) => null);

/// The day the Day tab is showing, as `YYYY-MM-DD`.
final attendanceDayProvider = StateProvider<String>((ref) {
  return attendanceIsoDate(DateTime.now());
});

/// Who the Employee tab is showing. Null until one is picked.
final attendanceSelectedEmployeeProvider = StateProvider<String?>((ref) => null);

/// The range the Employee and Summary tabs read, defaulting to the current
/// month so opening either tab shows something real immediately.
final attendanceRangeProvider = StateProvider<AttendanceRange>((ref) {
  return AttendanceRange.ofMonth(attendanceMonthOf(DateTime.now()));
});

/// Branch / Employee / Day toggle on the Summary tab.
final attendanceGroupByProvider = StateProvider<AttendanceGroupBy>(
  (ref) => AttendanceGroupBy.branch,
);

/// Which column the summary table is sorted on, and which way.
final attendanceSummarySortProvider = StateProvider<AttendanceSummarySort>(
  (ref) => const AttendanceSummarySort(),
);

// ── Reads ──────────────────────────────────────────────────────────────

final attendanceBootstrapProvider = FutureProvider<AttendanceBootstrap>((
  ref,
) async {
  return ref.watch(attendanceRepositoryProvider).getBootstrap();
});

final attendanceMonthDataProvider = FutureProvider<AttendanceMonth>((ref) async {
  final month = ref.watch(attendanceMonthProvider);
  final location = ref.watch(attendanceLocationFilterProvider);
  return ref
      .watch(attendanceRepositoryProvider)
      .getMonth(month: month, shiftLocation: location);
});

final attendanceDayDataProvider = FutureProvider<AttendanceDay>((ref) async {
  final date = ref.watch(attendanceDayProvider);
  final location = ref.watch(attendanceLocationFilterProvider);
  return ref
      .watch(attendanceRepositoryProvider)
      .getDay(date: date, shiftLocation: location);
});

/// One person's range. Keyed by the whole query so switching back to a person
/// already looked at is instant, and so two people's data can never be shown
/// under the wrong name while a second request is in flight.
final attendanceEmployeeDataProvider =
    FutureProvider.family<AttendanceEmployeeDetail, AttendanceEmployeeQuery>((
      ref,
      query,
    ) async {
      return ref
          .watch(attendanceRepositoryProvider)
          .getEmployee(
            employee: query.employee,
            fromDate: query.fromDate,
            toDate: query.toDate,
          );
    });

final attendanceSummaryDataProvider =
    FutureProvider.family<AttendanceSummary, AttendanceSummaryQuery>((
      ref,
      query,
    ) async {
      return ref
          .watch(attendanceRepositoryProvider)
          .getSummary(
            fromDate: query.fromDate,
            toDate: query.toDate,
            groupBy: query.groupBy,
            shiftLocation: query.shiftLocation,
          );
    });

/// The employee picker's options.
///
/// Derived from the month payload rather than fetched separately: the month
/// endpoint already returns exactly the people this manager is allowed to see,
/// so a second source could offer somebody the detail call would then refuse.
final attendanceEmployeeOptionsProvider = Provider<List<AttendanceEmployeeOption>>(
  (ref) {
    final month = ref.watch(attendanceMonthDataProvider);
    final employees = month.asData?.value.employees ?? const [];
    final options = employees
        .map(
          (e) => AttendanceEmployeeOption(
            employee: e.employee,
            employeeName: e.employeeName,
            designation: e.designation,
          ),
        )
        .toList();
    options.sort((a, b) => a.employeeName.compareTo(b.employeeName));
    return options;
  },
);

// ── Value objects ──────────────────────────────────────────────────────

/// An inclusive date range, `YYYY-MM-DD` on both ends.
class AttendanceRange {
  const AttendanceRange({required this.fromDate, required this.toDate});

  final String fromDate;
  final String toDate;

  /// The whole of a `YYYY-MM` month.
  factory AttendanceRange.ofMonth(String month) {
    final parts = month.split('-');
    final year = int.tryParse(parts.first) ?? DateTime.now().year;
    final monthNumber = parts.length > 1
        ? (int.tryParse(parts[1]) ?? DateTime.now().month)
        : DateTime.now().month;
    // Day 0 of the NEXT month is the last day of this one — the only form of
    // this that gets February right without a leap-year branch.
    final end = DateTime(year, monthNumber + 1, 0);
    return AttendanceRange(
      fromDate: attendanceIsoDate(DateTime(year, monthNumber, 1)),
      toDate: attendanceIsoDate(end),
    );
  }

  AttendanceRange copyWith({String? fromDate, String? toDate}) =>
      AttendanceRange(
        fromDate: fromDate ?? this.fromDate,
        toDate: toDate ?? this.toDate,
      );

  @override
  bool operator ==(Object other) =>
      other is AttendanceRange &&
      other.fromDate == fromDate &&
      other.toDate == toDate;

  @override
  int get hashCode => Object.hash(fromDate, toDate);
}

/// The family key for one person's attendance. Value equality is what makes
/// the family cache work at all.
class AttendanceEmployeeQuery {
  const AttendanceEmployeeQuery({
    required this.employee,
    required this.fromDate,
    required this.toDate,
  });

  final String employee;
  final String fromDate;
  final String toDate;

  @override
  bool operator ==(Object other) =>
      other is AttendanceEmployeeQuery &&
      other.employee == employee &&
      other.fromDate == fromDate &&
      other.toDate == toDate;

  @override
  int get hashCode => Object.hash(employee, fromDate, toDate);
}

/// The family key for the summary table.
class AttendanceSummaryQuery {
  const AttendanceSummaryQuery({
    required this.fromDate,
    required this.toDate,
    required this.groupBy,
    this.shiftLocation,
  });

  final String fromDate;
  final String toDate;
  final AttendanceGroupBy groupBy;
  final String? shiftLocation;

  @override
  bool operator ==(Object other) =>
      other is AttendanceSummaryQuery &&
      other.fromDate == fromDate &&
      other.toDate == toDate &&
      other.groupBy == groupBy &&
      other.shiftLocation == shiftLocation;

  @override
  int get hashCode => Object.hash(fromDate, toDate, groupBy, shiftLocation);
}

class AttendanceEmployeeOption {
  const AttendanceEmployeeOption({
    required this.employee,
    required this.employeeName,
    this.designation,
  });

  final String employee;
  final String employeeName;
  final String? designation;
}

/// The sortable columns of the summary table.
enum AttendanceSummaryColumn {
  label,
  rosteredDays,
  presentDays,
  lateDays,
  lateUnmatchedDays,
  absentDays,
  pendingDays,
  workedHours,
  avgLateMinutes,
  attendanceRate,
  punctualityRate,
}

class AttendanceSummarySort {
  const AttendanceSummarySort({
    this.column = AttendanceSummaryColumn.label,
    this.ascending = true,
  });

  final AttendanceSummaryColumn column;
  final bool ascending;

  /// Tapping the active column flips direction; tapping another column starts
  /// it descending, because every numeric column is asked "who is worst" first.
  AttendanceSummarySort toggled(AttendanceSummaryColumn next) {
    if (next == column) {
      return AttendanceSummarySort(column: column, ascending: !ascending);
    }
    return AttendanceSummarySort(
      column: next,
      ascending: next == AttendanceSummaryColumn.label,
    );
  }
}

/// Sorts the summary rows client-side.
///
/// Client-side on purpose: the row set is one screen's worth of aggregates
/// that are already in memory, and re-fetching to reorder would make a tap on
/// a column header cost a round trip.
List<AttendanceSummaryRow> sortAttendanceSummaryRows(
  List<AttendanceSummaryRow> rows,
  AttendanceSummarySort sort,
) {
  final sorted = List<AttendanceSummaryRow>.from(rows);
  int compare(AttendanceSummaryRow a, AttendanceSummaryRow b) {
    switch (sort.column) {
      case AttendanceSummaryColumn.label:
        return a.label.compareTo(b.label);
      case AttendanceSummaryColumn.rosteredDays:
        return a.rosteredDays.compareTo(b.rosteredDays);
      case AttendanceSummaryColumn.presentDays:
        return a.presentDays.compareTo(b.presentDays);
      case AttendanceSummaryColumn.lateDays:
        return a.lateDays.compareTo(b.lateDays);
      case AttendanceSummaryColumn.lateUnmatchedDays:
        return a.lateUnmatchedDays.compareTo(b.lateUnmatchedDays);
      case AttendanceSummaryColumn.absentDays:
        return a.absentDays.compareTo(b.absentDays);
      case AttendanceSummaryColumn.pendingDays:
        return a.pendingDays.compareTo(b.pendingDays);
      case AttendanceSummaryColumn.workedHours:
        return a.workedHours.compareTo(b.workedHours);
      case AttendanceSummaryColumn.avgLateMinutes:
        return a.avgLateMinutes.compareTo(b.avgLateMinutes);
      case AttendanceSummaryColumn.attendanceRate:
        return a.attendanceRate.compareTo(b.attendanceRate);
      case AttendanceSummaryColumn.punctualityRate:
        return a.punctualityRate.compareTo(b.punctualityRate);
    }
  }

  sorted.sort((a, b) => sort.ascending ? compare(a, b) : compare(b, a));
  return sorted;
}

// ── Date helpers ───────────────────────────────────────────────────────

/// `YYYY-MM-DD` from a local `DateTime`, with no timezone arithmetic.
String attendanceIsoDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// `YYYY-MM` from a local `DateTime`.
String attendanceMonthOf(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}';
}

/// Shift the visible month by [delta] months.
///
/// Done with a `DateTime` round-trip rather than by adding to the month number
/// so December -> January rolls the year, which hand-rolled arithmetic on the
/// `YYYY-MM` string routinely gets wrong.
String shiftAttendanceMonth(String month, int delta) {
  final parts = month.split('-');
  final year = int.tryParse(parts.first) ?? DateTime.now().year;
  final monthNumber = parts.length > 1
      ? (int.tryParse(parts[1]) ?? DateTime.now().month)
      : DateTime.now().month;
  final shifted = DateTime(year, monthNumber + delta, 1);
  return attendanceMonthOf(shifted);
}

/// Shift a `YYYY-MM-DD` day by [delta] days, month and year boundaries included.
String shiftAttendanceDay(String date, int delta) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return date;
  return attendanceIsoDate(
    DateTime(parsed.year, parsed.month, parsed.day + delta),
  );
}
