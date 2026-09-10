import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/production_suggestion.dart';
import '../../state/plan_board_providers.dart';
import 'production_format.dart';
import 'status_chip.dart';
import 'stock_elsewhere_note.dart';

/// One jar on the merged Plan tab: what the board knows, and what to make.
///
/// The figures were on one tab and the field on another, so deciding a quantity
/// meant remembering a cover number from a screen you had to leave. They are one
/// row now, and the row's arithmetic is still entirely the server's — nobody
/// divides jars by a BOM yield here.
///
/// The suggestion is an OFFER, never a default. A quantity nobody typed must not
/// reach a submit: that already cost this feature a day where 50 were planned,
/// 42 were made, and one un-edited tap booked 50.
class PlanJarRow extends StatefulWidget {
  const PlanJarRow({
    super.key,
    required this.row,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onUseSuggestion,
    this.plannedToday,
    this.onUsePlanned,
    this.isShort = false,
  });

  final PlanRow row;

  /// Jars planned for this flavour. Zero renders as an empty field: a typed 0
  /// and nothing typed at all mean the same thing here, and a field full of
  /// zeroes reads as a form somebody already filled in.
  final int quantity;

  final ValueChanged<int> onQuantityChanged;

  /// Fills the field with the board's suggestion. One tap, visible result.
  final VoidCallback onUseSuggestion;

  /// What the plan already filed for this day says about this flavour, when it
  /// says anything.
  ///
  /// Shown BESIDE the field and never inside it. A saved plan is a target, not
  /// a quantity somebody just typed: poured into the field it would also be
  /// queued, and a run started this morning could then be started again by
  /// re-opening the tab. One tap adopts it, which is the point at which it
  /// becomes an instruction.
  final int? plannedToday;
  final VoidCallback? onUsePlanned;

  /// The consolidated pick list flagged a material this row needs. Only the
  /// roll-up can see it — a material shared by three rows passes every row on
  /// its own and still leaves the day short.
  final bool isShort;

  @override
  State<PlanJarRow> createState() => _PlanJarRowState();
}

class _PlanJarRowState extends State<PlanJarRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _textFor(widget.quantity));
  }

  @override
  void didUpdateWidget(covariant PlanJarRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only when the model actually disagrees with what is on screen: rewriting
    // the field on every rebuild would fight the keyboard and move the caret to
    // the end mid-word. This is how the field catches up with "Use 60" and with
    // "Fill the day", which write the model and nothing else.
    final shown = int.tryParse(_controller.text) ?? 0;
    if (shown == widget.quantity) return;
    final text = _textFor(widget.quantity);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _textFor(int quantity) => quantity > 0 ? '$quantity' : '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final row = widget.row;
    final suggestion = row.suggestion;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    Text(
                      row.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // Most items here are named by their code, so printing both
                    // just renders the same string twice.
                    if (row.itemCode != row.itemName)
                      Text(
                        row.itemCode,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    if (row.jarsPerBatch != null)
                      Text(
                        // The number the floor already knows by heart. Showing
                        // it is how they spot a BOM that has drifted.
                        l10n.dailyPlanPerBatch(row.jarsPerBatch!.round()),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      )
                    else if (row.inTemplate)
                      Text(
                        l10n.dailyPlanNoMix,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (suggestion != null)
                    ProductionStatusChip(status: suggestion.status),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 104,
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        isDense: true,
                        border: const OutlineInputBorder(),
                        // The hint carries the unit rather than a floating
                        // label: the Arabic word is longer than this field and
                        // a label would clip, while a hint ellipsizes and gets
                        // out of the way the moment a digit is typed.
                        hintText: l10n.productionPlanQty,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (text) =>
                          widget.onQuantityChanged(int.tryParse(text) ?? 0),
                    ),
                  ),
                  if (widget.plannedToday case final planned?)
                    if (planned > 0 && planned != widget.quantity)
                      TextButton(
                        onPressed: widget.onUsePlanned,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.productionPlannedToday(planned),
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                ],
              ),
            ],
          ),
          if (suggestion != null) ...[
            const SizedBox(height: 10),
            _Figures(suggestion: suggestion),
            if (suggestion.stockIsNegative) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.error_outline, size: 15, color: scheme.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      // The suggestion below ignores the hole on purpose, so
                      // the row has to say the stock figure cannot be trusted.
                      l10n.productionNegativeStock,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (suggestion.suggestedBatches > 0) ...[
              const SizedBox(height: 10),
              _SuggestionOffer(
                row: widget.row,
                suggestion: suggestion,
                onUse: widget.onUseSuggestion,
              ),
            ],
          ],
          if (widget.isShort) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 15, color: scheme.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.manufacturingInsufficientInventory,
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

