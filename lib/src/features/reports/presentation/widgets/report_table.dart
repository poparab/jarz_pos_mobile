import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';

/// One column of a [ReportTable].
class ReportColumn {
  final String label;

  /// Numeric columns align to the end (right in LTR, left in RTL).
  final bool numeric;

  /// Relative width.
  final int flex;

  const ReportColumn(this.label, {this.numeric = false, this.flex = 1});
}

/// A compact, RTL-safe table made of rows of pre-formatted strings, with
/// optional tappable rows. Not a [DataTable]: it fits the width (flex
/// columns, ellipsis) instead of scrolling sideways, which suits a phone.
///
/// The same `List<List<String>>` can feed `ReportExportButton`
/// (prepend the column labels as the header row).
class ReportTable extends StatefulWidget {
  final List<ReportColumn> columns;
  final List<List<String>> rows;

  /// Called with the row index in [rows].
  final void Function(int index)? onRowTap;

  /// Optional per-cell text colour: `(row, column) → color or null`.
  final Color? Function(int row, int column)? cellColor;

  /// Show only the first [maxRows] with a "Show all (n)" toggle; null = all.
  final int? maxRows;

  /// Shown instead of the table when [rows] is empty; defaults to the
  /// standard "no data" text.
  final String? emptyText;

  const ReportTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.cellColor,
    this.maxRows,
    this.emptyText,
  });

  @override
  State<ReportTable> createState() => _ReportTableState();
}

class _ReportTableState extends State<ReportTable> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final rows = widget.rows;
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
        child: Text(
          widget.emptyText ?? l10n.reportNoData,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    final limit = widget.maxRows;
    final collapsible = limit != null && rows.length > limit;
    final count = (collapsible && !_expanded) ? limit : rows.length;
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurfaceVariant,
    );
    final cellStyle = theme.textTheme.bodySmall;

    Widget cell(String text, ReportColumn col, TextStyle? style, {Color? color}) =>
        Expanded(
          flex: col.flex,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: col.numeric ? TextAlign.end : TextAlign.start,
              style: color == null ? style : style?.copyWith(color: color),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
          child: Row(
            children: [
              for (final c in widget.columns) cell(c.label, c, headerStyle),
              if (widget.onRowTap != null) const SizedBox(width: 18),
            ],
          ),
        ),
        const Divider(height: 1),
        for (var i = 0; i < count; i++)
          InkWell(
            onTap: widget.onRowTap == null ? null : () => widget.onRowTap!(i),
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
                ),
              ),
              child: Row(
                children: [
                  for (var c = 0; c < widget.columns.length; c++)
                    cell(
                      c < rows[i].length ? rows[i][c] : '',
                      widget.columns[c],
                      cellStyle,
                      color: widget.cellColor?.call(i, c),
                    ),
                  if (widget.onRowTap != null)
                    Icon(Icons.chevron_right,
                        size: 18, color: theme.colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        if (collapsible)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? l10n.reportShowLess : l10n.reportShowAllCount(rows.length),
              ),
            ),
          ),
      ],
    );
  }
}
