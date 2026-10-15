import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/ops_reports.dart';
import '../../state/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_export_button.dart';
import '../widgets/report_section_card.dart';
import '../widgets/report_table.dart';
import 'daily_close_screen.dart'
    show
        OpsKeyValue,
        OpsKpiGrid,
        OpsReportView,
        OpsTwoUp,
        opsCsvDate,
        opsCsvNum,
        opsDateTime,
        opsScopeNote,
        opsSignedColor,
        showOpsDetailSheet;

/// Cash over/short: drawer differences at shift close, by branch, cashier and
/// shift, plus what the Cash Over/Short account actually booked
/// (`ops_reports.get_cash_over_short`).
class CashOverShortScreen extends ConsumerWidget {
  const CashOverShortScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final q = ref.watch(reportQueryProvider);
    final async = ref.watch(cashOverShortProvider(q));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rptCashOverShortTitle),
        actions: [
          ReportExportButton(
            title: l10n.rptCashOverShortTitle,
            rows: () => _csvRows(context, async.valueOrNull),
          ),
        ],
      ),
      body: OpsReportView<CashOverShort>(
        async: async,
        onRefresh: () => ref.refresh(cashOverShortProvider(q).future),
        onRetry: () => ref.invalidate(cashOverShortProvider(q)),
        isEmpty: (d) => d.isEmpty && _ledgerIsEmpty(d.ledger),
        emptyMessage: l10n.rptCashOverShortNoShifts,
        builder: (context, d) {
          final scope = opsScopeNote(context, d.filters);
          return [
            if (scope != null) scope,
            _Kpis(totals: d.totals),
            if (!_ledgerIsEmpty(d.ledger)) _LedgerCard(ledger: d.ledger!),
            OpsTwoUp(
              first: _BranchesCard(branches: d.branches),
              second: _CashiersCard(cashiers: d.cashiers, shifts: d.shifts),
            ),
            _ShiftsCard(shifts: d.shifts),
          ];
        },
      ),
    );
  }

  static bool _ledgerIsEmpty(CashOverShortLedger? l) =>
      l == null ||
      (l.atCloseNet == 0 &&
          l.atOpenNet == 0 &&
          l.unlinkedNet == 0 &&
          l.over == 0 &&
          l.short == 0 &&
          l.net == 0);

  List<List<String>> _csvRows(BuildContext context, CashOverShort? d) {
    if (d == null) return const [];
    final l10n = context.l10n;
    final rows = <List<String>>[
      [l10n.rptCashOverShortBranches],
      [
        l10n.rptCashOverShortBranch,
        l10n.rptCashOverShortShifts,
        l10n.rptCashOverShortOver,
        l10n.rptCashOverShortShort,
        l10n.rptCashOverShortNet,
      ],
      for (final b in d.branches)
        [
          b.branch,
          opsCsvNum(b.shifts),
          opsCsvNum(b.over),
          opsCsvNum(b.short),
          opsCsvNum(b.net),
        ],
      const [],
      [l10n.rptCashOverShortCashiers],
      [
        l10n.rptCashOverShortCashier,
        l10n.rptCashOverShortShifts,
        l10n.rptCashOverShortOver,
        l10n.rptCashOverShortShort,
        l10n.rptCashOverShortNet,
      ],
      for (final c in d.cashiers)
        [
          c.displayName,
          opsCsvNum(c.shifts),
          opsCsvNum(c.over),
          opsCsvNum(c.short),
          opsCsvNum(c.net),
        ],
      const [],
      [l10n.rptCashOverShortShiftList],
      [
        l10n.rptCashOverShortShift,
        l10n.rptCashOverShortBranch,
        l10n.rptCashOverShortCashier,
        l10n.rptCashOverShortOpened,
        l10n.rptCashOverShortClosed,
        l10n.rptCashOverShortExpected,
        l10n.rptCashOverShortCounted,
        l10n.rptCashOverShortDifference,
        l10n.rptCashOverShortOpeningEntry,
        l10n.rptCashOverShortOpeningDifference,
      ],
      for (final s in d.shifts)
        [
          s.name,
          s.branch,
          s.displayName,
          opsCsvDate(s.opened),
          opsCsvDate(s.closed),
          opsCsvNum(s.expected),
          opsCsvNum(s.counted),
          opsCsvNum(s.difference),
          s.openingEntry ?? '',
          opsCsvNum(s.openingDifference),
        ],
    ];
    return rows;
  }
}

// ── KPIs ──────────────────────────────────────────────────────────────────

class _Kpis extends StatelessWidget {
  final CashOverShortTotals totals;

