import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/b2b_sales_clients.dart';
import '../../state/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_alert_text.dart';
import '../widgets/report_chart_card.dart';
import '../widgets/report_date_range_bar.dart';

/// The B2B Sales & Clients dashboard: the flagship analytics screen. Renders KPI
/// tiles, a stage-coloured sales-pipeline funnel, a revenue/orders trend line,
/// top-client and client-group tables, revenue-by-policy donut, revenue-by-
/// territory bars, reorder-due and at-risk client feeds, a conversion stat row
/// and an alerts feed. Data comes from [b2bSalesClientsProvider], keyed by the
/// shared [reportRangeProvider]. Fully RTL/Arabic-aware.
class B2bSalesClientsScreen extends ConsumerWidget {
  const B2bSalesClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(reportRangeProvider);
    final async = ref.watch(b2bSalesClientsProvider(range));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportB2bTitle)),
      body: Column(
        children: [
          const ReportDateRangeBar(),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(
                onRetry: () =>
                    ref.invalidate(b2bSalesClientsProvider(range)),
              ),
              data: (data) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(b2bSalesClientsProvider(range));
                  await ref.read(b2bSalesClientsProvider(range).future);
                },
                child: _B2bDashboardBody(data: data),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stage helpers (mirrors b2b_stage_chip.dart; replicated locally so this
//    dashboard has no cross-feature coupling) ──────────────────────────────

const List<String> _kStageOrder = <String>[
  'Lead',
  'Qualify',
  'Sample',
  'Approved',
  'Trial',
  'Check-up',
  'Active',
  'Lost/On-hold',
];

Color _stageColor(String stage) {
  switch (stage) {
    case 'Lead':
      return Colors.blueGrey;
    case 'Qualify':
      return Colors.indigo;
    case 'Sample':
      return Colors.teal;
    case 'Approved':
      return Colors.green;
    case 'Trial':
      return Colors.orange;
    case 'Check-up':
      return Colors.purple;
    case 'Active':
      return Colors.lightGreen;
    case 'Lost/On-hold':
      return Colors.red;
    default:
      return Colors.blueGrey;
  }
}

/// Short axis label so long stage names ("Lost/On-hold") don't overflow the
/// bar-chart bottom axis.
String _stageShort(String stage) {
  switch (stage) {
    case 'Qualify':
      return 'Qual';
    case 'Sample':
      return 'Samp';
    case 'Approved':
      return 'Appr';
    case 'Check-up':
      return 'Chk';
    case 'Active':
      return 'Actv';
    case 'Lost/On-hold':
      return 'Lost';
    default:
      return stage;
  }
}

Color _alertColor(BuildContext context, String type) {
  switch (type) {
    case 'danger':
      return Colors.red;
    case 'warning':
      return Colors.orange;
    case 'success':
      return Colors.green;
    default:
      return Theme.of(context).colorScheme.primary;
  }
}

IconData _alertIcon(String type) {
  switch (type) {
    case 'danger':
      return Icons.error_outline;
    case 'warning':
      return Icons.warning_amber_outlined;
    case 'success':
      return Icons.check_circle_outline;
    default:
      return Icons.info_outline;
  }
}

// ── Body ───────────────────────────────────────────────────────────────────

class _B2bDashboardBody extends StatelessWidget {
  final B2bSalesAnalytics data;
  const _B2bDashboardBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      children: [
        if (data.alerts.isNotEmpty) ...[
          _AlertsCard(alerts: data.alerts),
          const SizedBox(height: 12),
        ],
        _KpiGrid(summary: data.summary),
        const SizedBox(height: 12),
        _PipelineChart(
          stages: data.pipelineByStage,
          openValue: data.summary.pipelineOpenValue,
        ),
        const SizedBox(height: 12),
        _RevenueTrendChart(points: data.revenueTrend),
        const SizedBox(height: 12),
        _TopClientsTable(clients: data.topClients),
        const SizedBox(height: 12),
        _RevenueByPolicyDonut(rows: data.revenueByPolicy),
        const SizedBox(height: 12),
        _TerritoryChart(rows: data.revenueByTerritory),
        const SizedBox(height: 12),
        _ClientsByGroupTable(rows: data.clientsByGroup),
        if (data.reorderDue.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ReorderDueTable(rows: data.reorderDue),
        ],
        if (data.atRiskClients.isNotEmpty) ...[
          const SizedBox(height: 12),
          _AtRiskTable(rows: data.atRiskClients),
        ],
        const SizedBox(height: 12),
        _ConversionCard(conversion: data.conversion),
      ],
    );
  }
}

