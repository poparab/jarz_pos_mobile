import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/shift_monitor/models/shift_monitor_models.dart';

void main() {
  test('parses shift monitor response with open and closed rows', () {
    final response = ShiftMonitorResponse.fromJson({
      'summary': {
        'open_count': 1,
        'closed_count': 1,
        'discrepancy_count': 1,
        'discrepancy_total': 50,
      },
      'filters': {
        'from_date': '2026-06-05',
        'to_date': '2026-06-05',
        'status': 'all',
      },
      'profiles': [
        {'name': 'Dokki', 'title': 'Dokki'},
      ],
      'shifts': [
        {
          'pos_profile': 'Dokki',
          'shift_status': 'closed',
          'opening_entry': 'POS-OPE-0001',
          'closing_entry': 'POS-CLO-0001',
          'opened_at': '2026-06-05 08:00:00',
          'closed_at': '2026-06-05 16:00:00',
          'opened_by_full_name': 'Omar',
          'closed_by_full_name': 'Sara',
          'cash_account': 'Dokki - J',
          'opening_amount': 1000,
          'expected_closing_amount': 1400,
          'actual_closing_amount': 1450,
          'difference_amount': 50,
          'difference_kind': 'surplus',
          'journal_entry': 'JE-0001',
        },
        {
          'pos_profile': 'Dokki',
          'shift_status': 'open',
          'opening_entry': 'POS-OPE-0002',
          'opened_at': '2026-06-05 18:00:00',
          'opened_by_full_name': 'Nada',
          'opening_amount': 750,
          'difference_kind': 'none',
        },
      ],
    });

    expect(response.summary.openCount, 1);
    expect(response.summary.closedCount, 1);
    expect(response.summary.discrepancyTotal, 50);
    expect(response.profiles.single.name, 'Dokki');
    expect(response.shifts, hasLength(2));
    expect(response.shifts.first.isClosed, isTrue);
    expect(response.shifts.first.hasDiscrepancy, isTrue);
    expect(response.shifts.first.closerLabel, 'Sara');
    expect(response.shifts.last.isOpen, isTrue);
    expect(response.shifts.last.closingEntry, isNull);
  });
}
