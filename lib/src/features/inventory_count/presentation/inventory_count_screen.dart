import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/posting_date_confirmation_dialog.dart';
import '../../manager/state/manager_providers.dart';
import '../data/inventory_count_service.dart';

enum _InventoryCountStep { setup, blindEntry, review }

class InventoryCountScreen extends ConsumerStatefulWidget {
  const InventoryCountScreen({super.key});

  @override
  ConsumerState<InventoryCountScreen> createState() => _InventoryCountScreenState();
}

class _InventoryCountScreenState extends ConsumerState<InventoryCountScreen> {
  static const _selectedWarehouseCacheKey = 'selected_warehouse';
  static const _enforceAllCacheKey = 'enforce_all';
  static const _stepCacheKey = 'current_step';

  late final Future<List<Map<String, dynamic>>> _warehousesFuture;
  String? _selectedWarehouse;
  DateTime _postingDate = DateTime.now();
  final TextEditingController _searchCtrl = TextEditingController();
  final Map<String, Map<String, dynamic>> _counts = {}; // item_code -> {qty,uom}
  final Set<String> _confirmed = <String>{};
  bool _enforceAll = true;
  bool _loading = false;
  bool _showUnchanged = false;
  List<Map<String, dynamic>> _items = [];
  Box<dynamic>? _box;
  _InventoryCountStep _currentStep = _InventoryCountStep.setup;

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
    _warehousesFuture = ref.read(inventoryCountServiceProvider).listWarehouses();
    _searchCtrl.addListener(_handleSearchChanged);
    _openBox();
  }

  @override
  void dispose() {
    _saveCache();
    _searchCtrl.removeListener(_handleSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    if (!mounted || _currentStep != _InventoryCountStep.blindEntry) {
      return;
    }
    setState(() {});
  }

  _InventoryCountStep _stepFromCache(String? value) {
    switch (value) {
      case 'blindEntry':
        return _InventoryCountStep.blindEntry;
      case 'review':
        return _InventoryCountStep.review;
      default:
        return _InventoryCountStep.setup;
    }
  }

  Future<void> _loadItems() async {
    if (_selectedWarehouse == null) return;
    setState(() => _loading = true);
    await _restoreCache(updateUi: false);
    if (mounted) {
      setState(() {});
    }
    final service = ref.read(inventoryCountServiceProvider);
    try {
      final data = await service.listItemsForCount(
        warehouse: _selectedWarehouse!,
      );
      setState(() {
        _items = data.map((item) => Map<String, dynamic>.from(item)).toList();
        _pruneDraftToLoadedItems();
      });
      _saveCache();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.inventoryCountOfflineUsingCache)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startCounting() async {
    if (_selectedWarehouse == null) {
      return;
    }
    await _loadItems();
    if (!mounted) {
      return;
    }
    setState(() => _currentStep = _InventoryCountStep.blindEntry);
    _saveCache();
  }

  void _goToReview() {
    setState(() {
      _currentStep = _InventoryCountStep.review;
      _showUnchanged = false;
    });
    _saveCache();
  }

  void _goBackOneStep() {
    switch (_currentStep) {
      case _InventoryCountStep.review:
        setState(() => _currentStep = _InventoryCountStep.blindEntry);
        break;
      case _InventoryCountStep.blindEntry:
        setState(() => _currentStep = _InventoryCountStep.setup);
        break;
      case _InventoryCountStep.setup:
        if (mounted) {
          context.go(AppRoutes.kanban);
        }
        return;
    }
    _saveCache();
  }

  double _sanitizeQty(double qty) => qty < 0 ? 0 : qty;

  bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }

  double _qtyForItem(String itemCode) {
    final saved = _counts[itemCode];
    return _sanitizeQty((saved?['qty'] as num?)?.toDouble() ?? 0.0);
  }

  List<String> _uomOptionsForItem(Map<String, dynamic> item) {
    final values = <String>[];
    final itemCode = item['item_code'] as String?;

    void addOption(String? value) {
      if (value == null || value.isEmpty || values.contains(value)) {
        return;
      }
      values.add(value);
    }

    addOption(itemCode == null ? null : _counts[itemCode]?['uom'] as String?);
    addOption(item['stock_uom'] as String?);
    final rawUoms = item['uoms'] as List?;
    if (rawUoms != null) {
      for (final raw in rawUoms) {
        if (raw is Map) {
          addOption(raw['uom']?.toString());
        }
      }
    }

    return values;
  }

  String? _selectedUomForItem(Map<String, dynamic> item) {
    final itemCode = item['item_code'] as String?;
    if (itemCode == null) {
      return null;
    }
    final saved = _counts[itemCode]?['uom'] as String?;
    if (saved != null && saved.isNotEmpty) {
      return saved;
    }
    final stockUom = item['stock_uom'] as String?;
    if (stockUom != null && stockUom.isNotEmpty) {
      return stockUom;
    }
    final options = _uomOptionsForItem(item);
    return options.isNotEmpty ? options.first : null;
  }

  void _submitItemCount(Map<String, dynamic> item, String rawValue) {
    final itemCode = item['item_code'] as String?;
    if (itemCode == null) {
      return;
    }
    final trimmed = rawValue.trim();
    final wasCounted = _confirmed.contains(itemCode);
    if (trimmed.isEmpty) {
      return;
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null) {
      return;
    }
    final selectedUom = _selectedUomForItem(item);
    _counts[itemCode] = {
      'qty': _sanitizeQty(parsed),
      if (selectedUom != null) 'uom': selectedUom,
    };
    _confirmed.add(itemCode);
    _saveCache();
    if (mounted && !wasCounted) {
      setState(() {});
    }
  }

  void _updateItemUom(Map<String, dynamic> item, String? uom) {
    final itemCode = item['item_code'] as String?;
    if (itemCode == null) {
      return;
    }
    final updated = Map<String, dynamic>.from(_counts[itemCode] ?? const <String, dynamic>{});
    if (uom == null || uom.isEmpty) {
      updated.remove('uom');
    } else {
      updated['uom'] = uom;
    }
    if (updated.isEmpty) {
      _counts.remove(itemCode);
    } else {
      _counts[itemCode] = updated;
    }
    _saveCache();
    if (mounted) {
      setState(() {});
    }
  }

  void _clearItemEntry(String itemCode, {bool refreshUi = true}) {
    _counts.remove(itemCode);
    _confirmed.remove(itemCode);
    _saveCache();
    if (mounted && refreshUi) {
      setState(() {});
    }
  }

  Future<void> _clearAllEnteredData() async {
    _counts.clear();
    _confirmed.clear();
    if (_box != null) {
      await _box!.delete(_countsKey());
      await _box!.delete(_confirmedKey());
    }
    _saveCache();
    if (!mounted) {
      return;
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.inventoryCountAllEnteredDataCleared)),
    );
  }

  Future<void> _clearSubmittedDraft() async {
    _counts.clear();
    _confirmed.clear();
    if (_box != null) {
      await _box!.delete(_countsKey());
      await _box!.delete(_confirmedKey());
    }
  }

  Future<void> _submit() async {
    if (_selectedWarehouse == null) return;
    final service = ref.read(inventoryCountServiceProvider);
    final reviewLines = _buildReviewLines();
    final missingItems = reviewLines.where((line) => line.isMissing).length;
    if (_enforceAll && missingItems > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.inventoryCountConfirmAllBeforeSubmit(missingItems))),
      );
      return;
    }
    final lines = reviewLines
        .where((line) => line.isCounted)
        .map((line) {
          final vr = line.valuationRate;
          return {
            'item_code': line.itemCode,
            'counted_qty': line.countedQty,
            if (line.selectedUom != null) 'uom': line.selectedUom,
            if (vr != null && vr > 0) 'valuation_rate': vr,
          };
        })
        .toList();
    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.inventoryCountConfirmAtLeastOne)));
      return;
    }

    final postingDate = DateTime(_postingDate.year, _postingDate.month, _postingDate.day);
    final confirmedPostingDate = await confirmPostingDatesBeforeSubmit(
      context,
      dates: [postingDate],
    );
    if (!confirmedPostingDate || !mounted) {
      return;
    }

    final postingDateStr = formatPostingDateForApi(postingDate);

    try {
      setState(() => _loading = true);
      
      _debugLog('Submitting reconciliation', {
        'warehouse': _selectedWarehouse,
        'linesCount': lines.length,
        'lines': lines,
        'postingDate': postingDateStr,
        'enforceAll': _enforceAll,
      });
      
      final res = await service.submitReconciliation(
        warehouse: _selectedWarehouse!,
        lines: lines,
        postingDate: postingDateStr,
        enforceAll: _enforceAll,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.inventoryCountSubmitted(
              '${res['stock_reconciliation'] ?? context.l10n.inventoryCountNoDifferences}',
            ),
          ),
        ),
      );
      _searchCtrl.clear();
      await _clearSubmittedDraft();
      if (!mounted) return;
      setState(() {
        _currentStep = _InventoryCountStep.setup;
        _showUnchanged = false;
      });
      _saveCache();
    } catch (e) {
      if (!mounted) return;
      _debugLog('Submit reconciliation error', e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.commonErrorWithDetails(e.toString()))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openBox() async {
    _box = await Hive.openBox(HiveBoxes.inventoryCount);
    final savedWarehouse = _box!.get(_selectedWarehouseCacheKey);
    if (savedWarehouse is String && savedWarehouse.isNotEmpty) {
      _selectedWarehouse = savedWarehouse;
    }
    final savedEnforceAll = _box!.get(_enforceAllCacheKey);
    if (savedEnforceAll is bool) {
      _enforceAll = savedEnforceAll;
    }
    _currentStep = _stepFromCache(_box!.get(_stepCacheKey) as String?);
    if (_selectedWarehouse != null) {
      await _restoreCache(updateUi: false);
      if (_items.isEmpty && _confirmed.isEmpty) {
        _currentStep = _InventoryCountStep.setup;
      }
      if (_currentStep != _InventoryCountStep.setup) {
        await _loadItems();
        return;
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  String _itemsKey() => 'items:${_selectedWarehouse ?? ''}';
  String _countsKey() => 'counts:${_selectedWarehouse ?? ''}';
  String _dateKey() => 'posting_date:${_selectedWarehouse ?? ''}';
  String _confirmedKey() => 'confirmed:${_selectedWarehouse ?? ''}';

  void _saveCache() {
    if (_box == null) return;
    _box!.put(_selectedWarehouseCacheKey, _selectedWarehouse);
    _box!.put(_enforceAllCacheKey, _enforceAll);
    _box!.put(_stepCacheKey, _currentStep.name);
    if (_selectedWarehouse == null) return;
    _box!.put(_itemsKey(), _items);
    _box!.put(_countsKey(), _counts);
    _box!.put(_dateKey(), DateFormat('yyyy-MM-dd').format(_postingDate));
    _box!.put(_confirmedKey(), _confirmed.toList());
  }

  Future<void> _restoreCache({bool updateUi = true}) async {
    if (_box == null || _selectedWarehouse == null) return;
    _items = [];
    _counts.clear();
    _confirmed.clear();
    final cachedItems = _box!.get(_itemsKey());
    if (cachedItems is List) {
      _items = cachedItems.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }
    final cachedCounts = _box!.get(_countsKey());
    if (cachedCounts is Map) {
      _counts.addAll(cachedCounts.map((k, v) => MapEntry(k.toString(), Map<String, dynamic>.from(v as Map))));
    }
    final cachedConfirmed = _box!.get(_confirmedKey());
    _confirmed.addAll((cachedConfirmed is List ? cachedConfirmed : const <dynamic>[]).map((e) => e.toString()));
    final cachedDate = _box!.get(_dateKey());
    if (cachedDate is String) {
      _postingDate = DateFormat('yyyy-MM-dd').parse(cachedDate);
    }
    _pruneDraftToLoadedItems();
    if (updateUi && mounted) {
      setState(() {});
    }
  }

  void _pruneDraftToLoadedItems() {
    if (_items.isEmpty) {
      return;
    }
    final validCodes = _items
        .map((item) => item['item_code'] as String?)
        .whereType<String>()
        .toSet();
    _counts.removeWhere((itemCode, _) => !validCodes.contains(itemCode));
    _confirmed.removeWhere((itemCode) => !validCodes.contains(itemCode));
  }

  double _toStockQty(Map<String, dynamic> item, double qty, String? uom) {
    final stockUom = (item['stock_uom'] as String?) ?? '';
    if (uom == null || uom == stockUom) return qty;
    final rawUoms = item['uoms'] as List?;
    final uoms = rawUoms == null
        ? const <Map<String, dynamic>>[]
        : rawUoms.whereType<Map>().map((entry) => Map<String, dynamic>.from(entry)).toList();
    final match = uoms.firstWhere(
      (e) => (e['uom'] as String?) == uom,
      orElse: () => const {'conversion_factor': 1},
    );
    final factor = (match['conversion_factor'] as num?)?.toDouble() ?? 1.0;
    return qty * factor;
  }

  List<Map<String, dynamic>> get _visibleItems {
    final query = _searchCtrl.text.trim().toLowerCase();
    final items = [..._items]
      ..sort((left, right) {
        final leftCode = left['item_code'] as String? ?? '';
        final rightCode = right['item_code'] as String? ?? '';
        final leftPending = !_confirmed.contains(leftCode);
        final rightPending = !_confirmed.contains(rightCode);
        if (leftPending != rightPending) {
          return leftPending ? -1 : 1;
        }
        final leftLabel = '${left['item_name'] ?? ''} $leftCode'.toLowerCase();
        final rightLabel = '${right['item_name'] ?? ''} $rightCode'.toLowerCase();
        return leftLabel.compareTo(rightLabel);
      });
    if (query.isEmpty) {
      return items;
    }
    return items.where((item) {
      final haystack = [
        item['item_code']?.toString() ?? '',
        item['item_name']?.toString() ?? '',
        item['item_group']?.toString() ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  List<_ReviewLine> _buildReviewLines() {
    final lines = <_ReviewLine>[];
    for (final item in _items) {
      final itemCode = item['item_code'] as String?;
      if (itemCode == null || itemCode.isEmpty) {
        continue;
      }
      final isCounted = _confirmed.contains(itemCode);
      if (!isCounted && !_enforceAll) {
        continue;
      }
      final stockUom = item['stock_uom'] as String? ?? '';
      final selectedUom = _selectedUomForItem(item) ?? stockUom;
      final countedQty = isCounted ? _qtyForItem(itemCode) : 0.0;
      final countedStockQty = isCounted ? _toStockQty(item, countedQty, selectedUom) : 0.0;
      final currentQty = (item['current_qty'] as num?)?.toDouble() ?? 0.0;
      final delta = countedStockQty - currentQty;
      lines.add(
        _ReviewLine(
          itemCode: itemCode,
          itemName: (item['item_name'] as String?)?.trim().isNotEmpty == true
              ? item['item_name'] as String
              : itemCode,
          countedQty: countedQty,
          countedStockQty: countedStockQty,
          currentQty: currentQty,
          delta: delta,
          selectedUom: selectedUom,
          stockUom: stockUom,
          isCounted: isCounted,
          isChanged: isCounted && delta.abs() > 1e-9,
          isMissing: _enforceAll && !isCounted,
          hasBatchNo: _asBool(item['has_batch_no']),
          hasSerialNo: _asBool(item['has_serial_no']),
          valuationRate: (item['valuation_rate'] as num?)?.toDouble(),
        ),
      );
    }
    return lines;
  }

  String _formatQuantity(double value) {
    final text = value.toStringAsFixed(3);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _formatSignedQuantity(double value) {
    if (value.abs() < 1e-9) {
      return '0';
    }
    final prefix = value > 0 ? '+' : '-';
    return '$prefix${_formatQuantity(value.abs())}';
  }

  Widget _buildStepHeader(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final currentIndex = _InventoryCountStep.values.indexOf(_currentStep);
    final steps = <({String label, int index})>[
      (label: l10n.inventoryCountSetupStep, index: 0),
      (label: l10n.inventoryCountBlindEntryStep, index: 1),
      (label: l10n.inventoryCountReviewStep, index: 2),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: steps.map((step) {
          final isActive = step.index == currentIndex;
          final isComplete = step.index < currentIndex;
          return Chip(
            avatar: CircleAvatar(
              backgroundColor: isActive || isComplete
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              foregroundColor: isActive || isComplete
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
              child: Text('${step.index + 1}'),
            ),
            label: Text(step.label),
            backgroundColor: isActive
                ? colorScheme.primaryContainer
                : isComplete
                    ? colorScheme.secondaryContainer
                    : colorScheme.surfaceContainerHighest,
            side: BorderSide.none,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSessionSummaryCard(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final modeLabel = _enforceAll
        ? l10n.inventoryCountEnforceAll
        : l10n.inventoryCountSpotCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedWarehouse ?? l10n.inventoryCountSelectWarehouse,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InventoryCountMetaTile(
                  icon: Icons.business_outlined,
                  label: l10n.inventoryCountWarehouseLabel,
                  value: _selectedWarehouse ?? '-',
                ),
                _InventoryCountMetaTile(
                  icon: Icons.event_outlined,
                  label: l10n.inventoryCountPostingDateLabel,
                  value: DateFormat('yyyy-MM-dd').format(_postingDate),
                ),
                _InventoryCountMetaTile(
                  icon: Icons.fact_check_outlined,
                  label: l10n.inventoryCountCountModeLabel,
                  value: modeLabel,
                ),
              ],
            ),
            if (_items.isNotEmpty) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _items.isEmpty ? 0.0 : _confirmed.length / _items.length,
              ),
              const SizedBox(height: 6),
              Text(l10n.inventoryCountConfirmedProgress(_confirmed.length, _items.length)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSetupStep(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          l10n.inventoryCountSetupStep,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _warehousesFuture,
                  builder: (context, snapshot) {
                    final warehouses = snapshot.data ?? const <Map<String, dynamic>>[];
                    final warehouseNames = warehouses
                        .map((warehouse) => warehouse['name']?.toString())
                        .whereType<String>()
                        .toSet();
                    final dropdownValue = warehouseNames.contains(_selectedWarehouse)
                        ? _selectedWarehouse
                        : null;

                    return DropdownButtonFormField<String>(
                      key: ValueKey(dropdownValue),
                      isExpanded: true,
                      initialValue: dropdownValue,
                      hint: Text(l10n.inventoryCountSelectWarehouse),
                      items: warehouses
                          .map(
                            (warehouse) => DropdownMenuItem<String>(
                              value: warehouse['name'] as String,
                              child: Text(warehouse['name'] as String),
                            ),
                          )
                          .toList(),
                      onChanged: snapshot.connectionState == ConnectionState.waiting
                          ? null
                          : (value) async {
                              if (value == _selectedWarehouse) {
                                return;
                              }
                              _searchCtrl.clear();
                              setState(() {
                                _selectedWarehouse = value;
                                _currentStep = _InventoryCountStep.setup;
                              });
                              _saveCache();
                              await _restoreCache();
                            },
                    );
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(l10n.inventoryCountPostingDateLabel),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(_postingDate)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _postingDate,
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2100),
                    );
                    if (picked == null) {
                      return;
                    }
                    setState(() => _postingDate = picked);
                    _saveCache();
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: RadioGroup<bool>(
            groupValue: _enforceAll,
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _enforceAll = value);
              _saveCache();
            },
            child: Column(
              children: [
                RadioListTile<bool>(
                  value: false,
                  title: Text(l10n.inventoryCountSpotCount),
                  subtitle: Text(l10n.inventoryCountSpotCountDescription),
                ),
                const Divider(height: 1),
                RadioListTile<bool>(
                  value: true,
                  title: Text(l10n.inventoryCountEnforceAll),
                  subtitle: Text(l10n.inventoryCountFullWarehouseCountDescription),
                ),
              ],
            ),
          ),
        ),
        if (_selectedWarehouse != null && (_confirmed.isNotEmpty || _items.isNotEmpty)) ...[
          const SizedBox(height: 12),
          _buildSessionSummaryCard(context),
        ],
      ],
    );
  }

  Widget _buildBlindEntryStep(BuildContext context) {
    final l10n = context.l10n;
    final visibleItems = _visibleItems;

    return Column(
      children: [
        if (_loading) const LinearProgressIndicator(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _buildSessionSummaryCard(context),
              const SizedBox(height: 12),
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.commonSearchItems,
                  suffixIcon: _searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchCtrl.clear(),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.inventoryCountFilteredItems(visibleItems.length, _items.length)),
                  ),
                  IconButton(
                    tooltip: l10n.inventoryCountClearAllEnteredData,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _confirmed.isEmpty ? null : _clearAllEnteredData,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (visibleItems.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(l10n.commonNoItems)),
                  ),
                )
              else
                ...visibleItems.map((item) {
                  final itemCode = item['item_code'] as String? ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BlindEntryRow(
                      key: ValueKey(itemCode),
                      itemCode: itemCode,
                      itemName: (item['item_name'] as String?)?.trim().isNotEmpty == true
                          ? item['item_name'] as String
                          : itemCode,
                      quantity: _confirmed.contains(itemCode) ? _qtyForItem(itemCode) : null,
                      selectedUom: _selectedUomForItem(item),
                      uomOptions: _uomOptionsForItem(item),
                      isCounted: _confirmed.contains(itemCode),
                      onSubmitQuantity: (value) => _submitItemCount(item, value),
                      onUomChanged: (value) => _updateItemUom(item, value),
                      onClear: () => _clearItemEntry(itemCode),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep(
    BuildContext context,
    List<_ReviewLine> reviewLines,
    List<_ReviewLine> discrepancyLines,
    List<_ReviewLine> unchangedLines,
    List<_ReviewLine> missingLines,
  ) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (_loading) const LinearProgressIndicator(),
        _buildSessionSummaryCard(context),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _InventoryCountSummaryCard(
              title: l10n.inventoryCountSummaryCountedItems,
              value: _confirmed.length.toString(),
            ),
            _InventoryCountSummaryCard(
              title: l10n.inventoryCountSummaryChangedItems,
              value: discrepancyLines.length.toString(),
            ),
            if (_enforceAll)
              _InventoryCountSummaryCard(
                title: l10n.inventoryCountSummaryMissingItems,
                value: missingLines.length.toString(),
              ),
          ],
        ),
        if (_enforceAll && missingLines.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.inventoryCountConfirmAllBeforeSubmit(missingLines.length),
                style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.inventoryCountReviewDiscrepancies,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (discrepancyLines.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                reviewLines.isEmpty
                    ? l10n.inventoryCountReviewNoCountedItems
                    : l10n.inventoryCountReviewNoDiscrepancies,
              ),
            ),
          )
        else
          ...discrepancyLines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReviewLineCard(
                line: line,
                deltaText: _formatSignedQuantity(line.delta),
                countedQtyText: _formatQuantity(line.countedQty),
                countedStockQtyText: _formatQuantity(line.countedStockQty),
                currentQtyText: _formatQuantity(line.currentQty),
              ),
            ),
          ),
        if (unchangedLines.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            child: ExpansionTile(
              initiallyExpanded: _showUnchanged,
              onExpansionChanged: (value) => setState(() => _showUnchanged = value),
              title: Text('${l10n.inventoryCountReviewUnchanged} (${unchangedLines.length})'),
              children: unchangedLines
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _ReviewLineCard(
                        line: line,
                        deltaText: _formatSignedQuantity(line.delta),
                        countedQtyText: _formatQuantity(line.countedQty),
                        countedStockQtyText: _formatQuantity(line.countedStockQty),
                        currentQtyText: _formatQuantity(line.currentQty),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        if (_enforceAll && missingLines.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            child: ExpansionTile(
              initiallyExpanded: true,
              title: Text('${l10n.inventoryCountReviewMissing} (${missingLines.length})'),
              children: missingLines
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _ReviewLineCard(
                        line: line,
                        deltaText: _formatSignedQuantity(line.delta),
                        countedQtyText: _formatQuantity(line.countedQty),
                        countedStockQtyText: _formatQuantity(line.countedStockQty),
                        currentQtyText: _formatQuantity(line.currentQty),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    List<_ReviewLine> reviewLines,
    List<_ReviewLine> missingLines,
  ) {
    final l10n = context.l10n;

    switch (_currentStep) {
      case _InventoryCountStep.setup:
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading || _selectedWarehouse == null ? null : _startCounting,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  _confirmed.isNotEmpty
                      ? l10n.inventoryCountContinueCount
                      : l10n.inventoryCountStartCount,
                ),
              ),
            ),
          ),
        );
      case _InventoryCountStep.blindEntry:
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: _loading ? null : _goBackOneStep,
                  child: Text(l10n.inventoryCountBackToSetup),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _items.isEmpty || _loading ? null : _goToReview,
                    icon: const Icon(Icons.visibility_outlined),
                    label: Text(l10n.inventoryCountReviewButton),
                  ),
                ),
              ],
            ),
          ),
        );
      case _InventoryCountStep.review:
        final canSubmit = !_loading &&
            reviewLines.any((line) => line.isCounted) &&
            (!_enforceAll || missingLines.isEmpty);
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: _loading ? null : _goBackOneStep,
                  child: Text(l10n.inventoryCountBackToCounting),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canSubmit ? _submit : null,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(l10n.inventoryCountSubmitCount),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final allowed = ref.watch(managerAccessProvider).maybeWhen(data: (v) => v, orElse: () => false);
    if (!allowed) {
      return Scaffold(body: Center(child: Text(l10n.inventoryCountManagerAccessRequired)));
    }

    final reviewLines = _buildReviewLines();
    final discrepancyLines = reviewLines.where((line) => line.isChanged).toList();
    final unchangedLines = reviewLines.where((line) => line.isCounted && !line.isChanged).toList();
    final missingLines = reviewLines.where((line) => line.isMissing).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !mounted) return;
        _goBackOneStep();
      },
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: _currentStep == _InventoryCountStep.setup
              ? Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _loading ? null : _goBackOneStep,
                ),
          title: Text(l10n.menuInventoryCount),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loading || _selectedWarehouse == null ? null : _loadItems,
            ),
          ],
        ),
        body: Column(
          children: [
            _buildStepHeader(context),
            Expanded(
              child: switch (_currentStep) {
                _InventoryCountStep.setup => _buildSetupStep(context),
                _InventoryCountStep.blindEntry => _buildBlindEntryStep(context),
                _InventoryCountStep.review => _buildReviewStep(
                    context,
                    reviewLines,
                    discrepancyLines,
                    unchangedLines,
                    missingLines,
                  ),
              },
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(context, reviewLines, missingLines),
      ),
    );
  }
}

