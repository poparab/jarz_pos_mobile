import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/shipping_analytics.dart';
import '../../state/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_alert_text.dart';
import '../widgets/report_chart_card.dart';
import '../widgets/report_date_range_bar.dart';

/// Shipping Analytics dashboard: delivery cost, courier settlements and
/// shipping P&L. Consumes [shippingAnalyticsProvider] keyed by the shared
/// [reportRangeProvider]. RTL-safe (uses directional layout + `start/end`).
class ShippingAnalyticsScreen extends ConsumerWidget {
  const ShippingAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(reportRangeProvider);
    final async = ref.watch(shippingAnalyticsProvider(range));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportShippingTitle)),
      body: Column(
        children: [
          const ReportDateRangeBar(),
          Expanded(
            child: async.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(range: range),
              data: (data) => _DataView(data: data, range: range),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Error / retry
// ─────────────────────────────────────────────────────────────────────────

class _ErrorView extends ConsumerWidget {
  final ReportRange range;
  const _ErrorView({required this.range});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(l10n.reportError, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () =>
                ref.invalidate(shippingAnalyticsProvider(range)),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.reportsRetry),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Data view
// ─────────────────────────────────────────────────────────────────────────

class _DataView extends ConsumerWidget {
  final ShippingAnalytics data;
  final ReportRange range;
  const _DataView({required this.data, required this.range});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(shippingAnalyticsProvider(range));
        await ref.read(shippingAnalyticsProvider(range).future);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 24),
            children: [
              _KpiGrid(kpis: data.summaryKpis, maxWidth: constraints.maxWidth),
              if (data.alerts.isNotEmpty) ...[
                const SizedBox(height: 12),
                _AlertsCard(alerts: data.alerts),
              ],
              const SizedBox(height: 12),
              _TerritorySection(rows: data.costByTerritory),
              const SizedBox(height: 12),
              _BranchSection(rows: data.costByPosProfile),
              const SizedBox(height: 12),
              _CourierSection(rows: data.costByCourier),
              const SizedBox(height: 12),
              _PickupDeliverySection(
                split: data.pickupVsDeliverySplit,
                subTerritories: data.costBySubTerritory,
              ),
              const SizedBox(height: 12),
              _DailyTrendSection(points: data.dailyTrend),
              const SizedBox(height: 12),
              _PickupDeliveryTrendSection(points: data.pickupDeliveryTrend),
              if (data.unsettledCourierBalances.isNotEmpty) ...[
                const SizedBox(height: 12),
                _UnsettledBalancesSection(rows: data.unsettledCourierBalances),
              ],
              if (data.doubleShippingImpact.trips.isNotEmpty ||
                  data.doubleShippingImpact.totalDoubleTrips > 0) ...[
                const SizedBox(height: 12),
                _DoubleShippingSection(impact: data.doubleShippingImpact),
              ],
              if (data.customShippingBreakdown.rows.isNotEmpty) ...[
                const SizedBox(height: 12),
                _OverridesSection(breakdown: data.customShippingBreakdown),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// KPI grid
// ─────────────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final ShippingSummaryKpis kpis;
  final double maxWidth;
  const _KpiGrid({required this.kpis, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final positive = Colors.green.shade700;
    final negative = theme.colorScheme.error;
    final netColor = kpis.netPl >= 0 ? positive : negative;

    final tiles = <Widget>[
      KpiCard(
        label: l10n.reportShipKpiTotalOrders,
        value: formatCount(context, kpis.totalOrders),
        icon: Icons.receipt_long_outlined,
      ),
      KpiCard(
        label: l10n.reportShipKpiDeliveryOrders,
        value: formatCount(context, kpis.deliveryOrders),
        icon: Icons.local_shipping_outlined,
      ),
      KpiCard(
        label: l10n.reportShipKpiPickupOrders,
        value: formatCount(context, kpis.pickupOrders),
        icon: Icons.store_outlined,
      ),
      KpiCard(
        label: l10n.reportShipKpiExpense,
        value: formatCompactCurrency(context, kpis.totalExpense),
        icon: Icons.trending_down,
        color: negative,
      ),
      KpiCard(
        label: l10n.reportShipKpiIncome,
        value: formatCompactCurrency(context, kpis.totalIncome),
        icon: Icons.trending_up,
        color: positive,
      ),
      KpiCard(
        label: l10n.reportShipKpiNetPl,
        value: formatCompactCurrency(context, kpis.netPl),
        icon: Icons.account_balance_wallet_outlined,
        color: netColor,
      ),
      KpiCard(
        label: l10n.reportShipKpiAvgCost,
        value: formatCurrency(context, kpis.avgCostPerOrder),
        icon: Icons.calculate_outlined,
      ),
      KpiCard(
        label: l10n.reportShipKpiPendingOverrides,
        value: formatCount(context, kpis.pendingCsrCount),
        icon: Icons.rule_outlined,
        color: kpis.pendingCsrCount > 0 ? Colors.orange.shade800 : null,
      ),
      KpiCard(
        label: l10n.reportShipKpiUnsettled,
        value: formatCurrency(context, kpis.unsettledCourierTotal),
        icon: Icons.pending_actions_outlined,
        color: kpis.unsettledCourierTotal > 0 ? Colors.orange.shade800 : null,
      ),
    ];

    const spacing = 8.0;
    final crossCount = (maxWidth / 180).floor().clamp(2, 4);
    final cardWidth =
        (maxWidth - spacing * (crossCount - 1)) / crossCount;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (final t in tiles) SizedBox(width: cardWidth, child: t),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────────────────────────────

Color _alertColor(BuildContext context, String type) {
  final theme = Theme.of(context);
  switch (type) {
    case 'danger':
      return theme.colorScheme.error;
    case 'warning':
      return Colors.orange.shade800;
    default:
      return theme.colorScheme.primary;
  }
}

IconData _alertIcon(String type) {
  switch (type) {
    case 'danger':
      return Icons.error_outline;
    case 'warning':
      return Icons.warning_amber_outlined;
    default:
      return Icons.info_outline;
  }
}

class _AlertsCard extends StatelessWidget {
  final List<ShippingAlert> alerts;
  const _AlertsCard({required this.alerts});

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.reportAlerts,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final a in alerts)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _alertIcon(a.type),
                      size: 18,
                      color: _alertColor(context, a.type),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stripHtml(a.message),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shared chart helpers
// ─────────────────────────────────────────────────────────────────────────

String _axisNum(num v) {
  final a = v.abs();
  if (a >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (a >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
  return v.toStringAsFixed(0);
}

String _shortDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return DateFormat('M/d').format(d);
}

/// Keep charts readable by capping to the top [n] rows by [metric].
List<T> _topN<T>(List<T> rows, num Function(T) metric, [int n = 8]) {
  final sorted = [...rows]..sort((a, b) => metric(b).compareTo(metric(a)));
  return sorted.length > n ? sorted.sublist(0, n) : sorted;
}

class _LegendRow extends StatelessWidget {
  final List<MapEntry<String, Color>> items;
  const _LegendRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 8, start: 4),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          for (final e in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: e.value,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(e.key, style: theme.textTheme.labelSmall),
              ],
            ),
        ],
      ),
    );
  }
}

FlTitlesData _titles(List<String> labels, double maxY) {
  final interval = maxY <= 0 ? 1.0 : maxY / 4;
  return FlTitlesData(
    topTitles:
        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles:
        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        interval: interval,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          axisSide: meta.axisSide,
          space: 4,
          child: Text(
            _axisNum(value),
            style: const TextStyle(fontSize: 9),
          ),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 34,
        interval: 1,
        getTitlesWidget: (value, meta) {
          final idx = value.round();
          if (idx < 0 || idx >= labels.length) {
            return const SizedBox.shrink();
          }
          if ((value - idx).abs() > 0.01) return const SizedBox.shrink();
          var label = labels[idx];
          if (label.length > 8) label = '${label.substring(0, 7)}…';
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 9),
            ),
          );
        },
      ),
    ),
  );
}

