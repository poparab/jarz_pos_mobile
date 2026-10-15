import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/models/ops_reports.dart';
import '../../data/models/report_json.dart';
import '../../state/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_export_button.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_section_card.dart';
import '../widgets/report_table.dart';

// ═════════════════════════════════════════════════════════════════════════
// Shared helpers for the three daily-operations reports (daily close, cash
// over/short, fulfilment SLA). Public so the sibling screens can import them.
// ═════════════════════════════════════════════════════════════════════════

/// Report body: the filter card (and any [header] widgets) scroll with the
/// content, so a phone in landscape still has room for the report. The whole
/// view is one scrollable under a [RefreshIndicator], so loading, error and
/// empty states can all be pulled to refresh.
class OpsReportView<T> extends StatelessWidget {
  final AsyncValue<T> async;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final List<Widget> header;
  final bool Function(T data) isEmpty;
  final String? emptyMessage;
  final List<Widget> Function(BuildContext context, T data) builder;

  const OpsReportView({
    super.key,
    required this.async,
    required this.onRefresh,
    required this.onRetry,
    required this.isEmpty,
    required this.builder,
    this.header = const [],
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = async.when(
      loading: () => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsetsDirectional.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (e, _) => SliverFillRemaining(
        hasScrollBody: false,
        child: _OpsStateBody(
          icon: Icons.error_outline,
          isError: true,
          title: context.l10n.reportError,
          message: context.userErrorMessage(e),
          onRetry: onRetry,
        ),
      ),
      data: (data) {
        if (isEmpty(data)) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _OpsStateBody(
              icon: Icons.insights_outlined,
              title: emptyMessage ?? context.l10n.reportNoData,
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 24),
          sliver: SliverList.list(children: builder(context, data)),
        );
      },
    );

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverList.list(
            children: [const ReportFilterBar(), ...header],
          ),
          content,
        ],
      ),
    );
  }
}

class _OpsStateBody extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final bool isError;
  final VoidCallback? onRetry;

  const _OpsStateBody({
    required this.icon,
    required this.title,
    this.message,
    this.isError = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Icon(
            icon,
            size: 48,
            color: isError ? theme.colorScheme.error : theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: isError
                ? theme.textTheme.titleMedium
                : theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.reportsRetry),
            ),
          ],
        ],
      ),
    );
  }
}

/// KPI tiles in a responsive grid (2 on a phone, up to 5 on a wide tablet).
class OpsKpiGrid extends StatelessWidget {
  final List<Widget> tiles;

  const OpsKpiGrid({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final columns = w >= 1100
              ? 5
              : w >= 820
                  ? 4
                  : w >= 520
                      ? 3
                      : 2;
          const spacing = 8.0;
          final width = (w - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final t in tiles) SizedBox(width: width, child: t),
            ],
          );
        },
      ),
    );
  }
}

/// Two sections side by side on a wide screen, stacked on a phone.
class OpsTwoUp extends StatelessWidget {
  final Widget first;
  final Widget second;
  final double breakpoint;

  const OpsTwoUp({
    super.key,
    required this.first,
    required this.second,
    this.breakpoint = 760,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [first, second],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: first), Expanded(child: second)],
        );
      },
    );
  }
}

