import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/settlement_reversal/data/settlement_reversal_service.dart';

import '../../../helpers/mock_services.dart';

/// Mirrors the real Frappe wire shape: `_server_messages` is a JSON-encoded
/// list of JSON-encoded `{"message": ...}` objects.
Map<String, dynamic> _validationError(String message) => {
      '_server_messages': jsonEncode([
        jsonEncode({'message': message}),
      ]),
    };

void main() {
  group('SettlementReversalService', () {
    late MockDio mockDio;
    late SettlementReversalService service;

    setUp(() {
      mockDio = MockDio();
      service = SettlementReversalService(mockDio);
    });

    group('preview', () {
      test('parses transactions, account lines and the preview token', () async {
        mockDio.setResponse(ApiEndpoints.unsettlePreview, {
          'message': {
            'journal_entry': 'ACC-JV-0099',
            'preview_token': 'tok-abc123',
            'party_type': 'Supplier',
            'party': 'Ahmed Courier',
            'branch': 'Nasr City',
            'posting_date': '2026-09-01',
            'net_amount': 250.0,
            'transactions': [
              {'invoice': 'ACC-SINV-0001', 'amount': 100.0, 'city': 'Nasr City'},
              {'invoice': 'ACC-SINV-0002', 'amount': 150.0, 'city': 'Nasr City'},
            ],
            'account_lines': [
              {'account': 'Cash - J', 'debit': 250.0, 'credit': 0.0},
              {'account': 'Courier Payable - J', 'debit': 0.0, 'credit': 250.0},
            ],
          },
        });

        final preview = await service.preview(journalEntry: 'ACC-JV-0099');

        expect(preview.journalEntry, equals('ACC-JV-0099'));
        expect(preview.previewToken, equals('tok-abc123'));
        expect(preview.party, equals('Ahmed Courier'));
        expect(preview.branch, equals('Nasr City'));
        expect(preview.netAmount, equals(250.0));
        expect(preview.transactions, hasLength(2));
        expect(preview.transactions.first.invoice, equals('ACC-SINV-0001'));
        expect(preview.accountLines, hasLength(2));
        expect(preview.accountLines.first.debit, equals(250.0));
      });

      test('sends the journal_entry the caller asked to preview', () async {
        mockDio.setResponse(ApiEndpoints.unsettlePreview, {
          'message': {'journal_entry': 'ACC-JV-0005', 'preview_token': 'tok'},
        });

        await service.preview(journalEntry: 'ACC-JV-0005');

        final requests = mockDio.requestLog;
        expect(requests.first['data']['journal_entry'], equals('ACC-JV-0005'));
      });

      test('falls back to the requested journal entry when the response omits it', () async {
        mockDio.setResponse(ApiEndpoints.unsettlePreview, {
          'message': {'preview_token': 'tok', 'net_amount': 10},
        });

        final preview = await service.preview(journalEntry: 'ACC-JV-0007');

        expect(preview.journalEntry, equals('ACC-JV-0007'));
      });

      test('surfaces an already-reversed refusal as a clean message', () async {
        mockDio.setError(
          ApiEndpoints.unsettlePreview,
          createMockDioException(
            statusCode: 417,
            data: _validationError(
                'This settlement (ACC-JV-0099) has already been reversed.'),
          ),
        );

        await expectLater(
          () => service.preview(journalEntry: 'ACC-JV-0099'),
          throwsA(predicate((e) =>
              e is Exception &&
              e.toString().contains('already been reversed'))),
        );
      });

      test('surfaces a multi-branch refusal as a clean message', () async {
        mockDio.setError(
          ApiEndpoints.unsettlePreview,
          createMockDioException(
            statusCode: 417,
            data: _validationError(
                'This settlement spans more than one branch and cannot be reversed automatically.'),
          ),
        );

        await expectLater(
          () => service.preview(journalEntry: 'ACC-JV-0100'),
          throwsA(predicate((e) =>
              e is Exception &&
              e.toString().contains('more than one branch'))),
        );
      });

      test('never leaks a raw traceback to the UI', () async {
        mockDio.setError(
          ApiEndpoints.unsettlePreview,
          createMockDioException(
            statusCode: 500,
            data: 'Traceback (most recent call last):\n  File "x.py"\nKeyError: 42',
          ),
        );

        try {
          await service.preview(journalEntry: 'ACC-JV-0100');
          fail('expected an exception');
        } catch (e) {
          expect(e.toString().contains('Traceback'), isFalse);
          expect(e.toString().contains('KeyError'), isFalse);
        }
      });
    });

    group('commit', () {
      test('sends the journal_entry, preview_token and optional reason', () async {
        mockDio.setResponse(ApiEndpoints.unsettleCommit, {
          'message': {'success': true, 'journal_entry': 'ACC-JV-0200'},
        });

        await service.commit(
          journalEntry: 'ACC-JV-0099',
          previewToken: 'tok-abc123',
          reason: 'Settled from the wrong branch till',
        );

        final data = mockDio.requestLog.first['data'] as Map;
        expect(data['journal_entry'], equals('ACC-JV-0099'));
        expect(data['preview_token'], equals('tok-abc123'));
        expect(data['reason'], equals('Settled from the wrong branch till'));
      });

      test('omits reason when blank', () async {
        mockDio.setResponse(ApiEndpoints.unsettleCommit, {
          'message': {'success': true},
        });

        await service.commit(journalEntry: 'ACC-JV-0099', previewToken: 'tok', reason: '   ');

        final data = mockDio.requestLog.first['data'] as Map;
        expect(data.containsKey('reason'), isFalse);
      });

      test('returns the reversing journal entry on success', () async {
        mockDio.setResponse(ApiEndpoints.unsettleCommit, {
          'message': {'success': true, 'journal_entry': 'ACC-JV-0201'},
        });

        final result = await service.commit(journalEntry: 'ACC-JV-0099', previewToken: 'tok');

        expect(result['journal_entry'], equals('ACC-JV-0201'));
      });

      test('an expired or mismatched preview token surfaces a clean, actionable message',
          () async {
        mockDio.setError(
          ApiEndpoints.unsettleCommit,
          createMockDioException(
            statusCode: 417,
            data: _validationError('This preview has expired. Please try again.'),
          ),
        );

        await expectLater(
          () => service.commit(journalEntry: 'ACC-JV-0099', previewToken: 'stale-token'),
          throwsA(predicate((e) =>
              e is Exception && e.toString().contains('expired'))),
        );
      });

      test('already-reversed refusal on commit is a clean message too', () async {
        mockDio.setError(
          ApiEndpoints.unsettleCommit,
          createMockDioException(
            statusCode: 417,
            data: _validationError('This settlement has already been reversed.'),
          ),
        );

        await expectLater(
          () => service.commit(journalEntry: 'ACC-JV-0099', previewToken: 'tok'),
          throwsA(predicate((e) =>
              e is Exception && e.toString().contains('already been reversed'))),
        );
      });
    });
  });
}
