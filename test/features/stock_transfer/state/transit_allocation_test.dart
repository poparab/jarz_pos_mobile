import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/stock_transfer/data/stock_handover_models.dart';
import 'package:jarz_pos/src/features/stock_transfer/data/stock_transfer_service.dart';
import 'package:jarz_pos/src/features/stock_transfer/state/transit_allocation.dart';

TransitSend _send(
  String name,
  String source,
  Map<String, double> remaining, {
  bool overdue = false,
}) =>
    TransitSend(
      name: name,
      sourceWarehouse: source,
      sourceLabel: '$source label',
      overdue: overdue,
      canAct: true,
      lines: [
        for (final e in remaining.entries)
          TransitSendLine(
            itemCode: e.key,
            itemName: e.key,
            qty: e.value,
            remaining: e.value,
          ),
      ],
    );

TransitSuggestion _sug(
  String? dispatch,
  String source,
  double qty, {
  TransitConfidence confidence = TransitConfidence.high,
  List<String> reasons = const ['exact_qty'],
}) =>
    TransitSuggestion(
      dispatch: dispatch,
      sourceWarehouse: source,
      sourceLabel: '$source label',
      qty: qty,
      confidence: confidence,
      reasons: [for (final r in reasons) TransitReason(code: r)],
    );

TransitReceiptLine _line(
  String item,
  double qty,
  List<TransitSuggestion> suggestions, {
  double unresolved = 0,
}) =>
    TransitReceiptLine(
      itemCode: item,
      itemName: item,
      qty: qty,
      suggestions: suggestions,
      unresolvedQty: unresolved,
    );

TransitReceipt _receipt(
  String name,
  String target,
  List<TransitReceiptLine> lines, {
  bool canApprove = true,
  String? named,
}) =>
    TransitReceipt(
      name: name,
      targetWarehouse: target,
      targetLabel: '$target label',
      namedSource: named,
      canApprove: canApprove,
      lines: lines,
    );

/// Factory F sent A×10 + B×5 (S1); branch B2 sent A×4 (S2). Branch B1
/// received exactly S1 (all high); branch B3 received S2's 4 (medium).
TransitBoard _board({List<TransitReceipt>? receipts}) => TransitBoard(
      version: 'v1',
      sends: [
        _send('S1', 'F', {'A': 10, 'B': 5}),
        _send('S2', 'B2', {'A': 4}),
      ],
      receipts: receipts ??
          [
            _receipt('R1', 'B1', [
              _line('A', 10, [_sug('S1', 'F', 10)]),
              _line('B', 5, [_sug('S1', 'F', 5)]),
            ]),
            _receipt('R2', 'B3', [
              _line('A', 4, [
                _sug('S2', 'B2', 4,
                    confidence: TransitConfidence.medium,
                    reasons: ['only_sender']),
              ]),
            ]),
          ],
      senders: const [
        HandoverSide(warehouse: 'F', label: 'Factory', kind: 'factory'),
        HandoverSide(warehouse: 'B1', label: 'Branch 1', kind: 'branch'),
        HandoverSide(warehouse: 'B2', label: 'Branch 2', kind: 'branch'),
      ],
    );

ReceiptAllocation _alloc(TransitBoard board, String name) =>
    ReceiptAllocation.fromBoard(
        board, board.receipts.firstWhere((r) => r.name == name));

