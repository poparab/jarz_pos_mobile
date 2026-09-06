import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/woo_sync_event.dart';
import 'woo_sync_labels.dart';

/// Confirmation for a system-wide action (run worker / clear breaker) —
/// both have effects beyond whatever is currently on screen, so a plain
/// tap-to-fire button is not enough.
Future<bool> confirmWooSyncAction(
  BuildContext context, {
  required String title,
  required String body,
}) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.wooSyncCancel)),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.wooSyncConfirm)),
      ],
    ),
  );
  return result ?? false;
}

/// Picks a review state (+ optional notes) for a single event or a bulk
/// selection. Returns null if the operator cancelled.
Future<({String reviewState, String? notes})?> pickWooSyncReviewState(
  BuildContext context, {
  String? initialState,
}) async {
  final l10n = context.l10n;
  String selected = initialState ?? WooSyncEvent.reviewStates.first;
  final notesController = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(l10n.wooSyncReviewStateDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final state in WooSyncEvent.reviewStates)
              RadioListTile<String>(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(wooSyncReviewStateLabel(ctx, state)),
                value: state,
                groupValue: selected,
                onChanged: (v) => setState(() => selected = v ?? selected),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: l10n.wooSyncReviewStateNotesLabel,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.wooSyncCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.wooSyncConfirm)),
        ],
      ),
    ),
  );

  if (result != true) return null;
  final notes = notesController.text.trim();
  return (reviewState: selected, notes: notes.isEmpty ? null : notes);
}
