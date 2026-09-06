import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';

/// Localized display text + colour for every fixed enum this console shows.
/// Kept as free functions rather than an extension on the model classes so
/// the models stay pure data with no `BuildContext` dependency.
String wooSyncStatusLabel(BuildContext context, String status) {
  final l10n = context.l10n;
  switch (status) {
    case 'Pending':
      return l10n.wooSyncStatusPending;
    case 'Processing':
      return l10n.wooSyncStatusProcessing;
    case 'Succeeded':
      return l10n.wooSyncStatusSucceeded;
    case 'RetryScheduled':
      return l10n.wooSyncStatusRetryScheduled;
    case 'Skipped':
      return l10n.wooSyncStatusSkipped;
    case 'Superseded':
      return l10n.wooSyncStatusSuperseded;
    case 'Failed':
      return l10n.wooSyncStatusFailed;
    case 'NeedsReview':
      return l10n.wooSyncStatusNeedsReview;
    case 'DeadLetter':
      return l10n.wooSyncStatusDeadLetter;
    default:
      return status;
  }
}

/// Semantic colour for a status stripe/chip. Deliberately distinct from the
/// app's accent colour family so "this needs attention" reads at a glance
/// instead of blending into ordinary UI chrome.
Color wooSyncStatusColor(String status) {
  switch (status) {
    case 'Succeeded':
      return Colors.green.shade600;
    case 'Pending':
    case 'RetryScheduled':
      return Colors.amber.shade700;
    case 'Processing':
      return Colors.blue.shade600;
    case 'Skipped':
    case 'Superseded':
      return Colors.grey.shade600;
    case 'Failed':
    case 'DeadLetter':
      return Colors.red.shade700;
    case 'NeedsReview':
      return Colors.deepOrange.shade600;
    default:
      return Colors.grey.shade500;
  }
}

String wooSyncDirectionLabel(BuildContext context, String direction) {
  final l10n = context.l10n;
  switch (direction) {
    case 'Inbound':
      return l10n.wooSyncDirectionInbound;
    case 'Outbound':
      return l10n.wooSyncDirectionOutbound;
    default:
      return direction;
  }
}

String wooSyncReviewStateLabel(BuildContext context, String? reviewState) {
  final l10n = context.l10n;
  switch (reviewState) {
    case 'Open':
      return l10n.wooSyncReviewStateOpen;
    case 'Investigating':
      return l10n.wooSyncReviewStateInvestigating;
    case 'Resolved':
      return l10n.wooSyncReviewStateResolved;
    case 'Ignored':
      return l10n.wooSyncReviewStateIgnored;
    default:
      return reviewState ?? '';
  }
}

Color wooSyncReviewStateColor(String? reviewState) {
  switch (reviewState) {
    case 'Open':
      return Colors.orange.shade700;
    case 'Investigating':
      return Colors.blue.shade600;
    case 'Resolved':
      return Colors.green.shade600;
    case 'Ignored':
      return Colors.grey.shade600;
    default:
      return Colors.grey.shade400;
  }
}
