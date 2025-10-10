import 'package:flutter_test/flutter_test.dart';
import '../../helpers/mock_services.dart';

void main() {
  group('ConnectivityService', () {
    late MockConnectivityService connectivityService;

    setUp(() {
      connectivityService = MockConnectivityService();
    });

    tearDown(() {
      connectivityService.dispose();
    });

    test('initially reports online status', () {
      expect(connectivityService.isOnline, isTrue);
    });

    test('hasConnection returns current online status', () async {
      expect(await connectivityService.hasConnection(), isTrue);
      
      connectivityService.setOnline(false);
      expect(await connectivityService.hasConnection(), isFalse);
    });

    test('emits connectivity changes through stream', () async {
      final statusChanges = <bool>[];
      connectivityService.connectivityStream.listen(statusChanges.add);
      
      connectivityService.setOnline(false);
      await Future.delayed(const Duration(milliseconds: 10));
      
      connectivityService.setOnline(true);
      await Future.delayed(const Duration(milliseconds: 10));
      
      expect(statusChanges, equals([false, true]));
    });

    test('does not emit duplicate status changes', () async {
      final statusChanges = <bool>[];
      connectivityService.connectivityStream.listen(statusChanges.add);
      
      connectivityService.setOnline(true);
      connectivityService.setOnline(true);
      connectivityService.setOnline(false);
      connectivityService.setOnline(false);
      
      await Future.delayed(const Duration(milliseconds: 10));
      
      expect(statusChanges, equals([false]));
    });

    test('updates isOnline property when status changes', () {
      expect(connectivityService.isOnline, isTrue);
      
      connectivityService.setOnline(false);
      expect(connectivityService.isOnline, isFalse);
      
      connectivityService.setOnline(true);
      expect(connectivityService.isOnline, isTrue);
    });

    test('connectivityStream can have multiple listeners', () async {
      final listener1Changes = <bool>[];
      final listener2Changes = <bool>[];
      
      connectivityService.connectivityStream.listen(listener1Changes.add);
      connectivityService.connectivityStream.listen(listener2Changes.add);
      
      connectivityService.setOnline(false);
      await Future.delayed(const Duration(milliseconds: 10));
      
      expect(listener1Changes, equals([false]));
      expect(listener2Changes, equals([false]));
    });
  });
}
