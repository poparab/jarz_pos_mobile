import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/roster/models/roster_models.dart';
import 'package:jarz_pos/src/features/roster/state/roster_providers.dart';

/// The two things that matter on the client side of shift distribution:
/// telling the four day-states apart (one of which stops somebody working),
/// and moving between months without losing the year.
void main() {
  group('RosterCell day states', () {
    test('a rostered day is working and not off', () {
      final cell = RosterCell.fromJson({
        'date': '2026-09-10',
        'shift_type': 'Branch Opening',
        'shift_location': 'Nasr City',
        'hours': 9,
        'is_holiday': false,
        'day_off': null,
      });

      expect(cell.isWorking, isTrue);
      expect(cell.isOff, isFalse);
      expect(cell.isUnrostered, isFalse);
      expect(cell.hours, 9);
    });

    test('a day off is off, and carries who covers it', () {
      final cell = RosterCell.fromJson({
        'date': '2026-09-11',
        'shift_type': null,
        'hours': 0,
        'day_off': {
          'name': 'JRDO-2026-00001',
          'off_type': 'Weekly Off',
          'covered_by': 'HR-EMP-00002',
          'covered_by_name': 'Ahmed Samir',
          'cover_shift_type': 'Branch Cover Full Day',
        },
      });

      expect(cell.isOff, isTrue);
      expect(cell.isWorking, isFalse);
      expect(cell.isUnrostered, isFalse);
      expect(cell.dayOff!.isCovered, isTrue);
      expect(cell.dayOff!.coveredByName, 'Ahmed Samir');
    });

    test('a day off with nobody named is off but uncovered', () {
      final cell = RosterCell.fromJson({
        'date': '2026-09-12',
        'day_off': {'name': 'JRDO-2026-00002', 'off_type': 'Vacation'},
      });

      expect(cell.isOff, isTrue);
      expect(cell.dayOff!.isCovered, isFalse);
    });

    test('an empty day is UNROSTERED, not merely blank', () {
      // This is the state that refuses the check-in, so the client has to be
      // able to name it — drawing it as an innocent empty square would hide
      // the fact that somebody will be turned away at the door.
      final cell = RosterCell.fromJson({'date': '2026-09-13'});

      expect(cell.isUnrostered, isTrue);
      expect(cell.isWorking, isFalse);
      expect(cell.isOff, isFalse);
    });

    test('a holiday is not flagged as unrostered', () {
      final cell = RosterCell.fromJson({
        'date': '2026-09-14',
        'is_holiday': true,
      });

      expect(cell.isHoliday, isTrue);
      expect(cell.isUnrostered, isFalse);
    });
  });

  group('RosterShift', () {
    test('parses a shift that crosses midnight without mangling its hours', () {
      // The server computes the length; the client must not re-derive it.
      final shift = RosterShift.fromJson({
        'shift_type': 'Branch Cover Full Day',
        'start_time': '12:30:00',
        'end_time': '1:00:00',
        'hours': 12.5,
      });

      expect(shift.hours, 12.5);
      expect(shift.window, '12:30 → 01:00');
    });

    test('a shift with no times renders an empty window rather than junk', () {
      final shift = RosterShift.fromJson({'shift_type': 'X', 'hours': 0});
      expect(shift.window, '');
    });
  });

  group('RosterMonth', () {
    final payload = {
      'hrms_available': true,
      'month': '2026-09',
      'month_start': '2026-09-01',
      'month_end': '2026-09-30',
      'employees': [
        {
          'employee': 'HR-EMP-00001',
          'employee_name': 'Mostafa',
          'designation': 'Dispatcher',
          'shift_locations': ['Nasr City'],
          'standard_hours': 9.0,
          'is_courier': false,
          'overtime_multiplier': 1.0,
          'days': {
            '2026-09-02': {'date': '2026-09-02', 'shift_type': 'A', 'hours': 9},
            '2026-09-01': {'date': '2026-09-01', 'shift_type': 'A', 'hours': 9},
            '2026-09-03': {'date': '2026-09-03'},
          },
        },
      ],
      'shift_catalog': [
        {
          'shift_type': 'A',
          'start_time': '12:30:00',
          'end_time': '21:30:00',
          'hours': 9,
        },
      ],
      'shift_locations': [
        {'shift_location': 'Nasr City', 'checkin_radius': 200},
      ],
      'uncovered': [
        {
          'employee': 'HR-EMP-00001',
          'off_date': '2026-09-20',
          'off_type': 'Weekly Off',
        },
      ],
      'scope': {'configured': true, 'unrestricted': false, 'locations': ['Nasr City']},
    };

    test('dates come back in calendar order, not map order', () {
      // The payload above deliberately lists 09-02 before 09-01: a JSON object
      // has no ordering guarantee, and the grid's columns must not inherit
      // whatever order the map happened to deserialise in.
      final month = RosterMonth.fromJson(payload);
      expect(month.dates, ['2026-09-01', '2026-09-02', '2026-09-03']);
    });

    test('parses employees, catalogue, branches and gaps', () {
      final month = RosterMonth.fromJson(payload);

      expect(month.employees, hasLength(1));
      expect(month.employees.first.employeeName, 'Mostafa');
      expect(month.employees.first.standardHours, 9.0);
      expect(month.shiftCatalog.first.hours, 9);
      expect(month.shiftLocations.first.radius, 200);
      expect(month.gaps, hasLength(1));
      expect(month.gaps.first.date, '2026-09-20');
      expect(month.scope.unrestricted, isFalse);
    });

    test('an HRMS-less site parses into an explained empty state', () {
      final month = RosterMonth.fromJson({
        'hrms_available': false,
        'notice': 'HRMS is not installed',
        'employees': [],
      });

      expect(month.hrmsAvailable, isFalse);
      expect(month.notice, 'HRMS is not installed');
      expect(month.dates, isEmpty);
    });
  });

  group('RosterHoursRow', () {
    test('separates hours stood from hours paid', () {
      // A courier who worked 2h over gets 4h credited, so worked and paid
      // differ. Collapsing them into one number is the bug this guards.
      final row = RosterHoursRow.fromJson({
        'employee': 'HR-EMP-00003',
        'employee_name': 'Kareem',
        'designation': 'Courier',
        'is_courier': true,
        'standard_hours': 10,
        'overtime_multiplier': 2,
        'worked_days': 2,
        'off_days': 1,
        'cover_days': 1,
        'worked_hours': 22,
        'base_hours': 20,
        'overtime_hours': 2,
        'credited_overtime_hours': 4,
        'credited_hours': 24,
      });

      expect(row.isCourier, isTrue);
      expect(row.workedHours, 22);
      expect(row.creditedHours, 24);
      expect(row.creditedOvertimeHours, 4);
      expect(row.overtimeMultiplier, 2);
    });
  });

  group('shiftMonth', () {
    test('steps forward and back within a year', () {
      expect(shiftMonth('2026-09', 1), '2026-10');
      expect(shiftMonth('2026-09', -1), '2026-08');
    });

    test('rolls the year at both boundaries', () {
      // Hand-rolled arithmetic on the YYYY-MM string is what usually gets this
      // wrong, producing "2026-13" and an empty month.
      expect(shiftMonth('2026-12', 1), '2027-01');
      expect(shiftMonth('2026-01', -1), '2025-12');
    });

    test('pads single-digit months so the server sees YYYY-MM', () {
      expect(shiftMonth('2026-10', -1), '2026-09');
      expect(shiftMonth('2026-08', 1), '2026-09');
    });

    test('a malformed month does not throw', () {
      expect(() => shiftMonth('nonsense', 1), returnsNormally);
    });
  });
}
