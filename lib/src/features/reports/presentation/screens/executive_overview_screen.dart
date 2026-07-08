import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/executive_overview.dart';
import '../../data/models/report_json.dart';
import '../../state/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_alert_text.dart';
import '../widgets/report_chart_card.dart';
import '../widgets/report_date_range_bar.dart';

/// Executive Overview dashboard: top-line KPIs, revenue trend, product &
/// customer-segment mix, and top territories for the selected date range.
///
/// Reads [executiveOverviewProvider] (family keyed by the shared
/// [reportRangeProvider]) and renders a scrollable, pull-to-refresh, RTL-safe
/// board. All chart rows degrade to an empty-state placeholder when their
/// backing list is empty.
class ExecutiveOverviewScreen extends ConsumerWidget {
  const ExecutiveOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(reportRangeProvider);
    final async = ref.watch(executiveOverviewProvider(range));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportExecutiveTitle)),
      body: Column(
        children: [
          const ReportDateRangeBar(),
          Expanded(
            child: async.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorRetry(
                onRetry: () =>
                    ref.invalidate(executiveOverviewProvider(range)),
              ),
              data: (data) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(executiveOverviewProvider(range));
                  await ref.read(executiveOverviewProvider(range).future);
                },
                child: _Content(data: data),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────

class _Content extends StatelessWidget {
  final ExecutiveOverview data;
  const _Content({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const _QuickNavRow(),
        const SizedBox(height: 12),
        _AlertsSection(alerts: data.alerts),
        _KpiGrid(kpis: data.kpis),
        const SizedBox(height: 12),
        _RevenueTrendCard(rows: data.revenueTrend),
        const SizedBox(height: 12),
        _ProductMixCard(rows: data.productMix),
        const SizedBox(height: 12),
        _SegmentMixCard(rows: data.segmentMix),
        const SizedBox(height: 12),
        _TopTerritoriesCard(rows: data.topTerritories),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Quick navigation to the sibling dashboards
// ─────────────────────────────────────────────────────────────────────────

class _QuickNavRow extends StatelessWidget {
  const _QuickNavRow();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _NavChip(
          icon: Icons.local_shipping_outlined,
          label: l10n.reportShippingTitle,
          route: AppRoutes.reportsShipping,
        ),
        _NavChip(
          icon: Icons.inventory_2_outlined,
          label: l10n.reportInventoryTitle,
          route: AppRoutes.reportsInventory,
        ),
        _NavChip(
          icon: Icons.category_outlined,
          label: l10n.reportProductTitle,
          route: AppRoutes.reportsProduct,
        ),
        _NavChip(
          icon: Icons.people_outline,
          label: l10n.reportCustomerTitle,
          route: AppRoutes.reportsCustomer,
        ),
        _NavChip(
          icon: Icons.business_center_outlined,
          label: l10n.reportB2bTitle,
          route: AppRoutes.reportsB2b,
        ),
      ],
    );
  }
}

class _NavChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _NavChip({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      onPressed: () => context.push(route),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Priority alerts
// ─────────────────────────────────────────────────────────────────────────

class _AlertsSection extends StatelessWidget {
  final List<JsonMap> alerts;
  const _AlertsSection({required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportAlerts,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        ...alerts.map((a) {
          final type = _str(a, const ['type']);
          final message = _str(a, const ['message']);
          if (message.isEmpty) return const SizedBox.shrink();
          final color = _alertColor(context, type);
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            color: color.withValues(alpha: 0.10),
            child: ListTile(
              dense: true,
              leading: Icon(_alertIcon(type), color: color),
              title: Text(
                stripHtml(message),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// KPI grid
// ─────────────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final ExecutiveKpis kpis;
  const _KpiGrid({required this.kpis});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final positive = Colors.green.shade700;
    final negative = theme.colorScheme.error;

    final netShippingColor = kpis.netShippingPl >= 0 ? positive : negative;
    final criticalColor =
        kpis.criticalStock > 0 ? theme.colorScheme.error : Colors.grey;

    final cards = <Widget Function(double)>[
      (w) => KpiCard(
            width: w,
            label: l10n.reportKpiRevenue,
            value: formatCompactCurrency(context, kpis.revenue),
            icon: Icons.payments_outlined,
            color: theme.colorScheme.primary,
          ),
      (w) => KpiCard(
            width: w,
            label: l10n.reportKpiOrders,
            value: formatCount(context, kpis.orders),
            icon: Icons.receipt_long_outlined,
            color: Colors.blue.shade700,
          ),
      (w) => KpiCard(
            width: w,
            label: l10n.reportKpiGrossProfit,
            value: formatCompactCurrency(context, kpis.grossProfit),
            icon: Icons.trending_up,
            color: positive,
          ),
      (w) => KpiCard(
            width: w,
            label: l10n.reportKpiGrossMargin,
            value: '${kpis.grossMarginPct.toStringAsFixed(1)}%',
            icon: Icons.percent,
            color: Colors.teal.shade700,
          ),
      (w) => KpiCard(
            width: w,
            label: l10n.reportKpiAov,
            value: formatCurrency(context, kpis.avgOrderValue),
            icon: Icons.shopping_cart_outlined,
            color: Colors.indigo.shade600,
          ),
      (w) => KpiCard(
            width: w,
            label: l10n.reportKpiNetShippingPl,
            value: formatCompactCurrency(context, kpis.netShippingPl),
            icon: kpis.netShippingPl >= 0
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            color: netShippingColor,
          ),
      (w) => KpiCard(
            width: w,
            label: l10n.reportKpiCustomers,
            value: formatCount(context, kpis.customers),
            icon: Icons.groups_outlined,
            color: Colors.purple.shade600,
          ),
      (w) => KpiCard(
            width: w,
            label: l10n.reportKpiCriticalStock,
            value: formatCount(context, kpis.criticalStock),
            icon: Icons.warning_amber_outlined,
            color: criticalColor,
          ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 600
                ? 3
                : 2;
        const spacing = 8.0;
        final cardWidth =
            (constraints.maxWidth - (cols - 1) * spacing) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (final b in cards) b(cardWidth)],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Revenue trend (line): revenue + orders over time
// ─────────────────────────────────────────────────────────────────────────

class _RevenueTrendCard extends StatelessWidget {
  final List<JsonMap> rows;
  const _RevenueTrendCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final revenueColor = theme.colorScheme.primary;
    final ordersColor = Colors.orange.shade700;

    final revenueSpots = <FlSpot>[];
    final orderSpots = <FlSpot>[];
    final labels = <String>[];
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      revenueSpots.add(FlSpot(i.toDouble(), _d(r, const ['revenue'])));
      orderSpots.add(FlSpot(i.toDouble(), _d(r, const ['orders'])));
      labels.add(_shortDate(_str(r, const ['posting_date', 'date'])));
    }

    final interval = labels.isEmpty ? 1.0 : (labels.length / 5).ceilToDouble();

    return ReportChartCard(
      title: l10n.reportRevenueTrend,
      height: 240,
      isEmpty: rows.isEmpty,
      emptyText: l10n.reportNoData,
      trailing: _Legend(items: [
        _LegendItem(color: revenueColor, label: l10n.reportKpiRevenue),
        _LegendItem(color: ordersColor, label: l10n.reportKpiOrders),
      ]),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (rows.length - 1).clamp(0, double.maxFinite).toDouble(),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    _compact(value),
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval < 1 ? 1 : interval,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (i < 0 || i >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      labels[i],
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
              isCurved: true,
              color: revenueColor,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: revenueColor.withValues(alpha: 0.12),
              ),
            ),
            LineChartBarData(
              spots: orderSpots,
              isCurved: true,
              color: ordersColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Product mix (donut)
// ─────────────────────────────────────────────────────────────────────────

class _ProductMixCard extends StatelessWidget {
  final List<JsonMap> rows;
  const _ProductMixCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slices = [
      for (final r in rows)
        _Slice(
          label: _str(r, const ['product_type', 'type']),
          value: _d(r, const ['revenue', 'value']),
        )
    ].where((s) => s.value > 0).toList();

    return ReportChartCard(
      title: l10n.reportProductMix,
      height: 240,
      isEmpty: slices.isEmpty,
      emptyText: l10n.reportNoData,
      child: _DonutWithLegend(slices: slices, money: true),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Customer segments (donut)
// ─────────────────────────────────────────────────────────────────────────

class _SegmentMixCard extends StatelessWidget {
  final List<JsonMap> rows;
  const _SegmentMixCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slices = [
      for (final r in rows)
        _Slice(
          label: _str(r, const ['segment']),
          value: _d(r, const ['count', 'value']),
        )
    ].where((s) => s.value > 0).toList();

    return ReportChartCard(
      title: l10n.reportCustomerSegments,
      height: 240,
      isEmpty: slices.isEmpty,
      emptyText: l10n.reportNoData,
      child: _DonutWithLegend(slices: slices, money: false),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Top territories (grouped bars: revenue + gross profit)
// ─────────────────────────────────────────────────────────────────────────

class _TopTerritoriesCard extends StatelessWidget {
  final List<JsonMap> rows;
  const _TopTerritoriesCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final revenueColor = theme.colorScheme.primary;
    final profitColor = Colors.green.shade700;

    final data = rows.take(8).toList();
    var maxY = 0.0;
    final groups = <BarChartGroupData>[];
    final names = <String>[];
    for (var i = 0; i < data.length; i++) {
      final r = data[i];
      final revenue = _d(r, const ['revenue']);
      final profit = _d(r, const ['gross_profit', 'profit']);
      maxY = [maxY, revenue, profit].reduce((a, b) => a > b ? a : b);
      names.add(_str(r, const ['territory']));
      groups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 2,
          barRods: [
            BarChartRodData(
              toY: revenue,
              color: revenueColor,
              width: 7,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              toY: profit,
              color: profitColor,
              width: 7,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    }

    return ReportChartCard(
      title: l10n.reportTopTerritories,
      height: 260,
      isEmpty: data.isEmpty,
      emptyText: l10n.reportNoData,
      trailing: _Legend(items: [
        _LegendItem(color: revenueColor, label: l10n.reportKpiRevenue),
        _LegendItem(color: profitColor, label: l10n.reportKpiGrossProfit),
      ]),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY <= 0 ? 1 : maxY * 1.2,
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: groups,
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    _compact(value),
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (i < 0 || i >= names.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      _truncate(names[i], 8),
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shared small pieces
// ─────────────────────────────────────────────────────────────────────────

class _Slice {
  final String label;
  final double value;
  const _Slice({required this.label, required this.value});
}

class _DonutWithLegend extends StatelessWidget {
  final List<_Slice> slices;
  final bool money;
  const _DonutWithLegend({required this.slices, required this.money});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = slices.fold<double>(0, (s, e) => s + e.value);

    return Row(
      children: [
        Expanded(
          flex: 3,
          // Adaptive radii so the donut always fits its (narrow) slot on small
          // phones instead of clipping at a fixed pixel radius.
          child: LayoutBuilder(
            builder: (context, c) {
              final d = c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight;
              final outer = (d / 2) - 2;
              final sectionRadius = (outer * 0.6).clamp(22.0, 55.0);
              final center = (outer * 0.4).clamp(12.0, 42.0);
              final sections = <PieChartSectionData>[
                for (var i = 0; i < slices.length; i++)
                  PieChartSectionData(
                    value: slices[i].value,
                    color: _palette[i % _palette.length],
                    radius: sectionRadius,
                    title: (total <= 0
                                ? 0.0
                                : (slices[i].value / total) * 100) >=
                            6
                        ? '${(slices[i].value / total * 100).toStringAsFixed(0)}%'
                        : '',
                    titleStyle: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ];
              return PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: center,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < slices.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _palette[i % _palette.length],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            slices[i].label,
                            style: theme.textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          money
                              ? formatCompactCurrency(context, slices[i].value)
                              : formatCount(context, slices[i].value),
                          style: theme.textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
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

class _Legend extends StatelessWidget {
  final List<_LegendItem> items;
  const _Legend({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: items,
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
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
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorRetry({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 40,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 8),
          Text(l10n.reportError, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onRetry,
            child: Text(l10n.reportsRetry),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Pure helpers (file-private)
// ─────────────────────────────────────────────────────────────────────────

const List<Color> _palette = <Color>[
  Color(0xFF1E88E5),
  Color(0xFF00897B),
  Color(0xFFFB8C00),
  Color(0xFF8E24AA),
  Color(0xFFE53935),
  Color(0xFF43A047),
  Color(0xFF3949AB),
  Color(0xFFD81B60),
  Color(0xFF6D4C41),
  Color(0xFF00ACC1),
];

double _d(JsonMap m, List<String> keys) {
  for (final k in keys) {
    final v = m[k];
    if (v is num) return v.toDouble();
    if (v is String) {
      final p = double.tryParse(v);
      if (p != null) return p;
    }
  }
  return 0;
}

String _str(JsonMap m, List<String> keys) {
  for (final k in keys) {
    final v = m[k];
    if (v != null && '$v'.trim().isNotEmpty) return '$v';
  }
  return '';
}

String _compact(num value) => NumberFormat.compact().format(value);

String _truncate(String s, int max) =>
    s.length <= max ? s : '${s.substring(0, max)}…';

String _shortDate(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  return DateFormat('M/d').format(parsed);
}

Color _alertColor(BuildContext context, String type) {
  switch (type.toLowerCase()) {
    case 'danger':
    case 'error':
    case 'critical':
      return Colors.red.shade700;
    case 'warning':
    case 'warn':
      return Colors.orange.shade800;
    case 'success':
      return Colors.green.shade700;
    default:
      return Theme.of(context).colorScheme.primary;
  }
}

IconData _alertIcon(String type) {
  switch (type.toLowerCase()) {
    case 'danger':
    case 'error':
    case 'critical':
      return Icons.error_outline;
    case 'warning':
    case 'warn':
      return Icons.warning_amber_outlined;
    case 'success':
      return Icons.check_circle_outline;
    default:
      return Icons.info_outline;
  }
}
