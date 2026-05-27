import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/shift/data/shift_repository.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import '../../../helpers/mock_services.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  group('ShiftRepository', () {
    late MockDio mockDio;
    late ShiftRepository repo;

    setUp(() {
      mockDio = MockDio();
      repo = ShiftRepository(mockDio);
    });

    // ── getActiveShift ────────────────────────────────────────────────

    group('getActiveShift', () {
      test('returns ShiftEntry when API returns valid map', () async {
        mockDio.setResponse(
          ApiEndpoints.getActiveShift,
          createSuccessResponse(data: {
            'name': 'POS-OPN-2024-00001',
            'pos_profile': 'Main Store',
            'status': 'Open',
            'user': 'user@test.com',
            'employee_name': 'Test User',
            'period_start_date': '2024-01-15 08:00:00',
            'balance_details': [
              {
                'mode_of_payment': 'Cash',
                'opening_amount': 1000,
                'expected_amount': 1500,
                'closing_amount': 0,
                'difference': 0,
              }
            ],
          }),
        );

        final result = await repo.getActiveShift();

        expect(result, isNotNull);
        expect(result!.name, 'POS-OPN-2024-00001');
        expect(result.posProfile, 'Main Store');
        expect(result.status, 'Open');
        expect(result.openedByUser, 'user@test.com');
        expect(result.openedByName, 'Test User');
        expect(result.balanceDetails, hasLength(1));
        expect(result.balanceDetails.first.modeOfPayment, 'Cash');
        expect(result.balanceDetails.first.openingAmount, 1000);
      });

      test('returns null when API returns null message', () async {
        mockDio.setResponse(
          ApiEndpoints.getActiveShift,
          createSuccessResponse(data: null),
        );

        final result = await repo.getActiveShift();
        expect(result, isNull);
      });

      test('returns null when API returns non-map message', () async {
        mockDio.setResponse(
          ApiEndpoints.getActiveShift,
          createSuccessResponse(data: 'no shift'),
        );

        final result = await repo.getActiveShift();
        expect(result, isNull);
      });

      test('request is POST with empty body', () async {
        mockDio.setResponse(
          ApiEndpoints.getActiveShift,
          createSuccessResponse(data: null),
        );

        await repo.getActiveShift();

        expect(mockDio.requestLog, hasLength(1));
        expect(mockDio.requestLog.first['method'], 'POST');
        expect(mockDio.requestLog.first['data'], equals({}));
      });
    });

    // ── getShiftPaymentMethods ────────────────────────────────────────

    group('getShiftPaymentMethods', () {
      test('returns list of payment method maps', () async {
        mockDio.setResponse(
          ApiEndpoints.getShiftPaymentMethods,
          createSuccessResponse(data: [
            {'mode_of_payment': 'Cash', 'amounts_hidden': 1},
            {'mode_of_payment': 'Card', 'default': 0},
          ]),
        );

        final result = await repo.getShiftPaymentMethods('Main Store');

        expect(result, hasLength(2));
        expect(result[0]['mode_of_payment'], 'Cash');
        expect(result[0]['amounts_hidden'], 1);
        expect(result[1]['mode_of_payment'], 'Card');
      });

      test('returns empty list when message is not a list', () async {
        mockDio.setResponse(
          ApiEndpoints.getShiftPaymentMethods,
          createSuccessResponse(data: null),
        );

        final result = await repo.getShiftPaymentMethods('Main Store');
        expect(result, isEmpty);
      });

      test('sends pos_profile in request body', () async {
        mockDio.setResponse(
          ApiEndpoints.getShiftPaymentMethods,
          createSuccessResponse(data: []),
        );

        await repo.getShiftPaymentMethods('Branch A');

        final req = mockDio.requestLog.first;
        expect(req['data'], containsPair('pos_profile', 'Branch A'));
      });

      test('maps DioException via _mapApiException', () async {
        mockDio.setError(
          ApiEndpoints.getShiftPaymentMethods,
          createMockDioException(
            statusCode: 500,
            data: {'message': 'Server overloaded'},
          ),
        );

        expect(
          () => repo.getShiftPaymentMethods('X'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Server overloaded'),
          )),
        );
      });

      test('extracts exception field when message is null', () async {
        mockDio.setError(
          ApiEndpoints.getShiftPaymentMethods,
          createMockDioException(
            statusCode: 403,
            data: {'exception': 'frappe.exceptions.PermissionError'},
          ),
        );

        expect(
          () => repo.getShiftPaymentMethods('X'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'exception field',
            contains('PermissionError'),
          )),
        );
      });
    });

    // ── startShift ────────────────────────────────────────────────────

    group('startShift', () {
      test('returns opening_entry on success', () async {
        mockDio.setResponse(
          ApiEndpoints.startShift,
          createSuccessResponse(data: {
            'opening_entry': 'POS-OPN-2024-00099',
          }),
        );

        final result = await repo.startShift(
          posProfile: 'Main Store',
          openingBalances: [
            {'mode_of_payment': 'Cash', 'opening_amount': 500},
          ],
        );

        expect(result, 'POS-OPN-2024-00099');
      });

      test('sends correct payload', () async {
        final balances = [
          {'mode_of_payment': 'Cash', 'opening_amount': 500},
          {'mode_of_payment': 'Card', 'opening_amount': 0},
        ];

        mockDio.setResponse(
          ApiEndpoints.startShift,
          createSuccessResponse(data: {'opening_entry': 'E1'}),
        );

        await repo.startShift(
          posProfile: 'Branch B',
          openingBalances: balances,
        );

        final req = mockDio.requestLog.first;
        expect(req['data']['pos_profile'], 'Branch B');
        expect(req['data']['opening_balances'], equals(balances));
      });

      test('throws when opening_entry missing from response', () async {
        mockDio.setResponse(
          ApiEndpoints.startShift,
          createSuccessResponse(data: {'status': 'ok'}),
        );

        expect(
          () => repo.startShift(
            posProfile: 'X',
            openingBalances: [],
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws mapped exception on DioError', () async {
        mockDio.setError(
          ApiEndpoints.startShift,
          createMockDioException(
            statusCode: 417,
            data: {'_server_messages': '["Shift already open"]'},
          ),
        );

        expect(
          () => repo.startShift(posProfile: 'X', openingBalances: []),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'server message',
            contains('Shift already open'),
          )),
        );
      });
    });

    // ── getShiftSummary ───────────────────────────────────────────────

    group('getShiftSummary', () {
      test('returns ShiftSummary on valid response', () async {
        mockDio.setResponse(
          ApiEndpoints.getShiftSummary,
          createSuccessResponse(data: {
            'opening_entry': 'POS-OPN-001',
            'status': 'Open',
            'invoice_count': 12,
            'grand_total': 5400.50,
            'net_total': 5000,
            'payment_reconciliation': [
              {
                'mode_of_payment': 'Cash',
                'opening_amount': 500,
                'expected_amount': 5500,
                'closing_amount': 0,
                'difference': 0,
              },
            ],
            'sales_invoices': [
              {
                'name': 'INV-001',
                'customer': 'CUST-001',
                'customer_name': 'Test Customer',
                'grand_total': 100,
              },
            ],
            'account_movements': [],
            'account': 'Cash - JRZ',
            'account_balance': 10000,
            'total_sales': 5400.50,
            'total_outflows': 200,
            'net_movement': 5200.50,
            'amounts_hidden': 0,
            'variance_visible': 1,
          }),
        );

        final summary = await repo.getShiftSummary('POS-OPN-001');

        expect(summary.openingEntry, 'POS-OPN-001');
        expect(summary.status, 'Open');
        expect(summary.invoiceCount, 12);
        expect(summary.grandTotal, 5400.50);
        expect(summary.paymentReconciliation, hasLength(1));
        expect(summary.salesInvoices, hasLength(1));
        expect(summary.salesInvoices.first.name, 'INV-001');
        expect(summary.account, 'Cash - JRZ');
        expect(summary.totalSales, 5400.50);
        expect(summary.netMovement, 5200.50);
        expect(summary.amountsHidden, isFalse);
        expect(summary.varianceVisible, isTrue);
      });

      test('parses blind pre-close summary without exposed money fields', () async {
        mockDio.setResponse(
          ApiEndpoints.getShiftSummary,
          createSuccessResponse(data: {
            'opening_entry': 'POS-OPN-001',
            'status': 'Open',
            'invoice_count': 2,
            'amounts_hidden': 1,
            'variance_visible': 0,
            'payment_reconciliation': [
              {
                'mode_of_payment': 'Cash',
              },
            ],
            'sales_invoices': [],
          }),
        );

        final summary = await repo.getShiftSummary('POS-OPN-001');

        expect(summary.openingEntry, 'POS-OPN-001');
        expect(summary.amountsHidden, isTrue);
        expect(summary.varianceVisible, isFalse);
        expect(summary.paymentReconciliation, hasLength(1));
        expect(summary.paymentReconciliation.first.modeOfPayment, 'Cash');
        expect(summary.paymentReconciliation.first.expectedAmount, 0);
        expect(summary.totalSales, 0);
      });

      test('sends pos_opening_entry in body', () async {
        mockDio.setResponse(
          ApiEndpoints.getShiftSummary,
          createSuccessResponse(data: {
            'opening_entry': 'E1',
            'status': 'Open',
          }),
        );

        await repo.getShiftSummary('E1');

        final req = mockDio.requestLog.first;
        expect(req['data'], containsPair('pos_opening_entry', 'E1'));
      });

      test('throws when message is not a map', () async {
        mockDio.setResponse(
          ApiEndpoints.getShiftSummary,
          createSuccessResponse(data: 'bad'),
        );

        expect(() => repo.getShiftSummary('E1'), throwsA(isA<Exception>()));
      });
    });

    // ── endShift ──────────────────────────────────────────────────────

    group('endShift', () {
      test('returns ShiftSummary on success', () async {
        mockDio.setResponse(
          ApiEndpoints.endShift,
          createSuccessResponse(data: {
            'opening_entry': 'POS-OPN-001',
            'status': 'Closed',
            'invoice_count': 5,
            'grand_total': 2500,
            'net_total': 2300,
            'closing_entry': 'POS-CL-001',
          }),
        );

        final summary = await repo.endShift(
          openingEntry: 'POS-OPN-001',
          closingBalances: [
            {'mode_of_payment': 'Cash', 'closing_amount': 2500},
          ],
        );

        expect(summary.openingEntry, 'POS-OPN-001');
        expect(summary.status, 'Closed');
        expect(summary.closingEntry, 'POS-CL-001');
      });

      test('sends correct payload', () async {
        final closing = [
          {'mode_of_payment': 'Cash', 'closing_amount': 1000},
        ];

        mockDio.setResponse(
          ApiEndpoints.endShift,
          createSuccessResponse(data: {
            'opening_entry': 'E1',
            'status': 'Closed',
          }),
        );

        await repo.endShift(openingEntry: 'E1', closingBalances: closing);

        final req = mockDio.requestLog.first;
        expect(req['data']['pos_opening_entry'], 'E1');
        expect(req['data']['closing_balances'], equals(closing));
      });

      test('throws when message is not a map', () async {
        mockDio.setResponse(
          ApiEndpoints.endShift,
          createSuccessResponse(data: null),
        );

        expect(
          () =>
              repo.endShift(openingEntry: 'E1', closingBalances: []),
          throwsA(isA<Exception>()),
        );
      });

      test('maps backend close blocker into a clean exception', () async {
        mockDio.setError(
          ApiEndpoints.endShift,
          createMockDioException(
            path: ApiEndpoints.endShift,
            statusCode: 417,
            type: DioExceptionType.badResponse,
            message: 'DioException [bad response]: This exception was thrown because the response has a status code of 417.',
            data: {
              '_server_messages': '["{\\"message\\": \\"You still have 2 unsettled courier transaction(s) for 1 courier(s) across 1 invoice(s) on POS Profile Dokki. Settle courier balances before closing the shift.\\"}"]',
            },
          ),
        );

        expect(
          () => repo.endShift(
            openingEntry: 'E1',
            closingBalances: const [],
          ),
          throwsA(
            isA<Exception>()
                .having(
                  (e) => e.toString(),
                  'message',
                  contains('Settle courier balances before closing the shift'),
                )
                .having(
                  (e) => e.toString(),
                  'raw dio text removed',
                  isNot(contains('DioException')),
                ),
          ),
        );
      });
    });
  });
}
