import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/business_constants.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/production_round/data/models/production_round.dart';
import 'package:jarz_pos/src/features/production_round/presentation/production_round_screen.dart';
import 'package:jarz_pos/src/features/production_round/state/production_round_providers.dart';

import '../production_round_fixture.dart';

const _manager = UserRoles(
  user: 'manager@jarz',
  roles: [RoleNames.jarzManager],
);
const _cashier = UserRoles(user: 'cashier@jarz', roles: []);

Future<void> _pump(
  WidgetTester tester, {
  Map<String, dynamic>? payload,
  UserRoles roles = _manager,
  Locale locale = const Locale('en'),
  // A 360 dp phone: the narrowest device in the field.
  Size size = const Size(360, 800),
  ThemeMode themeMode = ThemeMode.light,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userRolesFutureProvider.overrideWith((ref) async => roles),
        productionRoundProvider.overrideWith(
          (ref) async =>
              ProductionRound.fromJson(payload ?? productionRoundFixture()),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProductionRoundScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _inSize(String size, String text) => find.descendant(
  of: find.byKey(ValueKey('production-round-size-$size')),
  matching: find.text(text),
);

void main() {
  testWidgets('header shows batches and jars per size, and the alarm chips', (
    tester,
  ) async {
    await _pump(tester);

    expect(_inSize('Medium', 'Medium'), findsOneWidget);
    expect(_inSize('Medium', '2.5 batches'), findsOneWidget);
    expect(_inSize('Medium', '300 jars'), findsOneWidget);
    expect(_inSize('Large', 'Large'), findsOneWidget);
    expect(_inSize('Large', '5.25 batches'), findsOneWidget);
    expect(_inSize('Large', '404 jars'), findsOneWidget);

    expect(find.text('6 needed now'), findsOneWidget);
    expect(find.text('5 materials missing'), findsOneWidget);
    expect(find.text('9 items blocked'), findsOneWidget);
    expect(find.text('1 note'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chips are hidden when their counts are zero', (tester) async {
    final payload = productionRoundFixture();
    payload['summary'] = {
      ...payload['summary'] as Map<String, dynamic>,
      'needed_now_count': 0,
      'missing_count': 0,
      'blocked_count': 0,
    };
    await _pump(tester, payload: payload);

    expect(find.textContaining('needed now'), findsNothing);
    expect(find.textContaining('materials missing'), findsNothing);
    expect(find.textContaining('blocked'), findsNothing);
  });

  testWidgets(
    'Make tab folds zero-batch items into a collapsed Covered group',
    (tester) async {
      // Tall enough that both size sections are laid out at once.
      await _pump(tester, size: const Size(360, 1400));

      // One covered item per size: Lotus (Medium) and Date (Large).
      expect(find.text('Covered (1)'), findsNWidgets(2));
      // Collapsed: the covered flavours are not on screen yet.
      expect(find.text('Lotus'), findsNothing);
      expect(find.text('Date'), findsNothing);
      // Items to make are, with their batch pill.
      expect(find.text('Mango'), findsOneWidget);
      expect(find.text('0.75 batch · 90 jars'), findsOneWidget);
      expect(find.text('Blueberry'), findsOneWidget);
      expect(find.text('1 batch · 77 jars'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

      await tester.tap(find.text('Covered (1)').first);
      await tester.pumpAndSettle();
      expect(find.text('Lotus'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('tapping a row opens the per-branch breakdown', (tester) async {
    await _pump(tester, size: const Size(360, 1400));

    await tester.tap(find.text('Blueberry'));
    await tester.pumpAndSettle();

    expect(find.text('Blueberry Large'), findsOneWidget);
    expect(find.text('Blocked by:'), findsOneWidget);
    expect(find.textContaining('(missing 230)'), findsOneWidget);
    expect(find.text('Nasr city'), findsOneWidget);
    expect(find.text('0.2 days left'), findsOneWidget);
    expect(find.text('Negative — count first'), findsOneWidget);
    expect(find.text('Net need 63'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Materials tab: make-first card and missing-only by default', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('Materials'));
    await tester.pumpAndSettle();

    expect(find.text('Make first'), findsOneWidget);
    expect(find.text('Butter Biscuit'), findsOneWidget);
    expect(find.text('0.91 batch (12.43 Kg)'), findsOneWidget);
    expect(find.text('fresh, 7.2 batches'), findsOneWidget);
    expect(find.text('Crumble'), findsNothing);

    expect(find.text('Jar Lid 330'), findsOneWidget);
    expect(find.text('need 404 · have 174'), findsOneWidget);
    expect(find.text('short 230'), findsOneWidget);
    expect(find.text('Sugar'), findsNothing);

    await tester.tap(find.text('All (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Sugar'), findsOneWidget);
    expect(find.text('need 18.46 Kg · have 40 Kg'), findsOneWidget);
  });

  testWidgets('Branches tab: one compact card per branch', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Branches'));
    await tester.pumpAndSettle();

    expect(find.text('Nasr city'), findsOneWidget);
    expect(find.textContaining('Sells ~33'), findsOneWidget);
    expect(find.text('holds 222 of 1,120 target'), findsOneWidget);
    expect(find.text('needs 898'), findsOneWidget);
    expect(find.text('7 items below backup'), findsOneWidget);
    expect(find.textContaining('below backup'), findsOneWidget);
  });

  testWidgets('tune sheet offers the planning knobs, not batch sizes', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Planning settings'), findsWidgets);
    // Cycle 7/14/21 and backup 0/3/7/14 share the day labels.
    expect(find.widgetWithText(ChoiceChip, '7 days'), findsNWidgets(2));
    expect(find.widgetWithText(ChoiceChip, '14 days'), findsNWidgets(2));
    expect(find.widgetWithText(ChoiceChip, '21 days'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'None'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '3 days'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '8 weeks'), findsOneWidget);
    // The payload's own values are the selected ones: cycle 14, backup 7,
    // sales 8 weeks.
    bool isSelected(String label, int index) => tester
        .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, label).at(index))
        .selected;
    expect(isSelected('14 days', 0), isTrue);
    expect(isSelected('7 days', 1), isTrue);
    expect(isSelected('14 days', 1), isFalse);
    expect(isSelected('8 weeks', 0), isTrue);
  });

  testWidgets('empty items render a friendly message', (tester) async {
    final payload = productionRoundFixture()
      ..['items'] = <dynamic>[]
      ..['summary'] = <String, dynamic>{};
    await _pump(tester, payload: payload);

    expect(find.text('Nothing to make'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic, dark mode, 360 dp: renders without overflow', (
    tester,
  ) async {
    await _pump(tester, locale: const Locale('ar'), themeMode: ThemeMode.dark);
    expect(find.text('دورة الإنتاج'), findsOneWidget);
    expect(_inSize('Medium', 'وسط'), findsOneWidget);
    expect(_inSize('Large', '5.25 تشغيلة'), findsOneWidget);

    for (final tab in ['الخامات', 'الفروع', 'الإنتاج']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('roles outside the production view set are refused', (
    tester,
  ) async {
    await _pump(tester, roles: _cashier);
    expect(
      find.text('You do not have access to production planning.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.tune), findsNothing);
  });
}
