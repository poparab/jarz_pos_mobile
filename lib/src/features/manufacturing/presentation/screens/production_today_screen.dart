import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/network/user_service.dart';
import '../../../../core/ui/loading_overlay.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/posting_date_confirmation_dialog.dart';
import '../../data/daily_plan_service.dart';
import '../../data/models/base_item.dart';
import '../../data/models/basket_rollup.dart';
import '../../data/models/daily_plan.dart';
import '../../state/base_production_providers.dart';
import '../../state/daily_plan_providers.dart';
import '../../state/production_providers.dart';
import '../../state/production_today_providers.dart';
import '../../state/running_batches_notifier.dart';
import '../back_date_gate.dart';
import '../production_timestamp.dart';
import '../widgets/basket_shortage_banner.dart';
import '../widgets/mixer_run_summary.dart';
import '../widgets/production_format.dart';

/// Today — what is coming out of the kitchen.
///
/// The collapsed front of the Production Board. The five-tab board it sits in
/// front of is complete and correct, and produced nothing in three and a half
/// months: it asks the person holding the tablet to carry the ERPNext document
/// lifecycle in their head — two screens that both answer "what to make" and
/// never reconcile, two number fields per card, two submit buttons with
/// different accounting consequences side by side. Nothing here is deleted;
/// the full board is one tap away in the app bar.
///
/// What is deliberately ABSENT is as much of the design as what is present.
/// There is no days-of-cover, no sells-per-day, no trend and no negative-stock
/// warning on this screen: every one of those numbers is derived from sales
/// velocity against recorded production, and production is precisely what has
/// not been recorded. Leading with them means leading with figures that are
/// wrong *because* nobody uses the board — which is how the board taught the
/// floor not to trust it.
class ProductionTodayScreen extends ConsumerStatefulWidget {
  const ProductionTodayScreen({super.key});

  @override
  ConsumerState<ProductionTodayScreen> createState() =>
      _ProductionTodayScreenState();
}

class _ProductionTodayScreenState extends ConsumerState<ProductionTodayScreen> {
  final Map<String, TextEditingController> _baseControllers = {};
  final Map<String, TextEditingController> _jarControllers = {};

  /// Today's saved plan is pulled in once. Re-seeding on every rebuild would
  /// overwrite what is being typed right now.
  bool _seeded = false;

