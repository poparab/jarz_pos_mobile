import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/product_analytics.dart';
import '../../data/models/report_envelopes.dart';
import '../../data/models/report_json.dart';
import '../../state/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_chart_card.dart';
import '../widgets/report_export_button.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_states.dart';
import '../widgets/report_table.dart';

/// Product Analytics dashboard: revenue, gross profit and best sellers broken
/// down by product type, individual product, territory and time. Keyed by the
/// shared range + branch ([reportQueryProvider]). Each product's cost is
/// labelled actual (real cost of goods) or estimated (recipe/BOM), with the
/// share of revenue that is actual. Every section degrades to an empty state
/// instead of crashing on missing keys, and the layout is RTL-safe.
class ProductAnalyticsScreen extends ConsumerWidget {
  const ProductAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final q = ref.watch(reportQueryProvider);
    final async = ref.watch(productReportProvider(q));

    Future<void> refresh() => ref.refresh(productReportProvider(q).future);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportProductTitle),
        actions: [
          ReportExportButton(
            title: l10n.reportProductTitle,
            rows: () => _productExportRows(context, async.valueOrNull),
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
                  onRetry: () => ref.invalidate(productReportProvider(q)),
                ),
              ),
              data: (report) => RefreshIndicator(
                onRefresh: refresh,
                child: _ProductBody(report: report),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CSV: every top product with its cost basis.
List<List<String>> _productExportRows(
  BuildContext context,
  ProductReport? report,
) {
  if (report == null) return const [];
  final l10n = context.l10n;
  String n(double v) => v.toStringAsFixed(2);
  final rows = [for (final r in report.data.topProducts) _ProductRow.from(r)]
    ..sort((a, b) => b.revenue.compareTo(a.revenue));
  return [
    [
      l10n.reportsColumnItem,
      l10n.reportKpiTotalRevenue,
      l10n.rptG1Units,
      l10n.reportKpiGrossProfit,
      l10n.reportKpiGrossMargin,
      l10n.rptG1CostBasis,
      l10n.rptG1CostPerUnit,
      l10n.reportsColumnBomCost,
    ],
    for (final r in rows)
      [
        r.name,
        n(r.revenue),
        n(r.qty),
        n(r.grossProfit),
        r.margin.toStringAsFixed(1),
        _costSourceLabel(context, r.costSource),
        r.actualCostPerUnit == null ? '' : n(r.actualCostPerUnit!),
        n(r.bomCost),
      ],
  ];
}

// ── Body ──────────────────────────────────────────────────────────────────

class _ProductBody extends StatelessWidget {
  final ProductReport report;
  const _ProductBody({required this.report});

  @override
  Widget build(BuildContext context) {
    final data = report.data;
    final bundles = data.bundleComposition;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 24),
      children: [
        _KpiGrid(summary: data.summary),
        const SizedBox(height: 12),
        _RevenueByTypeCard(rows: data.byProductType),
        const SizedBox(height: 12),
        _TopProductsCard(
          rows: data.topProducts,
          costCoveragePct: report.costCoveragePct,
        ),
        const SizedBox(height: 12),
        _ByTerritoryCard(rows: data.byTerritory),
        const SizedBox(height: 12),
        _RevenueTrendCard(rows: data.trend),
        const SizedBox(height: 12),
        _OrdersTrendCard(rows: data.trend),
        // Bundle composition is optional — hide the whole section when empty.
        if (bundles.isNotEmpty) ...[
          const SizedBox(height: 12),
          _BundleCompositionCard(rows: bundles),
        ],
      ],
    );
  }
}

/// One `top_products` row, read null-safely. `cost_source` and
/// `actual_cost_per_unit` are newer keys and may be absent.
class _ProductRow {
  final String code;
  final String name;
  final double revenue;
  final double qty;
  final double grossProfit;
  final double margin;
  final double bomCost;
  final double? actualCostPerUnit;
  final ProductCostSource costSource;

  const _ProductRow({
    required this.code,
    required this.name,
    required this.revenue,
    required this.qty,
    required this.grossProfit,
    required this.margin,
    required this.bomCost,
    required this.actualCostPerUnit,
    required this.costSource,
  });

  factory _ProductRow.from(JsonMap r) => _ProductRow(
    code: _str(r, const ['item_code'], fallback: ''),
    name: _str(r, const ['item_name', 'item_code'], fallback: '—'),
    revenue: _num(r, const ['total_revenue', 'revenue']),
    qty: _num(r, const ['total_qty', 'qty']),
    grossProfit: _num(r, const ['gross_profit']),
    margin: _num(r, const ['margin_pct']),
    bomCost: _num(r, const ['bom_cost_per_unit', 'bom_cost']),
    actualCostPerUnit: ReportJson.dblOrNull(r['actual_cost_per_unit']),
    costSource: ProductReport.costSourceOf(r),
  );

