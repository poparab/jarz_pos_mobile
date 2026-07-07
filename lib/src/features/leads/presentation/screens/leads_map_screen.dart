import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/lead.dart';
import '../../state/lead_filter.dart';
import '../leads_theme.dart';
import '../widgets/lead_map.dart';
import '../widgets/sahel_badge.dart';
import '../widgets/tier_pill.dart';

/// A filterable map of the leads (same filters as the list). Tapping a marker
/// shows a small card that navigates to the lead detail.
class LeadsMapScreen extends ConsumerStatefulWidget {
  const LeadsMapScreen({super.key});

  @override
  ConsumerState<LeadsMapScreen> createState() => _LeadsMapScreenState();
}

class _LeadsMapScreenState extends ConsumerState<LeadsMapScreen> {
  Lead? _selected;

  @override
  Widget build(BuildContext context) {
    final filtered = ref.watch(filteredLeadsProvider);
    final located = filtered
        .where((l) => l.latitude != null && l.longitude != null)
        .toList();

    return Scaffold(
      backgroundColor: LeadsTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: LeadsTheme.deepPlum,
        elevation: 0,
        title: Text(
          'Leads map',
          style: LeadsTheme.heading.copyWith(fontSize: 22),
        ),
        actions: [
          IconButton(
            tooltip: 'List view',
            icon: const Icon(Icons.list_alt),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: Stack(
        children: [
          LeadMap(
            leads: filtered,
            onMarkerTap: (lead) => setState(() => _selected = lead),
          ),
          // Count pill.
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Text(
                '${located.length} on map',
                style: LeadsTheme.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (_selected != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 20,
              child: _MarkerCard(
                lead: _selected!,
                onClose: () => setState(() => _selected = null),
                onOpen: () => context.push(
                  '/leads/${Uri.encodeComponent(_selected!.name)}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MarkerCard extends StatelessWidget {
  const _MarkerCard({
    required this.lead,
    required this.onClose,
    required this.onOpen,
  });

  final Lead lead;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final nameRtl = LeadsTheme.isArabic(lead.leadName);
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TierPill(lead.tier, dense: true),
                        const SizedBox(width: 6),
                        if (lead.sahelBranches > 0)
                          SahelBadge(lead.sahelBranches),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Directionality(
                      textDirection:
                          nameRtl ? TextDirection.rtl : TextDirection.ltr,
                      child: Text(
                        lead.leadName.isEmpty ? lead.name : lead.leadName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LeadsTheme.nameStyle(lead.leadName),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (lead.primaryArea.isNotEmpty) lead.primaryArea,
                        if (lead.avgRating != null)
                          '★ ${lead.avgRating!.toStringAsFixed(1)}',
                        '${lead.branchCount} branches',
                      ].join('  ·  '),
                      style: LeadsTheme.bodyMuted,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: LeadsTheme.muted,
                onPressed: onClose,
              ),
              const Icon(Icons.chevron_right, color: LeadsTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}
