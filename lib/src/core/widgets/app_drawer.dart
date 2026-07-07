import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';
import '../../features/auth/state/login_notifier.dart';
import '../../features/manager/state/manager_providers.dart';
import '../../features/pos/presentation/widgets/courier_balances_dialog.dart';
import '../localization/locale_notifier.dart';
import '../localization/localization_extensions.dart';
import '../network/user_service.dart';
import '../../features/shift/state/shift_notifier.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isLineManager = ref.watch(isLineManagerProvider);
    final isModerator = ref.watch(isModeratorProvider);
    final canAccessB2b = ref.watch(canAccessB2bProvider);
    final canAccessManagerDashboardRole = ref.watch(
      canAccessManagerDashboardRoleProvider,
    );
    final canAccessShiftMonitor = ref.watch(canAccessShiftMonitorProvider);
    final managerAccess = canAccessManagerDashboardRole
        ? ref.watch(managerAccessProvider)
        : const AsyncValue<bool>.data(false);
    final requirePosShift = ref.watch(requirePosShiftProvider);
    final activeShiftAsync = ref.watch(activeShiftProvider);
    final hasActiveShift = activeShiftAsync.valueOrNull != null;
    final hasManagerAccess = managerAccess.maybeWhen(
      data: (v) => v,
      orElse: () => false,
    );
    final hasElevatedAccess = hasManagerAccess || isLineManager || isModerator;
    final locale = ref.watch(localeNotifierProvider);
    final englishLocale = const Locale('en');
    final arabicLocale = const Locale('ar');
    final currentLocale = locale?.languageCode ?? englishLocale.languageCode;
    final isArabic = currentLocale == arabicLocale.languageCode;
    final selectedLanguageLabel = l10n.menuSelectedLanguage(
      describeLocale(context, isArabic ? arabicLocale : englishLocale),
    );

    Future<void> changeLanguage(Locale targetLocale) async {
      final notifier = ref.read(localeNotifierProvider.notifier);
      final languageName = describeLocale(context, targetLocale);
      final confirmed =
          await showDialog<bool>(
            context: context,
            builder: (dialogCtx) => AlertDialog(
              title: Text(l10n.menuLanguage),
              content: Text(l10n.menuConfirmLanguage(languageName)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                  child: Text(l10n.commonConfirm),
                ),
              ],
            ),
          ) ??
          false;
      if (!confirmed) return;

      await notifier.setLocale(targetLocale);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.languageChanged(languageName))),
      );
    }

    // Navigate helper: preserve the existing behavior (close drawer, then go).
    void navigate(String route) {
      Navigator.pop(context);
      context.go(route);
    }

    ListTile navTile({
      required IconData icon,
      required String title,
      required VoidCallback onTap,
    }) {
      return ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: onTap,
      );
    }

    // Current location, used to auto-expand the group holding the active route.
    String currentLocation;
    try {
      currentLocation = GoRouterState.of(context).uri.toString();
    } catch (_) {
      currentLocation = '';
    }
    bool matchesRoute(List<String> routes) => routes.any(
      (r) => currentLocation == r || currentLocation.startsWith('$r/'),
    );

    // ── Group child lists (each item keeps its original route/gate/icon) ──
    final posChildren = <Widget>[
      navTile(
        icon: Icons.point_of_sale,
        title: l10n.menuPointOfSale,
        onTap: () => navigate(AppRoutes.pos),
      ),
      if (requirePosShift && hasActiveShift)
        navTile(
          icon: Icons.timer_off,
          title: l10n.menuEndShift,
          onTap: () => navigate(AppRoutes.shiftEnd),
        ),
      navTile(
        icon: Icons.view_kanban,
        title: l10n.menuSalesKanban,
        onTap: () => navigate(AppRoutes.kanban),
      ),
    ];

    final crmChildren = <Widget>[
      if (canAccessB2b)
        navTile(
          icon: Icons.handshake_outlined,
          title: l10n.menuB2bMode,
          onTap: () => navigate(AppRoutes.b2b),
        ),
      if (canAccessB2b)
        navTile(
          icon: Icons.travel_explore,
          title: l10n.menuLeads,
          onTap: () => navigate(AppRoutes.leads),
        ),
    ];

    final deliveryChildren = <Widget>[
      navTile(
        icon: Icons.local_shipping_outlined,
        title: l10n.menuDeliveryTrips,
        onTap: () => navigate(AppRoutes.trips),
      ),
      navTile(
        icon: Icons.local_shipping,
        title: l10n.menuCourierBalances,
        onTap: () {
          Navigator.pop(context);
          showCourierBalancesDialog(context);
        },
      ),
    ];

    final financeChildren = <Widget>[
      navTile(
        icon: Icons.receipt_long,
        title: l10n.menuExpenses,
        onTap: () => navigate(AppRoutes.expenses),
      ),
      if (hasManagerAccess)
        navTile(
          icon: Icons.account_balance_wallet,
          title: l10n.menuCashTransfer,
          onTap: () => navigate(AppRoutes.cashTransfer),
        ),
    ];

    final purchasingChildren = <Widget>[
      if (hasManagerAccess) ...[
        navTile(
          icon: Icons.receipt_long,
          title: l10n.menuPurchaseInvoice,
          onTap: () => navigate(AppRoutes.purchase),
        ),
        navTile(
          icon: Icons.factory,
          title: l10n.menuManufacturing,
          onTap: () => navigate(AppRoutes.manufacturing),
        ),
        navTile(
          icon: Icons.swap_horiz,
          title: l10n.menuStockTransfer,
          onTap: () => navigate(AppRoutes.stockTransfer),
        ),
        navTile(
          icon: Icons.inventory,
          title: l10n.menuInventoryCount,
          onTap: () => navigate(AppRoutes.inventoryCount),
        ),
      ],
    ];

    final managementChildren = <Widget>[
      if (hasElevatedAccess)
        navTile(
          icon: Icons.list_alt,
          title: l10n.menuMasterOrders,
          onTap: () => navigate(AppRoutes.masterOrders),
        ),
      if (hasManagerAccess)
        navTile(
          icon: Icons.dashboard,
          title: l10n.menuManagerDashboard,
          onTap: () => navigate(AppRoutes.manager),
        ),
      if (hasManagerAccess && canAccessShiftMonitor)
        navTile(
          icon: Icons.timeline,
          title: l10n.menuShiftMonitor,
          onTap: () => navigate(AppRoutes.shiftMonitor),
        ),
      if (hasManagerAccess)
        navTile(
          icon: Icons.bar_chart,
          title: l10n.menuReports,
          onTap: () => navigate(AppRoutes.reports),
        ),
    ];

    // Auto-expand the group containing the active route; fall back to POS/Sales.
    const posRoutes = [AppRoutes.pos, AppRoutes.shiftEnd, AppRoutes.kanban];
    const crmRoutes = [AppRoutes.b2b, AppRoutes.leads];
    const deliveryRoutes = [AppRoutes.trips];
    const financeRoutes = [AppRoutes.expenses, AppRoutes.cashTransfer];
    const purchasingRoutes = [
      AppRoutes.purchase,
      AppRoutes.manufacturing,
      AppRoutes.stockTransfer,
      AppRoutes.inventoryCount,
    ];
    const managementRoutes = [
      AppRoutes.masterOrders,
      AppRoutes.manager,
      AppRoutes.shiftMonitor,
      AppRoutes.reports,
      AppRoutes.reportsShipping,
      AppRoutes.reportsInventory,
      AppRoutes.reportsProduct,
      AppRoutes.reportsCustomer,
      AppRoutes.reportsExecutive,
      AppRoutes.reportsB2b,
    ];
    final anyGroupMatches = [
      posRoutes,
      crmRoutes,
      deliveryRoutes,
      financeRoutes,
      purchasingRoutes,
      managementRoutes,
    ].any(matchesRoute);

    Widget? group({
      required IconData icon,
      required String label,
      required List<Widget> children,
      required bool expanded,
    }) {
      if (children.isEmpty) return null;
      return ExpansionTile(
        leading: Icon(icon),
        title: Text(label),
        initiallyExpanded: expanded,
        childrenPadding: const EdgeInsets.only(left: 16),
        children: children,
      );
    }

    final groups = <Widget?>[
      group(
        icon: Icons.point_of_sale,
        label: l10n.drawerGroupPosSales,
        children: posChildren,
        expanded: matchesRoute(posRoutes) || !anyGroupMatches,
      ),
      group(
        icon: Icons.handshake_outlined,
        label: l10n.drawerGroupCrm,
        children: crmChildren,
        expanded: matchesRoute(crmRoutes),
      ),
      group(
        icon: Icons.local_shipping_outlined,
        label: l10n.drawerGroupDelivery,
        children: deliveryChildren,
        expanded: matchesRoute(deliveryRoutes),
      ),
      group(
        icon: Icons.account_balance_wallet,
        label: l10n.drawerGroupFinance,
        children: financeChildren,
        expanded: matchesRoute(financeRoutes),
      ),
      group(
        icon: Icons.inventory,
        label: l10n.drawerGroupPurchasing,
        children: purchasingChildren,
        expanded: matchesRoute(purchasingRoutes),
      ),
      group(
        icon: Icons.insights,
        label: l10n.drawerGroupManagement,
        children: managementChildren,
        expanded: matchesRoute(managementRoutes),
      ),
    ].whereType<Widget>().toList();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_DrawerHeaderTitle()],
            ),
          ),
          ...groups,
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.menuAbout),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.about);
            },
          ),
          SwitchListTile.adaptive(
            secondary: const Icon(Icons.language),
            title: Text(l10n.menuLanguage),
            subtitle: Text(selectedLanguageLabel),
            value: isArabic,
            onChanged: (value) {
              final targetLocale = value ? arabicLocale : englishLocale;
              if (targetLocale.languageCode != currentLocale) {
                changeLanguage(targetLocale);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.menuLogout),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(loginNotifierProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerHeaderTitle extends StatelessWidget {
  const _DrawerHeaderTitle();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          l10n.drawerHeaderTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.drawerHeaderSubtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
