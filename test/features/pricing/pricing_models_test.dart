import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pricing/data/models/pricing_models.dart';

void main() {
  group('PriceListSummary.fromJson — get_price_lists item', () {
    final json = <String, dynamic>{
      'name': 'Companies',
      'currency': 'EGP',
      'enabled': true,
      'is_default': false,
      'customer_count': 12,
      'categories': [
        {'item_group': 'Medium', 'rate': 75, 'item_count': 30},
        {'item_group': 'Large', 'rate': null, 'item_count': 18},
      ],
    };

    test('decodes scalars, flags, and nested categories', () {
      final s = PriceListSummary.fromJson(json);
      expect(s.name, 'Companies');
      expect(s.currency, 'EGP');
      expect(s.enabled, isTrue);
      expect(s.isDefault, isFalse);
      expect(s.customerCount, 12);
      expect(s.categories, hasLength(2));

      final medium = s.categories.first;
      expect(medium.itemGroup, 'Medium');
      expect(medium.rate, 75);
      expect(medium.itemCount, 30);

      // A null category rate stays null (list has no item-group price yet).
      final large = s.categories.last;
      expect(large.itemGroup, 'Large');
      expect(large.rate, isNull);
      expect(large.itemCount, 18);
    });

    test('missing optional keys fall back to null-safe defaults', () {
      final s = PriceListSummary.fromJson({'name': 'Bare'});
      expect(s.name, 'Bare');
      expect(s.currency, 'EGP');
      expect(s.enabled, isTrue);
      expect(s.isDefault, isFalse);
      expect(s.customerCount, 0);
      expect(s.categories, isEmpty);
    });
  });

  group('PriceListDetail.fromJson — get_price_list_detail', () {
    final json = <String, dynamic>{
      'name': 'Companies',
      'currency': 'EGP',
      'enabled': true,
      'is_default': true,
      'categories': [
        {'item_group': 'Medium', 'rate': 75, 'item_count': 30},
      ],
      'item_overrides': [
        {
          'item_code': 'CHOC-M',
          'item_name': 'Chocolate Medium',
          'item_group': 'Medium',
          'rate': 82.5,
        },
      ],
      'customers': [
        {
          'customer': 'CUST-001',
          'customer_name': 'Acme Co',
          'assignment': 'direct',
          'customer_group': 'Companies',
        },
        {
          'customer': 'CUST-002',
          'customer_name': 'Beta LLC',
          'assignment': 'group',
          'customer_group': 'Companies',
        },
      ],
    };

    test('decodes categories, overrides and assigned customers', () {
      final d = PriceListDetail.fromJson(json);
      expect(d.name, 'Companies');
      expect(d.isDefault, isTrue);
      expect(d.categories.single.itemGroup, 'Medium');

      expect(d.itemOverrides, hasLength(1));
      final ov = d.itemOverrides.single;
      expect(ov.itemCode, 'CHOC-M');
      expect(ov.itemName, 'Chocolate Medium');
      expect(ov.itemGroup, 'Medium');
      expect(ov.rate, 82.5);

      expect(d.customers, hasLength(2));
      expect(d.customers.first.assignment, 'direct');
      expect(d.customers.last.assignment, 'group');
    });

    test('empty override/customer lists decode cleanly', () {
      final d = PriceListDetail.fromJson({
        'name': 'X',
        'categories': [],
        'item_overrides': [],
        'customers': [],
      });
      expect(d.itemOverrides, isEmpty);
      expect(d.customers, isEmpty);
    });
  });

  group('CustomerPricing.fromJson — get_customer_pricing (reverse view)', () {
    final json = <String, dynamic>{
      'customer': 'CUST-001',
      'customer_name': 'Acme Co',
      'customer_group': 'Companies',
      'effective_price_list': 'Companies',
      'assignment': 'direct',
      'prices': [
        {
          'item_group': 'Medium',
          'item_code': 'CHOC-M',
          'item_name': 'Chocolate Medium',
          'rate': 82.5,
          'source': 'override',
        },
        {
          'item_group': 'Large',
          'item_code': null,
          'item_name': null,
          'rate': 120,
          'source': 'category',
        },
      ],
    };

    test('decodes the customer, assignment and each price source', () {
      final p = CustomerPricing.fromJson(json);
      expect(p.customer, 'CUST-001');
      expect(p.customerName, 'Acme Co');
      expect(p.effectivePriceList, 'Companies');
      expect(p.assignment, 'direct');
      expect(p.prices, hasLength(2));

      final override = p.prices.first;
      expect(override.source, 'override');
      expect(override.itemCode, 'CHOC-M');
      expect(override.rate, 82.5);

      final category = p.prices.last;
      expect(category.source, 'category');
      expect(category.itemCode, isNull);
      expect(category.rate, 120);
    });

    test('a customer with no assignment decodes with null price list', () {
      final p = CustomerPricing.fromJson({
        'customer': 'CUST-9',
        'assignment': 'none',
        'effective_price_list': null,
        'prices': [],
      });
      expect(p.effectivePriceList, isNull);
      expect(p.assignment, 'none');
      expect(p.prices, isEmpty);
    });
  });

  group('PricingCategory / B2bCustomerResult', () {
    test('PricingCategory decodes item_group + item_count', () {
      final c = PricingCategory.fromJson({'item_group': 'Medium', 'item_count': 5});
      expect(c.itemGroup, 'Medium');
      expect(c.itemCount, 5);
    });

    test('B2bCustomerResult decodes with a null default_price_list', () {
      final r = B2bCustomerResult.fromJson({
        'customer': 'CUST-001',
        'customer_name': 'Acme Co',
        'customer_group': 'Companies',
        'default_price_list': null,
      });
      expect(r.customer, 'CUST-001');
      expect(r.customerName, 'Acme Co');
      expect(r.defaultPriceList, isNull);
    });
  });
}
