import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/courier_balances_provider.dart';
import '../../data/repositories/courier_repository.dart';

class CourierBalancesScreen extends ConsumerWidget {
  const CourierBalancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courierBalancesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courier Balances'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(courierBalancesProvider.notifier).load(),
        child: Builder(
          builder: (context) {
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
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final b = balances[index];
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
                  onTap: () {
                    // Expand to show per-invoice details in a bottom sheet
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
                                        subtitle: Text('City: ${d.city}\nOrder: ${d.amount.toStringAsFixed(2)} • Shipping: ${d.shipping.toStringAsFixed(2)}'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                const Text('Net'),
                                                Text(
                                                  net.toStringAsFixed(2),
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              tooltip: 'Preview Settlement',
                                              icon: const Icon(Icons.account_balance_wallet_outlined),
                                              onPressed: () => _showSettlementPreview(
                                                context,
                                                ref,
                                                invoice: d.invoice,
                                                partyType: b.partyType,
                                                party: b.party,
                                              ),
                                            ),
                                          ],
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
                  },
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: balances.length,
            );
          },
        ),
      ),
    );
  }
}

Future<void> _showSettlementPreview(
  BuildContext context,
  WidgetRef ref, {
  required String invoice,
  required String partyType,
  required String party,
}) async {
  final repo = ref.read(courierRepositoryProvider);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    final preview = await repo.getSettlementPreview(
      invoice: invoice,
      partyType: partyType.isNotEmpty ? partyType : null,
      party: party.isNotEmpty ? party : null,
    );
    if (!context.mounted) return;
    Navigator.of(context).pop(); // remove loader
  final action = preview['branch_action'] as String? ?? '';
  final net = (preview['net_amount'] ?? 0).toString();
  final netVal = (preview['net_amount'] is num)
    ? (preview['net_amount'] as num).toDouble()
    : double.tryParse(preview['net_amount'].toString()) ?? 0.0;
  final message = preview['message'] as String? ?? 'No details';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Settlement Preview – $invoice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            Text(
              netVal > 0
                  ? 'COLLECT: ${netVal.toStringAsFixed(2)}'
                  : netVal < 0
                      ? 'PAY: ${(-netVal).toStringAsFixed(2)}'
                      : 'Nothing to pay or collect',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to load settlement preview: $e'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
