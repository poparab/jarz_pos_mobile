import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../b2b/presentation/widgets/b2b_stage_chip.dart'
    show B2bStageChip, kB2bStages;
import '../../state/lead_filter.dart';
import '../../state/leads_notifier.dart';
import '../leads_theme.dart';
import 'area_picker_sheet.dart';

/// Bottom sheet with the advanced filters: pipeline stage, rating range, min
/// reviews, min branch count, has-Sahel, specialty-only, presence toggles,
/// price band, and whether not-suitable prospects are shown.
class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: LeadsTheme.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const FilterSheet(),
    );
  }

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  static const _branchOptions = <int, String>{
    0: 'Any',
    2: '2+',
    3: '3+',
    6: '6+',
    10: '10+',
  };

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(leadFilterProvider);
    final notifier = ref.read(leadFilterProvider.notifier);

    final catalog = ref.watch(leadsProvider).valueOrNull ?? const [];

    // Distinct areas present in the catalog — same source as the list bar's
    // picker, so both surfaces offer exactly the options that can match.
    final areas = <String>{
      for (final l in catalog)
        if (l.primaryArea.trim().isNotEmpty) l.primaryArea.trim(),
    }.toList()
      ..sort();

    // Distinct price bands present in the catalog.
    final priceBands = <String>{
      for (final l in catalog)
        if (l.priceBand.trim().isNotEmpty) l.priceBand.trim(),
    }.toList()
      ..sort();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: LeadsTheme.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Filters', style: LeadsTheme.heading),
                const Spacer(),
                if (filter.activeAdvancedCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: LeadsTheme.berryPink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${filter.activeAdvancedCount} active',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: LeadsTheme.bodyFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Areas. Reachable from here because the map has no filter bar of
            // its own, and area is one of the two narrowings a rep changes
            // while planning a route.
            _label('Areas'),
            Align(
              alignment: Alignment.centerLeft,
              child: AreaFilterButton(areas: areas),
            ),

            const SizedBox(height: 12),
            // Pipeline stage. "All" is a real chip rather than an implicit
            // empty state, so clearing the narrowing is one tap and the sheet
            // never looks like it has no stage selected by accident.
            _label('Pipeline stage'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: filter.selectedStages.isEmpty,
                  selectedColor: LeadsTheme.blush,
                  showCheckmark: false,
                  onSelected: (_) => notifier.clearStages(),
                ),
                for (final stage in kB2bStages)
                  FilterChip(
                    label: Text(stage),
                    selected: filter.selectedStages.contains(stage),
                    selectedColor:
                        B2bStageChip.colorFor(stage).withValues(alpha: 0.2),
                    checkmarkColor: B2bStageChip.colorFor(stage),
                    onSelected: (_) => notifier.toggleStage(stage),
                  ),
              ],
            ),

            const SizedBox(height: 12),
            _label('Rating range'),
            RangeSlider(
              values: RangeValues(filter.ratingMin, filter.ratingMax),
              min: 0,
              max: 5,
              divisions: 10,
              activeColor: LeadsTheme.berryPink,
              inactiveColor: LeadsTheme.line,
              labels: RangeLabels(
                filter.ratingMin.toStringAsFixed(1),
                filter.ratingMax.toStringAsFixed(1),
              ),
              onChanged: (v) => notifier.update(
                (f) => f.copyWith(ratingMin: v.start, ratingMax: v.end),
              ),
            ),

            const SizedBox(height: 8),
            _label('Minimum reviews: ${filter.minReviews}'),
            Slider(
              value: filter.minReviews.toDouble().clamp(0, 1000),
              min: 0,
              max: 1000,
              divisions: 20,
              activeColor: LeadsTheme.berryPink,
              inactiveColor: LeadsTheme.line,
              label: '${filter.minReviews}',
              onChanged: (v) =>
                  notifier.update((f) => f.copyWith(minReviews: v.round())),
            ),

            const SizedBox(height: 8),
            _label('Minimum branch count'),
            Wrap(
              spacing: 6,
              children: [
                for (final entry in _branchOptions.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: filter.minBranches == entry.key,
                    selectedColor: LeadsTheme.blush,
                    showCheckmark: false,
                    onSelected: (_) => notifier
                        .update((f) => f.copyWith(minBranches: entry.key)),
                  ),
              ],
            ),

            const SizedBox(height: 12),
            _toggle('Has Sahel branches', filter.hasSahel,
                (v) => notifier.update((f) => f.copyWith(hasSahel: v))),
            _toggle('Specialty only', filter.specialtyOnly,
                (v) => notifier.update((f) => f.copyWith(specialtyOnly: v))),
            _toggle('Has phone', filter.hasPhone,
                (v) => notifier.update((f) => f.copyWith(hasPhone: v))),
            _toggle('Has Instagram', filter.hasInstagram,
                (v) => notifier.update((f) => f.copyWith(hasInstagram: v))),
            _toggle('Has website', filter.hasWebsite,
                (v) => notifier.update((f) => f.copyWith(hasWebsite: v))),
            _toggle('Show not suitable', filter.showNotSuitable,
                (v) => notifier.setShowNotSuitable(v)),

            if (priceBands.isNotEmpty) ...[
              const SizedBox(height: 12),
              _label('Price band'),
              Wrap(
                spacing: 6,
                children: [
                  ChoiceChip(
                    label: const Text('Any'),
                    selected: filter.priceBand == null,
                    selectedColor: LeadsTheme.blush,
                    showCheckmark: false,
                    onSelected: (_) =>
                        notifier.update((f) => f.copyWith(priceBand: null)),
                  ),
                  for (final band in priceBands)
                    ChoiceChip(
                      label: Text(band),
                      selected: filter.priceBand == band,
                      selectedColor: LeadsTheme.blush,
                      showCheckmark: false,
                      onSelected: (_) =>
                          notifier.update((f) => f.copyWith(priceBand: band)),
                    ),
                ],
              ),
            ],

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => notifier.clearAdvanced(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LeadsTheme.deepPlum,
                      side: const BorderSide(color: LeadsTheme.line),
                    ),
                    child: const Text('Clear all'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: LeadsTheme.berryPink,
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: LeadsTheme.bodyMuted),
      );

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeThumbColor: LeadsTheme.berryPink,
      title: Text(label, style: LeadsTheme.body),
      value: value,
      onChanged: onChanged,
    );
  }
}
