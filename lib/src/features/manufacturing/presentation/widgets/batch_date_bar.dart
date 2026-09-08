import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/posting_date_confirmation_dialog.dart';
import '../../data/models/production_policy.dart';

/// One production date for the whole batch.
///
/// Replaces the per-line date and time pickers: for a team making one run a
/// day, a picker per row was ceremony repeated per line.
///
/// The window comes from [ProductionPolicy] — the server's own answer — and not
/// from a constant in this app. Those two used to be separate numbers, and they
/// disagreed: the app offered three days back while production's setting held
/// 0, so the picker cheerfully offered yesterday and every submit of it was
/// refused. A window the client invents is a window the client can be wrong
/// about, and being wrong here reads on the floor as "the screen lies".
///
/// Forward-dating is gone entirely, at every window: a future-dated stock entry
/// for work already done is meaningless, and a wrong tablet clock is the usual
/// cause.
class BatchDateBar extends StatelessWidget {
  const BatchDateBar({
    super.key,
    required this.date,
    required this.onChanged,
    required this.policy,
    this.earliest,
    this.timeChosen = false,
  });

  final DateTime date;

  /// Reports the day AND the clock time, as one choice. The picker asks for
  /// both or returns nothing, so every value this emits carries a time the
  /// operator actually chose — which is what lets the callers tell an explicit
  /// production time apart from a default they should let the server stamp.
  final ValueChanged<DateTime> onChanged;

  /// Whether [date] carries a time the operator picked, rather than a default.
  ///
  /// Only the label depends on it: showing "00:00" on a date nobody timed is
  /// exactly the midnight-that-was-never-chosen this feature exists to stop.
  final bool timeChosen;

  /// A floor tighter than the policy window, when the caller has one.
  ///
  /// The finish sheet passes the batch's start day: a batch cannot be finished
  /// before its material went in, and the server refuses that outright. Offering
  /// the date and refusing it three taps later is the failure this widget was
  /// rewritten to stop, so the clamp belongs in the picker too.
  ///
  /// Never widens the window — only ever narrows it.
  final DateTime? earliest;

  /// What the server will accept from this user. While it is still loading the
  /// fallback is today-only — a picker that offers a date the server refuses is
  /// worse than one that briefly offers too few.
  final ProductionPolicy policy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final backDated = policy.isBackDated(date);
    // A ceiling of zero days is a real setting — "today only" — and locks the
    // picker just as firmly as the role check does. A System Manager is bound
    // by neither.
    final canPick = policy.canBackDate &&
        (policy.unlimitedBackDate || policy.maxBackDateDays > 0) &&
        // A floor at today leaves one selectable day, so there is nothing to
        // pick — show it locked rather than opening a one-cell calendar.
        _firstDate.isBefore(policy.today());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.event,
              size: 18,
              color: backDated ? scheme.tertiary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            // Expanded rather than a Spacer: the label is a translated string
            // and the Arabic one is longer, so on a narrow phone a fixed-width
            // Text plus the date button overflowed the row.
            Expanded(
              child: Text(
                l10n.productionPostingDate,
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: canPick ? () => _pick(context) : null,
              child: Text(
                timeChosen
                    ? formatPostingDateTimeForDisplay(context, date)
                    : _format(date),
              ),
            ),
          ],
        ),
        // A greyed-out date button with no explanation reads as a bug, and a
        // usable one still hides where the wall is until somebody opens the
        // calendar and finds it. Say both, in one line.
        if (_caption(context) case final caption?)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 26, bottom: 2),
            child: Text(
              caption,
              style: theme.textTheme.labelSmall?.copyWith(
                color: backDated ? scheme.tertiary : scheme.onSurfaceVariant,
                fontWeight: backDated ? FontWeight.w700 : null,
              ),
            ),
          ),
      ],
    );
  }

  /// The line under the date, or null when there is nothing worth saying — a
  /// System Manager on today's date has no window to be told about.
  String? _caption(BuildContext context) {
    final l10n = context.l10n;
    if (policy.isBackDated(date)) return l10n.productionRecordingPastDate;
    if (!policy.canBackDate || policy.maxBackDateDays <= 0) {
      return policy.unlimitedBackDate ? null : l10n.productionBackDateTodayOnly;
    }
    if (policy.unlimitedBackDate) return null;
    return l10n.productionBackDateWindow(policy.maxBackDateDays);
  }

  /// The oldest selectable day: the policy window, narrowed by [earliest].
  DateTime get _firstDate {
    final windowStart = policy.earliestPostable();
    final floor = earliest;
    if (floor == null) return windowStart;
    final clamped = floor.isAfter(windowStart) ? floor : windowStart;
    // A floor later than today would invert the range and assert inside
    // showDatePicker; today always stays selectable.
    final today = policy.today();
    return clamped.isAfter(today) ? today : clamped;
  }

  Future<void> _pick(BuildContext context) async {
    // The server's today, not the device's: the gate is evaluated against the
    // server clock, so a tablet a day fast would otherwise be offered as its
    // last selectable day a date the server calls the future.
    final today = policy.today();
    final first = _firstDate;
    // Clamped on the DAY, then given its clock component back: comparing a
    // dated-and-timed value against midnight would read today 14:30 as "after
    // today" and silently reset the time on every re-open.
    final day = DateTime(date.year, date.month, date.day);
    var initial = day.isAfter(today) ? today : day;
    if (initial.isBefore(first)) initial = first;
    initial = DateTime(
      initial.year,
      initial.month,
      initial.day,
      date.hour,
      date.minute,
    );

    final picked = await pickPostingDateTime(
      context,
      initial: initial,
      firstDate: first,
      lastDate: today,
    );
    if (picked != null) onChanged(picked);
  }

  static String _format(DateTime value) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)}';
  }
}
