import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/src/core/constants/timing_config.dart';
import 'package:jarz_pos/src/core/network/session_expired_signal.dart';
import 'package:jarz_pos/src/features/pos/order_alert/order_alert_bridge.dart';

void main() {
  group('nextOrderAlertPollDelay', () {
    test('polls at the normal interval while everything is fine', () {
      expect(nextOrderAlertPollDelay(0), PollingIntervals.orderAlert);
    });

    test('widens the interval on consecutive failures', () {
      // The old Timer.periodic asked again every 10s no matter how many times
      // the server had already refused.
      expect(nextOrderAlertPollDelay(1), const Duration(seconds: 20));
      expect(nextOrderAlertPollDelay(2), const Duration(seconds: 40));
      expect(nextOrderAlertPollDelay(3), const Duration(seconds: 80));
    });

    test('stops widening at the ceiling', () {
      expect(nextOrderAlertPollDelay(4), kOrderAlertPollBackoffCeiling);
      expect(nextOrderAlertPollDelay(50), kOrderAlertPollBackoffCeiling);
      expect(kOrderAlertPollBackoffCeiling, const Duration(seconds: 120));
    });

    test('snaps straight back to the normal interval after a success', () {
      // The controller zeroes its counter on the first server answer, so this
      // is what "recovered" looks like: no trickle back down.
      expect(nextOrderAlertPollDelay(50), kOrderAlertPollBackoffCeiling);
      expect(nextOrderAlertPollDelay(0), PollingIntervals.orderAlert);
    });
  });

  group('nextOrderAlertPollDelayAfterRun', () {
    Duration? decide({
      bool isAuthenticated = true,
      bool sessionExpired = false,
      int consecutiveFailures = 0,
    }) {
      return nextOrderAlertPollDelayAfterRun(
        isAuthenticated: isAuthenticated,
        sessionExpired: sessionExpired,
        consecutiveFailures: consecutiveFailures,
      );
    }

    test('keeps polling while the session is alive', () {
      expect(decide(), PollingIntervals.orderAlert);
    });

    test('backs off after failures the session survives', () {
      expect(decide(consecutiveFailures: 2), const Duration(seconds: 40));
    });

    test('stops the loop outright once the session is dead', () {
      // Not a backoff: a session the server has thrown away cannot recover by
      // being asked again, so every retry is a guaranteed 403.
      expect(decide(sessionExpired: true), isNull);
      expect(decide(sessionExpired: true, consecutiveFailures: 1), isNull);
    });

    test('stops the loop when the client has signed out', () {
      expect(decide(isAuthenticated: false), isNull);
    });

    test('a latched signal cancels polling for every failure count', () {
      for (var failures = 0; failures < 10; failures++) {
        expect(
          decide(sessionExpired: true, consecutiveFailures: failures),
          isNull,
          reason: 'must not reschedule after $failures failures',
        );
      }
    });
  });

  group('the signal the poll loop reads', () {
    setUp(SessionExpiredSignal.instance.clear);
    tearDown(SessionExpiredSignal.instance.clear);

    test('a dead-session report latches and stops the loop', () {
      expect(
        nextOrderAlertPollDelayAfterRun(
          isAuthenticated: true,
          sessionExpired: SessionExpiredSignal.instance.expired.value,
          consecutiveFailures: 0,
        ),
        PollingIntervals.orderAlert,
      );

      SessionExpiredSignal.instance.report();

      expect(
        nextOrderAlertPollDelayAfterRun(
          isAuthenticated: true,
          sessionExpired: SessionExpiredSignal.instance.expired.value,
          consecutiveFailures: 0,
        ),
        isNull,
      );
    });

    test('signing in again clears the latch so polling resumes', () {
      SessionExpiredSignal.instance.report();
      SessionExpiredSignal.instance.clear();

      expect(
        nextOrderAlertPollDelayAfterRun(
          isAuthenticated: true,
          sessionExpired: SessionExpiredSignal.instance.expired.value,
          consecutiveFailures: 0,
        ),
        PollingIntervals.orderAlert,
      );
    });
  });
}
