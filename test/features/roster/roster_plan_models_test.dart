import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/roster/data/roster_repository.dart';
import 'package:jarz_pos/src/features/roster/models/roster_models.dart';
import 'package:jarz_pos/src/features/roster/models/roster_plan_models.dart';
import 'package:jarz_pos/src/features/roster/state/roster_plan_draft.dart';

import '../../helpers/mock_services.dart';

/// The rota plan wizard's wire shapes (`get_plan_defaults`, `apply_plan`) and
/// the pure rules behind the wizard (period, pre-fill, cover default, payload).
List<RosterShift> _catalog() => [
  for (final name in [
    'Branch Opening',
    'Branch Opening - Friday',
    'Branch Closing',
    'Branch Cover Full Day',
    'Courier Nasr City',
  ])
    RosterShift.fromJson({
      'shift_type': name,
      'start_time': '09:00:00',
      'end_time': '18:00:00',
      'hours': 9,
    }),
];

void main() {
  group('RosterPlanDefaults.fromJson', () {
    test('parses the contract shape', () {
      final defaults = RosterPlanDefaults.fromJson({
        'success': true,
        'suggested_start': '2026-11-01',
        'employees': [
          {
            'employee': 'HR-EMP-0001',
            'employee_name': 'Ali',
            'designation': 'Cashier',
            'is_courier': false,
            'shift_location': 'Nasr City',
            'shift_type': 'Branch Opening',
            'off_days': ['Friday', 'Saturday'],
            'use_friday_variant': true,
            'friday_shift_type': 'Branch Opening - Friday',
            'covers': [
              {
                'weekday': 'Friday',
                'covered_by': 'HR-EMP-0002',
                'covered_by_name': 'Omar',
                'cover_shift_type': 'Branch Cover Full Day',
              },
            ],
            'has_standing_rota': true,
          },
        ],
      });

      expect(defaults.suggestedStart, '2026-11-01');
      final ali = defaults.employees.single;
      expect(ali.displayName, 'Ali');
      expect(ali.shiftLocation, 'Nasr City');
      expect(ali.shiftType, 'Branch Opening');
      // Normalised to the Saturday-first week.
      expect(ali.offDays, ['Saturday', 'Friday']);
      expect(ali.useFridayVariant, isTrue);
      expect(ali.fridayShiftType, 'Branch Opening - Friday');
      expect(ali.covers.single.coveredBy, 'HR-EMP-0002');
      expect(ali.covers.single.coveredByName, 'Omar');
      expect(ali.covers.single.coverShiftType, 'Branch Cover Full Day');
      expect(ali.hasStandingRota, isTrue);
    });

    test('tolerates missing and null fields', () {
      final defaults = RosterPlanDefaults.fromJson({
        'employees': [
          {
            'employee': 'HR-EMP-0003',
            'shift_type': null,
            'off_days': null,
            'covers': null,
          },
          {'employee_name': 'no id, dropped'},
          'junk',
        ],
      });
      expect(defaults.suggestedStart, isNull);
      final person = defaults.employees.single;
      expect(person.displayName, 'HR-EMP-0003');
      expect(person.shiftType, isNull);
      expect(person.offDays, isEmpty);
      expect(person.covers, isEmpty);
      expect(person.hasStandingRota, isFalse);
      expect(person.fridayShiftType, isNull);

      expect(RosterPlanDefaults.fromJson(const {}).employees, isEmpty);
    });
  });

  group('RosterPlanResult.fromJson', () {
    test('parses summary, rows, manual days and issues by severity', () {
      final result = RosterPlanResult.fromJson({
        'success': true,
        'dry_run': true,
        'applied': false,
        'start': '2026-11-01',
        'end': '2026-11-30',
        'summary': {
          'people': 3,
          'shift_days': 70,
          'day_offs': 12,
          'covers': 10,
          'manual_kept': 2,
          'manual_replaced': 0,
          'errors': 1,
          'warnings': 1,
        },
        'rows': [
          {
            'employee': 'HR-EMP-0001',
            'employee_name': 'Ali',
            'shift_type': 'Branch Opening',
            'friday_shift_type': 'Branch Opening - Friday',
            'shift_location': 'Nasr City',
            'shift_days': 26,
            'day_offs': 4,
            'covers': 4,
            'manual_days': [
              {'date': '2026-11-12', 'current': 'Evening', 'kind': 'shift'},
              {'date': '2026-11-13', 'kind': 'empty'},
            ],
            'issues': [],
          },
        ],
        'issues': [
          {
            'employee': 'HR-EMP-0001',
            'employee_name': 'Ali',
            'date': '2026-11-06',
            'code': 'cover_is_off',
            'severity': 'error',
            'message': 'Omar is off that day.',
          },
          {
            'employee': 'HR-EMP-0001',
            'date': '2026-11-06',
            'code': 'same_day_off',
            'severity': 'warning',
            'message': 'Two people off.',
          },
          {'code': 'no_friday_variant', 'severity': 'info', 'message': 'x'},
        ],
      });

      expect(result.dryRun, isTrue);
      expect(result.applied, isFalse);
      expect(result.summary.people, 3);
      expect(result.summary.shiftDays, 70);
      expect(result.summary.manualKept, 2);
      expect(result.errors.single.code, 'cover_is_off');
      expect(result.warnings.single.code, 'same_day_off');
      expect(result.notes.single.code, 'no_friday_variant');
      expect(result.hasErrors, isTrue);
      final row = result.rowsWithManualDays.single;
      expect(row.shiftDays, 26);
      expect(row.manualDays.first.current, 'Evening');
      expect(row.manualDays.last.kind, 'empty');
      expect(row.manualDays.last.current, isNull);
    });

    test('rebuilds the flat issue list from the rows when absent', () {
      final result = RosterPlanResult.fromJson({
        'applied': true,
        'dry_run': false,
        'rows': [
          {
            'employee': 'HR-EMP-0001',
            'employee_name': 'Ali',
            'issues': [
              {'code': 'cover_double', 'severity': 'error', 'message': 'm'},
            ],
          },
        ],
      });
      expect(result.applied, isTrue);
      expect(result.dryRun, isFalse);
      expect(result.errors.single.employeeName, 'Ali');
      expect(result.hasErrors, isTrue);
    });

    test('an unknown severity is a warning, never a blocker', () {
      final result = RosterPlanResult.fromJson({
        'issues': [
          {'code': 'new_code', 'severity': 'critical-ish', 'message': 'm'},
        ],
      });
      expect(result.warnings, hasLength(1));
      expect(result.hasErrors, isFalse);
    });

    test('an empty body parses to an empty preview', () {
      final result = RosterPlanResult.fromJson(const {});
      expect(result.rows, isEmpty);
      expect(result.issues, isEmpty);
      expect(result.summary.people, 0);
      expect(result.hasErrors, isFalse);
    });
  });

  group('plan draft rules', () {
    test('next month uses the server start and ends on the month end', () {
      final period = rosterPlanPeriodFor(
        RosterPlanPeriodKind.nextMonth,
        today: DateTime(2026, 10, 12),
        suggestedStart: '2026-11-01',
      )!;
      expect(period.startIso, '2026-11-01');
      expect(period.endIso, '2026-11-30');
      expect(period.days, 30);
    });

    test('rest of this month starts tomorrow; none on the last day', () {
      final period = rosterPlanPeriodFor(
        RosterPlanPeriodKind.restOfMonth,
        today: DateTime(2026, 10, 12),
      )!;
      expect(period.startIso, '2026-10-13');
      expect(period.endIso, '2026-10-31');
      expect(
        rosterPlanPeriodFor(
          RosterPlanPeriodKind.restOfMonth,
          today: DateTime(2026, 10, 31),
        ),
        isNull,
      );
    });

    test('a custom period over 62 days is too long', () {
      final period = rosterPlanPeriodFor(
        RosterPlanPeriodKind.custom,
        today: DateTime(2026, 10, 12),
        custom: RosterPlanPeriod(
          DateTime.utc(2026, 11, 1),
          DateTime.utc(2027, 1, 5),
        ),
      )!;
      expect(period.isTooLong, isTrue);
    });

    test('the cover default prefers the one full-day/cover shift', () {
      const coverer = RosterPlanDefaultsEmployee(
        employee: 'HR-EMP-0002',
        employeeName: 'Omar',
        shiftType: 'Branch Closing',
      );
      expect(
        rosterPlanDefaultCoverShift(coverer: coverer, catalog: _catalog()),
        'Branch Cover Full Day',
      );
      // A courier's group has no cover shift: their own shift.
      const courier = RosterPlanDefaultsEmployee(
        employee: 'HR-EMP-0009',
        employeeName: 'Rider',
        isCourier: true,
        shiftType: 'Courier Nasr City',
      );
      expect(
        rosterPlanDefaultCoverShift(coverer: courier, catalog: _catalog()),
        'Courier Nasr City',
      );
    });

    test('the payload sends English weekdays, Saturday first, and only '
        'covers on off days', () {
      final row = RosterPlanRowDraft(
        employee: 'HR-EMP-0001',
        shiftType: 'Branch Opening',
        shiftLocation: 'Nasr City',
        offDays: {'Friday', 'Saturday'},
        covers: {
          'Friday': RosterPlanCoverDraft(
            coveredBy: 'HR-EMP-0002',
            coverShiftType: 'Branch Cover Full Day',
          ),
          'Monday': RosterPlanCoverDraft(coveredBy: 'HR-EMP-0003'),
        },
      );
      final payload = buildRosterPlanPayload(
        period: RosterPlanPeriod(
          DateTime.utc(2026, 11, 1),
          DateTime.utc(2026, 11, 30),
        ),
        rows: [row],
        catalog: _catalog(),
        replaceManual: false,
        grantPosAccess: true,
      );
      expect(payload['start'], '2026-11-01');
      expect(payload['end'], '2026-11-30');
      final sent = (payload['rows'] as List).single as Map;
      expect(sent['off_days'], ['Saturday', 'Friday']);
      expect(sent['use_friday_variant'], isTrue);
      expect(sent['covers'], [
        {
          'weekday': 'Friday',
          'covered_by': 'HR-EMP-0002',
          'cover_shift_type': 'Branch Cover Full Day',
        },
      ]);
    });

    test(
      '"Same for everyone" copies shift and days off, drops stale covers',
      () {
        final first = RosterPlanRowDraft(
          employee: 'A',
          shiftType: 'Branch Opening',
          offDays: {'Friday'},
        );
        final other = RosterPlanRowDraft(
          employee: 'B',
          shiftType: 'Branch Closing',
          shiftLocation: 'Dokki',
          offDays: {'Tuesday'},
          covers: {'Tuesday': RosterPlanCoverDraft(coveredBy: 'C')},
        );
        other.copyWeekFrom(first);
        expect(other.shiftType, 'Branch Opening');
        expect(other.offDays, {'Friday'});
        expect(other.covers, isEmpty);
        expect(other.shiftLocation, 'Dokki');
      },
    );
  });

  group('RosterRepository plan calls', () {
    const defaultsPath = '/api/method/jarz_pos.api.roster.get_plan_defaults';
    const applyPath = '/api/method/jarz_pos.api.roster.apply_plan';

    test('getPlanDefaults is a GET with the optional branch filter', () async {
      final dio = MockDio()
        ..setResponse(defaultsPath, {
          'message': {'suggested_start': '2026-11-01', 'employees': []},
        });
      final repo = RosterRepository(dio);
      final defaults = await repo.getPlanDefaults(shiftLocation: 'Nasr City');
      expect(defaults.suggestedStart, '2026-11-01');
      expect(dio.requestLog.single['method'], 'GET');
      expect(dio.requestLog.single['queryParameters'], {
        'shift_location': 'Nasr City',
      });
    });

    test('applyPlan JSON-encodes the payload and sends dry_run 0/1', () async {
      final dio = MockDio()
        ..setResponse(applyPath, {
          'message': {'dry_run': true, 'applied': false},
        });
      final repo = RosterRepository(dio);
      await repo.applyPlan({'start': '2026-11-01', 'rows': []}, dryRun: true);
      await repo.applyPlan({'start': '2026-11-01', 'rows': []}, dryRun: false);
      final first = dio.requestLog.first['data'] as Map;
      expect(first['dry_run'], 1);
      expect(jsonDecode(first['payload'] as String)['start'], '2026-11-01');
      expect((dio.requestLog.last['data'] as Map)['dry_run'], 0);
    });
  });
}
