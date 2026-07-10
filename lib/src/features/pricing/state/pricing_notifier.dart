import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pricing_repository.dart';
import '../data/models/pricing_models.dart';

/// Loads all price lists (`get_price_lists`) and supports creating a new one.
final priceListsProvider =
    AsyncNotifierProvider<PriceListsNotifier, List<PriceListSummary>>(
      PriceListsNotifier.new,
    );

class PriceListsNotifier extends AsyncNotifier<List<PriceListSummary>> {
  PricingRepository get _repo => ref.read(pricingRepositoryProvider);

  @override
  Future<List<PriceListSummary>> build() => _repo.getPriceLists();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getPriceLists);
  }

  /// Creates a price list (managers only) then refreshes the list.
  Future<String> createPriceList(String name, {String currency = 'EGP'}) async {
    final created = await _repo.createPriceList(name, currency: currency);
    await refresh();
    return created;
  }
}

/// Loads a single price list's detail and supports inline edits (managers).
final priceListDetailProvider = AsyncNotifierProvider.family<
    PriceListDetailNotifier, PriceListDetail, String>(
  PriceListDetailNotifier.new,
);

class PriceListDetailNotifier
    extends FamilyAsyncNotifier<PriceListDetail, String> {
  PricingRepository get _repo => ref.read(pricingRepositoryProvider);

  @override
  Future<PriceListDetail> build(String priceList) =>
      _repo.getPriceListDetail(priceList);

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getPriceListDetail(arg));
  }

  Future<void> setCategoryPrice(String itemGroup, num rate) async {
    await _repo.setCategoryPrice(
      priceList: arg,
      itemGroup: itemGroup,
      rate: rate,
    );
    await refresh();
  }

  /// Upsert (rate != null) or remove (rate == null) a per-item override.
  Future<void> setItemOverride(String itemCode, num? rate) async {
    await _repo.setItemOverride(
      priceList: arg,
      itemCode: itemCode,
      rate: rate,
    );
    await refresh();
  }

  Future<void> assignCustomer(String customer) async {
    await _repo.assignCustomerToPriceList(customer: customer, priceList: arg);
    await refresh();
  }

  /// Clears a customer's direct assignment (reverts to group default).
  Future<void> unassignCustomer(String customer) async {
    await _repo.assignCustomerToPriceList(customer: customer, priceList: null);
    await refresh();
  }
}

/// The reverse (customer → effective prices) view.
final customerPricingProvider =
    FutureProvider.autoDispose.family<CustomerPricing, String>((ref, customer) {
  return ref.watch(pricingRepositoryProvider).getCustomerPricing(customer);
});

/// Item Groups that can carry a category price (for the "add category" flow).
final pricingCategoriesProvider =
    FutureProvider.autoDispose<List<PricingCategory>>((ref) {
  return ref.watch(pricingRepositoryProvider).listPricingCategories();
});