/// A grouped (or single-series) vertical bar chart.
class _CategoryBarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> series1;
  final Color color1;
  final List<double>? series2;
  final Color? color2;

  const _CategoryBarChart({
    required this.labels,
    required this.series1,
    required this.color1,
    this.series2,
    this.color2,
  });

  @override
  Widget build(BuildContext context) {
    var maxV = 0.0;
    for (var i = 0; i < series1.length; i++) {
      maxV = math.max(maxV, series1[i]);
      if (series2 != null) maxV = math.max(maxV, series2![i]);
    }
    final maxY = maxV <= 0 ? 1.0 : maxV * 1.2;

    final groups = <BarChartGroupData>[];
    for (var i = 0; i < labels.length; i++) {
      final rods = <BarChartRodData>[
        BarChartRodData(
          toY: series1[i],
          color: color1,
          width: series2 == null ? 12 : 8,
          borderRadius: BorderRadius.circular(2),
        ),
        if (series2 != null)
          BarChartRodData(
            toY: series2![i],
            color: color2,
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
      ];
      groups.add(BarChartGroupData(x: i, barsSpace: 4, barRods: rods));
    }

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        barGroups: groups,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: _titles(labels, maxY),
        barTouchData: BarTouchData(enabled: true),
      ),
    );
  }
}

