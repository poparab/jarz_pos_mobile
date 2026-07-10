import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/user_service.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../data/models/pricing_models.dart';
import '../../state/pricing_notifier.dart';
import 'customer_pricing_screen.dart';
import 'price_list_detail_screen.dart';

/// The Price Lists page: a list of price lists (with their category rates) that
/// managers can edit and B2B reps can browse read-only. From here you can drill
/// into a list's detail or run the reverse (customer → price) lookup.
class PricingScreen extends ConsumerWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(priceListsProvider);
    final notifier = ref.read(priceListsProvider.notifier);
    final canEdit = ref.watch(canEditPricingProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Price Lists'),
        actions: [
          IconButton(
            tooltip: 'Customer pricing lookup',
            icon: const Icon(Icons.person_search),
            onPressed: () => _openCustomerLookup(context),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.refresh(),
          ),
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _promptCreate(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New price list'),
            )
          : null,
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          error: error,
          onRetry: notifier.refresh,
        ),
        data: (lists) {
          if (lists.isEmpty) {
            return const Center(child: Text('No price lists yet.'));
          }
          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: lists.length,
              itemBuilder: (context, i) => _PriceListCard(
                summary: lists[i],
                canEdit: canEdit,
              ),
            ),
          );
        },
      ),
    );
  }

  void _openCustomerLookup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CustomerPricingSearchScreen(),
      ),
    );
  }

  Future<void> _promptCreate(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final currencyController = TextEditingController(text: 'EGP');
    final messenger = ScaffoldMessenger.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New price list'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: currencyController,
              decoration: const InputDecoration(labelText: 'Currency'),
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
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (result != true) return;
    final name = nameController.text.trim();
    if (name.isEmpty) return;
    try {
      await ref.read(priceListsProvider.notifier).createPriceList(
            name,
            currency: currencyController.text.trim().isEmpty
                ? 'EGP'
                : currencyController.text.trim(),
          );
      messenger.showSnackBar(
        SnackBar(content: Text('Created "$name"')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not create price list: $e')),
      );
    }
  }
}

class _PriceListCard extends StatelessWidget {
  final PriceListSummary summary;
  final bool canEdit;
  const _PriceListCard({required this.summary, required this.canEdit});

  @override
  Widget build(BuildContext context) {
    final categoryLabel = summary.categories.isEmpty
        ? 'No category rates set'
        : summary.categories
            .map(
              (c) => '${c.itemGroup}: '
                  '${c.rate == null ? '—' : c.rate!.toStringAsFixed(2)}',
            )
            .join(' · ');
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(summary.currency.isEmpty ? '?' : summary.currency[0]),
        ),
        title: Row(
          children: [
            Flexible(child: Text(summary.name)),
            if (summary.isDefault)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Chip(
                  label: Text('Default'),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(categoryLabel),
            Text(
              '${summary.customerCount} customer(s) · ${summary.currency}'
              '${summary.enabled ? '' : ' · disabled'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PriceListDetailScreen(priceList: summary.name),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              'Could not load price lists.\n$error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