/// A small info line (icon + text) used for scope and data-quality notes.
class OpsNote extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? color;

  const OpsNote({
    super.key,
    required this.text,
    this.icon = Icons.info_outline,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 14, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: c),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Limited to your branches: …" when the server scoped a line manager.
Widget? opsScopeNote(BuildContext context, JsonMap filters) {
  final scoped = ReportJson.strings(filters['scoped_to']);
  if (scoped.isEmpty) return null;
  return OpsNote(
    icon: Icons.lock_outline,
    text: context.l10n.rptDailyCloseScopedTo(scoped.join('، ')),
  );
}

/// Green for a positive amount, the error colour for a negative one.
Color? opsSignedColor(BuildContext context, double value) {
  if (value > 0.004) return Colors.green.shade700;
  if (value < -0.004) return Theme.of(context).colorScheme.error;
  return null;
}

/// Localised percentage of [part] in [whole] (e.g. "12.5%"), or "—".
String opsPercent(BuildContext context, double part, double whole) {
  if (whole == 0) return '—';
  return NumberFormat.decimalPercentPattern(
    locale: context.l10n.localeName,
    decimalDigits: 1,
  ).format(part / whole);
}

/// Minutes as "45 min" / "1 h 20 min"; "—" when null.
String opsMinutes(BuildContext context, double? minutes) {
  if (minutes == null) return '—';
  final l10n = context.l10n;
  final nf = NumberFormat.decimalPattern(l10n.localeName);
  final total = minutes.round();
  if (total.abs() < 60) return l10n.rptSlaMinutes(nf.format(total));
  final sign = total < 0 ? '-' : '';
  final abs = total.abs();
  return '$sign${l10n.rptSlaHoursMinutes(nf.format(abs ~/ 60), nf.format(abs % 60))}';
}

/// Short local date-time ("15 Oct, 3:40 PM"); "—" when null. Server times
/// are naive Cairo-local, so they are shown as sent (no UTC conversion).
String opsDateTime(BuildContext context, DateTime? dt) =>
    dt == null ? '—' : formatDateTime(context, dt, pattern: 'd MMM, h:mm a');

/// Plain number for CSV cells (no grouping, no symbol).
String opsCsvNum(num v, [int digits = 2]) =>
    v is int ? v.toString() : v.toStringAsFixed(digits);

/// ISO-ish timestamp for CSV cells.
String opsCsvDate(DateTime? dt) =>
    dt == null ? '' : DateFormat('yyyy-MM-dd HH:mm').format(dt);

/// Opens a scrollable bottom sheet with a title and arbitrary content.
Future<void> showOpsDetailSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<Widget> children,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 2),
                    child: Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                ...children,
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// One label/value line in a detail sheet or a key-figures card.
class OpsKeyValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const OpsKeyValue({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Channels ──────────────────────────────────────────────────────────────

/// Localised label for a backend channel key (`pos`, `woo`, `talabat`, `b2b`,
/// `staff`, `samples`, `partner`); unknown keys pass through raw.
String opsChannelLabel(BuildContext context, String channel) {
  final l10n = context.l10n;
  return switch (channel.trim().toLowerCase()) {
    'pos' => l10n.rptDailyCloseChannelPos,
    'woo' => l10n.rptDailyCloseChannelWoo,
    'talabat' => l10n.rptDailyCloseChannelTalabat,
    'b2b' => l10n.rptDailyCloseChannelB2b,
    'staff' => l10n.rptDailyCloseChannelStaff,
    'samples' => l10n.rptDailyCloseChannelSamples,
    'partner' => l10n.rptDailyCloseChannelPartner,
    '' => l10n.commonNotSpecified,
    _ => channel,
  };
}

Color _channelColor(String channel) {
  return switch (channel.trim().toLowerCase()) {
    'pos' => const Color(0xFF1E88E5),
    'woo' => const Color(0xFF8E24AA),
    'talabat' => const Color(0xFFFF6D00),
    'b2b' => const Color(0xFF00897B),
    'staff' => const Color(0xFF6D4C41),
    'samples' => const Color(0xFFD81B60),
    'partner' => const Color(0xFF3949AB),
    _ => const Color(0xFF757575),
  };
}

// ═════════════════════════════════════════════════════════════════════════
// Daily close
// ═════════════════════════════════════════════════════════════════════════

/// Set once per app session: the first time the daily close opens, a range
/// still on the reports default (this month) is switched to Today. After
/// that, whatever the user picks is left alone.
bool _dailyCloseDefaultApplied = false;

/// Daily close: sales by branch, channel, payment method and hour for the
/// shared range (`ops_reports.get_daily_close`). Opens on Today.
class DailyCloseScreen extends ConsumerStatefulWidget {
  const DailyCloseScreen({super.key});

  @override
  ConsumerState<DailyCloseScreen> createState() => _DailyCloseScreenState();
}

class _DailyCloseScreenState extends ConsumerState<DailyCloseScreen> {
  bool _awaitingDefault = false;

  @override
  void initState() {
    super.initState();
    if (!_dailyCloseDefaultApplied) {
      _dailyCloseDefaultApplied = true;
      if (ref.read(reportRangeProvider) == ReportRange.thisMonth()) {
        // Switch after the first frame (providers cannot change mid-build);
        // until then nothing is fetched, so the month is never loaded.
        _awaitingDefault = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(reportRangeProvider.notifier).state = ReportRange.today();
          setState(() => _awaitingDefault = false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final q = ref.watch(reportQueryProvider);
    final AsyncValue<DailyClose> async = _awaitingDefault
        ? const AsyncValue<DailyClose>.loading()
        : ref.watch(dailyCloseProvider(q));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rptDailyCloseTitle),
        actions: [
          ReportExportButton(
            title: l10n.rptDailyCloseTitle,
            rows: () => _csvRows(context, async.valueOrNull),
          ),
        ],
      ),
      body: OpsReportView<DailyClose>(
        async: async,
        onRefresh: () => ref.refresh(dailyCloseProvider(q).future),
        onRetry: () => ref.invalidate(dailyCloseProvider(q)),
        header: const [_DayNavigator()],
        isEmpty: (d) => d.isEmpty && d.totals.returns == 0,
        builder: (context, d) => _body(context, d),
      ),
    );
  }

  List<Widget> _body(BuildContext context, DailyClose d) {
    final scope = opsScopeNote(context, d.filters);
    return [
      if (scope != null) scope,
      _DailyCloseKpis(data: d),
      OpsTwoUp(
        first: _ChannelsCard(channels: d.channels),
        second: _ByHourCard(hours: d.byHour),
      ),
      OpsTwoUp(
        first: _PaymentsCard(payments: d.payments),
        second: _BranchesCard(branches: d.branches),
      ),
    ];
  }

  List<List<String>> _csvRows(BuildContext context, DailyClose? d) {
    if (d == null) return const [];
    final l10n = context.l10n;
    final rows = <List<String>>[
      [
        l10n.rptDailyCloseBranch,
        l10n.rptDailyCloseChannel,
        l10n.rptDailyCloseMode,
        l10n.rptDailyCloseOrders,
        l10n.rptDailyCloseAmount,
      ],
    ];
    for (final c in d.channels) {
      rows.add([
        l10n.rptAllBranches,
        opsChannelLabel(context, c.channel),
        '',
        opsCsvNum(c.orders),
        opsCsvNum(c.netSales),
      ]);
    }
    for (final p in d.payments) {
      rows.add([
        l10n.rptAllBranches,
        '',
        localizedPaymentMethodLabel(context, p.mode),
        '',
        opsCsvNum(p.amount),
      ]);
    }
    for (final b in d.branches) {
      rows.add([b.branch, '', '', opsCsvNum(b.orders), opsCsvNum(b.netSales)]);
      for (final c in b.channels) {
        rows.add([
          b.branch,
          opsChannelLabel(context, c.channel),
          '',
          opsCsvNum(c.orders),
          opsCsvNum(c.netSales),
        ]);
      }
      for (final p in b.payments) {
        rows.add([
          b.branch,
          '',
          localizedPaymentMethodLabel(context, p.mode),
          '',
          opsCsvNum(p.amount),
        ]);
      }
    }
    return rows;
  }
}

// ── Day navigator (Today / Yesterday, previous / next) ────────────────────

class _DayNavigator extends ConsumerWidget {
  const _DayNavigator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final range = ref.watch(reportRangeProvider);
    final today = ReportRange.today();
    final preset = range.matchingPreset();
    final n = range.dayCount;
    final canGoNext = range.to.isBefore(today.to);

    void set(ReportRange r) =>
        ref.read(reportRangeProvider.notifier).state = r;

    void shift(int dir) {
      var from = DateTime(range.from.year, range.from.month, range.from.day + dir * n);
      var to = DateTime(range.to.year, range.to.month, range.to.day + dir * n);
      if (to.isAfter(today.to)) {
        to = today.to;
        from = DateTime(to.year, to.month, to.day - (n - 1));
      }
      set(ReportRange(from: from, to: to));
    }

    final label = n == 1
        ? formatDate(context, range.from, pattern: 'EEEE, d MMMM yyyy')
        : '${formatDate(context, range.from)} – ${formatDate(context, range.to)}';

    return Card(
      margin: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 4),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            IconButton(
              tooltip: l10n.rptDailyClosePrevDay,
              icon: const Icon(Icons.chevron_left),
              onPressed: () => shift(-1),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.rptRangeToday),
                        selected: preset == ReportRangePreset.today,
                        onSelected: (_) => set(ReportRange.today()),
                      ),
                      ChoiceChip(
                        label: Text(l10n.rptRangeYesterday),
                        selected: preset == ReportRangePreset.yesterday,
                        onSelected: (_) => set(ReportRange.yesterday()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.rptDailyCloseNextDay,
              icon: const Icon(Icons.chevron_right),
              onPressed: canGoNext ? () => shift(1) : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── KPIs ──────────────────────────────────────────────────────────────────

class _DailyCloseKpis extends StatelessWidget {
  final DailyClose data;

  const _DailyCloseKpis({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final t = data.totals;
    final tiles = <Widget>[
      KpiCard(
        label: l10n.rptDailyCloseNetSales,
        value: formatCurrency(context, t.netSales),
        icon: Icons.payments_outlined,
      ),
      KpiCard(
        label: l10n.rptDailyCloseOrders,
        value: formatCount(context, t.orders),
        icon: Icons.receipt_long_outlined,
      ),
      KpiCard(
        label: l10n.rptDailyCloseAvgOrder,
        value: formatCurrency(context, t.avgOrderValue),
        icon: Icons.shopping_basket_outlined,
      ),
      KpiCard(
        label: l10n.rptDailyCloseShipping,
        value: formatCurrency(context, t.shippingIncome),
        icon: Icons.local_shipping_outlined,
      ),
      if (t.grossSales != 0 && (t.grossSales - t.netSales).abs() > 0.004)
        KpiCard(
          label: l10n.rptDailyCloseGrossSales,
          value: formatCurrency(context, t.grossSales),
          icon: Icons.stacked_line_chart,
        ),
      if (t.grandTotal != 0)
        KpiCard(
          label: l10n.rptDailyCloseGrandTotal,
          value: formatCurrency(context, t.grandTotal),
          icon: Icons.summarize_outlined,
        ),
      KpiCard(
        label: l10n.rptDailyCloseReturns,
        value: formatCurrency(context, t.returns),
        icon: Icons.assignment_return_outlined,
        color: t.returns != 0 ? theme.colorScheme.error : null,
        delta: t.returnsCount > 0 ? l10n.rptDailyCloseReturnsCount(t.returnsCount) : null,
        deltaColor: theme.colorScheme.error,
      ),
      KpiCard(
        label: l10n.rptDailyCloseCancelled,
        value: formatCount(context, t.cancelled),
        icon: Icons.cancel_outlined,
        color: t.cancelled > 0 ? Colors.orange.shade800 : null,
      ),
      if (t.outstanding > 0.004)
        KpiCard(
          label: l10n.rptDailyCloseOutstanding,
          value: formatCurrency(context, t.outstanding),
          icon: Icons.hourglass_bottom,
          color: Colors.orange.shade800,
          delta: l10n.rptDailyCloseOutstandingHint,
          deltaColor: Colors.orange.shade800,
        ),
    ];
    return OpsKpiGrid(tiles: tiles);
  }
}

// ── Channel donut ─────────────────────────────────────────────────────────

class _ChannelsCard extends StatelessWidget {
  final List<ChannelSales> channels;

  const _ChannelsCard({required this.channels});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final positive = channels.where((c) => c.netSales > 0).toList();
    final total = positive.fold<double>(0, (s, c) => s + c.netSales);
    final shown = channels.where((c) => c.orders != 0 || c.netSales != 0).toList();
    final pctFmt = NumberFormat.decimalPercentPattern(
      locale: l10n.localeName,
      decimalDigits: 0,
    );

    final legend = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final c in shown)
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _channelColor(c.channel),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opsChannelLabel(context, c.channel),
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        l10n.rptDailyCloseOrdersCount(c.orders),
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
                      formatCurrency(context, c.netSales),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (c.netSales > 0 && total > 0)
                      Text(
                        pctFmt.format(c.netSales / total),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );

    Widget chart() => SizedBox(
          height: 180,
          width: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    for (final c in positive)
                      PieChartSectionData(
                        value: c.netSales,
                        color: _channelColor(c.channel),
                        radius: 34,
                        title: c.netSales / total >= 0.08
                            ? pctFmt.format(c.netSales / total)
                            : '',
                        titleStyle: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.all(8),
                child: Text(
                  formatCompactCurrency(context, total),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );

    return ReportSectionCard(
      title: l10n.rptDailyCloseChannels,
      child: shown.isEmpty
          ? Text(l10n.reportNoData, style: theme.textTheme.bodySmall)
          : LayoutBuilder(
              builder: (context, constraints) {
                final hasChart = positive.isNotEmpty && total > 0;
                if (!hasChart) return legend;
                if (constraints.maxWidth >= 440) {
                  return Row(
                    children: [
                      chart(),
                      const SizedBox(width: 16),
                      Expanded(child: legend),
                    ],
                  );
                }
                return Column(
                  children: [Center(child: chart()), const SizedBox(height: 8), legend],
                );
              },
            ),
    );
  }
}

// ── Sales by hour ─────────────────────────────────────────────────────────

class _ByHourCard extends StatelessWidget {
  final List<HourlySales> hours;

  const _ByHourCard({required this.hours});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = l10n.localeName;
    final byHour = <int, HourlySales>{
      for (final h in hours)
        if (h.hour >= 0 && h.hour <= 23) h.hour: h,
    };
    final active = byHour.values.where((h) => h.orders != 0 || h.netSales != 0);
    if (active.isEmpty) {
      return ReportSectionCard(
        title: l10n.rptDailyCloseByHour,
        child: Text(l10n.reportNoData, style: theme.textTheme.bodySmall),
      );
    }
    // Show the trading window only (first to last hour with sales).
    final first = active.map((h) => h.hour).reduce((a, b) => a < b ? a : b);
    final last = active.map((h) => h.hour).reduce((a, b) => a > b ? a : b);
    final span = [for (var h = first; h <= last; h++) h];
    double maxY = 0;
    for (final h in span) {
      final v = byHour[h]?.netSales ?? 0;
      if (v > maxY) maxY = v;
    }
    if (maxY <= 0) maxY = 1;
    final step = span.length <= 8 ? 1 : (span.length <= 14 ? 2 : 3);
    final hourFmt = DateFormat.j(locale);
    String hourLabel(int h) => hourFmt.format(DateTime(2000, 1, 1, h));
    final compact = NumberFormat.compact(locale: locale);

    return ReportSectionCard(
      title: l10n.rptDailyCloseByHour,
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY * 1.15,
            minY: 0,
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final h = byHour[group.x];
                  return BarTooltipItem(
                    '${hourLabel(group.x)}\n'
                    '${formatCurrency(context, h?.netSales ?? 0)}\n'
                    '${l10n.rptDailyCloseOrdersCount(h?.orders ?? 0)}',
                    theme.textTheme.labelSmall!.copyWith(
                      color: theme.colorScheme.onInverseSurface,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    if (value == meta.max) return const SizedBox.shrink();
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        compact.format(value),
                        style: theme.textTheme.labelSmall,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  getTitlesWidget: (value, meta) {
                    final h = value.toInt();
                    if ((h - first) % step != 0) return const SizedBox.shrink();
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4,
                      child: Text(hourLabel(h), style: theme.textTheme.labelSmall),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (final h in span)
                BarChartGroupData(
                  x: h,
                  barRods: [
                    BarChartRodData(
                      toY: (byHour[h]?.netSales ?? 0).clamp(0, double.infinity).toDouble(),
                      color: theme.colorScheme.primary,
                      width: span.length > 14 ? 8 : 14,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Payments ──────────────────────────────────────────────────────────────

class _PaymentsCard extends StatelessWidget {
  final List<PaymentModeAmount> payments;

  const _PaymentsCard({required this.payments});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sorted = [...payments]..sort((a, b) => b.amount.compareTo(a.amount));
    final total = sorted.fold<double>(0, (s, p) => s + p.amount);
    return ReportSectionCard(
      title: l10n.rptDailyClosePayments,
      subtitle: total != 0 ? formatCurrency(context, total) : null,
      child: ReportTable(
        columns: [
          ReportColumn(l10n.rptDailyCloseMode, flex: 3),
          ReportColumn(l10n.rptDailyCloseAmount, numeric: true, flex: 3),
          ReportColumn(l10n.rptDailyCloseShare, numeric: true, flex: 2),
        ],
        rows: [
          for (final p in sorted)
            [
              localizedPaymentMethodLabel(context, p.mode),
              formatCurrency(context, p.amount),
              opsPercent(context, p.amount, total),
            ],
        ],
      ),
    );
  }
}

// ── Branches ──────────────────────────────────────────────────────────────

class _BranchesCard extends StatelessWidget {
  final List<DailyCloseBranch> branches;

  const _BranchesCard({required this.branches});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sorted = [...branches]..sort((a, b) => b.netSales.compareTo(a.netSales));
    return ReportSectionCard(
      title: l10n.rptDailyCloseBranches,
      subtitle: sorted.isEmpty ? null : l10n.rptDailyCloseBranchesHint,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 480;
          return ReportTable(
            columns: [
              ReportColumn(l10n.rptDailyCloseBranch, flex: 3),
              ReportColumn(l10n.rptDailyCloseOrders, numeric: true, flex: 2),
              ReportColumn(l10n.rptDailyCloseNetSales, numeric: true, flex: 3),
              if (wide) ReportColumn(l10n.rptDailyCloseShipping, numeric: true, flex: 3),
              if (wide) ReportColumn(l10n.rptDailyCloseCancelled, numeric: true, flex: 2),
            ],
            rows: [
              for (final b in sorted)
                [
                  b.branch,
                  formatCount(context, b.orders),
                  formatCurrency(context, b.netSales),
                  if (wide) formatCurrency(context, b.shippingIncome),
                  if (wide) formatCount(context, b.cancelled),
                ],
            ],
            onRowTap: (i) => _openBranch(context, sorted[i]),
          );
        },
      ),
    );
  }

  void _openBranch(BuildContext context, DailyCloseBranch b) {
    final l10n = context.l10n;
    final payments = [...b.payments]..sort((x, y) => y.amount.compareTo(x.amount));
    final payTotal = payments.fold<double>(0, (s, p) => s + p.amount);
    final channels = b.channels.where((c) => c.orders != 0 || c.netSales != 0).toList();
    showOpsDetailSheet(
      context,
      title: b.branch,
      children: [
        OpsKeyValue(label: l10n.rptDailyCloseNetSales, value: formatCurrency(context, b.netSales), bold: true),
        OpsKeyValue(label: l10n.rptDailyCloseOrders, value: formatCount(context, b.orders)),
        OpsKeyValue(label: l10n.rptDailyCloseShipping, value: formatCurrency(context, b.shippingIncome)),
        OpsKeyValue(label: l10n.rptDailyCloseCancelled, value: formatCount(context, b.cancelled)),
        const Divider(height: 24),
        Text(l10n.rptDailyCloseChannels, style: Theme.of(context).textTheme.titleSmall),
        ReportTable(
          columns: [
            ReportColumn(l10n.rptDailyCloseChannel, flex: 3),
            ReportColumn(l10n.rptDailyCloseOrders, numeric: true, flex: 2),
            ReportColumn(l10n.rptDailyCloseNetSales, numeric: true, flex: 3),
          ],
          rows: [
            for (final c in channels)
              [
                opsChannelLabel(context, c.channel),
                formatCount(context, c.orders),
                formatCurrency(context, c.netSales),
              ],
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.rptDailyClosePayments, style: Theme.of(context).textTheme.titleSmall),
        ReportTable(
          columns: [
            ReportColumn(l10n.rptDailyCloseMode, flex: 3),
            ReportColumn(l10n.rptDailyCloseAmount, numeric: true, flex: 3),
            ReportColumn(l10n.rptDailyCloseShare, numeric: true, flex: 2),
          ],
          rows: [
            for (final p in payments)
              [
                localizedPaymentMethodLabel(context, p.mode),
                formatCurrency(context, p.amount),
                opsPercent(context, p.amount, payTotal),
              ],
          ],
        ),
      ],
    );
  }
}
