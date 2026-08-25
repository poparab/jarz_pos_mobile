import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../b2b/data/b2b_repository.dart';
import '../../../b2b/state/b2b_today_notifier.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../leads/presentation/leads_theme.dart';
import '../../data/journey_repository.dart';
import '../../data/models/journey_action.dart';
import '../../state/action_calendar_notifier.dart';
import '../../state/journey_notes_notifier.dart';
import '../journey_format.dart';

/// Marker colours. Three states, three hues: an overdue promise has to be
/// separable from a merely upcoming one at a glance, in a 6px dot.
const _pendingColor = LeadsTheme.sahelBlue;
const _overdueColor = Color(0xFFB3261E);
const _doneColor = JourneyFormat.doneGreen;

/// Everything a rep owes anybody, on a month grid.
///
/// The diary answers "what happened at this account"; this answers the other
/// question — "what do I owe, and when" — across every account at once. The
/// server does the filtering (scope, done, window), so what the grid counts is
/// exactly what the reminders will fire on.
class ActionCalendarScreen extends ConsumerStatefulWidget {
  const ActionCalendarScreen({super.key});

  @override
  ConsumerState<ActionCalendarScreen> createState() =>
      _ActionCalendarScreenState();
}

class _ActionCalendarScreenState extends ConsumerState<ActionCalendarScreen> {
  /// The day whose list is shown below the grid. Null until the rep taps, and
  /// deliberately dropped when the month changes — see [_effectiveSelection].
  DateTime? _selected;

  /// Resolves what the list below the grid is showing.
  ///
  /// A selection from a month the rep has since paged away from would render
  /// an empty list under a grid full of dots, so it falls back to today when
  /// today is on screen and to the 1st otherwise.
  DateTime _effectiveSelection(ActionCalendarQuery query) {
    final chosen = _selected;
    if (chosen != null &&
        chosen.year == query.month.year &&
        chosen.month == query.month.month) {
      return chosen;
    }
    final now = DateTime.now();
    if (now.year == query.month.year && now.month == query.month.month) {
      return DateTime(now.year, now.month, now.day);
    }
    return query.firstDay;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = ref.watch(actionCalendarQueryProvider);
    final async = ref.watch(actionCalendarProvider(query));
    final selected = _effectiveSelection(query);

    return Scaffold(
      backgroundColor: LeadsTheme.bg,
      appBar: AppBar(
        title: Text(l10n.journeyCalendarTitle),
        actions: [
          IconButton(
            tooltip: l10n.commonRetry,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(actionCalendarProvider(query)),
          ),
        ],
      ),
      body: Column(
        children: [
          // The controls stay put while a month loads: paging back out of a
          // slow month must not require waiting for it to arrive first.
          _Controls(query: query),
          _MonthBar(
            query: query,
            onPrevious: () =>
                ref.read(actionCalendarQueryProvider.notifier).previousMonth(),
            onNext: () =>
                ref.read(actionCalendarQueryProvider.notifier).nextMonth(),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorView(
                error: error,
                onRetry: () => ref.invalidate(actionCalendarProvider(query)),
              ),
              data: (calendar) => _CalendarBody(
                query: query,
                calendar: calendar,
                selected: selected,
                onSelectDay: (day) => setState(() => _selected = day),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scope ("mine" / "all") and whether closed promises are shown. Both are
/// server-side filters, so flipping either re-queries rather than hiding rows
/// the app already downloaded.
class _Controls extends ConsumerWidget {
  const _Controls({required this.query});

  final ActionCalendarQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notifier = ref.read(actionCalendarQueryProvider.notifier);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'mine',
                  label: Text(l10n.journeyCalendarScopeMine),
                ),
                ButtonSegment(
                  value: 'all',
                  label: Text(l10n.journeyCalendarScopeAll),
                ),
              ],
              selected: {query.scope},
              showSelectedIcon: false,
              onSelectionChanged: (values) =>
                  notifier.setScope(values.first),
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(l10n.journeyCalendarShowDone),
            selected: query.includeDone,
            onSelected: notifier.setIncludeDone,
            selectedColor: const Color(0xFFE7F3EA),
            checkmarkColor: _doneColor,
          ),
        ],
      ),
    );
  }
}

/// Month title with the two arrows that move the window.
class _MonthBar extends StatelessWidget {
  const _MonthBar({
    required this.query,
    required this.onPrevious,
    required this.onNext,
  });

