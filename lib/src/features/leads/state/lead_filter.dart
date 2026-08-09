import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../b2b/presentation/widgets/b2b_stage_chip.dart' show kDefaultB2bStage;
import '../data/models/lead.dart';
import '../domain/lead_clustering.dart';
import 'leads_notifier.dart';
import 'my_location_notifier.dart';

/// How the filtered list is ordered.
///
/// [distance] needs the device position and is ignored without one, so the
/// catalog silently keeps its previous order rather than shuffling into an
/// arbitrary one when a fix is unavailable.
enum LeadSortBy { score, rating, reviews, branches, name, distance }

/// The full set of filters applied to the lead catalog. Immutable; mutate via
/// [copyWith]. Search is case-insensitive and Arabic-friendly.
class LeadFilter {
  final Set<String> selectedTiers;
  /// B2B pipeline stages to keep. EMPTY means "every stage" — unlike
  /// [selectedTiers], where empty means "none". Tiers are a closed grading a
  /// rep always wants some of; stage is an opt-in narrowing, and a filter sheet
  /// that silently emptied the catalog the moment you deselected the last stage
  /// would read as a bug.
  final Set<String> selectedStages;
  final String? selectedCategory;
  final String? selectedArea; // null / '' == all areas
  final String searchText;
  final double ratingMin;
  final double ratingMax;
  final int minReviews;
  final int minBranches;
  final bool hasSahel;
  final bool specialtyOnly;
  final bool hasPhone;
  final bool hasInstagram;
  final bool hasWebsite;
  final String? priceBand;
  /// Whether prospects marked not suitable after manual inspection are shown.
  /// Off by default: a rejected lead should leave the working catalog.
  final bool showNotSuitable;
  final LeadSortBy sortBy;
  final bool sortDescending;

  const LeadFilter({
    this.selectedTiers = const {'A', 'B'},
    this.selectedStages = const {},
    this.selectedCategory,
    this.selectedArea,
    this.searchText = '',
    this.ratingMin = 0.0,
    this.ratingMax = 5.0,
    this.minReviews = 0,
    this.minBranches = 0,
    this.hasSahel = false,
    this.specialtyOnly = false,
    this.hasPhone = false,
    this.hasInstagram = false,
    this.hasWebsite = false,
    this.priceBand,
    this.showNotSuitable = false,
    this.sortBy = LeadSortBy.score,
    this.sortDescending = true,
  });

  LeadFilter copyWith({
    Set<String>? selectedTiers,
    Set<String>? selectedStages,
    Object? selectedCategory = _sentinel,
    Object? selectedArea = _sentinel,
    String? searchText,
    double? ratingMin,
    double? ratingMax,
    int? minReviews,
    int? minBranches,
    bool? hasSahel,
    bool? specialtyOnly,
    bool? hasPhone,
    bool? hasInstagram,
    bool? hasWebsite,
    Object? priceBand = _sentinel,
    bool? showNotSuitable,
    LeadSortBy? sortBy,
    bool? sortDescending,
  }) {
    return LeadFilter(
      selectedTiers: selectedTiers ?? this.selectedTiers,
      selectedStages: selectedStages ?? this.selectedStages,
      selectedCategory: selectedCategory == _sentinel
          ? this.selectedCategory
          : selectedCategory as String?,
      selectedArea:
          selectedArea == _sentinel ? this.selectedArea : selectedArea as String?,
      searchText: searchText ?? this.searchText,
      ratingMin: ratingMin ?? this.ratingMin,
      ratingMax: ratingMax ?? this.ratingMax,
      minReviews: minReviews ?? this.minReviews,
      minBranches: minBranches ?? this.minBranches,
      hasSahel: hasSahel ?? this.hasSahel,
      specialtyOnly: specialtyOnly ?? this.specialtyOnly,
      hasPhone: hasPhone ?? this.hasPhone,
      hasInstagram: hasInstagram ?? this.hasInstagram,
      hasWebsite: hasWebsite ?? this.hasWebsite,
      priceBand:
          priceBand == _sentinel ? this.priceBand : priceBand as String?,
      showNotSuitable: showNotSuitable ?? this.showNotSuitable,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }

  static const _sentinel = Object();

  /// Count of non-default "advanced" filters that are active (used for the
  /// active-filter badge on the filter button).
  int get activeAdvancedCount {
    var count = 0;
    if (ratingMin > 0.0) count++;
    if (ratingMax < 5.0) count++;
    if (minReviews > 0) count++;
    if (minBranches > 0) count++;
    if (hasSahel) count++;
    if (specialtyOnly) count++;
    if (hasPhone) count++;
    if (hasInstagram) count++;
    if (hasWebsite) count++;
    if (priceBand != null && priceBand!.isNotEmpty) count++;
    if (showNotSuitable) count++;
    if (selectedStages.isNotEmpty) count++;
    return count;
  }

  /// A fully reset advanced-filter state (keeps tier/category/area/search).
  LeadFilter clearedAdvanced() {
    return LeadFilter(
      selectedTiers: selectedTiers,
      selectedCategory: selectedCategory,
      selectedArea: selectedArea,
      searchText: searchText,
      sortBy: sortBy,
      sortDescending: sortDescending,
    );
  }
}

/// Holds the current [LeadFilter]. UI mutates it through the exposed helpers.
class LeadFilterNotifier extends Notifier<LeadFilter> {
  @override
  LeadFilter build() => const LeadFilter();

