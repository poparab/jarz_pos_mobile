import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/network/user_service.dart';
import '../../data/models/inventory_intelligence.dart';
import '../../data/models/report_envelopes.dart';
import '../../data/models/report_json.dart';
import '../../data/velocity_alerts_repository.dart';
import '../../state/reports_providers.dart';
import '../../state/velocity_alerts_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_chart_card.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_section_card.dart';
import '../widgets/report_states.dart';
import '../widgets/report_table.dart';

/// Inventory & restock: stock-health KPIs, one velocity-based restock list
/// (critical / watch / slow / overstock, per branch), a velocity donut, top
/// movers and top sellers. Absorbs the old Velocity Alerts screen: tapping a
/// restock row opens the item's velocity detail, and managers can recalculate
/// the velocity job from the app bar.
///
/// Data comes from `inventoryReportProvider(reportQuery)`; the branch selector
/// scopes stock and restock alerts to that branch's warehouse.
class InventoryIntelligenceScreen extends ConsumerWidget {
  const InventoryIntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final query = ref.watch(reportQueryProvider);
    final async = ref.watch(inventoryReportProvider(query));
    final roles = ref.watch(userRolesFutureProvider).valueOrNull;
    final canRecalculate = roles?.canViewAllReports ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportInventoryTitle),
        actions: [
          if (canRecalculate)
            IconButton(
              icon: const Icon(Icons.autorenew),
              tooltip: l10n.velocityReportRecalculateAction,
              onPressed: () => _confirmAndRecalculate(context, ref),
            ),
        ],
      ),
      body: Column(
        children: [
          const ReportFilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(inventoryReportProvider(query).future),
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ReportErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(inventoryReportProvider(query)),
                ),
                data: (report) => _Body(report: report),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndRecalculate(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.velocityReportRecalculateConfirmTitle),
        content: Text(l10n.velocityReportRecalculateConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.velocityReportRecalculateAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = ref.read(velocityAlertsRepositoryProvider);
      final count = await repo.runVelocityUpdateNow();
      ref.invalidate(inventoryReportProvider);
      ref.invalidate(itemVelocityDetailProvider);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.velocityReportRecalculateSuccess(count))),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.velocityReportRecalculateError)),
      );
    }
  }
}