  const _Kpis({required this.totals});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final t = totals;
    return OpsKpiGrid(
      tiles: [
        KpiCard(
          label: l10n.rptCashOverShortNet,
          value: formatCurrency(context, t.net),
          icon: Icons.balance_outlined,
          color: opsSignedColor(context, t.net),
        ),
        KpiCard(
          label: l10n.rptCashOverShortShort,
          value: formatCurrency(context, t.short),
          icon: Icons.trending_down,
          color: t.short > 0 ? theme.colorScheme.error : null,
        ),
        KpiCard(
          label: l10n.rptCashOverShortOver,
          value: formatCurrency(context, t.over),
          icon: Icons.trending_up,
          color: t.over > 0 ? Colors.green.shade700 : null,
        ),
        KpiCard(
          label: l10n.rptCashOverShortShifts,
          value: formatCount(context, t.shifts),
          icon: Icons.point_of_sale_outlined,
        ),
        KpiCard(
          label: l10n.rptCashOverShortWithDiff,
          value: formatCount(context, t.shiftsWithDiff),
          icon: Icons.report_problem_outlined,
          color: t.shiftsWithDiff > 0 ? Colors.orange.shade800 : null,
        ),
      ],
    );
  }
}

// ── Ledger block ──────────────────────────────────────────────────────────

class _LedgerCard extends StatelessWidget {
  final CashOverShortLedger ledger;

  const _LedgerCard({required this.ledger});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final l = ledger;
    OpsKeyValue line(String label, double v, {bool bold = false}) => OpsKeyValue(
          label: label,
          value: formatCurrency(context, v),
          valueColor: opsSignedColor(context, v),
          bold: bold,
        );
    return ReportSectionCard(
      title: l10n.rptCashOverShortLedger,
      subtitle: l10n.rptCashOverShortLedgerHint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          line(l10n.rptCashOverShortAtClose, l.atCloseNet),
          line(l10n.rptCashOverShortAtOpen, l.atOpenNet),
          line(l10n.rptCashOverShortUnlinked, l.unlinkedNet),
          const Divider(height: 16),
          OpsKeyValue(
            label: l10n.rptCashOverShortOver,
            value: formatCurrency(context, l.over),
            valueColor: l.over > 0 ? Colors.green.shade700 : null,
          ),
          OpsKeyValue(
            label: l10n.rptCashOverShortShort,
            value: formatCurrency(context, l.short),
            valueColor: l.short > 0 ? Theme.of(context).colorScheme.error : null,
          ),
          line(l10n.rptCashOverShortNet, l.net, bold: true),
        ],
      ),
    );
  }
}

// ── Tables ────────────────────────────────────────────────────────────────

/// Colours for an over / short / net column triple starting at [firstCol].
Color? _osColor(BuildContext context, int col, int firstCol, double over, double short, double net) {
  if (col == firstCol && over > 0) return Colors.green.shade700;
  if (col == firstCol + 1 && short > 0) return Theme.of(context).colorScheme.error;
  if (col == firstCol + 2) return opsSignedColor(context, net);
  return null;
}

class _BranchesCard extends StatelessWidget {
  final List<CashOverShortBranch> branches;

  const _BranchesCard({required this.branches});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ReportSectionCard(
      title: l10n.rptCashOverShortBranches,
      child: ReportTable(
        columns: [
          ReportColumn(l10n.rptCashOverShortBranch, flex: 3),
          ReportColumn(l10n.rptCashOverShortShifts, numeric: true, flex: 2),
          ReportColumn(l10n.rptCashOverShortOver, numeric: true, flex: 3),
          ReportColumn(l10n.rptCashOverShortShort, numeric: true, flex: 3),
          ReportColumn(l10n.rptCashOverShortNet, numeric: true, flex: 3),
        ],
        rows: [
          for (final b in branches)
            [
              b.branch,
              formatCount(context, b.shifts),
              formatCurrency(context, b.over),
              formatCurrency(context, b.short),
              formatCurrency(context, b.net),
            ],
        ],
        cellColor: (r, c) {
          final b = branches[r];
          return _osColor(context, c, 2, b.over, b.short, b.net);
        },
      ),
    );
  }
}

class _CashiersCard extends StatelessWidget {
  final List<CashOverShortCashier> cashiers;
  final List<CashOverShortShift> shifts;

  const _CashiersCard({required this.cashiers, required this.shifts});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ReportSectionCard(
      title: l10n.rptCashOverShortCashiers,
      subtitle: cashiers.isEmpty ? null : l10n.rptCashOverShortCashiersHint,
      child: ReportTable(
        columns: [
          ReportColumn(l10n.rptCashOverShortCashier, flex: 3),
          ReportColumn(l10n.rptCashOverShortShifts, numeric: true, flex: 2),
          ReportColumn(l10n.rptCashOverShortOver, numeric: true, flex: 3),
          ReportColumn(l10n.rptCashOverShortShort, numeric: true, flex: 3),
          ReportColumn(l10n.rptCashOverShortNet, numeric: true, flex: 3),
        ],
        rows: [
          for (final c in cashiers)
            [
              c.displayName,
              formatCount(context, c.shifts),
              formatCurrency(context, c.over),
              formatCurrency(context, c.short),
              formatCurrency(context, c.net),
            ],
        ],
        maxRows: 10,
        cellColor: (r, col) {
          final c = cashiers[r];
          return _osColor(context, col, 2, c.over, c.short, c.net);
        },
        onRowTap: (i) => _openCashier(context, cashiers[i]),
      ),
    );
  }

  void _openCashier(BuildContext context, CashOverShortCashier c) {
    final l10n = context.l10n;
    final own = shifts.where((s) => s.user == c.user).toList();
    showOpsDetailSheet(
      context,
      title: c.displayName,
      subtitle: c.fullName.isNotEmpty && c.user != c.fullName ? c.user : null,
      children: [
        OpsKeyValue(label: l10n.rptCashOverShortShifts, value: formatCount(context, c.shifts)),
        OpsKeyValue(
          label: l10n.rptCashOverShortOver,
          value: formatCurrency(context, c.over),
          valueColor: c.over > 0 ? Colors.green.shade700 : null,
        ),
        OpsKeyValue(
          label: l10n.rptCashOverShortShort,
          value: formatCurrency(context, c.short),
          valueColor: c.short > 0 ? Theme.of(context).colorScheme.error : null,
        ),
        OpsKeyValue(
          label: l10n.rptCashOverShortNet,
          value: formatCurrency(context, c.net),
          valueColor: opsSignedColor(context, c.net),
          bold: true,
        ),
        if (own.isNotEmpty) ...[
          const Divider(height: 24),
          Text(l10n.rptCashOverShortShiftList, style: Theme.of(context).textTheme.titleSmall),
          _ShiftTable(shifts: own, showCashier: false),
        ],
      ],
    );
  }
}

