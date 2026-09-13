import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/pasted_text.dart';

/// Outcome of a clipboard read. [text] is null when the clipboard was empty
/// and [failed] is true when the platform refused the read (a denied browser
/// permission, Firefox without `clipboard.readText`, …).
@immutable
class ClipboardReadResult {
  const ClipboardReadResult._(this.text, this.failed);

  final String? text;
  final bool failed;

  bool get hasText => text != null && text!.isNotEmpty;
}

/// Reads plain text from the clipboard without ever throwing.
///
/// On Flutter web `Clipboard.getData` goes through `navigator.clipboard`, which
/// rejects with a `PlatformException(paste_fail)` when permission is denied or
/// the browser does not implement it. Uncaught, that made every in-field paste
/// button look dead on the web build.
Future<ClipboardReadResult> readClipboardText() async {
  try {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    return ClipboardReadResult._(
      text == null || text.isEmpty ? null : text,
      false,
    );
  } catch (error) {
    debugPrint('readClipboardText: clipboard read failed — $error');
    return const ClipboardReadResult._(null, true);
  }
}

/// Splices [pasted] into [current] the way a keyboard paste would: it replaces
/// the selection (or inserts at the caret) and leaves the caret after the
/// inserted text. With [replace], or when the field has never held a caret,
/// the pasted text becomes the whole value / is appended respectively.
///
/// [inputFormatters] run exactly as they would for typed input, so a phone
/// formatter normalises pasted digits rather than being bypassed.
TextEditingValue applyPastedText(
  TextEditingValue current,
  String pasted, {
  bool replace = false,
  List<TextInputFormatter> inputFormatters = const [],
}) {
  TextEditingValue next;
  if (replace) {
    next = TextEditingValue(
      text: pasted,
      selection: TextSelection.collapsed(offset: pasted.length),
    );
  } else {
    final selection = current.selection;
    final text = current.text;
    final start = selection.isValid
        ? selection.start.clamp(0, text.length)
        : text.length;
    final end = selection.isValid
        ? selection.end.clamp(0, text.length)
        : text.length;
    final result = text.replaceRange(start, end, pasted);
    next = TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: start + pasted.length),
    );
  }
  for (final formatter in inputFormatters) {
    next = formatter.formatEditUpdate(current, next);
  }
  return next;
}

/// A compact paste affordance for a text field's `suffixIcon`.
///
/// Why it exists: the long-press toolbar is the only paste route on a touch
/// screen, and it is unreliable exactly where staff paste the most — inside a
/// dialog squeezed by the keyboard, or on the web build, where Flutter never
/// draws its own toolbar and a phone browser rarely shows its native one over
/// the canvas. One tap here works everywhere, with the keyboard still down.
///
/// Behaviour:
/// * with a [controller], the text is inserted at the caret / over the
///   selection (or replaces everything when [replace] is true), the
///   [inputFormatters] are applied, and [onChanged] is notified — a
///   programmatic controller write never fires the field's own `onChanged`;
/// * without a controller (a `TextFormField(initialValue:)`), the cleaned text
///   is handed to [onPasted] and the host decides what to do with it;
/// * an empty clipboard is a no-op; a refused read shows a short SnackBar
///   pointing at the keyboard shortcut instead of failing silently.
class PasteIconButton extends StatelessWidget {
  const PasteIconButton({
    super.key,
    this.controller,
    this.onPasted,
    this.onChanged,
    this.replace = false,
    this.multiline = false,
    this.transform,
    this.inputFormatters = const [],
    this.enabled = true,
    this.iconSize = 20,
    this.failureHint,
  }) : assert(
         controller != null || onPasted != null,
         'PasteIconButton needs a controller or an onPasted callback',
       );

  final TextEditingController? controller;

  /// Receives the cleaned clipboard text. Required when [controller] is null;
  /// with a controller it is called after the controller was updated.
  final ValueChanged<String>? onPasted;

  /// Notified with the field's full text after a paste into [controller].
  final ValueChanged<String>? onChanged;

  /// Replace the whole value instead of inserting at the caret.
  final bool replace;

  /// Keep line breaks from the clipboard (multi-line fields only).
  final bool multiline;

  /// Extra clean-up for this field, e.g. [PastedText.normalizePhone].
  final String Function(String)? transform;

  /// The field's own input formatters, re-applied to the pasted value.
  final List<TextInputFormatter> inputFormatters;

  final bool enabled;
  final double iconSize;

  /// Shown when the clipboard cannot be read. Defaults to "Paste: Ctrl+V".
  final String? failureHint;

  static const buttonKey = ValueKey('paste_icon_button');

  Future<void> _paste(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final pasteLabel = MaterialLocalizations.of(context).pasteButtonLabel;
    final result = await readClipboardText();
    if (result.failed) {
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(failureHint ?? '$pasteLabel: Ctrl+V'),
            duration: const Duration(seconds: 3),
          ),
        );
      return;
    }
    if (!result.hasText) return;

    var text = PastedText.sanitize(result.text!, multiline: multiline);
    if (transform != null) text = transform!(text);
    if (text.isEmpty) return;

    final target = controller;
    if (target != null) {
      final before = target.value;
      final next = applyPastedText(
        before,
        text,
        replace: replace,
        inputFormatters: inputFormatters,
      );
      target.value = next;
      if (next.text != before.text) onChanged?.call(next.text);
    }
    onPasted?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: buttonKey,
      visualDensity: VisualDensity.compact,
      iconSize: iconSize,
      icon: const Icon(Icons.content_paste),
      tooltip: MaterialLocalizations.of(context).pasteButtonLabel,
      onPressed: enabled ? () => _paste(context) : null,
    );
  }
}

/// Lays several compact suffix actions (paste + clear, paste + search, …) side
/// by side inside an `InputDecoration.suffixIcon` slot without stretching it.
class SuffixIconRow extends StatelessWidget {
  const SuffixIconRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
