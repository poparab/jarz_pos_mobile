import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/approvals/models/pending_approvals.dart';
import 'package:jarz_pos/src/features/credit/data/credit_repository.dart';
import 'package:jarz_pos/src/features/credit/data/models/settlement_models.dart';
import 'package:jarz_pos/src/features/credit/presentation/settlement_labels.dart';
import 'package:jarz_pos/src/features/credit/presentation/widgets/settlement_terms_card.dart';
import 'package:jarz_pos/src/features/credit/presentation/widgets/settlement_terms_sheet.dart';
import 'package:jarz_pos/src/features/tasks/models/task_models.dart';
import 'package:jarz_pos/src/features/tasks/state/tasks_providers.dart';

/// Settlement terms: a B2B shop's agreed pay rhythm, feeding reminders and the
/// Collections list. Nothing here blocks an order.
///
/// The payloads below use the EXACT keys of the settlement-terms contract.
/// The credit feature's first production week was lost to a row model reading
/// a key that only existed on the summary; these tests read each shape from
/// its own keys and would fail on that mistake.

Map<String, dynamic> _termsPayload({
  String state = 'overdue',
  bool canEdit = true,
}) =>
    {
      'success': true,
      'customer': 'CUST-0042',
      'customer_name': 'Café Orbit',
      'terms': {
        'customer': 'CUST-0042',
        'enabled': 1,
        'cycle': 'Weekly',
        'weekdays': 'Thu',
        'week_interval': 1,
        'month_days': null,
        'interval_days': null,
        'anchor_date': '2026-09-01',
        'remind_days_before': 1,
        'overdue_repeat_days': 2,
        'responsible_user': 'sara@orderjarz.com',
        'notes': 'Returns credited on the next invoice',
        'exists': true,
      },
      'description': 'Every Thursday',
      'status': {
        'state': state,
        'next_due_date': '2026-10-01',
        'next_due_amount': 450.0,
        'due_now_amount': '1200.50',
        'overdue_amount': 1200.5,
        'open_balance': 1650.5,
        'oldest_overdue_date': '2026-09-17',
        'upcoming_dates': ['2026-10-01', '2026-10-08', '2026-10-15'],
      },
      'currency': 'EGP',
      'can_edit': canEdit,
    };

Map<String, dynamic> _collectionsPayload() => {
      'success': true,
      'currency': 'EGP',
      'rows': [
        {
          'customer': 'CUST-0042',
          'customer_name': 'Café Orbit',
          'cycle': 'Weekly',
          'description': 'Every Thursday',
          'state': 'overdue',
          'next_due_date': '2026-10-01',
          'next_due_amount': 450,
          'due_now_amount': 1200.5,
          'overdue_amount': 1200.5,
          'open_balance': 1650.5,
          'responsible_user': 'sara@orderjarz.com',
        },
        {
          'customer': 'CUST-0099',
          'customer_name': 'Beanery',
          'cycle': null,
          'description': '',
          'state': 'unscheduled',
          'next_due_date': null,
          'next_due_amount': 0,
          'due_now_amount': 0,
          'overdue_amount': 0,
          'open_balance': '300.00',
          'responsible_user': null,
        },
        {
          'customer': 'CUST-0007',
          'customer_name': 'Roastery',
          'cycle': 'Days of Month',
          'description': 'On the 15th and the last day of each month',
          'state': 'due_today',
          'next_due_date': '2026-09-30',
          'next_due_amount': 800,
          'due_now_amount': 800,
          'overdue_amount': 0,
          'open_balance': 800,
          'responsible_user': '',
        },
      ],
      'counts': {'overdue': 1, 'due_today': 1, 'due_soon': 0},
    };

