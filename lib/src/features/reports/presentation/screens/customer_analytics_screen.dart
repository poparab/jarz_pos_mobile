import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/customer_analytics.dart';
import '../../data/models/report_json.dart';
import '../../state/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_chart_card.dart';
import '../widgets/report_date_range_bar.dart';

/// Customer Analytics dashboard: RFM segmentation, retention KPIs, top and
/// at-risk customers, and new-customer acquisition. Reads the shared date range
/// and the `customerAnalyticsProvider` family. RTL/Arabic-safe.
class CustomerAnalyticsScreen extends ConsumerWidget {
  const CustomerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(reportRangeProvider);
    final async = ref.watch(customerAnalyticsProvider(range));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportCustomerTitle)),
      body: Column(
        children: [
          const ReportDateRangeBar(),
          Expanded(
            child: async.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorRetry(
                onRetry: () =>
                    ref.invalidate(customerAnalyticsProvider(range)),
              ),
              data: (data) => RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(customerAnalyticsProvider(range)),
                child: _CustomerAnalyticsBody(data: data),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error / retry ──────────────────────────────────────────────────────────

class _ErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorRetry({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.reportError,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
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

// ── Body ───────────────────────────────────────────────────────────────────

class _CustomerAnalyticsBody extends StatelessWidget {
  final CustomerAnalytics data;
  const _CustomerAnalyticsBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final atRisk = data.atRiskCustomers;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      children: [
        _KpiSection(summary: data.summary),
        const SizedBox(height: 12),
        _SegmentDistributionCard(
          distribution: data.segmentDistribution,
          segmentTable: data.segmentTable,
        ),
        const SizedBox(height: 12),
        _SegmentDetailCard(rows: data.segmentTable),
        const SizedBox(height: 12),
        _TopCustomersCard(rows: data.topCustomers),
        if (atRisk.isNotEmpty) ...[
          const SizedBox(height: 12),
          _AtRiskCard(rows: atRisk),
        ],
        const SizedBox(height: 12),
        _AcquisitionCard(trend: data.acquisitionTrend),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── KPI cards ────────────────────────────────────────────────────────────

class _KpiSection extends StatelessWidget {
  final CustomerAnalyticsSummary summary;
  const _KpiSection({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Repeat rate may arrive as a fraction (0..1) or a percentage (0..100).
    final rawRate = summary.repeatRate;
    final ratePct = rawRate <= 1 ? rawRate * 100 : rawRate;

    final tiles = <_Kpi>[
      _Kpi(
        label: l10n.reportKpiTotalCustomers,
        value: formatCount(context, summary.totalCustomers),
        icon: Icons.groups_outlined,
        color: scheme.primary,
      ),
      _Kpi(
        label: l10n.reportKpiActive,
        value: formatCount(context, summary.activeInPeriod),
        icon: Icons.person_outline,
        color: scheme.tertiary,
      ),
      _Kpi(
        label: l10n.reportKpiNew,
        value: formatCount(context, summary.newCustomers),
        icon: Icons.person_add_alt,
        color: _segmentColor('New Customer'),
      ),
      _Kpi(
        label: l10n.reportKpiRepeatRate,
        value: '${ratePct.toStringAsFixed(1)}%',
        icon: Icons.repeat,
        color: scheme.secondary,
      ),
      _Kpi(
        label: l10n.reportKpiChampions,
        value: formatCount(context, summary.champions),
        icon: Icons.emoji_events_outlined,
        color: _segmentColor('Champion'),
      ),
      _Kpi(
        label: l10n.reportKpiAtRisk,
        value: formatCount(context, summary.atRisk),
        icon: Icons.warning_amber_outlined,
        color: Colors.amber.shade800,
      ),
      _Kpi(
        label: l10n.reportKpiLost,
        value: formatCount(context, summary.lost),
        icon: Icons.person_off_outlined,
        color: scheme.error,
      ),
      _Kpi(
        label: l10n.reportKpiAov,
        value: formatCurrency(context, summary.avgOrderValue),
        icon: Icons.receipt_long_outlined,
        color: scheme.primary,
      ),
    ];

    return LayoutBuilder(
      builder: (ctx, constraints) {
        const spacing = 8.0;
        final cols = (constraints.maxWidth / 170).floor().clamp(2, 4);
        final cardW =
            (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final t in tiles)
              KpiCard(
                width: cardW,
                label: t.label,
                value: t.value,
                icon: t.icon,
                color: t.color,
              ),
          ],
        );
      },
    );
  }
}

class _Kpi {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _Kpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

// ── Segment distribution: donut (share by count) + revenue bar ─────────────

class _SegmentDistributionCard extends StatelessWidget {
  final List<JsonMap> distribution;
  final List<JsonMap> segmentTable;
  const _SegmentDistributionCard({
    required this.distribution,
    required this.segmentTable,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // segment_distribution only carries {segment, count}; per-segment revenue
    // lives in segment_table. Build a lookup so the revenue bar has real data.
    final revenueBySegment = <String, double>{
      for (final m in segmentTable)
        _readStr(m, ['segment'], 'Unclassified').toLowerCase():
            _readNum(m, ['revenue']),
    };
    final rows = distribution
        .map(
          (m) {
            final segment = _readStr(m, ['segment'], 'Unclassified');
            return _SegSlice(
              segment: segment,
              count: _readNum(m, ['count']),
              revenue: revenueBySegment[segment.toLowerCase()] ??
                  _readNum(m, ['revenue']),
            );
          },
        )
        .toList();

    final hasData = rows.any((r) => r.count > 0 || r.revenue > 0);

    return ReportChartCard(
      title: l10n.reportSegmentDistribution,
      height: 470,
      isEmpty: !hasData,
      emptyText: l10n.reportNoData,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: 196, child: _donut(context, rows)),
          const SizedBox(height: 12),
          Expanded(
            child: _barChart(
              context,
              bars: [
                for (final r in rows)
                  _Bar(
                    label: r.segment,
                    value: r.revenue,
                    color: _segmentColor(r.segment),
                    tooltip: formatCompactCurrency(context, r.revenue),
                  ),
              ],
              currencyAxis: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _donut(BuildContext context, List<_SegSlice> rows) {
    final total = rows.fold<double>(0, (a, r) => a + r.count);
    final theme = Theme.of(context);
    final hasSlices = rows.any((r) => r.count > 0);

    return Row(
      children: [
        Expanded(
          flex: 5,
          // Adaptive radii keep the donut inside its slot on narrow phones.
          child: !hasSlices
              ? const SizedBox.shrink()
              : LayoutBuilder(
                  builder: (context, c) {
                    final d =
                        c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight;
                    final outer = (d / 2) - 2;
                    final sectionRadius = (outer * 0.6).clamp(20.0, 50.0);
                    final center = (outer * 0.4).clamp(12.0, 34.0);
                    final sections = <PieChartSectionData>[
                      for (final r in rows)
                        if (r.count > 0)
                          PieChartSectionData(
                            value: r.count,
                            color: _segmentColor(r.segment),
                            radius: sectionRadius,
                            title: total > 0 && r.count / total >= 0.06
                                ? '${(r.count / total * 100).round()}%'
                                : '',
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                    ];
                    return PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: center,
                        sections: sections,
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final r in rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _segmentColor(r.segment),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            r.segment,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatCount(context, r.count),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
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

class _SegSlice {
  final String segment;
  final double count;
  final double revenue;
  const _SegSlice({
    required this.segment,
    required this.count,
    required this.revenue,
  });
}

// ── Segment detail table ───────────────────────────────────────────────────

class _SegmentDetailCard extends StatelessWidget {
  final List<JsonMap> rows;
  const _SegmentDetailCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _TableCard(
      title: l10n.reportSegmentDetail,
      isEmpty: rows.isEmpty,
      emptyText: l10n.reportNoData,
      child: DataTable(
        headingRowHeight: 36,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 48,
        columnSpacing: 20,
        columns: [
          DataColumn(label: Text(l10n.reportsColumnSegment)),
          DataColumn(
              label: Text(l10n.reportKpiCustomers), numeric: true),
          DataColumn(
              label: Text(l10n.reportsColumnRecencyDays), numeric: true),
          DataColumn(
              label: Text(l10n.reportsColumnFrequency), numeric: true),
          DataColumn(label: Text(l10n.reportsColumnAov), numeric: true),
          DataColumn(label: Text(l10n.reportKpiRevenue), numeric: true),
        ],
        rows: [
          for (final m in rows)
            DataRow(
              cells: [
                DataCell(_segmentChip(
                  context,
                  _readStr(m, ['segment'], 'Unclassified'),
                )),
                DataCell(Text(formatCount(
                  context,
                  _readNum(m, ['customers', 'count']),
                ))),
                DataCell(Text(formatCount(
                  context,
                  _readNum(m, ['avg_recency', 'recency', 'avg_recency_days']),
                ))),
                DataCell(Text(formatCount(
                  context,
                  _readNum(m, ['avg_frequency', 'frequency']),
                ))),
                DataCell(Text(formatCurrency(
                  context,
                  _readNum(m, ['avg_aov', 'avg_order_value']),
                ))),
                DataCell(Text(formatCurrency(
                  context,
                  _readNum(m, ['revenue']),
                ))),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Top customers table ────────────────────────────────────────────────────

class _TopCustomersCard extends StatelessWidget {
  final List<JsonMap> rows;
  const _TopCustomersCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _TableCard(
      title: l10n.reportTopCustomers,
      isEmpty: rows.isEmpty,
      emptyText: l10n.reportNoData,
      child: DataTable(
        headingRowHeight: 36,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 48,
        columnSpacing: 20,
        columns: [
          DataColumn(label: Text(l10n.commonCustomerLabel)),
          DataColumn(label: Text(l10n.reportsColumnSegment)),
          DataColumn(label: Text(l10n.reportKpiRevenue), numeric: true),
          DataColumn(label: Text(l10n.reportKpiOrders), numeric: true),
          DataColumn(
              label: Text(l10n.reportsColumnRecencyDays), numeric: true),
        ],
        rows: [
          for (final m in rows)
            DataRow(
              cells: [
                DataCell(Text(
                  _readStr(
                    m,
                    ['customer_name', 'customer'],
                    '—',
                  ),
                )),
                DataCell(_segmentChip(
                  context,
                  _readStr(m, ['segment'], 'Unclassified'),
                )),
                DataCell(Text(formatCurrency(
                  context,
                  _readNum(m, ['revenue']),
                ))),
                DataCell(Text(formatCount(
                  context,
                  _readNum(m, ['orders']),
                ))),
                DataCell(Text(formatCount(
                  context,
                  _readNum(m, ['recency_days']),
                ))),
              ],
            ),
        ],
      ),
    );
  }
}

// ── At-risk / win-back table ───────────────────────────────────────────────

class _AtRiskCard extends StatelessWidget {
  final List<JsonMap> rows;
  const _AtRiskCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _TableCard(
      title: l10n.reportAtRiskWinBack,
      isEmpty: rows.isEmpty,
      emptyText: l10n.reportNoData,
      child: DataTable(
        headingRowHeight: 36,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 48,
        columnSpacing: 20,
        columns: [
          DataColumn(label: Text(l10n.commonCustomerLabel)),
          DataColumn(label: Text(l10n.reportsColumnSegment)),
          DataColumn(
              label: Text(l10n.reportsColumnRecencyDays), numeric: true),
          DataColumn(label: Text(l10n.reportsColumnAov), numeric: true),
        ],
        rows: [
          for (final m in rows)
            DataRow(
              cells: [
                DataCell(Text(
                  _readStr(m, ['customer_name', 'customer'], '—'),
                )),
                DataCell(_segmentChip(
                  context,
                  _readStr(m, ['segment'], 'At Risk'),
                )),
                DataCell(Text(formatCount(
                  context,
                  _readNum(m, ['recency_days']),
                ))),
                DataCell(Text(formatCurrency(
                  context,
                  _readNum(m, ['avg_aov']),
                ))),
              ],
            ),
        ],
      ),
    );
  }
}

// ── New customer acquisition bar chart ─────────────────────────────────────

class _AcquisitionCard extends StatelessWidget {
  final List<JsonMap> trend;
  const _AcquisitionCard({required this.trend});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bars = [
      for (final m in trend)
        _Bar(
          label: _periodLabel(
            _readStr(m, ['date', 'period', 'posting_date', 'month'], ''),
          ),
          value: _readNum(m, ['new_customers', 'count']),
          color: theme.colorScheme.primary,
          tooltip: formatCount(context, _readNum(m, ['new_customers', 'count'])),
        ),
    ];
    final hasData = bars.any((b) => b.value > 0);

    return ReportChartCard(
      title: l10n.reportNewCustomerAcquisition,
      height: 240,
      isEmpty: !hasData,
      emptyText: l10n.reportNoData,
      child: _barChart(context, bars: bars, currencyAxis: false),
    );
  }
}

// ── Shared bar chart builder (fl_chart 0.69) ───────────────────────────────

Widget _barChart(
  BuildContext context, {
  required List<_Bar> bars,
  required bool currencyAxis,
}) {
  if (bars.isEmpty) return const SizedBox.shrink();
  final maxV = bars.fold<double>(0, (a, b) => b.value > a ? b.value : a);
  final maxY = maxV <= 0 ? 1.0 : maxV * 1.2;
  final step = (bars.length / 6).ceil().clamp(1, 9999);

  return BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      barGroups: [
        for (var i = 0; i < bars.length; i++)
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: bars[i].value,
                color: bars[i].color,
                width: 14,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
      ],
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        show: true,
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            getTitlesWidget: (value, meta) {
              if (value <= 0) return const SizedBox.shrink();
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  _compactNum(context, value),
                  style: const TextStyle(fontSize: 9),
                ),
              );
            },
          ),
        ),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= bars.length) return const SizedBox.shrink();
              if (i % step != 0) return const SizedBox.shrink();
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: SizedBox(
                  width: 54,
                  child: Text(
                    bars[i].label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final b = bars[group.x.toInt()];
            return BarTooltipItem(
              '${b.label}\n${b.tooltip}',
              const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ),
    ),
  );
}

class _Bar {
  final String label;
  final double value;
  final Color color;
  final String tooltip;
  const _Bar({
    required this.label,
    required this.value,
    required this.color,
    required this.tooltip,
  });
}

// ── Reusable titled table card with empty state + horizontal scroll ────────

class _TableCard extends StatelessWidget {
  final String title;
  final bool isEmpty;
  final String? emptyText;
  final Widget child;

  const _TableCard({
    required this.title,
    required this.child,
    this.isEmpty = false,
    this.emptyText,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.table_chart_outlined,
                        size: 28,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        emptyText ?? context.l10n.reportNoData,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: child,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Segment chip (colored dot + label) ─────────────────────────────────────

Widget _segmentChip(BuildContext context, String segment) {
  final theme = Theme.of(context);
  final color = _segmentColor(segment);
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        localizedCustomerSegment(context, segment),
        style: theme.textTheme.bodySmall,
      ),
    ],
  );
}

// ── RFM segment → color map (shared by donut, bars, chips) ─────────────────

const Map<String, Color> _kSegmentColors = {
  'champion': Color(0xFF2E7D32),
  'champions': Color(0xFF2E7D32),
  'loyal': Color(0xFF1565C0),
  'loyal customer': Color(0xFF1565C0),
  'potential loyalist': Color(0xFF00897B),
  'new customer': Color(0xFF6A1B9A),
  'new': Color(0xFF6A1B9A),
  'at risk': Color(0xFFEF6C00),
  "can't lose them": Color(0xFFC62828),
  'cant lose them': Color(0xFFC62828),
  'lost': Color(0xFF757575),
  'one-time': Color(0xFF9E9D24),
  'one time': Color(0xFF9E9D24),
  'unclassified': Color(0xFFBDBDBD),
};

const List<Color> _kFallbackPalette = [
  Color(0xFF5E35B1),
  Color(0xFF00838F),
  Color(0xFFD81B60),
  Color(0xFF43A047),
  Color(0xFFF9A825),
  Color(0xFF3949AB),
];

Color _segmentColor(String segment) {
  final key = segment.trim().toLowerCase();
  final mapped = _kSegmentColors[key];
  if (mapped != null) return mapped;
  if (key.isEmpty) return _kSegmentColors['unclassified']!;
  return _kFallbackPalette[key.hashCode.abs() % _kFallbackPalette.length];
}

// ── Null-safe JsonMap readers ──────────────────────────────────────────────

String _readStr(JsonMap map, List<String> keys, [String fallback = '']) {
  for (final k in keys) {
    final v = map[k];
    if (v != null) {
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
  }
  return fallback;
}

double _readNum(JsonMap map, List<String> keys) {
  for (final k in keys) {
    final v = map[k];
    if (v is num) return v.toDouble();
    if (v is String) {
      final parsed = double.tryParse(v);
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

String _compactNum(BuildContext context, num value) =>
    NumberFormat.compact(locale: context.l10n.localeName).format(value);

/// Shortens ISO date-ish period labels to `MM-DD` while leaving month names or
/// other short labels untouched.
String _periodLabel(String raw) {
  final v = raw.trim();
  if (v.isEmpty) return '';
  final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(v);
  if (iso != null) return '${iso.group(2)}-${iso.group(3)}';
  final ym = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(v);
  if (ym != null) return '${ym.group(1)}-${ym.group(2)}';
  return v;
}
