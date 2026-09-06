import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/core/network/dio_provider.dart';
import 'package:jarz_pos/src/features/settlement_reversal/presentation/widgets/unsettle_flow_dialog.dart';

import '../../../helpers/mock_services.dart';

const _journalEntry = 'ACC-JV-0099';

Future<void> _pump(WidgetTester tester, MockDio mockDio, String journalEntry) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [dioProvider.overrideWithValue(mockDio)],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showUnsettleFlowDialog(context, journalEntry),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('UnsettleFlowDialog — the confirmation cannot be triggered by accident', () {
    testWidgets(
        'the destructive button is disabled until the acknowledgement checkbox is ticked',
        (tester) async {
      final mockDio = MockDio();
      mockDio.setResponse(ApiEndpoints.unsettlePreview, {
        'message': {
          'journal_entry': 'ACC-JV-0099',
          'preview_token': 'tok-1',
          'party': 'Ahmed Courier',
          'net_amount': 100.0,
        },
      });

      await _pump(tester, mockDio, _journalEntry);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final confirmButtonFinder = find.widgetWithText(ElevatedButton, 'Reverse Settlement');
      expect(confirmButtonFinder, findsOneWidget);

      // Before the checkbox is ticked, the button must be present but inert —
      // this reverses real money movement and must never be one accidental
      // tap away.
      ElevatedButton confirmButton = tester.widget(confirmButtonFinder);
      expect(confirmButton.onPressed, isNull);

      // Tapping the disabled button must not have started the commit: the
      // mock never registered a response for the commit endpoint, so a
      // request there would surface as a 404 the notifier turns into an
      // error step, which the test explicitly rules out below.
      await tester.tap(confirmButtonFinder, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Reverse settlement?'), findsNothing);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      confirmButton = tester.widget(confirmButtonFinder);
      expect(confirmButton.onPressed, isNotNull,
          reason: 'ticking the explicit acknowledgement must enable it');

      final commitRequestsBefore = mockDio.requestLog
          .where((r) => r['path'] == ApiEndpoints.unsettleCommit)
          .length;
      expect(commitRequestsBefore, 0,
          reason: 'ticking the checkbox alone must not submit the reversal');
    });

    testWidgets('cancel never calls the commit endpoint', (tester) async {
      final mockDio = MockDio();
      mockDio.setResponse(ApiEndpoints.unsettlePreview, {
        'message': {
          'journal_entry': 'ACC-JV-0099',
          'preview_token': 'tok-1',
        },
      });

      await _pump(tester, mockDio, _journalEntry);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      final commitRequests = mockDio.requestLog
          .where((r) => r['path'] == ApiEndpoints.unsettleCommit)
          .length;
      expect(commitRequests, 0);
    });
  });
}
