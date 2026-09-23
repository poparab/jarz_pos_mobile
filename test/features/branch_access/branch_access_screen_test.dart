// Smoke test of the whole Branch Access screen against a fake repository:
// it renders branches, people and the history tab in both languages without
// layout errors, and a refused change shows the server's own sentence.
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/branch_access/data/branch_access_repository.dart';
import 'package:jarz_pos/src/features/branch_access/models/branch_access_models.dart';
import 'package:jarz_pos/src/features/branch_access/presentation/branch_access_screen.dart';

const _refusal =
    'Nasr city has an open shift (seif@example.com since 12:47). '
    'Branch access can only change when the branch is closed.';

class _FakeRepository implements BranchAccessRepository {
  _FakeRepository({this.canManageAll = true});

  final bool canManageAll;

  @override
  Future<BranchAccessOverview> getOverview() async =>
      BranchAccessOverview.fromJson({
        'can_manage_all': canManageAll,
        'branches': [
          {
            'pos_profile': 'Dokki',
            'manageable': true,
            'open_shift': {
              'name': 'POS-OPE-1',
              'user': 'seif@example.com',
              'user_full_name': 'Seif',
              'since': '2026-09-23 12:47:00',
            },
          },
          {'pos_profile': 'Nasr city', 'manageable': true},
          {'pos_profile': '6th of october', 'manageable': false},
        ],
        'users': [
          {
            'user': 'ali@example.com',
            'full_name': 'Ali',
            'branches': ['Dokki'],
            'day_access': [
              {
                'name': 'JPDA-1',
                'pos_profile': 'Nasr city',
                'access_date': '2026-09-25',
                'status': 'Scheduled',
                'row_added': 0,
              },
            ],
          },
        ],
      });

  @override
  Future<SetBranchAccessResult> setBranchAccess({
    required String user,
    required String posProfile,
    required bool allowed,
    String? notes,
  }) async {
    final options = RequestOptions(path: '/set');
    throw DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        statusCode: 417,
        data: {
          'exc_type': 'BranchOpenError',
          '_server_messages':
              '["{\\"message\\": \\"$_refusal\\", \\"indicator\\": \\"red\\"}"]',
        },
      ),
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<DayAccessResult> grantDayAccess({
    required String user,
    required String posProfile,
    required String accessDate,
    String? notes,
  }) async => const DayAccessResult();

  @override
  Future<DayAccessResult> cancelDayAccess(String name) async =>
      const DayAccessResult();

  @override
  Future<BranchAccessLogPage> getAccessLog({
    String? posProfile,
    String? user,
    int limit = 50,
    int start = 0,
  }) async => BranchAccessLogPage.fromJson({
    'rows': [
      {
        'name': 'JBAL-1',
        'creation': '2026-09-23 13:00:00',
        'user': 'ali@example.com',
        'user_full_name': 'Ali',
        'pos_profile': 'Dokki',
        'action': 'Added',
        'source': 'Branch Access Screen',
        'changed_by_name': 'Manager',
        'notes': 'New hire',
      },
    ],
    'has_more': false,
  });
}

Future<void> _pump(
  WidgetTester tester,
  Locale locale, {
  bool canManageAll = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        canActAsLineManagerProvider.overrideWithValue(true),
        branchAccessRepositoryProvider.overrideWithValue(
          _FakeRepository(canManageAll: canManageAll),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const BranchAccessScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final locale in const [Locale('en'), Locale('ar')]) {
    testWidgets('renders people and history ($locale)', (tester) async {
      await _pump(tester, locale);
      expect(tester.takeException(), isNull);
      expect(find.text('Ali'), findsOneWidget);
      expect(find.byType(FilterChip), findsNWidgets(3));

      await tester.tap(find.byType(Tab).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('New hire'), findsOneWidget);
    });
  }

  Future<List<String>> historyFilterOptions(WidgetTester tester) async {
    await tester.tap(find.byType(Tab).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    return [
      for (final b in ['Dokki', 'Nasr city', '6th of october'])
        if (find.text(b).evaluate().isNotEmpty) b,
    ];
  }

  testWidgets('history filter: a line manager sees only their branches', (
    tester,
  ) async {
    await _pump(tester, const Locale('en'), canManageAll: false);
    final options = await historyFilterOptions(tester);
    expect(options, containsAll(['Dokki', 'Nasr city']));
    expect(options, isNot(contains('6th of october')));
  });

  testWidgets('history filter: a manager sees every branch', (tester) async {
    await _pump(tester, const Locale('en'));
    final options = await historyFilterOptions(tester);
    expect(options, contains('6th of october'));
  });

  testWidgets('a refused change shows the server sentence verbatim in Arabic', (
    tester,
  ) async {
    await _pump(tester, const Locale('ar'));

    // Nasr city is closed, so its chip is tappable; the fake then refuses.
    await tester.tap(
      find.byKey(const ValueKey('branch-chip-ali@example.com-Nasr city')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton).last);
    await tester.pumpAndSettle();

    expect(find.text(_refusal), findsOneWidget);
  });
}
