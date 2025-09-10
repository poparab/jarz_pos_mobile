import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../connectivity/connectivity_service.dart';
import '../sync/offline_sync_service.dart';
import '../websocket/websocket_service.dart';
import '../../features/pos/state/courier_balances_provider.dart';
import '../../features/pos/presentation/widgets/courier_balances_dialog.dart';
import '../../features/pos/state/pos_notifier.dart';
import '../../features/pos/presentation/widgets/sales_partner_selector.dart';

class SystemStatusBar extends ConsumerWidget {
  const SystemStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStatusProvider);
    final webSocketService = ref.watch(webSocketServiceProvider);
    final offlineSyncService = ref.watch(offlineSyncServiceProvider);
    final courierState = ref.watch(courierBalancesProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Row(
        children: [
          // Connectivity Status
          connectivityAsync.when(
            data: (isOnline) => _StatusChip(
              icon: isOnline ? Icons.wifi : Icons.wifi_off,
              label: isOnline ? 'Online' : 'Offline',
              color: isOnline ? Colors.green : Colors.red,
            ),
            loading: () => const _StatusChip(
              icon: Icons.wifi,
              label: 'Checking...',
              color: Colors.orange,
            ),
            error: (err, stack) => const _StatusChip(
              icon: Icons.wifi_off,
              label: 'Error',
              color: Colors.red,
            ),
          ),
          
          const SizedBox(width: 12),

          // WebSocket Status
          StreamBuilder<bool>(
            stream: webSocketService.connectionStatus,
            initialData: false,
            builder: (context, snapshot) {
              final isConnected = snapshot.data ?? false;
              return _StatusChip(
                icon: isConnected ? Icons.sync : Icons.sync_disabled,
                label: isConnected ? 'Real-time' : 'No real-time',
                color: isConnected ? Colors.blue : Colors.grey,
              );
            },
          ),

          const SizedBox(width: 12),

          // Offline Queue Status
          FutureBuilder<int>(
            future: offlineSyncService.getPendingCount(),
            builder: (context, snapshot) {
              final pendingCount = snapshot.data ?? 0;
              if (pendingCount == 0) {
                return const _StatusChip(
                  icon: Icons.check_circle,
                  label: 'Synced',
                  color: Colors.green,
                );
              } else {
                return _StatusChip(
                  icon: Icons.sync_problem,
                  label: '$pendingCount pending',
                  color: Colors.orange,
                );
              }
            },
          ),

          const Spacer(),

          // Unsettled Couriers indicator + one-click access
          if (!courierState.loading)
            InkWell(
              onTap: () => showCourierBalancesDialog(context),
              child: _StatusChip(
                icon: courierState.hasUnsettled ? Icons.delivery_dining : Icons.local_shipping,
                label: courierState.hasUnsettled
                    ? '${courierState.unsettledCount} couriers'
                    : 'Couriers',
                color: courierState.hasUnsettled ? Colors.orange : Colors.grey,
              ),
            )
          else
            const _StatusChip(
              icon: Icons.local_shipping,
              label: 'Couriers',
              color: Colors.grey,
            ),

          const SizedBox(width: 12),

          // Sales Partner chip (view/edit/remove)
          Consumer(
            builder: (context, ref, _) {
              final partner = ref.watch(
                posNotifierProvider.select((s) => s.selectedSalesPartner),
              );
              final theme = Theme.of(context);
              if (partner == null) {
                // Show subtle add chip for quick access
                return InkWell(
                  onTap: () async {
                    final sel = await showDialog<Map<String, dynamic>?>(
                      context: context,
                      builder: (_) => const SalesPartnerSelectorDialog(),
                    );
                    if (sel != null) {
                      ref.read(posNotifierProvider.notifier).setSalesPartner(sel);
                    }
                  },
                  child: _StatusChip(
                    icon: Icons.handshake,
                    label: 'Partner',
                    color: theme.colorScheme.primary,
                  ),
                );
              }

              final partnerLabel = partner['title'] ??
                  partner['partner_name'] ??
                  partner['name'] ??
                  'Sales Partner';

              return InputChip(
                avatar: const Icon(Icons.handshake, size: 16),
                label: Text(partnerLabel),
                onPressed: () async {
                  final sel = await showDialog<Map<String, dynamic>?>(
                    context: context,
                    builder: (_) => const SalesPartnerSelectorDialog(),
                  );
                  if (sel != null) {
                    ref.read(posNotifierProvider.notifier).setSalesPartner(sel);
                  }
                },
                onDeleted: () {
                  ref.read(posNotifierProvider.notifier).setSalesPartner(null);
                },
                deleteIcon: const Icon(Icons.close),
              );
            },
          ),

          // Current Time
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              final now = DateTime.now();
              return Text(
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),

          const SizedBox(width: 16),

          // Manual Sync Button
      IconButton(
            onPressed: () async {
              // Trigger offline sync first
        final messenger = ScaffoldMessenger.of(context);
        await offlineSyncService.forceSyncNow();
              // Then refresh courier balances snapshot
              await ref.read(courierBalancesProvider.notifier).load();
        messenger.showSnackBar(
                const SnackBar(
                  content: Text('Sync completed & couriers refreshed'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Force sync now',
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
  color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
  border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
