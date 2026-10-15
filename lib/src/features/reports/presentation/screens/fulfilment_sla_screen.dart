import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/ops_reports.dart';
import '../../state/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_export_button.dart';
import '../widgets/report_section_card.dart';
import '../widgets/report_table.dart';
import 'daily_close_screen.dart'
    show
        OpsKeyValue,
        OpsKpiGrid,
        OpsNote,
        OpsReportView,
        OpsTwoUp,
        opsCsvDate,
        opsCsvNum,
        opsDateTime,
        opsMinutes,
        opsScopeNote,
        showOpsDetailSheet;

/// The day the Invoice State Log started recording kanban transitions; orders
/// before it have no dispatch / delivery timings.
final DateTime _stateLogSince = DateTime(2026, 10, 13);

/// Fulfilment SLA: order → dispatch → delivered timings, late orders and
/// cancellation reasons (`ops_reports.get_fulfilment_sla`).
class FulfilmentSlaScreen extends ConsumerWidget {
  const FulfilmentSlaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final q = ref.watch(reportQueryProvider);
    final async = ref.watch(fulfilmentSlaProvider(q));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rptFulfilmentSlaTitle),
        actions: [
          ReportExportButton(
            title: l10n.rptFulfilmentSlaTitle,
            rows: () => _csvRows(context, async.valueOrNull),
          ),
        ],
      ),
      body: OpsReportView<FulfilmentSla>(
        async: async,
        onRefresh: () => ref.refresh(fulfilmentSlaProvider(q).future),
        onRetry: () => ref.invalidate(fulfilmentSlaProvider(q)),
        isEmpty: (d) => d.isEmpty,
        header: [
          if (q.from.isBefore(_stateLogSince))
            OpsNote(
              icon: Icons.history_toggle_off,
              text: l10n.rptSlaDataSince(formatDate(context, _stateLogSince)),
            ),
        ],
        builder: (context, d) => _body(context, d),
      ),
    );
  }

  List<Widget> _body(BuildContext context, FulfilmentSla d) {
    final l10n = context.l10n;
    final nf = NumberFormat.decimalPattern(l10n.localeName);
    final t = d.totals;
    final scope = opsScopeNote(context, d.filters);
    return [
      if (scope != null) scope,
      OpsNote(text: l10n.rptSlaLateRule(nf.format(t.lateThresholdMin))),
      if (t.timedDispatch > 0 || t.timedDelivery > 0)
        OpsNote(
          icon: Icons.timer_outlined,
          text: l10n.rptSlaTimedCoverage(
            nf.format(t.timedDispatch),
            nf.format(t.timedDelivery),
          ),
        ),
      _Kpis(totals: t),
      if (d.byDay.isNotEmpty)
        OpsTwoUp(
          first: _MedianByDayCard(days: d.byDay, thresholdMin: t.lateThresholdMin),
          second: _LateByDayCard(days: d.byDay),
        ),
      _BranchesCard(branches: d.branches),
      _LateCard(late: d.late),
      if (d.cancellations.isNotEmpty) _CancellationsCard(reasons: d.cancellations),
    ];
  }

  List<List<String>> _csvRows(BuildContext context, FulfilmentSla? d) {
    if (d == null) return const [];
    final l10n = context.l10n;
    return [
      [l10n.rptSlaBranches],
      [
        l10n.rptSlaBranch,
        l10n.rptSlaOrders,
        l10n.rptSlaDispatchCol,
        l10n.rptSlaDeliverCol,
        l10n.rptSlaLateCol,
        l10n.rptSlaCancelled,
        l10n.rptSlaReturned,
      ],
      for (final b in d.branches)
        [
          b.branch,
          opsCsvNum(b.orders),
          b.medianToDispatchMin == null ? '' : opsCsvNum(b.medianToDispatchMin!, 1),
          b.medianToDeliverMin == null ? '' : opsCsvNum(b.medianToDeliverMin!, 1),
          opsCsvNum(b.lateOrders),
          opsCsvNum(b.cancelled),
          opsCsvNum(b.returned),
        ],
      const [],
      [l10n.rptSlaLateList],
      [
        l10n.rptSlaInvoice,
        l10n.rptSlaBranch,
        l10n.rptSlaCustomer,
        l10n.rptSlaCreated,
        l10n.rptSlaDeadline,
        l10n.rptSlaDeliveredAt,
        l10n.rptSlaLateBy,
        l10n.rptSlaTotalTime,
        l10n.rptSlaSlot,
        l10n.rptSlaRule,
        l10n.rptSlaState,
      ],
      for (final o in d.late)
        [
          o.invoice,
          o.branch,
          o.customer,
          opsCsvDate(o.created),
          opsCsvDate(o.deadline),
          opsCsvDate(o.delivered),
          opsCsvNum(o.minutes, 0),
          o.toDeliverMin == null ? '' : opsCsvNum(o.toDeliverMin!, 0),
          o.slot ?? '',
          _ruleLabel(context, o.rule),
          o.state == null ? '' : localizedKanbanState(context, o.state),
        ],
      const [],
      [l10n.rptSlaCancellations],
      [l10n.rptSlaReason, l10n.rptSlaCount],
      for (final c in d.cancellations) [_reasonLabel(context, c.reason), opsCsvNum(c.count)],
    ];
  }
}

