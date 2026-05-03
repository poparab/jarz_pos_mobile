import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive_utils.dart';
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
  // Track selected items for each bundle section: groupKey -> List<selectedItems>
  Map<String, List<Map<String, dynamic>>> selectedItems = {};

  @override
  void initState() {
    super.initState();
    _initializeSelections();
  }

  void _initializeSelections() {
    final itemGroups = widget.bundle['item_groups'] as List<dynamic>? ?? [];

    if (widget.initialSelections != null) {
      final initialSelections = widget.initialSelections!;
      final normalizedSelections = <String, List<Map<String, dynamic>>>{};
      final usedLegacyGroupNames = <String>{};

      for (var index = 0; index < itemGroups.length; index++) {
        final group = Map<String, dynamic>.from(itemGroups[index] as Map);
        final groupKey = _groupKey(group, index);
        final groupName = _groupName(group);

        if (initialSelections.containsKey(groupKey)) {
          normalizedSelections[groupKey] = _cloneSelectionList(
            initialSelections[groupKey],
          );
          continue;
        }

        if (!usedLegacyGroupNames.contains(groupName) &&
            initialSelections.containsKey(groupName)) {
          normalizedSelections[groupKey] = _cloneSelectionList(
            initialSelections[groupName],
          );
          usedLegacyGroupNames.add(groupName);
          continue;
        }

        normalizedSelections[groupKey] = [];
      }

      selectedItems = normalizedSelections;
    } else {
      for (var index = 0; index < itemGroups.length; index++) {
        final group = Map<String, dynamic>.from(itemGroups[index] as Map);
        selectedItems[_groupKey(group, index)] = [];
      }
    }
  }

  List<Map<String, dynamic>> _cloneSelectionList(
    List<Map<String, dynamic>>? selections,
  ) {
    if (selections == null) {
      return [];
    }
    return selections
        .map<Map<String, dynamic>>((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  String _groupName(Map<String, dynamic> group) {
    final value = (group['group_name'] ?? group['item_group'] ?? group['title'])
        ?.toString()
        .trim();
    return (value == null || value.isEmpty) ? 'Group' : value;
  }

  String _groupKey(Map<String, dynamic> group, int fallbackIndex) {
    final rawKey = (group['group_key'] ?? group['group_id'] ?? group['name'])
        ?.toString()
        .trim();
    if (rawKey != null && rawKey.isNotEmpty) {
      return rawKey;
    }

    final rawIndex = _asInt(group['group_index'] ?? group['idx']) ??
        (fallbackIndex + 1);
    return '${_groupName(group)}::$rawIndex';
  }

  @override
  Widget build(BuildContext context) {
    final itemGroups = widget.bundle['item_groups'] as List<dynamic>? ?? [];
    final isPhone = ResponsiveUtils.isPhone(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bundle['name'] ?? 'Bundle Selection',
          style: isPhone ? const TextStyle(fontSize: 16) : null,
        ),
        toolbarHeight: isPhone ? 48 : null,
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
                fontSize: isPhone ? 13 : null,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Bundle info header — compact on phones
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isPhone ? 10 : 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: isPhone
                ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.bundle['name'] ?? 'Bundle',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.local_offer,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${(widget.bundle['price'] ?? 0.0).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Column(
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
                    padding: EdgeInsets.all(isPhone ? 8 : 16),
                    itemCount: itemGroups.length,
                    itemBuilder: (context, index) {
                      final group = itemGroups[index] as Map<String, dynamic>;
                      return _buildItemGroupCard(group, index);
                    },
                  ),
          ),

          // Progress indicator
          _buildProgressIndicator(itemGroups),
        ],
      ),
    );
  }

  Widget _buildItemGroupCard(Map<String, dynamic> group, int groupIndex) {
    final groupName = _groupName(group);
    final groupKey = _groupKey(group, groupIndex);
    final requiredQuantity = group['quantity'] as int;
    final availableItems = group['items'] as List<dynamic>? ?? [];
    final selectedForGroup = selectedItems[groupKey] ?? [];
    final isPhone = ResponsiveUtils.isPhone(context);

    return Card(
      margin: EdgeInsets.only(bottom: isPhone ? 10 : 16),
      child: Padding(
        padding: EdgeInsets.all(isPhone ? 10 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group header — wraps on small screens
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPhone ? 8 : 12,
                    vertical: isPhone ? 4 : 6,
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
                      fontSize: isPhone ? 12 : null,
                    ),
                  ),
                ),
                Text(
                  'Select $requiredQuantity items',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isPhone ? 12 : null,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPhone ? 6 : 8,
                    vertical: isPhone ? 2 : 4,
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
                      fontSize: isPhone ? 11 : null,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isPhone ? 10 : 16),

            // Items grid
            if (availableItems.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveUtils.getBundleGridColumns(context),
                  childAspectRatio: isPhone ? 1.0 : 1.2,
                  crossAxisSpacing: ResponsiveUtils.getSpacing(context, small: 4, medium: 8, large: 8),
                  mainAxisSpacing: ResponsiveUtils.getSpacing(context, small: 4, medium: 8, large: 8),
                ),
                itemCount: availableItems.length,
                itemBuilder: (context, itemIndex) {
                  final item =
                      availableItems[itemIndex] as Map<String, dynamic>;
                  return _buildItemCard(item, groupKey, groupName, requiredQuantity);
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

  Widget _buildItemCard(
    Map<String, dynamic> item,
    String groupKey,
    String groupName,
    int requiredQuantity,
  ) {
    final selectedCount = _getSelectedCount(item, groupKey);
    final canAddMore = _canAddMoreItems(groupKey, requiredQuantity, item);
    final canRemove = selectedCount > 0;
    final isPhone = ResponsiveUtils.isPhone(context);
    final itemName = _displayItemName(item);
    final itemPrice = _asDouble(item['price']);

    // Extract stock information (should now be consistent with main grid)
    final stockQty = _asDouble(item['qty'] ?? item['actual_qty']);
    // Debug: Log the stock values being received
    if (kDebugMode) {
      debugPrint(
        'Bundle item $itemName - qty: ${item['qty']}, actual_qty: ${item['actual_qty']}, final stock: $stockQty',
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
            ? () => _addItemToSelection(item, groupKey, groupName)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(isPhone ? 4 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: selectedCount > 0
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: stockColor,
                      borderRadius: BorderRadius.circular(10),
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
                  const Spacer(),
                  if (selectedCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
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
                          const Icon(Icons.check, size: 10, color: Colors.white),
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
                ],
              ),
              SizedBox(height: isPhone ? 8 : 10),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        itemName,
                        style: TextStyle(
                          fontSize: isPhone ? 10 : 13,
                          fontWeight: FontWeight.bold,
                          color: isOutOfStock
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isPhone ? 4 : 6),
                      Text(
                        '\$${itemPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: isPhone ? 10 : 11,
                          color: isOutOfStock
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: isPhone ? 32 : 36,
                child: selectedCount > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (canRemove)
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () =>
                                    _removeItemFromSelection(item, groupKey),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '$selectedCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (canActuallyAdd)
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () =>
                                    _addItemToSelection(item, groupKey, groupName),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayItemName(Map<String, dynamic> item) {
    final value = item['name'];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return 'Unknown Item';
  }

  double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value == null) {
      return null;
    }
    return int.tryParse(value.toString().trim()) ??
        double.tryParse(value.toString().trim())?.toInt();
  }

  Widget _buildProgressIndicator(List<dynamic> itemGroups) {
    final isPhone = ResponsiveUtils.isPhone(context);
    final totalGroups = itemGroups.length;
    var completedGroups = 0;
    for (var index = 0; index < itemGroups.length; index++) {
      final group = Map<String, dynamic>.from(itemGroups[index] as Map);
      final requiredQuantity = group['quantity'] as int;
      final selectedForGroup = selectedItems[_groupKey(group, index)] ?? [];
      if (selectedForGroup.length == requiredQuantity) {
        completedGroups += 1;
      }
    }

    return Container(
      padding: EdgeInsets.all(isPhone ? 10 : 16),
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

  void _addItemToSelection(
    Map<String, dynamic> item,
    String groupKey,
    String groupName,
  ) {
    setState(() {
      // Only send essential fields to backend - exclude stock qty fields
      final cleanItem = {
        'id': item['id'],
        'name': item['name'],
        'price': item['price'],
        'group_name': groupName,
      };
      selectedItems[groupKey] = [...(selectedItems[groupKey] ?? []), cleanItem];
    });
  }

  void _removeItemFromSelection(Map<String, dynamic> item, String groupKey) {
    setState(() {
      final currentList = selectedItems[groupKey] ?? [];
      final itemIndex = currentList.indexWhere(
        (selected) => selected['id'] == item['id'],
      );
      if (itemIndex >= 0) {
        final newList = List<Map<String, dynamic>>.from(currentList);
        newList.removeAt(itemIndex);
        selectedItems[groupKey] = newList;
      }
    });
  }

  bool _canAddToCart() {
    final itemGroups = widget.bundle['item_groups'] as List<dynamic>? ?? [];

    for (var index = 0; index < itemGroups.length; index++) {
      final group = Map<String, dynamic>.from(itemGroups[index] as Map);
      final groupKey = _groupKey(group, index);
      final requiredQuantity = group['quantity'] as int;
      final selectedForGroup = selectedItems[groupKey] ?? [];

      if (selectedForGroup.length < requiredQuantity) {
        return false;
      }
    }

    return true;
  }

  // Helper method to get selected count for an item in a group
  int _getSelectedCount(Map<String, dynamic> item, String groupKey) {
    final selectedForGroup = selectedItems[groupKey] ?? [];
    final itemId = item['id'] as String;
    return selectedForGroup
        .where((selected) => selected['id'] == itemId)
        .length;
  }

  // Helper method to check if more items can be added to a group
  bool _canAddMoreItems(
    String groupKey,
    int requiredQuantity,
    Map<String, dynamic> item,
  ) {
    final selectedForGroup = selectedItems[groupKey] ?? [];
    if (selectedForGroup.length >= requiredQuantity) return false;

    // Check stock limit: don't allow adding more than available inventory
    final stockQty = _asDouble(item['qty'] ?? item['actual_qty']);
    final selectedCount = _getSelectedCount(item, groupKey);
    if (selectedCount >= stockQty) return false;

    return true;
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