/// A stacked vertical bar chart (one bar per category, two stacked segments).
class _StackedBarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> bottom;
  final List<double> top;
  final Color bottomColor;
  final Color topColor;

  const _StackedBarChart({
    required this.labels,
    required this.bottom,
    required this.top,
    required this.bottomColor,
    required this.topColor,
  });

  @override
  Widget build(BuildContext context) {
    var maxV = 0.0;
    for (var i = 0; i < labels.length; i++) {
      maxV = math.max(maxV, bottom[i] + top[i]);
    }
    final maxY = maxV <= 0 ? 1.0 : maxV * 1.2;

    final groups = <BarChartGroupData>[];
    for (var i = 0; i < labels.length; i++) {
      final total = bottom[i] + top[i];
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: total,
              width: 12,
              borderRadius: BorderRadius.circular(2),
              rodStackItems: [
                BarChartRodStackItem(0, bottom[i], bottomColor),
                BarChartRodStackItem(bottom[i], total, topColor),
              ],
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        barGroups: groups,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: _titles(labels, maxY),
        barTouchData: BarTouchData(enabled: true),
      ),
    );
  }
}

/// A multi-line trend chart.
class _TrendLineChart extends StatelessWidget {
  final List<String> labels;
  final List<List<double>> series;
  final List<Color> colors;

  const _TrendLineChart({
    required this.labels,
    required this.series,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    var maxV = 0.0;
    for (final s in series) {
      for (final v in s) {
        maxV = math.max(maxV, v);
      }
    }
    final maxY = maxV <= 0 ? 1.0 : maxV * 1.2;

    final bars = <LineChartBarData>[];
    for (var s = 0; s < series.length; s++) {
      bars.add(
        LineChartBarData(
          isCurved: true,
          barWidth: 2,
          color: colors[s],
          dotData: const FlDotData(show: false),
          spots: [
            for (var i = 0; i < series[s].length; i++)
              FlSpot(i.toDouble(), series[s][i]),
          ],
        ),
      );
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        lineBarsData: bars,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: _titles(labels, maxY),
        lineTouchData: const LineTouchData(enabled: true),
      ),
    );
  }
}

