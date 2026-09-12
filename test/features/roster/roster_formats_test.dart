import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/localization/localized_formatters.dart';
import 'package:jarz_pos/src/features/roster/presentation/roster_formats.dart';

/// One numeral system per locale, and a branch you can read in a 56px cell.
///
/// The grid used to format its day numbers and its cell hours by hand
/// (`toStringAsFixed`) while the month title above them went through the
/// locale-aware date helper. That is two independent numeral systems on one
/// screen, held apart only by the fact that `ar` currently resolves to Western
/// digits — the day the app adds `ar_EG`, the title flips and the grid does
/// not. Everything numeric on the roster now goes through one function.

class _Captured {
  const _Captured({required this.number, required this.dayOfMonth});

  final String number;
  final String dayOfMonth;
}

Future<_Captured> _capture(
  WidgetTester tester,
  num value, {
  required Locale locale,
}) async {
  late _Captured captured;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          captured = _Captured(
            number: rosterNumber(context, value),
            dayOfMonth: formatDate(
              context,
              DateTime(2026, 9, value is int ? value : 9),
              pattern: 'd',
            ),
          );
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return captured;
}

void main() {
  group('rosterNumber', () {
    testWidgets('a whole number loses its decimal, a half keeps one', (
      tester,
    ) async {
      expect((await _capture(tester, 9, locale: const Locale('en'))).number, '9');
      expect(
        (await _capture(tester, 12.5, locale: const Locale('en'))).number,
        '12.5',
      );
      expect(
        (await _capture(tester, 12.0, locale: const Locale('en'))).number,
        '12',
      );
    });

    testWidgets('hours are written in the same digits as the dates', (
      tester,
    ) async {
      // The invariant, in both languages: whatever numeral system the locale's
      // date formatter uses for a day number, the cell's hours use it too.
      for (final locale in const [Locale('en'), Locale('ar')]) {
        final captured = await _capture(tester, 9, locale: locale);
        expect(
          captured.number,
          captured.dayOfMonth,
          reason: 'numeral systems diverge in ${locale.languageCode}',
        );
      }
    });
  });

  group('branchToken', () {
    test('two words become their initials', () {
      expect(branchToken('Nasr City'), 'NC');
      expect(branchToken('New Cairo Branch'), 'NC');
      expect(branchToken('Sheikh-Zayed'), 'SZ');
    });

    test('one word becomes its first two letters', () {
      expect(branchToken('Obour'), 'OB');
      expect(branchToken('  maadi  '), 'MA');
    });

    test('a name in Arabic still yields a token', () {
      expect(branchToken('مدينة نصر').isNotEmpty, isTrue);
      expect(branchToken('مدينة نصر').length, 2);
    });

    test('an empty branch yields nothing rather than junk', () {
      expect(branchToken(''), '');
      expect(branchToken('   '), '');
    });
  });
}
