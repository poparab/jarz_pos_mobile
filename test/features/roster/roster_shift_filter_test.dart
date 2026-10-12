import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/roster/models/roster_models.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_shift_filter.dart';
import 'package:jarz_pos/src/features/roster/presentation/widgets/roster_shift_picker.dart';

// The live catalog on both servers (2026-10-12).
const _names = [
  'Branch Closing',
  'Branch Closing - Friday',
  'Branch Cover Full Day',
  'Branch Cover Full Day - Friday',
  'Branch Opening',
  'Branch Opening - Friday',
  'Courier 6Oct-Dokki',
  'Courier 6Oct-Dokki - Friday',
  'Courier Nasr City',
  'Courier Nasr City - Friday',
  'Factory',
];

final _catalog = [
  for (final n in _names)
    RosterShift(shiftType: n, startTime: '10:00', endTime: '19:00', hours: 9),
];

// 2026-10-16 is a Friday, 2026-10-17 a Saturday.
const _friday = '2026-10-16';
const _saturday = '2026-10-17';
const _sunday = '2026-10-18';

RosterEmployee _employee({
  List<String?> shifts = const [],
  bool isCourier = false,
  String? department,
}) {
  final days = <String, RosterCell>{};
  for (var i = 0; i < shifts.length; i++) {
    final date = '2026-10-${(i + 1).toString().padLeft(2, '0')}';
    days[date] = RosterCell(date: date, shiftType: shifts[i]);
  }
  return RosterEmployee(
    employee: 'HR-EMP-1',
    employeeName: 'Test',
    days: days,
    isCourier: isCourier,
    department: department,
  );
}

List<String> _pick(
  RosterEmployee? e, {
  List<String> dates = const [],
  String? selected,
}) => rosterShiftsFor(
  e,
  _catalog,
  dates: dates,
  selected: selected,
).map((s) => s.shiftType).toList();

void main() {
  group('rosterShiftsFor', () {
    test('a Nasr City courier sees only their own route', () {
      final e = _employee(
        isCourier: true,
        shifts: ['Courier Nasr City', 'Courier Nasr City - Friday'],
      );
      expect(_pick(e, dates: [_saturday]), ['Courier Nasr City']);
      expect(_pick(e, dates: [_friday]), ['Courier Nasr City - Friday']);
    });

    test('a courier with no shifts this month sees every courier shift', () {
      final e = _employee(isCourier: true);
      expect(_pick(e, dates: [_saturday]), [
        'Courier 6Oct-Dokki',
        'Courier Nasr City',
      ]);
    });

    test('factory staff see only the factory shift', () {
      final e = _employee(shifts: ['Factory', 'Factory', null]);
      expect(_pick(e, dates: [_saturday]), ['Factory']);
      // Factory has no Friday twin, so it still shows on a Friday.
      expect(_pick(e, dates: [_friday]), ['Factory']);
    });

    test('branch staff see the branch shifts, Friday-aware', () {
      final e = _employee(shifts: ['Branch Opening', 'Branch Closing']);
      expect(_pick(e, dates: [_saturday, _sunday]), [
        'Branch Closing',
        'Branch Cover Full Day',
        'Branch Opening',
      ]);
      expect(_pick(e, dates: [_friday]), [
        'Branch Closing - Friday',
        'Branch Cover Full Day - Friday',
        'Branch Opening - Friday',
      ]);
      // A selection that mixes Friday and other days shows both kinds.
      expect(_pick(e, dates: [_friday, _saturday]).length, 6);
    });

    test('department decides when the month has no shifts', () {
      expect(
        _pick(_employee(department: 'Production - J'), dates: [_saturday]),
        ['Factory'],
      );
      expect(_pick(_employee(department: 'Dispatch - J'), dates: [_saturday]), [
        'Courier 6Oct-Dokki',
        'Courier Nasr City',
      ]);
    });

    test('an unknown person gets the whole catalog', () {
      expect(_pick(_employee()), _names);
      expect(_pick(null), _names);
    });

    test('the current shift stays listed even outside the group', () {
      final e = _employee(shifts: ['Factory']);
      expect(_pick(e, dates: [_saturday], selected: 'Branch Opening'), [
        'Factory',
        'Branch Opening',
      ]);
    });
  });

  testWidgets('picker lists the person\'s shifts and can show all', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final e = _employee(shifts: ['Factory']);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: RosterShiftPicker(
            catalog: _catalog,
            employee: e,
            dates: const [_saturday],
            maxHeight: 2000,
            onPick: (_) {},
          ),
        ),
      ),
    );
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Factory'), findsOneWidget);

    await tester.tap(find.byKey(rosterShowAllShiftsKey));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(_names.length));
  });
}
