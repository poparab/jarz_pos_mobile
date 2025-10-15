import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/pos_notifier.dart';

class BundleSelectionWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic> bundle;
  final VoidCallback onCancel;
  final Function(Map<String, List<Map<String, dynamic>>>)? onBundleSelected;
  final Map<String, List<Map<String, dynamic>>>? initialSelections;
  final bool isEditing;

  const BundleSelectionWidget({
    super.key,
    required this.bundle,
    required this.onCancel,
    this.onBundleSelected,
    this.initialSelections,
    this.isEditing = false,
  });

  @override
  ConsumerState<BundleSelectionWidget> createState() =>
      _BundleSelectionWidgetState();
}

class _BundleSelectionWidgetState extends ConsumerState<BundleSelectionWidget> {
  // Track selected items for each group: groupName -> List<selectedItems>
  Map<String, List<Map<String, dynamic>>> selectedItems = {};

  @override
  void initState() {
    super.initState();
    _initializeSelections();
  }

  void _initializeSelections() {
    final itemGroups = widget.bundle['item_groups'] as List<dynamic>? ?? [];

    if (widget.initialSelections != null) {
      // Use provided initial selections (for editing)
      selectedItems = Map.from(widget.initialSelections!);
      // Ensure all groups exist even if not in initial selections
      for (final group in itemGroups) {
        final groupName = group['group_name'] as String;
        selectedItems.putIfAbsent(groupName, () => []);
      }
    } else {
      // Initialize empty selections for each group
      for (final group in itemGroups) {
        final groupName = group['group_name'] as String;
        selectedItems[groupName] = [];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemGroups = widget.bundle['item_groups'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bundle['name'] ?? 'Bundle Selection'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
        actions: [
          TextButton(
            onPressed: _canAddToCart() ? _addBundleToCart : null,
            child: Text(
              widget.isEditing ? 'Update Bundle' : 'Add to Cart',
              style: TextStyle(
                color: _canAddToCart()
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Bundle info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.bundle['name'] ?? 'Bundle',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.local_offer,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${(widget.bundle['price'] ?? 0.0).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Select items from each group below:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // Item groups list
          Expanded(
            child: itemGroups.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: itemGroups.length,
                    itemBuilder: (context, index) {
                      final group = itemGroups[index] as Map<String, dynamic>;
                      return _buildItemGroupCard(group);
                    },
                  ),
          ),

          // Progress indicator
          _buildProgressIndicator(itemGroups),
        ],
      ),
    );
  }

  Widget _buildItemGroupCard(Map<String, dynamic> group) {
    final groupName = group['group_name'] as String;
    final requiredQuantity = group['quantity'] as int;
    final availableItems = group['items'] as List<dynamic>? ?? [];
    final selectedForGroup = selectedItems[groupName] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    groupName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select $requiredQuantity items',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selectedForGroup.length == requiredQuantity
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedForGroup.length}/$requiredQuantity',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selectedForGroup.length == requiredQuantity
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Items grid
            if (availableItems.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Reduce columns for bigger cards
                  childAspectRatio: 1.2, // Make cards slightly taller
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: availableItems.length,
                itemBuilder: (context, itemIndex) {
                  final item =
                      availableItems[itemIndex] as Map<String, dynamic>;
                  return _buildItemCard(item, groupName);
                },
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No items available in this group',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, String groupName) {
    final selectedCount = _getSelectedCount(item, groupName);
    final canAddMore = _canAddMoreItems(groupName, item);
    final canRemove = selectedCount > 0;

    // Extract stock information (should now be consistent with main grid)
    final stockQty = (item['qty'] ?? item['actual_qty'] ?? 0).toDouble();
    // Debug: Log the stock values being received
    if (kDebugMode) {
      debugPrint(
        'Bundle item ${item['name']} - qty: ${item['qty']}, actual_qty: ${item['actual_qty']}, final stock: $stockQty',
      );
    }
    Color stockColor;
    if (stockQty <= 0) {
      stockColor = Colors.red;
    } else if (stockQty <= 20) {
      stockColor = Colors.orange;
    } else {
      stockColor = Colors.green;
    }

    final isOutOfStock = stockQty <= 0;
    final canActuallyAdd = canAddMore && !isOutOfStock;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: canActuallyAdd
            ? () => _addItemToSelection(item, groupName)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: selectedCount > 0
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Stack(
            children: [
              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Item name - bigger and centered
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        item['name'] ?? 'Unknown Item',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Price
                  Text(
                    '\$${(item['price'] ?? 0).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20), // Space for bottom controls
                ],
              ),

              // Stock indicator in top-right
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

              // Selection indicator in top-left if selected
              if (selectedCount > 0)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
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
                        Icon(Icons.check, size: 10, color: Colors.white),
                        const SizedBox(width: 2),
                        Text(
                          '$selectedCount',
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

              // Quantity controls at bottom if selected
              if (selectedCount > 0)
                Positioned(
                  bottom: 4,
                  left: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (canRemove)
                          GestureDetector(
                            onTap: () =>
                                _removeItemFromSelection(item, groupName),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.remove,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          '$selectedCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (canActuallyAdd)
                          GestureDetector(
                            onTap: () => _addItemToSelection(item, groupName),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(List<dynamic> itemGroups) {
    final totalGroups = itemGroups.length;
    final completedGroups = itemGroups.where((group) {
      final groupName = group['group_name'] as String;
      final requiredQuantity = group['quantity'] as int;
      final selectedForGroup = selectedItems[groupName] ?? [];
      return selectedForGroup.length == requiredQuantity;
    }).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '$completedGroups/$totalGroups groups complete',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: completedGroups == totalGroups
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: totalGroups > 0 ? completedGroups / totalGroups : 0,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
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
            'No item groups found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This bundle has no available item groups',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _addItemToSelection(Map<String, dynamic> item, String groupName) {
    setState(() {
      // Only send essential fields to backend - exclude stock qty fields
      final cleanItem = {
        'id': item['id'],
        'name': item['name'],
        'price': item['price'],
      };
      selectedItems[groupName] = [...(selectedItems[groupName] ?? []), cleanItem];
    });
  }

  void _removeItemFromSelection(Map<String, dynamic> item, String groupName) {
    setState(() {
      final currentList = selectedItems[groupName] ?? [];
      final itemIndex = currentList.indexWhere(
        (selected) => selected['id'] == item['id'],
      );
      if (itemIndex >= 0) {
        final newList = List<Map<String, dynamic>>.from(currentList);
        newList.removeAt(itemIndex);
        selectedItems[groupName] = newList;
      }
    });
  }

  bool _canAddToCart() {
    final itemGroups = widget.bundle['item_groups'] as List<dynamic>? ?? [];

    for (final group in itemGroups) {
      final groupName = group['group_name'] as String;
      final requiredQuantity = group['quantity'] as int;
      final selectedForGroup = selectedItems[groupName] ?? [];

      if (selectedForGroup.length < requiredQuantity) {
        return false;
      }
    }

    return true;
  }

  // Helper method to get selected count for an item in a group
  int _getSelectedCount(Map<String, dynamic> item, String groupName) {
    final selectedForGroup = selectedItems[groupName] ?? [];
    final itemId = item['id'] as String;
    return selectedForGroup
        .where((selected) => selected['id'] == itemId)
        .length;
  }

  // Helper method to check if more items can be added to a group
  bool _canAddMoreItems(String groupName, Map<String, dynamic> item) {
    final itemGroups = widget.bundle['item_groups'] as List<dynamic>? ?? [];
    final group = itemGroups.firstWhere(
      (g) => g['group_name'] == groupName,
      orElse: () => {},
    );
    final requiredQuantity = group['quantity'] as int? ?? 0;
    final selectedForGroup = selectedItems[groupName] ?? [];
    return selectedForGroup.length < requiredQuantity;
  }

  void _addBundleToCart() {
    if (_canAddToCart()) {
      if (widget.isEditing && widget.onBundleSelected != null) {
        // For editing, call the callback
        widget.onBundleSelected!(selectedItems);
      } else {
        // For new bundles, add to cart
        ref
            .read(posNotifierProvider.notifier)
            .addBundleToCart(widget.bundle, selectedItems);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.bundle['name']} added to cart'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Close the bundle selection
        widget.onCancel();
      }
    }
  }
}
