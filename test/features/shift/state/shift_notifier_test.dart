import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/shift/models/shift_models.dart';
import 'package:jarz_pos/src/features/shift/data/shift_repository.dart';
import 'package:jarz_pos/src/features/shift/state/shift_notifier.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import '../../../helpers/mock_services.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  group('ShiftNotifier', () {
    late MockDio mockDio;
    late ShiftRepository repo;
    late ShiftNotifier notifier;

    setUp(() {
      mockDio = MockDio();
      repo = ShiftRepository(mockDio);
      notifier = ShiftNotifier(repo);
    });

    // ── checkActiveShift ──────────────────────────────────────────────

    group('checkActiveShift', () {
      test('sets activeShift when shift exists', () async {
        mockDio.setResponse(
          ApiEndpoints.getActiveShift,
          createSuccessResponse(data: {
            'name': 'POS-OPN-001',
            'pos_profile': 'Main',
            'status': 'Open',
            'user': 'user@test.com',
          }),
        );

        final result = await notifier.checkActiveShift();

        expect(result, isNotNull);
        expect(result!.name, 'POS-OPN-001');
        expect(notifier.state.activeShift?.name, 'POS-OPN-001');
        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, isNull);
      });

      test('sets activeShift to null when no shift', () async {
        mockDio.setResponse(
          ApiEndpoints.getActiveShift,
          createSuccessResponse(data: null),
        );

        final result = await notifier.checkActiveShift();

        expect(result, isNull);
        expect(notifier.state.activeShift, isNull);
        expect(notifier.state.isLoading, false);
      });

      test('sets error on failure', () async {
        mockDio.setError(
          ApiEndpoints.getActiveShift,
          createMockDioException(message: 'network fail'),
        );

        final result = await notifier.checkActiveShift();

        expect(result, isNull);
        expect(notifier.state.error, isNotNull);
        expect(notifier.state.isLoading, false);
      });

      test('sets isLoading during request', () async {
        // We can only verify isLoading is false after the call completes.
        mockDio.setResponse(
          ApiEndpoints.getActiveShift,
          createSuccessResponse(data: null),
        );

        await notifier.checkActiveShift();
        expect(notifier.state.isLoading, false);
      });
    });

    // ── loadPaymentMethods ────────────────────────────────────────────

    group('loadPaymentMethods', () {
      test('populates paymentMethods and profile name', () async {
        mockDio.setResponse(
          ApiEndpoints.getShiftPaymentMethods,
          createSuccessResponse(data: [
            {'mode_of_payment': 'Cash', 'default': 1},
            {'mode_of_payment': 'Card', 'default': 0},
          ]),
        );

        await notifier.loadPaymentMethods('Main');

        expect(notifier.state.paymentMethods, hasLength(2));
        expect(notifier.state.paymentMethodsProfile, 'Main');
        expect(notifier.state.isLoading, false);
      });

      test('sets error on failure', () async {
        mockDio.setError(
          ApiEndpoints.getShiftPaymentMethods,
          createMockDioException(
            statusCode: 500,
            data: {'message': 'fail'},
          ),
        );

        await notifier.loadPaymentMethods('X');

        expect(notifier.state.error, isNotNull);
        expect(notifier.state.isLoading, false);
      });
    });

    // ── startShift ────────────────────────────────────────────────────

    group('startShift', () {
      test('returns opening entry and refreshes active shift', () async {
        // startShift calls two endpoints: startShift then getActiveShift
        mockDio.setResponse(
          ApiEndpoints.startShift,
          createSuccessResponse(data: {'opening_entry': 'POS-OPN-099'}),
        );
        mockDio.setResponse(
          ApiEndpoints.getActiveShift,
          createSuccessResponse(data: {
            'name': 'POS-OPN-099',
            'pos_profile': 'Main',
            'status': 'Open',
          }),
        );

        final entry = await notifier.startShift(
          posProfile: 'Main',
          openingBalances: [
            {'mode_of_payment': 'Cash', 'opening_amount': 500},
          ],
        );

        expect(entry, 'POS-OPN-099');
        expect(notifier.state.activeShift?.name, 'POS-OPN-099');
        expect(notifier.state.isLoading, false);
      });

      test('returns null and sets error on failure', () async {
        mockDio.setError(
          ApiEndpoints.startShift,
          createMockDioException(
            statusCode: 417,
            data: {'message': 'Shift already open'},
          ),
        );

        final entry = await notifier.startShift(
          posProfile: 'Main',
          openingBalances: [],
        );

        expect(entry, isNull);
        expect(notifier.state.error, isNotNull);
        expect(notifier.state.isLoading, false);
      });
    });

    // ── endShift ──────────────────────────────────────────────────────

    group('endShift', () {
      test('clears active shift and returns summary', () async {
        // First set an active shift in state.
        mockDio.setResponse(
          ApiEndpoints.getActiveShift,
          createSuccessResponse(data: {
            'name': 'POS-OPN-001',
            'pos_profile': 'Main',
            'status': 'Open',
          }),
        );
        await notifier.checkActiveShift();
        expect(notifier.state.activeShift, isNotNull);

        mockDio.setResponse(
          ApiEndpoints.endShift,
          createSuccessResponse(data: {
            'opening_entry': 'POS-OPN-001',
            'status': 'Closed',
            'closing_entry': 'POS-CL-001',
          }),
        );

        final summary = await notifier.endShift(
          closingBalances: [
            {'mode_of_payment': 'Cash', 'closing_amount': 2000},
          ],
        );

        expect(summary, isNotNull);
        expect(summary!.status, 'Closed');
        expect(notifier.state.activeShift, isNull);
        expect(notifier.state.isLoading, false);
      });

      test('returns null when no active shift', () async {
        // No active shift set.
        mockDio.setResponse(
          ApiEndpoints.getActiveShift,
          createSuccessResponse(data: null),
        );

        final summary = await notifier.endShift(closingBalances: []);
        expect(summary, isNull);
      });

      test('sets error on API failure', () async {
        mockDio.setResponse(
          ApiEndpoints.getActiveShift,
          createSuccessResponse(data: {
            'name': 'POS-OPN-001',
            'pos_profile': 'Main',
            'status': 'Open',
          }),
        );
        await notifier.checkActiveShift();

        mockDio.setError(
          ApiEndpoints.endShift,
          createMockDioException(
            statusCode: 500,
            data: {'message': 'Cannot close shift with pending invoices'},
          ),
        );

        final summary = await notifier.endShift(closingBalances: []);

        expect(summary, isNull);
        expect(notifier.state.error, isNotNull);
        expect(notifier.state.isLoading, false);
      });
    });

    // ── getCurrentShiftSummary ────────────────────────────────────────

    group('getCurrentShiftSummary', () {
      test('fetches summary for active shift', () async {
        mockDio.setResponse(
          ApiEndpoints.getActiveShift,
          createSuccessResponse(data: {
            'name': 'POS-OPN-001',
            'pos_profile': 'Main',
            'status': 'Open',
          }),
        );
        await notifier.checkActiveShift();

        mockDio.setResponse(
          ApiEndpoints.getShiftSummary,
          createSuccessResponse(data: {
            'opening_entry': 'POS-OPN-001',
            'status': 'Open',
            'invoice_count': 5,
            'grand_total': 2000,
          }),
        );

        final summary = await notifier.getCurrentShiftSummary();

        expect(summary, isNotNull);
        expect(summary!.invoiceCount, 5);
      });

      test('returns null when no active shift', () async {
        mockDio.setResponse(
          ApiEndpoints.getActiveShift,
          createSuccessResponse(data: null),
        );

        final summary = await notifier.getCurrentShiftSummary();
        expect(summary, isNull);
      });
    });

    // ── ShiftState.copyWith ──────────────────────────────────────────

    group('ShiftState.copyWith', () {
      test('clears activeShift with clearActiveShift flag', () {
        final state = ShiftState(
          activeShift: ShiftEntry.fromJson({
            'name': 'E1',
            'pos_profile': 'P1',
            'status': 'Open',
          }),
        );

        final cleared = state.copyWith(clearActiveShift: true);
        expect(cleared.activeShift, isNull);
      });

      test('clears error with clearError flag', () {
        const state = ShiftState(error: 'something bad');
        final cleared = state.copyWith(clearError: true);
        expect(cleared.error, isNull);
      });

      test('preserves existing values when not overridden', () {
        const state = ShiftState(
          isLoading: true,
          error: 'err',
          paymentMethods: [{'mode_of_payment': 'Cash'}],
        );

        final updated = state.copyWith(isLoading: false);

        expect(updated.isLoading, false);
        expect(updated.error, 'err');
        expect(updated.paymentMethods, hasLength(1));
      });
    });
  });
}
