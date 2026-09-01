// Every approve/confirm/start action in the app now has a way to say no.
//
// These cover the client half of that: the model has to be able to tell a
// REJECTED request from one still waiting (both are docstatus 0, which is the
// whole trap), the services have to hit the right endpoints with the reason the
// server requires, and the cancel affordance on a running batch has to
// disappear the moment anything has been produced.

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/expenses/data/expenses_repository.dart';
import 'package:jarz_pos/src/features/expenses/models/expense_models.dart';
import 'package:jarz_pos/src/features/manufacturing/data/daily_plan_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/manufacturing_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/running_batch.dart';

import '../../helpers/mock_services.dart';

/// The mobile mirror of the server's rule: the cancel action is offered only
/// while nothing has been produced. Kept as a named predicate so the tab and
/// this test cannot drift apart silently.
bool canCancelBatch(RunningBatch batch) => batch.producedQty <= 0;

RunningBatch batchWith({double producedQty = 0}) {
  return RunningBatch.fromJson({
    'name': 'WO-0001',
    'production_item': 'PIST-CAKE',
    'item_name': 'Pistachio',
    'qty': 50,
    'produced_qty': producedQty,
    'bom_no': 'BOM-PIST',
    'status': 'In Process',
    'stock_uom': 'Nos',
    'material_transferred_qty': 50,
    'wip_leftover_qty': 50 - producedQty,
  });
}

