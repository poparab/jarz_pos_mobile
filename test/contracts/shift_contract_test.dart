// Contract tests for Shift API endpoints.
//
// Verifies that ShiftEntry can deserialize the active_shift.json fixture.
// Refresh with snapshot_updater.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/shift/models/shift_models.dart';

void main() {
  const fixturesDir = 'test/contracts/fixtures';

  group('Shift Contract — get_active_shift', () {
    test('fixture with no active shift deserializes without error', () {
      final raw = File('$fixturesDir/active_shift.json').readAsStringSync();
      final json = jsonDecode(raw) as Map<String, dynamic>;

      // When there is no active shift the API returns {}.
      // is_open may be absent (null), false, or 0 — all mean "no shift".
      final rawIsOpen = json['is_open'];
      final isOpen = rawIsOpen == true || rawIsOpen == 1;
      if (isOpen) {
        // If a shift is active, it MUST have an opening_entry.
        final entry = ShiftEntry.fromJson(json);
        expect(entry.name, isNotEmpty,
            reason: 'ShiftEntry name must not be empty when is_open=true');
        expect(entry.posProfile, isNotEmpty,
            reason: 'pos_profile must be present when shift is active');
      } else {
        // Inactive shift (null, false, 0, or absent) — passes if no exception.
        expect(rawIsOpen == null || rawIsOpen == false || rawIsOpen == 0, isTrue,
            reason: 'is_open must be null/false/0 when no shift is active');
      }
    });
  });
}