// ── Body ───────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final InventoryReport report;
  const _Body({required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final data = report.data;
    final s = data.summary;
    final scheme = Theme.of(context).colorScheme;
    // Older servers do not send `restock`; derive the same list from the
    // legacy alert buckets so the screen still works before the deploy.
    final restock =
        report.restock.isNotEmpty ? report.restock : _legacyRestock(data);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 24),
      children: [
        // KPI cards ────────────────────────────────────────────────
        _KpiWrap(cards: [
          KpiCard(
            label: l10n.reportInvKpiStockItems,
            value: formatCount(context, s.totalStockItems),
            icon: Icons.inventory_2_outlined,
          ),
          KpiCard(
            label: l10n.reportInvKpiCritical,
            value: formatCount(context, s.criticalCount),
            icon: Icons.error_outline,
            color: scheme.error,
          ),
          KpiCard(
            label: l10n.reportInvKpiWatch,
            value: formatCount(context, s.watchCount),
            icon: Icons.visibility_outlined,
            color: Colors.amber.shade800,
          ),
          KpiCard(
            label: l10n.reportInvKpiSlow,
            value: formatCount(context, s.slowCount),
            icon: Icons.trending_down,
          ),
          KpiCard(
            label: l10n.reportInvKpiOverstock,
            value: formatCount(context, s.overstockCount),
            icon: Icons.warehouse_outlined,
          ),
          KpiCard(
            label: l10n.reportInvKpiStockValue,
            value: formatCompactCurrency(context, s.totalStockValue),
            icon: Icons.payments_outlined,
          ),
        ]),
        const SizedBox(height: 12),

        // Restock list (merged velocity alerts) ───────────────────
        _RestockSection(rows: restock),
        const SizedBox(height: 12),

        // Stock velocity donut ─────────────────────────────────────
        ReportChartCard(
          title: l10n.reportStockVelocity,
          isEmpty: data.velocityDistribution.isEmpty,
          emptyText: l10n.reportNoData,
          child: _VelocityDonut(rows: data.velocityDistribution),
        ),
        const SizedBox(height: 12),

        // Top movers: one heading, chart then table ────────────────
        ReportChartCard(
          title: l10n.reportTopMovers,
          isEmpty: data.topMovers.isEmpty,
          emptyText: l10n.reportNoData,
          child: _TopMoversChart(rows: data.topMovers),
        ),
        if (data.topMovers.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsetsDirectional.all(12),
              child: ReportTable(
                columns: [
                  ReportColumn(l10n.reportsColumnItem, flex: 3),
                  ReportColumn(l10n.reportsColumnVelocity30d,
                      numeric: true, flex: 2),
                  ReportColumn(l10n.reportsColumnVelocity60d,
                      numeric: true, flex: 2),
                  ReportColumn(l10n.reportsColumnTrend, flex: 2),
                ],
                rows: [
                  for (final r in data.topMovers)
                    [
                      _itemLabel(r),
                      _fmtRate(context, _n(r, _velocity30)),
                      _fmtRate(context, _n(r, const ['velocity_60d', 'velocity_60'])),
                      localizedVelocityTrend(context, _text(r, const ['trend'])),
                    ],
                ],
                onRowTap: (i) {
                  final r = data.topMovers[i];
                  final code = _text(r, const ['item_code'], fallback: '');
                  if (code.isEmpty) return;
                  showVelocityDetailSheet(
                    context,
                    itemCode: code,
                    itemName: _itemLabel(r),
                  );
                },
                maxRows: 10,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),

        // Top sellers in range ─────────────────────────────────────
        if (data.topSoldInRange.isNotEmpty)
          ReportSectionCard(
            title: l10n.reportTopSellers,
            child: ReportTable(
              columns: [
                ReportColumn(l10n.reportsColumnItem, flex: 3),
                ReportColumn(l10n.reportsColumnSold, numeric: true, flex: 2),
                ReportColumn(l10n.reportsColumnRevenue, numeric: true, flex: 3),
              ],
              rows: [
                for (final r in data.topSoldInRange)
                  [
                    _itemLabel(r),
                    _fmtQty(context, _n(r, _qtySold)),
                    formatCurrency(
                      context,
                      _n(r, const ['revenue', 'stock_value', 'value']),
                    ),
                  ],
              ],
              maxRows: 10,
            ),
          ),
      ],
    );
  }
}

// ── Restock list ───────────────────────────────────────────────────────

class _RestockSection extends StatefulWidget {
  final List<RestockRow> rows;
  const _RestockSection({required this.rows});

  @override
  State<_RestockSection> createState() => _RestockSectionState();
}

class _RestockSectionState extends State<_RestockSection> {
  /// Null = all statuses.
  RestockStatus? _filter;