class _ShiftsCard extends StatelessWidget {
  final List<CashOverShortShift> shifts;

  const _ShiftsCard({required this.shifts});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ReportSectionCard(
      title: l10n.rptCashOverShortShiftList,
      subtitle: shifts.isEmpty ? null : l10n.rptCashOverShortShiftListHint,
      child: LayoutBuilder(
        builder: (context, constraints) => _ShiftTable(
          shifts: shifts,
          showCashier: true,
          wide: constraints.maxWidth >= 600,
          maxRows: 15,
        ),
      ),
    );
  }
}

/// The shift list as a table; tapping a row opens the shift's details.
class _ShiftTable extends StatelessWidget {
  final List<CashOverShortShift> shifts;
  final bool showCashier;
  final bool wide;
  final int? maxRows;

  const _ShiftTable({
    required this.shifts,
    required this.showCashier,
    this.wide = false,
    this.maxRows,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final diffCol = 1 + (wide ? 1 : 0) + (showCashier ? 1 : 0) + (wide ? 2 : 0);
    return ReportTable(
      columns: [
        ReportColumn(l10n.rptCashOverShortClosed, flex: 3),
        if (wide) ReportColumn(l10n.rptCashOverShortBranch, flex: 3),
        if (showCashier) ReportColumn(l10n.rptCashOverShortCashier, flex: 3),
        if (wide) ReportColumn(l10n.rptCashOverShortExpected, numeric: true, flex: 3),
        if (wide) ReportColumn(l10n.rptCashOverShortCounted, numeric: true, flex: 3),
        ReportColumn(l10n.rptCashOverShortDifference, numeric: true, flex: 3),
      ],
      rows: [
        for (final s in shifts)
          [
            s.closed == null ? l10n.rptCashOverShortNotClosed : opsDateTime(context, s.closed),
            if (wide) s.branch,
            if (showCashier) s.displayName,
            if (wide) formatCurrency(context, s.expected),
            if (wide) formatCurrency(context, s.counted),
            formatCurrency(context, s.difference),
          ],
      ],
      maxRows: maxRows,
      cellColor: (r, c) => c == diffCol ? opsSignedColor(context, shifts[r].difference) : null,
      onRowTap: (i) => _openShift(context, shifts[i]),
    );
  }

  void _openShift(BuildContext context, CashOverShortShift s) {
    final l10n = context.l10n;
    showOpsDetailSheet(
      context,
      title: s.name,
      subtitle: [s.branch, s.displayName].where((x) => x.isNotEmpty).join(' · '),
      children: [
        OpsKeyValue(label: l10n.rptCashOverShortOpened, value: opsDateTime(context, s.opened)),
        OpsKeyValue(
          label: l10n.rptCashOverShortClosed,
          value: s.closed == null ? l10n.rptCashOverShortNotClosed : opsDateTime(context, s.closed),
        ),
        const Divider(height: 20),
        OpsKeyValue(label: l10n.rptCashOverShortExpected, value: formatCurrency(context, s.expected)),
        OpsKeyValue(label: l10n.rptCashOverShortCounted, value: formatCurrency(context, s.counted)),
        OpsKeyValue(
          label: l10n.rptCashOverShortDifference,
          value: formatCurrency(context, s.difference),
          valueColor: opsSignedColor(context, s.difference),
          bold: true,
        ),
        if ((s.openingEntry ?? '').isNotEmpty || s.openingDifference != 0) ...[
          const Divider(height: 20),
          if ((s.openingEntry ?? '').isNotEmpty)
            OpsKeyValue(label: l10n.rptCashOverShortOpeningEntry, value: s.openingEntry!),
          OpsKeyValue(
            label: l10n.rptCashOverShortOpeningDifference,
            value: formatCurrency(context, s.openingDifference),
            valueColor: opsSignedColor(context, s.openingDifference),
          ),
        ],
      ],
    );
  }
}
