import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/network/user_service.dart';
import 'widgets/delivery_partner_tab.dart';
import 'widgets/sales_partner_tab.dart';

/// Two payables that today can only be cleared outside the app:
///
///  * Delivery Partners — the weekly bank transfer for courier-company fees.
///  * Sales Partners — commission + VAT settlement.
///
/// Gated the same way `CashTransferScreen` is: this moves real money, so a
/// non-manager sees a plain "managers only" message rather than the form.
class PartnerSettlementsScreen extends ConsumerStatefulWidget {
  const PartnerSettlementsScreen({super.key});

  @override
  ConsumerState<PartnerSettlementsScreen> createState() =>
      _PartnerSettlementsScreenState();
}

class _PartnerSettlementsScreenState
    extends ConsumerState<PartnerSettlementsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // ROLES.MANAGER, not the manager-dashboard tier: both settle endpoints
    // are gated on the former, so gating this screen on the latter would let
    // a line manager in to a screen where every call 403s.
    final allowed = ref.watch(canAccessPartnerSettlementsProvider);

    if (!allowed) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.partnerSettlementMenuTitle)),
        body: Center(child: Text(l10n.stockTransferManagersOnly)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.partnerSettlementMenuTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.partnerSettlementTabDelivery),
            Tab(text: l10n.partnerSettlementTabSales),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DeliveryPartnerTab(),
          SalesPartnerTab(),
        ],
      ),
    );
  }
}
