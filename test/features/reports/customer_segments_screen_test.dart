import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/reports/data/customer_segments_repository.dart';
import 'package:jarz_pos/src/features/reports/data/models/customer_analytics.dart';
import 'package:jarz_pos/src/features/reports/data/models/customer_segments.dart';
import 'package:jarz_pos/src/features/reports/data/models/report_envelopes.dart';
import 'package:jarz_pos/src/features/reports/data/models/report_json.dart';
import 'package:jarz_pos/src/features/reports/presentation/screens/customer_analytics_screen.dart';
import 'package:jarz_pos/src/features/reports/state/reports_providers.dart';

class _OverrideCall {
  _OverrideCall(this.customer, this.override, this.manualSegment);
  final String customer;
  final bool override;
  final String? manualSegment;
}

class _FakeCustomerSegmentsRepository implements CustomerSegmentsRepository {
  _FakeCustomerSegmentsRepository({this.customers = const []});
  final List<JsonMap> customers;
  final calls = <_OverrideCall>[];

  @override
  Future<List<SegmentSummaryRow>> fetchSegmentSummary() async => const [];

  @override
  Future<List<JsonMap>> exportSegment(String segment) async => customers;

  @override
  Future<Map<String, dynamic>> runSegmentationNow() async =>
      {'updated': 0, 'skipped_override': 0, 'total_customers': 0};

  @override
  Future<void> setSegmentOverride({
    required String customer,
    required bool override,
    String? manualSegment,
  }) async {
    calls.add(_OverrideCall(customer, override, manualSegment));
  }
}

Future<_FakeCustomerSegmentsRepository> _pump(
  WidgetTester tester,
  List<SegmentSummaryRow> summary, {
  List<JsonMap> customers = const [],
}) async {
  final view = tester.view;
  view.physicalSize = const Size(400 * 2, 2400 * 2);
  view.devicePixelRatio = 2;
  addTearDown(view.resetPhysicalSize);
  addTearDown(view.resetDevicePixelRatio);

  final repo = _FakeCustomerSegmentsRepository(customers: customers);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerSegmentsRepositoryProvider.overrideWithValue(repo),
        customerReportProvider.overrideWith(
          (ref, query) => CustomerReport(
            data: CustomerAnalytics.fromJson(const {}),
            segmentsSummary: summary,
          ),
        ),
        reportBranchesProvider.overrideWith((ref) => const []),
        userRolesFutureProvider.overrideWith(
          (ref) async => const UserRoles(
            user: 'manager@jarz.pos',
            roles: ['JARZ Manager'],
          ),
        ),
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
        home: CustomerAnalyticsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  group('pin helpers', () {
    test('pseudo segments are recognised case-insensitively', () {
      expect(isPseudoSegment('Regular'), isTrue);
      expect(isPseudoSegment(' regulars '), isTrue);
      expect(isPseudoSegment('Loyal'), isFalse);
      expect(isPseudoSegment(null), isFalse);
      expect(isPseudoSegment('VIP', pseudoSegments: const ['VIP']), isTrue);
    });

    test('a pin never sends a pseudo or blank segment', () {
      expect(manualSegmentForPin('Loyal'), 'Loyal');
      expect(manualSegmentForPin('Regular'), isNull);
      expect(manualSegmentForPin(''), isNull);
      expect(manualSegmentForPin(null), isNull);
    });
  });

  testWidgets('Customers report lists segments; pseudo rows stay out of the '
      'total', (tester) async {
    await _pump(tester, [
      const SegmentSummaryRow(segment: 'Champion', count: 12),
      const SegmentSummaryRow(segment: 'Loyal', count: 30),
      SegmentSummaryRow.fromJson(
        const {'segment': 'Regular', 'count': 7, 'pseudo': 1},
      ),
    ]);

    expect(find.text('Customers & segments'), findsOneWidget);
    expect(find.text('Champion'), findsOneWidget);
    expect(find.text('Loyal'), findsOneWidget);
    expect(find.text('Regulars'), findsOneWidget);
    expect(find.text('Overlay'), findsOneWidget);
    expect(find.text('Total Customers: 42'), findsOneWidget);
    // Manager tier: recalculate and export are offered.
    expect(find.byIcon(Icons.autorenew), findsOneWidget);
    expect(find.byIcon(Icons.ios_share), findsOneWidget);
  });

  testWidgets('a segment drills into its customers, with CSV export',
      (tester) async {
    await _pump(
      tester,
      const [SegmentSummaryRow(segment: 'Champion', count: 1)],
      customers: [
        {
          'customer_id': 'CUST-1',
          'customer_name': 'Alice Store',
          'mobile_no': '0100',
          'territory': 'Cairo',
          'customer_segment': 'Champion',
          'rfm_recency_days': 3,
          'rfm_frequency_count': 8,
          'rfm_avg_order_value': 250.5,
        },
      ],
    );

    await tester.tap(find.text('Champion'));
    await tester.pumpAndSettle();

    expect(find.text('Alice Store'), findsOneWidget);
    expect(find.byIcon(Icons.ios_share), findsOneWidget);
    expect(find.byIcon(Icons.copy_all_outlined), findsNothing);
  });

  testWidgets('pinning from the Regular overlay sends the real RFM segment',
      (tester) async {
    final repo = await _pump(
      tester,
      [
        SegmentSummaryRow.fromJson(
          const {'segment': 'Regular', 'count': 1, 'pseudo': 1},
        ),
      ],
      customers: [
        {
          'customer_id': 'CUST-9',
          'customer_name': 'Regular Joe',
          'customer_segment': 'Loyal',
        },
      ],
    );

    await tester.tap(find.text('Regulars'));
    await tester.pumpAndSettle();
    expect(find.text('Regular Joe'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pin segment').last);
    await tester.pumpAndSettle();
    // Confirm dialog.
    await tester.tap(find.widgetWithText(FilledButton, 'Pin segment'));
    await tester.pumpAndSettle();

    expect(repo.calls, hasLength(1));
    expect(repo.calls.single.customer, 'CUST-9');
    expect(repo.calls.single.override, isTrue);
    expect(repo.calls.single.manualSegment, 'Loyal');
  });
}
