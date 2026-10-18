// The B2B account page's collapsible sections: Journey (collapsed for an
// Active account, expanded for every other stage) and Open to-dos (always
// collapsed), each toggled by tapping its header.
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/b2b/data/b2b_repository.dart';
import 'package:jarz_pos/src/features/b2b/data/models/b2b_account_labels.dart';
import 'package:jarz_pos/src/features/b2b/data/models/b2b_models.dart';
import 'package:jarz_pos/src/features/b2b/presentation/screens/b2b_account_screen.dart';
import 'package:jarz_pos/src/features/credit/data/credit_repository.dart';
import 'package:jarz_pos/src/features/journey/data/journey_repository.dart';
import 'package:jarz_pos/src/features/journey/data/models/journey_note.dart';
import 'package:jarz_pos/src/features/pos/presentation/widgets/customer_search_widget.dart'
    show territoriesProvider;

class _FakeB2bRepository extends B2bRepository {
  _FakeB2bRepository(this.stage) : super(Dio());

  final String stage;

  @override
  Future<B2bAccountDetail> getAccount({
    required String doctype,
    required String name,
  }) async {
    return B2bAccountDetail(
      account: B2bAccount(
        doctype: doctype,
        name: name,
        title: 'Café Orbit',
        stage: stage,
        openTodos: const [
          B2bTodo(name: 'TODO-1', description: 'Call the owner'),
          B2bTodo(name: 'TODO-2', description: 'Send price list'),
        ],
      ),
    );
  }
}

class _FakeJourneyRepository extends JourneyRepository {
  _FakeJourneyRepository() : super(Dio());

  @override
  Future<List<JourneyNote>> getNotes({
    required String referenceDoctype,
    required String referenceName,
  }) async => const [
    JourneyNote(name: 'JN-1', note: 'Visited the shop'),
    JourneyNote(name: 'JN-2', note: 'Rang to confirm'),
  ];
}

Widget _app(String stage) {
  return ProviderScope(
    overrides: [
      b2bRepositoryProvider.overrideWithValue(_FakeB2bRepository(stage)),
      creditRepositoryProvider.overrideWithValue(CreditRepository(Dio())),
      journeyRepositoryProvider.overrideWithValue(_FakeJourneyRepository()),
      territoriesProvider(null).overrideWith((ref) async => const []),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const B2bAccountScreen(doctype: 'Lead', name: 'LEAD-1'),
    ),
  );
}

void main() {
  Future<void> pumpScreen(WidgetTester tester, String stage) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(stage));
    await tester.pumpAndSettle();
  }

  final journeyExpand = find.byKey(const ValueKey('b2b-journey-expand'));
  final journeyCollapse = find.byKey(const ValueKey('b2b-journey-collapse'));
  final todosHeader = find.byKey(const ValueKey('b2b-open-todos-header'));

  testWidgets('an Active account starts with Journey collapsed, with its count', (
    tester,
  ) async {
    await pumpScreen(tester, 'Active');

    expect(journeyExpand, findsOneWidget);
    expect(journeyCollapse, findsNothing);
    expect(
      find.descendant(of: journeyExpand, matching: find.text('Journey (2)')),
      findsOneWidget,
    );
    expect(find.text('Visited the shop'), findsNothing);
  });

  testWidgets('Journey toggles open and closed on an Active account', (
    tester,
  ) async {
    await pumpScreen(tester, 'Active');

    await tester.tap(journeyExpand);
    await tester.pumpAndSettle();
    expect(journeyCollapse, findsOneWidget);
    expect(journeyExpand, findsNothing);
    expect(find.text('Visited the shop'), findsOneWidget);

    await tester.tap(journeyCollapse);
    await tester.pumpAndSettle();
    expect(journeyExpand, findsOneWidget);
    expect(journeyCollapse, findsNothing);
    expect(find.text('Visited the shop'), findsNothing);
  });

  testWidgets('a non-Active account starts with Journey expanded', (
    tester,
  ) async {
    await pumpScreen(tester, 'Lead');

    expect(journeyCollapse, findsOneWidget);
    expect(journeyExpand, findsNothing);
    expect(find.text('Visited the shop'), findsOneWidget);

    await tester.tap(journeyCollapse);
    await tester.pumpAndSettle();
    expect(journeyExpand, findsOneWidget);
    expect(find.text('Visited the shop'), findsNothing);
  });

  testWidgets('Open to-dos start collapsed and toggle on tap', (tester) async {
    // Collapsed by default whatever the stage.
    for (final stage in ['Active', 'Lead']) {
      await pumpScreen(tester, stage);
      expect(todosHeader, findsOneWidget);
      expect(
        find.descendant(
          of: todosHeader,
          matching: find.text('Open to-dos (2)'),
        ),
        findsOneWidget,
      );
      expect(find.text('Call the owner'), findsNothing);
    }

    await tester.ensureVisible(todosHeader);
    await tester.tap(todosHeader);
    await tester.pumpAndSettle();
    expect(find.text('Call the owner'), findsOneWidget);
    expect(find.text('Send price list'), findsOneWidget);

    await tester.tap(todosHeader);
    await tester.pumpAndSettle();
    expect(find.text('Call the owner'), findsNothing);
  });
}