  final ActionCalendarQuery query;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title =
        DateFormat('MMMM yyyy', l10n.localeName).format(query.firstDay);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.journeyCalendarPreviousMonth,
            // chevron_left/right auto-flip in RTL, so "previous" stays on the
            // reading-start side in Arabic without a manual swap.
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: LeadsTheme.nameStyle(title, fontSize: 17),
            ),
          ),
          IconButton(
            tooltip: l10n.journeyCalendarNextMonth,
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

/// The counts strip, the grid, and the selected day's list.
class _CalendarBody extends StatelessWidget {
  const _CalendarBody({
    required this.query,
    required this.calendar,
    required this.selected,
    required this.onSelectDay,
  });

  final ActionCalendarQuery query;
  final JourneyActionCalendar calendar;
  final DateTime selected;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final byDay = calendar.byDay;
    final dayActions = byDay[JourneyFormat.iso(selected)] ?? const [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      children: [
        _CountsStrip(counts: calendar.counts),
        const SizedBox(height: 8),
        _MonthGrid(
          query: query,
          byDay: byDay,
          selected: selected,
          onSelectDay: onSelectDay,
        ),
        const SizedBox(height: 12),
        Text(
          JourneyFormat.pretty(context, JourneyFormat.iso(selected)),
          style: LeadsTheme.heading,
        ),
        const SizedBox(height: 6),
        if (dayActions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              calendar.isEmpty
                  ? l10n.journeyCalendarEmptyMonth
                  : l10n.journeyCalendarNothingOnDay,
              style: LeadsTheme.bodyMuted,
            ),
          )
        else
          for (final action in dayActions)
            _ActionTile(action: action, query: query),
      ],
    );
  }
}

class _CountsStrip extends StatelessWidget {
  const _CountsStrip({required this.counts});

