// The branch chip's lock state: a branch with an open shift, a branch the
// caller does not manage, and a line manager's own row are all disabled, show
// a lock and say why; an editable chip taps through.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/l10n/app_localizations_en.dart';
import 'package:jarz_pos/src/features/branch_access/models/branch_access_models.dart';
import 'package:jarz_pos/src/features/branch_access/presentation/widgets/branch_access_chip.dart';

const _closed = BranchAccessBranch(posProfile: 'Nasr city', manageable: true);

const _open = BranchAccessBranch(
  posProfile: 'Dokki',
  manageable: true,
  openShift: BranchOpenShift(
    name: 'POS-OPE-1',
    user: 'seif@example.com',
    userFullName: 'Seif',
    since: '2026-09-20 12:47:00',
  ),
);

const _notMine = BranchAccessBranch(posProfile: '6th of october');

const _ali = BranchAccessUser(
  user: 'ali@example.com',
  fullName: 'Ali',
  branches: ['Dokki'],
);

const _me = BranchAccessUser(
  user: 'me@example.com',
  fullName: 'Me',
  isSelf: true,
);

Future<List<int>> _pump(
  WidgetTester tester, {
  required BranchAccessUser user,
  required BranchAccessBranch branch,
  bool canManageAll = false,
  Locale locale = const Locale('en'),
}) async {
  final taps = <int>[];
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: BranchAccessChip(
            user: user,
            branch: branch,
            canManageAll: canManageAll,
            onTap: () => taps.add(1),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return taps;
}

FilterChip _chip(WidgetTester tester) =>
    tester.widget<FilterChip>(find.byType(FilterChip));

void main() {
  testWidgets('a closed, manageable branch is tappable', (tester) async {
    final taps = await _pump(tester, user: _ali, branch: _closed);

    expect(_chip(tester).onSelected, isNotNull);
    expect(find.byIcon(Icons.lock), findsNothing);
    await tester.tap(find.byType(FilterChip));
    expect(taps, [1]);
  });

  testWidgets('an open branch is locked and names who holds it', (
    tester,
  ) async {
    final taps = await _pump(tester, user: _ali, branch: _open);

    expect(_chip(tester).onSelected, isNull);
    expect(find.byIcon(Icons.lock), findsOneWidget);
    // Still reads as a member: locked is about changing, not about access.
    expect(_chip(tester).selected, isTrue);

    await tester.tap(find.byType(FilterChip));
    await tester.pump(const Duration(milliseconds: 200));
    expect(taps, isEmpty);

    final tooltip = tester.widget<Tooltip>(find.byType(Tooltip).first);
    expect(tooltip.message, contains('Dokki'));
    expect(tooltip.message, contains('Seif'));
    expect(tooltip.message, contains('12:47'));
  });

  testWidgets('a branch the caller does not manage is locked', (tester) async {
    await _pump(tester, user: _ali, branch: _notMine);

    expect(_chip(tester).onSelected, isNull);
    expect(find.byIcon(Icons.lock), findsOneWidget);
    final tooltip = tester.widget<Tooltip>(find.byType(Tooltip).first);
    expect(tooltip.message, AppLocalizationsEn().branchAccessNotYourBranch);
  });

  testWidgets('a line manager cannot change their own access', (tester) async {
    await _pump(tester, user: _me, branch: _closed);
    expect(_chip(tester).onSelected, isNull);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });

  testWidgets('the manager tier may change their own access', (tester) async {
    await _pump(tester, user: _me, branch: _closed, canManageAll: true);
    expect(_chip(tester).onSelected, isNotNull);
  });

  testWidgets('a row the server marks non-editable is locked', (tester) async {
    const target = BranchAccessUser(
      user: 'lm@example.com',
      fullName: 'Line Manager',
      editable: false,
    );
    await _pump(tester, user: target, branch: _closed, canManageAll: true);
    expect(_chip(tester).onSelected, isNull);
    expect(find.byIcon(Icons.lock), findsOneWidget);
    final tooltip = tester.widget<Tooltip>(find.byType(Tooltip).first);
    expect(tooltip.message, AppLocalizationsEn().branchAccessUserNotEditable);
  });

  testWidgets('editable=true overrides the own-row fallback', (tester) async {
    const me = BranchAccessUser(
      user: 'me@example.com',
      fullName: 'Me',
      isSelf: true,
      editable: true,
    );
    await _pump(tester, user: me, branch: _closed);
    expect(_chip(tester).onSelected, isNotNull);
  });

  testWidgets(
    'an active day access on an open branch can still be made permanent',
    (tester) async {
      const temp = BranchAccessUser(
        user: 'temp@example.com',
        fullName: 'Temp',
        branches: ['Dokki'],
        dayAccess: [
          DayAccess(
            name: 'JPDA-1',
            posProfile: 'Dokki',
            accessDate: '2026-09-20',
            status: 'Active',
            rowAdded: true,
          ),
        ],
      );
      final taps = await _pump(tester, user: temp, branch: _open);
      expect(_chip(tester).onSelected, isNotNull);
      expect(find.byIcon(Icons.lock), findsNothing);
      await tester.tap(find.byType(FilterChip));
      expect(taps, [1]);
    },
  );

  testWidgets('a scheduled day access on an open branch stays locked', (
    tester,
  ) async {
    const later = BranchAccessUser(
      user: 'later@example.com',
      fullName: 'Later',
      dayAccess: [
        DayAccess(
          name: 'JPDA-2',
          posProfile: 'Dokki',
          accessDate: '2026-09-25',
          status: 'Scheduled',
        ),
      ],
    );
    await _pump(tester, user: later, branch: _open);
    expect(_chip(tester).onSelected, isNull);
  });

  testWidgets('renders the lock state in Arabic too', (tester) async {
    await _pump(tester, user: _ali, branch: _open, locale: const Locale('ar'));
    expect(_chip(tester).onSelected, isNull);
    expect(tester.takeException(), isNull);
  });
}
