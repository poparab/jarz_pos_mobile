import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/partner_settlements_service.dart';
import 'delivery_partner_settle_screen.dart';

/// Each row is one Delivery Partner's unbilled fee total. Tapping it opens
/// the trip-by-trip reconciliation screen — the weekly transfer never posts
/// from this list directly, because the partner's own invoice does not
/// always agree with ours.
class DeliveryPartnerTab extends ConsumerStatefulWidget {
  const DeliveryPartnerTab({super.key});

  @override
  ConsumerState<DeliveryPartnerTab> createState() =>
      _DeliveryPartnerTabState();
}

class _DeliveryPartnerTabState extends ConsumerState<DeliveryPartnerTab> {
  List<Map<String, dynamic>> _balances = const [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(partnerSettlementsServiceProvider);
      final balances = await service.getDeliveryPartnerBalances();
      if (!mounted) return;
      setState(() => _balances = balances);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.userErrorMessage(_error.toString())),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _load,
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      );
    }
    if (_balances.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Text(l10n.partnerSettlementDeliveryEmptyBalances),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _balances.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final row = _balances[index];
          final deliveryPartner = (row['delivery_partner'] ?? '').toString();
          final displayName =
              (row['partner_name'] ?? deliveryPartner).toString();
          final tripCount = (row['order_count'] as num?)?.toInt() ?? 0;
          final totalFee = (row['total_fee'] as num?)?.toDouble() ?? 0.0;
          final oldestDate = row['oldest_date']?.toString();

          return ListTile(
            leading: const Icon(Icons.local_shipping_outlined),
            title: Text(displayName),
            subtitle: Text(
              oldestDate == null || oldestDate.isEmpty
                  ? l10n.partnerSettlementTripCount(tripCount)
                  : '${l10n.partnerSettlementTripCount(tripCount)} • '
                      '${l10n.partnerSettlementOldestSince(formatDateString(context, oldestDate))}',
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(context, totalFee),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  l10n.partnerSettlementReviewAndSettle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            onTap: () async {
              final settled = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => DeliveryPartnerSettleScreen(
                    deliveryPartner: deliveryPartner,
                    displayName: displayName,
                  ),
                ),
              );
              if (settled == true) {
                await _load();
              }
            },
          );
        },
      ),
    );
  }
}
