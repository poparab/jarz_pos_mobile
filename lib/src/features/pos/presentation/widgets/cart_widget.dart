import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../state/pos_notifier.dart';
import '../dialogs/payment_method_dialog.dart';
import 'bundle_selection_widget.dart';
import 'delivery_slot_selection.dart';

class CartWidget extends ConsumerWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(posNotifierProvider);
    final cartItems = state.cartItems;
  final customerTerritory = state.selectedCustomer?['territory']?.toString();
    // Get cart total from state if needed
    // final cartTotal = state.cartTotal;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Cart header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.posCartHeader(cartItems.length),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (cartItems.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.clear_all,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () => _showClearCartDialog(context, ref),
                    tooltip: l10n.posCartClear,
                  ),
              ],
            ),
          ),

          // Cart items
          Expanded(
            child: cartItems.isEmpty
                ? _buildEmptyCart(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      return _buildCartItem(context, ref, cartItem, index);
                    },
                  ),
          ),

          // Cart summary and checkout
          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Customer info
                  if (state.selectedCustomer != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.selectedCustomer!['customer_name'] ??
                                  l10n.posUnknownCustomer,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),


                  // Pickup toggle + Delivery Slot Selection
                  if (state.selectedProfile != null) ...[
                    // Pickup toggle row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Switch(
                            value: state.isPickup,
                            onChanged: (v) => ref.read(posNotifierProvider.notifier).setPickup(v),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.posCartPickupTitle,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  state.isPickup
                                      ? l10n.posCartPickupDescription
                                      : l10n.posCartDeliveryDescription,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (state.isPickup)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.store_mall_directory, size: 14, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.posCartPickupChip,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: Theme.of(context).colorScheme.primary),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    if (!state.isPickup)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: () {
                          if (kDebugMode) {
                            debugPrint(
                              '🎯 Rendering DeliverySlotSelection for profile: ${state.selectedProfile!['name']}',
                            );
                          }
                          return DeliverySlotSelection(
                            posProfile: state.selectedProfile!['name'],
                            selectedSlot: state.selectedDeliverySlot,
                            onSlotChanged: (slot) {
                              if (kDebugMode) {
                                debugPrint('🔄 Delivery slot changed: ${slot?.label}');
                              }
                              ref
                                  .read(posNotifierProvider.notifier)
                                  .setDeliverySlot(slot);
                            },
                            isRequired: true, // Make delivery time selection mandatory when not pickup
                          );
                        }(),
                      ),
                  ],

                  // Subtotal, Delivery, and Total
                  Column(
                    children: [
                      // Subtotal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.posSubtotalLabel,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '\$${state.cartTotal.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),

            // Delivery income (hidden when a Sales Partner is selected)
            if (state.selectedSalesPartner == null &&
              state.selectedCustomer != null &&
              state.shippingCost > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.posDeliveryLabel,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '\$${state.shippingCost.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Final Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.posTotalLabel,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${state.totalWithShipping.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Checkout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => _handleCheckout(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              l10n.posCheckoutButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

          // Shipping expense (operational info) - hide when Sales Partner is selected
          if (state.selectedSalesPartner == null &&
            state.selectedCustomer != null &&
            state.selectedCustomer!['delivery_expense'] != null &&
            state.selectedCustomer!['delivery_expense'] > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.errorContainer.withValues(alpha: 0.1),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.posOperationalInfoTitle,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.posDeliveryExpenseLabel,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                                    ),
                              ),
                              Text(
                                '\$${state.selectedCustomer!['delivery_expense'].toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                                customerTerritory != null
                                    ? l10n.posDeliveryCostTo(customerTerritory)
                                    : l10n.posDeliveryCostGeneric,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(l10n.posCartEmptyTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            l10n.posCartEmptyBody,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> cartItem,
    int index,
  ) {
    final l10n = context.l10n;
    final quantity = (cartItem['quantity'] ?? 1) as int;
    final rate = (cartItem['rate'] ?? 0.0) as double;
    final total = quantity.toDouble() * rate;
    final isBundle = cartItem['type'] == 'bundle';
    final isShipping = cartItem['is_shipping'] == true;
    final itemName = cartItem['item_name']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isShipping
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item name and action buttons
            Row(
              children: [
                if (isBundle)
                  Icon(
                    Icons.local_offer,
                    size: 16,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                if (isShipping)
                  Icon(
                    Icons.local_shipping,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                if (isBundle || isShipping) const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    itemName ?? l10n.posUnknownItem,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isShipping
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isBundle)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _editBundle(context, ref, cartItem, index),
                    tooltip: l10n.posCartEditBundle,
                  ),
                if (!isShipping) // Don't allow removing shipping items
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => ref
                        .read(posNotifierProvider.notifier)
                        .removeFromCart(index),
                    color: Theme.of(context).colorScheme.error,
                  ),
              ],
            ),

            // Show bundle items if it's a bundle
            if (isBundle && cartItem['bundle_details'] != null)
              _buildBundleDetails(context, cartItem['bundle_details']),

            const SizedBox(height: 8),

            // Price and quantity controls
            Row(
              children: [
                // Price per unit
                Text(
                  '\$${rate.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isShipping
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                const Spacer(),

                // Quantity controls (disabled for shipping items)
                if (!isShipping)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: quantity > 1
                            ? () => ref
                                  .read(posNotifierProvider.notifier)
                                  .updateCartItemQuantity(index, quantity - 1)
                            : null,
                        iconSize: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 40),
                        child: Text(
                          quantity.toString(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => ref
                            .read(posNotifierProvider.notifier)
                            .updateCartItemQuantity(index, quantity + 1),
                        iconSize: 20,
                      ),
                    ],
                  )
                else
                  // For shipping items, show quantity but make it non-editable
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${l10n.commonQtyLabel} $quantity',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Total for this item
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.posTotalLabel, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isShipping
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.posCartClearTitle),
        content: Text(l10n.posCartClearMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(posNotifierProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            child: Text(l10n.posCartClearConfirm),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCheckout(BuildContext context, WidgetRef ref) async {
    final state = ref.read(posNotifierProvider);
    final l10n = context.l10n;

    // Validate delivery slot is selected
    if (!state.isPickup && state.selectedDeliverySlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.posDeliverySelectSlot),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Payment method selection for non-sales partner orders
    String? paymentMethod;
    if (state.selectedSalesPartner == null) {
      // Show payment method dialog
      paymentMethod = await PaymentMethodDialog.show(context);
      if (paymentMethod == null) {
        return; // user cancelled the dialog
      }
    }

    // Sales partner orders require choosing how the partner will pay
    String? paymentType;
    if (state.selectedSalesPartner != null) {
      paymentType = await _promptSalesPartnerPayment(context);
      if (paymentType == null) {
        return; // user cancelled the dialog
      }
    }

    // Use the already selected profile, no branch selection dialog
    String? overridePosProfileName = state.selectedProfile?['name']?.toString();

    await ref
        .read(posNotifierProvider.notifier)
        .checkout(
          paymentType: paymentType, 
          overridePosProfileName: overridePosProfileName,
          paymentMethod: paymentMethod,
        );
    final updatedState = ref.read(posNotifierProvider);

    if (context.mounted) {
      if (updatedState.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.posCheckoutSuccess),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final failure = updatedState.error ?? l10n.commonError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.posCheckoutFailed(failure)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }



  Widget _buildBundleDetails(
    BuildContext context,
    Map<String, dynamic> bundleDetails,
  ) {
    final l10n = context.l10n;
    final selectedItems =
        bundleDetails['selected_items']
            as Map<String, List<Map<String, dynamic>>>? ??
        {};

    if (selectedItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.posBundleContentsTitle,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          ...selectedItems.entries.map((entry) {
            final groupName = entry.key;
            final items = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '$groupName: ${items.map((item) => item['name']).join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<String?> _promptSalesPartnerPayment(BuildContext context) async {
    String selected = 'cash';
    final l10n = context.l10n;
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.posSalesPartnerPaymentTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.posSalesPartnerPaymentDescription),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment<String>(
                    value: 'cash',
                    label: Text(l10n.posSalesPartnerPaymentCash),
                    icon: const Icon(Icons.attach_money),
                  ),
                  ButtonSegment<String>(
                    value: 'online',
                    label: Text(l10n.posSalesPartnerPaymentOnline),
                    icon: const Icon(Icons.online_prediction),
                  ),
                ],
                selected: <String>{selected},
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) return;
                  setState(() => selected = selection.first);
                },
                showSelectedIcon: false,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(selected),
              child: Text(l10n.commonContinue),
            ),
          ],
        ),
      ),
    );
  }

  void _editBundle(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> cartItem,
    int index,
  ) {
    final bundleDetails = cartItem['bundle_details'] as Map<String, dynamic>?;
    if (bundleDetails == null) return;

    final bundleInfo = bundleDetails['bundle_info'] as Map<String, dynamic>?;
    final currentSelections =
        bundleDetails['selected_items']
            as Map<String, List<Map<String, dynamic>>>? ??
        {};

    if (bundleInfo == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: BundleSelectionWidget(
            bundle: bundleInfo,
            initialSelections: currentSelections,
            isEditing: true,
            onCancel: () => Navigator.of(context).pop(),
            onBundleSelected: (selectedItems) {
              Navigator.of(context).pop();
              ref
                  .read(posNotifierProvider.notifier)
                  .updateBundleInCart(index, selectedItems);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.posBundleUpdated),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
