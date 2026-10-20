import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../models/roster_models.dart';
import '../../state/roster_filter.dart';
import '../../state/roster_providers.dart';

/// Stable keys so the tests can drive the filter.
const Key rosterFilterButtonKey = ValueKey<String>('roster-filter-button');
const Key rosterFilterApplyKey = ValueKey<String>('roster-filter-apply');
const Key rosterFilterSearchKey = ValueKey<String>('roster-filter-search');
const Key rosterFilterBranchesAllKey = ValueKey<String>(
  'roster-filter-branches-all',
);
const Key rosterFilterBranchesClearKey = ValueKey<String>(
  'roster-filter-branches-clear',
);
const Key rosterFilterPeopleAllKey = ValueKey<String>(
  'roster-filter-people-all',
);
const Key rosterFilterPeopleClearKey = ValueKey<String>(
  'roster-filter-people-clear',
);

Key rosterFilterBranchKey(String location) =>
    ValueKey<String>('roster-filter-branch-$location');

Key rosterFilterPersonKey(String employee) =>
    ValueKey<String>('roster-filter-person-$employee');

/// Beyond this many people the People section gets a search box.
const int rosterFilterSearchThreshold = 8;

/// The button's words: "All", "Dokki, Factory", "Alice", "3 people + 1 branch".
///
/// Up to two branches (or two people) are named; more are counted.
String rosterFilterSummary(
  AppLocalizations l10n,
  RosterFilter filter, {
  Map<String, String> names = const {},
}) {
  if (filter.isEmpty) return l10n.rosterFilterAll;
  final branches = filter.locations.toList()..sort();
  final people = filter.employees.map((id) => names[id] ?? id).toList()..sort();
  if (people.isEmpty) {
    return branches.length <= 2
        ? branches.join(', ')
        : l10n.rosterFilterBranchCount(branches.length);
  }
  if (branches.isEmpty) {
    return people.length <= 2
        ? people.join(', ')
        : l10n.rosterFilterPeopleCount(people.length);
  }
  return l10n.rosterFilterPeopleAndBranches(
    l10n.rosterFilterPeopleCount(people.length),
    l10n.rosterFilterBranchCount(branches.length),
  );
}

/// The control-bar button: the current filter in words; opens the sheet.
class RosterFilterButton extends ConsumerWidget {
  const RosterFilterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.watch(rosterEffectiveFilterProvider);
    final month = ref.watch(rosterMonthDataProvider).valueOrNull;
    final names = {
      for (final e in month?.employees ?? const <RosterEmployee>[])
        e.employee: e.employeeName,
    };
    final active = !filter.isEmpty;
    return Tooltip(
      message: l10n.rosterFilterTooltip,
      child: ActionChip(
        key: rosterFilterButtonKey,
        avatar: Icon(
          active ? Icons.filter_alt : Icons.filter_alt_outlined,
          size: 18,
        ),
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(
            rosterFilterSummary(l10n, filter, names: names),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        visualDensity: VisualDensity.compact,
        side: active
            ? BorderSide(color: Theme.of(context).colorScheme.primary)
            : null,
        onPressed: () => showRosterFilterSheet(context, ref),
      ),
    );
  }
}

/// Open the filter sheet; on Apply, show and save the new filter.
Future<void> showRosterFilterSheet(BuildContext context, WidgetRef ref) async {
  final bootstrap = ref.read(rosterBootstrapProvider).valueOrNull;
  final month = ref.read(rosterMonthDataProvider).valueOrNull;
  final branches = rosterKnownLocations(
    bootstrap: bootstrap,
    month: bootstrap == null || bootstrap.shiftLocations.isEmpty ? month : null,
  ).toList()..sort();
  final people = [...?month?.employees]
    ..sort(
      (a, b) =>
          a.employeeName.toLowerCase().compareTo(b.employeeName.toLowerCase()),
    );
  final picked = await showModalBottomSheet<RosterFilter>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => RosterFilterSheet(
      initial: ref.read(rosterEffectiveFilterProvider),
      branches: branches,
      people: people,
    ),
  );
  if (picked == null) return;
  await ref.read(rosterFilterProvider.notifier).apply(picked);
}

