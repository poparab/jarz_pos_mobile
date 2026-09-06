import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/woo_sync_dashboard.dart';

/// The single most important thing on this console: whether the outbound
/// circuit breaker is open. Full-width, high-contrast, and above everything
/// else — an operator must not be able to miss it.
class WooBreakerBanner extends StatelessWidget {
  final WooBreakerState breaker;

  const WooBreakerBanner({super.key, required this.breaker});

  String? _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat('yyyy-MM-dd HH:mm').format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isOpen = breaker.isOpen;
    final color = isOpen ? Colors.red.shade700 : Colors.green.shade700;
    final bg = isOpen ? Colors.red.shade50 : Colors.green.shade50;
    final icon = isOpen ? Icons.report_gmailerrorred : Icons.check_circle_outline;
    final formattedUntil = _formatTime(breaker.openUntil);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        border: Border(left: BorderSide(color: color, width: 6)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? l10n.wooSyncBreakerOpenTitle : l10n.wooSyncBreakerClosedTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                ),
                const SizedBox(height: 4),
                Text(isOpen ? l10n.wooSyncBreakerOpenBody : l10n.wooSyncBreakerClosedBody),
                if (isOpen) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text(
                        l10n.wooSyncBreakerFailureCount(breaker.failureCount),
                        style: TextStyle(color: color, fontWeight: FontWeight.w600),
                      ),
                      if (formattedUntil != null)
                        Text(
                          l10n.wooSyncBreakerOpenUntil(formattedUntil),
                          style: TextStyle(color: color, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
