import 'dart:math' as math;

import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../../core/network/user_service.dart';
import '../../../core/widgets/app_drawer.dart';
import '../models/roster_models.dart';
import '../state/roster_filter.dart';
import '../state/roster_providers.dart';
import 'roster_cell_style.dart';
import 'roster_formats.dart';
import 'roster_grid_metrics.dart';
import 'roster_plan_wizard.dart';
import 'widgets/roster_bulk_bar.dart';
import 'widgets/roster_filter_sheet.dart';
import 'widgets/roster_day_off_form.dart' show rosterOffTypeLabel;
import 'widgets/roster_day_sheet.dart';
import 'widgets/roster_hours_sheet.dart';
import 'widgets/roster_legend.dart';

/// Stable keys for the screen's controls, so the tests can drive them.
const Key rosterSelectDaysKey = ValueKey<String>('roster-select-days');
const Key rosterLegendButtonKey = ValueKey<String>('roster-legend-button');
const Key rosterUncoveredBannerKey = ValueKey<String>(
  'roster-uncovered-banner',
);
const Key rosterPreviousKey = ValueKey<String>('roster-previous');
const Key rosterNextKey = ValueKey<String>('roster-next');
const Key rosterPeriodTitleKey = ValueKey<String>('roster-period-title');
const Key rosterPlanActionKey = ValueKey<String>('roster-plan-action');

Key rosterGapTileKey(String employee, String date) =>
    ValueKey<String>('roster-gap-$employee-$date');

/// Shift distribution: one week (default) or one month of the rota.
///
/// People down the side, days across the top — the shape a rota is actually
/// read in. The employee column is pinned while the days scroll horizontally,
/// because the one thing a manager must never lose track of while scanning
/// across the days is whose row they are on.
///
/// The backend serves a whole month at a time; week mode draws a full
/// Saturday-to-Friday week (see [rosterWeekDates]) and loads both months when
/// the week straddles a month end, so stepping weeks inside already-loaded
/// months costs no request. The people/branch filter is applied on the
/// client ([rosterVisibleMonthProvider]).
///
/// Every colour on this screen comes from [RosterStyleResolver]; nothing here
/// picks its own. Colour means "needs fixing" and nothing else — see
/// `roster_cell_style.dart`.
///
/// Note this is unrelated to the Shift Monitor screen. "Shift" means a POS cash
/// drawer there and a working pattern here; the two features share a word and
/// nothing else.
class RosterScreen extends ConsumerWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final canManage = ref.watch(canActAsLineManagerProvider);
    // Restores the saved people/branch filter once the user is known.
    ref.watch(rosterFilterRestoreProvider);
    final monthAsync = ref.watch(rosterVisibleMonthProvider);
    final selection = ref.watch(rosterSelectionProvider);
    final selectMode = ref.watch(rosterSelectModeProvider);

    // A selection names dates in a SPECIFIC month and row set; switching the
    // month, the week, the view or the filter must not leave it pointing at
    // days the manager can no longer see, where a bulk action would look like
    // it targets nothing.
    void clearSelection() =>
        ref.read(rosterSelectionProvider.notifier).state = null;
    ref.listen(rosterMonthProvider, (previous, next) {
      if (previous != next) clearSelection();
    });
    ref.listen(rosterEffectiveFilterProvider, (previous, next) {
      if (previous != next) clearSelection();
    });
    ref.listen(rosterViewModeProvider, (previous, next) {
      if (previous != next) clearSelection();
    });
    ref.listen(rosterWeekFocusProvider, (previous, next) {
      if (previous != next) clearSelection();
    });

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: l10n.managerMenuTooltip,
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(l10n.rosterTitle),
        actions: [
          if (canManage)
            IconButton(
              key: rosterPlanActionKey,
              tooltip: l10n.rosterPlanAction,
              icon: const Icon(Icons.edit_calendar_outlined),
              onPressed: () => showRosterPlanWizard(context),
            ),
          if (canManage)
            IconButton(
              key: rosterLegendButtonKey,
              tooltip: l10n.rosterLegendButton,
              icon: const Icon(Icons.info_outline),
              onPressed: () => showRosterLegendSheet(context),
            ),
          if (canManage)
            IconButton(
              tooltip: l10n.rosterHoursTitle,
              icon: const Icon(Icons.summarize_outlined),
              onPressed: () => showRosterHoursSheet(context),
            ),
          IconButton(
            tooltip: l10n.commonRetry,
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(rosterBootstrapProvider);
              ref.invalidate(rosterMonthDataProvider);
              ref.invalidate(rosterHoursProvider);
            },
          ),
        ],
      ),
      body: !canManage
          ? _AccessDenied(message: l10n.rosterAccessDenied)
          : Column(
              children: [
                const _RosterControlBar(),
                Expanded(
                  child: monthAsync.when(
                    data: (month) => _RosterBody(month: month),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => _ErrorState(error: error),
                  ),
                ),
                if (selection != null)
                  RosterBulkBar(selection: selection)
                else if (selectMode)
                  const _SelectModeHint(),
              ],
            ),
    );
  }
}

