import 'package:flutter/material.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../models/branch_access_models.dart';

/// "12:47" for a shift opened today, "22 Sep 12:47" for one left open from an
/// earlier day (some are left open 22-59h, and "since 12:47" would then read
/// as this afternoon).
String formatOpenSince(BuildContext context, BranchOpenShift shift) {
  final since = shift.sinceTime;
  if (since == null) return shift.since ?? '';
  final now = DateTime.now();
  final sameDay =
      since.year == now.year &&
      since.month == now.month &&
      since.day == now.day;
  return formatDateTime(
    context,
    since,
    pattern: sameDay ? 'HH:mm' : 'd MMM HH:mm',
  );
}

/// Why the caller may not change [user]'s access on any branch, or null.
///
/// Uses the server's `editable` flag when sent (own row for a line manager, or
/// a manager / line manager target); an older server without it falls back to
/// the own-row rule.
String? userLockReason(
  AppLocalizations l10n,
  BranchAccessUser user, {
  required bool canManageAll,
}) {
  if (!user.isLockedFor(canManageAll: canManageAll)) return null;
  return user.isSelf
      ? l10n.branchAccessCannotEditSelf
      : l10n.branchAccessUserNotEditable;
}

/// Why [user]'s access on [branch] cannot be changed right now, or null when
/// it can. Checked in the same order the server refuses in, so the reason
/// shown is the one the server would give.
String? branchChipLockReason(
  AppLocalizations l10n, {
  required BranchAccessBranch branch,
  required BranchAccessUser user,
  required bool canManageAll,
  required String openSinceText,
}) {
  final userReason = userLockReason(l10n, user, canManageAll: canManageAll);
  if (userReason != null) return userReason;
  if (!branch.manageable) return l10n.branchAccessNotYourBranch;
  final open = branch.openShift;
  // Making an ACTIVE day access permanent changes no row (the row is already
  // there; only the grant is flipped), so the server allows it while the
  // branch is open. Every other change on an open branch is refused.
  final convertsDayAccess =
      user.stateOn(branch.posProfile) == BranchMembershipState.dayAccessActive;
  if (open != null && !convertsDayAccess) {
    return l10n.branchAccessLockedOpen(
      branch.posProfile,
      openSinceText,
      open.holder,
    );
  }
  return null;
}

/// One person's access on one branch.
///
/// Tapping toggles permanent membership (through a confirm dialog the caller
/// shows). A locked chip - branch open, not the caller's branch, or the
/// caller's own row - is disabled, shows a lock, and explains itself on tap
/// through its tooltip rather than silently ignoring the tap.
class BranchAccessChip extends StatelessWidget {
  const BranchAccessChip({
    super.key,
    required this.user,
    required this.branch,
    required this.canManageAll,
    required this.onTap,
  });

  final BranchAccessUser user;
  final BranchAccessBranch branch;
  final bool canManageAll;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final open = branch.openShift;
    final lockReason = branchChipLockReason(
      l10n,
      branch: branch,
      user: user,
      canManageAll: canManageAll,
      openSinceText: open == null ? '' : formatOpenSince(context, open),
    );
    final locked = lockReason != null;
    final state = user.stateOn(branch.posProfile);

    final days = user.dayAccessFor(branch.posProfile);
    final dayLabel = days.isEmpty
        ? null
        : l10n.branchAccessChipDay(
            branch.posProfile,
            formatDateString(context, days.first.accessDate, pattern: 'd MMM'),
          );

    final (IconData icon, String label, String stateText) = switch (state) {
      BranchMembershipState.member => (
        Icons.check_circle,
        branch.posProfile,
        l10n.branchAccessChipMember,
      ),
      BranchMembershipState.dayAccessActive => (
        Icons.today,
        dayLabel ?? branch.posProfile,
        l10n.branchAccessDayStatusActive,
      ),
      BranchMembershipState.dayAccessScheduled => (
        Icons.event,
        dayLabel ?? branch.posProfile,
        l10n.branchAccessDayStatusScheduled,
      ),
      BranchMembershipState.none => (
        Icons.remove_circle_outline,
        branch.posProfile,
        l10n.branchAccessChipNone,
      ),
    };

    final selected = state == BranchMembershipState.member;
    final chip = FilterChip(
      key: ValueKey('branch-chip-${user.user}-${branch.posProfile}'),
      selected: selected,
      showCheckmark: false,
      avatar: Icon(
        locked ? Icons.lock : icon,
        size: 18,
        color: locked
            ? theme.colorScheme.onSurfaceVariant
            : (state == BranchMembershipState.none
                  ? theme.colorScheme.outline
                  : theme.colorScheme.primary),
      ),
      label: Text(label),
      onSelected: locked ? null : (_) => onTap(),
    );

    return Tooltip(
      message: lockReason ?? stateText,
      triggerMode: locked
          ? TooltipTriggerMode.tap
          : TooltipTriggerMode.longPress,
      child: chip,
    );
  }
}
