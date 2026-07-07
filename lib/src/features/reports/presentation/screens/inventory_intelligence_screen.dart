import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/inventory_intelligence.dart';
import '../../data/models/report_json.dart';
import '../../state/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_chart_card.dart';
import '../widgets/report_date_range_bar.dart';

/// Inventory Intelligence dashboard: stock-health KPIs, a velocity-distribution
/// donut, a top-movers bar chart, and restock / slow-mover / overstock / top
/// seller tables. Data comes from `inventoryIntelligenceProvider(range)`.
/// Loosely-typed JSON rows are read defensively so a missing key never crashes.
class InventoryIntelligenceScreen extends ConsumerWidget {
  const InventoryIntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(reportRangeProvider);
    final async = ref.watch(inventoryIntelligenceProvider(range));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportInventoryTitle)),
      body: Column(
        children: [
          const ReportDateRangeBar(),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorBody(
                onRetry: () =>
                    ref.invalidate(inventoryIntelligenceProvider(range)),
              ),
              data: (data) => RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(inventoryIntelligenceProvider(range)),
                child: _Body(data: data),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final InventoryIntelligence data;
  const _Body({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = data.summary;
    final scheme = Theme.of(context).colorScheme;

    final criticalEmpty = data.alerts.critical.isEmpty;
    final watchEmpty = data.alerts.watchList.isEmpty;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      children: [
        // KPI cards ────────────────────────────────────────────────
        _KpiWrap(cards: [
          KpiCard(
            label: l10n.reportInvKpiStockItems,
            value: _fmtInt(s.totalStockItems),
            icon: Icons.inventory_2_outlined,
          ),
          KpiCard(
            label: l10n.reportInvKpiCritical,
            value: _fmtInt(s.criticalCount),
            icon: Icons.error_outline,
            color: scheme.error,
          ),
          KpiCard(
            label: l10n.reportInvKpiWatch,
            value: _fmtInt(s.watchCount),
            icon: Icons.visibility_outlined,
            color: Colors.amber.shade800,
          ),
          KpiCard(
            label: l10n.reportInvKpiSlow,
            value: _fmtInt(s.slowCount),
            icon: Icons.trending_down,
          ),
          KpiCard(
            label: l10n.reportInvKpiOverstock,
            value: _fmtInt(s.overstockCount),
            icon: Icons.warehouse_outlined,
          ),
          KpiCard(
            label: l10n.reportInvKpiStockValue,
            value: _fmtMoney(s.totalStockValue),
            icon: Icons.attach_money,
          ),
        ]),
        const SizedBox(height: 12),

        // Stock velocity donut ─────────────────────────────────────
        ReportChartCard(
          title: l10n.reportStockVelocity,
          isEmpty: data.velocityDistribution.isEmpty,
          emptyText: l10n.reportNoData,
          child: _VelocityDonut(rows: data.velocityDistribution),
        ),
        const SizedBox(height: 12),

        // Top movers bar chart ─────────────────────────────────────
        ReportChartCard(
          title: l10n.reportTopMovers,
          isEmpty: data.topMovers.isEmpty,
          emptyText: l10n.reportNoData,
          child: _TopMoversChart(rows: data.topMovers),
        ),
        if (data.topMovers.isNotEmpty) ...[
          const SizedBox(height: 8),
          _TableCard(
            title: l10n.reportTopMovers,
            columns: [
              _Column('Item', (r) => _itemLabel(r)),
              _Column('Vel 30d', (r) => _fmtNum(_n(r, _velocity30)),
                  numeric: true),
              _Column('Vel 60d',
                  (r) => _fmtNum(_n(r, const ['velocity_60d', 'velocity_60'])),
                  numeric: true),
              _Column('Trend', (r) => _text(r, const ['trend']),
                  numeric: true),
            ],
            rows: data.topMovers,
          ),
        ],
        const SizedBox(height: 12),

        // Restock alerts (critical + watch list) ───────────────────
        if (criticalEmpty && watchEmpty)
          ReportChartCard(
            title: l10n.reportRestockAlerts,
            isEmpty: true,
            emptyText: l10n.reportNoData,
            child: const SizedBox.shrink(),
          )
        else ...[
          _SectionHeader(title: l10n.reportRestockAlerts),
          const SizedBox(height: 6),
          if (!criticalEmpty)
            _TableCard(
              title: l10n.reportCriticalItems,
              titleColor: scheme.error,
              columns: _alertColumns(),
              rows: data.alerts.critical,
            ),
          if (!criticalEmpty && !watchEmpty) const SizedBox(height: 8),
          if (!watchEmpty)
            _TableCard(
              title: l10n.reportWatchList,
              titleColor: Colors.amber.shade800,
              columns: _alertColumns(),
              rows: data.alerts.watchList,
            ),
        ],
        const SizedBox(height: 12),

        // Slow movers (always shown; empty-state when no rows) ──────
        _TableSection(
          title: l10n.reportSlowMovers,
          hideIfEmpty: false,
          columns: [
            _Column('Item', (r) => _itemLabel(r)),
            _Column('Velocity', (r) => _fmtNum(_n(r, _velocity30)),
                numeric: true),
            _Column('Stock', (r) => _fmtNum(_n(r, _currentStock)),
                numeric: true),
            _Column('Value', (r) => _fmtMoney(_n(r, _stockValue)),
                numeric: true),
          ],
          rows: data.alerts.slowMovers,
        ),
        const SizedBox(height: 12),

        // Overstocked (hidden when empty) ──────────────────────────
        _TableSection(
          title: l10n.reportOverstocked,
          hideIfEmpty: true,
          columns: [
            _Column('Item', (r) => _itemLabel(r)),
            _Column('Stock', (r) => _fmtNum(_n(r, _currentStock)),
                numeric: true),
            _Column('Cover', (r) => _fmtNum(_n(r, _daysCover)),
                numeric: true),
            _Column('Value', (r) => _fmtMoney(_n(r, _stockValue)),
                numeric: true),
          ],
          rows: data.alerts.overstocked,
        ),
        const SizedBox(height: 12),

        // Top sellers in range (hidden when empty) ─────────────────
        _TableSection(
          title: l10n.reportTopSellers,
          hideIfEmpty: true,
          columns: [
            _Column('Item', (r) => _itemLabel(r)),
            _Column('Sold', (r) => _fmtNum(_n(r, _qtySold)), numeric: true),
            _Column('Value', (r) => _fmtMoney(_n(r, _stockValue)),
                numeric: true),
          ],
          rows: data.topSoldInRange,
        ),
      ],
    );
  }

  /// Shared column layout for critical / watch-list alert rows.
  List<_Column> _alertColumns() => [
        _Column('Item', (r) => _itemLabel(r)),
        _Column('Stock', (r) => _fmtNum(_n(r, _currentStock)), numeric: true),
        _Column('Cover', (r) => _fmtNum(_n(r, _daysCover)), numeric: true),
        _Column('Velocity', (r) => _fmtNum(_n(r, _velocity30)), numeric: true),
      ];
}

// ── KPI layout ─────────────────────────────────────────────────────────

class _KpiWrap extends StatelessWidget {
  final List<Widget> cards;
  const _KpiWrap({required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxW = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      final crossCount = maxW >= 900
          ? 4
          : maxW >= 560
              ? 3
              : 2;
      const spacing = 8.0;
      final cardWidth = (maxW - spacing * (crossCount - 1)) / crossCount;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final c in cards) SizedBox(width: cardWidth, child: c),
        ],
      );
    });
  }
}

