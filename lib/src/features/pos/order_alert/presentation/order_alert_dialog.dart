import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/invoice_alert.dart';
import '../state/order_alert_controller.dart';
import '../../../../core/network/user_service.dart';

class OrderAlertDialog extends ConsumerWidget {
  const OrderAlertDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderAlertControllerProvider);
    final alert = state.active;
    if (alert == null) {
      return const SizedBox.shrink();
    }

    final canMute = ref.watch(isJarzManagerProvider);

    final theme = Theme.of(context);
    final items = alert.items.take(8).toList();

    return AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.notification_important_outlined,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text('New Order: ${alert.invoiceId}')),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(theme, 'Customer', alert.customerName ?? 'Walk-in'),
            const SizedBox(height: 8),
            _buildField(theme, 'Total', 'PHP ${alert.displayTotal}'),
            if (alert.deliveryDate != null || alert.deliveryTime != null) ...[
              const SizedBox(height: 8),
              _buildField(theme, 'Delivery', _formatDelivery(alert)),
            ],
            const SizedBox(height: 12),
            Text('Items', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            if (items.isEmpty)
              Text('No line items', style: theme.textTheme.bodySmall)
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
                            item.itemName ?? item.itemCode ?? 'Item',
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
                    '+${alert.items.length - items.length} more item(s)',
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
          ],
        ),
      ),
      actions: [
        if (canMute)
          TextButton.icon(
            onPressed: state.isAcknowledging
                ? null
                : () => _toggleMute(ref, state.isMuted),
            icon: Icon(
              state.isMuted
                  ? Icons.volume_up_outlined
                  : Icons.volume_off_outlined,
            ),
            label: Text(state.isMuted ? 'Unmute Alarm' : 'Mute Alarm'),
          ),
        FilledButton.icon(
          onPressed: state.isAcknowledging ? null : () => _acknowledge(ref),
          icon: state.isAcknowledging
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_circle_outline),
          label: Text(state.isAcknowledging ? 'Accepting…' : 'Accept Order'),
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

  String _formatDelivery(InvoiceAlert alert) {
    final date = alert.deliveryDate ?? '';
    final time = alert.deliveryTime ?? '';
    if (date.isEmpty && time.isEmpty) {
      return 'Scheduled';
    }
    if (date.isEmpty) return time;
    if (time.isEmpty) return date;
    return '$date • $time';
  }

  Future<void> _acknowledge(WidgetRef ref) async {
    await ref.read(orderAlertControllerProvider.notifier).acknowledgeActive();
  }

  Future<void> _toggleMute(WidgetRef ref, bool isMuted) async {
    final controller = ref.read(orderAlertControllerProvider.notifier);
    if (isMuted) {
      await controller.unmuteAlerts();
    } else {
      await controller.muteActiveAlert();
    }
  }
}
