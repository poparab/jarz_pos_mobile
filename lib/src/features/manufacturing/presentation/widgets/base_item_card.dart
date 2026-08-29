import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/network/frappe_error_message.dart';
import '../../../../core/ui/loading_overlay.dart';
import '../../data/manufacturing_service.dart';
import '../../data/models/base_batch_preview.dart';
import '../../data/models/base_item.dart';
import '../../domain/base_batch_math.dart';
import '../../state/base_production_providers.dart';
import '../../state/running_batches_notifier.dart';
import 'batch_line_card.dart' show DecimalTextInputFormatter;
import 'production_format.dart';
import 'stock_elsewhere_note.dart';
import 'status_chip.dart';
import 'view_sop_button.dart';

/// One base the floor can put on the mixer.
///
/// Everything on the card is a batch figure. The jars downstream are a *hint*
/// on one line and nothing more: the number the operator types is what runs,
/// because the mixer is the constraint and the plan is an estimate.
class BaseItemCard extends ConsumerStatefulWidget {
  const BaseItemCard({super.key, required this.item});

  final BaseItem item;

  @override
  ConsumerState<BaseItemCard> createState() => _BaseItemCardState();
}

class _BaseItemCardState extends ConsumerState<BaseItemCard> {
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    // The first preview is requested here rather than in the provider's
    // build(): nothing is fetched inside build(), and a card that never
    // appears never costs a request.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(baseBatchDraftProvider(widget.item.itemCode).notifier)
          .ensurePreview();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final item = widget.item;

    final draft = ref.watch(baseBatchDraftProvider(item.itemCode));
    final notifier = ref.read(baseBatchDraftProvider(item.itemCode).notifier);

    // Only a preview that describes the batch count currently on screen may
    // drive the Start button. A stale one is still rendered — greyed — but it
    // must not be read as an answer about this run.
    final preview = draft.previewIsCurrent ? draft.preview : null;

    final blocked =
        preview != null ? preview.hasShortage : item.isBlockedByMaterials;
    final canStart = !blocked && !draft.loading && !_starting;

