/// Master full-cycle E2E test runner.
///
/// Imports and runs all full-cycle integration tests in sequence.
/// Each test group logs in independently and cleans up after itself.
///
/// Run:
///   flutter test integration_test/full_cycle/run_full_cycle_test.dart \
///     --dart-define=STAGING_USER=x --dart-define=STAGING_PASSWORD=y
@TestOn('vm')
// ignore_for_file: unused_import
library;

import 'package:flutter_test/flutter_test.dart';

// Full-cycle tests are self-contained groups with their own login/teardown.
// Importing them registers their group()/test() calls in the test framework.
import 'pos_full_cycle_test.dart' as pos_full_cycle;
import 'kanban_full_cycle_test.dart' as kanban_full_cycle;
import 'accounting_round_trip_test.dart' as accounting_round_trip;
import 'multi_case_lifecycle_test.dart' as multi_case_lifecycle;

void main() {
  // The imported test files register their own group()/test() calls at import
  // time, so they run automatically when this file is executed.
}
