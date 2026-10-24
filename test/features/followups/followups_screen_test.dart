import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/business_constants.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/followups/data/followups_repository.dart';
import 'package:jarz_pos/src/features/followups/data/models/followup_models.dart';
import 'package:jarz_pos/src/features/followups/presentation/screens/followups_screen.dart';

class _FakeRepo implements FollowupsRepository {
  _FakeRepo(this.today, {this.logError});

  final FollowupsToday today;
  final Object? logError;
  final List<Map<String, Object?>> logged = [];

  @override
  Future<FollowupsToday> fetchToday() async => today;

  @override
  Future<FollowupLogResult> logTouch({
    required String name,
    required FollowupOutcome outcome,
    FollowupReach? reached,
    String? notes,
  }) async {
    if (logError != null) throw logError!;
    logged.add({'name': name, 'outcome': outcome, 'reached': reached});
    return const FollowupLogResult();
  }

  @override
  Future<void> skipTouch({required String name, String? reason}) async {}

  @override
  Future<FollowupDraftResult> draftMessage(String name,
          {bool refresh = false}) async =>
      FollowupDraftResult(name: name, messageText: 'm', source: 'template');

  @override
  Future<FollowupBriefResult> getCallBrief(String name,
          {bool refresh = false}) async =>
      FollowupBriefResult(name: name, brief: 'b', source: 'template');

  @override
  Future<FollowupStats> fetchStats({
    required String fromDate,
    required String toDate,
  }) async =>
      const FollowupStats();
}

FollowupsToday _today() => FollowupsToday.fromJson({
      'summary': {'due': 2, 'overdue': 1, 'calls': 1, 'messages': 1},
      'rows': [
        {
          'name': 'CF-A',
          'customer_name': 'Mona',
          'phone': '01012345678',
          'step': 'day2',
          'channel': 'Call',
          'is_overdue': 1,
          'customer_type': 'New',
          'value_band': 'High',
          'order_value': 1200,
          'woo_order_id': 17901,
        },
        {
          'name': 'CF-B',
          'customer_name': 'Omar',
          'whatsapp_msisdn': '201112223333',
          'message_text': 'hello',
          'step': '3h',
          'channel': 'Message',
          'is_overdue': 0,
          'customer_type': 'Repeat',
          'value_band': 'Low',
          'rfm_is_regular': 1,
        },
      ],
    });

Future<void> _pump(
  WidgetTester tester,
  _FakeRepo repo, {
  Locale locale = const Locale('en'),
  List<String> roles = const [RoleNames.jarzLineManager],
}) async {
  await tester.binding.setSurfaceSize(const Size(800, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        followupsRepositoryProvider.overrideWithValue(repo),
        userRolesFutureProvider.overrideWith(
          (ref) async => UserRoles(user: 'sender@jarz.pos', roles: roles),
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
        home: const FollowupsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders summary, sections and card chips', (tester) async {
    await _pump(tester, _FakeRepo(_today()));

    expect(find.text('Follow-ups today'), findsOneWidget);
    expect(find.text('Overdue (1)'), findsOneWidget);
    expect(find.text('Today (1)'), findsOneWidget);
    expect(find.text('Mona'), findsOneWidget);
    expect(find.text('Omar'), findsOneWidget);
    expect(find.text('High value (≥ 1000)'), findsOneWidget);
    expect(find.text('Regular'), findsOneWidget);
    expect(find.textContaining('Order #17901'), findsOneWidget);
    expect(find.textContaining('Day 2'), findsOneWidget);
    expect(find.textContaining('After 3 hours'), findsOneWidget);
  });

  testWidgets('Arabic step labels', (tester) async {
    await _pump(tester, _FakeRepo(_today()), locale: const Locale('ar'));

    expect(find.text('متابعات النهارده'), findsOneWidget);
    expect(find.textContaining('بعد ٣ ساعات'), findsOneWidget);
    expect(find.textContaining('اليوم'), findsWidgets);
  });

  testWidgets('a call needs Reached / Not reached before saving',
      (tester) async {
    final repo = _FakeRepo(_today());
    await _pump(tester, repo);

    await tester.tap(find.text('Log result').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Choose whether the customer answered'), findsOneWidget);

    await tester.tap(find.text('Not reached'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.logged.single['name'], 'CF-A');
    expect(repo.logged.single['outcome'], FollowupOutcome.noReply);
    expect(repo.logged.single['reached'], FollowupReach.notReached);
    expect(find.text('Mona'), findsNothing);
    expect(find.text('Result saved'), findsOneWidget);
  });

  testWidgets('Not reached locks the outcome to No reply', (tester) async {
    final repo = _FakeRepo(_today());
    await _pump(tester, repo);

    await tester.tap(find.text('Log result').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not reached'));
    await tester.pumpAndSettle();

    final happy = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Happy'),
    );
    expect(happy.onSelected, isNull);
    final noReply = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'No reply'),
    );
    expect(noReply.selected, isTrue);

    await tester.tap(find.text('Reached'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Happy'))
          .onSelected,
      isNotNull,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'No reply'))
          .selected,
      isFalse,
    );
  });

  testWidgets('stats link is hidden for a line manager', (tester) async {
    await _pump(tester, _FakeRepo(_today()));
    expect(find.byIcon(Icons.query_stats), findsNothing);
  });

  testWidgets('stats link is shown for a JARZ Manager', (tester) async {
    await _pump(
      tester,
      _FakeRepo(_today()),
      roles: const [RoleNames.jarzManager],
    );
    expect(find.byIcon(Icons.query_stats), findsOneWidget);
  });

  testWidgets('shows the server reason when logging fails', (tester) async {
    final error = DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 417,
        data: {
          'exc_type': 'ValidationError',
          'message': 'This follow-up is already closed and cannot be logged again.',
        },
      ),
      type: DioExceptionType.badResponse,
    );
    await _pump(tester, _FakeRepo(_today(), logError: error));

    await tester.tap(find.text('Log result').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Happy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('already closed and cannot be logged again'),
      findsOneWidget,
    );
    expect(find.text('Omar'), findsWidgets);
  });
}
