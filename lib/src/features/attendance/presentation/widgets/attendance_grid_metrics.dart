import 'package:flutter/widgets.dart';

/// The month grid's geometry. The ONLY place these numbers exist.
///
/// The grid is three independently laid-out strips: the pinned name column,
/// the date header row, and the cell rows. Nothing links them except that
/// they are sized identically. So if a cell is even one pixel larger than
/// the header above it or the name beside it, the error builds up: row 14's
/// absence ends up beside the wrong person, and day 24 sits under the wrong
/// date. That already shipped once. Each cell was 46x54 plus a 1px outer
/// margin, so it really took 48x56 against 46x54 headers.
///
/// The rules that keep the strips aligned:
///
/// 1. The cell, the date header and the name cell all read their size from
///    here. No widget in the grid has a size of its own.
/// 2. Each of them takes up EXACTLY [slot] (or [nameSlot] / [headerSlot]) on
///    the outside. A visual gap between cells is drawn INSIDE that space with
///    [cellInset], never as outer margin, because margin adds to the
///    footprint.
///
/// `test/features/attendance/attendance_month_grid_test.dart` pumps a
/// 24-employee, 31-day grid and checks the far corner against its name and
/// date. That test is what enforces these rules.
abstract final class AttendanceGridMetrics {
  /// Width of one day column. Header and cell both.
  static const double cellWidth = 46;

  /// Height of one employee row. Name cell and day cell both.
  static const double rowHeight = 54;

  /// Height of the date header row, and of the name column's header above it.
  static const double headerHeight = 44;

  /// Width of the pinned name column.
  static const double nameWidth = 136;

  /// The visible gap between neighbouring cells, drawn inside each cell's
  /// footprint.
  static const EdgeInsets cellInset = EdgeInsets.all(1);

  /// One day cell's outer footprint.
  static const Size slot = Size(cellWidth, rowHeight);

  /// One date header's outer footprint.
  static const Size headerSlot = Size(cellWidth, headerHeight);

  /// One name cell's outer footprint.
  static const Size nameSlot = Size(nameWidth, rowHeight);
}
