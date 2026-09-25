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
import 'package:jarz_pos/src/features/credit/data/models/settlement_models.dart';
import 'package:jarz_pos/src/features/credit/presentation/widgets/settlement_terms_card.dart';
import 'package:jarz_pos/src/features/pos/presentation/widgets/customer_search_widget.dart'
    show territoriesProvider;

/// The B2B account screen's "Payment terms" section: a Lead's own terms
/// before conversion, the Customer's once there is one, and nothing at all
/// when the caller may not see terms or the server predates them.

class _FakeB2bRepository extends B2bRepository {
  _FakeB2bRepository({this.customer}) : super(Dio());

  final String? customer;

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
        stage: doctype == 'Customer' ? 'Customer' : 'Lead',
        customer: customer,
      ),
    );
  }
}

class _FakeCreditRepository extends CreditRepository {
  _FakeCreditRepository({this.unavailable = false, this.canEdit = true})
      : super(Dio());

  final bool unavailable;

  /// The server decides this per party (a rep may edit a Lead or a Company
  /// customer, not every customer); the UI only follows it.
  final bool canEdit;
  final List<Map<String, String?>> calls = [];

  @override
  Future<SettlementTermsResponse> getSettlementTerms({
    String? customer,
    String? lead,
  }) async {
    calls.add({'customer': customer, 'lead': lead});
    if (unavailable) throw const SettlementTermsUnavailable('403');
    final isLead = lead != null;
    return SettlementTermsResponse.fromJson({
      'party_type': isLead ? 'Lead' : 'Customer',
      'party': lead ?? customer,
      'customer': customer,
      'customer_name': 'Café Orbit',
      'terms': {'cycle': 'Invoice after Invoice', 'exists': true},
      'description': 'Pays the previous invoice on each delivery',
      'status': {'state': 'none', 'open_balance': 0},
      'currency': 'EGP',
      'can_edit': canEdit,
    });
  }
}

Widget _app({
  required Widget home,
  required B2bRepository b2b,
  required CreditRepository credit,
}) {
  return ProviderScope(
    overrides: [
      b2bRepositoryProvider.overrideWithValue(b2b),
      creditRepositoryProvider.overrideWithValue(credit),
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
      home: home,
    ),
  );
}

const _leadHint = 'Will apply automatically when this lead becomes a customer.';

void main() {
  group('settlementPartyForAccount', () {
    test('a Lead without a Customer is its own party', () {
      expect(
        settlementPartyForAccount(
          const B2bAccount(doctype: 'Lead', name: 'LEAD-1', title: 'x'),
        ),
        const SettlementParty.lead('LEAD-1'),
      );
    });

    test('a converted Lead uses its Customer', () {
      expect(
        settlementPartyForAccount(
          const B2bAccount(
            doctype: 'Lead',
            name: 'LEAD-1',
            title: 'x',
            customer: 'CUST-1',
          ),
        ),
        const SettlementParty.customer('CUST-1'),
      );
    });

    test('a Customer account is the Customer', () {
      expect(
        settlementPartyForAccount(
          const B2bAccount(doctype: 'Customer', name: 'CUST-2', title: 'x'),
        ),
        const SettlementParty.customer('CUST-2'),
      );
    });

    test('an Opportunity falls back to its Lead, else nothing', () {
      expect(
        settlementPartyForAccount(
          const B2bAccount(
            doctype: 'Opportunity',
            name: 'OPP-1',
            title: 'x',
            branchLead: 'LEAD-3',
          ),
        ),
        const SettlementParty.lead('LEAD-3'),
      );
      expect(
        settlementPartyForAccount(
          const B2bAccount(doctype: 'Opportunity', name: 'OPP-1', title: 'x'),
        ),
        isNull,
      );
    });
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required String doctype,
    required String name,
    String? customer,
    required _FakeCreditRepository credit,
  }) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(
        b2b: _FakeB2bRepository(customer: customer),
        credit: credit,
        home: B2bAccountScreen(doctype: doctype, name: name),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Lead account shows the card, asks with lead=, shows the hint', (
    tester,
  ) async {
    final credit = _FakeCreditRepository();
    await pumpScreen(tester, doctype: 'Lead', name: 'LEAD-1', credit: credit);

    expect(find.byType(SettlementTermsCard), findsOneWidget);
    expect(find.text('Payment terms'), findsOneWidget);
    expect(find.text(_leadHint), findsOneWidget);
    expect(credit.calls, [
      {'customer': null, 'lead': 'LEAD-1'},
    ]);
  });

  testWidgets('Customer account shows the card, asks with customer=', (
    tester,
  ) async {
    final credit = _FakeCreditRepository();
    await pumpScreen(
      tester,
      doctype: 'Customer',
      name: 'CUST-1',
      customer: 'CUST-1',
      credit: credit,
    );

    expect(find.byType(SettlementTermsCard), findsOneWidget);
    expect(find.text(_leadHint), findsNothing);
    expect(credit.calls, [
      {'customer': 'CUST-1', 'lead': null},
    ]);
  });

  testWidgets('can_edit false: the card shows, with no edit action', (
    tester,
  ) async {
    final credit = _FakeCreditRepository(canEdit: false);
    await pumpScreen(
      tester,
      doctype: 'Customer',
      name: 'CUST-1',
      customer: 'CUST-1',
      credit: credit,
    );

    final card = find.byType(SettlementTermsCard);
    expect(card, findsOneWidget);
    expect(
      find.descendant(of: card, matching: find.byType(TextButton)),
      findsNothing,
    );
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Set terms'), findsNothing);
  });

  testWidgets('can_edit true: Edit only, never a delete action', (
    tester,
  ) async {
    final credit = _FakeCreditRepository();
    await pumpScreen(tester, doctype: 'Lead', name: 'LEAD-1', credit: credit);

    final card = find.byType(SettlementTermsCard);
    expect(
      find.descendant(of: card, matching: find.text('Edit')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.byIcon(Icons.delete_outline)),
      findsNothing,
    );
    expect(
      find.descendant(of: card, matching: find.textContaining('Delete')),
      findsNothing,
    );
  });

  testWidgets('403 / older server hides the section silently', (
    tester,
  ) async {
    final credit = _FakeCreditRepository(unavailable: true);
    await pumpScreen(tester, doctype: 'Lead', name: 'LEAD-1', credit: credit);

    expect(credit.calls, hasLength(1));
    expect(find.byType(SettlementTermsCard), findsNothing);
    expect(find.text('Payment terms'), findsNothing);
    expect(find.text('Could not load payment terms'), findsNothing);
  });
}
