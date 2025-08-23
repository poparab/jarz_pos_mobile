import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../../core/ui/loading_overlay.dart';
import '../data/models/pos_cart_item.dart';
import '../data/repositories/pos_repository.dart';
import '../domain/models/delivery_slot.dart';

// State for the POS screen
class PosState {
  final List<Map<String, dynamic>> profiles;
  final Map<String, dynamic>? selectedProfile;
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> bundles;
  final List<Map<String, dynamic>> cartItems;
  final Map<String, dynamic>? selectedCustomer;
  final DeliverySlot? selectedDeliverySlot;
  final bool isLoading;
  final String? error;

  PosState({
    this.profiles = const [],
    this.selectedProfile,
    this.items = const [],
    this.bundles = const [],
    this.cartItems = const [],
    this.selectedCustomer,
    this.selectedDeliverySlot,
    this.isLoading = false,
    this.error,
  });

  PosState copyWith({
    List<Map<String, dynamic>>? profiles,
    Map<String, dynamic>? selectedProfile,
    List<Map<String, dynamic>>? items,
    List<Map<String, dynamic>>? bundles,
    List<Map<String, dynamic>>? cartItems,
    Map<String, dynamic>? selectedCustomer,
    DeliverySlot? selectedDeliverySlot,
    bool? isLoading,
    String? error,
    bool clearSelectedCustomer = false,
    bool clearSelectedDeliverySlot = false,
    bool clearError = false,
  }) {
    return PosState(
      profiles: profiles ?? this.profiles,
      selectedProfile: selectedProfile ?? this.selectedProfile,
      items: items ?? this.items,
      bundles: bundles ?? this.bundles,
      cartItems: cartItems ?? this.cartItems,
      selectedCustomer: clearSelectedCustomer
          ? null
          : (selectedCustomer ?? this.selectedCustomer),
      selectedDeliverySlot: clearSelectedDeliverySlot
          ? null
          : (selectedDeliverySlot ?? this.selectedDeliverySlot),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  double get cartTotal {
    return cartItems.fold(0.0, (total, item) {
      final price = ((item['rate'] ?? 0) as num).toDouble();
      final quantity = ((item['quantity'] ?? 1) as num).toDouble();
      return total + (price * quantity);
    });
  }

  double get shippingCost {
    if (selectedCustomer != null &&
        selectedCustomer!['delivery_income'] != null &&
        selectedCustomer!['delivery_income'] > 0) {
      return (selectedCustomer!['delivery_income'] as num).toDouble();
    }
    return 0.0;
  }

  double get totalWithShipping {
    return cartTotal + shippingCost;
  }

  int get cartItemCount {
    return cartItems.fold(0, (total, item) {
      final quantity = (item['quantity'] ?? 1) as int;
      return total + quantity;
    });
  }
}

class PosNotifier extends StateNotifier<PosState> {
  PosNotifier(this._repository) : super(PosState());

  final PosRepository _repository;

  Future<void> loadProfiles() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profiles = await _repository.getPosProfiles();

      // If there's only one profile, automatically select it
      if (profiles.length == 1) {
        final profile = profiles.first;
        final profileName = profile['name'] as String;

        // Load both items and bundles for the single profile
        final futures = await Future.wait([
          _repository.getItems(profileName),
          _repository.getBundles(profileName),
        ]);

        final items = futures[0];
        final bundles = futures[1];

        state = state.copyWith(
          profiles: profiles,
          selectedProfile: profile,
          items: items,
          bundles: bundles,
          isLoading: false,
        );
      } else {
        state = state.copyWith(profiles: profiles, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        clearError: false,
      );
    }
  }

  Future<void> selectProfile(Map<String, dynamic> profile) async {
    // Optimistically set selected profile to prevent redirect loop
    state = state.copyWith(selectedProfile: profile, isLoading: true, clearError: true);
    try {
      final profileName = profile['name'] as String;

      // Load both items and bundles for the selected profile
      final futures = await Future.wait([
        _repository.getItems(profileName),
        _repository.getBundles(profileName),
      ]);

      final items = futures[0];
      final bundles = futures[1];

      state = state.copyWith(
        items: items,
        bundles: bundles,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        clearError: false,
      );
    }
  }

  void addToCart(Map<String, dynamic> item) {
    final existingItemIndex = state.cartItems.indexWhere(
      (cartItem) => cartItem['item_code'] == item['name'],
    );

    List<Map<String, dynamic>> updatedCart;
    if (existingItemIndex >= 0) {
      // Update quantity of existing item
      updatedCart = List.from(state.cartItems);
      final existingItem = Map<String, dynamic>.from(
        updatedCart[existingItemIndex],
      );
      existingItem['quantity'] = (existingItem['quantity'] ?? 1) + 1;
      updatedCart[existingItemIndex] = existingItem;

      if (kDebugMode) {
        debugPrint('📦 UPDATED EXISTING ITEM IN CART:');
        debugPrint('   Item Code: ${item['name']}');
        debugPrint('   New Quantity: ${existingItem['quantity']}');
      }
    } else {
      // Add new item to cart
      final cartItem = {
        'item_code': item['name'],
        'item_name': item['item_name'],
        'rate': item['rate'],
        'quantity': 1,
        'type': 'item', // CRITICAL: Mark as regular item
      };
      updatedCart = [...state.cartItems, cartItem];

      if (kDebugMode) {
        debugPrint('📦 ADDED NEW ITEM TO CART:');
        debugPrint('   Item Code: ${item['name']}');
        debugPrint('   Item Name: ${item['item_name']}');
        debugPrint('   Rate: ${item['rate']}');
        debugPrint('   Type: item');
      }
    }

    state = state.copyWith(cartItems: updatedCart);
  }

  void addBundleToCart(
    Map<String, dynamic> bundle,
    Map<String, List<Map<String, dynamic>>> selectedItems,
  ) {
    final bundleCartItem = {
      'item_code':
          bundle['id'], // This will be sent as item_code but will be overridden by bundle_id in createInvoice
      'item_name': bundle['name'],
      'rate': bundle['price'],
      'quantity': 1,
      'type': 'bundle', // CRITICAL: Mark as bundle
      'bundle_details': {
        'bundle_id': bundle['id'], // CRITICAL: Store the actual bundle ID
        'selected_items': selectedItems,
        'bundle_info': bundle, // Store full bundle info for editing
      },
    };

    if (kDebugMode) {
      debugPrint('🎁 ADDING BUNDLE TO CART:');
      debugPrint('   Bundle ID: ${bundle['id']}');
      debugPrint('   Bundle Name: ${bundle['name']}');
      debugPrint('   Bundle Price: ${bundle['price']}');
      debugPrint('   Selected Items: ${selectedItems.length} groups');
      debugPrint('   Cart Item Structure: $bundleCartItem');
    }

    final updatedCart = [...state.cartItems, bundleCartItem];
    state = state.copyWith(cartItems: updatedCart);
  }

  void updateBundleInCart(
    int cartIndex,
    Map<String, List<Map<String, dynamic>>> newSelectedItems,
  ) {
    final updatedCart = [...state.cartItems];
    final bundleItem = updatedCart[cartIndex];

    if (bundleItem['type'] == 'bundle') {
      bundleItem['bundle_details']['selected_items'] = newSelectedItems;
      state = state.copyWith(cartItems: updatedCart);
    }
  }

  void updateCartItemQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(index);
      return;
    }

