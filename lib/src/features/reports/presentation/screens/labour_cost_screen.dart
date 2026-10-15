import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/business_reports.dart';
import '../../state/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_chart_card.dart';
import '../widgets/report_export_button.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_section_card.dart';
import '../widgets/report_states.dart';
import '../widgets/report_table.dart';

/// Labour cost (`business_reports.get_labour_cost`): attendance hours and
/// the payroll cost behind them, set against each branch's sales. The
/// `cost_basis` chip says where the cost figure came from.
class LabourCostScreen extends ConsumerWidget {
  const LabourCostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = context.l10n.rptLabourCostTitle;
    final q = ref.watch(reportQueryProvider);
    final async = ref.watch(labourCostProvider(q));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ReportExportButton(
            title: title,
            rows: () => _csvRows(context, async.valueOrNull),
          ),
        ],
      ),
      body: Column(
        children: [
          const ReportFilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  _settle(ref.refresh(labourCostProvider(q).future)),
              child: async.when(
                skipLoadingOnRefresh: true,
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => ReportErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(labourCostProvider(q)),
                ),
                data: (d) => d.isEmpty
                    ? const ReportEmptyView(icon: Icons.badge_outlined)
                    : _Body(data: d),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────

Future<void> _settle(Future<Object?> reload) async {
  try {
    await reload;
  } catch (_) {}
}

String _csvNum(double v) => v.toStringAsFixed(2);

/// [v] is a percentage in 0–100 units.
String _pct(BuildContext context, double? v) => v == null
    ? '—'
    : NumberFormat.decimalPercentPattern(
        locale: context.l10n.localeName,
        decimalDigits: 1,
      ).format(v / 100);

String _hours(BuildContext context, double v) =>
    NumberFormat.decimalPatternDigits(
      locale: context.l10n.localeName,
      decimalDigits: v == v.truncateToDouble() ? 0 : 1,
    ).format(v);

String _branchLabel(BuildContext context, String? label) =>
    label ?? context.l10n.rptLabourUnassigned;

/// Colour for a labour % — green when lean, amber in the usual band, red
/// when labour eats a large share of sales.
Color? _pctColor(BuildContext context, double? v) {
  if (v == null) return null;
  if (v >= 35) return Theme.of(context).colorScheme.error;
  if (v >= 25) return Colors.orange.shade800;
  return Colors.green.shade700;
}

({String label, String help, IconData icon, Color color}) _basisInfo(
  BuildContext context,
  LabourCostBasis basis,
) {
  final l10n = context.l10n;
  return switch (basis) {
    LabourCostBasis.salarySlips => (
        label: l10n.rptLabourBasisSalarySlips,
        help: l10n.rptLabourBasisSalarySlipsHelp,
        icon: Icons.verified_outlined,
        color: Colors.green.shade700,
      ),
    LabourCostBasis.recurringExpense => (
        label: l10n.rptLabourBasisRecurring,
        help: l10n.rptLabourBasisRecurringHelp,
        icon: Icons.event_repeat_outlined,
        color: Colors.blue.shade700,
      ),
    LabourCostBasis.estimate => (
        label: l10n.rptLabourBasisEstimate,
        help: l10n.rptLabourBasisEstimateHelp,
        icon: Icons.info_outline,
        color: Colors.orange.shade800,
      ),
  };
}

List<List<String>> _csvRows(BuildContext context, LabourCost? d) {
  if (d == null) return const [];
  final l10n = context.l10n;
  final unassigned = l10n.rptLabourUnassigned;
  return [
    [
      l10n.rptLabourBranch,
      l10n.rptLabourEmployeeId,
      l10n.rptLabourEmployee,
      l10n.rptLabourDays,
      l10n.rptLabourHours,
      l10n.rptLabourCost,
      l10n.rptLabourSales,
      l10n.rptLabourPctOfSales,
    ],
    // Totals first, then one row per branch, then one row per employee.
    [
      '',
      '',
      '',
      '',
      _csvNum(d.totals.hours),
      _csvNum(d.totals.labourCost),
      _csvNum(d.totals.sales),
      d.totals.labourPct == null ? '' : _csvNum(d.totals.labourPct!),
    ],
    for (final b in d.branches)
      [
        b.label ?? unassigned,
        '',
        '',
        '',
        _csvNum(b.hours),
        _csvNum(b.labourCost),
        _csvNum(b.sales),
        b.labourPct == null ? '' : _csvNum(b.labourPct!),
      ],
    for (final e in d.employees)
      [
        e.branchLabel ?? unassigned,
        e.employee,
        e.displayName,
        e.days.toString(),
        _csvNum(e.hours),
        _csvNum(e.cost),
        '',
        '',
      ],
  ];
}

// ── Body ──────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final LabourCost data;
  const _Body({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final wide = width >= 900;
        final allColumns = width >= 700;
        final branches = [...data.branches]
          ..sort((a, b) => b.labourCost.compareTo(a.labourCost));
        final employees = [...data.employees]
          ..sort((a, b) => b.cost.compareTo(a.cost));

        final chart = _BranchChartCard(rows: branches);
        final branchTable =
            _BranchTableCard(rows: branches, allColumns: allColumns);
        final employeeTable =
            _EmployeesCard(rows: employees, allColumns: allColumns);

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 24),
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
              child: _KpiGrid(totals: data.totals),
            ),
            _BasisCard(basis: data.costBasis),
            if (wide) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (branches.isNotEmpty)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(8),
                        child: chart,
                      ),
                    ),
                  Expanded(child: branchTable),
                ],
              ),
              employeeTable,
            ] else ...[
              if (branches.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.all(8),
                  child: chart,
                ),
              branchTable,
              employeeTable,
            ],
          ],
        );
      },
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final LabourCostTotals totals;
  const _KpiGrid({required this.totals});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tiles = [
      KpiCard(
        label: l10n.rptLabourPctOfSales,
        value: _pct(context, totals.labourPct),
        icon: Icons.pie_chart_outline,
        color: _pctColor(context, totals.labourPct) ?? theme.colorScheme.primary,
      ),
      KpiCard(
        label: l10n.rptLabourCost,
        value: formatCurrency(context, totals.labourCost),
        icon: Icons.payments_outlined,
        color: theme.colorScheme.error,
      ),
      KpiCard(
        label: l10n.rptLabourSales,
        value: formatCurrency(context, totals.sales),
        icon: Icons.point_of_sale_outlined,
        color: Colors.green.shade700,
      ),
      KpiCard(
        label: l10n.rptLabourHours,
        value: _hours(context, totals.hours),
        icon: Icons.schedule_outlined,
        color: theme.colorScheme.tertiary,
      ),
      KpiCard(
        label: l10n.rptLabourSalesPerHour,
        value: totals.salesPerHour == null
            ? '—'
            : formatCurrency(context, totals.salesPerHour!),
        icon: Icons.speed_outlined,
        color: theme.colorScheme.secondary,
      ),
      KpiCard(
        label: l10n.rptLabourHeadcount,
        value: formatCount(context, totals.headcount),
        icon: Icons.groups_outlined,
        color: Colors.blueGrey,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w >= 900 ? 6 : (w >= 600 ? 3 : 2);
        const spacing = 8.0;
        final cardWidth = (w - spacing * (cols - 1)) / cols;
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
}

class _BasisCard extends StatelessWidget {
  final LabourCostBasis basis;
  const _BasisCard({required this.basis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = _basisInfo(context, basis);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
      child: Container(
        padding: const EdgeInsetsDirectional.all(12),
        decoration: BoxDecoration(
          color: info.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: info.color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              avatar: Icon(info.icon, size: 18, color: info.color),
              label: Text(info.label),
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                color: info.color,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(color: info.color.withValues(alpha: 0.5)),
              backgroundColor: theme.colorScheme.surface,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(height: 6),
            Text(info.help, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ── Chart: labour cost vs sales per branch ────────────────────────────────

class _BranchChartCard extends StatelessWidget {
  final List<LabourCostBranch> rows;
  const _BranchChartCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final data = rows.take(8).toList();
    final labourColor = theme.colorScheme.error;
    final salesColor = Colors.green.shade600;
    final maxV = data.fold<double>(
      0,
      (m, b) => [m, b.labourCost, b.sales].reduce((x, y) => x > y ? x : y),
    );

    Widget legend(String text, Color color) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(text, style: theme.textTheme.labelSmall),
          ],
        );

    return ReportChartCard(
      title: l10n.rptLabourChartTitle,
      isEmpty: data.isEmpty || maxV <= 0,
      height: 240,
      trailing: Wrap(
        spacing: 8,
        children: [
          legend(l10n.rptLabourCost, labourColor),
          legend(l10n.rptLabourSales, salesColor),
        ],
      ),
      child: BarChart(
        BarChartData(
          maxY: maxV * 1.15,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                '${_branchLabel(context, data[groupIndex].label)}\n'
                '${rodIndex == 0 ? l10n.rptLabourCost : l10n.rptLabourSales}: '
                '${formatCurrency(context, rod.toY)}',
                theme.textTheme.labelSmall!.copyWith(color: Colors.white),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max) return const SizedBox.shrink();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      formatCompactCurrency(context, value),
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: SizedBox(
                      width: 72,
                      child: Text(
                        _branchLabel(context, data[i].label),
                        style: theme.textTheme.labelSmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 4,
                barRods: [
                  BarChartRodData(
                    toY: data[i].labourCost,
                    color: labourColor,
                    width: 12,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
                  BarChartRodData(
                    toY: data[i].sales,
                    color: salesColor,
                    width: 12,
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

// ── Tables ────────────────────────────────────────────────────────────────

class _BranchTableCard extends StatelessWidget {
  final List<LabourCostBranch> rows;
  final bool allColumns;
  const _BranchTableCard({required this.rows, required this.allColumns});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final columns = [
      ReportColumn(l10n.rptLabourBranch, flex: 3),
      ReportColumn(l10n.rptLabourCost, numeric: true, flex: 2),
      ReportColumn(l10n.rptLabourSales, numeric: true, flex: 2),
      ReportColumn(l10n.rptLabourPctOfSales, numeric: true, flex: 2),
      if (allColumns) ReportColumn(l10n.rptLabourHours, numeric: true, flex: 2),
      if (allColumns)
        ReportColumn(l10n.rptLabourHeadcount, numeric: true, flex: 2),
    ];
    final money = allColumns
        ? (double v) => formatCurrency(context, v)
        : (double v) => formatCompactCurrency(context, v);
    return ReportSectionCard(
      title: l10n.rptLabourByBranch,
      child: ReportTable(
        columns: columns,
        rows: [
          for (final b in rows)
            [
              _branchLabel(context, b.label),
              money(b.labourCost),
              money(b.sales),
              _pct(context, b.labourPct),
              if (allColumns) _hours(context, b.hours),
              if (allColumns) formatCount(context, b.headcount),
            ],
        ],
        cellColor: (r, c) => c == 3 ? _pctColor(context, rows[r].labourPct) : null,
      ),
    );
  }
}

class _EmployeesCard extends StatelessWidget {
  final List<LabourCostEmployee> rows;
  final bool allColumns;
  const _EmployeesCard({required this.rows, required this.allColumns});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final columns = [
      ReportColumn(l10n.rptLabourEmployee, flex: 4),
      if (allColumns) ReportColumn(l10n.rptLabourBranch, flex: 3),
      ReportColumn(l10n.rptLabourDays, numeric: true, flex: 2),
      ReportColumn(l10n.rptLabourHours, numeric: true, flex: 2),
      ReportColumn(l10n.rptLabourCost, numeric: true, flex: 3),
    ];
    return ReportSectionCard(
      title: l10n.rptLabourEmployees,
      child: ReportTable(
        columns: columns,
        rows: [
          for (final e in rows)
            [
              e.displayName,
              if (allColumns) _branchLabel(context, e.branchLabel),
              formatCount(context, e.days),
              _hours(context, e.hours),
              allColumns
                  ? formatCurrency(context, e.cost)
                  : formatCompactCurrency(context, e.cost),
            ],
        ],
        maxRows: 15,
        onRowTap: (i) => _showEmployeeDetail(context, rows[i]),
      ),
    );
  }
}

void _showEmployeeDetail(BuildContext context, LabourCostEmployee e) {
  final l10n = context.l10n;
  final costPerHour = e.hours > 0 ? e.cost / e.hours : null;
  final items = <(String, String)>[
    (l10n.rptLabourEmployeeId, e.employee.isEmpty ? '—' : e.employee),
    (l10n.rptLabourBranch, _branchLabel(context, e.branchLabel)),
    (l10n.rptLabourDays, formatCount(context, e.days)),
    (l10n.rptLabourHours, _hours(context, e.hours)),
    (l10n.rptLabourCost, formatCurrency(context, e.cost)),
    (
      l10n.rptLabourCostPerHour,
      costPerHour == null ? '—' : formatCurrency(context, costPerHour),
    ),
  ];
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                e.displayName,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              for (final (label, value) in items)
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(label, style: theme.textTheme.bodyMedium),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        value,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
