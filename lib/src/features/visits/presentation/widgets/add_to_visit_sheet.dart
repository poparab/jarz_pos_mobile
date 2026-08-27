import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../journey/presentation/journey_format.dart';
import '../../../leads/presentation/leads_theme.dart';
import '../../data/models/visit_plan.dart';
import '../../data/visits_repository.dart';
import '../../state/visit_plans_notifier.dart';

/// Put a door on a day, from wherever the rep already is.
///
/// The same sheet serves the B2B kanban card, the leads list, the map callout
/// and the lead page, because the decision is identical on all four: *which
/// door*, and *which day*. Duplicating that per screen is how the four slowly
/// stop agreeing about what a stop is.
///
/// Two things it deliberately does NOT do:
///
/// * It does not assume one door. A brand with six branches is six possible
///   stops in six different areas; picking silently would send a rep to the
///   wrong one. Multi-select, because "add all three Zamalek branches" is a
///   real thing a rep wants.
/// * It does not require an existing plan. "New route on Saturday" is one tap,
///   because the common case is a rep looking at a lead and deciding *now*
///   that it belongs on a day that does not exist yet.
///
/// Returns the plan name it added to, or null if the rep backed out.
Future<String?> showAddToVisitSheet(
  BuildContext context, {
  required String referenceDoctype,
  required String referenceName,
  String? title,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _AddToVisitSheet(
        referenceDoctype: referenceDoctype,
        referenceName: referenceName,
        recordTitle: title,
      ),
    ),
  );
}

/// The doors of one record. Family-keyed so opening the same lead twice does
/// not refetch, and autoDispose so a long session does not accumulate them.
final recordVisitTargetsProvider = FutureProvider.autoDispose
    .family<List<VisitTarget>, ({String doctype, String name})>((ref, arg) {
  return ref.watch(visitsRepositoryProvider).getRecordTargets(
        referenceDoctype: arg.doctype,
        referenceName: arg.name,
      );
});

/// Days a stop can be added to. Not autoDispose-family: one list, reused by
/// every sheet, invalidated whenever a plan changes.
final addableVisitPlansProvider =
    FutureProvider.autoDispose<List<VisitPlan>>((ref) {
  return ref.watch(visitsRepositoryProvider).getAddablePlans();
});

class _AddToVisitSheet extends ConsumerStatefulWidget {
  const _AddToVisitSheet({
    required this.referenceDoctype,
    required this.referenceName,
    this.recordTitle,
  });

  final String referenceDoctype;
  final String referenceName;
  final String? recordTitle;

  @override
  ConsumerState<_AddToVisitSheet> createState() => _AddToVisitSheetState();
}

class _AddToVisitSheetState extends ConsumerState<_AddToVisitSheet> {
  final Set<String> _chosenDoors = {};
  String? _chosenPlan;
  DateTime? _newPlanDate;
  bool _busy = false;
  String? _error;
  bool _seeded = false;

  ({String doctype, String name}) get _arg =>
      (doctype: widget.referenceDoctype, name: widget.referenceName);

  /// With exactly one door there is nothing to decide, so it starts ticked and
  /// the rep only chooses a day.
  void _seedSelection(List<VisitTarget> targets) {
    if (_seeded) return;
    _seeded = true;
    if (targets.length == 1) _chosenDoors.add(targets.single.key);
  }

