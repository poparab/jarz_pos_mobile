import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/widgets/customer_shipping_address_flow.dart';

void main() {
  test('branch options select canonical address and effective territory', () {
    final customer = mergeCustomerAddressBook(
      const {
        'name': 'ilo specialty coffee',
        'customer_name': 'ILO Specialty Coffee',
        'territory': 'EGMASRJD',
      },
      const {
        'addresses': [
          {
            'name': 'legacy-unknown',
            'address_line1': 'مدينتي All season Park',
            'city': 'Unknown',
          },
        ],
        'branch_options': [
          {
            'address_name': 'ilo specialty coffee-16815-Shipping',
            'branch_name': 'All Seasons Park',
            'full_address': 'مدينتي All Season Park',
            'effective_territory': 'EGMADINATY',
            'territory_pos_profile': 'Madinaty POS',
            'duplicate_count': 3,
          },
        ],
        'selected_address_name': 'ilo specialty coffee-16815-Shipping',
      },
      const [
        {
          'name': 'EGMADINATY',
          'territory_name': 'Madinaty',
          'delivery_income': 55,
        },
      ],
    );

    expect(
      customer['selected_shipping_address_name'],
      'ilo specialty coffee-16815-Shipping',
    );
    expect(customer['selected_shipping_branch_name'], 'All Seasons Park');
    expect(customer['selected_shipping_address_territory'], 'EGMADINATY');
    expect(
      customer['selected_shipping_address_territory_pos_profile'],
      'Madinaty POS',
    );
    expect(customer['selected_shipping_address_delivery_income'], 55.0);
    expect(customer['shipping_addresses'], hasLength(1));
  });

  test('unresolved branch never derives territory or fee from city', () {
    final customer = mergeCustomerAddressBook(
      const {
        'name': 'ilo specialty coffee',
        'territory': 'EGMASRJD',
        'delivery_income': 40,
      },
      const {
        'branch_options': [
          {
            'address_name': 'legacy-madinaty',
            'branch_name': 'All Seasons legacy',
            'city': 'EGMADINATY',
            'territory_missing': true,
          },
        ],
        'selected_address_name': 'legacy-madinaty',
      },
      const [
        {'name': 'EGMADINATY', 'delivery_income': 55},
      ],
    );

    expect(customer['selected_shipping_address_territory'], isNull);
    expect(customer['selected_shipping_address_delivery_income'], 0.0);
    expect(customer['selected_shipping_address_territory_missing'], isTrue);
  });
}
