import 'package:flutter/material.dart';

import 'report_branch_selector.dart';
import 'report_date_range_bar.dart';

/// The standard filter card at the top of a report: the shared date range
/// (from/to + preset chips) and, unless [showBranch] is false, the shared
/// branch selector. Both write the shared providers, so the selection
/// carries between reports.
///
/// Watch `reportQueryProvider` (range + branch) in the screen; when
/// [showBranch] is false, watch `reportRangeProvider` instead.
class ReportFilterBar extends StatelessWidget {
  final bool showBranch;
  final bool showDates;

  const ReportFilterBar({
    super.key,
    this.showBranch = true,
    this.showDates = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBranch && !showDates) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsetsDirectional.all(8),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showBranch) const ReportBranchSelector(),
            if (showBranch && showDates) const SizedBox(height: 10),
            if (showDates) const ReportDateRangeBar(embedded: true),
          ],
        ),
      ),
    );
  }
}