    final runSizes = preview?.runSizes ?? item.runSizes;
    // Server verdict first: the client grid check is only a stand-in for the
    // window before the first preview lands.
    final runSizeOk = preview?.runSizeOk ?? isRunSizeOk(draft.batches, runSizes);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context, item),
            const SizedBox(height: 10),
            _freezerPosition(context, item),
            if (item.stockIsNegative) ...[
              const SizedBox(height: 8),
              _warningRow(
                context,
                icon: Icons.error_outline,
                text: l10n.productionNegativeStock,
                color: scheme.error,
              ),
            ],
            if (item.demand != null) ...[
              const SizedBox(height: 10),
              _DemandHint(
                item: item,
                demand: item.demand!,
                onUse: notifier.setBatches,
              ),
            ],
            const Divider(height: 20),
            _BatchStepper(
              batches: draft.batches,
              onChanged: notifier.setBatches,
              onStep: notifier.step,
            ),
            if (runSizes != null && runSizes.isNotEmpty) ...[
              const SizedBox(height: 8),
              _RunSizeChips(
                runSizes: runSizes,
                batches: draft.batches,
                onSelect: notifier.setBatches,
              ),
            ],
            if (!runSizeOk) ...[
              const SizedBox(height: 8),
              // A warning, never a block: the mixer grid is a convention and
              // the floor sometimes has a reason to go off it.
              _warningRow(
                context,
                icon: Icons.info_outline,
                text: l10n.basesRunSizeOff,
                color: scheme.tertiary,
              ),
            ],
            const SizedBox(height: 10),
            _PreviewPanel(
              item: item,
              draft: draft,
              onRetry: notifier.refreshPreview,
            ),
            if (blocked) ...[
              const SizedBox(height: 10),
              _ShortageBanner(
                item: item,
                preview: preview,
                onReduce: notifier.setBatches,
              ),
            ],
            const SizedBox(height: 10),
            // Wrap, not Row: the Arabic labels for "View SOP" and "Start
            // batch" together overflow a 360 dp screen.
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ViewSopButton(
                  hasSop: preview?.hasSop ?? item.hasSop,
                  // The SOP's own published total. The screen it opens scales
                  // the per-step times server-side for the chosen batch count;
                  // this badge is the "is this a 20-minute or a 3-hour job"
                  // signal, not a promise about this run.
                  totalDurationMins: item.sopTotalDurationMins,
                  onTap: () => _openSop(context, item, draft.batches),
                ),
                FilledButton(
                  onPressed: canStart ? () => _start(context, item) : null,
                  child: Text(l10n.productionStart),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, BaseItem item) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.displayName,
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        // Most bases are named by their code, so printing both renders the
        // same string twice.
        if (item.itemCode != item.itemName && item.itemName.isNotEmpty)
          Text(
            item.itemCode,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        const SizedBox(height: 2),
        Text(
          l10n.basesBatchYield(trimQty(item.safeBatchYield), item.stockUom),
          style: theme.textTheme.labelMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _freezerPosition(BuildContext context, BaseItem item) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final capacity = item.canMakeNowBatches;

    return Wrap(
      spacing: 18,
      runSpacing: 8,
      children: [
        ProductionStat(
          label: l10n.basesInFreezer,
          value: l10n.basesBatchesValue(trimQty(item.batchesOnHand)),
          emphasis: item.stockIsNegative ? scheme.error : null,
        ),
        ProductionStat(
          label: l10n.productionOnHand,
          value: l10n.basesQtyValue(trimQty(item.onHand), item.stockUom),
          emphasis: item.stockIsNegative ? scheme.error : null,
        ),
        // Null means the server skipped the capacity check — deliberately
        // distinct from zero, which means "cannot make any".
        if (capacity != null)
          ProductionStat(
            label: l10n.basesCanMakeNow,
            value: l10n.basesBatchesValue(trimQty(capacity.toDouble())),
            emphasis: capacity <= 0 ? scheme.error : null,
          ),
      ],
    );
  }

  Widget _warningRow(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  /// Navigates by route so this card never imports the SOP screen.
  ///
  /// The keys are the snake_case shape the SOP launch args accept. The batch
  /// count IS sent here, unlike from a running batch: there is no Work Order
  /// yet, so nothing else can tell the server what to scale the steps to.
  void _openSop(BuildContext context, BaseItem item, double batches) {
    context.push(
      AppRoutes.productionSop,
      extra: <String, dynamic>{
        'item_code': item.itemCode,
        'item_name': item.displayName,
        if (item.defaultBom.isNotEmpty) 'bom': item.defaultBom,
        'batches': batches,
      },
    );
  }

  /// Creates the Work Order and files the material transfer. What comes out is
  /// recorded later on the Running tab, exactly like a jar batch.
  Future<void> _start(BuildContext context, BaseItem item) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final draft = ref.read(baseBatchDraftProvider(item.itemCode));

    // The server's own conversion when a preview is in hand; the client's only
    // when it is not. Both are `batches * batch_yield` — the fallback exists so
    // a failed preview cannot stop the floor from working.
    final itemQty = draft.previewIsCurrent && draft.preview != null
        ? draft.preview!.itemQty
        : itemQtyForBatches(draft.batches, item.batchYield);

    final bomName = (draft.preview?.bomName.isNotEmpty ?? false)
        ? draft.preview!.bomName
        : item.defaultBom;

    setState(() => _starting = true);
    ref.read(loadingOverlayProvider.notifier).show(l10n.productionSubmitting);

    String? workOrder;
    Object? failure;
    try {
      final result =
          await ref.read(manufacturingServiceProvider).startProductionBatch(
                itemCode: item.itemCode,
                bomName: bomName,
                itemQty: itemQty,
                scheduledAt: _nowTimestamp(),
              );
      workOrder = result.workOrder;
    } catch (error) {
      failure = error;
    } finally {
      ref.read(loadingOverlayProvider.notifier).hide();
      if (mounted) setState(() => _starting = false);
    }

    if (failure != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.manufacturingSubmitFailed(
              extractFrappeErrorMessage(failure, fallback: l10n.commonError),
            ),
          ),
        ),
      );
      return;
    }

    // Stock has physically moved, so every figure the card was showing is now
    // wrong: the list is re-read and the cached preview dropped.
    ref.invalidate(baseItemsProvider);
    ref.read(baseBatchDraftProvider(item.itemCode).notifier).invalidatePreview();
    await ref.read(runningBatchesProvider.notifier).refresh();

    // The batch has left this tab, so leaving the operator staring at the card
    // it started from reads as "nothing happened".
    ref.read(productionTabRequestProvider.notifier).state =
        kProductionRunningTabIndex;

    messenger.showSnackBar(
      SnackBar(content: Text(l10n.productionStarted(workOrder ?? ''))),
    );
  }

  /// Now, to the minute. A base run is always posted as it happens — there is
  /// no back-dating path here, so no posting-date confirmation either.
  static String _nowTimestamp() {
    String two(int v) => v.toString().padLeft(2, '0');
    final now = DateTime.now();
    return '${now.year}-${two(now.month)}-${two(now.day)} '
        '${two(now.hour)}:${two(now.minute)}:00';
  }
}

