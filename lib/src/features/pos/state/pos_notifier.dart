import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';

import '../data/models/draft_cart.dart';
import '../data/models/pos_cart_item.dart';
import '../data/repositories/draft_cart_repository.dart';
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
  final Map<String, dynamic>? selectedSalesPartner;
  final List<DeliverySlot>
  deliverySlots; // Cached delivery slots for current profile
  final bool isLoading;
  final String? error;
  // When true, this order is for pickup (no delivery fee or slot required)
  final bool isPickup;
  final bool isAmendmentDraft;
  final String? amendmentSourceInvoiceId;
  // Source invoice grand total captured when the amendment draft started.
  // Used to guard against submitting an empty or badly loaded cart.
  final double? amendmentSourceGrandTotal;
  // ── Draft (multi-cart) state ───────────────────────────────────────
  /// All persisted draft carts (summaries only, sorted newest-first).
  final List<DraftCartSummary> drafts;

  /// The draft id currently loaded into the active cart, or null for an
  /// unsaved "new" cart.
  final String? currentDraftId;

  /// True when the active cart has changes not yet persisted to Hive.
  final bool draftDirty;

  PosState({
    this.profiles = const [],
    this.selectedProfile,
    this.items = const [],
    this.bundles = const [],
    this.cartItems = const [],
    this.selectedCustomer,
    this.selectedDeliverySlot,
    this.selectedSalesPartner,
    this.deliverySlots = const [],
    this.isLoading = false,
    this.error,
    this.isPickup = false,
    this.isAmendmentDraft = false,
    this.amendmentSourceInvoiceId,
    this.amendmentSourceGrandTotal,
    this.drafts = const [],
    this.currentDraftId,
    this.draftDirty = false,
  });

  PosState copyWith({
    List<Map<String, dynamic>>? profiles,
    Map<String, dynamic>? selectedProfile,
    List<Map<String, dynamic>>? items,
    List<Map<String, dynamic>>? bundles,
    List<Map<String, dynamic>>? cartItems,
    Map<String, dynamic>? selectedCustomer,
    DeliverySlot? selectedDeliverySlot,
    Map<String, dynamic>? selectedSalesPartner,
    bool? isLoading,
    String? error,
    bool clearSelectedCustomer = false,
    bool clearSelectedDeliverySlot = false,
    bool clearSelectedSalesPartner = false,
    bool clearError = false,
    bool clearDeliverySlots = false,
    List<DeliverySlot>? deliverySlots,
    bool? isPickup,
    bool? isAmendmentDraft,
    String? amendmentSourceInvoiceId,
    bool clearAmendmentSourceInvoiceId = false,
    double? amendmentSourceGrandTotal,
    // Draft fields
    List<DraftCartSummary>? drafts,
    String? currentDraftId,
    bool clearCurrentDraftId = false,
    bool? draftDirty,
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
      selectedSalesPartner: clearSelectedSalesPartner
          ? null
          : (selectedSalesPartner ?? this.selectedSalesPartner),
      deliverySlots: clearDeliverySlots
          ? const []
          : (deliverySlots ?? this.deliverySlots),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isPickup: isPickup ?? this.isPickup,
      isAmendmentDraft: isAmendmentDraft ?? this.isAmendmentDraft,
      amendmentSourceInvoiceId: clearAmendmentSourceInvoiceId
          ? null
          : (amendmentSourceInvoiceId ?? this.amendmentSourceInvoiceId),
      amendmentSourceGrandTotal: clearAmendmentSourceInvoiceId
          ? null
          : (amendmentSourceGrandTotal ?? this.amendmentSourceGrandTotal),
      drafts: drafts ?? this.drafts,
      currentDraftId: clearCurrentDraftId
          ? null
          : (currentDraftId ?? this.currentDraftId),
      draftDirty: draftDirty ?? this.draftDirty,
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
    // If a Sales Partner is selected, we suppress delivery income entirely
    if (selectedSalesPartner != null) return 0.0;
    // Pickup mode waives delivery
    if (isPickup) return 0.0;
    // If any bundle in cart has free_shipping=true, waive delivery income client-side
    try {
      final hasFreeShippingBundle = cartItems.any((ci) {
        if (ci['type'] != 'bundle') return false;
        final info =
            ci['bundle_details']?['bundle_info'] as Map<String, dynamic>?;
        final fs = info?['free_shipping'];
        return (fs == true) ||
            (fs is num && fs != 0) ||
            (fs?.toString() == '1');
      });
      if (hasFreeShippingBundle) return 0.0;
    } catch (_) {}
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
  PosNotifier(this._repository, this._draftRepo) : super(PosState()) {
    _hydrateLocalDrafts();
  }

  final PosRepository _repository;
  final DraftCartRepository _draftRepo;
  bool _isPrefetchingSlots = false; // Guard against concurrent prefetch

  // ── Draft auto-save debounce ──────────────────────────────────────────
  static const _kAutoSaveDebounce = Duration(milliseconds: 400);
  Timer? _autoSaveTimer;
  // True while startAmendmentDraft is running (between state-clear and final state-set).
  // Prevents the autosave timer from persisting a half-built amendment cart to Hive.
  bool _amendmentSetupInProgress = false;

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  // ── Draft: hydration from Hive ────────────────────────────────────────
  Future<void> _hydrateLocalDrafts() async {
    try {
      final drafts = await _draftRepo.loadAll();
      state = state.copyWith(
        drafts: drafts.map(DraftCartSummary.from).toList(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ PosNotifier: failed to hydrate drafts: $e');
      }
    }
  }

  // ── Draft: trigger debounced auto-save ───────────────────────────────

  /// Exposes [_persistCurrentCart] for unit tests only.
  /// Allows tests to simulate the autosave timer firing at a specific point.
  @visibleForTesting
  Future<void> testInvokePersistCurrentCart() => _persistCurrentCart();

  /// Schedule an auto-save of the current cart.
  void _autoSaveDebounced() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(_kAutoSaveDebounce, _persistCurrentCart);
  }

  Future<void> _persistCurrentCart() async {
    // Amendment drafts are also persisted so amendment context survives app restart.
    // Guard 1: never persist while startAmendmentDraft is mid-flight (race window).
    if (_amendmentSetupInProgress) {
      if (kDebugMode) {
        debugPrint(
          '[PosNotifier] _persistCurrentCart: skipped — amendment setup in progress',
        );
      }
      return;
    }
    // Guard 2: never persist while the state signals a loading operation.
    if (state.isLoading) {
      if (kDebugMode) {
        debugPrint(
          '[PosNotifier] _persistCurrentCart: skipped — state.isLoading=true',
        );
      }
      return;
    }
    // Guard 3: don't poison Hive with a broken amendment draft.
    if (state.isAmendmentDraft) {
      final hasCatalogMiss = state.cartItems.any(
        (i) => i['_bundle_catalog_miss'] == true,
      );
      final missingCustomer =
          state.selectedCustomer == null &&
          state.amendmentSourceInvoiceId != null;
      if (hasCatalogMiss || missingCustomer) {
        if (kDebugMode) {
          debugPrint(
            '[PosNotifier] _persistCurrentCart: skipped — broken amendment draft '
            '(catalog_miss=$hasCatalogMiss, missing_customer=$missingCustomer). '
            'Will NOT persist to Hive.',
          );
        }
        return;
      }
    }
    final cartItems = state.cartItems;
    // Don't create a draft for a completely empty cart with no id yet.
    if (cartItems.isEmpty && state.currentDraftId == null) return;

    final now = DateTime.now();
    final id = state.currentDraftId ?? const Uuid().v4();
    final label = DraftCart.buildLabel(
      customer: state.selectedCustomer,
      cartItems: cartItems,
      at: now,
    );
    final draft = DraftCart(
      id: id,
      label: label,
      cartItems: List<Map<String, dynamic>>.from(cartItems),
      customer: state.selectedCustomer,
      salesPartner: state.selectedSalesPartner,
      isPickup: state.isPickup,
      createdAt: now,
      updatedAt: now,
      amendmentSourceInvoiceId: state.amendmentSourceInvoiceId,
      amendmentSourceGrandTotal: state.amendmentSourceGrandTotal,
    );

    try {
      await _draftRepo.upsert(draft);
      final allDrafts = await _draftRepo.loadAll();
      state = state.copyWith(
        currentDraftId: id,
        drafts: allDrafts.map(DraftCartSummary.from).toList(),
        draftDirty: false,
      );
    } on DraftLimitReachedException {
      // Surface to the caller via a state error so the UI can show a snackbar.
      state = state.copyWith(error: 'draft_limit_reached', clearError: false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ PosNotifier: auto-save failed: $e');
      }
    }
  }

  // ── Draft: public API ─────────────────────────────────────────────────

  /// Switch the active cart to a new empty cart (unsaved).
  /// Auto-saves the current cart first if there are unsaved changes.
  void newDraft() {
    if (state.draftDirty) {
      _autoSaveTimer?.cancel();
      _persistCurrentCart();
    }
    state = state.copyWith(
      cartItems: const [],
      clearSelectedCustomer: true,
      clearSelectedDeliverySlot: true,
      clearSelectedSalesPartner: true,
      clearDeliverySlots: true,
      isPickup: false,
      clearCurrentDraftId: true,
      draftDirty: false,
      isAmendmentDraft: false,
      clearAmendmentSourceInvoiceId: true,
    );
  }

  /// Load a saved draft by [id] into the active cart.
  /// Auto-saves the current cart first if there are unsaved changes.
  Future<void> switchDraft(String id) async {
    if (state.currentDraftId == id) return;
    // Persist current cart before switching away
    if (state.draftDirty) {
      _autoSaveTimer?.cancel();
      await _persistCurrentCart();
    }
    try {
      final allDrafts = await _draftRepo.loadAll();
      final target = allDrafts.cast<DraftCart?>().firstWhere(
        (d) => d?.id == id,
        orElse: () => null,
      );
      if (target == null) return;

      // Revalidate amendment drafts before restoring — a previous auto-save
      // race may have persisted a half-built cart (catalog-miss sentinel or
      // null customer) to Hive. Restoring that would surface the bug again.
      if (target.amendmentSourceInvoiceId != null) {
        final hasCatalogMiss = target.cartItems.any(
          (i) => i['_bundle_catalog_miss'] == true,
        );
        final missingCustomer = target.customer == null;
        if (hasCatalogMiss || missingCustomer) {
          if (kDebugMode) {
            debugPrint(
              '[PosNotifier] switchDraft: stale amendment draft detected '
              '(catalog_miss=$hasCatalogMiss, missing_customer=$missingCustomer). '
              'Aborting restore for invoice ${target.amendmentSourceInvoiceId}.',
            );
          }
          await Sentry.captureMessage(
            'amendment_stale_draft_blocked',
            level: SentryLevel.warning,
            withScope: (scope) {
              scope.setContexts('amendment_stale_draft', <String, Object?>{
                'invoice_id': target.amendmentSourceInvoiceId ?? '',
                'has_catalog_miss': hasCatalogMiss,
                'missing_customer': missingCustomer,
                'draft_id': id,
              });
            },
          );
          state = state.copyWith(
            error:
                'This amendment draft is outdated — please reopen the order from the kanban to start again.',
            clearError: false,
          );
          return;
        }
      }

      state = state.copyWith(
        cartItems: List<Map<String, dynamic>>.from(target.cartItems),
        selectedCustomer: target.customer,
        clearSelectedCustomer: target.customer == null,
        selectedSalesPartner: target.salesPartner,
        clearSelectedSalesPartner: target.salesPartner == null,
        isPickup: target.isPickup,
        // Delivery slot is intentionally cleared on load; must be re-picked at checkout.
        clearSelectedDeliverySlot: true,
        clearDeliverySlots: true,
        currentDraftId: id,
        draftDirty: false,
        // Restore amendment context if this draft was saved mid-amendment.
        isAmendmentDraft: target.amendmentSourceInvoiceId != null,
        amendmentSourceInvoiceId: target.amendmentSourceInvoiceId,
        clearAmendmentSourceInvoiceId: target.amendmentSourceInvoiceId == null,
        amendmentSourceGrandTotal: target.amendmentSourceGrandTotal,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ PosNotifier: switchDraft failed: $e');
      }
    }
  }

  /// Delete a draft by [id].
  /// If it is the currently active draft, switches to a new empty cart.
  Future<void> deleteDraft(String id) async {
    try {
      await _draftRepo.delete(id);
      final allDrafts = await _draftRepo.loadAll();
      final wasActive = state.currentDraftId == id;
      state = state.copyWith(
        drafts: allDrafts.map(DraftCartSummary.from).toList(),
        clearCurrentDraftId: wasActive,
      );
      if (wasActive) {
        state = state.copyWith(
          cartItems: const [],
          clearSelectedCustomer: true,
          clearSelectedDeliverySlot: true,
          clearSelectedSalesPartner: true,
          clearDeliverySlots: true,
          isPickup: false,
          draftDirty: false,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ PosNotifier: deleteDraft failed: $e');
      }
    }
  }
  // ─────────────────────────────────────────────────────────────────────

  Future<void> refreshCatalog({bool showLoading = false}) async {
    final profileName = state.selectedProfile?['name']?.toString();
    if (profileName == null || profileName.isEmpty) {
      return;
    }

    state = state.copyWith(
      isLoading: showLoading ? true : state.isLoading,
      clearError: true,
    );

    try {
      final futures = await Future.wait([
        _repository.getItems(profileName),
        _repository.getBundles(profileName),
      ]);

      state = state.copyWith(
        items: futures[0],
        bundles: futures[1],
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
    state = state.copyWith(
      selectedProfile: profile,
      isLoading: true,
      clearError: true,
      clearDeliverySlots: true,
      clearSelectedDeliverySlot: true,
    );
    try {
      final profileName = profile['name'] as String;

      // Load both items and bundles for the selected profile
      final futures = await Future.wait([
        _repository.getItems(profileName),
        _repository.getBundles(profileName),
      ]);

      final items = futures[0];
      final bundles = futures[1];

      state = state.copyWith(items: items, bundles: bundles, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        clearError: false,
      );
    }
  }

  /// Returns `true` if the item was added, `false` if blocked by stock limit.
  bool addToCart(Map<String, dynamic> item) {
    // Block adding delivery/shipping related items when a Sales Partner is selected
    if (state.selectedSalesPartner != null) {
      final group = (item['item_group'] ?? '').toString().toLowerCase();
      final name = (item['item_name'] ?? item['name'] ?? '')
          .toString()
          .toLowerCase();
      final code = (item['name'] ?? '').toString().toLowerCase();
      if (group.contains('delivery') ||
          group.contains('shipping') ||
          name.contains('delivery') ||
          name.contains('shipping') ||
          code.contains('delivery') ||
          code.contains('shipping') ||
          (item['is_shipping'] == true)) {
        if (kDebugMode) {
          debugPrint(
            '🚫 Skipping add: delivery/shipping charge is hidden for Sales Partner invoices',
          );
        }
        return false;
      }
    }

    // Only enforce stock limits when the item payload includes stock metadata.
    final rawStockQty = item['actual_qty'];
    final stockQty = rawStockQty is num
        ? rawStockQty.toDouble()
        : double.infinity;
    final existingItemIndex = state.cartItems.indexWhere(
      (cartItem) => cartItem['item_code'] == item['name'],
    );
    final currentCartQty = existingItemIndex >= 0
        ? ((state.cartItems[existingItemIndex]['quantity'] ?? 1) as num).toInt()
        : 0;
    if (currentCartQty >= stockQty) {
      if (kDebugMode) {
        debugPrint(
          '🚫 Stock limit reached: ${item['name']} has $stockQty available, $currentCartQty in cart',
        );
      }
      return false;
    }

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

    state = state.copyWith(cartItems: updatedCart, draftDirty: true);
    _autoSaveDebounced();
    return true;
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
    state = state.copyWith(cartItems: updatedCart, draftDirty: true);
    _autoSaveDebounced();
  }

  void updateBundleInCart(
    int cartIndex,
    Map<String, List<Map<String, dynamic>>> newSelectedItems,
  ) {
    final updatedCart = [...state.cartItems];
    final bundleItem = updatedCart[cartIndex];

    if (bundleItem['type'] == 'bundle') {
      bundleItem['bundle_details']['selected_items'] = newSelectedItems;
      state = state.copyWith(cartItems: updatedCart, draftDirty: true);
      _autoSaveDebounced();
    }
  }

  /// Returns the available stock for an item by its item_code.
  double getStockForItem(String itemCode) {
    final item = state.items.cast<Map<String, dynamic>?>().firstWhere(
      (i) => i?['name'] == itemCode,
      orElse: () => null,
    );
    return item != null
        ? ((item['actual_qty'] ?? 0) as num).toDouble()
        : double.infinity;
  }

  void updateCartItemQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(index);
      return;
    }

    // Cap at available stock (skip for bundles / items not in stock list)
    final itemCode = state.cartItems[index]['item_code']?.toString() ?? '';
    final stockQty = getStockForItem(itemCode);
    final cappedQuantity = stockQty.isFinite
        ? (newQuantity <= stockQty.toInt() ? newQuantity : stockQty.toInt())
        : newQuantity;
    if (cappedQuantity <= 0) return;

    final updatedCart = List<Map<String, dynamic>>.from(state.cartItems);
    updatedCart[index] = {...updatedCart[index], 'quantity': cappedQuantity};
    state = state.copyWith(cartItems: updatedCart, draftDirty: true);
    _autoSaveDebounced();
  }

  void removeFromCart(int index) {
    final updatedCart = List<Map<String, dynamic>>.from(state.cartItems);
    updatedCart.removeAt(index);
    state = state.copyWith(cartItems: updatedCart, draftDirty: true);
    _autoSaveDebounced();
  }

  void selectCustomer(Map<String, dynamic> customer) {
    // Simply select the customer without adding shipping to cart
    // Shipping will be handled separately in the UI total calculation
    state = state.copyWith(selectedCustomer: customer, draftDirty: true);
    _autoSaveDebounced();
    // Trigger background prefetch of delivery slots (only if profile selected & not already cached)
    if (state.selectedProfile != null && state.deliverySlots.isEmpty) {
      _prefetchDeliverySlots();
    }
  }

  void setDeliverySlot(DeliverySlot? slot) {
    state = state.copyWith(selectedDeliverySlot: slot);
  }

  // Toggle pickup mode; when enabling pickup, clear any selected delivery slot
  void setPickup(bool value) {
    state = state.copyWith(
      isPickup: value,
      clearSelectedDeliverySlot: value,
      draftDirty: true,
    );
    _autoSaveDebounced();
  }

  void setSalesPartner(Map<String, dynamic>? partner) {
    if (partner == null) {
      state = state.copyWith(clearSelectedSalesPartner: true, draftDirty: true);
    } else {
      state = state.copyWith(selectedSalesPartner: partner, draftDirty: true);
    }
    _autoSaveDebounced();
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
    state = state.copyWith(clearSelectedCustomer: true, draftDirty: true);
    _autoSaveDebounced();

    if (kDebugMode) {
      debugPrint(
        'Customer state after clearing: ${state.selectedCustomer == null ? 'null' : 'still has customer'}',
      ); // Debug
    }
  }

  void clearCart() {
    // Simply clear the cart - shipping is handled separately, not as cart items
    state = state.copyWith(cartItems: [], draftDirty: true);
    _autoSaveDebounced();
  }

  Future<void> _prefetchDeliverySlots() async {
    if (_isPrefetchingSlots) return; // avoid duplicate concurrent calls
    final profile = state.selectedProfile;
    if (profile == null) return;
    final profileName = profile['name']?.toString();
    if (profileName == null || profileName.isEmpty) return;
    _isPrefetchingSlots = true;
    try {
      final slots = await _repository.getDeliverySlots(profileName);
      if (slots.isNotEmpty) {
        // Choose default slot if none selected
        DeliverySlot? selected = state.selectedDeliverySlot;
        selected ??= slots.firstWhere(
          (s) => s.isDefault,
          orElse: () => slots.first,
        );
        state = state.copyWith(
          deliverySlots: slots,
          selectedDeliverySlot: selected,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Prefetch delivery slots failed: $e');
      }
    } finally {
      _isPrefetchingSlots = false;
    }
  }

  bool _coerceBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    return normalized == '1' ||
        normalized == 'true' ||
        normalized == 'yes' ||
        normalized == 'y';
  }

  double _coerceDouble(dynamic value, {double fallback = 0.0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  int _coerceInt(dynamic value, {int fallback = 0}) {
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  bool _isBundleParentInvoiceItem(Map<String, dynamic> item) {
    return _coerceBool(item['is_bundle_parent']) ||
        (item['bundle_code']?.toString().trim().isNotEmpty ?? false);
  }

  bool _isBundleChildInvoiceItem(Map<String, dynamic> item) {
    return _coerceBool(item['is_bundle_child']) ||
        (item['parent_bundle']?.toString().trim().isNotEmpty ?? false);
  }

  Map<String, dynamic>? _findBundleInfoForInvoiceItem(
    Map<String, dynamic> parentItem,
    List<Map<String, dynamic>> bundles,
  ) {
    final bundleCode = parentItem['bundle_code']?.toString().trim() ?? '';
    final parentItemCode = parentItem['item_code']?.toString().trim() ?? '';

    for (final bundle in bundles) {
      final bundleId = bundle['id']?.toString().trim() ?? '';
      final bundleName = bundle['name']?.toString().trim() ?? '';
      final erpnextItem = bundle['erpnext_item']?.toString().trim() ?? '';
      if (bundleCode.isNotEmpty &&
          (bundleId == bundleCode || bundleName == bundleCode)) {
        return bundle;
      }
      if (parentItemCode.isNotEmpty &&
          erpnextItem.isNotEmpty &&
          erpnextItem == parentItemCode) {
        return bundle;
      }
    }
    // No match — log diagnostic to help diagnose catalog drift.
    if (kDebugMode) {
      final catalogTriples = bundles
          .map(
            (b) =>
                '(id=${b['id']}, name=${b['name']}, erpnext_item=${b['erpnext_item']})',
          )
          .join(', ');
      debugPrint(
        '[Amendment] _findBundleInfoForInvoiceItem: NO MATCH '
        'bundle_code="$bundleCode" parent_item_code="$parentItemCode" '
        'catalog_size=${bundles.length} '
        'catalog_triples=[$catalogTriples]',
      );
    }
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'amendment_bundle_catalog_miss_match_failure',
        data: {
          'bundle_code': bundleCode,
          'parent_item_code': parentItemCode,
          'catalog_size': bundles.length,
        },
        level: SentryLevel.warning,
      ),
    );
    return null;
  }

  Map<String, List<Map<String, dynamic>>> _reconstructBundleSelections(
    List<Map<String, dynamic>> childItems,
    Map<String, dynamic> bundleInfo,
    int bundleQuantity,
  ) {
    final selections = <String, List<Map<String, dynamic>>>{};
    final rawGroups = bundleInfo['item_groups'] as List<dynamic>? ?? const [];

    String groupKeyFor(Map<String, dynamic> group, int fallbackIndex) {
      final rawKey =
          (group['group_key'] ?? group['group_id'] ?? group['name'])
              ?.toString()
              .trim() ??
          '';
      if (rawKey.isNotEmpty) return rawKey;

      final groupName =
          (group['group_name'] ?? group['item_group'] ?? group['title'])
              ?.toString()
              .trim() ??
          'Group';
      final rawIndex = _coerceInt(
        group['group_index'] ?? group['idx'],
        fallback: fallbackIndex + 1,
      );
      return '$groupName::$rawIndex';
    }

    for (final childItem in childItems) {
      final itemCode = childItem['item_code']?.toString().trim() ?? '';
      if (itemCode.isEmpty) continue;

      Map<String, dynamic>? matchedGroup;
      Map<String, dynamic>? matchedItem;
      var matchedGroupIndex = 0;
      var groupIndex = 0;
      for (final rawGroup in rawGroups.whereType<Map>()) {
        final group = Map<String, dynamic>.from(rawGroup);
        final rawItems = group['items'] as List<dynamic>? ?? const [];
        for (final rawItem in rawItems.whereType<Map>()) {
          final candidate = Map<String, dynamic>.from(rawItem);
          final candidateId = candidate['id']?.toString().trim() ?? '';
          final candidateName = candidate['name']?.toString().trim() ?? '';
          if (candidateId == itemCode || candidateName == itemCode) {
            matchedGroup = group;
            matchedGroupIndex = groupIndex;
            matchedItem = candidate;
            break;
          }
        }
        if (matchedItem != null) break;
        groupIndex += 1;
      }

      final persistedGroupKey =
          childItem['bundle_group_key']?.toString().trim() ?? '';
      final persistedGroupName =
          childItem['bundle_group_name']?.toString().trim() ?? '';

      // Determine the selection key and whether we have a real catalog match.
      final bool hasCatalogMatch = matchedGroup != null;
      final String selectionKey;
      if (hasCatalogMatch) {
        selectionKey = groupKeyFor(matchedGroup!, matchedGroupIndex);
      } else if (persistedGroupKey.isNotEmpty) {
        selectionKey = persistedGroupKey;
      } else if (persistedGroupName.isNotEmpty) {
        selectionKey = persistedGroupName;
      } else if (rawGroups.isNotEmpty) {
        // Catalog drift: no metadata at all — fall back to the first group so
        // the child at least appears under a visible header in the edit UI.
        selectionKey = groupKeyFor(
          Map<String, dynamic>.from(rawGroups.first as Map),
          0,
        );
      } else {
        selectionKey = itemCode;
      }

      // Tag the item template with _catalog_drift when there is no catalog
      // match AND no persisted metadata, so the bundle editor can warn the
      // user that selections may need re-confirmation.
      final bool isDrift =
          !hasCatalogMatch &&
          persistedGroupKey.isEmpty &&
          persistedGroupName.isEmpty;

      final template = matchedItem != null
          ? Map<String, dynamic>.from(matchedItem)
          : {
              'id': itemCode,
              'name': childItem['item_name']?.toString() ?? itemCode,
              'item_name': childItem['item_name']?.toString() ?? itemCode,
              'price': _coerceDouble(
                childItem['price_list_rate'] ?? childItem['rate'],
              ),
              // Carry forward the matched group when available so the cart UI
              // can still render the correct group header even on catalog miss.
              if (matchedGroup != null)
                '_group_key':
                    (matchedGroup['group_key'] ??
                            matchedGroup['group_id'] ??
                            matchedGroup['name'] ??
                            matchedGroup['group_name'] ??
                            '')
                        .toString(),
              // Signal catalog drift so the bundle editor can show a warning.
              if (isDrift) '_catalog_drift': true,
            };

      final totalQuantity = _coerceInt(childItem['qty'], fallback: 1);
      // B3: use integer division (truncate) — if qty is not a clean multiple of
      // bundleQuantity the bundle reconstruction is indeterminate; return null
      // from the caller so the catalog-miss sentinel blocks the submit.
      if (bundleQuantity > 0 && totalQuantity % bundleQuantity != 0) {
        // Signal caller via a special sentinel entry so _buildAmendmentBundleCartItem
        // can detect and return null (triggering catalog-miss guard).
        selections['_qty_mismatch'] = [];
        return selections;
      }
      final perBundleQuantity = bundleQuantity > 0
          ? (totalQuantity ~/ bundleQuantity).clamp(1, totalQuantity)
          : totalQuantity.clamp(1, totalQuantity);

      for (var index = 0; index < perBundleQuantity; index++) {
        selections
            .putIfAbsent(selectionKey, () => [])
            .add(Map<String, dynamic>.from(template));
      }
    }

    return selections;
  }

  Map<String, dynamic>? _buildAmendmentBundleCartItem(
    Map<String, dynamic> parentItem,
    List<Map<String, dynamic>> childItems,
    List<Map<String, dynamic>> bundles,
  ) {
    final bundleInfo = _findBundleInfoForInvoiceItem(parentItem, bundles);
    if (bundleInfo == null) {
      return null;
    }

    final bundleQuantity = _coerceInt(
      parentItem['qty'],
      fallback: 1,
    ).clamp(1, 9999);
    // Prefer the catalog bundle price (always authoritative).
    // Only fall back to invoice-stored rates when the catalog has no price and
    // the stored rate is strictly positive — Dart's ?? does not catch numeric 0.
    final catalogPrice = _coerceDouble(bundleInfo['price']);
    final invoicePriceListRate = _coerceDouble(parentItem['price_list_rate']);
    final invoiceRate = _coerceDouble(parentItem['rate']);
    final bundleRate = catalogPrice > 0
        ? catalogPrice
        : invoicePriceListRate > 0
        ? invoicePriceListRate
        : invoiceRate;
    final bundleId =
        bundleInfo['id']?.toString() ??
        parentItem['bundle_code']?.toString() ??
        parentItem['item_code']?.toString() ??
        '';

    final selections = _reconstructBundleSelections(
      childItems,
      bundleInfo,
      bundleQuantity,
    );
    // B3: if reconstruction detected a qty-mismatch return null so the
    // catalog-miss sentinel path is triggered in _buildAmendmentCartItems.
    if (selections.containsKey('_qty_mismatch')) {
      return null;
    }

    return {
      'item_code': bundleId,
      'item_name':
          parentItem['item_name']?.toString() ??
          bundleInfo['name']?.toString() ??
          bundleId,
      'rate': bundleRate,
      'quantity': bundleQuantity,
      'type': 'bundle',
      'bundle_details': {
        'bundle_id': bundleId,
        'selected_items': selections,
        'bundle_info': bundleInfo,
      },
    };
  }

  Duration? _parseDeliveryDuration(dynamic rawDuration) {
    if (rawDuration == null) return null;
    if (rawDuration is num) {
      return Duration(seconds: rawDuration.toInt());
    }
    final value = rawDuration.toString().trim();
    if (value.isEmpty) return null;
    if (!value.contains(':')) {
      final seconds = int.tryParse(value);
      return seconds == null ? null : Duration(seconds: seconds);
    }
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  List<Map<String, dynamic>> _buildAmendmentCartItems(
    dynamic rawItems,
    List<Map<String, dynamic>> bundles,
  ) {
    if (rawItems is! List) return const [];

    final invoiceItems = rawItems
        .whereType<Map>()
        .map((rawItem) => Map<String, dynamic>.from(rawItem))
        .toList();
    final consumedBundleChildren = <int>{};
    final cartItems = <Map<String, dynamic>>[];

    for (var index = 0; index < invoiceItems.length; index++) {
      if (consumedBundleChildren.contains(index)) {
        continue;
      }

      final item = invoiceItems[index];
      if (_isBundleChildInvoiceItem(item)) {
        continue;
      }

      if (_isBundleParentInvoiceItem(item)) {
        final bundleCode = item['bundle_code']?.toString().trim() ?? '';
        final childItems = <Map<String, dynamic>>[];
        final candidateChildIndices = <int>[];
        for (
          var childIndex = 0;
          childIndex < invoiceItems.length;
          childIndex++
        ) {
          if (childIndex == index) continue;
          final childItem = invoiceItems[childIndex];
          if (!_isBundleChildInvoiceItem(childItem)) continue;
          final parentBundle =
              childItem['parent_bundle']?.toString().trim() ?? '';
          if (bundleCode.isNotEmpty && parentBundle == bundleCode) {
            childItems.add(childItem);
            candidateChildIndices.add(childIndex);
          }
        }

        final bundleCartItem = _buildAmendmentBundleCartItem(
          item,
          childItems,
          bundles,
        );
        if (bundleCartItem != null) {
          // Only consume child indices after a confirmed successful build.
          consumedBundleChildren.addAll(candidateChildIndices);
          cartItems.add(bundleCartItem);
          continue;
        }
        // Bundle catalog miss: consume children (they are always skipped anyway)
        // and add a sentinel so checkout validation can block a silent
        // zero-priced submission rather than letting it reach the backend.
        // Also capture a Sentry event so we can diagnose root cause in the wild.
        Sentry.captureMessage(
          'amendment_bundle_catalog_miss',
          level: SentryLevel.warning,
          withScope: (scope) {
            scope.setContexts('bundle_catalog_miss', <String, Object?>{
              'bundle_code': item['bundle_code']?.toString() ?? '',
              'item_code': item['item_code']?.toString() ?? '',
              'item_name': item['item_name']?.toString() ?? '',
              'catalog_size': bundles.length,
            });
          },
        );
        consumedBundleChildren.addAll(candidateChildIndices);
        cartItems.add({
          'item_code': bundleCode.isNotEmpty
              ? bundleCode
              : (item['item_code']?.toString() ?? ''),
          'item_name': item['item_name']?.toString() ?? 'Unknown Bundle',
          'rate': 0.0,
          'quantity': _coerceInt(item['qty'], fallback: 1).clamp(1, 9999),
          'type': 'bundle',
          '_bundle_catalog_miss': true,
          'bundle_details': {
            'bundle_id': bundleCode.isNotEmpty
                ? bundleCode
                : (item['item_code']?.toString() ?? ''),
            'selected_items': <String, List<Map<String, dynamic>>>{},
            'bundle_info': <String, dynamic>{},
          },
        });
        continue;
      }

      final itemCode = item['item_code']?.toString() ?? '';
      if (itemCode.isEmpty) {
        continue;
      }
      final quantity = _coerceInt(item['qty'], fallback: 1);
      cartItems.add({
        'item_code': itemCode,
        'item_name': item['item_name']?.toString() ?? itemCode,
        'rate': _coerceDouble(item['rate']),
        'quantity': quantity < 1 ? 1 : quantity,
        'type': 'item',
        if (item.containsKey('price_list_rate'))
          'price_list_rate': _coerceDouble(item['price_list_rate']),
        if (item.containsKey('discount_amount'))
          'discount_amount': _coerceDouble(item['discount_amount']),
        if (item.containsKey('discount_percentage'))
          'discount_percentage': _coerceDouble(item['discount_percentage']),
      });
    }

    return cartItems;
  }

  Map<String, dynamic>? _buildAmendmentCustomer(
    Map<String, dynamic> invoiceData,
  ) {
    final rawCustomer = invoiceData['customer'];
    final customer = rawCustomer?.toString().trim() ?? '';
    if (customer.isEmpty) {
      final invoiceId = invoiceData['name']?.toString() ?? 'unknown';
      if (kDebugMode) {
        debugPrint(
          '[Amendment] _buildAmendmentCustomer: MISSING customer for invoice "$invoiceId". '
          'Raw customer field: ${rawCustomer.runtimeType}($rawCustomer). '
          'Keys present: ${invoiceData.keys.toList()}',
        );
      }
      Sentry.captureMessage(
        'amendment_customer_missing',
        level: SentryLevel.warning,
        withScope: (scope) {
          scope.setContexts('amendment_customer_missing', <String, Object?>{
            'invoice_id': invoiceId,
            'raw_customer': rawCustomer?.toString() ?? 'null',
            'customer_name': invoiceData['customer_name']?.toString() ?? 'null',
            'has_territory': invoiceData.containsKey('territory'),
          });
        },
      );
      return null;
    }

    final selectedShippingAddressName =
        invoiceData['shipping_address_name']?.toString().trim() ?? '';
    final selectedShippingAddress =
        invoiceData['full_address']?.toString().trim() ?? '';

    final wasFreeShipping = _coerceBool(invoiceData['was_free_shipping']);
    return {
      'name': customer,
      'customer_name': invoiceData['customer_name']?.toString() ?? customer,
      'territory': invoiceData['territory']?.toString() ?? '',
      'territory_name':
          invoiceData['territory_display']?.toString() ??
          invoiceData['territory']?.toString() ??
          '',
      'territory_name_ar': invoiceData['territory_name_ar']?.toString() ?? '',
      // Gate delivery_income to zero when the source invoice had free shipping;
      // otherwise returning the territory default would re-charge on resubmit.
      'delivery_income': wasFreeShipping
          ? 0.0
          : invoiceData['shipping_income'] is num
          ? (invoiceData['shipping_income'] as num).toDouble()
          : double.tryParse(invoiceData['shipping_income']?.toString() ?? '') ??
                0.0,
      'delivery_expense': invoiceData['shipping_expense'] is num
          ? (invoiceData['shipping_expense'] as num).toDouble()
          : double.tryParse(
                  invoiceData['shipping_expense']?.toString() ?? '',
                ) ??
                0.0,
      'was_free_shipping': wasFreeShipping,
      'mobile_no': invoiceData['customer_phone']?.toString() ?? '',
      'selected_shipping_address_name': selectedShippingAddressName,
      'selected_shipping_address': selectedShippingAddress,
    };
  }

  DeliverySlot? _buildAmendmentDeliverySlot(Map<String, dynamic> invoiceData) {
    final deliveryDate = invoiceData['delivery_date']?.toString().trim() ?? '';
    final deliveryTime =
        invoiceData['delivery_time_from']?.toString().trim() ?? '';
    if (deliveryDate.isEmpty || deliveryTime.isEmpty) {
      return null;
    }

    final normalizedTime = deliveryTime.length == 5
        ? '$deliveryTime:00'
        : deliveryTime;
    final label =
        (invoiceData['delivery_slot_label']?.toString().trim().isNotEmpty ??
            false)
        ? invoiceData['delivery_slot_label'].toString().trim()
        : '$deliveryDate $deliveryTime';

    try {
      final start = DateTime.parse('${deliveryDate}T$normalizedTime');
      final duration = _parseDeliveryDuration(invoiceData['delivery_duration']);
      final end = duration == null ? start : start.add(duration);
      return DeliverySlot(
        date: deliveryDate,
        time: deliveryTime,
        datetime: start.toIso8601String(),
        endDatetime: end.toIso8601String(),
        label: label,
        dayLabel: deliveryDate,
        timeLabel: label,
      );
    } catch (_) {
      final fallbackDateTime = '$deliveryDate $deliveryTime';
      return DeliverySlot(
        date: deliveryDate,
        time: deliveryTime,
        datetime: fallbackDateTime,
        endDatetime: fallbackDateTime,
        label: label,
        dayLabel: deliveryDate,
        timeLabel: label,
      );
    }
  }

  Future<void> startAmendmentDraft(Map<String, dynamic> invoiceData) async {
    // Cancel any pending autosave timer immediately so it cannot fire during
    // the async gap between state-clear and final state-set below.
    _autoSaveTimer?.cancel();
    _amendmentSetupInProgress = true;

    final invoiceId = invoiceData['name']?.toString().trim() ?? '';
    final posProfileName =
        (invoiceData['pos_profile'] ?? invoiceData['custom_kanban_profile'])
            ?.toString()
            .trim() ??
        '';
    if (invoiceId.isEmpty || posProfileName.isEmpty) {
      _amendmentSetupInProgress = false;
      state = state.copyWith(
        error: 'Missing invoice amendment draft data',
        clearError: false,
        isLoading: false,
        isAmendmentDraft: false,
        clearAmendmentSourceInvoiceId: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      cartItems: const [],
      clearSelectedCustomer: true,
      clearSelectedDeliverySlot: true,
      clearSelectedSalesPartner: true,
      clearDeliverySlots: true,
      isPickup: false,
      isAmendmentDraft: false,
      clearAmendmentSourceInvoiceId: true,
    );

    try {
      final profiles = state.profiles.isNotEmpty
          ? state.profiles
          : await _repository.getPosProfiles();

      Map<String, dynamic>? selectedProfile;
      for (final profile in profiles) {
        if ((profile['name']?.toString() ?? '').trim() == posProfileName) {
          selectedProfile = profile;
          break;
        }
      }
      selectedProfile ??= {'name': posProfileName, 'title': posProfileName};

      final futures = await Future.wait([
        _repository.getItems(posProfileName),
        _repository.getBundles(posProfileName),
      ]);

      final customer = _buildAmendmentCustomer(invoiceData);
      final deliverySlot = _buildAmendmentDeliverySlot(invoiceData);
      final salesPartnerName =
          invoiceData['sales_partner']?.toString().trim() ?? '';
      final isPickup = _coerceBool(invoiceData['is_pickup']);
      final bundleCatalog = futures[1];

      final builtCartItems = _buildAmendmentCartItems(
        invoiceData['items'],
        bundleCatalog,
      );

      // B4: Guard against empty or badly loaded amendment cart.
      // If the source had items but we loaded zero, refuse to open the draft
      // so the user cannot accidentally submit an empty cart that overwrites history.
      final sourceItemCount = (invoiceData['items'] is List)
          ? (invoiceData['items'] as List).length
          : 0;
      final sourceGrandTotal = _coerceDouble(invoiceData['grand_total']);

      if (sourceItemCount > 0 && builtCartItems.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          isAmendmentDraft: false,
          clearAmendmentSourceInvoiceId: true,
          error:
              'Failed to load the original order items. '
              'Please close and reopen the order to retry.',
          clearError: false,
        );
        if (kDebugMode) {
          debugPrint(
            '[Amendment] BLOCKED — source had $sourceItemCount items but '
            'built cart is empty. Source total: $sourceGrandTotal',
          );
        }
        // early-return inside try — finally block will still clear the flag.
        return;
      }

      if (kDebugMode) {
        final bundleCount = builtCartItems
            .where((i) => i['type'] == 'bundle')
            .length;
        final missCount = builtCartItems
            .where(
              (i) => i['type'] == 'bundle' && i['_bundle_catalog_miss'] == true,
            )
            .length;
        debugPrint(
          '[Amendment] Loaded ${builtCartItems.length} cart items '
          '($bundleCount bundles, $missCount catalog misses) '
          'from $sourceItemCount source rows. Source total: $sourceGrandTotal',
        );
      }

      state = state.copyWith(
        profiles: profiles,
        selectedProfile: selectedProfile,
        items: futures[0],
        bundles: bundleCatalog,
        cartItems: builtCartItems,
        selectedCustomer: customer,
        clearSelectedCustomer: customer == null,
        selectedDeliverySlot: isPickup ? null : deliverySlot,
        clearSelectedDeliverySlot: isPickup || deliverySlot == null,
        selectedSalesPartner: salesPartnerName.isEmpty
            ? null
            : {'name': salesPartnerName},
        clearSelectedSalesPartner: salesPartnerName.isEmpty,
        deliverySlots: !isPickup && deliverySlot != null
            ? [deliverySlot]
            : const [],
        clearDeliverySlots: isPickup || deliverySlot == null,
        isPickup: isPickup,
        isLoading: false,
        isAmendmentDraft: true,
        amendmentSourceInvoiceId: invoiceId,
        amendmentSourceGrandTotal: sourceGrandTotal > 0
            ? sourceGrandTotal
            : null,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        clearError: false,
        isAmendmentDraft: false,
        clearAmendmentSourceInvoiceId: true,
      );
    } finally {
      _amendmentSetupInProgress = false;
    }
  }

  Future<void> checkout({
    String? paymentType,
    String? overridePosProfileName,
    String? paymentMethod,
    bool posProfileOverride = false,
  }) async {
    if (state.cartItems.isEmpty) {
      state = state.copyWith(error: 'Cart is empty', clearError: false);
      return;
    }

    if (state.selectedProfile == null &&
        (overridePosProfileName == null || overridePosProfileName.isEmpty)) {
      state = state.copyWith(error: 'No profile selected', clearError: false);
      return;
    }

    // For amendment drafts, block submission if any bundle has no price.
    // This catches both catalog-miss sentinels and unexpected zero-rate reloads
    // before they silently overwrite the original invoice with a lower amount.
    if (state.isAmendmentDraft) {
      // B4: Block empty cart submission for amendment drafts.
      if (state.cartItems.isEmpty) {
        state = state.copyWith(
          error:
              'Cannot submit amendment: cart is empty. '
              'Please close and reopen the order to reload the original items.',
          clearError: false,
          isLoading: false,
        );
        return;
      }

      // B4: Block if any item has no item_code.
      final hasEmptyCode = state.cartItems.any(
        (item) => (item['item_code']?.toString() ?? '').trim().isEmpty,
      );
      if (hasEmptyCode) {
        state = state.copyWith(
          error:
              'Cannot submit amendment: one or more items have no item code. '
              'Please close and reopen the order.',
          clearError: false,
          isLoading: false,
        );
        return;
      }

      for (final cartItem in state.cartItems) {
        if (cartItem['type'] == 'bundle') {
          // Only a true catalog miss (bundle not found in the item catalog)
          // blocks submission.  A zero-rate is a legitimate 100% discount and
          // must pass through to the backend.
          final isMiss = cartItem['_bundle_catalog_miss'] == true;
          if (isMiss) {
            final name =
                cartItem['item_name']?.toString() ??
                cartItem['item_code']?.toString() ??
                'bundle';
            state = state.copyWith(
              error:
                  'Cannot submit amendment: "$name" was not found in the '
                  'item catalog. Please close and reopen the order to refresh.',
              clearError: false,
              isLoading: false,
            );
            return;
          }

          final selectedItems = cartItem['bundle_details']?['selected_items'];
          final hasSelectedChildren =
              selectedItems is Map &&
              selectedItems.values.any(
                (entries) => entries is List && entries.isNotEmpty,
              );
          if (!hasSelectedChildren) {
            final name =
                cartItem['item_name']?.toString() ??
                cartItem['item_code']?.toString() ??
                'bundle';
            state = state.copyWith(
              error:
                  'Cannot submit amendment: "$name" has no selected bundle items. '
                  'Please close and reopen the order to refresh.',
              clearError: false,
              isLoading: false,
            );
            return;
          }
        }
      }
    }

    if (kDebugMode) {
      debugPrint('🛒 STARTING CHECKOUT PROCESS (no auto-print):');
      debugPrint('   Cart Items Count: ${state.cartItems.length}');
      debugPrint(
        '   Customer: ${state.selectedCustomer?['customer_name'] ?? 'Walking Customer'}',
      );
      debugPrint(
        '   POS Profile: ${state.selectedProfile?['name'] ?? 'No Profile Selected'}',
      );
    }

    for (int i = 0; i < state.cartItems.length; i++) {
      final item = state.cartItems[i];
      final type = item['type'] ?? 'unknown';
      if (kDebugMode) {
        debugPrint(
          '   Cart Item ${i + 1}: ${item['item_code']} - Type: $type, Qty: ${item['quantity']}, Rate: ${item['rate']}',
        );
        if (type == 'bundle') {
          debugPrint(
            '      Bundle ID: ${item['bundle_details']?['bundle_id']}',
          );
        }
      }
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final effectivePosProfile =
          (overridePosProfileName != null && overridePosProfileName.isNotEmpty)
          ? overridePosProfileName
          : state.selectedProfile!['name'];
      final invoice = state.isAmendmentDraft
          ? await _repository.submitInvoiceAmendment(
              sourceInvoiceId: state.amendmentSourceInvoiceId ?? '',
              posProfile: effectivePosProfile,
              items: state.cartItems,
              customer: state.selectedCustomer,
              requiredDeliveryDatetime: state.isPickup
                  ? null
                  : state.selectedDeliverySlot?.datetime,
              deliveryEndDatetime: state.isPickup
                  ? null
                  : state.selectedDeliverySlot?.endDatetime,
              isPickup: state.isPickup,
              salesPartner: state.selectedSalesPartner?['name'],
              paymentType: paymentType,
              paymentMethod: paymentMethod,
              posProfileOverride: posProfileOverride,
              expectedSourceGrandTotal: state.amendmentSourceGrandTotal,
            )
          : await _repository.createInvoice(
              posProfile: effectivePosProfile,
              items: state.cartItems,
              customer: state.selectedCustomer,
              requiredDeliveryDatetime: state.isPickup
                  ? null
                  : state.selectedDeliverySlot?.datetime,
              deliveryEndDatetime: state.isPickup
                  ? null
                  : state.selectedDeliverySlot?.endDatetime,
              isPickup: state.isPickup,
              salesPartner: state.selectedSalesPartner?['name'],
              paymentType: paymentType,
              paymentMethod: paymentMethod,
              posProfileOverride: posProfileOverride,
            );

      if (kDebugMode) {
        debugPrint('✅ CHECKOUT SUCCESS (no auto-print):');
        debugPrint(
          '   Invoice Name: ${invoice['name'] ?? invoice['invoice_name']}',
        );
        debugPrint('   Grand Total: ${invoice['grand_total']}');
      }

      // No modal overlay; rely on inline progress UI

      // Delete the draft that was just checked out.
      final completedDraftId = state.currentDraftId;
      if (completedDraftId != null) {
        try {
          await _draftRepo.delete(completedDraftId);
        } catch (_) {}
      }
      // Refresh drafts list from Hive.
      List<DraftCartSummary> remainingDrafts = state.drafts;
      try {
        final allDrafts = await _draftRepo.loadAll();
        remainingDrafts = allDrafts.map(DraftCartSummary.from).toList();
      } catch (_) {}

      // Reset invoice context (cart, customer, delivery slot, sales partner) for a fresh start.
      state = state.copyWith(
        cartItems: [],
        clearSelectedCustomer: true,
        clearSelectedDeliverySlot: true,
        clearSelectedSalesPartner: true,
        isPickup: false,
        isLoading: false,
        isAmendmentDraft: false,
        clearAmendmentSourceInvoiceId: true,
        clearCurrentDraftId: true,
        draftDirty: false,
        drafts: remainingDrafts,
      );

      // TODO (Wallet/InstaPay Reference Capture):
      // When adding a payment step (wallet / instapay) after invoice creation,
      // prompt user for reference number & date, then call repository.payInvoice
      // with those fields. Cash payments won't require references.
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ CHECKOUT ERROR: $e');
      }
      // M3: Report amendment failures to Sentry with enough context to diagnose
      // pricing drift or catalog-miss issues without a support call.
      if (state.isAmendmentDraft) {
        unawaited(
          Sentry.captureException(
            e,
            stackTrace: stackTrace,
            hint: Hint.withMap({
              'amendment_source_invoice_id':
                  state.amendmentSourceInvoiceId ?? '',
              'cart_items_count': state.cartItems.length,
              'amendment_source_grand_total':
                  state.amendmentSourceGrandTotal ?? 0.0,
            }),
          ),
        );
      }
      // No modal overlay; rely on inline progress UI
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

  // Explicit public method to start a new invoice manually (also clears sales partner)
  void startNewInvoice() {
    state = state.copyWith(
      cartItems: [],
      clearSelectedCustomer: true,
      clearSelectedDeliverySlot: true,
      clearSelectedSalesPartner: true,
      clearDeliverySlots: true,
      isLoading: false,
      isPickup: false,
      isAmendmentDraft: false,
      clearAmendmentSourceInvoiceId: true,
      clearCurrentDraftId: true,
      draftDirty: false,
    );
  }

  void addCartPosItem(PosCartItem item) {
    // Safeguard: prevent adding delivery/shipping-like items when Sales Partner is selected
    if (state.selectedSalesPartner != null) {
      final codeLower = item.itemCode.toLowerCase();
      if (codeLower.contains('delivery') || codeLower.contains('shipping')) {
        if (kDebugMode) {
          debugPrint(
            '🚫 Skipping add(PosCartItem): delivery/shipping blocked for Sales Partner',
          );
        }
        return;
      }
    }
    final cartEntry = {
      'item_code': item.itemCode,
      'item_name': item.itemCode,
      'rate': item.rate,
      'quantity': item.quantity,
      'type': item.isBundle ? 'bundle' : 'item',
      if (item.priceListRate != null) 'price_list_rate': item.priceListRate,
      if (item.discountAmount != null) 'discount_amount': item.discountAmount,
      if (item.discountPercentage != null)
        'discount_percentage': item.discountPercentage,
    };
    final updated = [...state.cartItems, cartEntry];
    state = state.copyWith(cartItems: updated, draftDirty: true);
    _autoSaveDebounced();
  }

  /// Fetches the POS profile mapped to [customerName]'s territory.
  /// Returns `null` when the customer has no territory, the territory has no
  /// profile, or on any network/server error.
  Future<String?> getTerritoryPosProfile(String customerName) =>
      _repository.getTerritoryPosProfile(customerName);
}

final posNotifierProvider = StateNotifierProvider<PosNotifier, PosState>((ref) {
  final repository = ref.watch(posRepositoryProvider);
  final draftRepo = ref.watch(draftCartRepositoryProvider);
  return PosNotifier(repository, draftRepo);
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