/// Shown in select mode until the first day is picked: what a tap does now,
/// and the way back out.
class _SelectModeHint extends ConsumerWidget {
  const _SelectModeHint();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      color: theme.colorScheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 4, 6),
          child: Row(
            children: [
              const Icon(Icons.touch_app_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.rosterBulkSelectHint,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(rosterSelectionProvider.notifier).state = null;
                  ref.read(rosterSelectModeProvider.notifier).state = false;
                },
                child: Text(context.l10n.commonCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RosterControlBar extends ConsumerWidget {
  const _RosterControlBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final month = ref.watch(rosterMonthProvider);
    final mode = ref.watch(rosterViewModeProvider);
    final focus = ref.watch(rosterWeekFocusProvider);
    final selectMode = ref.watch(rosterSelectModeProvider);
    final theme = Theme.of(context);
    final isWeek = mode == RosterViewMode.week;

    final title = isWeek
        ? _weekLabel(
            context,
            rosterWeekDates(month: month, focus: focus, today: DateTime.now()),
          )
        : _monthLabel(context, month);

    void switchMode(RosterViewMode next) {
      if (next == mode) return;
      if (next == RosterViewMode.week) {
        // Month -> week: today's week when this month holds today, else the
        // week of the 1st (the null focus default).
        ref.read(rosterWeekFocusProvider.notifier).state = null;
      } else {
        // Week -> month: the month holding most of the week. The arrows keep
        // rosterMonthProvider on it already; this covers a stale value.
        final week = rosterWeekDates(
          month: month,
          focus: focus,
          today: DateTime.now(),
        );
        if (!week.any((d) => d.startsWith('$month-'))) {
          ref.read(rosterMonthProvider.notifier).state = rosterWeekMonth(week);
        }
      }
      ref.read(rosterViewModeProvider.notifier).state = next;
    }

    void step(int delta) {
      if (isWeek) {
        final next = rosterStepWeek(
          month: month,
          focus: focus,
          delta: delta,
          today: DateTime.now(),
        );
        ref.read(rosterMonthProvider.notifier).state = next.month;
        ref.read(rosterWeekFocusProvider.notifier).state = next.focus;
      } else {
        ref.read(rosterMonthProvider.notifier).state = shiftMonth(month, delta);
      }
    }

    return Material(
      // Chrome, not a state: the control bar, the headers and the name column
      // all sit on one neutral, and no cell state uses that neutral. Solid
      // rather than a 0.4 alpha wash so the text on it keeps its contrast.
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  key: rosterPreviousKey,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: isWeek
                      ? l10n.rosterPreviousWeek
                      : l10n.rosterPreviousMonth,
                  onPressed: () => step(-1),
                ),
                Expanded(
                  child: Text(
                    title,
                    key: rosterPeriodTitleKey,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  key: rosterNextKey,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: isWeek ? l10n.rosterNextWeek : l10n.rosterNextMonth,
                  onPressed: () => step(1),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SegmentedButton<RosterViewMode>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  segments: [
                    ButtonSegment(
                      value: RosterViewMode.week,
                      label: Text(l10n.rosterViewWeek),
                    ),
                    ButtonSegment(
                      value: RosterViewMode.month,
                      label: Text(l10n.rosterViewMonth),
                    ),
                  ],
                  selected: {mode},
                  onSelectionChanged: (value) => switchMode(value.first),
                ),
                FilterChip(
                  key: rosterSelectDaysKey,
                  label: Text(l10n.rosterSelectDays),
                  avatar: selectMode
                      ? null
                      : const Icon(Icons.checklist_rtl, size: 18),
                  selected: selectMode,
                  visualDensity: VisualDensity.compact,
                  onSelected: (on) {
                    ref.read(rosterSelectModeProvider.notifier).state = on;
                    if (!on) {
                      ref.read(rosterSelectionProvider.notifier).state = null;
                    }
                  },
                ),
                const RosterFilterButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// "September 2026" / "سبتمبر ٢٠٢٦".
  ///
  /// Formatted through the app's locale-aware helper rather than an ICU
  /// placeholder so the month name is translated, not just the digits.
  static String _monthLabel(BuildContext context, String month) {
    final parts = month.split('-');
    if (parts.length < 2) return month;
    final year = int.tryParse(parts[0]);
    final monthNumber = int.tryParse(parts[1]);
    if (year == null || monthNumber == null) return month;
    return formatDate(
      context,
      DateTime(year, monthNumber, 1),
      pattern: 'MMMM yyyy',
    );
  }

  /// "3–9 Oct 2026", "26 Sep – 2 Oct 2026", "27 Dec 2026 – 2 Jan 2027": the
  /// shared month and year are written once, after the range.
  static String _weekLabel(BuildContext context, List<String> week) {
    if (week.isEmpty) return '';
    final start = DateTime.tryParse(week.first);
    final end = DateTime.tryParse(week.last);
    if (start == null || end == null) return week.first;
    final tail = formatDate(context, end, pattern: 'd MMM yyyy');
    if (week.length == 1) return tail;
    if (start.year != end.year) {
      return '${formatDate(context, start, pattern: 'd MMM yyyy')} – $tail';
    }
    if (start.month != end.month) {
      return '${formatDate(context, start, pattern: 'd MMM')} – $tail';
    }
    return '${formatDate(context, start, pattern: 'd')}–$tail';
  }
}

/// The days the grid draws: all seven days of the visible week in week mode
/// (whatever month each falls in), else the month's days.
///
/// [period] is [rosterMonthProvider]'s `YYYY-MM`; in week mode the week comes
/// from it and [focus] (see [rosterWeekDates]), not from the payload, so a
/// week straddling a month end is never cut short.
List<String> rosterVisibleDates({
  required RosterMonth month,
  required String period,
  required RosterViewMode mode,
  required String? focus,
  required DateTime today,
}) {
  if (mode != RosterViewMode.week) return month.dates;
  return rosterWeekDates(month: period, focus: focus, today: today);
}

class _RosterBody extends ConsumerWidget {
  const _RosterBody({required this.month});

  final RosterMonth month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mode = ref.watch(rosterViewModeProvider);
    final focus = ref.watch(rosterWeekFocusProvider);
    final period = ref.watch(rosterMonthProvider);
    final filter = ref.watch(rosterEffectiveFilterProvider);

    if (!month.hrmsAvailable) {
      return _EmptyState(
        icon: Icons.info_outline,
        message: month.notice ?? l10n.rosterHrmsMissing,
      );
    }
    if (month.employees.isEmpty && !filter.isEmpty) {
      return _EmptyState(
        icon: Icons.filter_alt_off_outlined,
        message: l10n.rosterFilterNoMatch,
      );
    }
    if (month.employees.isEmpty) {
      return _EmptyState(
        icon: Icons.event_busy_outlined,
        message: month.scope.configured || month.scope.unrestricted
            ? l10n.rosterNobodyRostered
            : l10n.rosterScopeUnconfigured,
      );
    }

    // Built once per payload and handed down, because a cover day is recorded
    // on the *other* person's cell.
    final coverIndex = RosterCoverIndex.fromMonth(month);
    final dates = rosterVisibleDates(
      month: month,
      period: period,
      mode: mode,
      focus: focus,
      today: DateTime.now(),
    );

    return Column(
      children: [
        if (month.gaps.isNotEmpty)
          _UncoveredBanner(
            gaps: month.gaps,
            onFix: () => _openGaps(context, ref, coverIndex),
          ),
        Expanded(
          child: RosterGrid(
            month: month,
            coverIndex: coverIndex,
            dates: dates,
            stretchToWidth: mode == RosterViewMode.week,
            showShiftEnd: mode == RosterViewMode.week,
            totalsFilter: filter,
          ),
        ),
      ],
    );
  }

  /// The banner's "Fix": list every gap, and jump to the one picked.
  Future<void> _openGaps(
    BuildContext context,
    WidgetRef ref,
    RosterCoverIndex coverIndex,
  ) async {
    final picked = await showModalBottomSheet<RosterGap>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _GapListSheet(month: month),
    );
    if (picked == null || !context.mounted) return;

    final employee = month.employees
        .where((e) => e.employee == picked.employee)
        .firstOrNull;
    // Gaps are filtered with the rows, so this is a safety net only.
    if (employee == null) return;

    if (ref.read(rosterViewModeProvider) == RosterViewMode.week) {
      rosterFocusWeekOn(ref, picked.date);
    }
    await showRosterDaySheet(
      context,
      employee: employee,
      date: picked.date,
      cell: employee.cellFor(picked.date),
      catalog: month.shiftCatalog,
      coveringFor: coverIndex.coveredColleague(employee.employee, picked.date),
    );
  }
}

/// Every uncovered day off, one row each; tapping one resolves the sheet to it.
class _GapListSheet extends StatelessWidget {
  const _GapListSheet({required this.month});

  final RosterMonth month;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final names = {for (final e in month.employees) e.employee: e.employeeName};
    final gaps = [...month.gaps]..sort((a, b) => a.date.compareTo(b.date));

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              l10n.rosterUncoveredListTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: gaps.length,
              itemBuilder: (context, index) {
                final gap = gaps[index];
                final parsed = DateTime.tryParse(gap.date);
                final offType = (gap.offType ?? '').trim();
                return ListTile(
                  key: rosterGapTileKey(gap.employee, gap.date),
                  leading: const Icon(
                    Icons.warning_amber_rounded,
                    color: RosterColors.riskLine,
                  ),
                  title: Text(names[gap.employee] ?? gap.employee),
                  subtitle: Text(
                    [
                      parsed == null
                          ? gap.date
                          : formatDate(context, parsed, pattern: 'EEE d MMM'),
                      if (offType.isNotEmpty) rosterOffTypeLabel(l10n, offType),
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pop(gap),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Days off that nobody was named to cover.
///
/// Surfaced at the top rather than left to be spotted in the grid, because this
/// is the mistake the screen exists to prevent: a branch whose second shift was
/// removed and never handed to anyone reads as a perfectly normal calendar
/// right up until the morning it opens short-staffed. Tapping it lists the
/// gaps and jumps to the one picked, so the warning leads straight to the fix.
///
/// Drawn in the same amber as the cells it is counting. It used to be
/// `errorContainer`, i.e. the same red as an unrostered day and a destructive
/// button — so the banner's colour pointed at nothing in particular.
class _UncoveredBanner extends StatelessWidget {
  const _UncoveredBanner({required this.gaps, required this.onFix});

  final List<RosterGap> gaps;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: RosterColors.riskFill,
      child: InkWell(
        key: rosterUncoveredBannerKey,
        onTap: onFix,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: RosterColors.riskLine, width: 2),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: RosterColors.riskInk,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.rosterUncoveredWarning(gaps.length),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: RosterColors.riskInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                context.l10n.rosterUncoveredFix,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: RosterColors.riskInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: RosterColors.riskInk,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stable keys for the grid's name, header, totals and day cells, so a test
/// can measure where each one actually landed. See
/// `test/features/roster/roster_grid_alignment_test.dart`.
Key rosterGridNameKey(String employee) =>
    ValueKey<String>('roster-grid-name-$employee');

Key rosterGridHeaderKey(String date) =>
    ValueKey<String>('roster-grid-header-$date');

Key rosterGridTotalsKey(String date) =>
    ValueKey<String>('roster-grid-totals-$date');

Key rosterGridCellKey(String employee, String date) =>
    ValueKey<String>('roster-grid-cell-$employee-$date');

/// The grid itself: a pinned employee column beside horizontally scrolling days.
///
/// One outer vertical scroll wraps both halves so they cannot drift out of
/// alignment — synchronising two separate vertical controllers is the usual way
/// this kind of table ends up one row out.
///
/// Public only so the grid tests can pump it on their own; the screen is the
/// sole production caller. Every size comes from [RosterGridMetrics].
class RosterGrid extends ConsumerWidget {
  const RosterGrid({
    super.key,
    required this.month,
    required this.coverIndex,
    this.dates,
    this.stretchToWidth = false,
    this.showShiftEnd = false,
    this.totalsFilter = RosterFilter.empty,
  });

  final RosterMonth month;
  final RosterCoverIndex coverIndex;

  /// The people/branch filter the rows were picked with; it also narrows the
  /// on-duty row. See [dayTotals].
  final RosterFilter totalsFilter;

  /// The days to draw; the whole month when null.
  final List<String>? dates;

  /// Widen the day columns to fill the screen (week view), never narrowing
  /// them below [RosterGridMetrics.cellWidth].
  final bool stretchToWidth;

  /// Write a working day's start AND end time (`9a–6p`, the week view) rather
  /// than its start alone (`9a`, the month view's narrow columns).
  final bool showShiftEnd;

  /// The one day-column width for headers, totals and cells alike.
  ///
  /// Computed ONCE and passed to all three strips: they line up only because
  /// they share a width (see [RosterGridMetrics]), so a stretched week must
  /// stretch every strip by exactly the same amount. Floored to a whole pixel
  /// so no strip can round differently from another.
  static double columnWidth({
    required double availableWidth,
    required int dayCount,
    required bool stretch,
  }) {
    if (!stretch || dayCount <= 0 || !availableWidth.isFinite) {
      return RosterGridMetrics.cellWidth;
    }
    final share = ((availableWidth - RosterGridMetrics.nameWidth) / dayCount)
        .floorToDouble();
    return math.max(RosterGridMetrics.cellWidth, share);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dates = this.dates ?? month.dates;
    final theme = Theme.of(context);
    final locations = totalsFilter.locations;
    final branch = locations.length == 1 ? locations.first : null;
    final shifts = RosterShiftCatalog(month.shiftCatalog);
    final resolver = RosterStyleResolver.of(context, catalog: shifts);
    final totals = dayTotals(month, dates, resolver, filter: totalsFilter);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = columnWidth(
          availableWidth: constraints.maxWidth,
          dayCount: dates.length,
          stretch: stretchToWidth,
        );
        return SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pinned: who.
              Column(
                children: [
                  _ChromeCell(
                    width: RosterGridMetrics.nameWidth,
                    height: RosterGridMetrics.headerHeight,
                    child: Text(
                      context.l10n.rosterEmployeeColumn,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                  _ChromeCell(
                    width: RosterGridMetrics.nameWidth,
                    height: RosterGridMetrics.totalsHeight,
                    child: Text(
                      branch == null
                          ? context.l10n.rosterOnDutyRow
                          : context.l10n.rosterOnDutyRowBranch(branch),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ...month.employees.map(
                    (employee) => _EmployeeNameCell(
                      key: rosterGridNameKey(employee.employee),
                      employee: employee,
                      width: RosterGridMetrics.nameWidth,
                      height: RosterGridMetrics.rowHeight,
                    ),
                  ),
                ],
              ),
              // Scrolling: when.
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      Row(
                        children: dates
                            .map(
                              (date) => _DayHeaderCell(
                                key: rosterGridHeaderKey(date),
                                date: date,
                                width: cellWidth,
                                height: RosterGridMetrics.headerHeight,
                              ),
                            )
                            .toList(),
                      ),
                      Row(
                        children: dates
                            .map(
                              (date) => _DayTotalsCell(
                                key: rosterGridTotalsKey(date),
                                date: date,
                                totals:
                                    totals[date] ??
                                    const RosterDayTotals(onDuty: 0, atRisk: 0),
                                width: cellWidth,
                                height: RosterGridMetrics.totalsHeight,
                              ),
                            )
                            .toList(),
                      ),
                      ...month.employees.map(
                        (employee) => Row(
                          children: dates
                              .map(
                                (date) => _DayCell(
                                  key: rosterGridCellKey(
                                    employee.employee,
                                    date,
                                  ),
                                  employee: employee,
                                  date: date,
                                  cell: employee.cellFor(date),
                                  catalog: month.shiftCatalog,
                                  shifts: shifts,
                                  showShiftEnd: showShiftEnd,
                                  coveringFor: coverIndex.coveredColleague(
                                    employee.employee,
                                    date,
                                  ),
                                  width: cellWidth,
                                  height: RosterGridMetrics.rowHeight,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Headcount and at-risk count per visible day.
  ///
  /// Resolved through the same [RosterStyleResolver] the cells use, so the
  /// number in the totals row can never count a day differently from the way
  /// the column below it is drawn.
  /// On duty / at risk per day, over the rows drawn.
  ///
  /// With branches in [filter], a day only counts for a row picked through a
  /// branch when that day is AT one of those branches (the cell's location,
  /// else where the person's unrostered days land). Someone who belongs to
  /// Dokki but covers at the Factory on Tuesday is not "on duty at Dokki" that
  /// Tuesday. People picked by name always count. A day whose branch cannot be
  /// told counts, rather than silently vanishing.
  @visibleForTesting
  static Map<String, RosterDayTotals> dayTotals(
    RosterMonth month,
    List<String> dates,
    RosterStyleResolver resolver, {
    RosterFilter filter = RosterFilter.empty,
  }) {
    final locations = filter.locations;
    final totals = <String, RosterDayTotals>{};
    for (final date in dates) {
      var duty = 0;
      var risk = 0;
      for (final employee in month.employees) {
        final cell = employee.cellFor(date);
        if (locations.isNotEmpty &&
            !filter.employees.contains(employee.employee)) {
          final at = (cell?.shiftLocation ?? employee.fallbackLocation).trim();
          if (at.isNotEmpty && !locations.contains(at)) continue;
        }
        final state = resolver.stateFor(cell: cell, date: date);
        if (state == RosterCellState.working) {
          duty++;
        } else if (state == RosterCellState.offUncovered ||
            state == RosterCellState.unrosteredFuture) {
          risk++;
        }
      }
      totals[date] = RosterDayTotals(onDuty: duty, atRisk: risk);
    }
    return totals;
  }
}

/// Makes a fixed-size grid cell's content fit INSIDE the cell at any system
/// text size.
///
/// The grid's cells cannot grow to fit their content: the pinned names, the
/// headers and the day cells are laid out as separate strips that line up only
/// because they share fixed sizes (see [RosterGridMetrics]). So at large text
/// sizes the content has to give way instead. Before this, at Android's 1.5x
/// and 2x font settings the name cells overflowed by up to 37px, the date
/// headers by up to 17px and the on-duty totals by up to 30px, painting over
/// the neighbouring cells.
///
/// Content is scaled down uniformly, and only when it does not fit, so at a
/// normal text size nothing changes and at a large one the text stays as large
/// as the cell allows. That is deliberately not a cap on the text scale (which
/// would shrink text for someone who needs it even where it fits) and not
/// taller rows (which would change the grid for everybody).
///
/// [wrapAtCellWidth]: when true the content is laid out at the cell's real
/// width, so a two-line name still wraps and ellipsises THERE and only its
/// height is scaled. Pass false for a single row that overflows sideways (the
/// totals cell): pinning the width would leave it nowhere to go, so it is laid
/// out at its natural width and scaled to fit.
class _FitInCell extends StatelessWidget {
  const _FitInCell({
    required this.child,
    this.alignment = AlignmentDirectional.centerStart,
    this.wrapAtCellWidth = true,
  });

  final Widget child;
  final AlignmentGeometry alignment;
  final bool wrapAtCellWidth;

  @override
  Widget build(BuildContext context) {
    if (!wrapAtCellWidth) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: child,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: SizedBox(width: constraints.maxWidth, child: child),
      ),
    );
  }
}

/// A header / totals / name cell: the screen's neutral chrome.
class _ChromeCell extends StatelessWidget {
  const _ChromeCell({
    required this.width,
    required this.height,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      alignment: AlignmentDirectional.centerStart,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: _FitInCell(child: child),
    );
  }
}

/// Who the row is: the name, and a courier icon for couriers. Nothing else.
///
/// The standard day used to sit under the name; it is the overtime baseline,
/// so it now lives in the day sheet's header beside the day it explains.
class _EmployeeNameCell extends StatelessWidget {
  const _EmployeeNameCell({
    super.key,
    required this.employee,
    required this.width,
    required this.height,
  });

  final RosterEmployee employee;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: _FitInCell(
        child: Row(
          children: [
            Expanded(
              child: Text(
                employee.employeeName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ),
            if (employee.isCourier)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 2),
                child: Icon(
                  Icons.two_wheeler,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayHeaderCell extends StatelessWidget {
  const _DayHeaderCell({
    super.key,
    required this.date,
    required this.width,
    required this.height,
  });

  final String date;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parsed = DateTime.tryParse(date);
    // Egypt's weekend is Friday AND Saturday; this used to tint Friday alone.
    final isWeekend = parsed != null && isRosterWeekend(parsed);

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isWeekend
            ? RosterColors.weekendHeader
            : theme.colorScheme.surfaceContainerHigh,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: _FitInCell(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              // Locale digits, like every other number on the screen. The month
              // title was already Arabic-Indic in Arabic while the day numbers
              // and the hours stayed Western — three numeral systems at once.
              parsed == null ? date : rosterNumber(context, parsed.day),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (parsed != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isWeekend)
                    const Padding(
                      padding: EdgeInsetsDirectional.only(end: 2),
                      child: Icon(
                        Icons.weekend_outlined,
                        size: 9,
                        color: RosterColors.markerInk,
                      ),
                    ),
                  Flexible(
                    child: Text(
                      formatDate(context, parsed, pattern: 'E'),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
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

/// Headcount for one day, with the count of days nobody has dealt with.
class _DayTotalsCell extends StatelessWidget {
  const _DayTotalsCell({
    super.key,
    required this.date,
    required this.totals,
    required this.width,
    required this.height,
  });

  final String date;
  final RosterDayTotals totals;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parsed = DateTime.tryParse(date);
    final isWeekend = parsed != null && isRosterWeekend(parsed);

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isWeekend
            ? RosterColors.weekendHeader
            : theme.colorScheme.surfaceContainerHigh,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: _FitInCell(
        alignment: Alignment.center,
        wrapAtCellWidth: false,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rosterNumber(context, totals.onDuty),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (totals.atRisk > 0) ...[
              const SizedBox(width: 3),
              const Icon(
                Icons.warning_amber_rounded,
                size: 11,
                color: RosterColors.riskLine,
              ),
              Text(
                rosterNumber(context, totals.atRisk),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: RosterColors.riskInk,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One person on one day.
///
/// Draws ONE thing, read from [RosterStyleResolver] — the same object the
/// legend is generated from: the shift's time on a working day (with a small
/// dot when it runs past the person's standard day), or the state's word
/// otherwise. Only the two problem states are filled with colour; every other
/// cell is neutral, and what it is is written in it. The shift code, the
/// branch and the cover / holiday-worked markers live in the day sheet, one
/// tap away, and the Semantics label still says everything.
class _DayCell extends ConsumerWidget {
  const _DayCell({
    super.key,
    required this.employee,
    required this.date,
    required this.cell,
    required this.catalog,
    required this.shifts,
    required this.showShiftEnd,
    required this.coveringFor,
    required this.width,
    required this.height,
  });

  final RosterEmployee employee;
  final String date;
  final RosterCell? cell;
  final List<RosterShift> catalog;
  final RosterShiftCatalog shifts;
  final bool showShiftEnd;
  final String? coveringFor;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = cell;
    final selection = ref.watch(rosterSelectionProvider);
    final selectionIsThisRow = selection?.employee == employee.employee;
    final isSelected = selectionIsThisRow && selection!.dates.contains(date);

    final resolver = RosterStyleResolver.of(context, catalog: shifts);
    final state = resolver.stateFor(cell: data, date: date);
    final style = resolver.styleFor(
      state,
      shiftType: data?.shiftType,
      hours: data?.hours,
      withEnd: showShiftEnd,
    );
    final markers = resolver.markersFor(
      cell: data,
      employee: employee,
      isCover: coveringFor != null || (data?.isCoverFlag ?? false),
      isSelected: isSelected,
    );
    final isOvertime =
        state == RosterCellState.working &&
        markers.contains(RosterCellMarker.overtime);

    final Widget content;
    if (state == RosterCellState.working) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            // The shift's time, not its name or a colour: "9a–6p" answers
            // "who is in when" at a glance, where no abbreviation of "Branch
            // Cover Full Day" fits a phone-width cell. The name is in the day
            // sheet.
            style.token,
            maxLines: 1,
            style: theme.textTheme.labelLarge?.copyWith(
              color: style.foreground,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (isOvertime) ...[
            const SizedBox(width: 2),
            RosterOvertimeDot(color: style.foreground),
          ],
        ],
      );
    } else {
      final token = Text(
        style.token,
        maxLines: 1,
        style: theme.textTheme.labelSmall?.copyWith(
          color: style.foreground,
          fontWeight: style.isProblem ? FontWeight.w800 : FontWeight.w600,
          height: 1.1,
        ),
      );
      // A glyph beside the word only where the word is not enough: the
      // warning on an uncovered day off (so it does not rely on its amber
      // alone to stand apart from a covered one), and the flag on a holiday.
      final showIcon =
          state == RosterCellState.offUncovered ||
          state == RosterCellState.holiday;
      content = showIcon
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(style.icon, size: 11, color: style.foreground),
                const SizedBox(width: 2),
                token,
              ],
            )
          : token;
    }

    return Semantics(
      button: true,
      label: _semanticsLabel(context, style, markers, resolver),
      // SizedBox sets the footprint; Padding draws the gap inside it. A
      // Container with an outer margin here is the drift bug: it made every
      // cell 58x64 against 56-wide headers and 62-tall names, and the grid slid
      // a full column off its dates by day 29. See RosterGridMetrics.
      //
      // The InkWell sits OUTSIDE the padding so the tap target is still the
      // whole slot, exactly as it was when the margin lived inside it.
      child: SizedBox(
        width: width,
        height: height,
        child: InkWell(
          onTap: () {
            // In select mode a tap picks days; outside it, a tap opens the
            // single-day sheet. Two modes rather than "tap inside a selection
            // toggles" because that rule was invisible: the same tap did two
            // different things depending on a selection you might not see.
            if (ref.read(rosterSelectModeProvider)) {
              _toggleSelected(ref);
              return;
            }
            showRosterDaySheet(
              context,
              employee: employee,
              date: date,
              cell: data,
              catalog: catalog,
              coveringFor: coveringFor,
            );
          },
          // The shortcut into select mode, starting with this day.
          onLongPress: () {
            ref.read(rosterSelectModeProvider.notifier).state = true;
            _toggleSelected(ref);
          },
          child: Padding(
            padding: RosterGridMetrics.cellInset,
            child: Container(
              decoration: BoxDecoration(
                color: style.background,
                borderRadius: BorderRadius.circular(6),
                border: isSelected
                    ? Border.all(
                        color: RosterStyleResolver.selectionColor,
                        width: 2,
                      )
                    : style.hasBorder
                    ? Border.all(
                        color: style.borderColor,
                        width: style.borderWidth,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      // Scales down rather than clipping: a long window such
                      // as 12:30p–1a in a 56px column, a large system text
                      // size, Arabic's إجازة where English writes OFF. The
                      // cell's own size is fixed (see _FitInCell).
                      child: Center(
                        child: FittedBox(fit: BoxFit.scaleDown, child: content),
                      ),
                    ),
                  ),
                  if (isSelected)
                    const PositionedDirectional(
                      top: 2,
                      end: 2,
                      child: _SelectionTick(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Add or remove this day. A day in another person's row starts a fresh
  /// selection for that person (a bulk action is one person's days), and
  /// removing the last day leaves nothing selected rather than an empty set.
  void _toggleSelected(WidgetRef ref) {
    final notifier = ref.read(rosterSelectionProvider.notifier);
    final current = ref.read(rosterSelectionProvider);
    if (current != null && current.employee == employee.employee) {
      final next = current.toggle(date);
      notifier.state = next.dates.isEmpty ? null : next;
    } else {
      notifier.state = RosterSelection(
        employee: employee.employee,
        employeeName: employee.employeeName,
        dates: {date},
      );
    }
  }

  String _semanticsLabel(
    BuildContext context,
    RosterCellStyle style,
    Set<RosterCellMarker> markers,
    RosterStyleResolver resolver,
  ) {
    final parsed = DateTime.tryParse(date);
    final parts = <String>[
      employee.employeeName,
      parsed == null
          ? date
          : formatDate(context, parsed, pattern: 'EEEE, MMM d'),
      style.label,
      if (style.state == RosterCellState.working) ...[
        cell?.shiftType ?? '',
        resolver.workingText(shiftType: cell?.shiftType),
        rosterNumber(context, cell?.hours ?? 0),
        (cell?.shiftLocation ?? '').trim().isEmpty
            ? context.l10n.rosterBranchUnknown
            : cell!.shiftLocation!,
      ],
      for (final marker in markers) resolver.markerStyle(marker).label,
    ];
    return parts.where((p) => p.trim().isNotEmpty).join(' · ');
  }
}

class _SelectionTick extends StatelessWidget {
  const _SelectionTick();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 13,
      height: 13,
      decoration: const BoxDecoration(
        color: RosterStyleResolver.selectionColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, size: 9, color: Colors.white),
    );
  }
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) =>
      _EmptyState(icon: Icons.lock_outline, message: message);
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              context.userErrorMessage(error),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => ref.invalidate(rosterMonthDataProvider),
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
