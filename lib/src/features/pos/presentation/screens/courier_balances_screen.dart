import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../state/courier_balances_provider.dart';
import '../../data/repositories/courier_repository.dart';
import '../../../kanban/widgets/settlement_preview_dialog.dart';

class CourierBalancesScreen extends ConsumerWidget {
  const CourierBalancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(courierBalancesProvider);
  final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.courierBalancesTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(courierBalancesProvider.notifier).load(),
        child: Builder(
          builder: (context) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text(l10n.commonErrorWithDetails(state.error!)));
            }

            final balances = state.balances;
            if (balances.isEmpty) {
              return Center(child: Text(l10n.courierBalancesEmpty));
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
          ? l10n.courierBalancesSettledLabel
          : (isPayCourier ? l10n.courierBalancesPayCourierLabel : l10n.courierBalancesCourierPaysUsLabel);

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
                                          l10n.courierBalancesDetailsTitle(
                                            b.courierName.isNotEmpty ? b.courierName : b.courier,
                                          ),
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
                                    separatorBuilder: (context, index) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final d = b.details[index];
                                      final net = d.amount - d.shipping;
                                      return ListTile(
                                        dense: true,
                                        title: Text(d.invoice),
                                        subtitle: Text(
                                          l10n.courierBalancesCityOrderLine(
                                            d.city,
                                            d.amount.toStringAsFixed(2),
                                            d.shipping.toStringAsFixed(2),
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(l10n.courierBalancesNetLabel),
                                                Text(
                                                  net.toStringAsFixed(2),
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              tooltip: l10n.courierBalancesPreviewTooltip,
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
              separatorBuilder: (context, index) => const Divider(height: 1),
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
  final ctx = context;
  showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    final preview = await repo.getSettlementPreview(
      invoice: invoice,
      partyType: partyType.isNotEmpty ? partyType : null,
      party: party.isNotEmpty ? party : null,
    );
    if (!ctx.mounted) return;
    Navigator.of(ctx).pop(); // remove loader
    await showSettlementInfoDialog(
      ctx,
      preview,
      invoice: invoice,
      orderFallback: null, // not available here
      shippingFallback: null,
    );
  } catch (e) {
    if (!ctx.mounted) return;
    Navigator.of(ctx).pop();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(ctx.l10n.courierBalancesPreviewFailed('$e')),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
