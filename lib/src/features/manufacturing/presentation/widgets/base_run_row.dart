import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/models/base_batch_preview.dart';
import '../../data/models/base_item.dart';
import '../../domain/base_batch_math.dart' show batchesForQty;
import '../../domain/base_entry_math.dart';
import '../../state/base_production_providers.dart';
import 'batch_line_card.dart' show DecimalTextInputFormatter;
import 'material_options_panel.dart';
import 'production_format.dart';
import 'status_chip.dart';
import 'stock_elsewhere_note.dart';
import 'view_sop_button.dart';

/// One base, collapsed to a line until somebody picks it.
///
/// The old card put every figure this screen knows on every base at once —
/// freezer batches, quantity on hand, capacity, consumption per day, cover,
/// a cover suggestion, a demand hint, a stepper, a cost panel and a component
/// list — nine bases deep. Nobody used it. What is on a closed row here is what
/// the floor needs to choose: the name, whether it is running out, and how much
/// is in the store. Everything else opens when the row does.
///
/// There is no Start button on the row. Several mixes at once is the normal
/// case, so the action lives once at the bottom of the screen and acts on
/// everything ticked.
class BaseRunRow extends ConsumerStatefulWidget {
  const BaseRunRow({super.key, required this.item});

  final BaseItem item;

  @override
  ConsumerState<BaseRunRow> createState() => _BaseRunRowState();
}

class _BaseRunRowState extends ConsumerState<BaseRunRow> {
  BaseRunDraftNotifier get _draftNotifier =>
      ref.read(baseRunDraftProvider(widget.item.itemCode).notifier);

  /// Rates keyed by jar, for the draft's quantity derivation. Built here because
  /// the notifier has no view of the catalogue row it belongs to.
  Map<String, double> get _perJar => {
    for (final jar in widget.item.jarConsumers)
      if (jar.isUsable) jar.itemCode: jar.qtyPerJar,
  };

