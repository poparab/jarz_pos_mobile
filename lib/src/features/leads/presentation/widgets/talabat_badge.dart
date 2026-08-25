import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../leads_theme.dart';

/// Marks a lead that already sells on Talabat.
///
/// The fact matters commercially: a brand on a delivery app has proven it will
/// hand its product to a third party and already prices for that channel, so it
/// is a warmer prospect than one that only sells over the counter.
///
/// Orange is Talabat's own brand colour — the badge is meant to be recognised at
/// a glance in a dense card, not to blend into the catalog palette.
class TalabatBadge extends StatelessWidget {
  const TalabatBadge({super.key, this.areas = const <String>[]});

  /// Delivery zones the listing was seen in. Shown as a tooltip so the card
  /// stays compact while a rep can still check the coverage they care about.
  final List<String> areas;

  static const _orange = Color(0xFFFF5A00);
  static const _orangeBg = Color(0xFFFFEDE4);

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: _orangeBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _orange.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.delivery_dining, size: 12, color: _orange),
          const SizedBox(width: 3),
          Text(
            context.l10n.leadsTalabatBadge,
            style: const TextStyle(
              fontFamily: LeadsTheme.bodyFont,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _orange,
            ),
          ),
        ],
      ),
    );
    if (areas.isEmpty) return badge;
    return Tooltip(message: areas.join(' · '), child: badge);
  }
}
