import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/leads/data/models/lead.dart';
import 'package:jarz_pos/src/features/leads/state/lead_filter.dart';

/// Builds a diverse in-memory catalog of leads for exercising the filter/sort.
List<Lead> _catalog() => const [
      // 0: Tier A, Restaurant, Zamalek, high rating, many reviews, sahel, phone+ig+web
      Lead(
        name: 'L-A1',
        leadName: 'Zooba',
        category: 'Restaurant',
        score: 90,
        tier: 'A',
        branchCount: 4,
        priceBand: r'$$',
        avgRating: 4.6,
        totalReviews: 1200,
        sahelBranches: 2,
        isSpecialty: true,
        primaryArea: 'Zamalek',
        areas: ['Zamalek', 'Sahel'],
        regions: ['Cairo'],
        governorates: ['Cairo'],
        phone: '+2011',
        instagram: '@zooba',
        website: 'https://zooba.com',
      ),
      // 1: Tier B, Cafe, Maadi, mid rating, some reviews, no sahel
      Lead(
        name: 'L-B1',
        leadName: 'Cilantro',
        category: 'Cafe',
        score: 55,
        tier: 'B',
        branchCount: 12,
        priceBand: r'$',
        avgRating: 4.1,
        totalReviews: 300,
        sahelBranches: 0,
        isSpecialty: false,
        primaryArea: 'Maadi',
        areas: ['Maadi'],
        phone: '+2012',
        instagram: '@cilantro',
      ),
      // 2: Tier C — excluded by default tiers
      Lead(
        name: 'L-C1',
        leadName: 'Local Diner',
        category: 'Restaurant',
        score: 30,
        tier: 'C',
        branchCount: 1,
        avgRating: 3.2,
        totalReviews: 20,
        primaryArea: 'Nasr City',
        areas: ['Nasr City'],
      ),
      // 3: Tier REF — excluded by default tiers
      Lead(
        name: 'L-REF1',
        leadName: 'Referral Co',
        category: 'Cafe',
        score: 70,
        tier: 'REF',
        branchCount: 6,
        avgRating: 4.9,
        totalReviews: 500,
        primaryArea: 'Zamalek',
        areas: ['Zamalek'],
      ),
      // 4: Tier A, Bakery, Sahel, high branches, sahel branches, no rating
      Lead(
        name: 'L-A2',
        leadName: 'TBS Bakery',
        category: 'Bakery',
        score: 80,
        tier: 'A',
        branchCount: 15,
        priceBand: r'$$',
        avgRating: null,
        totalReviews: 0,
        sahelBranches: 3,
        isSpecialty: false,
        primaryArea: 'Sahel',
        areas: ['Sahel', 'North Coast'],
        regions: ['North Coast'],
        website: 'https://tbs.com',
      ),
      // 5: Tier B, Restaurant, Zamalek, Arabic name, specialty, 2 branches
      Lead(
        name: 'L-B2',
        leadName: 'كشري التحرير',
        category: 'Restaurant',
        score: 60,
        tier: 'B',
        branchCount: 2,
        avgRating: 4.3,
        totalReviews: 150,
        sahelBranches: 0,
        isSpecialty: true,
        primaryArea: 'Zamalek',
        areas: ['Zamalek'],
        phone: '+2015',
      ),
      // 6: Tier A, Cafe, Maadi, low rating (below range tests), 3 branches
      Lead(
        name: 'L-A3',
        leadName: 'Beano\'s',
        category: 'Cafe',
        score: 45,
        tier: 'A',
        branchCount: 3,
        priceBand: r'$',
        avgRating: 3.5,
        totalReviews: 90,
        sahelBranches: 0,
        primaryArea: 'Maadi',
        areas: ['Maadi'],
        instagram: '@beanos',
      ),
      // 7: Tier B, Restaurant, Zamalek, 10 branches, high rating, no contacts
      Lead(
        name: 'L-B3',
        leadName: 'Abou Tarek',
        category: 'Restaurant',
        score: 65,
        tier: 'B',
        branchCount: 10,
        avgRating: 4.8,
        totalReviews: 2000,
        sahelBranches: 1,
        primaryArea: 'Downtown',
        areas: ['Downtown'],
      ),
    ];

/// Convenience: the `name`s of the filtered result, in order.
List<String> _names(List<Lead> leads) => leads.map((l) => l.name).toList();

