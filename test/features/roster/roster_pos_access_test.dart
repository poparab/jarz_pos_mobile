// The roster side of branch access: the bootstrap tells the day sheet which
// branches can take a POS grant (and an older backend that says nothing must
// hide the tick box), the writes send `grant_pos_access` only when asked, and
// the returned `pos_access` outcome becomes the right snackbar line.
library;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations_en.dart';
import 'package:jarz_pos/src/features/roster/data/roster_repository.dart';
import 'package:jarz_pos/src/features/roster/models/roster_models.dart';
import 'package:jarz_pos/src/features/roster/presentation/widgets/roster_day_sheet.dart';

class _Adapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  Object? Function(RequestOptions options) respond = (_) => const {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({'message': respond(options)}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('bootstrap shift_locations', () {
    test('parses pos_profile and pos_manageable', () {
      final bootstrap = RosterBootstrap.fromJson({
        'shift_locations': [
          {
            'shift_location': 'Dokki',
            'checkin_radius': 100,
            'pos_profile': 'Dokki',
            'pos_manageable': true,
          },
          {
            'shift_location': 'Factory',
            'checkin_radius': 100,
            'pos_profile': null,
            'pos_manageable': false,
          },
          {
            'shift_location': 'Nasr City',
            'pos_profile': 'Nasr city',
            'pos_manageable': false,
          },
        ],
      });
      final byName = {
        for (final l in bootstrap.shiftLocations) l.shiftLocation: l,
      };
      expect(byName['Dokki']!.canGrantPosAccess, isTrue);
      expect(byName['Factory']!.posProfile, isNull);
      expect(byName['Factory']!.canGrantPosAccess, isFalse);
      expect(byName['Nasr City']!.posProfile, 'Nasr city');
      expect(byName['Nasr City']!.canGrantPosAccess, isFalse);
    });

    test('schedule_location drives the fallback branch', () {
      final withSchedule = RosterEmployee.fromJson({
        'employee': 'HR-EMP-1',
        'employee_name': 'A',
        'shift_locations': ['Nasr City', 'Dokki'],
        'schedule_location': 'Dokki',
        'days': {},
      });
      expect(withSchedule.scheduleLocation, 'Dokki');
      expect(withSchedule.fallbackLocation, 'Dokki');

      final older = RosterEmployee.fromJson({
        'employee': 'HR-EMP-2',
        'employee_name': 'B',
        'shift_locations': ['Nasr City'],
        'days': {},
      });
      expect(older.scheduleLocation, isNull);
      expect(older.fallbackLocation, 'Nasr City');
    });

    test('an older backend without the keys never offers the tick box', () {
      final location = RosterLocation.fromJson({
        'shift_location': 'Dokki',
        'checkin_radius': 100,
      });
      expect(location.posProfile, isNull);
      expect(location.posManageable, isFalse);
      expect(location.canGrantPosAccess, isFalse);
    });
  });

  group('repository', () {
    late _Adapter adapter;
    late RosterRepository repository;

    setUp(() {
      adapter = _Adapter();
      repository = RosterRepository(Dio()..httpClientAdapter = adapter);
    });

    test('assignShift omits grant_pos_access unless asked', () async {
      adapter.respond = (_) => {'success': true};
      final outcome = await repository.assignShift(
        employee: 'HR-EMP-1',
        date: '2026-09-24',
        shiftType: 'Branch Opening',
      );
      expect(
        (adapter.requests.single.data as Map).containsKey('grant_pos_access'),
        isFalse,
      );
      expect(outcome, isNull);
    });

    test('assignShift sends the flag and parses pos_access', () async {
      adapter.respond = (_) => {
        'success': true,
        'pos_access': {
          'requested': true,
          'granted': true,
          'status': 'Scheduled',
          'already_member': false,
          'reason': null,
          'pos_profile': 'Dokki',
          'day_access': 'JPDA-2026-00001',
        },
      };
      final outcome = await repository.assignShift(
        employee: 'HR-EMP-1',
        date: '2026-09-24',
        shiftType: 'Branch Opening',
        grantPosAccess: true,
      );
      expect((adapter.requests.single.data as Map)['grant_pos_access'], 1);
      expect(outcome!.granted, isTrue);
      expect(outcome.isScheduled, isTrue);
      expect(outcome.posProfile, 'Dokki');
      expect(outcome.dayAccess, 'JPDA-2026-00001');
    });

    test('setDayOff sends the flag only with a cover', () async {
      adapter.respond = (_) => {
        'success': true,
        'pos_access': {
          'requested': true,
          'granted': false,
          'status': null,
          'already_member': false,
          'reason': 'Dokki has an open shift.',
          'pos_profile': 'Dokki',
          'day_access': null,
        },
      };
      await repository.setDayOff(
        employee: 'HR-EMP-1',
        date: '2026-09-24',
        offType: 'Weekly Off',
        grantPosAccess: true,
      );
      expect(
        (adapter.requests.last.data as Map).containsKey('grant_pos_access'),
        isFalse,
      );

      final outcome = await repository.setDayOff(
        employee: 'HR-EMP-1',
        date: '2026-09-24',
        offType: 'Weekly Off',
        coveredBy: 'HR-EMP-2',
        coverShiftType: 'Branch Cover Full Day',
        grantPosAccess: true,
      );
      final body = adapter.requests.last.data as Map;
      expect(body['grant_pos_access'], 1);
      expect(body['covered_by'], 'HR-EMP-2');
      expect(outcome!.granted, isFalse);
      expect(outcome.reason, 'Dokki has an open shift.');
    });
  });

  group('outcome message', () {
    final l10n = AppLocalizationsEn();

    test('granted now vs scheduled', () {
      expect(
        posAccessOutcomeMessage(
          l10n,
          const PosAccessOutcome(
            requested: true,
            granted: true,
            status: 'Active',
            posProfile: 'Dokki',
          ),
          fallbackBranch: 'x',
        ),
        l10n.rosterPosAccessGranted('Dokki'),
      );
      expect(
        posAccessOutcomeMessage(
          l10n,
          const PosAccessOutcome(
            requested: true,
            granted: true,
            status: 'Scheduled',
          ),
          fallbackBranch: 'Nasr city',
        ),
        l10n.rosterPosAccessScheduled('Nasr city'),
      );
    });

    test('already a member', () {
      expect(
        posAccessOutcomeMessage(
          l10n,
          const PosAccessOutcome(
            requested: true,
            granted: false,
            alreadyMember: true,
            posProfile: 'Dokki',
          ),
          fallbackBranch: '',
        ),
        l10n.rosterPosAccessAlreadyMember('Dokki'),
      );
    });

    test('a refusal carries the server reason verbatim', () {
      final message = posAccessOutcomeMessage(
        l10n,
        const PosAccessOutcome(
          requested: true,
          granted: false,
          reason: 'Employee has no user.',
        ),
        fallbackBranch: '',
      );
      expect(message, contains('Employee has no user.'));
    });

    test('no outcome from the server is reported, not ignored', () {
      expect(
        posAccessOutcomeMessage(l10n, null, fallbackBranch: 'Dokki'),
        l10n.rosterPosAccessNotConfirmed,
      );
    });
  });

  group('cover location', () {
    test('absent person first, then coverer that day, then coverer home', () {
      expect(
        resolveCoverLocation(
          absentLocation: 'Dokki',
          covererLocationThatDay: 'Nasr City',
          covererHomeLocation: '6th of October',
        ),
        'Dokki',
      );
      expect(
        resolveCoverLocation(
          absentLocation: ' ',
          covererLocationThatDay: 'Nasr City',
          covererHomeLocation: '6th of October',
        ),
        'Nasr City',
      );
      expect(
        resolveCoverLocation(covererHomeLocation: '6th of October'),
        '6th of October',
      );
      expect(resolveCoverLocation(), isNull);
    });
  });

  group('grant window', () {
    final now = DateTime(2026, 9, 23, 18);
    test('today through 14 days ahead', () {
      expect(isWithinPosAccessWindow('2026-09-23', now: now), isTrue);
      expect(isWithinPosAccessWindow('2026-10-07', now: now), isTrue);
      expect(isWithinPosAccessWindow('2026-10-08', now: now), isFalse);
      expect(isWithinPosAccessWindow('2026-09-22', now: now), isFalse);
      expect(isWithinPosAccessWindow('garbage', now: now), isFalse);
    });
  });
}
