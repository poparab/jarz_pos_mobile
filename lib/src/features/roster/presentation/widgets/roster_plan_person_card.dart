import 'package:flutter/material.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/roster_models.dart';
import '../../models/roster_plan_models.dart';
import '../../state/roster_plan_draft.dart';
import '../roster_formats.dart';
import 'roster_shift_picker.dart';

Key rosterPlanShiftChipKey(String employee, String shift) =>
    ValueKey<String>('roster-plan-shift-$employee-$shift');
Key rosterPlanOffChipKey(String employee, String weekday) =>
    ValueKey<String>('roster-plan-off-$employee-$weekday');
Key rosterPlanCoverPickerKey(String employee, String weekday) =>
    ValueKey<String>('roster-plan-cover-$employee-$weekday');
Key rosterPlanFridaySwitchKey(String employee) =>
    ValueKey<String>('roster-plan-friday-$employee');

/// Weekday chips speak the screen's language; the value sent stays English.
String rosterPlanWeekdayLabel(AppLocalizations l10n, String weekday) {
  switch (weekday) {
    case 'Saturday':
      return l10n.rosterPlanWeekdaySaturday;
    case 'Sunday':
      return l10n.rosterPlanWeekdaySunday;
    case 'Monday':
      return l10n.rosterPlanWeekdayMonday;
    case 'Tuesday':
      return l10n.rosterPlanWeekdayTuesday;
    case 'Wednesday':
      return l10n.rosterPlanWeekdayWednesday;
    case 'Thursday':
      return l10n.rosterPlanWeekdayThursday;
    case 'Friday':
      return l10n.rosterPlanWeekdayFriday;
    default:
      return weekday;
  }
}

/// "Their week" — one person's card: shift, branch, day off, and who covers
/// each day off.
///
/// One decision per row, every option a big chip. Nothing is coloured by
/// shift: colour on the roster means "needs fixing" and nothing else, so the
/// only red here is a missing answer.
///
/// The card edits [row] in place and calls [onChanged]; the wizard owns the
/// drafts and rebuilds.
class RosterPlanPersonCard extends StatelessWidget {
  const RosterPlanPersonCard({
    super.key,
    required this.person,
    required this.row,
    required this.people,
    required this.plannedRows,
    required this.catalog,
    required this.locations,
    required this.onChanged,
  });

  final RosterPlanDefaultsEmployee person;
  final RosterPlanRowDraft row;

  /// Everyone who could cover, in the order the server sent them.
  final List<RosterPlanDefaultsEmployee> people;

  /// The drafts being planned, so a coverer's cover shift can follow the
  /// shift they are being planned onto rather than their old one.
  final Map<String, RosterPlanRowDraft> plannedRows;
  final List<RosterShift> catalog;
  final List<String> locations;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final variant = rosterFridayVariantFor(row.shiftType, catalog);
    final shifts = rosterPlanShiftsFor(
      person,
      catalog,
      currentShift: row.shiftType,
      selected: row.shiftType,
    );
    final everyWeekdayShift = rosterPlanShiftsFor(null, catalog);
    final narrowed = shifts.length < everyWeekdayShift.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              person.displayName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!person.hasStandingRota)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  l10n.rosterPlanNoUsualWeek,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            _Label(l10n.rosterPlanShift),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final shift in shifts)
                  ChoiceChip(
                    key: rosterPlanShiftChipKey(
                      person.employee,
                      shift.shiftType,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    label: _ShiftLabel(shift: shift),
                    selected: row.shiftType == shift.shiftType,
                    onSelected: (_) {
                      row.shiftType = shift.shiftType;
                      onChanged();
                    },
                  ),
                if (narrowed)
                  ActionChip(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    avatar: const Icon(Icons.unfold_more, size: 18),
                    label: Text(l10n.rosterPlanOtherShifts),
                    onPressed: () async {
                      final picked = await showRosterShiftPickerSheet(
                        context,
                        title: l10n.rosterPlanPickShift,
                        catalog: everyWeekdayShift,
                        dates: rosterPlanAWeekday,
                      );
                      if (picked == null) return;
                      row.shiftType = picked.shiftType;
                      onChanged();
                    },
                  ),
              ],
            ),
            if ((row.shiftType ?? '').isEmpty)
              _Problem(l10n.rosterPlanNeedsShift),
            if (locations.length > 1) ...[
              _Label(l10n.rosterPlanBranch),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final location in locations)
                    ChoiceChip(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      label: Text(location),
                      selected: row.shiftLocation == location,
                      onSelected: (_) {
                        row.shiftLocation = location;
                        onChanged();
                      },
                    ),
                ],
              ),
            ],
            _Label(l10n.rosterPlanDaysOff),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final weekday in rosterPlanWeekdays)
                  FilterChip(
                    key: rosterPlanOffChipKey(person.employee, weekday),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 10,
                    ),
                    label: Text(rosterPlanWeekdayLabel(l10n, weekday)),
                    selected: row.offDays.contains(weekday),
                    onSelected: (_) {
                      row.toggleOffDay(weekday);
                      onChanged();
                    },
                  ),
              ],
            ),
            if (row.offDays.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.rosterPlanWorksEveryDay,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (variant != null && !row.offDays.contains('Friday'))
              SwitchListTile(
                key: rosterPlanFridaySwitchKey(person.employee),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.rosterPlanFridayVariant(variant)),
                value: row.useFridayVariant,
                onChanged: (value) {
                  row.useFridayVariant = value;
                  onChanged();
                },
              ),
            for (final weekday in rosterPlanWeekdays)
              if (row.offDays.contains(weekday))
                _CoverRow(
                  person: person,
                  row: row,
                  weekday: weekday,
                  people: people,
                  plannedRows: plannedRows,
                  catalog: catalog,
                  onChanged: onChanged,
                ),
          ],
        ),
      ),
    );
  }
}

