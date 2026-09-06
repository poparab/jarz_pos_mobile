import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/repositories/customer_address_repository.dart';
import 'package:jarz_pos/src/features/b2b/data/b2b_repository.dart';
import 'package:jarz_pos/src/features/b2b/data/models/b2b_account_labels.dart';
import 'package:jarz_pos/src/features/b2b/data/models/b2b_models.dart';
import 'package:jarz_pos/src/features/b2b/presentation/screens/b2b_account_screen.dart';
import 'package:jarz_pos/src/features/leads/data/leads_repository.dart';
import 'package:jarz_pos/src/features/leads/data/models/lead.dart';
import 'package:jarz_pos/src/features/leads/presentation/screens/lead_form_screen.dart';
import 'package:jarz_pos/src/features/pos/presentation/widgets/customer_search_widget.dart'
    show territoriesProvider;

const _territories = <Map<String, dynamic>>[
  {'name': 'Cairo', 'territory_name': 'Cairo'},
  {'name': 'Giza', 'territory_name': 'Giza'},
];

const _leadSources = <String>['Walk In', 'Reference', 'Campaign'];

class _FakeB2bRepository extends B2bRepository {
  _FakeB2bRepository({this.accountDoctype = 'Lead'}) : super(Dio());

  final String accountDoctype;
  String? linkedCustomer;
  final List<String> linkCalls = [];
  int accountLoads = 0;

  @override
  Future<List<String>> getLeadSources() async => _leadSources;

  @override
  Future<B2bAccountDetail> getAccount({
    required String doctype,
    required String name,
  }) async {
    accountLoads += 1;
    return B2bAccountDetail(
      account: B2bAccount(
        doctype: accountDoctype,
        name: name,
        title: 'Acme Co',
        stage: 'Lead',
        contact: const B2bContact(mobileNo: '01000000000'),
        customer: linkedCustomer,
      ),
      labels: null,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> searchLinkableCustomers(
    String query, {
    int limit = 20,
  }) async => const [
    {
      'name': 'ilo specialty coffee',
      'customer_name': 'ILO Specialty Coffee',
      'customer_type': 'Individual',
    },
    {
      'name': 'ILO-PRODUCTION',
      'customer_name': 'ILO Production',
      'customer_type': 'Company',
      'customer_group': 'B2B',
    },
  ];

  @override
  Future<Map<String, dynamic>> linkExistingCustomer({
    required String partyDoctype,
    required String partyName,
    required String customer,
    String? expectedCustomer,
    bool allowRelink = false,
  }) async {
    linkCalls.add('$partyDoctype:$partyName:$customer');
    linkedCustomer = customer;
    return {'success': true, 'customer': customer, 'changed': true};
  }

  @override
  Future<OrderBinding> placeB2bOrder({
    required String partyDoctype,
    required String partyName,
    String? customerName,
    String? mobileNo,
    String? customerPrimaryAddress,
    String? territoryId,
    String? customerGroup,
    String? shippingAddressName,
  }) async => OrderBinding(
    customer: linkedCustomer!,
    customerName: linkedCustomer,
    orderPurpose: 'B2B Supply',
    requiresShippingAddressSelection: true,
    addressBook: const {
      'branch_options': [
        {
          'address_name': 'ILO-HELIOPOLIS',
          'branch_name': 'Heliopolis',
          'full_address': '104 Omar Ibn El Khattab',
          'effective_territory': 'EGMASRJD',
        },
        {
          'address_name': 'ILO-MADINATY',
          'branch_name': 'All Seasons Park',
          'full_address': 'Madinaty All Seasons Park',
          'effective_territory': 'EGMADINATY',
          'duplicate_count': 3,
        },
      ],
    },
  );
}

class _FakeAddressRepository extends CustomerAddressRepository {
  _FakeAddressRepository() : super(Dio());

  @override
  Future<List<Map<String, dynamic>>> getTerritories({String? search}) async =>
      _territories;
}

/// Minimal leads repository so [LeadFormScreen]'s category dropdown resolves
/// without hitting the network.
class _FakeLeadsRepository extends LeadsRepository {
  _FakeLeadsRepository() : super(Dio());

  @override
  Future<List<LeadCategory>> getLeadCategories() async => const [];
}

Widget _wrap(Widget child, {required List<Override> overrides}) {
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
      home: child,
    ),
  );
}

