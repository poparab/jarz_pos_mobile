import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../manager/state/manager_providers.dart';
import '../data/stock_transfer_service.dart';

class StockTransferScreen extends ConsumerStatefulWidget {
  const StockTransferScreen({super.key});

  @override
  ConsumerState<StockTransferScreen> createState() => _StockTransferScreenState();
}

class _StockTransferScreenState extends ConsumerState<StockTransferScreen> {
  String? sourceProfile;
  String? targetProfile;
  String? sourceWarehouse;
  String? targetWarehouse;
  String? itemGroup;
  String search = '';
  DateTime? postingDate; // null => today

  // Keep the latest search results to enable bulk-add/select-all actions
  List<Map<String, dynamic>> currentItems = [];

  final List<Map<String, dynamic>> lines = [];

  @override
  void dispose() {
    for (final l in lines) {
      try {
        (l['qtyCtrl'] as TextEditingController?)?.dispose();
      } catch (e, stack) {
        debugPrint('StockTransferScreen dispose error: $e');
        debugPrintStack(stackTrace: stack);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(managerAccessProvider).maybeWhen(data: (v) => v, orElse: () => false);
    if (!allowed) {
      return Scaffold(appBar: AppBar(title: const Text('Stock Transfer')), body: const Center(child: Text('Managers only')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Transfer')),
      drawer: const AppDrawer(),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildBranchSelectors(),
                const SizedBox(height: 8),
                _buildDatePickerRow(),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search items'),
                      onChanged: (v) => setState(() => search = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _GroupPicker(
                    onPicked: (g) => setState(() => itemGroup = g),
                    initial: itemGroup,
                  ),
                  const SizedBox(width: 8),
                  _BulkActionsButton(
                    onAddAll: _onAddAllResults,
                    onAddGroup: itemGroup == null ? null : _onAddGroup,
                  ),
                ]),
                const SizedBox(height: 8),
                Expanded(child: _buildItemResults()),
              ]),
            ),
          ),
          Container(width: 1, color: Colors.grey.shade300),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.inventory_2),
                  const SizedBox(width: 8),
                  Text('Transfer Lines (${lines.length})', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  if (postingDate != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(label: Text('Posting: ${DateFormat('yyyy-MM-dd').format(postingDate!)}')),
                    ),
                  ElevatedButton.icon(
                    onPressed: _canSubmit() ? _submit : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Submit'),
                  )
                ]),
                const SizedBox(height: 8),
                Expanded(child: _buildLinesList()),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    if (sourceWarehouse == null || targetWarehouse == null) return false;
    if (sourceWarehouse == targetWarehouse) return false;
    return lines.any((l) => ((l['qty'] as num?)?.toDouble() ?? 0) > 0);
  }

  Widget _buildBranchSelectors() {
    final service = ref.read(stockTransferServiceProvider);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: service.listPosProfiles(),
      builder: (context, snap) {
        final profiles = snap.data ?? [];
        // compute invalid pair warning
        final sameProfile = sourceProfile != null && targetProfile != null && sourceProfile == targetProfile;
        return Row(children: [
          Expanded(child: _profileDropdown('Source', profiles, sourceProfile, (v) {
            setState(() {
              sourceProfile = v;
              sourceWarehouse = profiles.firstWhere((p) => p['name'] == v, orElse: () => const {})['warehouse'] as String?;
              // If same selection occurs, clear target to force reselect
              if (targetProfile == sourceProfile) {
                targetProfile = null;
                targetWarehouse = null;
              }
            });
          })),
          const SizedBox(width: 8),
          Expanded(child: _profileDropdown('Target', profiles, targetProfile, (v) {
            setState(() {
              targetProfile = v;
              targetWarehouse = profiles.firstWhere((p) => p['name'] == v, orElse: () => const {})['warehouse'] as String?;
              if (targetProfile == sourceProfile) {
                // prevent same profile; revert selection
                targetProfile = null;
                targetWarehouse = null;
              }
            });
          })),
          if (sameProfile) ...[
            const SizedBox(width: 8),
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 4),
            const Text('Source and Target must differ', style: TextStyle(color: Colors.red)),
          ]
        ]);
      },
    );
  }

  Widget _profileDropdown(String label, List<Map<String, dynamic>> profiles, String? value, ValueChanged<String?> onChanged) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: const Text('Select POS Profile'),
          items: [
            for (final p in profiles)
              DropdownMenuItem<String>(
                value: p['name'] as String,
                child: Text('${p['name']} • ${p['warehouse'] ?? 'No WH'}'),
              )
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildItemResults() {
    if (sourceWarehouse == null || targetWarehouse == null) {
      return const Center(child: Text('Select source and target branches'));
    }
    if (sourceProfile != null && targetProfile != null && sourceProfile == targetProfile) {
      return const Center(child: Text('Source and Target cannot be the same')); 
    }
    final service = ref.read(stockTransferServiceProvider);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: service.searchItemsWithStock(
        sourceWarehouse: sourceWarehouse!,
        targetWarehouse: targetWarehouse!,
        search: search.isEmpty ? null : search,
        itemGroup: itemGroup,
      ),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        final items = snap.data ?? [];
        // Save for bulk actions
        currentItems = items;
        if (items.isEmpty) return const Center(child: Text('No items'));
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final it = items[i];
            final code = it['item_code'];
            final name = it['item_name'] ?? code;
            final src = (it['qty_source'] as num?)?.toDouble() ?? 0;
            final dst = (it['qty_target'] as num?)?.toDouble() ?? 0;
            final reservedSrc = (it['reserved_source'] as num?)?.toDouble() ?? 0;
            final reservedDst = (it['reserved_target'] as num?)?.toDouble() ?? 0;
            final isPos = (it['pos_item'] == 1);
            return ListTile(
              title: Text('$name ($code)'),
              subtitle: Text(
                'Src: $src • Dst: $dst'
                '${reservedSrc > 0 ? ' • Res Src: $reservedSrc' : ''}'
                '${reservedDst > 0 ? ' • Res Dst: $reservedDst' : ''}'
                '${isPos ? ' • POS' : ''}',
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  setState(() {
                    lines.add({
                      'item_code': code,
                      'item_name': name,
                      'uom': it['stock_uom'] ?? 'Nos',
                      'src_before': src,
                      'dst_before': dst,
                      'reserved_src': reservedSrc,
                      'reserved_dst': reservedDst,
                      'qty': 1.0,
                      'qtyCtrl': TextEditingController(text: '1.00'),
                    });
                  });
                },
                child: const Text('Add'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDatePickerRow() {
    final label = postingDate == null
        ? 'Posting Date: Today'
        : 'Posting Date: ${DateFormat('yyyy-MM-dd').format(postingDate!)}';
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            final now = DateTime.now();
            final initial = postingDate ?? now;
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(now.year - 5),
              lastDate: DateTime(now.year + 5),
            );
            if (picked != null) {
              setState(() => postingDate = DateTime(picked.year, picked.month, picked.day));
            }
          },
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(label),
        ),
        if (postingDate != null) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Use Today',
            onPressed: () => setState(() => postingDate = null),
            icon: const Icon(Icons.close),
          ),
        ]
      ],
    );
  }

  Widget _buildLinesList() {
    if (lines.isEmpty) return const Center(child: Text('No lines'));
    return ListView.separated(
      itemCount: lines.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final l = lines[i];
        final qty = (l['qty'] as num?)?.toDouble() ?? 0;
        final srcB = (l['src_before'] as num?)?.toDouble() ?? 0;
        final dstB = (l['dst_before'] as num?)?.toDouble() ?? 0;
        final reservedSrc = (l['reserved_src'] as num?)?.toDouble() ?? 0;
        final reservedDst = (l['reserved_dst'] as num?)?.toDouble() ?? 0;
        l['qtyCtrl'] ??= TextEditingController(text: qty.toStringAsFixed(2));
        final TextEditingController qtyCtrl = l['qtyCtrl'] as TextEditingController;
        final srcAfter = srcB - qty;
        final dstAfter = dstB + qty;
        return ListTile(
          title: Text('${l['item_name']} (${l['item_code']})'),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Before — Src: $srcB • Dst: $dstB'
        '${reservedSrc > 0 ? ' • Res Src: $reservedSrc' : ''}'
        '${reservedDst > 0 ? ' • Res Dst: $reservedDst' : ''}'),
            Text('After  — Src: ${srcAfter.toStringAsFixed(2)} • Dst: ${dstAfter.toStringAsFixed(2)}'),
            const SizedBox(height: 6),
            Row(children: [
              const Text('Qty:'),
              const SizedBox(width: 6),
              SizedBox(
                width: 28, height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    double newQty = qty - 1;
                    if (newQty < 0) newQty = 0;
                    setState(() { l['qty'] = newQty; qtyCtrl.text = newQty.toStringAsFixed(2); });
                  },
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 90,
                child: TextFormField(
                  controller: qtyCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) {
                    final q = double.tryParse(v) ?? qty; setState(() => l['qty'] = q);
                  },
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 28, height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add),
                  onPressed: () { final newQty = qty + 1; setState(() { l['qty'] = newQty; qtyCtrl.text = newQty.toStringAsFixed(2); }); },
                ),
              ),
            ]),
          ]),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() {
              try {
                (l['qtyCtrl'] as TextEditingController?)?.dispose();
              } catch (e, stack) {
                debugPrint('StockTransferScreen remove line dispose error: $e');
                debugPrintStack(stackTrace: stack);
              }
              lines.removeAt(i);
            }),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_canSubmit()) return;
    final service = ref.read(stockTransferServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final payload = [for (final l in lines) if (((l['qty'] as num?)?.toDouble() ?? 0) > 0) {'item_code': l['item_code'], 'qty': (l['qty'] as num).toDouble()}];
      final String? postingDateStr = postingDate == null ? null : DateFormat('yyyy-MM-dd').format(postingDate!);
      final res = await service.submitTransfer(
        sourceWarehouse: sourceWarehouse!,
        targetWarehouse: targetWarehouse!,
        lines: payload,
        postingDate: postingDateStr,
      );
      messenger.showSnackBar(SnackBar(content: Text('Transfer created: ${res['stock_entry']}')));
      if (!mounted) return;
      setState(() {
        for (final l in lines) {
          try {
            (l['qtyCtrl'] as TextEditingController?)?.dispose();
          } catch (e, stack) {
            debugPrint('StockTransferScreen submit dispose error: $e');
            debugPrintStack(stackTrace: stack);
          }
        }
        lines.clear();
      });
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _onAddAllResults() async {
    if (currentItems.isEmpty) return;
    final qty = await _promptBulkQty(context);
    if (qty == null || qty <= 0) return;
    setState(() {
      for (final it in currentItems) {
        _addOrIncrementLineFromItem(it, qty);
      }
    });
  }

  Future<void> _onAddGroup() async {
    if (itemGroup == null || sourceWarehouse == null || targetWarehouse == null) return;
    final qty = await _promptBulkQty(context);
    if (qty == null || qty <= 0) return;
    final service = ref.read(stockTransferServiceProvider);
    try {
      final items = await service.searchItemsWithStock(
        sourceWarehouse: sourceWarehouse!,
        targetWarehouse: targetWarehouse!,
        itemGroup: itemGroup,
      );
      if (!mounted) return;
      setState(() {
        for (final it in items) {
          _addOrIncrementLineFromItem(it, qty);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bulk add failed: $e')));
    }
  }

  void _addOrIncrementLineFromItem(Map<String, dynamic> it, double addQty) {
    final code = it['item_code'];
    final idx = lines.indexWhere((l) => l['item_code'] == code);
    final name = it['item_name'] ?? code;
    final src = (it['qty_source'] as num?)?.toDouble() ?? 0;
    final dst = (it['qty_target'] as num?)?.toDouble() ?? 0;
    final reservedSrc = (it['reserved_source'] as num?)?.toDouble() ?? 0;
    final reservedDst = (it['reserved_target'] as num?)?.toDouble() ?? 0;
    if (idx >= 0) {
      final l = lines[idx];
      final newQty = ((l['qty'] as num?)?.toDouble() ?? 0) + addQty;
      l['qty'] = newQty;
      (l['qtyCtrl'] as TextEditingController?)?.text = newQty.toStringAsFixed(2);
    } else {
      lines.add({
        'item_code': code,
        'item_name': name,
        'uom': it['stock_uom'] ?? 'Nos',
        'src_before': src,
        'dst_before': dst,
        'reserved_src': reservedSrc,
        'reserved_dst': reservedDst,
        'qty': addQty,
        'qtyCtrl': TextEditingController(text: addQty.toStringAsFixed(2)),
      });
    }
  }

  Future<double?> _promptBulkQty(BuildContext context) async {
    final ctrl = TextEditingController(text: '1.00');
    final res = await showDialog<double>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Quick quantity'),
          content: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Quantity for each item'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
            ElevatedButton(onPressed: () {
              final v = double.tryParse(ctrl.text.trim());
              Navigator.of(ctx).pop(v);
            }, child: const Text('Add')),
          ],
        );
      },
    );
    return res;
  }
}

