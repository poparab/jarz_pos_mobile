import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/shift_models.dart';

class ShiftStatusBanner extends StatelessWidget {
  const ShiftStatusBanner({
    super.key,
    required this.shift,
  });

  final ShiftEntry shift;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final start = shift.periodStartDate;
    final time = start == null
        ? '--:--'
        : '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.shiftStatusActive,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  l10n.shiftStartedAt(time),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go('/shift/end'),
            child: Text(l10n.shiftEndButton),
          ),
        ],
      ),
    );
  }
}
