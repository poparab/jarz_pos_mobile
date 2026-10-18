import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../data/models/report_json.dart';
import '../../data/models/revenue_dashboard.dart';
import '../../state/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_chart_card.dart';
import '../widgets/report_export_button.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_states.dart';
import '../widgets/report_table.dart';

/// The owner's daily revenue dashboard
/// (`revenue_dashboard.get_revenue_dashboard`).
///
/// Top to bottom: a today-relative snapshot (today, yesterday, last 7 days,
/// month to date, each against its own comparison window) that ignores the
/// picked dates, then the standard filter bar, then the selected period: the
/// KPIs, the B2B vs B2C trend and split, best/worst day, and the breakdowns by
/// source, payment, branch, hour and fulfilment, then the top products and
/// B2B customers. Every figure is the backend's; the screen only lays it out.
///
/// Reached from the side menu with `context.go`, so it carries the drawer.
class RevenueDashboardScreen extends ConsumerStatefulWidget {
  const RevenueDashboardScreen({super.key});

  @override
  ConsumerState<RevenueDashboardScreen> createState() =>
      _RevenueDashboardScreenState();
}

class _RevenueDashboardScreenState
    extends ConsumerState<RevenueDashboardScreen> {
  // The snapshot does not depend on the dates, so while a new range loads the
  // last one stays on screen (for the same branch) instead of a blank page.
  RevenueSnapshot? _lastSnapshot;
  String? _lastSnapshotBranch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final q = ref.watch(reportQueryProvider);
    final async = ref.watch(revenueDashboardProvider(q));
    final loaded = async.valueOrNull;
    if (loaded != null && !loaded.isEmpty) {
      _lastSnapshot = loaded.snapshot;
      _lastSnapshotBranch = q.branchOrNull;
    }
    final cachedSnapshot = _lastSnapshotBranch == q.branchOrNull
        ? _lastSnapshot
        : null;

    Future<void> refresh() async {
      ref.invalidate(revenueDashboardProvider(q));
      try {
        await ref.read(revenueDashboardProvider(q).future);
      } catch (_) {
        // The error state renders it; the spinner only has to stop.
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rptRevenueDashboardTitle),
        actions: [
          ReportExportButton(
            title: l10n.rptRevenueDashboardTitle,
            rows: () => _exportRows(context, async.valueOrNull),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: async.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.all(12),
          children: [
            if (cachedSnapshot != null) ...[
              _SnapshotSection(snapshot: cachedSnapshot),
              const SizedBox(height: 4),
            ],
            const ReportFilterBar(),
            const Padding(
              padding: EdgeInsetsDirectional.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
        error: (e, _) => Column(
          children: [
            const ReportFilterBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: refresh,
                child: ReportErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(revenueDashboardProvider(q)),
                ),
              ),
            ),
          ],
        ),
        data: (data) => data.isEmpty
            ? Column(
                children: [
                  const ReportFilterBar(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: refresh,
                      child: const ReportEmptyView(),
                    ),
                  ),
                ],
              )
            : RefreshIndicator(
                onRefresh: refresh,
                child: RevenueDashboardContent(
                  data: data,
                  query: q,
                  selectedBranch: q.branchOrNull,
                  onBranchTap: (branch) {
                    // The server's bucket for invoices with no POS Profile is
                    // a label, not a branch: filtering by it matches nothing.
                    if (branch == _noProfile) return;
                    final notifier = ref.read(reportBranchProvider.notifier);
                    notifier.state = notifier.state == branch ? null : branch;
                  },
                ),
              ),
      ),
    );
  }
}

/// The scrollable body, split out so tests can render it from a fixture.
class RevenueDashboardContent extends StatelessWidget {
  final RevenueDashboard data;

  /// The query the data was loaded for; the period header falls back to it
  /// when the payload carries no `filters`.
  final ReportQuery? query;
  final String? selectedBranch;
  final ValueChanged<String>? onBranchTap;