  @override
  void didUpdateWidget(covariant BaseRunRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A changed BOM invalidates any alternative-material choice made against
    // the old one, and the cached preview with it.
    if (oldWidget.item.defaultBom == widget.item.defaultBom) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _draftNotifier.resetMaterialSelections();
    });
  }

  void _toggle() {
    final selection = ref.read(baseSelectionProvider.notifier);
    final wasSelected = selection.isSelected(widget.item.itemCode);
    selection.toggle(widget.item.itemCode);
    if (wasSelected) return;
    // Opening a row is what asks the server to cost it — a closed row costs
    // nothing, which is why nine of them no longer fire nine previews on load.
    _draftNotifier.seed(widget.item.safeBatchYield);
    _revealEditor();
  }

  /// Brings a freshly opened row into view.
  ///
  /// The last base in the list is a tap away from the bottom of the screen, and
  /// the action bar sits over it: opening it without this puts the jar fields
  /// somewhere the operator has to go looking for. Two frames, because the
  /// editor does not exist to be scrolled to until the rebuild that adds it has
  /// laid out.
  void _revealEditor() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Scrollable.ensureVisible(
          context,
          alignment: 0.05,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final scheme = Theme.of(context).colorScheme;
    final selected = ref.watch(baseSelectionProvider).contains(item.itemCode);
    final draft = ref.watch(baseRunDraftProvider(item.itemCode));

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: selected ? scheme.surfaceContainerHigh : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 1.4 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _summary(context, selected, draft),
          if (selected) ...[
            Divider(height: 1, color: scheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: _editor(context, draft),
            ),
          ],
        ],
      ),
    );
  }

  // ── Closed ────────────────────────────────────────────────────────────

  Widget _summary(BuildContext context, bool selected, BaseRunDraft draft) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final item = widget.item;

    return InkWell(
      onTap: _toggle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_box : Icons.check_box_outline_blank,
              color: selected ? scheme.primary : scheme.outline,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.displayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _storeLine(context),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: item.stockIsNegative
                          ? scheme.error
                          : scheme.onSurfaceVariant,
                      fontWeight: item.stockIsNegative
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // What this row will make, once something is set on it. The only
            // figure on a closed row that is not about the store, and it is
            // what lets somebody check a whole selection at a glance before
            // pressing Make.
            if (draft.isRunnable) ...[
              const SizedBox(width: 8),
              _QueuedPill(label: _queuedLabel(context, draft.qty)),
            ] else if (item.hasCoverSignal && item.isBelowCover) ...[
              const SizedBox(width: 8),
              ProductionStatusChip(status: item.status!, compact: true),
            ],
            Icon(
              selected ? Icons.expand_less : Icons.expand_more,
              size: 20,
              color: scheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  /// "0.58 Kg in store · 2 days left" — the two things that decide whether this
  /// base needs making, and nothing else.
  ///
  /// Cover is appended only when the server worked one out. A base nothing has
  /// drawn on has no cover, and printing "0 days" for it would send somebody to
  /// the mixer for a base nobody uses.
  String _storeLine(BuildContext context) {
    final l10n = context.l10n;
    final item = widget.item;
    final store = l10n.basesInStoreValue(
      trimQty(item.onHand, decimals: 3),
      item.stockUom,
    );
    if (!item.hasCoverSignal || item.daysOfCover == null) return store;
    return '$store · ${l10n.productionCoverDays(trimQty(item.daysOfCover!))}';
  }

  /// The pill on a closed row, in the unit the run was entered in — "45 eggs"
  /// for a cake, "2 Kg" for a mix. Reading it back in the other unit is how the
  /// old screen made a mix sound like a batch.
  String _queuedLabel(BuildContext context, double qty) {
    final l10n = context.l10n;
    final unit = widget.item.countedBatchUnit;
    if (unit != null && unit.isUsable) {
      final batches = batchesForQty(qty, widget.item.safeBatchYield);
      return l10n.basesCountedValue(
        trimQty(unit.countFor(batches)),
        unit.displayName,
      );
    }
    return l10n.basesQtyValue(trimQty(qty, decimals: 3), widget.item.stockUom);
  }

  // ── Open ──────────────────────────────────────────────────────────────

  Widget _editor(BuildContext context, BaseRunDraft draft) {
    final item = widget.item;
    final preview = draft.previewIsCurrent ? draft.preview : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (item.stockIsNegative) ...[
          _Warning(
            icon: Icons.error_outline,
            text: context.l10n.productionNegativeStock,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 10),
        ],

        // How much to make. Two entirely different questions, and the whole
        // point of the rebuild: a mix is asked in jars and kilos, a cake in
        // eggs.
        if (item.hasJarEntry) ...[
          _JarCounter(
            item: item,
            counts: draft.jarCounts,
            onChanged: (jar, count) =>
                _draftNotifier.setJarCount(jar, count, perJar: _perJar),
          ),
          const SizedBox(height: 10),
        ],
        if (item.isMadeByQuantity)
          _QtyEntry(
            item: item,
            draft: draft,
            onChanged: _draftNotifier.setQty,
          )
        else
          _CountedEntry(
            item: item,
            draft: draft,
            onChanged: _draftNotifier.setQty,
          ),

        const SizedBox(height: 10),
        MaterialOptionsPanel(
          bomName: draft.preview?.bomName ?? item.defaultBom,
          qty: draft.preview?.itemQty ?? draft.qty,
          selections: draft.materialSelections,
          onSelectionChanged: _draftNotifier.setMaterialSelection,
        ),
        _Outcome(
          item: item,
          draft: draft,
          onRetry: _draftNotifier.refreshPreview,
        ),
        if (preview != null && preview.hasShortage) ...[
          const SizedBox(height: 10),
          _ShortageNote(preview: preview, onReduce: _draftNotifier.setQty),
        ],
        if (item.hasSop || (draft.preview?.hasSop ?? false)) ...[
          const SizedBox(height: 4),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: ViewSopButton(
              hasSop: true,
              totalDurationMins: item.sopTotalDurationMins,
              onTap: () => _openSop(context, draft.qty),
            ),
          ),
        ],
      ],
    );
  }

  /// Navigates by route so this row never imports the SOP screen.
  ///
  /// The batch count is sent, not the quantity: there is no Work Order yet, so
  /// nothing else can tell the server what to scale the step times to, and its
  /// contract is in batches.
  void _openSop(BuildContext context, double qty) {
    final item = widget.item;
    context.push(
      AppRoutes.productionSop,
      extra: <String, dynamic>{
        'item_code': item.itemCode,
        'item_name': item.displayName,
        if (item.defaultBom.isNotEmpty) 'bom': item.defaultBom,
        'batches': batchesForQty(qty, item.safeBatchYield),
      },
    );
  }
}

