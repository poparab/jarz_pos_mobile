import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../kanban/providers/kanban_provider.dart';
import '../../pos/state/pos_notifier.dart';
import '../data/instapay_reconciliation_service.dart';
import '../data/models/escalated_payment_order.dart';
import '../data/models/unconfirmed_online_order.dart';
import '../state/instapay_reconciliation_providers.dart';
import 'widgets/confirm_payment_sheet.dart';

/// Manager reconciliation screen for InstaPay-on-delivery orders: lists online
/// orders that are Out for Delivery and awaiting a confirmed bank transfer, and
/// lets the manager confirm the transfer or fall back to cash-at-the-door.
///
/// Also surfaces the ESCALATED subset — unpaid online orders the hourly
/// escalation job has flagged as Out for Delivery past the configured
/// threshold, the ones a Notification Log gets written for and nobody reads.
/// This is the one screen where a manager already confirms these payments, so
/// escalations are shown here worst-first rather than in a screen of their own.
class InstapayReconciliationScreen extends ConsumerWidget {
  const InstapayReconciliationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posProfile = ref.watch(
      posNotifierProvider.select((s) => s.selectedProfile?['name'] as String?),
    );
    final async = ref.watch(unconfirmedOnlineOrdersProvider(posProfile));
    final escalationsAsync =
        ref.watch(unconfirmedPaymentEscalationsProvider(posProfile));

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
        title: Text(context.l10n.instapayTitle),
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
            onPressed: () {
              ref.invalidate(unconfirmedOnlineOrdersProvider(posProfile));
              ref.invalidate(unconfirmedPaymentEscalationsProvider(posProfile));
            },
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(posProfile: posProfile),
        data: (orders) => _DataView(
          orders: orders,
          posProfile: posProfile,
          escalations: escalationsAsync,
        ),
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
  final AsyncValue<List<EscalatedPaymentOrder>> escalations;
  const _DataView({
    required this.orders,
    required this.posProfile,
    required this.escalations,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final partitioned = partitionEscalatedOrders(
      orders: orders,
      escalations: escalations.valueOrNull ?? const [],
    );
    final escalatedOrders = partitioned.escalated;
    final remainingOrders = partitioned.remaining;

    final isEmpty = escalatedOrders.isEmpty && remainingOrders.isEmpty;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(unconfirmedOnlineOrdersProvider(posProfile));
        ref.invalidate(unconfirmedPaymentEscalationsProvider(posProfile));
        await Future.wait([
          ref.read(unconfirmedOnlineOrdersProvider(posProfile).future),
          ref
              .read(unconfirmedPaymentEscalationsProvider(posProfile).future)
              .catchError((_) => const <EscalatedPaymentOrder>[]),
        ]);
      },
      child: isEmpty
          ? ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Text(context.l10n.instapayNoOrders),
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
              children: [
                if (escalations.hasError)
                  _EscalationErrorBanner(
                    onRetry: () => ref.invalidate(
                      unconfirmedPaymentEscalationsProvider(posProfile),
                    ),
                  ),
                if (escalatedOrders.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.warning_amber_rounded,
                    label: l10n.escalationSectionTitle,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 6),
                  for (final escalation in escalatedOrders)
                    _EscalatedOrderCard(
                      escalation: escalation,
                      posProfile: posProfile,
                    ),
                  const SizedBox(height: 8),
                ],
                for (final order in remainingOrders)
                  _OrderCard(order: order, posProfile: posProfile),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _EscalationErrorBanner extends StatelessWidget {
  final VoidCallback onRetry;
  const _EscalationErrorBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.error_outline,
                size: 18, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.escalationLoadFailed,
                style: theme.textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

/// A row escalated by the hourly job: unconfirmed AND Out for Delivery past
/// the configured threshold. Wraps the same info/action body an ordinary
/// [_OrderCard] shows with an urgency banner on top — worst-first ordering,
/// a stripe + chip in FORM (not colour alone), the breached threshold and how
/// long it has been out, plus whether the job already alerted a manager.
class _EscalatedOrderCard extends StatelessWidget {
  final EscalatedPaymentOrder escalation;
  final String? posProfile;
  const _EscalatedOrderCard({
    required this.escalation,
    required this.posProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final mapped = UnconfirmedOnlineOrder.forEscalation(escalation);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.error, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A left stripe encodes urgency in FORM, not colour alone.
            Container(width: 6, color: theme.colorScheme.error),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    color: theme.colorScheme.error.withValues(alpha: 0.14),
                    child: Row(
                      children: [
                        Chip(
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          avatar: Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: theme.colorScheme.onError,
                          ),
                          backgroundColor: theme.colorScheme.error,
                          label: Text(
                            l10n.escalationBadge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onError,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.escalationThresholdBreached(
                              escalation.thresholdHours,
                            ),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Tooltip(
                          message: escalation.alreadyAlerted
                              ? l10n.escalationAlreadyNotified
                              : l10n.escalationNotYetNotified,
                          child: Icon(
                            escalation.alreadyAlerted
                                ? Icons.notifications_active
                                : Icons.notifications_none,
                            size: 16,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping_outlined,
                            size: 14, color: theme.colorScheme.error),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            l10n.escalationOutForDeliveryDuration(
                              _formatDuration(
                                escalation.outForDeliverySeconds,
                              ),
                            ),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if ((escalation.branch ?? '').isNotEmpty)
                          Text(
                            '${l10n.escalationBranchLabel}: ${escalation.branch}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: _OrderCardBody(order: mapped, posProfile: posProfile),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final UnconfirmedOnlineOrder order;
  final String? posProfile;
  const _OrderCard({required this.order, required this.posProfile});

  bool get _isStale => order.ageSeconds > kInstapayStaleThresholdSeconds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        child: _OrderCardBody(order: order, posProfile: posProfile),
      ),
    );
  }
}

/// The card's shared info + action body: title/age, customer, amount,
/// reference, courier and the confirm / collect-cash actions. Reused by both
/// the plain [_OrderCard] and [_EscalatedOrderCard] so the two rows never
/// drift on what actions an order carries.
class _OrderCardBody extends ConsumerWidget {
  final UnconfirmedOnlineOrder order;
  final String? posProfile;
  const _OrderCardBody({required this.order, required this.posProfile});

  bool get _isStale => order.ageSeconds > kInstapayStaleThresholdSeconds;

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    await ConfirmPaymentSheet.show(
      context,
      order: order,
      posProfile: posProfile,
    );
    // The sheet invalidates the list on success; re-fetch defensively.
    ref.invalidate(unconfirmedOnlineOrdersProvider(posProfile));
    ref.invalidate(unconfirmedPaymentEscalationsProvider(posProfile));
  }

  Future<void> _collectedCash(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final selectPosMessage = l10n.invoiceSelectPosFirst;

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
        SnackBar(content: Text(l10n.instapayCourierRequired)),
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
      ref.invalidate(unconfirmedPaymentEscalationsProvider(posProfile));
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.instapayConvertedToCod)),
      );
    } catch (error) {
      final friendly = context.userErrorMessage(
        error,
        fallback: l10n.instapayConvertFailed,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                order.displayId,
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
                  _formatDuration(order.ageSeconds),
                  style: TextStyle(
                    color: ageColor,
                    fontWeight: _isStale ? FontWeight.bold : FontWeight.w600,
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
              label: Text(context.l10n.instapayCollectedCashInstead),
            ),
            ElevatedButton.icon(
              onPressed:
                  order.canConfirm ? () => _confirm(context, ref) : null,
              icon: const Icon(Icons.check, size: 18),
              label: Text(context.l10n.instapayConfirmReceived),
            ),
          ],
        ),
      ],
    );
  }
}

