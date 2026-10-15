import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/reports/data/models/warehouse_alignment_row.dart';
import 'package:jarz_pos/src/features/reports/data/warehouse_alignment_service.dart';
import 'package:jarz_pos/src/features/reports/presentation/screens/warehouse_alignment_screen.dart';
import 'package:jarz_pos/src/features/reports/state/reports_providers.dart';

import '../../../../helpers/test_helpers.dart';

Future<void> _pump(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // The branch selector must not reach the network.
        reportBranchesProvider.overrideWith((ref) => const []),
        ...overrides,
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: WarehouseAlignmentScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  group('WarehouseAlignmentFilter', () {
    test('copyWith keeps the branch unless cleared', () {
      const f = WarehouseAlignmentFilter(branch: 'Maadi', limit: 50);
      expect(f.copyWith(limit: 25).branch, 'Maadi');
      expect(f.copyWith(branch: null).branch, 'Maadi');
      expect(f.copyWith(clearBranch: true).branch, isNull);
      expect(f.copyWith(clearBranch: true).limit, 50);
      expect(
        const WarehouseAlignmentFilter(branch: 'X')
            .copyWith(clearBranch: true),
        const WarehouseAlignmentFilter(),
      );
    });
  });

  group('WarehouseAlignmentScreen', () {
    testWidgets('renders expected vs actual side by side, read-only',
        (tester) async {
      const filter = WarehouseAlignmentFilter();
      await _pump(
        tester,
        overrides: [
          warehouseAlignmentReportProvider(filter).overrideWith(
            (ref) async => const [
              WarehouseAlignmentRow(
                name: 'ACC-SINV-2026-00042',
                customer: 'Ahmad',
                postingDate: '2026-09-01',
                amount: 350,
                operationalProfile: 'Nasr City',
                targetWarehouse: 'Nasr City - JB',
                actualWarehouses: ['Maadi - JB'],
                company: 'Jarz Bakery',
              ),
            ],
          ),
        ],
      );

      expect(find.text('Expected'), findsOneWidget);
      expect(find.text('Actual'), findsOneWidget);
      expect(find.text('Nasr City - JB'), findsOneWidget);
      expect(find.text('Maadi - JB'), findsOneWidget);
      expect(find.textContaining('Ahmad'), findsOneWidget);
      expect(find.text('Company: Jarz Bakery'), findsOneWidget);
      // Branch is the shared, clearable report selector.
      expect(find.text('All branches'), findsOneWidget);

      // Watchlist, not an action surface: no repair/fix affordance anywhere.
      expect(find.byIcon(Icons.build), findsNothing);
      expect(find.textContaining('Repair'), findsNothing);
      expect(find.textContaining('Fix'), findsNothing);
    });

    testWidgets('shows the empty state when there are no mismatches',
        (tester) async {
      const filter = WarehouseAlignmentFilter();
      await _pump(
        tester,
        overrides: [
          warehouseAlignmentReportProvider(filter)
              .overrideWith((ref) async => const []),
        ],
      );

      expect(find.text('No warehouse mismatches found'), findsOneWidget);
    });

    testWidgets('shows an error state with retry on failure', (tester) async {
      const filter = WarehouseAlignmentFilter();
      await _pump(
        tester,
        overrides: [
          warehouseAlignmentReportProvider(filter).overrideWith(
            (ref) async => throw Exception('boom'),
          ),
        ],
      );

      expect(find.text("Couldn't load report"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
