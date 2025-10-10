import 'package:flutter_test/flutter_test.dart';
import '../../helpers/mock_services.dart';

void main() {
  group('OfflineQueue', () {
    late MockOfflineQueue offlineQueue;

    setUp(() {
      offlineQueue = MockOfflineQueue();
    });

    test('initially has no pending transactions', () async {
      final count = await offlineQueue.getPendingCount();
      expect(count, equals(0));
    });

    test('can add transaction to queue', () async {
      await offlineQueue.addTransaction({
        'endpoint': '/api/test',
        'data': {'key': 'value'},
      });
      
      final count = await offlineQueue.getPendingCount();
      expect(count, equals(1));
    });

    test('getPendingTransactions returns all pending transactions', () async {
      await offlineQueue.addTransaction({
        'endpoint': '/api/test1',
        'data': {'test': 1},
      });
      await offlineQueue.addTransaction({
        'endpoint': '/api/test2',
        'data': {'test': 2},
      });
      
      final transactions = await offlineQueue.getPendingTransactions();
      expect(transactions, hasLength(2));
      expect(transactions[0]['status'], equals('pending'));
      expect(transactions[1]['status'], equals('pending'));
    });

    test('markAsProcessed updates transaction status', () async {
      await offlineQueue.addTransaction({
        'endpoint': '/api/test',
        'data': {'key': 'value'},
      });
      
      final transactions = await offlineQueue.getPendingTransactions();
      final id = transactions.first['id'] as String;
      
      await offlineQueue.markAsProcessed(id);
      
      final pendingCount = await offlineQueue.getPendingCount();
      expect(pendingCount, equals(0));
    });

    test('markAsError updates transaction with error status', () async {
      await offlineQueue.addTransaction({
        'endpoint': '/api/test',
        'data': {'key': 'value'},
      });
      
      final transactions = await offlineQueue.getPendingTransactions();
      final id = transactions.first['id'] as String;
      
      await offlineQueue.markAsError(id, 'Network error');
      
      final pendingCount = await offlineQueue.getPendingCount();
      expect(pendingCount, equals(0));
    });

    test('clearAll removes all transactions', () async {
      await offlineQueue.addTransaction({
        'endpoint': '/api/test1',
        'data': {'test': 1},
      });
      await offlineQueue.addTransaction({
        'endpoint': '/api/test2',
        'data': {'test': 2},
      });
      
      await offlineQueue.clearAll();
      
      final count = await offlineQueue.getPendingCount();
      expect(count, equals(0));
    });

    test('transaction includes endpoint from data', () async {
      await offlineQueue.addTransaction({
        'endpoint': '/api/custom',
        'data': {'key': 'value'},
      });
      
      final transactions = await offlineQueue.getPendingTransactions();
      expect(transactions.first['endpoint'], equals('/api/custom'));
    });

    test('only returns pending transactions, not processed ones', () async {
      await offlineQueue.addTransaction({
        'endpoint': '/api/test1',
        'data': {'test': 1},
      });
      await offlineQueue.addTransaction({
        'endpoint': '/api/test2',
        'data': {'test': 2},
      });
      
      final allTransactions = await offlineQueue.getPendingTransactions();
      await offlineQueue.markAsProcessed(allTransactions[0]['id'] as String);
      
      final pending = await offlineQueue.getPendingTransactions();
      expect(pending, hasLength(1));
      expect(pending.first['id'], equals(allTransactions[1]['id']));
    });
  });
}
