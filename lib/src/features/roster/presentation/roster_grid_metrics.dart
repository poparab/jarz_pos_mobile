import 'package:flutter/widgets.dart';

/// The shift distribution grid's geometry. The ONLY place these numbers exist.
///
/// The grid is three independently laid-out strips: the pinned name column,
/// the header and totals rows, and the day-cell rows. Nothing links them except
/// that they are sized identically, so a day cell even one pixel larger than
/// the header above it or the name beside it compounds down the month. That
/// shipped: each day cell was 56x62 plus a 1px outer margin, so it really took
/// 58x64 against 56-wide headers and 62-tall names, and by day 29 the columns
/// sat a full column away from their dates while the rows slid past their names.
/// A manager reading "off" beside one person was looking at a neighbour's day.
///
/// The rules that keep the strips aligned — the same ones the attendance month
/// grid follows (`attendance_grid_metrics.dart`), because it had the same bug:
///
/// 1. Day cells, date headers, totals cells and name cells all read their size
///    from here. No widget in the grid carries a size of its own.
/// 2. Each takes up EXACTLY its slot on the outside. A visible gap between
///    cells is drawn INSIDE that footprint with [cellInset], never as outer
///    margin, because margin adds to the footprint.
///
/// `test/features/roster/roster_grid_alignment_test.dart` pumps a full month
/// and checks every cell against its name and its date. That test is what
/// enforces these rules.
abstract final class RosterGridMetrics {
  /// Width of one day column. Header, totals cell and day cell all.
  static const double cellWidth = 56;

  /// Height of one employee row. Name cell and day cell both.
  static const double rowHeight = 62;

  /// Height of the date header row, and of the name column's header beside it.
  static const double headerHeight = 42;

  /// Height of the on-duty totals row, and of its label beside it.
  static const double totalsHeight = 30;

  /// Width of the pinned name column.
  static const double nameWidth = 120;

  /// The visible gap between neighbouring day cells, drawn inside each cell's
  /// footprint.
  static const EdgeInsets cellInset = EdgeInsets.all(1);

  /// One day cell's outer footprint.
  static const Size slot = Size(cellWidth, rowHeight);

  /// One date header's outer footprint.
  static const Size headerSlot = Size(cellWidth, headerHeight);

  /// One totals cell's outer footprint.
  static const Size totalsSlot = Size(cellWidth, totalsHeight);

  /// One name cell's outer footprint.
  static const Size nameSlot = Size(nameWidth, rowHeight);
}
