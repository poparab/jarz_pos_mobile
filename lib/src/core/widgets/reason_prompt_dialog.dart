import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';

/// Ask for a written reason before a destructive or refusing action.
///
/// Every reverse action in this app — rejecting an expense, cancelling a
/// production batch, turning down a payment receipt, calling off a day's
/// production plan — takes a reason, and the server refuses the call without
/// one. Collecting it was being copied per screen, which is how the wording,
/// the validation and the "empty means cancelled" contract drift apart.
///
/// Returns the trimmed reason, or `null` if the operator backed out. `null` and
/// empty string are deliberately the same outcome: the caller does nothing.
Future<String?> promptForReason(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? hint,
  String? message,
  bool destructive = true,
}) async {
  final controller = TextEditingController();
  try {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final l10n = ctx.l10n;
        final formKey = GlobalKey<FormState>();
        final scheme = Theme.of(ctx).colorScheme;

        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message != null && message.isNotEmpty) ...[
                Text(message, style: Theme.of(ctx).textTheme.bodyMedium),
                const SizedBox(height: 12),
              ],
              Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  maxLines: 3,
                  autofocus: true,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: l10n.commonReasonLabel,
                    hintText: hint,
                  ),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? l10n.commonReasonRequired
                      : null,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                    )
                  : null,
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                Navigator.of(ctx).pop(controller.text.trim());
              },
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    if (reason == null || reason.isEmpty) return null;
    return reason;
  } finally {
    // In the `finally` so a dialog dismissed by a route pop (back gesture,
    // a parent route being removed) still releases the controller.
    controller.dispose();
  }
}
