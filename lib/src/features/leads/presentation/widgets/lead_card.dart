import 'package:flutter/material.dart';

import '../../../journey/presentation/widgets/journey_badge.dart';
import '../../data/models/lead.dart';
import '../../domain/lead_clustering.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../leads_theme.dart';
import 'lead_actions.dart';
import '../../../visits/presentation/widgets/add_to_visit_sheet.dart';
import 'sahel_badge.dart';
import 'talabat_badge.dart';
import 'score_bar.dart';
import 'tier_pill.dart';

/// A single row in the leads list: score + bar on the left, the brand's
/// identity + metrics in the middle, quick contact actions at the bottom.
class LeadCard extends StatelessWidget {
  const LeadCard({
    super.key,
    required this.lead,
    required this.onTap,
    this.distanceMetres,
  });

  final Lead lead;
  final VoidCallback onTap;

  /// Straight-line metres from the rep, when a position is known. Null hides
  /// the badge entirely rather than showing a placeholder — an unknown
  /// distance is not a distance.
  final double? distanceMetres;

  @override
  Widget build(BuildContext context) {
    final nameRtl = LeadsTheme.isArabic(lead.leadName);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: LeadsTheme.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScoreBar(lead.score),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Directionality(
                            textDirection: nameRtl
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            child: Text(
                              lead.leadName.isEmpty ? lead.name : lead.leadName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: LeadsTheme.nameStyle(lead.leadName),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        TierPill(lead.tier, dense: true),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (lead.notSuitable) const _NotSuitableBadge(),
                        if (distanceMetres != null)
                          _Metric(
                            icon: Icons.straighten,
                            iconColor: const Color(0xFF1B6CA8),
                            label: formatDistance(context, distanceMetres!),
                          ),
                        if (lead.sahelBranches > 0)
                          SahelBadge(lead.sahelBranches),
                        if (lead.onTalabat)
                          TalabatBadge(
                            areas: lead.talabatAreas,
                            rating: lead.talabatRating,
                            reviews: lead.talabatReviews,
                            ratingSource: lead.talabatRatingSource,
                          ),
                        _Metric(
                          icon: Icons.storefront_outlined,
                          label: '${lead.branchCount}',
                        ),
                        if (lead.avgRating != null)
                          _Metric(
                            icon: Icons.star_rounded,
                            iconColor: LeadsTheme.gold,
                            label: lead.avgRating!.toStringAsFixed(1),
                          ),
                        if (lead.totalReviews > 0)
                          _Metric(
                            icon: Icons.reviews_outlined,
                            label: '${lead.totalReviews}',
                          ),
                        if (lead.priceBand.isNotEmpty)
                          _Chip(text: lead.priceBand),
                        if (lead.primaryArea.isNotEmpty)
                          _Metric(
                            icon: Icons.place_outlined,
                            label: lead.primaryArea,
                          ),
                      ],
                    ),
                    // Last touch + what is due, when this lead has a diary.
                    // A rep scanning the catalog needs to see who was visited
                    // recently before deciding where to go next.
                    if (!lead.journey.isEmpty) ...[
                      const SizedBox(height: 8),
                      JourneyCardBadge(summary: lead.journey, dense: false),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        LeadActionButton(
                          icon: Icons.call_outlined,
                          enabled: lead.callablePhone.isNotEmpty,
                          tooltip: context.l10n.leadActionCall,
                          onTap: () => LeadActions.call(lead.callablePhone),
                        ),
                        LeadActionButton(
                          icon: Icons.camera_alt_outlined,
                          enabled: lead.instagram.trim().isNotEmpty,
                          tooltip: context.l10n.leadActionInstagram,
                          color: LeadsTheme.berryPink,
                          onTap: () => LeadActions.instagram(lead.instagram),
                        ),
                        LeadActionButton(
                          icon: Icons.language_outlined,
                          enabled: lead.website.trim().isNotEmpty,
                          tooltip: context.l10n.leadActionWebsite,
                          onTap: () => LeadActions.website(lead.website),
                        ),
                        LeadActionButton(
                          icon: Icons.map_outlined,
                          enabled:
                              lead.mapsUrl.trim().isNotEmpty ||
                              (lead.latitude != null && lead.longitude != null),
                          tooltip: context.l10n.leadActionMap,
                          onTap: () {
                            if (lead.mapsUrl.trim().isNotEmpty) {
                              LeadActions.maps(lead.mapsUrl);
                            } else if (lead.latitude != null &&
                                lead.longitude != null) {
                              LeadActions.mapsAt(
                                lead.latitude!,
                                lead.longitude!,
                              );
                            }
                          },
                        ),
                        // Routable only when the brand has a pin somewhere.
                        // The sheet resolves the actual doors; this just
                        // avoids offering the action on a lead that has none.
                        LeadActionButton(
                          icon: Icons.route,
                          enabled: lead.locations.isNotEmpty ||
                              (lead.latitude != null && lead.longitude != null),
                          tooltip: context.l10n.visitAddToRoute,
                          color: LeadsTheme.sahelBlue,
                          onTap: () => addToVisitAndConfirm(
                            context,
                            referenceDoctype: 'Lead',
                            referenceName: lead.name,
                            title: lead.leadName,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: LeadsTheme.muted,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Marks a prospect a rep judged not worth pursuing. Only visible when the
/// "Show not suitable" filter is on, since those cards are hidden by default.
class _NotSuitableBadge extends StatelessWidget {
  const _NotSuitableBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: LeadsTheme.rejectedBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: LeadsTheme.rejected.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.block, size: 12, color: LeadsTheme.rejected),
          const SizedBox(width: 3),
          Text(
            context.l10n.leadsNotSuitableBadge,
            style: const TextStyle(
              fontFamily: LeadsTheme.bodyFont,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: LeadsTheme.rejected,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    this.iconColor = LeadsTheme.muted,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: LeadsTheme.fontFamilyFor(label),
            fontSize: 12,
            color: LeadsTheme.muted,
            fontFeatures: LeadsTheme.tabular,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: LeadsTheme.bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: LeadsTheme.line),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: LeadsTheme.bodyFont,
          fontSize: 11,
          color: LeadsTheme.muted,
        ),
      ),
    );
  }
}
