import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/lead.dart';
import '../../state/lead_filter.dart';
import '../leads_theme.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/lead_map.dart';
import '../widgets/sahel_badge.dart';
import '../widgets/stage_filter_bar.dart';
import '../widgets/tier_pill.dart';

/// A filterable map of the leads (same filters as the list). Tapping a marker
/// shows a small card that navigates to the lead detail.
///
/// The map reads the SHARED [filteredLeadsProvider], but until it carried its
/// own controls a rep had to go back to the list to change anything — so the
/// filters were effectively unreachable here. The stage strip is inline
/// because stage is what changes while planning a route; everything else is
/// one tap away behind the same sheet the list uses.
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
    final filter = ref.watch(leadFilterProvider);
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
          _MapFilterButton(count: filter.activeAdvancedCount),
          IconButton(
            tooltip: 'List view',
            icon: const Icon(Icons.list_alt),
            onPressed: () => context.pop(),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(44),
          child: StageFilterBar(backgroundColor: Colors.white),
        ),
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
                // Name the active stage narrowing right on the map: a rep who
                // filtered and then panned away needs to know why the map
                // looks empty here.
                filter.selectedStages.isEmpty
                    ? '${located.length} on map'
                    : '${located.length} on map  ·  '
                        '${_stageSummary(filter.selectedStages)}',
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

/// "Qualify" for one stage, "3 stages" beyond that — the full list would not
/// fit the pill and truncating it mid-name reads worse than a count.
String _stageSummary(Set<String> stages) {
  if (stages.length == 1) return stages.first;
  return '${stages.length} stages';
}

/// The map's route into the shared advanced-filter sheet, badged with the
/// active count so a narrowed map is never mistaken for an empty catalog.
class _MapFilterButton extends StatelessWidget {
  const _MapFilterButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Advanced filters',
          icon: const Icon(Icons.tune),
          color: LeadsTheme.deepPlum,
          onPressed: () => FilterSheet.show(context),
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: LeadsTheme.berryPink,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontFamily: LeadsTheme.bodyFont,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
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
