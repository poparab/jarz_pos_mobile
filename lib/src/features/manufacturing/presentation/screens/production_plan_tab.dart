import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/ui/loading_overlay.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/posting_date_confirmation_dialog.dart';
import '../../../../core/widgets/reason_prompt_dialog.dart';
import '../../data/daily_plan_service.dart';
import '../../data/manufacturing_service.dart';
import '../../data/models/basket_rollup.dart';
import '../../data/models/batch_line.dart';
import '../../data/models/daily_plan.dart';
import '../../data/models/production_suggestion.dart';
import '../../state/daily_plan_providers.dart';
import '../../state/plan_board_providers.dart';
import '../../state/production_basket_notifier.dart';
import '../../state/production_providers.dart';
import '../../state/running_batches_notifier.dart';
import '../back_date_gate.dart';
import '../production_timestamp.dart';
import '../widgets/basket_shortage_banner.dart';
import '../widgets/batch_date_bar.dart';
import '../widgets/material_options_panel.dart';
import '../widgets/mixer_run_summary.dart';
import '../widgets/plan_jar_row.dart';
import '../widgets/production_format.dart';

/// The day, in one list.
///
/// This was three tabs — Daily held the jar target, Plan held the ranking, Batch
/// held the queue — and nothing carried between them: the quantity was decided
/// on one screen using a cover figure printed on another, then re-entered on a
/// third to be started. They are one thought, so they are one tab: pick the
/// flavours and quantities, see beside each what is running low, then either
/// record the target or start the batches.
///
/// One quantity drives all of it — the saved plan, the mixer split, the
/// consolidated pick list and the Work Orders — because that is what the three
/// tabs were failing to share. It is never written by the app: every suggestion
/// is a one-tap OFFER that lands visibly in the field first.
class ProductionPlanTab extends ConsumerStatefulWidget {
  const ProductionPlanTab({super.key});

  @override
  ConsumerState<ProductionPlanTab> createState() => _ProductionPlanTabState();
}

class _ProductionPlanTabState extends ConsumerState<ProductionPlanTab> {
  /// Whether the day's already-filed plan has been fetched. Once only: a second
  /// fetch after the operator has started typing would fight the form.
  bool _planRequested = false;

  /// The plan already filed for this day, shown as a target beside each field.
  /// Deliberately not poured into the fields — see [PlanEntryController.hydrate].
  DailyPlan? _savedPlan;

  @override
  void initState() {
    super.initState();
    // The queue is restored from Hive by the host, asynchronously, so the
    // fields are filled from it after the first frame rather than in build().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(planEntryProvider).hydrate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // The queue comes back from Hive after this tab is already on screen —
    // `restore()` awaits a box open — so the one-shot in `initState` is not
    // enough on its own. Nothing to loop on: an edit writes the fields first
    // and the queue second, so by the time this fires the draft is no longer
    // empty and `hydrate` returns without touching anything.
    ref.listen<ProductionBasket>(productionBasketProvider, (previous, next) {
      if ((previous?.lines.isNotEmpty ?? false) || next.lines.isEmpty) return;
      ref.read(planEntryProvider).hydrate();
    });

    final board = ref.watch(planBoardProvider);

    if (board.error != null) {
      return _ErrorRetry(
        message: context.userErrorMessage(
          board.error!,
          fallback: l10n.commonError,
        ),
        onRetry: _refresh,
      );
    }
    if (board.isLoading && board.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final existing = board.existingPlan;
    if (!_planRequested && existing != null && existing.isNotEmpty) {
      _planRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadExistingPlan(existing);
      });
    }

    final planned = <String, int>{
      for (final line in _savedPlan?.lines ?? const <DailyPlanLine>[])
        if (line.plannedQty > 0) line.itemCode: line.plannedQty,
    };

    final draft = ref.watch(dailyPlanDraftProvider);
    final basket = ref.watch(productionBasketProvider);
    final entry = ref.read(planEntryProvider);
    final groups = ref.watch(visiblePlanBoardProvider);
    final readiness = ref.watch(bomReadinessProvider).valueOrNull;