String _ruleLabel(BuildContext context, String? rule) {
  final r = (rule ?? '').trim().toLowerCase();
  if (r.isEmpty) return '';
  if (r == 'slot_start') return context.l10n.rptSlaRuleSlotStart;
  if (r.contains('slot')) return context.l10n.rptSlaRuleSlot;
  if (r.contains('threshold') || r.contains('limit')) return context.l10n.rptSlaRuleThreshold;
  return rule!;
}

String _reasonLabel(BuildContext context, String reason) {
  final label = localizedCancelReason(context, reason);
  return label.trim().isEmpty ? context.l10n.rptSlaNoReason : label;
}

// ── KPIs ──────────────────────────────────────────────────────────────────

class _Kpis extends StatelessWidget {
  final FulfilmentSlaTotals totals;

  const _Kpis({required this.totals});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final t = totals;
    final pctFmt = NumberFormat('#,##0.#', l10n.localeName);
    final latePct = t.delivered > 0
        ? l10n.rptSlaLatePct(pctFmt.format(t.lateOrders * 100 / t.delivered))
        : null;
    return OpsKpiGrid(
      tiles: [
        KpiCard(
          label: l10n.rptSlaMedianDeliver,
          value: opsMinutes(context, t.medianToDeliverMin),
          icon: Icons.delivery_dining_outlined,
        ),
        KpiCard(
          label: l10n.rptSlaMedianDispatch,
          value: opsMinutes(context, t.medianToDispatchMin),
          icon: Icons.outbox_outlined,
        ),
        KpiCard(
          label: l10n.rptSlaP90Deliver,
          value: opsMinutes(context, t.p90ToDeliverMin),
          icon: Icons.speed_outlined,
        ),
        KpiCard(
          label: l10n.rptSlaLateOrders,
          value: formatCount(context, t.lateOrders),
          icon: Icons.alarm_outlined,
          color: t.lateOrders > 0 ? theme.colorScheme.error : null,
          delta: latePct,
          deltaColor: theme.colorScheme.error,
        ),
        if (t.openLateOrders > 0)
          KpiCard(
            label: l10n.rptSlaOpenLate,
            value: formatCount(context, t.openLateOrders),
            icon: Icons.running_with_errors_outlined,
            color: Colors.orange.shade800,
          ),
        KpiCard(
          label: l10n.rptSlaOrders,
          value: formatCount(context, t.orders),
          icon: Icons.receipt_long_outlined,
        ),
        KpiCard(
          label: l10n.rptSlaDelivered,
          value: formatCount(context, t.delivered),
          icon: Icons.check_circle_outline,
          color: Colors.green.shade700,
        ),
        KpiCard(
          label: l10n.rptSlaCancelled,
          value: formatCount(context, t.cancelled),
          icon: Icons.cancel_outlined,
          color: t.cancelled > 0 ? Colors.orange.shade800 : null,
        ),
        KpiCard(
          label: l10n.rptSlaReturned,
          value: formatCount(context, t.returned),
          icon: Icons.assignment_return_outlined,
          color: t.returned > 0 ? theme.colorScheme.error : null,
        ),
      ],
    );
  }
}

// ── Charts ────────────────────────────────────────────────────────────────

/// Bottom-axis label every [step] points so a long range stays legible.
int _labelStep(int n) => n <= 8 ? 1 : (n / 7).ceil();

String _dayLabel(BuildContext context, FulfilmentSlaDay d) {
  final day = d.day;
  return day == null ? d.date : formatDate(context, day, pattern: 'd MMM');
}

class _MedianByDayCard extends StatelessWidget {
  final List<FulfilmentSlaDay> days;
  final int thresholdMin;