/// On hand, sells per day, cover, trend — every one of them already computed.
class _Figures extends StatelessWidget {
  const _Figures({required this.suggestion});

  final ProductionSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    final cover = suggestion.daysOfCover;
    final coverColor = switch (suggestion.status) {
      ProductionStatus.critical => scheme.error,
      ProductionStatus.low => scheme.tertiary,
      _ => null,
    };

    return Wrap(
      spacing: 18,
      runSpacing: 8,
      children: [
        ProductionStat(
          label: l10n.productionOnHand,
          value: trimQty(suggestion.onHand),
          emphasis: suggestion.stockIsNegative ? scheme.error : null,
        ),
        ProductionStat(
          label: l10n.productionSellsPerDay,
          value: trimQty(suggestion.effectiveVelocity),
        ),
        ProductionStat(
          label: l10n.productionCover,
          value: cover == null
              ? l10n.productionCoverUnknown
              : l10n.productionCoverDays(trimQty(cover)),
          emphasis: coverColor,
        ),
        if ((suggestion.velocityTrend ?? '').isNotEmpty)
          ProductionStat(
            label: l10n.productionTrend,
            value: suggestion.velocityTrend!,
          ),
      ],
    );
  }
}

/// "Make 5 batches · 60 Nos to reach 10 days cover", and the tap that fills it
/// in.
class _SuggestionOffer extends StatelessWidget {
  const _SuggestionOffer({
    required this.row,
    required this.suggestion,
    required this.onUse,
  });

  final PlanRow row;
  final ProductionSuggestion suggestion;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final achievable = suggestion.achievableBatches;
    final capped = suggestion.isCappedByMaterials;
    final blocked = achievable <= 0;
    final offer = row.suggestedJars;

    // A shortage names the component that caused it and offers the achievable
    // number, rather than presenting a red wall with no way forward.
    final limiter = suggestion.limitingComponent;
    final limiterLabel = limiter == null
        ? ''
        : (limiter.itemName.isEmpty ? limiter.itemCode : limiter.itemName);

    final why = capped && limiter != null
        ? l10n.productionCappedBy(
            achievable,
            limiterLabel,
            suggestion.suggestedBatches,
          )
        : l10n.productionReachCover(suggestion.targetDays);

    // A blocked line must not headline "Make 6 batches" over a subtitle saying
    // it is capped at zero — the two read as a contradiction.
    final headline = blocked
        ? (limiter == null
              ? l10n.manufacturingInsufficientInventory
              : (limiter.isMissingWarehouse
                    ? l10n.productionNoSourceWarehouse
                    : l10n.productionCannotStart(limiterLabel)))
        : (suggestion.bomQty == 1
              // One BOM makes one unit, so "5 batches · 5 Nos" is the same
              // number printed twice.
              ? l10n.productionMakeUnits(
                  trimQty(achievable * suggestion.bomQty),
                  suggestion.stockUom,
                )
              : l10n.productionMakeBatches(
                  achievable,
                  trimQty(achievable * suggestion.bomQty),
                  suggestion.stockUom,
                ));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: capped
            ? scheme.tertiaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      // Wrap rather than Row: the Arabic headline runs long and the offer
      // button beside it overflows a 360 dp screen.
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  headline,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: blocked ? scheme.error : null,
                  ),
                ),
                if (!blocked)
                  Text(
                    why,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                // The backend only fills these for an item that cannot make a
                // single batch, so this lands on the blocked row. Filling the
                // field does not authorize production: the footer still checks
                // the consolidated stock before Start batches.
                if (limiter != null)
                  StockElsewhereNote(
                    availableElsewhere: limiter.availableElsewhere,
                    alternatives: limiter.alternatives,
                    uom: limiter.uom,
                    itemCode: limiter.itemCode,
                    itemName: limiter.itemName,
                    // One batch's worth of shortfall: what it takes to stop
                    // this row saying "Cannot start". The sheet offers "move
                    // all" beside it for the operator who wants the lot.
                    neededQty: limiter.requiredQty - limiter.availableQty,
                    destinationWarehouse: limiter.sourceWarehouse,
                  ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: offer <= 0 ? null : onUse,
            child: Text(l10n.productionUseSuggestion(offer)),
          ),
        ],
      ),
    );
  }
}
