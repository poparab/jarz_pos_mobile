import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../manager/state/manager_providers.dart';
import '../data/inventory_count_service.dart';

class InventoryCountScreen extends ConsumerStatefulWidget {
  const InventoryCountScreen({super.key});

  @override
  ConsumerState<InventoryCountScreen> createState() => _InventoryCountScreenState();
}

class _InventoryCountScreenState extends ConsumerState<InventoryCountScreen> {
  String? _selectedWarehouse;
  DateTime _postingDate = DateTime.now();
  final TextEditingController _searchCtrl = TextEditingController();
  final Map<String, Map<String, dynamic>> _counts = {}; // item_code -> {qty,uom}
  final Set<String> _confirmed = <String>{};
  bool _enforceAll = true;
  bool _loading = false;
  List<Map<String, dynamic>> _items = [];
  Box<dynamic>? _box;

  void _debugLog(String message, [Object? data]) {
    assert(() {
      developer.log(
        data == null ? message : '$message: $data',
        name: 'InventoryCountScreen',
      );
      return true;
    }());
  }

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  @override
  void dispose() {
    _saveCache();
    _searchCtrl.dispose();
    super.dispose();
  }

  // Warehouses are fetched on demand via FutureBuilder

  Future<void> _loadItems() async {
    if (_selectedWarehouse == null) return;
    _counts.clear();
    _confirmed.clear();
    setState(() => _loading = true);
    // Try restore from cache immediately for smoother UX
    await _restoreCache();
    final service = ref.read(inventoryCountServiceProvider);
    try {
      final data = await service.listItemsForCount(
        warehouse: _selectedWarehouse!,
        search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      );
      setState(() {
        _items = data;
        _ensureDefaultCounts(data);
      });
      _saveCache();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Offline using cached data')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setCount(String itemCode, double qty, String? uom, {bool markConfirmed = true}) {
    _counts[itemCode] = {'qty': qty, 'uom': uom};
    if (markConfirmed) {
      _confirmed.add(itemCode);
    }
    _saveCache();
    setState(() {});
  }

  Future<void> _submit() async {
    if (_selectedWarehouse == null) return;
    final service = ref.read(inventoryCountServiceProvider);
    if (_enforceAll && _confirmed.length < _items.length) {
      final remaining = _items.length - _confirmed.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please confirm all items before submitting ($remaining remaining)')),
      );
      return;
    }
    final lines = _counts.entries
        .where((e) => _confirmed.contains(e.key))
        .map((e) {
          final item = _items.firstWhere(
            (it) => it['item_code'] == e.key,
            orElse: () => const <String, dynamic>{},
          );
          final vr = (item['valuation_rate'] as num?)?.toDouble();
          return {
            'item_code': e.key,
            'counted_qty': e.value['qty'] ?? 0,
            if (e.value['uom'] != null) 'uom': e.value['uom'],
            if (vr != null && vr > 0) 'valuation_rate': vr,
          };
        })
        .toList();
    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Confirm at least one item before submitting')));
      return;
    }
    try {
      setState(() => _loading = true);
      
      _debugLog('Submitting reconciliation', {
        'warehouse': _selectedWarehouse,
        'linesCount': lines.length,
        'lines': lines,
        'postingDate': DateFormat('yyyy-MM-dd').format(_postingDate),
        'enforceAll': _enforceAll,
      });
      
      final res = await service.submitReconciliation(
        warehouse: _selectedWarehouse!,
        lines: lines,
        postingDate: DateFormat('yyyy-MM-dd').format(_postingDate),
        enforceAll: _enforceAll,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submitted: ${res['stock_reconciliation'] ?? 'No differences'}')));
  _counts.clear();
  _confirmed.clear();
      await _loadItems();
    } catch (e) {
      if (!mounted) return;
  _debugLog('Submit reconciliation error', e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openBox() async {
    _box = await Hive.openBox('inventory_count');
  }

  String _itemsKey() => 'items:${_selectedWarehouse ?? ''}';
  String _countsKey() => 'counts:${_selectedWarehouse ?? ''}';
  String _dateKey() => 'posting_date:${_selectedWarehouse ?? ''}';
  String _confirmedKey() => 'confirmed:${_selectedWarehouse ?? ''}';

  void _saveCache() {
    if (_box == null || _selectedWarehouse == null) return;
    _box!.put(_itemsKey(), _items);
    _box!.put(_countsKey(), _counts);
    _box!.put(_dateKey(), DateFormat('yyyy-MM-dd').format(_postingDate));
    _box!.put(_confirmedKey(), _confirmed.toList());
  }

  Future<void> _restoreCache() async {
    if (_box == null || _selectedWarehouse == null) return;
    final cachedItems = _box!.get(_itemsKey());
    if (cachedItems is List) {
      _items = cachedItems.cast<Map<String, dynamic>>();
    }
    final cachedCounts = _box!.get(_countsKey());
    if (cachedCounts is Map) {
      _counts
        ..clear()
        ..addAll(cachedCounts.map((k, v) => MapEntry(k.toString(), Map<String, dynamic>.from(v as Map))));
    }
    final cachedConfirmed = _box!.get(_confirmedKey());
    _confirmed
      ..clear()
      ..addAll((cachedConfirmed is List ? cachedConfirmed : const <dynamic>[]).map((e) => e.toString()));
    _confirmed.removeWhere((code) => !_counts.containsKey(code));
    final cachedDate = _box!.get(_dateKey());
    if (cachedDate is String) {
      _postingDate = DateFormat('yyyy-MM-dd').parse(cachedDate);
    }
    setState(() {});
  }

  // Convert a qty in a chosen UOM to stock UOM using item's uoms list
  double _toStockQty(Map<String, dynamic> item, double qty, String? uom) {
    final stockUom = (item['stock_uom'] as String?) ?? '';
    if (uom == null || uom == stockUom) return qty;
    final uoms = (item['uoms'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final match = uoms.firstWhere(
      (e) => (e['uom'] as String?) == uom,
      orElse: () => const {'conversion_factor': 1},
    );
    final factor = (match['conversion_factor'] as num?)?.toDouble() ?? 1.0;
    return qty * factor;
  }

  Map<String, List<Map<String, dynamic>>> _groupByItemGroup() {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final it in _items) {
      final grp = (it['item_group'] as String?) ?? 'Uncategorized';
      (map[grp] ??= []).add(it);
    }
    return map;
  }

  void _ensureDefaultCounts(Iterable<Map<String, dynamic>> items) {
    for (final item in items) {
      final code = item['item_code'] as String?;
      if (code == null) {
        continue;
      }
      final stockUom = item['stock_uom'] as String?;
      final currentQty = (item['current_qty'] as num?)?.toDouble() ?? 0.0;
      final existing = _counts[code];
      if (existing == null) {
        _counts[code] = {
          'qty': currentQty,
          if (stockUom != null) 'uom': stockUom,
        };
      } else {
        if (!existing.containsKey('uom') && stockUom != null) {
          existing['uom'] = stockUom;
        }
      }
    }
    _confirmed.removeWhere((code) => !_counts.containsKey(code));
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(managerAccessProvider).maybeWhen(data: (v) => v, orElse: () => false);
    if (!allowed) {
      return const Scaffold(body: Center(child: Text('Manager access required')));
    }

    return WillPopScope(
      onWillPop: () async {
        if (!mounted) return true;
        context.go('/kanban');
        return false;
      },
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        title: const Text('Inventory Count'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadItems,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: ref.read(inventoryCountServiceProvider).listWarehouses(),
                    builder: (context, snap) {
                      final list = snap.data ?? [];
                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedWarehouse,
                        hint: const Text('Select Warehouse'),
                        items: list
                            .map((w) => DropdownMenuItem<String>(
                                  value: w['name'] as String,
                                  child: Text(w['name'] as String),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _selectedWarehouse = v);
                          _loadItems();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _postingDate,
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _postingDate = picked);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.date_range),
                      const SizedBox(width: 8),
                      Text(DateFormat('yyyy-MM-dd').format(_postingDate)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search items',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _loadItems();
                        },
                      ),
                    ),
                    onSubmitted: (_) => _loadItems(),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Enforce all'),
                    Switch(value: _enforceAll, onChanged: (v) => setState(() => _enforceAll = v)),
                  ],
                ),
              ],
            ),
          ),
          // Progress bar for partial counts
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: _items.isEmpty
                            ? 0.0
                            : _confirmed.length / _items.length,
                      ),
                      const SizedBox(height: 4),
                      Text('Confirmed ${_confirmed.length} / ${_items.length}')
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Clear all entered data',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    // Clear in-memory user entries
                    _counts.clear();
                    _confirmed.clear();
                    // Remove cached entries for current warehouse
                    if (_box != null) {
                      await _box!.delete(_countsKey());
                      await _box!.delete(_confirmedKey());
                    }
                    if (!context.mounted) return;
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All entered data cleared')),
                    );
                  },
                )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: _groupByItemGroup().entries.map((entry) {
                      final groupName = entry.key;
                      final groupItems = entry.value;
            // Only count items the user explicitly confirmed
            final countedInGroup = groupItems
              .where((it) => _confirmed.contains(it['item_code'] as String))
              .length;
                      return ExpansionTile(
                        title: Text(groupName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(label: Text('$countedInGroup/${groupItems.length}')),
                            const SizedBox(width: 8),
                            const Icon(Icons.expand_more),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 3.3,
                              ),
                              itemCount: groupItems.length,
                              itemBuilder: (context, idx) {
                                final it = groupItems[idx];
                                final itemCode = it['item_code'] as String;
                                final stockUom = it['stock_uom'] as String;
                                final current = (it['current_qty'] ?? 0).toDouble();
                                final uoms = (it['uoms'] as List).cast<Map<String, dynamic>>();
                                final valuationRate = (it['valuation_rate'] as num?)?.toDouble();
                                final saved = _counts[itemCode];
                                final qtyCtrl = TextEditingController(text: (saved?['qty'] ?? '').toString());
                                String? selectedUom = (saved?['uom'] as String?) ?? stockUom;

                                // Live delta computation based on current input
                                double enteredQty = double.tryParse(qtyCtrl.text) ?? (saved?['qty'] as num?)?.toDouble() ?? 0;
                                final countedStock = _toStockQty(it, enteredQty, selectedUom);
                                final delta = countedStock - current;
                                final Color deltaColor = delta.abs() < 1e-9
                                    ? Colors.grey
                                    : (delta > 0 ? Colors.green : Colors.red);

                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(itemCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(it['item_name'] ?? ''),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Expanded(child: Text('Current: $current $stockUom')),
                                            // Minus button
                                            IconButton(
                                              tooltip: 'Decrease',
                                              icon: const Icon(Icons.remove_circle_outline),
                                              onPressed: () {
                                                final cur = double.tryParse(qtyCtrl.text) ?? 0.0;
                                                double next = cur - 1.0;
                                                if (next < 0) next = 0.0;
                                                qtyCtrl.text = next.toString();
                                                _setCount(itemCode, next, selectedUom);
                                              },
                                            ),
                                            SizedBox(
                                              width: 90,
                                              child: TextField(
                                                controller: qtyCtrl,
                                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                decoration: const InputDecoration(labelText: 'Count'),
                                                onChanged: (val) {
                                                  enteredQty = double.tryParse(val) ?? 0;
                                                  if (enteredQty < 0) enteredQty = 0;
                                                  _setCount(itemCode, enteredQty, selectedUom);
                                                },
                                              ),
                                            ),
                                            // Plus button
                                            IconButton(
                                              tooltip: 'Increase',
                                              icon: const Icon(Icons.add_circle_outline),
                                              onPressed: () {
                                                final cur = double.tryParse(qtyCtrl.text) ?? 0;
                                                final next = cur + 1;
                                                qtyCtrl.text = next.toString();
                                                _setCount(itemCode, next, selectedUom);
                                              },
                                            ),
                                            const SizedBox(width: 6),
                                            DropdownButton<String>(
                                              value: selectedUom,
                                              items: uoms
                                                  .map((u) => DropdownMenuItem<String>(
                                                        value: u['uom'] as String,
                                                        child: Text(u['uom'] as String),
                                                      ))
                                                  .toList(),
                                              onChanged: (v) {
                                                selectedUom = v;
                                                _setCount(itemCode, double.tryParse(qtyCtrl.text) ?? 0, selectedUom);
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        if (valuationRate != null)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 2),
                                            child: Text(
                                              'Valuation: ${valuationRate.toStringAsFixed(2)} / $stockUom',
                                              style: const TextStyle(color: Colors.black87),
                                            ),
                                          ),
                                        Row(
                                          children: [
                                            const Text('Delta: '),
                                            Text(
                                              '${delta.toStringAsFixed(3)} $stockUom',
                                              style: TextStyle(color: deltaColor, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _loading ? null : _submit,
          icon: const Icon(Icons.save),
          label: const Text('Submit Count'),
        ),
      ),
    );
  }
}
