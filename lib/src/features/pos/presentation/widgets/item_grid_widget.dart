import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive_utils.dart';
import '../../state/pos_notifier.dart';
import 'bundle_selection_widget.dart';

class ItemGridWidget extends ConsumerStatefulWidget {
  /// Optional animation (1.0=visible, 0.0=hidden) to collapse filter chips
  /// on phones when scrolling.
  final Animation<double>? hideAnimation;

  const ItemGridWidget({super.key, this.hideAnimation});

  @override
  ConsumerState<ItemGridWidget> createState() => _ItemGridWidgetState();
}

class _ItemGridWidgetState extends ConsumerState<ItemGridWidget> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(posNotifierProvider.select((state) => state.items));
    final bundles = ref.watch(
      posNotifierProvider.select((state) => state.bundles),
    );
    final selectedCustomer = ref.watch(
      posNotifierProvider.select((state) => state.selectedCustomer),
    );

    // Group items by category and ensure Bundles is first
    final itemsByCategory = <String, List<Map<String, dynamic>>>{};

    // Add bundles first if they exist
    if (bundles.isNotEmpty) {
      itemsByCategory['Bundles'] = bundles;
    }

    // Then add item categories
    for (final item in items) {
      final category = item['item_group'] ?? 'Uncategorized';
      itemsByCategory.putIfAbsent(category, () => []).add(item);
    }

    // Filter items based on search and category
    final filteredData = _getFilteredData(items, bundles);

    final isPhone = ResponsiveUtils.isPhone(context);
    final hideAnim = widget.hideAnimation;

    // Filter chips — collapsible on phones when scrolling
    Widget filterChips = const SizedBox.shrink();
    if (itemsByCategory.isNotEmpty) {
      final chipContent = Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            FilterChip(
              label: const Text('All'),
              selected: selectedCategory == null,
              onSelected: (selected) {
                setState(() { selectedCategory = null; });
              },
            ),
            const SizedBox(width: 8),
            ...itemsByCategory.keys.map(
              (category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: selectedCategory == category,
                  onSelected: (selected) {
                    setState(() { selectedCategory = selected ? category : null; });
                  },
                ),
              ),
            ),
          ],
        ),
      );

      filterChips = (isPhone && hideAnim != null)
          ? ClipRect(
              child: SizeTransition(
                sizeFactor: hideAnim,
                axisAlignment: -1.0,
                child: chipContent,
              ),
            )
          : chipContent;
    }

    return Column(
      children: [
        filterChips,

        const SizedBox(height: 16),

        // Customer selection warning
        if (selectedCustomer == null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please select a customer before adding items or bundles to cart',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Items grid
        Expanded(
          child: filteredData.isEmpty
              ? _buildEmptyState()
              : _buildItemsView(
                  filteredData,
                  itemsByCategory,
                  selectedCustomer,
                ),
        ),
      ],
    );
  }

  Widget _buildItemsView(
    List<Map<String, dynamic>> items,
    Map<String, List<Map<String, dynamic>>> itemsByCategory,
    Map<String, dynamic>? selectedCustomer,
  ) {
    final isPhone = ResponsiveUtils.isPhone(context);
    // If "All" is selected and no search, show categorized view
    if (selectedCategory == null && itemsByCategory.isNotEmpty) {
      return _buildCategorizedView(itemsByCategory, selectedCustomer);
    }

    // Otherwise show filtered grid
    final columns = ResponsiveUtils.getItemGridColumns(context);
    final spacing = ResponsiveUtils.getSpacing(context, small: 6, medium: 8, large: 8);
    final aspectRatio = ResponsiveUtils.getGridAspectRatio(context, compact: 1.3, normal: 1.5);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isPhone ? 10 : 16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns, // Responsive: 2-5 columns based on screen size
          crossAxisSpacing: isPhone ? 6 : spacing,
          mainAxisSpacing: isPhone ? 6 : spacing,
          childAspectRatio: aspectRatio,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isBundle = item['type'] == 'bundle';
          return isBundle
              ? _buildBundleCard(item, selectedCustomer)
              : _buildItemCard(item, selectedCustomer);
        },
      ),
    );
  }

  Widget _buildCategorizedView(
    Map<String, List<Map<String, dynamic>>> itemsByCategory,
    Map<String, dynamic>? selectedCustomer,
  ) {
    final isPhone = ResponsiveUtils.isPhone(context);
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: isPhone ? 10 : 16),
      itemCount: itemsByCategory.keys.length,
      itemBuilder: (context, index) {
        final category = itemsByCategory.keys.elementAt(index);
        final categoryItems = itemsByCategory[category]!;
        final isBundleCategory = category == 'Bundles';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isBundleCategory
                          ? Theme.of(context).colorScheme.tertiaryContainer
                          : Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isBundleCategory)
                          Icon(
                            Icons.local_offer,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onTertiaryContainer,
                          ),
                        if (isBundleCategory) const SizedBox(width: 4),
                        Text(
                          category,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: isBundleCategory
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.onTertiaryContainer
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${categoryItems.length} ${isBundleCategory ? 'bundles' : 'items'})',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Category items grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveUtils.getItemGridColumns(context), // Responsive columns
                crossAxisSpacing: ResponsiveUtils.getSpacing(context, small: 6, medium: 8, large: 8),
                mainAxisSpacing: ResponsiveUtils.getSpacing(context, small: 6, medium: 8, large: 8),
                childAspectRatio: ResponsiveUtils.getGridAspectRatio(context, compact: 1.0, normal: 1.4),
              ),
              itemCount: categoryItems.length,
              itemBuilder: (context, itemIndex) {
                final item = categoryItems[itemIndex];
                return isBundleCategory
                    ? _buildBundleCard(item, selectedCustomer)
                    : _buildItemCard(item, selectedCustomer);
              },
            ),

            const SizedBox(height: 20), // Space between categories
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredData(
    List<Map<String, dynamic>> items,
    List<Map<String, dynamic>> bundles,
  ) {
    List<Map<String, dynamic>> allData = [];

    // Add items with type marker
    allData.addAll(items.map((item) => {...item, 'type': 'item'}));

    // Add bundles with type marker
    allData.addAll(bundles.map((bundle) => {...bundle, 'type': 'bundle'}));

    var filtered = allData;

    // Filter by category
    if (selectedCategory != null) {
      if (selectedCategory == 'Bundles') {
        filtered = filtered.where((item) => item['type'] == 'bundle').toList();
      } else {
        filtered = filtered
            .where(
              (item) =>
                  item['type'] == 'item' &&
                  item['item_group'] == selectedCategory,
            )
            .toList();
      }
    }

    return filtered;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            selectedCategory != null
                ? 'No items or bundles found'
                : 'No items or bundles available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            selectedCategory != null
                ? 'Try selecting a different category'
                : 'Items and bundles will appear here when available',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBundleCard(
    Map<String, dynamic> bundle,
    Map<String, dynamic>? selectedCustomer,
  ) {
    final isPhone = ResponsiveUtils.isPhone(context);
    final canAddToCart = selectedCustomer != null;
    final hasFreeShipping = (bundle['free_shipping'] == true);

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: canAddToCart
            ? () {
                _showBundleSelection(bundle);
              }
            : () {
                _showCannotAddToCartMessage(selectedCustomer, false);
              },
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_offer,
                  size: isPhone ? 16 : 20,
                  color: !canAddToCart
                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                      : Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(height: 2),
                Text(
                  bundle['name'] ?? 'Unknown Bundle',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: !canAddToCart
                        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
                        : null,
                    fontWeight: FontWeight.bold,
                    fontSize: isPhone ? 12 : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${(bundle['price'] ?? 0.0).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: !canAddToCart
                        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
                        : Theme.of(context).colorScheme.tertiary,
                    fontSize: isPhone ? 12 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            if (hasFreeShipping)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_shipping, size: 12, color: Theme.of(context).colorScheme.onSecondaryContainer),
                      const SizedBox(width: 4),
                      Text(
                        'Free delivery',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(
    Map<String, dynamic> item,
    Map<String, dynamic>? selectedCustomer,
  ) {
    final isPhone = ResponsiveUtils.isPhone(context);
    // Extract stock information
    final stockQty = (item['actual_qty'] ?? 0).toDouble();
    final isOutOfStock = stockQty <= 0;
    // Debug: Log the stock values for comparison
    if (kDebugMode) {
      debugPrint(
        'Main item ${item['item_name']} - actual_qty: ${item['actual_qty']}, final stock: $stockQty',
      );
    }
    final canAddToCart = selectedCustomer != null && !isOutOfStock;

    // Determine stock color based on quantity
    Color stockColor;
    if (stockQty <= 0) {
      stockColor = Colors.red;
    } else if (stockQty <= 20) {
      stockColor = Colors.orange;
    } else {
      stockColor = Colors.green;
    }

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: canAddToCart
            ? () {
                ref.read(posNotifierProvider.notifier).addToCart(item);
                _showAddedToCartSnackbar(item);
              }
            : () {
                _showCannotAddToCartMessage(selectedCustomer, isOutOfStock);
              },
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Main card content
            Padding(
              padding: EdgeInsets.all(isPhone ? 4 : 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['item_name'] ?? item['name'] ?? 'Unknown Item',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: !canAddToCart
                          ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5)
                          : null,
                      fontWeight: FontWeight.bold,
                      fontSize: isPhone ? 12 : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${item['rate']?.toStringAsFixed(2) ?? '0.00'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: !canAddToCart
                          ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5)
                          : Theme.of(context).colorScheme.primary,
                      fontSize: isPhone ? 12 : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Small stock indicator in top-right corner
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: stockColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      stockQty <= 0 ? Icons.warning : Icons.inventory,
                      size: 10,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${stockQty.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddedToCartSnackbar(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['item_name']} added to cart'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCannotAddToCartMessage(
    Map<String, dynamic>? selectedCustomer,
    bool isOutOfStock,
  ) {
    String message;
    if (selectedCustomer == null) {
      message = 'Please select a customer first';
    } else if (isOutOfStock) {
      message = 'Item is out of stock';
    } else {
      message = 'Cannot add item to cart';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showBundleSelection(Map<String, dynamic> bundle) {
    final isPhone = ResponsiveUtils.isPhone(context);

    if (isPhone) {
      // Full-screen on phones so bundles aren't cramped
      showDialog(
        context: context,
        barrierDismissible: true,
        useSafeArea: false,
        builder: (context) => Dialog.fullscreen(
          child: BundleSelectionWidget(
            bundle: bundle,
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      );
    } else {
      // Constrained dialog on tablets
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
            child: BundleSelectionWidget(
              bundle: bundle,
              onCancel: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      );
    }
  }
}
