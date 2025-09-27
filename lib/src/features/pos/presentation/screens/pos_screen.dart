import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/websocket/websocket_service.dart';
import '../../../../core/sync/offline_sync_service.dart';
import '../../state/courier_balances_provider.dart';
import 'package:go_router/go_router.dart';

// Merged system status: connectivity, realtime, sync, couriers, partner chip
// Removed unused system status imports (connectivity, sync, websocket) to satisfy analyzer.
import '../../state/pos_notifier.dart';
import '../widgets/customer_search_widget.dart';
import '../widgets/sales_partner_selector.dart';
import '../widgets/item_grid_widget.dart';
import '../widgets/cart_widget.dart';
import '../widgets/courier_balances_dialog.dart';
// Kanban is navigated as a separate route to keep headers consistent
// Printing
import '../../../printing/pos_printer_provider.dart';
import '../../../printing/printer_status.dart';
import '../../../../core/widgets/app_drawer.dart';
// Removed branch filter from POS; filter lives in Kanban header
// Removed unused direct service import (service accessed through provider)

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  // Remove embedded Kanban toggle; navigate via router instead
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if user is authenticated before loading profiles
  // Authentication assumed handled by route guard; proceed to load profiles.

      final state = ref.read(posNotifierProvider);
      if (state.selectedProfile == null) {
        ref.read(posNotifierProvider.notifier).loadProfiles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(posNotifierProvider);
    // Enforce POS profile selection: show inline selection UI on entry
    if (state.selectedProfile == null) {
      if (state.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      // Auto-select if only one profile available
      if (state.profiles.length == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(posNotifierProvider.notifier).selectProfile(state.profiles.first);
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      // Show inline profile selection without modal dialog
      if (state.profiles.isNotEmpty) {
        return _buildInlineProfileSelection(context, state.profiles);
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: PreferredSize(
    preferredSize: const Size.fromHeight(88),
        child: _MergedHeader(
          state: state,
          onShowCart: () => _showCartBottomSheet(context),
          onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
          ref: ref,
          context: context,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside text fields
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
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

}

extension on _PosScreenState {
  Widget _buildInlineProfileSelection(BuildContext context, List<Map<String, dynamic>> profiles) {
    String? selectedProfile = profiles.isNotEmpty ? profiles.first['name']?.toString() : null;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select POS Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        automaticallyImplyLeading: false,
      ),
      body: StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a POS profile to continue:',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    final name = (profile['name'] ?? '').toString();
                    final title = (profile['title'] ?? profile['name'] ?? '').toString();
                    final isSelected = selectedProfile == name;
                    
                    return Card(
                      elevation: isSelected ? 8 : 2,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: InkWell(
                        onTap: () => setState(() => selectedProfile = name),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.store,
                                size: 48,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (profile['warehouse'] != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Warehouse: ${profile['warehouse']}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedProfile == null
                          ? null
                          : () {
                              final selProfile = profiles.firstWhere(
                                (p) => p['name']?.toString() == selectedProfile,
                                orElse: () => profiles.first,
                              );
                              ref.read(posNotifierProvider.notifier).selectProfile(selProfile);
                            },
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MergedHeader extends ConsumerWidget implements PreferredSizeWidget {
  final PosState state;
  final VoidCallback onShowCart;
  final VoidCallback onOpenDrawer;
  final WidgetRef ref;
  final BuildContext context;
  const _MergedHeader({required this.state, required this.onShowCart, required this.onOpenDrawer, required this.ref, required this.context});

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext ctx, WidgetRef r) {
    final theme = Theme.of(ctx);
    final connectivityAsync = r.watch(connectivityStatusProvider);
    final webSocketService = r.watch(webSocketServiceProvider);
    final offlineSyncService = r.watch(offlineSyncServiceProvider);
    final courierState = r.watch(courierBalancesProvider);
    final partner = r.watch(posNotifierProvider.select((s) => s.selectedSalesPartner));
  final printer = r.watch(posPrinterServiceProvider);

    return Material(
      elevation: 4,
      color: theme.colorScheme.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Hamburger menu
                IconButton(
                  icon: Icon(Icons.menu, color: theme.colorScheme.onPrimary),
                  onPressed: onOpenDrawer,
                  tooltip: 'Menu',
                ),
                const SizedBox(width: 4),
                // Branch filter removed from POS (lives in Kanban header)
                const SizedBox(width: 12),
                _vDivider(theme),
                const SizedBox(width: 12),
                // Section: Partner
                if (partner != null)
                  InputChip(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    avatar: const Icon(Icons.handshake, size: 16),
                    label: Text(
                      partner['title'] ?? partner['partner_name'] ?? partner['name'] ?? 'Partner',
                      overflow: TextOverflow.ellipsis,
                    ),
                    onDeleted: () => r.read(posNotifierProvider.notifier).setSalesPartner(null),
                    deleteIcon: const Icon(Icons.close, size: 16),
                  )
                else
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onPrimary),
                    onPressed: () async {
                      final sel = await showDialog<Map<String, dynamic>?>(
                        context: ctx,
                        builder: (_) => const SalesPartnerSelectorDialog(),
                      );
                      if (sel != null) {
                        r.read(posNotifierProvider.notifier).setSalesPartner(sel);
                      }
                    },
                    icon: const Icon(Icons.handshake),
                    label: const Text('Partner'),
                  ),
                const SizedBox(width: 12),
                _vDivider(theme),
                const SizedBox(width: 12),
                // Section: POS Profile quick selector (dialog-based)
                Builder(builder: (bCtx) {
                  final profiles = r.watch(posNotifierProvider).profiles;
                  final selected = r.watch(posNotifierProvider).selectedProfile;
                  final onPrimary = theme.colorScheme.onPrimary;

                  if (profiles.isEmpty) {
                    return Text(
                      selected?['title'] ?? selected?['name'] ?? 'POS',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }

                  final label = selected != null
                      ? (selected['title'] ?? selected['name'] ?? 'POS').toString()
                      : (profiles.length == 1
                          ? (profiles.first['title'] ?? profiles.first['name'] ?? 'POS').toString()
                          : 'Select POS');

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: InkWell(
                      onTap: () async {
                        if (profiles.length == 1) {
                          r.read(posNotifierProvider.notifier).selectProfile(profiles.first);
                          return;
                        }
                        // Cycle through profiles without modal dialog
                        final currentIndex = selected != null 
                            ? profiles.indexWhere((p) => p['name'] == selected['name'])
                            : -1;
                        final nextIndex = (currentIndex + 1) % profiles.length;
                        final nextProfile = profiles[nextIndex];
                        r.read(posNotifierProvider.notifier).selectProfile(nextProfile);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: onPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: onPrimary.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.store, size: 16, color: onPrimary),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: TextStyle(
                                color: onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.arrow_drop_down, size: 18, color: onPrimary),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 12),
                _vDivider(theme),
                const SizedBox(width: 12),
                // Section: Status chips
                connectivityAsync.when(
                  data: (isOnline) => _statusChip(
                    ctx,
                    icon: isOnline ? Icons.wifi : Icons.wifi_off,
                    label: isOnline ? 'Online' : 'Offline',
                    color: isOnline ? Colors.green : Colors.red,
                  ),
                  loading: () => _statusChip(ctx, icon: Icons.wifi, label: 'Checking...', color: Colors.orange),
                  error: (e, st) => _statusChip(ctx, icon: Icons.wifi_off, label: 'Error', color: Colors.red),
                ),
                const SizedBox(width: 8),
                StreamBuilder<bool>(
                  stream: webSocketService.connectionStatus,
                  initialData: false,
                  builder: (c, snap) {
                    final connected = snap.data ?? false;
                    return _statusChip(
                      ctx,
                      icon: connected ? Icons.sync : Icons.sync_disabled,
                      label: connected ? 'Realtime' : 'No RT',
                      color: connected ? Colors.blue : Colors.grey,
                    );
                  },
                ),
                const SizedBox(width: 8),
                FutureBuilder<int>(
                  future: offlineSyncService.getPendingCount(),
                  builder: (c, snap) {
                    final pending = snap.data ?? 0;
                    return _statusChip(
                      ctx,
                      icon: pending == 0 ? Icons.check_circle : Icons.sync_problem,
                      label: pending == 0 ? 'Synced' : '$pending pending',
                      color: pending == 0 ? Colors.green : Colors.orange,
                    );
                  },
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => showCourierBalancesDialog(ctx),
                  child: _statusChip(
                    ctx,
                    icon: courierState.hasUnsettled ? Icons.delivery_dining : Icons.local_shipping,
                    label: courierState.hasUnsettled ? '${courierState.unsettledCount} couriers' : 'Couriers',
                    color: courierState.hasUnsettled ? Colors.orange : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (c, snap) {
                    final now = DateTime.now();
                    return _statusChip(
                      ctx,
                      icon: Icons.schedule,
                      label: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                      color: Colors.teal,
                    );
                  },
                ),
                const SizedBox(width: 12),
                _vDivider(theme),
                const SizedBox(width: 12),
                // Section: Printer status & actions (moved from footer)
                InkWell(
                  onTap: () => context.push('/printers'),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: () {
                        switch (printer.unifiedStatus) {
                          case PrinterUnifiedStatus.connectedBle:
                          case PrinterUnifiedStatus.connectedClassic:
                            return Colors.green.withValues(alpha: 0.15);
                          case PrinterUnifiedStatus.connecting:
                            return Colors.orange.withValues(alpha: 0.15);
                          case PrinterUnifiedStatus.error:
                            return Colors.red.withValues(alpha: 0.18);
                          case PrinterUnifiedStatus.disconnected:
                            return Colors.red.withValues(alpha: 0.15);
                        }
                      }(),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: () {
                          switch (printer.unifiedStatus) {
                            case PrinterUnifiedStatus.connectedBle:
                            case PrinterUnifiedStatus.connectedClassic:
                              return Colors.green;
                            case PrinterUnifiedStatus.connecting:
                              return Colors.orange;
                            case PrinterUnifiedStatus.error:
                              return Colors.red;
                            case PrinterUnifiedStatus.disconnected:
                              return Colors.red;
                          }
                        }().withValues(alpha: 0.7),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.print,
                          size: 16,
                          color: () {
                            switch (printer.unifiedStatus) {
                              case PrinterUnifiedStatus.connectedBle:
                              case PrinterUnifiedStatus.connectedClassic:
                                return Colors.greenAccent;
                              case PrinterUnifiedStatus.connecting:
                                return Colors.orangeAccent;
                              case PrinterUnifiedStatus.error:
                                return Colors.redAccent;
                              case PrinterUnifiedStatus.disconnected:
                                return Colors.redAccent;
                            }
                          }(),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          () {
                            switch (printer.unifiedStatus) {
                              case PrinterUnifiedStatus.connectedBle:
                                return 'Printer: BLE';
                              case PrinterUnifiedStatus.connectedClassic:
                                return 'Printer: Classic';
                              case PrinterUnifiedStatus.connecting:
                                return 'Printer: Connecting…';
                              case PrinterUnifiedStatus.error:
                                return printer.lastErrorMessage ?? 'Printer Error';
                              case PrinterUnifiedStatus.disconnected:
                                return 'Printer: Not Connected';
                            }
                          }(),
                          style: TextStyle(
                            color: () {
                              switch (printer.unifiedStatus) {
                                case PrinterUnifiedStatus.connectedBle:
                                case PrinterUnifiedStatus.connectedClassic:
                                  return Colors.green;
                                case PrinterUnifiedStatus.connecting:
                                  return Colors.orange;
                                case PrinterUnifiedStatus.error:
                                  return Colors.red;
                                case PrinterUnifiedStatus.disconnected:
                                  return Colors.red;
                              }
                            }(),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Section: Actions (Kanban, Cart, Logout)
                IconButton(
                  icon: Icon(Icons.view_kanban, color: theme.colorScheme.onPrimary),
                  tooltip: 'Kanban',
                  onPressed: () => context.push('/kanban'),
                ),
                Consumer(builder: (c, ref2, _) {
                  final cartCount = ref2.watch(posNotifierProvider.select((s) => s.cartItemCount));
                  return Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.shopping_cart, color: theme.colorScheme.onPrimary),
                        onPressed: onShowCart,
                      ),
                      if (cartCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text('$cartCount',
                                style: TextStyle(color: theme.colorScheme.onError, fontSize: 11),
                                textAlign: TextAlign.center),
                          ),
                        ),
                    ],
                  );
                }),
                // Removed Logout from header; available in Drawer
                const SizedBox(width: 12),
                // Force sync
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Force sync',
                  icon: Icon(Icons.refresh, size: 20, color: theme.colorScheme.onPrimary),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(ctx);
                    await offlineSyncService.forceSyncNow();
                    await r.read(courierBalancesProvider.notifier).load();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Sync completed'), duration: Duration(seconds: 2)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context, {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _vDivider(ThemeData theme) => Container(
        width: 1,
        height: 24,
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.12),
      );
}

// Footer removed: printer status now lives in header
