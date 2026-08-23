import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/utils/territory_label.dart';

void main() {
  // Rows shaped like what jarz_pos.api.customer.get_territories returns on
  // production: the record is *named* by its Woo code and territory_name is
  // equal to that code, so territory_name_ar is the only human label.
  Map<String, dynamic> row({
    String name = 'EGNASRCITY',
    String? territoryName = 'EGNASRCITY',
    String? nameAr = 'مدينة نصر',
    String? wooCode = 'EGNASRCITY',
  }) => {
    'name': name,
    if (territoryName != null) 'territory_name': territoryName,
    if (nameAr != null) 'territory_name_ar': nameAr,
    if (wooCode != null) 'woo_code': wooCode,
  };

  group('territoryLabelOf', () {
    test('prefers the Arabic name over the Woo code', () {
      expect(territoryLabelOf(row()), 'مدينة نصر');
    });

    test('falls back to the title when the Arabic name is blank', () {
      // The backend sends "" — not null — for a territory with no Arabic name,
      // so a plain `??` chain would resolve to an empty label.
      expect(
        territoryLabelOf(row(territoryName: 'Nasr City', nameAr: '')),
        'Nasr City',
      );
      expect(
        territoryLabelOf(row(territoryName: 'Nasr City', nameAr: '   ')),
        'Nasr City',
      );
    });

    test('falls back to the record name when nothing else is set', () {
      expect(territoryLabelOf(row(territoryName: '', nameAr: '')), 'EGNASRCITY');
    });

    test('reads the id/territory spellings other payloads use', () {
      expect(
        territoryLabelOf({'id': 'EGMAADI', 'territory_name_ar': ''}),
        'EGMAADI',
      );
      expect(territoryLabelOf({'territory': 'EGMAADI'}), 'EGMAADI');
    });

    test('is empty for a null or empty row', () {
      expect(territoryLabelOf(null), '');
      expect(territoryLabelOf(const {}), '');
    });
  });

  group('territoryLabel', () {
    test('applies the same Arabic-first precedence to model fields', () {
      expect(
        territoryLabel(
          nameAr: 'مدينة نصر',
          display: 'EGNASRCITY',
          raw: 'EGNASRCITY',
        ),
        'مدينة نصر',
      );
    });

    test('skips blanks rather than stopping at them', () {
      expect(territoryLabel(nameAr: '', display: '  ', raw: 'EGMAADI'), 'EGMAADI');
    });

    test('accepts non-string scalars from realtime and FCM payloads', () {
      expect(territoryLabel(nameAr: null, display: null, raw: 12345), '12345');
    });

    test('is empty when the invoice carries no territory at all', () {
      expect(territoryLabel(), '');
    });
  });

  group('isSelectableTerritory', () {
    test('keeps a territory that carries a Woo code', () {
      expect(isSelectableTerritory(row()), isTrue);
    });

    test('drops structural nodes and sub-zones, which carry no Woo code', () {
      // "Egypt" and the Arabic-named sub-zones under a coded parent are real
      // Territory records, but an order can never ship to them directly.
      expect(isSelectableTerritory({'name': 'Egypt', 'woo_code': null}), isFalse);
      expect(
        isSelectableTerritory({'name': 'القرية الذكية', 'woo_code': ''}),
        isFalse,
      );
      expect(isSelectableTerritory({'name': 'EG6OCT', 'woo_code': '  '}), isFalse);
    });

    test('keeps a row from a backend too old to send woo_code', () {
      // Absent key means "unknown", not "uncoded" — dropping those would empty
      // the picker against an older server.
      expect(
        isSelectableTerritory({'name': 'EGMAADI', 'territory_name': 'EGMAADI'}),
        isTrue,
      );
    });

    test('drops a null row', () {
      expect(isSelectableTerritory(null), isFalse);
    });
  });

  group('selectableTerritories', () {
    test('filters a list in place, preserving backend order', () {
      final list = <Map<String, dynamic>>[
        {'name': 'All Territories'},
        {'name': 'Egypt', 'woo_code': ''},
        row(name: 'EGZAYED', wooCode: 'EGZAYED'),
        {'name': 'القرية الذكية', 'woo_code': null},
        row(name: 'EGMAADI', wooCode: 'EGMAADI'),
      ];

      expect(
        selectableTerritories(list).map((t) => t['name']).toList(),
        // "All Territories" has no woo_code key at all, so it survives the
        // client-side guard; the server-side filter is what removes it.
        ['All Territories', 'EGZAYED', 'EGMAADI'],
      );
    });
  });
}
