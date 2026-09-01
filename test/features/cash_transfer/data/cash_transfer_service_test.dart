import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/cash_transfer/data/cash_transfer_service.dart';
import '../../../helpers/mock_services.dart';

void main() {
  group('CashTransferService', () {
    late MockDio mockDio;
    late CashTransferService service;

    setUp(() {
      mockDio = MockDio();
      service = CashTransferService(mockDio);
    });

    group('listAccounts', () {
      test('returns list of accounts when response contains message list', () async {
        final accounts = [
          {'name': 'Cash - Main', 'balance': 1000.0},
          {'name': 'Cash - Branch', 'balance': 500.0},
        ];
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.cash_transfer.list_accounts',
          {'message': accounts},
        );

        final result = await service.listAccounts();

        expect(result, hasLength(2));
        expect(result[0]['name'], equals('Cash - Main'));
        expect(result[1]['name'], equals('Cash - Branch'));
      });

      test('returns list when response is directly a list', () async {
        final accounts = [
          {'name': 'Account 1'},
          {'name': 'Account 2'},
        ];
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.cash_transfer.list_accounts',
          accounts,
        );

        final result = await service.listAccounts();

        expect(result, hasLength(2));
      });

      test('returns empty list when response format is unexpected', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.cash_transfer.list_accounts',
          {'unexpected': 'format'},
        );

        final result = await service.listAccounts();

        expect(result, isEmpty);
      });

      test('sends asOf parameter when provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.cash_transfer.list_accounts',
          {'message': []},
        );

        await service.listAccounts(asOf: '2025-05-01');

        final requests = mockDio.requestLog;
        expect(requests.first['data']['as_of'], equals('2025-05-01'));
      });

      test('sends company parameter when provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.cash_transfer.list_accounts',
          {'message': []},
        );

        await service.listAccounts(company: 'Test Company');

        final requests = mockDio.requestLog;
        expect(requests.first['data']['company'], equals('Test Company'));
      });

      test('sends both parameters when both provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.cash_transfer.list_accounts',
          {'message': []},
        );

        await service.listAccounts(asOf: '2025-05-01', company: 'Test Company');

        final requests = mockDio.requestLog;
        expect(requests.first['data']['as_of'], equals('2025-05-01'));
        expect(requests.first['data']['company'], equals('Test Company'));
      });
    });

    group('submitCashTransfer', () {
      test('submits cash transfer with required parameters', () async {
        final response = {'name': 'JE-001', 'status': 'Submitted'};
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.cash_transfer.submit_transfer',
          {'message': response},
        );

        final result = await service.submitCashTransfer(
          fromAccount: 'Cash - Main',
          toAccount: 'Cash - Branch',
          amount: 500.0,
        );

        expect(result['name'], equals('JE-001'));
        expect(result['status'], equals('Submitted'));
      });

      test('sends all parameters correctly', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.cash_transfer.submit_transfer',
          {'message': {}},
        );

        await service.submitCashTransfer(
          fromAccount: 'Cash - Main',
          toAccount: 'Cash - Branch',
          amount: 500.0,
          postingDate: '2025-05-01',
          remark: 'Test transfer',
        );

        final requests = mockDio.requestLog;
        final data = requests.first['data'];
        expect(data['from_account'], equals('Cash - Main'));
        expect(data['to_account'], equals('Cash - Branch'));
        expect(data['amount'], equals(500.0));
        expect(data['posting_date'], equals('2025-05-01'));
        expect(data['remark'], equals('Test transfer'));
      });

      test('handles response with direct map', () async {
        final response = {'name': 'JE-002', 'status': 'Draft'};
        
        mockDio.setResponse(
          '/api/method/jarz_pos.api.cash_transfer.submit_transfer',
          response,
        );

        final result = await service.submitCashTransfer(
          fromAccount: 'Cash - Main',
          toAccount: 'Cash - Branch',
          amount: 100.0,
        );

        expect(result['name'], equals('JE-002'));
      });

      test('throws exception on unexpected response format', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.cash_transfer.submit_transfer',
          'unexpected string response',
        );

        expect(
          () => service.submitCashTransfer(
            fromAccount: 'Cash - Main',
            toAccount: 'Cash - Branch',
            amount: 100.0,
          ),
          throwsException,
        );
      });

      test('omits optional parameters when not provided', () async {
        mockDio.setResponse(
          '/api/method/jarz_pos.api.cash_transfer.submit_transfer',
          {'message': {}},
        );

        await service.submitCashTransfer(
          fromAccount: 'Cash - Main',
          toAccount: 'Cash - Branch',
          amount: 250.0,
        );

        final requests = mockDio.requestLog;
        final data = requests.first['data'];
        expect(data.containsKey('posting_date'), isFalse);
        expect(data.containsKey('remark'), isFalse);
      });
    });

    group('listTransfers', () {
      const path = '/api/method/jarz_pos.api.cash_transfer.list_transfers';

      test('unwraps the rows and the filtered total', () async {
        mockDio.setResponse(path, {
          'message': {
            'transfers': [
              {
                'name': 'ACC-JV-0001',
                'from_account': 'Cash - J',
                'to_account': 'Bank Account - J',
                'amount': 500.0,
              },
            ],
            'total': 3,
          },
        });

        final result = await service.listTransfers();

        expect(result.transfers, hasLength(1));
        expect(result.transfers.first['from_account'], equals('Cash - J'));
        expect(result.total, equals(3));
      });

      test('returns nothing rather than throwing on an unexpected shape',
          () async {
        mockDio.setResponse(path, {'message': 'nope'});

        final result = await service.listTransfers();

        expect(result.transfers, isEmpty);
        expect(result.total, equals(0));
      });

      test('sends only the filters it is given', () async {
        mockDio.setResponse(path, {
          'message': {'transfers': [], 'total': 0},
        });

        await service.listTransfers(
          account: 'Cash - J',
          fromDate: '2026-01-01',
          search: '',
        );

        final data = mockDio.requestLog.first['data'] as Map;
        expect(data['account'], equals('Cash - J'));
        expect(data['from_date'], equals('2026-01-01'));
        expect(data.containsKey('to_date'), isFalse);
        expect(data.containsKey('search'), isFalse);
      });
    });
  });
}
