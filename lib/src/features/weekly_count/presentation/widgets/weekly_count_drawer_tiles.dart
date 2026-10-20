import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/weekly_count_models.dart';
import '../weekly_count_format.dart';
import '../weekly_count_providers.dart';

/// What the drawer needs from the weekly-count status, null-safe: until the
/// status arrives (or if it fails) nothing is offered, exactly as a role
/// gate that has not loaded yet offers nothing.
class WeeklyCountDrawerState {
  const WeeklyCountDrawerState({
    required this.canCount,
    required this.isApprover,
    required this.due,
    required this.urgent,
    required this.pending,
  });

  static const none = WeeklyCountDrawerState(
    canCount: false,
    isApprover: false,
    due: false,
    urgent: false,
    pending: 0,
  );

  factory WeeklyCountDrawerState.from(WeeklyCountStatus? status) {
    if (status == null) return none;
    return WeeklyCountDrawerState(
      canCount: status.canCount,
      isApprover: status.isApprover,
      due: status.hasDue,
      urgent: status.urgent,
      pending: status.pendingApprovalCount,
    );
  }

  /// Anyone with at least one branch to count.
  final bool canCount;
  final bool isApprover;
  final bool due;
  final bool urgent;
  final int pending;
}

final weeklyCountDrawerStateProvider = Provider<WeeklyCountDrawerState>((ref) {
  return WeeklyCountDrawerState.from(
    ref.watch(weeklyCountStatusProvider).valueOrNull,
  );
});

/// "الجرد الأسبوعي", with a dot while a member branch still owes the count.
class WeeklyCountNavTile extends ConsumerWidget {
  const WeeklyCountNavTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weeklyCountDrawerStateProvider);
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: const Icon(Icons.fact_check),
      title: Text(context.l10n.menuWeeklyCount),
      // Null rather than an empty widget: a trailing slot shifts the title.
      trailing: state.due ? WeeklyCountDueDot(urgent: state.urgent) : null,
      onTap: onTap,
    );
  }
}

/// "موافقات الجرد", with how many counts wait for approval.
class WeeklyCountApprovalsNavTile extends ConsumerWidget {
  const WeeklyCountApprovalsNavTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(weeklyCountDrawerStateProvider).pending;
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: const Icon(Icons.rule),
      title: Text(context.l10n.menuWeeklyCountApprovals),
      trailing: pending > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: WeeklyCountColors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$pending',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

/// The small dot for the tile and for the collapsed group header.
class WeeklyCountDueDot extends StatelessWidget {
  const WeeklyCountDueDot({super.key, this.urgent = false});

  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: urgent ? WeeklyCountColors.red : WeeklyCountColors.amber,
        shape: BoxShape.circle,
      ),
    );
  }
}