// ── Jar counter ─────────────────────────────────────────────────────────

/// "I'm filling 40 mediums and 20 larges" — in, and the kilos come out.
///
/// The arithmetic the floor was doing in its head, and the reason a mix could
/// not be entered honestly before: the screen only took batches, and a mix has
/// no batch.
class _JarCounter extends StatelessWidget {
  const _JarCounter({
    required this.item,
    required this.counts,
    required this.onChanged,
  });

  final BaseItem item;
  final Map<String, int> counts;
  final void Function(String jarItemCode, int count) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final jars = item.jarConsumers.where((jar) => jar.isUsable).toList();
    if (jars.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.basesJarsToFill,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          for (final jar in jars)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          jar.displayName,
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          l10n.basesPerJar(
                            trimQty(jar.qtyPerJar, decimals: 3),
                            item.stockUom,
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _JarField(
                    // Keyed by jar so the fields do not swap their controllers
                    // when the list order changes under them.
                    key: ValueKey('jar-${item.itemCode}-${jar.itemCode}'),
                    count: counts[jar.itemCode] ?? 0,
                    onChanged: (value) => onChanged(jar.itemCode, value),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A whole-number jar count. No stepper: the floor types 40, it does not press
/// plus forty times.
class _JarField extends StatefulWidget {
  const _JarField({super.key, required this.count, required this.onChanged});

  final int count;
  final ValueChanged<int> onChanged;

  @override
  State<_JarField> createState() => _JarFieldState();
}

class _JarFieldState extends State<_JarField> {
  late final TextEditingController _controller;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.count > 0 ? '${widget.count}' : '',
    );
    _focus.addListener(_syncFromModel);
  }

  @override
  void didUpdateWidget(covariant _JarField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) _syncFromModel();
  }

  /// Pushes the model back into the field, but never while it has focus — that
  /// is what makes a cleared row safe to re-render without fighting the typist.
  void _syncFromModel() {
    if (_focus.hasFocus) return;
    final text = widget.count > 0 ? '${widget.count}' : '';
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
    return SizedBox(
      width: 74,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(isDense: true, hintText: '0'),
        // An emptied field is a zero, not "leave it as it was": clearing a jar
        // row has to take its kilos back out of the total.
        onChanged: (raw) => widget.onChanged(int.tryParse(raw.trim()) ?? 0),
      ),
    );
  }
}

// ── Quantity entry (weighed bases) ──────────────────────────────────────

/// How much to make, in the unit it is weighed in.
///
/// No batch count anywhere on it. The recipe's own yield only shows up as the
/// step the +/- buttons move by, because that is the amount somebody would say
/// out loud, not because a mix has batches.
class _QtyEntry extends StatefulWidget {
  const _QtyEntry({
    required this.item,
    required this.draft,
    required this.onChanged,
  });

  final BaseItem item;
  final BaseRunDraft draft;
  final ValueChanged<double> onChanged;

  @override
  State<_QtyEntry> createState() => _QtyEntryState();
}

