import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../../core/network/frappe_error_message.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../kanban/providers/kanban_provider.dart';
import '../../pos/state/pos_notifier.dart';
import '../data/instapay_reconciliation_service.dart';
import '../data/models/unconfirmed_online_order.dart';
import '../state/instapay_reconciliation_providers.dart';
import 'widgets/confirm_payment_sheet.dart';

/// Manager reconciliation screen for InstaPay-on-delivery orders: lists online
/// orders that are Out for Delivery and awaiting a confirmed bank transfer, and
/// lets the manager confirm the transfer or fall back to cash-at-the-door.
class InstapayReconciliationScreen extends ConsumerWidget {
  const InstapayReconciliationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posProfile = ref.watch(
      posNotifierProvider.select((s) => s.selectedProfile?['name'] as String?),
    );
    final async = ref.watch(unconfirmedOnlineOrdersProvider(posProfile));

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.pos);
            }
          },
        ),
        title: const Text('InstaPay Reconciliation'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          IconButton(
            tooltip: context.l10n.commonRetry,
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.invalidate(unconfirmedOnlineOrdersProvider(posProfile)),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(posProfile: posProfile),
        data: (orders) => _DataView(orders: orders, posProfile: posProfile),
      ),
    );
  }
}

class _ErrorView extends ConsumerWidget {
  final String? posProfile;
  const _ErrorView({required this.posProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(context.l10n.commonError, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () =>
                ref.invalidate(unconfirmedOnlineOrdersProvider(posProfile)),
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.commonRetry),
          ),
        ],
      ),
    );
  }
}

class _DataView extends ConsumerWidget {
  final List<UnconfirmedOnlineOrder> orders;
  final String? posProfile;
  const _DataView({required this.orders, required this.posProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(unconfirmedOnlineOrdersProvider(posProfile));
        await ref.read(unconfirmedOnlineOrdersProvider(posProfile).future);
      },
      child: orders.isEmpty
          ? ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: const Center(
                    child: Text('No orders awaiting InstaPay confirmation'),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
              itemCount: orders.length,
              itemBuilder: (context, index) => _OrderCard(
                order: orders[index],
                posProfile: posProfile,
              ),
            ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final UnconfirmedOnlineOrder order;
  final String? posProfile;
  const _OrderCard({required this.order, required this.posProfile});

  bool get _isStale => order.ageSeconds > kInstapayStaleThresholdSeconds;

  String _formatAge(int seconds) {
    if (seconds <= 0) return '0m';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    await ConfirmPaymentSheet.show(
      context,
      order: order,
      posProfile: posProfile,
    );
    // The sheet invalidates the list on success; re-fetch defensively.
    ref.invalidate(unconfirmedOnlineOrdersProvider(posProfile));
  }

  Future<void> _collectedCash(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final selectPosMessage = context.l10n.invoiceSelectPosFirst;

    String? partyType = order.courierPartyType;
    String? party = order.courierParty;

    // If the order has no courier assigned, ask which courier collected cash.
    if ((party ?? '').trim().isEmpty) {
      final picked = await _pickCourier(context, ref);
      if (picked == null) return;
      partyType = picked['party_type'];
      party = picked['party'];
    }

    if ((party ?? '').trim().isEmpty || (partyType ?? '').trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('A courier is required for cash collection')),
      );
      return;
    }
    final profile = (posProfile ?? '').trim();
    if (profile.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(selectPosMessage)));
      return;
    }

    try {
      await ref.read(instapayReconciliationServiceProvider).convertToCod(
            invoiceName: order.invoice,
            posProfile: profile,
            partyType: partyType!.trim(),
            party: party!.trim(),
          );
      ref.invalidate(unconfirmedOnlineOrdersProvider(posProfile));
      messenger.showSnackBar(
        const SnackBar(content: Text('Converted to cash on delivery')),
      );
    } catch (error) {
      final friendly = extractFrappeErrorMessage(
        error,
        fallback: 'Failed to convert order to cash',
      );
      messenger.showSnackBar(SnackBar(content: Text(friendly)));
    }
  }

  Future<Map<String, String>?> _pickCourier(
    BuildContext context,
    WidgetRef ref,
  ) async {
    List<Map<String, String>> couriers = const [];
    try {
      couriers = await ref
          .read(kanbanProvider.notifier)
          .getCouriers(posProfile: posProfile);
    } catch (_) {}
    if (!context.mounted) return null;

    return showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.commonCourierLabel),
        content: SizedBox(
          width: double.maxFinite,
          child: couriers.isEmpty
              ? Text(context.l10n.kanbanNoCouriersAvailable)
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: couriers.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final c = couriers[i];
                    final label = (c['display_name'] ?? c['courier_name'] ?? '')
                        .toString();
                    return ListTile(
                      leading: const Icon(Icons.local_shipping_outlined),
                      title: Text(label),
                      onTap: () => Navigator.of(ctx).pop(c),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.commonCancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ageColor =
        _isStale ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant;
    final courier = (order.courierName ?? order.courierParty ?? '').trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: _isStale ? Colors.red.withValues(alpha: 0.05) : null,
      shape: _isStale
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.invoice,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 14, color: ageColor),
                    const SizedBox(width: 4),
                    Text(
                      _formatAge(order.ageSeconds),
                      style: TextStyle(
                        color: ageColor,
                        fontWeight:
                            _isStale ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(order.customerName, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  formatCurrency(context, order.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                if ((order.paymentMethod ?? '').isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    order.paymentMethod!,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
            if ((order.expectedReference ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Ref: ${order.expectedReference}',
                style: theme.textTheme.labelSmall,
              ),
            ],
            if (courier.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                '${context.l10n.commonCourierLabel}: $courier',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _collectedCash(context, ref),
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: const Text('Collected cash instead'),
                ),
                ElevatedButton.icon(
                  onPressed: order.canConfirm
                      ? () => _confirm(context, ref)
                      : null,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Confirm received'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
