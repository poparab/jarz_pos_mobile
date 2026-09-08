import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/manufacturing_service.dart';
import '../data/models/base_item.dart';
import '../data/models/basket_rollup.dart';
import '../data/models/daily_plan.dart';
import 'base_production_providers.dart';
import 'daily_plan_providers.dart';

/// One line's answer from `produce_now`.
class ProduceLineOutcome {
  const ProduceLineOutcome({
    required this.itemCode,
    required this.ok,
    this.error,
  });

  final String itemCode;
  final bool ok;

  /// The server's own words. Never replaced by a generic message: "BOM has no
  /// operations" and "insufficient stock in WIP" need different actions from
  /// the person holding the tablet.
  final String? error;
}

/// What one Make attempt did, in enough detail for the screen to report it
/// line by line and to keep the failures on screen for a retry.
@immutable
class ProduceReport {
  const ProduceReport({
    this.outcomes = const <ProduceLineOutcome>[],
    this.shortages = const <RollupComponent>[],
    this.attempted = 0,
    this.baseError,
    this.jarError,
    this.jarsSkipped = false,
    this.planSaveFailed = false,
    this.nothingToDo = false,
  });

  final List<ProduceLineOutcome> outcomes;

  /// `basket_shortages` from either stage, rendered through the pick-list
  /// presentation the Batch tab already uses.
  final List<RollupComponent> shortages;

  /// How many lines were actually sent, across both stages.
  final int attempted;

  /// A transport-level failure of the bases call (and of the jars call), kept
  /// raw so the screen can run it through `userErrorMessage`.
  final Object? baseError;
  final Object? jarError;

  /// The bases stage did not come out clean, so the jars were never sent.
  final bool jarsSkipped;

  /// The by-product save failed. Reported as a footnote and never as a
  /// production failure: the stock entries are already posted.
  final bool planSaveFailed;

  /// Nothing was typed. The button is disabled in that state, so this only
  /// guards a race.
  final bool nothingToDo;

  List<ProduceLineOutcome> get failures =>
      outcomes.where((o) => !o.ok).toList(growable: false);

  int get producedCount => outcomes.where((o) => o.ok).length;

  Set<String> get succeededItemCodes => {
    for (final outcome in outcomes)
      if (outcome.ok && outcome.itemCode.isNotEmpty) outcome.itemCode,
  };

  /// True when nothing at all reached the ledger — the screen then leads with
  /// the failure rather than with a count.
  bool get producedNothing => producedCount == 0;

  ProduceReport copyWith({
    List<ProduceLineOutcome>? outcomes,
    List<RollupComponent>? shortages,
    int? attempted,
    Object? baseError,
    Object? jarError,
    bool? jarsSkipped,
    bool? planSaveFailed,
    bool? nothingToDo,
  }) {
    return ProduceReport(
      outcomes: outcomes ?? this.outcomes,
      shortages: shortages ?? this.shortages,
      attempted: attempted ?? this.attempted,
      baseError: baseError ?? this.baseError,
      jarError: jarError ?? this.jarError,
      jarsSkipped: jarsSkipped ?? this.jarsSkipped,
      planSaveFailed: planSaveFailed ?? this.planSaveFailed,
      nothingToDo: nothingToDo ?? this.nothingToDo,
    );
  }
}

/// The base batch counts typed on the Today screen.
///
/// Deliberately NOT `baseBatchDraftProvider`: that one starts every card at one
/// batch and fires a `preview_base_batch` per keystroke, both of which are
/// exactly what this screen removes. Jar quantities are not duplicated here —
/// they stay in `dailyPlanDraftProvider`, which already debounces the mixer
/// split and owns `save_plan`.
@immutable
class ProductionTodayDraft {
  const ProductionTodayDraft({
    this.baseBatches = const <String, double>{},
    this.submitting = false,
  });

  /// Batches, not units. The mixer is the unit of work on a base, and
  /// `batch_yield` is the only bridge back to a stock quantity.
  final Map<String, double> baseBatches;

  final bool submitting;

  bool get hasBases => baseBatches.values.any((v) => v > 0);

  ProductionTodayDraft copyWith({
    Map<String, double>? baseBatches,
    bool? submitting,
  }) {
    return ProductionTodayDraft(
      baseBatches: baseBatches ?? this.baseBatches,
      submitting: submitting ?? this.submitting,
    );
  }
}

