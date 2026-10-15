import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/report_envelopes.dart';
import '../../data/models/shipping_analytics.dart';
import '../../state/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_alerts_card.dart';
import '../widgets/report_export_button.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_section_card.dart';
import '../widgets/report_states.dart';
import '../widgets/report_table.dart';

/// Shipping: what couriers cost against what customers were charged, where
/// shipping loses money, courier cost overrides, and what is still owed to
/// couriers. Keyed by the shared range + branch ([reportQueryProvider]).
/// RTL-safe (directional layout, `start`/`end` alignment throughout).
class ShippingAnalyticsScreen extends ConsumerWidget {
  const ShippingAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final q = ref.watch(reportQueryProvider);
    final async = ref.watch(shippingReportProvider(q));

    Future<void> refresh() => ref.refresh(shippingReportProvider(q).future);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportShippingTitle),
        actions: [
          ReportExportButton(
            title: l10n.reportShippingTitle,
            rows: () => _shippingExportRows(context, async.valueOrNull),
          ),
        ],
      ),
      body: Column(
        children: [
          const ReportFilterBar(),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => RefreshIndicator(
                onRefresh: refresh,
                child: ReportErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(shippingReportProvider(q)),
                ),
              ),
              data: (report) => RefreshIndicator(
                onRefresh: refresh,
                child: _DataView(report: report),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CSV: the per-area table, then the unsettled courier balances.
List<List<String>> _shippingExportRows(
  BuildContext context,
  ShippingReport? report,
) {
  if (report == null) return const [];
  final l10n = context.l10n;
  final d = report.data;
  String n(num v) => v.toStringAsFixed(2);
  final areas = [...d.costByTerritory]
    ..sort((a, b) => a.netPl.compareTo(b.netPl));
  return [
    [
      l10n.rptG1ColArea,
      l10n.reportKpiOrders,
      l10n.rptG1ColCost,
      l10n.rptG1ColCharged,
      l10n.rptG1ColNet,
    ],
    for (final r in areas)
      [r.territory, '${r.orderCount}', n(r.totalExpense), n(r.totalIncome),
        n(r.netPl)],
    if (d.unsettledCourierBalances.isNotEmpty) ...[
      const <String>[],
      [
        l10n.rptG1ColCourier,
        l10n.reportKpiOrders,
        l10n.rptG1ColOwed,
        l10n.rptG1ColDaysAged,
      ],
      for (final r in d.unsettledCourierBalances)
        [r.party, '${r.orderCount}', n(r.totalOwed), '${r.daysAged}'],
    ],
  ];
}

// ─────────────────────────────────────────────────────────────────────────
// Data view
// ─────────────────────────────────────────────────────────────────────────

class _DataView extends StatelessWidget {
  final ShippingReport report;
  const _DataView({required this.report});

  @override
  Widget build(BuildContext context) {
    final data = report.data;
    final alerts = [
      for (final a in data.alerts)
        ReportAlert(
          message: a.message,
          severity: ReportAlertSeverity.parse(a.type),
        ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 24),
          children: [
            // The grid pads 8 on each side: measuring the full width made
            // two cards 8px too wide to share a row, so they stacked.
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
              child: _KpiGrid(
                kpis: data.summaryKpis,
                maxWidth: constraints.maxWidth - 16,
              ),
            ),
            const SizedBox(height: 6),
            if (alerts.isNotEmpty) ReportAlertsCard(alerts: alerts),
            _CostVsChargedSection(points: data.dailyTrend),
            _LossByAreaSection(rows: data.costByTerritory),
            _CourierSection(rows: data.costByCourier),
            if (data.unsettledCourierBalances.isNotEmpty)
              _UnsettledBalancesSection(
                rows: data.unsettledCourierBalances,
                asOf: report.unsettledAsOf,
              ),
            if (data.doubleShippingImpact.trips.isNotEmpty ||
                data.doubleShippingImpact.totalDoubleTrips > 0)
              _DoubleShippingSection(impact: data.doubleShippingImpact),
            if (data.customShippingBreakdown.rows.isNotEmpty)
              _OverridesSection(breakdown: data.customShippingBreakdown),
          ],
        );
      },
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
        label: l10n.reportShipKpiDeliveryOrders,
        value: formatCount(context, kpis.deliveryOrders),
        icon: Icons.local_shipping_outlined,
      ),
      KpiCard(
        label: l10n.reportShipKpiIncome,
        value: formatCompactCurrency(context, kpis.totalIncome),
        icon: Icons.trending_up,
        color: positive,
      ),
      KpiCard(
        label: l10n.reportShipKpiExpense,
        value: formatCompactCurrency(context, kpis.totalExpense),
        icon: Icons.trending_down,
        color: negative,
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
        label: l10n.reportShipKpiUnsettled,
        value: formatCompactCurrency(context, kpis.unsettledCourierTotal),
        icon: Icons.pending_actions_outlined,
        color: kpis.unsettledCourierTotal > 0 ? Colors.orange.shade800 : null,
      ),
    ];

    const spacing = 8.0;
    final crossCount = (maxWidth / 180).floor().clamp(2, 4);
    // floorToDouble: fractional widths can still round past the row.
    final cardWidth =
        ((maxWidth - spacing * (crossCount - 1)) / crossCount).floorToDouble();

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
// Shared chart helpers
// ─────────────────────────────────────────────────────────────────────────

