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
import 'package:jarz_pos/src/features/b2b/presentation/screens/b2b_branch_invoices_screen.dart';
import 'package:jarz_pos/src/features/pos/presentation/widgets/customer_search_widget.dart'
    show territoriesProvider;

const _branches = [
  B2bBranch(
    addressName: 'ILO-MADINATY',
    branchName: 'All Seasons Park',
    addressLine1: 'Madinaty',
    territory: 'EGMADINATY',
    isPrimaryAddress: true,
    latitude: 30.1,
    longitude: 31.6,
    invoiceCount: 3,
    totalBilled: 4500,
    outstanding: 250,
    lastOrderDate: '2026-09-20',
  ),
  B2bBranch(
    addressName: 'ILO-ZAYED',
    branchName: 'Zayed',
    territoryMissing: true,
  ),
];

class _FakeRepo extends B2bRepository {
  _FakeRepo() : super(Dio());

  final List<String?> invoiceBranches = [];
  final List<String> previews = [];
  List<String> blockers = const [];
  List<B2bBranch> branches = _branches;
  String? customer = 'ILO-1';
  final List<String> links = [];

  @override
  Future<B2bBranchLinkResult> linkBranch({
    required String doctype,
    required String name,
    required String mapsRow,
    String? addressName,
  }) async {
    links.add('$mapsRow>${addressName ?? ''}');
    // Mimic the server: link moves the maps row onto the address branch,
    // unlink turns it back into a maps-only entry.
    final source = branches.firstWhere((b) => b.mapsRow == mapsRow);
    final updated = <B2bBranch>[
      for (final b in branches)
        if (b.isMapsOnly && b.mapsRow == mapsRow)
          ...const <B2bBranch>[]
        else if (addressName != null && b.addressName == addressName)
          b.copyWith(maps: source.maps, mapsMatch: 'linked')
        else if (addressName == null && b.mapsRow == mapsRow)
          b.copyWith(maps: null, mapsMatch: null)
        else
          b,
      if (addressName == null)
        B2bBranch(source: 'maps', maps: source.maps),
    ];
    branches = updated;
    return B2bBranchLinkResult(branches: updated);
  }

  @override
  Future<List<B2bMergeCandidate>> searchMergeTargets({
    required String doctype,
    required String name,
    String? query,
    int limit = 20,
  }) async => const [
    B2bMergeCandidate(doctype: 'Lead', name: 'CRM-LEAD-2', title: 'ILO Zayed'),
  ];

  @override
  Future<B2bMergePreview> previewMergeAsBranch({
    required String sourceDoctype,
    required String sourceName,
    required String targetDoctype,
    required String targetName,
  }) async {
    previews.add('$sourceName>$targetName');
    return B2bMergePreview(
      canExecute: blockers.isEmpty,
      blockers: blockers,
      warnings: const ['irreversible_customer_merge', 'unknown_code'],
    );
  }

  @override
  Future<B2bAccountDetail> getAccount({
    required String doctype,
    required String name,
  }) async {
    return B2bAccountDetail(
      account: B2bAccount(
        doctype: doctype,
        name: name,
        title: 'ILO Specialty Coffee',
        customer: customer,
        branches: branches,
        unassignedInvoices: const B2bBranchStats(
          invoiceCount: 2,
          totalBilled: 800,
        ),
        recentInvoices: const [
          B2bRecentInvoice(
            name: 'ACC-SINV-1',
            postingDate: '2026-09-20',
            grandTotal: 1500,
            branchName: 'All Seasons Park',
          ),
        ],
      ),
    );
  }

  @override
  Future<B2bAccountInvoices> getAccountInvoices({
    required String doctype,
    required String name,
    String? branch,
    int limit = 100,
  }) async {
    invoiceBranches.add(branch);
    return B2bAccountInvoices(
      branch: branch,
      invoices: [
        B2bRecentInvoice(
          name: 'ACC-SINV-${invoiceBranches.length}',
          postingDate: '2026-09-20',
          grandTotal: 1500,
          outstandingAmount: 250,
          paymentMethod: 'Cash',
          branchName: branch == null ? 'All Seasons Park' : null,
        ),
      ],
      summary: const B2bBranchStats(
        invoiceCount: 1,
        totalBilled: 1500,
        outstanding: 250,
      ),
      truncated: true,
    );
  }
}