  const RevenueDashboardContent({
    super.key,
    required this.data,
    this.query,
    this.selectedBranch,
    this.onBranchTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final updated = ReportJson.dateTimeOrNull(data.generatedAt);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.all(12),
      children: [
        _SnapshotSection(snapshot: data.snapshot),
        const SizedBox(height: 4),
        const ReportFilterBar(),
        const SizedBox(height: 4),
        _PeriodHeader(data: data, query: query),
        const SizedBox(height: 8),
        _PeriodKpis(summary: data.summary),
        const SizedBox(height: 12),
        _TrendCard(data: data),
        const SizedBox(height: 12),
        _SplitCard(summary: data.summary),
        const SizedBox(height: 12),
        _BestWorstCard(summary: data.summary),
        const SizedBox(height: 12),
        _BarListCard(
          title: l10n.rptRevBySourceTitle,
          rows: [
            for (final r in data.bySource)
              _BarRowData(
                label: _sourceLabel(context, r.source),
                value: r.netSales,
                sharePct: r.sharePct,
                orders: r.orders,
                color: _sourceColor(r.source),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _BarListCard(
          title: l10n.rptRevByPaymentTitle,
          rows: [
            for (final r in data.byPayment)
              _BarRowData(
                label: _paymentLabel(context, r.method),
                value: r.netSales,
                sharePct: r.sharePct,
                orders: r.orders,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
        const SizedBox(height: 12),
        _ByBranchCard(
          rows: data.byBranch,
          selected: selectedBranch,
          onTap: onBranchTap,
        ),
        const SizedBox(height: 12),
        _ByHourCard(rows: data.hourly),
        const SizedBox(height: 12),
        _FulfilmentCard(fulfilment: data.fulfilment),
        const SizedBox(height: 12),
        _TopProductsCard(rows: data.topProducts),
        const SizedBox(height: 12),
        _TopB2bCard(rows: data.topB2bCustomers),
        if (updated != null) ...[
          const SizedBox(height: 12),
          Text(
            l10n.rptRevUpdatedAt(formatDateTime(context, updated)),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Snapshot strip (independent of the picked dates)
// ─────────────────────────────────────────────────────────────────────────

class _SnapshotSection extends StatelessWidget {
  final RevenueSnapshot snapshot;
  const _SnapshotSection({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cards = <Widget>[
      _SnapshotCard(
        key: const ValueKey('revenue-snapshot-today'),
        title: l10n.rptRevToday,
        caption: l10n.rptRevVsSameDayLastWeek,
        period: snapshot.today,
      ),
      _SnapshotCard(
        key: const ValueKey('revenue-snapshot-yesterday'),
        title: l10n.rptRevYesterday,
        caption: l10n.rptRevVsSameDayLastWeek,
        period: snapshot.yesterday,
      ),
      _SnapshotCard(
        key: const ValueKey('revenue-snapshot-last-7-days'),
        title: l10n.rptRevLast7Days,
        caption: l10n.rptRevVsPrevious7Days,
        period: snapshot.last7Days,
      ),
      _SnapshotCard(
        key: const ValueKey('revenue-snapshot-month-to-date'),
        title: l10n.rptRevMonthToDate,
        caption: l10n.rptRevVsSameDaysLastMonth,
        period: snapshot.monthToDate,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: l10n.rptRevAtAGlance,
          subtitle: l10n.rptRevSnapshotNote,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            // 2x2 on a phone, one row of four on a tablet.
            final perRow = constraints.maxWidth >= 600 ? 4 : 2;
            const gap = 8.0;
            return Column(
              children: [
                for (var start = 0; start < cards.length; start += perRow) ...[
                  if (start > 0) const SizedBox(height: gap),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = start; i < start + perRow; i++) ...[
                          if (i > start) const SizedBox(width: gap),
                          Expanded(
                            child: i < cards.length
                                ? cards[i]
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        if (theme.brightness == Brightness.dark) const SizedBox(height: 2),
      ],
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  final String title;
  final String caption;
  final RevenueSnapshotPeriod period;

  const _SnapshotCard({
    super.key,
    required this.title,
    required this.caption,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: muted,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                formatCompactCurrency(context, period.netSales),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            _SplitLine(
              color: _b2cColor,
              label: l10n.rptRevColB2c,
              value: formatCompactCurrency(context, period.b2c),
            ),
            _SplitLine(
              color: _b2bColor,
              label: l10n.rptRevColB2b,
              value: formatCompactCurrency(context, period.b2b),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.pnlOrdersCount(period.orders),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
            ),
            const Spacer(),
            const SizedBox(height: 4),
            _ChangeText(pct: period.changePct),
            Text(
              caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitLine extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _SplitLine({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 1),
      child: Row(
        children: [
          _Swatch(color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            flex: 2,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: style?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// "▲ 12.5%" in green, "▼ 3.0%" in red, "—" when there is nothing to compare.
class _ChangeText extends StatelessWidget {
  final double? pct;
  const _ChangeText({required this.pct});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      _changeLabel(pct),
      maxLines: 1,
      style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: _changeColor(context, pct),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Selected period: header + KPIs
// ─────────────────────────────────────────────────────────────────────────

class _PeriodHeader extends StatelessWidget {
  final RevenueDashboard data;
  final ReportQuery? query;
  const _PeriodHeader({required this.data, this.query});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final from = data.filters.dateFrom.isNotEmpty
        ? data.filters.dateFrom
        : (query?.fromIso ?? '');
    final to = data.filters.dateTo.isNotEmpty
        ? data.filters.dateTo
        : (query?.toIso ?? '');
    final prev = data.summary.previous;
    final range = from.isEmpty
        ? null
        : l10n.rptRevRange(_day(context, from), _day(context, to));
    final previous = prev.dateFrom.isEmpty
        ? null
        : l10n.rptRevPreviousRange(
            _day(context, prev.dateFrom),
            _day(context, prev.dateTo),
          );
    return _SectionHeader(
      title: range == null
          ? l10n.rptRevPeriodTitle
          : '${l10n.rptRevPeriodTitle} · $range',
      subtitle: previous,
    );
  }
}

class _PeriodKpis extends StatelessWidget {
  final RevenueSummary summary;
  const _PeriodKpis({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final s = summary;
    final p = s.previous;
    String money(double v) => formatCompactCurrency(context, v);
    String moneyOrDash(double? v) => v == null ? _dash : money(v);

    final cards = <Widget Function(double)>[
      (w) => KpiCard(
        width: w,
        label: l10n.rptRevNetSales,
        value: money(s.netSales),
        icon: Icons.payments_outlined,
        color: theme.colorScheme.primary,
        delta: _changeLabel(p.changePct),
        deltaColor: _changeColor(context, p.changePct),
        caption: l10n.rptRevVsPreviousPeriod,
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.rptRevB2c,
        value: money(s.b2c),
        icon: Icons.person_outline,
        color: _b2cColor,
        delta: _changeLabel(p.b2cChangePct),
        deltaColor: _changeColor(context, p.b2cChangePct),
        caption: l10n.pnlOrdersCount(s.b2cOrders),
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.rptRevB2b,
        value: money(s.b2b),
        icon: Icons.business_outlined,
        color: _b2bColor,
        delta: _changeLabel(p.b2bChangePct),
        deltaColor: _changeColor(context, p.b2bChangePct),
        caption: l10n.rptRevShareOfSales(_pctOrDash(s.b2bSharePct)),
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.reportKpiOrders,
        value: formatCount(context, s.orders),
        icon: Icons.receipt_long_outlined,
        color: theme.colorScheme.tertiary,
        delta: _changeLabel(p.ordersChangePct),
        deltaColor: _changeColor(context, p.ordersChangePct),
        caption: l10n.rptRevOrdersSplit(
          formatCount(context, s.b2cOrders),
          formatCount(context, s.b2bOrders),
          formatCount(context, s.otherOrders),
        ),
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.reportKpiAov,
        value: moneyOrDash(s.aov),
        icon: Icons.shopping_cart_outlined,
        color: theme.colorScheme.secondary,
        caption: l10n.rptRevAovSplit(
          moneyOrDash(s.b2cAov),
          moneyOrDash(s.b2bAov),
        ),
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.rptRevDeliveryFees,
        value: money(s.shippingIncome),
        icon: Icons.local_shipping_outlined,
        color: _shippingColor,
        caption: l10n.rptRevInclFees(money(s.totalRevenue)),
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.rptRevDailyAverage,
        value: money(s.dailyAverage),
        icon: Icons.calendar_today_outlined,
        color: Colors.indigo.shade600,
        caption: l10n.rptRevDaysCount(s.days),
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.reportKpiCustomers,
        value: formatCount(context, s.customers),
        icon: Icons.groups_outlined,
        color: Colors.teal.shade700,
        caption: l10n.rptRevNewCustomers(formatCount(context, s.newCustomers)),
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.rptRevReturns,
        value: money(s.returnsValue),
        icon: Icons.assignment_return_outlined,
        color: s.returns > 0 ? _negative : theme.colorScheme.outline,
        caption: l10n.rptRevReturnsCount(formatCount(context, s.returns)),
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.rptRevCancelled,
        value: money(s.cancelledValue),
        icon: Icons.cancel_outlined,
        color: s.cancelled > 0 ? _negative : theme.colorScheme.outline,
        caption: l10n.rptRevCancelledCount(formatCount(context, s.cancelled)),
      ),
      (w) => KpiCard(
        width: w,
        label: l10n.rptRevDiscounts,
        value: money(s.discountTotal),
        icon: Icons.local_offer_outlined,
        color: Colors.pink.shade600,
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
// B2B vs B2C: stacked trend, donut, best / worst day
// ─────────────────────────────────────────────────────────────────────────

class _TrendCard extends StatelessWidget {
  final RevenueDashboard data;
  const _TrendCard({required this.data});

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
        (_pos(p.other), _otherColor),
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
      title: l10n.rptRevTrendTitle,
      subtitle: switch (data.granularity) {
        'month' => l10n.rptRevPerMonth,
        'week' => l10n.rptRevPerWeek,
        _ => l10n.rptRevPerDay,
      },
      height: 240,
      isEmpty: points.isEmpty || maxY <= 0,
      emptyText: l10n.reportNoData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Legend(
            items: [
              _LegendItem(color: _b2cColor, label: l10n.rptRevB2c),
              _LegendItem(color: _b2bColor, label: l10n.rptRevB2b),
              _LegendItem(color: _otherColor, label: l10n.rptRevOther),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BarChart(
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
                titlesData: _titles(context, labels),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitCard extends StatelessWidget {
  final RevenueSummary summary;
  const _SplitCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slices = [
      _Slice(l10n.rptRevB2c, summary.b2c, _b2cColor),
      _Slice(l10n.rptRevB2b, summary.b2b, _b2bColor),
      _Slice(l10n.rptRevOther, summary.other, _otherColor),
    ].where((s) => s.value > 0).toList();
    return ReportChartCard(
      title: l10n.rptRevSplitTitle,
      height: 180,
      isEmpty: slices.isEmpty,
      emptyText: l10n.reportNoData,
      child: _DonutWithLegend(slices: slices),
    );
  }
}

class _BestWorstCard extends StatelessWidget {
  final RevenueSummary summary;
  const _BestWorstCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    Widget line(IconData icon, Color color, String label, RevenueDay? day) =>
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.bodyMedium),
                    Text(
                      day == null
                          ? _dash
                          : _day(context, day.date, pattern: 'EEE d MMM yyyy'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  day == null ? _dash : formatCurrency(context, day.netSales),
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardTitle(l10n.rptRevBestWorstTitle),
            const SizedBox(height: 4),
            line(Icons.trending_up, _positive, l10n.rptRevBestDay,
                summary.bestDay),
            line(Icons.trending_down, _negative, l10n.rptRevWorstDay,
                summary.worstDay),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Breakdowns: source, payment (bars), branch (table)
// ─────────────────────────────────────────────────────────────────────────

class _BarRowData {
  final String label;
  final double value;
  final double? sharePct;
  final int orders;
  final Color color;
  const _BarRowData({
    required this.label,
    required this.value,
    required this.sharePct,
    required this.orders,
    required this.color,
  });
}

/// Horizontal bars, one per row: label, amount and share above, a bar scaled
/// to the largest row below. Stacked rather than side by side so a long
/// Arabic label never squeezes the numbers off a 360dp phone.
class _BarListCard extends StatelessWidget {
  final String title;
  final List<_BarRowData> rows;
  const _BarListCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final max = rows.fold<double>(
      0,
      (m, r) => r.value.abs() > m ? r.value.abs() : m,
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardTitle(title),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              Text(l10n.reportNoData, style: theme.textTheme.bodySmall),
            for (final r in rows)
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                l10n.pnlOrdersCount(r.orders),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${formatCompactCurrency(context, r.value)} · ${_pctOrDash(r.sharePct)}%',
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: max > 0
                            ? (_pos(r.value) / max).clamp(0.0, 1.0)
                            : 0,
                        color: r.color,
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

class _ByBranchCard extends StatelessWidget {
  final List<RevenueBranchRow> rows;
  final String? selected;
  final ValueChanged<String>? onTap;
  const _ByBranchCard({required this.rows, this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final selectedIndex = rows.indexWhere((r) => r.branch == selected);
    final tap = onTap;
    String n(double v) => _compact(context, v);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardTitle(l10n.rptRevByBranchTitle),
            Text(
              l10n.rptRevAmountsIn(currencySymbol(context)),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            ReportTable(
              columns: [
                ReportColumn(l10n.rptBranchLabel, flex: 4),
                ReportColumn(l10n.rptRevColNet, numeric: true, flex: 3),
                ReportColumn(l10n.rptRevColB2c, numeric: true, flex: 3),
                ReportColumn(l10n.rptRevColB2b, numeric: true, flex: 3),
                ReportColumn(l10n.reportKpiOrders, numeric: true, flex: 3),
                ReportColumn(l10n.rptRevColShare, numeric: true, flex: 3),
              ],
              rows: [
                for (final r in rows)
                  [
                    r.branch == _noProfile ? l10n.rptRevNoProfile : r.branch,
                    n(r.netSales),
                    n(r.b2c),
                    n(r.b2b),
                    formatCount(context, r.orders),
                    '${_pctOrDash(r.sharePct)}%',
                  ],
              ],
              cellColor: (row, col) =>
                  row == selectedIndex ? theme.colorScheme.primary : null,
              onRowTap: tap == null ? null : (i) => tap(rows[i].branch),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Orders by hour, delivery vs pickup
// ─────────────────────────────────────────────────────────────────────────

class _ByHourCard extends StatelessWidget {
  /// Always 24 rows (see [RevenueDashboard.hourly]).
  final List<RevenueHourRow> rows;
  const _ByHourCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final maxY = rows.fold<int>(0, (m, r) => r.orders > m ? r.orders : m);
    final color = theme.colorScheme.primary;
    return ReportChartCard(
      title: l10n.rptRevByHourTitle,
      height: 200,
      isEmpty: maxY <= 0,
      emptyText: l10n.reportNoData,
      child: BarChart(
        BarChartData(
          maxY: maxY <= 0 ? 1 : maxY * 1.2,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (final r in rows)
              BarChartGroupData(
                x: r.hour,
                barRods: [
                  BarChartRodData(
                    toY: r.orders.toDouble(),
                    color: color,
                    width: 6,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
          ],
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, _) {
                final r = rows.firstWhere(
                  (e) => e.hour == group.x,
                  orElse: () => RevenueHourRow(hour: group.x),
                );
                return BarTooltipItem(
                  l10n.rptRevHourTooltip(
                    '${r.hour}',
                    formatCount(context, r.orders),
                    formatCompactCurrency(context, r.netSales),
                  ),
                  theme.textTheme.labelSmall!.copyWith(color: Colors.white),
                );
              },
            ),
          ),
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
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  if (value != value.roundToDouble()) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      _compact(context, value),
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final h = value.round();
                  // Every third hour: 24 labels do not fit a phone.
                  if (value != h.toDouble() || h % 3 != 0) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text('$h', style: theme.textTheme.labelSmall),
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

class _FulfilmentCard extends StatelessWidget {
  final RevenueFulfilment fulfilment;
  const _FulfilmentCard({required this.fulfilment});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final total = fulfilment.total;
    const deliveryColor = _shippingColor;
    final pickupColor = Colors.teal.shade600;

    Widget figure(IconData icon, Color color, String label, int count) =>
        Expanded(
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatCount(context, count),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      total > 0
                          ? '$label · ${_pct(count * 100 / total)}%'
                          : label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardTitle(l10n.rptRevFulfilmentTitle),
            const SizedBox(height: 8),
            Row(
              children: [
                figure(
                  Icons.delivery_dining_outlined,
                  deliveryColor,
                  l10n.rptRevDelivery,
                  fulfilment.deliveryOrders,
                ),
                const SizedBox(width: 8),
                figure(
                  Icons.storefront_outlined,
                  pickupColor,
                  l10n.rptRevPickup,
                  fulfilment.pickupOrders,
                ),
              ],
            ),
            if (total > 0) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      if (fulfilment.deliveryOrders > 0)
                        Expanded(
                          flex: fulfilment.deliveryOrders,
                          child: const ColoredBox(color: deliveryColor),
                        ),
                      if (fulfilment.pickupOrders > 0)
                        Expanded(
                          flex: fulfilment.pickupOrders,
                          child: ColoredBox(color: pickupColor),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Top 10 tables
// ─────────────────────────────────────────────────────────────────────────

class _TopProductsCard extends StatelessWidget {
  final List<RevenueProductRow> rows;
  const _TopProductsCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardTitle(l10n.rptRevTopProductsTitle),
            const SizedBox(height: 4),
            ReportTable(
              columns: [
                ReportColumn(l10n.rptRevColProduct, flex: 5),
                ReportColumn(l10n.rptRevColQty, numeric: true, flex: 2),
                ReportColumn(l10n.rptRevColNet, numeric: true, flex: 3),
              ],
              rows: [
                for (final r in rows.take(10))
                  [
                    r.displayName,
                    formatCount(context, r.qty),
                    formatCompactCurrency(context, r.netSales),
                  ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopB2bCard extends StatelessWidget {
  final List<RevenueB2bCustomerRow> rows;
  const _TopB2bCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardTitle(l10n.rptRevTopB2bTitle),
            const SizedBox(height: 4),
            ReportTable(
              columns: [
                ReportColumn(l10n.rptRevColCustomer, flex: 5),
                ReportColumn(l10n.reportKpiOrders, numeric: true, flex: 2),
                ReportColumn(l10n.rptRevColNet, numeric: true, flex: 3),
              ],
              rows: [
                for (final r in rows.take(10))
                  [
                    r.displayName,
                    formatCount(context, r.orders),
                    formatCompactCurrency(context, r.netSales),
                  ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shared small pieces
// ─────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = subtitle;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (sub != null && sub.isNotEmpty)
            Text(
              sub,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String text;
  const _CardTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
  );
}

class _Slice {
  final String label;
  final double value;
  final Color color;
  const _Slice(this.label, this.value, this.color);
}

/// Donut on the start side, and per slice its label, value and percentage.
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
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 3),
                        child: _Swatch(color: s.color),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.label,
                              style: theme.textTheme.labelSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${formatCompactCurrency(context, s.value)} · '
                              '${total > 0 ? _pct(s.value / total * 100) : _dash}%',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

// ── colours: B2C / B2B match the P&L report, so a channel reads the same ──

const _b2cColor = Color(0xFF1E88E5);
const _b2bColor = Color(0xFF8E24AA);
const _otherColor = Color(0xFF90A4AE);
const _shippingColor = Color(0xFFFB8C00);
final _positive = Colors.green.shade700;
const _negative = Color(0xFFD32F2F);

/// The backend's label for invoices with no POS Profile.
const _noProfile = '(No Profile)';

/// Shown where the backend sends null (nothing to compare, no orders).
const _dash = '—';

Color _sourceColor(String source) => switch (source) {
  'pos' => const Color(0xFF1E88E5),
  'woo' => const Color(0xFF43A047),
  'talabat' => const Color(0xFFFF6D00),
  'partner' => const Color(0xFF00897B),
  'b2b' => _b2bColor,
  'staff' => _otherColor,
  'samples' => const Color(0xFFA1887F),
  _ => const Color(0xFF78909C),
};

String _sourceLabel(BuildContext context, String source) {
  final l10n = context.l10n;
  return switch (source) {
    'pos' => l10n.rptRevSourcePos,
    'woo' => l10n.rptRevSourceWoo,
    'talabat' => l10n.rptRevSourceTalabat,
    'partner' => l10n.rptRevSourcePartner,
    'b2b' => l10n.rptRevB2b,
    'staff' => l10n.rptRevSourceStaff,
    'samples' => l10n.rptRevSourceSamples,
    _ => source.isEmpty ? l10n.commonNotSpecified : source,
  };
}

String _paymentLabel(BuildContext context, String method) =>
    method.trim().toLowerCase() == 'unspecified'
    ? context.l10n.commonNotSpecified
    : localizedPaymentMethodLabel(context, method);

// ── pure helpers ──────────────────────────────────────────────────────────

double _pos(double v) => v > 0 ? v : 0;

/// One decimal, as the backend rounds percentages.
String _pct(double v) => v.toStringAsFixed(1);

String _pctOrDash(double? v) => v == null ? _dash : _pct(v);

String _changeLabel(double? pct) {
  if (pct == null) return _dash;
  if (pct > 0) return '▲ ${_pct(pct)}%';
  if (pct < 0) return '▼ ${_pct(pct.abs())}%';
  return '${_pct(0)}%';
}

Color _changeColor(BuildContext context, double? pct) {
  if (pct == null || pct == 0) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
  return pct > 0 ? _positive : _negative;
}

String _compact(BuildContext context, num value) =>
    NumberFormat.compact(locale: context.l10n.localeName).format(value);

/// An ISO date as e.g. "18 Oct 2026"; the raw text when it does not parse.
String _day(BuildContext context, String raw, {String pattern = 'd MMM yyyy'}) {
  final d = DateTime.tryParse(raw);
  if (d == null) return raw.isEmpty ? _dash : raw;
  return DateFormat(pattern, context.l10n.localeName).format(d);
}

String _bucketLabel(BuildContext context, String raw, String granularity) {
  final d = DateTime.tryParse(raw);
  if (d == null) return raw;
  final locale = context.l10n.localeName;
  return granularity == 'month'
      ? DateFormat('MMM yy', locale).format(d)
      : DateFormat('M/d', locale).format(d);
}

FlTitlesData _titles(BuildContext context, List<String> labels) {
  final theme = Theme.of(context);
  // At most ~6 labels. BarChart asks for a title per group and ignores
  // `interval`, so the step is also enforced inside getTitlesWidget.
  final step = labels.isEmpty
      ? 1
      : (labels.length / 6).ceil().clamp(1, 1 << 20);
  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 50,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text(
            _compact(context, value),
            style: theme.textTheme.labelSmall,
          ),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: step.toDouble(),
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

// ── CSV export ────────────────────────────────────────────────────────────

List<List<String>> _exportRows(BuildContext context, RevenueDashboard? data) {
  if (data == null || data.isEmpty) return const [];
  final l10n = context.l10n;
  final s = data.summary;
  final snap = data.snapshot;
  String n(num v) => v.toStringAsFixed(2);
  String o(double? v) => v == null ? '' : n(v);
  return [
    [l10n.rptG1ColMetric, l10n.rptG1ColAmount],
    [l10n.rptRevToday, n(snap.today.netSales)],
    [l10n.rptRevYesterday, n(snap.yesterday.netSales)],
    [l10n.rptRevLast7Days, n(snap.last7Days.netSales)],
    [l10n.rptRevMonthToDate, n(snap.monthToDate.netSales)],
    const <String>[],
    [l10n.rptRevNetSales, n(s.netSales)],
    [l10n.rptRevB2c, n(s.b2c)],
    [l10n.rptRevB2b, n(s.b2b)],
    [l10n.rptRevOther, n(s.other)],
    [l10n.rptRevDeliveryFees, n(s.shippingIncome)],
    [l10n.pnlTotalRevenue, n(s.totalRevenue)],
    [l10n.reportKpiOrders, '${s.orders}'],
    [l10n.reportKpiAov, o(s.aov)],
    [l10n.rptRevDailyAverage, n(s.dailyAverage)],
    [l10n.reportKpiCustomers, '${s.customers}'],
    [l10n.rptRevReturns, n(s.returnsValue)],
    [l10n.rptRevCancelled, n(s.cancelledValue)],
    [l10n.rptRevDiscounts, n(s.discountTotal)],
    if (data.byBranch.isNotEmpty) ...[
      const <String>[],
      [
        l10n.rptBranchLabel,
        l10n.rptRevColNet,
        l10n.rptRevColB2c,
        l10n.rptRevColB2b,
        l10n.reportKpiOrders,
      ],
      for (final b in data.byBranch)
        [b.branch, n(b.netSales), n(b.b2c), n(b.b2b), '${b.orders}'],
    ],
  ];
}
