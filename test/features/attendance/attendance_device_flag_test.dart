import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/attendance/models/attendance_models.dart';
import 'package:jarz_pos/src/features/attendance/presentation/widgets/attendance_device_flag.dart';
import 'package:jarz_pos/src/features/attendance/presentation/widgets/attendance_status_style.dart';

Widget _app(Locale locale, Widget child) => MaterialApp(
  locale: locale,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('device flag parsing', () {
    test('cell without the keys is clean', () {
      final cell = AttendanceCell.fromJson({
        'date': '2026-10-01',
        'status': 'present',
      });
      expect(cell.deviceFlags, isEmpty);
      expect(cell.deviceFlagDetail, isNull);
      expect(cell.hasDeviceFlag, isFalse);
    });

    test('cell with flags and detail', () {
      final cell = AttendanceCell.fromJson({
        'date': '2026-10-01',
        'status': 'present',
        'device_flags': ['Shared Device', 'New Device'],
        'device_flag_detail': 'a | b',
      });
      expect(cell.deviceFlags, ['Shared Device', 'New Device']);
      expect(cell.deviceFlagDetail, 'a | b');
    });

    test('null / garbage device_flags is tolerated', () {
      expect(
        AttendanceCell.fromJson({
          'status': 'present',
          'device_flags': null,
          'device_flag_detail': '',
        }).deviceFlags,
        isEmpty,
      );
      expect(
        AttendanceCell.fromJson({
          'status': 'present',
          'device_flags': 'oops',
        }).deviceFlags,
        isEmpty,
      );
    });

    test('day row carries the flags through its cell', () {
      final row = AttendanceDayRow.fromJson({
        'employee': 'E1',
        'employee_name': 'A',
        'status': 'present',
        'device_flags': ['New Device'],
        'device_flag_detail': 'd',
      }, date: '2026-10-01');
      expect(row.cell.deviceFlags, ['New Device']);
      expect(row.cell.deviceFlagDetail, 'd');
    });

    test('check-in with and without the keys', () {
      final flagged = AttendanceCheckin.fromJson({
        'name': 'C1',
        'time': '2026-10-01 09:00:00',
        'device_flag': 'Shared Device',
        'device_flag_detail': 'same phone',
      });
      expect(flagged.deviceFlag, 'Shared Device');
      expect(flagged.deviceFlagDetail, 'same phone');

      final clean = AttendanceCheckin.fromJson({
        'name': 'C2',
        'time': '2026-10-01 09:00:00',
      });
      expect(clean.deviceFlag, isNull);
      expect(clean.deviceFlagDetail, isNull);
    });
  });

  group('device flag widgets', () {
    testWidgets('chips show English label and server detail', (tester) async {
      await tester.pumpWidget(
        _app(
          const Locale('en'),
          const AttendanceDeviceFlagChips(
            flags: ['Shared Device', 'New Device'],
            detail: 'Same phone checked in HR-EMP-00007',
          ),
        ),
      );
      expect(find.text('Shared phone'), findsOneWidget);
      expect(find.text('New phone'), findsOneWidget);
      expect(find.text('Same phone checked in HR-EMP-00007'), findsOneWidget);
    });

    testWidgets('chips show Arabic labels', (tester) async {
      await tester.pumpWidget(
        _app(
          const Locale('ar'),
          const AttendanceDeviceFlagChips(
            flags: ['Shared Device', 'New Device', 'No Device'],
          ),
        ),
      );
      expect(find.text('تليفون مشترك'), findsOneWidget);
      expect(find.text('تليفون جديد'), findsOneWidget);
      expect(find.text('مفيش تعريف للجهاز'), findsOneWidget);
    });

    testWidgets('no flags renders nothing', (tester) async {
      await tester.pumpWidget(
        _app(const Locale('en'), const AttendanceDeviceFlagChips(flags: [])),
      );
      expect(
        find.byKey(const ValueKey('attendance-device-flag-chips')),
        findsNothing,
      );
    });

    testWidgets(
      'grid square keeps its size and shows a dot only when flagged',
      (tester) async {
        Future<Size> pump(List<String> flags) async {
          await tester.pumpWidget(
            _app(
              const Locale('en'),
              AttendanceStatusSquare(
                status: AttendanceStatus.present,
                deviceFlags: flags,
              ),
            ),
          );
          return tester.getSize(find.byType(AttendanceStatusSquare));
        }

        final clean = await pump(const []);
        expect(
          find.byKey(const ValueKey('attendance-device-flag-dot')),
          findsNothing,
        );
        final flagged = await pump(const ['Shared Device']);
        expect(
          find.byKey(const ValueKey('attendance-device-flag-dot')),
          findsOneWidget,
        );
        expect(flagged, clean);
      },
    );
  });
}