final productionTodayProvider =
    NotifierProvider<ProductionTodayNotifier, ProductionTodayDraft>(
      ProductionTodayNotifier.new,
    );

class ProductionTodayNotifier extends Notifier<ProductionTodayDraft> {
  @override
  ProductionTodayDraft build() => const ProductionTodayDraft();

  void setBaseBatches(String itemCode, double batches) {
    final next = Map<String, double>.from(state.baseBatches);
    if (batches <= 0) {
      next.remove(itemCode);
    } else {
      next[itemCode] = batches;
    }
    state = state.copyWith(baseBatches: next);
  }

  void clear() => state = const ProductionTodayDraft();

  /// Books what came out, bases first and jars second.
  ///
  /// **The order is load-bearing and the two calls must not be merged.** Jars
  /// consume the mix the bases produce, so one combined basket would be refused
  /// by the basket-wide precheck (`strict_basket`) for material that is about
  /// to exist. Jars are only sent once every base line has come back produced —
  /// filling jars against mix that was never made is the accounting hole this
  /// ordering closes.
  Future<ProduceReport> produce({required String scheduledAt}) async {
    if (state.submitting) return const ProduceReport(nothingToDo: true);

    final baseLines = _baseLines(scheduledAt);
    final jarQuantities = Map<String, int>.from(
      ref.read(dailyPlanDraftProvider).quantities,
    )..removeWhere((_, qty) => qty <= 0);
    final jarLines = _jarLines(jarQuantities, scheduledAt);

    if (baseLines.isEmpty && jarLines.isEmpty) {
      return const ProduceReport(nothingToDo: true);
    }

    state = state.copyWith(submitting: true);
    final service = ref.read(manufacturingServiceProvider);
    var report = const ProduceReport();

    try {
      if (baseLines.isNotEmpty) {
        report = report.copyWith(attempted: report.attempted + baseLines.length);
        try {
          final response = await service.produceNow(
            baseLines,
            strictBasket: true,
          );
          report = _merge(report, response);
        } catch (error) {
          report = report.copyWith(baseError: error);
        }

        // Every base line has to be back as produced before a jar is filled.
        // A partial bases stage is a stop, not a warning: the mix for the
        // missing base does not exist, and the jars that need it would post
        // against stock nobody made.
        final basesProduced = report.producedCount;
        final basesClean =
            report.baseError == null &&
            report.failures.isEmpty &&
            basesProduced == baseLines.length;
        if (!basesClean) {
          return report.copyWith(jarsSkipped: jarLines.isNotEmpty);
        }
      }

      if (jarLines.isNotEmpty) {
        report = report.copyWith(attempted: report.attempted + jarLines.length);
        try {
          final response = await service.produceNow(
            jarLines,
            strictBasket: true,
          );
          report = _merge(report, response);
        } catch (error) {
          report = report.copyWith(jarError: error);
        }
      }

      // The plan record falls out of the day's work rather than being a second
      // chore: whoever recorded production has already typed the numbers a
      // plan is made of. Best effort by design — production is posted, and a
      // failed bookkeeping save must never read as a failed batch.
      if (jarQuantities.isNotEmpty && report.producedCount > 0) {
        try {
          await ref
              .read(dailyPlanDraftProvider.notifier)
              .save(status: 'Planned');
        } catch (_) {
          report = report.copyWith(planSaveFailed: true);
        }
      }

      _clearSucceeded(report.succeededItemCodes, jarQuantities);
      return report;
    } finally {
      state = state.copyWith(submitting: false);
    }
  }

  /// Saves the typed jar numbers for later without posting anything.
  ///
  /// The morning half of the screen: the numbers survive to the evening and
  /// feed the "needed today" hint on the bases above.
  Future<DailyPlan> savePlanForLater() {
    return ref.read(dailyPlanDraftProvider.notifier).save(status: 'Planned');
  }

