import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/b2b/data/models/b2b_models.dart';

void main() {
  test('Customer account accepts a null backend stage', () {
    final account = B2bAccount.fromJson(const {
      'doctype': 'Customer',
      'name': 'ilo specialty coffee',
      'title': 'ILO Specialty Coffee',
      'stage': null,
      'customer': 'ilo specialty coffee',
    });

    expect(account.doctype, 'Customer');
    expect(account.stage, 'Customer');
    expect(account.customer, 'ilo specialty coffee');
  });

  test('Customer account accepts a missing backend stage', () {
    final account = B2bAccount.fromJson(const {
      'doctype': 'Customer',
      'name': 'ILO-PRODUCTION',
      'title': 'ILO Production',
      'customer': 'ILO-PRODUCTION',
    });

    expect(account.stage, 'Customer');
  });
}