class _CoverRow extends StatelessWidget {
  const _CoverRow({
    required this.person,
    required this.row,
    required this.weekday,
    required this.people,
    required this.plannedRows,
    required this.catalog,
    required this.onChanged,
  });

  final RosterPlanDefaultsEmployee person;
  final RosterPlanRowDraft row;
  final String weekday;
  final List<RosterPlanDefaultsEmployee> people;
  final Map<String, RosterPlanRowDraft> plannedRows;
  final List<RosterShift> catalog;
  final VoidCallback onChanged;

  RosterPlanDefaultsEmployee? _find(String? employee) {
    if (employee == null) return null;
    for (final p in people) {
      if (p.employee == employee) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cover = row.covers[weekday];
    final coveredBy = cover?.coveredBy;
    final coverer = _find(coveredBy);
    final isFriday = weekday == 'Friday';
    final candidates = [
      for (final p in people)
        if (p.employee != person.employee) p,
    ];

    final coverShifts = coverer == null
        ? const <RosterShift>[]
        : rosterPlanShiftsFor(
            coverer,
            catalog,
            currentShift: plannedRows[coverer.employee]?.shiftType,
            selected: cover?.coverShiftType,
            friday: isFriday,
          );
    final coverShift = cover?.coverShiftType;
    final coverShiftValue = coverShifts.any((s) => s.shiftType == coverShift)
        ? coverShift
        : null;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.rosterPlanCoverQuestion(rosterPlanWeekdayLabel(l10n, weekday)),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          KeyedSubtree(
            key: rosterPlanCoverPickerKey(person.employee, weekday),
            child: DropdownButtonFormField<String?>(
              // Keyed on the value too, so a change made elsewhere ("Same for
              // everyone") lands in the field instead of a stale initial value.
              key: ValueKey<String>(
                'roster-plan-cover-value-${person.employee}-$weekday-'
                '${coverer?.employee ?? ''}',
              ),
              initialValue: coverer == null ? null : coveredBy,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: <DropdownMenuItem<String?>>[
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.rosterPlanNobodyCovers),
                ),
                for (final p in candidates)
                  DropdownMenuItem<String?>(
                    value: p.employee,
                    child: Text(p.displayName, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (value) {
                if (value == null) {
                  row.covers.remove(weekday);
                } else {
                  row.covers[weekday] = RosterPlanCoverDraft(
                    coveredBy: value,
                    coverShiftType: rosterPlanDefaultCoverShift(
                      coverer: _find(value),
                      catalog: catalog,
                      covererPlannedShift: plannedRows[value]?.shiftType,
                      absentShift: row.shiftType,
                      friday: isFriday,
                    ),
                  );
                }
                onChanged();
              },
            ),
          ),
          if (coverer != null) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              // Keyed on the coverer so the automatic fill lands in the field
              // instead of being ignored as a stale initial value.
              key: ValueKey<String>(
                'roster-plan-cover-shift-${person.employee}-$weekday-'
                '${coverer.employee}',
              ),
              initialValue: coverShiftValue,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.rosterPlanCoverShift,
                border: const OutlineInputBorder(),
                errorText: coverShiftValue == null
                    ? l10n.rosterPlanNeedsCoverShift
                    : null,
              ),
              items: [
                for (final shift in coverShifts)
                  DropdownMenuItem<String>(
                    value: shift.shiftType,
                    child: Text(
                      shift.shiftType,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) {
                cover?.coverShiftType = value;
                onChanged();
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ShiftLabel extends StatelessWidget {
  const _ShiftLabel({required this.shift});

  final RosterShift shift;

  @override
  Widget build(BuildContext context) {
    final time = rosterShiftTimeText(shift, context.l10n, withEnd: true);
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(shift.shiftType, style: theme.textTheme.bodyLarge),
        if (time != null)
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
