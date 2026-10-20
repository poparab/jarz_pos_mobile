import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/pasted_text.dart';
import 'handover_format.dart';

/// Positive decimals only, up to 3 places. Arabic-Indic digits and the Arabic
/// decimal separator (or a comma) are folded to ASCII, so an Arabic keyboard
/// types a number instead of nothing.
class HandoverQtyInputFormatter extends TextInputFormatter {
  const HandoverQtyInputFormatter();

  static final _valid = RegExp(r'^\d{0,6}(\.\d{0,3})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = PastedText.normalizeDigits(newValue.text)
        .replaceAll('٫', '.')
        .replaceAll(',', '.')
        .trim();
    if (!_valid.hasMatch(text)) return oldValue;
    if (text == newValue.text) return newValue;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// A compact quantity box that keeps its text in step with [value] when the
/// parent changes it from outside (a reset, a "fill the remainder").
class HandoverQtyField extends StatefulWidget {
  const HandoverQtyField({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 76,
    this.bold = false,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double width;
  final bool bold;

  @override
  State<HandoverQtyField> createState() => _HandoverQtyFieldState();
}

class _HandoverQtyFieldState extends State<HandoverQtyField> {
  late final TextEditingController _ctrl;

  static String _fmt(double v) => v <= 0 ? '' : handoverQty(v);

  static double _parse(String text) => double.tryParse(text) ?? 0;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _fmt(widget.value));
  }

  @override
  void didUpdateWidget(covariant HandoverQtyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((_parse(_ctrl.text) - widget.value).abs() > 1e-9) {
      final text = _fmt(widget.value);
      _ctrl.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: widget.width,
      child: TextField(
        controller: _ctrl,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: widget.bold ? FontWeight.w800 : FontWeight.w600,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: const [HandoverQtyInputFormatter()],
        decoration: const InputDecoration(
          isDense: true,
          hintText: '0',
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          border: OutlineInputBorder(),
        ),
        onTap: () => _ctrl.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _ctrl.text.length,
        ),
        onChanged: (text) => widget.onChanged(_parse(text)),
      ),
    );
  }
}
