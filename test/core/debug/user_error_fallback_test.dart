import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/debug/app_error_console.dart';
import 'package:jarz_pos/src/core/localization/localized_display_mappers.dart';
import 'package:jarz_pos/src/features/pos/order_alert/web_push_registration_result.dart';

void main() {
  testWidgets(
    'failed notification setup never shows raw technical details in Arabic',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Text(
              localizedWebPushMessage(
                context,
                WebPushRegistrationStatus.failed,
                'TypeError: ${'internal stack' * 500}',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          lookupAppLocalizations(const Locale('ar')).webPushEnableFailed,
        ),
        findsOneWidget,
      );
      expect(find.textContaining('TypeError'), findsNothing);
    },
  );

  testWidgets('a small failing widget does not overflow its error fallback', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 120,
            height: 60,
            child: buildAppErrorWidget(
              FlutterErrorDetails(exception: StateError('boom')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  for (final locale in ['ar', 'en']) {
    testWidgets('render failure is concise and localized in $locale', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: buildAppErrorWidget(
              FlutterErrorDetails(
                exception: StateError('Traceback ${'private data' * 1000}'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(lookupAppLocalizations(Locale(locale)).userErrorScreenFailed),
        findsOneWidget,
      );
      expect(find.textContaining('Traceback'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'render fallback works before localization and directionality exist',
    (tester) async {
      tester.binding.platformDispatcher.localeTestValue = const Locale('ar');
      addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
      await tester.pumpWidget(
        buildAppErrorWidget(FlutterErrorDetails(exception: StateError('boom'))),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          lookupAppLocalizations(const Locale('ar')).userErrorScreenFailed,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
