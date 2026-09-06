import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/localization_extensions.dart';

/// In-field paste/clear affordance for text inputs staff fill by pasting.
///
/// On a phone the native route is unreliable inside a dialog: tapping the field
/// raises the keyboard, the dialog shrinks into what is left, and the
/// long-press selection toolbar ends up clipped against that edge — which is
/// exactly how pasting an address into Quick Add Customer fails today.
///
/// The button shows **Paste** while the field is empty and **Clear** once it
/// holds text, so filling or replacing a pasted address is one tap either way,
/// with the keyboard still down.
class PasteOrClearButton extends StatelessWidget {
  const PasteOrClearButton({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onChanged,
    this.clearTooltip,
    this.iconSize = 20,
  });

  final TextEditingController controller;
  final bool enabled;

  /// Notified with the field's full text after a paste or a clear — a
  /// programmatic controller write never fires the field's own `onChanged`,
  /// so hosts that react to input (validation, a debounced resolve) need this.
  final ValueChanged<String>? onChanged;

  /// Overrides the generic "Clear" tooltip when the field has a name worth
  /// saying out loud (screen readers read the tooltip).
  final String? clearTooltip;

  final double iconSize;

  static const pasteKey = ValueKey('paste_or_clear_paste');
  static const clearKey = ValueKey('paste_or_clear_clear');

  Future<void> _paste() async {
    // iOS 16+ raises its own "Allow Paste?" prompt here. That is one extra tap
    // on a system sheet, still far cheaper than the long-press dance it
    // replaces — and it only appears while the field is empty.
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    if (text.trim().isEmpty) return;
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    onChanged?.call(text);
  }

  void _clear() {
    controller.clear();
    onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    // Listening to the controller keeps the swap local: the host form is not
    // rebuilt on every keystroke just to flip one icon.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.trim().isNotEmpty;
        return IconButton(
          key: hasText ? clearKey : pasteKey,
          visualDensity: VisualDensity.compact,
          icon: Icon(
            hasText ? Icons.close : Icons.content_paste,
            size: iconSize,
          ),
          tooltip: hasText
              ? (clearTooltip ?? context.l10n.commonClear)
              : context.l10n.commonPaste,
          onPressed: enabled ? (hasText ? _clear : _paste) : null,
        );
      },
    );
  }
}