void main() {
  // The Source/Territory dropdowns now live on the single shared add-lead form
  // (LeadFormScreen), which both the Leads list and the B2B pipeline open.
  group('LeadFormScreen B2B dropdowns', () {
    testWidgets('Source dropdown renders options from get_lead_sources', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const LeadFormScreen(),
          overrides: [
            leadsRepositoryProvider.overrideWithValue(_FakeLeadsRepository()),
            b2bRepositoryProvider.overrideWithValue(_FakeB2bRepository()),
            b2bLeadSourcesProvider.overrideWith((ref) async => _leadSources),
            territoriesProvider(null).overrideWith((ref) async => _territories),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // The Source dropdown is present.
      expect(find.text('Source'), findsOneWidget);

      // Open it and verify the mocked options appear.
      await tester.tap(find.text('Source'));
      await tester.pumpAndSettle();
      expect(find.text('Walk In'), findsWidgets);
      expect(find.text('Reference'), findsWidgets);
      expect(find.text('Campaign'), findsWidgets);
    });

    testWidgets('Territory dropdown renders options from the territory list', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const LeadFormScreen(),
          overrides: [
            leadsRepositoryProvider.overrideWithValue(_FakeLeadsRepository()),
            b2bRepositoryProvider.overrideWithValue(_FakeB2bRepository()),
            b2bLeadSourcesProvider.overrideWith((ref) async => _leadSources),
            territoriesProvider(null).overrideWith((ref) async => _territories),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Territory'), findsOneWidget);

      await tester.tap(find.text('Territory'));
      await tester.pumpAndSettle();
      expect(find.text('Cairo'), findsWidgets);
      expect(find.text('Giza'), findsWidgets);
    });
  });

  group('B2bAccountScreen action bar', () {
    testWidgets('pinned action bar is wrapped in a SafeArea', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const B2bAccountScreen(doctype: 'Lead', name: 'LEAD-001'),
          overrides: [
            b2bRepositoryProvider.overrideWithValue(_FakeB2bRepository()),
            territoriesProvider(null).overrideWith((ref) async => _territories),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // The action buttons render.
      expect(find.text('Send sample'), findsOneWidget);
      expect(find.text('Place order'), findsOneWidget);

      // The pinned bar's Material is wrapped in a SafeArea(top: false).
      final safeAreas = tester
          .widgetList<SafeArea>(find.byType(SafeArea))
          .where((s) => s.top == false);
      expect(safeAreas, isNotEmpty);
    });

    for (final scenario in const [
      (doctype: 'Lead', name: 'LEAD-ILO', customer: 'ilo specialty coffee'),
      (doctype: 'Opportunity', name: 'OPP-ILO', customer: 'ILO-PRODUCTION'),
    ]) {
      testWidgets(
        '${scenario.doctype} links an existing customer and shows two branches',
        (tester) async {
          final repo = _FakeB2bRepository(accountDoctype: scenario.doctype);
          await tester.pumpWidget(
            _wrap(
              B2bAccountScreen(doctype: scenario.doctype, name: scenario.name),
              overrides: [
                b2bRepositoryProvider.overrideWithValue(repo),
                customerAddressRepositoryProvider.overrideWithValue(
                  _FakeAddressRepository(),
                ),
                territoriesProvider(
                  null,
                ).overrideWith((ref) async => _territories),
              ],
            ),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Place order'));
          await tester.pumpAndSettle();
          await tester.tap(
            find.text(
              scenario.customer == 'ilo specialty coffee'
                  ? 'ILO Specialty Coffee'
                  : 'ILO Production',
            ),
          );
          await tester.pump();
          await tester.tap(find.text('Link and continue'));
          // The account deliberately keeps a busy spinner behind the branch
          // dialog until selection finishes, so pumpAndSettle cannot quiesce.
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          expect(find.text('Heliopolis'), findsOneWidget);
          expect(find.text('All Seasons Park'), findsOneWidget);
          expect(repo.linkCalls, [
            '${scenario.doctype}:${scenario.name}:${scenario.customer}',
          ]);

          await tester.tap(find.text('Cancel').last);
          await tester.pumpAndSettle();
          expect(repo.accountLoads, greaterThan(1));
        },
      );
    }
  });
}
