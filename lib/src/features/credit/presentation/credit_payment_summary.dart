import 'package:jarz_pos/l10n/app_localizations.dart';

import '../data/models/credit_models.dart';

/// Turns a FIFO allocation result into the sentences a user reads back.
///
/// This is the whole point of the record-payment flow. The backend allocates
/// oldest-invoice-first, so "pay 1,960" against a 1,840 + 240 balance clears
/// two invoices and leaves 120 sitting as an advance — a result the person who
/// typed the amount did not picture. Echoing the input amount would hide that;
/// these lines report what the server actually did, invoice by invoice.
///
/// Pure on purpose: [money] is injected rather than reaching for a
/// `BuildContext`, so the wording can be tested without pumping a widget.
List<String> creditPaymentSummaryLines({
  required AppLocalizations l10n,
  required CreditPaymentResult result,
  required String Function(double amount) money,
}) {
  final lines = <String>[];

  // The replay branch answers a DIFFERENT question, and it is the urgent one:
  // "did my money go in?". It carries no allocations, no advance and no
  // remaining balance, so every block below would produce nothing and the
  // dialog would show a title and an id — the blank result that earns a third
  // tap. Say it outright instead, and stop: there is nothing else to report.
  if (result.isReplay) {
    lines.add(l10n.creditPaymentResultAlreadyRecorded(money(result.amount)));
    lines.add(l10n.creditPaymentResultAlreadyRecordedHint);
    return lines;
  }

  // An unrecognised code still carries a sentence the server wrote for a
  // human; dropping it would hide the only explanation that exists.
  final serverNotice = result.unknownNotice;
  if (serverNotice != null) {
    lines.add(serverNotice);
  }

  final cleared = result.cleared;
  if (cleared.isNotEmpty) {
    final clearedTotal = cleared.fold<double>(
      0,
      (sum, allocation) => sum + allocation.allocatedAmount,
    );
    lines.add(
      l10n.creditPaymentResultCleared(
        cleared.length,
        money(clearedTotal),
        joinCreditList(
          l10n,
          cleared.map((allocation) => allocation.displayId).toList(),
        ),
      ),
    );
  }

  // FIFO leaves at most one part-paid invoice, but the loop costs nothing and
  // survives a backend that splits differently.
  for (final allocation in result.partial) {
    lines.add(
      l10n.creditPaymentResultPartial(
        money(allocation.allocatedAmount),
        allocation.displayId,
      ),
    );
  }

  if (result.hasAdvance) {
    // "Nothing was open at all" is a different story from "the tail became an
    // advance", and only the first one means the payment cleared nothing.
    lines.add(
      result.isEntirelyAdvance
          ? l10n.creditPaymentResultNoneAllocated(money(result.unallocatedAmount))
          : l10n.creditPaymentResultAdvance(money(result.unallocatedAmount)),
    );
  }

  final remaining = result.remainingBalance;
  if (remaining != null && remaining.abs() >= 0.005) {
    lines.add(l10n.creditPaymentResultRemaining(money(remaining)));
  }

  return lines;
}

/// Localised "a, b and c". Arabic joins with "و" and no comma before it, which
/// is why the last pair goes through an ARB string rather than a hardcoded
/// " and ".
String joinCreditList(AppLocalizations l10n, List<String> parts) {
  final items = parts.where((part) => part.trim().isNotEmpty).toList();
  if (items.isEmpty) return '';
  if (items.length == 1) return items.first;
  final head = items.sublist(0, items.length - 1).join(', ');
  return l10n.creditListJoin(head, items.last);
}
