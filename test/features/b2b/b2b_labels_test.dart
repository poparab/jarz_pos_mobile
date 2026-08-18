// Label-stock data riding on the B2B payloads:
//  * `label_alert` on each pipeline card (crm.get_b2b_pipeline), and
//  * the nullable `labels` block on the account (crm.get_account).
//
// Both must parse TOLERANTLY: a backend without the labels feature sends
// neither key, and that has to read as "no alert / labels unknown" — never as
// a crash on the board or the account screen.

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/b2b/data/models/b2b_account_labels.dart';
import 'package:jarz_pos/src/features/b2b/data/models/b2b_models.dart';

Map<String, dynamic> _cardJson({dynamic labelAlert = _absent}) {
  final json = <String, dynamic>{
    'doctype': 'Lead',
    'name': 'LEAD-001',
    'title': 'Acme Co',
    'stage': 'Active',
  };
  if (!identical(labelAlert, _absent)) json['label_alert'] = labelAlert;
  return json;
}

const _absent = Object();

void main() {
  group('B2bCard.label_alert', () {
    test('parses the count the server sends', () {
      expect(B2bCard.fromJson(_cardJson(labelAlert: 2)).labelAlert, 2);
    });

    test('a missing key defaults to zero (older backend)', () {
      expect(B2bCard.fromJson(_cardJson()).labelAlert, 0);
    });

    test('an explicit null defaults to zero', () {
      expect(B2bCard.fromJson(_cardJson(labelAlert: null)).labelAlert, 0);
    });

    test('a double still counts as its integer value', () {
      // Frappe ints occasionally travel as doubles through JSON.
      expect(B2bCard.fromJson(_cardJson(labelAlert: 2.0)).labelAlert, 2);
    });
  });

  group('B2bAccountLabels.tryParse', () {
    test('null and absence read as "labels unknown"', () {
      expect(B2bAccountLabels.tryParse(null), isNull);
      expect(B2bAccountLabels.tryParse('junk'), isNull);
      expect(B2bAccountLabels.tryParse(42), isNull);
    });

    test('parses totals and per-flavour rows', () {
      final labels = B2bAccountLabels.tryParse({
        'total': 3,
        'needs_attention': 2,
        'out_of_stock': 1,
        'reorder_now': 1,
        'flavours': [
          {
            'label': 'JLBL-00001',
            'title': 'Mango',
            'size': 'Medium',
            'on_hand_qty': 0,
            'status': 'Out of Stock',
          },
          {
            'label': 'JLBL-00002',
            'title': 'Berry',
            'size': 'Large',
            'on_hand_qty': 120,
            'status': 'OK',
          },
        ],
      });

      expect(labels, isNotNull);
      expect(labels!.total, 3);
      expect(labels.needsAttention, 2);
      expect(labels.outOfStock, 1);
      expect(labels.reorderNow, 1);
      expect(labels.isEmpty, isFalse);
      expect(labels.flavours, hasLength(2));
      expect(labels.flavours.first.label, 'JLBL-00001');
      expect(labels.flavours.first.status, 'Out of Stock');
      expect(labels.flavours.last.onHandQty, 120);
    });

    test('an empty block reads as empty, prompting the setup shortcut', () {
      final labels = B2bAccountLabels.tryParse(const <String, dynamic>{});
      expect(labels, isNotNull);
      expect(labels!.isEmpty, isTrue);
      expect(labels.flavours, isEmpty);
    });

    test('junk flavour rows are skipped, not fatal', () {
      final labels = B2bAccountLabels.tryParse({
        'total': 1,
        'flavours': [
          'garbage',
          42,
          {'label': 'JLBL-00003', 'title': 'Lemon', 'status': 'OK'},
        ],
      });
      expect(labels!.flavours, hasLength(1));
      expect(labels.flavours.single.title, 'Lemon');
    });
  });
}
