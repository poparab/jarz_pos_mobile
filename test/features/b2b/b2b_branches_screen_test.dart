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
        customer: 'ILO-1',
        branches: _branches,
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
}