/// Human-readable duration used for both the plain "age" clock and the
/// escalated "out for delivery for" text. Deliberately not localized — the
/// screen has never localized this "Xh Ym" shorthand, and matching that
/// existing idiom beats a half-localized string.
String _formatDuration(int seconds) {
  if (seconds <= 0) return '0m';
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h > 0) return '${h}h ${m}m';
  return '${m}m';
}

/// Splits the raw unconfirmed-orders + escalations lists into what
/// [_DataView] actually renders: [escalated] sorted worst-first (longest out
/// for delivery first — the service already sorts this way, but the split
/// re-sorts defensively rather than trust an upstream ordering), and
/// [remaining], the plain unconfirmed orders with any invoice already shown
/// in [escalated] removed so it never renders twice.
///
/// Deliberately a plain top-level function (not folded into the widget's
/// `build`) so the partition/sort/dedup logic is unit-testable without
/// pumping the widget tree.
({List<EscalatedPaymentOrder> escalated, List<UnconfirmedOnlineOrder> remaining})
    partitionEscalatedOrders({
  required List<UnconfirmedOnlineOrder> orders,
  required List<EscalatedPaymentOrder> escalations,
}) {
  final escalated = [...escalations]
    ..sort(
      (a, b) => b.outForDeliverySeconds.compareTo(a.outForDeliverySeconds),
    );
  final escalatedInvoices = escalated.map((e) => e.invoice).toSet();
  final remaining =
      orders.where((o) => !escalatedInvoices.contains(o.invoice)).toList();
  return (escalated: escalated, remaining: remaining);
}
