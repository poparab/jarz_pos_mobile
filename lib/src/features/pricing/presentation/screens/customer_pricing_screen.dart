import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/pricing_models.dart';
import '../../data/pricing_repository.dart';
import '../../state/pricing_notifier.dart';

/// A company-customer search that opens the reverse (customer → price) view.
/// Reachable from the Price Lists page and from the B2B account screen.
class CustomerPricingSearchScreen extends ConsumerStatefulWidget {
  const CustomerPricingSearchScreen({super.key});

  @override
  ConsumerState<CustomerPricingSearchScreen> createState() =>
      _CustomerPricingSearchScreenState();
}

class _CustomerPricingSearchScreenState
    extends ConsumerState<CustomerPricingSearchScreen> {
  final _controller = TextEditingController();
  List<B2bCustomerResult> _results = const [];
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results =
          await ref.read(pricingRepositoryProvider).searchB2bCustomers(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.customerPricingTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: context.l10n.customerPricingSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _search(_controller.text.trim()),
                ),
              ),
              onSubmitted: (v) => _search(v.trim()),
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
          child: Text(context.l10n.customerPricingSearchFailed('$_error'),
              textAlign: TextAlign.center));
    }
    if (_results.isEmpty) {
      return Center(child: Text(context.l10n.customerPricingNoCustomers));
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final c = _results[i];
        return ListTile(
          leading: const Icon(Icons.business),
          title: Text(c.customerName.isEmpty ? c.customer : c.customerName),
          subtitle: Text(
            [
              if (c.customerGroup.isNotEmpty) c.customerGroup,
              if (c.defaultPriceList != null) 'List: ${c.defaultPriceList}',
            ].join(' · '),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CustomerPricingScreen(customer: c.customer),
            ),
          ),
        );
      },
    );
  }
}

/// The reverse / "double-entry" view: a customer's effective price list plus
/// each item-group / item rate and where it comes from (override / category /
/// none). Read-only for everyone.
class CustomerPricingScreen extends ConsumerWidget {
  final String customer;
  const CustomerPricingScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricingAsync = ref.watch(customerPricingProvider(customer));
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.customerPricingTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.pricingRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(customerPricingProvider(customer)),
          ),
        ],
      ),
      body: pricingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    context.l10n
                        .customerPricingLoadFailed(customer, '$error'),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(customerPricingProvider(customer)),
                  child: Text(context.l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
        data: (pricing) => ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.business),
                title: Text(pricing.customerName.isEmpty
                    ? pricing.customer
                    : pricing.customerName),
                subtitle: Text(
                  context.l10n.customerPricingGroupLine(
                    pricing.customerGroup.isEmpty
                        ? context.l10n.pricingDash
                        : pricing.customerGroup,
                    pricing.effectivePriceList ??
                        context.l10n.pricingNoneValue,
                    pricing.assignment,
                  ),
                ),
                isThreeLine: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(context.l10n.customerPricingEffective,
                style: Theme.of(context).textTheme.titleMedium),
            if (pricing.prices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(context.l10n.customerPricingNoResolved),
              )
            else
              for (final p in pricing.prices) _PriceRow(price: p),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final CustomerPrice price;
  const _PriceRow({required this.price});

  @override
  Widget build(BuildContext context) {
    final title = price.itemName ?? price.itemCode ?? price.itemGroup;
    final (icon, color) = switch (price.source) {
      'override' => (Icons.tune, Colors.deepPurple),
      'category' => (Icons.category, Colors.blue),
      _ => (Icons.help_outline, Colors.grey),
    };
    return Card(
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color),
        title: Text(title.isEmpty ? price.itemGroup : title),
        subtitle: Text(context.l10n
            .customerPricingSource(price.itemGroup, price.source)),
        trailing: Text(
          formatCurrency(context, price.rate),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
