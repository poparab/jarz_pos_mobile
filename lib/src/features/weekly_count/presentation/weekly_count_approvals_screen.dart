import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/network/user_service.dart';
import '../../../core/widgets/app_drawer.dart';
import '../data/weekly_count_models.dart';
import 'weekly_count_format.dart';
import 'weekly_count_providers.dart';

/// Whether to offer the approvals list: the server's own `is_approver` once
/// the status is in, the role helpers until then (line manager tier, or
/// stock). The server re-checks every approval regardless.
final weeklyCountIsApproverProvider = Provider.autoDispose<bool>((ref) {
  final status = ref.watch(weeklyCountStatusProvider).valueOrNull;
  if (status != null) return status.isApprover;
  return ref.watch(canActAsLineManagerProvider) ||
      ref.watch(canAccessInventoryCountProvider);
});

/// `/weekly-count/approvals`: counts waiting for approval first, as big
/// cards, then the recent history.
class WeeklyCountApprovalsScreen extends ConsumerWidget {
  const WeeklyCountApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final statusAsync = ref.watch(weeklyCountStatusProvider);
    final approver = ref.watch(weeklyCountIsApproverProvider);

    Widget body;
    if (!approver) {
      body = statusAsync.isLoading && !statusAsync.hasValue
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      l10n.weeklyCountApproverOnly,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
    } else {
      body = _ApprovalsList();
    }

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(l10n.weeklyCountApprovalsTitle)),
      body: body,
    );
  }
}

class _ApprovalsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final listAsync = ref.watch(weeklyCountListProvider);
    final rows = listAsync.valueOrNull;
    if (rows == null) {
      if (listAsync.hasError) {
        return WeeklyCountErrorView(
          error: listAsync.error!,
          onRetry: () => ref.invalidate(weeklyCountListProvider),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }
    final pending = rows.where((r) => r.isPending).toList();
    final history = rows.where((r) => !r.isPending).toList();
    final theme = Theme.of(context);

    Future<void> open(WeeklyCountSummary row) async {
      await context.push(AppRoutes.weeklyCountDetailFor(row.name));
      if (context.mounted) ref.invalidate(weeklyCountListProvider);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(weeklyCountStatusProvider);
        return ref.refresh(weeklyCountListProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Text(
            l10n.weeklyCountApprovalsPending,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (pending.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: WeeklyCountColors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.weeklyCountApprovalsNonePending),
                ],
              ),
            )
          else
            for (final row in pending)
              _PendingCard(row: row, onTap: () => open(row)),
          const SizedBox(height: 20),
          Text(
            l10n.weeklyCountApprovalsHistory,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l10n.weeklyCountApprovalsNoHistory,
                textAlign: TextAlign.center,
              ),
            )
          else
            for (final row in history)
              _HistoryTile(row: row, onTap: () => open(row)),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.row, required this.onTap});

  final WeeklyCountSummary row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final diffs = row.differencesCount;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: WeeklyCountColors.amber.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: WeeklyCountColors.amberBg,
                child: Icon(
                  Icons.hourglass_top,
                  color: WeeklyCountColors.amber,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.posProfile,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.weeklyCountCountedBy(
                        row.counterLabel,
                        weeklyCountTimeLabel(context, row.countedAt),
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (diffs != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.weeklyCountDifferences(diffs),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: diffs == 0
                              ? WeeklyCountColors.green
                              : WeeklyCountColors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.row, required this.onTap});

  final WeeklyCountSummary row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final diffs = row.differencesCount;
    final subtitle = [
      l10n.weeklyCountCountedBy(
        row.counterLabel,
        weeklyCountTimeLabel(context, row.countedAt),
      ),
      if (diffs != null) l10n.weeklyCountDifferences(diffs),
    ].join(' · ');
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      onTap: onTap,
      title: Text(
        row.posProfile,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: WeeklyCountStatusChip(status: row.status),
    );
  }
}
