import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';

/// What the keypad returned: a number, or "back to not counted".
class WeeklyCountKeypadResult {
  const WeeklyCountKeypadResult.qty(int this.qty) : uncount = false;
  const WeeklyCountKeypadResult.uncount() : qty = null, uncount = true;

  final int? qty;
  final bool uncount;
}

/// A big numeric keypad for typing a count without the system keyboard.
///
/// Returns null when dismissed. Whole numbers only, up to 5 digits.
Future<WeeklyCountKeypadResult?> showWeeklyCountKeypad(
  BuildContext context, {
  required String itemName,
  int? initial,
}) {
  return showDialog<WeeklyCountKeypadResult>(
    context: context,
    builder: (_) => _KeypadDialog(itemName: itemName, initial: initial),
  );
}

class _KeypadDialog extends StatefulWidget {
  const _KeypadDialog({required this.itemName, this.initial});

  final String itemName;
  final int? initial;

  @override
  State<_KeypadDialog> createState() => _KeypadDialogState();
}

class _KeypadDialogState extends State<_KeypadDialog> {
  static const _maxDigits = 5;
  late String _digits = widget.initial?.toString() ?? '';

  void _press(String digit) {
    setState(() {
      if (_digits == '0') _digits = '';
      if (_digits.length < _maxDigits) _digits += digit;
    });
  }

  void _backspace() {
    if (_digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final value = int.tryParse(_digits);

    Widget key(String label, {VoidCallback? onTap, Widget? child}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            height: 60,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  child ??
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ),
          ),
        ),
      );
    }

    Widget row(List<String> digits) =>
        Row(children: [for (final d in digits) key(d, onTap: () => _press(d))]);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.itemName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _digits.isEmpty ? '—' : _digits,
                key: const ValueKey('weekly-count-keypad-display'),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Digits stay left-to-right in an RTL app, like a phone keypad.
            Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  row(const ['1', '2', '3']),
                  row(const ['4', '5', '6']),
                  row(const ['7', '8', '9']),
                  Row(
                    children: [
                      key(
                        l10n.weeklyCountKeypadClear,
                        onTap: _digits.isEmpty
                            ? null
                            : () => setState(() => _digits = ''),
                        child: Text(
                          l10n.weeklyCountKeypadClear,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      key('0', onTap: () => _press('0')),
                      key(
                        '',
                        onTap: _digits.isEmpty ? null : _backspace,
                        child: const Icon(Icons.backspace_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (widget.initial != null)
                  TextButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(const WeeklyCountKeypadResult.uncount()),
                    child: Text(l10n.weeklyCountKeypadUncount),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: value == null
                      ? null
                      : () => Navigator.of(
                          context,
                        ).pop(WeeklyCountKeypadResult.qty(value)),
                  child: Text(l10n.commonOk),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
