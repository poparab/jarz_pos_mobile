import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../domain/invoice_alert.dart';
import '../state/order_alert_controller.dart';

class OrderAlertDialog extends ConsumerWidget {
  const OrderAlertDialog({
    this.onAccept,
    this.onMute,
    this.isMuted = false,
    this.isAcknowledging = false,
    this.error,
    super.key,
  });

  final VoidCallback? onAccept;
  final VoidCallback? onMute;
  final bool isMuted;
  final bool isAcknowledging;
  final String? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🔔 📱 OrderAlertDialog.build() called');

    final state = ref.watch(orderAlertControllerProvider);
    final alert = state.active;

    debugPrint('🔔 📱 OrderAlertDialog: alert=${alert?.invoiceId}');

    if (alert == null) {
      debugPrint('🔔 📱 OrderAlertDialog: alert is NULL - returning SizedBox.shrink()');
      return const SizedBox.shrink();
    }

    debugPrint('🔔 📱 OrderAlertDialog: Rendering AlertDialog for ${alert.invoiceId}');

    final theme = Theme.of(context);
    final l10n = context.l10n;
    final items = alert.items.take(8).toList();
    final posProfile = alert.posProfile.trim().isEmpty
      ? l10n.commonNotSpecified
        : alert.posProfile.trim();

    return AlertDialog(
      backgroundColor: Colors.white, // Explicitly set background
      elevation: 24, // High elevation to ensure visibility
      title: Row(
        children: [
          const Icon(
            Icons.notification_important_outlined,
            color: Colors.redAccent,
            size: 32, // Make icon bigger
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.orderAlertTitle(alert.invoiceId),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(theme, l10n.commonCustomerLabel, alert.customerName ?? l10n.commonWalkIn),
            const SizedBox(height: 8),
            _buildField(theme, l10n.commonPosProfileLabel, posProfile),
            const SizedBox(height: 8),
            _buildField(theme, l10n.commonTotalLabel, alert.displayTotal),
            if (alert.deliveryDate != null || alert.deliveryTime != null) ...[
              const SizedBox(height: 8),
              _buildField(theme, l10n.commonDeliveryLabel, _formatDelivery(alert, l10n.commonScheduled)),
            ],
            const SizedBox(height: 12),
            Text(l10n.commonItemsLabel, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            if (items.isEmpty)
              Text(l10n.orderAlertNoLineItems, style: theme.textTheme.bodySmall)
            else ...[
              SizedBox(
                height: items.length > 4 ? 160 : items.length * 32.0,
                child: ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, index) => const Divider(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.itemName ?? item.itemCode ?? l10n.commonItemLabel,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '×${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)}',
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (alert.items.length > items.length)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.orderAlertMoreItems(alert.items.length - items.length),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(
                state.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(
              error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    ),
    actions: [
      if (onMute != null)
        TextButton.icon(
          onPressed: isAcknowledging ? null : onMute,
          icon: Icon(
            isMuted
                ? Icons.volume_up_outlined
                : Icons.volume_off_outlined,
          ),
          label: Text(isMuted ? l10n.orderAlertUnmuteAlarm : l10n.orderAlertMuteAlarm),
        ),
      FilledButton.icon(
        onPressed: isAcknowledging ? null : (onAccept ?? () {}),
        icon: isAcknowledging
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check_circle_outline),
        label: Text(isAcknowledging ? l10n.orderAlertAccepting : l10n.orderAlertAcceptOrder),
      ),
    ],
  );
}

  Widget _buildField(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }

  String _formatDelivery(InvoiceAlert alert, String scheduledLabel) {
    final date = alert.deliveryDate ?? '';
    final time = alert.deliveryTime ?? '';
    if (date.isEmpty && time.isEmpty) {
      return scheduledLabel;
    }
    if (date.isEmpty) return time;
    if (time.isEmpty) return date;
    return '$date • $time';
  }
}
