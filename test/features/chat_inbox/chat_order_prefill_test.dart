// get_order_prefill(with_order=1): the `order` the AI read from the chat, its
// tolerant parsing, the route round trip, and the repository's query.
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/chat_inbox/data/chat_repository.dart';
import 'package:jarz_pos/src/features/chat_inbox/data/models/chat_models.dart';

import '../../helpers/mock_services.dart';

Map<String, dynamic> _orderJson() => {
  'lines': [
    {
      'kind': 'item',
      'item_code': 'Chocolate Hazelnut Large',
      'item_name': 'Chocolate Hazelnut Large',
      'qty': 2,
    },
    {
      'kind': 'bundle',
      'bundle_id': 'BNDL-0001',
      'item_code': 'Jarz Signature Trio',
      'item_name': 'Jarz Signature Trio',
      'qty': 1,
      'selections': {
        'Jars::1': [
          {'item_code': 'Chocolate Hazelnut Large', 'qty': 3},
        ],
      },
      'complete': true,
    },
  ],
  'address': {'text': 'شارع ٩ المعادي عمارة ٥'},
  'area': {
    'territory': 'EG6OCT',
    'label': 'السادس من اكتوبر',
    'delivery_income': 60.0,
  },
  'phone': '01012345678',
  'contact_name': 'Mona',
  'pickup': false,
  'notes': 'No nuts on top',
  'warnings': ['"Mango Small" is paused'],
};

void main() {
  group('ChatOrderPrefill with an order', () {
    test('parses lines, bundle selections and the side details', () {
      final p = ChatOrderPrefill.fromJson({
        'customer': {'name': 'CUST-1', 'customer_name': 'Mona'},
        'order': _orderJson(),
        'order_error': null,
      });
      final order = p.order!;
      expect(p.orderError, isNull);
      expect(order.lines, hasLength(2));

      final item = order.lines[0];
      expect(item.isBundle, isFalse);
      expect(item.itemCode, 'Chocolate Hazelnut Large');
      expect(item.qty, 2);

      final bundle = order.lines[1];
      expect(bundle.isBundle, isTrue);
      expect(bundle.bundleId, 'BNDL-0001');
      expect(bundle.complete, isTrue);
      expect(bundle.selections.keys, ['Jars::1']);
      expect(bundle.selections['Jars::1']!.single.itemCode,
          'Chocolate Hazelnut Large');
      expect(bundle.selections['Jars::1']!.single.qty, 3);

      expect(order.addressText, 'شارع ٩ المعادي عمارة ٥');
      expect(order.area!.territory, 'EG6OCT');
      expect(order.area!.deliveryIncome, 60.0);
      expect(order.phone, '01012345678');
      expect(order.contactName, 'Mona');
      expect(order.pickup, isFalse);
      expect(order.notes, 'No nuts on top');
      expect(order.warnings, ['"Mango Small" is paused']);
      expect(order.isEmpty, isFalse);
      expect(order.changesCart, isTrue);
    });

    test('a failed read gives no order and the error', () {
      final p = ChatOrderPrefill.fromJson({
        'customer': {'name': 'CUST-1'},
        'order': null,
        'order_error': 'AI drafting is off',
      });
      expect(p.order, isNull);
      expect(p.orderError, 'AI drafting is off');
      expect(p.customer?['name'], 'CUST-1');
    });

    test('without with_order the answer is unchanged', () {
      final p = ChatOrderPrefill.fromJson({
        'customer': {'name': 'CUST-1'},
        'phone': '+201000000001',
      });
      expect(p.order, isNull);
      expect(p.orderError, isNull);
    });

    test('tolerates odd types and unknown keys', () {
      final order = ChatPrefillOrder.fromJson({
        'lines': [
          {'kind': 'item', 'item_code': 'A', 'qty': '3', 'extra': 1},
          {'item_code': '', 'qty': 1}, // no code: dropped
          'garbage',
          {'bundle_id': 'B-1', 'item_code': 'BX', 'complete': '1',
            'selections': {'g': [{'item_code': 'A'}], '': [], 'h': 'x'}},
        ],
        'address': 'a bare string address',
        'area': 'not a map',
        'pickup': 1,
        'warnings': '["w1", "w2"]',
        'future_key': {'x': 1},
      });
      expect(order.lines, hasLength(2));
      expect(order.lines[0].qty, 3);
      expect(order.lines[0].itemName, 'A', reason: 'name falls back to code');
      // No kind but a bundle_id: read as a bundle.
      expect(order.lines[1].isBundle, isTrue);
      expect(order.lines[1].complete, isTrue);
      expect(order.lines[1].selections.keys, ['g']);
      expect(order.lines[1].selections['g']!.single.qty, 1);
      expect(order.addressText, 'a bare string address');
      expect(order.area, isNull);
      expect(order.pickup, isTrue);
      expect(order.warnings, ['w1', 'w2']);
    });

    test('an order with nothing in it is empty', () {
      final order = ChatPrefillOrder.fromJson({
        'lines': <dynamic>[],
        'address': null,
        'pickup': false,
        'warnings': <dynamic>[],
      });
      expect(order.isEmpty, isTrue);
      expect(order.changesCart, isFalse);
    });

    test('survives the round trip through the route extra', () {
      final order = ChatPrefillOrder.fromJson(_orderJson());
      final again = ChatPrefillOrder.fromJson(order.toJson());
      expect(again.lines, hasLength(2));
      expect(again.lines[1].selections['Jars::1']!.single.qty, 3);
      expect(again.lines[1].bundleId, 'BNDL-0001');
      expect(again.lines[1].complete, isTrue);
      expect(again.addressText, order.addressText);
      expect(again.area!.label, order.area!.label);
      expect(again.area!.deliveryIncome, 60.0);
      expect(again.notes, order.notes);
      expect(again.warnings, order.warnings);
    });
  });

  group('ChatRepository.fetchOrderPrefill', () {
    late MockDio dio;
    late ChatRepository repo;

    setUp(() {
      dio = MockDio();
      repo = ChatRepository(dio);
    });

    test('with_order is sent only when asked', () async {
      dio.setResponse(ApiEndpoints.chatGetOrderPrefill, {
        'message': {
          'customer': {'name': 'CUST-1'},
          'order': _orderJson(),
        },
      });

      final plain = await repo.fetchOrderPrefill('CHAT-1');
      expect(dio.requestLog.last['queryParameters'], {'conversation': 'CHAT-1'});
      expect(plain.customer?['name'], 'CUST-1');

      final withOrder = await repo.fetchOrderPrefill('CHAT-1', withOrder: true);
      expect(dio.requestLog.last['method'], 'GET');
      expect(dio.requestLog.last['queryParameters'], {
        'conversation': 'CHAT-1',
        'with_order': 1,
      });
      expect(withOrder.order!.lines, hasLength(2));
    });

    test('the read allows a slow model call', () {
      expect(ChatRepository.orderPrefillTimeout, const Duration(seconds: 45));
    });
  });
}