/// A pie / donut chart.
class _PieChartView extends StatelessWidget {
  final List<_PieSlice> slices;
  final double centerSpaceRadius;
  const _PieChartView({
    required this.slices,
    this.centerSpaceRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<double>(0, (s, e) => s + e.value);
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: centerSpaceRadius,
        sections: [
          for (final s in slices)
            PieChartSectionData(
              value: s.value,
              color: s.color,
              radius: 70,
              title: total <= 0
                  ? ''
                  : '${(s.value / total * 100).toStringAsFixed(0)}%',
              titleStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

class _PieSlice {
  final String label;
  final double value;
  final Color color;
  const _PieSlice(this.label, this.value, this.color);
}

// ─────────────────────────────────────────────────────────────────────────
// Cost by territory (grouped bar + P&L rows)
// ─────────────────────────────────────────────────────────────────────────

class _TerritorySection extends StatelessWidget {
  final List<ShippingTerritoryCost> rows;
  const _TerritorySection({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final expenseColor = theme.colorScheme.error;
    final incomeColor = Colors.green.shade700;
    final top = _topN(rows, (r) => r.totalExpense);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportChartCard(
          title: l10n.reportCostByTerritory,
          isEmpty: top.isEmpty,
          emptyText: l10n.reportNoData,
          child: _CategoryBarChart(
            labels: [for (final r in top) r.territory],
            series1: [for (final r in top) r.totalExpense],
            color1: expenseColor,
            series2: [for (final r in top) r.totalIncome],
            color2: incomeColor,
          ),
        ),
        if (top.isNotEmpty)
          _LegendRow(items: [
            MapEntry(l10n.reportShipKpiExpense, expenseColor),
            MapEntry(l10n.reportShipKpiIncome, incomeColor),
          ]),
        if (top.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final r in top)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              r.territory,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          Text(
                            formatCurrency(context, r.netPl),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: r.netPl >= 0
                                  ? incomeColor
                                  : expenseColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Cost by branch (grouped bar)
// ─────────────────────────────────────────────────────────────────────────

class _BranchSection extends StatelessWidget {
  final List<ShippingPosProfileCost> rows;
  const _BranchSection({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final expenseColor = theme.colorScheme.error;
    final incomeColor = Colors.green.shade700;
    final top = _topN(rows, (r) => r.totalExpense);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportChartCard(
          title: l10n.reportCostByBranch,
          isEmpty: top.isEmpty,
          emptyText: l10n.reportNoData,
          child: _CategoryBarChart(
            labels: [for (final r in top) r.branch],
            series1: [for (final r in top) r.totalExpense],
            color1: expenseColor,
            series2: [for (final r in top) r.totalIncome],
            color2: incomeColor,
          ),
        ),
        if (top.isNotEmpty)
          _LegendRow(items: [
            MapEntry(l10n.reportShipKpiExpense, expenseColor),
            MapEntry(l10n.reportShipKpiIncome, incomeColor),
          ]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Cost by courier (stacked bar settled vs unsettled)
// ─────────────────────────────────────────────────────────────────────────

class _CourierSection extends StatelessWidget {
  final List<ShippingCourierCost> rows;
  const _CourierSection({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settledColor = Colors.green.shade700;
    final unsettledColor = Colors.orange.shade800;
    final top = _topN(rows, (r) => r.settled + r.unsettled);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportChartCard(
          title: l10n.reportCostByCourier,
          isEmpty: top.isEmpty,
          emptyText: l10n.reportNoData,
          child: _StackedBarChart(
            labels: [for (final r in top) r.party],
            bottom: [for (final r in top) r.settled],
            top: [for (final r in top) r.unsettled],
            bottomColor: settledColor,
            topColor: unsettledColor,
          ),
        ),
        if (top.isNotEmpty)
          _LegendRow(items: [
            MapEntry('Settled', settledColor),
            MapEntry(l10n.reportShipKpiUnsettled, unsettledColor),
          ]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Pickup vs delivery (pie) + cost by sub-territory (bar)
// ─────────────────────────────────────────────────────────────────────────

class _PickupDeliverySection extends StatelessWidget {
  final ShippingPickupDeliverySplit split;
  final List<ShippingSubTerritoryCost> subTerritories;
  const _PickupDeliverySection({
    required this.split,
    required this.subTerritories,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pickupColor = Colors.blue.shade600;
    final deliveryColor = Colors.indigo.shade400;
    final splitEmpty = split.pickup == 0 && split.delivery == 0;
    final expenseColor = Theme.of(context).colorScheme.error;
    final top = _topN(subTerritories, (r) => r.totalExpense);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportChartCard(
          title: l10n.reportPickupVsDelivery,
          isEmpty: splitEmpty,
          emptyText: l10n.reportNoData,
          child: _PieChartView(
            slices: [
              _PieSlice(
                l10n.reportShipKpiPickupOrders,
                split.pickup.toDouble(),
                pickupColor,
              ),
              _PieSlice(
                l10n.reportShipKpiDeliveryOrders,
                split.delivery.toDouble(),
                deliveryColor,
              ),
            ],
          ),
        ),
        if (!splitEmpty)
          _LegendRow(items: [
            MapEntry(l10n.reportShipKpiPickupOrders, pickupColor),
            MapEntry(l10n.reportShipKpiDeliveryOrders, deliveryColor),
          ]),
        const SizedBox(height: 12),
        ReportChartCard(
          title: l10n.reportCostBySubTerritory,
          isEmpty: top.isEmpty,
          emptyText: l10n.reportNoData,
          child: _CategoryBarChart(
            labels: [for (final r in top) r.subTerritory],
            series1: [for (final r in top) r.totalExpense],
            color1: expenseColor,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Daily trend (line: expense & income)
// ─────────────────────────────────────────────────────────────────────────

class _DailyTrendSection extends StatelessWidget {
  final List<ShippingDailyTrendPoint> points;
  const _DailyTrendSection({required this.points});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final expenseColor = theme.colorScheme.error;
    final incomeColor = Colors.green.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportChartCard(
          title: l10n.reportDailyTrend,
          isEmpty: points.isEmpty,
          emptyText: l10n.reportNoData,
          child: _TrendLineChart(
            labels: [for (final p in points) _shortDate(p.postingDate)],
            series: [
              [for (final p in points) p.totalExpense],
              [for (final p in points) p.totalIncome],
            ],
            colors: [expenseColor, incomeColor],
          ),
        ),
        if (points.isNotEmpty)
          _LegendRow(items: [
            MapEntry(l10n.reportShipKpiExpense, expenseColor),
            MapEntry(l10n.reportShipKpiIncome, incomeColor),
          ]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Pickup / delivery trend (stacked bars)
// ─────────────────────────────────────────────────────────────────────────

class _PickupDeliveryTrendSection extends StatelessWidget {
  final List<ShippingPickupDeliveryTrendPoint> points;
  const _PickupDeliveryTrendSection({required this.points});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pickupColor = Colors.blue.shade600;
    final deliveryColor = Colors.indigo.shade400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportChartCard(
          title: l10n.reportPickupDeliveryTrend,
          isEmpty: points.isEmpty,
          emptyText: l10n.reportNoData,
          child: _StackedBarChart(
            labels: [for (final p in points) _shortDate(p.postingDate)],
            bottom: [for (final p in points) p.pickup.toDouble()],
            top: [for (final p in points) p.delivery.toDouble()],
            bottomColor: pickupColor,
            topColor: deliveryColor,
          ),
        ),
        if (points.isNotEmpty)
          _LegendRow(items: [
            MapEntry(l10n.reportShipKpiPickupOrders, pickupColor),
            MapEntry(l10n.reportShipKpiDeliveryOrders, deliveryColor),
          ]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Unsettled courier balances (table)
// ─────────────────────────────────────────────────────────────────────────

class _UnsettledBalancesSection extends StatelessWidget {
  final List<ShippingUnsettledCourierBalance> rows;
  const _UnsettledBalancesSection({required this.rows});

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.reportUnsettledBalances,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.party,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '${formatCount(context, r.orderCount)} · ${r.daysAged}d',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        formatCurrency(context, r.totalOwed),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Double-shipping impact (summary + list)
// ─────────────────────────────────────────────────────────────────────────

class _DoubleShippingSection extends StatelessWidget {
  final ShippingDoubleImpact impact;
  const _DoubleShippingSection({required this.impact});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final negative = theme.colorScheme.error;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.reportDoubleShipping,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: l10n.reportShipKpiTotalOrders,
                    value: formatCount(context, impact.totalDoubleTrips),
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: l10n.reportShipKpiExpense,
                    value: formatCurrency(context, impact.totalExtraCost),
                    color: negative,
                  ),
                ),
              ],
            ),
            if (impact.trips.isNotEmpty) ...[
              const Divider(height: 20),
              for (final t in impact.trips) _DoubleTripRow(trip: t),
            ],
          ],
        ),
      ),
    );
  }
}

class _DoubleTripRow extends StatelessWidget {
  final Map<String, dynamic> trip;
  const _DoubleTripRow({required this.trip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = (trip['invoice'] ??
            trip['name'] ??
            trip['customer'] ??
            trip['party'] ??
            '—')
        .toString();
    final territory = (trip['territory'] ?? '').toString();
    final rawCost = trip['extra_cost'] ?? trip['total_extra_cost'];
    final cost = rawCost is num ? rawCost : num.tryParse('$rawCost');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                if (territory.isNotEmpty)
                  Text(
                    territory,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (cost != null)
            Text(
              formatCurrency(context, cost),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.error,
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _MiniStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shipping overrides (donut + table)
// ─────────────────────────────────────────────────────────────────────────

class _OverridesSection extends StatelessWidget {
  final ShippingCustomBreakdown breakdown;
  const _OverridesSection({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final s = breakdown.summary;
    final approvedColor = Colors.green.shade700;
    final rejectedColor = theme.colorScheme.error;
    final pendingColor = Colors.orange.shade800;
    final donutEmpty = s.total == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportChartCard(
          title: l10n.reportShippingOverrides,
          isEmpty: donutEmpty,
          emptyText: l10n.reportNoData,
          child: _PieChartView(
            centerSpaceRadius: 40,
            slices: [
              _PieSlice('', s.approved.toDouble(), approvedColor),
              _PieSlice('', s.rejected.toDouble(), rejectedColor),
              _PieSlice('', s.pending.toDouble(), pendingColor),
            ],
          ),
        ),
        if (!donutEmpty)
          _LegendRow(items: [
            MapEntry('Approved', approvedColor),
            MapEntry('Rejected', rejectedColor),
            MapEntry('Pending', pendingColor),
          ]),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final r in breakdown.rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (r.isLargeOverride) ...[
                                    Icon(
                                      Icons.priority_high,
                                      size: 14,
                                      color: theme.colorScheme.error,
                                    ),
                                    const SizedBox(width: 2),
                                  ],
                                  Flexible(
                                    child: Text(
                                      r.displayId,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${r.territory} · ${r.status}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            formatCurrency(context, r.delta),
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: r.delta >= 0
                                  ? theme.colorScheme.error
                                  : approvedColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
