import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/basket_rollup.dart';
import '../../data/models/batch_line.dart';
import 'production_format.dart';

/// One queued line, with linked batch-count and unit-count fields.
///
/// The controllers and focus nodes live here rather than on [BatchLine].
/// Keeping them in the model meant every line carried mutable editing state,
/// needed two re-entrancy guards to stop the linked fields fighting each other,
/// and leaked its controllers whenever a line was removed mid-session.
class BatchLineCard extends StatefulWidget {
  const BatchLineCard({
    super.key,
    required this.line,
    required this.onBatchesChanged,
    required this.onUnitsChanged,
    required this.onRemove,
    this.shortages = const <String>{},
  });

  final BatchLine line;
  final ValueChanged<double> onBatchesChanged;
  final ValueChanged<double> onUnitsChanged;
  final VoidCallback onRemove;

  /// Item codes flagged short by the basket-wide roll-up.
  final Set<String> shortages;

  @override
  State<BatchLineCard> createState() => _BatchLineCardState();
}

class _BatchLineCardState extends State<BatchLineCard> {
  late final TextEditingController _batchesCtrl;
  late final TextEditingController _unitsCtrl;
  final FocusNode _batchesFocus = FocusNode();
  final FocusNode _unitsFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _batchesCtrl = TextEditingController(text: trimQty(widget.line.batches));
    _unitsCtrl = TextEditingController(text: trimQty(widget.line.units));
    _batchesFocus.addListener(_syncFromModel);
    _unitsFocus.addListener(_syncFromModel);
  }

  @override
  void didUpdateWidget(covariant BatchLineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.line != widget.line) _syncFromModel();
  }

  /// Pushes the model's values back into the fields, but never into a field the
  /// user is currently typing in — that is what makes the two-way link safe
  /// without any re-entrancy flag.
  void _syncFromModel() {
    if (!_batchesFocus.hasFocus) {
      _setText(_batchesCtrl, trimQty(widget.line.batches));
    }
    if (!_unitsFocus.hasFocus) {
      _setText(_unitsCtrl, trimQty(widget.line.units));
    }
  }

  void _setText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  void dispose() {
    _batchesFocus.dispose();
    _unitsFocus.dispose();
    _batchesCtrl.dispose();
    _unitsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final line = widget.line;

    final lineShortages = line.components
        .where((c) => widget.shortages.contains(c.itemCode))
        .toList(growable: false);
    final isShort = lineShortages.isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      color: isShort ? scheme.errorContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isShort ? scheme.error : scheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.itemName,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        line.itemCode,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _QuantityField(
                  label: l10n.productionBatchesLabel,
                  controller: _batchesCtrl,
                  focusNode: _batchesFocus,
                  onChanged: widget.onBatchesChanged,
                  onStep: (delta) =>
                      widget.onBatchesChanged(line.batches + delta),
                ),
                _QuantityField(
                  label: l10n.commonQtyWithUom(line.stockUom),
                  controller: _unitsCtrl,
                  focusNode: _unitsFocus,
                  width: 110,
                  onChanged: widget.onUnitsChanged,
                  onStep: (delta) => widget.onUnitsChanged(line.units + delta),
                ),
              ],
            ),
            if (line.components.isNotEmpty) ...[
              const SizedBox(height: 4),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text(
                  l10n.manufacturingRequiredItems,
                  style: theme.textTheme.bodyMedium,
                ),
                children: [
                  for (final component in line.components)
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: EdgeInsets.zero,
                      leading: widget.shortages.contains(component.itemCode)
                          ? Icon(Icons.warning_amber_rounded, color: scheme.error)
                          : null,
                      title: Text(
                        l10n.commonNameWithCode(
                          component.itemName,
                          component.itemCode,
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: Text(
                        l10n.manufacturingComponentRequired(
                          trimQty(line.requiredQtyOf(component), decimals: 3),
                          component.uom,
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuantityField extends StatelessWidget {
  const _QuantityField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onStep,
    this.width = 92,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onStep;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(width: 6),
        _StepButton(icon: Icons.remove, onPressed: () => onStep(-1)),
        const SizedBox(width: 4),
        SizedBox(
          width: width,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const [DecimalTextInputFormatter()],
            decoration: const InputDecoration(isDense: true),
            onChanged: (raw) {
              final parsed = double.tryParse(raw.trim().replaceAll(',', '.'));
              // An empty field mid-edit means zero, not "ignore me" — otherwise
              // clearing it leaves the previous value silently queued.
              onChanged(parsed ?? 0);
            },
          ),
        ),
        const SizedBox(width: 4),
        _StepButton(icon: Icons.add, onPressed: () => onStep(1)),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
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

/// Allows a partially-typed decimal ("1.", "0.") so the field stays editable.
class DecimalTextInputFormatter extends TextInputFormatter {
  const DecimalTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final normalized = newValue.text.replaceAll(',', '.');
    if (!RegExp(r'^\d*(?:\.\d*)?$').hasMatch(normalized)) return oldValue;
    return newValue;
  }
}

/// Item codes the roll-up flagged short, for highlighting affected lines.
Set<String> shortageItemCodes(BasketRollup? rollup) =>
    rollup?.shortages.map((s) => s.itemCode).toSet() ?? const <String>{};
