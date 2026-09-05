import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../models/purchase_request_models.dart';
import '../../state/purchase_request_notifier.dart';

/// What the buyer takes away from the sheet: an item, the quantity they
/// actually decided to buy, and the request lines that quantity should be
/// credited against.
class RequestPurchaseSelection {
  final RequestDemandLine demand;
  final double qty;

  const RequestPurchaseSelection({required this.demand, required this.qty});
}

/// The consolidated buying list.
///
/// Real purchasing software never buys request-by-request — it sums demand per
/// item first, so one order covers everyone who asked. Without the roll-up the
/// default outcome is three separate orders for the same item.
///
/// Quantities arrive pre-filled with what is still outstanding and are freely
/// editable: buying more or less than was asked for is the normal case, not an
/// exception, and the sheet is built around that.
class BuyFromRequestsSheet extends ConsumerStatefulWidget {
  const BuyFromRequestsSheet({super.key});

  static Future<List<RequestPurchaseSelection>?> show(BuildContext context) {
    return showModalBottomSheet<List<RequestPurchaseSelection>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BuyFromRequestsSheet(),
    );
  }

  @override
  ConsumerState<BuyFromRequestsSheet> createState() =>
      _BuyFromRequestsSheetState();
}

class _BuyFromRequestsSheetState extends ConsumerState<BuyFromRequestsSheet> {
  /// item_code -> quantity the buyer settled on. Absent means not selected.
  final Map<String, double> _selected = {};
  final Map<String, TextEditingController> _controllers = {};
  final Set<String> _expanded = {};
  bool _seeded = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Everything starts selected at its outstanding quantity — the buyer is here
  /// to buy the list, so opting *out* is the rarer action.
  void _seed(List<RequestDemandLine> lines) {
    if (_seeded) return;
    _seeded = true;
    for (final line in lines) {
      _selected[line.itemCode] = line.outstandingQty;
      _controllers[line.itemCode] =
          TextEditingController(text: _fmtQty(line.outstandingQty));
    }
  }

  String _fmtQty(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

  void _toggle(RequestDemandLine line, bool selected) {
    setState(() {
      if (selected) {
        _selected[line.itemCode] = line.outstandingQty;
        _controllers[line.itemCode]?.text = _fmtQty(line.outstandingQty);
      } else {
        _selected.remove(line.itemCode);
      }
    });
  }

  void _submit(List<RequestDemandLine> lines) {
    final selections = <RequestPurchaseSelection>[];
    for (final line in lines) {
      final qty = _selected[line.itemCode];
      if (qty == null || qty <= 0) continue;
      selections.add(RequestPurchaseSelection(demand: line, qty: qty));
    }
    Navigator.of(context).pop(selections);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final demand = ref.watch(openDemandProvider);

    return DraggableScrollableSheet(
      initialChildSize: ResponsiveUtils.getCartBottomSheetInitialSize(context),
      minChildSize: ResponsiveUtils.getCartBottomSheetMinSize(context),
      maxChildSize: ResponsiveUtils.getCartBottomSheetMaxSize(context),
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(l10n.purchaseFromRequestsTitle,
                          style: theme.textTheme.titleMedium),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: demand.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        context.userErrorMessage(error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  data: (lines) {
                    if (lines.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.purchaseFromRequestsEmpty,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.outline),
                        ),
                      );
                    }
                    _seed(lines);
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      itemCount: lines.length + 1,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              l10n.purchaseFromRequestsHint,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: theme.colorScheme.outline),
                            ),
                          );
                        }
                        return _demandTile(context, lines[index - 1]);
                      },
                    );
                  },
                ),
              ),
              demand.maybeWhen(
                data: (lines) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    12 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _selected.isEmpty ? null : () => _submit(lines),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(
                        l10n.purchaseAddSelected('${_selected.length}'),
                      ),
                    ),
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _demandTile(BuildContext context, RequestDemandLine line) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isSelected = _selected.containsKey(line.itemCode);
    final controller = _controllers.putIfAbsent(
      line.itemCode,
      () => TextEditingController(text: _fmtQty(line.outstandingQty)),
    );
    final chosen = _selected[line.itemCode] ?? 0;
    final deviates = isSelected && (chosen - line.outstandingQty).abs() > 0.0001;
    final isExpanded = _expanded.contains(line.itemCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) => _toggle(line, value ?? false),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            line.itemName,
                            style: theme.textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (line.isUrgent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l10n.purchaseUrgent,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Everything the buyer needs to price the line without
                    // leaving the sheet.
                    Wrap(
                      spacing: 10,
                      children: [
                        Text(
                          l10n.purchaseRequestedQty(
                              '${_fmtQty(line.outstandingQty)} ${line.stockUom}'),
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          l10n.purchaseOnHand(_fmtQty(line.onHandQty)),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.outline),
                        ),
                        if (line.lastPurchaseRate > 0)
                          Text(
                            l10n.purchaseLastPaid(
                                line.lastPurchaseRate.toStringAsFixed(2)),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.outline),
                          ),
                        if (line.earliestNeededBy != null)
                          Text(
                            l10n.purchaseNeededBy(
                              DateFormat('MMM d').format(line.earliestNeededBy!),
                            ),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.outline),
                          ),
                      ],
                    ),
                    if (deviates)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          l10n.purchaseBuyingLess(
                            _fmtQty(line.outstandingQty),
                            _fmtQty(chosen),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (line.branches.length > 1)
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => setState(() {
                          if (isExpanded) {
                            _expanded.remove(line.itemCode);
                          } else {
                            _expanded.add(line.itemCode);
                          }
                        }),
                        child: Text(
                          '${l10n.purchaseRequestSources}: ${line.branches.join(', ')}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 72,
                child: TextField(
                  controller: controller,
                  enabled: isSelected,
                  textAlign: TextAlign.center,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(isDense: true),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed == null) return;
                    setState(() => _selected[line.itemCode] = parsed);
                  },
                ),
              ),
            ],
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 48, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final source in line.sources)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Text(
                      '${source.posProfile ?? '—'} · '
                      '${_fmtQty(source.outstandingQty)} ${line.stockUom} · '
                      '${source.requestedBy}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
