import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/network/user_service.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../state/pos_notifier.dart';
import '../dialogs/payment_method_dialog.dart';
import '../dialogs/territory_profile_mismatch_dialog.dart';
import 'bundle_selection_widget.dart';
import 'delivery_slot_selection.dart';
import '../../../../core/constants/business_constants.dart';

class CartWidget extends ConsumerWidget {
  final ScrollController? scrollController;
  const CartWidget({super.key, this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(posNotifierProvider);
    final canManagePricing = ref.watch(userRolesFutureProvider).maybeWhen(
      data: (roles) => roles.canAccessManagerDashboard,
      orElse: () => false,
    );
    final cartItems = state.cartItems;
    final hasAmendmentSource =
        !state.isAmendmentDraft ||
        ((state.amendmentSourceInvoiceId ?? '').trim().isNotEmpty);
    final customerTerritory = state.selectedCustomer?['territory_name_ar']?.toString() ?? state.selectedCustomer?['territory_name']?.toString() ?? state.selectedCustomer?['territory']?.toString();
    final isPhone = ResponsiveUtils.isPhone(context);
    
    // Responsive padding
    final headerPadding = ResponsiveUtils.getResponsivePadding(
      context,
      small: 8,
      medium: 12,
      large: 16,
    );
    final contentPadding = ResponsiveUtils.getResponsivePadding(
      context,
      small: 5,
      medium: 8,
      large: 8,
    );
    
    final controller = scrollController ?? ScrollController();

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
        child: CustomScrollView(
          controller: controller,
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: headerPadding,
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
                      size: isPhone ? 18 : (ResponsiveUtils.isCompactLayout(context) ? 20 : 24),
                    ),
                    SizedBox(width: ResponsiveUtils.getSpacing(context, small: isPhone ? 4 : 6, medium: 8, large: 8)),
                    Expanded(
                      child: Text(
                        l10n.posCartHeader(cartItems.length),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: isPhone ? 14 : (ResponsiveUtils.isCompactLayout(context) ? 14 : 16),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (cartItems.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.clear_all,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          size: isPhone ? 18 : (ResponsiveUtils.isCompactLayout(context) ? 20 : 24),
                        ),
                        onPressed: () => _showClearCartDialog(context, ref),
                        tooltip: l10n.posCartClear,
                        padding: EdgeInsets.all(isPhone ? 4 : (ResponsiveUtils.isCompactLayout(context) ? 6 : 8)),
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),

            if (canManagePricing && state.selectedProfile != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: contentPadding,
                  child: _buildManagerPricingControls(context, ref, state),
                ),
              ),

            // Items or empty state
            if (cartItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyCart(context),
              )
            else
              SliverList.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = cartItems[index];
                  return Padding(
                    padding: contentPadding,
                    child: _buildCartItem(
                      context,
                      ref,
                      cartItem,
                      index,
                      canManagePricing: canManagePricing,
                    ),
                  );
                },
              ),

