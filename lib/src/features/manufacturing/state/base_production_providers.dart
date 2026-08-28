import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/manufacturing_service.dart';
import '../data/models/base_batch_preview.dart';
import '../data/models/base_item.dart';
import '../domain/base_batch_math.dart';

/// Whether to ask the backend to roll up jar demand for each base.
///
/// Demand costs a plan lookup plus a BOM explosion per base server-side. Kept
/// switchable for the same reason `includeCapacityProvider` is: a slow list can
/// be made fast without a deploy.
final includeBaseDemandProvider = StateProvider<bool>((ref) => true);

/// The list of bases. Loads once and is refreshed explicitly.
final baseItemsProvider =
    AsyncNotifierProvider<BaseItemsNotifier, BaseItemsPage>(
  BaseItemsNotifier.new,
);

class BaseItemsNotifier extends AsyncNotifier<BaseItemsPage> {
  ManufacturingService get _service => ref.read(manufacturingServiceProvider);

  @override
  Future<BaseItemsPage> build() {
    final includeDemand = ref.watch(includeBaseDemandProvider);
    return _service.getBaseItems(includeDemand: includeDemand);
  }

  /// Pull-to-refresh, and the single way the list comes back in sync after a
  /// run is started.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.getBaseItems(
        includeDemand: ref.read(includeBaseDemandProvider),
      ),
    );
  }
}

/// One base's card state: the batch count the operator typed, and the server's
/// answer for it.
@immutable
class BaseBatchDraft {
  const BaseBatchDraft({
    this.batches = 1.0,
    this.preview,
    this.loading = false,
    this.error,
  });

  /// Always the operator's control. Nothing ever writes a demand figure in
  /// here without a tap.
  final double batches;

  final BaseBatchPreview? preview;

  /// A preview is in flight or queued behind the debounce.
  final bool loading;

  /// The raw error object, not a message: the string has to be built with the
  /// widget's `l10n` and this class has no `BuildContext`.
  final Object? error;

  bool get hasPreview => preview != null;

  /// The preview describes the batch count currently on screen.
  ///
  /// While the stepper is ahead of the last answer, the old component list is
  /// still worth showing — it just must not be read as current.
  bool get previewIsCurrent =>
      preview != null && (preview!.batches - batches).abs() <= kBatchEpsilon;

  BaseBatchDraft copyWith({
    double? batches,
    BaseBatchPreview? preview,
    bool? loading,
    Object? error,
    bool clearPreview = false,
    bool clearError = false,
  }) {
    return BaseBatchDraft(
      batches: batches ?? this.batches,
      preview: clearPreview ? null : (preview ?? this.preview),
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Per-base draft, keyed by item code.
///
/// Deliberately NOT auto-disposed: a card scrolled off screen and back must
/// still hold the batch count the operator dialled in. The family is bounded by
/// the number of bases (a handful), so nothing accumulates.
final baseBatchDraftProvider =
    NotifierProvider.family<BaseBatchDraftNotifier, BaseBatchDraft, String>(
  BaseBatchDraftNotifier.new,
);

class BaseBatchDraftNotifier extends FamilyNotifier<BaseBatchDraft, String> {
  Timer? _debounce;

  /// Long enough that walking the stepper from 1 to 3 costs one request, short
  /// enough that the consumption panel feels attached to the number above it.
  static const _debounceDelay = Duration(milliseconds: 400);

  @override
  BaseBatchDraft build(String arg) {
    ref.onDispose(() => _debounce?.cancel());
    // Nothing is fetched here on purpose: a provider's build() must not start
    // network work, and the card asks for its first preview once it is mounted.
    return const BaseBatchDraft();
  }

  /// Sets the batch count, snapped onto the half-batch grid.
  void setBatches(double value) {
    final next = clampBatches(snapToHalf(value));
    if ((next - state.batches).abs() <= kBatchEpsilon && state.hasPreview) {
      return;
    }
    state = state.copyWith(batches: next, clearError: true);
    _schedulePreview();
  }

  /// Moves the stepper by [delta] half-batches.
  void step(double delta) => setBatches(state.batches + delta);

  /// Fetches the first preview for a card that has just appeared. Idempotent,
  /// so a rebuild does not re-request.
  void ensurePreview() {
    if (state.hasPreview || state.loading) return;
    _schedulePreview();
  }

  /// Drops the cached preview and re-asks. Used after a run starts, when the
  /// stock the last preview was computed against has physically moved.
  void invalidatePreview() {
    state = state.copyWith(clearPreview: true, clearError: true);
    _schedulePreview();
  }

  void _schedulePreview() {
    _debounce?.cancel();
    state = state.copyWith(loading: true);
    _debounce = Timer(_debounceDelay, refreshPreview);
  }

  /// Fetches now, skipping the debounce.
  Future<void> refreshPreview() async {
    final item = _item();
    if (item == null) {
      // The list has not loaded yet (or this base fell off it). Not an error
      // worth showing — the card re-asks once the list arrives.
      state = state.copyWith(loading: false);
      return;
    }

    final requested = state.batches;
    try {
      final preview =
          await ref.read(manufacturingServiceProvider).previewBaseBatch(
                itemCode: item.itemCode,
                batches: requested,
                bomName: item.defaultBom,
              );
      // A slower earlier request must not overwrite a newer entry.
      if (!_stillWanted(requested)) return;
      state = state.copyWith(
        preview: preview,
        loading: false,
        clearError: true,
      );
    } catch (error) {
      if (!_stillWanted(requested)) return;
      // The stale component list is dropped with the failure: leaving numbers
      // on screen that describe a different batch count is worse than an
      // honest blank.
      state = state.copyWith(
        loading: false,
        error: error,
        clearPreview: true,
      );
    }
  }

  bool _stillWanted(double requested) =>
      (state.batches - requested).abs() <= kBatchEpsilon;

  BaseItem? _item() {
    final page = ref.read(baseItemsProvider).valueOrNull;
    if (page == null) return null;
    for (final item in page.items) {
      if (item.itemCode == arg) return item;
    }
    return null;
  }
}
