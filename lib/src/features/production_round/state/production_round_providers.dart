import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/production_round.dart';
import '../data/production_round_service.dart';

/// The planning knobs the owner may turn from the tune sheet. A null field
/// means "the server's default", so an untouched screen never pins a number
/// the backend has since changed.
class ProductionRoundParams {
  const ProductionRoundParams({
    this.cycleDays,
    this.backupDays,
    this.salesWeeks,
  });

  final int? cycleDays;
  final int? backupDays;
  final int? salesWeeks;

  bool get isDefault =>
      cycleDays == null && backupDays == null && salesWeeks == null;

  ProductionRoundParams copyWith({
    int? cycleDays,
    int? backupDays,
    int? salesWeeks,
  }) {
    return ProductionRoundParams(
      cycleDays: cycleDays ?? this.cycleDays,
      backupDays: backupDays ?? this.backupDays,
      salesWeeks: salesWeeks ?? this.salesWeeks,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ProductionRoundParams &&
      other.cycleDays == cycleDays &&
      other.backupDays == backupDays &&
      other.salesWeeks == salesWeeks;

  @override
  int get hashCode => Object.hash(cycleDays, backupDays, salesWeeks);
}

final productionRoundParamsProvider =
    StateProvider.autoDispose<ProductionRoundParams>(
      (ref) => const ProductionRoundParams(),
    );

/// The round itself. Not polled: the figures move with the day's sales and a
/// plan that reshuffles while someone is reading it is worse than one that is
/// ten minutes old. Refresh is explicit (app bar, pull-to-refresh).
final productionRoundProvider = FutureProvider.autoDispose<ProductionRound>((
  ref,
) {
  final params = ref.watch(productionRoundParamsProvider);
  return ref
      .watch(productionRoundServiceProvider)
      .getRound(
        cycleDays: params.cycleDays,
        backupDays: params.backupDays,
        salesWeeks: params.salesWeeks,
      );
});