  void set(LeadFilter filter) => state = filter;

  void update(LeadFilter Function(LeadFilter) fn) => state = fn(state);

  void toggleTier(String tier) {
    final next = Set<String>.from(state.selectedTiers);
    if (next.contains(tier)) {
      next.remove(tier);
    } else {
      next.add(tier);
    }
    state = state.copyWith(selectedTiers: next);
  }

  void toggleStage(String stage) {
    final next = Set<String>.from(state.selectedStages);
    if (next.contains(stage)) {
      next.remove(stage);
    } else {
      next.add(stage);
    }
    state = state.copyWith(selectedStages: next);
  }

  void clearStages() => state = state.copyWith(selectedStages: const {});

  void setCategory(String? category) =>
      state = state.copyWith(selectedCategory: category);

  void setArea(String? area) => state = state.copyWith(selectedArea: area);

  void setSearch(String text) => state = state.copyWith(searchText: text);

  void setSort(LeadSortBy sortBy, {bool? descending}) => state =
      state.copyWith(sortBy: sortBy, sortDescending: descending);

  void clearAdvanced() => state = state.clearedAdvanced();

  void setShowNotSuitable(bool value) =>
      state = state.copyWith(showNotSuitable: value);
}

final leadFilterProvider =
    NotifierProvider<LeadFilterNotifier, LeadFilter>(LeadFilterNotifier.new);

String _norm(String value) => value.toLowerCase().trim();

/// Applies every active filter (AND) to the cached catalog, then sorts.
/// Returns an empty list while the catalog is loading / errored.
final filteredLeadsProvider = Provider<List<Lead>>((ref) {
  final catalog = ref.watch(leadsProvider).valueOrNull ?? const <Lead>[];
  final f = ref.watch(leadFilterProvider);
  // Only watched so a "nearest first" sort re-runs when a fix arrives; with
  // any other sort the position is unused and this is inert.
  final origin = ref.watch(myLocationProvider).position;
  return applyLeadFilter(catalog, f, origin: origin);
});

/// Pure filter + sort applied by [filteredLeadsProvider]. Extracted so it can be
/// unit-tested without a network/Hive-backed catalog. Never mutates [catalog];
/// returns a fresh, sorted list.
List<Lead> applyLeadFilter(
  List<Lead> catalog,
  LeadFilter f, {
  LatLng? origin,
}) {
  final query = _norm(f.searchText);
  final result = catalog.where((lead) => _matchesLead(lead, f, query)).toList();
  sortLeads(result, f, origin: origin);
  return result;
}

/// Whether a single [lead] passes every active filter in [f]. [query] is the
/// already-normalized search text (pass '' when searching is not active).
bool _matchesLead(Lead lead, LeadFilter f, String query) {
  // Manual-inspection verdict: rejected prospects are hidden unless asked for.
  if (lead.notSuitable && !f.showNotSuitable) return false;

  // B2B stage: empty selection means "every stage". A lead the backend has
  // never advanced carries an empty stage and counts as the first one.
  if (f.selectedStages.isNotEmpty) {
    final stage = lead.b2bStage.trim();
    if (!f.selectedStages.contains(stage.isEmpty ? kDefaultB2bStage : stage)) {
      return false;
    }
  }

  // Tier: empty selection means "show none".
  if (f.selectedTiers.isNotEmpty) {
    final tier = lead.tier.trim().toUpperCase();
    if (!f.selectedTiers.contains(tier)) return false;
  } else {
    return false;
  }

  // Category.
  if (f.selectedCategory != null && f.selectedCategory!.isNotEmpty) {
    if ((lead.category ?? '') != f.selectedCategory) return false;
  }

  // Area (matches primary area).
  if (f.selectedArea != null && f.selectedArea!.isNotEmpty) {
    if (lead.primaryArea != f.selectedArea) return false;
  }

  // Rating range (leads with no rating pass only when range is the default).
  final rating = lead.avgRating;
  if (rating != null) {
    if (rating < f.ratingMin || rating > f.ratingMax) return false;
  } else if (f.ratingMin > 0.0) {
    return false;
  }

  if (lead.totalReviews < f.minReviews) return false;
  if (lead.branchCount < f.minBranches) return false;

  if (f.hasSahel && lead.sahelBranches <= 0) return false;
  if (f.specialtyOnly && !lead.isSpecialty) return false;

  if (f.hasPhone && lead.phone.trim().isEmpty) return false;
  if (f.hasInstagram && lead.instagram.trim().isEmpty) return false;
  if (f.hasWebsite && lead.website.trim().isEmpty) return false;

  if (f.priceBand != null && f.priceBand!.isNotEmpty) {
    if (lead.priceBand != f.priceBand) return false;
  }

  // Search across name + areas + category (case-insensitive, Arabic-safe).
  if (query.isNotEmpty) {
    final haystack = [
      lead.leadName,
      lead.primaryArea,
      lead.category ?? '',
      ...lead.areas,
      ...lead.regions,
      ...lead.governorates,
      lead.phone,
      lead.instagram,
    ].map(_norm).join(' ');
    if (!haystack.contains(query)) return false;
  }

  return true;
}

/// Sorts [leads] in place per [f]'s sort key + direction.
///
/// [origin] is required only by [LeadSortBy.distance]; without it that sort is
/// a no-op, because ordering by a distance nobody can compute would silently
/// reorder the catalog for no reason the rep could see.
void sortLeads(List<Lead> leads, LeadFilter f, {LatLng? origin}) {
  if (f.sortBy == LeadSortBy.distance) {
    if (origin == null) return;
    final byDistance = sortByDistance(leads, origin);
    leads
      ..clear()
      ..addAll(f.sortDescending ? byDistance.reversed : byDistance);
    return;
  }

  int cmp(Lead a, Lead b) {
    switch (f.sortBy) {
      case LeadSortBy.score:
        return a.score.compareTo(b.score);
      case LeadSortBy.rating:
        return (a.avgRating ?? -1).compareTo(b.avgRating ?? -1);
      case LeadSortBy.reviews:
        return a.totalReviews.compareTo(b.totalReviews);
      case LeadSortBy.branches:
        return a.branchCount.compareTo(b.branchCount);
      case LeadSortBy.name:
        return a.leadName.toLowerCase().compareTo(b.leadName.toLowerCase());
      case LeadSortBy.distance:
        return 0; // handled above, where the origin is in scope
    }
  }

  leads.sort((a, b) {
    final base = cmp(a, b);
    return f.sortDescending ? -base : base;
  });
}