Widget _app(_FakeRepo repo, Widget home) => ProviderScope(
  overrides: [
    b2bRepositoryProvider.overrideWithValue(repo),
    territoriesProvider.overrideWith(
      (ref, search) async => [
        {'name': 'EGMADINATY', 'territory_name_ar': 'مدينتي'},
      ],
    ),
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

void main() {
  testWidgets('account screen lists branches and opens a branch filter', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = _FakeRepo();
    await tester.pumpWidget(
      _app(repo, const B2bAccountScreen(doctype: 'Customer', name: 'ILO-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Branches (2)'), findsOneWidget);
    expect(find.text('Add branch'), findsOneWidget);
    expect(find.text('All Seasons Park'), findsOneWidget);
    expect(find.textContaining('مدينتي'), findsOneWidget);
    expect(find.text('No delivery area'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Unassigned invoices'), findsOneWidget);
    expect(find.byTooltip('Open on map'), findsOneWidget);
    // The recent invoice names its branch.
    expect(find.textContaining('· All Seasons Park'), findsOneWidget);
    // Merge is offered for a Customer account.
    expect(find.byType(PopupMenuButton<String>), findsOneWidget);

    await tester.tap(find.text('All Seasons Park'));
    await tester.pumpAndSettle();

    expect(find.byType(B2bBranchInvoicesScreen), findsOneWidget);
    expect(repo.invoiceBranches, ['ILO-MADINATY']);
    expect(find.text('Showing the first 1 invoices only.'), findsOneWidget);
  });

  testWidgets('merge action is hidden for an Opportunity account', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _FakeRepo(),
        const B2bAccountScreen(doctype: 'Opportunity', name: 'CRM-OPP-1'),
      ),
    );
    await tester.pump();
    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });

  testWidgets('invoice screen switches branch filters', (tester) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(
      _app(
        repo,
        const B2bBranchInvoicesScreen(
          doctype: 'Customer',
          name: 'ILO-1',
          accountTitle: 'ILO',
          branches: _branches,
          hasUnassigned: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.invoiceBranches, [null]);
    expect(find.widgetWithText(ChoiceChip, 'All branches'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Unassigned'), findsOneWidget);
    // "All" shows which branch each invoice went to.
    expect(find.text('All Seasons Park'), findsWidgets);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Unassigned'));
    await tester.pumpAndSettle();
    expect(repo.invoiceBranches, [null, B2bRepository.unassignedBranch]);
  });

  testWidgets('merge defaults to folding the picked account in; swap flips', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = _FakeRepo();
    await tester.pumpWidget(
      _app(repo, const B2bAccountScreen(doctype: 'Customer', name: 'ILO-1')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add another account as a branch…'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ILO Zayed'));
    await tester.pumpAndSettle();

    // Picked = source, current = target.
    expect(repo.previews, ['CRM-LEAD-2>ILO-1']);
    expect(
      find.text('ILO Zayed will become a branch of ILO Specialty Coffee.'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextField, 'ILO Zayed'),
      findsOneWidget,
      reason: 'branch name is prefilled with the source title',
    );
    expect(find.textContaining('cannot be undone'), findsOneWidget);
    expect(find.text('unknown_code'), findsNothing);
    final confirm = find.widgetWithText(FilledButton, 'Merge');
    expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);

    await tester.tap(find.text('Keep ILO Zayed instead'));
    await tester.pumpAndSettle();
    expect(repo.previews, ['CRM-LEAD-2>ILO-1', 'ILO-1>CRM-LEAD-2']);
    expect(
      find.text('ILO Specialty Coffee will become a branch of ILO Zayed.'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextField, 'ILO Specialty Coffee'),
      findsOneWidget,
    );
  });

  testWidgets('server blockers are listed and keep confirm disabled', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = _FakeRepo()
      ..blockers = const [
        "'ILO Zayed' cannot be merged: it is the default customer of a POS "
            'Profile.',
      ];
    await tester.pumpWidget(
      _app(repo, const B2bAccountScreen(doctype: 'Customer', name: 'ILO-1')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add another account as a branch…'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ILO Zayed'));
    await tester.pumpAndSettle();

    expect(find.text('This merge can’t be done'), findsOneWidget);
    expect(find.textContaining('default customer of a POS'), findsOneWidget);
    // A blocker is not the manager-only refusal.
    expect(
      find.text('Only a manager can merge two customer accounts.'),
      findsNothing,
    );
    final confirm = find.widgetWithText(FilledButton, 'Merge');
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
  });

  group('unified branches', () {
    const unified = [
      B2bBranch(
        addressName: 'ILO-MADINATY',
        branchName: 'All Seasons Park',
        invoiceCount: 3,
        totalBilled: 4500,
        maps: B2bMapsInfo(
          row: 'a1',
          branchName: 'ILO Madinaty',
          area: 'Madinaty',
          rating: 4.6,
          reviews: 312,
        ),
        mapsMatch: 'auto',
      ),
      B2bBranch(addressName: 'ILO-ZAYED', branchName: 'Zayed'),
      B2bBranch(
        branchName: 'ILO Maadi',
        source: 'maps',
        maps: B2bMapsInfo(
          row: 'd4',
          branchName: 'ILO Maadi',
          area: 'Maadi',
          rating: 4.1,
          reviews: 20,
          latitude: 29.96,
          longitude: 31.25,
        ),
      ),
    ];

    void bigScreen(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
    }

    testWidgets('lists every door once, maps-only entries last', (
      tester,
    ) async {
      bigScreen(tester);
      final repo = _FakeRepo()..branches = unified;
      await tester.pumpWidget(
        _app(repo, const B2bAccountScreen(doctype: 'Customer', name: 'ILO-1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Branches (3)'), findsOneWidget);
      expect(find.text('Matched automatically'), findsOneWidget);
      expect(find.text('4.6 (312)'), findsOneWidget);
      expect(find.text('ILO Maadi'), findsOneWidget);
      expect(
        find.text('On Google Maps — not a delivery branch yet'),
        findsOneWidget,
      );
      // The maps-only entry has a pin; the auto-matched branch has none.
      expect(find.byTooltip('Open on map'), findsOneWidget);

      // Tapping a maps-only entry opens no invoice list.
      await tester.tap(find.text('ILO Maadi'));
      await tester.pumpAndSettle();
      expect(find.byType(B2bBranchInvoicesScreen), findsNothing);
      expect(repo.invoiceBranches, isEmpty);
    });

    testWidgets('"Same as an existing branch" links the maps row', (
      tester,
    ) async {
      bigScreen(tester);
      final repo = _FakeRepo()..branches = unified;
      await tester.pumpWidget(
        _app(repo, const B2bAccountScreen(doctype: 'Customer', name: 'ILO-1')),
      );
      await tester.pumpAndSettle();

      // Menus: "Unlink" on the matched branch, "Link" on Zayed, and the
      // maps-only entry's own actions.
      final menus = find.byTooltip('Branch actions');
      expect(menus, findsNWidgets(3));
      await tester.tap(menus.last);
      await tester.pumpAndSettle();
      expect(find.text('Make it a delivery branch'), findsOneWidget);
      await tester.tap(find.text('Same as an existing branch…'));
      await tester.pumpAndSettle();

      // Only the delivery branch without a Maps listing is offered.
      expect(find.text('Which delivery branch is this?'), findsOneWidget);
      final picker = find.byType(SimpleDialog);
      expect(
        find.descendant(of: picker, matching: find.text('Zayed')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: picker, matching: find.text('All Seasons Park')),
        findsNothing,
      );
      await tester.tap(
        find.descendant(of: picker, matching: find.text('Zayed')),
      );
      await tester.pumpAndSettle();

      expect(repo.links, ['d4>ILO-ZAYED']);
      // Updated in place: the maps-only entry is folded into Zayed.
      expect(find.text('Branches (2)'), findsOneWidget);
      expect(find.text('Linked to Google Maps'), findsOneWidget);
      expect(
        find.text('On Google Maps — not a delivery branch yet'),
        findsNothing,
      );
    });

    testWidgets('"Link a Google Maps branch" picks among maps-only entries', (
      tester,
    ) async {
      bigScreen(tester);
      final repo = _FakeRepo()..branches = unified;
      await tester.pumpWidget(
        _app(repo, const B2bAccountScreen(doctype: 'Customer', name: 'ILO-1')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Branch actions').at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Link a Google Maps branch'));
      await tester.pumpAndSettle();
      final picker = find.byType(SimpleDialog);
      await tester.tap(
        find.descendant(of: picker, matching: find.text('ILO Maadi')),
      );
      await tester.pumpAndSettle();
      expect(repo.links, ['d4>ILO-ZAYED']);
    });

    testWidgets('unlink sends an empty address', (tester) async {
      bigScreen(tester);
      final repo = _FakeRepo()..branches = unified;
      await tester.pumpWidget(
        _app(repo, const B2bAccountScreen(doctype: 'Customer', name: 'ILO-1')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Branch actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unlink Google Maps branch'));
      await tester.pumpAndSettle();
      expect(repo.links, ['a1>']);
      expect(find.text('Matched automatically'), findsNothing);
      expect(find.text('Branches (4)'), findsOneWidget);
    });

    testWidgets('an account with no customer still sees its Maps branches', (
      tester,
    ) async {
      bigScreen(tester);
      final repo = _FakeRepo()
        ..customer = null
        ..branches = [unified.last];
      await tester.pumpWidget(
        _app(
          repo,
          const B2bAccountScreen(doctype: 'Opportunity', name: 'CRM-OPP-1'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Branches (1)'), findsOneWidget);
      expect(find.text('ILO Maadi'), findsOneWidget);
      // No Customer: no delivery branch can be added or made, and there is no
      // delivery branch to combine with.
      expect(find.text('Add branch'), findsNothing);
      expect(find.byTooltip('Branch actions'), findsNothing);
    });

    test('invoice screen gets only the delivery branches', () {
      const account = B2bAccount(
        doctype: 'Customer',
        name: 'ILO-1',
        title: 'ILO',
        branches: unified,
      );
      expect(account.deliveryBranches.map((b) => b.key), [
        'ILO-MADINATY',
        'ILO-ZAYED',
      ]);
    });
  });
}