class _GroupPicker extends ConsumerStatefulWidget {
  const _GroupPicker({required this.onPicked, this.initial});
  final ValueChanged<String?> onPicked;
  final String? initial;
  @override
  ConsumerState<_GroupPicker> createState() => _GroupPickerState();
}

class _GroupPickerState extends ConsumerState<_GroupPicker> {
  String? selected;
  List<Map<String, dynamic>> groups = const [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    selected = widget.initial;
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final service = ref.read(stockTransferServiceProvider);
      groups = await service.listItemGroups();
    } catch (e, stack) {
      debugPrint('StockTransferScreen group load error: $e');
      debugPrintStack(stackTrace: stack);
    }
    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String?>(
      hint: const Text('Item Group'),
      value: selected,
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('All Groups')),
        for (final g in groups)
          DropdownMenuItem<String?>(value: g['name'] as String, child: Text(g['name'] as String)),
      ],
      onChanged: (v) {
        setState(() => selected = v);
        widget.onPicked(v);
      },
    );
  }
}

class _BulkActionsButton extends StatelessWidget {
  const _BulkActionsButton({required this.onAddAll, this.onAddGroup});
  final VoidCallback onAddAll;
  final VoidCallback? onAddGroup;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: onAddAll,
          icon: const Icon(Icons.select_all),
          label: const Text('Add All'),
        ),
        const SizedBox(width: 6),
        OutlinedButton.icon(
          onPressed: onAddGroup,
          icon: const Icon(Icons.playlist_add),
          label: const Text('Add Group'),
        ),
      ],
    );
  }
}
