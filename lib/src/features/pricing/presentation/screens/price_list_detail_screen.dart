import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/localization/localized_formatters.dart';
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
            tooltip: context.l10n.pricingRefresh,
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
                Text(
                  context.userErrorMessage(error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: notifier.refresh,
                  child: Text(context.l10n.commonRetry),
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
    final l10n = context.l10n;
    final rate = await _promptRate(
      context,
      title: l10n.pricingSetRateTitle(row.itemGroup),
      initial: row.rate,
    );
    if (rate == null) return;
    await _run(
      messenger,
      () => ref
          .read(priceListDetailProvider(priceList).notifier)
          .setCategoryPrice(row.itemGroup, rate),
      success: l10n.pricingRateUpdated(row.itemGroup),
      l10n: l10n,
    );
  }

  Future<void> _addCategory(
    BuildContext context,
    WidgetRef ref,
    PriceListDetail detail,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final categories = await ref.read(pricingCategoriesProvider.future);
    if (!context.mounted) return;
    final existing = detail.categories.map((c) => c.itemGroup).toSet();
    final options =
        categories.where((c) => !existing.contains(c.itemGroup)).toList();
    if (options.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.pricingAllCategoriesHaveRows)),
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
                subtitle: Text(l10n.pricingItemCount(c.itemCount)),
                onTap: () => Navigator.pop(ctx, c),
              ),
          ],
        ),
      ),
    );
    if (chosen == null || !context.mounted) return;
    final rate = await _promptRate(
      context,
      title: l10n.pricingSetRateTitle(chosen.itemGroup),
      initial: null,
    );
    if (rate == null) return;
    await _run(
      messenger,
      () => ref
          .read(priceListDetailProvider(priceList).notifier)
          .setCategoryPrice(chosen.itemGroup, rate),
      success: l10n.pricingRateSet(chosen.itemGroup),
      l10n: l10n,
    );
  }

  // ── Override edits ────────────────────────────────────────────────────
  Future<void> _editOverride(
    BuildContext context,
    WidgetRef ref,
    ItemOverride row,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final rate = await _promptRate(
      context,
      title: l10n.pricingOverrideTitle(
          row.itemName.isEmpty ? row.itemCode : row.itemName),
      initial: row.rate,
    );
    if (rate == null) return;
    await _run(
      messenger,
      () => ref
          .read(priceListDetailProvider(priceList).notifier)
          .setItemOverride(row.itemCode, rate),
      success: l10n.pricingOverrideUpdated,
      l10n: l10n,
    );
  }

  Future<void> _removeOverride(
    BuildContext context,
    WidgetRef ref,
    ItemOverride row,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.pricingRemoveOverrideTitle),
        content: Text(
          l10n.pricingRemoveOverrideBody(
              row.itemName.isEmpty ? row.itemCode : row.itemName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.pricingRemove),
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
      success: l10n.pricingOverrideRemoved,
      l10n: l10n,
    );
  }

  Future<void> _addOverride(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final codeController = TextEditingController();
    final rateController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.pricingAddOverride),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.pricingItemCode),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(labelText: l10n.pricingRateField),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonSave),
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
      success: l10n.pricingOverrideAdded,
      l10n: l10n,
    );
  }

  // ── Customer assignment ───────────────────────────────────────────────
  Future<void> _unassign(
    BuildContext context,
    WidgetRef ref,
    AssignedCustomer c,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.pricingUnassignTitle),
        content: Text(
          l10n.pricingUnassignBody(
              c.customerName.isEmpty ? c.customer : c.customerName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.pricingUnassign),
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
      success: l10n.pricingCustomerUnassigned,
      l10n: l10n,
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
          decoration:
              InputDecoration(labelText: context.l10n.pricingRateField),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              final v = num.tryParse(controller.text.trim());
              Navigator.pop(ctx, v);
            },
            child: Text(context.l10n.commonSave),
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
    required AppLocalizations l10n,
  }) async {
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(success)));
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text(userErrorMessageFor(l10n, e))));
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
              context.l10n.pricingCategoryPrices,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: onAdd == null
                ? null
                : IconButton(
                    tooltip: context.l10n.pricingAddCategory,
                    icon: const Icon(Icons.add),
                    onPressed: onAdd,
                  ),
          ),
          if (detail.categories.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.l10n.pricingNoCategoryRates),
            )
          else
            for (final row in detail.categories)
              ListTile(
                dense: true,
                title: Text(row.itemGroup),
                subtitle: Text(context.l10n.pricingItemCount(row.itemCount)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      row.rate == null
                          ? context.l10n.pricingDash
                          : formatCurrency(context, row.rate!),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (canEdit)
                      IconButton(
                        tooltip:
                            context.l10n.pricingEditRateTooltip(row.itemGroup),
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
        title: Text(context.l10n.pricingPerFlavorOverrides),
        subtitle: Text(
            context.l10n.pricingOverrideCount(detail.itemOverrides.length)),
        childrenPadding: EdgeInsets.zero,
        children: [
          if (canEdit)
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(context.l10n.pricingAddOverride),
              onTap: onAdd,
            ),
          if (detail.itemOverrides.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.l10n.pricingNoOverrides),
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
                      formatCurrency(context, row.rate),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (canEdit) ...[
                      IconButton(
                        tooltip: context.l10n.pricingEditOverride,
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => onEdit(row),
                      ),
                      IconButton(
                        tooltip: context.l10n.pricingRemoveOverride,
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
              context.l10n.pricingAssignedCustomers,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
                context.l10n.pricingCustomerCount(detail.customers.length)),
          ),
          if (detail.customers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.l10n.pricingNoCustomers),
            )
          else
            for (final c in detail.customers)
              ListTile(
                dense: true,
                leading: const Icon(Icons.business),
                title: Text(c.customerName.isEmpty ? c.customer : c.customerName),
                subtitle: Text(
                  c.assignment == 'group'
                      ? context.l10n.pricingViaGroup(c.customerGroup)
                      : context.l10n.pricingDirectAssignment,
                ),
                trailing: (canEdit && c.assignment == 'direct')
                    ? IconButton(
                        tooltip: context.l10n.pricingUnassign,
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
