import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../journey/presentation/journey_format.dart';
import '../../../leads/presentation/leads_theme.dart';
import '../../data/models/visit_plan.dart';
import '../../state/visit_builder_notifier.dart';
import '../widgets/route_engine_badge.dart';
import '../widgets/route_preview_panel.dart';
import '../widgets/visit_filter_sheet.dart';

/// Build a day out of the catalog.
///
/// The screen is deliberately two paths onto one selection:
///
/// * **Plan my day** hands the problem to the server — take what is due
///   (overdue follow-ups, doors nobody has walked into for months) crossed
///   with what is good (fit score, pipeline stage), cluster it geographically,
///   order it, and trim it until it fits the working day. With ~2,900 doors in
///   the corpus this is the only path that scales; hand-picking nine of them
///   is not a plan, it is a lottery.
/// * **The list** is the same doors, ranked, for a rep who already knows where
///   they are going or wants to argue with the proposal.
///
/// Both feed one selection, so accepting a suggestion and then adding the shop
/// you promised to drop into is a single gesture rather than a mode switch.
class VisitBuilderScreen extends ConsumerWidget {
  const VisitBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(visitBuilderProvider);
    final notifier = ref.read(visitBuilderProvider.notifier);
    final targets = ref.watch(visitTargetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.visitBuildDay),
        actions: [
          const RouteEngineBadge(),
          // Badged rather than a bare funnel: a filter left on from a previous
          // session is the usual reason a rep thinks the catalog is empty.
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: l10n.visitFilters,
                icon: const Icon(Icons.tune),
                onPressed: () => showVisitFilterSheet(context),
              ),
              if (state.activeFilterCount > 0)
                PositionedDirectional(
                  top: 8,
                  end: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${state.activeFilterCount}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _CommitBar(state: state),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _DayControls(state: state),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: FilledButton.icon(
              onPressed: state.busy ? null : notifier.suggest,
              icon: state.busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(l10n.visitSuggestDay),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(context.userErrorMessage(state.error!),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (state.suggestion != null) _SuggestionSummary(state: state),
          // The day as it currently stands. Sits above the candidate list
          // because it IS the thing being made; the list below is the source
          // of parts.
          const Divider(height: 20),
          const RoutePreviewPanel(),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.visitCandidateDoors,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (state.hasSelection)
                  TextButton(
                    onPressed: notifier.clearSelection,
                    child: Text(l10n.visitClearSelection),
                  ),
              ],
            ),
          ),
          targets.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.visitTargetsLoadFailed,
                  textAlign: TextAlign.center),
            ),
            data: (rows) => rows.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(l10n.visitNoCandidates,
                        textAlign: TextAlign.center),
                  )
                : Column(
                    children: [
                      for (final target in rows.take(120))
                        _TargetTile(
                          target: target,
                          selected: state.isSelected(target),
                          onToggle: () => notifier.toggle(target),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _DayControls extends ConsumerWidget {
  const _DayControls({required this.state});

  final VisitBuilderState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notifier = ref.read(visitBuilderProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: state.visitDate,
                      firstDate: now.subtract(const Duration(days: 1)),
                      lastDate: now.add(const Duration(days: 180)),
                    );
                    if (picked != null) notifier.setDate(picked);
                  },
                  icon: const Icon(Icons.event, size: 18),
                  label: Text(
                    JourneyFormat.pretty(context, state.isoDate),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StepperField(
                  label: l10n.visitMaxStops,
                  value: state.maxStops,
                  min: 1,
                  max: 30,
                  onChanged: notifier.setMaxStops,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StepperField(
                  label: l10n.visitDayHours,
                  value: state.dayMinutes ~/ 60,
                  min: 1,
                  max: 12,
                  onChanged: (hours) => notifier.setDayMinutes(hours * 60),
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: state.useMyLocation,
            onChanged: notifier.setUseMyLocation,
            title: Text(l10n.visitStartFromMyLocation),
            subtitle: Text(
              l10n.visitStartFromMyLocationHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: state.includeCustomers,
            onChanged: notifier.setIncludeCustomers,
            title: Text(l10n.visitIncludeCustomers),
            subtitle: Text(
              l10n.visitIncludeCustomersHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperField extends StatelessWidget {
  const _StepperField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove, size: 18),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          Text('$value', style: Theme.of(context).textTheme.titleSmall),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add, size: 18),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _SuggestionSummary extends StatelessWidget {
  const _SuggestionSummary({required this.state});

  final VisitBuilderState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final suggestion = state.suggestion!;
    final theme = Theme.of(context);

    if (suggestion.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          suggestion.note ?? l10n.visitNoCandidates,
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.visitProposedDay(suggestion.targets.length),
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                Text(l10n.visitDistanceKm(
                    suggestion.totalDistanceKm.toStringAsFixed(1))),
                Text(l10n.visitDurationMinutes(suggestion.totalDriveMinutes)),
                Text(l10n.visitDayTotal(
                    '${suggestion.totalDurationMinutes ~/ 60}h '
                    '${suggestion.totalDurationMinutes % 60}m')),
              ],
            ),
            const SizedBox(height: 6),
            // Say what it weighed. "9 of 812 considered" is what makes a
            // suggestion read as a decision rather than a coincidence.
            Text(
              l10n.visitConsidered(suggestion.considered),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.hintColor),
            ),
            if (suggestion.droppedForTime > 0)
              Text(
                l10n.visitDroppedForTime(suggestion.droppedForTime),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.hintColor),
              ),
          ],
        ),
      ),
    );
  }
}

