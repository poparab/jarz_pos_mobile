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
    this.savedPlanDate,
  });

  final Map<String, int> quantities;
  final DailyPlanPreview? preview;
  final bool calculating;
  final String? error;
  final String? savedPlanName;

  /// Which day [savedPlanName] is the plan FOR, as `yyyy-MM-dd`.
  ///
  /// Carried because the tab can be back-dated: the name alone would send a
  /// yesterday save into today's document, leaving the stock entry on one date
  /// and the intent it came from on another.
  final String? savedPlanDate;

  int get totalJars => quantities.values.fold(0, (a, b) => a + b);
  bool get isEmpty => quantities.values.every((q) => q <= 0);

  DailyPlanDraft copyWith({
    Map<String, int>? quantities,
    DailyPlanPreview? preview,
    bool? calculating,
    String? error,
    String? savedPlanName,
    String? savedPlanDate,
    bool clearError = false,
    bool clearPreview = false,
  }) {
    return DailyPlanDraft(
      quantities: quantities ?? this.quantities,
      preview: clearPreview ? null : (preview ?? this.preview),
      calculating: calculating ?? this.calculating,
      error: clearError ? null : (error ?? this.error),
      savedPlanName: savedPlanName ?? this.savedPlanName,
      savedPlanDate: savedPlanDate ?? this.savedPlanDate,
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
    seedQuantities(
      {
        for (final line in plan.lines)
          if (line.plannedQty > 0) line.itemCode: line.plannedQty,
      },
      planName: plan.name,
    );
  }

  /// Adopts a set of quantities wholesale, without writing anything back out.
  ///
  /// Used to re-hydrate the form from a source that is already authoritative —
  /// a saved plan, or the Hive-backed batch queue after a restart. Deliberately
  /// one-way: the merged Plan tab writes through [setQuantity] so the queue and
  /// this draft move together, and a seed that echoed back into the queue would
  /// re-add lines a start had just removed.
  void seedQuantities(Map<String, int> quantities, {String? planName}) {
    state = DailyPlanDraft(
      quantities: {
        for (final entry in quantities.entries)
          if (entry.value > 0) entry.key: entry.value,
      },
      savedPlanName: planName ?? state.savedPlanName,
    );
    _schedulePreview();
  }

  /// Forgets [itemCodes] — what a successful start leaves behind.
  ///
  /// The jars are on the floor now, so leaving their numbers in the fields
  /// would invite the same run to be started twice. What was planned survives
  /// on the saved plan document, which is the point of Save plan being its own
  /// action.
  void forget(Iterable<String> itemCodes) {
    final drop = itemCodes.toSet();
    if (drop.isEmpty) return;
    final next = Map<String, int>.from(state.quantities)
      ..removeWhere((code, _) => drop.contains(code));
    if (next.length == state.quantities.length) return;
    state = state.copyWith(quantities: next, clearError: true);
    _schedulePreview();
  }

  /// Points the draft at a plan document that already exists, WITHOUT adopting
  /// its numbers.
  ///
  /// For a screen that shows today's saved plan as a target rather than as an
  /// entry: a later `save()` has to update that same document instead of filing
  /// a second plan for the same day, but the planned quantities must not become
  /// something a single tap can post as produced stock.
  void attachSavedPlan(String name) {
    if (name.isEmpty || state.savedPlanName == name) return;
    state = state.copyWith(savedPlanName: name);
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

  /// Files the day's plan, on [planDate] when the tab has been back-dated.
  ///
  /// The saved name is reused ONLY while it still belongs to the day being
  /// saved. `save_plan` ignores `plan_date` whenever a name is passed, so
  /// reusing it across a date change would quietly write yesterday's run into
  /// today's document — the stock entry on one day and the intent on another,
  /// which is exactly what the evening comparison then gets wrong. With no
  /// name, the backend finds or creates that day's own plan.
  Future<DailyPlan> save({String? status, String? planDate}) async {
    final date = _dateOnly(planDate);
    final reuseName = date == null || date == state.savedPlanDate;

    final plan = await ref.read(dailyPlanServiceProvider).save(
          quantities: state.quantities,
          name: reuseName ? state.savedPlanName : null,
          planDate: date,
          status: status,
        );
    state = DailyPlanDraft(
      quantities: state.quantities,
      preview: state.preview,
      calculating: state.calculating,
      error: state.error,
      savedPlanName: plan.name,
      savedPlanDate: _dateOnly(plan.planDate) ?? date ?? state.savedPlanDate,
    );
    return plan;
  }

  /// `yyyy-MM-dd`, dropping any clock time the posting date carries.
  static String? _dateOnly(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    return text.length >= 10 ? text.substring(0, 10) : text;
  }

  /// Calls off the saved plan and empties the form.
  ///
  /// The draft is cleared rather than left showing the quantities that were
  /// just cancelled: the point of cancelling is that the day gets planned
  /// again from scratch, and leaving the old numbers on screen invites them to
  /// be re-saved unchanged. The template is invalidated too, so
  /// `existingPlan` no longer points at the cancelled document.
  Future<DailyPlan> cancel(String reason) async {
    final name = state.savedPlanName;
    if (name == null || name.isEmpty) {
      throw StateError('No saved plan to cancel');
    }
    final plan = await ref.read(dailyPlanServiceProvider).cancel(
          name: name,
          reason: reason,
        );
    clear();
    ref.invalidate(dailyPlanTemplateProvider);
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
