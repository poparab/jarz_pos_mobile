import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/purchase_request_models.dart';

/// Colour + label for a request status.
///
/// Colour is derived from the theme's scheme rather than hardcoded so the chip
/// stays legible in dark mode — the older purchase history card hardcoded
/// `Colors.green`/`Colors.red` and washes out on a dark background.
class RequestStatusChip extends StatelessWidget {
  final RequestStatus status;
  final bool isOverdue;
  final bool dense;

  const RequestStatusChip({
    super.key,
    required this.status,
    this.isOverdue = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    final (label, color) = switch (status) {
      RequestStatus.pending => (l10n.requestsStatusPending, scheme.primary),
      RequestStatus.partiallyOrdered ||
      RequestStatus.ordered =>
        (l10n.requestsStatusOrdered, scheme.tertiary),
      RequestStatus.partiallyReceived => (
          l10n.requestsStatusPartiallyReceived,
          scheme.tertiary,
        ),
      RequestStatus.received => (
          l10n.requestsStatusReceived,
          Colors.green.shade700,
        ),
      RequestStatus.stopped => (l10n.requestsStatusStopped, scheme.error),
      RequestStatus.cancelled => (
          l10n.requestsStatusCancelled,
          scheme.outline,
        ),
      RequestStatus.unknown => (status.name, scheme.outline),
    };

    return Wrap(
      spacing: 4,
      children: [
        _pill(context, label, color),
        if (isOverdue) _pill(context, l10n.requestsOverdue, scheme.error),
      ],
    );
  }

  Widget _pill(BuildContext context, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: dense ? 10 : 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