  /// Average selling price per unit; 0 when nothing was sold.
  double get avgPrice => qty == 0 ? 0 : revenue / qty;
}

String _costSourceLabel(BuildContext context, ProductCostSource src) {
  final l10n = context.l10n;
  return switch (src) {
    ProductCostSource.actual => l10n.rptG1CostActual,
    ProductCostSource.bom => l10n.rptG1CostBom,
    ProductCostSource.none => l10n.rptG1CostNone,
    ProductCostSource.unknown => '—',
  };
}

// ── KPI grid ─────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final ProductAnalyticsSummary summary;
  const _KpiGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final revenue = summary.totalRevenue;
    final grossProfit = summary.totalGrossProfit;
    final margin = revenue > 0 ? grossProfit / revenue * 100 : 0.0;
    final bestSeller = summary.bestSellingProduct.trim();
    final topTerritory = summary.topTerritory.trim();

    final tiles = <Widget>[
      _kpi(
        l10n.reportKpiTotalRevenue,
        formatCompactCurrency(context, revenue),
        Icons.payments_outlined,
        theme.colorScheme.primary,
      ),
      _kpi(
        l10n.reportKpiTotalOrders,
        formatCount(context, summary.totalOrders),
        Icons.receipt_long_outlined,
        theme.colorScheme.tertiary,
      ),
      _kpi(
        l10n.reportKpiGrossProfit,
        formatCompactCurrency(context, grossProfit),
        Icons.trending_up,
        Colors.green.shade700,
      ),
      _kpi(
        l10n.reportKpiGrossMargin,
        '${margin.toStringAsFixed(1)}%',
        Icons.percent,
        Colors.teal.shade700,
      ),
      _kpi(
        l10n.reportKpiAov,
        formatCurrency(context, summary.avgOrderValue),
        Icons.shopping_cart_outlined,
        theme.colorScheme.secondary,
      ),
      _kpi(
        l10n.reportKpiBestSeller,
        bestSeller.isEmpty ? '—' : bestSeller,
        Icons.star_outline,
        Colors.amber.shade800,
      ),
      _kpi(
        l10n.reportKpiTopTerritory,
        topTerritory.isEmpty ? '—' : topTerritory,
        Icons.place_outlined,
        Colors.indigo.shade400,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 600 ? 3 : 2;
        const spacing = 8.0;
        final cardWidth =
            (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final t in tiles) SizedBox(width: cardWidth, child: t),
          ],
        );
      },
    );
  }

  Widget _kpi(String label, String value, IconData icon, Color color) =>
      KpiCard(label: label, value: value, icon: icon, color: color);
}

// ── Revenue by product type (donut + table) ─────────────────────────────────

class _RevenueByTypeCard extends StatelessWidget {
  final List<JsonMap> rows;
  const _RevenueByTypeCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final data = [
      for (final r in rows)
        (
          type: _str(r, const ['product_type', 'type'], fallback: '—'),
          revenue: _num(r, const ['revenue']),
          units: _num(r, const ['units', 'qty']),
          margin: _num(r, const ['gross_margin', 'margin_pct']),
        ),
    ]..sort((a, b) => b.revenue.compareTo(a.revenue));