  static const _statuses = [
    RestockStatus.critical,
    RestockStatus.watch,
    RestockStatus.slow,
    RestockStatus.overstock,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = widget.rows;
    final visible = _filter == null
        ? rows
        : rows.where((r) => r.status == _filter).toList(growable: false);

    return ReportSectionCard(
      title: l10n.rptInventoryRestockTitle,
      subtitle: l10n.rptInventoryRestockSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip(context, null, l10n.rptG2RestockAll, rows.length),
                for (final st in _statuses)
                  _chip(
                    context,
                    st,
                    restockStatusLabel(context, st),
                    rows.where((r) => r.status == st).length,
                  ),
              ],
            ),
          ),
          if (visible.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 6, bottom: 2),
              child: Text(
                l10n.rptG2RestockHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ReportTable(
            columns: [
              ReportColumn(l10n.reportsColumnItem, flex: 4),
              ReportColumn(l10n.reportsColumnStock, numeric: true, flex: 2),
              ReportColumn(l10n.rptG2ColumnDaysCover, numeric: true, flex: 2),
              ReportColumn(l10n.rptG2ColumnSuggestedQty,
                  numeric: true, flex: 2),
            ],
            rows: [
              for (final r in visible)
                [
                  r.displayName,
                  _fmtQty(context, r.stock),
                  r.daysCover == null ? '—' : _fmtQty(context, r.daysCover!),
                  r.suggestedQty > 0 ? _fmtQty(context, r.suggestedQty) : '—',
                ],
            ],
            cellColor: (row, col) =>
                col == 0 ? restockStatusColor(context, visible[row].status) : null,
            onRowTap: (i) {
              final r = visible[i];
              if (r.itemCode.isEmpty) return;
              showVelocityDetailSheet(
                context,
                itemCode: r.itemCode,
                itemName: r.displayName,
                restock: r,
              );
            },
            maxRows: 15,
            emptyText: l10n.rptG2RestockEmpty,
          ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    RestockStatus? status,
    String label,
    int count,
  ) {
    final color =
        status == null ? null : restockStatusColor(context, status);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: ChoiceChip(
        selected: _filter == status,
        avatar: color == null
            ? null
            : CircleAvatar(backgroundColor: color, radius: 5),
        label: Text('$label  ${formatCount(context, count)}'),
        onSelected: (_) => setState(() => _filter = status),
      ),
    );
  }
}

/// Localised label for a restock status (reuses the velocity summary keys).
String restockStatusLabel(BuildContext context, RestockStatus status) {
  final l10n = context.l10n;
  return switch (status) {
    RestockStatus.critical => l10n.velocityReportSummaryCritical,
    RestockStatus.watch => l10n.velocityReportSummaryWatch,
    RestockStatus.slow => l10n.velocityReportSummarySlow,
    RestockStatus.overstock => l10n.velocityReportSummaryOverstock,
    RestockStatus.unknown => l10n.rptG2RestockStatusOther,
  };
}

Color restockStatusColor(BuildContext context, RestockStatus status) {
  final scheme = Theme.of(context).colorScheme;
  return switch (status) {
    RestockStatus.critical => scheme.error,
    RestockStatus.watch => Colors.amber.shade800,
    RestockStatus.slow => Colors.blueGrey,
    RestockStatus.overstock => Colors.indigo,
    RestockStatus.unknown => scheme.outline,
  };
}

/// Builds the restock list from the legacy `alerts` buckets, for servers that
/// predate the `restock` key.
List<RestockRow> _legacyRestock(InventoryIntelligence data) {
  RestockRow conv(JsonMap r, RestockStatus status) => RestockRow(
        itemCode: _text(r, const ['item_code'], fallback: ''),
        itemName: _text(r, const ['item_name'], fallback: ''),
        itemGroup: _text(r, const ['item_group'], fallback: ''),
        stock: _n(r, _currentStock),
        velocity30d: _n(r, _velocity30),
        daysCover: _nOrNull(r, _daysCover),
        status: status,
        trend: _text(r, const ['trend'], fallback: ''),
      );
  return [
    for (final r in data.alerts.critical) conv(r, RestockStatus.critical),
    for (final r in data.alerts.watchList) conv(r, RestockStatus.watch),
    for (final r in data.alerts.slowMovers) conv(r, RestockStatus.slow),
    for (final r in data.alerts.overstocked) conv(r, RestockStatus.overstock),
  ];
}

// ── Velocity detail sheet (from the retired Velocity Alerts screen) ────

void showVelocityDetailSheet(
  BuildContext context, {
  required String itemCode,
  required String itemName,
  RestockRow? restock,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _VelocityDetailSheet(
      itemCode: itemCode,
      itemName: itemName,
      restock: restock,
    ),
  );
}