            // Summary
            if (cartItems.isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  padding: headerPadding,
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
                      if (state.isAmendmentDraft)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isPhone ? 10 : 12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.edit_note,
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.posAmendmentDraftTitle,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      hasAmendmentSource
                                          ? l10n.posAmendmentDraftMessage
                                          : l10n.posAmendmentCheckoutBlocked,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (state.selectedCustomer != null)
                        Container(
                          padding: EdgeInsets.all(isPhone ? 10 : 12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.selectedCustomer!['customer_name'] ??
                                      l10n.posUnknownCustomer,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Pickup toggle + Delivery Slot Selection
                      if (state.selectedProfile != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: isPhone ? 10 : 12, vertical: isPhone ? 6 : 8),
                          margin: EdgeInsets.only(bottom: isPhone ? 6 : 8),
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
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],

                      if (!state.isPickup)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: DeliverySlotSelection(
                            posProfile: state.selectedProfile!['name'],
                            selectedSlot: state.selectedDeliverySlot,
                            onSlotChanged: (slot) {
                              ref.read(posNotifierProvider.notifier).setDeliverySlot(slot);
                            },
                            isRequired: true,
                          ),
                        ),

                      // Subtotal and delivery
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.posSubtotalLabel,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: isPhone ? 14 : null),
                          ),
                          Text(
                            '\$${state.cartTotal.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: isPhone ? 14 : null),
                          ),
                        ],
                      ),

                      if (state.selectedSalesPartner == null &&
                          state.selectedCustomer != null &&
                          state.shippingCost > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.posDeliveryLabel,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: isPhone ? 14 : null),
                            ),
                            Text(
                              '\$${state.shippingCost.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: isPhone ? 14 : null),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.posTotalLabel,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isPhone ? 18 : null,
                                ),
                          ),
                          Text(
                            '\$${state.totalWithShipping.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isPhone ? 18 : null,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Checkout button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isLoading || !hasAmendmentSource
                              ? null
                              : () => _handleCheckout(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: state.isAmendmentDraft
                                ? Theme.of(context).colorScheme.secondaryContainer
                                : Theme.of(context).colorScheme.primary,
                            foregroundColor: state.isAmendmentDraft
                                ? Theme.of(context).colorScheme.onSecondaryContainer
                                : Theme.of(context).colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(vertical: isPhone ? 12 : 14),
                          ),
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  state.isAmendmentDraft
                                      ? l10n.posAmendmentDraftButton
                                      : l10n.posCheckoutButton,
                                  style: TextStyle(fontSize: isPhone ? 14 : 15, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),

                      // Shipping expense (operational info)
                      if (state.selectedSalesPartner == null &&
                          state.selectedCustomer != null &&
                          state.selectedCustomer!['delivery_expense'] != null &&
                          state.selectedCustomer!['delivery_expense'] > 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.posOperationalInfoTitle,
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.posDeliveryLabel,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                                        ),
                                  ),
                                  Text(
                                    '\$${state.selectedCustomer!['delivery_expense'].toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                customerTerritory != null
                                    ? l10n.posDeliveryCostTo(customerTerritory)
                                    : l10n.posDeliveryCostGeneric,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
              ),
          ],
        ),
      );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final l10n = context.l10n;
    return Column(
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
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> cartItem,
    int index,
    {required bool canManagePricing}
  ) {
    final l10n = context.l10n;
    final isPhone = ResponsiveUtils.isPhone(context);
    double readAmount(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    final quantity = (cartItem['quantity'] ?? 1) as int;
    final rate = readAmount(cartItem['rate']);
    final baseRate = readAmount(cartItem['price_list_rate'] ?? cartItem['rate']);
    final customRate = cartItem.containsKey('custom_rate_override')
        ? readAmount(cartItem['custom_rate_override'])
        : null;
    final discountAmount = cartItem.containsKey('discount_amount')
        ? readAmount(cartItem['discount_amount'])
        : null;
    final discountPercentage = cartItem.containsKey('discount_percentage')
        ? readAmount(cartItem['discount_percentage'])
        : null;
    final hasPricingOverride =
        customRate != null ||
        (discountAmount != null && discountAmount > 0) ||
        (discountPercentage != null && discountPercentage > 0);
    final total = quantity.toDouble() * rate;
    final isBundle = cartItem['type'] == 'bundle';
    final isShipping = cartItem['is_shipping'] == true;
    final itemName = cartItem['item_name']?.toString();
    final itemCode = cartItem['item_code']?.toString() ?? '';
    final stockQty = ref.read(posNotifierProvider.notifier).getStockForItem(itemCode);
    final exceedsStock = !isShipping && stockQty.isFinite && quantity > stockQty;

    return Card(
      margin: EdgeInsets.only(bottom: isPhone ? 6 : 8),
      color: isShipping
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: Padding(
        padding: EdgeInsets.all(isPhone ? 10 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item name and action buttons
            Row(
              children: [
                if (isBundle)
                  Icon(
                    Icons.local_offer,
                    size: isPhone ? 14 : 16,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                if (isShipping)
                  Icon(
                    Icons.local_shipping,
                    size: isPhone ? 14 : 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                if (isBundle || isShipping) const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    itemName ?? l10n.posUnknownItem,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isPhone ? 13 : null,
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
                    icon: Icon(Icons.edit, size: isPhone ? 16 : 18),
                    onPressed: () => _editBundle(context, ref, cartItem, index),
                    tooltip: l10n.posCartEditBundle,
                    visualDensity: VisualDensity.compact,
                  ),
                if (canManagePricing && !isShipping)
                  IconButton(
                    icon: Icon(Icons.price_change, size: isPhone ? 18 : 20),
                    onPressed: () =>
                        _showItemPricingDialog(context, ref, cartItem, index),
                    tooltip: l10n.posCartItemPricingDialogTitle,
                    visualDensity: VisualDensity.compact,
                  ),
                if (!isShipping) // Don't allow removing shipping items
                  IconButton(
                    icon: Icon(Icons.delete, size: isPhone ? 18 : 20),
                    onPressed: () => ref
                        .read(posNotifierProvider.notifier)
                        .removeFromCart(index),
                    color: Theme.of(context).colorScheme.error,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),

            // Show bundle items if it's a bundle
            if (isBundle && cartItem['_bundle_catalog_miss'] == true)
              _buildIncompleteBundleWarning(context)
            else if (isBundle && cartItem['bundle_details'] != null)
              _buildBundleDetails(context, cartItem['bundle_details']),

            if (hasPricingOverride) ...[
              SizedBox(height: isPhone ? 6 : 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (customRate != null)
                    _buildPricingChip(
                      context,
                      l10n.posCartItemCustomPriceApplied(
                        customRate.toStringAsFixed(2),
                      ),
                    ),
                  if (discountAmount != null && discountAmount > 0)
                    _buildPricingChip(
                      context,
                      l10n.posCartItemDiscountAmountApplied(
                        discountAmount.toStringAsFixed(2),
                      ),
                    ),
                  if (discountPercentage != null && discountPercentage > 0)
                    _buildPricingChip(
                      context,
                      l10n.posCartItemDiscountPercentApplied(
                        discountPercentage.toStringAsFixed(2),
                      ),
                    ),
                ],
              ),
            ],

            SizedBox(height: isPhone ? 6 : 8),

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
                    fontSize: isPhone ? 13 : null,
                  ),
                ),
                if (baseRate > rate) ...[
                  const SizedBox(width: 8),
                  Text(
                    '\$${baseRate.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                    ),
                  ),
                ],
                const Spacer(),

                // Quantity controls (disabled for shipping items)
                if (!isShipping)
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, size: isPhone ? 18 : 20),
                        onPressed: quantity > 1
                            ? () => ref
                                  .read(posNotifierProvider.notifier)
                                  .updateCartItemQuantity(index, quantity - 1)
                            : null,
                        iconSize: isPhone ? 18 : 20,
                        visualDensity: VisualDensity.compact,
                      ),
                      Container(
                        constraints: BoxConstraints(minWidth: isPhone ? 34 : 40),
                        child: Text(
                          quantity.toString(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold, fontSize: isPhone ? 14 : null),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, size: isPhone ? 18 : 20),
                        onPressed: () => ref
                            .read(posNotifierProvider.notifier)
                            .updateCartItemQuantity(index, quantity + 1),
                        iconSize: isPhone ? 18 : 20,
                        visualDensity: VisualDensity.compact,
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

            if (exceedsStock) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.itemGridStockLimitReached(stockQty.toInt()),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Total for this item
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.posTotalLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: isPhone ? 13 : null),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isPhone ? 14 : null,
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

  Widget _buildManagerPricingControls(
    BuildContext context,
    WidgetRef ref,
    PosState state,
  ) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final priceLists = state.availablePriceLists;
    final selectedPriceList = state.selectedPriceList;
    final selectedPriceListName = state.selectedPriceListName;
    final zeroShippingDefault =
        selectedPriceList?['zero_shipping_default'] == true ||
        selectedPriceList?['zero_shipping_default'] == 1;
    final shippingSwitchLocked =
        state.isPickup || state.selectedSalesPartner != null;

    final helperText = shippingSwitchLocked
        ? (state.isPickup
              ? l10n.posCartZeroShippingManagedByPickup
              : l10n.posCartZeroShippingManagedByPartner)
        : (zeroShippingDefault
              ? l10n.posCartZeroShippingPriceListDefault
              : l10n.posCartZeroShippingDescription);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sell_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.posCartPricingTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (selectedPriceList?['is_default'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.posCartPriceListDefaultChip,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey(selectedPriceListName ?? 'default-price-list'),
              initialValue: priceLists.any(
                (priceList) =>
                    priceList['name']?.toString() == selectedPriceListName,
              )
                  ? selectedPriceListName
                  : null,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.posCartPriceListLabel,
                helperText: l10n.posCartPriceListHint,
                border: const OutlineInputBorder(),
              ),
              items: priceLists
                  .map(
                    (priceList) => DropdownMenuItem<String>(
                      value: priceList['name']?.toString(),
                      child: Text(
                        priceList['display_label']?.toString() ??
                            priceList['name']?.toString() ??
                            '',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: priceLists.isEmpty || state.isLoading
                  ? null
                  : (value) {
                      ref
                          .read(posNotifierProvider.notifier)
                          .setSelectedPriceList(value);
                    },
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: state.zeroShippingOverride,
              onChanged: shippingSwitchLocked || state.isLoading
                  ? null
                  : (value) {
                      ref
                          .read(posNotifierProvider.notifier)
                          .setZeroShippingOverride(value);
                    },
              title: Text(
                l10n.posCartZeroShippingTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              subtitle: Text(helperText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  double? _parseNullableAmount(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  Future<void> _showItemPricingDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> cartItem,
    int index,
  ) async {
    final l10n = context.l10n;
    double readAmount(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    final originalCatalogRate = readAmount(
      cartItem['original_catalog_rate'] ??
          cartItem['price_list_rate'] ??
          cartItem['rate'],
    );
    final hasOverrides =
        cartItem.containsKey('custom_rate_override') ||
        cartItem.containsKey('discount_amount') ||
        cartItem.containsKey('discount_percentage');
    final customRateController = TextEditingController(
      text: cartItem.containsKey('custom_rate_override')
          ? readAmount(cartItem['custom_rate_override']).toStringAsFixed(2)
          : '',
    );
    final discountAmountController = TextEditingController(
      text: cartItem.containsKey('discount_amount')
          ? readAmount(cartItem['discount_amount']).toStringAsFixed(2)
          : '',
    );
    final discountPercentController = TextEditingController(
      text: cartItem.containsKey('discount_percentage')
          ? readAmount(cartItem['discount_percentage']).toStringAsFixed(2)
          : '',
    );

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          String? validationError;
          return StatefulBuilder(
            builder: (context, setStateDialog) {
              void savePricing() {
                final customRate =
                    _parseNullableAmount(customRateController.text);
                final discountAmount =
                    _parseNullableAmount(discountAmountController.text);
                final discountPercentage =
                    _parseNullableAmount(discountPercentController.text);

                if ((customRateController.text.trim().isNotEmpty && customRate == null) ||
                    (discountAmountController.text.trim().isNotEmpty && discountAmount == null) ||
                    (discountPercentController.text.trim().isNotEmpty && discountPercentage == null)) {
                  setStateDialog(() {
                    validationError = l10n.posCartItemPricingInvalidNumber;
                  });
                  return;
                }
                if (customRate != null && customRate < 0) {
                  setStateDialog(() {
                    validationError = l10n.posCartItemPricingInvalidCustomRate;
                  });
                  return;
                }
                if (discountAmount != null && discountAmount < 0) {
                  setStateDialog(() {
                    validationError = l10n.posCartItemPricingInvalidDiscountAmount;
                  });
                  return;
                }
                if (discountPercentage != null &&
                    (discountPercentage < 0 || discountPercentage > 100)) {
                  setStateDialog(() {
                    validationError = l10n.posCartItemPricingInvalidDiscountPercent;
                  });
                  return;
                }
                if ((discountAmount ?? 0) > 0 && (discountPercentage ?? 0) > 0) {
                  setStateDialog(() {
                    validationError = l10n.posCartItemPricingChooseSingleDiscount;
                  });
                  return;
                }

                final effectiveBase = customRate ?? originalCatalogRate;
                if ((discountAmount ?? 0) > effectiveBase) {
                  setStateDialog(() {
                    validationError = l10n.posCartItemPricingDiscountTooHigh;
                  });
                  return;
                }

                ref.read(posNotifierProvider.notifier).applyCartItemPricing(
                      index,
                      customRateOverride: customRate,
                      discountAmount: discountAmount,
                      discountPercentage: discountPercentage,
                    );
                Navigator.of(dialogContext).pop();
              }

              return AlertDialog(
                title: Text(l10n.posCartItemPricingDialogTitle),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem['item_name']?.toString() ?? l10n.posUnknownItem,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.posCartItemPricingBaseRate(
                          originalCatalogRate.toStringAsFixed(2),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: customRateController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.posCartItemPricingCustomRateLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: discountAmountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.posCartItemPricingDiscountAmountLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: discountPercentController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.posCartItemPricingDiscountPercentLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.posCartItemPricingDiscountHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                      ),
                      if (validationError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          validationError!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  if (hasOverrides)
                    TextButton(
                      onPressed: () {
                        ref
                            .read(posNotifierProvider.notifier)
                            .clearCartItemPricing(index);
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(l10n.posCartItemPricingReset),
                    ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.commonCancel),
                  ),
                  ElevatedButton(
                    onPressed: savePricing,
                    child: Text(l10n.posCartItemPricingSave),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      customRateController.dispose();
      discountAmountController.dispose();
      discountPercentController.dispose();
    }
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

    final stockOverages = ref
        .read(posNotifierProvider.notifier)
        .getCartItemsExceedingStock();
    if (stockOverages.isNotEmpty) {
      final proceed = await _confirmStockOverageCheckout(
        context,
        stockOverages,
      );
      if (proceed != true) {
        return;
      }
    }

    // Payment method selection for non-sales partner orders
    String? paymentMethod;
    if (state.selectedSalesPartner == null) {
      if (!context.mounted) return;
      // Show payment method dialog
      paymentMethod = await PaymentMethodDialog.show(context);
      if (paymentMethod == null) {
        return; // user cancelled the dialog
      }
    }
    // Sales partner orders require choosing how the partner will pay
    String? paymentType;
    if (state.selectedSalesPartner != null) {
      if (!context.mounted) return;
      paymentType = await _promptSalesPartnerPayment(context);
      if (paymentType == null) {
        return; // user cancelled the dialog
      }
    }

    // Territory → POS profile preflight
    if (!context.mounted) return;
    final profileResolution = await _resolveProfileForCheckout(context, ref, state);
    if (profileResolution == null) return; // user cancelled

    await ref
        .read(posNotifierProvider.notifier)
        .checkout(
          paymentType: paymentType,
          overridePosProfileName: profileResolution.profileName,
          paymentMethod: paymentMethod,
          posProfileOverride: profileResolution.override,
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

  Future<bool?> _confirmStockOverageCheckout(
    BuildContext context,
    List<Map<String, dynamic>> overages,
  ) {
    final l10n = context.l10n;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.posCheckoutStockExceedTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.posCheckoutStockExceedMessage),
              const SizedBox(height: 12),
              ...overages.map((item) {
                final itemName = item['item_name']?.toString() ??
                    item['item_code']?.toString() ??
                    l10n.posUnknownItem;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    l10n.posCheckoutStockExceedLine(
                      itemName,
                      _formatQty(item['requested_qty']),
                      _formatQty(item['available_qty']),
                    ),
                    style: Theme.of(dialogContext).textTheme.bodySmall,
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.posCheckoutProceedAnyway),
          ),
        ],
      ),
    );
  }

  String _formatQty(dynamic value) {
    final qty = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;
    return qty == qty.roundToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(2);
  }



  Widget _buildBundleDetails(
    BuildContext context,
    Map<String, dynamic> bundleDetails,
  ) {
    final l10n = context.l10n;
    final bundleInfo = bundleDetails['bundle_info'] as Map<String, dynamic>?;
    final groupLabels = _bundleGroupLabels(bundleInfo);
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
            final groupName = _bundleGroupLabel(
              entry.key,
              entry.value,
              groupLabels,
            );
            final items = entry.value;
            // Group identical items by name and show count
            final counts = <String, int>{};
            for (final item in items) {
              final name = (item['name'] ?? '').toString();
              counts[name] = (counts[name] ?? 0) + 1;
            }
            final summary = counts.entries.map((e) {
              return e.value > 1 ? '${e.key} x${e.value}' : e.key;
            }).join(', ');
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '$groupName: $summary',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIncompleteBundleWarning(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: colorScheme.error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Bundle contents could not be loaded. Edit this bundle and reselect items before submitting.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _bundleGroupLabels(Map<String, dynamic>? bundleInfo) {
    final labels = <String, String>{};
    final itemGroups = bundleInfo?['item_groups'] as List<dynamic>? ?? const [];

    for (var index = 0; index < itemGroups.length; index++) {
      final group = Map<String, dynamic>.from(itemGroups[index] as Map);
      final groupKey = _bundleGroupKey(group, index);
      final label =
          (group['group_name'] ?? group['item_group'] ?? group['title'])
              ?.toString()
              .trim();
      if (label != null && label.isNotEmpty) {
        labels[groupKey] = label;
      }
    }

    return labels;
  }

  String _bundleGroupKey(Map<String, dynamic> group, int fallbackIndex) {
    final rawKey =
        (group['group_key'] ?? group['group_id'] ?? group['name'])
            ?.toString()
            .trim();
    if (rawKey != null && rawKey.isNotEmpty) {
      return rawKey;
    }

    final rawIndex = group['group_index'] ?? group['idx'] ?? (fallbackIndex + 1);
    return '${_bundleLegacyGroupLabel((group['group_name'] ?? group['item_group'] ?? group['title'] ?? 'Group').toString())}::$rawIndex';
  }

  String _bundleGroupLabel(
    String key,
    List<Map<String, dynamic>> items,
    Map<String, String> labels,
  ) {
    final resolvedLabel = labels[key];
    if (resolvedLabel != null && resolvedLabel.isNotEmpty) {
      return resolvedLabel;
    }

    if (items.isNotEmpty) {
      final itemLabel = items.first['group_name']?.toString().trim();
      if (itemLabel != null && itemLabel.isNotEmpty) {
        return itemLabel;
      }
    }

    return _bundleLegacyGroupLabel(key);
  }

  String _bundleLegacyGroupLabel(String key) {
    final separatorIndex = key.lastIndexOf('::');
    if (separatorIndex > 0) {
      return key.substring(0, separatorIndex);
    }
    return key;
  }

  Future<String?> _promptSalesPartnerPayment(BuildContext context) async {
    String selected = PaymentModes.cashLower;
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
                    value: PaymentModes.cashLower,
                    label: Text(l10n.posSalesPartnerPaymentCash),
                    icon: const Icon(Icons.attach_money),
                  ),
                  ButtonSegment<String>(
                    value: PaymentModes.onlineLower,
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

  /// Determines which POS profile to use for checkout, prompting the user if
  /// the selected profile doesn't match the customer's territory profile.
  ///
  /// Returns `null` when the user cancels, or a record with the chosen profile
  /// name and whether `pos_profile_override` should be sent.
  Future<({String profileName, bool override})?> _resolveProfileForCheckout(
    BuildContext context,
    WidgetRef ref,
    PosState state,
  ) async {
    final selectedProfileName =
        state.selectedProfile?['name']?.toString() ?? '';
    if (selectedProfileName.isEmpty) return null;

    final customer = state.selectedCustomer;
    final customerName = customer?['name']?.toString() ?? '';
    final isWalkingCustomer =
        customerName.isEmpty || customerName == 'Walking Customer';

    if (isWalkingCustomer) {
      // No territory → show dialog with only the "keep selected" option
      if (!context.mounted) return null;
      final choice = await TerritoryProfileMismatchDialog.show(
        context,
        selectedProfile: selectedProfileName,
        territoryProfile: null,
      );
      if (choice == null) return null;
      return (profileName: choice.profileName, override: choice.override);
    }

    // Fetch the POS profile mapped to the customer's territory (null = none)
    final territoryProfile = await ref
        .read(posNotifierProvider.notifier)
        .getTerritoryPosProfile(customerName);

    // Profiles match → proceed silently, no override needed
    if (territoryProfile != null &&
        territoryProfile.isNotEmpty &&
        territoryProfile == selectedProfileName) {
      return (profileName: selectedProfileName, override: false);
    }

    // Mismatch (or no territory mapping) → ask the user
    if (!context.mounted) return null;
    final choice = await TerritoryProfileMismatchDialog.show(
      context,
      selectedProfile: selectedProfileName,
      territoryProfile: territoryProfile,
    );
    if (choice == null) return null;
    return (profileName: choice.profileName, override: choice.override);
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

    final isPhone = ResponsiveUtils.isPhone(context);

    final bundleWidget = BundleSelectionWidget(
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
    );

    if (isPhone) {
      showDialog(
        context: context,
        barrierDismissible: true,
        useSafeArea: false,
        builder: (context) => Dialog.fullscreen(child: bundleWidget),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.getDialogWidth(
                context,
                small: 800,
                medium: 800,
                large: 800,
              ),
              maxHeight: ResponsiveUtils.getDialogHeight(
                context,
                phoneFraction: 0.9,
                tabletFraction: 0.78,
                max: 600,
              ),
            ),
            child: bundleWidget,
          ),
        ),
      );
    }
  }
}
