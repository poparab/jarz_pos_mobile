// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/courier_balances_provider.dart';
import '../../data/models/courier_balance.dart';
import '../../../pos/state/pos_notifier.dart';
import '../../../../core/network/courier_service.dart';
import '../../data/repositories/courier_repository.dart';
import '../../../kanban/widgets/settlement_preview_dialog.dart';

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
            _DialogHeader(
              onClose: () => Navigator.of(context).pop(),
              onRefresh: () async {
                final notifier = ref.read(courierBalancesProvider.notifier);
                await notifier.load();
              },
            ),
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
  separatorBuilder: (context, index) => const Divider(height: 1),
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
      trailing: SizedBox(
        width: 170,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              amount.toStringAsFixed(2),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 30,
              child: _InlineSettleAllButton(balance: b),
            ),
          ],
        ),
      ),
      onTap: () => _showDetails(context),
    );
  }

  void _showDetails(BuildContext context) {
    final ctx = context;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (sheetCtx, scrollController) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(sheetCtx).colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Details – ${b.courierName.isNotEmpty ? b.courierName : b.courier}',
          style: Theme.of(sheetCtx).textTheme.titleMedium?.copyWith(
            color: Theme.of(sheetCtx).colorScheme.onPrimary,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _SettleAllButton(balance: b),
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
                                child: Consumer(
                                  builder: (sheetCtx, ref, _) {
                                    return ElevatedButton(
                                      onPressed: () async {
                                        final messenger = ScaffoldMessenger.of(ctx);
                                        try {
                                          final posProfile = ref.read(posNotifierProvider).selectedProfile?['name'];
                                          if (posProfile == null || posProfile.isEmpty) {
                                            messenger.showSnackBar(const SnackBar(content: Text('Select POS profile first')));
                                            return;
                                          }
                                          String partyType = b.partyType.isNotEmpty ? b.partyType : 'Supplier';
                                          String party = b.party.isNotEmpty ? b.party : b.courier;

                                          // Two-step: generate preview → confirm
                                          final preview = await ref.read(courierServiceProvider).generateSettlementPreview(
                                            invoice: d.invoice,
                                            partyType: partyType,
                                            party: party,
                                            mode: 'pay_now',
                                            recentPaymentSeconds: 30,
                                          );
                                          // adopt backend provided party if missing/blank
                                          if (partyType.isEmpty && (preview['party_type'] ?? '') != '') partyType = preview['party_type'];
                                          if (party.isEmpty && (preview['party'] ?? '') != '') party = preview['party'];
                                          if (!ctx.mounted) return;

                                          final confirmed = await showSettlementConfirmDialog(
                                            ctx,
                                            preview,
                                            invoice: d.invoice,
                                            orderFallback: d.amount,
                                            shippingFallback: d.shipping,
                                          );
                                          if (confirmed != true) return;

                                          final token = preview['preview_token']?.toString();
                                          if (token == null || token.isEmpty) {
                                            messenger.showSnackBar(const SnackBar(content: Text('Missing preview token')));
                                            return;
                                          }

                                          final res = await ref.read(courierServiceProvider).confirmSettlement(
                                            invoice: d.invoice,
                                            previewToken: token,
                                            mode: 'pay_now',
                                            posProfile: posProfile,
                                            partyType: partyType.isNotEmpty ? partyType : null,
                                            party: party.isNotEmpty ? party : null,
                                            paymentMode: 'Cash',
                                            courier: b.courier,
                                          );

                                          if (!ctx.mounted) return;
                                          if (res['success'] == true || res['journal_entry'] != null || res['payment_entry'] != null) {
                                            messenger.showSnackBar(const SnackBar(content: Text('Settlement complete')));
                                            try {
                                              await ref.read(courierBalancesProvider.notifier).load();
                                            } catch (e) {
                                              debugPrint('Failed to refresh courier balances after settlement: $e');
                                            }
                                          } else {
                                            messenger.showSnackBar(const SnackBar(content: Text('Settlement failed')));
                                          }
                                        } catch (e) {
                                          if (ctx.mounted) {
                                            messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        minimumSize: const Size(0, 28),
                                        textStyle: const TextStyle(fontSize: 10),
                                      ),
                                      child: const Text('Settle'),
                                    );
                                  },
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

class _SettleAllButton extends ConsumerStatefulWidget {
  final CourierBalance balance;
  const _SettleAllButton({required this.balance});

  @override
  ConsumerState<_SettleAllButton> createState() => _SettleAllButtonState();
}

// Inline variant for list row reuse underlying logic
class _InlineSettleAllButton extends ConsumerStatefulWidget {
  final CourierBalance balance;
  const _InlineSettleAllButton({required this.balance});
  @override
  ConsumerState<_InlineSettleAllButton> createState() => _InlineSettleAllButtonState();
}

class _InlineSettleAllButtonState extends ConsumerState<_InlineSettleAllButton> {
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    final b = widget.balance;
    final disabled = (b.balance).abs() < 0.0001 || _loading;
    return ElevatedButton(
      onPressed: disabled ? null : () => _run(context),
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: const Size(0,30)),
      child: _loading ? const SizedBox(width:14,height:14,child:CircularProgressIndicator(strokeWidth:2,color: Colors.white)) : const Text('Settle', style: TextStyle(fontSize: 11)),
    );
  }

  Future<void> _run(BuildContext context) async {
    final b = widget.balance;
    final posProfile = ref.read(posNotifierProvider).selectedProfile?['name'];
    if (posProfile == null || posProfile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select POS profile first')));
      return;
    }
    final amount = b.balance.abs().toStringAsFixed(2);
    final payCourier = b.balance > 0;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(payCourier ? 'Pay Courier $amount' : 'Collect $amount'),
        content: Text('Settle all ${b.details.length} invoices for this courier?'),
        actions: [
          TextButton(onPressed: ()=>Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: ()=>Navigator.of(ctx).pop(true), child: const Text('Confirm')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(()=>_loading=true);
    try {
      final res = await ref.read(courierRepositoryProvider).settleAllForParty(
        posProfile: posProfile,
        partyType: b.partyType.isNotEmpty ? b.partyType : null,
        party: b.party.isNotEmpty ? b.party : null,
        legacyCourier: b.courier.isNotEmpty ? b.courier : null,
      );
      if (!mounted) return;
      if (res['journal_entry']!=null || res['net_balance']!=null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settled')));
        try {
          await ref.read(courierBalancesProvider.notifier).load();
        } catch (e) {
          debugPrint('Failed to refresh courier balances after settle-all inline: $e');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settlement failed')));
      }
    } catch(e){
      if(mounted){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));}    
    } finally { if(mounted) setState(()=>_loading=false); }
  }
}

class _SettleAllButtonState extends ConsumerState<_SettleAllButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final b = widget.balance;
    final disabled = (b.balance).abs() < 0.0001 || _loading;
    return SizedBox(
      height: 32,
      child: ElevatedButton.icon(
        onPressed: disabled ? null : () => _confirmAndSettleAll(context),
        icon: _loading ? const SizedBox(width:16,height:16,child: CircularProgressIndicator(strokeWidth:2,color: Colors.white)) : const Icon(Icons.done_all,size:16),
        label: const Text('Settle All', style: TextStyle(fontSize: 11)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          disabledBackgroundColor: Colors.grey.shade500,
        ),
      ),
    );
  }

  Future<void> _confirmAndSettleAll(BuildContext context) async {
    final b = widget.balance;
  final posProfile = ref.read(posNotifierProvider).selectedProfile?['name'];
    if (posProfile == null || posProfile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select POS profile first')));
      return;
    }
    final payCourier = b.balance > 0; // same logic as tile (positive => pay courier)
    final actionLabel = payCourier ? 'Pay Courier' : 'Collect From Courier';
    final netLabel = b.balance.abs().toStringAsFixed(2);
    final invoices = b.details.map((d) => d.invoice).toList();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('$actionLabel – Total $netLabel'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This will settle ${invoices.length} invoice(s).'),
              const SizedBox(height: 8),
              Text('Invoices:'),
              const SizedBox(height: 6),
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: invoices.length,
                    itemBuilder: (context, i) => Text(invoices[i], style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(payCourier
                  ? 'You will pay the courier the net amount now.'
                  : 'You will collect the net amount from the courier.'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirm')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      final res = await ref.read(courierRepositoryProvider).settleAllForParty(
        posProfile: posProfile,
        partyType: b.partyType.isNotEmpty ? b.partyType : null,
        party: b.party.isNotEmpty ? b.party : null,
        legacyCourier: b.courier.isNotEmpty ? b.courier : null,
      );
      if (!mounted) return;
      if (res['journal_entry'] != null || res['net_balance'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All settled')));
        try {
          await ref.read(courierBalancesProvider.notifier).load();
        } catch (e) {
          debugPrint('Failed to refresh courier balances after settle-all: $e');
        }
        if (Navigator.of(context).canPop()) {
          // Optionally close bottom sheet after success
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settlement failed')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
