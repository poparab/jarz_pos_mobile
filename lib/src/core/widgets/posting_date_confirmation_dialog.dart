import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../localization/localization_extensions.dart';

DateTime resolvePostingDateOrToday(DateTime? postingDate) {
  final source = postingDate ?? DateTime.now();
  return DateTime(source.year, source.month, source.day);
}

String formatPostingDateForApi(DateTime postingDate) {
  return DateFormat('yyyy-MM-dd').format(
    DateTime(postingDate.year, postingDate.month, postingDate.day),
  );
}

Future<bool> confirmPostingDatesBeforeSubmit(
  BuildContext context, {
  required Iterable<DateTime> dates,
}) async {
  final l10n = context.l10n;
  final dateLabels = <String>[];
  final seenLabels = <String>{};

  for (final date in dates) {
    final label = formatPostingDateForApi(date);
    if (seenLabels.add(label)) {
      dateLabels.add(label);
    }
  }

  if (dateLabels.isEmpty) {
    return true;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.postingDateConfirmationTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.postingDateConfirmationMessage),
            const SizedBox(height: 12),
            if (dateLabels.length == 1)
              Text(l10n.postingDateConfirmationDate(dateLabels.single))
            else ...[
              Text(l10n.postingDateConfirmationDates),
              const SizedBox(height: 8),
              for (final label in dateLabels)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(label),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.commonConfirm),
        ),
      ],
    ),
  );

  return confirmed == true;
}