    final rollupAsync = ref.watch(basketRollupProvider);
    final rollup = rollupAsync.valueOrNull;
    final shortages = _shortageItemCodes(rollup);

    // The quantities the heavy checks are actually describing. While a keystroke
    // is still settling this trails the fields by 400 ms, which is why nothing
    // that submits reads it.
    final settled = ref.watch(settledBasketProvider).valueOrNull ?? basket;
    final settledUnits = <String, double>{
      for (final line in settled.positiveLines) line.itemCode: line.units,
    };
    final materialSelectionsValid = settled.positiveLines.every((line) {
      final options = ref.watch(
        materialOptionsProvider(
          MaterialOptionsRequest(bomName: line.bomName, qty: line.units),
        ),
      );
      return options.maybeWhen(
        data: (value) =>
            materialSelectionsAreValid(value, line.materialSelections),
        orElse: () => false,
      );
    });

    // The server's today, never the device's. Every verdict about this date —
    // `isBackDated`, the caption under the bar, the refusal that gates Start —
    // is taken against `policy.today()`, so defaulting it from the device clock
    // put the two on different calendars: a tablet a day fast defaulted to the
    // server's TOMORROW, which every gate here waves through and the server
    // then refuses; a day slow defaulted to the server's yesterday and blocked
    // Start for a date the operator never picked.
    final policy = ref.watch(productionPolicyOrFallbackProvider);
    final notifier = ref.read(productionBasketProvider.notifier);

