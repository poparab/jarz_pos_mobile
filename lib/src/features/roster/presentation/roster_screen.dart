import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../../core/network/user_service.dart';
import '../../../core/widgets/app_drawer.dart';
import '../models/roster_models.dart';
import '../state/roster_providers.dart';
import 'roster_cell_style.dart';
import 'roster_formats.dart';
import 'roster_shift_palette.dart';
import 'widgets/roster_bulk_bar.dart';
import 'widgets/roster_day_sheet.dart';
import 'widgets/roster_hours_sheet.dart';
import 'widgets/roster_legend.dart';

/// Monthly shift distribution.
///
/// People down the side, days across the top — the shape a rota is actually
/// read in. The employee column is pinned while the days scroll horizontally,
/// because the one thing a manager must never lose track of while scanning
/// across a month is whose row they are on.
///
/// Every colour on this screen comes from [RosterStyleResolver]; nothing here
/// picks its own. See `roster_cell_style.dart` for what each hue means.
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
    final monthAsync = ref.watch(rosterMonthDataProvider);
    final selection = ref.watch(rosterSelectionProvider);

    // A selection names dates in a SPECIFIC month; switching months or the
    // branch filter must not leave it pointing at a grid the manager can no
    // longer see, where a bulk action would look like it targets nothing.
    ref.listen(rosterMonthProvider, (previous, next) {
      if (previous != next) {
        ref.read(rosterSelectionProvider.notifier).state = null;
      }
    });
    ref.listen(rosterLocationFilterProvider, (previous, next) {
      if (previous != next) {
        ref.read(rosterSelectionProvider.notifier).state = null;
      }
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
                if (selection != null) RosterBulkBar(selection: selection),
              ],
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
    final location = ref.watch(rosterLocationFilterProvider);
    final bootstrap = ref.watch(rosterBootstrapProvider);
    final theme = Theme.of(context);

    final branches =
        bootstrap.asData?.value.shiftLocations
            .map((l) => l.shiftLocation)
            .toList() ??
        const <String>[];

    return Material(
      // Chrome, not a state: the control bar, the headers and the name column
      // all sit on one neutral, and no cell state uses that neutral. Solid
      // rather than a 0.4 alpha wash so the text on it keeps its contrast.
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: l10n.rosterPreviousMonth,
              onPressed: () => ref.read(rosterMonthProvider.notifier).state =
                  shiftMonth(month, -1),
            ),
            Expanded(
              child: Text(
                _monthLabel(context, month),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: l10n.rosterNextMonth,
              onPressed: () => ref.read(rosterMonthProvider.notifier).state =
                  shiftMonth(month, 1),
            ),
            if (branches.length > 1)
              DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: location,
                  hint: Text(l10n.rosterAllBranches),
                  items: <DropdownMenuItem<String?>>[
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.rosterAllBranches),
                    ),
                    ...branches.map(
                      (b) => DropdownMenuItem<String?>(
                        value: b,
                        child: Text(b),
                      ),
                    ),
                  ],
                  onChanged: (value) => ref
                      .read(rosterLocationFilterProvider.notifier)
                      .state = value,
                ),
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
}

class _RosterBody extends ConsumerWidget {
  const _RosterBody({required this.month});

  final RosterMonth month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    if (!month.hrmsAvailable) {
      return _EmptyState(
        icon: Icons.info_outline,
        message: month.notice ?? l10n.rosterHrmsMissing,
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

    // Built once per payload and handed down: the palette so every cell, the
    // legend and the day sheet agree on what a shift type looks like, and the
    // cover index because a cover day is recorded on the *other* person's cell.
    final palette = RosterShiftPalette.fromMonth(month);
    final coverIndex = RosterCoverIndex.fromMonth(month);

    return Column(
      children: [
        if (month.gaps.isNotEmpty) _UncoveredBanner(gaps: month.gaps),
        RosterLegend(palette: palette),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            l10n.rosterBulkSelectHint,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ),
        Expanded(
          child: _RosterGrid(
            month: month,
            palette: palette,
            coverIndex: coverIndex,
          ),
        ),
      ],
    );
  }
}

/// Days off that nobody was named to cover.
///
/// Surfaced at the top rather than left to be spotted in the grid, because this
/// is the mistake the screen exists to prevent: a branch whose second shift was
/// removed and never handed to anyone reads as a perfectly normal calendar
/// right up until the morning it opens short-staffed.
///
/// Drawn in the same amber as the cells it is counting. It used to be
/// `errorContainer`, i.e. the same red as an unrostered day and a destructive
/// button — so the banner's colour pointed at nothing in particular.
class _UncoveredBanner extends StatelessWidget {
  const _UncoveredBanner({required this.gaps});

