import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../journey/presentation/journey_format.dart';
import '../../../leads/presentation/leads_theme.dart';
import '../../../leads/state/my_location_notifier.dart';
import '../../data/models/visit_plan.dart';
import '../../state/visit_plan_notifier.dart';
import '../visit_navigation.dart';
import '../widgets/check_in_sheet.dart';
import '../widgets/route_engine_badge.dart';
import '../widgets/route_map.dart';

/// One field day, as the rep drives it.
///
/// The screen is built around the fact that it is used standing on a pavement
/// with one hand: the next door is always the primary action, navigation and
/// check-in are one tap each, and nothing important is hidden behind a menu.
/// Reordering exists but is deliberately secondary — a rep who drags a stop
/// has overruled the optimiser, and the app takes that instruction literally
/// rather than quietly re-solving.
class VisitPlanScreen extends ConsumerWidget {
  const VisitPlanScreen({super.key, required this.planName});

  final String planName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(visitPlanProvider(planName));
    final notifier = ref.read(visitPlanProvider(planName).notifier);
    final plan = state.plan;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          plan == null || plan.title.trim().isEmpty
              ? l10n.visitRouteTitle
              : plan.title,
        ),
        actions: [
          const RouteEngineBadge(),
          if (plan != null && plan.canEdit)
            PopupMenuButton<String>(
              onSelected: (value) => _onMenu(context, ref, notifier, value),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'optimize',
                  child: Text(l10n.visitOptimise),
                ),
                PopupMenuItem(
                  value: 'optimize_here',
                  child: Text(l10n.visitOptimiseFromHere),
                ),
                PopupMenuItem(
                  value: 'navigate_all',
                  child: Text(l10n.visitNavigateWholeRoute),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(l10n.visitDeleteRoute),
                ),
              ],
            ),
        ],
      ),
      body: plan == null
          ? Center(
              child: state.error != null
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        context.userErrorMessage(state.error),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const CircularProgressIndicator(),
            )
          : _PlanBody(plan: plan, busy: state.busy, error: state.error),
      bottomNavigationBar: plan == null || plan.nextStop == null
          ? null
          : _NextStopBar(plan: plan, planName: planName),
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    VisitPlanNotifier notifier,
    String action,
  ) async {
    final l10n = context.l10n;
    switch (action) {
      case 'optimize':
        await notifier.optimize();
      case 'optimize_here':
        // A live fix, not the plan's saved start: "re-plan from where I am
        // now" is the mid-morning question, and where the rep is standing at
        // 11am is not where they set off from.
        await ref.read(myLocationProvider.notifier).locate();
        final position = ref.read(myLocationProvider).position;
        if (position == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.visitLocationUnavailable)),
            );
          }
          return;
        }
        await notifier.optimize(
          startLatitude: position.latitude,
          startLongitude: position.longitude,
        );
      case 'navigate_all':
        final plan = ref.read(visitPlanProvider(planName)).plan;
        if (plan == null) return;
        final handed = await VisitNavigation.navigateWholeRoute(plan);
        final routable = plan.stops
            .where((s) => s.hasLocation && s.status != 'Cancelled')
            .length;
        if (context.mounted && handed > 0 && handed < routable) {
          // Never let a rep discover half a route in the car. Google's URL
          // caps the waypoints, so say what was handed over.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.visitRouteTruncated(handed, routable))),
          );
        }
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.visitDeleteRoute),
            content: Text(l10n.visitDeleteRouteConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.commonDelete),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        final removed = await notifier.deletePlan();
        if (removed && context.mounted) Navigator.of(context).pop();
    }
  }
}

class _PlanBody extends ConsumerWidget {
  const _PlanBody({required this.plan, required this.busy, this.error});

