import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/credit/data/credit_repository.dart';
import 'package:jarz_pos/src/features/credit/data/models/settlement_models.dart';
import 'package:jarz_pos/src/features/credit/presentation/widgets/settlement_terms_card.dart';
import 'package:jarz_pos/src/features/credit/presentation/widgets/settlement_terms_sheet.dart';
import 'package:jarz_pos/src/features/credit/state/credit_providers.dart';
import 'package:jarz_pos/src/features/tasks/models/task_models.dart';
import 'package:jarz_pos/src/features/tasks/state/tasks_providers.dart';

/// Settlement terms held on a Lead (settlement-terms-leads): the rep records
/// the agreed terms during the deal, before the first order, and the server
/// moves them to the Customer on conversion.

/// A Lead that is not a Customer yet: `customer` is null.
Map<String, dynamic> _leadPayload() => {
      'success': true,
      'party_type': 'Lead',
      'party': 'CRM-LEAD-2026-00042',
      'customer': null,
      'customer_name': 'Café Orbit',
      'terms': {
        'enabled': 1,
        'cycle': 'Weekly',
        'weekdays': 'Thu',
        'week_interval': 1,
        'remind_days_before': 1,
        'overdue_repeat_days': 2,
        'responsible_user': null,
        'notes': 'Agreed at the tasting',
        'exists': true,
      },
      'description': 'Every Thursday',
      'status': {
        'state': 'none',
        'next_due_date': null,
        'next_due_amount': 0,
        'due_now_amount': 0,
        'overdue_amount': 0,
        'open_balance': 0,
        'oldest_overdue_date': null,
        'upcoming_dates': ['2026-10-01', '2026-10-08', '2026-10-15'],
      },
      'currency': 'EGP',
      'can_edit': true,
    };

Map<String, dynamic> _customerPayload() => {
      'success': true,
      'customer': 'CUST-0042',
      'customer_name': 'Café Orbit',
      'terms': {'cycle': 'On Delivery', 'exists': true},
      'description': 'Pays on delivery',
      'status': {'state': 'ok', 'open_balance': 0},
      'currency': 'EGP',
      'can_edit': true,
    };

/// Records every request and answers each with [reply] at [status].
class _CapturingAdapter implements HttpClientAdapter {
  _CapturingAdapter({this.reply, this.status = 200});

  final Map<String, dynamic>? reply;
  final int status;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(reply ?? {'message': _leadPayload()}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

CreditRepository _repoWith(_CapturingAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = adapter;
  return CreditRepository(dio);
}

class _RecordingRepository extends CreditRepository {
  _RecordingRepository() : super(Dio());

  final List<Map<String, dynamic>> payloads = [];

  @override
  Future<SettlementTermsResponse> saveSettlementTerms(
    SettlementTermsDraft draft,
  ) async {
    payloads.add(draft.toPayload());
    return SettlementTermsResponse.fromJson(_leadPayload());
  }
}

Widget _app({required Widget home, List<Override> overrides = const []}) {
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
      home: home,
    ),
  );
}

const _leadHint = 'Will apply automatically when this lead becomes a customer.';