Widget _app({required Widget child, List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

class _RecordingRepository extends CreditRepository {
  _RecordingRepository() : super(Dio());

  final List<Map<String, dynamic>> payloads = [];

  @override
  Future<SettlementTermsResponse> saveSettlementTerms(
    SettlementTermsDraft draft,
  ) async {
    payloads.add(draft.toPayload());
    return SettlementTermsResponse.fromJson(_termsPayload());
  }
}

void main() {
  group('model parsing — exact contract keys', () {
    test('get_settlement_terms response', () {
      final parsed = SettlementTermsResponse.fromJson(_termsPayload());

      expect(parsed.customer, 'CUST-0042');
      expect(parsed.customerName, 'Café Orbit');
      expect(parsed.canEdit, isTrue);
      expect(parsed.currency, 'EGP');
      expect(parsed.description, 'Every Thursday');
      expect(parsed.hasTerms, isTrue);

      final terms = parsed.terms!;
      expect(terms.enabled, isTrue);
      expect(terms.cycle, SettlementCycle.weekly);
      expect(terms.weekdayList, ['Thu']);
      expect(terms.weekInterval, 1);
      expect(terms.monthDays, '');
      expect(terms.intervalDays, isNull);
      expect(terms.anchorDate, '2026-09-01');
      expect(terms.remindDaysBefore, 1);
      expect(terms.overdueRepeatDays, 2);
      expect(terms.responsibleUser, 'sara@orderjarz.com');
      expect(terms.notes, 'Returns credited on the next invoice');

      final status = parsed.status;
      expect(status.state, SettlementState.overdue);
      expect(status.nextDueDate, '2026-10-01');
      expect(status.nextDueAmount, 450.0);
      // A serialised Decimal arrives as a String.
      expect(status.dueNowAmount, 1200.5);
      expect(status.overdueAmount, 1200.5);
      expect(status.openBalance, 1650.5);
      expect(status.oldestOverdueDate, '2026-09-17');
      expect(status.upcomingDates, hasLength(3));
      expect(status.collectOnNextDelivery, isNull);
    });

    test('a shop with no terms: terms null, can_edit absent', () {
      final parsed = SettlementTermsResponse.fromJson({
        'success': true,
        'customer': 'CUST-1',
        'customer_name': 'New Shop',
        'terms': null,
        'description': '',
        'status': {'state': 'none', 'open_balance': 0},
        'currency': 'EGP',
      });
      expect(parsed.terms, isNull);
      expect(parsed.hasTerms, isFalse);
      expect(parsed.canEdit, isFalse);
      expect(parsed.status.state, SettlementState.none);
    });

    test('an empty template (exists: false) is not a saved record', () {
      final parsed = SettlementTermsResponse.fromJson({
        'terms': {'cycle': '', 'exists': false},
        'status': <String, dynamic>{},
      });
      expect(parsed.hasTerms, isFalse);
    });

    test('weekdays / month_days as JSON lists, Invoice after Invoice status',
        () {
      final terms = SettlementTerms.fromJson({
        'cycle': 'Days of Month',
        'month_days': ['last', 15, '15'],
        'weekdays': ['Thu', 'Mon'],
      });
      expect(terms.monthDayList, ['15', 'last']);
      expect(terms.weekdayList, ['Mon', 'Thu']);
      expect(terms.enabled, isTrue, reason: 'absent enabled reads as on');

      final status = SettlementStatus.fromJson({
        'state': 'due_today',
        'next_due_date': null,
        'collect_on_next_delivery': '250.00',
      });
      expect(status.hasNextDue, isFalse);
      expect(status.collectOnNextDelivery, 250.0);
    });

    test('get_collections_due: row keys on rows, counts on the envelope', () {
      final parsed = CollectionsDue.fromJson(_collectionsPayload());
      expect(parsed.currency, 'EGP');
      expect(parsed.rows, hasLength(3));
      expect(parsed.counts.overdue, 1);
      expect(parsed.counts.dueToday, 1);
      expect(parsed.counts.dueSoon, 0);

      final first = parsed.rows.first;
      expect(first.customer, 'CUST-0042');
      expect(first.displayName, 'Café Orbit');
      expect(first.cycle, 'Weekly');
      expect(first.description, 'Every Thursday');
      expect(first.state, 'overdue');
      expect(first.nextDueDate, '2026-10-01');
      expect(first.nextDueAmount, 450);
      expect(first.dueNowAmount, 1200.5);
      expect(first.overdueAmount, 1200.5);
      expect(first.openBalance, 1650.5);
      expect(first.responsibleUser, 'sara@orderjarz.com');

      final unscheduled = parsed.rows[1];
      expect(unscheduled.cycle, '', reason: 'null cycle → no terms');
      expect(unscheduled.nextDueDate, '');
      expect(unscheduled.openBalance, 300.0);

      // Grouped in urgency order regardless of arrival order.
      expect(parsed.grouped.map((g) => g.key), [
        SettlementState.overdue,
        SettlementState.dueToday,
        SettlementState.unscheduled,
      ]);
    });

    test('credit_collections is a queue this build renders', () {
      final parsed = PendingApprovals.fromJson({
        'eligible': true,
        'queues': [
          {'key': 'credit_collections', 'count': 3},
        ],
      });
      expect(parsed.waiting.single.key, PendingApprovalKeys.creditCollections);
      expect(parsed.total, 3);
    });
  });

  group('SettlementTermsDraft.toPayload', () {
    test('fortnightly carries its anchor; weekly does not', () {
      final fortnightly = const SettlementTermsDraft(
        customer: 'C',
        cycle: SettlementCycle.weekly,
        weekdays: ['Thu'],
        weekInterval: 2,
        anchorDate: '2026-09-03',
      ).toPayload();
      expect(fortnightly['week_interval'], 2);
      expect(fortnightly['anchor_date'], '2026-09-03');

      final weekly = const SettlementTermsDraft(
        customer: 'C',
        cycle: SettlementCycle.weekly,
        weekdays: ['Thu'],
        anchorDate: '2026-09-03',
      ).toPayload();
      expect(weekly.containsKey('anchor_date'), isFalse);
    });

    test('fields of other cycles never travel', () {
      final payload = const SettlementTermsDraft(
        customer: 'C',
        cycle: SettlementCycle.onDelivery,
        weekdays: ['Thu'],
        monthDays: ['15'],
        intervalDays: 10,
        anchorDate: '2026-09-03',
      ).toPayload();
      expect(payload.keys, isNot(contains('weekdays')));
      expect(payload.keys, isNot(contains('month_days')));
      expect(payload.keys, isNot(contains('interval_days')));
      expect(payload.keys, isNot(contains('anchor_date')));
    });
  });

  group('localized description', () {
    testWidgets('English sentences per cycle', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        _app(
          child: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      String d(Map<String, dynamic> json) =>
          settlementDescription(l10n, SettlementTerms.fromJson(json));

      expect(d({'cycle': 'Weekly', 'weekdays': 'Thu'}), 'Every Thursday');
      expect(
        d({'cycle': 'Weekly', 'weekdays': 'Thu', 'week_interval': 2}),
        'Every 2 weeks on Thursday',
      );
      expect(
        d({'cycle': 'Days of Month', 'month_days': '15,last'}),
        'Every month on the 15th and the last day',
      );
      expect(d({'cycle': 'Every N Days', 'interval_days': 10}), 'Every 10 days');
      expect(
        d({'cycle': 'Invoice after Invoice'}),
        'Pays the previous invoice on each delivery',
      );
      expect(d({'cycle': 'On Delivery'}), 'Pays on delivery');
    });
  });

  group('SettlementTermsCard states', () {
    Future<void> pumpCard(
      WidgetTester tester,
      Map<String, dynamic> json, {
      VoidCallback? onEdit,
    }) async {
      await tester.pumpWidget(
        _app(
          child: SettlementTermsCard(
            data: SettlementTermsResponse.fromJson(json),
            onEdit: onEdit ?? () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    for (final (state, label) in [
      ('overdue', 'Overdue'),
      ('due_today', 'Due today'),
      ('due_soon', 'Due soon'),
      ('ok', 'On track'),
    ]) {
      testWidgets('$state renders the "$label" chip', (tester) async {
        await pumpCard(tester, _termsPayload(state: state));
        final chip = find.byType(SettlementStateChip);
        expect(chip, findsOneWidget);
        expect(
          find.descendant(of: chip, matching: find.text(label)),
          findsOneWidget,
        );
        expect(find.text('Every Thursday'), findsOneWidget);
        expect(find.text('Oct 1, 2026'), findsOneWidget);
        expect(find.text('Returns credited on the next invoice'), findsOneWidget);
        expect(find.text('sara@orderjarz.com'), findsOneWidget);
        expect(find.text('Edit'), findsOneWidget);
      });
    }

    testWidgets('overdue shows due-now, overdue amount and since-date',
        (tester) async {
      await pumpCard(tester, _termsPayload());
      expect(find.text('Due now'), findsOneWidget);
      expect(find.text('Overdue since'), findsOneWidget);
      expect(find.text('Sep 17, 2026'), findsOneWidget);
      expect(find.textContaining('1,200.50'), findsNWidgets(2));
    });

    testWidgets('no terms with a balance: "Not scheduled" + Set terms',
        (tester) async {
      await pumpCard(tester, {
        'customer': 'CUST-1',
        'terms': null,
        'status': {'state': 'unscheduled', 'open_balance': 300},
        'currency': 'EGP',
        'can_edit': true,
      });
      expect(find.text('Not scheduled'), findsOneWidget);
      expect(find.text('Set terms'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('renders in Arabic (RTL) with a localized schedule',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SettlementTermsCard(
                data: SettlementTermsResponse.fromJson(_termsPayload()),
                onEdit: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        Directionality.of(tester.element(find.byType(SettlementTermsCard))),
        TextDirection.rtl,
      );
      expect(find.text('متأخر'), findsWidgets);
      expect(find.textContaining('الخميس'), findsOneWidget);
    });

    testWidgets('read-only caller sees no edit action', (tester) async {
      await pumpCard(tester, _termsPayload(canEdit: false));
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Set terms'), findsNothing);
    });
  });

  group('SettlementTermsSheet payload per cycle', () {
    Future<_RecordingRepository> openSheet(
      WidgetTester tester, {
      SettlementTerms? initial,
    }) async {
      tester.view.physicalSize = const Size(1200, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = _RecordingRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            creditRepositoryProvider.overrideWithValue(repository),
            taskBoardContextProvider
                .overrideWith((ref) async => TaskBoardContext.denied),
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
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => SettlementTermsSheet.show(
                    context,
                    customer: 'CUST-0042',
                    customerName: 'Café Orbit',
                    initial: initial,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return repository;
    }

    Future<void> pickCycle(WidgetTester tester, String cycle) async {
      await tester.tap(find.byKey(ValueKey('settlement-cycle-$cycle')));
      await tester.pumpAndSettle();
    }

    Future<void> save(WidgetTester tester) async {
      await tester.tap(find.byKey(const ValueKey('settlement-save')));
      await tester.pumpAndSettle();
    }

    testWidgets('Weekly on Thursday', (tester) async {
      final repo = await openSheet(tester);
      await pickCycle(tester, SettlementCycle.weekly);
      await tester.tap(find.byKey(const ValueKey('settlement-weekday-Thu')));
      await tester.pumpAndSettle();
      await save(tester);

      expect(repo.payloads.single, {
        'customer': 'CUST-0042',
        'cycle': 'Weekly',
        'enabled': 1,
        'weekdays': 'Thu',
        'week_interval': 1,
        'remind_days_before': 1,
        'overdue_repeat_days': 2,
      });
      expect(find.byType(SettlementTermsSheet), findsNothing);
    });

    testWidgets('Weekly with no day is refused, nothing sent', (tester) async {
      final repo = await openSheet(tester);
      await pickCycle(tester, SettlementCycle.weekly);
      await save(tester);
      expect(repo.payloads, isEmpty);
      expect(find.text('Pick at least one day'), findsOneWidget);
    });

    testWidgets('Days of Month on the 15th and the last day', (tester) async {
      final repo = await openSheet(tester);
      await pickCycle(tester, SettlementCycle.daysOfMonth);
      await tester.tap(find.byKey(const ValueKey('settlement-monthday-last')));
      await tester.tap(find.byKey(const ValueKey('settlement-monthday-15')));
      await tester.pumpAndSettle();
      await save(tester);

      expect(repo.payloads.single, {
        'customer': 'CUST-0042',
        'cycle': 'Days of Month',
        'enabled': 1,
        'month_days': '15,last',
        'remind_days_before': 1,
        'overdue_repeat_days': 2,
      });
    });

    testWidgets('Every N Days', (tester) async {
      final repo = await openSheet(tester);
      await pickCycle(tester, SettlementCycle.everyNDays);
      await tester.enterText(
        find.byKey(const ValueKey('settlement-interval-days')),
        '10',
      );
      await tester.enterText(
        find.byKey(const ValueKey('settlement-remind-days')),
        '0',
      );
      await tester.pumpAndSettle();
      await save(tester);

      expect(repo.payloads.single, {
        'customer': 'CUST-0042',
        'cycle': 'Every N Days',
        'enabled': 1,
        'interval_days': 10,
        'remind_days_before': 0,
        'overdue_repeat_days': 2,
      });
    });

    testWidgets('Invoice after Invoice', (tester) async {
      final repo = await openSheet(tester);
      await pickCycle(tester, SettlementCycle.invoiceAfterInvoice);
      await tester.enterText(
        find.byKey(const ValueKey('settlement-notes')),
        '  Pays last invoice at the door  ',
      );
      await save(tester);

      expect(repo.payloads.single, {
        'customer': 'CUST-0042',
        'cycle': 'Invoice after Invoice',
        'enabled': 1,
        'remind_days_before': 1,
        'overdue_repeat_days': 2,
        'notes': 'Pays last invoice at the door',
      });
    });

    testWidgets('On Delivery', (tester) async {
      final repo = await openSheet(tester);
      await pickCycle(tester, SettlementCycle.onDelivery);
      await save(tester);

      expect(repo.payloads.single, {
        'customer': 'CUST-0042',
        'cycle': 'On Delivery',
        'enabled': 1,
        'remind_days_before': 1,
        'overdue_repeat_days': 2,
      });
    });

    testWidgets('editing: switching cycle drops the old cycle fields',
        (tester) async {
      final initial = SettlementTermsResponse.fromJson(_termsPayload()).terms;
      final repo = await openSheet(tester, initial: initial);
      // Opens on the saved cycle with the saved day already chosen.
      final thu = tester.widget<FilterChip>(
        find.byKey(const ValueKey('settlement-weekday-Thu')),
      );
      expect(thu.selected, isTrue);

      await pickCycle(tester, SettlementCycle.daysOfMonth);
      await tester.tap(find.byKey(const ValueKey('settlement-monthday-15')));
      await tester.pumpAndSettle();
      await save(tester);

      expect(repo.payloads.single, {
        'customer': 'CUST-0042',
        'cycle': 'Days of Month',
        'enabled': 1,
        'month_days': '15',
        'remind_days_before': 1,
        'overdue_repeat_days': 2,
        'responsible_user': 'sara@orderjarz.com',
        'notes': 'Returns credited on the next invoice',
      });
    });
  });
}
