// Courier realtime events must be SUBSCRIBED, not merely handled.
//
// socket.io only delivers events that have a registered handler. An event listed
// in the service's routing switch but missing from its bind list therefore never
// arrives — no exception, no log, the board just never updates and it looks like
// a backend problem. This codebase has been bitten by that shape of silence
// before, so the agreement between the two lists is asserted rather than trusted.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/src/core/constants/ws_events.dart';
import 'package:jarz_pos/src/core/websocket/websocket_service.dart';

void main() {
  group('courier stop events', () {
    test('every courier stop event is bound on connect', () {
      for (final event in WebSocketService.courierStopEvents) {
        expect(
          WebSocketService.subscribedEvents,
          contains(event),
          reason:
              '$event is routed but never subscribed, so it would never '
              'arrive. Add it to WebSocketService.subscribedEvents.',
        );
      }
    });

    test('carries exactly the four events the board reacts to', () {
      // COURIER_CONTRACTS §7 also freezes courierDutyChanged and
      // courierDepositDeclared. Neither changes a Kanban card, so both are
      // deliberately absent here — this asserts that omission is intentional and
      // makes anyone adding one to the board do it on purpose.
      expect(WebSocketService.courierStopEvents, {
        WsEvents.courierStopArrived,
        WsEvents.courierStopDelivered,
        WsEvents.courierStopFailed,
        WsEvents.addressPinUpdated,
      });
    });

    test('the frozen §7 event strings are unchanged', () {
      // These must match jarz_pos.constants.WS_EVENTS verbatim; a typo here is a
      // silently dead listener.
      expect(WsEvents.courierStopArrived, 'jarz_pos_courier_stop_arrived');
      expect(WsEvents.courierStopDelivered, 'jarz_pos_courier_stop_delivered');
      expect(WsEvents.courierStopFailed, 'jarz_pos_courier_stop_failed');
      expect(WsEvents.courierDutyChanged, 'jarz_pos_courier_duty_changed');
      expect(
        WsEvents.courierDepositDeclared,
        'jarz_pos_courier_deposit_declared',
      );
      expect(WsEvents.addressPinUpdated, 'jarz_pos_address_pin_updated');
    });

    test('event names are lower-case, as the Kanban dispatch assumes', () {
      // The Kanban handler lower-cases the incoming event name before comparing,
      // so a mixed-case constant would never match.
      for (final event in WebSocketService.courierStopEvents) {
        expect(event, event.toLowerCase(), reason: event);
      }
    });

    test('no event is bound twice', () {
      expect(
        WebSocketService.subscribedEvents.toSet().length,
        WebSocketService.subscribedEvents.length,
      );
    });
  });

  group('branch access event', () {
    test('is bound on connect and keeps its backend name', () {
      expect(WsEvents.branchAccessChanged, 'jarz_pos_branch_access_changed');
      expect(
        WebSocketService.subscribedEvents,
        contains(WsEvents.branchAccessChanged),
      );
    });

    test('is routed to branchAccessUpdates', () async {
      final service = WebSocketService();
      final received = <Map<String, dynamic>>[];
      final sub = service.branchAccessUpdates.listen(received.add);
      service.debugHandleMessage({
        'event': WsEvents.branchAccessChanged,
        'data': <String, dynamic>{
          'user': 'ali@example.com',
          'pos_profile': 'Dokki',
        },
      });
      service.debugHandleMessage({'event': WsEvents.branchAccessChanged});
      await Future<void>.delayed(Duration.zero);
      expect(received, hasLength(2));
      expect(received.first['pos_profile'], 'Dokki');
      await sub.cancel();
    });
  });

  group('chat update event', () {
    test('is bound on connect and keeps its backend name', () {
      expect(WsEvents.chatUpdate, 'jarz_chat_update');
      expect(
        WebSocketService.subscribedEvents,
        contains(WsEvents.chatUpdate),
      );
    });

    test('is routed to chatUpdates, and an empty payload is dropped', () async {
      final service = WebSocketService();
      final received = <Map<String, dynamic>>[];
      final sub = service.chatUpdates.listen(received.add);
      service.debugHandleMessage({
        'event': WsEvents.chatUpdate,
        'data': <String, dynamic>{
          'conversation': 'CHAT-0001',
          'kind': 'message',
        },
      });
      service.debugHandleMessage({'event': WsEvents.chatUpdate});
      await Future<void>.delayed(Duration.zero);
      expect(received, hasLength(1));
      expect(received.single['conversation'], 'CHAT-0001');
      await sub.cancel();
    });
  });
}
