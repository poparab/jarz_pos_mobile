import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/leads/data/models/lead.dart';
import 'package:jarz_pos/src/features/leads/presentation/widgets/lead_card.dart';
import 'package:jarz_pos/src/features/leads/presentation/widgets/sahel_badge.dart';
import 'package:jarz_pos/src/features/leads/presentation/widgets/tier_pill.dart';

Future<void> _pumpCard(WidgetTester tester, Lead lead) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: LeadCard(lead: lead, onTap: () {}),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('LeadCard', () {
    testWidgets('renders name, tier pill, and sahel badge when sahel > 0',
        (tester) async {
      const lead = Lead(
        name: 'L-A1',
        leadName: 'Zooba',
        tier: 'A',
        branchCount: 4,
        avgRating: 4.6,
        totalReviews: 1200,
        sahelBranches: 2,
        primaryArea: 'Zamalek',
      );

      await _pumpCard(tester, lead);

      // Name renders.
      expect(find.text('Zooba'), findsOneWidget);

      // Tier pill renders with the tier label.
      expect(find.byType(TierPill), findsOneWidget);
      expect(find.text('A'), findsOneWidget);

      // Sahel badge renders with the '🌊 N' label.
      expect(find.byType(SahelBadge), findsOneWidget);
      expect(find.text('🌊 2'), findsOneWidget);
    });

    testWidgets('omits the sahel badge when sahel == 0', (tester) async {
      const lead = Lead(
        name: 'L-B1',
        leadName: 'Cilantro',
        tier: 'B',
        branchCount: 12,
        avgRating: 4.1,
        totalReviews: 300,
        sahelBranches: 0,
        primaryArea: 'Maadi',
      );

      await _pumpCard(tester, lead);

      expect(find.text('Cilantro'), findsOneWidget);
      expect(find.byType(TierPill), findsOneWidget);
      expect(find.text('B'), findsOneWidget);

      // No sahel badge.
      expect(find.byType(SahelBadge), findsNothing);
      expect(find.textContaining('🌊'), findsNothing);
    });

    testWidgets('falls back to name when leadName is empty', (tester) async {
      const lead = Lead(
        name: 'FALLBACK-NAME',
        leadName: '',
        tier: 'A',
      );

      await _pumpCard(tester, lead);

      expect(find.text('FALLBACK-NAME'), findsOneWidget);
    });
  });
}