// ── Velocity donut ─────────────────────────────────────────────────────

class _VelocityDonut extends StatelessWidget {
  final List<JsonMap> rows;
  const _VelocityDonut({required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = <_Slice>[];
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      final label = _text(
        r,
        const ['label', 'bucket', 'velocity_band'],
        fallback: '—',
      );
      final value = _n(r, const ['count', 'value', 'qty']);
      if (value <= 0) continue;
      entries.add(_Slice(label, value, _palette[i % _palette.length]));
    }

    if (entries.isEmpty) {
      return Center(
        child: Text(
          context.l10n.reportNoData,
          style: theme.textTheme.bodySmall,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 42,
              sections: [
                for (final s in entries)
                  PieChartSectionData(
                    value: s.value,
                    color: s.color,
                    radius: 46,
                    title: '',
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final s in entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: s.color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            s.label,
                            style: theme.textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _fmtNum(s.value),
                          style: theme.textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
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

class _Slice {
  final String label;
  final double value;
  final Color color;
  const _Slice(this.label, this.value, this.color);
}

// ── Top movers bar chart ───────────────────────────────────────────────

class _TopMoversChart extends StatelessWidget {
  final List<JsonMap> rows;
  const _TopMoversChart({required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Take the strongest movers, sorted by 30-day velocity descending.
    final items = [...rows]
      ..sort((a, b) => _n(b, _velocity30).compareTo(_n(a, _velocity30)));
    final top = items.take(6).toList();
    if (top.isEmpty) {
      return Center(
        child: Text(context.l10n.reportNoData,
            style: theme.textTheme.bodySmall),
      );
    }

    final values = [for (final r in top) _n(r, _velocity30)];
    final maxV = values.fold<double>(0, (m, v) => v > m ? v : m);
    final maxY = maxV <= 0 ? 1.0 : maxV * 1.2;

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, _) {
              final r = top[group.x];
              return BarTooltipItem(
                '${_itemLabel(r)}\n${_fmtNum(rod.toY)}',
                theme.textTheme.labelSmall!
                    .copyWith(color: scheme.onInverseSurface),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= top.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    width: 52,
                    child: Text(
                      _shortLabel(_itemLabel(top[i])),
                      style: theme.textTheme.labelSmall,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < top.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: scheme.primary,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Tables ─────────────────────────────────────────────────────────────

class _Column {
  final String label;
  final String Function(JsonMap) cell;
  final bool numeric;
  const _Column(this.label, this.cell, {this.numeric = false});
}

/// Renders a titled table, or an empty-state / hidden slot depending on rows.
class _TableSection extends StatelessWidget {
  final String title;
  final List<_Column> columns;
  final List<JsonMap> rows;
  final bool hideIfEmpty;

  const _TableSection({
    required this.title,
    required this.columns,
    required this.rows,
    required this.hideIfEmpty,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      if (hideIfEmpty) return const SizedBox.shrink();
      return ReportChartCard(
        title: title,
        isEmpty: true,
        emptyText: context.l10n.reportNoData,
        child: const SizedBox.shrink(),
      );
    }
    return _TableCard(title: title, columns: columns, rows: rows);
  }
}

class _TableCard extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final List<_Column> columns;
  final List<JsonMap> rows;

  const _TableCard({
    required this.title,
    required this.columns,
    required this.rows,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final cellStyle = theme.textTheme.bodySmall;

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
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 18,
                headingRowHeight: 40,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 46,
                columns: [
                  for (final c in columns)
                    DataColumn(
                      numeric: c.numeric,
                      label: Text(c.label, style: headerStyle),
                    ),
                ],
                rows: [
                  for (final r in rows)
                    DataRow(
                      cells: [
                        for (final c in columns)
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 160),
                              child: Text(
                                c.cell(r),
                                style: cellStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.reportError, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(l10n.reportsRetry),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Row / value helpers (null-safe) ────────────────────────────────────

const _velocity30 = ['velocity_30d', 'velocity', 'velocity_30'];
const _currentStock = ['current_stock', 'qty', 'stock_qty'];
const _stockValue = ['stock_value', 'value'];
const _daysCover = ['days_of_cover', 'days_left', 'days_cover'];
const _qtySold = ['qty_sold', 'qty', 'sold_qty'];

/// A display label for an item row: name preferred, else code.
String _itemLabel(JsonMap r) =>
    _text(r, const ['item_name', 'item_code', 'name'], fallback: '—');

/// First non-empty stringified value among [keys], else [fallback].
String _text(JsonMap r, List<String> keys, {String fallback = '-'}) {
  for (final k in keys) {
    final v = r[k];
    if (v != null && v.toString().trim().isNotEmpty) return v.toString();
  }
  return fallback;
}

/// First parseable numeric value among [keys], else 0.
double _n(JsonMap r, List<String> keys) {
  for (final k in keys) {
    final v = r[k];
    if (v is num) return v.toDouble();
    if (v is String) {
      final p = double.tryParse(v);
      if (p != null) return p;
    }
  }
  return 0;
}

String _shortLabel(String s) => s.length <= 10 ? s : '${s.substring(0, 9)}…';

final _intFmt = NumberFormat.decimalPattern();
final _moneyFmt = NumberFormat.currency(symbol: 'EGP ', decimalDigits: 0);

String _fmtInt(num v) => _intFmt.format(v);

String _fmtNum(num v) => v == v.truncateToDouble()
    ? _intFmt.format(v.toInt())
    : v.toStringAsFixed(1);

String _fmtMoney(num v) => _moneyFmt.format(v);

const _palette = <Color>[
  Color(0xFF2E7D32),
  Color(0xFF1565C0),
  Color(0xFFF9A825),
  Color(0xFFC62828),
  Color(0xFF6A1B9A),
  Color(0xFF00838F),
  Color(0xFFEF6C00),
  Color(0xFF37474F),
];
