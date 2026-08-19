/// Master full-cycle E2E test runner.
///
/// Runs all full-cycle staging suites in sequence, in one process.
///
/// Run:
///   flutter test integration_test/full_cycle/run_full_cycle_test.dart \
///     --dart-define=STAGING_USER=x --dart-define=STAGING_PASSWORD=y
///
/// WHY THIS FILE LOOKS LIKE THIS
/// -----------------------------
/// It used to have an EMPTY `main()` plus a comment claiming that "importing
/// them registers their group()/test() calls". That is false — a Dart import
/// runs a library's top-level *initialisers*, never its `main()`. So this file
/// registered ZERO tests and reported a green pass no matter what state the
/// backend was in. The `// ignore_for_file: unused_import` was the tell: the
/// analyzer had already worked out that the imports did nothing.
///
/// Two honest options existed: delete the file, or make it genuinely call the
/// four `main()`s. Calling them is kept because the aggregate run is useful,
/// but each one is wrapped in its own `group()` rather than invoked bare.
/// That matters: all four suites register `setUpAll`/`tearDownAll` at the TOP
/// LEVEL, so calling `pos_full_cycle.main(); kanban_full_cycle.main(); ...`
/// would hoist all four `setUpAll`s ahead of the first test and defer all four
/// `tearDownAll`s to the very end — four suites fighting over one POS shift,
/// with cleanup running long after the invoices it owns were needed. Wrapping
/// each in a `group()` scopes its fixtures, so the suites run strictly
/// sequentially: setUp -> tests -> tearDown, one suite at a time.
///
/// NOTE: this is a `flutter test` (VM) suite that talks to staging over HTTP.
/// It is NOT a device integration test, so the ~50s device crash limit does not
/// apply — but it does take as long as all four suites combined.
@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';

import 'accounting_round_trip_test.dart' as accounting_round_trip;
import 'kanban_full_cycle_test.dart' as kanban_full_cycle;
import 'multi_case_lifecycle_test.dart' as multi_case_lifecycle;
import 'pos_full_cycle_test.dart' as pos_full_cycle;

void main() {
  group('pos_full_cycle', pos_full_cycle.main);
  group('kanban_full_cycle', kanban_full_cycle.main);
  group('accounting_round_trip', accounting_round_trip.main);
  group('multi_case_lifecycle', multi_case_lifecycle.main);
}
