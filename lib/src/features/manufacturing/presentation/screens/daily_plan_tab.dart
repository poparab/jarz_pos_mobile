import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/network/frappe_error_message.dart';
import '../../../../core/widgets/reason_prompt_dialog.dart';
import '../../data/daily_plan_service.dart';
import '../../data/models/daily_plan.dart';
import '../../state/daily_plan_providers.dart';
import '../widgets/mixer_run_summary.dart';

/// The morning jar target and the evening count.
///
/// The floor plans in jars but mixes in batches, so the answer this screen owes
/// them is the mixer split — which is why it lives pinned to the bottom rather
/// than at the end of a long scroll.
class DailyPlanTab extends ConsumerStatefulWidget {
  const DailyPlanTab({super.key});

  @override
  ConsumerState<DailyPlanTab> createState() => _DailyPlanTabState();
}

class _DailyPlanTabState extends ConsumerState<DailyPlanTab> {
  final Map<String, TextEditingController> _controllers = {};
  bool _seeded = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String itemCode, int value) {
    return _controllers.putIfAbsent(
      itemCode,
      () => TextEditingController(text: value > 0 ? '$value' : ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final template = ref.watch(dailyPlanTemplateProvider);

    return template.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorState(
        message: '$error',
        onRetry: () => ref.invalidate(dailyPlanTemplateProvider),
      ),
      data: (data) {
        if (data.items.isEmpty) {
          return Center(child: Text(l10n.dailyPlanNoItems));
        }
        // Seeded once so re-entering the tab does not wipe what was typed.
        if (!_seeded) {
          _seeded = true;
          final existing = data.existingPlan;
          if (existing != null && existing.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadExisting(existing);
            });
          }
        }
        return _PlanBody(
          template: data,
          controllerFor: _controllerFor,
        );
      },
    );
  }

  Future<void> _loadExisting(String name) async {
    try {
      final plan = await ref.read(dailyPlanServiceProvider).getPlan(name);
      if (!mounted) return;
      ref.read(dailyPlanDraftProvider.notifier).loadFrom(plan);
      for (final line in plan.lines) {
        _controllerFor(line.itemCode, line.plannedQty).text =
            line.plannedQty > 0 ? '${line.plannedQty}' : '';
      }
    } catch (_) {
      // A plan that fails to load is not worth blocking a fresh entry on; the
      // save path will surface the conflict if one exists.
    }
  }
}

class _PlanBody extends ConsumerWidget {
  const _PlanBody({required this.template, required this.controllerFor});

  final DailyPlanTemplate template;
  final TextEditingController Function(String, int) controllerFor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final draft = ref.watch(dailyPlanDraftProvider);
    final readiness = ref.watch(bomReadinessProvider).valueOrNull;

    final grouped = <String, List<DailyPlanItem>>{};
    for (final item in template.items) {
      grouped.putIfAbsent(item.itemGroup, () => []).add(item);
    }
    final groups = grouped.keys.toList()..sort();

    return Column(
      children: [
        if (readiness != null && !readiness.ok)
          _ReadinessBanner(readiness: readiness),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              for (final group in groups) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                  child: Text(
                    group,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                for (final item in grouped[group]!)
                  _JarRow(
                    item: item,
                    controller: controllerFor(
                      item.itemCode,
                      draft.quantities[item.itemCode] ?? 0,
                    ),
                    onChanged: (qty) => ref
                        .read(dailyPlanDraftProvider.notifier)
                        .setQuantity(item.itemCode, qty),
                  ),
              ],
              if (draft.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    draft.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
        MixerRunSummary(
          preview: draft.preview,
          calculating: draft.calculating,
          mixUom: template.mix.uom,
          totalJars: draft.totalJars,
          onSave: draft.isEmpty ? null : () => _save(context, ref, l10n),
          onCheckMaterials: draft.isEmpty
              ? null
              : () => ref
                  .read(dailyPlanDraftProvider.notifier)
                  .refreshPreview(withMaterials: true),
          // Only offered once a plan actually exists for the day: there is
          // nothing to call off while the form is still a draft in memory.
          onCancelPlan: (draft.savedPlanName ?? '').isEmpty
              ? null
              : () => _cancelPlan(context, ref),
        ),
      ],
    );
  }

  /// Calls off the day.
  ///
  /// Deliberately not the same act as closing with zeroes: the dialog says so,
  /// because the two are one tap apart and only one of them tells the truth
  /// about a day the mixer was down.
  Future<void> _cancelPlan(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final reason = await promptForReason(
      context,
      title: l10n.productionPlanCancelTitle,
      message: l10n.productionPlanCancelBody,
      hint: l10n.productionPlanCancelHint,
      confirmLabel: l10n.productionPlanCancelConfirm,
    );
    if (reason == null || !context.mounted) return;

    try {
      await ref.read(dailyPlanDraftProvider.notifier).cancel(reason);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.productionPlanCancelled)),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            extractFrappeErrorMessage(error, fallback: l10n.commonError),
          ),
        ),
      );
    }
  }

  Future<void> _save(BuildContext context, WidgetRef ref, dynamic l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final plan = await ref
          .read(dailyPlanDraftProvider.notifier)
          .save(status: 'Planned');
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.dailyPlanSaved(plan.name))),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('$error')));
    }
  }
}

/// One flavour: what it yields per batch, and how many are wanted today.
class _JarRow extends StatelessWidget {
  const _JarRow({
    required this.item,
    required this.controller,
    required this.onChanged,
  });

  final DailyPlanItem item;
  final TextEditingController controller;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemName, style: theme.textTheme.bodyMedium),
                Text(
                  item.usesMix && item.jarsPerBatch != null
                      // The number the floor already knows by heart. Showing it
                      // is how they spot a BOM that has drifted from reality.
                      ? l10n.dailyPlanPerBatch(item.jarsPerBatch!.round())
                      : l10n.dailyPlanNoMix,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 92,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              onChanged: (text) => onChanged(int.tryParse(text) ?? 0),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessBanner extends StatelessWidget {
  const _ReadinessBanner({required this.readiness});

  final BomReadiness readiness;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final hasError = readiness.issues.any((i) => i.severity == 'error');
    final colour = hasError ? theme.colorScheme.error : theme.colorScheme.tertiary;

    return Material(
      color: colour.withValues(alpha: 0.10),
      child: InkWell(
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(hasError ? Icons.error_outline : Icons.info_outline,
                  size: 18, color: colour),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.dailyPlanBomIssues(readiness.issueCount),
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: colour),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              context.l10n.dailyPlanBomIssuesTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final issue in readiness.issues)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  issue.severity == 'error'
                      ? Icons.error_outline
                      : Icons.warning_amber_outlined,
                  size: 20,
                  color: issue.severity == 'error'
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.tertiary,
                ),
                title: Text(issue.itemCode),
                subtitle: Text(issue.detail),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(MaterialLocalizations.of(context)
                  .refreshIndicatorSemanticLabel),
            ),
          ],
        ),
      ),
    );
  }
}