  const _MedianByDayCard({required this.days, required this.thresholdMin});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final values = days.map((d) => d.medianToDeliverMin).whereType<double>();
    if (values.isEmpty) {
      return ReportSectionCard(
        title: l10n.rptSlaByDay,
        subtitle: l10n.rptSlaByDayHint,
        child: Text(l10n.reportNoData, style: theme.textTheme.bodySmall),
      );
    }
    final maxV = math.max(values.reduce(math.max), thresholdMin.toDouble());
    final step = _labelStep(days.length);
    final nf = NumberFormat.decimalPattern(l10n.localeName);
    final color = theme.colorScheme.primary;

    return ReportSectionCard(
      title: l10n.rptSlaByDay,
      subtitle: l10n.rptSlaByDayHint,
      child: SizedBox(
        height: 220,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 8, top: 8),
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxV * 1.15,
              minX: 0,
              maxX: math.max(0, days.length - 1).toDouble(),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: thresholdMin.toDouble(),
                    color: theme.colorScheme.error.withValues(alpha: 0.6),
                    strokeWidth: 1.5,
                    dashArray: const [6, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      labelResolver: (_) =>
                          '${l10n.rptSlaRuleThreshold}: ${opsMinutes(context, thresholdMin.toDouble())}',
                    ),
                  ),
                ],
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) => [
                    for (final s in spots)
                      LineTooltipItem(
                        '${_dayLabel(context, days[s.x.toInt()])}\n'
                        '${opsMinutes(context, s.y)}',
                        theme.textTheme.labelSmall!.copyWith(
                          color: theme.colorScheme.onInverseSurface,
                        ),
                      ),
                  ],
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max) return const SizedBox.shrink();
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(nf.format(value.round()), style: theme.textTheme.labelSmall),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= days.length || i % step != 0 || value != i) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4,
                        child: Text(_dayLabel(context, days[i]), style: theme.textTheme.labelSmall),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < days.length; i++)
                      days[i].medianToDeliverMin == null
                          ? FlSpot.nullSpot
                          : FlSpot(i.toDouble(), days[i].medianToDeliverMin!),
                  ],
                  color: color,
                  barWidth: 2.5,
                  dotData: FlDotData(show: days.length <= 31),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LateByDayCard extends StatelessWidget {
  final List<FulfilmentSlaDay> days;

  const _LateByDayCard({required this.days});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final maxLate = days.fold<int>(0, (m, d) => d.lateOrders > m ? d.lateOrders : m);
    if (maxLate == 0) {
      return ReportSectionCard(
        title: l10n.rptSlaLateByDay,
        child: Text(l10n.rptSlaNoLate, style: theme.textTheme.bodySmall),
      );
    }
    final step = _labelStep(days.length);
    final nf = NumberFormat.decimalPattern(l10n.localeName);
    final color = theme.colorScheme.error;

    return ReportSectionCard(
      title: l10n.rptSlaLateByDay,
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            minY: 0,
            maxY: maxLate * 1.2 + 1,
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem: (group, gi, rod, ri) {
                  final d = days[group.x];
                  return BarTooltipItem(
                    '${_dayLabel(context, d)}\n'
                    '${l10n.rptSlaLateOrders}: ${nf.format(d.lateOrders)}\n'
                    '${l10n.rptSlaOrders}: ${nf.format(d.orders)}',
                    theme.textTheme.labelSmall!.copyWith(
                      color: theme.colorScheme.onInverseSurface,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value == meta.max || value != value.roundToDouble()) {
                      return const SizedBox.shrink();
                    }
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(nf.format(value.round()), style: theme.textTheme.labelSmall),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= days.length || i % step != 0) {
                      return const SizedBox.shrink();
                    }
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4,
                      child: Text(_dayLabel(context, days[i]), style: theme.textTheme.labelSmall),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < days.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: days[i].lateOrders.toDouble(),
                      color: color,
                      width: days.length > 20 ? 6 : 12,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tables ────────────────────────────────────────────────────────────────

class _BranchesCard extends StatelessWidget {
  final List<FulfilmentSlaBranch> branches;

  const _BranchesCard({required this.branches});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ReportSectionCard(
      title: l10n.rptSlaBranches,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 600;
          final lateCol = wide ? 4 : 3;
          return ReportTable(
            columns: [
              ReportColumn(l10n.rptSlaBranch, flex: 3),
              ReportColumn(l10n.rptSlaOrders, numeric: true, flex: 2),
              if (wide) ReportColumn(l10n.rptSlaDispatchCol, numeric: true, flex: 3),
              ReportColumn(l10n.rptSlaDeliverCol, numeric: true, flex: 3),
              ReportColumn(l10n.rptSlaLateCol, numeric: true, flex: 2),
              if (wide) ReportColumn(l10n.rptSlaCancelled, numeric: true, flex: 2),
              if (wide) ReportColumn(l10n.rptSlaReturned, numeric: true, flex: 2),
            ],
            rows: [
              for (final b in branches)
                [
                  b.branch,
                  formatCount(context, b.orders),
                  if (wide) opsMinutes(context, b.medianToDispatchMin),
                  opsMinutes(context, b.medianToDeliverMin),
                  formatCount(context, b.lateOrders),
                  if (wide) formatCount(context, b.cancelled),
                  if (wide) formatCount(context, b.returned),
                ],
            ],
            cellColor: (r, c) =>
                c == lateCol && branches[r].lateOrders > 0 ? theme.colorScheme.error : null,
          );
        },
      ),
    );
  }
}