  final JourneyActionCounts counts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _CountChip(
          label: l10n.journeyCalendarPendingCount(counts.upcoming),
          color: _pendingColor,
        ),
        _CountChip(
          label: l10n.journeyCalendarOverdueCount(counts.overdue),
          color: _overdueColor,
        ),
        _CountChip(
          label: l10n.journeyCalendarDoneCount(counts.done),
          color: _doneColor,
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dot(color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: LeadsTheme.bodyFont,
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFeatures: LeadsTheme.tabular,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, this.size = 7});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// A hand-built month grid.
///
/// Deliberately not a calendar package: the app ships one screen that needs a
/// grid, and a new dependency would push the next release from a Shorebird
/// patch to a full store build. Weekday order and labels come from
/// [MaterialLocalizations], so the week starts on the right day per locale and
/// the whole thing mirrors correctly in Arabic.
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.query,
    required this.byDay,
    required this.selected,
    required this.onSelectDay,
  });

  final ActionCalendarQuery query;
  final Map<String, List<JourneyAction>> byDay;
  final DateTime selected;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final firstWeekday = material.firstDayOfWeekIndex;
    final first = query.firstDay;
    final daysInMonth = query.lastDay.day;

    // DateTime.weekday is 1=Mon..7=Sun; Material indexes 0=Sun..6=Sat.
    final leading = (first.weekday % 7 - firstWeekday + 7) % 7;
    final cells = leading + daysInMonth;
    final rows = (cells / 7).ceil();
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LeadsTheme.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      material.narrowWeekdays[(firstWeekday + i) % 7],
                      style: const TextStyle(
                        fontFamily: LeadsTheme.bodyFont,
                        color: LeadsTheme.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (var row = 0; row < rows; row++)
            Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _buildCell(
                      context,
                      dayNumber: row * 7 + col - leading + 1,
                      daysInMonth: daysInMonth,
                      today: today,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCell(
    BuildContext context, {
    required int dayNumber,
    required int daysInMonth,
    required DateTime today,
  }) {
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      // A spill cell is left blank rather than showing the neighbouring
      // month's number: the window fetched is this month only, so a number
      // there would promise "nothing due" without having asked.
      return const SizedBox(height: 46);
    }
    final date = DateTime(query.month.year, query.month.month, dayNumber);
    final actions = byDay[JourneyFormat.iso(date)] ?? const <JourneyAction>[];
    final isSelected = date.year == selected.year &&
        date.month == selected.month &&
        date.day == selected.day;
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    final hasOverdue = actions.any((a) => a.overdue && !a.done);
    final hasPending = actions.any((a) => !a.done && !a.overdue);
    final hasDone = actions.any((a) => a.done);

    return Semantics(
      selected: isSelected,
      label: actions.isEmpty
          ? null
          : context.l10n.journeyCalendarDueCount(actions.length),
      child: InkWell(
        onTap: () => onSelectDay(date),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 46,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: isSelected
                ? LeadsTheme.berryPink.withValues(alpha: 0.14)
                : null,
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: LeadsTheme.berryPink, width: 1.2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$dayNumber',
                style: TextStyle(
                  fontFamily: LeadsTheme.bodyFont,
                  color: LeadsTheme.deepPlum,
                  fontSize: 13,
                  fontWeight:
                      isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                  fontFeatures: LeadsTheme.tabular,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasOverdue) const _Dot(color: _overdueColor, size: 6),
                  if (hasOverdue && (hasPending || hasDone))
                    const SizedBox(width: 3),
                  if (hasPending) const _Dot(color: _pendingColor, size: 6),
                  if (hasPending && hasDone) const SizedBox(width: 3),
                  if (hasDone) const _Dot(color: _doneColor, size: 6),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One due action: which account, what was promised, to whom.
class _ActionTile extends ConsumerStatefulWidget {
  const _ActionTile({required this.action, required this.query});

  final JourneyAction action;
  final ActionCalendarQuery query;

  @override
  ConsumerState<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends ConsumerState<_ActionTile> {
  bool _busy = false;

  /// Both kinds of row can be ticked off, through different endpoints — see
  /// [_toggle]. A follow-up that is already done offers nothing, because the
  /// record-level endpoint has no reverse.
  bool get _canToggle => widget.action.canToggle;

  Future<void> _toggle() async {
    if (_busy) return;
    final action = widget.action;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final done = !action.done;
    setState(() => _busy = true);
    try {
      if (action.isJourney) {
        await ref
            .read(journeyRepositoryProvider)
            .setActionDone(name: action.note, done: done);
      } else {
        // A bare account follow-up has no note to stamp; it is settled through
        // the record-level endpoint the "My follow-ups" feed already uses.
        // That one only closes — hence `canToggle` hiding the control once done.
        await ref.read(b2bRepositoryProvider).completeFollowup(
              doctype: action.referenceDoctype,
              name: action.referenceName,
            );
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            done ? l10n.journeyActionMarkedDone : l10n.journeyActionReopened,
          ),
        ),
      );
      // Both the grid and the account's own timeline moved. Invalidating the
      // diary too keeps a screen the rep pushes into next from showing the
      // state they just changed here.
      ref.invalidate(actionCalendarProvider(widget.query));
      // The "My follow-ups" feed lists these same ToDos, so a row ticked off
      // here must not still be sitting there when the rep navigates back.
      ref.invalidate(b2bTodayProvider);
      ref.invalidate(
        journeyNotesProvider(
          JourneyRef(
            doctype: action.referenceDoctype,
            name: action.referenceName,
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.journeyFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Every row opens the B2B account screen, whatever it hangs off: it takes
  /// Lead, Opportunity and Customer alike, and the calendar is reached from
  /// the B2B surfaces, so a rep stays in one place rather than being thrown
  /// into the leads catalog for half the list.
  void _open() {
    final action = widget.action;
    if (action.referenceName.trim().isEmpty) return;
    context.push(
      AppRoutes.b2bAccount,
      extra: <String, dynamic>{
        'doctype': action.referenceDoctype.isEmpty
            ? 'Lead'
            : action.referenceDoctype,
        'name': action.referenceName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final action = widget.action;
    final done = action.done;
    final overdue = action.overdue && !done;
    final typeHint = action.isJourney
        ? localizedJourneyType(context, action.entryType)
        : l10n.journeyCalendarSourceFollowup;
    final actionText = action.action.trim().isEmpty
        ? l10n.journeyCalendarNoAction
        : action.action.trim();

    return InkWell(
      onTap: _open,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: overdue ? const Color(0xFFFBEDEC) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: overdue ? _overdueColor.withValues(alpha: 0.35)
                : LeadsTheme.line,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              done
                  ? Icons.check_circle
                  : action.isJourney
                      ? JourneyFormat.typeIcon(action.entryType)
                      : Icons.alarm,
              size: 18,
              color: done
                  ? _doneColor
                  : overdue
                      ? _overdueColor
                      : LeadsTheme.deepPlum,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LeadsTheme.nameStyle(action.title, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    actionText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: LeadsTheme.fontFamilyFor(actionText),
                      color: done ? LeadsTheme.muted : LeadsTheme.deepPlum,
                      fontSize: 13,
                      height: 1.3,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (typeHint.isNotEmpty)
                        _HintChip(
                          label: typeHint,
                          color: overdue ? _overdueColor : LeadsTheme.muted,
                        ),
                      if (action.contactPerson.trim().isNotEmpty)
                        _IconLabel(
                          icon: Icons.person_outline,
                          label: action.contactPerson.trim(),
                        ),
                      // Who owns it only matters on the "all" scope; on "mine"
                      // it is the reader, every row.
                      if (widget.query.scope == 'all' &&
                          action.ownerName.trim().isNotEmpty)
                        _IconLabel(
                          icon: Icons.badge_outlined,
                          label: action.ownerName.trim(),
                        ),
                      if (overdue)
                        _HintChip(
                          label: l10n.journeyOverdue,
                          color: _overdueColor,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_canToggle)
              IconButton(
                onPressed: _toggle,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                tooltip:
                    done ? l10n.journeyMarkNotDone : l10n.journeyMarkDone,
                icon: Icon(
                  done ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 22,
                  color: done ? _doneColor : LeadsTheme.muted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  const _HintChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: LeadsTheme.bodyFont,
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: LeadsTheme.muted),
        const SizedBox(width: 3),
        Text(label, style: LeadsTheme.bodyMuted),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.journeyCalendarLoadFailed,
              textAlign: TextAlign.center,
              style: LeadsTheme.body,
            ),
            const SizedBox(height: 6),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: LeadsTheme.bodyMuted,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