// ── Error ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(l10n.reportError, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.reportsRetry),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Alerts ───────────────────────────────────────────────────────────────

class _AlertsCard extends StatelessWidget {
  final List<B2bSalesAlert> alerts;
  const _AlertsCard({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.reportAlerts,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final alert in alerts) _AlertRow(alert: alert),
          ],
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final B2bSalesAlert alert;
  const _AlertRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = _alertColor(context, alert.type);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_alertIcon(alert.type), size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              stripHtml(alert.message),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ── KPI grid ─────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final B2bSalesSummary summary;
  const _KpiGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tiles = <Widget>[
      KpiCard(
        label: l10n.reportKpiB2bRevenue,
        value: formatCompactCurrency(context, summary.b2bRevenue),
        icon: Icons.payments_outlined,
        color: Colors.green,
      ),
      KpiCard(
        label: l10n.reportKpiB2bOrders,
        value: formatCount(context, summary.b2bOrders),
        icon: Icons.receipt_long_outlined,
        color: Colors.indigo,
      ),
      KpiCard(
        label: l10n.reportKpiActiveClients,
        value: formatCount(context, summary.activeClients),
        icon: Icons.groups_outlined,
        color: Colors.teal,
      ),
      KpiCard(
        label: l10n.reportKpiNewClients,
        value: formatCount(context, summary.newClients),
        icon: Icons.person_add_alt_outlined,
        color: Colors.lightGreen,
      ),
      KpiCard(
        label: l10n.reportKpiAov,
        value: formatCurrency(context, summary.avgOrderValue),
        icon: Icons.sell_outlined,
        color: Colors.blue,
      ),
      KpiCard(
        label: l10n.reportKpiGrossMargin,
        value: _pct(summary.grossMarginPct),
        icon: Icons.percent_outlined,
        color: Colors.purple,
      ),
      KpiCard(
        label: l10n.reportKpiReorderDue,
        value: formatCount(context, summary.reorderDueCount),
        icon: Icons.replay_outlined,
        color: Colors.orange,
      ),
      KpiCard(
        label: l10n.reportKpiAtRisk,
        value: formatCount(context, summary.atRiskCount),
        icon: Icons.warning_amber_outlined,
        color: Colors.red,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720
            ? 4
            : constraints.maxWidth >= 480
                ? 3
                : 2;
        const spacing = 10.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final tile in tiles) SizedBox(width: width, child: tile),
          ],
        );
      },
    );
  }
}

String _pct(double value) => '${value.toStringAsFixed(1)}%';

// ── Pipeline funnel (bar chart) ──────────────────────────────────────────

class _PipelineChart extends StatelessWidget {
  final List<B2bPipelineStage> stages;
  final double openValue;
  const _PipelineChart({required this.stages, required this.openValue});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    // Reindex the payload by stage name, then plot in the canonical order.
    final byStage = <String, B2bPipelineStage>{
      for (final s in stages) s.stage: s,
    };
    final ordered = [
      for (final name in _kStageOrder)
        byStage[name] ?? B2bPipelineStage(stage: name),
    ];
    final maxCount = ordered.fold<int>(0, (m, s) => s.count > m ? s.count : m);
    final isEmpty = maxCount == 0;

