import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/courier_balances_provider.dart';
import '../../data/models/courier_balance.dart';
import '../../../kanban/providers/kanban_provider.dart';
import '../../../pos/state/pos_notifier.dart';

Future<void> showCourierBalancesDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => const CourierBalancesDialog(),
  );
}

class CourierBalancesDialog extends ConsumerWidget {
  const CourierBalancesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courierBalancesProvider);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: FractionallySizedBox(
        widthFactor: 0.95,
        heightFactor: 0.85,
        child: Column(
          children: [
            _DialogHeader(onClose: () => Navigator.of(context).pop(), onRefresh: () async {
              await ref.read(courierBalancesProvider.notifier).load();
            }),
            const Divider(height: 1),
            Expanded(
              child: _DialogBody(state: state),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onRefresh;
  const _DialogHeader({required this.onClose, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.primary,
      child: Row(
        children: [
          Icon(Icons.local_shipping, color: Theme.of(context).colorScheme.onPrimary),
          const SizedBox(width: 8),
          Text(
            'Courier Balances',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Refresh',
            icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.onPrimary),
            onPressed: onRefresh,
          ),
          IconButton(
            tooltip: 'Close',
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onPrimary),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _DialogBody extends StatelessWidget {
  final CourierBalancesState state;
  const _DialogBody({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }
    final balances = state.balances;
    if (balances.isEmpty) {
      return const Center(child: Text('No couriers found.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: balances.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) => _CourierTile(balances[index]),
    );
  }
}

class _CourierTile extends StatelessWidget {
  final CourierBalance b;
  const _CourierTile(this.b);

  @override
  Widget build(BuildContext context) {
    final amount = b.balance;
    final isPayCourier = amount > 0;
    final color = amount == 0
        ? Colors.grey
        : (isPayCourier ? Colors.red : Colors.green);
    final label = amount == 0
        ? 'Settled'
        : (isPayCourier ? 'Pay courier' : 'Courier pays us');
    return ListTile(
      title: Text(b.courierName.isNotEmpty ? b.courierName : b.courier),
      subtitle: Text(label),
      trailing: Text(
        amount.toStringAsFixed(2),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      onTap: () => _showDetails(context),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Details – ${b.courierName.isNotEmpty ? b.courierName : b.courier}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: b.details.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final d = b.details[index];
                      final net = d.amount - d.shipping;
                      return ListTile(
                        dense: true,
                        title: Text(d.invoice),
                        subtitle: Text(
                          'City: ${d.city}\nOrder: ${d.amount.toStringAsFixed(2)} • Shipping: ${d.shipping.toStringAsFixed(2)}',
                        ),
                        trailing: SizedBox(
                          width: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Net', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                                  Text(net.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 60,
                                height: 28,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Single invoice settlement assumes invoice already paid
                                    final messenger = ScaffoldMessenger.of(context);
                                    messenger.showSnackBar(const SnackBar(content: Text('Settling...')));
                                    try {
                                      // Access Kanban provider via root context if available
                                      final container = ProviderScope.containerOf(context, listen: false);
                                      final posProfile = container.read(posNotifierProvider).selectedProfile?['name'];
                                      if (posProfile == null || posProfile.isEmpty) {
                                        messenger.showSnackBar(const SnackBar(content: Text('Select POS profile first')));
                                        return;
                                      }
                                      final kanban = container.read(kanbanProvider.notifier);
                                      final res = await kanban.settleSingleInvoicePaid(
                                        invoiceId: d.invoice,
                                        posProfile: posProfile,
                                        partyType: b.partyType.isNotEmpty ? b.partyType : 'Supplier',
                                        party: b.party.isNotEmpty ? b.party : b.courier,
                                      );
                                      if (res != null && res['success'] == true) {
                                        messenger.showSnackBar(const SnackBar(content: Text('Settled')));
                                      } else {
                                        messenger.showSnackBar(const SnackBar(content: Text('Failed')));
                                      }
                                    } catch (e) {
                                      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    minimumSize: const Size(0, 28),
                                    textStyle: const TextStyle(fontSize: 10),
                                  ),
                                  child: const Text('Settle'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
