import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/pos/presentation/widgets/courier_balances_dialog.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
            leading: const Icon(Icons.local_shipping),
            title: const Text('Courier Balances'),
            onTap: () {
              Navigator.pop(context);
              showCourierBalancesDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              context.go('/home');
            },
          ),
          const Divider(),
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
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement logout
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
