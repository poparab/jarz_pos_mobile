import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/attendance_models.dart';

/// Stable keys so the tests can find the badges.
const Key attendanceCheckoutCorrectedKey = ValueKey<String>(
  'attendance-checkout-corrected',
);
const Key attendanceMissedCheckoutKey = ValueKey<String>(
  'attendance-missed-checkout',
);

/// The two check-out problems the server reports on a day:
///
/// * `checkout_corrected`: the person pressed Check Out on arrival and the
///   server counted it as a Check In;
/// * `missed_checkout`: they checked in and never checked out.
///
/// Both are absent on an older server, so this draws nothing there. Amber
/// (tertiary), never red: neither is an absence.
class AttendanceCheckoutBadges extends StatelessWidget {
  const AttendanceCheckoutBadges({
    super.key,
    required this.cell,
    this.dense = false,
  });

  final AttendanceCell cell;

  /// One line per badge at body size (false, the day sheet) or small chips
  /// that wrap (true, the day list row).
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (!cell.hasCheckoutIssue) return const SizedBox.shrink();
    final l10n = context.l10n;
    final badges = <(Key, IconData, String)>[
      if (cell.checkoutCorrected)
        (
          attendanceCheckoutCorrectedKey,
          Icons.swap_vert,
          l10n.attendanceCheckoutCorrected,
        ),
      if (cell.missedCheckout)
        (
          attendanceMissedCheckoutKey,
          Icons.logout,
          l10n.attendanceMissedCheckout,
        ),
    ];
    if (dense) {
      return Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          for (final (key, icon, text) in badges)
            _Badge(key: key, icon: icon, text: text),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (key, icon, text) in badges)
          _Line(key: key, icon: icon, text: text),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: scheme.onTertiaryContainer),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onTertiaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.tertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small corner tick for the month grid square: the day has a check-out
/// problem (see [AttendanceCheckoutBadges]). Shape, not just colour.
class AttendanceCheckoutMarker extends StatelessWidget {
  const AttendanceCheckoutMarker({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: scheme.tertiary,
        borderRadius: BorderRadius.circular(1.5),
        border: Border.all(color: scheme.surface, width: 1),
      ),
    );
  }
}
