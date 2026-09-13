import 'package:flutter/material.dart';

/// A cart line's rate box.
///
/// `TextFormField(initialValue:)` reads its value once, so a rate changed from
/// outside — picking another UOM re-prices the line — kept showing the old
/// number while the new one was totalled and sent. This owns its controller
/// and follows [rate] whenever it changes underneath what is on screen.
class LineRateField extends StatefulWidget {
  const LineRateField({
    super.key,
    required this.rate,
    required this.onChanged,
  });

  final double rate;
  final ValueChanged<double> onChanged;

  @override
  State<LineRateField> createState() => _LineRateFieldState();
}

class _LineRateFieldState extends State<LineRateField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.rate.toStringAsFixed(2));

  @override
  void didUpdateWidget(LineRateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rate == oldWidget.rate) return;
    // The buyer's own typing also changes the rate; rewriting "12.5" as
    // "12.50" under their cursor would fight them, so only a value that
    // disagrees with the box is written back.
    final shown = double.tryParse(_controller.text);
    if (shown != null && (shown - widget.rate).abs() < 1e-9) return;
    _controller.text = widget.rate.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (v) => widget.onChanged(double.tryParse(v) ?? widget.rate),
    );
  }
}
