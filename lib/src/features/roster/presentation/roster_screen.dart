import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../../core/network/user_service.dart';
import '../../../core/widgets/app_drawer.dart';
import '../models/roster_models.dart';
import '../state/roster_providers.dart';
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
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
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

  /// "September 2026" / "سبتمبر 2026".
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

    return Column(
      children: [
        if (month.gaps.isNotEmpty) _UncoveredBanner(gaps: month.gaps),
        const RosterLegend(),
        Expanded(child: _RosterGrid(month: month)),
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
class _UncoveredBanner extends StatelessWidget {
  const _UncoveredBanner({required this.gaps});

  final List<RosterGap> gaps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.rosterUncoveredWarning(gaps.length),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
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
  const _RosterGrid({required this.month});

  final RosterMonth month;

  static const double _rowHeight = 52;
  static const double _headerHeight = 44;
  static const double _cellWidth = 46;
  static const double _nameWidth = 132;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dates = month.dates;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned: who.
          Column(
            children: [
              Container(
                width: _nameWidth,
                height: _headerHeight,
                alignment: AlignmentDirectional.centerStart,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border(
                    bottom: BorderSide(color: theme.dividerColor),
                  ),
                ),
                child: Text(
                  context.l10n.rosterEmployeeColumn,
                  style: theme.textTheme.labelSmall,
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
                  ...month.employees.map(
                    (employee) => Row(
                      children: dates
                          .map(
                            (date) => _ShiftCell(
                              employee: employee,
                              date: date,
                              cell: employee.cellFor(date),
                              catalog: month.shiftCatalog,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            // The overtime baseline, shown because it is what every cell in
            // this row is compared against to decide what counts as overtime.
            context.l10n.rosterStandardDay(
              _trimZero(employee.standardHours),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
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
    final isWeekendish =
        parsed != null && parsed.weekday == DateTime.friday;

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isWeekendish
            ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            parsed == null ? date : parsed.day.toString(),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (parsed != null)
            Text(
              formatDate(context, parsed, pattern: 'E'),
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
            ),
        ],
      ),
    );
  }
}

class _ShiftCell extends ConsumerWidget {
  const _ShiftCell({
    required this.employee,
    required this.date,
    required this.cell,
    required this.catalog,
    required this.width,
    required this.height,
  });

  final RosterEmployee employee;
  final String date;
  final RosterCell? cell;
  final List<RosterShift> catalog;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = cell;

    Color background;
    Color foreground;
    String label;
    IconData? badge;

    if (data == null || data.isUnrostered) {
      if (_isPast(date)) {
        // History, not a gap. HRMS retires an assignment once its end date has
        // passed, so old days legitimately read as unrostered — flagging them
        // red would paint every past month as a wall of alarms and train
        // people to ignore the colour that matters.
        background = theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.4,
        );
        foreground = theme.colorScheme.outline;
        label = '·';
        badge = null;
      } else {
        // Deliberately not a blank: an unrostered day refuses check-ins, so
        // drawing nothing would hide a state that stops somebody working.
        background = theme.colorScheme.errorContainer.withValues(alpha: 0.35);
        foreground = theme.colorScheme.error;
        label = '—';
        badge = Icons.block;
      }
    } else if (data.isOff) {
      background = theme.colorScheme.tertiaryContainer;
      foreground = theme.colorScheme.onTertiaryContainer;
      label = context.l10n.rosterOffShort;
      badge = data.dayOff!.isCovered ? Icons.check_circle : Icons.warning;
    } else if (data.isHoliday && !data.isWorking) {
      background = theme.colorScheme.surfaceContainerHighest;
      foreground = theme.colorScheme.onSurfaceVariant;
      label = context.l10n.rosterHolidayShort;
      badge = null;
    } else {
      background = _shiftColor(context, data.shiftType!);
      foreground = theme.colorScheme.onSurface;
      // The hours, not the shift name: a manager scanning a month cares whether
      // a day is a 9 or a 12, and no abbreviation of "Branch Cover Full Day"
      // fits in a phone-width cell without becoming a riddle.
      label = _trimZero(data.hours);
      badge = null;
    }

    return InkWell(
      onTap: () => showRosterDaySheet(
        context,
        employee: employee,
        date: date,
        cell: data,
        catalog: catalog,
      ),
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.all(1),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (badge != null) Icon(badge, size: 10, color: foreground),
          ],
        ),
      ),
    );
  }

  /// Whether this cell's day has already gone.
  ///
  /// Compared date-only: a cell for today must never count as past, because
  /// today is the one day where an empty cell has an immediate consequence.
  static bool _isPast(String date) {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(parsed.year, parsed.month, parsed.day).isBefore(today);
  }

  /// Stable colour per shift type.
  ///
  /// Derived from the name so the same shift is the same colour in every month
  /// and on every device, without needing a colour column to be filled in on
  /// each Shift Type in Desk.
  static Color _shiftColor(BuildContext context, String shiftType) {
    const palette = <Color>[
      Color(0xFFB3E5FC),
      Color(0xFFC8E6C9),
      Color(0xFFFFE0B2),
      Color(0xFFD1C4E9),
      Color(0xFFF8BBD0),
      Color(0xFFDCEDC8),
      Color(0xFFFFF9C4),
      Color(0xFFB2DFDB),
    ];
    final hash = shiftType.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) & 0x7fffffff);
    final base = palette[hash % palette.length];
    return Theme.of(context).brightness == Brightness.dark
        ? Color.alphaBlend(base.withValues(alpha: 0.35), Colors.black26)
        : base;
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

String _trimZero(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}