/// "The plan needs 3.2 batches · you have 1.8", plus a one-tap offer.
///
/// Deliberately never written into the stepper on its own: demand is derived
/// from a jar plan that may not survive contact with the day, and the mixer
/// operator is the one who knows what is worth mixing.
class _DemandHint extends StatelessWidget {
  const _DemandHint({
    required this.item,
    required this.demand,
    required this.onUse,
  });

  final BaseItem item;
  final BaseDemand demand;
  final ValueChanged<double> onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // What is actually left to make: the shortfall when stock covers part of
    // it, the whole requirement when it covers none. Rounded UP to a half —
    // 3.2 batches of demand needs 3.5 batches of mixing.
    final offer = snapUpToHalf(
      demand.isShort ? demand.shortfallBatches : demand.batchesRequired,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: demand.isShort
            ? scheme.tertiaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      // Wrap rather than Row: the Arabic hint runs long and the offer chip
      // beside it overflows a 360 dp screen.
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.basesDemandHint(
                  trimQty(demand.batchesRequired),
                  trimQty(item.batchesOnHand),
                ),
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (demand.driver.isNotEmpty)
                Text(
                  l10n.basesDemandDriver(demand.driver),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
            ],
          ),
          if (offer >= kMinBatches)
            ActionChip(
              visualDensity: VisualDensity.compact,
              label: Text(l10n.basesUseBatches(trimQty(offer))),
              onPressed: () => onUse(offer),
            ),
        ],
      ),
    );
  }
}

/// Batch count entry. Moves in halves, because the mixer does.
class _BatchStepper extends StatefulWidget {
  const _BatchStepper({
    required this.batches,
    required this.onChanged,
    required this.onStep,
  });

  final double batches;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onStep;

  @override
  State<_BatchStepper> createState() => _BatchStepperState();
}

class _BatchStepperState extends State<_BatchStepper> {
  late final TextEditingController _controller;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: trimQty(widget.batches));
    _focus.addListener(_syncFromModel);
  }

  @override
  void didUpdateWidget(covariant _BatchStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.batches != widget.batches) _syncFromModel();
  }

  /// Pushes the model's value back into the field, but never while the user is
  /// typing in it — that is what makes snapping safe without a re-entrancy flag.
  void _syncFromModel() {
    if (_focus.hasFocus) return;
    final text = trimQty(widget.batches);
    if (_controller.text == text) return;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(l10n.productionBatchesLabel),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepButton(
              icon: Icons.remove,
              // Half-batch steps: the mixer runs 1, 1½ or 2, so whole-batch
              // arrows would hide half the machine's range.
              onPressed: widget.batches <= kMinBatches
                  ? null
                  : () => widget.onStep(-kBatchStep),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 84,
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                textAlign: TextAlign.center,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: const [DecimalTextInputFormatter()],
                decoration: const InputDecoration(isDense: true),
                onChanged: (raw) {
                  final parsed =
                      double.tryParse(raw.trim().replaceAll(',', '.'));
                  if (parsed == null) return;
                  // Typed input lands on the same half grid as the arrows: a
                  // 1.2-batch mix is not a thing the mixer can do, and the
                  // field re-renders snapped as soon as it loses focus.
                  widget.onChanged(parsed);
                },
              ),
            ),
            const SizedBox(width: 4),
            _StepButton(
              icon: Icons.add,
              onPressed: widget.batches >= kMaxBatches
                  ? null
                  : () => widget.onStep(kBatchStep),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

/// The mixer's published run sizes, as one-tap choices.
class _RunSizeChips extends StatelessWidget {
  const _RunSizeChips({
    required this.runSizes,
    required this.batches,
    required this.onSelect,
  });

  final List<double> runSizes;
  final double batches;
  final ValueChanged<double> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.basesRunSizes,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        // Wrap, not a Row: five chips with Arabic labels do not fit a 360 dp
        // screen on one line.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final size in runSizes)
              ChoiceChip(
                visualDensity: VisualDensity.compact,
                // The bare figure: the "Mixer runs" header above already says
                // what the number is, and "1 batches" under it reads wrong in
                // English and in Arabic alike.
                label: Text(trimQty(size)),
                tooltip: l10n.basesBatchesValue(trimQty(size)),
                selected: (size - batches).abs() <= kBatchEpsilon,
                onSelected: (_) => onSelect(size),
              ),
          ],
        ),
      ],
    );
  }
}

