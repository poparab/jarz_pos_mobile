import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
import '../models/pending_approvals.dart';
import '../state/pending_approvals_provider.dart';

const _alertRed = Color(0xFFB3261E);

/// The app bar's menu (hamburger) icon, badged with how many items await the
/// user's decision.
///
/// Installed once, app-wide, through `ActionIconThemeData.drawerButtonIconBuilder`
/// — so every screen that has the side menu carries the indicator without any
/// screen knowing about it. No badge while loading, on error, at zero, or for a
/// user who approves nothing: the plain icon, exactly as before.
class PendingApprovalsMenuIcon extends ConsumerWidget {
  const PendingApprovalsMenuIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(pendingApprovalsProvider).valueOrNull?.total ?? 0;
    const icon = Icon(Icons.menu);
    if (total == 0) return icon;
    return Semantics(
      label: context.l10n.approvalsMenuBadgeSemantics(total),
      child: Badge(
        backgroundColor: _alertRed,
        label: Text(total > 99 ? '99+' : '$total'),
        child: icon,
      ),
    );
  }
}

/// "Needs your action" — pinned at the top of the side menu, above the groups.
///
/// Shown only while something is waiting, and only the queues the server says
/// this user may act on, each with its count and a direct way in. It sits above
/// the collapsible groups on purpose: a count inside a collapsed group is a
/// count nobody sees.
class PendingApprovalsDrawerSection extends ConsumerStatefulWidget {
  const PendingApprovalsDrawerSection({super.key});

  @override
  ConsumerState<PendingApprovalsDrawerSection> createState() =>
      _PendingApprovalsDrawerSectionState();
}

class _PendingApprovalsDrawerSectionState
    extends ConsumerState<PendingApprovalsDrawerSection> {
  /// A read younger than this is trusted as-is when the drawer opens; an older
  /// one is re-asked, so a manager who just approved something and reopens the
  /// menu is not shown the count from before.
  static const _freshFor = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final current = ref.read(pendingApprovalsProvider).valueOrNull;
      if (current == null ||
          DateTime.now().difference(current.fetchedAt) > _freshFor) {
        ref.invalidate(pendingApprovalsProvider);
      }
    });
  }

  void _go(String location) {
    Navigator.pop(context);
    context.go(location);
  }

  String _expensesLocation({required String tab, String? month}) {
    final params = <String, String>{'tab': tab};
    if (month != null && month.isNotEmpty) params['month'] = month;
    return Uri(path: AppRoutes.expenses, queryParameters: params).toString();
  }

  void _open(PendingApprovalQueue queue) {
    switch (queue.key) {
      case PendingApprovalKeys.expenses:
        _go(_expensesLocation(tab: 'expenses', month: queue.oldestMonth));
      case PendingApprovalKeys.employeeAdvances:
        _go(_expensesLocation(tab: 'advances', month: queue.oldestMonth));
      case PendingApprovalKeys.itemRequests:
        _go(AppRoutes.itemRequests);
      case PendingApprovalKeys.customShipping:
        _go(AppRoutes.manager);
      case PendingApprovalKeys.tasksAssigned:
        _go(AppRoutes.tasksView('mine'));
      case PendingApprovalKeys.tasksReview:
        _go(AppRoutes.tasksView('review'));
      case PendingApprovalKeys.paymentReceipts:
        // Receipts are confirmed in the Kanban's receipts dialog, which runs on
        // the board's provider — so it is opened there, not over any screen
        // (that would start the whole board, realtime and polling included,
        // for the rest of the session).
        _go(
          Uri(
            path: AppRoutes.kanban,
            queryParameters: const {'receipts': '1'},
          ).toString(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(pendingApprovalsProvider).valueOrNull;
    final waiting = data?.waiting ?? const <PendingApprovalQueue>[];
    if (waiting.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    (IconData, String) describe(String key) => switch (key) {
      PendingApprovalKeys.expenses => (
        Icons.receipt_long,
        l10n.approvalsQueueExpenses,
      ),
      PendingApprovalKeys.employeeAdvances => (
        Icons.payments_outlined,
        l10n.approvalsQueueEmployeeAdvances,
      ),
      PendingApprovalKeys.itemRequests => (
        Icons.playlist_add,
        l10n.approvalsQueueItemRequests,
      ),
      PendingApprovalKeys.paymentReceipts => (
        Icons.fact_check_outlined,
        l10n.approvalsQueuePaymentReceipts,
      ),
      PendingApprovalKeys.tasksAssigned => (
        Icons.task_alt,
        l10n.tasksQueueAssigned,
      ),
      PendingApprovalKeys.tasksReview => (
        Icons.rate_review_outlined,
        l10n.tasksQueueReview,
      ),
      _ => (Icons.local_shipping_outlined, l10n.approvalsQueueCustomShipping),
    };

    // A Material, not a decorated Container: the ListTiles paint their ink on
    // the nearest Material, and Flutter asserts on a coloured box between them.
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Material(
        color: scheme.errorContainer.withValues(alpha: 0.45),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _alertRed.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.notification_important, color: _alertRed),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.approvalsNeedsYourAction,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _alertRed,
                      ),
                    ),
                  ),
                  _CountPill(count: data!.total),
                ],
              ),
            ),
            for (final queue in waiting)
              Builder(
                builder: (_) {
                  final (icon, label) = describe(queue.key);
                  return ListTile(
                    dense: true,
                    leading: Icon(icon),
                    title: Text(label),
                    trailing: _CountPill(count: queue.count),
                    onTap: () => _open(queue),
                  );
                },
              ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;
  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _alertRed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
