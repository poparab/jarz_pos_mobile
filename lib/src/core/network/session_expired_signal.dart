import 'package:flutter/foundation.dart';

/// One-way channel from the Dio interceptor to the sign-in gate: "the server
/// no longer knows who we are".
///
/// Same shape and the same reason as [AppUpgradeSignal] next door - the
/// interceptor is built inside `dioProvider` without a `Ref`, so it cannot
/// write Riverpod state directly. It publishes here, and a gate widget that
/// does have a `Ref` reacts by ending the client-side session.
///
/// Why this exists at all: Frappe answers a dead session with **403**, not
/// 401. Nothing in the app reacted to that, so a tablet whose backend session
/// had died stayed "logged in" client-side and kept polling
/// `get_pending_alerts` every 10s forever - 587 Sentry events, 72% of all
/// production client errors, and no alerts actually delivered to that till.
///
/// A singleton because the interceptor outlives any particular widget tree and
/// there is only ever one Dio.
class SessionExpiredSignal {
  SessionExpiredSignal._();

  static final SessionExpiredSignal instance = SessionExpiredSignal._();

  /// Latched. Once the server has told us we are Guest, every later request on
  /// this session is equally dead, so re-reporting adds nothing - and the
  /// pollers read this to stop retrying at all. Cleared only by [clear], which
  /// login and logout both call, i.e. when a real session boundary is crossed.
  final ValueNotifier<bool> expired = ValueNotifier<bool>(false);

  bool _clientFlipDeferred = false;

  /// True while the app has *deliberately* killed the backend session but is
  /// still holding the user on screen on purpose.
  ///
  /// The only case is ending a POS shift: `LoginNotifier.endSession()` kills
  /// the session the instant the till is counted out, but leaves
  /// `currentAuthStateProvider` true so the closing summary survives (see the
  /// comment on `endSession`). The very next alert poll then gets the Guest
  /// 403 and lands here - and if the gate acted on it, it would tear down the
  /// closing summary, which is exactly what `endSession` was written to avoid.
  /// So during that window the gate stands down and `LoginNotifier.logout()`
  /// (fired when the operator acknowledges the summary) does the flip.
  bool get clientFlipDeferred => _clientFlipDeferred;

  /// Called by `LoginNotifier.endSession()`. See [clientFlipDeferred].
  void deferClientFlip() {
    _clientFlipDeferred = true;
  }

  void report() {
    expired.value = true;
  }

  void clear() {
    _clientFlipDeferred = false;
    expired.value = false;
  }
}