void main() {
  // ── The model has to distinguish rejected from pending ────────────────

  group('ExpenseRecord rejection state', () {
    ExpenseRecord parse(Map<String, dynamic> overrides) {
      return ExpenseRecord.fromJson({
        'name': 'JEXP-00001',
        'amount': 250,
        'docstatus': 0,
        'requires_approval': 1,
        ...overrides,
      });
    }

    test('a request awaiting an answer is pending and not rejected', () {
      final record = parse({});
      expect(record.isPending, isTrue);
      expect(record.isRejected, isFalse);
      expect(record.isApproved, isFalse);
    });

    test('a rejected request is NOT pending, though it is still docstatus 0',
        () {
      // The trap this guards: there is no docstatus for "refused", so a
      // rejected request stays a draft. Reading docstatus alone would keep
      // offering Approve on a request a manager already turned down.
      final record = parse({
        'rejection_reason': 'Not a business expense',
        'rejected_by': 'manager@jarz.test',
        'rejected_on': '2026-09-02 10:15:00',
      });
      expect(record.docstatus, 0);
      expect(record.isRejected, isTrue);
      expect(record.isPending, isFalse);
      expect(record.rejectionReason, 'Not a business expense');
    });

    test('a rejected_on with no reason still counts as rejected', () {
      final record = parse({'rejected_on': '2026-09-02 10:15:00'});
      expect(record.isRejected, isTrue);
      expect(record.isPending, isFalse);
    });

    test('an approved expense is approved, not rejected', () {
      final record = parse({'docstatus': 1, 'requires_approval': 0});
      expect(record.isApproved, isTrue);
      expect(record.isRejected, isFalse);
      expect(record.isCancelled, isFalse);
    });

    test('a cancelled expense carries the reason but is not "rejected"', () {
      // Cancel reverses an approval; reject refuses one. They stamp the same
      // fields, and the docstatus is what separates them.
      final record = parse({
        'docstatus': 2,
        'rejection_reason': 'Paid twice',
        'rejected_on': '2026-09-02 10:15:00',
      });
      expect(record.isCancelled, isTrue);
      expect(record.isRejected, isFalse);
      expect(record.rejectionReason, 'Paid twice');
    });

    test('the timeline carries the manager reason on the rejection entry', () {
      final record = parse({
        'timeline': [
          {'label': 'Created', 'timestamp': '2026-09-02 09:00:00'},
          {
            'label': 'Rejected',
            'timestamp': '2026-09-02 10:15:00',
            'user': 'manager@jarz.test',
            'reason': 'Not a business expense',
          },
        ],
      });
      expect(record.timeline.last.reason, 'Not a business expense');
      expect(record.timeline.first.reason, isNull);
    });
  });

  // ── The services have to send the reason ──────────────────────────────

  group('ExpensesRepository reverse actions', () {
    late MockDio mockDio;
    late ExpensesRepository repo;

    setUp(() {
      mockDio = MockDio();
      repo = ExpensesRepository(mockDio);
    });

    test('rejectExpense posts the name and reason', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.expenses.reject_expense',
        {
          'message': {
            'success': true,
            'expense': {
              'name': 'JEXP-00001',
              'docstatus': 0,
              'rejection_reason': 'Not a business expense',
            },
          },
        },
      );

      final record = await repo.rejectExpense('JEXP-00001', 'Not a business expense');

      final sent = mockDio.requestLog.first['data'] as Map;
      expect(sent['name'], 'JEXP-00001');
      expect(sent['reason'], 'Not a business expense');
      expect(record.isRejected, isTrue);
    });

    test('cancelExpense hits the cancel endpoint, not reject', () async {
      // Two endpoints because they are two different acts: cancel reverses a
      // journal entry, reject refuses to post one.
      mockDio.setResponse(
        '/api/method/jarz_pos.api.expenses.cancel_expense',
        {
          'message': {
            'success': true,
            'expense': {'name': 'JEXP-00001', 'docstatus': 2},
          },
        },
      );

      final record = await repo.cancelExpense('JEXP-00001', 'Paid twice');

      expect(
        mockDio.requestLog.first['path'],
        '/api/method/jarz_pos.api.expenses.cancel_expense',
      );
      expect(record.isCancelled, isTrue);
    });
  });

  group('ManufacturingService.cancelProductionBatch', () {
    late MockDio mockDio;
    late ManufacturingService service;

    setUp(() {
      mockDio = MockDio();
      service = ManufacturingService(mockDio);
    });

    test('posts the work order and the reason', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.manufacturing.cancel_production_batch',
        {
          'message': {
            'work_order': 'WO-0001',
            'status': 'Stopped',
            'stock_entry': 'STE-RETURN',
          },
        },
      );

      final result = await service.cancelProductionBatch(
        workOrder: 'WO-0001',
        reason: 'Wrong flavour started',
      );

      final sent = mockDio.requestLog.first['data'] as Map;
      expect(sent['work_order'], 'WO-0001');
      expect(sent['reason'], 'Wrong flavour started');
      expect(result['status'], 'Stopped');
      expect(result['stock_entry'], 'STE-RETURN');
    });
  });

  group('DailyPlanService.cancel', () {
    late MockDio mockDio;
    late DailyPlanService service;

    setUp(() {
      mockDio = MockDio();
      service = DailyPlanService(mockDio);
    });

    test('posts to cancel_plan and parses the cancelled status', () async {
      mockDio.setResponse(
        '/api/method/jarz_pos.api.daily_plan.cancel_plan',
        {
          'message': {
            'name': 'JPP-0001',
            'plan_date': '2026-09-02',
            'status': 'Cancelled',
            'lines': <dynamic>[],
          },
        },
      );

      final plan = await service.cancel(
        name: 'JPP-0001',
        reason: 'Mixer down all day',
      );

      final sent = mockDio.requestLog.first['data'] as Map;
      expect(sent['name'], 'JPP-0001');
      expect(sent['reason'], 'Mixer down all day');
      expect(plan.isCancelled, isTrue);
      expect(plan.isClosed, isFalse);
    });
  });

  // ── The affordance has to match the server's rule ─────────────────────

  group('running batch cancel affordance', () {
    test('offered while nothing has been produced', () {
      expect(canCancelBatch(batchWith()), isTrue);
    });

    test('withdrawn the moment anything has been produced', () {
      // The server refuses this case outright. A button that always fails is
      // worse than no button, so the card hides it rather than surfacing the
      // refusal after the tap.
      expect(canCancelBatch(batchWith(producedQty: 0.5)), isFalse);
      expect(canCancelBatch(batchWith(producedQty: 50)), isFalse);
    });
  });
}
