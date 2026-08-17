import 'package:flutter/material.dart';

import '../../models/label_models.dart';

/// Colour, icon and wording for a label's reorder status.
///
/// The palette is deliberately a traffic light rather than the app's brand
/// colours: the only question this screen answers is "does this have to go to
/// the print house today", and that reads faster in red/amber/green than in any
/// amount of typography.
class LabelStatusStyle {
  final Color color;
  final IconData icon;
  final String text;
  final String explanation;

  const LabelStatusStyle({
    required this.color,
    required this.icon,
    required this.text,
    required this.explanation,
  });

  static LabelStatusStyle of(LabelStatus status, {int leadDaysMax = 3}) {
    switch (status) {
      case LabelStatus.outOfStock:
        return const LabelStatusStyle(
          color: Color(0xFFB3261E),
          icon: Icons.error,
          text: 'Out of stock',
          explanation: 'No labels left. This customer cannot be packed.',
        );
      case LabelStatus.reorderNow:
        return LabelStatusStyle(
          color: const Color(0xFFE65100),
          icon: Icons.local_printshop,
          text: 'Print now',
          explanation:
              'Stock runs out before a new batch could arrive '
              '($leadDaysMax working days).',
        );
      case LabelStatus.reorderSoon:
        return const LabelStatusStyle(
          color: Color(0xFFF9A825),
          icon: Icons.schedule,
          text: 'Print soon',
          explanation: 'Getting close to the point of no return.',
        );
      case LabelStatus.onOrder:
        return const LabelStatusStyle(
          color: Color(0xFF1565C0),
          icon: Icons.local_shipping,
          text: 'At the printer',
          explanation: 'A batch is already on its way.',
        );
      case LabelStatus.ok:
        return const LabelStatusStyle(
          color: Color(0xFF2E7D32),
          icon: Icons.check_circle,
          text: 'OK',
          explanation: 'Comfortable cover.',
        );
      case LabelStatus.notTracked:
        return const LabelStatusStyle(
          color: Color(0xFF757575),
          icon: Icons.do_not_disturb_on,
          text: 'Customer prints',
          explanation:
              'This customer supplies their own labels, so nothing is counted.',
        );
      case LabelStatus.unknown:
        return const LabelStatusStyle(
          color: Color(0xFF757575),
          icon: Icons.help_outline,
          text: 'Unknown',
          explanation: '',
        );
    }
  }
}

/// Compact status pill used on cards and in the detail header.
class LabelStatusChip extends StatelessWidget {
  final LabelStatus status;
  final int leadDaysMax;
  final bool dense;

  const LabelStatusChip({
    super.key,
    required this.status,
    this.leadDaysMax = 3,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = LabelStatusStyle.of(status, leadDaysMax: leadDaysMax);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: dense ? 13 : 15, color: style.color),
          const SizedBox(width: 5),
          Text(
            style.text,
            style: TextStyle(
              color: style.color,
              fontWeight: FontWeight.w600,
              fontSize: dense ? 11 : 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