  Future<void> _submit(List<VisitTarget> targets) async {
    final chosen =
        targets.where((t) => _chosenDoors.contains(t.key)).toList();
    if (chosen.isEmpty) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    final repo = ref.read(visitsRepositoryProvider);
    final payload = chosen.map((t) => t.toStopPayload()).toList();
    try {
      final String planName;
      if (_chosenPlan != null) {
        final plan = await repo.addStops(_chosenPlan!, payload);
        planName = plan.name;
      } else {
        final date = _newPlanDate ?? DateTime.now().add(const Duration(days: 1));
        final plan = await repo.createPlan(
          visitDate: JourneyFormat.iso(date),
          stops: payload,
          status: 'Planned',
        );
        planName = plan.name;
      }
      // Both the calendar and any other open sheet are now stale.
      ref.invalidate(visitPlansProvider);
      ref.invalidate(addableVisitPlansProvider);
      if (!mounted) return;
      Navigator.of(context).pop(planName);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        // Inline, never a SnackBar: this sheet covers the bottom of the
        // screen, which is exactly where a SnackBar renders.
        _error = _message(error);
      });
    }
  }

  String _message(Object error) {
    final text = error.toString();
    final match = RegExp(r'"message":\s*"([^"]+)"').firstMatch(text);
    if (match != null) return match.group(1)!.replaceAll(r'\n', ' ');
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final targetsAsync = ref.watch(recordVisitTargetsProvider(_arg));

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.route, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.visitAddToRoute,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            if ((widget.recordTitle ?? '').trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    widget.recordTitle!.trim(),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor),
                  ),
                ),
              ),
            const Divider(height: 1),
            Flexible(
              child: targetsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.visitTargetsLoadFailed,
                      textAlign: TextAlign.center),
                ),
                data: (targets) {
                  if (targets.isEmpty) return _NoDoors(l10n: l10n);
                  _seedSelection(targets);
                  return _Body(
                    targets: targets,
                    chosenDoors: _chosenDoors,
                    chosenPlan: _chosenPlan,
                    newPlanDate: _newPlanDate,
                    error: _error,
                    onToggleDoor: (key) => setState(() {
                      _chosenDoors.contains(key)
                          ? _chosenDoors.remove(key)
                          : _chosenDoors.add(key);
                    }),
                    onPickPlan: (name) => setState(() {
                      _chosenPlan = name;
                      _newPlanDate = null;
                    }),
                    onPickNewDate: (date) => setState(() {
                      _newPlanDate = date;
                      _chosenPlan = null;
                    }),
                  );
                },
              ),
            ),
            targetsAsync.maybeWhen(
              data: (targets) => targets.isEmpty
                  ? const SizedBox.shrink()
                  : _Footer(
                      busy: _busy,
                      enabled: _chosenDoors.isNotEmpty &&
                          (_chosenPlan != null || _newPlanDate != null),
                      count: _chosenDoors.length,
                      onSubmit: () => _submit(targets),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoDoors extends StatelessWidget {
  const _NoDoors({required this.l10n});

  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off_outlined,
              size: 40, color: Theme.of(context).hintColor),
          const SizedBox(height: 12),
          Text(
            l10n.visitNoDoorsToRoute,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.visitNoDoorsToRouteHint,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.targets,
    required this.chosenDoors,
    required this.chosenPlan,
    required this.newPlanDate,
    required this.error,
    required this.onToggleDoor,
    required this.onPickPlan,
    required this.onPickNewDate,
  });

  final List<VisitTarget> targets;
  final Set<String> chosenDoors;
  final String? chosenPlan;
  final DateTime? newPlanDate;
  final String? error;
  final ValueChanged<String> onToggleDoor;
  final ValueChanged<String> onPickPlan;
  final ValueChanged<DateTime> onPickNewDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final plansAsync = ref.watch(addableVisitPlansProvider);

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        // ── Which door ────────────────────────────────────────────────────
        if (targets.length > 1) ...[
          _SectionLabel(text: l10n.visitWhichDoor(targets.length)),
          for (final target in targets)
            CheckboxListTile(
              dense: true,
              value: chosenDoors.contains(target.key),
              onChanged: (_) => onToggleDoor(target.key),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                target.branchName.trim().isEmpty
                    ? target.displayTitle
                    : target.branchName,
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: target.area.trim().isEmpty
                  ? null
                  : Text(target.area, style: theme.textTheme.bodySmall),
            ),
          const Divider(height: 16),
        ],

        // ── Which day ─────────────────────────────────────────────────────
        _SectionLabel(text: l10n.visitWhichDay),
        plansAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(l10n.visitPlansLoadFailed,
                style: theme.textTheme.bodySmall),
          ),
          data: (plans) => Column(
            children: [
              for (final plan in plans)
                // A plain tile with a radio glyph rather than RadioListTile:
                // that widget's groupValue/onChanged pair is deprecated in
                // favour of a RadioGroup ancestor, and one selectable row does
                // not need an inherited controller.
                ListTile(
                  dense: true,
                  onTap: () => onPickPlan(plan.name),
                  leading: Icon(
                    chosenPlan == plan.name
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: chosenPlan == plan.name
                        ? theme.colorScheme.primary
                        : null,
                  ),
                  title: Text(
                    plan.title.trim().isEmpty
                        ? JourneyFormat.pretty(context, plan.visitDate)
                        : plan.title,
                    style: theme.textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    '${JourneyFormat.pretty(context, plan.visitDate)} · '
                    '${l10n.visitStopsCount(plan.totalStops)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              if (plans.isEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.visitNoUpcomingRoutes,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // "New route" is always available, and is the whole point when the rep
        // is looking at a lead and deciding now that it needs a day.
        ListTile(
          dense: true,
          leading: Icon(
            newPlanDate != null
                ? Icons.radio_button_checked
                : Icons.add_circle_outline,
            color: newPlanDate != null ? theme.colorScheme.primary : null,
          ),
          title: Text(
            newPlanDate == null
                ? l10n.visitNewRoute
                : l10n.visitNewRouteOn(
                    JourneyFormat.pretty(context, JourneyFormat.iso(newPlanDate!))),
            style: theme.textTheme.bodyMedium,
          ),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: newPlanDate ?? now.add(const Duration(days: 1)),
              firstDate: now.subtract(const Duration(days: 1)),
              lastDate: now.add(const Duration(days: 180)),
            );
            if (picked != null) onPickNewDate(picked);
          },
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(error!,
                style: TextStyle(color: theme.colorScheme.error)),
          ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: LeadsTheme.sahelBlue),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.busy,
    required this.enabled,
    required this.count,
    required this.onSubmit,
  });

  final bool busy;
  final bool enabled;
  final int count;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.visitSelectedCount(count),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          FilledButton.icon(
            onPressed: (busy || !enabled) ? null : onSubmit,
            icon: busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add, size: 18),
            label: Text(l10n.visitAddStop),
          ),
        ],
      ),
    );
  }
}

/// Show the sheet and, on success, offer a way straight to the route.
///
/// The confirmation matters: a rep who adds a door from the kanban has no
/// other feedback that anything happened, and being able to jump to the day
/// they just changed is the natural next thought.
Future<void> addToVisitAndConfirm(
  BuildContext context, {
  required String referenceDoctype,
  required String referenceName,
  String? title,
}) async {
  final planName = await showAddToVisitSheet(
    context,
    referenceDoctype: referenceDoctype,
    referenceName: referenceName,
    title: title,
  );
  if (planName == null || !context.mounted) return;
  final l10n = context.l10n;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.visitAddedToRoute),
      action: SnackBarAction(
        label: l10n.visitOpenRoute,
        onPressed: () => context.push(
          '${AppRoutes.b2bVisitPlan}/${Uri.encodeComponent(planName)}',
        ),
      ),
    ),
  );
}