  /// Base rows are typed in batches; the endpoint takes a quantity. This is the
  /// one place the two are converted, exactly as `BaseItemCard` does it.
  List<Map<String, dynamic>> _baseLines(String scheduledAt) {
    final page = ref.read(baseItemsProvider).valueOrNull;
    final byCode = <String, BaseItem>{
      for (final item in page?.items ?? const <BaseItem>[])
        item.itemCode: item,
    };

    final lines = <Map<String, dynamic>>[];
    for (final entry in state.baseBatches.entries) {
      if (entry.value <= 0) continue;
      final item = byCode[entry.key];
      if (item == null) continue;
      lines.add({
        'item_code': item.itemCode,
        if (item.defaultBom.isNotEmpty) 'bom_name': item.defaultBom,
        'item_qty': entry.value * item.safeBatchYield,
        'scheduled_at': scheduledAt,
      });
    }
    return lines;
  }

  List<Map<String, dynamic>> _jarLines(
    Map<String, int> quantities,
    String scheduledAt,
  ) {
    final template = ref.read(dailyPlanTemplateProvider).valueOrNull;
    final byCode = <String, DailyPlanItem>{
      for (final item in template?.items ?? const <DailyPlanItem>[])
        item.itemCode: item,
    };

    final lines = <Map<String, dynamic>>[];
    for (final entry in quantities.entries) {
      if (entry.value <= 0) continue;
      final item = byCode[entry.key];
      final bom = item?.defaultBom ?? '';
      lines.add({
        'item_code': entry.key,
        if (bom.isNotEmpty) 'bom_name': bom,
        // Jars are counted in units already — no conversion, and none invented.
        'item_qty': entry.value.toDouble(),
        'scheduled_at': scheduledAt,
      });
    }
    return lines;
  }

  /// Succeeded rows are emptied so the next entry starts clean; failed rows
  /// keep their numbers, because the only thing to do with a failure here is
  /// fix it and press Make again.
  void _clearSucceeded(Set<String> succeeded, Map<String, int> jarQuantities) {
    if (succeeded.isEmpty) return;

    final nextBases = Map<String, double>.from(state.baseBatches)
      ..removeWhere((code, _) => succeeded.contains(code));
    state = state.copyWith(baseBatches: nextBases);

    final draft = ref.read(dailyPlanDraftProvider.notifier);
    for (final code in succeeded) {
      if (jarQuantities.containsKey(code)) draft.setQuantity(code, 0);
    }
  }

  ProduceReport _merge(ProduceReport report, Map<String, dynamic> response) {
    return report.copyWith(
      outcomes: [...report.outcomes, ...parseProduceResults(response)],
      shortages: [...report.shortages, ...parseBasketShortages(response)],
    );
  }
}

/// Reads the `{"results": [...]}` envelope both `produce_now` and
/// `submit_work_orders` answer with.
///
/// A row counts as produced when the server says `ok` OR named a Work Order:
/// the two endpoints have historically disagreed on which of those they set,
/// and reading only one of them silently turned successes into failures.
List<ProduceLineOutcome> parseProduceResults(Map<String, dynamic> response) {
  final rows = (response['results'] as List?) ?? const [];
  final outcomes = <ProduceLineOutcome>[];

  for (final entry in rows) {
    if (entry is! Map) continue;
    final row = Map<String, dynamic>.from(entry);
    final line = row['line'] is Map
        ? Map<String, dynamic>.from(row['line'] as Map)
        : const <String, dynamic>{};
    final itemCode = '${line['item_code'] ?? row['item_code'] ?? ''}';
    final ok =
        row['ok'] == true || '${row['work_order'] ?? ''}'.trim().isNotEmpty;

    outcomes.add(
      ProduceLineOutcome(
        itemCode: itemCode,
        ok: ok,
        error: ok ? null : '${row['error'] ?? ''}'.trim(),
      ),
    );
  }
  return outcomes;
}

/// Reads `basket_shortages` into the same model the pick list already renders.
///
/// Malformed rows are dropped rather than thrown on: the shortages are an
/// explanation attached to a result that has already been decided, and losing
/// the whole report to one unparsable component would hide it.
List<RollupComponent> parseBasketShortages(Map<String, dynamic> response) {
  final rows = (response['basket_shortages'] as List?) ?? const [];
  final components = <RollupComponent>[];

  for (final entry in rows) {
    if (entry is! Map) continue;
    try {
      components.add(
        RollupComponent.fromJson(Map<String, dynamic>.from(entry)),
      );
    } catch (_) {
      continue;
    }
  }
  return components;
}