/// Branches and people, ticked independently; Apply returns the choice.
///
/// Nothing ticked means everyone. A person shows when ticked by name OR when
/// they belong to a ticked branch (see `rosterEmployeeBelongsTo`).
class RosterFilterSheet extends StatefulWidget {
  const RosterFilterSheet({
    super.key,
    required this.initial,
    required this.branches,
    required this.people,
  });

  final RosterFilter initial;
  final List<String> branches;
  final List<RosterEmployee> people;

  @override
  State<RosterFilterSheet> createState() => _RosterFilterSheetState();
}

class _RosterFilterSheetState extends State<RosterFilterSheet> {
  late final Set<String> _locations = {...widget.initial.locations};
  late final Set<String> _employees = {...widget.initial.employees};
  String _query = '';

  List<RosterEmployee> get _matchingPeople {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.people;
    return widget.people
        .where(
          (e) =>
              e.employeeName.toLowerCase().contains(q) ||
              e.employee.toLowerCase().contains(q) ||
              (e.designation ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final matching = _matchingPeople;
    final showSearch = widget.people.length > rosterFilterSearchThreshold;

    Widget sectionHeader(
      String title, {
      required Key allKey,
      required Key clearKey,
      required VoidCallback onAll,
      required VoidCallback onClear,
    }) => Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            key: allKey,
            onPressed: onAll,
            child: Text(l10n.rosterFilterSelectAll),
          ),
          TextButton(
            key: clearKey,
            onPressed: onClear,
            child: Text(l10n.commonClear),
          ),
        ],
      ),
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (context, controller) => SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.rosterFilterTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.rosterFilterHelp,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                children: [
                  sectionHeader(
                    l10n.rosterFilterBranches,
                    allKey: rosterFilterBranchesAllKey,
                    clearKey: rosterFilterBranchesClearKey,
                    onAll: () => setState(() {
                      _locations.addAll(widget.branches);
                    }),
                    onClear: () => setState(_locations.clear),
                  ),
                  for (final branch in widget.branches)
                    CheckboxListTile(
                      key: rosterFilterBranchKey(branch),
                      dense: true,
                      value: _locations.contains(branch),
                      title: Text(branch),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (on) => setState(() {
                        if (on ?? false) {
                          _locations.add(branch);
                        } else {
                          _locations.remove(branch);
                        }
                      }),
                    ),
                  const Divider(height: 24),
                  sectionHeader(
                    l10n.rosterFilterPeople,
                    allKey: rosterFilterPeopleAllKey,
                    clearKey: rosterFilterPeopleClearKey,
                    // "Select all" takes the people the search shows.
                    onAll: () => setState(() {
                      _employees.addAll(matching.map((e) => e.employee));
                    }),
                    onClear: () => setState(_employees.clear),
                  ),
                  if (showSearch)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: TextField(
                        key: rosterFilterSearchKey,
                        decoration: InputDecoration(
                          isDense: true,
                          prefixIcon: const Icon(Icons.search),
                          hintText: l10n.rosterFilterSearchHint,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                    ),
                  if (matching.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.rosterFilterNoPeople,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  for (final person in matching)
                    CheckboxListTile(
                      key: rosterFilterPersonKey(person.employee),
                      dense: true,
                      value: _employees.contains(person.employee),
                      title: Text(person.employeeName),
                      subtitle: (person.designation ?? '').isEmpty
                          ? null
                          : Text(person.designation!),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (on) => setState(() {
                        if (on ?? false) {
                          _employees.add(person.employee);
                        } else {
                          _employees.remove(person.employee);
                        }
                      }),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rosterFilterSummary(
                        l10n,
                        RosterFilter(
                          locations: _locations,
                          employees: _employees,
                        ),
                        names: {
                          for (final e in widget.people)
                            e.employee: e.employeeName,
                        },
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.commonCancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: rosterFilterApplyKey,
                    onPressed: () => Navigator.of(context).pop(
                      RosterFilter(
                        locations: {..._locations},
                        employees: {..._employees},
                      ),
                    ),
                    child: Text(l10n.rosterFilterApply),
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
