import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../state/production_basket_notifier.dart';

/// One production date for the whole batch.
///
/// Replaces the per-line date and time pickers: for a team making one run a
/// day, a picker per row was ceremony repeated per line.
///
/// The window is clamped to [kProductionBackDateDays] back and today. The old
/// picker spanned last year to two years out, and that date became the stock
/// entry's posting date — an open door into closed periods once more people
/// hold the screen. Forward-dating is gone entirely: a future-dated stock entry
/// for work already done is meaningless.
class BatchDateBar extends StatelessWidget {
  const BatchDateBar({
    super.key,
    required this.date,
    required this.onChanged,
    this.canBackDate = true,
  });

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  /// When false the picker is locked to today.
  final bool canBackDate;

  static DateTime earliestAllowed(DateTime today) =>
      today.subtract(const Duration(days: kProductionBackDateDays));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(Icons.event, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        // Expanded rather than a Spacer: the label is a translated string and
        // the Arabic one is longer, so on a narrow phone a fixed-width Text
        // plus the date button overflowed the row.
        Expanded(
          child: Text(
            l10n.productionPostingDate,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: canBackDate ? () => _pick(context) : null,
          child: Text(_format(date)),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: date.isAfter(today) ? today : date,
      firstDate: earliestAllowed(today),
      lastDate: today,
    );
    if (picked != null) onChanged(picked);
  }

  static String _format(DateTime value) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)}';
  }
}