class _QtyEntryState extends State<_QtyEntry> {
  late final TextEditingController _controller;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _text);
    _focus.addListener(_syncFromModel);
  }

  String get _text =>
      widget.draft.qty > 0 ? trimQty(widget.draft.qty, decimals: 3) : '';

  @override
  void didUpdateWidget(covariant _QtyEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.qty != widget.draft.qty) _syncFromModel();
  }

  void _syncFromModel() {
    if (_focus.hasFocus) return;
    final text = _text;
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final step = niceQtyStep(widget.item.safeBatchYield);
    final qty = widget.draft.qty;

    // What the jars typed above add up to, and what is still missing once the
    // store is counted. Shown rather than written into the field: rounding it up
    // to something weighable is the operator's call, and a figure that appears
    // in a submit without a tap is how 50 got booked against 42 made.
    final jarNeed = qtyForJarCounts(widget.draft.jarCounts, {
      for (final jar in widget.item.jarConsumers)
        if (jar.isUsable) jar.itemCode: jar.qtyPerJar,
    });
    final gap = jarNeed > 0
        ? qtyStillNeeded(required: jarNeed, onHand: widget.item.onHand)
        : 0.0;
    final rounded = gap > 0 ? roundQtyUpTo(gap, step) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (jarNeed > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              gap > 0
                  ? l10n.basesJarNeedShort(
                      trimQty(jarNeed, decimals: 3),
                      widget.item.stockUom,
                      trimQty(gap, decimals: 3),
                    )
                  : l10n.basesJarNeedCovered(
                      trimQty(jarNeed, decimals: 3),
                      widget.item.stockUom,
                    ),
              style: theme.textTheme.labelMedium?.copyWith(
                color: gap > 0 ? scheme.onSurface : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Row(
          children: [
            Text(
              l10n.basesMakeLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
            _StepButton(
              icon: Icons.remove,
              onPressed: qty <= kMinQty
                  ? null
                  : () => widget.onChanged(qty - step),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 92,
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: const [DecimalTextInputFormatter()],
                decoration: const InputDecoration(isDense: true, hintText: '0'),
                onChanged: (raw) => widget.onChanged(
                  double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0,
                ),
              ),
            ),
            const SizedBox(width: 4),
            _StepButton(
              icon: Icons.add,
              onPressed: () => widget.onChanged(qty + step),
            ),
            const SizedBox(width: 6),
            Text(
              widget.item.stockUom,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (rounded > 0 && (rounded - qty).abs() > kQtyEpsilon) ...[
          const SizedBox(height: 6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ActionChip(
              visualDensity: VisualDensity.compact,
              label: Text(
                l10n.basesUseQty(
                  trimQty(rounded, decimals: 3),
                  widget.item.stockUom,
                ),
              ),
              onPressed: () => widget.onChanged(rounded),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Counted entry (batch bases) ─────────────────────────────────────────

/// How much to make, in the thing the kitchen counts: eggs.
///
/// The recipe already knows — a Fudge Cake BOM lists 30 eggs and yields one
/// batch — so the chips read 30, 45, 60 instead of 1, 1.5, 2. That is the same
/// grid as before, spoken in the language the floor uses for it.
class _CountedEntry extends StatelessWidget {
  const _CountedEntry({
    required this.item,
    required this.draft,
    required this.onChanged,
  });

  final BaseItem item;
  final BaseRunDraft draft;
  final ValueChanged<double> onChanged;

  /// The batch multiples offered. Half a tray up to three trays covers every run
  /// the floor has recorded; anything else is reached with the +/- buttons.
  static const List<double> _multiples = <double>[0.5, 1, 1.5, 2, 3];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final unit = item.countedBatchUnit;
    final batchYield = item.safeBatchYield;
    final batches = batchesForQty(draft.qty, batchYield);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          unit != null && unit.isUsable
              ? l10n.basesCountedPerBatch(
                  trimQty(unit.qtyPerBatch),
                  unit.displayName,
                )
              : l10n.basesBatchYield(trimQty(batchYield), item.stockUom),
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        // Wrap, not a Row: five chips with Arabic labels do not fit a 360 dp
        // screen on one line.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final multiple in _multiples)
              ChoiceChip(
                visualDensity: VisualDensity.compact,
                label: Text(
                  unit != null && unit.isUsable
                      ? trimQty(unit.countFor(multiple))
                      : trimQty(multiple),
                ),
                tooltip: l10n.basesBatchesValue(trimQty(multiple)),
                selected: (multiple - batches).abs() <= kBatchChipEpsilon,
                onSelected: (_) => onChanged(multiple * batchYield),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _StepButton(
              icon: Icons.remove,
              onPressed: batches <= 0.5
                  ? null
                  : () => onChanged((batches - 0.5) * batchYield),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                unit != null && unit.isUsable
                    ? l10n.basesCountedAndBatches(
                        trimQty(unit.countFor(batches)),
                        unit.displayName,
                        trimQty(batches),
                      )
                    : l10n.basesBatchesValue(trimQty(batches)),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _StepButton(
              icon: Icons.add,
              onPressed: () => onChanged((batches + 0.5) * batchYield),
            ),
          ],
        ),
      ],
    );
  }
}

/// Halves are exact in binary but a figure that came out of a division is not:
/// `9.258 / 9.258` can present as `0.9999999999999999`.
const double kBatchChipEpsilon = 1e-6;

// ── Outcome of the chosen run ───────────────────────────────────────────

/// What the chosen run makes and what it eats.
///
/// One line plus a fold, where the old card had a headline, a cost, an always-on
/// expansion tile and a five-stat block above it.
class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.item,
    required this.draft,
    required this.onRetry,
  });

  final BaseItem item;
  final BaseRunDraft draft;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (!draft.isRunnable) return const SizedBox.shrink();

    if (draft.error != null) {
      // Degrades to a retry: the preview endpoint failing does not stop a run
      // being made, it only stops it being costed.
      return Row(
        children: [
          Expanded(
            child: Text(
              l10n.basesPreviewFailed(
                context.userErrorMessage(
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
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    // A preview taken at a different quantity is dimmed rather than hidden: the
    // component list is still roughly what will be pulled, and blanking it on
    // every keystroke makes the panel flash.
    final stale = !draft.previewIsCurrent;

    return Opacity(
      opacity: stale ? 0.45 : 1,
      child: Theme(
        // The fold's divider lines are noise inside a card that already has a
        // border; the panel is one line until somebody asks for the detail.
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          initiallyExpanded: preview.hasShortage,
          visualDensity: VisualDensity.compact,
          title: Text(
            l10n.basesMakes(
              trimQty(preview.itemQty, decimals: 3),
              preview.stockUom.isEmpty ? item.stockUom : preview.stockUom,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: preview.estimatedCost == null
              ? null
              : Text(
                  l10n.basesEstimatedCost(
                    formatCurrency(context, preview.estimatedCost!),
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
          children: [
            for (final component in preview.components)
              _ComponentLine(component: component),
          ],
        ),
      ),
    );
  }
}

class _ComponentLine extends StatelessWidget {
  const _ComponentLine({required this.component});

  final BasePreviewComponent component;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.isShort) ...[
            Icon(Icons.warning_amber_rounded, size: 16, color: scheme.error),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  component.displayName,
                  style: theme.textTheme.bodySmall,
                ),
                if (component.isShort)
                  Text(
                    l10n.productionPickListShort(
                      trimQty(component.shortfall, decimals: 3),
                      component.uom,
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.basesQtyValue(
              trimQty(component.requiredQty, decimals: 3),
              component.uom,
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Names what is short and offers the quantity that would work.
///
/// Never a red wall with no way forward — and the way forward is two offers, not
/// one: make less, or fetch the material from the branch that has it.
class _ShortageNote extends StatelessWidget {
  const _ShortageNote({required this.preview, required this.onReduce});

  final BaseBatchPreview preview;
  final ValueChanged<double> onReduce;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final worst = preview.worstShortage;

    // The largest run the store can actually cover, in the same unit the field
    // takes. `achievableBatches` is a ratio off this very preview, so scaling
    // its quantity by it is exact.
    final achievable = preview.batches > 0
        ? roundQty(preview.itemQty * (preview.achievableBatches / preview.batches))
        : 0.0;
    final canReduce =
        achievable >= kMinQty && achievable < preview.itemQty - kQtyEpsilon;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            worst == null
                ? l10n.manufacturingInsufficientInventory
                : l10n.basesShortage(
                    worst.displayName,
                    trimQty(worst.shortfall, decimals: 3),
                    worst.uom,
                  ),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onErrorContainer,
            ),
          ),
          if (worst != null)
            StockElsewhereNote(
              availableElsewhere: worst.availableElsewhere,
              alternatives: worst.alternatives,
              uom: worst.uom,
              color: scheme.onErrorContainer,
              itemCode: worst.itemCode,
              itemName: worst.itemName,
              neededQty: worst.shortfall,
              destinationWarehouse: worst.sourceWarehouse,
            ),
          if (canReduce) ...[
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.tonal(
                onPressed: () => onReduce(achievable),
                child: Text(
                  l10n.basesReduceToQty(
                    trimQty(achievable, decimals: 3),
                    preview.stockUom,
                  ),
                ),
              ),
            ),
          ] else
            Text(
              l10n.basesNothingPossible,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onErrorContainer,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Small shared pieces ─────────────────────────────────────────────────

class _QueuedPill extends StatelessWidget {
  const _QueuedPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
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
      width: 38,
      height: 38,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 20,
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

class _Warning extends StatelessWidget {
  const _Warning({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