class _ReviewLine {
  const _ReviewLine({
    required this.itemCode,
    required this.itemName,
    required this.countedQty,
    required this.countedStockQty,
    required this.currentQty,
    required this.delta,
    required this.selectedUom,
    required this.stockUom,
    required this.isCounted,
    required this.isChanged,
    required this.isMissing,
    required this.hasBatchNo,
    required this.hasSerialNo,
    required this.valuationRate,
  });

  final String itemCode;
  final String itemName;
  final double countedQty;
  final double countedStockQty;
  final double currentQty;
  final double delta;
  final String? selectedUom;
  final String stockUom;
  final bool isCounted;
  final bool isChanged;
  final bool isMissing;
  final bool hasBatchNo;
  final bool hasSerialNo;
  final double? valuationRate;
}

class _InventoryCountMetaTile extends StatelessWidget {
  const _InventoryCountMetaTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryCountSummaryCard extends StatelessWidget {
  const _InventoryCountSummaryCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlindEntryRow extends StatefulWidget {
  const _BlindEntryRow({
    super.key,
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.selectedUom,
    required this.uomOptions,
    required this.isCounted,
    required this.onSubmitQuantity,
    required this.onUomChanged,
    required this.onClear,
  });

  final String itemCode;
  final String itemName;
  final double? quantity;
  final String? selectedUom;
  final List<String> uomOptions;
  final bool isCounted;
  final ValueChanged<String> onSubmitQuantity;
  final ValueChanged<String?> onUomChanged;
  final VoidCallback onClear;

  @override
  State<_BlindEntryRow> createState() => _BlindEntryRowState();
}

class _BlindEntryRowState extends State<_BlindEntryRow> {
  late final TextEditingController _controller;
  bool _hasLocalDraft = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _textFor(widget.quantity));
  }

