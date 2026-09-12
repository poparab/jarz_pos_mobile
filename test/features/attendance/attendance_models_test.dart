import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/attendance/models/attendance_models.dart';
import 'package:jarz_pos/src/features/attendance/state/attendance_providers.dart';

/// Parsing the five attendance endpoints, with the nulls the frozen contract
/// actually allows.
///
/// The payloads below are written out as the contract spells them rather than
/// trimmed to what the code reads, so a field the backend adds or renames
/// shows up here as a failing expectation instead of as a silently missing
/// number on a manager's screen.
void main() {
  group('AttendanceStatus parsing', () {
    test('every contract string maps to its own enum value', () {
      expect(attendanceStatusFromWire('present'), AttendanceStatus.present);
      expect(attendanceStatusFromWire('late'), AttendanceStatus.late);
      expect(
        attendanceStatusFromWire('late_unmatched'),
        AttendanceStatus.lateUnmatched,
      );
      expect(attendanceStatusFromWire('absent'), AttendanceStatus.absent);
      expect(attendanceStatusFromWire('pending'), AttendanceStatus.pending);
      expect(attendanceStatusFromWire('off'), AttendanceStatus.off);
      expect(attendanceStatusFromWire('holiday'), AttendanceStatus.holiday);
      expect(
        attendanceStatusFromWire('not_rostered'),
        AttendanceStatus.notRostered,
      );
    });

    test('an unknown, empty or null status degrades instead of throwing', () {
      // A backend that grows a ninth status must not crash a list builder on
      // an installed phone that predates it.
      expect(
        attendanceStatusFromWire('half_day_leave'),
        AttendanceStatus.unknown,
      );
      expect(attendanceStatusFromWire(''), AttendanceStatus.unknown);
      expect(attendanceStatusFromWire(null), AttendanceStatus.unknown);
      expect(attendanceStatusFromWire(7), AttendanceStatus.unknown);
    });

    test('round-trips through the wire spelling', () {
      for (final status in kAttendanceStatusOrder) {
        expect(
          attendanceStatusFromWire(attendanceStatusToWire(status)),
          status,
        );
      }
    });

    test('the legend order covers every status except unknown', () {
      // The legend is generated from this list. A status that exists but is
      // not in it would be a colour on the grid that nothing explains.
      expect(
        kAttendanceStatusOrder.toSet(),
        AttendanceStatus.values.toSet()..remove(AttendanceStatus.unknown),
      );
      expect(kAttendanceStatusOrder.length, 8);
    });
  });

  group('AttendanceCell.fromJson', () {
    test('parses a full late day', () {
      final cell = AttendanceCell.fromJson({
        'date': '2026-09-10',
        'status': 'late',
        'shift_type': 'Branch Opening',
        'shift_location': 'Nasr City',
        'scheduled_start': '09:00',
        'scheduled_end': '18:00',
        'first_in': '2026-09-10 09:42:00',
        'last_out': '2026-09-10 18:05:00',
        'late_minutes': 42,
        'worked_hours': 8.4,
        'checkin_count': 2,
        'offshift': false,
        'geo_ok': true,
        'day_off': null,
        'is_cover': false,
      });

      expect(cell.status, AttendanceStatus.late);
      expect(cell.rawStatus, 'late');
      expect(cell.lateMinutes, 42);
      expect(cell.lateMinutesPositive, 42);
      expect(cell.workedHours, 8.4);
      expect(cell.checkinCount, 2);
      expect(cell.hasCheckin, isTrue);
      expect(cell.geoOk, isTrue);
      expect(cell.isRostered, isTrue);
      expect(cell.dayOff, isNull);
    });

    test('accepts null in every place the contract allows one', () {
      final cell = AttendanceCell.fromJson({
        'date': '2026-09-11',
        'status': 'pending',
        'shift_type': null,
        'shift_location': null,
        'scheduled_start': null,
        'scheduled_end': null,
        'first_in': null,
        'last_out': null,
        'late_minutes': null,
        'worked_hours': null,
        'checkin_count': 0,
        'offshift': false,
        'geo_ok': null,
        'day_off': null,
        'is_cover': false,
      });

      expect(cell.status, AttendanceStatus.pending);
      expect(cell.shiftType, isNull);
      expect(cell.scheduledStart, isNull);
      expect(cell.firstIn, isNull);
      expect(cell.lateMinutes, isNull);
      // Null hours is NOT zero hours: one is a missing second punch, the other
      // is somebody who left immediately.
      expect(cell.workedHours, isNull);
      expect(cell.geoOk, isNull);
      expect(cell.hasCheckin, isFalse);
    });

    test('worked_hours 0 stays 0 and does not collapse into null', () {
      final cell = AttendanceCell.fromJson({
        'date': '2026-09-11',
        'status': 'present',
        'worked_hours': 0,
        'checkin_count': 1,
      });

      expect(cell.workedHours, 0);
      expect(cell.workedHours, isNotNull);
    });

    test('geo_ok false is not the same as geo_ok missing', () {
      final outside = AttendanceCell.fromJson({
        'date': '2026-09-11',
        'status': 'present',
        'geo_ok': false,
      });
      final unrecorded = AttendanceCell.fromJson({
        'date': '2026-09-11',
        'status': 'present',
      });

      expect(outside.geoOk, isFalse);
      expect(unrecorded.geoOk, isNull);
    });

    test('a negative late_minutes means early, not late', () {
      final cell = AttendanceCell.fromJson({
        'date': '2026-09-11',
        'status': 'present',
        'late_minutes': -12,
      });

      expect(cell.lateMinutes, -12);
      expect(cell.lateMinutesPositive, 0);
    });

    test('an arrival outside the shift window keeps its own status', () {
      // shift=None, offshift=1, shift_start=NULL is an ARRIVAL, not "no data".
      final cell = AttendanceCell.fromJson({
        'date': '2026-09-11',
        'status': 'late_unmatched',
        'scheduled_start': null,
        'first_in': '2026-09-11 23:58:00',
        'late_minutes': null,
        'checkin_count': 1,
        'offshift': 1,
      });

      expect(cell.status, AttendanceStatus.lateUnmatched);
      expect(cell.offshift, isTrue);
      expect(cell.hasCheckin, isTrue);
      expect(cell.isRostered, isTrue);
    });

    test('a day off carries its type and who covered it', () {
      final cell = AttendanceCell.fromJson({
        'date': '2026-09-11',
        'status': 'off',
        'day_off': {
          'off_type': 'Weekly Off',
          'covered_by': 'HR-EMP-00002',
          'covered_by_name': 'Ahmed Samir',
        },
      });

      expect(cell.status, AttendanceStatus.off);
      expect(cell.dayOff!.offType, 'Weekly Off');
      expect(cell.dayOff!.isCovered, isTrue);
      expect(cell.dayOff!.coveredByName, 'Ahmed Samir');
      expect(cell.isRostered, isFalse);
    });

    test('an uncovered day off reports nobody covering', () {
      final cell = AttendanceCell.fromJson({
        'date': '2026-09-11',
        'status': 'off',
        'day_off': {'off_type': 'Vacation', 'covered_by': null},
      });

      expect(cell.dayOff!.isCovered, isFalse);
      expect(cell.dayOff!.coveredByName, isNull);
    });

    test('an unrecognised status becomes unknown and keeps the raw string', () {
      final cell = AttendanceCell.fromJson({
        'date': '2026-09-11',
        'status': 'half_day',
      });

      expect(cell.status, AttendanceStatus.unknown);
      expect(cell.rawStatus, 'half_day');
    });

    test('a missing date falls back to the key it was stored under', () {
      final cell = AttendanceCell.fromJson({
        'status': 'present',
      }, fallbackDate: '2026-09-11');

      expect(cell.date, '2026-09-11');
    });
  });

  group('AttendanceMonth.fromJson', () {
    Map<String, dynamic> monthPayload() => {
      'success': true,
      'hrms_available': true,
      'month': '2026-09',
      'month_start': '2026-09-01',
      'month_end': '2026-09-30',
      'scope': {
        'configured': true,
        'unrestricted': false,
        'locations': ['Nasr City'],
      },
      'grace_minutes': 15,
      'employees': [
        {
          'employee': 'HR-EMP-00001',
          'employee_name': 'Mona Adel',
          'designation': 'Cashier',
          'department': null,
          'shift_locations': ['Nasr City'],
          'is_courier': false,
          'days': {
            '2026-09-01': {
              'date': '2026-09-01',
              'status': 'absent',
              'checkin_count': 0,
            },
            '2026-09-02': {
              'date': '2026-09-02',
              'status': 'off',
              'checkin_count': 0,
            },
          },
          'totals': {
            'rostered_days': 2,
            'present_days': 0,
            'late_days': 0,
            'absent_days': 1,
            'off_days': 1,
            'worked_hours': 0.0,
            'late_minutes': 0,
            'attendance_rate': 0.0,
            'punctuality_rate': 0.0,
          },
        },
        {
          'employee': 'HR-EMP-00002',
          'employee_name': 'Ahmed Samir',
          // Hired mid-month: fewer days than the row above.
          'days': {
            '2026-09-03': {
              'date': '2026-09-03',
              'status': 'present',
              'checkin_count': 2,
            },
          },
          'totals': {'rostered_days': 1, 'present_days': 1},
        },
      ],
      'totals': {
        'employees': 2,
        'rostered_days': 3,
        'present_days': 1,
        'late_days': 0,
        'absent_days': 1,
        'off_days': 1,
        'worked_hours': 8.0,
        'late_minutes': 0,
        'attendance_rate': 0.3333,
        'punctuality_rate': 1.0,
      },
    };

    test('parses employees, cells and totals', () {
      final month = AttendanceMonth.fromJson(monthPayload());

      expect(month.month, '2026-09');
      expect(month.monthStart, '2026-09-01');
      expect(month.employees, hasLength(2));
      expect(month.graceMinutes, 15);
      expect(month.totals.employees, 2);
      expect(month.totals.rosteredDays, 3);
      expect(month.scope.configured, isTrue);
      expect(month.scope.locations, ['Nasr City']);
      expect(
        month.employees.first.cellFor('2026-09-02')!.status,
        AttendanceStatus.off,
      );
    });

    test('column dates are the UNION of every row', () {
      // A person hired mid-month must not shorten everybody else's calendar,
      // which is what reading the dates off the first row alone would do.
      final month = AttendanceMonth.fromJson(monthPayload());

      expect(month.dates, ['2026-09-01', '2026-09-02', '2026-09-03']);
    });

    test('a month with no check-ins at all says so', () {
      final payload = monthPayload();
      // Production today: everyone rostered, nobody clocking in.
      for (final employee in payload['employees'] as List) {
        for (final day in (employee['days'] as Map).values) {
          (day as Map)['checkin_count'] = 0;
        }
      }
      final month = AttendanceMonth.fromJson(payload);

      expect(month.hasAnyCheckin, isFalse);
    });

    test('one check-in anywhere flips hasAnyCheckin', () {
      expect(AttendanceMonth.fromJson(monthPayload()).hasAnyCheckin, isTrue);
    });

    test('the degraded HRMS-missing shape parses without employees', () {
      final month = AttendanceMonth.fromJson({
        'success': true,
        'hrms_available': false,
        'notice': 'HRMS is not installed on this site.',
      });

      expect(month.hrmsAvailable, isFalse);
      expect(month.notice, 'HRMS is not installed on this site.');
      expect(month.employees, isEmpty);
      expect(month.dates, isEmpty);
      expect(month.totals.rosteredDays, 0);
    });
  });

  group('AttendanceDay.fromJson', () {
    Map<String, dynamic> dayPayload() => {
      'success': true,
      'hrms_available': true,
      'date': '2026-09-12',
      'scope': {'configured': true, 'unrestricted': true, 'locations': null},
      'grace_minutes': 15,
      'branches': [
        {
          'shift_location': 'Nasr City',
          'totals': {
            'rostered': 2,
            'present': 1,
            'late': 1,
            'absent': 0,
            'pending': 0,
            'off': 0,
          },
          'rows': [
            {
              'employee': 'HR-EMP-00001',
              'employee_name': 'Mona Adel',
              'designation': 'Cashier',
              'is_courier': false,
              'status': 'late',
              'shift_type': 'Branch Opening',
              'scheduled_start': '09:00',
              'scheduled_end': '18:00',
              'first_in': '2026-09-12 09:42:00',
              'last_out': null,
              'late_minutes': 42,
              'worked_hours': null,
              'checkin_count': 1,
              'offshift': false,
              'geo_ok': false,
              'day_off': null,
              'is_cover': false,
            },
            {
              'employee': 'HR-EMP-00002',
              'employee_name': 'Ahmed Samir',
              'status': 'present',
              'checkin_count': 2,
            },
          ],
        },
        {
          // The bucket with no branch. Always last, never blank.
          'shift_location': null,
          'totals': {'rostered': 1, 'present': 0, 'pending': 1},
          'rows': [
            {
              'employee': 'HR-EMP-00009',
              'employee_name': 'Unassigned Person',
              'status': 'pending',
              'checkin_count': 0,
            },
          ],
        },
      ],
      'totals': {
        'rostered': 3,
        'present': 1,
        'late': 1,
        'late_unmatched': 0,
        'absent': 0,
        'pending': 1,
        'off': 0,
      },
    };

    test('parses branches, rows and both totals levels', () {
      final day = AttendanceDay.fromJson(dayPayload());

      expect(day.date, '2026-09-12');
      expect(day.branches, hasLength(2));
      expect(day.totals.late, 1);
      expect(day.totals.rostered, 3);
      expect(day.branches.first.totals.rostered, 2);
      expect(day.branches.first.rows.first.employeeName, 'Mona Adel');
      expect(day.branches.first.rows.first.status, AttendanceStatus.late);
      expect(day.branches.first.rows.first.cell.lateMinutes, 42);
      expect(day.branches.first.rows.first.cell.geoOk, isFalse);
    });

    test('a row inherits the day it belongs to', () {
      // The row payload has no `date` of its own; the sheet still has to know
      // which day it is looking at.
      final day = AttendanceDay.fromJson(dayPayload());

      expect(day.branches.first.rows.first.cell.date, '2026-09-12');
    });

    test('the null branch is flagged, not blank', () {
      final day = AttendanceDay.fromJson(dayPayload());
      final last = day.branches.last;

      expect(last.shiftLocation, isNull);
      expect(last.isUnresolvedBranch, isTrue);
      expect(day.branches.first.isUnresolvedBranch, isFalse);
    });

    test('an empty-string branch counts as unresolved too', () {
      final branch = AttendanceBranchDay.fromJson({
        'shift_location': '   ',
        'totals': {},
        'rows': [],
      }, date: '2026-09-12');

      expect(branch.shiftLocation, isNull);
      expect(branch.isUnresolvedBranch, isTrue);
    });

    test('row order is preserved exactly as the server sent it', () {
      final day = AttendanceDay.fromJson(dayPayload());

      expect(
        day.branches.first.rows.map((r) => r.employee).toList(),
        ['HR-EMP-00001', 'HR-EMP-00002'],
      );
    });

    test('a day where nobody checked in is detectable', () {
      final payload = dayPayload();
      for (final branch in payload['branches'] as List) {
        for (final row in (branch as Map)['rows'] as List) {
          (row as Map)['checkin_count'] = 0;
        }
      }

      expect(AttendanceDay.fromJson(payload).hasAnyCheckin, isFalse);
      expect(AttendanceDay.fromJson(payload).hasAnyRow, isTrue);
    });

    test('no branches at all is an empty day, not a crash', () {
      final day = AttendanceDay.fromJson({
        'success': true,
        'hrms_available': true,
        'date': '2026-09-12',
        'branches': [],
      });

      expect(day.branches, isEmpty);
      expect(day.hasAnyRow, isFalse);
      expect(day.totals.rostered, 0);
    });
  });

  group('AttendanceEmployeeDetail.fromJson', () {
    final payload = {
      'success': true,
      'hrms_available': true,
      'employee': 'HR-EMP-00001',
      'employee_name': 'Mona Adel',
      'designation': 'Cashier',
      'department': null,
      'is_courier': false,
      'shift_locations': ['Nasr City', 'Obour'],
      'from_date': '2026-09-01',
      'to_date': '2026-09-03',
      'grace_minutes': 15,
      'days': [
        {'date': '2026-09-01', 'status': 'present', 'checkin_count': 2},
        {'date': '2026-09-02', 'status': 'absent', 'checkin_count': 0},
        {'date': '2026-09-03', 'status': 'not_rostered', 'checkin_count': 0},
      ],
      'totals': {
        'rostered_days': 2,
        'present_days': 1,
        'late_days': 0,
        'absent_days': 1,
        'off_days': 0,
        'worked_hours': 8.5,
        'late_minutes': 0,
        'attendance_rate': 0.5,
        'punctuality_rate': 1.0,
      },
      'by_branch': [
        {
          'shift_location': 'Nasr City',
          'rostered_days': 1,
          'present_days': 1,
          'late_days': 0,
          'absent_days': 0,
          'worked_hours': 8.5,
        },
        {
          'shift_location': null,
          'rostered_days': 1,
          'present_days': 0,
          'late_days': 0,
          'absent_days': 1,
          'worked_hours': 0.0,
        },
      ],
      'checkins': [
        {
          'name': 'EMP-CKIN-2026-00001',
          'time': '2026-09-01 08:58:00',
          'log_type': 'IN',
          'shift': 'Branch Opening',
          'offshift': false,
          'latitude': 30.06,
          'longitude': 31.33,
          'geo_ok': true,
        },
        {
          'name': 'EMP-CKIN-2026-00002',
          'time': '2026-09-01 17:31:00',
          'log_type': null,
          'shift': null,
          'offshift': true,
          'latitude': null,
          'longitude': null,
          'geo_ok': null,
        },
      ],
    };

    test('parses identity, days, totals, branches and raw check-ins', () {
      final detail = AttendanceEmployeeDetail.fromJson(payload);

      expect(detail.employeeName, 'Mona Adel');
      expect(detail.department, isNull);
      expect(detail.shiftLocations, ['Nasr City', 'Obour']);
      expect(detail.days, hasLength(3));
      expect(detail.totals.attendanceRate, 0.5);
      expect(detail.byBranch, hasLength(2));
      expect(detail.checkins, hasLength(2));
      expect(detail.hasAnyCheckin, isTrue);
      expect(detail.movedBetweenBranches, isTrue);
    });

    test('days arrive ascending and keep their own dates', () {
      final detail = AttendanceEmployeeDetail.fromJson(payload);

      expect(detail.days.map((d) => d.date).toList(), [
        '2026-09-01',
        '2026-09-02',
        '2026-09-03',
      ]);
      expect(detail.days.last.status, AttendanceStatus.notRostered);
    });

    test('the by-branch bucket with no branch is flagged', () {
      final detail = AttendanceEmployeeDetail.fromJson(payload);

      expect(detail.byBranch.last.shiftLocation, isNull);
      expect(detail.byBranch.last.isUnresolvedBranch, isTrue);
      expect(detail.byBranch.first.isUnresolvedBranch, isFalse);
    });

    test('a check-in with no coordinates is not "outside the fence"', () {
      final detail = AttendanceEmployeeDetail.fromJson(payload);
      final second = detail.checkins.last;

      expect(second.geoOk, isNull);
      expect(second.hasCoordinates, isFalse);
      expect(second.logType, isNull);
      expect(second.offshift, isTrue);
    });

    test('an employee with no check-ins at all parses cleanly', () {
      final detail = AttendanceEmployeeDetail.fromJson({
        'success': true,
        'hrms_available': true,
        'employee': 'HR-EMP-00003',
        'employee_name': 'Nobody Clocking In',
        'from_date': '2026-09-01',
        'to_date': '2026-09-30',
        'days': [],
        'totals': {},
        'by_branch': [],
        'checkins': [],
      });

      expect(detail.hasAnyCheckin, isFalse);
      expect(detail.movedBetweenBranches, isFalse);
      expect(detail.totals.attendanceRate, 0);
    });
  });

  group('AttendanceSummary.fromJson', () {
    final payload = {
      'success': true,
      'hrms_available': true,
      'from_date': '2026-09-01',
      'to_date': '2026-09-30',
      'group_by': 'branch',
      'scope': {'configured': false, 'unrestricted': true, 'locations': null},
      'grace_minutes': 15,
      'rows': [
        {
          'key': 'Nasr City',
          'label': 'Nasr City',
          'employee': null,
          'shift_location': 'Nasr City',
          'rostered_days': 40,
          'present_days': 30,
          'late_days': 6,
          'absent_days': 4,
          'off_days': 8,
          'worked_hours': 310.5,
          'late_minutes': 180,
          'avg_late_minutes': 30.0,
          'attendance_rate': 0.9,
          'punctuality_rate': 0.8333,
          'employees': 5,
        },
        {
          // Nothing rostered: every rate is a divide by zero the server
          // already resolved to 0.0.
          'key': null,
          'label': 'No branch',
          'employee': null,
          'shift_location': null,
          'rostered_days': 0,
          'present_days': 0,
          'late_days': 0,
          'absent_days': 0,
          'off_days': 0,
          'worked_hours': 0.0,
          'late_minutes': 0,
          'avg_late_minutes': 0.0,
          'attendance_rate': 0.0,
          'punctuality_rate': 0.0,
          'employees': 1,
        },
      ],
      'totals': {
        'rostered_days': 40,
        'present_days': 30,
        'late_days': 6,
        'absent_days': 4,
        'off_days': 8,
        'worked_hours': 310.5,
        'late_minutes': 180,
        'avg_late_minutes': 30.0,
        'attendance_rate': 0.9,
        'punctuality_rate': 0.8333,
        'employees': 6,
      },
    };

    test('parses rows and the totals line through the same shape', () {
      final summary = AttendanceSummary.fromJson(payload);

      expect(summary.groupBy, AttendanceGroupBy.branch);
      expect(summary.rows, hasLength(2));
      expect(summary.rows.first.employees, 5);
      expect(summary.rows.first.avgLateMinutes, 30.0);
      expect(summary.totals.rosteredDays, 40);
      expect(summary.totals.punctualityRate, closeTo(0.8333, 0.0001));
    });

    test('a group with nothing rostered keeps its zero rates', () {
      final summary = AttendanceSummary.fromJson(payload);
      final empty = summary.rows.last;

      expect(empty.rosteredDays, 0);
      expect(empty.attendanceRate, 0.0);
      expect(empty.punctualityRate, 0.0);
      expect(empty.isUnresolvedBranch, isTrue);
    });

    test('hasAnyAttendance is false when nobody was ever present or late', () {
      final quiet = AttendanceSummary.fromJson({
        'from_date': '2026-09-01',
        'to_date': '2026-09-30',
        'group_by': 'day',
        'rows': [
          {'key': '2026-09-01', 'label': '1 Sep', 'rostered_days': 6},
        ],
        'totals': {'rostered_days': 6},
      });

      expect(quiet.hasAnyAttendance, isFalse);
      expect(quiet.groupBy, AttendanceGroupBy.day);
    });

    test('an unrecognised group_by falls back to branch', () {
      expect(attendanceGroupByFromWire('nonsense'), AttendanceGroupBy.branch);
      expect(attendanceGroupByFromWire(null), AttendanceGroupBy.branch);
      expect(
        attendanceGroupByFromWire('employee'),
        AttendanceGroupBy.employee,
      );
    });

    test('the group_by wire spellings match the contract', () {
      expect(attendanceGroupByToWire(AttendanceGroupBy.branch), 'branch');
      expect(attendanceGroupByToWire(AttendanceGroupBy.employee), 'employee');
      expect(attendanceGroupByToWire(AttendanceGroupBy.day), 'day');
    });
  });

  group('AttendanceBootstrap.fromJson', () {
    test('parses locations, scope and the grace window', () {
      final bootstrap = AttendanceBootstrap.fromJson({
        'success': true,
        'hrms_available': true,
        'shift_locations': [
          {
            'shift_location': 'Nasr City',
            'checkin_radius': 120,
            'latitude': 30.06,
            'longitude': 31.33,
          },
        ],
        'scope': {
          'configured': true,
          'unrestricted': false,
          'locations': ['Nasr City'],
        },
        'grace_minutes': 15,
        'statuses': ['present', 'late', 'absent'],
        'checkin_enforced': true,
        'notice': null,
      });

      expect(bootstrap.hrmsAvailable, isTrue);
      expect(bootstrap.shiftLocations.single.checkinRadius, 120);
      expect(bootstrap.shiftLocations.single.latitude, 30.06);
      expect(bootstrap.graceMinutes, 15);
      expect(bootstrap.checkinEnforced, isTrue);
      expect(bootstrap.notice, isNull);
    });

    test('the HRMS-missing shape carries its notice', () {
      final bootstrap = AttendanceBootstrap.fromJson({
        'success': true,
        'hrms_available': false,
        'notice': 'HRMS is not installed.',
      });

      expect(bootstrap.hrmsAvailable, isFalse);
      expect(bootstrap.notice, 'HRMS is not installed.');
      expect(bootstrap.shiftLocations, isEmpty);
      expect(bootstrap.graceMinutes, 0);
    });
  });

  group('AttendanceScope', () {
    test('a manager scoped to no location is detectable', () {
      // Otherwise this reads as "nobody is rostered anywhere", forever.
      final scope = AttendanceScope.fromJson({
        'configured': true,
        'unrestricted': false,
        'locations': <String>[],
      });

      expect(scope.isEmptyScope, isTrue);
    });

    test('unrestricted is never an empty scope', () {
      final scope = AttendanceScope.fromJson({
        'configured': true,
        'unrestricted': true,
        'locations': null,
      });

      expect(scope.isEmptyScope, isFalse);
    });

    test('a scope with locations is not empty', () {
      final scope = AttendanceScope.fromJson({
        'configured': true,
        'unrestricted': false,
        'locations': ['Obour'],
      });

      expect(scope.isEmptyScope, isFalse);
    });
  });

  group('date helpers', () {
    test('month stepping rolls the year at both boundaries', () {
      expect(shiftAttendanceMonth('2026-12', 1), '2027-01');
      expect(shiftAttendanceMonth('2026-01', -1), '2025-12');
      expect(shiftAttendanceMonth('2026-08', 1), '2026-09');
    });

    test('a malformed month does not throw', () {
      expect(() => shiftAttendanceMonth('nonsense', 1), returnsNormally);
    });

    test('day stepping crosses month and year ends', () {
      expect(shiftAttendanceDay('2026-09-30', 1), '2026-10-01');
      expect(shiftAttendanceDay('2026-01-01', -1), '2025-12-31');
    });

    test('a malformed day is returned unchanged rather than guessed at', () {
      expect(shiftAttendanceDay('not-a-date', 1), 'not-a-date');
    });

    test('a month range ends on the real last day, February included', () {
      expect(
        AttendanceRange.ofMonth('2026-02').toDate,
        '2026-02-28',
      );
      expect(AttendanceRange.ofMonth('2024-02').toDate, '2024-02-29');
      expect(AttendanceRange.ofMonth('2026-09').fromDate, '2026-09-01');
      expect(AttendanceRange.ofMonth('2026-09').toDate, '2026-09-30');
    });

    test('query keys compare by value so the family caches', () {
      const a = AttendanceEmployeeQuery(
        employee: 'HR-EMP-00001',
        fromDate: '2026-09-01',
        toDate: '2026-09-30',
      );
      const b = AttendanceEmployeeQuery(
        employee: 'HR-EMP-00001',
        fromDate: '2026-09-01',
        toDate: '2026-09-30',
      );
      const other = AttendanceEmployeeQuery(
        employee: 'HR-EMP-00002',
        fromDate: '2026-09-01',
        toDate: '2026-09-30',
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == other, isFalse);
    });
  });

  group('summary sorting', () {
    List<AttendanceSummaryRow> rows() => [
      const AttendanceSummaryRow(
        label: 'Obour',
        lateDays: 2,
        attendanceRate: 0.9,
      ),
      const AttendanceSummaryRow(
        label: 'Nasr City',
        lateDays: 9,
        attendanceRate: 0.5,
      ),
    ];

    test('sorts by a numeric column in both directions', () {
      final descending = sortAttendanceSummaryRows(
        rows(),
        const AttendanceSummarySort(
          column: AttendanceSummaryColumn.lateDays,
          ascending: false,
        ),
      );
      expect(descending.first.label, 'Nasr City');

      final ascending = sortAttendanceSummaryRows(
        rows(),
        const AttendanceSummarySort(
          column: AttendanceSummaryColumn.lateDays,
          ascending: true,
        ),
      );
      expect(ascending.first.label, 'Obour');
    });

    test('does not mutate the list it was given', () {
      final original = rows();
      sortAttendanceSummaryRows(
        original,
        const AttendanceSummarySort(
          column: AttendanceSummaryColumn.attendanceRate,
        ),
      );

      expect(original.first.label, 'Obour');
    });

    test('tapping a new column starts it worst-first', () {
      const sort = AttendanceSummarySort();
      final next = sort.toggled(AttendanceSummaryColumn.lateDays);

      expect(next.column, AttendanceSummaryColumn.lateDays);
      expect(next.ascending, isFalse);
      expect(next.toggled(AttendanceSummaryColumn.lateDays).ascending, isTrue);
    });

    test('the label column still starts A-Z', () {
      const sort = AttendanceSummarySort(
        column: AttendanceSummaryColumn.lateDays,
        ascending: false,
      );

      expect(sort.toggled(AttendanceSummaryColumn.label).ascending, isTrue);
    });
  });

  // ── The five additive backend fixes ──────────────────────────────────
  //
  // Each one is tested twice: with the field the backend now sends, and
  // WITHOUT it. The second half is not hypothetical — an installed phone runs
  // against whatever the server happens to be, and a client that needs a new
  // key in order to parse is a client that dies the moment it meets an older
  // one.

  group('late_unmatched and pending counters', () {
    test('month totals parse both new counters at both levels', () {
      final month = AttendanceMonth.fromJson({
        'hrms_available': true,
        'month': '2026-09',
        'employees': [
          {
            'employee': 'HR-EMP-00001',
            'employee_name': 'Mona Adel',
            'days': {},
            'totals': {
              'rostered_days': 10,
              'present_days': 5,
              'late_days': 2,
              'late_unmatched_days': 1,
              'absent_days': 2,
              'pending_days': 3,
              'off_days': 4,
              'attendance_rate': 0.8,
              'punctuality_rate': 0.625,
            },
          },
        ],
        'totals': {
          'employees': 1,
          'rostered_days': 10,
          'present_days': 5,
          'late_days': 2,
          'late_unmatched_days': 1,
          'absent_days': 2,
          'pending_days': 3,
          'off_days': 4,
          'attendance_rate': 0.8,
          'punctuality_rate': 0.625,
        },
      });

      expect(month.totals.lateUnmatchedDays, 1);
      expect(month.totals.pendingDays, 3);
      expect(month.employees.single.totals.lateUnmatchedDays, 1);
      expect(month.employees.single.totals.pendingDays, 3);
    });

    test('the month invariant holds, pending excluded by design', () {
      final totals = AttendanceTotals.fromJson({
        'rostered_days': 10,
        'present_days': 5,
        'late_days': 2,
        'late_unmatched_days': 1,
        'absent_days': 2,
        'pending_days': 3,
      });

      // rostered == present + late + late_unmatched + absent
      expect(totals.addsUp, isTrue);
      expect(totals.attendedDays, 8);
      // late_unmatched counts as "turned up": they did arrive, just outside a
      // window the server could match to a shift start.
      expect(totals.punctualityDenominator, 8);
    });

    test('an older backend omitting the counters parses as zero, and says so '
        'rather than pretending to add up', () {
      final totals = AttendanceTotals.fromJson({
        'rostered_days': 10,
        'present_days': 5,
        'late_days': 2,
        'absent_days': 2,
      });

      expect(totals.lateUnmatchedDays, 0);
      expect(totals.pendingDays, 0);
      // 10 != 5 + 2 + 0 + 2 — the unaccounted day stays visible instead of
      // being silently absorbed into another bucket.
      expect(totals.addsUp, isFalse);
    });

    test('day totals parse late_unmatched and satisfy the day invariant', () {
      final totals = AttendanceDayTotals.fromJson({
        'rostered': 6,
        'present': 2,
        'late': 1,
        'late_unmatched': 1,
        'absent': 1,
        'pending': 1,
        'off': 2,
      });

      expect(totals.lateUnmatched, 1);
      // rostered == present + late + late_unmatched + absent + pending;
      // `off` sits outside it.
      expect(totals.addsUp, isTrue);
    });

    test('day totals from an older backend default to zero', () {
      final totals = AttendanceDayTotals.fromJson({
        'rostered': 3,
        'present': 1,
        'late': 1,
        'absent': 0,
        'pending': 0,
      });

      expect(totals.lateUnmatched, 0);
      expect(totals.addsUp, isFalse);
    });

    test('summary rows and totals parse both counters', () {
      final summary = AttendanceSummary.fromJson({
        'from_date': '2026-09-01',
        'to_date': '2026-09-30',
        'group_by': 'branch',
        'rows': [
          {
            'key': 'Nasr City',
            'label': 'Nasr City',
            'shift_location': 'Nasr City',
            'rostered_days': 20,
            'present_days': 12,
            'late_days': 4,
            'late_unmatched_days': 2,
            'absent_days': 2,
            'pending_days': 5,
            'attendance_rate': 0.9,
            'punctuality_rate': 0.6667,
          },
        ],
        'totals': {
          'rostered_days': 20,
          'present_days': 12,
          'late_days': 4,
          'late_unmatched_days': 2,
          'absent_days': 2,
          'pending_days': 5,
        },
      });

      expect(summary.rows.single.lateUnmatchedDays, 2);
      expect(summary.rows.single.pendingDays, 5);
      expect(summary.rows.single.attendedDays, 18);
      expect(summary.rows.single.addsUp, isTrue);
      expect(summary.totals.lateUnmatchedDays, 2);
      expect(summary.totals.pendingDays, 5);
    });

    test('summary rows from an older backend still parse', () {
      final row = AttendanceSummaryRow.fromJson({
        'key': 'Obour',
        'label': 'Obour',
        'rostered_days': 5,
        'present_days': 5,
      });

      expect(row.lateUnmatchedDays, 0);
      expect(row.pendingDays, 0);
      expect(row.attendedDays, 5);
      expect(row.addsUp, isTrue);
    });

    test('the new counters are sortable columns', () {
      final rows = [
        const AttendanceSummaryRow(label: 'A', lateUnmatchedDays: 1),
        const AttendanceSummaryRow(label: 'B', lateUnmatchedDays: 7),
      ];

      expect(
        sortAttendanceSummaryRows(
          rows,
          const AttendanceSummarySort(
            column: AttendanceSummaryColumn.lateUnmatchedDays,
            ascending: false,
          ),
        ).first.label,
        'B',
      );
      expect(
        sortAttendanceSummaryRows(
          rows,
          const AttendanceSummarySort(
            column: AttendanceSummaryColumn.pendingDays,
          ),
        ),
        hasLength(2),
      );
    });
  });

  group('a day-tab branch header adds up to its own rows', () {
    AttendanceBranchDay branch(Map<String, dynamic> totals) =>
        AttendanceBranchDay.fromJson({
          'shift_location': 'Nasr City',
          'totals': totals,
          'rows': [
            {'employee': 'E1', 'employee_name': 'A', 'status': 'present'},
            {'employee': 'E2', 'employee_name': 'B', 'status': 'late'},
            {'employee': 'E3', 'employee_name': 'C', 'status': 'late'},
            {'employee': 'E4', 'employee_name': 'D', 'status': 'late_unmatched'},
            {'employee': 'E5', 'employee_name': 'E', 'status': 'absent'},
            {'employee': 'E6', 'employee_name': 'F', 'status': 'pending'},
            {'employee': 'E7', 'employee_name': 'G', 'status': 'off'},
            {'employee': 'E8', 'employee_name': 'H', 'status': 'holiday'},
          ],
        }, date: '2026-09-12');

    test('the rows tally to exactly the totals the server sends', () {
      final section = branch({
        'rostered': 6,
        'present': 1,
        'late': 2,
        'late_unmatched': 1,
        'absent': 1,
        'pending': 1,
        'off': 2,
      });
      final counted = section.countedFromRows();

      expect(counted.present, section.totals.present);
      expect(counted.late, section.totals.late);
      expect(counted.lateUnmatched, section.totals.lateUnmatched);
      expect(counted.absent, section.totals.absent);
      expect(counted.pending, section.totals.pending);
      // `holiday` folds into `off`: the contract's day totals have no holiday
      // bucket, and both mean "not expected today".
      expect(counted.off, section.totals.off);
      expect(counted.rostered, section.totals.rostered);
      expect(section.totals.addsUp, isTrue);
      // Nothing to correct, so the header prints the server's own numbers.
      expect(identical(section.headerTotals, section.totals), isTrue);
    });

    test('the header falls back to the rows when the server does not tally', () {
      // Exactly the defect that was reported: no `late_unmatched` bucket, so
      // the header claimed five people while six were listed underneath it.
      final section = branch({
        'rostered': 6,
        'present': 1,
        'late': 2,
        'absent': 1,
        'pending': 1,
        'off': 2,
      });

      expect(section.totals.addsUp, isFalse);
      expect(section.headerTotals.lateUnmatched, 1);
      expect(section.headerTotals.rostered, 6);
      expect(section.headerTotals.addsUp, isTrue);
    });

    test('not_rostered and unknown rows are counted in no bucket', () {
      final section = AttendanceBranchDay.fromJson({
        'shift_location': 'Obour',
        'totals': <String, dynamic>{},
        'rows': [
          {'employee': 'E1', 'employee_name': 'A', 'status': 'not_rostered'},
          {'employee': 'E2', 'employee_name': 'B', 'status': 'invented_status'},
          {'employee': 'E3', 'employee_name': 'C', 'status': 'present'},
        ],
      }, date: '2026-09-12');
      final counted = section.countedFromRows();

      expect(counted.rostered, 1);
      expect(counted.present, 1);
      expect(counted.off, 0);
    });
  });

  group('get_day rows carry their own date', () {
    test('a row keeps the date it was sent with', () {
      // The night-shift case: the row belongs to the shift's date, which is
      // the grouping key, even when its punches spill past midnight.
      final row = AttendanceDayRow.fromJson({
        'employee': 'HR-EMP-00001',
        'employee_name': 'Mona Adel',
        'status': 'late',
        'date': '2026-09-11',
        'first_in': '2026-09-12 00:42:00',
      }, date: '2026-09-12');

      expect(row.cell.date, '2026-09-11');
    });

    test('a row from an older backend falls back to the response date', () {
      final row = AttendanceDayRow.fromJson({
        'employee': 'HR-EMP-00001',
        'employee_name': 'Mona Adel',
        'status': 'present',
      }, date: '2026-09-12');

      expect(row.cell.date, '2026-09-12');
    });

    test('a blank date is treated as absent, not as an empty day', () {
      final row = AttendanceDayRow.fromJson({
        'employee': 'HR-EMP-00001',
        'employee_name': 'Mona Adel',
        'status': 'present',
        'date': '   ',
      }, date: '2026-09-12');

      expect(row.cell.date, '2026-09-12');
    });
  });

  group('get_summary group_by=day', () {
    test('the key is a bare ISO date the client can format itself', () {
      final summary = AttendanceSummary.fromJson({
        'from_date': '2026-09-01',
        'to_date': '2026-09-02',
        'group_by': 'day',
        'rows': [
          {'key': '2026-09-01', 'label': '1 September 2026', 'rostered_days': 6},
          {'key': '2026-09-02', 'label': '2 September 2026', 'rostered_days': 6},
        ],
        'totals': {'rostered_days': 12},
      });

      expect(summary.groupBy, AttendanceGroupBy.day);
      for (final row in summary.rows) {
        expect(row.key, isNotNull);
        expect(DateTime.tryParse(row.key!), isNotNull);
        // The label is still carried; the screen prefers the key so the date
        // follows the app's locale rather than the server's.
        expect(row.label, isNotEmpty);
      }
      expect(summary.rows.first.isUnresolvedBranch, isFalse);
    });
  });

  group('get_employee scope', () {
    test('a scope block is parsed like every other endpoint', () {
      final detail = AttendanceEmployeeDetail.fromJson({
        'employee': 'HR-EMP-00001',
        'employee_name': 'Mona Adel',
        'from_date': '2026-09-01',
        'to_date': '2026-09-30',
        'days': [],
        'totals': <String, dynamic>{},
        'by_branch': [],
        'checkins': [],
        'scope': {
          'configured': true,
          'unrestricted': false,
          'locations': <String>[],
        },
      });

      // "Your account is scoped to no branch" — not "this person has no days".
      expect(detail.scope.isEmptyScope, isTrue);
    });

    test('a real scope is not an empty one', () {
      final detail = AttendanceEmployeeDetail.fromJson({
        'employee': 'HR-EMP-00001',
        'employee_name': 'Mona Adel',
        'days': [],
        'totals': <String, dynamic>{},
        'by_branch': [],
        'checkins': [],
        'scope': {
          'configured': true,
          'unrestricted': false,
          'locations': ['Nasr City'],
        },
      });

      expect(detail.scope.isEmptyScope, isFalse);
      expect(detail.scope.locations, ['Nasr City']);
    });

    test('an older backend with no scope block does not crash or accuse', () {
      final detail = AttendanceEmployeeDetail.fromJson({
        'employee': 'HR-EMP-00001',
        'employee_name': 'Mona Adel',
        'days': [],
        'totals': <String, dynamic>{},
        'by_branch': [],
        'checkins': [],
      });

      // Unconfigured, so the screen shows the ordinary empty state rather than
      // telling a manager their permissions are broken.
      expect(detail.scope.configured, isFalse);
      expect(detail.scope.isEmptyScope, isFalse);
    });
  });

  group('worked_hours and geo_ok stay three-valued', () {
    test('a lone check-in yields null hours, never 0.0', () {
      final cell = AttendanceCell.fromJson({
        'date': '2026-09-12',
        'status': 'present',
        'first_in': '2026-09-12 09:00:00',
        'last_out': null,
        'worked_hours': null,
        'checkin_count': 1,
      });

      expect(cell.workedHours, isNull);
      expect(cell.hasCheckin, isTrue);
    });

    test('a missing coordinate yields null geo_ok, never false', () {
      final checkin = AttendanceCheckin.fromJson({
        'name': 'EMP-CKIN-2026-00003',
        'time': '2026-09-12 09:00:00',
        'latitude': null,
        'longitude': null,
        'geo_ok': null,
      });

      expect(checkin.geoOk, isNull);
      expect(checkin.hasCoordinates, isFalse);
    });
  });
}