void main() {
  group('models', () {
    test('unconverted lead: customer null is tolerated', () {
      final parsed = SettlementTermsResponse.fromJson(_leadPayload());
      expect(parsed.customer, '');
      expect(parsed.partyType, SettlementParty.leadType);
      expect(parsed.party, 'CRM-LEAD-2026-00042');
      expect(parsed.isUnconvertedLead, isTrue);
      expect(
        parsed.resolvedParty,
        const SettlementParty.lead('CRM-LEAD-2026-00042'),
      );
      expect(parsed.hasTerms, isTrue);
      expect(parsed.terms!.customer, '');
      expect(parsed.terms!.responsibleUser, '');
      expect(parsed.status.state, SettlementState.none);
      expect(parsed.status.upcomingDates, hasLength(3));
    });

    test('customer response carries party_type Customer', () {
      final parsed = SettlementTermsResponse.fromJson({
        ..._customerPayload(),
        'party_type': 'Customer',
        'party': 'CUST-0042',
      });
      expect(parsed.isUnconvertedLead, isFalse);
      expect(parsed.resolvedParty, const SettlementParty.customer('CUST-0042'));
    });

    test('party equality keys the provider by (type, name)', () {
      expect(const SettlementParty.lead('X'), const SettlementParty.lead('X'));
      expect(
        const SettlementParty.lead('X'),
        isNot(const SettlementParty.customer('X')),
      );
      expect(const SettlementParty.lead('X').queryParameters, {'lead': 'X'});
      expect(
        const SettlementParty.customer('X').queryParameters,
        {'customer': 'X'},
      );
    });

    test('a lead draft sends lead and never customer', () {
      final payload = const SettlementTermsDraft(
        lead: 'CRM-LEAD-1',
        cycle: SettlementCycle.onDelivery,
      ).toPayload();
      expect(payload['lead'], 'CRM-LEAD-1');
      expect(payload.containsKey('customer'), isFalse);
    });
  });

  group('repository', () {
    test('get sends only lead for a lead', () async {
      final adapter = _CapturingAdapter();
      final result = await _repoWith(adapter)
          .getSettlementTerms(lead: 'CRM-LEAD-2026-00042');
      expect(
        adapter.requests.single.queryParameters,
        {'lead': 'CRM-LEAD-2026-00042'},
      );
      expect(result.isUnconvertedLead, isTrue);
    });

    test('get sends only customer for a customer', () async {
      final adapter = _CapturingAdapter(
        reply: {'message': _customerPayload()},
      );
      final result =
          await _repoWith(adapter).getSettlementTerms(customer: 'CUST-0042');
      expect(
        adapter.requests.single.queryParameters,
        {'customer': 'CUST-0042'},
      );
      // An older server says nothing about the party: the request implies it.
      expect(result.partyType, SettlementParty.customerType);
      expect(result.party, 'CUST-0042');
      expect(result.customer, 'CUST-0042');
    });

    test('save and delete send the lead', () async {
      final adapter = _CapturingAdapter();
      final repo = _repoWith(adapter);
      await repo.saveSettlementTerms(
        const SettlementTermsDraft(
          lead: 'CRM-LEAD-1',
          cycle: SettlementCycle.invoiceAfterInvoice,
        ),
      );
      await repo.deleteSettlementTerms(lead: 'CRM-LEAD-1');
      final save = adapter.requests[0].data as Map;
      expect(save['lead'], 'CRM-LEAD-1');
      expect(save.containsKey('customer'), isFalse);
      expect(adapter.requests[1].data, {'lead': 'CRM-LEAD-1'});
    });

    test('exactly one of customer / lead', () {
      final repo = _repoWith(_CapturingAdapter());
      expect(() => repo.getSettlementTerms(), throwsArgumentError);
      expect(
        () => repo.getSettlementTerms(customer: 'C', lead: 'L'),
        throwsArgumentError,
      );
    });

    // (label, status, body, sent with lead=?)
    const oldBackend = {
      'exc_type': 'ValidationError',
      'exception': 'frappe.exceptions.ValidationError: customer is required',
      '_server_messages':
          '["{\\"message\\": \\"customer is required\\"}"]',
    };
    for (final (label, status, body, lead) in [
      ('403', 403, <String, dynamic>{}, true),
      ('404', 404, <String, dynamic>{}, false),
      (
        'exc_type PermissionError',
        417,
        <String, dynamic>{'exc_type': 'PermissionError'},
        false,
      ),
      (
        'exc_type DoesNotExistError',
        500,
        <String, dynamic>{'exc_type': 'DoesNotExistError'},
        true,
      ),
      (
        'a missing method',
        500,
        <String, dynamic>{
          'exception': 'Failed to get method for command '
              'jarz_pos.api.settlement_terms.get_settlement_terms',
        },
        false,
      ),
      (
        'a non-whitelisted method',
        500,
        <String, dynamic>{
          'exception': 'frappe.exceptions.PermissionError: Function '
              'get_settlement_terms is not whitelisted.',
        },
        false,
      ),
      ('an older backend answering lead= with 417', 417, oldBackend, true),
    ]) {
      test('$label is SettlementTermsUnavailable', () async {
        final adapter = _CapturingAdapter(reply: body, status: status);
        final repo = _repoWith(adapter);
        await expectLater(
          lead
              ? repo.getSettlementTerms(lead: 'L')
              : repo.getSettlementTerms(customer: 'C'),
          throwsA(isA<SettlementTermsUnavailable>()),
        );
      });
    }

    // A real failure keeps the retry line: none of these may hide the card.
    for (final (label, status, body, lead) in [
      (
        'a plain validation error',
        417,
        <String, dynamic>{'exception': 'ValidationError: something broke'},
        false,
      ),
      (
        '"customer is required" on a customer= request',
        417,
        oldBackend,
        false,
      ),
      (
        'a server bug whose traceback mentions has no attribute',
        500,
        <String, dynamic>{
          'exc_type': 'AttributeError',
          'exception':
              "AttributeError: 'NoneType' object has no attribute 'name'",
          'exc': '["Traceback ... No module named foo ... PermissionError"]',
        },
        true,
      ),
      (
        'an unexpected keyword argument (no longer a marker)',
        500,
        <String, dynamic>{
          'exc_type': 'TypeError',
          'exception': 'TypeError: got an unexpected keyword argument',
        },
        true,
      ),
    ]) {
      test('$label is a real error', () async {
        final adapter = _CapturingAdapter(reply: body, status: status);
        final repo = _repoWith(adapter);
        await expectLater(
          lead
              ? repo.getSettlementTerms(lead: 'L')
              : repo.getSettlementTerms(customer: 'C'),
          throwsA(
            allOf(isA<Exception>(), isNot(isA<SettlementTermsUnavailable>())),
          ),
        );
      });
    }

    test('provider is keyed by party and asks for that party', () async {
      final adapter = _CapturingAdapter();
      final container = ProviderContainer(
        overrides: [
          creditRepositoryProvider.overrideWithValue(_repoWith(adapter)),
        ],
      );
      addTearDown(container.dispose);
      const party = SettlementParty.lead('CRM-LEAD-9');
      final sub = container.listen(settlementTermsProvider(party), (_, _) {});
      addTearDown(sub.close);
      await container.read(settlementTermsProvider(party).future);
      expect(adapter.requests.single.queryParameters, {'lead': 'CRM-LEAD-9'});
    });
  });

  group('widgets', () {
    testWidgets('card shows the lead hint only for an unconverted lead', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          home: Scaffold(
            body: SettlementTermsCard(
              data: SettlementTermsResponse.fromJson(_leadPayload()),
              onEdit: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(_leadHint), findsOneWidget);
      expect(find.text('Every Thursday'), findsOneWidget);

      await tester.pumpWidget(
        _app(
          home: Scaffold(
            body: SettlementTermsCard(
              data: SettlementTermsResponse.fromJson(_customerPayload()),
              onEdit: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(_leadHint), findsNothing);
    });

    testWidgets('sheet opened for a lead saves with lead=', (tester) async {
      tester.view.physicalSize = const Size(1200, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = _RecordingRepository();
      await tester.pumpWidget(
        _app(
          overrides: [
            creditRepositoryProvider.overrideWithValue(repository),
            taskBoardContextProvider.overrideWith(
              (ref) async => TaskBoardContext.denied,
            ),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => SettlementTermsSheet.show(
                  context,
                  party: const SettlementParty.lead('CRM-LEAD-1'),
                  customerName: 'Café Orbit',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text(_leadHint), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('settlement-cycle-On Delivery')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('settlement-save')));
      await tester.pumpAndSettle();

      expect(repository.payloads.single, {
        'lead': 'CRM-LEAD-1',
        'cycle': 'On Delivery',
        'enabled': 1,
        'remind_days_before': 1,
        'overdue_repeat_days': 2,
      });
      expect(find.byType(SettlementTermsSheet), findsNothing);
    });
  });
}