class _LateCard extends StatelessWidget {
  final List<LateOrder> late;

  const _LateCard({required this.late});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ReportSectionCard(
      title: l10n.rptSlaLateList,
      subtitle: late.isEmpty ? null : l10n.rptSlaLateListHint,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 600;
          final lateCol = wide ? 3 : 2;
          return ReportTable(
            columns: [
              ReportColumn(l10n.rptSlaInvoice, flex: 3),
              ReportColumn(l10n.rptSlaCustomer, flex: 3),
              if (wide) ReportColumn(l10n.rptSlaBranch, flex: 3),
              ReportColumn(l10n.rptSlaLateBy, numeric: true, flex: 2),
            ],
            rows: [
              for (final o in late)
                [
                  o.invoice,
                  o.customer,
                  if (wide) o.branch,
                  opsMinutes(context, o.minutes),
                ],
            ],
            maxRows: 15,
            emptyText: l10n.rptSlaNoLate,
            cellColor: (r, c) => c == lateCol ? theme.colorScheme.error : null,
            onRowTap: (i) => _openLate(context, late[i]),
          );
        },
      ),
    );
  }

  void _openLate(BuildContext context, LateOrder o) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    showOpsDetailSheet(
      context,
      title: o.invoice,
      subtitle: [o.customer, o.branch].where((x) => x.isNotEmpty).join(' · '),
      children: [
        OpsKeyValue(
          label: l10n.rptSlaLateBy,
          value: opsMinutes(context, o.minutes),
          valueColor: theme.colorScheme.error,
          bold: true,
        ),
        OpsKeyValue(label: l10n.rptSlaCreated, value: opsDateTime(context, o.created)),
        if (o.deadline != null)
          OpsKeyValue(label: l10n.rptSlaDeadline, value: opsDateTime(context, o.deadline)),
        OpsKeyValue(
          label: l10n.rptSlaDeliveredAt,
          value: o.delivered == null ? l10n.rptSlaNotDelivered : opsDateTime(context, o.delivered),
        ),
        if (o.toDeliverMin != null)
          OpsKeyValue(label: l10n.rptSlaTotalTime, value: opsMinutes(context, o.toDeliverMin)),
        if ((o.slot ?? '').isNotEmpty) OpsKeyValue(label: l10n.rptSlaSlot, value: o.slot!),
        if ((o.rule ?? '').isNotEmpty)
          OpsKeyValue(label: l10n.rptSlaRule, value: _ruleLabel(context, o.rule)),
        if ((o.state ?? '').isNotEmpty)
          OpsKeyValue(label: l10n.rptSlaState, value: localizedKanbanState(context, o.state)),
        const SizedBox(height: 12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: Text(l10n.rptSlaCopyInvoice),
            onPressed: () async {
              final messenger = ScaffoldMessenger.maybeOf(context);
              await Clipboard.setData(ClipboardData(text: o.invoice));
              messenger?.showSnackBar(SnackBar(content: Text(l10n.rptSlaCopied)));
            },
          ),
        ),
      ],
    );
  }
}

class _CancellationsCard extends StatelessWidget {
  final List<CancellationReason> reasons;

  const _CancellationsCard({required this.reasons});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sorted = [...reasons]..sort((a, b) => b.count.compareTo(a.count));
    return ReportSectionCard(
      title: l10n.rptSlaCancellations,
      child: ReportTable(
        columns: [
          ReportColumn(l10n.rptSlaReason, flex: 4),
          ReportColumn(l10n.rptSlaCount, numeric: true, flex: 1),
        ],
        rows: [
          for (final c in sorted) [_reasonLabel(context, c.reason), formatCount(context, c.count)],
        ],
      ),
    );
  }
}
