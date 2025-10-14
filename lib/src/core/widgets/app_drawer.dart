import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/state/login_notifier.dart';
import '../../features/pos/presentation/widgets/courier_balances_dialog.dart';
import '../../features/manager/state/manager_providers.dart';
import '../network/user_service.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isManager = ref.watch(isJarzManagerProvider);
    final managerAccess = isManager
        ? ref.watch(managerAccessProvider)
        : const AsyncValue<bool>.data(false);
    final hasManagerAccess = managerAccess.maybeWhen(
      data: (v) => v,
      orElse: () => false,
    );

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
                Text(
                  'Jarz POS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Mobile Point of Sale',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.point_of_sale),
            title: const Text('Point of Sale'),
            onTap: () {
              Navigator.pop(context);
              context.go('/pos');
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_kanban),
            title: const Text('Sales Kanban'),
            onTap: () {
              Navigator.pop(context);
              context.go('/kanban');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Expenses'),
            onTap: () {
              Navigator.pop(context);
              context.go('/expenses');
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping),
            title: const Text('Courier Balances'),
            onTap: () {
              Navigator.pop(context);
              showCourierBalancesDialog(context);
            },
          ),
          if (hasManagerAccess) ...[
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Manager Dashboard'),
              onTap: () {
                Navigator.pop(context);
                context.go('/manager');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Purchase Invoice'),
              onTap: () {
                Navigator.pop(context);
                context.go('/purchase');
              },
            ),
            ListTile(
              leading: const Icon(Icons.factory),
              title: const Text('Manufacturing'),
              onTap: () {
                Navigator.pop(context);
                context.go('/manufacturing');
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Stock Transfer'),
              onTap: () {
                Navigator.pop(context);
                context.go('/stock-transfer');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Cash Transfer'),
              onTap: () {
                Navigator.pop(context);
                context.go('/cash-transfer');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Inventory Count'),
              onTap: () {
                Navigator.pop(context);
                context.go('/inventory-count');
              },
            ),
          ],
          if (isManager)
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                context.go('/home');
              },
            ),
          if (isManager || hasManagerAccess) const Divider(),
          if (isManager)
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings
              },
            ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
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
