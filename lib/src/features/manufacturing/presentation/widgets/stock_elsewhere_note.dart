import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/stock_alternative.dart';
import '../../domain/stock_elsewhere.dart';
import 'move_stock_sheet.dart';
import 'production_format.dart';

/// One line under an existing shortage: where else in the company the material
/// is sitting — and, when the caller names the item, a button that fetches it.
///
/// A shortage is measured in the recipe line's own source warehouse, so stock
/// received or counted into another store reads as "none at all" and sends
/// somebody off to buy what the company already owns; eight jar labels on
/// production went that way. Naming the store fixed half of that. The other
/// half was that naming it was all the screen could do: the transfer lived in
/// Desk, which nobody standing at a bench has open, so an operator with 4.336
/// Kg of Butter Biscuit one shelf away still could not start.
///
/// The block itself is unchanged, and deliberately so. This does not decide the
/// batch may run — it moves stock into the warehouse the check measures, and
/// then the same check decides, on the same rules, with the stock where it
/// belongs.
class StockElsewhereNote extends StatelessWidget {
  const StockElsewhereNote({
    super.key,
    required this.availableElsewhere,
    required this.alternatives,
    this.uom = '',
    this.color,
    this.itemCode = '',
    this.itemName = '',
    this.neededQty,
    this.destinationWarehouse,
    this.onMoved,
  });

  /// Both nullable on purpose: absent means the backend never looked, which is
  /// a different answer from a zero, and rendering "none anywhere" for it would
  /// be an invention.
  final double? availableElsewhere;
  final List<StockAlternative>? alternatives;

  /// Empty when the shortage payload carries no UOM — the quantity then prints
  /// bare rather than with a trailing space.
  final String uom;

  /// Lets the note inherit the container it sits in (an error banner uses
  /// `onErrorContainer`, a pick-list row uses `onSurfaceVariant`).
  final Color? color;

  /// Naming the item is what turns the note from a sentence into an action.
  /// Left empty by callers that have a shortage but not an item to move — the
  /// note then renders exactly as it did before this button existed.
  final String itemCode;
  final String itemName;

  /// The shortfall, when the caller knows it: only the sheet's default
  /// quantity, never a cap.
  final double? neededQty;

  /// The warehouse the recipe draws from, so the sheet can name the
  /// destination before the move rather than after. Null is fine — the server
  /// resolves it and refuses any other destination regardless.
  final String? destinationWarehouse;

  /// Called after stock actually moved, for callers holding state the board
  /// providers do not cover (a locally-typed batch size, say).
  final VoidCallback? onMoved;

  bool get _canOfferMove => itemCode.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final hint = StockElsewhere.resolve(
      availableElsewhere: availableElsewhere,
      alternatives: alternatives,
    );
    // Nobody looked: render exactly what was rendered before this feature.
    if (hint == null) return const SizedBox.shrink();

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tone = color ?? theme.colorScheme.onSurfaceVariant;

    final String text;
    final IconData icon;
    if (hint.isFound) {
      final top = hint.top;
      final quantity = trimQty(top.availableQty, decimals: 3);
      final measured =
          uom.isEmpty ? quantity : l10n.basesQtyValue(quantity, uom);
      // Warehouse names are data, not copy: they stay unlocalised. In an
      // Arabic sentence they are direction-isolated, or the bidi algorithm
      // drags the trailing " - J" of "Nasr City - J" to the front.
      final warehouse = Directionality.of(context) == TextDirection.rtl
          ? isolateLtr(top.warehouse)
          : top.warehouse;
      // The rest are named as a count rather than listed: these banners are
      // already dense, and the operator only needs one place to go.
      text = hint.otherCount > 0
          ? l10n.productionStockElsewhereMore(
              hint.otherCount,
              measured,
              warehouse,
            )
          : l10n.productionStockElsewhere(measured, warehouse);
      icon = Icons.swap_horiz;
    } else {
      // A real answer, not an absence: the lookup ran and found none in the
      // company, so buying genuinely is the fix and the hunt can stop.
      text = l10n.productionStockNowhere;
      icon = Icons.shopping_cart_outlined;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // MainAxisSize.min with a Flexible label: the row shrinks to its
          // content inside a Wrap, and the Arabic sentence still wraps instead
          // of overflowing a 360 dp screen.
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 14, color: tone),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  style: theme.textTheme.labelSmall?.copyWith(color: tone),
                ),
              ),
            ],
          ),
          // Only where there is somewhere to move it from AND an item to move.
          // "None anywhere" gets no button: the fix there really is a purchase.
          if (hint.isFound && _canOfferMove)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: tone,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.move_down, size: 16),
                label: Text(l10n.productionMoveStock),
                onPressed: () => _openMoveSheet(context, hint),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openMoveSheet(
    BuildContext context,
    StockElsewhere hint,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    final result = await showMoveStockSheet(
      context,
      itemCode: itemCode,
      itemName: itemName.isEmpty ? itemCode : itemName,
      uom: uom,
      alternatives: hint.alternatives,
      neededQty: neededQty,
      destinationWarehouse: destinationWarehouse,
    );
    if (result == null) return;

    onMoved?.call();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n.productionMoved(
            uom.isEmpty
                ? trimQty(result.qty, decimals: 3)
                : l10n.basesQtyValue(
                    trimQty(result.qty, decimals: 3),
                    result.uom.isEmpty ? uom : result.uom,
                  ),
            result.toWarehouse,
          ),
        ),
      ),
    );
  }
}
