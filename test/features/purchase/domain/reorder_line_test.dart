import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/purchase/domain/reorder_line.dart';

/// Reorder refills the cart from a past purchase. Both defects pinned here
/// submitted cleanly and were wrong: a removed UOM kept the old total while
/// receiving a fraction of the stock, and an unloaded VAT list sent every line
/// out untaxed.
void main() {
  const vat14 = {'name': 'VAT 14% - JZ', 'title': 'VAT', 'rate': 14};

  Map<String, dynamic> boxLine({Object? factor = 12, Object? template}) => {
        'item_code': 'RM-CUPS',
        'item_name': 'Cups',
        'qty': 5,
        'uom': 'Box of 12',
        'rate': 120,
        if (factor != null) 'conversion_factor': factor,
        'item_tax_template': template,
      };

  Map<String, dynamic> detail({
    bool boxStillOffered = false,
    List<Map<String, dynamic>> prices = const [],
  }) =>
      {
        'item_code': 'RM-CUPS',
        'stock_uom': 'Nos',
        'uoms': [
          {'uom': 'Nos', 'conversion_factor': 1},
          if (boxStillOffered) {'uom': 'Box of 12', 'conversion_factor': 12},
        ],
        'prices': prices,
      };

  group('reorderLineFrom — UOM', () {
    test('a UOM the Item still offers is refilled exactly as bought', () {
      final line = reorderLineFrom(boxLine(),
          detail: detail(boxStillOffered: true), itemTaxTemplates: const []);
      expect(line.uom, 'Box of 12');
      expect(line.qty, 5);
      expect(line.rate, 120);
      expect(line.needsQty, isFalse);
    });

    test('a removed UOM is restated in the stock UOM by its own factor', () {
      final line =
          reorderLineFrom(boxLine(), detail: detail(), itemTaxTemplates: const []);
      expect(line.uom, 'Nos');
      expect(line.qty, 60, reason: '5 boxes of 12 is 60 units, not 5');
      expect(line.rate, 10, reason: 'the valuation rate must not be 12x');
      expect(line.qty * line.rate, 600, reason: 'the total stays what was paid');
      expect(line.uoms.map((u) => u['uom']), contains('Nos'));
      expect(line.needsQty, isFalse);
    });

    test('a stock-UOM price does not replace what was actually paid', () {
      final line = reorderLineFrom(
        boxLine(),
        detail: detail(prices: [
          {'uom': 'Nos', 'rate': 11}
        ]),
        itemTaxTemplates: const [],
      );
      expect(line.uom, 'Nos');
      expect(line.qty, 60);
      expect(line.rate, 10);
    });

    test('a factor sent as a string is still honoured', () {
      final line = reorderLineFrom(boxLine(factor: '12.0'),
          detail: detail(), itemTaxTemplates: const []);
      expect(line.qty, 60);
      expect(line.rate, 10);
    });

    test('an unknown factor never books the old quantity 1:1', () {
      // An older server does not send conversion_factor.
      final line = reorderLineFrom(
        boxLine(factor: null),
        detail: detail(prices: [
          {'uom': 'Nos', 'rate': 11}
        ]),
        itemTaxTemplates: const [],
      );
      expect(line.uom, 'Nos');
      expect(line.qty, 0, reason: 'the buyer must enter the unit quantity');
      expect(line.rate, 11);
      expect(line.needsQty, isTrue);
    });

    test('a zero factor is unknown, not 1:1', () {
      final line = reorderLineFrom(boxLine(factor: 0),
          detail: detail(), itemTaxTemplates: const []);
      expect(line.qty, 0);
      expect(line.rate, 0);
      expect(line.needsQty, isTrue);
    });

    test('a failed Item lookup keeps the line\'s own UOM as its only option',
        () {
      final line = reorderLineFrom(boxLine(), itemTaxTemplates: const []);
      expect(line.uom, 'Box of 12');
      expect(line.qty, 5);
      expect(line.rate, 120);
      expect(line.uoms.single['uom'], 'Box of 12');
    });

    test('a return invoice refills as a positive purchase', () {
      final source = boxLine()
        ..['qty'] = -5
        ..['rate'] = -120;
      final line =
          reorderLineFrom(source, detail: detail(), itemTaxTemplates: const []);
      expect(line.qty, 60);
      expect(line.rate, 10);
    });

    test('fractional factors do not leave float noise on the quantity', () {
      final source = boxLine(factor: 0.1)
        ..['uom'] = 'Pack'
        ..['qty'] = 3
        ..['rate'] = 1;
      final line =
          reorderLineFrom(source, detail: detail(), itemTaxTemplates: const []);
      expect(line.qty, 0.3);
      expect(line.rate, 10);
    });
  });

  group('reorderLineFrom — VAT', () {
    test('a template the company still offers is kept', () {
      final line = reorderLineFrom(boxLine(template: 'VAT 14% - JZ'),
          detail: detail(), itemTaxTemplates: const [vat14]);
      expect(line.itemTaxTemplate, 'VAT 14% - JZ');
    });

    test('a retired template is cleared once the list is known', () {
      final line = reorderLineFrom(boxLine(template: 'VAT 10% - OLD'),
          detail: detail(), itemTaxTemplates: const [vat14]);
      expect(line.itemTaxTemplate, isNull);
    });

    test('a retired template falls back to the Item\'s current one', () {
      final line = reorderLineFrom(
        boxLine(template: 'VAT 10% - OLD'),
        detail: detail()..['item_tax_template'] = 'VAT 14% - JZ',
        itemTaxTemplates: const [vat14],
      );
      expect(line.itemTaxTemplate, 'VAT 14% - JZ',
          reason: 'a taxed line must not quietly become No VAT');
    });

    test('the Item\'s template never taxes a line bought untaxed', () {
      final line = reorderLineFrom(
        boxLine(template: ''),
        detail: detail()..['item_tax_template'] = 'VAT 14% - JZ',
        itemTaxTemplates: const [vat14],
      );
      expect(line.itemTaxTemplate, isNull);
    });

    test('an unavailable list keeps the line\'s own VAT', () {
      final line = reorderLineFrom(boxLine(template: 'VAT 14% - JZ'),
          detail: detail(), itemTaxTemplates: null);
      expect(line.itemTaxTemplate, 'VAT 14% - JZ',
          reason: 'clearing it sends the purchase out as No VAT');
    });

    test('an untaxed line stays untaxed either way', () {
      expect(
        reorderLineFrom(boxLine(template: ''), itemTaxTemplates: null)
            .itemTaxTemplate,
        isNull,
      );
      expect(
        reorderLineFrom(boxLine(), itemTaxTemplates: const [vat14])
            .itemTaxTemplate,
        isNull,
      );
    });
  });

  group('linesWithoutQty', () {
    test('an unconverted refill cannot be submitted', () {
      final refill = reorderLineFrom(boxLine(factor: null),
          detail: detail(), itemTaxTemplates: const []);
      final cart = [
        {'item_code': 'RM-SUGAR', 'qty': 2.0},
        {'item_code': 'RM-CUPS', 'qty': refill.qty},
      ];
      expect(linesWithoutQty(cart).map((l) => l['item_code']), ['RM-CUPS'],
          reason: 'a zero line expands to no invoice rows and is dropped');
    });

    test('zero, negative and missing quantities are all refused', () {
      final cart = <Map<String, dynamic>>[
        {'item_code': 'A', 'qty': 0},
        {'item_code': 'B', 'qty': -1},
        {'item_code': 'C'},
        {'item_code': 'D', 'qty': 0.001},
      ];
      expect(linesWithoutQty(cart).map((l) => l['item_code']), ['A', 'B', 'C']);
    });

    test('a full cart passes', () {
      expect(
          linesWithoutQty([
            {'item_code': 'A', 'qty': 1.0}
          ]),
          isEmpty);
    });
  });

  group('linesWithUnresolvedTaxTemplate', () {
    test('a refill that kept its VAT while the list was down is refused', () {
      final refill = reorderLineFrom(boxLine(template: 'VAT 14% - JZ'),
          detail: detail(), itemTaxTemplates: null);
      final cart = [
        {'item_code': 'RM-CUPS', 'item_tax_template': refill.itemTaxTemplate},
      ];
      expect(
          linesWithUnresolvedTaxTemplate(cart, const [])
              .map((l) => l['item_code']),
          ['RM-CUPS'],
          reason: 'the screen shows no VAT but the server would charge it');
      expect(linesWithUnresolvedTaxTemplate(cart, const [vat14]), isEmpty,
          reason: 'once the list arrives the line is priced correctly');
    });

    test('a template the loaded list does not offer is refused', () {
      final cart = <Map<String, dynamic>>[
        {'item_code': 'A', 'item_tax_template': 'VAT 10% - OLD'},
        {'item_code': 'B', 'item_tax_template': 'VAT 14% - JZ'},
      ];
      expect(
          linesWithUnresolvedTaxTemplate(cart, const [vat14])
              .map((l) => l['item_code']),
          ['A']);
    });

    test('No VAT lines always resolve, even with no list', () {
      final cart = <Map<String, dynamic>>[
        {'item_code': 'A', 'item_tax_template': null},
        {'item_code': 'B', 'item_tax_template': ''},
        {'item_code': 'C'},
      ];
      expect(linesWithUnresolvedTaxTemplate(cart, const []), isEmpty);
    });
  });

  group('RetryingLoad', () {
    test('a call made before the first load finishes shares it', () async {
      var calls = 0;
      final gate = Completer<List<String>>();
      final load = RetryingLoad(() {
        calls++;
        return gate.future;
      });

      final first = load.ensure();
      final second = load.ensure();
      gate.complete(['VAT 14% - JZ']);

      expect(await first, ['VAT 14% - JZ']);
      expect(await second, ['VAT 14% - JZ']);
      expect(calls, 1);
    });

    test('a failed load is retried on the next call, not remembered', () async {
      var calls = 0;
      final load = RetryingLoad<List<String>>(() async {
        calls++;
        if (calls == 1) throw Exception('offline');
        return ['VAT 14% - JZ'];
      });

      expect(await load.ensure(), isNull);
      expect(load.isLoaded, isFalse);
      expect(await load.ensure(), ['VAT 14% - JZ']);
      expect(load.isLoaded, isTrue);
      expect(calls, 2);
    });

    test('a loaded value is not fetched again', () async {
      var calls = 0;
      final load = RetryingLoad<List<String>>(() async {
        calls++;
        return const [];
      });
      await load.ensure();
      expect(await load.ensure(), isEmpty,
          reason: 'an empty list is a real answer, not "unavailable"');
      expect(calls, 1);
    });
  });
}