  @override
  void dispose() {
    for (final controller in _baseControllers.values) {
      controller.dispose();
    }
    for (final controller in _jarControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _baseController(String itemCode) =>
      _baseControllers.putIfAbsent(itemCode, TextEditingController.new);

  TextEditingController _jarController(String itemCode, int value) =>
      _jarControllers.putIfAbsent(
        itemCode,
        () => TextEditingController(text: value > 0 ? '$value' : ''),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Same gate as the board it fronts, and the same provider: a second,
    // parallel role check is a second thing to drift.
    if (!ref.watch(canAccessProductionBoardProvider)) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.productionTodayTitle)),
        drawer: const AppDrawer(),
        body: Center(child: Text(l10n.productionAccessDenied)),
      );
    }

    final basesAsync = ref.watch(baseItemsProvider);
    final templateAsync = ref.watch(dailyPlanTemplateProvider);
    final draft = ref.watch(dailyPlanDraftProvider);
    final today = ref.watch(productionTodayProvider);
    final runningCount =
        ref.watch(runningBatchesProvider).valueOrNull?.length ?? 0;
    final canExecute = ref.watch(canExecuteProductionProvider);

    final template = templateAsync.valueOrNull;
    _maybeSeedFromSavedPlan(template);

    final anythingTyped = today.hasBases || !draft.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productionTodayTitle),
        actions: [
          TextButton.icon(
            onPressed: () => context.go(AppRoutes.manufacturing),
            icon: const Icon(Icons.dashboard_customize_outlined, size: 18),
            label: Text(l10n.productionTodayAdvancedBoard),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: ResponsiveUtils.getResponsivePadding(
                  context,
                  small: 10,
                  medium: 12,
                  large: 12,
                ),
                children: [
                  // The safety valve. Work started somewhere else — the Batch
                  // tab, a base card, yesterday — is still holding material in
                  // WIP, and a screen that only ever shows today's list would
                  // hide it completely.
                  if (runningCount > 0)
                    _OpenBatchesBanner(count: runningCount),
                  _SectionHeader(
                    title: l10n.productionTodayBasesSection,
                    hint: l10n.productionTodayBasesHint,
                  ),
                  ...basesAsync.when(
                    loading: () => const [_SectionLoading()],
                    error: (error, _) => [
                      _SectionError(
                        message: context.userErrorMessage(
                          error,
                          fallback: l10n.commonError,
                        ),
                        onRetry: () => ref.invalidate(baseItemsProvider),
                      ),
                    ],
                    data: (page) => page.items.isEmpty
                        ? [_SectionEmpty(message: l10n.basesEmpty)]
                        : [
                            for (final item in page.items)
                              _BaseRow(
                                item: item,
                                hasDemand: page.hasDemand,
                                controller: _baseController(item.itemCode),
                                onChanged: (batches) => ref
                                    .read(productionTodayProvider.notifier)
                                    .setBaseBatches(
                                      item.itemCode,
                                      batches.toDouble(),
                                    ),
                              ),
                          ],
                  ),
                  _SectionHeader(
                    title: l10n.productionTodayJarsSection,
                    hint: l10n.productionTodayJarsHint,
                  ),
                  ...templateAsync.when(
                    loading: () => const [_SectionLoading()],
                    error: (error, _) => [
                      _SectionError(
                        message: context.userErrorMessage(
                          error,
                          fallback: l10n.commonError,
                        ),
                        onRetry: () =>
                            ref.invalidate(dailyPlanTemplateProvider),
                      ),
                    ],
                    data: (data) => data.items.isEmpty
                        ? [_SectionEmpty(message: l10n.dailyPlanNoItems)]
                        : [
                            for (final item in data.items)
                              _JarRow(
                                item: item,
                                controller: _jarController(
                                  item.itemCode,
                                  draft.quantities[item.itemCode] ?? 0,
                                ),
                                onChanged: (qty) => ref
                                    .read(dailyPlanDraftProvider.notifier)
                                    .setQuantity(item.itemCode, qty),
                              ),
                          ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          // The mixer split, live off the same `preview_plan` the Daily tab
          // uses. Its own buttons are switched off here: this screen has one
          // primary action for the whole day, and the bar must not sit above
          // three greyed-out ones. The bottom inset belongs to the action bar
          // below it, not to a panel in the middle of the stack.
          MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: MixerRunSummary(
              preview: draft.preview,
              calculating: draft.calculating,
              mixUom: template?.mix.uom ?? '',
              totalJars: draft.totalJars,
              showActions: false,
              // Past tense on purpose: the field above this bar asks what came
              // out of the oven, and the Daily tab's "you plan to fill" would
              // contradict it in the same glance.
              totalLabel: context.l10n.productionTodayTotalJars(draft.totalJars),
              emptyHint: context.l10n.productionTodayEnterQuantities,
            ),
          ),
          _TodayActions(
            // Recording production is a role the board's read access does not
            // imply, exactly as on the Batch tab.
            onMake: canExecute && anythingTyped && !today.submitting
                ? _make
                : null,
            onSaveForLater: !draft.isEmpty && !today.submitting
                ? _saveForLater
                : null,
          ),
        ],
      ),
    );
  }

  /// Pre-fills the jar rows from today's saved plan, when there is one.
  ///
  /// From the PLAN, never from the sales suggestions: the number on the row is
  /// what came out of the kitchen, and seeding it from a forecast would put a
  /// figure nobody produced one tap away from being posted as stock.
  void _maybeSeedFromSavedPlan(DailyPlanTemplate? template) {
    if (_seeded || template == null) return;
    _seeded = true;

    final existing = template.existingPlan;
    if (existing == null || existing.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPlan(existing));
  }

  Future<void> _loadPlan(String name) async {
    try {
      final plan = await ref.read(dailyPlanServiceProvider).getPlan(name);
      if (!mounted) return;
      ref.read(dailyPlanDraftProvider.notifier).loadFrom(plan);
      for (final line in plan.lines) {
        _jarController(line.itemCode, line.plannedQty).text = line.plannedQty > 0
            ? '${line.plannedQty}'
            : '';
      }
    } catch (_) {
      // A plan that will not load is not worth blocking a fresh entry on; the
      // save path surfaces the conflict if one exists.
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(baseItemsProvider);
    ref.invalidate(dailyPlanTemplateProvider);
    await ref.read(runningBatchesProvider.notifier).refresh();
  }

  Future<void> _saveForLater() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final plan = await ref
          .read(productionTodayProvider.notifier)
          .savePlanForLater();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.dailyPlanSaved(plan.name))),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            context.userErrorMessage(error, fallback: l10n.commonError),
          ),
        ),
      );
    }
  }

  /// Books what actually came out.
  Future<void> _make() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    // No date bar on this screen: today is the answer, and it is the SERVER's
    // today — the gate below is evaluated against the server clock, so a
    // tablet a day out would otherwise pick a date its own gate waves through
    // and the server refuses.
    final policy = ref.read(productionPolicyOrFallbackProvider);
    final postingDate = policy.today();

    // Checked before the confirmation dialog so a refusal names the real
    // reason instead of arriving as a server error after two more taps.
    final refusal = backDateRefusal(l10n, policy, postingDate);
    if (refusal != null) {
      messenger.showSnackBar(SnackBar(content: Text(refusal)));
      return;
    }

    final confirmed = await confirmPostingDatesBeforeSubmit(
      context,
      dates: [postingDate],
      includeTime: false,
    );
    if (!confirmed || !mounted) return;

    final scheduledAt = startScheduledAt(postingDate, explicitTime: false);
    ref.read(loadingOverlayProvider.notifier).show(l10n.productionSubmitting);

    ProduceReport report;
    try {
      report = await ref
          .read(productionTodayProvider.notifier)
          .produce(scheduledAt: scheduledAt);
    } finally {
      ref.read(loadingOverlayProvider.notifier).hide();
    }
    if (!mounted) return;

    if (report.nothingToDo) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.manufacturingNothingToSubmit)),
      );
      return;
    }

    // Only the rows that posted are emptied. A failed row keeps its number,
    // because the one thing to do with it is fix the cause and press Make
    // again — retyping the count from memory is how the second attempt ends up
    // recording a different day.
    for (final itemCode in report.succeededItemCodes) {
      _baseControllers[itemCode]?.clear();
      _jarControllers[itemCode]?.clear();
    }

    if (report.producedCount > 0) {
      // Freezer stock has physically moved. Invalidated rather than refreshed
      // so the list is re-read from its own provider on the next frame.
      ref.invalidate(baseItemsProvider);
    }

    await _report(report);
  }

  Future<void> _report(ProduceReport report) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final issues = <String>[
      for (final failure in report.failures)
        failure.itemCode.isEmpty
            ? (failure.error?.isNotEmpty == true
                  ? failure.error!
                  : l10n.commonError)
            : '${failure.itemCode}: '
                  '${failure.error?.isNotEmpty == true ? failure.error! : l10n.commonError}',
      if (report.baseError != null)
        context.userErrorMessage(report.baseError, fallback: l10n.commonError),
      if (report.jarError != null)
        context.userErrorMessage(report.jarError, fallback: l10n.commonError),
      if (report.jarsSkipped) l10n.productionTodayJarsSkipped,
    ];

    if (issues.isNotEmpty || report.shortages.isNotEmpty) {
      await _showIssues(issues, report.shortages);
      if (!mounted) return;
    }

    final produced = report.producedNothing
        ? l10n.productionTodayNothingProduced
        : l10n.productionTodayProduced(report.producedCount, report.attempted);

    // The plan save is a by-product. It is reported as a footnote under the
    // production result and never as a failure of it: the stock entries are
    // already posted, and telling the floor that "production failed" because a
    // bookkeeping document did not save is how a correct posting gets repeated.
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          report.planSaveFailed
              ? '$produced\n${l10n.productionTodayPlanSaveFailed}'
              : produced,
        ),
      ),
    );
  }

  Future<void> _showIssues(
    List<String> issues,
    List<RollupComponent> shortages,
  ) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.commonError),
        content: SizedBox(
          width: ResponsiveUtils.getDialogWidth(
            dialogContext,
            small: 340,
            medium: 440,
            large: 520,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (issues.isNotEmpty) Text(issues.join('\n\n')),
                if (shortages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  // The same consolidated pick list the Batch tab renders, off
                  // the same model — a shortage explained two different ways on
                  // two screens is two things to keep true.
                  BasketPickList(
                    rollup: BasketRollup(
                      components: shortages,
                      shortages: shortages,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(),
            child: Text(dialogContext.l10n.commonOk),
          ),
        ],
      ),
    );
  }
}

