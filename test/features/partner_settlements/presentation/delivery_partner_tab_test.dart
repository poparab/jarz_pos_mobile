import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/partner_settlements/data/partner_settlements_service.dart';
import 'package:jarz_pos/src/features/partner_settlements/presentation/widgets/delivery_partner_tab.dart';

class _FakePartnerSettlementsService extends PartnerSettlementsService {
  _FakePartnerSettlementsService({
    this.balances = const [],
    this.trips = const [],
  }) : super(Dio());

  final List<Map<String, dynamic>> balances;
  final List<Map<String, dynamic>> trips;

  String? requestedDeliveryPartner;
  bool settleCalled = false;
  List<String>? settledTransactions;
  List<Map<String, dynamic>>? settledCharges;

  @override
  Future<List<Map<String, dynamic>>> getDeliveryPartnerBalances() async {
    return balances.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getDeliveryPartnerUnsettledDetails(
    String deliveryPartner,
  ) async {
    requestedDeliveryPartner = deliveryPartner;
    return trips.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<Map<String, dynamic>> settleDeliveryPartner({
    required String deliveryPartner,
    String? bankAccount,
    required List<String> courierTransactions,
    List<Map<String, dynamic>> extraCharges = const [],
  }) async {
    settleCalled = true;
    settledTransactions = courierTransactions;
    settledCharges = extraCharges;
    return {'success': true, 'journal_entry': 'ACC-JV-TEST'};
  }
}

Future<void> _pumpDeliveryTab(
  WidgetTester tester,
  _FakePartnerSettlementsService service,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        partnerSettlementsServiceProvider.overrideWithValue(service),
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
        home: Scaffold(body: DeliveryPartnerTab()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('DeliveryPartnerTab', () {
    testWidgets('renders a partner row with its unbilled total', (
      tester,
    ) async {
      final service = _FakePartnerSettlementsService(
        balances: const [
          {
            'delivery_partner': 'DP-001',
            'partner_name': 'Bosta',
            'order_count': 3,
            'total_fee': 150.0,
          },
        ],
      );

      await _pumpDeliveryTab(tester, service);

      expect(find.text('Bosta'), findsOneWidget);
      expect(find.textContaining('3 trips'), findsOneWidget);
    });

    testWidgets('shows the empty state when there is nothing unbilled', (
      tester,
    ) async {
      final service = _FakePartnerSettlementsService(balances: const []);

      await _pumpDeliveryTab(tester, service);

      expect(
        find.text('No unbilled delivery partner fees.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'blocks settling until at least one trip is ticked, then submits only the selected trip',
      (tester) async {
        final service = _FakePartnerSettlementsService(
          balances: const [
            {
              'delivery_partner': 'DP-001',
              'partner_name': 'Bosta',
              'order_count': 2,
              'total_fee': 70.0,
            },
          ],
          trips: const [
            {
              'name': 'CT-0001',
              'invoice': 'ACC-SINV-0001',
              'fee': 40.0,
              'date': '2026-09-01',
            },
            {
              'name': 'CT-0002',
              'invoice': 'ACC-SINV-0002',
              'fee': 30.0,
              'date': '2026-09-02',
            },
          ],
        );

        await _pumpDeliveryTab(tester, service);

        await tester.tap(find.text('Bosta'));
        await tester.pumpAndSettle();

        expect(service.requestedDeliveryPartner, equals('DP-001'));

        // Nothing ticked yet: the Settle button must be disabled.
        final settleButtonFinder = find.widgetWithText(
          ElevatedButton,
          'Settle',
        );
        expect(settleButtonFinder, findsOneWidget);
        ElevatedButton settleButton = tester.widget(settleButtonFinder);
        expect(settleButton.onPressed, isNull);

        // Tick the first trip only.
        await tester.tap(find.byKey(const ValueKey('CT-0001')));
        await tester.pumpAndSettle();

        settleButton = tester.widget(settleButtonFinder);
        expect(settleButton.onPressed, isNotNull);

        // The unticked-trips warning stays visible while CT-0002 is unselected.
        expect(
          find.textContaining('Unticked trips stay unbilled'),
          findsOneWidget,
        );

        await tester.tap(settleButtonFinder);
        await tester.pumpAndSettle();

        // Confirmation dialog appears before anything is posted.
        expect(find.text('Confirm bank transfer'), findsOneWidget);
        expect(service.settleCalled, isFalse);

        await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
        await tester.pumpAndSettle();

        expect(service.settleCalled, isTrue);
        expect(service.settledTransactions, equals(['CT-0001']));
      },
    );
  });
}
