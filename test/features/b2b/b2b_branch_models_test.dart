import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/b2b/data/models/b2b_models.dart';

void main() {
  group('B2bAccount branches', () {
    test('parses branches, unassigned stats and invoice branch fields', () {
      final account = B2bAccount.fromJson({
        'doctype': 'Customer',
        'name': 'ilo specialty coffee',
        'title': 'ILO Specialty Coffee',
        'customer': 'ilo specialty coffee',
        'recent_invoices': [
          {
            'name': 'ACC-SINV-2026-00012',
            'woo_order_id': 17529,
            'posting_date': '2026-09-20',
            'grand_total': 1500,
            'outstanding_amount': '250.5',
            'custom_order_purpose': 'B2B Supply',
            'status': 'Partly Paid',
            'branch_address': 'ILO-MADINATY',
            'branch_name': 'All Seasons Park',
          },
        ],
        'branches': [
          {
            'address_name': 'ILO-MADINATY',
            'branch_name': 'All Seasons Park',
            'address_line1': 'Madinaty',
            'address_line2': null,
            'city': 'Cairo',
            'phone': '01000000000',
            'territory': 'EGMADINATY',
            'territory_missing': false,
            'is_primary_address': 1,
            'latitude': 30.1,
            'longitude': '31.6',
            'member_address_names': ['ILO-MADINATY', 'ILO-MADINATY-1'],
            'invoice_count': '3',
            'total_billed': 4500,
            'outstanding': '250.50',
            'last_order_date': '2026-09-20',
          },
          {
            'address_name': 'ILO-ZAYED',
            'branch_name': '',
            'address_line1': 'Sheikh Zayed',
            'territory': null,
            'territory_missing': 1,
          },
        ],
        'unassigned_invoices': {
          'invoice_count': 2,
          'total_billed': '800',
          'outstanding': 0,
          'last_order_date': null,
        },
      });

      expect(account.branches, hasLength(2));
      final first = account.branches.first;
      expect(first.key, 'ILO-MADINATY');
      expect(first.displayName, 'All Seasons Park');
      expect(first.addressText, 'Madinaty, Cairo');
      expect(first.isPrimaryAddress, isTrue);
      expect(first.territoryMissing, isFalse);
      expect(first.hasLocation, isTrue);
      expect(first.longitude, 31.6);
      expect(first.memberAddressNames, ['ILO-MADINATY', 'ILO-MADINATY-1']);
      expect(first.invoiceCount, 3);
      expect(first.totalBilled, 4500);
      expect(first.outstanding, 250.5);
      expect(first.stats.lastOrderDate, '2026-09-20');

      final second = account.branches.last;
      // A blank branch name falls back to the street.
      expect(second.displayName, 'Sheikh Zayed');
      expect(second.territory, isNull);
      expect(second.territoryMissing, isTrue);
      expect(second.hasLocation, isFalse);
      expect(second.invoiceCount, 0);
      expect(second.totalBilled, 0);
      expect(second.memberAddressNames, isEmpty);

      final unassigned = account.unassignedInvoices!;
      expect(unassigned.invoiceCount, 2);
      expect(unassigned.totalBilled, 800);
      expect(unassigned.outstanding, 0);
      expect(unassigned.lastOrderDate, isNull);

      final invoice = account.recentInvoices.single;
      expect(invoice.displayId, isNotEmpty);
      expect(invoice.grandTotal, 1500);
      expect(invoice.outstandingAmount, 250.5);
      expect(invoice.branchAddress, 'ILO-MADINATY');
      expect(invoice.branchName, 'All Seasons Park');
      expect(invoice.isReturn, isFalse);
    });

    test('older server without branch keys defaults to empty / null', () {
      final account = B2bAccount.fromJson(const {
        'doctype': 'Lead',
        'name': 'CRM-LEAD-0001',
        'title': 'Cafe',
        'recent_invoices': [
          {'name': 'ACC-SINV-1', 'grand_total': 10.0},
        ],
      });

      expect(account.branches, isEmpty);
      expect(account.unassignedInvoices, isNull);
      final invoice = account.recentInvoices.single;
      expect(invoice.branchAddress, isNull);
      expect(invoice.branchName, isNull);
      expect(invoice.outstandingAmount, isNull);
      expect(invoice.paymentMethod, isNull);
      expect(invoice.isReturn, isFalse);
    });

    test('numeric strings in legacy invoice fields are tolerated', () {
      final invoice = B2bRecentInvoice.fromJson(const {
        'name': 'ACC-SINV-2',
        'woo_order_id': '17600',
        'grand_total': '99.5',
      });
      expect(invoice.wooOrderId, 17600);
      expect(invoice.grandTotal, 99.5);
    });
  });

  group('unified branches (delivery + Google Maps)', () {
    Map<String, dynamic> payload() => {
      'doctype': 'Lead',
      'name': 'CRM-LEAD-1',
      'title': 'ILO',
      'customer': 'ILO-1',
      'branch_lead': 'CRM-LEAD-1',
      'branches': [
        {
          'address_name': 'ILO-MADINATY',
          'branch_name': 'All Seasons Park',
          'address_line1': 'Madinaty',
          'member_address_names': ['ILO-MADINATY'],
          'invoice_count': 3,
          'total_billed': '4500',
          'outstanding': 0,
          'last_order_date': '2026-09-20',
          'source': 'address',
          'maps': {
            'row': 'a1b2c3',
            'branch_name': 'ILO Madinaty',
            'area': 'Madinaty',
            'region': 'New Cairo',
            'governorate': 'Cairo',
            'rating': '4.6',
            'reviews': '312',
            'maps_url': 'https://maps.google.com/?cid=1',
            'phone': '0100',
            'address': 'All Seasons Park, Madinaty',
            'latitude': 30.1,
            'longitude': '31.6',
            'on_talabat': 1,
          },
          'maps_match': 'linked',
        },
        {
          'address_name': 'ILO-ZAYED',
          'branch_name': 'Zayed',
          'source': 'address',
          'maps': {'row': '__self__', 'rating': 4.1, 'reviews': 20},
          'maps_match': 'auto',
        },
        {
          'address_name': null,
          'branch_name': 'ILO Maadi',
          'member_address_names': <String>[],
          'invoice_count': 0,
          'total_billed': 0,
          'outstanding': 0,
          'last_order_date': null,
          'source': 'maps',
          'maps': {
            'row': 'd4e5f6',
            'branch_name': 'ILO Maadi',
            'area': 'Maadi',
            'rating': null,
            'reviews': null,
            'maps_url': null,
            'latitude': 29.96,
            'longitude': 31.25,
            'on_talabat': false,
          },
          'maps_match': null,
        },
      ],
    };

    test('parses an address branch with a linked Google Maps listing', () {
      final account = B2bAccount.fromJson(payload());
      expect(account.branchLead, 'CRM-LEAD-1');
      expect(account.branches, hasLength(3));

      final linked = account.branches.first;
      expect(linked.source, B2bBranch.sourceAddress);
      expect(linked.isMapsOnly, isFalse);
      expect(linked.isDeliveryBranch, isTrue);
      expect(linked.hasMaps, isTrue);
      expect(linked.mapsMatch, 'linked');
      expect(linked.isMapsAutoMatched, isFalse);
      expect(linked.mapsRow, 'a1b2c3');
      expect(linked.key, 'ILO-MADINATY');
      expect(linked.displayName, 'All Seasons Park');
      expect(linked.totalBilled, 4500);

      final maps = linked.maps!;
      expect(maps.rating, 4.6);
      expect(maps.reviews, 312);
      expect(maps.onTalabat, isTrue);
      expect(maps.hasLocation, isTrue);
      expect(maps.longitude, 31.6);
      expect(maps.mapsUrl, 'https://maps.google.com/?cid=1');
      expect(maps.areaText, 'Madinaty · New Cairo · Cairo');

      final auto = account.branches[1];
      expect(auto.isMapsAutoMatched, isTrue);
      expect(auto.mapsRow, '__self__');
      expect(auto.maps!.onTalabat, isFalse);
      expect(auto.maps!.hasLocation, isFalse);
    });

    test('parses a maps-only entry with an empty key and zero stats', () {
      final account = B2bAccount.fromJson(payload());
      final mapsOnly = account.branches.last;
      expect(mapsOnly.source, B2bBranch.sourceMaps);
      expect(mapsOnly.isMapsOnly, isTrue);
      expect(mapsOnly.isDeliveryBranch, isFalse);
      expect(mapsOnly.addressName, isNull);
      // No Address behind it: nothing for the invoice filter to key on.
      expect(mapsOnly.key, isEmpty);
      expect(mapsOnly.memberAddressNames, isEmpty);
      expect(mapsOnly.invoiceCount, 0);
      expect(mapsOnly.totalBilled, 0);
      expect(mapsOnly.mapsMatch, isNull);
      expect(mapsOnly.isMapsAutoMatched, isFalse);
      expect(mapsOnly.displayName, 'ILO Maadi');
      expect(mapsOnly.mapsRow, 'd4e5f6');
      expect(mapsOnly.maps!.rating, isNull);
      expect(mapsOnly.maps!.hasLocation, isTrue);

      // Only the delivery branches reach the invoice filter.
      expect(account.deliveryBranches.map((b) => b.key), [
        'ILO-MADINATY',
        'ILO-ZAYED',
      ]);
    });

    test('maps-only entry without a branch name falls back to its area', () {
      final branch = B2bBranch.fromJson(const {
        'source': 'maps',
        'maps': {'row': 'x', 'area': 'Heliopolis'},
      });
      expect(branch.displayName, 'Heliopolis');
      expect(branch.key, isEmpty);
    });

    test('legacy payload without the new keys reads as address branches', () {
      final account = B2bAccount.fromJson(const {
        'doctype': 'Customer',
        'name': 'ILO-1',
        'title': 'ILO',
        'branches': [
          {'address_name': 'ILO-MADINATY', 'branch_name': 'All Seasons Park'},
        ],
      });
      expect(account.branchLead, isNull);
      final branch = account.branches.single;
      expect(branch.source, B2bBranch.sourceAddress);
      expect(branch.isMapsOnly, isFalse);
      expect(branch.hasMaps, isFalse);
      expect(branch.maps, isNull);
      expect(branch.mapsMatch, isNull);
      expect(branch.mapsRow, isNull);
      expect(branch.key, 'ILO-MADINATY');
      expect(account.deliveryBranches, hasLength(1));
    });

    test('blank source and a non-object maps value are tolerated', () {
      final branch = B2bBranch.fromJson(const {
        'address_name': 'A',
        'source': '',
        'maps': 'garbage',
      });
      expect(branch.source, B2bBranch.sourceAddress);
      expect(branch.maps, isNull);
    });

    test('link result parses branches and unassigned totals', () {
      final result = B2bBranchLinkResult.fromJson({
        'branches': payload()['branches'],
        'unassigned': {'invoice_count': '2', 'total_billed': 800},
      });
      expect(result.branches, hasLength(3));
      expect(result.branches.last.isMapsOnly, isTrue);
      expect(result.unassigned!.invoiceCount, 2);

      final empty = B2bBranchLinkResult.fromJson(const {'unassigned': null});
      expect(empty.branches, isEmpty);
      expect(empty.unassigned, isNull);
    });
  });

  group('B2bAccountInvoices', () {
    test('parses invoices, summary and truncation', () {
      final page = B2bAccountInvoices.fromJson({
        'customer': 'ilo specialty coffee',
        'branch': '__unassigned__',
        'invoices': [
          {
            'name': 'ACC-SINV-3',
            'woo_order_id': null,
            'posting_date': '2026-09-01',
            'grand_total': -120,
            'outstanding_amount': 0,
            'custom_order_purpose': 'Standard',
            'custom_payment_method': 'Cash',
            'status': 'Return',
            'is_return': 1,
            'branch_address': null,
            'branch_name': null,
          },
        ],
        'summary': {
          'invoice_count': 1,
          'total_billed': -120,
          'outstanding': 0,
          'last_order_date': '2026-09-01',
        },
        'truncated': true,
      });

      expect(page.branch, '__unassigned__');
      expect(page.truncated, isTrue);
      expect(page.summary.invoiceCount, 1);
      expect(page.summary.totalBilled, -120);
      final invoice = page.invoices.single;
      expect(invoice.isReturn, isTrue);
      expect(invoice.paymentMethod, 'Cash');
      expect(invoice.orderPurpose, 'Standard');
      expect(invoice.branchName, isNull);
    });

    test('missing keys default to an empty page', () {
      final page = B2bAccountInvoices.fromJson(const {});
      expect(page.invoices, isEmpty);
      expect(page.summary.invoiceCount, 0);
      expect(page.truncated, isFalse);
    });
  });

  group('merge models', () {
    test('candidate parses doctype badge fields', () {
      final candidate = B2bMergeCandidate.fromJson(const {
        'doctype': 'Customer',
        'name': 'ILO-2',
        'title': 'ILO Zayed',
        'customer': 'ILO-2',
        'stage': null,
        'area': 'Sheikh Zayed',
        'mobile_no': '0100',
        'branch_count': '2',
      });
      expect(candidate.doctype, 'Customer');
      expect(candidate.displayName, 'ILO Zayed');
      expect(candidate.branchCount, 2);
      expect(candidate.stage, isNull);
    });

    test('preview parses plan, customers and warnings', () {
      final preview = B2bMergePreview.fromJson({
        'source': {
          'doctype': 'Customer',
          'name': 'ILO-2',
          'title': 'ILO Zayed',
          'lead': null,
          'customer': 'ILO-2',
        },
        'target': {
          'doctype': 'Lead',
          'name': 'CRM-LEAD-1',
          'title': 'ILO',
          'lead': 'CRM-LEAD-1',
          'customer': 'ILO-1',
        },
        'plan': {
          'customer_action': 'merge_customers',
          'lead_action': null,
          'requires_manager': true,
          'final_customer': 'ILO-1',
        },
        'source_customer': {
          'name': 'ILO-2',
          'customer_name': 'ILO Zayed',
          'invoice_count': 4,
          'total_billed': '1200.00',
          'outstanding': 300,
          'address_count': 1,
          'credit_allowed': 1,
          'extra_field': 'ignored',
        },
        'target_customer': null,
        'can_execute': false,
        'warnings': [
          'irreversible_customer_merge',
          'credit_terms_carried_over',
        ],
      });

      expect(preview.source.displayName, 'ILO Zayed');
      expect(preview.target.customer, 'ILO-1');
      expect(preview.plan.customerAction, 'merge_customers');
      expect(preview.plan.requiresManager, isTrue);
      expect(preview.sourceCustomer!.totalBilled, 1200);
      expect(preview.sourceCustomer!.creditAllowed, isTrue);
      expect(preview.targetCustomer, isNull);
      expect(preview.canExecute, isFalse);
      expect(preview.warnings, hasLength(2));
    });

    test('preview tolerates a sparse payload', () {
      final preview = B2bMergePreview.fromJson(const {'can_execute': 1});
      expect(preview.canExecute, isTrue);
      expect(preview.warnings, isEmpty);
      expect(preview.blockers, isEmpty);
      expect(preview.source.displayName, '');
      expect(preview.plan.customerAction, isNull);
    });

    test('preview carries server blocker sentences verbatim', () {
      final preview = B2bMergePreview.fromJson(const {
        'can_execute': false,
        'warnings': <String>[],
        'blockers': [
          "'ILO-2' cannot be merged: it is the default customer of a POS "
              'Profile.',
          '',
        ],
      });
      expect(preview.canExecute, isFalse);
      expect(preview.blockers, [
        "'ILO-2' cannot be merged: it is the default customer of a POS "
            'Profile.',
      ]);
    });

    test('merge result reads a count or a list of moved invoices', () {
      final counted = B2bMergeResult.fromJson(
        const {
          'success': true,
          'target_doctype': 'Lead',
          'target_name': 'CRM-LEAD-1',
          'customer': 'ILO-1',
          'moved_invoices': 4,
        },
        fallbackDoctype: 'Customer',
        fallbackName: 'X',
      );
      expect(counted.targetDoctype, 'Lead');
      expect(counted.targetName, 'CRM-LEAD-1');
      expect(counted.movedInvoices, 4);

      final listed = B2bMergeResult.fromJson(
        const {
          'moved_invoices': ['A', 'B'],
        },
        fallbackDoctype: 'Customer',
        fallbackName: 'ILO-1',
      );
      expect(listed.success, isTrue);
      expect(listed.targetDoctype, 'Customer');
      expect(listed.targetName, 'ILO-1');
      expect(listed.movedInvoices, 2);
    });
  });
}
