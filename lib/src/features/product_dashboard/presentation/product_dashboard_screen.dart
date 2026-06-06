import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/app_drawer.dart';
import '../data/product_analytics_models.dart';
import '../state/product_analytics_providers.dart';

// ── Colour palette for product types ────────────────────────────────────
const _typeColors = {
  'Bundle': Color(0xFF7B61FF),
  'Medium': Color(0xFF22C55E),
  'Large': Color(0xFFF97316),
};

Color _typeColor(String type) => _typeColors[type] ?? Colors.grey;

// ── Number formatter ─────────────────────────────────────────────────────
final _numFmt = NumberFormat('#,##0.##');

String _fmtK(double v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}

String _fmtEgp(double v) => 'EGP ${_numFmt.format(v)}';

// ════════════════════════════════════════════════════════════════════════
// Screen
// ════════════════════════════════════════════════════════════════════════

class ProductDashboardScreen extends ConsumerWidget {
  const ProductDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(productAnalyticsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Product Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(productAnalyticsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          const _FilterBar(),
          Expanded(
            child: analyticsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(
                error: e.toString(),
                onRetry: () => ref.invalidate(productAnalyticsProvider),
              ),
              data: (data) => _DashboardContent(data: data),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter bar ───────────────────────────────────────────────────────────

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(dateFilterProvider);

    return Card(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final preset in DateFilterPreset.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(preset.label),
                        selected: filter.preset == preset,
                        onSelected: (_) => _onPresetTap(context, ref, preset, filter),
                      ),
                    ),
                ],
              ),
            ),
            if (filter.preset == DateFilterPreset.custom &&
                filter.customFrom != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  filter.displayLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPresetTap(
    BuildContext context,
    WidgetRef ref,
    DateFilterPreset preset,
    DateFilter current,
  ) async {
    if (preset != DateFilterPreset.custom) {
      ref.read(dateFilterProvider.notifier).state =
          DateFilter(preset: preset);
      return;
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: current.customFrom != null
          ? DateTimeRange(
              start: current.customFrom!,
              end: current.customTo ?? DateTime.now(),
            )
          : null,
    );
    if (picked == null) return;
    ref.read(dateFilterProvider.notifier).state = DateFilter(
      preset: DateFilterPreset.custom,
      customFrom: picked.start,
      customTo: picked.end,
    );
  }
}

// ── Dashboard content ────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  final ProductAnalyticsData data;
  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── KPI Cards ──────────────────────────────────────────────────
          _KpiCardsRow(summary: data.summary),
          const SizedBox(height: 12),

          // ── Row 1: Revenue Donut + Top Products Table ──────────────────
          _SectionTitle(title: 'Revenue by Type'),
          const SizedBox(height: 8),
          _RevenueDonutCard(data: data.byProductType),
          const SizedBox(height: 12),

          // ── Product type detail row ────────────────────────────────────
          _SectionTitle(title: 'Product Type Performance'),
          const SizedBox(height: 8),
          _ProductTypeSummaryCards(types: data.byProductType),
          const SizedBox(height: 12),

          // ── Top Products table ─────────────────────────────────────────
          _SectionTitle(title: 'Top Products by Revenue'),
          const SizedBox(height: 8),
          _TopProductsCard(products: data.topProducts),
          const SizedBox(height: 12),

          // ── Revenue by Territory ───────────────────────────────────────
          _SectionTitle(title: 'Revenue by Territory'),
          const SizedBox(height: 8),
          _TerritoryCard(territories: data.byTerritory),
          const SizedBox(height: 12),

          // ── Sales Trend ────────────────────────────────────────────────
          _SectionTitle(title: 'Sales Trend'),
          const SizedBox(height: 8),
          _SalesTrendCard(trend: data.trend),
          const SizedBox(height: 12),

          // ── Bundle Composition (only when bundles exist) ───────────────
          if (data.bundleComposition.isNotEmpty) ...[
            _SectionTitle(title: 'Bundle Flavor Composition'),
            const SizedBox(height: 8),
            _BundleCompositionCard(items: data.bundleComposition),
          ],
        ],
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}

// ── KPI Cards row ────────────────────────────────────────────────────────

