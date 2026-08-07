import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/daily_plan_service.dart';
import '../data/models/daily_plan.dart';

/// The fillable items and the batch definition, loaded once per screen open.
final dailyPlanTemplateProvider = FutureProvider<DailyPlanTemplate>((ref) {
  return ref.watch(dailyPlanServiceProvider).getTemplate();
});

/// Whether the BOMs can answer the batch question yet.
///
/// Separate from the template because it is advisory: a plan is still worth
/// entering while some BOMs are unmigrated, it just under-reports the mix.
final bomReadinessProvider = FutureProvider<BomReadiness>((ref) {
  return ref.watch(dailyPlanServiceProvider).checkBomReadiness();
});

/// Jar quantities the user has typed, and the server's answer for them.
///
/// The preview is debounced rather than fired per keystroke: each call totals
/// the mix server-side, and at ~18 flavours a naive implementation would send a
/// request per digit.
class DailyPlanDraft {
  const DailyPlanDraft({
    this.quantities = const {},
    this.preview,
    this.calculating = false,
    this.error,
    this.savedPlanName,
  });

  final Map<String, int> quantities;
  final DailyPlanPreview? preview;
  final bool calculating;
  final String? error;
  final String? savedPlanName;

  int get totalJars => quantities.values.fold(0, (a, b) => a + b);
  bool get isEmpty => quantities.values.every((q) => q <= 0);

  DailyPlanDraft copyWith({
    Map<String, int>? quantities,
    DailyPlanPreview? preview,
    bool? calculating,
    String? error,
    String? savedPlanName,
    bool clearError = false,
    bool clearPreview = false,
  }) {
    return DailyPlanDraft(
      quantities: quantities ?? this.quantities,
      preview: clearPreview ? null : (preview ?? this.preview),
      calculating: calculating ?? this.calculating,
      error: clearError ? null : (error ?? this.error),
      savedPlanName: savedPlanName ?? this.savedPlanName,
    );
  }
}

final dailyPlanDraftProvider =
    NotifierProvider<DailyPlanDraftNotifier, DailyPlanDraft>(
  DailyPlanDraftNotifier.new,
);

class DailyPlanDraftNotifier extends Notifier<DailyPlanDraft> {
  Timer? _debounce;

  /// Long enough to swallow a multi-digit entry, short enough that the split
  /// feels like it is reacting to what was typed.
  static const _debounceDelay = Duration(milliseconds: 350);

  @override
  DailyPlanDraft build() {
    ref.onDispose(() => _debounce?.cancel());
    return const DailyPlanDraft();
  }

  void setQuantity(String itemCode, int qty) {
    final next = Map<String, int>.from(state.quantities);
    if (qty <= 0) {
      next.remove(itemCode);
    } else {
      next[itemCode] = qty;
    }
    state = state.copyWith(quantities: next, clearError: true);
    _schedulePreview();
  }

  void loadFrom(DailyPlan plan) {
    state = DailyPlanDraft(
      quantities: {
        for (final line in plan.lines)
          if (line.plannedQty > 0) line.itemCode: line.plannedQty,
      },
      savedPlanName: plan.name,
    );
    _schedulePreview();
  }

  void clear() {
    _debounce?.cancel();
    state = const DailyPlanDraft();
  }

  void _schedulePreview() {
    _debounce?.cancel();
    if (state.isEmpty) {
      // Nothing entered: drop the stale split rather than leaving yesterday's
      // run list under an empty form.
      state = state.copyWith(calculating: false, clearPreview: true);
      return;
    }
    state = state.copyWith(calculating: true);
    _debounce = Timer(_debounceDelay, refreshPreview);
  }

  /// Recomputes now. [withMaterials] triggers the heavier stock check, which
  /// only runs on demand and before saving.
  Future<void> refreshPreview({bool withMaterials = false}) async {
    final quantities = Map<String, int>.from(state.quantities);
    if (quantities.isEmpty) {
      state = state.copyWith(calculating: false, clearPreview: true);
      return;
    }

    try {
      final preview = await ref
          .read(dailyPlanServiceProvider)
          .preview(quantities, includeMaterials: withMaterials);
      // A slower earlier request must not overwrite a newer entry.
      if (!_sameQuantities(quantities, state.quantities)) return;
      state = state.copyWith(
        preview: preview,
        calculating: false,
        clearError: true,
      );
    } catch (error) {
      if (!_sameQuantities(quantities, state.quantities)) return;
      state = state.copyWith(calculating: false, error: error.toString());
    }
  }

  Future<DailyPlan> save({String? status}) async {
    final plan = await ref.read(dailyPlanServiceProvider).save(
          quantities: state.quantities,
          name: state.savedPlanName,
          status: status,
        );
    state = state.copyWith(savedPlanName: plan.name);
    return plan;
  }

  static bool _sameQuantities(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}

/// The plan being closed at end of day, keyed by item code.
///
/// A missing key means not counted, which the server keeps distinct from a
/// counted zero — so this is deliberately not defaulted to 0.
final dailyPlanActualsProvider =
    NotifierProvider<DailyPlanActualsNotifier, Map<String, int?>>(
  DailyPlanActualsNotifier.new,
);

class DailyPlanActualsNotifier extends Notifier<Map<String, int?>> {
  @override
  Map<String, int?> build() => {};

  void set(String itemCode, int? qty) {
    final next = Map<String, int?>.from(state);
    if (qty == null) {
      next.remove(itemCode);
    } else {
      next[itemCode] = qty;
    }
    state = next;
  }

  void seedFrom(DailyPlan plan) {
    state = {
      for (final line in plan.lines)
        if (line.actualQty != null) line.itemCode: line.actualQty,
    };
  }

  void clear() => state = {};
}
