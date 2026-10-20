import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/attendance/data/attendance_repository.dart';
import 'package:jarz_pos/src/features/attendance/models/attendance_models.dart';
import 'package:jarz_pos/src/features/attendance/presentation/widgets/attendance_checkout_badge.dart';
import 'package:jarz_pos/src/features/attendance/presentation/widgets/attendance_day_sheet.dart';
import 'package:jarz_pos/src/features/attendance/presentation/widgets/attendance_day_tab.dart';
import 'package:jarz_pos/src/features/attendance/state/attendance_providers.dart';

/// The check-out corrections (`checkout_corrected`, `missed_checkout`,
/// `log_type_note`, `original_log_type`) and "Approve this phone". Every new
/// key is optional: an older server that sends none of them must parse to
/// "nothing to show".
class _FakeRepository extends AttendanceRepository {
  _FakeRepository({this.fail = false}) : super(Dio());

  final bool fail;
  final calls = <(String, String)>[];

  @override
  Future<AttendanceBootstrap> getBootstrap() async =>
      AttendanceBootstrap.fromJson(const {'can_approve_device': true});

  @override
  Future<AttendanceDeviceApproval> approveDevice({
    required String employee,
    required String date,
  }) async {
    calls.add((employee, date));
    if (fail) throw Exception('Not allowed');
    return AttendanceDeviceApproval.fromJson({
      'employee': employee,
      'employee_name': 'Ana',
      'cleared': 1,
    });
  }
}

Widget _app({
  required Widget home,
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  ),
);

AttendanceCell _cell({
  bool corrected = false,
  bool missed = false,
  String? note,
  List<String> flags = const [],
}) => AttendanceCell.fromJson({
  'date': '2026-10-05',
  'status': 'present',
  'first_in': '09:00',
  if (corrected) 'checkout_corrected': true,
  if (missed) 'missed_checkout': 1,
  if (note != null) 'log_type_note': note,
  if (flags.isNotEmpty) 'device_flags': flags,
});