String _axisNum(BuildContext context, num v) =>
    NumberFormat.compact(locale: context.l10n.localeName).format(v);

String _shortDate(BuildContext context, String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return DateFormat('M/d', context.l10n.localeName).format(d);
}

/// Keep charts readable by capping to the first [n] rows by [order].
List<T> _firstN<T>(List<T> rows, int Function(T a, T b) order, [int n = 8]) {
  final sorted = [...rows]..sort(order);
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

/// "No data" inside a section card, at chart height so the page doesn't jump.
class _NoData extends StatelessWidget {
  const _NoData();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 80,
      child: Center(
        child: Text(
          context.l10n.reportNoData,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

FlTitlesData _titles(BuildContext context, List<String> labels, double maxY) {
  final interval = maxY <= 0 ? 1.0 : maxY / 4;
  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        interval: interval,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          axisSide: meta.axisSide,
          space: 4,
          child: Text(
            _axisNum(context, value),
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
          // Thin out long date axes so labels don't collide.
          final step = (labels.length / 8).ceil();
          if (step > 1 && idx % step != 0) return const SizedBox.shrink();
          var label = labels[idx];
          if (label.length > 8) label = '${label.substring(0, 7)}…';
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 4,
            child: Text(label, style: const TextStyle(fontSize: 9)),
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
    final s2 = series2;
    var maxV = 0.0;
    for (var i = 0; i < series1.length; i++) {
      maxV = math.max(maxV, series1[i]);
      if (s2 != null) maxV = math.max(maxV, s2[i]);
    }
    final maxY = maxV <= 0 ? 1.0 : maxV * 1.2;

    final groups = <BarChartGroupData>[];
    for (var i = 0; i < labels.length; i++) {
      final rods = <BarChartRodData>[
        BarChartRodData(
          toY: series1[i],
          color: color1,
          width: s2 == null ? 12 : 8,
          borderRadius: BorderRadius.circular(2),
        ),
        if (s2 != null)
          BarChartRodData(
            toY: s2[i],
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
        titlesData: _titles(context, labels, maxY),
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
        titlesData: _titles(context, labels, maxY),
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
          preventCurveOverShooting: true,
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
        titlesData: _titles(context, labels, maxY),
        lineTouchData: const LineTouchData(enabled: true),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Courier cost vs charged (daily line)
// ─────────────────────────────────────────────────────────────────────────

class _CostVsChargedSection extends StatelessWidget {
  final List<ShippingDailyTrendPoint> points;
  const _CostVsChargedSection({required this.points});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final costColor = Theme.of(context).colorScheme.error;
    final chargedColor = Colors.green.shade700;

    return ReportSectionCard(
      title: l10n.rptG1ShipCostVsCharged,
      subtitle: l10n.rptG1ShipCostVsChargedHint,
      child: points.isEmpty
          ? const _NoData()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 200,
                  child: _TrendLineChart(
                    labels: [
                      for (final p in points) _shortDate(context, p.postingDate),
                    ],
                    series: [
                      [for (final p in points) p.totalExpense],
                      [for (final p in points) p.totalIncome],
                    ],
                    colors: [costColor, chargedColor],
                  ),
                ),
                _LegendRow(
                  items: [
                    MapEntry(l10n.rptG1ColCost, costColor),
                    MapEntry(l10n.rptG1ColCharged, chargedColor),
                  ],
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Loss by area (grouped bars + table, biggest loss first)
// ─────────────────────────────────────────────────────────────────────────

class _LossByAreaSection extends StatelessWidget {
  final List<ShippingTerritoryCost> rows;
  const _LossByAreaSection({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final costColor = theme.colorScheme.error;
    final chargedColor = Colors.green.shade700;
    final sorted = [...rows]..sort((a, b) => a.netPl.compareTo(b.netPl));
    final chart = _firstN(sorted, (a, b) => a.netPl.compareTo(b.netPl));

    return ReportSectionCard(
      title: l10n.rptG1ShipLossByArea,
      subtitle: l10n.rptG1ShipLossByAreaHint,
      child: sorted.isEmpty
          ? const _NoData()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 200,
                  child: _CategoryBarChart(
                    labels: [for (final r in chart) r.territory],
                    series1: [for (final r in chart) r.totalExpense],
                    color1: costColor,
                    series2: [for (final r in chart) r.totalIncome],
                    color2: chargedColor,
                  ),
                ),
                _LegendRow(
                  items: [
                    MapEntry(l10n.rptG1ColCost, costColor),
                    MapEntry(l10n.rptG1ColCharged, chargedColor),
                  ],
                ),
                const SizedBox(height: 8),
                ReportTable(
                  maxRows: 10,
                  columns: [
                    ReportColumn(l10n.rptG1ColArea, flex: 3),
                    ReportColumn(l10n.reportKpiOrders, numeric: true, flex: 2),
                    ReportColumn(l10n.rptG1ColCost, numeric: true, flex: 2),
                    ReportColumn(l10n.rptG1ColCharged, numeric: true, flex: 2),
                    ReportColumn(l10n.rptG1ColNet, numeric: true, flex: 2),
                  ],
                  rows: [
                    for (final r in sorted)
                      [
                        r.territory,
                        formatCount(context, r.orderCount),
                        formatCompactCurrency(context, r.totalExpense),
                        formatCompactCurrency(context, r.totalIncome),
                        formatCompactCurrency(context, r.netPl),
                      ],
                  ],
                  cellColor: (row, col) {
                    if (col != 4) return null;
                    return sorted[row].netPl >= 0 ? chargedColor : costColor;
                  },
                ),
              ],
            ),
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
    final top = _firstN(
      rows,
      (a, b) => (b.settled + b.unsettled).compareTo(a.settled + a.unsettled),
    );

    return ReportSectionCard(
      title: l10n.reportCostByCourier,
      child: top.isEmpty
          ? const _NoData()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 200,
                  child: _StackedBarChart(
                    labels: [for (final r in top) r.party],
                    bottom: [for (final r in top) r.settled],
                    top: [for (final r in top) r.unsettled],
                    bottomColor: settledColor,
                    topColor: unsettledColor,
                  ),
                ),
                _LegendRow(
                  items: [
                    MapEntry(l10n.rptG1Settled, settledColor),
                    MapEntry(l10n.reportShipKpiUnsettled, unsettledColor),
                  ],
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Unsettled courier balances (table)
// ─────────────────────────────────────────────────────────────────────────

class _UnsettledBalancesSection extends StatelessWidget {
  final List<ShippingUnsettledCourierBalance> rows;

  /// `YYYY-MM-DD` the balances are owed as of; null on an older backend.
  final String? asOf;

  const _UnsettledBalancesSection({required this.rows, this.asOf});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final owedColor = Colors.orange.shade800;
    final date = asOf;
    final sorted = [...rows]..sort((a, b) => b.totalOwed.compareTo(a.totalOwed));
    return ReportSectionCard(
      title: l10n.reportUnsettledBalances,
      subtitle: date == null || date.isEmpty
          ? null
          : l10n.rptG1UnsettledAsOf(formatDateString(context, date)),
      child: ReportTable(
        columns: [
          ReportColumn(l10n.rptG1ColCourier, flex: 3),
          ReportColumn(l10n.reportKpiOrders, numeric: true, flex: 2),
          ReportColumn(l10n.rptG1ColOwed, numeric: true, flex: 3),
          ReportColumn(l10n.rptG1ColDaysAged, numeric: true, flex: 2),
        ],
        rows: [
          for (final r in sorted)
            [
              r.party,
              formatCount(context, r.orderCount),
              formatCurrency(context, r.totalOwed),
              formatCount(context, r.daysAged),
            ],
        ],
        cellColor: (row, col) => col == 2 ? owedColor : null,
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
    final negative = Theme.of(context).colorScheme.error;
    return ReportSectionCard(
      title: l10n.reportDoubleShipping,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: l10n.rptG1DoubleTrips,
                  value: formatCount(context, impact.totalDoubleTrips),
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: l10n.rptG1DoubleExtraCost,
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
    // The double-shipping payload spells this `double_shipping_territory`;
    // reading only `territory` meant the label never rendered.
    final territory =
        (trip['double_shipping_territory'] ?? trip['territory'] ?? '')
            .toString();
    final rawCost = trip['extra_cost'] ?? trip['total_extra_cost'];
    final cost = rawCost is num ? rawCost : num.tryParse('$rawCost');

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 3),
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
// Courier cost overrides (money summary + by area)
// ─────────────────────────────────────────────────────────────────────────

/// Courier-cost overrides as money, not as a list of orders: how much more
/// (or less) was paid than each area's standard rate, how often it happens,
/// and where. The per-order approvals live on the Manager Dashboard.
class _OverridesSection extends StatelessWidget {
  final ShippingCustomBreakdown breakdown;
  const _OverridesSection({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final s = breakdown.summary;
    final extraColor = theme.colorScheme.error;
    final savedColor = Colors.green.shade700;
    final netColor = s.netEffect > 0 ? extraColor : savedColor;
    String pct(double v) => v.toStringAsFixed(v.abs() >= 10 ? 0 : 1);

    return ReportSectionCard(
      title: l10n.reportOverridesTitle,
      subtitle: l10n.reportOverridesHint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.reportOverridesNetExtra, style: theme.textTheme.labelMedium),
          Text(
            formatCurrency(context, s.netEffect),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: netColor,
            ),
          ),
          Text(
            l10n.reportOverridesVsStandard(pct(s.netEffectPct)),
            style: theme.textTheme.labelSmall,
          ),
          const Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OverrideStat(
                label: l10n.reportOverridesExtraPaid,
                value: formatCurrency(context, s.approvedExtra),
                sub: l10n.reportOverridesIncreases(
                  s.increases,
                  formatCurrency(context, s.avgIncrease),
                ),
                color: extraColor,
              ),
              const SizedBox(width: 8),
              _OverrideStat(
                label: l10n.reportOverridesSaved,
                value: formatCurrency(context, s.approvedSaved),
                sub: l10n.reportOverridesDecreases(s.decreases),
                color: savedColor,
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OverrideStat(
                label: l10n.reportOverridesShare,
                value: '${pct(s.exceptionRatePct)}%',
                sub: l10n.reportOverridesShareOf(s.approved, s.deliveryOrders),
              ),
              const SizedBox(width: 8),
              _OverrideStat(
                label: l10n.reportOverridesDecisions,
                value: '${pct(s.approvalRate)}%',
                sub: l10n.reportOverridesDecisionsValue(
                  s.approved,
                  s.rejected,
                  s.pending,
                ),
              ),
            ],
          ),
          if (s.maxIncreasePct > 0)
            Text(
              l10n.reportOverridesLargest(pct(s.maxIncreasePct)),
              style: theme.textTheme.labelSmall,
            ),
          if (s.pending > 0 && s.pendingExtra != 0)
            Text(
              l10n.reportOverridesPendingExtra(
                formatCurrency(context, s.pendingExtra),
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.orange.shade800,
              ),
            ),
          if (breakdown.byArea.isNotEmpty) ...[
            const Divider(height: 20),
            Text(
              l10n.reportOverridesByArea,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            for (final a in breakdown.byArea)
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${a['territory'] ?? ''}',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      l10n.rptG1OverridesCount(
                        (a['count'] as num?)?.toInt() ?? 0,
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      formatCurrency(
                        context,
                        (a['net'] as num?)?.toDouble() ?? 0,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: extraColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _OverrideStat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color? color;
  const _OverrideStat({
    required this.label,
    required this.value,
    required this.sub,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Expanded(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: muted),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(sub, style: muted),
          ],
        ),
      ),
    );
  }
}
