import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router.dart';
import '../../../../core/ui/system_status_bar.dart';
import '../../state/pos_notifier.dart';
import '../widgets/customer_search_widget.dart';
import '../widgets/item_grid_widget.dart';
import '../widgets/cart_widget.dart';
import '../widgets/courier_balances_dialog.dart';
// Kanban is navigated as a separate route to keep headers consistent

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  // Remove embedded Kanban toggle; navigate via router instead

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if user is authenticated before loading profiles
      final authState = ref.read(currentAuthStateProvider);
      if (!authState) {
        // User is not authenticated, router should handle redirect
        return;
      }

      final state = ref.read(posNotifierProvider);
      if (state.selectedProfile == null) {
        ref.read(posNotifierProvider.notifier).loadProfiles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(posNotifierProvider);

    // If multiple profiles available and no profile selected, redirect to profile selection
    if (state.profiles.length > 1 && state.selectedProfile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/pos-profile-selection');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(state.selectedProfile?['title'] ?? 'POS'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          // Couriers shortcut (opens big popup)
          IconButton(
            icon: const Icon(Icons.local_shipping),
            onPressed: () => showCourierBalancesDialog(context),
            tooltip: 'Courier Balances',
          ),
          // Navigate to Kanban
          IconButton(
            icon: const Icon(Icons.view_kanban),
            onPressed: () => context.push('/kanban'),
            tooltip: 'Open Kanban',
          ),
          // Cart summary badge (only show in POS mode)
          if (true)
            Consumer(
              builder: (context, ref, child) {
                final cartCount = ref.watch(
                  posNotifierProvider.select((state) => state.cartItemCount),
                );
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () => _showCartBottomSheet(context),
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$cartCount',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onError,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside text fields
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
            // System Status Bar
            const SystemStatusBar(),
            
            // Main Content
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                  ? _buildError(context, state.error!)
                  : Row(
                children: [
                  // Left side - Items and customer search (70% width)
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        // Customer search bar
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const CustomerSearchWidget(),
                        ),
                        // Items grid
                        const Expanded(child: ItemGridWidget()),
                      ],
                    ),
                  ),
                  // Right side - Cart (30% width)
                  const Expanded(flex: 3, child: CartWidget()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text('Error', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                ref.read(posNotifierProvider.notifier).loadProfiles(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Shopping Cart',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: const CartWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
