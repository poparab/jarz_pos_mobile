import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manufacturing/domain/recipe_text.dart';

void main() {
  const bilingual = 'Brew 165.3 g of coffee\n\n  \nاعمل 496 جرام قهوة\n';

  group('recipeLinesForLocale', () {
    test('English keeps the lines without Arabic', () {
      expect(recipeLinesForLocale(bilingual, arabic: false), [
        'Brew 165.3 g of coffee',
      ]);
    });

    test('Arabic keeps the lines with Arabic', () {
      expect(recipeLinesForLocale(bilingual, arabic: true), [
        'اعمل 496 جرام قهوة',
      ]);
    });

    test('falls back to every line when the filter leaves nothing', () {
      expect(recipeLinesForLocale('Fill the jar\nThen chill', arabic: true), [
        'Fill the jar',
        'Then chill',
      ]);
      expect(recipeLinesForLocale('املأ\nبرّد', arabic: false), [
        'املأ',
        'برّد',
      ]);
    });

    test('null and blank text are no lines', () {
      expect(recipeLinesForLocale(null, arabic: false), isEmpty);
      expect(recipeLinesForLocale(' \n\n ', arabic: true), isEmpty);
    });
  });

  group('shortSizeName', () {
    test('strips the sheet title prefix', () {
      expect(shortSizeName('Tiramisu Large', 'Tiramisu'), 'Large');
      expect(shortSizeName('tiramisu - Small', 'Tiramisu'), 'Small');
    });

    test('keeps names that do not start with the title', () {
      expect(shortSizeName('Lotus Jar', 'Tiramisu'), 'Lotus Jar');
      expect(shortSizeName('Tiramisu', 'Tiramisu'), 'Tiramisu');
      expect(shortSizeName('Tiramisu Large', ''), 'Tiramisu Large');
    });
  });

  group('splitRecipeQuantities', () {
    test('marks the weights and keeps the text whole', () {
      const line = '40 g savoiardi + 24 g coffee, 1.5 kg total';
      final pieces = splitRecipeQuantities(line);
      expect(pieces.map((p) => p.$1).join(), line);
      expect(
        [
          for (final p in pieces)
            if (p.$2) p.$1,
        ],
        ['40 g', '24 g', '1.5 kg'],
      );
    });

    test('marks Arabic grams, not a word that merely starts with g', () {
      final pieces = splitRecipeQuantities('40 جرام سافوياردي و 3 grinds');
      expect(
        [
          for (final p in pieces)
            if (p.$2) p.$1,
        ],
        ['40 جرام'],
      );
    });
  });

  test('formatRecipeCount drops a whole number decimal', () {
    expect(formatRecipeCount(28), '28');
    expect(formatRecipeCount(2.5), '2.5');
  });
}
