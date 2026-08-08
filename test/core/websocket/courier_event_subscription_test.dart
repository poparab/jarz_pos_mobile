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
          reason: '$event is routed but never subscribed, so it would never '
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
}