    final total = data.fold<double>(0, (s, e) => s + e.revenue);
    final isEmpty = data.isEmpty || total <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportChartCard(
          title: l10n.reportRevenueByType,
          isEmpty: isEmpty,
          emptyText: l10n.reportNoData,
          height: 200,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 42,
                    pieTouchData: PieTouchData(enabled: false),
                    sections: [
                      for (var i = 0; i < data.length; i++)
                        PieChartSectionData(
                          value: data[i].revenue,
                          color: _paletteColor(i),
                          radius: 46,
                          title: total > 0
                              ? '${(data[i].revenue / total * 100).toStringAsFixed(0)}%'
                              : '',
                          titleStyle: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ListView(
                  padding: EdgeInsetsDirectional.zero,
                  children: [
                    for (var i = 0; i < data.length; i++)
                      _LegendDot(
                        color: _paletteColor(i),
                        label: data[i].type,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isEmpty)
          _TableCard(
            headers: [
              l10n.rptG1ColType,
              l10n.reportKpiTotalRevenue,
              l10n.rptG1Units,
              l10n.reportKpiGrossMargin,
            ],
            rows: [
              for (final e in data)
                [
                  e.type,
                  formatCurrency(context, e.revenue),
                  formatCount(context, e.units),
                  '${e.margin.toStringAsFixed(1)}%',
                ],
            ],
          ),
      ],
    );
  }
}

// ── Top products (horizontal bars + profitability table) ────────────────────

class _TopProductsCard extends StatelessWidget {
  final List<JsonMap> rows;

  /// Share of revenue (0–100) costed from real cost of goods; null on an
  /// older backend, where the note is hidden.
  final double? costCoveragePct;

  const _TopProductsCard({required this.rows, this.costCoveragePct});

  static const int _topN = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final data = [for (final r in rows) _ProductRow.from(r)]
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    final top = data.take(_topN).toList();
    final maxRevenue = top.isEmpty
        ? 0.0
        : top.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);
    final isEmpty = top.isEmpty || maxRevenue <= 0;
    final coverage = costCoveragePct;
    final muted = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportChartCard(
          title: l10n.reportTopProducts,
          isEmpty: isEmpty,
          emptyText: l10n.reportNoData,
          height: isEmpty ? 120 : top.length * 30.0 + 8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final e in top)
                _HBar(
                  label: e.name,
                  value: e.revenue,
                  fraction: maxRevenue > 0 ? e.revenue / maxRevenue : 0,
                  valueText: formatCompactCurrency(context, e.revenue),
                ),
            ],
          ),
        ),
        if (!isEmpty)
          Card(
            margin: const EdgeInsetsDirectional.only(top: 8),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (coverage != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: coverage >= 90
                              ? theme.colorScheme.primary
                              : Colors.orange.shade800,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.rptG1CostCoverage(
                              coverage.toStringAsFixed(
                                coverage >= 10 ? 0 : 1,
                              ),
                            ),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(l10n.rptG1ProductTapHint, style: muted),
                  const SizedBox(height: 6),
                  ReportTable(
                    columns: [
                      ReportColumn(l10n.reportsColumnItem, flex: 3),
                      ReportColumn(
                        l10n.reportKpiTotalRevenue,
                        numeric: true,
                        flex: 2,
                      ),
                      ReportColumn(
                        l10n.reportKpiGrossProfit,
                        numeric: true,
                        flex: 2,
                      ),
                      ReportColumn(
                        l10n.reportKpiGrossMargin,
                        numeric: true,
                        flex: 2,
                      ),
                      ReportColumn(l10n.rptG1CostBasis, flex: 2),
                    ],
                    rows: [
                      for (final e in top)
                        [
                          e.name,
                          formatCompactCurrency(context, e.revenue),
                          formatCompactCurrency(context, e.grossProfit),
                          '${e.margin.toStringAsFixed(1)}%',
                          _costSourceLabel(context, e.costSource),
                        ],
                    ],
                    cellColor: (row, col) {
                      if (col != 4) return null;
                      return switch (top[row].costSource) {
                        ProductCostSource.actual => Colors.green.shade700,
                        ProductCostSource.bom => Colors.orange.shade800,
                        ProductCostSource.none => theme.colorScheme.error,
                        ProductCostSource.unknown => null,
                      };
                    },
                    onRowTap: (i) => _showProductDetail(context, top[i]),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Bottom sheet with one product's numbers and where its cost came from.
void _showProductDetail(BuildContext context, _ProductRow p) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      final l10n = ctx.l10n;
      final theme = Theme.of(ctx);
      Widget line(String label, String value, {Color? color}) => Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      );
      final actual = p.actualCostPerUnit;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                p.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (p.code.isNotEmpty && p.code != p.name)
                Text(p.code, style: theme.textTheme.labelSmall),
              const Divider(height: 20),
              line(l10n.reportKpiTotalRevenue, formatCurrency(ctx, p.revenue)),
              line(l10n.rptG1Units, formatCount(ctx, p.qty)),
              line(l10n.rptG1AvgPrice, formatCurrency(ctx, p.avgPrice)),
              line(
                l10n.reportKpiGrossProfit,
                formatCurrency(ctx, p.grossProfit),
                color: p.grossProfit < 0 ? theme.colorScheme.error : null,
              ),
              line(l10n.reportKpiGrossMargin, '${p.margin.toStringAsFixed(1)}%'),
              const Divider(height: 20),
              line(l10n.rptG1CostBasis, _costSourceLabel(ctx, p.costSource)),
              if (actual != null)
                line(l10n.rptG1CostPerUnit, formatCurrency(ctx, actual)),
              line(l10n.reportsColumnBomCost, formatCurrency(ctx, p.bomCost)),
            ],
          ),
        ),
      );
    },
  );
}

// ── Revenue (+ profit) by territory ─────────────────────────────────────────