  @override
  void didUpdateWidget(covariant _BlindEntryRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = _textFor(widget.quantity);
    final quantityChanged = widget.quantity != oldWidget.quantity;
    if (_hasLocalDraft && !quantityChanged) {
      return;
    }
    if (_controller.text == nextText) {
      if (quantityChanged) {
        _hasLocalDraft = false;
      }
      return;
    }
    _controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
    _hasLocalDraft = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _textFor(double? value) {
    if (value == null) {
      return '';
    }
    final text = value.toStringAsFixed(3);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  bool get _hasPendingChanges => _controller.text.trim() != _textFor(widget.quantity);

  void _setLocalText(String text) {
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() => _hasLocalDraft = true);
  }

  void _adjustLocalCount(double delta) {
    final current = double.tryParse(_controller.text) ?? 0.0;
    final next = (current + delta).clamp(0.0, double.infinity);
    _setLocalText(_textFor(next));
  }

  void _submitCurrentValue() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    widget.onSubmitQuantity(trimmed);
    setState(() => _hasLocalDraft = false);
  }

  void _clearCurrentValue() {
    _controller.clear();
    setState(() => _hasLocalDraft = false);
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isCommitted = widget.isCounted && !_hasPendingChanges;
    final statusColor = isCommitted
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final statusText = isCommitted
        ? l10n.inventoryCountCountedStatus
        : l10n.inventoryCountPendingStatus;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.itemName, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(widget.itemCode, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Chip(
                  backgroundColor: statusColor,
                  side: BorderSide.none,
                  label: Text(statusText),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton(
                  tooltip: l10n.inventoryCountDecrease,
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _adjustLocalCount(-1),
                ),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                    decoration: InputDecoration(labelText: l10n.inventoryCountCount),
                    onChanged: (_) => setState(() => _hasLocalDraft = true),
                    onSubmitted: (_) => _submitCurrentValue(),
                  ),
                ),
                IconButton(
                  tooltip: l10n.inventoryCountIncrease,
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _adjustLocalCount(1),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('${widget.itemCode}:${widget.selectedUom ?? ''}'),
                    initialValue: widget.selectedUom,
                    decoration: InputDecoration(labelText: l10n.commonUomLabel),
                    items: widget.uomOptions
                        .map(
                          (uom) => DropdownMenuItem<String>(
                            value: uom,
                            child: Text(uom),
                          ),
                        )
                        .toList(),
                    onChanged: widget.uomOptions.length <= 1 ? null : widget.onUomChanged,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _canSubmit ? _submitCurrentValue : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(l10n.commonSubmit),
                ),
                TextButton.icon(
                  onPressed: _clearCurrentValue,
                  icon: const Icon(Icons.clear),
                  label: Text(l10n.inventoryCountClearEntry),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewLineCard extends StatelessWidget {
  const _ReviewLineCard({
    required this.line,
    required this.deltaText,
    required this.countedQtyText,
    required this.countedStockQtyText,
    required this.currentQtyText,
  });

  final _ReviewLine line;
  final String deltaText;
  final String countedQtyText;
  final String countedStockQtyText;
  final String currentQtyText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final deltaColor = line.isMissing
        ? colorScheme.tertiary
        : line.delta.abs() < 1e-9
            ? colorScheme.onSurfaceVariant
            : line.delta > 0
                ? Colors.green.shade700
                : colorScheme.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(line.itemName, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(line.itemCode, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (!line.isMissing)
                  Text(
                    '$deltaText ${line.stockUom}'.trim(),
                    style: TextStyle(color: deltaColor, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (line.hasBatchNo)
                  Chip(
                    side: BorderSide.none,
                    label: Text(l10n.inventoryCountBatchTracked),
                  ),
                if (line.hasSerialNo)
                  Chip(
                    side: BorderSide.none,
                    label: Text(l10n.inventoryCountSerialTracked),
                  ),
              ],
            ),
            if (line.hasBatchNo || line.hasSerialNo) const SizedBox(height: 12),
            if (line.isMissing)
              Text(l10n.inventoryCountMissingItemNote)
            else ...[
              Text(
                l10n.inventoryCountCountedAmount(
                  countedQtyText,
                  line.selectedUom ?? line.stockUom,
                ),
              ),
              if ((line.selectedUom ?? line.stockUom) != line.stockUom)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.inventoryCountStockEquivalent(countedStockQtyText, line.stockUom),
                  ),
                ),
            ],
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l10n.inventoryCountCurrentAmount(currentQtyText, line.stockUom)),
            ),
            if (!line.isMissing)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Text(l10n.inventoryCountDeltaLabel),
                    Text(
                      '$deltaText ${line.stockUom}'.trim(),
                      style: TextStyle(color: deltaColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
