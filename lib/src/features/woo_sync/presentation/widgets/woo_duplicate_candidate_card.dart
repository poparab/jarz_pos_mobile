import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/woo_duplicate_group.dart';

/// One candidate customer inside a duplicate group, shown side by side with
/// its siblings so a human can judge which is the real record. Read-only —
/// no action is offered here; see the screen-level banner for why.
class WooDuplicateCandidateCard extends StatelessWidget {
  final WooDuplicateCandidate candidate;

  const WooDuplicateCandidateCard({super.key, required this.candidate});

  String _formatCreated(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat('yyyy-MM-dd').format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: candidate.disabled ? Colors.grey.shade400 : Colors.blue.shade200),
        color: candidate.disabled ? Colors.grey.shade100 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(candidate.customerName, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
          Text(candidate.name, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          const SizedBox(height: 6),
          _row(Icons.receipt_long, l10n.wooDuplicatesCandidateInvoices(candidate.invoiceCount)),
          _row(Icons.verified_outlined, l10n.wooDuplicatesCandidateSubmitted(candidate.submittedInvoiceCount)),
          _row(Icons.payments_outlined, l10n.wooDuplicatesCandidateRevenue(currency.format(candidate.revenue))),
          _row(Icons.event_outlined, l10n.wooDuplicatesCandidateCreated(_formatCreated(candidate.created))),
          _row(
            Icons.tag,
            candidate.wooCustomerId.isEmpty
                ? l10n.wooDuplicatesCandidateNoWooId
                : l10n.wooDuplicatesCandidateWooId(candidate.wooCustomerId),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: candidate.disabled ? Colors.grey.shade300 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              candidate.disabled ? l10n.wooDuplicatesCandidateDisabled : l10n.wooDuplicatesCandidateActive,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: candidate.disabled ? Colors.grey.shade700 : Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
