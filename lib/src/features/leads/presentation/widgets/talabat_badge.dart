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
  const TalabatBadge({
    super.key,
    this.areas = const <String>[],
    this.rating,
    this.reviews = 0,
    this.ratingSource = '',
  });

  /// Delivery zones the listing was seen in. Shown as a tooltip so the card
  /// stays compact while a rep can still check the coverage they care about.
  final List<String> areas;

  /// Talabat's star rating, or null when the listing is unrated ("New").
  final double? rating;

  /// How many ratings. A LOWER BOUND — Talabat buckets big counts as "1k+".
  final int reviews;

  /// 'talabat' | 'google_maps' | ''. A google_maps score is Google's, shown
  /// because the venue has no Talabat rating yet, so it is deliberately NOT
  /// rendered as a Talabat score — that would credit a reputation it lacks.
  final String ratingSource;

  static const _orange = Color(0xFFFF5A00);
  static const _orangeBg = Color(0xFFFFEDE4);

  /// Only Talabat's own score earns the badge; a borrowed Google score does not.
  bool get showsRating => rating != null && ratingSource == 'talabat';

  /// Re-labels the stored bucket floor the way Talabat itself writes it, so the
  /// tooltip never implies a precision the source did not give us.
  String get reviewsLabel {
    if (reviews >= 1000) return '1k+';
    if (reviews >= 500) return '500+';
    if (reviews >= 100) return '100+';
    return '$reviews';
  }

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
          if (showsRating) ...[
            const SizedBox(width: 4),
            const Icon(Icons.star_rounded, size: 11, color: _orange),
            Text(
              rating!.toStringAsFixed(1),
              style: const TextStyle(
                fontFamily: LeadsTheme.bodyFont,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _orange,
                fontFeatures: LeadsTheme.tabular,
              ),
            ),
          ],
        ],
      ),
    );
    final tip = <String>[
      if (areas.isNotEmpty) areas.join(' · '),
      if (showsRating) '${rating!.toStringAsFixed(1)} ★ ($reviewsLabel)',
      if (ratingSource == 'google_maps')
        context.l10n.leadsTalabatRatingFromGoogle,
      if (ratingSource.isEmpty && rating == null)
        context.l10n.leadsTalabatUnrated,
    ].join('\n');
    if (tip.isEmpty) return badge;
    return Tooltip(message: tip, child: badge);
  }
}
