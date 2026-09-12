import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/attendance/presentation/widgets/attendance_states.dart';
import 'package:jarz_pos/src/features/attendance/state/attendance_providers.dart';

/// The picker, range and selection rules from the b4792ab release review.
///
/// These are pure functions, so they are tested without pumping any widget.
/// The widgets only call them.
void main() {
  group('server range limits', () {
    test('match _range_bounds in services/attendance.py', () {
      // If this fails, the server limit changed. Change both sides together,
      // or users will reach the server's refusal again.
      expect(kAttendanceMaxRangeDays.summary, 93);
      expect(kAttendanceMaxRangeDays.employee, 366);
    });

    test('day counts are inclusive: end - start + 1', () {
      expect(
        attendanceRangeDays(
          const AttendanceRange(fromDate: '2026-09-01', toDate: '2026-09-01'),
        ),
        1,
      );
      expect(
        attendanceRangeDays(
          const AttendanceRange(fromDate: '2026-09-01', toDate: '2026-09-30'),
        ),
        30,
      );
    });

    test('counting across a daylight-saving change does not lose a day', () {
      // Egypt moves its clocks in late April and late October.
      expect(
        attendanceRangeDays(
          const AttendanceRange(fromDate: '2026-04-20', toDate: '2026-05-05'),
        ),
        16,
      );
      expect(
        attendanceRangeDays(
          const AttendanceRange(fromDate: '2026-10-25', toDate: '2026-11-05'),
        ),
        12,
      );
    });

    test('an unparseable range counts as zero days', () {
      expect(
        attendanceRangeDays(
          const AttendanceRange(fromDate: 'nonsense', toDate: '2026-09-01'),
        ),
        0,
      );
    });
  });

  group('fitAttendanceRange', () {
    test('a range within the limit is returned unchanged', () {
      const range = AttendanceRange(fromDate: '2026-09-01', toDate: '2026-09-30');
      final fit = fitAttendanceRange(range, 93);

      expect(fit.adjusted, isFalse);
      expect(fit.range, range);
    });

    test('exactly the limit is allowed', () {
      // 2026-06-30 .. 2026-09-30 inclusive is exactly 93 days.
      const range = AttendanceRange(fromDate: '2026-06-30', toDate: '2026-09-30');
      expect(attendanceRangeDays(range), 93);
      expect(fitAttendanceRange(range, 93).adjusted, isFalse);
    });

    test('one day over the limit is shortened to exactly the limit', () {
      const range = AttendanceRange(fromDate: '2026-06-29', toDate: '2026-09-30');
      expect(attendanceRangeDays(range), 94);

      final fit = fitAttendanceRange(range, 93);
      expect(fit.shortened, isTrue);
      expect(attendanceRangeDays(fit.range), 93);
    });

    test('picking the START moves the END to fit', () {
      const range = AttendanceRange(fromDate: '2026-01-01', toDate: '2026-12-31');
      final fit = fitAttendanceRange(
        range,
        93,
        keep: AttendanceRangeEdge.from,
      );

      expect(fit.shortened, isTrue);
      expect(fit.range.fromDate, '2026-01-01');
      expect(fit.range.toDate, '2026-04-03');
      expect(attendanceRangeDays(fit.range), 93);
    });

    test('picking the END moves the START to fit', () {
      const range = AttendanceRange(fromDate: '2026-01-01', toDate: '2026-12-31');
      final fit = fitAttendanceRange(range, 93, keep: AttendanceRangeEdge.to);

      expect(fit.range.toDate, '2026-12-31');
      expect(fit.range.fromDate, '2026-09-30');
      expect(attendanceRangeDays(fit.range), 93);
    });

    test('the employee limit allows a whole leap year', () {
      const range = AttendanceRange(fromDate: '2028-01-01', toDate: '2028-12-31');
      expect(attendanceRangeDays(range), 366);
      expect(
        fitAttendanceRange(range, kAttendanceMaxRangeDays.employee).adjusted,
        isFalse,
      );
    });

    test('ends in the wrong order meet at the end that was picked', () {
      const range = AttendanceRange(fromDate: '2026-09-20', toDate: '2026-09-10');

      final keepFrom = fitAttendanceRange(
        range,
        93,
        keep: AttendanceRangeEdge.from,
      );
      expect(keepFrom.reordered, isTrue);
      expect(keepFrom.range.fromDate, '2026-09-20');
      expect(keepFrom.range.toDate, '2026-09-20');

      final keepTo = fitAttendanceRange(range, 93, keep: AttendanceRangeEdge.to);
      expect(keepTo.range.fromDate, '2026-09-10');
      expect(keepTo.range.toDate, '2026-09-10');
    });

    test('the default keeps the most recent end', () {
      // The shared range arriving at the Summary tab from a longer Employee
      // range: nobody picked an end, so the latest days are kept.
      const range = AttendanceRange(fromDate: '2026-01-01', toDate: '2026-09-30');
      final fit = fitAttendanceRange(range, kAttendanceMaxRangeDays.summary);

      expect(fit.range.toDate, '2026-09-30');
      expect(attendanceRangeDays(fit.range), 93);
    });

    test('a fitted range never exceeds the limit, across a year boundary', () {
      const range = AttendanceRange(fromDate: '2025-06-01', toDate: '2026-02-15');
      final fit = fitAttendanceRange(range, 93);

      expect(attendanceRangeDays(fit.range), lessThanOrEqualTo(93));
      expect(fit.range.toDate, '2026-02-15');
    });

    test('an unparseable range is left alone rather than guessed at', () {
      const range = AttendanceRange(fromDate: 'x', toDate: 'y');
      expect(fitAttendanceRange(range, 93).range, range);
    });
  });

  group('date picker window', () {
    final now = DateTime(2026, 9, 12);
    final window = attendancePickerWindow(now);

    test('runs from three years back to the end of next year', () {
      expect(window.first, DateTime(2023, 1, 1));
      expect(window.last, DateTime(2027, 12, 31));
    });

    test('a date inside the window is kept, time dropped', () {
      expect(
        clampAttendancePickerDate(
          DateTime(2026, 5, 4, 13, 30),
          first: window.first,
          last: window.last,
        ),
        DateTime(2026, 5, 4),
      );
    });

    test('a date before the window is moved to its first day', () {
      // showDatePicker asserts on this without the clamp.
      expect(
        clampAttendancePickerDate(
          DateTime(2019, 1, 1),
          first: window.first,
          last: window.last,
        ),
        window.first,
      );
    });

    test('a date after the window is moved to its last day', () {
      expect(
        clampAttendancePickerDate(
          DateTime(2031, 6, 1),
          first: window.first,
          last: window.last,
        ),
        window.last,
      );
    });
  });

  group('employee selection after the list changes', () {
    const options = [
      AttendanceEmployeeOption(employee: 'E1', employeeName: 'A'),
      AttendanceEmployeeOption(employee: 'E2', employeeName: 'B'),
    ];

    test('a selection still in the list is kept', () {
      expect(
        reconcileAttendanceSelection('E1', options, listSettled: true),
        'E1',
      );
    });

    test('a selection the filter removed is cleared', () {
      // The bug: the picker went empty while the old person's data stayed
      // on screen underneath it.
      expect(
        reconcileAttendanceSelection('E9', options, listSettled: true),
        isNull,
      );
    });

    test('a month with nobody in it clears the selection', () {
      expect(
        reconcileAttendanceSelection('E1', const [], listSettled: true),
        isNull,
      );
    });

    test('while the list is still loading, the selection is not cleared', () {
      expect(
        reconcileAttendanceSelection('E9', options, listSettled: false),
        'E9',
      );
    });

    test('no selection stays no selection', () {
      expect(
        reconcileAttendanceSelection(null, options, listSettled: true),
        isNull,
      );
    });
  });

  group('server ValidationError message', () {
    DioException refusal(int status, Object? body) {
      final request = RequestOptions(path: '/api/method/x');
      return DioException(
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: status,
          data: body,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    test('reads the message out of Frappe\'s nested _server_messages', () {
      final inner = jsonEncode({
        'message': 'Date range is longer than <b>93</b> days.',
        'title': 'Message',
      });
      final error = refusal(417, {
        'exc_type': 'ValidationError',
        '_server_messages': jsonEncode([inner]),
      });

      expect(
        attendanceServerValidationMessage(error),
        'Date range is longer than 93 days.',
      );
    });

    test('falls back to the exception line when there are no messages', () {
      final error = refusal(417, {
        'exception':
            'frappe.exceptions.ValidationError: Date range is too long.',
      });

      expect(attendanceServerValidationMessage(error), 'Date range is too long.');
    });

    test('accepts a body that arrived as a JSON string', () {
      final error = refusal(
        417,
        jsonEncode({
          'exc_type': 'ValidationError',
          'exception': 'frappe.exceptions.ValidationError: Too long.',
        }),
      );

      expect(attendanceServerValidationMessage(error), 'Too long.');
    });

    test('a 403 or a 500 is not a validation refusal', () {
      expect(
        attendanceServerValidationMessage(
          refusal(403, {'exc_type': 'PermissionError'}),
        ),
        isNull,
      );
      expect(
        attendanceServerValidationMessage(refusal(500, {'message': 'boom'})),
        isNull,
      );
    });

    test('a traceback is never shown as the message', () {
      final error = refusal(417, {
        'exc_type': 'ValidationError',
        'exception': 'Traceback (most recent call last): ...',
      });

      expect(attendanceServerValidationMessage(error), isNull);
    });

    test('a very long message is capped', () {
      final error = refusal(417, {
        'exc_type': 'ValidationError',
        'exception': 'frappe.exceptions.ValidationError: ${'x' * 600}',
      });

      expect(
        attendanceServerValidationMessage(error)!.length,
        lessThanOrEqualTo(240),
      );
    });

    test('something that is not a DioException is ignored', () {
      expect(attendanceServerValidationMessage(Exception('nope')), isNull);
      expect(attendanceServerValidationMessage(null), isNull);
    });
  });
}
