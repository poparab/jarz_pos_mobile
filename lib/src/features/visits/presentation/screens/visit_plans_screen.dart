import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../journey/presentation/journey_format.dart';
import '../../../leads/presentation/leads_theme.dart';
import '../../data/models/visit_plan.dart';
import '../../state/visit_plans_notifier.dart';
import '../widgets/route_engine_badge.dart';

/// A month of field days.
///
/// The action calendar answers "what do I owe and when"; this answers the
/// other half — "where am I actually going, and in what order". They are
/// deliberately separate screens over the same month: a promise and a route
/// are different objects, and a rep planning Saturday is not doing the same
/// job as a rep working through today's follow-ups.
class VisitPlansScreen extends ConsumerStatefulWidget {
  const VisitPlansScreen({super.key});

  @override
  ConsumerState<VisitPlansScreen> createState() => _VisitPlansScreenState();
}

class _VisitPlansScreenState extends ConsumerState<VisitPlansScreen> {
  /// The day whose routes are listed below the grid. Dropped when the month
  /// changes — a selection from a month the rep paged away from would show an
  /// empty list under a grid full of markers.
  DateTime? _selected;

  DateTime _effectiveSelection(VisitPlansQuery query) {
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

  Future<void> _refresh() async {
    ref.invalidate(visitPlansProvider);
    try {
      await ref.read(visitPlansProvider.future);
    } catch (_) {
      // The provider renders its own error; a failed background refresh keeps
      // the last good month on screen.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = ref.watch(visitPlansQueryProvider);
    final plans = ref.watch(visitPlansProvider);
    final byDay = ref.watch(visitPlansByDayProvider);
    final selected = _effectiveSelection(query);
    final selectedKey = JourneyFormat.iso(selected);
    final dayPlans = byDay[selectedKey] ?? const <VisitPlan>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.visitPlannerTitle),
        actions: [
          const RouteEngineBadge(),
          IconButton(
            tooltip: query.scope == 'all'
                ? l10n.visitScopeAll
                : l10n.visitScopeMine,
            icon: Icon(query.scope == 'all' ? Icons.groups : Icons.person),
            onPressed: () => ref
                .read(visitPlansQueryProvider.notifier)
                .setScope(query.scope == 'all' ? 'mine' : 'all'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.b2bVisitBuilder),
        icon: const Icon(Icons.auto_awesome),
        label: Text(l10n.visitPlanDay),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            _MonthHeader(query: query),
            _MonthGrid(
              query: query,
              byDay: byDay,
              selected: selected,
              onSelect: (day) => setState(() => _selected = day),
            ),
            const Divider(height: 1),
            if (plans.isLoading && plans.valueOrNull == null)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (plans.hasError && plans.valueOrNull == null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.visitPlansLoadFailed,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  DateFormat('EEEE, d MMMM', l10n.localeName).format(selected),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (dayPlans.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 32),
                  child: Text(
                    l10n.visitNoRoutesOnDay,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).hintColor),
                  ),
                )
              else
                ...dayPlans.map(
                  (plan) => _PlanTile(
                    plan: plan,
                    onTap: () => context.push(
                      '${AppRoutes.b2bVisitPlan}/${Uri.encodeComponent(plan.name)}',
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MonthHeader extends ConsumerWidget {
  const _MonthHeader({required this.query});

  final VisitPlansQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(visitPlansQueryProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: notifier.previousMonth,
          ),
          Expanded(
            child: Center(
              child: Text(
                DateFormat('MMMM yyyy', context.l10n.localeName)
                    .format(query.month),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: notifier.nextMonth,
          ),
        ],
      ),
    );
  }
}

/// A hand-built month grid.
///
/// Hand-built rather than a calendar package for the same reason the action
/// calendar is: the grid has to show a domain marker (how many stops, whether
/// the day is done), and bending a general-purpose widget to that costs more
/// than seven columns of arithmetic.
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.query,
    required this.byDay,
    required this.selected,
    required this.onSelect,
  });

  final VisitPlansQuery query;
  final Map<String, List<VisitPlan>> byDay;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = query.firstDay;
    final daysInMonth = query.lastDay.day;
    // Monday-first, matching the rest of the app's calendars.
    final leading = (first.weekday - DateTime.monday) % 7;
    final cells = leading + daysInMonth;
    final rows = (cells / 7).ceil();
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            children: List.generate(7, (index) {
              final day = DateTime(2024, 1, 1).add(Duration(days: index));
              return Expanded(
                child: Center(
                  child: Text(
                    DateFormat('EEE', context.l10n.localeName)
                        .format(day)
                        .substring(0, 1),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          for (var row = 0; row < rows; row++)
            Row(
              children: List.generate(7, (column) {
                final dayNumber = row * 7 + column - leading + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 46));
                }
                final date =
                    DateTime(query.month.year, query.month.month, dayNumber);
                final plans = byDay[JourneyFormat.iso(date)] ?? const [];
                final isSelected = date.year == selected.year &&
                    date.month == selected.month &&
                    date.day == selected.day;
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
                return Expanded(
                  child: _DayCell(
                    date: date,
                    plans: plans,
                    isSelected: isSelected,
                    isToday: isToday,
                    onTap: () => onSelect(date),
                  ),
                );
              }),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.plans,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final List<VisitPlan> plans;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stops = plans.fold<int>(0, (sum, plan) => sum + plan.totalStops);
    final allDone = plans.isNotEmpty && plans.every((p) => p.isDone);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 46,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? scheme.primaryContainer : null,
          border: isToday
              ? Border.all(color: scheme.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight:
                        isSelected || isToday ? FontWeight.bold : null,
                  ),
            ),
            const SizedBox(height: 2),
            if (plans.isEmpty)
              const SizedBox(height: 12)
            else
              // The count, not a dot: "6" tells a rep the shape of that day at
              // a glance, which is the whole reason to look at a month.
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: allDone
                      ? JourneyFormat.doneGreen
                      : LeadsTheme.sahelBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$stops',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.plan, required this.onTap});

  final VisitPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: onTap,
        title: Text(
          plan.title.trim().isEmpty
              ? l10n.visitRouteFallbackTitle(plan.totalStops)
              : plan.title,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 12,
            runSpacing: 2,
            children: [
              Text(l10n.visitStopsCount(plan.totalStops)),
              Text(l10n.visitDistanceKm(
                  plan.totalDistanceKm.toStringAsFixed(1))),
              Text(l10n.visitDurationMinutes(plan.totalDurationMinutes)),
              if (plan.repName.isNotEmpty) Text(plan.repName),
            ],
          ),
        ),
        trailing: _StatusChip(status: plan.status),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Completed' => JourneyFormat.doneGreen,
      'In Progress' => LeadsTheme.sahelBlue,
      'Cancelled' => Theme.of(context).disabledColor,
      _ => Theme.of(context).hintColor,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