    return Column(
      // Stretched, not centred: the action bar sizes itself to its widest row,
      // and on a tablet that is barely a third of the screen — so it was being
      // centred as a floating island with the list's background either side of
      // it.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (readiness != null && !readiness.ok)
          _ReadinessBanner(readiness: readiness),
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
                BatchDateBar(
                  date: basket.postingDate ?? policy.today(),
                  onChanged: notifier.setPostingDate,
                  policy: policy,
                  timeChosen: hasExplicitPostingTime(basket.postingDate),
                ),
                const SizedBox(height: 4),
                _PlanHeader(board: board),
                if (rollupAsync.isLoading && rollup == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: LinearProgressIndicator()),
                  )
                else if (rollupAsync.hasError)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: ListTile(
                      title: Text(
                        context.userErrorMessage(
                          rollupAsync.error!,
                          fallback: l10n.commonError,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () => ref.invalidate(basketRollupProvider),
                        child: Text(l10n.commonRetry),
                      ),
                    ),
                  )
                else if (rollup != null) ...[
                  const SizedBox(height: 8),
                  BasketPickList(rollup: rollup),
                ],
                const SizedBox(height: 8),
                if (groups.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text(l10n.productionNoSuggestions)),
                  ),
                for (final group in groups) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 12, 4, 2),
                    child: Text(
                      group.name.isEmpty
                          ? l10n.productionOtherItems
                          : group.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  for (final row in group.rows)
                    Column(
                      key: ValueKey(row.itemCode),
                      children: [
                        PlanJarRow(
                          row: row,
                          quantity: draft.quantities[row.itemCode] ?? 0,
                          isShort: shortages.contains(row.itemCode),
                          plannedToday: planned[row.itemCode],
                          onQuantityChanged: (qty) =>
                              entry.setQuantity(row, qty),
                          onUseSuggestion: () => entry.fillSuggestion(row),
                          onUsePlanned: planned.containsKey(row.itemCode)
                              ? () => entry.setQuantity(
                                  row,
                                  planned[row.itemCode]!,
                                )
                              : null,
                        ),
                        // Only for a row that is actually queued, and only at
                        // the settled quantity: keyed on a live one this would
                        // fetch a fresh set of options per digit typed.
                        if (settledUnits[row.itemCode] case final qty?)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
                            child: MaterialOptionsPanel(
                              bomName: row.bomName,
                              qty: qty,
                              selections: _selectionsFor(basket, row.itemCode),
                              onSelectionChanged: (original, selected) {
                                final index = basket.indexOfItem(row.itemCode);
                                if (index < 0) return;
                                notifier.setMaterialSelection(
                                  index,
                                  original,
                                  selected,
                                );
                              },
                            ),
                          ),
                        const Divider(height: 1),
                      ],
                    ),
                ],
                if (draft.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      context.userErrorMessage(draft.error),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        // The split the floor actually mixes to, driven by the same fields.
        // Without its own buttons: the two actions below are one pair, and a
        // Save hidden in this bar beside a Start under it is the split-brain
        // this merge exists to end.
        MixerRunSummary(
          preview: draft.preview,
          calculating: draft.calculating,
          mixUom: board.mix.uom,
          totalJars: draft.totalJars,
          showActions: false,
        ),
        _PlanActions(
          rollup: rollup,
          rollupLoading: rollupAsync.isLoading,
          rollupFailed: rollupAsync.hasError,
          materialSelectionsValid: materialSelectionsValid,
          onSavePlan: draft.isEmpty ? null : () => _savePlan(context),
          onCheckMaterials: draft.isEmpty
              ? null
              : () => ref
                    .read(dailyPlanDraftProvider.notifier)
                    .refreshPreview(withMaterials: true),
          // Only offered once a plan actually exists for the day: there is
          // nothing to call off while the form is still a draft in memory.
          onCancelPlan: (draft.savedPlanName ?? '').isEmpty
              ? null
              : () => _cancelPlan(context),
          onClear: draft.isEmpty ? null : ref.read(planEntryProvider).clear,
          onStartBatches: () => _startBatches(context),
          onQuickProduce: () => _quickProduce(context),
          // The same condition the banner it replaced used: offered only when
          // the board actually has something worth filling.
          onFillTheDay: (board.page?.summary.actionable ?? 0) <= 0
              ? null
              : () => fillTheDay(context, ref, board.rows),
        ),
      ],
    );
  }

  static Map<String, String> _selectionsFor(
    ProductionBasket basket,
    String itemCode,
  ) {
    final index = basket.indexOfItem(itemCode);
    return index < 0
        ? const <String, String>{}
        : basket.lines[index].materialSelections;
  }

  /// Item codes the roll-up flagged short, for marking the rows that caused it.
  static Set<String> _shortageItemCodes(BasketRollup? rollup) {
    final shortages = rollup?.shortages ?? const <RollupComponent>[];
    return {
      for (final component in shortages)
        for (final line in component.contributingLines) line.itemCode,
    };
  }

  Future<void> _refresh() async {
    ref.invalidate(dailyPlanTemplateProvider);
    await ref.read(productionSuggestionsProvider.notifier).refresh();
  }

  /// Points the form at the plan already filed for this day.
  ///
  /// The name is attached so a later Save updates that document instead of
  /// filing a second plan for the same date. Its quantities go onto the rows as
  /// a target beside each field and nowhere else — see
  /// [PlanEntryController.hydrate] for why they must not land IN the field.
  Future<void> _loadExistingPlan(String name) async {
    try {
      final plan = await ref.read(dailyPlanServiceProvider).getPlan(name);
      if (!mounted) return;
      ref.read(dailyPlanDraftProvider.notifier).attachSavedPlan(plan.name);
      setState(() => _savedPlan = plan);
    } catch (_) {
      // A plan that fails to load is not worth blocking a fresh entry on; the
      // save path will surface the conflict if one exists.
    }
  }

  /// The day this tab is working on: whatever the date bar holds, else the
  /// SERVER's today — never the device's, which the gates are not measured
  /// against.
  DateTime _planDate() =>
      ref.read(productionBasketProvider).postingDate ??
      ref.read(productionPolicyOrFallbackProvider).today();

  /// `yyyy-MM-dd`, which is what `save_plan` files against.
  static String _planDateText(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _savePlan(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final plan = await ref
          .read(dailyPlanDraftProvider.notifier)
          .save(
            status: 'Planned',
            // Follows the date bar. Filing the intent on the server's today
            // while the stock entry goes to the chosen day would leave the
            // evening comparison reading two different days.
            planDate: _planDateText(_planDate()),
          );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.dailyPlanSaved(plan.name))),
      );
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(context.userErrorMessage(error))),
      );
    }
  }

  /// Calls off the day.
  ///
  /// Deliberately not the same act as closing with zeroes: the dialog says so,
  /// because the two are one tap apart and only one of them tells the truth
  /// about a day the mixer was down.
  Future<void> _cancelPlan(BuildContext context) async {
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
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            context.userErrorMessage(error, fallback: l10n.commonError),
          ),
        ),
      );
    }
  }

  /// Starts each queued line: Work Order plus material transfer, no Manufacture
  /// entry. What comes out is recorded later on the Running tab.
  ///
  /// Deliberately one call per line rather than a bulk endpoint — a start that
  /// fails on line three must not roll back the two batches already physically
  /// on the bench.
  Future<void> _startBatches(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final basket = ref.read(productionBasketProvider);
    // The server's today when nothing was picked — the same default the bar
    // showed, and on the same calendar as the gate below.
    final postingDate =
        basket.postingDate ??
        ref.read(productionPolicyOrFallbackProvider).today();

    // Checked before the confirmation dialog so the refusal names the actual
    // reason instead of arriving as a server error after two more taps. Against
    // the SERVER's policy, not this app's own idea of one.
    final backDateError = _backDateRefusal(context, postingDate);
    if (backDateError != null) {
      messenger.showSnackBar(SnackBar(content: Text(backDateError)));
      return;
    }

    final confirmed = await confirmPostingDatesBeforeSubmit(
      context,
      dates: [postingDate],
      includeTime: hasExplicitPostingTime(basket.postingDate),
    );
    if (!confirmed || !context.mounted) return;

    final lines = basket.positiveLines;
    if (lines.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.manufacturingNothingToSubmit)),
      );
      return;
    }

    final scheduledAt = startScheduledAt(
      postingDate,
      explicitTime: hasExplicitPostingTime(basket.postingDate),
    );
    final service = ref.read(manufacturingServiceProvider);

    ref.read(loadingOverlayProvider.notifier).show(l10n.productionSubmitting);

    // The target is filed BEFORE anything posts, and starting is enough on its
    // own — pressing Save plan first is not something the screen enforces or
    // even mentions, and started rows leave the form, so without this the day's
    // target is simply lost the moment a batch begins. Best effort in both
    // directions: a plan that will not save must never block or fail a
    // production run that is otherwise good, so it is reported as a footnote,
    // exactly as the Today screen reports it.
    var planSaveFailed = false;
    try {
      await ref
          .read(dailyPlanDraftProvider.notifier)
          .save(status: 'Planned', planDate: _planDateText(postingDate));
    } catch (_) {
      planSaveFailed = true;
    }
    final started = <BatchLine, String>{};
    final issues = <String>[];

    for (final line in lines) {
      try {
        final result = await service.startProductionBatch(
          itemCode: line.itemCode,
          bomName: line.bomName,
          itemQty: line.units,
          scheduledAt: scheduledAt,
          materialSelections: line.materialSelections,
        );
        started[line] = result.workOrder;
      } catch (error) {
        if (!context.mounted) break;
        issues.add(
          '${line.itemCode}: '
          '${context.userErrorMessage(error, fallback: l10n.commonError)}',
        );
      }
    }
    ref.read(loadingOverlayProvider.notifier).hide();

    // Only started lines leave the form, so a partial failure stays visible and
    // retryable instead of vanishing into a snackbar. What was PLANNED survives
    // on the saved plan document — that is what Save plan is for.
    ref
        .read(planEntryProvider)
        .forgetStarted(started.keys.map((l) => l.itemCode));

    if (started.isNotEmpty) {
      ref.invalidate(productionSuggestionsProvider);
      await ref.read(runningBatchesProvider.notifier).refresh();
      // The batches have physically left this tab, so leaving the operator
      // staring at the list they just emptied reads as "nothing happened".
      ref.read(productionTabRequestProvider.notifier).state =
          kProductionRunningTabIndex;
    }

    if (!context.mounted) return;
    if (issues.isNotEmpty) {
      await _showIssues(context, issues);
    }
    if (!context.mounted) return;

    final outcome = started.length == 1
        ? l10n.productionStarted(started.values.first)
        : l10n.manufacturingSubmitAllResult(started.length, lines.length);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          planSaveFailed ? '$outcome\n${l10n.productionPlanNotSaved}' : outcome,
        ),
      ),
    );
  }

  /// The escape hatch, unchanged: transfer and manufacture in one call, for
  /// items where the method genuinely does not matter. Same gates as Start —
  /// this was the one path with none, which made it the way around the ceiling
  /// rather than a convenience.
  Future<void> _quickProduce(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final basket = ref.read(productionBasketProvider);
    final postingDate =
        basket.postingDate ??
        ref.read(productionPolicyOrFallbackProvider).today();

    final backDateError = _backDateRefusal(context, postingDate);
    if (backDateError != null) {
      messenger.showSnackBar(SnackBar(content: Text(backDateError)));
      return;
    }

    final confirmed = await confirmPostingDatesBeforeSubmit(
      context,
      dates: [postingDate],
      includeTime: hasExplicitPostingTime(basket.postingDate),
    );
    if (!confirmed || !context.mounted) return;

    final lines = basket.toApiLines(
      scheduledAt: startScheduledAt(
        postingDate,
        explicitTime: hasExplicitPostingTime(basket.postingDate),
      ),
    );
    if (lines.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.manufacturingNothingToSubmit)),
      );
      return;
    }

    ref.read(loadingOverlayProvider.notifier).show(l10n.productionSubmitting);
    Map<String, dynamic> result;
    try {
      result = await ref
          .read(manufacturingServiceProvider)
          .submitWorkOrders(lines);
    } catch (error) {
      ref.read(loadingOverlayProvider.notifier).hide();
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            context.userErrorMessage(error, fallback: l10n.commonError),
          ),
        ),
      );
      return;
    }
    ref.read(loadingOverlayProvider.notifier).hide();

    final entries = (result['results'] as List?) ?? const [];
    final succeeded = <String>{};
    final issues = <String>[];

    for (final entry in entries) {
      if (entry is! Map) continue;
      final row = Map<String, dynamic>.from(entry);
      final line = row['line'] is Map
          ? Map<String, dynamic>.from(row['line'] as Map)
          : const <String, dynamic>{};
      final itemCode = '${line['item_code'] ?? ''}';

      if (row['ok'] == true ||
          (row['work_order'] ?? '').toString().isNotEmpty) {
        succeeded.add(itemCode);
      } else {
        final error = '${row['error'] ?? l10n.commonError}';
        issues.add(itemCode.isEmpty ? error : '$itemCode: $error');
      }
    }

    ref.read(planEntryProvider).forgetStarted(succeeded);
    ref.invalidate(productionSuggestionsProvider);

    if (!context.mounted) return;
    if (issues.isNotEmpty) {
      await _showIssues(context, issues);
    }
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n.manufacturingSubmitAllResult(succeeded.length, entries.length),
        ),
      ),
    );
  }

  /// Why the server would refuse [date], or null when it would accept it.
  ///
  /// The rule itself lives in `backDateRefusal` so the Today screen gates on
  /// exactly the same one.
  String? _backDateRefusal(BuildContext context, DateTime date) {
    return backDateRefusal(
      context.l10n,
      ref.read(productionPolicyOrFallbackProvider),
      date,
    );
  }

  Future<void> _showIssues(BuildContext context, List<String> issues) {
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
          child: SingleChildScrollView(child: Text(issues.join('\n\n'))),
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

/// The two actions, and the difference between them said out loud.
///
/// They are deliberately not two equal buttons: one records a number, the other
/// moves stock, and on the old board they lived on different tabs so nobody
/// could confuse them. Now that they sit together the weight, the icon and the
/// line underneath all carry the difference.
class _PlanActions extends ConsumerWidget {
  const _PlanActions({
    required this.rollup,
    required this.rollupLoading,
    required this.rollupFailed,
    required this.materialSelectionsValid,
    required this.onSavePlan,
    required this.onCheckMaterials,
    required this.onCancelPlan,
    required this.onClear,
    required this.onStartBatches,
    required this.onQuickProduce,
    required this.onFillTheDay,
  });

  final BasketRollup? rollup;
  final bool rollupLoading;
  final bool rollupFailed;
  final bool materialSelectionsValid;
  final VoidCallback? onSavePlan;
  final VoidCallback? onCheckMaterials;
  final VoidCallback? onCancelPlan;
  final VoidCallback? onClear;
  final VoidCallback onStartBatches;
  final VoidCallback onQuickProduce;

  /// Fills every urgent row's field at once. It lived on a banner of its own
  /// above the list; it is an action, so it sits with the actions.
  final VoidCallback? onFillTheDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final basket = ref.watch(productionBasketProvider);

    final blocked = rollup?.hasShortages ?? false;
    final nothingToSubmit = basket.positiveLines.isEmpty;
    final startDisabled =
        blocked ||
        nothingToSubmit ||
        rollupLoading ||
        rollupFailed ||
        !materialSelectionsValid;

    // No elevation of its own: the mixer bar directly above already lifts the
    // whole block off the list, and a second shadow between two panels that
    // belong together drew a hard line across the bottom of the screen.
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nothingToSubmit
                    ? l10n.productionPlanNothingQueued
                    : l10n.productionBatchTotals(
                        trimQty(basket.totalBatches),
                        trimQty(basket.totalUnits),
                      ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: onSavePlan,
                    icon: const Icon(Icons.event_note_outlined, size: 18),
                    label: Text(l10n.dailyPlanSave),
                  ),
                  const SizedBox(width: 10),
                  // Expanded, so the one action that moves stock is the widest
                  // thing on the bar rather than one of five equal buttons.
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: startDisabled ? null : onStartBatches,
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: Text(l10n.productionStartBatches),
                    ),
                  ),
                  // Everything that is neither the target nor the run. They were
                  // four more buttons on the bar, which made the two that matter
                  // look like options among six.
                  _PlanOverflow(
                    startDisabled: startDisabled,
                    onFillTheDay: onFillTheDay,
                    onCheckMaterials: onCheckMaterials,
                    onQuickProduce: onQuickProduce,
                    onClear: onClear,
                    onCancelPlan: onCancelPlan,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The secondary actions, behind one tap.
///
/// Ordered by how often the floor reaches for them, with the two that discard
/// work last and marked.
class _PlanOverflow extends StatelessWidget {
  const _PlanOverflow({
    required this.startDisabled,
    required this.onFillTheDay,
    required this.onCheckMaterials,
    required this.onQuickProduce,
    required this.onClear,
    required this.onCancelPlan,
  });

  final bool startDisabled;
  final VoidCallback? onFillTheDay;
  final VoidCallback? onCheckMaterials;
  final VoidCallback onQuickProduce;
  final VoidCallback? onClear;
  final VoidCallback? onCancelPlan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return PopupMenuButton<int>(
      tooltip: l10n.productionMoreActions,
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        if (onFillTheDay != null)
          PopupMenuItem(
            value: 0,
            onTap: onFillTheDay,
            child: Row(
              children: [
                const Icon(Icons.playlist_add, size: 18),
                const SizedBox(width: 10),
                Text(l10n.productionFillTheDay),
              ],
            ),
          ),
        PopupMenuItem(
          value: 1,
          enabled: onCheckMaterials != null,
          onTap: onCheckMaterials,
          child: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 18),
              const SizedBox(width: 10),
              Text(l10n.dailyPlanCheckMaterials),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          enabled: !startDisabled,
          onTap: startDisabled ? null : onQuickProduce,
          child: Row(
            children: [
              const Icon(Icons.bolt_outlined, size: 18),
              const SizedBox(width: 10),
              Text(l10n.productionQuickProduce),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 3,
          enabled: onClear != null,
          onTap: onClear,
          child: Row(
            children: [
              const Icon(Icons.backspace_outlined, size: 18),
              const SizedBox(width: 10),
              Text(l10n.productionClearBasket),
            ],
          ),
        ),
        if (onCancelPlan != null)
          PopupMenuItem(
            value: 4,
            onTap: onCancelPlan,
            child: Row(
              children: [
                Icon(Icons.cancel_outlined, size: 18, color: scheme.error),
                const SizedBox(width: 10),
                Text(
                  l10n.productionPlanCancel,
                  style: TextStyle(color: scheme.error),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// What the ranked board says about the day as a whole, and the one tap that
/// fills every urgent row at once.
class _PlanHeader extends ConsumerWidget {
  const _PlanHeader({required this.board});

  final PlanBoard board;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final filter = ref.watch(productionFilterProvider);

    final page = board.page;
    // Only claimed when the board actually answered: a failed suggestions call
    // must not read as "velocity has never run".
    final neverRan = page != null && (page.velocityUpdatedOn ?? '').isEmpty;

    // Counted off the WHOLE board, never the filtered view: a count that shrank
    // as you filtered would be describing the filter rather than the day.
    final counts = <String, int>{};
    for (final row in board.rows) {
      final status = row.suggestion?.status;
      if (status == null) continue;
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (neverRan)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: scheme.tertiaryContainer,
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: scheme.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.productionVelocityNever,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: Text(
                  l10n.productionFilterCount(
                    l10n.productionFilterAll,
                    counts.values.fold(0, (a, b) => a + b),
                  ),
                ),
                selected: filter.isAll,
                onSelected: (_) =>
                    ref.read(productionFilterProvider.notifier).state =
                        const ProductionFilter(),
              ),
              for (final entry in <(String, String)>[
                (ProductionStatus.critical, l10n.productionStatusCritical),
                (ProductionStatus.low, l10n.productionStatusLow),
                (ProductionStatus.ok, l10n.productionStatusOk),
                (
                  ProductionStatus.overstocked,
                  l10n.productionStatusOverstocked,
                ),
                (ProductionStatus.noVelocity, l10n.productionStatusNoVelocity),
              ])
                // A status with nothing in it is not offered: an empty filter
                // that yields an empty list reads as a broken board.
                if ((counts[entry.$1] ?? 0) > 0)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: FilterChip(
                      // The count is what the removed banner used to say, on
                      // the control that acts on it rather than above it.
                      label: Text(
                        l10n.productionFilterCount(entry.$2, counts[entry.$1]!),
                      ),
                      selected: filter.statuses.contains(entry.$1),
                      onSelected: (_) =>
                          ref.read(productionFilterProvider.notifier).state =
                              filter.toggle(entry.$1),
                    ),
                  ),
            ],
          ),
        ),
        if (page?.season.name != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              l10n.productionSeasonApplied(
                page!.season.name!,
                page.season.multiplier,
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}

/// Fills every urgent row's field, and says what it could not.
///
/// Fills the FIELDS, not a hidden queue: every number it writes is on screen
/// and correctable before either action is tapped. Top-level now that it is
/// reached from the action bar rather than from a banner of its own.
void fillTheDay(BuildContext context, WidgetRef ref, Iterable<PlanRow> rows) {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final result = ref.read(planEntryProvider).fillTheDay(rows);

  // Says what it skipped rather than quietly planning less than the board
  // suggested — a silent cap reads as "covered everything" when it wasn't.
  final message = StringBuffer(
    result.filledNothing
        ? l10n.productionFillTheDayNothing
        : l10n.productionFillTheDayFilled(
            result.itemsFilled,
            result.jarsFilled,
          ),
  );
  if (result.skippedNoMaterials > 0) {
    message
      ..write(' · ')
      ..write(l10n.productionFillTheDaySkipped(result.skippedNoMaterials));
  }

  messenger
    // One bar at a time: a row-by-row fill would otherwise queue six of them,
    // each naming an item the operator filled twenty seconds ago.
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message.toString())));
}

/// BOMs that cannot answer the batch question yet.
///
/// Advisory: a plan is still worth entering while some BOMs are unmigrated, it
/// just under-reports the mix.
class _ReadinessBanner extends StatelessWidget {
  const _ReadinessBanner({required this.readiness});

  final BomReadiness readiness;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final hasError = readiness.issues.any((i) => i.severity == 'error');
    final colour = hasError
        ? theme.colorScheme.error
        : theme.colorScheme.tertiary;

    return Material(
      color: colour.withValues(alpha: 0.10),
      child: InkWell(
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(
                hasError ? Icons.error_outline : Icons.info_outline,
                size: 18,
                color: colour,
              ),
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

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

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
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
