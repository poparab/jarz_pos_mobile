import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/user_service.dart';
import '../../data/models/pricing_models.dart';
import '../../state/pricing_notifier.dart';
import 'customer_pricing_screen.dart';

/// Detail for a single price list:
///  (a) editable category (item-group) price rows — inline edit for managers,
///  (b) a COLLAPSED-by-default "Per-flavor overrides" section (managers can
///      add / edit / remove per-item overrides),
///  (c) the list of assigned customers (direct or via customer group).
/// B2B reps see everything read-only.
class PriceListDetailScreen extends ConsumerWidget {
  final String priceList;
  const PriceListDetailScreen({super.key, required this.priceList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(priceListDetailProvider(priceList));
    final notifier = ref.read(priceListDetailProvider(priceList).notifier);
    final canEdit = ref.watch(canEditPricingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(priceList),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: notifier.refresh,
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Could not load "$priceList".\n$error',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: notifier.refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (detail) => RefreshIndicator(
          onRefresh: notifier.refresh,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _CategoriesSection(
                detail: detail,
                canEdit: canEdit,
                onEdit: (row) => _editCategory(context, ref, row),
                onAdd: canEdit ? () => _addCategory(context, ref, detail) : null,
              ),
              const SizedBox(height: 8),
              _OverridesSection(
                detail: detail,
                canEdit: canEdit,
                onEdit: (row) => _editOverride(context, ref, row),
                onRemove: (row) => _removeOverride(context, ref, row),
                onAdd: canEdit ? () => _addOverride(context, ref) : null,
              ),
              const SizedBox(height: 8),
              _CustomersSection(
                detail: detail,
                canEdit: canEdit,
                onUnassign: (c) => _unassign(context, ref, c),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Category edits ────────────────────────────────────────────────────
  Future<void> _editCategory(
    BuildContext context,
    WidgetRef ref,
    CategoryPrice row,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final rate = await _promptRate(
      context,
      title: 'Set ${row.itemGroup} rate',
      initial: row.rate,
    );
    if (rate == null) return;
    await _run(
      messenger,
      () => ref
          .read(priceListDetailProvider(priceList).notifier)
          .setCategoryPrice(row.itemGroup, rate),
      success: '${row.itemGroup} rate updated',
    );
  }

  Future<void> _addCategory(
    BuildContext context,
    WidgetRef ref,
    PriceListDetail detail,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final categories = await ref.read(pricingCategoriesProvider.future);
    if (!context.mounted) return;
    final existing = detail.categories.map((c) => c.itemGroup).toSet();
    final options =
        categories.where((c) => !existing.contains(c.itemGroup)).toList();
    if (options.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('All categories already have a row.')),
      );
      return;
    }
    final chosen = await showModalBottomSheet<PricingCategory>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final c in options)
              ListTile(
                title: Text(c.itemGroup),
                subtitle: Text('${c.itemCount} item(s)'),
                onTap: () => Navigator.pop(ctx, c),
              ),
          ],
        ),
      ),
    );
    if (chosen == null || !context.mounted) return;
    final rate = await _promptRate(
      context,
      title: 'Set ${chosen.itemGroup} rate',
      initial: null,
    );
    if (rate == null) return;
    await _run(
      messenger,
      () => ref
          .read(priceListDetailProvider(priceList).notifier)
          .setCategoryPrice(chosen.itemGroup, rate),
      success: '${chosen.itemGroup} rate set',
    );
  }

  // ── Override edits ────────────────────────────────────────────────────
  Future<void> _editOverride(
    BuildContext context,
    WidgetRef ref,
    ItemOverride row,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final rate = await _promptRate(
      context,
      title: 'Override ${row.itemName.isEmpty ? row.itemCode : row.itemName}',
      initial: row.rate,
    );
    if (rate == null) return;
    await _run(
      messenger,
      () => ref
          .read(priceListDetailProvider(priceList).notifier)
          .setItemOverride(row.itemCode, rate),
      success: 'Override updated',
    );
  }

  Future<void> _removeOverride(
    BuildContext context,
    WidgetRef ref,
    ItemOverride row,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove override?'),
        content: Text(
          '${row.itemName.isEmpty ? row.itemCode : row.itemName} will fall '
          'back to its category rate.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(
      messenger,
      () => ref
          .read(priceListDetailProvider(priceList).notifier)
          .setItemOverride(row.itemCode, null),
      success: 'Override removed',
    );
  }

  Future<void> _addOverride(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final codeController = TextEditingController();
    final rateController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add override'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Item code'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(labelText: 'Rate'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final code = codeController.text.trim();
    final rate = num.tryParse(rateController.text.trim());
    if (code.isEmpty || rate == null) return;
    await _run(
      messenger,
      () => ref
          .read(priceListDetailProvider(priceList).notifier)
          .setItemOverride(code, rate),
      success: 'Override added',
    );
  }

  // ── Customer assignment ───────────────────────────────────────────────
  Future<void> _unassign(
    BuildContext context,
    WidgetRef ref,
    AssignedCustomer c,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unassign customer?'),
        content: Text(
          '${c.customerName.isEmpty ? c.customer : c.customerName} will revert '
          'to their customer group default.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Unassign'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(
      messenger,
      () => ref
          .read(priceListDetailProvider(priceList).notifier)
          .unassignCustomer(c.customer),
      success: 'Customer unassigned',
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────
  Future<num?> _promptRate(
    BuildContext context, {
    required String title,
    required num? initial,
  }) {
    final controller = TextEditingController(
      text: initial == null ? '' : initial.toString(),
    );
    return showDialog<num>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: const InputDecoration(labelText: 'Rate'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final v = num.tryParse(controller.text.trim());
              Navigator.pop(ctx, v);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Runs [action] and reports via a messenger captured BEFORE any await, so
  /// there is no BuildContext use across an async gap.
  Future<void> _run(
    ScaffoldMessengerState messenger,
    Future<void> Function() action, {
    required String success,
  }) async {
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(success)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }
}

class _CategoriesSection extends StatelessWidget {
  final PriceListDetail detail;
  final bool canEdit;
  final void Function(CategoryPrice row) onEdit;
  final VoidCallback? onAdd;
  const _CategoriesSection({
    required this.detail,
    required this.canEdit,
    required this.onEdit,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              'Category prices',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: onAdd == null
                ? null
                : IconButton(
                    tooltip: 'Add category',
                    icon: const Icon(Icons.add),
                    onPressed: onAdd,
                  ),
          ),
          if (detail.categories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No category rates set.'),
            )
          else
            for (final row in detail.categories)
              ListTile(
                dense: true,
                title: Text(row.itemGroup),
                subtitle: Text('${row.itemCount} item(s)'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      row.rate == null ? '—' : row.rate!.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (canEdit)
                      IconButton(
                        tooltip: 'Edit ${row.itemGroup} rate',
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => onEdit(row),
                      ),
                  ],
                ),
                onTap: canEdit ? () => onEdit(row) : null,
              ),
        ],
      ),
    );
  }
}

class _OverridesSection extends StatelessWidget {
  final PriceListDetail detail;
  final bool canEdit;
  final void Function(ItemOverride row) onEdit;
  final void Function(ItemOverride row) onRemove;
  final VoidCallback? onAdd;
  const _OverridesSection({
    required this.detail,
    required this.canEdit,
    required this.onEdit,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        // Collapsed by default: overrides are the exception, not the rule.
        initiallyExpanded: false,
        leading: const Icon(Icons.tune),
        title: const Text('Per-flavor overrides'),
        subtitle: Text('${detail.itemOverrides.length} override(s)'),
        childrenPadding: EdgeInsets.zero,
        children: [
          if (canEdit)
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add override'),
              onTap: onAdd,
            ),
          if (detail.itemOverrides.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No per-item overrides.'),
            )
          else
            for (final row in detail.itemOverrides)
              ListTile(
                dense: true,
                title: Text(row.itemName.isEmpty ? row.itemCode : row.itemName),
                subtitle: Text(row.itemGroup.isEmpty ? row.itemCode
                    : '${row.itemGroup} · ${row.itemCode}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      row.rate.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (canEdit) ...[
                      IconButton(
                        tooltip: 'Edit override',
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => onEdit(row),
                      ),
                      IconButton(
                        tooltip: 'Remove override',
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () => onRemove(row),
                      ),
                    ],
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _CustomersSection extends StatelessWidget {
  final PriceListDetail detail;
  final bool canEdit;
  final void Function(AssignedCustomer c) onUnassign;
  const _CustomersSection({
    required this.detail,
    required this.canEdit,
    required this.onUnassign,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              'Assigned customers',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text('${detail.customers.length} customer(s)'),
          ),
          if (detail.customers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No customers use this list.'),
            )
          else
            for (final c in detail.customers)
              ListTile(
                dense: true,
                leading: const Icon(Icons.business),
                title: Text(c.customerName.isEmpty ? c.customer : c.customerName),
                subtitle: Text(
                  c.assignment == 'group'
                      ? 'via group ${c.customerGroup}'
                      : 'direct assignment',
                ),
                trailing: (canEdit && c.assignment == 'direct')
                    ? IconButton(
                        tooltip: 'Unassign',
                        icon: const Icon(Icons.link_off, size: 18),
                        onPressed: () => onUnassign(c),
                      )
                    : null,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CustomerPricingScreen(customer: c.customer),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