class _ByTerritoryCard extends StatelessWidget {
  final List<JsonMap> rows;
  const _ByTerritoryCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final data = [
      for (final r in rows)
        (
          territory: _str(r, const ['territory'], fallback: '—'),
          revenue: _num(r, const ['revenue']),
          profit: _num(r, const ['profit', 'gross_profit']),
          orders: _num(r, const ['orders']),
        ),
    ]..sort((a, b) => b.revenue.compareTo(a.revenue));

    final shown = data.take(8).toList();
    final maxY = shown.isEmpty
        ? 0.0
        : shown
            .map((e) => e.revenue > e.profit ? e.revenue : e.profit)
            .reduce((a, b) => a > b ? a : b);
    final isEmpty = shown.isEmpty || maxY <= 0;

    final revenueColor = theme.colorScheme.primary;
    final profitColor = Colors.green.shade600;

    return ReportChartCard(
      title: l10n.reportByTerritory,
      isEmpty: isEmpty,
      emptyText: l10n.reportNoData,
      height: 240,
      trailing: Wrap(
        spacing: 8,
        children: [
          _LegendDot(color: revenueColor, label: l10n.reportKpiTotalRevenue),
          _LegendDot(color: profitColor, label: l10n.reportKpiGrossProfit),
        ],
      ),
      child: isEmpty
          ? const SizedBox.shrink()
          : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.15,
                barTouchData: BarTouchData(enabled: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsetsDirectional.only(end: 4),
                        child: Text(
                          formatCompactCurrency(context, value),
                          style: theme.textTheme.labelSmall,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= shown.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(top: 6),
                          child: SizedBox(
                            width: 56,
                            child: Text(
                              shown[i].territory,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < shown.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: shown[i].revenue,
                          color: revenueColor,
                          width: 8,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3),
                          ),
                        ),
                        BarChartRodData(
                          toY: shown[i].profit,
                          color: profitColor,
                          width: 8,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3),
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

// ── Revenue trend (line) ────────────────────────────────────────────────────

typedef _TrendPoint = ({String date, double revenue, double orders});

List<_TrendPoint> _trendPoints(List<JsonMap> rows) => [
  for (final r in rows)
    (
      date: _str(r, const ['date', 'posting_date'], fallback: ''),
      revenue: _num(r, const ['revenue']),
      orders: _num(r, const ['orders']),
    ),
];

FlTitlesData _trendTitles(
  BuildContext context,
  List<_TrendPoint> data,
  String Function(double value) leftLabel,
) {
  final theme = Theme.of(context);
  final labelInterval = data.length <= 6 ? 1 : (data.length / 5).ceil();
  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 44,
        getTitlesWidget: (value, meta) => Padding(
          padding: const EdgeInsetsDirectional.only(end: 4),
          child: Text(
            leftLabel(value),
            style: theme.textTheme.labelSmall,
            textAlign: TextAlign.end,
          ),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 28,
        interval: 1,
        getTitlesWidget: (value, meta) {
          final i = value.round();
          if (i < 0 ||
              i >= data.length ||
              (value - i).abs() > 0.01 ||
              i % labelInterval != 0) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsetsDirectional.only(top: 6),
            child: Text(
              _shortDate(context, data[i].date),
              style: theme.textTheme.labelSmall,
            ),
          );
        },
      ),
    ),
  );
}

