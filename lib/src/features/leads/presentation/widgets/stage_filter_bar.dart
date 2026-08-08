import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../b2b/presentation/widgets/b2b_stage_chip.dart'
    show B2bStageChip, kB2bStages;
import '../../state/lead_filter.dart';

/// A horizontally scrollable strip of B2B pipeline-stage chips bound to the
/// shared [leadFilterProvider].
///
/// Exists because the map has no room for the full filter sheet but stage is
/// the axis a rep changes constantly while planning a route ("show me only
/// Qualify around here"). Writing to the same provider as the sheet means the
/// map, the list and the sheet can never disagree about what is filtered.
///
/// "All" is a real chip rather than an implicit empty state, so clearing the
/// narrowing is one tap and an empty selection never looks accidental.
class StageFilterBar extends ConsumerWidget {
  const StageFilterBar({super.key, this.backgroundColor});

  /// Painted behind the strip when it floats over content (the map).
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      leadFilterProvider.select((f) => f.selectedStages),
    );
    final notifier = ref.read(leadFilterProvider.notifier);

    return Container(
      color: backgroundColor,
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: ChoiceChip(
              label: const Text('All stages'),
              selected: selected.isEmpty,
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
              onSelected: (_) => notifier.clearStages(),
            ),
          ),
          for (final stage in kB2bStages)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: FilterChip(
                label: Text(stage),
                selected: selected.contains(stage),
                visualDensity: VisualDensity.compact,
                selectedColor:
                    B2bStageChip.colorFor(stage).withValues(alpha: 0.2),
                checkmarkColor: B2bStageChip.colorFor(stage),
                onSelected: (_) => notifier.toggleStage(stage),
              ),
            ),
        ],
      ),
    );
  }
}
