import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/reports/data/customer_segments_repository.dart';
import 'package:jarz_pos/src/features/reports/data/models/customer_segments.dart';
import 'package:jarz_pos/src/features/reports/data/models/report_json.dart';
import 'package:jarz_pos/src/features/reports/presentation/screens/customer_segments_screen.dart';

class _FakeCustomerSegmentsRepository implements CustomerSegmentsRepository {
  _FakeCustomerSegmentsRepository(this.summary, {this.customers = const []});
  final List<SegmentSummaryRow> summary;
  final List<JsonMap> customers;

  @override
  Future<List<SegmentSummaryRow>> fetchSegmentSummary() async => summary;

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
  }) async {}
}

Future<void> _pump(
  WidgetTester tester,
  List<SegmentSummaryRow> summary, {
  List<JsonMap> customers = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerSegmentsRepositoryProvider.overrideWithValue(
          _FakeCustomerSegmentsRepository(summary, customers: customers),
        ),
        userRolesFutureProvider.overrideWith(
          (ref) async => const UserRoles(
            user: 'manager@jarz.pos',
            roles: ['JARZ Manager'],
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CustomerSegmentsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders segment counts and the total customers KPI',
      (tester) async {
    await _pump(tester, const [
      SegmentSummaryRow(segment: 'Champion', count: 12),
      SegmentSummaryRow(segment: 'Loyal', count: 30),
    ]);

    expect(find.text('Customer Segments'), findsOneWidget);
    expect(find.text('Champion'), findsOneWidget);
    expect(find.text('Loyal'), findsOneWidget);
    expect(find.text('Total Customers'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.byIcon(Icons.autorenew), findsOneWidget);
  });

  testWidgets('tapping a segment drills into its customer list',
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
    expect(find.byIcon(Icons.copy_all_outlined), findsOneWidget);
  });
}