class _KpiCardsRow extends StatelessWidget {
  final ProductAnalyticsSummary summary;
  const _KpiCardsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final bestSeller = s.bestSellingProduct.itemName.isEmpty
        ? '—'
        : '${s.bestSellingProduct.itemName}\n${s.bestSellingProduct.totalQty.toStringAsFixed(0)} units';
    final topTerritory = s.topTerritory.territory.isEmpty
        ? '—'
        : '${s.topTerritory.territory}\n${_fmtEgp(s.topTerritory.revenue)}';

    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _KpiCard(label: 'Revenue', value: _fmtEgp(s.totalRevenue), icon: Icons.attach_money, color: Colors.green),
          _KpiCard(label: 'Orders', value: '${s.totalOrders}', icon: Icons.receipt_long, color: Colors.blue),
          _KpiCard(label: 'Gross Profit', value: _fmtEgp(s.totalGrossProfit), icon: Icons.trending_up, color: Colors.teal),
          _KpiCard(label: 'Avg. Order', value: _fmtEgp(s.avgOrderValue), icon: Icons.analytics_outlined, color: Colors.orange),
          _KpiCard(label: 'Best Seller', value: bestSeller, icon: Icons.star_outline, color: const Color(0xFF7B61FF)),
          _KpiCard(label: 'Top Area', value: topTerritory, icon: Icons.location_on_outlined, color: Colors.red),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
      child: Container(
        width: 138,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
            Text(value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── Revenue donut ─────────────────────────────────────────────────────────

class _RevenueDonutCard extends StatelessWidget {
  final List<ProductTypeMetrics> data;
  const _RevenueDonutCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final withRevenue = data.where((d) => d.revenue > 0).toList();
    if (withRevenue.isEmpty) {
      return const Card(child: _NoDataPadded());
    }

    final total = withRevenue.fold(0.0, (s, d) => s + d.revenue);

    final sections = withRevenue.map((d) {
      final pct = total > 0 ? d.revenue / total * 100 : 0.0;
      return PieChartSectionData(
        value: d.revenue,
        title: '${pct.toStringAsFixed(0)}%',
        color: _typeColor(d.type),
        radius: 64,
        titleStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: PieChart(PieChartData(
                sections: sections,
                centerSpaceRadius: 36,
                sectionsSpace: 2,
              )),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: withRevenue.map((d) {
                return Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _typeColor(d.type),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('${d.type}  ${_fmtEgp(d.revenue)}',
                      style: const TextStyle(fontSize: 12)),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Product type summary cards ────────────────────────────────────────────

class _ProductTypeSummaryCards extends StatelessWidget {
  final List<ProductTypeMetrics> types;
  const _ProductTypeSummaryCards({required this.types});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: types.map((t) {
        final color = _typeColor(t.type);
        return Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(t.type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  ]),
                  const SizedBox(height: 6),
                  Text(_fmtEgp(t.revenue),
                      style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('${t.units} units', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 4),
                  _MarginBadge(marginPct: t.marginPct),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MarginBadge extends StatelessWidget {
  final double marginPct;
  const _MarginBadge({required this.marginPct});

  @override
  Widget build(BuildContext context) {
    final isGood = marginPct >= 20;
    final color = marginPct == 0
        ? Colors.grey
        : isGood
            ? Colors.green
            : Colors.orange;
    final label = marginPct == 0 ? 'No BOM' : '${marginPct.toStringAsFixed(0)}% margin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Top products table ────────────────────────────────────────────────────

class _TopProductsCard extends StatelessWidget {
  final List<TopProduct> products;
  const _TopProductsCard({required this.products});

  @override
  Widget build(BuildContext context) {
    final top10 = products.take(10).toList();
    if (top10.isEmpty) {
      return const Card(child: _NoDataPadded());
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 36,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 48,
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text('Product', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('Type', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('Units', style: TextStyle(fontSize: 12)), numeric: true),
            DataColumn(label: Text('Revenue', style: TextStyle(fontSize: 12)), numeric: true),
            DataColumn(label: Text('Profit', style: TextStyle(fontSize: 12)), numeric: true),
            DataColumn(label: Text('Margin', style: TextStyle(fontSize: 12)), numeric: true),
          ],
          rows: top10.map((p) {
            final profitColor = p.grossProfit >= 0 ? Colors.green.shade700 : Colors.red;
            final marginColor = p.marginPct == 0
                ? Colors.grey
                : p.marginPct >= 20
                    ? Colors.green.shade700
                    : Colors.orange;
            return DataRow(cells: [
              DataCell(SizedBox(
                width: 130,
                child: Text(p.itemName,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2),
              )),
              DataCell(_TypeBadge(type: p.type)),
              DataCell(Text(p.totalQty.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 12))),
              DataCell(Text(_fmtK(p.totalRevenue),
                  style: const TextStyle(fontSize: 12))),
              DataCell(Text(_fmtK(p.grossProfit),
                  style: TextStyle(fontSize: 12, color: profitColor, fontWeight: FontWeight.w600))),
              DataCell(Text(
                p.marginPct == 0 ? '—' : '${p.marginPct.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, color: marginColor, fontWeight: FontWeight.w600),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final c = _typeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
      child: Text(type,
          style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Territory bar chart ───────────────────────────────────────────────────

class _TerritoryCard extends StatelessWidget {
  final List<TerritoryMetrics> territories;
  const _TerritoryCard({required this.territories});

  @override
  Widget build(BuildContext context) {
    final top7 = territories.take(7).toList();
    if (top7.isEmpty) {
      return const Card(child: _NoDataPadded());
    }

    final maxVal = top7.map((t) => t.revenue).fold(0.0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: BarChart(BarChartData(
                barGroups: top7.asMap().entries.map((e) {
                  return BarChartGroupData(x: e.key, barRods: [
                    BarChartRodData(
                      toY: e.value.revenue,
                      color: Theme.of(context).colorScheme.primary,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ]);
                }).toList(),
                maxY: maxVal > 0 ? maxVal * 1.15 : 100,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= top7.length) return const SizedBox.shrink();
                        final name = top7[i].territory;
                        final short = name.length > 9 ? '${name.substring(0, 9)}…' : name;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(short,
                              style: const TextStyle(fontSize: 9),
                              textAlign: TextAlign.center),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (v, _) => Text(_fmtK(v),
                          style: const TextStyle(fontSize: 9)),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
              )),
            ),
            const SizedBox(height: 8),
            // Territory detail rows
            ...top7.map((t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(children: [
                Expanded(child: Text(t.territory, style: const TextStyle(fontSize: 12))),
                Text('${t.orders} orders', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(width: 12),
                Text(_fmtEgp(t.revenue),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ]),
            )),
          ],
        ),
      ),
    );
  }
}

// ── Sales trend line chart ────────────────────────────────────────────────

class _SalesTrendCard extends StatelessWidget {
  final List<TrendPoint> trend;
  const _SalesTrendCard({required this.trend});

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) {
      return const Card(child: _NoDataPadded());
    }

    final spots = trend
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.revenue))
        .toList();
    final maxY = trend.map((t) => t.revenue).fold(0.0, (a, b) => a > b ? a : b);

    // Compute a sensible label interval (aim for ~5 labels)
    final labelInterval = (trend.length / 5).ceilToDouble().clamp(1.0, 999.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
        child: SizedBox(
          height: 200,
          child: LineChart(LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                ),
              ),
            ],
            minY: 0,
            maxY: maxY > 0 ? maxY * 1.15 : 100,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => spots.map((s) {
                  final i = s.x.toInt();
                  final label = i < trend.length ? trend[i].date.substring(5) : '';
                  return LineTooltipItem(
                    '$label\n${_fmtEgp(s.y)}',
                    const TextStyle(fontSize: 11),
                  );
                }).toList(),
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: labelInterval,
                  reservedSize: 24,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= trend.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(trend[i].date.substring(5),
                          style: const TextStyle(fontSize: 9)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  getTitlesWidget: (v, _) =>
                      Text(_fmtK(v), style: const TextStyle(fontSize: 9)),
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
          )),
        ),
      ),
    );
  }
}

// ── Bundle composition ────────────────────────────────────────────────────

class _BundleCompositionCard extends StatelessWidget {
  final List<BundleCompositionItem> items;
  const _BundleCompositionCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final top8 = items.take(8).toList();
    final maxCount = top8.isNotEmpty ? top8.first.timesInBundle : 1.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ...top8.map((item) {
              final ratio = maxCount > 0 ? item.timesInBundle / maxCount : 0.0;
              final group = item.itemGroup.isEmpty ? '' : ' (${item.itemGroup})';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      '${item.itemName}$group',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(children: [
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: ratio.clamp(0.0, 1.0),
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B61FF).withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '×${item.timesInBundle.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ]),
              );
            }),
            const SizedBox(height: 4),
            Text(
              'Flavors chosen most often inside bundle orders',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────

class _NoDataPadded extends StatelessWidget {
  const _NoDataPadded();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: Text('No data for this period')),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
