import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/followup_models.dart';
import '../../state/followups_providers.dart';
import 'followup_results_common.dart';
import 'log_touch_sheet.dart';

/// Calls tab: how the phone follow-ups went (`get_followup_stats`).
class FollowupResultsCalls extends StatelessWidget {
  const FollowupResultsCalls({super.key});

  @override
  Widget build(BuildContext context) {
    return ResultsAsync<FollowupStats>(
      provider: followupStatsProvider,
      builder: (context, stats) => _CallsBody(stats: stats),
    );
  }
}

class _CallsBody extends StatelessWidget {
  const _CallsBody({required this.stats});

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

    Widget metric(String label, String value, IconData icon) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(label),
        trailing: Text(
          value,
          style: tabularFigures(
            theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
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
      final top = entries.isEmpty ? 0 : entries.first.value;
      return ResultsSection(
        title: title,
        child: entries.isEmpty
            ? ResultsEmpty(message: l10n.followupsStatsEmpty, compact: true)
            : Column(
                children: [
                  for (final e in entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(label(e.key))),
                              Text(
                                formatCount(context, e.value),
                                style: tabularFigures(
                                  theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ResultsBar(
                            fraction: top == 0 ? 0 : e.value / top,
                            height: 6,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      );
    }

    return ResultsList.children(
      children: [
        metric(
          l10n.followupsStatsTotal,
          formatCount(context, stats.total),
          Icons.checklist,
        ),
        metric(
          l10n.followupsStatsCalls,
          formatCount(context, stats.callsTotal),
          Icons.call_outlined,
        ),
        metric(
          l10n.followupsStatsReached,
          formatCount(context, stats.callsReached),
          Icons.phone_in_talk_outlined,
        ),
        metric(
          l10n.followupsStatsReachRate,
          '${formatCount(context, stats.reachPercent.round())}%',
          Icons.percent,
        ),
        metric(
          l10n.followupsStatsTouchedCustomers,
          formatCount(context, stats.touchedCustomers),
          Icons.people_outline,
        ),
        metric(
          l10n.followupsStatsReordered,
          formatCount(context, stats.reordered),
          Icons.shopping_bag_outlined,
        ),
        metric(
          l10n.followupsStatsReorderRate,
          '${formatCount(context, stats.reorderPercent.round())}%',
          Icons.percent,
        ),
        const SizedBox(height: 4),
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
