import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/localization/locale_notifier.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/manager/state/manager_providers.dart';
import 'package:jarz_pos/src/features/shift/state/shift_notifier.dart';
import 'package:jarz_pos/src/features/woo_sync/data/models/woo_duplicate_group.dart';
import 'package:jarz_pos/src/features/woo_sync/presentation/providers/woo_duplicate_review_provider.dart';
import 'package:jarz_pos/src/features/woo_sync/presentation/screens/woo_duplicates_screen.dart';

const _testRoles = UserRoles(
  user: 'operator@example.com',
  roles: ['WooCommerce Sync Operator'],
);

final _sampleGroup = WooDuplicateGroup.fromJson({
  'group_id': '+201234567890',
  'phone': '+201234567890',
  'size': 2,
  'reason': 'different names and no exclusively-shared woo_customer_id',
  'candidates': [
    {
      'name': 'CUST-0001',
      'customer_name': 'Ahmed Ali',
      'phone': '+201234567890',
      'email': 'ahmed@example.com',
      'created': '2026-01-01T00:00:00',
      'disabled': 0,
      'woo_customer_id': '42',
      'invoice_count': 5,
      'submitted_invoice_count': 4,
      'revenue': 1200.5,
    },
    {
      'name': 'CUST-0002',
      'customer_name': 'Ahmed Ali Two',
      'phone': '+201234567890',
      'email': '',
      'created': '2026-02-01T00:00:00',
      'disabled': 1,
      'woo_customer_id': '',
      'invoice_count': 0,
      'submitted_invoice_count': 0,
      'revenue': 0.0,
    },
  ],
});

Future<void> _pumpWooDuplicatesScreen(
  WidgetTester tester, {
  List<WooDuplicateGroup> groups = const [],
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userRolesFutureProvider.overrideWith((ref) async => _testRoles),
        managerAccessProvider.overrideWith((ref) async => false),
        requirePosShiftProvider.overrideWith((ref) => false),
        activeShiftProvider.overrideWith((ref) async => null),
        localeNotifierProvider.overrideWith((ref) => LocaleNotifier(null)),
        wooDuplicateReviewProvider.overrideWith((ref) async => groups),
        ...extraOverrides,
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: WooDuplicatesScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  group('WooDuplicatesScreen', () {
    testWidgets('is read-only: shows the banner and candidates but no merge action anywhere', (tester) async {
      await _pumpWooDuplicatesScreen(tester, groups: [_sampleGroup]);

      // The purpose-of-screen banner is present and unmissable.
      expect(
        find.text('Read-only triage. Merging duplicate customers is administrator-only and is done in Desk, not here.'),
        findsOneWidget,
      );

      // Both candidates are shown side by side with judging signal.
      expect(find.text('Ahmed Ali'), findsOneWidget);
      expect(find.text('Ahmed Ali Two'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);

      // No merge *action* exists anywhere on this screen: no button of any
      // kind is offered at all (the banner text below legitimately uses the
      // word "merge" descriptively, to explain why the screen is read-only —
      // that is deliberately not asserted away here).
      expect(find.byIcon(Icons.merge), findsNothing);
      expect(find.byIcon(Icons.merge_type), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
      final iconButtonTooltips = tester
          .widgetList<IconButton>(find.byType(IconButton))
          .map((b) => (b.tooltip ?? '').toLowerCase())
          .toList();
      expect(iconButtonTooltips.any((t) => t.contains('merge')), isFalse);
    });

    testWidgets('shows the empty state when no groups need review', (tester) async {
      await _pumpWooDuplicatesScreen(tester, groups: const []);

      expect(find.text('No duplicate customer groups need review right now.'), findsOneWidget);
    });

    testWidgets('shows the not-permitted state when the operator role is missing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRolesFutureProvider.overrideWith(
              (ref) async => const UserRoles(user: 'cashier@example.com', roles: []),
            ),
            managerAccessProvider.overrideWith((ref) async => false),
            requirePosShiftProvider.overrideWith((ref) => false),
            activeShiftProvider.overrideWith((ref) async => null),
            localeNotifierProvider.overrideWith((ref) => LocaleNotifier(null)),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: WooDuplicatesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Not permitted'), findsOneWidget);
      expect(find.text('Ahmed Ali'), findsNothing);
    });
  });
}
