import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/leads/data/models/lead.dart';

void main() {
  group('Lead.fromJson — full get_lead payload', () {
    // A representative full-detail response as the backend `get_lead` returns it:
    // every snake_case key present, including branches[], both addresses, notes.
    final fullJson = <String, dynamic>{
      'name': 'LEAD-0001',
      'source_brand_id': 'BR-42',
      'lead_name': 'Zooba Restaurant',
      'category': 'Restaurant',
      'score': 87,
      'tier': 'A',
      'branch_count': 4,
      'price_band': r'$$',
      'avg_rating': 4.6,
      'total_reviews': 1200,
      'open_status': 'Open',
      'sahel_branches': 2,
      'is_specialty': true,
      'primary_area': 'Zamalek',
      'regions': ['Cairo', 'North Coast'],
      'governorates': ['Cairo', 'Matrouh'],
      'areas': ['Zamalek', 'Sahel'],
      'phone': '+201234567890',
      'website': 'https://zooba.com',
      'instagram': '@zooba',
      'facebook': 'zooba',
      'maps_url': 'https://maps.google.com/?q=zooba',
      'confidence': 'high',
      'status': 'Active',
      'b2b_stage': 'Contacted',
      'last_verified': '2026-07-01',
      'latitude': 30.06,
      'longitude': 31.22,
      'branches': [
        {
          'branch_name': 'Zooba Zamalek',
          'area': 'Zamalek',
          'region': 'Cairo',
          'governorate': 'Cairo',
          'rating': 4.7,
          'reviews': 800,
          'price': r'$$',
          'status': 'Open',
          'hours': '9am-11pm',
          'phone': '+201111111111',
          'website': 'https://zooba.com/zamalek',
          'maps_url': 'https://maps.google.com/?q=zamalek',
          'address': '10 Some St, Zamalek',
          'latitude': 30.061,
          'longitude': 31.221,
        },
        {
          // A branch with a null rating to confirm nullable parsing.
          'branch_name': 'Zooba Sahel',
          'area': 'Sahel',
          'region': 'North Coast',
          'governorate': 'Matrouh',
          'rating': null,
          'reviews': 0,
        },
      ],
      'primary_address': {
        'name': 'ADDR-1',
        'address_line1': '10 Some St',
        'address_line2': 'Floor 2',
        'city': 'Cairo',
        'state': 'Cairo',
        'country': 'Egypt',
        'pincode': '11511',
        'phone': '+201234567890',
      },
      'shipping_address': {
        'name': 'ADDR-2',
        'address_line1': 'Warehouse 5',
        'city': 'Giza',
        'country': 'Egypt',
      },
      'notes': 'Interested in bulk orders.',
    };

    test('decodes scalar + nullable fields with correct types', () {
      final lead = Lead.fromJson(fullJson);

      expect(lead.name, 'LEAD-0001');
      expect(lead.sourceBrandId, 'BR-42');
      expect(lead.leadName, 'Zooba Restaurant');
      expect(lead.category, 'Restaurant');
      expect(lead.score, 87);
      expect(lead.tier, 'A');
      expect(lead.branchCount, 4);
      expect(lead.priceBand, r'$$');
      expect(lead.avgRating, 4.6);
      expect(lead.avgRating, isA<double>());
      expect(lead.totalReviews, 1200);
      expect(lead.sahelBranches, 2);
      expect(lead.isSpecialty, isTrue);
      expect(lead.isSpecialty, isA<bool>());
      expect(lead.primaryArea, 'Zamalek');
      expect(lead.latitude, 30.06);
      expect(lead.longitude, 31.22);
      expect(lead.lastVerified, '2026-07-01');
      expect(lead.notes, 'Interested in bulk orders.');
    });

    test('parses list fields', () {
      final lead = Lead.fromJson(fullJson);

      expect(lead.regions, ['Cairo', 'North Coast']);
      expect(lead.governorates, ['Cairo', 'Matrouh']);
      expect(lead.areas, ['Zamalek', 'Sahel']);
    });

    test('parses branches[] including a branch with a null rating', () {
      final lead = Lead.fromJson(fullJson);

      expect(lead.branches, hasLength(2));

      final first = lead.branches.first;
      expect(first, isA<LeadBranch>());
      expect(first.branchName, 'Zooba Zamalek');
      expect(first.rating, 4.7);
      expect(first.reviews, 800);
      expect(first.latitude, 30.061);

      final second = lead.branches.last;
      expect(second.branchName, 'Zooba Sahel');
      expect(second.rating, isNull);
      expect(second.reviews, 0);
    });

    test('parses primary_address + shipping_address', () {
      final lead = Lead.fromJson(fullJson);

      final primary = lead.primaryAddress;
      expect(primary, isNotNull);
      expect(primary!.name, 'ADDR-1');
      expect(primary.addressLine1, '10 Some St');
      expect(primary.addressLine2, 'Floor 2');
      expect(primary.city, 'Cairo');
      expect(primary.state, 'Cairo');
      expect(primary.country, 'Egypt');
      expect(primary.pincode, '11511');
      expect(primary.phone, '+201234567890');

      final shipping = lead.shippingAddress;
      expect(shipping, isNotNull);
      expect(shipping!.name, 'ADDR-2');
      expect(shipping.addressLine1, 'Warehouse 5');
      expect(shipping.city, 'Giza');
      // Unspecified fields default to ''.
      expect(shipping.state, '');
      expect(shipping.pincode, '');
    });

    test('honors nullable rating/lat/lng when absent from payload', () {
      final json = Map<String, dynamic>.from(fullJson)
        ..remove('avg_rating')
        ..remove('latitude')
        ..remove('longitude');

      final lead = Lead.fromJson(json);
      expect(lead.avgRating, isNull);
      expect(lead.latitude, isNull);
      expect(lead.longitude, isNull);
    });
  });

  group('Lead.fromJson — lightweight get_leads card payload', () {
    // A card map as `get_leads` returns it: no branches/addresses/notes.
    final cardJson = <String, dynamic>{
      'name': 'LEAD-0002',
      'lead_name': 'Cilantro',
      'category': 'Cafe',
      'score': 55,
      'tier': 'B',
      'branch_count': 12,
      'price_band': r'$',
      'avg_rating': 4.1,
      'total_reviews': 300,
      'sahel_branches': 0,
      'is_specialty': false,
      'primary_area': 'Maadi',
      'areas': ['Maadi', 'Nasr City'],
      'phone': '+201000000000',
      'instagram': '@cilantro',
    };

    test('decodes without error', () {
      expect(() => Lead.fromJson(cardJson), returnsNormally);
    });

    test('detail-only fields default to empty/null', () {
      final lead = Lead.fromJson(cardJson);

      expect(lead.branches, isEmpty);
      expect(lead.primaryAddress, isNull);
      expect(lead.shippingAddress, isNull);
      expect(lead.notes, '');
    });

    test('still populates the card fields', () {
      final lead = Lead.fromJson(cardJson);

      expect(lead.name, 'LEAD-0002');
      expect(lead.leadName, 'Cilantro');
      expect(lead.tier, 'B');
      expect(lead.branchCount, 12);
      expect(lead.sahelBranches, 0);
      expect(lead.isSpecialty, isFalse);
      expect(lead.areas, ['Maadi', 'Nasr City']);
    });

    test('missing optional card keys fall back to null-safe defaults', () {
      final minimal = <String, dynamic>{'name': 'LEAD-0003'};
      final lead = Lead.fromJson(minimal);

      expect(lead.name, 'LEAD-0003');
      expect(lead.leadName, '');
      expect(lead.category, isNull);
      expect(lead.score, 0);
      expect(lead.tier, '');
      expect(lead.branchCount, 0);
      expect(lead.avgRating, isNull);
      expect(lead.totalReviews, 0);
      expect(lead.regions, isEmpty);
      expect(lead.governorates, isEmpty);
      expect(lead.areas, isEmpty);
      expect(lead.phone, '');
      expect(lead.instagram, '');
      expect(lead.website, '');
    });
  });

  group('LeadAddress.toJson — set_lead_address contract', () {
    test('produces the snake_case keys the backend expects', () {
      const address = LeadAddress(
        name: 'ADDR-9',
        addressLine1: '1 Main St',
        addressLine2: 'Apt 3',
        city: 'Alexandria',
        state: 'Alexandria',
        country: 'Egypt',
        pincode: '21500',
        phone: '+201555555555',
      );

      final json = address.toJson();

      // The keys set_lead_address consumes.
      expect(json['address_line1'], '1 Main St');
      expect(json['address_line2'], 'Apt 3');
      expect(json['city'], 'Alexandria');
      expect(json['state'], 'Alexandria');
      expect(json['country'], 'Egypt');
      expect(json['pincode'], '21500');
      expect(json['phone'], '+201555555555');

      // Snake_case keys must be present (not the camelCase Dart field names).
      expect(json.containsKey('address_line1'), isTrue);
      expect(json.containsKey('address_line2'), isTrue);
      expect(json.containsKey('addressLine1'), isFalse);
      expect(json.containsKey('addressLine2'), isFalse);
    });

    test('round-trips through fromJson/toJson', () {
      const address = LeadAddress(
        addressLine1: '5 Nile St',
        city: 'Cairo',
        country: 'Egypt',
        pincode: '11511',
        phone: '+2010',
      );

      final decoded = LeadAddress.fromJson(address.toJson());
      expect(decoded, address);
    });
  });
}