  final List<RosterGap> gaps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: RosterColors.riskFill,
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
        ],
      ),
    );
  }
}

/// The grid itself: a pinned employee column beside horizontally scrolling days.
///
/// One outer vertical scroll wraps both halves so they cannot drift out of
/// alignment — synchronising two separate vertical controllers is the usual way
/// this kind of table ends up one row out.
class _RosterGrid extends ConsumerWidget {
  const _RosterGrid({
    required this.month,
    required this.palette,
    required this.coverIndex,
  });

  final RosterMonth month;
  final RosterShiftPalette palette;
  final RosterCoverIndex coverIndex;

  static const double _rowHeight = 62;
  static const double _headerHeight = 42;
  static const double _totalsHeight = 30;
  static const double _cellWidth = 56;
  static const double _nameWidth = 120;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dates = month.dates;
    final theme = Theme.of(context);
    final branch = ref.watch(rosterLocationFilterProvider);
    final resolver = RosterStyleResolver.of(context, palette: palette);
    final totals = _dayTotals(month, resolver);

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned: who.
          Column(
            children: [
              _ChromeCell(
                width: _nameWidth,
                height: _headerHeight,
                child: Text(
                  context.l10n.rosterEmployeeColumn,
                  style: theme.textTheme.labelSmall,
                ),
              ),
              _ChromeCell(
                width: _nameWidth,
                height: _totalsHeight,
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
                  employee: employee,
                  width: _nameWidth,
                  height: _rowHeight,
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
                            date: date,
                            width: _cellWidth,
                            height: _headerHeight,
                          ),
                        )
                        .toList(),
                  ),
                  Row(
                    children: dates
                        .map(
                          (date) => _DayTotalsCell(
                            date: date,
                            totals:
                                totals[date] ??
                                const RosterDayTotals(onDuty: 0, atRisk: 0),
                            width: _cellWidth,
                            height: _totalsHeight,
                          ),
                        )
                        .toList(),
                  ),
                  ...month.employees.map(
                    (employee) => Row(
                      children: dates
                          .map(
                            (date) => _DayCell(
                              employee: employee,
                              date: date,
                              cell: employee.cellFor(date),
                              catalog: month.shiftCatalog,
                              palette: palette,
                              coveringFor: coverIndex.coveredColleague(
                                employee.employee,
                                date,
                              ),
                              width: _cellWidth,
                              height: _rowHeight,
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
  }

  /// Headcount and at-risk count per day.
  ///
  /// Resolved through the same [RosterStyleResolver] the cells use, so the
  /// number in the totals row can never count a day differently from the way
  /// the column below it is drawn.
  static Map<String, RosterDayTotals> _dayTotals(
    RosterMonth month,
    RosterStyleResolver resolver,
  ) {
    final totals = <String, RosterDayTotals>{};
    for (final date in month.dates) {
      var duty = 0;
      var risk = 0;
      for (final employee in month.employees) {
        final state = resolver.stateFor(
          cell: employee.cellFor(date),
          date: date,
        );
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
      child: child,
    );
  }
}

class _EmployeeNameCell extends StatelessWidget {
  const _EmployeeNameCell({
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            employee.employeeName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              // The overtime baseline, shown because it is what every cell in
              // this row is compared against — and now the cells say so, with
              // the overtime marker on any day that goes past it.
              Expanded(
                child: Text(
                  context.l10n.rosterStandardDay(
                    rosterNumber(context, employee.standardHours),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              if (employee.isCourier)
                Icon(
                  Icons.two_wheeler,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayHeaderCell extends StatelessWidget {
  const _DayHeaderCell({
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}

/// Headcount for one day, with the count of days nobody has dealt with.
class _DayTotalsCell extends StatelessWidget {
  const _DayTotalsCell({
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}

/// One person on one day.
///
/// Reads its colours, glyph and token from [RosterStyleResolver] — the same
/// object the legend is generated from — and adds the three things a manager
/// previously had to open the day sheet to learn: which shift it is (the code
/// in the corner), where they are (the branch token underneath), and whether
/// the day is out of the ordinary (the markers).
class _DayCell extends ConsumerWidget {
  const _DayCell({
    required this.employee,
    required this.date,
    required this.cell,
    required this.catalog,
    required this.palette,
    required this.coveringFor,
    required this.width,
    required this.height,
  });

  final RosterEmployee employee;
  final String date;
  final RosterCell? cell;
  final List<RosterShift> catalog;
  final RosterShiftPalette palette;
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

    final resolver = RosterStyleResolver.of(context, palette: palette);
    final state = resolver.stateFor(cell: data, date: date);
    final style = resolver.styleFor(state, shiftType: data?.shiftType);
    final markers = resolver.markersFor(
      cell: data,
      employee: employee,
      isCover: coveringFor != null || (data?.isCoverFlag ?? false),
      isSelected: isSelected,
    );
    final cornerMarkers = markers
        .where((m) => m != RosterCellMarker.selected)
        .toList();

    final branch = (data?.shiftLocation ?? '').trim();

    return Semantics(
      button: true,
      label: _semanticsLabel(context, style, markers, resolver),
      child: InkWell(
        onTap: () {
          // Tapping inside an active selection on THIS row extends or shrinks
          // the run instead of opening the single-cell sheet — that sheet's
          // per-day flow is still the entry point (via long-press) and the
          // right tool for a lone edit, so nothing here removes it.
          if (selectionIsThisRow) {
            ref.read(rosterSelectionProvider.notifier).state = selection!
                .toggle(date);
            return;
          }
          showRosterDaySheet(
            context,
            employee: employee,
            date: date,
            cell: data,
            catalog: catalog,
            palette: palette,
            coveringFor: coveringFor,
          );
        },
        onLongPress: () {
          final current = ref.read(rosterSelectionProvider);
          if (current != null && current.employee == employee.employee) {
            ref.read(rosterSelectionProvider.notifier).state = current.toggle(
              date,
            );
          } else {
            ref.read(rosterSelectionProvider.notifier).state = RosterSelection(
              employee: employee.employee,
              employeeName: employee.employeeName,
              dates: {date},
            );
          }
        },
        child: Container(
          width: width,
          height: height,
          margin: const EdgeInsets.all(1),
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
                child: Center(
                  child: state == RosterCellState.working
                      ? Padding(
                          // Leaves the corners to the code, the branch and the
                          // markers.
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            // The hours, not the shift name: a manager scanning
                            // a month cares whether a day is a 9 or a 12, and no
                            // abbreviation of "Branch Cover Full Day" fits in a
                            // phone-width cell without becoming a riddle. Which
                            // shift it is now rides in the corner code instead.
                            rosterNumber(context, data!.hours),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: style.foreground,
                              fontWeight: FontWeight.w800,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (style.icon != null)
                              Icon(
                                style.icon,
                                size: 16,
                                color: style.foreground,
                              ),
                            if (style.token.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: FittedBox(
                                  // Arabic writes إجازة where English writes
                                  // OFF; scaling down beats clipping, and beats
                                  // inventing an abbreviation Arabic does not
                                  // have.
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    style.token,
                                    maxLines: 1,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: style.foreground,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              if (style.shiftCode != null)
                PositionedDirectional(
                  top: 2,
                  start: 3,
                  child: _CodeChip(
                    code: style.shiftCode!,
                    foreground: style.foreground,
                  ),
                ),
              if (branch.isNotEmpty && state == RosterCellState.working)
                PositionedDirectional(
                  bottom: 2,
                  start: 3,
                  child: Text(
                    branchToken(branch),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      height: 1,
                      letterSpacing: 0.2,
                      color: style.foreground,
                    ),
                  ),
                ),
              if (cornerMarkers.isNotEmpty)
                PositionedDirectional(
                  bottom: 2,
                  end: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final marker in cornerMarkers)
                        _MarkerGlyph(style: resolver.markerStyle(marker)),
                    ],
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
    );
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
      parsed == null ? date : formatDate(context, parsed, pattern: 'EEEE, MMM d'),
      style.label,
      if (style.state == RosterCellState.working) ...[
        cell?.shiftType ?? '',
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

/// The shift type's short code, in the cell's leading corner.
class _CodeChip extends StatelessWidget {
  const _CodeChip({required this.code, required this.foreground});

  final String code;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontSize: 9,
          height: 1.2,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}

/// A marker: one ink, told apart by its glyph, on a chip light enough to read
/// over whatever colour Desk gave the shift type.
class _MarkerGlyph extends StatelessWidget {
  const _MarkerGlyph({required this.style});

  final RosterMarkerStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 13,
      height: 13,
      margin: const EdgeInsetsDirectional.only(start: 1),
      decoration: BoxDecoration(
        color: RosterColors.markerChip,
        shape: BoxShape.circle,
        border: Border.all(color: RosterColors.markerInk, width: 0.5),
      ),
      child: Icon(style.icon, size: 9, color: RosterColors.markerInk),
    );
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
            Icon(
              Icons.error_outline,
              size: 40,
              color: theme.colorScheme.error,
            ),
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