void main() {
  final catalog = _catalog();

  group('default filter', () {
    test('default tiers {A,B} exclude C and REF', () {
      final result = applyLeadFilter(catalog, const LeadFilter());
      final tiers = result.map((l) => l.tier).toSet();
      expect(tiers, containsAll(['A', 'B']));
      expect(tiers.contains('C'), isFalse);
      expect(tiers.contains('REF'), isFalse);
      expect(_names(result), isNot(contains('L-C1')));
      expect(_names(result), isNot(contains('L-REF1')));
    });

    test('empty tier selection shows none', () {
      final result =
          applyLeadFilter(catalog, const LeadFilter(selectedTiers: {}));
      expect(result, isEmpty);
    });
  });

  group('tier multi-select', () {
    test('selecting only C returns just C leads', () {
      final result =
          applyLeadFilter(catalog, const LeadFilter(selectedTiers: {'C'}));
      expect(_names(result), ['L-C1']);
    });

    test('selecting A, B, C, REF returns the whole catalog', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(selectedTiers: {'A', 'B', 'C', 'REF'}),
      );
      expect(result, hasLength(catalog.length));
    });
  });

  group('category', () {
    test('filters to a single category', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          selectedCategory: 'Cafe',
        ),
      );
      expect(result.every((l) => l.category == 'Cafe'), isTrue);
      expect(_names(result), containsAll(['L-B1', 'L-REF1', 'L-A3']));
    });
  });

  group('area', () {
    test('matches primary area', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          selectedAreas: {'Zamalek'},
        ),
      );
      expect(result.every((l) => l.primaryArea == 'Zamalek'), isTrue);
      expect(_names(result), containsAll(['L-A1', 'L-REF1', 'L-B2']));
    });

    test('empty selection means every area', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(selectedTiers: {'A', 'B', 'C', 'REF'}),
      );
      expect(result, hasLength(catalog.length));
    });

    test('several areas at once are an OR, not successive narrowing', () {
      // The whole point of the change: one trip covers several
      // neighbourhoods, so picking two must widen the result, not empty it.
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          selectedAreas: {'Zamalek', 'Maadi'},
        ),
      );
      expect(
        _names(result).toSet(),
        {'L-A1', 'L-REF1', 'L-B2', 'L-B1', 'L-A3'},
      );
      expect(_names(result), isNot(contains('L-C1'))); // Nasr City
      expect(_names(result), isNot(contains('L-B3'))); // Downtown
    });

    test('adding an area never shrinks the result', () {
      const oneArea = LeadFilter(
        selectedTiers: {'A', 'B', 'C', 'REF'},
        selectedAreas: {'Zamalek'},
      );
      const twoAreas = LeadFilter(
        selectedTiers: {'A', 'B', 'C', 'REF'},
        selectedAreas: {'Zamalek', 'Downtown'},
      );
      expect(
        applyLeadFilter(catalog, twoAreas).length,
        greaterThan(applyLeadFilter(catalog, oneArea).length),
      );
    });

    test('an area nothing sits in returns nothing', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          selectedAreas: {'Alexandria'},
        ),
      );
      expect(result, isEmpty);
    });

    test('area ANDs with the other filters rather than replacing them', () {
      // Zamalek OR Maadi, but only tier B — the area set widens within
      // itself and still intersects everything else.
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'B'},
          selectedAreas: {'Zamalek', 'Maadi'},
        ),
      );
      expect(_names(result).toSet(), {'L-B1', 'L-B2'});
    });

    test('clearedAdvanced keeps the area selection', () {
      const on = LeadFilter(selectedAreas: {'Zamalek', 'Maadi'});
      expect(on.clearedAdvanced().selectedAreas, {'Zamalek', 'Maadi'});
    });
  });

  group('search', () {
    test('case-insensitive name match', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(searchText: 'ZOOBA'),
      );
      expect(_names(result), ['L-A1']);
    });

    test('Arabic name match', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(searchText: 'كشري'),
      );
      expect(_names(result), ['L-B2']);
    });

    test('matches on area text', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          searchText: 'maadi',
        ),
      );
      expect(_names(result), containsAll(['L-B1', 'L-A3']));
    });

    test('matches on phone', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(searchText: '+2015'),
      );
      expect(_names(result), ['L-B2']);
    });
  });

  group('rating', () {
    test('rating range excludes below-min and unrated leads', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          ratingMin: 4.5,
        ),
      );
      // Only leads with avgRating >= 4.5: Zooba (4.6), Abou Tarek (4.8),
      // Referral Co (4.9). TBS has null rating -> excluded once min > 0.
      expect(_names(result), containsAll(['L-A1', 'L-B3', 'L-REF1']));
      expect(_names(result), isNot(contains('L-A2')));
      expect(_names(result), isNot(contains('L-A3')));
    });

    test('rating max caps the upper bound', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          ratingMax: 3.5,
        ),
      );
      // Only leads rated <= 3.5: Local Diner (3.2), Beano's (3.5).
      // TBS (null) passes because ratingMin is still default 0.0.
      expect(_names(result), containsAll(['L-C1', 'L-A3', 'L-A2']));
      expect(_names(result), isNot(contains('L-A1')));
    });
  });

  group('min reviews', () {
    test('excludes leads below the review threshold', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          minReviews: 500,
        ),
      );
      expect(result.every((l) => l.totalReviews >= 500), isTrue);
      expect(_names(result), containsAll(['L-A1', 'L-REF1', 'L-B3']));
    });
  });

  group('min branches', () {
    test('Any (0) keeps all', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(selectedTiers: {'A', 'B', 'C', 'REF'}, minBranches: 0),
      );
      expect(result, hasLength(catalog.length));
    });

    test('2+ excludes single-branch leads', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(selectedTiers: {'A', 'B', 'C', 'REF'}, minBranches: 2),
      );
      expect(result.every((l) => l.branchCount >= 2), isTrue);
      expect(_names(result), isNot(contains('L-C1'))); // 1 branch
    });

    test('3+', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(selectedTiers: {'A', 'B', 'C', 'REF'}, minBranches: 3),
      );
      expect(result.every((l) => l.branchCount >= 3), isTrue);
      expect(_names(result), isNot(contains('L-B2'))); // 2 branches
    });

    test('6+', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(selectedTiers: {'A', 'B', 'C', 'REF'}, minBranches: 6),
      );
      expect(result.every((l) => l.branchCount >= 6), isTrue);
      expect(_names(result), containsAll(['L-B1', 'L-REF1', 'L-A2', 'L-B3']));
    });

    test('10+', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(selectedTiers: {'A', 'B', 'C', 'REF'}, minBranches: 10),
      );
      expect(result.every((l) => l.branchCount >= 10), isTrue);
      expect(_names(result), containsAll(['L-B1', 'L-A2', 'L-B3']));
    });
  });

  group('has-Sahel', () {
    test('keeps only leads with sahel branches', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(selectedTiers: {'A', 'B', 'C', 'REF'}, hasSahel: true),
      );
      expect(result.every((l) => l.sahelBranches > 0), isTrue);
      expect(_names(result), containsAll(['L-A1', 'L-A2', 'L-B3']));
    });
  });

  group('specialty-only', () {
    test('keeps only specialty leads', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          specialtyOnly: true,
        ),
      );
      expect(result.every((l) => l.isSpecialty), isTrue);
      expect(_names(result), containsAll(['L-A1', 'L-B2']));
    });
  });

  group('has contact', () {
    test('has phone', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(selectedTiers: {'A', 'B', 'C', 'REF'}, hasPhone: true),
      );
      expect(result.every((l) => l.phone.trim().isNotEmpty), isTrue);
      expect(_names(result), containsAll(['L-A1', 'L-B1', 'L-B2']));
    });

    test('has instagram', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          hasInstagram: true,
        ),
      );
      expect(result.every((l) => l.instagram.trim().isNotEmpty), isTrue);
      expect(_names(result), containsAll(['L-A1', 'L-B1', 'L-A3']));
    });

    test('has website', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          hasWebsite: true,
        ),
      );
      expect(result.every((l) => l.website.trim().isNotEmpty), isTrue);
      expect(_names(result), containsAll(['L-A1', 'L-A2']));
    });
  });

  group('AND composition', () {
    test('two filters together return only rows matching both', () {
      // Tier A AND has-Sahel: from {A1, A2, A3} only A1 and A2 have sahel.
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(selectedTiers: {'A'}, hasSahel: true),
      );
      expect(_names(result), containsAll(['L-A1', 'L-A2']));
      expect(result.every((l) => l.tier == 'A' && l.sahelBranches > 0), isTrue);
      expect(_names(result), isNot(contains('L-B3'))); // B tier w/ sahel
    });

    test('category AND rating range narrows further than either alone', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          selectedCategory: 'Restaurant',
          ratingMin: 4.5,
        ),
      );
      // Restaurants rated >= 4.5: Zooba (4.6), Abou Tarek (4.8).
      expect(_names(result), containsAll(['L-A1', 'L-B3']));
      expect(result.every((l) => l.category == 'Restaurant'), isTrue);
      expect(result.every((l) => (l.avgRating ?? 0) >= 4.5), isTrue);
    });
  });

  group('sorting', () {
    test('score descending is the default order', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(selectedTiers: {'A', 'B', 'C', 'REF'}),
      );
      final scores = result.map((l) => l.score).toList();
      final sorted = [...scores]..sort((a, b) => b.compareTo(a));
      expect(scores, sorted);
      expect(scores.first, 90); // Zooba tops the list
    });

    test('score ascending flips the order', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          sortDescending: false,
        ),
      );
      final scores = result.map((l) => l.score).toList();
      final sorted = [...scores]..sort();
      expect(scores, sorted);
      expect(scores.first, 30); // Local Diner is lowest
    });

    test('sort by branches descending', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          sortBy: LeadSortBy.branches,
        ),
      );
      final branches = result.map((l) => l.branchCount).toList();
      final sorted = [...branches]..sort((a, b) => b.compareTo(a));
      expect(branches, sorted);
      expect(result.first.name, 'L-A2'); // 15 branches
    });

    test('sort by name ascending', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          sortBy: LeadSortBy.name,
          sortDescending: false,
        ),
      );
      final names = result.map((l) => l.leadName.toLowerCase()).toList();
      final sorted = [...names]..sort();
      expect(names, sorted);
    });

    test('unrated leads sort last when sorting by rating descending', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          sortBy: LeadSortBy.rating,
        ),
      );
      // TBS Bakery has a null rating -> treated as -1 -> comes last.
      expect(result.last.name, 'L-A2');
    });

    test('does not mutate the source catalog', () {
      final original = _names(catalog);
      applyLeadFilter(
        catalog,
        const LeadFilter(
          selectedTiers: {'A', 'B', 'C', 'REF'},
          sortBy: LeadSortBy.name,
        ),
      );
      expect(_names(catalog), original);
    });
  });

  group('pipeline stage', () {
    // Three tier-A leads that differ only by stage, so nothing but the stage
    // filter can separate them. The third carries an EMPTY stage, which the
    // backend uses for a lead that has never been advanced.
    const atQualify = Lead(
      name: 'L-ST1',
      leadName: 'Qualified Co',
      tier: 'A',
      b2bStage: 'Qualify',
    );
    const atActive = Lead(
      name: 'L-ST2',
      leadName: 'Active Co',
      tier: 'A',
      b2bStage: 'Active',
    );
    const atNothing = Lead(
      name: 'L-ST3',
      leadName: 'Untouched Co',
      tier: 'A',
      b2bStage: '',
    );
    const stageCatalog = [atQualify, atActive, atNothing];

    test('empty selection means every stage', () {
      final result = applyLeadFilter(stageCatalog, const LeadFilter());
      expect(_names(result), containsAll(['L-ST1', 'L-ST2', 'L-ST3']));
    });

    test('selecting one stage keeps only that stage', () {
      final result = applyLeadFilter(
        stageCatalog,
        const LeadFilter(selectedStages: {'Qualify'}),
      );
      expect(_names(result), ['L-ST1']);
    });

    test('selecting several stages is an OR across them', () {
      final result = applyLeadFilter(
        stageCatalog,
        const LeadFilter(selectedStages: {'Qualify', 'Active'}),
      );
      expect(_names(result).toSet(), {'L-ST1', 'L-ST2'});
    });

    test('an empty backend stage counts as the first stage', () {
      final result = applyLeadFilter(
        stageCatalog,
        const LeadFilter(selectedStages: {'Lead'}),
      );
      expect(_names(result), ['L-ST3']);
    });

    test('stage ANDs with the other filters rather than replacing them', () {
      // Tier C excludes it even though the stage matches.
      const tierCAtQualify = Lead(
        name: 'L-ST4',
        leadName: 'Small Co',
        tier: 'C',
        b2bStage: 'Qualify',
      );
      final result = applyLeadFilter(
        [...stageCatalog, tierCAtQualify],
        const LeadFilter(selectedStages: {'Qualify'}),
      );
      expect(_names(result), ['L-ST1']);
    });

    test('counts as one active advanced filter regardless of how many stages',
        () {
      expect(const LeadFilter().activeAdvancedCount, 0);
      expect(const LeadFilter(selectedStages: {'Qualify'}).activeAdvancedCount, 1);
      expect(
        const LeadFilter(selectedStages: {'Qualify', 'Active', 'Trial'})
            .activeAdvancedCount,
        1,
      );
    });

    test('clearedAdvanced resets the stage narrowing back to all', () {
      const on = LeadFilter(selectedStages: {'Active'}, selectedTiers: {'A'});
      final cleared = on.clearedAdvanced();
      expect(cleared.selectedStages, isEmpty);
      expect(cleared.selectedTiers, {'A'});
    });
  });

  group('not suitable', () {
    // A tier-A lead a rep judged unsuitable after manual inspection. It would
    // otherwise pass the default filter, so it isolates the verdict's effect.
    const rejected = Lead(
      name: 'L-NS1',
      leadName: 'Closed Roastery',
      category: 'Cafe',
      score: 80,
      tier: 'A',
      branchCount: 2,
      avgRating: 4.4,
      totalReviews: 400,
      primaryArea: 'Zamalek',
      areas: ['Zamalek'],
      phone: '+2019',
      notSuitable: true,
      notSuitableReason: 'Out of Business',
    );

    test('hidden by default', () {
      final result = applyLeadFilter([...catalog, rejected], const LeadFilter());
      expect(_names(result), isNot(contains('L-NS1')));
      // The rest of the catalog is unaffected.
      expect(_names(result), _names(applyLeadFilter(catalog, const LeadFilter())));
    });

    test('shown when showNotSuitable is on', () {
      final result = applyLeadFilter(
        [...catalog, rejected],
        const LeadFilter(showNotSuitable: true),
      );
      expect(_names(result), contains('L-NS1'));
    });

    test('the verdict wins over every other passing filter', () {
      // Every advanced filter this lead satisfies, but the verdict still hides it.
      final result = applyLeadFilter(
        [rejected],
        const LeadFilter(
          selectedTiers: {'A'},
          selectedCategory: 'Cafe',
          selectedAreas: {'Zamalek'},
          hasPhone: true,
        ),
      );
      expect(result, isEmpty);
    });

    test('counts as an active advanced filter', () {
      expect(const LeadFilter().activeAdvancedCount, 0);
      expect(const LeadFilter(showNotSuitable: true).activeAdvancedCount, 1);
    });

    test('clearedAdvanced turns it back off', () {
      const on = LeadFilter(showNotSuitable: true, selectedTiers: {'A'});
      final cleared = on.clearedAdvanced();
      expect(cleared.showNotSuitable, isFalse);
      // Tier/category/area/search are preserved by clearedAdvanced.
      expect(cleared.selectedTiers, {'A'});
    });
  });

  group('clear all (reset to defaults)', () {
    test('a fresh LeadFilter restores default tiers + sort', () {
      // Start from a heavily-customized filter.
      const custom = LeadFilter(
        selectedTiers: {'C'},
        selectedCategory: 'Cafe',
        selectedAreas: {'Maadi'},
        searchText: 'x',
        ratingMin: 2,
        minBranches: 5,
        hasSahel: true,
        specialtyOnly: true,
        sortBy: LeadSortBy.name,
        sortDescending: false,
      );
      final customResult = applyLeadFilter(catalog, custom);

      // "Clear all" resets to a default LeadFilter.
      const cleared = LeadFilter();
      final clearedResult = applyLeadFilter(catalog, cleared);

      expect(cleared.selectedTiers, {'A', 'B'});
      expect(cleared.sortBy, LeadSortBy.score);
      expect(cleared.sortDescending, isTrue);
      expect(cleared.activeAdvancedCount, 0);

      // The two outputs differ, proving the reset actually changes filtering.
      expect(_names(clearedResult), isNot(_names(customResult)));
      // Cleared result respects default tiers.
      expect(clearedResult.map((l) => l.tier).toSet(), {'A', 'B'});
    });
  });
}
