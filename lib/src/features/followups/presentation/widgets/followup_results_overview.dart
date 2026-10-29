import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/followup_models.dart';
import '../../state/followups_providers.dart';
import 'followup_results_common.dart';

/// Overview tab: what the campaign cost, what it brought, the funnel from
/// message to order, the codes, and the per-step / per-day breakdowns.
class FollowupResultsOverview extends StatelessWidget {
  const FollowupResultsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return ResultsAsync<FollowupSentReport>(
      provider: followupSentReportProvider,
      builder: (context, report) => ResultsList.children(
        children: [
          if (report.money != null) _CostCard(report: report),
          _FunnelCard(report: report),
          if (report.codes != null) _CodesCard(codes: report.codes!),
          if (report.optedOutCustomers > 0 || report.refusedWaitingForStaff > 0)
            _AttentionCard(report: report),
          _ByStepCard(report: report),
          _ByDayCard(report: report),
          _CancelledCard(report: report),
        ],
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({
    required this.label,
    required this.value,
    this.detail,
    this.strong = false,
  });

  final String label;
  final String value;
  final String? detail;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: strong
                      ? theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        )
                      : theme.textTheme.bodyMedium,
                ),
                if (detail != null)
                  Text(
                    detail!,
                    style: tabularFigures(
                      theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: tabularFigures(
              (strong ? theme.textTheme.titleMedium : theme.textTheme.bodyLarge)
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  const _BigStat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              textDirection: TextDirection.ltr,
              style: tabularFigures(
                theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  const _CostCard({required this.report});

  final FollowupSentReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final m = report.money!;
    String money(num v) => followupMoneyText(context, v, currency: m.currency);
    final good = Colors.green.shade700;
    final roiText = m.roi == null
        ? '—'
        : l10n.followupResultsRoiValue(
            NumberFormat('0.0', l10n.localeName).format(m.roi),
          );

    return ResultsSection(
      title: l10n.followupResultsCostTitle,
      icon: Icons.paid_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _BigStat(
                  label: l10n.followupResultsNet,
                  value: money(m.net),
                  color: m.net >= 0 ? good : theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BigStat(
                  label: l10n.followupResultsRoi,
                  value: roiText,
                  color: (m.roi ?? 0) >= 1 ? good : theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _LabelValue(
            label: l10n.followupResultsTotalCost,
            value: money(m.totalCost),
            strong: true,
          ),
          _LabelValue(
            label: l10n.followupResultsMessagesCost,
            detail: l10n.followupResultsMessagesCostDetail(
              formatCount(context, m.billableMessages),
              money(m.messageCostEach),
            ),
            value: money(m.messagesCost),
          ),
          _LabelValue(
            label: l10n.followupResultsDiscountsCost,
            value: money(m.discountCost),
          ),
          const Divider(height: 20),
          _LabelValue(
            label: l10n.followupResultsOrders,
            value: formatCount(context, m.orders),
            strong: true,
          ),
          _LabelValue(
            label: l10n.followupResultsRevenue,
            value: money(m.revenue),
          ),
          _LabelValue(
            label: l10n.followupResultsCostPerOrder,
            value: m.costPerOrder == null ? '—' : money(m.costPerOrder!),
          ),
          if (m.ordersWithCode > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.followupResultsOrdersWithCode(
                  formatCount(context, m.ordersWithCode),
                  money(m.revenueWithCode),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (report.customers > 0)
            Text(
              l10n.followupResultsCustomers(
                formatCount(context, report.customers),
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.followupResultsCostNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FunnelCard extends StatelessWidget {
  const _FunnelCard({required this.report});

  final FollowupSentReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final sent = report.total('sent');
    final stages = <(String, int, Color)>[
      (l10n.followupsSentTotal, sent, theme.colorScheme.outline),
      (
        l10n.followupsSentDelivered,
        report.total('delivered'),
        Colors.green.shade600,
      ),
      (l10n.followupsSentRead, report.total('read'), theme.colorScheme.primary),
      (
        l10n.followupResultsReplied,
        report.total('replied'),
        theme.colorScheme.tertiary,
      ),
      (
        l10n.followupResultsOrdered,
        report.total('reordered'),
        Colors.green.shade800,
      ),
    ];

    return ResultsSection(
      title: l10n.followupResultsFunnelTitle,
      icon: Icons.filter_alt_outlined,
      child: sent == 0
          ? ResultsEmpty(message: l10n.followupsStatsEmpty, compact: true)
          : Column(
              children: [
                for (final s in stages)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.$1,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              '${formatCount(context, s.$2)}  ·  '
                              '${formatCount(context, (s.$2 * 100 / sent).round())}%',
                              textDirection: TextDirection.ltr,
                              style: tabularFigures(
                                theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ResultsBar(fraction: s.$2 / sent, color: s.$3),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _CodesCard extends StatelessWidget {
  const _CodesCard({required this.codes});

  final FollowupCodes codes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    Widget tile(String label, int value, Color color) => Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatCount(context, value),
            style: tabularFigures(
              theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );

    return ResultsSection(
      title: l10n.followupResultsCodesTitle,
      icon: Icons.confirmation_number_outlined,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          tile(
            l10n.followupResultsCodesIssued,
            codes.issued,
            theme.colorScheme.primary,
          ),
          tile(
            l10n.followupResultsCodesUsed,
            codes.used,
            Colors.green.shade700,
          ),
          tile(
            l10n.followupResultsCodesUnused,
            codes.unused,
            theme.colorScheme.tertiary,
          ),
          tile(
            l10n.followupResultsCodesExpired,
            codes.expired,
            theme.colorScheme.outline,
          ),
        ],
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.report});

  final FollowupSentReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ResultsSection(
      title: l10n.followupResultsAttentionTitle,
      icon: Icons.flag_outlined,
      child: Column(
        children: [
          _LabelValue(
            label: l10n.followupsSentOptedOut,
            value: formatCount(context, report.optedOutCustomers),
          ),
          _LabelValue(
            label: l10n.followupsSentRefused,
            value: formatCount(context, report.refusedWaitingForStaff),
          ),
          _LabelValue(
            label: l10n.followupsSentFailed,
            value: formatCount(context, report.total('failed')),
          ),
        ],
      ),
    );
  }
}

class _ByStepCard extends StatelessWidget {
  const _ByStepCard({required this.report});

  final FollowupSentReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = report.byStep.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return ResultsSection(
      title: l10n.followupsSentByStep,
      icon: Icons.timeline,
      child: steps.isEmpty
          ? ResultsEmpty(message: l10n.followupsStatsEmpty, compact: true)
          : Column(
              children: [
                for (final e in steps)
                  _LabelValue(
                    label: followupResultsStepLabel(context, e.key),
                    detail: l10n.followupsSentStepSummary(
                      formatCount(context, e.value['sent'] ?? 0),
                      formatCount(context, e.value['read'] ?? 0),
                      formatCount(context, e.value['reordered'] ?? 0),
                    ),
                    value: formatCount(context, e.value['sent'] ?? 0),
                  ),
              ],
            ),
    );
  }
}

class _ByDayCard extends StatelessWidget {
  const _ByDayCard({required this.report});

  final FollowupSentReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final days = report.byDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final maxCount = days.fold<int>(0, (m, e) => e.value > m ? e.value : m);
    return ResultsSection(
      title: l10n.followupsSentByDay,
      icon: Icons.calendar_month_outlined,
      child: days.isEmpty
          ? ResultsEmpty(message: l10n.followupsStatsEmpty, compact: true)
          : Column(
              children: [
                for (final e in days)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 92,
                          child: Text(
                            formatDateString(
                              context,
                              e.key,
                              pattern: 'EEE d MMM',
                            ),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Expanded(
                          child: ResultsBar(
                            fraction: maxCount == 0 ? 0 : e.value / maxCount,
                            height: 8,
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          child: Text(
                            formatCount(context, e.value),
                            textAlign: TextAlign.end,
                            style: tabularFigures(
                              theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _CancelledCard extends StatelessWidget {
  const _CancelledCard({required this.report});

  final FollowupSentReport report;

  String _reasonLabel(BuildContext context, String reason) {
    final l10n = context.l10n;
    return switch (reason) {
      'Order cancelled' => l10n.followupsSentReasonOrderCancelled,
      'Order returned' => l10n.followupsSentReasonOrderReturned,
      'Excluded: B2B / employee' => l10n.followupsSentReasonExcluded,
      'New order' => l10n.followupsSentReasonNewOrder,
      'Opted out' => l10n.followupsSentReasonOptedOut,
      'Quality complaint' => l10n.followupsSentReasonQuality,
      '' => l10n.commonNotSpecified,
      _ => reason,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reasons = report.cancelled.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ResultsSection(
      title: l10n.followupsSentCancelled,
      icon: Icons.cancel_outlined,
      child: reasons.isEmpty
          ? ResultsEmpty(message: l10n.followupsStatsEmpty, compact: true)
          : Column(
              children: [
                for (final e in reasons)
                  _LabelValue(
                    label: _reasonLabel(context, e.key),
                    value: formatCount(context, e.value),
                  ),
              ],
            ),
    );
  }
}
