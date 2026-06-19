import 'package:flutter/material.dart';

/// A small coloured chip representing a pipeline stage.
class B2bStageChip extends StatelessWidget {
  final String stage;
  const B2bStageChip({super.key, required this.stage});

  static Color colorFor(String stage) {
    switch (stage) {
      case 'Lead':
        return Colors.blueGrey;
      case 'Qualify':
        return Colors.indigo;
      case 'Sample':
        return Colors.teal;
      case 'Approved':
        return Colors.green;
      case 'Trial':
        return Colors.orange;
      case 'Check-up':
        return Colors.purple;
      case 'Active':
        return Colors.lightGreen;
      case 'Lost/On-hold':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(stage);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        stage,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
