import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';

String? buildOfdBlockingErrorMessage(Map<String, dynamic> previewResponse) {
  final rawErrors = previewResponse['blocking_errors'];
  if (rawErrors is! List) {
    return null;
  }

  final errors = rawErrors
      .map((entry) => entry?.toString().trim() ?? '')
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
  if (errors.isEmpty) {
    return null;
  }

  return errors.join('\n');
}

Future<String?> showOfdShortageReasonDialog(
  BuildContext context,
  Map<String, dynamic> previewResponse,
) async {
  final preview = previewResponse['preview'];
  final shortages = preview is Map
      ? ((preview['approvable_shortages'] ?? preview['shortages']) as List? ?? const [])
      : const [];
  final controller = TextEditingController();
  String? validationError;

  try {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final l10n = dialogContext.l10n;
        return StatefulBuilder(
          builder: (dialogContext, setState) => AlertDialog(
            title: Text(l10n.ofdShortageDialogTitle),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.ofdShortageDialogMessage),
                    if (shortages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      for (final rawEntry in shortages)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            l10n.ofdShortageLine(
                              _itemLabel(rawEntry),
                              _formatQty(_entryValue(rawEntry, 'required_qty')),
                              _formatQty(_entryValue(rawEntry, 'available_qty')),
                              _entryValue(rawEntry, 'warehouse').toString(),
                            ),
                            style: Theme.of(dialogContext).textTheme.bodySmall,
                          ),
                        ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: l10n.commonReasonLabel,
                        hintText: l10n.ofdShortageReasonHint,
                        errorText: validationError,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () {
                  final reason = controller.text.trim();
                  if (reason.isEmpty) {
                    setState(() {
                      validationError = l10n.ofdShortageReasonRequired;
                    });
                    return;
                  }
                  Navigator.of(dialogContext).pop(reason);
                },
                child: Text(l10n.ofdShortageApprove),
              ),
            ],
          ),
        );
      },
    );
  } finally {
    controller.dispose();
  }
}

String _itemLabel(dynamic rawEntry) {
  final itemName = _entryValue(rawEntry, 'item_name').toString().trim();
  final itemCode = _entryValue(rawEntry, 'item_code').toString().trim();
  if (itemName.isNotEmpty && itemCode.isNotEmpty && itemName != itemCode) {
    return '$itemName ($itemCode)';
  }
  return itemName.isNotEmpty ? itemName : itemCode;
}

dynamic _entryValue(dynamic rawEntry, String key) {
  if (rawEntry is Map) {
    return rawEntry[key];
  }
  return null;
}

String _formatQty(dynamic value) {
  final qty = value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;
  return qty == qty.roundToDouble()
      ? qty.toInt().toString()
      : qty.toStringAsFixed(2);
}