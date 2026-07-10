import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pricing/data/models/pricing_models.dart';
import 'package:jarz_pos/src/features/pricing/data/pricing_repository.dart';
import 'package:jarz_pos/src/features/pricing/state/pricing_notifier.dart';

/// A fake repository that returns canned data and records the write calls.
class _FakePricingRepository extends PricingRepository {
  _FakePricingRepository() : super(Dio());

  int listCalls = 0;
  final List<String> categoryWrites = [];
  final List<String> overrideWrites = [];
  final List<String> createCalls = [];

  @override
  Future<List<PriceListSummary>> getPriceLists() async {
    listCalls++;
    return const [
      PriceListSummary(name: 'Companies', currency: 'EGP', customerCount: 2),
    ];
  }

  @override
  Future<String> createPriceList(String priceListName,
      {String currency = 'EGP'}) async {
    createCalls.add('$priceListName:$currency');
    return priceListName;
  }

  @override
  Future<PriceListDetail> getPriceListDetail(String priceList) async {
    return PriceListDetail(
      name: priceList,
      currency: 'EGP',
      categories: const [
        CategoryPrice(itemGroup: 'Medium', rate: 75, itemCount: 10),
      ],
    );
  }

  @override
  Future<void> setCategoryPrice({
    required String priceList,
    required String itemGroup,
    required num rate,
  }) async {
    categoryWrites.add('$priceList:$itemGroup:$rate');
  }

  @override
  Future<void> setItemOverride({
    required String priceList,
    required String itemCode,
    num? rate,
  }) async {
    overrideWrites.add('$priceList:$itemCode:$rate');
  }
}

ProviderContainer _container(_FakePricingRepository repo) {
  final c = ProviderContainer(
    overrides: [pricingRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('priceListsProvider', () {
    test('loads the price lists from the repository', () async {
      final repo = _FakePricingRepository();
      final container = _container(repo);

      final lists = await container.read(priceListsProvider.future);
      expect(lists.single.name, 'Companies');
      expect(repo.listCalls, 1);
    });

    test('createPriceList delegates then refreshes the list', () async {
      final repo = _FakePricingRepository();
      final container = _container(repo);
      await container.read(priceListsProvider.future);

      final name = await container
          .read(priceListsProvider.notifier)
          .createPriceList('Wholesale', currency: 'EGP');

      expect(name, 'Wholesale');
      expect(repo.createCalls.single, 'Wholesale:EGP');
      // The list was reloaded after creating (build called again).
      expect(repo.listCalls, greaterThanOrEqualTo(2));
    });
  });

  group('priceListDetailProvider (family)', () {
    test('loads the detail for the requested price list', () async {
      final repo = _FakePricingRepository();
      final container = _container(repo);

      final detail =
          await container.read(priceListDetailProvider('Companies').future);
      expect(detail.name, 'Companies');
      expect(detail.categories.single.itemGroup, 'Medium');
    });

    test('setCategoryPrice writes through to the repository', () async {
      final repo = _FakePricingRepository();
      final container = _container(repo);
      await container.read(priceListDetailProvider('Companies').future);

      await container
          .read(priceListDetailProvider('Companies').notifier)
          .setCategoryPrice('Medium', 90);

      expect(repo.categoryWrites.single, 'Companies:Medium:90');
    });

    test('setItemOverride with null rate removes the override', () async {
      final repo = _FakePricingRepository();
      final container = _container(repo);
      await container.read(priceListDetailProvider('Companies').future);

      await container
          .read(priceListDetailProvider('Companies').notifier)
          .setItemOverride('CHOC-M', null);

      expect(repo.overrideWrites.single, 'Companies:CHOC-M:null');
    });
  });
}
