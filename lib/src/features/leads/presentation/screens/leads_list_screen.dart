import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../data/models/lead.dart';
import '../../state/lead_categories_notifier.dart';
import '../../state/lead_filter.dart';
import '../../state/leads_notifier.dart';
import '../leads_theme.dart';
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

    return Scaffold(
      backgroundColor: LeadsTheme.bg,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: LeadsTheme.deepPlum,
        elevation: 0,
        title: Text(
          'Leads',
          style: LeadsTheme.heading.copyWith(fontSize: 22),
        ),
        actions: [
          IconButton(
            tooltip: 'Map view',
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.push(AppRoutes.leadsMap),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(leadsProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: LeadsTheme.berryPink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add lead'),
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
              child: filtered.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 96),
                      itemCount: filtered.length,
                      itemExtent: null,
                      itemBuilder: (context, index) {
                        final lead = filtered[index];
                        return LeadCard(
                          key: ValueKey(lead.name),
                          lead: lead,
                          onTap: () => context.push(
                            '/leads/${Uri.encodeComponent(lead.name)}',
                          ),
                        );
                      },
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
          _Stat(label: 'Showing', value: '${filtered.length}'),
          _Stat(label: 'Tier A', value: '$tierA'),
          _Stat(label: 'Branches', value: '$totalBranches'),
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
                      hintText: 'Search leads…',
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
                _AreaDropdown(areas: areas, selected: filter.selectedArea),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaDropdown extends ConsumerWidget {
  const _AreaDropdown({required this.areas, required this.selected});

  final List<String> areas;
  final String? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        value: selected,
        hint: const Text('All areas', style: LeadsTheme.bodyMuted),
        isDense: true,
        icon: const Icon(Icons.expand_more, size: 18),
        style: LeadsTheme.body,
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('All areas'),
          ),
          for (final area in areas)
            DropdownMenuItem<String?>(value: area, child: Text(area)),
        ],
        onChanged: (value) =>
            ref.read(leadFilterProvider.notifier).setArea(value),
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

class _SortButton extends ConsumerWidget {
  const _SortButton({required this.filter});

  final LeadFilter filter;

  static const _labels = <LeadSortBy, String>{
    LeadSortBy.score: 'Score',
    LeadSortBy.rating: 'Rating',
    LeadSortBy.reviews: 'Reviews',
    LeadSortBy.branches: 'Branches',
    LeadSortBy.name: 'Name',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(leadFilterProvider.notifier);
    return PopupMenuButton<LeadSortBy>(
      tooltip: 'Sort',
      icon: const Icon(Icons.sort, color: LeadsTheme.deepPlum),
      onSelected: (sortBy) {
        // Tapping the current sort toggles direction.
        final descending =
            filter.sortBy == sortBy ? !filter.sortDescending : true;
        notifier.setSort(sortBy, descending: descending);
      },
      itemBuilder: (context) => [
        for (final entry in _labels.entries)
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
        children: const [
          Icon(Icons.search_off, size: 48, color: LeadsTheme.muted),
          SizedBox(height: 8),
          Text('No leads match these filters', style: LeadsTheme.bodyMuted),
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
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