class _RevenueTrendCard extends StatelessWidget {
  final List<JsonMap> rows;
  const _RevenueTrendCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final data = _trendPoints(rows);
    final isEmpty = data.isEmpty;
    final revenueColor = theme.colorScheme.primary;
    final maxRevenue = isEmpty
        ? 0.0
        : data.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);

    return ReportChartCard(
      title: l10n.reportRevenueTrend,
      isEmpty: isEmpty,
      emptyText: l10n.reportNoData,
      height: 220,
      child: isEmpty
          ? const SizedBox.shrink()
          : LineChart(
              LineChartData(
                minX: 0,
                maxX: data.length <= 1 ? 1 : (data.length - 1).toDouble(),
                minY: 0,
                maxY: maxRevenue <= 0 ? 1 : maxRevenue * 1.15,
                lineTouchData: const LineTouchData(enabled: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: _trendTitles(
                  context,
                  data,
                  (v) => formatCompactCurrency(context, v),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: revenueColor,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: revenueColor.withValues(alpha: 0.12),
                    ),
                    spots: [
                      for (var i = 0; i < data.length; i++)
                        FlSpot(i.toDouble(), data[i].revenue),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Orders trend (bars, on their own axis) ──────────────────────────────────

/// Orders on their own chart: rescaling them onto the revenue axis made the
/// line's height meaningless.
class _OrdersTrendCard extends StatelessWidget {
  final List<JsonMap> rows;
  const _OrdersTrendCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final data = _trendPoints(rows);
    final maxOrders = data.isEmpty
        ? 0.0
        : data.map((e) => e.orders).reduce((a, b) => a > b ? a : b);
    final isEmpty = data.isEmpty || maxOrders <= 0;
    final ordersColor = Colors.orange.shade700;

    return ReportChartCard(
      title: l10n.rptG1OrdersTrend,
      isEmpty: isEmpty,
      emptyText: l10n.reportNoData,
      height: 180,
      child: isEmpty
          ? const SizedBox.shrink()
          : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxOrders * 1.15,
                barTouchData: BarTouchData(enabled: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: _trendTitles(
                  context,
                  data,
                  (v) => formatCount(context, v.round()),
                ),
                barGroups: [
                  for (var i = 0; i < data.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data[i].orders,
                          color: ordersColor,
                          width: data.length > 20 ? 4 : 8,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2),
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

// ── Bundle composition (table) ──────────────────────────────────────────────

class _BundleCompositionCard extends StatelessWidget {
  final List<JsonMap> rows;
  const _BundleCompositionCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final data = [
      for (final r in rows)
        [
          _str(r, const ['item_name', 'item_code'], fallback: '—'),
          formatCount(context, _num(r, const ['times_in_bundle', 'qty'])),
          formatCurrency(context, _num(r, const ['revenue'])),
        ],
    ];

    return _TableCard(
      title: l10n.reportBundleComposition,
      headers: [
        l10n.reportsColumnComponent,
        l10n.reportsColumnTimesInBundle,
        l10n.reportKpiRevenue,
      ],
      rows: data,
    );
  }
}

// ── Shared private helpers ──────────────────────────────────────────────────

/// A horizontal, proportional bar row (label + fill + value). RTL-safe because
/// it relies on [Row]/[Expanded] which honour the ambient text direction.
class _HBar extends StatelessWidget {
  final String label;
  final double value;
  final double fraction;
  final String valueText;

  const _HBar({
    required this.label,
    required this.value,
    required this.fraction,
    required this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final f = fraction.clamp(0.02, 1.0);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Container(
                    height: 14,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: f,
                    child: Container(
                      height: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: Text(
              valueText,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// A titled card wrapping a horizontally-scrollable [DataTable]. Used for the
/// per-type, top-product and bundle-composition breakdowns.
class _TableCard extends StatelessWidget {
  final String? title;
  final List<String> headers;
  final List<List<String>> rows;

  const _TableCard({
    this.title,
    required this.headers,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsetsDirectional.only(top: 8),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null && title!.isNotEmpty) ...[
              Text(
                title!,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
            ],
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 44,
                columnSpacing: 20,
                columns: [
                  for (final h in headers)
                    DataColumn(
                      label: Text(
                        h,
                        style: theme.textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
                rows: [
                  for (final r in rows)
                    DataRow(
                      cells: [
                        for (var i = 0; i < headers.length; i++)
                          DataCell(
                            Text(
                              i < r.length ? r[i] : '',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                      ],
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

// Distinct, colour-blind-friendly-ish palette cycled by index for chart series.
const List<Color> _kChartPalette = [
  Color(0xFF1976D2),
  Color(0xFF26A69A),
  Color(0xFFF57C00),
  Color(0xFF7E57C2),
  Color(0xFF43A047),
  Color(0xFFEF5350),
  Color(0xFF5C6BC0),
  Color(0xFFFFB300),
  Color(0xFF00ACC1),
  Color(0xFFEC407A),
];

Color _paletteColor(int i) => _kChartPalette[i % _kChartPalette.length];

/// Null-safe numeric extraction: returns the first key that parses to a number,
/// else 0. Accepts num or numeric-string values.
double _num(JsonMap row, List<String> keys) {
  for (final k in keys) {
    final v = row[k];
    if (v is num) return v.toDouble();
    if (v is String) {
      final p = double.tryParse(v.trim());
      if (p != null) return p;
    }
  }
  return 0;
}

/// Null-safe string extraction: first non-empty key, else [fallback].
String _str(JsonMap row, List<String> keys, {String fallback = ''}) {
  for (final k in keys) {
    final v = row[k];
    if (v != null) {
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
  }
  return fallback;
}

/// Formats an ISO `YYYY-MM-DD` string to a compact `M/d` label; falls back to
/// the raw value when unparseable.
String _shortDate(BuildContext context, String iso) {
  if (iso.isEmpty) return '';
  return formatDateString(context, iso, pattern: 'M/d');
}
