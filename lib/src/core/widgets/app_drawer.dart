import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/state/login_notifier.dart';
import '../../features/manager/state/manager_providers.dart';
import '../../features/pos/presentation/widgets/courier_balances_dialog.dart';
import '../localization/locale_notifier.dart';
import '../localization/localization_extensions.dart';
import '../network/user_service.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isManager = ref.watch(isJarzManagerProvider);
    final managerAccess = isManager
        ? ref.watch(managerAccessProvider)
        : const AsyncValue<bool>.data(false);
    final hasManagerAccess = managerAccess.maybeWhen(
      data: (v) => v,
      orElse: () => false,
    );
    final locale = ref.watch(localeNotifierProvider);
    final englishLocale = const Locale('en');
    final arabicLocale = const Locale('ar');
    final currentLocale = locale?.languageCode ?? englishLocale.languageCode;
    final isArabic = currentLocale == arabicLocale.languageCode;
    final selectedLanguageLabel = l10n.menuSelectedLanguage(
      describeLocale(
        context,
        isArabic ? arabicLocale : englishLocale,
      ),
    );

    Future<void> changeLanguage(Locale targetLocale) async {
      final notifier = ref.read(localeNotifierProvider.notifier);
      final languageName = describeLocale(context, targetLocale);
      final confirmed = await showDialog<bool>(
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

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _DrawerHeaderTitle(),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.point_of_sale),
            title: Text(l10n.menuPointOfSale),
            onTap: () {
              Navigator.pop(context);
              context.go('/pos');
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_kanban),
            title: Text(l10n.menuSalesKanban),
            onTap: () {
              Navigator.pop(context);
              context.go('/kanban');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text(l10n.menuExpenses),
            onTap: () {
              Navigator.pop(context);
              context.go('/expenses');
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping),
            title: Text(l10n.menuCourierBalances),
            onTap: () {
              Navigator.pop(context);
              showCourierBalancesDialog(context);
            },
          ),
          if (hasManagerAccess) ...[
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: Text(l10n.menuManagerDashboard),
              onTap: () {
                Navigator.pop(context);
                context.go('/manager');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(l10n.menuPurchaseInvoice),
              onTap: () {
                Navigator.pop(context);
                context.go('/purchase');
              },
            ),
            ListTile(
              leading: const Icon(Icons.factory),
              title: Text(l10n.menuManufacturing),
              onTap: () {
                Navigator.pop(context);
                context.go('/manufacturing');
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: Text(l10n.menuStockTransfer),
              onTap: () {
                Navigator.pop(context);
                context.go('/stock-transfer');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: Text(l10n.menuCashTransfer),
              onTap: () {
                Navigator.pop(context);
                context.go('/cash-transfer');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: Text(l10n.menuInventoryCount),
              onTap: () {
                Navigator.pop(context);
                context.go('/inventory-count');
              },
            ),
          ],
          const Divider(),
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
              if (context.mounted) context.go('/login');
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