class _TargetTile extends StatelessWidget {
  const _TargetTile({
    required this.target,
    required this.selected,
    required this.onToggle,
  });

  final VisitTarget target;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CheckboxListTile(
      value: selected,
      onChanged: (_) => onToggle(),
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      title: Text(target.displayTitle, style: theme.textTheme.bodyMedium),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Wrap(
          spacing: 8,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (target.area.isNotEmpty)
              Text(target.area, style: theme.textTheme.bodySmall),
            // The reasoning, not the score. A rep who disagrees is entitled to
            // see the argument.
            for (final reason in target.reasons.take(3))
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: reason.contains('overdue')
                      ? const Color(0xFFB3261E).withValues(alpha: 0.12)
                      : LeadsTheme.sahelBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reason,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: reason.contains('overdue')
                        ? const Color(0xFFB3261E)
                        : LeadsTheme.sahelBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CommitBar extends ConsumerWidget {
  const _CommitBar({required this.state});

  final VisitBuilderState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!state.hasSelection) return const SizedBox.shrink();
    final l10n = context.l10n;
    final notifier = ref.read(visitBuilderProvider.notifier);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.visitSelectedCount(state.selectedCount),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            // A half-built day is worth keeping. Without this the only way
            // out of the builder is to finish or to lose the work, and a rep
            // interrupted mid-plan loses it every time.
            TextButton(
              onPressed: state.busy
                  ? null
                  : () async {
                      final name =
                          await notifier.createPlan(status: 'Draft');
                      if (name == null || !context.mounted) return;
                      context.pushReplacement(
                        '${AppRoutes.b2bVisitPlan}/${Uri.encodeComponent(name)}',
                      );
                    },
              child: Text(l10n.visitSaveDraft),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: state.busy
                  ? null
                  : () async {
                      final name = await notifier.createPlan();
                      if (name == null || !context.mounted) return;
                      // Replace rather than push: the builder has done its job
                      // and backing out of the route should land on the
                      // calendar, not on a stale selection.
                      context.pushReplacement(
                        '${AppRoutes.b2bVisitPlan}/${Uri.encodeComponent(name)}',
                      );
                    },
              icon: const Icon(Icons.route, size: 18),
              label: Text(l10n.visitCreateRoute),
            ),
          ],
        ),
      ),
    );
  }
}
