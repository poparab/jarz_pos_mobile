import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../data/models/lead.dart';
import '../../domain/lead_clustering.dart';
import '../../state/lead_categories_notifier.dart';
import '../../state/lead_filter.dart';
import '../../state/leads_notifier.dart';
import '../../state/my_location_notifier.dart';
import '../leads_theme.dart';
import '../widgets/area_picker_sheet.dart';
import '../widgets/category_chip.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/lead_card.dart';
import '../widgets/tier_pill.dart';

/// The main leads research screen: summary bar + always-visible filters +
/// a virtualized list. Stays smooth with 1,300+ rows via [ListView.builder].
class LeadsListScreen extends ConsumerStatefulWidget {
  const LeadsListScreen({super.key});

  @override
  ConsumerState<LeadsListScreen> createState() => _LeadsListScreenState();
}

class _LeadsListScreenState extends ConsumerState<LeadsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(leadFilterProvider).searchText;
    // Revalidate whenever the screen is entered. The catalog is a Hive-backed
    // cache and every filter runs against it client-side, so a stage or
    // suitability change made on the server — by this rep on the detail screen,
    // or by a colleague — would otherwise keep filtering against stale rows
    // until someone thought to press refresh. The refresh keeps the current
    // rows on screen while it runs, so this is invisible when nothing changed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(leadsProvider.notifier).refresh();
    });
  }

  /// Opens a lead and revalidates on the way back, so an edit made in there is
  /// reflected by the filters immediately rather than after a manual refresh.
  Future<void> _openLead(String name) async {
    await context.push('/leads/${Uri.encodeComponent(name)}');
    if (mounted) ref.read(leadsProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(leadsProvider);
    final filtered = ref.watch(filteredLeadsProvider);
    final filter = ref.watch(leadFilterProvider);
    final origin = ref.watch(myLocationProvider).position;

    return Scaffold(
      backgroundColor: LeadsTheme.bg,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: LeadsTheme.deepPlum,
        elevation: 0,
        title: Text(
          context.l10n.leadsTitle,
          style: LeadsTheme.heading.copyWith(fontSize: 22),
        ),
        actions: [
          IconButton(
            tooltip: context.l10n.leadsMapViewTooltip,
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.push(AppRoutes.leadsMap),
          ),
          IconButton(
            tooltip: context.l10n.leadsRefreshTooltip,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(leadsProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: LeadsTheme.berryPink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(context.l10n.leadsAddLead),
        onPressed: () => context.push(AppRoutes.leadForm),
      ),
      body: leadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(
          message: '$err',
          onRetry: () => ref.read(leadsProvider.notifier).refresh(),
        ),
        data: (_) => Column(
          children: [
            _SummaryBar(filtered: filtered),
            _FilterBar(
              filter: filter,
              searchController: _searchController,
            ),
            const Divider(height: 1, color: LeadsTheme.line),
            Expanded(
              // Pull-to-refresh as well as the automatic revalidation: when a
              // rep is already looking at the list and knows something changed,
              // the gesture is faster than leaving and coming back.
              child: RefreshIndicator(
                color: LeadsTheme.berryPink,
                onRefresh: () => ref.read(leadsProvider.notifier).refresh(),
                // AlwaysScrollable so the pull gesture is available even when
                // the filters have left too few rows to fill the viewport —
                // which is exactly when a rep most wants to re-check.
                child: filtered.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 80),
                          _EmptyState(),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 4, bottom: 96),
                        itemCount: filtered.length,
                        itemExtent: null,
                        itemBuilder: (context, index) {
                          final lead = filtered[index];
                          return LeadCard(
                            key: ValueKey(lead.name),
                            lead: lead,
                            distanceMetres: origin == null
                                ? null
                                : metresToLead(origin, lead),
                            onTap: () => _openLead(lead.name),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.filtered});

  final List<Lead> filtered;

  @override
  Widget build(BuildContext context) {
    final tierA =
        filtered.where((l) => l.tier.trim().toUpperCase() == 'A').length;
    final totalBranches =
        filtered.fold<int>(0, (sum, l) => sum + l.branchCount);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _Stat(
              label: context.l10n.leadsStatShowing,
              value: '${filtered.length}'),
          _Stat(label: context.l10n.leadsStatTierA, value: '$tierA'),
          _Stat(
              label: context.l10n.leadsStatBranches,
              value: '$totalBranches'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: LeadsTheme.bodyFont,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: LeadsTheme.deepPlum,
              fontFeatures: LeadsTheme.tabular,
            ),
          ),
          Text(label, style: LeadsTheme.bodyMuted),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filter, required this.searchController});

  final LeadFilter filter;
  final TextEditingController searchController;

  static const _tiers = ['A', 'B', 'C', 'REF'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(leadFilterProvider.notifier);
    final categoriesAsync = ref.watch(leadCategoriesProvider);
    final catalog = ref.watch(leadsProvider).valueOrNull ?? const [];

    final areas = <String>{
      for (final l in catalog)
        if (l.primaryArea.trim().isNotEmpty) l.primaryArea.trim(),
    }.toList()
      ..sort();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          // Search + advanced filter + sort.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: notifier.setSearch,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: context.l10n.leadsSearchHint,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: filter.searchText.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                searchController.clear();
                                notifier.setSearch('');
                              },
                            ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      filled: true,
                      fillColor: LeadsTheme.bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: LeadsTheme.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: LeadsTheme.line),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _FilterButton(count: filter.activeAdvancedCount),
                _SortButton(filter: filter),
              ],
            ),
          ),
          // Category chips.
          SizedBox(
            height: 34,
            child: categoriesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (categories) => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  CategoryChip(
                    category: null,
                    selected: filter.selectedCategory == null,
                    onTap: () => notifier.setCategory(null),
                  ),
                  for (final cat in categories)
                    CategoryChip(
                      category: cat,
                      selected: filter.selectedCategory == cat.name,
                      onTap: () => notifier.setCategory(
                        filter.selectedCategory == cat.name ? null : cat.name,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Tier chips + area dropdown.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (final tier in _tiers)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => notifier.toggleTier(tier),
                      child: Opacity(
                        opacity:
                            filter.selectedTiers.contains(tier) ? 1.0 : 0.35,
                        child: TierPill(tier),
                      ),
                    ),
                  ),
                const Spacer(),
                AreaFilterButton(areas: areas),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: context.l10n.leadsAdvancedFilters,
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

class _SortButton extends ConsumerWidget {
  const _SortButton({required this.filter});

  final LeadFilter filter;

  static Map<LeadSortBy, String> _labels(BuildContext context) {
    final l10n = context.l10n;
    return <LeadSortBy, String>{
      LeadSortBy.score: l10n.leadsSortScore,
      LeadSortBy.rating: l10n.leadsSortRating,
      LeadSortBy.reviews: l10n.leadsSortReviews,
      LeadSortBy.branches: l10n.leadsSortBranches,
      LeadSortBy.name: l10n.leadsSortName,
      LeadSortBy.distance: l10n.leadsSortNearest,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(leadFilterProvider.notifier);
    return PopupMenuButton<LeadSortBy>(
      tooltip: context.l10n.leadsSortTooltip,
      icon: const Icon(Icons.sort, color: LeadsTheme.deepPlum),
      onSelected: (sortBy) {
        // "Nearest" is meaningless without a fix, and silently doing nothing
        // would read as a broken menu item — so choosing it asks for one.
        if (sortBy == LeadSortBy.distance &&
            ref.read(myLocationProvider).position == null) {
          ref.read(myLocationProvider.notifier).locate();
        }
        // Tapping the current sort toggles direction.
        final descending =
            filter.sortBy == sortBy ? !filter.sortDescending : true;
        notifier.setSort(sortBy, descending: descending);
      },
      itemBuilder: (context) => [
        for (final entry in _labels(context).entries)
          PopupMenuItem<LeadSortBy>(
            value: entry.key,
            child: Row(
              children: [
                Text(entry.value),
                const Spacer(),
                if (filter.sortBy == entry.key)
                  Icon(
                    filter.sortDescending
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    size: 16,
                    color: LeadsTheme.berryPink,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 48, color: LeadsTheme.muted),
          const SizedBox(height: 8),
          Text(context.l10n.leadsEmptyFiltered,
              style: LeadsTheme.bodyMuted),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: LeadsTheme.muted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: LeadsTheme.bodyMuted,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              style:
                  FilledButton.styleFrom(backgroundColor: LeadsTheme.berryPink),
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