void main() {
  group('prefill from suggestions', () {
    test('every line starts at the engine suggestion and adds up', () {
      final a = _alloc(_board(), 'R1');

      expect(a.version, 'v1');
      expect(a.lineFor('A')!.sendQty, {'S1': 10.0});
      expect(a.lineFor('B')!.sendQty, {'S1': 5.0});
      expect(a.lines.every((l) => l.leftToAssign == 0), isTrue);
      expect(a.fullyAssigned, isTrue);
      expect(a.canApprove, isTrue);
      expect(a.isConfident, isTrue);
      expect(a.lines.every((l) => l.keptSuggestion), isTrue);
    });

    test('suggested sends come first; others are listed with what is '
        'reserved for other receipts', () {
      final line = _alloc(_board(), 'R1').lineFor('A')!;

      expect(line.options.map((o) => o.dispatch), ['S1', 'S2']);
      expect(line.optionFor('S2')!.remaining, 4);
      expect(line.optionFor('S2')!.reservedElsewhere, 4,
          reason: 'R2 was suggested all of S2');
      expect(line.optionFor('S1')!.reservedElsewhere, 0);
    });

    test('a send from the receiver itself is never an option', () {
      final board = _board(receipts: [
        _receipt('R9', 'B2', [_line('A', 2, const [])]),
      ]);
      final line = _alloc(board, 'R9').lineFor('A')!;

      expect(line.options.map((o) => o.dispatch), ['S1']);
    });

    test('medium confidence can be approved but is not "confident"', () {
      final a = _alloc(_board(), 'R2');

      expect(a.canApprove, isTrue);
      expect(a.isConfident, isFalse);
      expect(confidentReceipts(_board()).map((x) => x.receipt.name), ['R1']);
    });

    test('unresolved quantity keeps a line out of the confident batch', () {
      final board = _board(receipts: [
        _receipt('R1', 'B1', [
          _line('A', 12, [_sug('S1', 'F', 10)], unresolved: 2),
        ]),
      ]);
      final a = _alloc(board, 'R1');

      expect(a.lineFor('A')!.leftToAssign, 2);
      expect(a.canApprove, isFalse);
      expect(a.isConfident, isFalse);
    });
  });

  group('left to assign', () {
    test('lowering a send leaves units to place and blocks Approve', () {
      final a = _alloc(_board(), 'R1');
      final line = a.lineFor('A')!..setSendQty('S1', 6);

      expect(line.assigned, 6);
      expect(line.leftToAssign, 4);
      expect(line.fullyAssigned, isFalse);
      expect(a.canApprove, isFalse);
      expect(a.openLines, 1);
    });

    test('fill the rest takes what is left, up to the send remaining', () {
      final a = _alloc(_board(), 'R1');
      final line = a.lineFor('A')!..setSendQty('S1', 3);

      line.fillRestFrom('S2'); // 7 left, S2 has only 4
      expect(line.qtyFor('S2'), 4);
      expect(line.leftToAssign, 3);

      line.fillRestFrom('S1');
      expect(line.qtyFor('S1'), 6);
      expect(line.leftToAssign, 0);
      expect(a.canApprove, isTrue);
      expect(line.keptSuggestion, isFalse);
      expect(a.isConfident, isFalse, reason: 'the manager changed it');
    });

    test('over-assigning, or taking more than a send has left, blocks', () {
      final a = _alloc(_board(), 'R1');
      final line = a.lineFor('A')!..setSendQty('S2', 2);

      expect(line.leftToAssign, -2);
      expect(a.canApprove, isFalse);

      line
        ..setSendQty('S1', 4)
        ..setSendQty('S2', 6); // S2 has 4 left
      expect(line.leftToAssign, 0);
      expect(line.overRemaining('S2'), isTrue);
      expect(line.fullyAssigned, isFalse);
      expect(a.canApprove, isFalse);
    });

    test('a zero or invalid qty removes the send', () {
      final line = _alloc(_board(), 'R1').lineFor('A')!
        ..setSendQty('S1', 0)
        ..setSendQty('S2', double.nan);

      expect(line.sendQty, isEmpty);
    });

    test('Approve needs the receipt itself to allow it', () {
      final board = _board(receipts: [
        _receipt('R1', 'B1', [
          _line('A', 10, [_sug('S1', 'F', 10)]),
        ], canApprove: false),
      ]);
      final a = _alloc(board, 'R1');

      expect(a.fullyAssigned, isTrue);
      expect(a.canApprove, isFalse);
      expect(a.isConfident, isFalse);
    });
  });

  group('received-qty correction', () {
    test('a correction reshapes left-to-assign and sends every item', () {
      final a = _alloc(_board(), 'R1');
      final line = a.lineFor('A')!..received = 8;

      expect(line.receivedChanged, isTrue);
      expect(line.leftToAssign, -2);
      expect(a.canApprove, isFalse);

      line.setSendQty('S1', 8);
      expect(a.canApprove, isTrue);
      expect(a.isConfident, isFalse);
      expect(a.receivedPayload(), {'A': 8.0, 'B': 5.0});
    });

    test('no correction sends no received map', () {
      expect(_alloc(_board(), 'R1').receivedPayload(), isNull);
    });

    test('nothing received at all cannot be approved', () {
      final a = _alloc(_board(), 'R2');
      a.lineFor('A')!
        ..received = 0
        ..setSendQty('S2', 0);

      expect(a.fullyAssigned, isTrue);
      expect(a.canApprove, isFalse);
    });

    test('reset puts back the suggestion and the declared qty', () {
      final a = _alloc(_board(), 'R1');
      final line = a.lineFor('A')!
        ..received = 7
        ..setSendQty('S1', 1)
        ..addDirect('B2', 'Branch 2');

      line.resetToSuggestion();
      expect(line.received, 10);
      expect(line.sendQty, {'S1': 10.0});
      expect(line.direct, isEmpty);
      expect(line.keptSuggestion, isTrue);
    });
  });

  group('"sender didn\'t declare" rows', () {
    test('a no-send suggestion prefills a direct row', () {
      final board = _board(receipts: [
        _receipt('R5', 'B1', [
          _line('C', 3, [
            _sug(null, 'B2', 3,
                confidence: TransitConfidence.low,
                reasons: ['no_send_declared']),
          ]),
        ]),
      ]);
      final a = _alloc(board, 'R5');
      final line = a.lineFor('C')!;

      expect(line.options, isEmpty);
      expect(line.direct.single.sourceWarehouse, 'B2');
      expect(line.direct.single.qty, 3);
      expect(a.canApprove, isTrue);
      expect(a.isConfident, isFalse, reason: 'low confidence');

      final rows = a.allocationsPayload();
      expect(rows.single, {
        'item_code': 'C',
        'dispatch': null,
        'source_warehouse': 'B2',
        'qty': 3.0,
        'was_recommended': 1,
        'confidence': 'low',
      });
    });

    test('adding a sender prefills what is left; the receiver itself and '
        'duplicates are ignored', () {
      final a = _alloc(_board(), 'R1');
      final line = a.lineFor('A')!..setSendQty('S1', 7);

      line.addDirect('B1', 'Branch 1'); // the receiver itself
      expect(line.direct, isEmpty);

      line.addDirect('B2', 'Branch 2');
      expect(line.direct.single.qty, 3);
      expect(line.leftToAssign, 0);
      expect(a.canApprove, isTrue);

      line.addDirect('B2', 'Branch 2');
      expect(line.direct, hasLength(1));

      line.setDirectQty('B2', 1);
      expect(line.leftToAssign, 2);

      line.removeDirect('B2');
      expect(line.direct, isEmpty);
      expect(line.leftToAssign, 3);
    });

    test('a manually added sender is sent with was_recommended 0', () {
      final a = _alloc(_board(), 'R1');
      a.lineFor('A')!
        ..setSendQty('S1', 7)
        ..addDirect('B2', 'Branch 2');

      final rows =
          a.allocationsPayload().where((r) => r['item_code'] == 'A').toList();
      expect(rows, hasLength(2));
      final direct = rows.firstWhere((r) => r['dispatch'] == null);
      expect(direct['source_warehouse'], 'B2');
      expect(direct['qty'], 3.0);
      expect(direct['was_recommended'], 0);
      expect(direct['confidence'], '');
    });
  });

  group('approve_receipt payload', () {
    test('a kept suggestion is recommended with its confidence', () {
      final rows = _alloc(_board(), 'R1').allocationsPayload();

      expect(rows, [
        {
          'item_code': 'A',
          'dispatch': 'S1',
          'source_warehouse': 'F',
          'qty': 10.0,
          'was_recommended': 1,
          'confidence': 'high',
        },
        {
          'item_code': 'B',
          'dispatch': 'S1',
          'source_warehouse': 'F',
          'qty': 5.0,
          'was_recommended': 1,
          'confidence': 'high',
        },
      ]);
      expect(positiveAllocations(rows), rows,
          reason: 'already in the wire shape');
    });

    test('a changed line is not recommended; an untouched one still is', () {
      final a = _alloc(_board(), 'R1');
      a.lineFor('A')!
        ..setSendQty('S1', 6)
        ..setSendQty('S2', 4);

      final rows = a.allocationsPayload();
      final aRows = rows.where((r) => r['item_code'] == 'A').toList();
      expect(aRows.map((r) => r['dispatch']), ['S1', 'S2']);
      expect(aRows.every((r) => r['was_recommended'] == 0), isTrue);
      expect(aRows.firstWhere((r) => r['dispatch'] == 'S1')['confidence'],
          'high');
      expect(aRows.firstWhere((r) => r['dispatch'] == 'S2')['confidence'], '',
          reason: 'S2 was never suggested for this receipt');
      final bRow = rows.singleWhere((r) => r['item_code'] == 'B');
      expect(bRow['was_recommended'], 1);
    });

    test('a split suggestion kept as-is is recommended on both rows', () {
      final board = _board(receipts: [
        _receipt('R1', 'B1', [
          _line('A', 12, [
            _sug('S1', 'F', 8, reasons: ['split']),
            _sug('S2', 'B2', 4,
                confidence: TransitConfidence.medium, reasons: ['split']),
          ]),
        ]),
      ]);
      final rows = _alloc(board, 'R1').allocationsPayload();

      expect(rows.map((r) => (r['dispatch'], r['qty'], r['confidence'])), [
        ('S1', 8.0, 'high'),
        ('S2', 4.0, 'medium'),
      ]);
      expect(rows.every((r) => r['was_recommended'] == 1), isTrue);
    });
  });

  group('drift', () {
    test('recognises the server drift sentence', () {
      expect(
        isTransitDrift(
            'Something changed in this batch. Reload and check again.'),
        isTrue,
      );
      expect(isTransitDrift('Not enough stock'), isFalse);
    });
  });

  group('can_direct', () {
    test('parses true from the board response', () {
      final board = TransitBoard.fromJson({'version': 'v1', 'can_direct': true});
      expect(board.canDirect, isTrue);
    });

    test('accepts the 1/0 form Frappe sends', () {
      expect(TransitBoard.fromJson({'can_direct': 1}).canDirect, isTrue);
      expect(TransitBoard.fromJson({'can_direct': 0}).canDirect, isFalse);
    });

    test('defaults to false when missing', () {
      expect(TransitBoard.fromJson({'version': 'v1'}).canDirect, isFalse);
      expect(const TransitBoard().canDirect, isFalse);
    });
  });
}
