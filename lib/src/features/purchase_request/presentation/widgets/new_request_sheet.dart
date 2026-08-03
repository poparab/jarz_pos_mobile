import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/purchase_request_repository.dart';
import '../../models/purchase_request_models.dart';
import '../../state/purchase_request_notifier.dart';

/// Raise a request. Deliberately the thinnest screen in the feature: search,
/// tap, set a number, send. If asking for stock costs more effort than
/// shouting across the kitchen, nobody uses it and the buying list stays empty.
class NewRequestSheet extends ConsumerStatefulWidget {
  const NewRequestSheet({super.key});

  static Future<ItemRequest?> show(BuildContext context) {
    return showModalBottomSheet<ItemRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NewRequestSheet(),
    );
  }

  @override
  ConsumerState<NewRequestSheet> createState() => _NewRequestSheetState();
}

class _NewRequestSheetState extends ConsumerState<NewRequestSheet> {
  final _searchController = TextEditingController();
  final _noteController = TextEditingController();
  final List<DraftRequestLine> _lines = [];

  Timer? _debounce;
  /// Monotonic token that lets a slow response for an older query be discarded.
  /// Without it, results for "ah" can land after "ahmed" and overwrite them.
  int _searchToken = 0;
  List<Map<String, dynamic>> _results = const [];
  bool _searching = false;
  DateTime? _neededBy;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    // One request per keystroke is what the old purchase screen did; 300ms of
    // quiet is the difference between ~20 calls and ~2 for a typed word.
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(query));
  }

  Future<void> _search(String query) async {
    final token = ++_searchToken;
    setState(() => _searching = true);
    try {
      final results =
          await ref.read(purchaseRequestRepositoryProvider).searchItems(query);
      if (!mounted || token != _searchToken) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    } catch (_) {
      if (!mounted || token != _searchToken) return;
      setState(() {
        _results = const [];
        _searching = false;
      });
    }
  }

  void _addItem(Map<String, dynamic> item) {
    final code = (item['item_code'] ?? '').toString();
    if (code.isEmpty) return;
    final existing = _lines.indexWhere((l) => l.itemCode == code);
    setState(() {
      if (existing >= 0) {
        // Tapping the same item again bumps the quantity instead of creating a
        // duplicate line the buyer would then have to merge by hand.
        _lines[existing] =
            _lines[existing].copyWith(qty: _lines[existing].qty + 1);
      } else {
        _lines.add(DraftRequestLine(
          itemCode: code,
          itemName: (item['item_name'] ?? code).toString(),
          uom: (item['stock_uom'] ?? '').toString(),
          qty: 1,
        ));
      }
    });
  }

  void _changeQty(int index, double delta) {
    final next = _lines[index].qty + delta;
    setState(() {
      if (next <= 0) {
        _lines.removeAt(index);
      } else {
        _lines[index] = _lines[index].copyWith(qty: next);
      }
    });
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final created =
        await ref.read(purchaseRequestNotifierProvider.notifier).submitRequest(
              items: _lines,
              scheduleDate: _neededBy == null
                  ? null
                  : DateFormat('yyyy-MM-dd').format(_neededBy!),
              note: _noteController.text,
            );

    if (!mounted) return;
    if (created == null) {
      final error = ref.read(purchaseRequestNotifierProvider).error ?? '';
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.requestsSubmitFailed(error))),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.requestsSubmitted(created.name))),
    );
    navigator.pop(created);
  }

  String _fmtQty(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isSubmitting =
        ref.watch(purchaseRequestNotifierProvider).isSubmitting;

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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Text(l10n.requestsNewTitle,
                        style: theme.textTheme.titleMedium),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.commonSearchItems,
                    suffixIcon: _searching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 8),
                    if (_lines.isNotEmpty) ...[
                      for (var i = 0; i < _lines.length; i++)
                        _draftTile(context, i),
                      const Divider(height: 24),
                    ],
                    if (_results.isEmpty && _lines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            l10n.requestsNoItemsYet,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                      ),
                    for (final item in _results) _resultTile(context, item),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  12 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event_outlined,
                            size: 18, color: theme.colorScheme.outline),
                        const SizedBox(width: 6),
                        Text(l10n.requestsNeededBy),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: now,
                              lastDate: now.add(const Duration(days: 365)),
                              initialDate: _neededBy ??
                                  now.add(const Duration(days: 3)),
                            );
                            if (picked != null) {
                              setState(() => _neededBy = picked);
                            }
                          },
                          child: Text(
                            _neededBy == null
                                ? l10n.commonChoose
                                : DateFormat('MMM d').format(_neededBy!),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      minLines: 1,
                      decoration: InputDecoration(
                        labelText: l10n.requestsNoteLabel,
                        hintText: l10n.requestsNoteHint,
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            _lines.isEmpty || isSubmitting ? null : _submit,
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        label: Text(l10n.requestsSubmit),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _draftTile(BuildContext context, int index) {
    final theme = Theme.of(context);
    final line = _lines[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line.itemName,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis),
                  Text(line.uom,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline)),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => _changeQty(index, -1),
            ),
            SizedBox(
              width: 44,
              child: Text(
                _fmtQty(line.qty),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall,
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _changeQty(index, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultTile(BuildContext context, Map<String, dynamic> item) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final code = (item['item_code'] ?? '').toString();
    final onHand = (item['on_hand_qty'] is num)
        ? (item['on_hand_qty'] as num).toDouble()
        : 0.0;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text((item['item_name'] ?? code).toString()),
      subtitle: Text(
        // Showing stock here stops the most common wasteful request: asking
        // for something the branch already has.
        '${item['stock_uom'] ?? ''} · ${l10n.purchaseOnHand(_fmtQty(onHand))}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle),
        color: theme.colorScheme.primary,
        onPressed: () => _addItem(item),
      ),
      onTap: () => _addItem(item),
    );
  }
}
