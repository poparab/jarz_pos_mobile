import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/models/followup_models.dart';
import '../../state/followups_providers.dart';
import '../widgets/log_touch_sheet.dart';

/// The last 7 days of `get_followup_stats` as a plain card list.
class FollowupStatsScreen extends ConsumerWidget {
  const FollowupStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(followupStatsLast7DaysProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.followupsStatsTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.userErrorMessage(e), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(followupStatsLast7DaysProvider),
                  child: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
        data: (stats) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(followupStatsLast7DaysProvider);
            await ref.read(followupStatsLast7DaysProvider.future);
          },
          child: _StatsBody(stats: stats),
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});

  final FollowupStats stats;

  String _statusLabel(BuildContext context, String status) {
    final l10n = context.l10n;
    return switch (status.toLowerCase()) {
      'pending' => l10n.followupsStatusPending,
      'done' => l10n.followupsStatusDone,
      'skipped' => l10n.followupsStatusSkipped,
      _ => status,
    };
  }

  String _outcomeLabel(BuildContext context, String outcome) {
    final known = FollowupOutcome.fromWire(outcome);
    return known == null ? outcome : followupOutcomeLabel(context, known);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    Widget metric(String label, String value) => Card(
          child: ListTile(
            title: Text(label),
            trailing: Text(
              value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );

    Widget breakdown(
      String title,
      Map<String, int> counts,
      String Function(String) label,
    ) {
      final entries = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(title, style: theme.textTheme.titleMedium),
              ),
              if (entries.isEmpty)
                ListTile(dense: true, title: Text(l10n.followupsStatsEmpty)),
              for (final e in entries)
                ListTile(
                  dense: true,
                  title: Text(label(e.key)),
                  trailing: Text(formatCount(context, e.value)),
                ),
            ],
          ),
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      children: [
        metric(l10n.followupsStatsTotal, formatCount(context, stats.total)),
        metric(l10n.followupsStatsCalls, formatCount(context, stats.callsTotal)),
        metric(
          l10n.followupsStatsReached,
          formatCount(context, stats.callsReached),
        ),
        metric(
          l10n.followupsStatsReachRate,
          '${formatCount(context, stats.reachPercent.round())}%',
        ),
        metric(
          l10n.followupsStatsTouchedCustomers,
          formatCount(context, stats.touchedCustomers),
        ),
        metric(
          l10n.followupsStatsReordered,
          formatCount(context, stats.reordered),
        ),
        metric(
          l10n.followupsStatsReorderRate,
          '${formatCount(context, stats.reorderPercent.round())}%',
        ),
        breakdown(
          l10n.followupsStatsByStatus,
          stats.byStatus,
          (k) => _statusLabel(context, k),
        ),
        breakdown(
          l10n.followupsStatsByOutcome,
          stats.byOutcome,
          (k) => _outcomeLabel(context, k),
        ),
      ],
    );
  }
}