class _VelocityDetailSheet extends ConsumerWidget {
  final String itemCode;
  final String itemName;
  final RestockRow? restock;
  const _VelocityDetailSheet({
    required this.itemCode,
    required this.itemName,
    this.restock,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final async = ref.watch(itemVelocityDetailProvider(itemCode));
    final r = restock;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.velocityReportDetailTitle,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(itemName, style: theme.textTheme.bodyMedium),
            if (r != null) ...[
              const SizedBox(height: 12),
              _detailRow(
                context,
                l10n.reportsColumnStock,
                r.uom.isEmpty
                    ? _fmtQty(context, r.stock)
                    : '${_fmtQty(context, r.stock)} ${r.uom}',
              ),
              _detailRow(
                context,
                l10n.rptG2ColumnDaysCover,
                r.daysCover == null ? '—' : _fmtQty(context, r.daysCover!),
              ),
              _detailRow(
                context,
                l10n.rptG2ColumnSuggestedQty,
                r.suggestedQty > 0 ? _fmtQty(context, r.suggestedQty) : '—',
              ),
              _detailRow(
                context,
                l10n.rptG2ColumnStatus,
                restockStatusLabel(context, r.status),
                color: restockStatusColor(context, r.status),
              ),
              if (r.stockValue > 0)
                _detailRow(
                  context,
                  l10n.rptG2StockValue,
                  formatCurrency(context, r.stockValue),
                ),
              _detailRow(
                context,
                l10n.rptG2LastSale,
                r.lastSale == null
                    ? '—'
                    : formatDateString(context, r.lastSale),
              ),
              const Divider(height: 20),
            ] else
              const SizedBox(height: 16),
            async.when(
              loading: () => const Padding(
                padding: EdgeInsetsDirectional.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
                child: Text(l10n.reportError),
              ),
              data: (detail) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow(context, l10n.reportsColumnVelocity30d,
                      _fmtRate(context, detail.velocity30d)),
                  _detailRow(context, l10n.reportsColumnVelocity60d,
                      _fmtRate(context, detail.velocity60d)),
                  _detailRow(context, l10n.reportsColumnTrend,
                      localizedVelocityTrend(context, detail.trend)),
                  if (r == null)
                    _detailRow(context, l10n.reportsColumnStock,
                        _fmtQty(context, detail.stockOnHand)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
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
      final label = localizedVelocityTrend(
        context,
        _text(
          r,
          const ['trend', 'label', 'bucket', 'velocity_band'],
          fallback: '—',
        ),
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
                    padding: const EdgeInsetsDirectional.symmetric(vertical: 3),
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
                          _fmtQty(context, s.value),
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
                '${_itemLabel(r)}\n${_fmtRate(context, rod.toY)}',
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
                  padding: const EdgeInsetsDirectional.only(top: 4),
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

// ── Row / value helpers (null-safe) ────────────────────────────────────

// Movers rows expose `velocity_30d`; alert rows (critical/watch) expose
// `daily_velocity`; both are covered so a single list works everywhere.
const _velocity30 = ['velocity_30d', 'velocity', 'velocity_30', 'daily_velocity'];
const _currentStock = ['stock_on_hand', 'current_stock', 'qty', 'stock_qty'];
const _daysCover = ['days_remaining', 'days_of_cover', 'days_left', 'days_cover'];
const _qtySold = ['qty', 'qty_sold', 'sold_qty'];

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
double _n(JsonMap r, List<String> keys) => _nOrNull(r, keys) ?? 0;

double? _nOrNull(JsonMap r, List<String> keys) {
  for (final k in keys) {
    final v = ReportJson.dblOrNull(r[k]);
    if (v != null) return v;
  }
  return null;
}

String _shortLabel(String s) => s.length <= 10 ? s : '${s.substring(0, 9)}…';

/// Quantities: whole numbers plain, otherwise one decimal; locale digits.
String _fmtQty(BuildContext context, num v) =>
    NumberFormat('#,##0.#', context.l10n.localeName).format(v);

/// Per-day sales rates: up to two decimals; locale digits.
String _fmtRate(BuildContext context, num v) =>
    NumberFormat('#,##0.##', context.l10n.localeName).format(v);

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