    return ReportChartCard(
      title: l10n.reportSalesPipeline,
      subtitle: formatCompactCurrency(context, openValue),
      isEmpty: isEmpty,
      emptyText: l10n.reportNoData,
      height: 240,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxCount * 1.25,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.transparent,
              tooltipPadding: EdgeInsets.zero,
              tooltipMargin: 2,
              fitInsideVertically: true,
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                rod.toY.round().toString(),
                theme.textTheme.labelSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= ordered.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: Text(
                      _stageShort(ordered[i].stage),
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < ordered.length; i++)
              BarChartGroupData(
                x: i,
                showingTooltipIndicators: ordered[i].count > 0 ? const [0] : const [],
                barRods: [
                  BarChartRodData(
                    toY: ordered[i].count.toDouble(),
                    color: _stageColor(ordered[i].stage),
                    width: 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ── Revenue trend (line chart) ───────────────────────────────────────────

class _RevenueTrendChart extends StatelessWidget {
  final List<B2bSalesRevenueTrendPoint> points;
  const _RevenueTrendChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isEmpty = points.isEmpty;

    final maxRevenue =
        points.fold<double>(0, (m, p) => p.revenue > m ? p.revenue : m);
    final maxOrders =
        points.fold<int>(0, (m, p) => p.orders > m ? p.orders : m);
    // Second line (orders) is rescaled onto the revenue axis so both series
    // remain legible on a single chart; the legend labels each metric.
    final ordersScale =
        maxOrders > 0 && maxRevenue > 0 ? maxRevenue / maxOrders : 0.0;

    final revenueSpots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].revenue),
    ];
    final ordersSpots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].orders * ordersScale),
    ];

    final labelStep = points.isEmpty ? 1 : (points.length / 4).ceil().clamp(1, 999);

    return ReportChartCard(
      title: l10n.reportRevenueTrend,
      isEmpty: isEmpty,
      emptyText: l10n.reportNoData,
      height: 240,
      trailing: _Legend(items: [
        _LegendItem(color: Colors.green, label: l10n.reportKpiB2bRevenue),
        _LegendItem(color: Colors.indigo, label: l10n.reportKpiB2bOrders),
      ]),
      child: isEmpty
          ? const SizedBox.shrink()
          : LineChart(
              LineChartData(
                minY: 0,
                maxY: maxRevenue <= 0 ? 1 : maxRevenue * 1.2,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 ||
                            i >= points.length ||
                            i % labelStep != 0) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(
                            _shortDate(context, points[i].postingDate),
                            style: theme.textTheme.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: revenueSpots,
                    color: Colors.green,
                    isCurved: true,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withValues(alpha: 0.12),
                    ),
                  ),
                  LineChartBarData(
                    spots: ordersSpots,
                    color: Colors.indigo,
                    isCurved: true,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Top clients (table) ──────────────────────────────────────────────────

class _TopClientsTable extends StatelessWidget {
  final List<B2bTopClient> clients;
  const _TopClientsTable({required this.clients});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _TableCard(
      title: l10n.reportTopClients,
      isEmpty: clients.isEmpty,
      header: const [
        _Col('', 3),
        _Col('', 2),
        _Col('#', 1),
      ],
      rows: [
        for (final c in clients)
          _TableRow(cells: [
            _TextCell(
              c.customerName.isEmpty ? c.customer : c.customerName,
              flex: 3,
            ),
            _TextCell(
              formatCompactCurrency(context, c.revenue),
              flex: 2,
              align: TextAlign.end,
            ),
            _TextCell(
              formatCount(context, c.orders),
              flex: 1,
              align: TextAlign.end,
            ),
          ], trailing: _SegmentChip(segment: c.segment)),
      ],
    );
  }
}

// ── Revenue by policy (donut) ────────────────────────────────────────────

class _RevenueByPolicyDonut extends StatelessWidget {
  final List<B2bRevenueByPolicy> rows;
  const _RevenueByPolicyDonut({required this.rows});

  static const List<Color> _palette = [
    Colors.indigo,
    Colors.teal,
    Colors.orange,
    Colors.purple,
    Colors.green,
    Colors.blueGrey,
    Colors.pink,
    Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = rows.fold<double>(0, (s, r) => s + r.revenue);
    final isEmpty = rows.isEmpty || total <= 0;

    return ReportChartCard(
      title: l10n.reportRevenueByPolicy,
      isEmpty: isEmpty,
      emptyText: l10n.reportNoData,
      height: 220,
      child: isEmpty
          ? const SizedBox.shrink()
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 42,
                      sections: [
                        for (var i = 0; i < rows.length; i++)
                          PieChartSectionData(
                            value: rows[i].revenue,
                            color: _palette[i % _palette.length],
                            radius: 46,
                            title:
                                '${(rows[i].revenue / total * 100).toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < rows.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: _LegendRow(
                            color: _palette[i % _palette.length],
                            label: rows[i].policy,
                            value: formatCompactCurrency(
                                context, rows[i].revenue),
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

// ── Revenue by territory (bar chart) ─────────────────────────────────────

class _TerritoryChart extends StatelessWidget {
  final List<B2bRevenueByTerritory> rows;
  const _TerritoryChart({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isEmpty = rows.isEmpty;
    final maxRevenue =
        rows.fold<double>(0, (m, r) => r.revenue > m ? r.revenue : m);

    return ReportChartCard(
      title: l10n.reportByTerritory,
      isEmpty: isEmpty,
      emptyText: l10n.reportNoData,
      height: 240,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxRevenue <= 0 ? 1 : maxRevenue * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => theme.colorScheme.inverseSurface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                formatCompactCurrency(context, rod.toY),
                theme.textTheme.labelSmall!.copyWith(
                  color: theme.colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= rows.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: SizedBox(
                      width: 54,
                      child: Text(
                        rows[i].territory,
                        style: theme.textTheme.labelSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < rows.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: rows[i].revenue,
                    color: theme.colorScheme.primary,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ── Clients by group (table) ─────────────────────────────────────────────

class _ClientsByGroupTable extends StatelessWidget {
  final List<B2bClientsByGroup> rows;
  const _ClientsByGroupTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _TableCard(
      title: l10n.reportClientsByGroup,
      isEmpty: rows.isEmpty,
      header: const [
        _Col('', 3),
        _Col('#', 1),
        _Col('', 2),
      ],
      rows: [
        for (final r in rows)
          _TableRow(cells: [
            _TextCell(r.customerGroup, flex: 3),
            _TextCell(
              formatCount(context, r.clientCount),
              flex: 1,
              align: TextAlign.end,
            ),
            _TextCell(
              formatCompactCurrency(context, r.revenue),
              flex: 2,
              align: TextAlign.end,
            ),
          ]),
      ],
    );
  }
}

// ── Reorder due (table) ──────────────────────────────────────────────────

class _ReorderDueTable extends StatelessWidget {
  final List<B2bReorderDueClient> rows;
  const _ReorderDueTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _TableCard(
      title: l10n.reportReorderDue,
      isEmpty: rows.isEmpty,
      header: const [
        _Col('', 3),
        _Col('', 2),
        _Col('', 2),
      ],
      rows: [
        for (final r in rows)
          _TableRow(cells: [
            _TextCell(
              r.customerName.isEmpty ? r.customer : r.customerName,
              flex: 3,
            ),
            _TextCell(
              formatDateString(context, r.lastOrderDate),
              flex: 2,
              align: TextAlign.end,
            ),
            _TextCell(
              '${r.daysSince}d',
              flex: 2,
              align: TextAlign.end,
              color: Colors.orange.shade800,
            ),
          ]),
      ],
    );
  }
}

// ── At-risk clients (table) ──────────────────────────────────────────────

class _AtRiskTable extends StatelessWidget {
  final List<B2bAtRiskClient> rows;
  const _AtRiskTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _TableCard(
      title: l10n.reportAtRiskClients,
      isEmpty: rows.isEmpty,
      header: const [
        _Col('', 3),
        _Col('', 2),
        _Col('', 2),
      ],
      rows: [
        for (final r in rows)
          _TableRow(cells: [
            _TextCell(
              r.customerName.isEmpty ? r.customer : r.customerName,
              flex: 3,
            ),
            _TextCell(
              '${r.recencyDays}d',
              flex: 2,
              align: TextAlign.end,
              color: Colors.red.shade700,
            ),
            _TextCell(
              formatCompactCurrency(context, r.revenue),
              flex: 2,
              align: TextAlign.end,
            ),
          ], trailing: _SegmentChip(segment: r.segment)),
      ],
    );
  }
}

// ── Conversion (stat row) ────────────────────────────────────────────────

class _ConversionCard extends StatelessWidget {
  final B2bConversion conversion;
  const _ConversionCard({required this.conversion});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reportConversion,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Stat(
                  label: l10n.reportSalesPipeline,
                  value: formatCount(context, conversion.opportunities),
                  color: Colors.indigo,
                ),
                _Stat(
                  label: l10n.reportKpiB2bOrders,
                  value: formatCount(context, conversion.won),
                  color: Colors.green,
                ),
                _Stat(
                  label: l10n.reportConversion,
                  value: _pct(conversion.conversionRate),
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Shared small building blocks ─────────────────────────────────────────

class _SegmentChip extends StatelessWidget {
  final String segment;
  const _SegmentChip({required this.segment});

  @override
  Widget build(BuildContext context) {
    if (segment.trim().isEmpty) return const SizedBox.shrink();
    final color = _segmentColor(segment);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        segment,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  static Color _segmentColor(String segment) {
    switch (segment.toLowerCase()) {
      case 'champion':
      case 'champions':
        return Colors.green;
      case 'loyal':
        return Colors.teal;
      case 'at risk':
      case 'at-risk':
        return Colors.orange;
      case 'lost':
        return Colors.red;
      case 'new':
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }
}

class _LegendItem {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});
}

class _Legend extends StatelessWidget {
  final List<_LegendItem> items;
  const _Legend({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(item.label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.labelSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Column descriptor for [_TableCard]: an (unused-when-empty) header label and
/// its flex weight, kept parallel to the per-row cells.
class _Col {
  final String label;
  final int flex;
  const _Col(this.label, this.flex);
}

class _TextCell {
  final String text;
  final int flex;
  final TextAlign align;
  final Color? color;
  const _TextCell(
    this.text, {
    required this.flex,
    this.align = TextAlign.start,
    this.color,
  });
}

class _TableRow {
  final List<_TextCell> cells;
  final Widget? trailing;
  const _TableRow({required this.cells, this.trailing});
}

/// A lightweight, RTL-safe table rendered as a titled card. Uses [Expanded]
/// cells (no fixed pixel columns) so it reflows in Arabic and on narrow phones.
class _TableCard extends StatelessWidget {
  final String title;
  final List<_Col> header;
  final List<_TableRow> rows;
  final bool isEmpty;

  const _TableCard({
    required this.title,
    required this.header,
    required this.rows,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    context.l10n.reportNoData,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              for (var i = 0; i < rows.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      top: i == 0
                          ? BorderSide.none
                          : BorderSide(
                              color: theme.dividerColor.withValues(alpha: 0.4),
                            ),
                    ),
                  ),
                  child: Row(
                    children: [
                      for (final cell in rows[i].cells)
                        Expanded(
                          flex: cell.flex,
                          child: Text(
                            cell.text,
                            textAlign: cell.align,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cell.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (rows[i].trailing != null) ...[
                        const SizedBox(width: 8),
                        rows[i].trailing!,
                      ],
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

String _shortDate(BuildContext context, String iso) {
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso;
  return DateFormat.MMMd(context.l10n.localeName).format(parsed);
}