/// What the chosen run makes, and what it eats.
class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.item,
    required this.draft,
    required this.onRetry,
  });

  final BaseItem item;
  final BaseBatchDraft draft;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (draft.error != null) {
      // Degrades to a retry rather than an empty card: the preview endpoint
      // failing does not stop a run being started, it only stops it being
      // costed.
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              l10n.basesPreviewFailed(
                extractFrappeErrorMessage(
                  draft.error!,
                  fallback: l10n.commonError,
                ),
              ),
              style: theme.textTheme.labelSmall?.copyWith(color: scheme.error),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
        ],
      );
    }

    final preview = draft.preview;
    if (preview == null) {
      return Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.basesChecking,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      );
    }

    // A preview taken at a different batch count is dimmed rather than hidden:
    // the component list is still roughly what will be pulled, and blanking it
    // on every stepper tap makes the panel flash.
    final stale = !draft.previewIsCurrent;

    return Opacity(
      opacity: stale ? 0.45 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.basesMakes(
                    trimQty(preview.itemQty, decimals: 3),
                    preview.stockUom.isEmpty ? item.stockUom : preview.stockUom,
                  ),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (preview.estimatedCost != null)
                Text(
                  l10n.basesEstimatedCost(
                    formatCurrency(context, preview.estimatedCost!),
                  ),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
            ],
          ),
          if (preview.components.isNotEmpty)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              initiallyExpanded: preview.hasShortage,
              title: Text(l10n.basesConsumes,
                  style: theme.textTheme.bodyMedium),
              children: [
                for (final component in preview.components)
                  _ComponentRow(component: component),
              ],
            ),
        ],
      ),
    );
  }
}

class _ComponentRow extends StatelessWidget {
  const _ComponentRow({required this.component});

  final BasePreviewComponent component;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      leading: component.isShort
          ? Icon(Icons.warning_amber_rounded, size: 18, color: scheme.error)
          : null,
      title: Text(
        component.displayName,
        style: theme.textTheme.bodySmall,
      ),
      subtitle: component.isShort
          ? Text(
              l10n.productionPickListShort(
                trimQty(component.shortfall, decimals: 3),
                component.uom,
              ),
              style: theme.textTheme.labelSmall?.copyWith(color: scheme.error),
            )
          : null,
      trailing: Text(
        l10n.basesQtyValue(
          trimQty(component.requiredQty, decimals: 3),
          component.uom,
        ),
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}

/// Names what is short and offers the number that would work.
///
/// Never a red wall with no way forward: the same treatment the Plan tab gives
/// a capped suggestion.
class _ShortageBanner extends StatelessWidget {
  const _ShortageBanner({
    required this.item,
    required this.preview,
    required this.onReduce,
  });

  final BaseItem item;
  final BaseBatchPreview? preview;
  final ValueChanged<double> onReduce;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final worst = preview?.worstShortage;
    final limiter = item.limitingComponent;

    // Whichever payload produced the headline also carries the "it is in
    // another store" answer. Read from one source only: mixing the preview
    // component's quantity with the list endpoint's warehouses would name a
    // store for the wrong item.
    final elsewhereQty =
        worst != null ? worst.availableElsewhere : limiter?.availableElsewhere;
    final elsewhereList =
        worst != null ? worst.alternatives : limiter?.alternatives;

    final String headline;
    if (worst != null) {
      headline = l10n.basesShortage(
        worst.displayName,
        trimQty(worst.shortfall, decimals: 3),
        worst.uom,
      );
    } else if (limiter == null) {
      headline = l10n.manufacturingInsufficientInventory;
    } else if (limiter.isMissingWarehouse) {
      headline = l10n.productionNoSourceWarehouse;
    } else {
      headline = l10n.productionCannotStart(limiter.displayName);
    }

    // Preferred over the list endpoint's whole-batch `can_make_now_batches`:
    // this tab trades in halves, and offering "2" when 2.5 is possible sends
    // the operator back for a second run they did not need.
    final achievable = preview?.achievableBatches ??
        (item.canMakeNowBatches?.toDouble() ?? 0);
    final canReduce =
        achievable >= kMinBatches && achievable < (preview?.batches ?? 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      // Wrap: the Arabic shortage line plus a "Reduce to 1.5" button overflows
      // a 360 dp row.
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                headline,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onErrorContainer,
                ),
              ),
              if (!canReduce)
                Text(
                  l10n.basesNothingPossible,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: scheme.onErrorContainer),
                ),
              // Says where the material is; changes nothing about the block.
              // The Start button above stays disabled exactly as before —
              // moving stock between stores is somebody's job in ERPNext, not
              // this screen's.
              StockElsewhereNote(
                availableElsewhere: elsewhereQty,
                alternatives: elsewhereList,
                uom: worst?.uom ?? '',
                color: scheme.onErrorContainer,
              ),
            ],
          ),
          if (canReduce)
            FilledButton.tonal(
              onPressed: () => onReduce(achievable),
              child: Text(l10n.basesReduceTo(trimQty(achievable))),
            ),
        ],
      ),
    );
  }
}
