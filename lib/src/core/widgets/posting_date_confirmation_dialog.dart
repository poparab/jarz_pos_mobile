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

/// The wire form when the user chose a clock time as well as a day.
///
/// The backend accepts both `YYYY-MM-DD` and `YYYY-MM-DD HH:MM:SS` on the same
/// field, so the two formatters are interchangeable per call site: send the
/// date-only form while the operator has not picked a time (the server then
/// stamps its own clock, which is the safer default), and this one once they
/// have.
///
/// Seconds are always `00`: the picker has minute resolution, so a non-zero
/// seconds field would be invented precision.
String formatPostingDateTimeForApi(DateTime value) {
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(
    DateTime(value.year, value.month, value.day, value.hour, value.minute),
  );
}

/// The same moment for the screen, in the reader's locale.
String formatPostingDateTimeForDisplay(BuildContext context, DateTime value) {
  return DateFormat('yyyy-MM-dd HH:mm', context.l10n.localeName).format(value);
}

/// Whether [value] carries a clock component somebody could have chosen.
///
/// Midnight is this app's marker for "no explicit time": every posting value
/// starts at 00:00, and anything persisted before the time picker existed
/// restores at 00:00 too. Callers that keep their own "did they pick a time"
/// flag should prefer it — this is for the ones reading a value they did not
/// watch being set, where treating a restored midnight as a deliberate 00:00
/// would be a worse error than ignoring a deliberate 00:00.
bool hasExplicitPostingTime(DateTime? value) =>
    value != null &&
    (value.hour != 0 || value.minute != 0 || value.second != 0);

/// A date picker followed by a time picker, as one posting-moment choice.
///
/// Returns null if the user cancels EITHER step — a half-made choice is not a
/// choice, and applying just the day would silently keep whatever clock time
/// the field already held.
///
/// [initial] seeds both steps, so re-opening the picker shows the time already
/// chosen rather than resetting it to midnight. Seconds are zeroed.
Future<DateTime?> pickPostingDateTime(
  BuildContext context, {
  required DateTime initial,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  final l10n = context.l10n;
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: firstDate,
    lastDate: lastDate,
    helpText: l10n.postingDatePickerHelp,
  );
  if (pickedDate == null) return null;
  // The date picker is a route: anything can have happened to this element
  // while it was up, and the sheets this runs inside are dismissible.
  if (!context.mounted) return null;

  final pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
    helpText: l10n.postingTimePickerHelp,
  );
  if (pickedTime == null) return null;

  return DateTime(
    pickedDate.year,
    pickedDate.month,
    pickedDate.day,
    pickedTime.hour,
    pickedTime.minute,
  );
}

/// Last stop before a document is posted at a date the operator may not have
/// noticed.
///
/// [includeTime] decides whether the clock time is part of the confirmation.
/// Callers that track "did the user pick a time" pass it explicitly; the rest
/// fall back to a midnight heuristic, because every picker in this app leaves
/// midnight on a value whose time was never chosen, and confirming a midnight
/// nobody asked for is exactly the misinformation this dialog exists to stop.
Future<bool> confirmPostingDatesBeforeSubmit(
  BuildContext context, {
  required Iterable<DateTime> dates,
  bool? includeTime,
}) async {
  final l10n = context.l10n;
  final resolvedDates = dates.toList(growable: false);
  final showTime = includeTime ?? resolvedDates.any(hasExplicitPostingTime);

  final dateLabels = <String>[];
  final seenLabels = <String>{};

  for (final date in resolvedDates) {
    final label = showTime
        ? formatPostingDateTimeForDisplay(context, date)
        : formatPostingDateForApi(date);
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
              Text(
                showTime
                    ? l10n.postingDateTimeConfirmationDate(dateLabels.single)
                    : l10n.postingDateConfirmationDate(dateLabels.single),
              )
            else ...[
              Text(
                showTime
                    ? l10n.postingDateTimeConfirmationDates
                    : l10n.postingDateConfirmationDates,
              ),
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