    final updatedCart = List<Map<String, dynamic>>.from(state.cartItems);
    updatedCart[index] = {...updatedCart[index], 'quantity': newQuantity};
    state = state.copyWith(cartItems: updatedCart);
  }

  void removeFromCart(int index) {
    final updatedCart = List<Map<String, dynamic>>.from(state.cartItems);
    updatedCart.removeAt(index);
    state = state.copyWith(cartItems: updatedCart);
  }

  void selectCustomer(Map<String, dynamic> customer) {
    // Simply select the customer without adding shipping to cart
    // Shipping will be handled separately in the UI total calculation
    state = state.copyWith(selectedCustomer: customer);
  }

  void setDeliverySlot(DeliverySlot? slot) {
    state = state.copyWith(selectedDeliverySlot: slot);
  }

  void unselectCustomer() {
    if (kDebugMode) {
      debugPrint('unselectCustomer called - clearing customer state'); // Debug
    }
    final oldCustomer = state.selectedCustomer;
    if (kDebugMode) {
      debugPrint(
        'Previous customer: ${oldCustomer?['customer_name'] ?? 'None'}',
      ); // Debug
    }

    // Simply clear the customer - no need to modify cart since shipping is not in cart anymore
    state = state.copyWith(clearSelectedCustomer: true);

    if (kDebugMode) {
      debugPrint(
        'Customer state after clearing: ${state.selectedCustomer == null ? 'null' : 'still has customer'}',
      ); // Debug
    }
  }

  void clearCart() {
    // Simply clear the cart - shipping is handled separately, not as cart items
    state = state.copyWith(cartItems: []);
  }

  Future<void> checkout([WidgetRef? ref]) async {
    if (state.cartItems.isEmpty) {
      state = state.copyWith(error: 'Cart is empty', clearError: false);
      return;
    }

    if (state.selectedProfile == null) {
      state = state.copyWith(error: 'No profile selected', clearError: false);
      return;
    }

    if (kDebugMode) {
      debugPrint('🛒 STARTING CHECKOUT PROCESS (no auto-print):');
      debugPrint('   Cart Items Count: ${state.cartItems.length}');
      debugPrint('   Customer: ${state.selectedCustomer?['customer_name'] ?? 'Walking Customer'}');
      debugPrint('   POS Profile: ${state.selectedProfile?['name'] ?? 'No Profile Selected'}');
    }

    for (int i = 0; i < state.cartItems.length; i++) {
      final item = state.cartItems[i];
      final type = item['type'] ?? 'unknown';
      if (kDebugMode) {
        debugPrint('   Cart Item ${i + 1}: ${item['item_code']} - Type: $type, Qty: ${item['quantity']}, Rate: ${item['rate']}');
        if (type == 'bundle') {
          debugPrint('      Bundle ID: ${item['bundle_details']?['bundle_id']}');
        }
      }
    }

    ref?.loading.show('Creating invoice...');

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Always create invoice without printing; printing moved to Kanban / separate action
      final invoice = await _repository.createInvoice(
        posProfile: state.selectedProfile!['name'],
        items: state.cartItems,
        customer: state.selectedCustomer,
        requiredDeliveryDatetime: state.selectedDeliverySlot?.datetime,
      );

      if (kDebugMode) {
        debugPrint('✅ CHECKOUT SUCCESS (no auto-print):');
        debugPrint('   Invoice Name: ${invoice['name'] ?? invoice['invoice_name']}');
        debugPrint('   Grand Total: ${invoice['grand_total']}');
      }

      ref?.loading.hide();

      state = state.copyWith(
        cartItems: [],
        clearSelectedCustomer: true,
        clearSelectedDeliverySlot: true,
        isLoading: false,
      );

  // TODO (Wallet/InstaPay Reference Capture):
  // When adding a payment step (wallet / instapay) after invoice creation,
  // prompt user for reference number & date, then call repository.payInvoice
  // with those fields. Cash payments won't require references.
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ CHECKOUT ERROR: $e');
      }
      ref?.loading.hide();
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        clearError: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void addCartPosItem(PosCartItem item) {
    final cartEntry = {
      'item_code': item.itemCode,
      'item_name': item.itemCode,
      'rate': item.rate,
      'quantity': item.quantity,
      'type': item.isBundle ? 'bundle' : 'item',
      if (item.priceListRate != null) 'price_list_rate': item.priceListRate,
      if (item.discountAmount != null) 'discount_amount': item.discountAmount,
      if (item.discountPercentage != null) 'discount_percentage': item.discountPercentage,
    };
    final updated = [...state.cartItems, cartEntry];
    state = state.copyWith(cartItems: updated);
  }
}

final posNotifierProvider = StateNotifierProvider<PosNotifier, PosState>((ref) {
  final repository = ref.watch(posRepositoryProvider);
  return PosNotifier(repository);
});

// Territories provider for dropdown selection
final territoriesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String?>((
      ref,
      search,
    ) async {
      final repository = ref.watch(posRepositoryProvider);
      return repository.getTerritories(search: search);
    });

// Customer creation provider
final createCustomerProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>((
      ref,
      customerData,
    ) async {
      final repository = ref.watch(posRepositoryProvider);
      return repository.createCustomer(
        customerName: customerData['customerName']!,
        mobileNumber: customerData['mobileNumber']!,
        territoryId: customerData['territoryId']!,
        detailedAddress: customerData['detailedAddress']!,
        locationLink: customerData['locationLink'],
      );
    });

// Provider for customer search
final customerSearchProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      query,
    ) async {
      if (query.isEmpty) return [];

      final repository = ref.watch(posRepositoryProvider);
      return await repository.searchCustomers(query);
    });
