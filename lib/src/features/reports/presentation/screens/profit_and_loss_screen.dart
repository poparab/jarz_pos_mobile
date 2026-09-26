import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/profit_and_loss.dart';
import '../../state/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_chart_card.dart';
import '../widgets/report_date_range_bar.dart';

/// Profit & Loss: revenue split B2B vs B2C, cost of sales, shipping income vs
/// expense, recurring and other expenses, and net profit for the selected
/// range.
///
/// Every number comes from the ledger-reconciled backend report; this screen
/// only lays it out. When the books for the period are incomplete (stock or
/// courier cost never posted) the warnings are shown first, because they
/// qualify every figure below them.
class ProfitAndLossScreen extends ConsumerWidget {
  const ProfitAndLossScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(reportRangeProvider);
    final async = ref.watch(profitAndLossProvider(range));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pnlTitle)),
      body: Column(
        children: [
          const ReportDateRangeBar(),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorRetry(
                onRetry: () => ref.invalidate(profitAndLossProvider(range)),
              ),
              data: (data) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(profitAndLossProvider(range));
                  await ref.read(profitAndLossProvider(range).future);
                },
                child: ProfitAndLossContent(data: data),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The scrollable body, split out so tests can render it from a fixture.
class ProfitAndLossContent extends StatelessWidget {
  final ProfitAndLoss data;
  const ProfitAndLossContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _Warnings(data: data),
        _LedgerCheck(reconciliation: data.reconciliation),
        const SizedBox(height: 8),
        _KpiGrid(data: data),
        const SizedBox(height: 12),
        _RevenueByChannelCard(data: data),
        const SizedBox(height: 12),
        _ChannelSplitCard(data: data),
        const SizedBox(height: 12),
        _StatementCard(data: data),
        const SizedBox(height: 12),
        _RevenueVsExpensesCard(data: data),
        const SizedBox(height: 12),
        _ShippingCard(shipping: data.shipping),
        const SizedBox(height: 12),
        _RecurringCard(recurring: data.recurring),
        const SizedBox(height: 12),
        _OtherExpensesCard(
          total: data.otherExpensesTotal,
          rows: data.otherExpenses,
        ),
        const SizedBox(height: 12),
        _ExpenseMixCard(summary: data.summary),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── colours shared by every chart, so a channel is the same colour everywhere ──

const _b2cColor = Color(0xFF1E88E5);
const _b2bColor = Color(0xFF8E24AA);
const _otherSalesColor = Color(0xFF90A4AE);
const _shippingColor = Color(0xFFFB8C00);
const _costColor = Color(0xFF6D4C41);
const _recurringColor = Color(0xFF3949AB);
const _otherExpenseColor = Color(0xFFD81B60);
final _positive = Colors.green.shade700;
const _negative = Color(0xFFD32F2F);

// ─────────────────────────────────────────────────────────────────────────
// Data-quality warnings + ledger check
// ─────────────────────────────────────────────────────────────────────────

class _Warnings extends StatelessWidget {
  final ProfitAndLoss data;
  const _Warnings({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dq = data.dataQuality;
    final messages = <String>[
      if (dq.warnings.contains('cogs_incomplete'))
        l10n.pnlWarnCogs(_pct(dq.cogsCoveragePct)),
      if (dq.warnings.contains('shipping_expense_incomplete'))
        l10n.pnlWarnShipping(_pct(dq.shippingExpenseCoveragePct)),
      if (dq.warnings.contains('recurring_not_fully_posted'))
        l10n.pnlWarnRecurring(
          formatCompactCurrency(context, data.recurring.total),
          formatCompactCurrency(context, data.recurring.due),
        ),
      if (data.reconciliation.notes.contains('shipping_income_in_freight'))
        l10n.pnlNoteShippingInFreight,
    ];
    if (messages.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final color = Colors.orange.shade800;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          for (final m in messages)
            Card(
              margin: const EdgeInsets.only(bottom: 6),
              color: color.withValues(alpha: 0.10),
              child: ListTile(
                dense: true,
                leading: Icon(Icons.warning_amber_outlined, color: color),
                title: Text(m, style: theme.textTheme.bodyMedium),
              ),
            ),
        ],
      ),
    );
  }
}

class _LedgerCheck extends StatelessWidget {
  final PnlReconciliation reconciliation;
  const _LedgerCheck({required this.reconciliation});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ok = reconciliation.matches;
    final color = ok ? _positive : _negative;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Chip(
        avatar: Icon(
          ok ? Icons.verified_outlined : Icons.error_outline,
          size: 18,
          color: color,
        ),
        label: Text(
          ok
              ? l10n.pnlLedgerMatches
              : l10n.pnlLedgerMismatch(
                  formatCurrency(context, reconciliation.difference),
                ),
        ),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        backgroundColor: color.withValues(alpha: 0.06),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// KPI grid
// ─────────────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final ProfitAndLoss data;
  const _KpiGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = data.summary;
    Color signed(double v) => v >= 0 ? _positive : _negative;

    final cards = <Widget Function(double)>[
      (w) => KpiCard(
        width: w,
        label: l10n.pnlTotalRevenue,
        value: formatCompactCurrency(context, s.totalRevenue),
        icon: Icons.payments_outlined,
        color: Theme.of(context).colorScheme.primary,
        delta: l10n.pnlOrdersCount(s.orders),
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.pnlB2cRevenue,
        value: formatCompactCurrency(context, s.b2cRevenue),
        icon: Icons.person_outline,
        color: _b2cColor,
        delta: '${_pct(data.channel('b2c').sharePct)}%',
        deltaColor: _b2cColor,
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.pnlB2bRevenue,
        value: formatCompactCurrency(context, s.b2bRevenue),
        icon: Icons.business_outlined,
        color: _b2bColor,
        delta: '${_pct(data.channel('b2b').sharePct)}%',
        deltaColor: _b2bColor,
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.pnlGrossProfit,
        value: formatCompactCurrency(context, s.grossProfit),
        icon: Icons.trending_up,
        color: signed(s.grossProfit),
        delta: l10n.pnlMarginOf(_pct(s.grossMarginPct)),
        deltaColor: signed(s.grossProfit),
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.pnlTotalExpenses,
        value: formatCompactCurrency(context, s.totalExpenses),
        icon: Icons.receipt_long_outlined,
        color: _costColor,
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.pnlNetProfit,
        value: formatCompactCurrency(context, s.netProfit),
        icon: s.netProfit >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
        color: signed(s.netProfit),
        delta: l10n.pnlMarginOf(_pct(s.netMarginPct)),
        deltaColor: signed(s.netProfit),
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.pnlShippingNet,
        value: formatCompactCurrency(context, s.shippingNet),
        icon: Icons.local_shipping_outlined,
        color: signed(s.shippingNet),
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.pnlRecurringExpenses,
        value: formatCompactCurrency(context, s.recurringExpenses),
        icon: Icons.event_repeat_outlined,
        color: _recurringColor,
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
        final cardWidth = (constraints.maxWidth - (cols - 1) * spacing) / cols;
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
// Revenue by channel (stacked bars per bucket)
// ─────────────────────────────────────────────────────────────────────────

class _RevenueByChannelCard extends StatelessWidget {
  final ProfitAndLoss data;
  const _RevenueByChannelCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final points = data.trend;
    final labels = [
      for (final p in points) _bucketLabel(context, p.date, data.granularity),
    ];

    var maxY = 0.0;
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final parts = <(double, Color)>[
        (_pos(p.b2c), _b2cColor),
        (_pos(p.b2b), _b2bColor),
        (_pos(p.otherSales), _otherSalesColor),
        (_pos(p.shippingIncome), _shippingColor),
      ];
      var running = 0.0;
      final stack = <BarChartRodStackItem>[];
      for (final (v, c) in parts) {
        if (v <= 0) continue;
        stack.add(BarChartRodStackItem(running, running + v, c));
        running += v;
      }
      if (running > maxY) maxY = running;
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: running,
              rodStackItems: stack,
              color: Colors.transparent,
              width: points.length > 20 ? 6 : 12,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    }

    return ReportChartCard(
      title: l10n.pnlRevenueTrend,
      height: 240,
      isEmpty: points.isEmpty || maxY <= 0,
      emptyText: l10n.reportNoData,
      child: _WithLegend(
        legend: _Legend(
          items: [
            _LegendItem(color: _b2cColor, label: l10n.pnlChannelB2c),
            _LegendItem(color: _b2bColor, label: l10n.pnlChannelB2b),
            _LegendItem(color: _otherSalesColor, label: l10n.pnlChannelOther),
            _LegendItem(color: _shippingColor, label: l10n.pnlShippingIncome),
          ],
        ),
        chart: BarChart(
          BarChartData(
            maxY: maxY <= 0 ? 1 : maxY * 1.15,
            alignment: BarChartAlignment.spaceAround,
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            barGroups: groups,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                  '${labels[group.x]}\n${formatCompactCurrency(context, rod.toY)}',
                  theme.textTheme.labelSmall!.copyWith(color: Colors.white),
                ),
              ),
            ),
            titlesData: _titles(theme, labels),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// B2B vs B2C (donut + per-channel table)
// ─────────────────────────────────────────────────────────────────────────

class _ChannelSplitCard extends StatelessWidget {
  final ProfitAndLoss data;
  const _ChannelSplitCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final rows = data.channels
        .where((c) => c.revenue != 0 || c.orders > 0)
        .toList();
    final slices = [
      for (final c in rows)
        if (c.revenue > 0)
          _Slice(
            _channelLabel(context, c.channel),
            c.revenue,
            _channelColor(c.channel),
          ),
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.pnlChannelSplit,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: slices.isEmpty
                  ? Center(child: Text(l10n.reportNoData))
                  : _DonutWithLegend(slices: slices),
            ),
            const Divider(height: 24),
            for (final c in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    _Swatch(color: _channelColor(c.channel)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _channelLabel(context, c.channel),
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            [
                              l10n.pnlOrdersCount(c.orders),
                              if (c.returns > 0)
                                l10n.pnlReturnsCount(c.returns),
                              if (c.shippingIncome != 0)
                                '${l10n.pnlShippingIncome}: ${formatCompactCurrency(context, c.shippingIncome)}',
                            ].join(' · '),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatCurrency(context, c.revenue),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_pct(c.sharePct)}%',
                          style: theme.textTheme.labelSmall,
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

// ─────────────────────────────────────────────────────────────────────────
// The statement itself
// ─────────────────────────────────────────────────────────────────────────

class _StatementCard extends StatelessWidget {
  final ProfitAndLoss data;
  const _StatementCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final s = data.summary;

    Widget line(
      String label,
      double amount, {
      bool bold = false,
      bool negative = false,
      int indent = 0,
      Color? color,
    }) {
      // `amount == 0` guard: -0.0 formats as "-EGP0.00".
      final shown = negative && amount != 0 ? -amount : amount;
      final style =
          (bold
                  ? theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                  : theme.textTheme.bodyMedium)
              ?.copyWith(color: color);
      return Padding(
        padding: EdgeInsetsDirectional.only(
          start: 12.0 * indent,
          top: 3,
          bottom: 3,
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: style)),
            Text(formatCurrency(context, shown), style: style),
          ],
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.pnlStatement,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            for (final c in data.channels.where((c) => c.sales != 0))
              line(
                '${l10n.pnlSales} — ${_channelLabel(context, c.channel)}',
                c.sales,
                indent: 1,
              ),
            line(l10n.pnlShippingIncome, s.shippingIncome, indent: 1),
            line(l10n.pnlTotalRevenue, s.totalRevenue, bold: true),
            const Divider(),
            for (final r in data.costOfSales.rows)
              line(r.label, r.amount, negative: true, indent: 1),
            line(
              l10n.pnlCostOfSales,
              s.costOfSales,
              negative: true,
              bold: true,
            ),
            line(
              l10n.pnlGrossProfit,
              s.grossProfit,
              bold: true,
              color: s.grossProfit >= 0 ? _positive : _negative,
            ),
            const Divider(),
            line(
              l10n.pnlShippingExpense,
              s.shippingExpense,
              negative: true,
              indent: 1,
            ),
            line(
              l10n.pnlRecurringExpenses,
              s.recurringExpenses,
              negative: true,
              indent: 1,
            ),
            line(
              l10n.pnlOtherExpenses,
              s.otherExpenses,
              negative: true,
              indent: 1,
            ),
            const Divider(),
            line(
              l10n.pnlNetProfit,
              s.netProfit,
              bold: true,
              color: s.netProfit >= 0 ? _positive : _negative,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Revenue vs expenses vs net profit (lines)
// ─────────────────────────────────────────────────────────────────────────

class _RevenueVsExpensesCard extends StatelessWidget {
  final ProfitAndLoss data;
  const _RevenueVsExpensesCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final points = data.trend;
    final labels = [
      for (final p in points) _bucketLabel(context, p.date, data.granularity),
    ];
    final revenueColor = theme.colorScheme.primary;

    // Running totals, not per-bucket values: rent and payroll land on single
    // days, so daily net profit swings wildly while the running line shows
    // where the period is heading and ends exactly at the period's figure.
    List<FlSpot> spots(double Function(PnlTrendPoint) f) {
      var running = 0.0;
      return [
        for (var i = 0; i < points.length; i++)
          FlSpot(i.toDouble(), running += f(points[i])),
      ];
    }

    LineChartBarData series(List<FlSpot> s, Color c, {bool area = false}) =>
        LineChartBarData(
          spots: s,
          isCurved: true,
          preventCurveOverShooting: true,
          color: c,
          barWidth: 2,
          dotData: FlDotData(show: points.length <= 12),
          belowBarData: BarAreaData(
            show: area,
            color: c.withValues(alpha: 0.10),
          ),
        );

    return ReportChartCard(
      title: l10n.pnlRevenueVsExpenses,
      subtitle: l10n.pnlRunningTotal,
      height: 240,
      isEmpty: points.isEmpty,
      emptyText: l10n.reportNoData,
      child: _WithLegend(
        legend: _Legend(
          items: [
            _LegendItem(color: revenueColor, label: l10n.pnlTotalRevenue),
            _LegendItem(color: _costColor, label: l10n.pnlExpenses),
            _LegendItem(color: _positive, label: l10n.pnlNetProfit),
          ],
        ),
        chart: LineChart(
          LineChartData(
            minX: 0,
            maxX: (points.length - 1).clamp(0, double.maxFinite).toDouble(),
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: _titles(theme, labels),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(y: 0, color: theme.dividerColor, strokeWidth: 1),
              ],
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => spots
                    .map(
                      (s) => LineTooltipItem(
                        formatCompactCurrency(context, s.y),
                        theme.textTheme.labelSmall!.copyWith(
                          color: s.bar.color,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            lineBarsData: [
              series(spots((p) => p.revenue), revenueColor, area: true),
              series(spots((p) => p.expenses), _costColor),
              series(spots((p) => p.netProfit), _positive),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shipping: what customers were charged vs what couriers cost
// ─────────────────────────────────────────────────────────────────────────

class _ShippingCard extends StatelessWidget {
  final PnlShipping shipping;
  const _ShippingCard({required this.shipping});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final maxY = [
      shipping.income,
      shipping.expense,
      1.0,
    ].reduce((a, b) => a > b ? a : b);
    final netColor = shipping.net >= 0 ? _positive : _negative;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.pnlShippingTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  maxY: maxY * 1.2,
                  alignment: BarChartAlignment.spaceEvenly,
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 20,
                        getTitlesWidget: (v, meta) => SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            formatCompactCurrency(
                              context,
                              v == 0 ? shipping.income : shipping.expense,
                            ),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (v, meta) => SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            v == 0
                                ? l10n.pnlShippingIncome
                                : l10n.pnlShippingExpense,
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: _pos(shipping.income),
                          color: _shippingColor,
                          width: 36,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: _pos(shipping.expense),
                          color: _costColor,
                          width: 36,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.pnlShippingDifference,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  formatCurrency(context, shipping.net),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: netColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (shipping.deliveryOrders > 0)
              Text(
                l10n.pnlPerDelivery(
                  formatCurrency(context, shipping.incomePerDelivery),
                  formatCurrency(context, shipping.expensePerDelivery),
                  shipping.deliveryOrders,
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Recurring expenses: posted vs due
// ─────────────────────────────────────────────────────────────────────────

class _RecurringCard extends StatelessWidget {
  final PnlRecurring recurring;
  const _RecurringCard({required this.recurring});

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.pnlRecurringExpenses,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  formatCurrency(context, recurring.total),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (recurring.due > 0)
              Text(
                l10n.pnlRecurringPosted(
                  formatCompactCurrency(context, recurring.total),
                  formatCompactCurrency(context, recurring.due),
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 8),
            if (recurring.rows.isEmpty)
              Text(l10n.reportNoData, style: theme.textTheme.bodySmall),
            for (final r in recurring.rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.label,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Flexible, not intrinsic: "posted / due" in Arabic
                        // compact currency can outgrow a 360dp row and crush
                        // the label to nothing.
                        Flexible(
                          child: Text(
                            r.due > 0
                                ? '${formatCompactCurrency(context, r.posted)} / ${formatCompactCurrency(context, r.due)}'
                                : formatCompactCurrency(context, r.posted),
                            style: theme.textTheme.labelMedium,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: r.due > 0
                            ? (r.posted / r.due).clamp(0.0, 1.0)
                            : 1.0,
                        color: r.due > 0 && r.posted + 0.5 < r.due
                            ? Colors.orange.shade700
                            : _recurringColor,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
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
// Other expenses: every remaining expense account, largest first
// ─────────────────────────────────────────────────────────────────────────

class _OtherExpensesCard extends StatelessWidget {
  final double total;
  final List<PnlAccountRow> rows;
  const _OtherExpensesCard({required this.total, required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final shown = rows.where((r) => r.amount.abs() >= 1).toList();
    final max = shown.fold<double>(
      0,
      (m, r) => r.amount.abs() > m ? r.amount.abs() : m,
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.pnlOtherExpenses,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  formatCurrency(context, total),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (shown.isEmpty)
              Text(l10n.reportNoData, style: theme.textTheme.bodySmall),
            for (final r in shown)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.label,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            formatCurrency(context, r.amount),
                            style: theme.textTheme.labelMedium,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: max > 0
                            ? (r.amount.abs() / max).clamp(0.0, 1.0)
                            : 0,
                        color: r.amount < 0 ? _positive : _otherExpenseColor,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
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
// Expense mix
// ─────────────────────────────────────────────────────────────────────────

class _ExpenseMixCard extends StatelessWidget {
  final PnlSummary summary;
  const _ExpenseMixCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slices = [
      _Slice(l10n.pnlCostOfSales, summary.costOfSales, _costColor),
      _Slice(l10n.pnlShippingExpense, summary.shippingExpense, _shippingColor),
      _Slice(
        l10n.pnlRecurringExpenses,
        summary.recurringExpenses,
        _recurringColor,
      ),
      _Slice(l10n.pnlOtherExpenses, summary.otherExpenses, _otherExpenseColor),
    ].where((s) => s.value > 0).toList();
    return ReportChartCard(
      title: l10n.pnlExpenseMix,
      height: 180,
      isEmpty: slices.isEmpty,
      emptyText: l10n.reportNoData,
      child: _DonutWithLegend(slices: slices),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shared small pieces
// ─────────────────────────────────────────────────────────────────────────

class _Slice {
  final String label;
  final double value;
  final Color color;
  const _Slice(this.label, this.value, this.color);
}

class _DonutWithLegend extends StatelessWidget {
  final List<_Slice> slices;
  const _DonutWithLegend({required this.slices});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = slices.fold<double>(0, (s, e) => s + e.value);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: LayoutBuilder(
            builder: (context, c) {
              final d = c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight;
              final outer = (d / 2) - 2;
              return PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: (outer * 0.4).clamp(12.0, 42.0),
                  sections: [
                    for (final s in slices)
                      PieChartSectionData(
                        value: s.value,
                        color: s.color,
                        radius: (outer * 0.6).clamp(22.0, 55.0),
                        title: total > 0 && s.value / total >= 0.06
                            ? '${(s.value / total * 100).toStringAsFixed(0)}%'
                            : '',
                        titleStyle: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in slices)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      _Swatch(color: s.color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          s.label,
                          style: theme.textTheme.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        formatCompactCurrency(context, s.value),
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
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  const _Swatch({required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

/// A legend on its own full-width line above the chart. Beside the card title
/// it only gets half a 360dp phone, and four labels overflow there.
class _WithLegend extends StatelessWidget {
  final Widget legend;
  final Widget chart;
  const _WithLegend({required this.legend, required this.chart});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      legend,
      const SizedBox(height: 8),
      Expanded(child: chart),
    ],
  );
}

class _Legend extends StatelessWidget {
  final List<_LegendItem> items;
  const _Legend({required this.items});

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 10, runSpacing: 2, children: items);
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _Swatch(color: color),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
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
          Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
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

// ── pure helpers ──────────────────────────────────────────────────────────

double _pos(double v) => v > 0 ? v : 0;

String _pct(double v) => v.toStringAsFixed(v.abs() >= 10 ? 0 : 1);

String _compact(num value) => NumberFormat.compact().format(value);

String _bucketLabel(BuildContext context, String raw, String granularity) {
  final d = DateTime.tryParse(raw);
  if (d == null) return raw;
  final locale = context.l10n.localeName;
  return granularity == 'month'
      ? DateFormat('MMM yy', locale).format(d)
      : DateFormat('M/d', locale).format(d);
}

Color _channelColor(String channel) => switch (channel) {
  'b2c' => _b2cColor,
  'b2b' => _b2bColor,
  _ => _otherSalesColor,
};

String _channelLabel(BuildContext context, String channel) {
  final l10n = context.l10n;
  return switch (channel) {
    'b2c' => l10n.pnlChannelB2c,
    'b2b' => l10n.pnlChannelB2b,
    'staff' => l10n.pnlChannelStaff,
    'samples' => l10n.pnlChannelSamples,
    'adjustments' => l10n.pnlChannelAdjustments,
    _ => channel,
  };
}

FlTitlesData _titles(ThemeData theme, List<String> labels) {
  // At most ~6 labels. BarChart asks for a title per group and ignores
  // `interval`, so the step is also enforced inside getTitlesWidget.
  final step = labels.isEmpty
      ? 1
      : (labels.length / 6).ceil().clamp(1, 1 << 20);
  final interval = step.toDouble();
  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 50,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text(_compact(value), style: theme.textTheme.labelSmall),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: interval,
        reservedSize: 26,
        getTitlesWidget: (value, meta) {
          final i = value.round();
          if (i < 0 ||
              i >= labels.length ||
              value != i.toDouble() ||
              i % step != 0) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            axisSide: meta.axisSide,
            child: Text(labels[i], style: theme.textTheme.labelSmall),
          );
        },
      ),
    ),
  );
}