void main() {
  group('parsing, with and without the new keys', () {
    test('a cell from an older server has no check-out issue', () {
      final cell = AttendanceCell.fromJson({
        'date': '2026-10-05',
        'status': 'present',
      });
      expect(cell.checkoutCorrected, isFalse);
      expect(cell.missedCheckout, isFalse);
      expect(cell.logTypeNote, isNull);
      expect(cell.hasCheckoutIssue, isFalse);
    });

    test('a cell with the keys, in any truthy shape', () {
      final cell = AttendanceCell.fromJson({
        'date': '2026-10-05',
        'status': 'present',
        'checkout_corrected': 1,
        'missed_checkout': 'true',
        'log_type_note': 'First punch was OUT; counted as IN',
      });
      expect(cell.checkoutCorrected, isTrue);
      expect(cell.missedCheckout, isTrue);
      expect(cell.logTypeNote, 'First punch was OUT; counted as IN');
      expect(cell.hasCheckoutIssue, isTrue);

      final falsy = AttendanceCell.fromJson({
        'status': 'present',
        'checkout_corrected': 0,
        'missed_checkout': null,
        'log_type_note': '  ',
      });
      expect(falsy.hasCheckoutIssue, isFalse);
      expect(falsy.logTypeNote, isNull);
    });

    test('a day row carries them through its cell', () {
      final row = AttendanceDayRow.fromJson({
        'employee': 'HR-EMP-00001',
        'employee_name': 'Ana',
        'status': 'present',
        'missed_checkout': true,
      }, date: '2026-10-05');
      expect(row.cell.missedCheckout, isTrue);
    });

    test('a check-in with and without original_log_type', () {
      final corrected = AttendanceCheckin.fromJson({
        'name': 'C1',
        'time': '2026-10-05 09:00:00',
        'log_type': 'IN',
        'original_log_type': 'OUT',
        'log_type_note': 'counted as IN',
      });
      expect(corrected.originalLogType, 'OUT');
      expect(corrected.logTypeNote, 'counted as IN');
      expect(corrected.logTypeCorrected, isTrue);

      final old = AttendanceCheckin.fromJson({
        'name': 'C2',
        'time': '2026-10-05 18:00:00',
        'log_type': 'OUT',
      });
      expect(old.originalLogType, isNull);
      expect(old.logTypeNote, isNull);
      expect(old.logTypeCorrected, isFalse);

      // Same direction is not a correction.
      expect(
        AttendanceCheckin.fromJson({
          'time': 't',
          'log_type': 'IN',
          'original_log_type': 'in',
        }).logTypeCorrected,
        isFalse,
      );
    });

    test('bootstrap can_approve_device defaults to false', () {
      expect(AttendanceBootstrap.fromJson(const {}).canApproveDevice, isFalse);
      expect(
        AttendanceBootstrap.fromJson(const {
          'can_approve_device': true,
        }).canApproveDevice,
        isTrue,
      );
      expect(
        AttendanceBootstrap.fromJson(const {
          'can_approve_device': 1,
        }).canApproveDevice,
        isTrue,
      );
    });

    test('approve_device reply, whatever shape "cleared" takes', () {
      final full = AttendanceDeviceApproval.fromJson({
        'employee': 'HR-EMP-00001',
        'employee_name': 'Ana',
        'device': 'abc123',
        'approved_by': 'boss@jarz.com',
        'approved_on': '2026-10-05 10:00:00',
        'cleared': 3,
      });
      expect(full.employee, 'HR-EMP-00001');
      expect(full.employeeName, 'Ana');
      expect(full.device, 'abc123');
      expect(full.approvedBy, 'boss@jarz.com');
      expect(full.approvedOn, '2026-10-05 10:00:00');
      expect(full.cleared, 3);
      expect(AttendanceDeviceApproval.fromJson({'cleared': true}).cleared, 1);
      expect(
        AttendanceDeviceApproval.fromJson({
          'cleared': ['a', 'b'],
        }).cleared,
        2,
      );
      final bare = AttendanceDeviceApproval.fromJson({'employee': 'E'});
      expect(bare.cleared, 0);
      expect(bare.device, isNull);
    });
  });

  group('badges', () {
    testWidgets('the day sheet shows both badges and the note', (tester) async {
      await tester.pumpWidget(
        _app(
          overrides: [
            attendanceBootstrapProvider.overrideWith(
              (ref) async => AttendanceBootstrap.fromJson(const {}),
            ),
          ],
          home: Scaffold(
            body: SingleChildScrollView(
              child: AttendanceDaySheet(
                employeeName: 'Ana',
                cell: _cell(
                  corrected: true,
                  missed: true,
                  note: 'OUT at 09:00',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Pressed Check Out on arrival — counted as Check In'),
        findsOneWidget,
      );
      expect(find.text('No check-out'), findsOneWidget);
      expect(find.text('Note: OUT at 09:00'), findsOneWidget);
    });

    testWidgets('a clean day draws no badge', (tester) async {
      await tester.pumpWidget(
        _app(
          home: Scaffold(body: AttendanceCheckoutBadges(cell: _cell())),
        ),
      );
      expect(find.byKey(attendanceCheckoutCorrectedKey), findsNothing);
      expect(find.byKey(attendanceMissedCheckoutKey), findsNothing);
    });

    testWidgets('the day-tab row shows the dense badge, in Arabic too', (
      tester,
    ) async {
      final row = AttendanceDayRow.fromJson({
        'employee': 'HR-EMP-00001',
        'employee_name': 'Ana',
        'status': 'present',
        'first_in': '09:00',
        'missed_checkout': true,
      }, date: '2026-10-05');
      await tester.pumpWidget(
        _app(
          locale: const Locale('ar'),
          home: Scaffold(
            body: AttendanceDayRowTile(row: row, graceMinutes: 15),
          ),
        ),
      );
      expect(find.byKey(attendanceMissedCheckoutKey), findsOneWidget);
      expect(find.text('لم يسجّل انصراف'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('approve this phone', () {
    Future<_FakeRepository> openSheet(
      WidgetTester tester, {
      bool canApprove = true,
      List<String> flags = const ['New Device'],
      String? employee = 'HR-EMP-00001',
      bool fail = false,
    }) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final repo = _FakeRepository(fail: fail);
      await tester.pumpWidget(
        _app(
          overrides: [
            attendanceRepositoryProvider.overrideWithValue(repo),
            attendanceBootstrapProvider.overrideWith(
              (ref) async => AttendanceBootstrap.fromJson({
                'can_approve_device': canApprove,
              }),
            ),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAttendanceDaySheet(
                  context,
                  employeeName: 'Ana',
                  employee: employee,
                  cell: _cell(flags: flags),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return repo;
    }

    testWidgets('shown only for a New Device day to a user who may approve', (
      tester,
    ) async {
      await openSheet(tester);
      expect(find.byKey(attendanceApproveDeviceKey), findsOneWidget);
    });

    testWidgets('hidden when the server does not allow it', (tester) async {
      await openSheet(tester, canApprove: false);
      expect(find.byKey(attendanceApproveDeviceKey), findsNothing);
    });

    testWidgets('hidden for other flags', (tester) async {
      await openSheet(tester, flags: const ['Shared Device']);
      expect(find.byKey(attendanceApproveDeviceKey), findsNothing);
    });

    testWidgets('hidden without an employee id', (tester) async {
      await openSheet(tester, employee: null);
      expect(find.byKey(attendanceApproveDeviceKey), findsNothing);
    });

    testWidgets('confirm, call, close and say so', (tester) async {
      final repo = await openSheet(tester);
      await tester.tap(find.byKey(attendanceApproveDeviceKey));
      await tester.pumpAndSettle();
      expect(find.text('Approve this phone?'), findsOneWidget);

      // Cancel does nothing.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repo.calls, isEmpty);

      await tester.tap(find.byKey(attendanceApproveDeviceKey));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Approve this phone'),
        ),
      );
      await tester.pumpAndSettle();
      expect(repo.calls, [('HR-EMP-00001', '2026-10-05')]);
      expect(find.byType(AttendanceDaySheet), findsNothing);
      expect(find.text('Phone approved for Ana'), findsOneWidget);
    });

    testWidgets('a refusal stays in the sheet with the reason', (tester) async {
      final repo = await openSheet(tester, fail: true);
      await tester.tap(find.byKey(attendanceApproveDeviceKey));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Approve this phone'),
        ),
      );
      await tester.pumpAndSettle();
      expect(repo.calls, hasLength(1));
      expect(find.byType(AttendanceDaySheet), findsOneWidget);
      expect(
        find.textContaining('Could not approve the phone'),
        findsOneWidget,
      );
      expect(find.byKey(attendanceApproveDeviceKey), findsOneWidget);
    });
  });
}
