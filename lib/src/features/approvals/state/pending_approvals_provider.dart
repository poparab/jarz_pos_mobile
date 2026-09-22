import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pending_approvals_repository.dart';
import '../models/pending_approvals.dart';

/// How often the counts are re-asked while something shows them. The menu
/// button carries the badge on every screen, so in practice this runs for as
/// long as the app is in front of a manager.
const pendingApprovalsPollInterval = Duration(seconds: 60);

/// Counts of everything awaiting the signed-in user's approval.
///
/// `autoDispose`: it lives while the menu button (on every screen with a
/// drawer) or the drawer itself watches it, and re-asks every
/// [pendingApprovalsPollInterval]. For a user who may approve nothing the
/// server answers `eligible: false` and no further poll is scheduled — a
/// cashier's device asks once per screen, not once a minute.
///
/// A failed read still schedules the next one, so a network blip does not
/// silence the badge for the rest of the session.
final pendingApprovalsProvider = FutureProvider.autoDispose<PendingApprovals>((
  ref,
) async {
  Timer? next;
  ref.onDispose(() => next?.cancel());
  void scheduleNext() {
    next = Timer(pendingApprovalsPollInterval, ref.invalidateSelf);
  }

  try {
    final result = await ref.watch(pendingApprovalsRepositoryProvider).fetch();
    if (result.eligible) scheduleNext();
    return result;
  } catch (_) {
    scheduleNext();
    rethrow;
  }
});
