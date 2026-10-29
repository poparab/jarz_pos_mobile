import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../data/followup_results.dart';
import '../../state/followups_providers.dart';
import '../widgets/followup_results_calls.dart';
import '../widgets/followup_results_common.dart';
import '../widgets/followup_results_messages.dart';
import '../widgets/followup_results_overview.dart';

/// The manager's follow-up results: what was sent to whom, who answered and
/// what they said, the orders that followed, and what it all cost. One date
/// range drives every tab.
class FollowupResultsScreen extends ConsumerWidget {
  const FollowupResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final canPop = Navigator.of(context).canPop();
    // Only the Messages tab watches the filter, and TabBarView unmounts tabs
    // off screen, so without this the autoDispose filter is dropped the moment
    // "all messages to this customer" sets it from Replies or Orders.
    ref.listen(followupMessageFilterProvider, (_, _) {});

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          // Opened from Follow-ups there is a screen to go back to; opened from
          // the drawer's own entry there is not, and the hamburger shows.
          leading: canPop ? const BackButton() : null,
          title: Text(l10n.followupResultsTitle),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: l10n.followupResultsTabOverview),
              Tab(text: l10n.followupResultsTabMessages),
              Tab(text: l10n.followupResultsTabReplies),
              Tab(text: l10n.followupResultsTabOrders),
              Tab(text: l10n.followupResultsTabCalls),
            ],
          ),
        ),
        body: const Column(
          children: [
            _RangeBar(),
            Expanded(
              child: TabBarView(
                children: [
                  FollowupResultsOverview(),
                  FollowupResultsMessages(),
                  FollowupResultsReplies(),
                  FollowupResultsOrders(),
                  FollowupResultsCalls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick ranges plus a custom one, centred like the content below it.
class _RangeBar extends ConsumerWidget {
  const _RangeBar();

  Future<void> _pickCustom(BuildContext context, WidgetRef ref) async {
    final current = ref.read(followupResultsRangeProvider);
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: DateTimeRange(start: current.from, end: current.to),
      helpText: context.l10n.followupResultsRangePickerHelp,
    );
    if (picked == null) return;
    ref.read(followupResultsRangeProvider.notifier).state =
        FollowupRange.custom(picked.start, picked.end);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(followupResultsRangeProvider);

    void select(FollowupRangePreset p) =>
        ref.read(followupResultsRangeProvider.notifier).state =
            FollowupRange.preset(p);

    Widget chip(String label, FollowupRangePreset p) => ChoiceChip(
      label: Text(label),
      selected: range.preset == p,
      visualDensity: VisualDensity.compact,
      onSelected: (_) => select(p),
    );

    final customLabel = range.preset == FollowupRangePreset.custom
        ? '${formatDate(context, range.from, pattern: 'MMM d')} – '
              '${formatDate(context, range.to, pattern: 'MMM d')}'
        : l10n.followupResultsRangeCustom;

    return LayoutBuilder(
      builder: (context, c) {
        final pad = resultsPadding(c.maxWidth, top: 8, bottom: 4);
        return Padding(
          padding: pad,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                chip(l10n.followupResultsRange7, FollowupRangePreset.last7),
                const SizedBox(width: 8),
                chip(l10n.followupResultsRange30, FollowupRangePreset.last30),
                const SizedBox(width: 8),
                chip(
                  l10n.followupResultsRangeMonth,
                  FollowupRangePreset.thisMonth,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.date_range, size: 18),
                  label: Text(customLabel),
                  selected: range.preset == FollowupRangePreset.custom,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => _pickCustom(context, ref),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