  final VisitPlan plan;
  final bool busy;
  final String? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(visitPlanProvider(plan.name).notifier);
    return Column(
      children: [
        if (busy) const LinearProgressIndicator(minHeight: 2),
        if (error != null)
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.errorContainer,
            padding: const EdgeInsets.all(12),
            child: Text(context.userErrorMessage(error!),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        RouteMap(plan: plan),
        _TotalsBar(plan: plan),
        const Divider(height: 1),
        Expanded(
          child: plan.stops.isEmpty
              ? Center(child: Text(context.l10n.visitNoStops))
              : ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: plan.stops.length,
                  buildDefaultDragHandles: plan.canEdit,
                  onReorder: notifier.moveStop,
                  itemBuilder: (context, index) {
                    final stop = plan.stops[index];
                    return _StopTile(
                      key: ValueKey(stop.name),
                      plan: plan,
                      stop: stop,
                      position: index + 1,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TotalsBar extends StatelessWidget {
  const _TotalsBar({required this.plan});

  final VisitPlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Metric(
                icon: Icons.place_outlined,
                label: l10n.visitStopsCount(plan.totalStops),
              ),
              _Metric(
                icon: Icons.straighten,
                label: l10n.visitDistanceKm(
                    plan.totalDistanceKm.toStringAsFixed(1)),
              ),
              _Metric(
                icon: Icons.directions_car_outlined,
                label: l10n.visitDurationMinutes(plan.totalDriveMinutes),
              ),
              _Metric(
                icon: Icons.schedule,
                label: l10n.visitDayTotal(
                    _hours(plan.totalDurationMinutes)),
              ),
            ],
          ),
          if (plan.stops.isNotEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: plan.progress,
                minHeight: 5,
                backgroundColor: theme.dividerColor,
                color: JourneyFormat.doneGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// `4h 20m` rather than `260 min`: a day's length is read in hours, and a
  /// three-digit minute count makes a rep do arithmetic on a pavement.
  static String _hours(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Theme.of(context).hintColor),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _StopTile extends ConsumerWidget {
  const _StopTile({
    super.key,
    required this.plan,
    required this.stop,
    required this.position,
  });

  final VisitPlan plan;
  final VisitStop stop;
  final int position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final notifier = ref.read(visitPlanProvider(plan.name).notifier);
    final resolved = stop.isResolved;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: _PositionBadge(position: position, status: stop.status),
        title: Text(
          stop.displayTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            decoration: stop.status == 'Cancelled'
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (stop.plannedTime != null)
                    Text(
                      _time(stop.plannedTime!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: LeadsTheme.sahelBlue,
                      ),
                    ),
                  if (stop.legKm > 0)
                    Text(
                      l10n.visitLeg(stop.legKm.toStringAsFixed(1),
                          stop.legMinutes),
                      style: theme.textTheme.bodySmall,
                    ),
                  if (stop.area.isNotEmpty)
                    Text(stop.area, style: theme.textTheme.bodySmall),
                  if (stop.locked)
                    Icon(Icons.push_pin, size: 13, color: theme.hintColor),
                ],
              ),
              if (stop.outcome.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    stop.outcome,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (stop.canCall)
              IconButton(
                tooltip: l10n.visitCall,
                icon: const Icon(Icons.phone_outlined, size: 20),
                onPressed: () => VisitNavigation.call(stop.phone),
              ),
            IconButton(
              tooltip: l10n.visitNavigate,
              icon: const Icon(Icons.navigation_outlined, size: 20),
              onPressed: stop.hasLocation
                  ? () => VisitNavigation.navigateToStop(stop)
                  : null,
            ),
            if (plan.canEdit)
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'check_in':
                      await showCheckInSheet(context, ref, plan.name, stop);
                    case 'skip':
                      await notifier.checkIn(
                          stopName: stop.name, status: 'Skipped');
                    case 'reopen':
                      await notifier.checkIn(
                          stopName: stop.name, status: 'Planned');
                    case 'pin':
                      await notifier.setLocked(stop.name, !stop.locked);
                    case 'remove':
                      await notifier.removeStop(stop.name);
                  }
                },
                itemBuilder: (context) => [
                  if (!resolved)
                    PopupMenuItem(
                        value: 'check_in', child: Text(l10n.visitCheckIn)),
                  if (!resolved)
                    PopupMenuItem(value: 'skip', child: Text(l10n.visitSkip)),
                  if (resolved)
                    PopupMenuItem(
                        value: 'reopen', child: Text(l10n.visitReopen)),
                  PopupMenuItem(
                    value: 'pin',
                    child:
                        Text(stop.locked ? l10n.visitUnpin : l10n.visitPin),
                  ),
                  PopupMenuItem(
                      value: 'remove', child: Text(l10n.visitRemoveStop)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// `09:30` from the backend's `HH:MM:SS`.
  static String _time(String raw) =>
      raw.length >= 5 ? raw.substring(0, 5) : raw;
}

class _PositionBadge extends StatelessWidget {
  const _PositionBadge({required this.position, required this.status});

  final int position;
  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      'Visited' => (JourneyFormat.doneGreen, Icons.check),
      'Skipped' => (Theme.of(context).disabledColor, Icons.remove),
      'Cancelled' => (Theme.of(context).disabledColor, Icons.close),
      _ => (LeadsTheme.sahelBlue, null),
    };
    return CircleAvatar(
      radius: 15,
      backgroundColor: color,
      child: icon != null
          ? Icon(icon, size: 16, color: Colors.white)
          : Text(
              '$position',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

/// The primary action, pinned to the bottom: get to the next door.
///
/// This is what the screen is FOR between stops. Everything else on it is
/// planning; this is the doing.
class _NextStopBar extends ConsumerWidget {
  const _NextStopBar({required this.plan, required this.planName});

  final VisitPlan plan;
  final String planName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stop = plan.nextStop;
    if (stop == null) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.visitNextStop,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    stop.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => showCheckInSheet(context, ref, planName, stop),
              icon: const Icon(Icons.how_to_reg, size: 18),
              label: Text(l10n.visitCheckIn),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: stop.hasLocation
                  ? () => VisitNavigation.navigateToStop(stop)
                  : null,
              icon: const Icon(Icons.navigation, size: 18),
              label: Text(l10n.visitGo),
            ),
          ],
        ),
      ),
    );
  }
}
