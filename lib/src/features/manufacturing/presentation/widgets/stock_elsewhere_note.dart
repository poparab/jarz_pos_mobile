import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/stock_alternative.dart';
import '../../domain/stock_elsewhere.dart';
import 'production_format.dart';

/// One line under an existing shortage: where else in the company the material
/// is sitting.
///
/// Purely informational, and deliberately so. A shortage is measured in the
/// recipe line's own source warehouse, so stock received into another branch
/// reads as "none at all" and sends somebody off to buy what the company
/// already owns — eight jar labels on production went that way. The block
/// stays exactly as it was; this only tells the operator that the answer is a
/// stock transfer somebody makes in ERPNext, not a purchase.
class StockElsewhereNote extends StatelessWidget {
  const StockElsewhereNote({
    super.key,
    required this.availableElsewhere,
    required this.alternatives,
    this.uom = '',
    this.color,
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
      // MainAxisSize.min with a Flexible label: the row shrinks to its content
      // inside a Wrap, and the Arabic sentence still wraps instead of
      // overflowing a 360 dp screen.
      child: Row(
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
    );
  }
}
