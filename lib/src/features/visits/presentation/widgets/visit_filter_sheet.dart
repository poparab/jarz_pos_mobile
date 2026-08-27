import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../leads/state/lead_categories_notifier.dart';
import '../../../leads/state/leads_notifier.dart';
import '../../state/visit_builder_notifier.dart';

/// Narrow the pool of doors the builder offers.
///
/// A separate sheet rather than more controls on the builder because these are
/// answers to a different question: the builder page asks "what does my day
/// look like", these ask "which doors are even candidates". Mixing the two is
/// how a planning screen turns into a form.
///
/// Deliberately a small set. The leads catalog has a dozen more filters, but
/// most of them (rating, review count, price band) are research questions, and
/// a rep choosing where to drive on Saturday is past that.
Future<void> showVisitFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _VisitFilterSheet(),
  );
}

class _VisitFilterSheet extends ConsumerWidget {
  const _VisitFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(visitBuilderProvider);
    final notifier = ref.read(visitBuilderProvider.notifier);
    final categories = ref.watch(leadCategoriesProvider).valueOrNull ?? const [];
    final areas = ref.watch(visitTargetAreasProvider);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l10n.visitFilters,
                        style: theme.textTheme.titleMedium),
                  ),
                  TextButton(
                    onPressed: notifier.clearFilters,
                    child: Text(l10n.visitClearFilters),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  _Label(text: l10n.visitFilterTier),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        for (final tier in const ['A', 'B', 'C'])
                          ChoiceChip(
                            label: Text(tier),
                            selected: state.tier == tier,
                            onSelected: (on) =>
                                notifier.setTier(on ? tier : null),
                          ),
                      ],
                    ),
                  ),
                  if (categories.isNotEmpty) ...[
                    _Label(text: l10n.visitFilterCategory),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final category in categories)
                            ChoiceChip(
                              label: Text(category.name),
                              selected: state.category == category.name,
                              onSelected: (on) => notifier
                                  .setCategory(on ? category.name : null),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (areas.isNotEmpty) ...[
                    _Label(text: l10n.visitFilterArea),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final area in areas)
                            ChoiceChip(
                              label: Text(area),
                              selected: state.area == area,
                              onSelected: (on) =>
                                  notifier.setArea(on ? area : null),
                            ),
                        ],
                      ),
                    ),
                  ],
                  _Label(text: l10n.visitFilterMinFit(state.minFitScore.round())),
                  Slider(
                    value: state.minFitScore.clamp(0, 100),
                    max: 100,
                    divisions: 20,
                    label: state.minFitScore.round().toString(),
                    onChanged: notifier.setMinFitScore,
                  ),
                  SwitchListTile(
                    dense: true,
                    value: state.specialtyOnly,
                    onChanged: notifier.setSpecialtyOnly,
                    title: Text(l10n.visitFilterSpecialty),
                  ),
                  SwitchListTile(
                    dense: true,
                    value: state.neverVisitedOnly,
                    onChanged: notifier.setNeverVisitedOnly,
                    title: Text(l10n.visitFilterNeverVisited),
                    subtitle: Text(
                      l10n.visitFilterNeverVisitedHint,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  SwitchListTile(
                    dense: true,
                    value: state.includeCustomers,
                    onChanged: notifier.setIncludeCustomers,
                    title: Text(l10n.visitIncludeCustomers),
                    subtitle: Text(
                      l10n.visitIncludeCustomersHint,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonDone),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Every area the corpus actually has doors in.
///
/// Derived from the cached lead catalog, NOT from the filtered candidate list.
/// That distinction is the whole point: candidates are already narrowed BY the
/// area filter, so sourcing the options from them would collapse the list to
/// the one area currently chosen and leave no way to switch to another.
///
/// Branch areas rather than the brand's primary area, because a visit target
/// is a door and a chain's branches sit in different areas.
final visitTargetAreasProvider = Provider.autoDispose<List<String>>((ref) {
  final leads = ref.watch(leadsProvider).valueOrNull ?? const [];
  final areas = <String>{};
  for (final lead in leads) {
    for (final location in lead.locations) {
      final area = location.area.trim();
      if (area.isNotEmpty) areas.add(area);
    }
    if (lead.locations.isEmpty && lead.primaryArea.trim().isNotEmpty) {
      areas.add(lead.primaryArea.trim());
    }
  }
  final sorted = areas.toList()..sort();
  return sorted;
});

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}
