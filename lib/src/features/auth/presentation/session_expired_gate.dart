import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/network/session_expired_signal.dart';
import '../../../core/router.dart';
import '../state/login_notifier.dart';

/// Ends the client-side session when the server has already ended the server
/// side one.
///
/// The counterpart of `AppUpdateGate`: the Dio interceptor detects the dead
/// session but has no `Ref`, so it publishes to [SessionExpiredSignal] and
/// this widget - which does have one - performs the logout and lets the router
/// fall back to `/login`.
///
/// Mounted above routing so it covers every screen at once. Before this, a
/// tablet whose backend session had died stayed authenticated client-side and
/// kept polling forever; the operator saw a POS that silently stopped
/// receiving orders rather than a sign-in screen.
///
/// It renders [child] untouched in every other case: nothing here reacts to a
/// status code, only to the explicit signal.
class SessionExpiredGate extends ConsumerStatefulWidget {
  const SessionExpiredGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SessionExpiredGate> createState() => _SessionExpiredGateState();
}

class _SessionExpiredGateState extends ConsumerState<SessionExpiredGate> {
  SessionExpiredSignal get _signal => SessionExpiredSignal.instance;

  bool _handling = false;

  @override
  void initState() {
    super.initState();
    _signal.expired.addListener(_onSignalChanged);
    if (_signal.expired.value) {
      // Latched before this widget mounted - e.g. a cold start that restored a
      // saved session the server had already dropped.
      WidgetsBinding.instance.addPostFrameCallback((_) => _onSignalChanged());
    }
  }

  @override
  void dispose() {
    _signal.expired.removeListener(_onSignalChanged);
    super.dispose();
  }

  void _onSignalChanged() {
    if (!mounted || _handling || !_signal.expired.value) {
      return;
    }

    // The shift-end flow kills the session on purpose and keeps the operator
    // on the closing summary; it owns the flip. See `LoginNotifier.endSession`.
    if (_signal.clientFlipDeferred) {
      return;
    }

    if (!ref.read(currentAuthStateProvider)) {
      // Already signed out - typically a 401 from the login form itself. There
      // is no session to end and no message worth showing, so just consume it.
      _signal.clear();
      return;
    }

    _handling = true;
    unawaited(_endClientSession());
  }

  Future<void> _endClientSession() async {
    try {
      // logout() swallows its own network failure and resets every user-scoped
      // provider and per-user cache, so no cart or role survives into the next
      // sign-in. It also clears the signal.
      await ref.read(loginNotifierProvider.notifier).logout();
    } catch (_) {
      // Belt and braces: a failure here must not leave the app sitting
      // authenticated against a session the server has thrown away.
      ref.read(currentAuthStateProvider.notifier).state = false;
      _signal.clear();
    } finally {
      _handling = false;
    }

    if (!mounted) {
      return;
    }

    // The router watches currentAuthStateProvider, so it has already fallen
    // back to /login. All that is left is telling the operator why.
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.sessionExpiredMessage),
          duration: const Duration(seconds: 6),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
