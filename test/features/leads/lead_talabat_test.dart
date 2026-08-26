import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/leads/data/models/lead.dart';
import 'package:jarz_pos/src/features/leads/presentation/widgets/talabat_badge.dart';
import 'package:jarz_pos/src/features/leads/state/lead_filter.dart';

/// Two leads on Talabat (one in each zone, one in both) and one that is not.
List<Lead> _catalog() => const [
      Lead(
        name: 'T-1',
        leadName: 'Dancing Goat Coffee',
        tier: 'A',
        onTalabat: true,
        talabatAreas: ['6th of October', 'Sheikh Zayed'],
      ),
      Lead(
        name: 'T-2',
        leadName: 'Luma',
        tier: 'B',
        onTalabat: true,
        talabatAreas: ['Sheikh Zayed'],
      ),
      Lead(name: 'T-3', leadName: 'Some Offline Cafe', tier: 'B'),
    ];

List<String> _names(List<Lead> ls) => ls.map((l) => l.name).toList();

const _tiers = {'A', 'B', 'C', 'REF'};

void main() {
  final catalog = _catalog();

  group('Talabat filter', () {
    test('any keeps the whole catalog', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(selectedTiers: _tiers),
      );
      expect(_names(result), containsAll(['T-1', 'T-2', 'T-3']));
    });

    test('on keeps only listed brands', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(selectedTiers: _tiers, talabatFilter: TalabatFilter.on),
      );
      expect(result.every((l) => l.onTalabat), isTrue);
      expect(_names(result), unorderedEquals(['T-1', 'T-2']));
    });

    // The inverse really is meaningful here, unlike takeawayOnly: the flag is
    // read off Talabat's own listings, so "off" is an answer, not missing data.
    test('off keeps only brands nobody is delivering for', () {
      final result = applyLeadFilter(
        catalog,
        const LeadFilter(selectedTiers: _tiers, talabatFilter: TalabatFilter.off),
      );
      expect(_names(result), unorderedEquals(['T-3']));
    });

    test('counts toward the advanced-filter badge only when narrowing', () {
      expect(const LeadFilter().activeAdvancedCount, 0);
      expect(
        const LeadFilter(talabatFilter: TalabatFilter.on).activeAdvancedCount,
        1,
      );
      expect(
        const LeadFilter(talabatFilter: TalabatFilter.off).activeAdvancedCount,
        1,
      );
    });

    test('clearedAdvanced resets it back to any', () {
      const f = LeadFilter(talabatFilter: TalabatFilter.on, searchText: 'goat');
      final cleared = f.clearedAdvanced();
      expect(cleared.talabatFilter, TalabatFilter.any);
      expect(cleared.searchText, 'goat', reason: 'search is not an advanced filter');
    });
  });

  group('Lead model', () {
    test('round-trips the Talabat keys the API sends', () {
      final lead = Lead.fromJson(const {
        'name': 'CRM-LEAD-1',
        'lead_name': 'Luma',
        'on_talabat': 1,
        'talabat_areas': ['Sheikh Zayed'],
      });
      expect(lead.onTalabat, isTrue);
      expect(lead.talabatAreas, ['Sheikh Zayed']);
    });

    test('defaults to not-on-Talabat when the API omits the keys', () {
      final lead = Lead.fromJson(const {'name': 'X', 'lead_name': 'Y'});
      expect(lead.onTalabat, isFalse);
      expect(lead.talabatAreas, isEmpty);
    });

    test('round-trips the rating keys', () {
      final lead = Lead.fromJson(const {
        'name': 'X', 'lead_name': 'Y', 'on_talabat': 1,
        'talabat_rating': 4.6, 'talabat_reviews': 1000,
        'talabat_rating_source': 'talabat',
      });
      expect(lead.talabatRating, 4.6);
      expect(lead.talabatReviews, 1000);
      expect(lead.talabatRatingSource, 'talabat');
    });

    test('an unrated Talabat listing keeps a null rating, not a zero', () {
      final lead = Lead.fromJson(const {
        'name': 'X', 'lead_name': 'Y', 'on_talabat': 1,
      });
      expect(lead.onTalabat, isTrue);
      expect(lead.talabatRating, isNull,
          reason: '0.0 would sort as the worst-rated venue rather than unrated');
      expect(lead.talabatReviews, 0);
    });

    test('an unrated listing decodes as null, never 0.0', () {
      final lead = Lead.fromJson(const {
        'name': 'X', 'lead_name': 'Y', 'on_talabat': 1,
        'talabat_rating': null, 'talabat_rating_source': '',
      });
      expect(lead.talabatRating, isNull);
      expect(lead.talabatRatingSource, '');
    });

    test('branch rows carry their own flag', () {
      final branch = LeadBranch.fromJson(const {
        'branch_name': 'Luma Zayed',
        'on_talabat': 1,
      });
      expect(branch.onTalabat, isTrue);
    });
  });

  group('TalabatBadge', () {
    Widget wrap(Widget child) => MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: child),
        );

    testWidgets('shows the rating when it is Talabat own score', (tester) async {
      await tester.pumpWidget(wrap(const TalabatBadge(
        rating: 4.6, reviews: 1000, ratingSource: 'talabat')));
      expect(find.text('4.6'), findsOneWidget);
    });

    // A borrowed Google score must not be dressed up as a Talabat rating --
    // that would credit the venue with a reputation it has not earned there.
    testWidgets('hides a borrowed Google score', (tester) async {
      await tester.pumpWidget(wrap(const TalabatBadge(
        rating: 5.0, reviews: 18, ratingSource: 'google_maps')));
      expect(find.text('5.0'), findsNothing);
      final tip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tip.message, contains('from Google'));
    });

    testWidgets('says so when listed but unrated', (tester) async {
      await tester.pumpWidget(wrap(const TalabatBadge()));
      final tip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tip.message, contains('not yet rated'));
    });

    // The corpus stores bucket FLOORS because Talabat itself buckets; the label
    // has to read back the way the app writes it, not as a fake exact number.
    testWidgets('re-labels bucketed counts the way Talabat writes them',
        (tester) async {
      for (final c in const [(1000, '1k+'), (500, '500+'), (100, '100+'), (43, '43')]) {
        await tester.pumpWidget(wrap(TalabatBadge(
          rating: 4.2, reviews: c.$1, ratingSource: 'talabat')));
        final tip = tester.widget<Tooltip>(find.byType(Tooltip));
        expect(tip.message, contains('(${c.$2})'), reason: 'for ${c.$1}');
      }
    });

    testWidgets('renders the label', (tester) async {
      await tester.pumpWidget(wrap(const TalabatBadge()));
      expect(find.text('Talabat'), findsOneWidget);
    });

    testWidgets('exposes the zones as a tooltip', (tester) async {
      await tester.pumpWidget(wrap(
        const TalabatBadge(areas: ['6th of October', 'Sheikh Zayed']),
      ));
      final tip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tip.message, contains('6th of October · Sheikh Zayed'));
    });

    // The tooltip carries whatever is known, so a badge with no zones but a
    // rating still earns one — only a badge with nothing to add goes bare.
    testWidgets('omits the zone line when no zone is known', (tester) async {
      await tester.pumpWidget(wrap(const TalabatBadge(
        rating: 4.2, reviews: 43, ratingSource: 'talabat')));
      final tip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tip.message, '4.2 ★ (43)');
    });
  });
}