/// Unfinished work started elsewhere, and the way back to it.
class _OpenBatchesBanner extends StatelessWidget {
  const _OpenBatchesBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          // Straight to the Running tab of the full board rather than a copy
          // of it here: finishing a batch is a different act, with a different
          // posting date, and it already has a screen.
          onTap: () => context.go(
            '${AppRoutes.manufacturing}?tab=$kProductionRunningTabIndex',
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.pending_actions_outlined,
                  size: 18,
                  color: scheme.onTertiaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.productionTodayOpenBatches(count),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: scheme.onTertiaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 14, 2, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            hint,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLoading extends StatelessWidget {
  const _SectionLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(message, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(context.l10n.commonRetry),
          ),
        ],
      ),
    );
  }
}

/// One base: what came out, in batches, and the two facts that decide whether
/// that number is right.
///
/// Cover, velocity, trend and the on-hand quantity in UOM are all deliberately
/// absent — see the class comment on the screen.
class _BaseRow extends StatelessWidget {
  const _BaseRow({
    required this.item,
    required this.hasDemand,
    required this.controller,
    required this.onChanged,
  });

  final BaseItem item;
  final bool hasDemand;
  final TextEditingController controller;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final demand = item.demand;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.displayName, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 2),
                    // Wrap, not Row: the two Arabic facts on one line overflow
                    // a 360 dp screen.
                    Wrap(
                      spacing: 14,
                      runSpacing: 2,
                      children: [
                        if (hasDemand && demand != null)
                          Text(
                            l10n.productionTodayNeededToday(
                              trimQty(demand.batchesRequired),
                            ),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        Text(
                          l10n.productionTodayInFreezer(
                            trimQty(item.batchesOnHand),
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _QtyField(
                controller: controller,
                suffix: l10n.productionTodayFieldBatches,
                onChanged: onChanged,
              ),
            ],
          ),
          // A real constraint, unlike the figures this screen drops: the
          // materials cannot cover even the smallest run, so whatever is typed
          // here will be refused.
          if (item.isBlockedByMaterials) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, size: 14, color: scheme.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.limitingComponent != null
                        ? l10n.productionTodayBlockedBy(
                            item.limitingComponent!.displayName,
                          )
                        : l10n.productionTodayBlocked,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// One jar flavour. Name and number, nothing else — the per-batch yield, the
/// cover and the sales hint all live on the full board.
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
    final theme = Theme.of(context);
    final name = item.itemName.isEmpty ? item.itemCode : item.itemName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(name, style: theme.textTheme.bodyMedium)),
          const SizedBox(width: 8),
          _QtyField(
            controller: controller,
            suffix: context.l10n.productionTodayFieldJars,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// A plain whole-number field.
///
/// One field per row on purpose. The board's cards carry two coupled ones —
/// batches AND quantity — which have to be kept consistent by hand, and the
/// unit of each is only obvious to somebody who already knows the BOM.
class _QtyField extends StatelessWidget {
  const _QtyField({
    required this.controller,
    required this.suffix,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.end,
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          suffixText: suffix,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
        ),
        onChanged: (text) => onChanged(int.tryParse(text) ?? 0),
      ),
    );
  }
}

/// One primary action for the whole day, and one quiet way out of it.
class _TodayActions extends StatelessWidget {
  const _TodayActions({required this.onMake, required this.onSaveForLater});

  final VoidCallback? onMake;
  final VoidCallback? onSaveForLater;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              TextButton(
                onPressed: onSaveForLater,
                child: Text(l10n.productionTodaySaveForLater),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onMake,
                  icon: const Icon(Icons.done_all, size: 18),
                  label: Text(l10n.productionTodayMake),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
