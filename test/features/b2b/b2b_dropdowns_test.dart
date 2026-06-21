import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/b2b/data/b2b_repository.dart';
import 'package:jarz_pos/src/features/b2b/data/models/b2b_models.dart';
import 'package:jarz_pos/src/features/b2b/presentation/screens/b2b_account_screen.dart';
import 'package:jarz_pos/src/features/b2b/presentation/screens/b2b_lead_add_screen.dart';
import 'package:jarz_pos/src/features/pos/presentation/widgets/customer_search_widget.dart'
    show territoriesProvider;

const _territories = <Map<String, dynamic>>[
  {'name': 'Cairo', 'territory_name': 'Cairo'},
  {'name': 'Giza', 'territory_name': 'Giza'},
];

const _leadSources = <String>['Walk In', 'Reference', 'Campaign'];

class _FakeB2bRepository extends B2bRepository {
  _FakeB2bRepository() : super(Dio());

  @override
  Future<List<String>> getLeadSources() async => _leadSources;

  @override
  Future<B2bAccount> getAccount({
    required String doctype,
    required String name,
  }) async {
    return const B2bAccount(
      doctype: 'Lead',
      name: 'LEAD-001',
      title: 'Acme Co',
      stage: 'Lead',
      contact: B2bContact(mobileNo: '01000000000'),
    );
  }
}

Widget _wrap(Widget child, {required List<Override> overrides}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}

void main() {
  group('B2bLeadAddScreen dropdowns', () {
    testWidgets('Source dropdown renders options from get_lead_sources',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const B2bLeadAddScreen(),
          overrides: [
            b2bRepositoryProvider.overrideWithValue(_FakeB2bRepository()),
            b2bLeadSourcesProvider
                .overrideWith((ref) async => _leadSources),
            territoriesProvider(null)
                .overrideWith((ref) async => _territories),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // The Source dropdown is present.
      expect(find.text('Source'), findsOneWidget);

      // Open it and verify the mocked options appear.
      await tester.tap(find.text('Source'));
      await tester.pumpAndSettle();
      expect(find.text('Walk In'), findsWidgets);
      expect(find.text('Reference'), findsWidgets);
      expect(find.text('Campaign'), findsWidgets);
    });

    testWidgets('Territory dropdown renders options from the territory list',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const B2bLeadAddScreen(),
          overrides: [
            b2bRepositoryProvider.overrideWithValue(_FakeB2bRepository()),
            b2bLeadSourcesProvider
                .overrideWith((ref) async => _leadSources),
            territoriesProvider(null)
                .overrideWith((ref) async => _territories),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Territory'), findsOneWidget);

      await tester.tap(find.text('Territory'));
      await tester.pumpAndSettle();
      expect(find.text('Cairo'), findsWidgets);
      expect(find.text('Giza'), findsWidgets);
    });
  });

  group('B2bAccountScreen action bar', () {
    testWidgets('pinned action bar is wrapped in a SafeArea', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const B2bAccountScreen(doctype: 'Lead', name: 'LEAD-001'),
          overrides: [
            b2bRepositoryProvider.overrideWithValue(_FakeB2bRepository()),
            territoriesProvider(null)
                .overrideWith((ref) async => _territories),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // The action buttons render.
      expect(find.text('Send sample'), findsOneWidget);
      expect(find.text('Place order'), findsOneWidget);

      // The pinned bar's Material is wrapped in a SafeArea(top: false).
      final safeAreas = tester
          .widgetList<SafeArea>(find.byType(SafeArea))
          .where((s) => s.top == false);
      expect(safeAreas, isNotEmpty);
    });
  });
}
