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
import '../../../core/localization/user_error_message.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/posting_date_confirmation_dialog.dart';
import '../../manager/state/manager_providers.dart';
import '../data/inventory_count_service.dart';
import 'widgets/inventory_count_history.dart';

enum _InventoryCountStep { setup, blindEntry, review }

final RegExp _inventoryCountQuantityPattern = RegExp(r'^\d*\.?\d*$');

String _normalizeInventoryCountQuantity(String value) =>
    value.replaceAll(',', '.');

final TextInputFormatter _inventoryCountQuantityFormatter =
    TextInputFormatter.withFunction((oldValue, newValue) {
      final normalizedText = _normalizeInventoryCountQuantity(newValue.text);
      if (normalizedText.isEmpty ||
          _inventoryCountQuantityPattern.hasMatch(normalizedText)) {
        return newValue.copyWith(text: normalizedText);
      }
      return oldValue;
    });

class InventoryCountScreen extends ConsumerStatefulWidget {
  const InventoryCountScreen({super.key});

  @override
  ConsumerState<InventoryCountScreen> createState() =>
      _InventoryCountScreenState();
}

class _InventoryCountScreenState extends ConsumerState<InventoryCountScreen> {
  static const _selectedWarehouseCacheKey = 'selected_warehouse';
  static const _enforceAllCacheKey = 'enforce_all';
  static const _stepCacheKey = 'current_step';

  late final Future<List<Map<String, dynamic>>> _warehousesFuture;
  String? _selectedWarehouse;
  String? _selectedCategory;
  DateTime _postingDate = DateTime.now();
  final TextEditingController _searchCtrl = TextEditingController();
  // item_code -> {components: [{qty, uom}, ...]}. Older cached {qty, uom}
  // entries are migrated when read so an in-progress count survives rollout.
  final Map<String, Map<String, dynamic>> _counts = {};
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
    _warehousesFuture = ref
        .read(inventoryCountServiceProvider)
        .listWarehouses();
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
    // Reached from `_openBox` after its own await as well as from the button,
    // so the State is not guaranteed alive on entry.
    if (!mounted) return;
    setState(() => _loading = true);
    await _restoreCache(updateUi: false);
    // Backing out of Inventory Count while a cold Hive box opens disposes this
    // State mid-await. The `ref.read` below then throws "Cannot use ref after
    // the widget was disposed" — and it sat OUTSIDE both this guard and the
    // try, so nothing caught it. Return instead of merely skipping the
    // setState.
    if (!mounted) return;
    setState(() {});
    final service = ref.read(inventoryCountServiceProvider);
    try {
      final data = await service.listItemsForCount(
        warehouse: _selectedWarehouse!,
      );
      if (!mounted) return;
      setState(() {
        _items = data.map((item) => Map<String, dynamic>.from(item)).toList();
        // A category from the previous warehouse would filter everything away
        // and read as an empty sheet rather than a stale filter.
        if (_selectedCategory != null &&
            !_items.any((item) => _categoryOf(item) == _selectedCategory)) {
          _selectedCategory = null;
        }
        _pruneDraftToLoadedItems();
      });
      _saveCache();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.inventoryCountOfflineUsingCache)),
        );
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

  List<Map<String, dynamic>> _savedComponentsForItem(String itemCode) {
    final saved = _counts[itemCode];
    if (saved == null) {
      return [];
    }
    final rawComponents = saved['components'];
    if (rawComponents is List) {
      return rawComponents
          .whereType<Map>()
          .map((component) => Map<String, dynamic>.from(component))
          .toList();
    }
    final legacyQty = saved['qty'];
    if (legacyQty is num) {
      return [
        {
          'qty': _sanitizeQty(legacyQty.toDouble()),
          if (saved['uom'] is String) 'uom': saved['uom'],
        },
      ];
    }
    return [];
  }

  List<Map<String, dynamic>> _componentsForItem(Map<String, dynamic> item) {
    final itemCode = item['item_code'] as String? ?? '';
    final saved = _savedComponentsForItem(itemCode);
    if (saved.isNotEmpty) {
      return saved;
    }
    final options = _uomOptionsForItem(item);
    return [
      {if (options.isNotEmpty) 'uom': options.first},
    ];
  }

  void _storeComponents(
    String itemCode,
    List<Map<String, dynamic>> components,
  ) {
    _counts[itemCode] = {
      'components': components
          .map((component) => Map<String, dynamic>.from(component))
          .toList(),
    };
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

    if (itemCode != null) {
      for (final component in _savedComponentsForItem(itemCode)) {
        addOption(component['uom'] as String?);
      }
    }
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

  void _submitItemCount(
    Map<String, dynamic> item,
    int componentIndex,
    String rawValue,
  ) {
    final itemCode = item['item_code'] as String?;
    if (itemCode == null) {
      return;
    }
    final trimmed = _normalizeInventoryCountQuantity(rawValue.trim());
    final wasCounted = _confirmed.contains(itemCode);
    if (trimmed.isEmpty) {
      return;
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      return;
    }
    final components = _componentsForItem(item);
    if (componentIndex < 0 || componentIndex >= components.length) {
      return;
    }
    components[componentIndex]['qty'] = _sanitizeQty(parsed);
    components[componentIndex].remove('draft');
    _storeComponents(itemCode, components);
    final allComponentsSubmitted = components.every(
      (component) => component['qty'] is num && !component.containsKey('draft'),
    );
    if (allComponentsSubmitted) {
      _confirmed.add(itemCode);
    } else {
      _confirmed.remove(itemCode);
    }
    _saveCache();
    if (mounted && !wasCounted) {
      setState(() {});
    }
  }

  void _updateItemDraft(
    Map<String, dynamic> item,
    int componentIndex,
    String rawValue,
  ) {
    final itemCode = item['item_code'] as String?;
    if (itemCode == null) {
      return;
    }
    final components = _componentsForItem(item);
    if (componentIndex < 0 || componentIndex >= components.length) {
      return;
    }
    components[componentIndex]['draft'] = _normalizeInventoryCountQuantity(
      rawValue,
    );
    _storeComponents(itemCode, components);
    _confirmed.remove(itemCode);
    _saveCache();
    if (mounted) {
      setState(() {});
    }
  }

  void _updateItemUom(
    Map<String, dynamic> item,
    int componentIndex,
    String? uom,
  ) {
    final itemCode = item['item_code'] as String?;
    if (itemCode == null) {
      return;
    }
    final components = _componentsForItem(item);
    if (componentIndex < 0 || componentIndex >= components.length) {
      return;
    }
    final updated = components[componentIndex];
    if (uom == null || uom.isEmpty) {
      updated.remove('uom');
    } else {
      updated['uom'] = uom;
    }
    _storeComponents(itemCode, components);
    _saveCache();
    if (mounted) {
      setState(() {});
    }
  }

  void _addItemUom(Map<String, dynamic> item) {
    final itemCode = item['item_code'] as String?;
    if (itemCode == null) {
      return;
    }
    final components = _componentsForItem(item);
    final usedUoms = components
        .map((component) => component['uom'])
        .whereType<String>()
        .toSet();
    final availableUoms = _uomOptionsForItem(
      item,
    ).where((uom) => !usedUoms.contains(uom));
    if (availableUoms.isEmpty) {
      return;
    }
    components.add({'uom': availableUoms.first});
    _storeComponents(itemCode, components);
    _confirmed.remove(itemCode);
    _saveCache();
    if (mounted) {
      setState(() {});
    }
  }

  void _removeItemUom(Map<String, dynamic> item, int componentIndex) {
    final itemCode = item['item_code'] as String?;
    if (itemCode == null) {
      return;
    }
    final components = _componentsForItem(item);
    if (components.length <= 1 ||
        componentIndex < 0 ||
        componentIndex >= components.length) {
      return;
    }
    components.removeAt(componentIndex);
    _storeComponents(itemCode, components);
    if (components.every(
      (component) => component['qty'] is num && !component.containsKey('draft'),
    )) {
      _confirmed.add(itemCode);
    } else {
      _confirmed.remove(itemCode);
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
    if (missingItems > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.inventoryCountConfirmAllBeforeSubmit(missingItems),
          ),
        ),
      );
      return;
    }
    final lines = reviewLines.where((line) => line.isCounted).expand((line) {
      final vr = line.valuationRate;
      return line.components.map(
        (component) => {
          'item_code': line.itemCode,
          'counted_qty': component.qty,
          'uom': component.uom,
          if (vr != null && vr > 0) 'valuation_rate': vr,
        },
      );
    }).toList();
    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.inventoryCountConfirmAtLeastOne)),
      );
      return;
    }

    final postingDate = DateTime(
      _postingDate.year,
      _postingDate.month,
      _postingDate.day,
    );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.userErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openBox() async {
    _box = await Hive.openBox(HiveBoxes.inventoryCount);
    // Opening a cold box is slow enough that the user can be back on the
    // previous screen by the time it lands. Everything below this line — and
    // `_loadItems`, which this may call — writes State and reads `ref`.
    if (!mounted) return;
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
      if (_items.isEmpty && _confirmed.isEmpty && _counts.isEmpty) {
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
      _items = cachedItems
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    final cachedCounts = _box!.get(_countsKey());
    if (cachedCounts is Map) {
      _counts.addAll(
        cachedCounts.map(
          (k, v) => MapEntry(k.toString(), Map<String, dynamic>.from(v as Map)),
        ),
      );
    }
    final cachedConfirmed = _box!.get(_confirmedKey());
    _confirmed.addAll(
      (cachedConfirmed is List ? cachedConfirmed : const <dynamic>[]).map(
        (e) => e.toString(),
      ),
    );
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
        : rawUoms
              .whereType<Map>()
              .map((entry) => Map<String, dynamic>.from(entry))
              .toList();
    final match = uoms.firstWhere(
      (e) => (e['uom'] as String?) == uom,
      orElse: () => const {'conversion_factor': 1},
    );
    final factor = (match['conversion_factor'] as num?)?.toDouble() ?? 1.0;
    return qty * factor;
  }

  /// Category of an item, falling back to the "Uncategorized" label.
  String _categoryOf(Map<String, dynamic> item) {
    final group = item['item_group']?.toString().trim() ?? '';
    return group.isEmpty ? context.l10n.inventoryCountUncategorized : group;
  }

  /// Categories present in the loaded sheet, in the order they should be shown,
  /// each with how many of its rows are still uncounted.
  ///
  /// Derived from what actually came back rather than from a fixed list, so a
  /// warehouse whose count profile covers three groups shows three chips.
  Map<String, int> get _categoryPending {
    final pending = <String, int>{};
    for (final item in _items) {
      final code = item['item_code'] as String? ?? '';
      final category = _categoryOf(item);
      pending[category] =
          (pending[category] ?? 0) + (_confirmed.contains(code) ? 0 : 1);
    }
    return Map.fromEntries(
      pending.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  List<Map<String, dynamic>> get _visibleItems {
    final query = _searchCtrl.text.trim().toLowerCase();
    final category = _selectedCategory;
    final items = [..._items]
      ..removeWhere((item) => category != null && _categoryOf(item) != category)
      ..sort((left, right) {
        // Category first, so each one is a contiguous run the section headers
        // can label. Within a category the old ordering is kept: still to
        // count, then alphabetical.
        final byCategory = _categoryOf(left).compareTo(_categoryOf(right));
        if (byCategory != 0) {
          return byCategory;
        }
        final leftCode = left['item_code'] as String? ?? '';
        final rightCode = right['item_code'] as String? ?? '';
        final leftPending = !_confirmed.contains(leftCode);
        final rightPending = !_confirmed.contains(rightCode);
        if (leftPending != rightPending) {
          return leftPending ? -1 : 1;
        }
        final leftLabel = '${left['item_name'] ?? ''} $leftCode'.toLowerCase();
        final rightLabel = '${right['item_name'] ?? ''} $rightCode'
            .toLowerCase();
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
      final hasDraftEntry = _counts.containsKey(itemCode);
      if (!isCounted && !_enforceAll && !hasDraftEntry) {
        continue;
      }
      final stockUom = item['stock_uom'] as String? ?? '';
      final components = isCounted
          ? _savedComponentsForItem(
              itemCode,
            ).where((component) => component['qty'] is num).map((component) {
              final qty = _sanitizeQty((component['qty'] as num).toDouble());
              final uom = component['uom'] as String? ?? stockUom;
              return _ReviewCountComponent(
                qty: qty,
                uom: uom,
                stockQty: _toStockQty(item, qty, uom),
              );
            }).toList()
          : <_ReviewCountComponent>[];
      final countedStockQty = components.fold<double>(
        0,
        (total, component) => total + component.stockQty,
      );
      final currentQty = (item['current_qty'] as num?)?.toDouble() ?? 0.0;
      final delta = countedStockQty - currentQty;
      lines.add(
        _ReviewLine(
          itemCode: itemCode,
          itemName: (item['item_name'] as String?)?.trim().isNotEmpty == true
              ? item['item_name'] as String
              : itemCode,
          components: components,
          countedStockQty: countedStockQty,
          currentQty: currentQty,
          delta: delta,
          stockUom: stockUom,
          isCounted: isCounted,
          isChanged: isCounted && delta.abs() > 1e-9,
          isMissing: !isCounted,
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
              Text(
                l10n.inventoryCountConfirmedProgress(
                  _confirmed.length,
                  _items.length,
                ),
              ),
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
                    final warehouses =
                        snapshot.data ?? const <Map<String, dynamic>>[];
                    final warehouseNames = warehouses
                        .map((warehouse) => warehouse['name']?.toString())
                        .whereType<String>()
                        .toSet();
                    final dropdownValue =
                        warehouseNames.contains(_selectedWarehouse)
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
                      onChanged:
                          snapshot.connectionState == ConnectionState.waiting
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
                  subtitle: Text(
                    l10n.inventoryCountFullWarehouseCountDescription,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedWarehouse != null &&
            (_confirmed.isNotEmpty || _items.isNotEmpty)) ...[
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
                    child: Text(
                      l10n.inventoryCountFilteredItems(
                        visibleItems.length,
                        _items.length,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.inventoryCountClearAllEnteredData,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _confirmed.isEmpty ? null : _clearAllEnteredData,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildCategoryFilter(context),
              if (visibleItems.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(l10n.commonNoItems)),
                  ),
                )
              else
                ..._buildCountRows(context, visibleItems),
            ],
          ),
        ),
      ],
    );
  }

  /// A chip per category in the sheet, each showing how many rows are still
  /// uncounted, so a counter can take one shelf at a time instead of scrolling
  /// a single flat list.
  Widget _buildCategoryFilter(BuildContext context) {
    final l10n = context.l10n;
    final pending = _categoryPending;
    // One category is not a choice — the chips would only take up space.
    if (pending.length < 2) return const SizedBox.shrink();

    final totalPending = pending.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChip(
            label: Text('${l10n.stockTransferAllGroups} ($totalPending)'),
            selected: _selectedCategory == null,
            onSelected: (_) => setState(() => _selectedCategory = null),
          ),
          ...pending.entries.map(
            (entry) => FilterChip(
              label: Text('${entry.key} (${entry.value})'),
              selected: _selectedCategory == entry.key,
              onSelected: (selected) => setState(
                () => _selectedCategory = selected ? entry.key : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The entry rows, with a header before each category.
  ///
  /// Headers are only worth their space when more than one category is on
  /// screen — filtering to a single category already names it on the chip.
  List<Widget> _buildCountRows(
    BuildContext context,
    List<Map<String, dynamic>> visibleItems,
  ) {
    final theme = Theme.of(context);
    final showHeaders = visibleItems.map(_categoryOf).toSet().length > 1;
    final counts = <String, List<int>>{};
    for (final item in visibleItems) {
      final code = item['item_code'] as String? ?? '';
      final bucket = counts.putIfAbsent(_categoryOf(item), () => [0, 0]);
      bucket[1] += 1;
      if (_confirmed.contains(code)) bucket[0] += 1;
    }

    final widgets = <Widget>[];
    String? currentCategory;
    for (final item in visibleItems) {
      final category = _categoryOf(item);
      if (showHeaders && category != currentCategory) {
        currentCategory = category;
        final bucket = counts[category] ?? [0, 0];
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: widgets.isEmpty ? 0 : 8, bottom: 8),
            child: Row(
              children: [
                Text(category, style: theme.textTheme.titleSmall),
                const SizedBox(width: 8),
                Expanded(
                  // Digits only, deliberately. The screen already shows
                  // "Confirmed x / y" for the sheet as a whole, and repeating
                  // that phrase per category would read as the same number
                  // twice over rather than progress through one shelf.
                  child: Text(
                    '${bucket[0]}/${bucket[1]}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      final itemCode = item['item_code'] as String? ?? '';
      final components = _componentsForItem(item);
      final usedUoms = components
          .map((component) => component['uom'])
          .whereType<String>()
          .toSet();
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _BlindEntryRow(
            key: ValueKey(itemCode),
            itemCode: itemCode,
            itemName: (item['item_name'] as String?)?.trim().isNotEmpty == true
                ? item['item_name'] as String
                : itemCode,
            components: components,
            uomOptions: _uomOptionsForItem(item),
            isCounted: _confirmed.contains(itemCode),
            canAddUom: usedUoms.length < _uomOptionsForItem(item).length,
            onSubmitQuantity: (index, value) =>
                _submitItemCount(item, index, value),
            onDraftChanged: (index, value) =>
                _updateItemDraft(item, index, value),
            onUomChanged: (index, value) => _updateItemUom(item, index, value),
            onAddUom: () => _addItemUom(item),
            onRemoveUom: (index) => _removeItemUom(item, index),
            onClear: () => _clearItemEntry(itemCode),
          ),
        ),
      );
    }
    return widgets;
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
            if (_enforceAll || missingLines.isNotEmpty)
              _InventoryCountSummaryCard(
                title: l10n.inventoryCountSummaryMissingItems,
                value: missingLines.length.toString(),
              ),
          ],
        ),
        if (missingLines.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.inventoryCountConfirmAllBeforeSubmit(missingLines.length),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
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
              onExpansionChanged: (value) =>
                  setState(() => _showUnchanged = value),
              title: Text(
                '${l10n.inventoryCountReviewUnchanged} (${unchangedLines.length})',
              ),
              children: unchangedLines
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _ReviewLineCard(
                        line: line,
                        deltaText: _formatSignedQuantity(line.delta),
                        countedStockQtyText: _formatQuantity(
                          line.countedStockQty,
                        ),
                        currentQtyText: _formatQuantity(line.currentQty),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        if (missingLines.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            child: ExpansionTile(
              initiallyExpanded: true,
              title: Text(
                '${l10n.inventoryCountReviewMissing} (${missingLines.length})',
              ),
              children: missingLines
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _ReviewLineCard(
                        line: line,
                        deltaText: _formatSignedQuantity(line.delta),
                        countedStockQtyText: _formatQuantity(
                          line.countedStockQty,
                        ),
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
                onPressed: _loading || _selectedWarehouse == null
                    ? null
                    : _startCounting,
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
        final canSubmit =
            !_loading &&
            reviewLines.any((line) => line.isCounted) &&
            missingLines.isEmpty;
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
    final allowed = ref
        .watch(managerAccessProvider)
        .maybeWhen(data: (v) => v, orElse: () => false);
    if (!allowed) {
      return Scaffold(
        body: Center(child: Text(l10n.inventoryCountManagerAccessRequired)),
      );
    }

    final reviewLines = _buildReviewLines();
    final discrepancyLines = reviewLines
        .where((line) => line.isChanged)
        .toList();
    final unchangedLines = reviewLines
        .where((line) => line.isCounted && !line.isChanged)
        .toList();
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
            // Setup step only. Past counts carry the system quantity each one
            // corrected, and for a slow-moving item that is close enough to
            // today's expected figure to defeat the blind entry step — so the
            // history is reachable before a count starts, not during it.
            if (_currentStep == _InventoryCountStep.setup)
              IconButton(
                tooltip: l10n.inventoryCountHistoryTitle,
                icon: const Icon(Icons.history),
                onPressed: () => InventoryCountHistory.show(
                  context,
                  ref,
                  warehouse: _selectedWarehouse,
                ),
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loading || _selectedWarehouse == null
                  ? null
                  : _loadItems,
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
        bottomNavigationBar: _buildBottomBar(
          context,
          reviewLines,
          missingLines,
        ),
      ),
    );
  }
}

class _ReviewLine {
  const _ReviewLine({
    required this.itemCode,
    required this.itemName,
    required this.components,
    required this.countedStockQty,
    required this.currentQty,
    required this.delta,
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
  final List<_ReviewCountComponent> components;
  final double countedStockQty;
  final double currentQty;
  final double delta;
  final String stockUom;
  final bool isCounted;
  final bool isChanged;
  final bool isMissing;
  final bool hasBatchNo;
  final bool hasSerialNo;
  final double? valuationRate;
}

class _ReviewCountComponent {
  const _ReviewCountComponent({
    required this.qty,
    required this.uom,
    required this.stockQty,
  });

  final double qty;
  final String uom;
  final double stockQty;
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
  const _InventoryCountSummaryCard({required this.title, required this.value});

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
    required this.components,
    required this.uomOptions,
    required this.isCounted,
    required this.canAddUom,
    required this.onSubmitQuantity,
    required this.onDraftChanged,
    required this.onUomChanged,
    required this.onAddUom,
    required this.onRemoveUom,
    required this.onClear,
  });

  final String itemCode;
  final String itemName;
  final List<Map<String, dynamic>> components;
  final List<String> uomOptions;
  final bool isCounted;
  final bool canAddUom;
  final void Function(int index, String value) onSubmitQuantity;
  final void Function(int index, String value) onDraftChanged;
  final void Function(int index, String? uom) onUomChanged;
  final VoidCallback onAddUom;
  final ValueChanged<int> onRemoveUom;
  final VoidCallback onClear;

  @override
  State<_BlindEntryRow> createState() => _BlindEntryRowState();
}

class _BlindEntryRowState extends State<_BlindEntryRow> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isCommitted = widget.isCounted;
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
                      Text(
                        widget.itemName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.itemCode,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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
            ...widget.components.asMap().entries.map((entry) {
              final index = entry.key;
              final component = entry.value;
              final usedByOtherComponents = widget.components
                  .asMap()
                  .entries
                  .where((other) => other.key != index)
                  .map((other) => other.value['uom'])
                  .whereType<String>()
                  .toSet();
              final options = widget.uomOptions
                  .where((uom) => !usedByOtherComponents.contains(uom))
                  .toList();
              final componentKey =
                  component['uom']?.toString() ?? index.toString();
              final quantityText = component.containsKey('draft')
                  ? component['draft']?.toString() ?? ''
                  : _quantityText((component['qty'] as num?)?.toDouble());
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == widget.components.length - 1 ? 0 : 12,
                ),
                child: _BlindEntryComponentRow(
                  key: ValueKey('${widget.itemCode}:component:$componentKey'),
                  itemCode: widget.itemCode,
                  componentIndex: index,
                  quantityText: quantityText,
                  selectedUom: component['uom'] as String?,
                  uomOptions: options,
                  canRemove: widget.components.length > 1,
                  onSubmitQuantity: (value) =>
                      widget.onSubmitQuantity(index, value),
                  onDraftChanged: (value) =>
                      widget.onDraftChanged(index, value),
                  onUomChanged: (value) => widget.onUomChanged(index, value),
                  onRemove: () => widget.onRemoveUom(index),
                ),
              );
            }),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: widget.canAddUom ? widget.onAddUom : null,
                  icon: const Icon(Icons.add),
                  label: Text('${l10n.commonAdd} ${l10n.commonUomLabel}'),
                ),
                TextButton.icon(
                  onPressed: widget.onClear,
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

  String _quantityText(double? value) {
    if (value == null) {
      return '';
    }
    final text = value.toStringAsFixed(3);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

class _BlindEntryComponentRow extends StatefulWidget {
  const _BlindEntryComponentRow({
    super.key,
    required this.itemCode,
    required this.componentIndex,
    required this.quantityText,
    required this.selectedUom,
    required this.uomOptions,
    required this.canRemove,
    required this.onSubmitQuantity,
    required this.onDraftChanged,
    required this.onUomChanged,
    required this.onRemove,
  });

  final String itemCode;
  final int componentIndex;
  final String quantityText;
  final String? selectedUom;
  final List<String> uomOptions;
  final bool canRemove;
  final ValueChanged<String> onSubmitQuantity;
  final ValueChanged<String> onDraftChanged;
  final ValueChanged<String?> onUomChanged;
  final VoidCallback onRemove;

  @override
  State<_BlindEntryComponentRow> createState() =>
      _BlindEntryComponentRowState();
}

class _BlindEntryComponentRowState extends State<_BlindEntryComponentRow> {
  late final TextEditingController _controller;
  bool _hasLocalDraft = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.quantityText);
  }

  @override
  void didUpdateWidget(covariant _BlindEntryComponentRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = widget.quantityText;
    final quantityChanged = widget.quantityText != oldWidget.quantityText;
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

  bool get _canSubmit {
    final trimmed = _normalizeInventoryCountQuantity(_controller.text.trim());
    final parsed = double.tryParse(trimmed);
    return trimmed.isNotEmpty &&
        parsed != null &&
        parsed.isFinite &&
        parsed >= 0;
  }

  bool get _hasPendingChanges => _controller.text.trim() != widget.quantityText;

  void _markDraft(bool value) {
    if (_hasLocalDraft == value) {
      return;
    }
    setState(() => _hasLocalDraft = value);
  }

  void _setLocalText(String text) {
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _markDraft(true);
    widget.onDraftChanged(text);
  }

  void _adjustLocalCount(double delta) {
    final current =
        double.tryParse(_normalizeInventoryCountQuantity(_controller.text)) ??
        0.0;
    final next = (current + delta).clamp(0.0, double.infinity);
    _setLocalText(_textFor(next));
  }

  void _submitCurrentValue() {
    final trimmed = _normalizeInventoryCountQuantity(_controller.text.trim());
    final parsed = double.tryParse(trimmed);
    if (trimmed.isEmpty || parsed == null || !parsed.isFinite || parsed < 0) {
      return;
    }
    widget.onSubmitQuantity(trimmed);
    _markDraft(false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      key: ValueKey(
        '${widget.itemCode}:component:${widget.componentIndex}:controls',
      ),
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
            inputFormatters: [_inventoryCountQuantityFormatter],
            decoration: InputDecoration(labelText: l10n.inventoryCountCount),
            onChanged: (value) {
              _markDraft(_hasPendingChanges);
              widget.onDraftChanged(value);
            },
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
            initialValue: widget.selectedUom,
            decoration: InputDecoration(labelText: l10n.commonUomLabel),
            items: widget.uomOptions
                .map(
                  (uom) =>
                      DropdownMenuItem<String>(value: uom, child: Text(uom)),
                )
                .toList(),
            onChanged: widget.uomOptions.length <= 1
                ? null
                : widget.onUomChanged,
          ),
        ),
        FilledButton.icon(
          onPressed: _canSubmit ? _submitCurrentValue : null,
          icon: const Icon(Icons.check_circle_outline),
          label: Text(l10n.commonSubmit),
        ),
        if (widget.canRemove)
          IconButton(
            tooltip: l10n.inventoryCountClearEntry,
            icon: const Icon(Icons.delete_outline),
            onPressed: widget.onRemove,
          ),
      ],
    );
  }
}

class _ReviewLineCard extends StatelessWidget {
  const _ReviewLineCard({
    required this.line,
    required this.deltaText,
    required this.countedStockQtyText,
    required this.currentQtyText,
  });

  final _ReviewLine line;
  final String deltaText;
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
                      Text(
                        line.itemName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        line.itemCode,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (!line.isMissing)
                  Text(
                    '$deltaText ${line.stockUom}'.trim(),
                    style: TextStyle(
                      color: deltaColor,
                      fontWeight: FontWeight.w600,
                    ),
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
              ...line.components.map(
                (component) => Text(
                  l10n.inventoryCountCountedAmount(
                    _formatComponentQuantity(component.qty),
                    component.uom,
                  ),
                ),
              ),
              if (line.components.length > 1 ||
                  line.components.any(
                    (component) => component.uom != line.stockUom,
                  ))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.inventoryCountStockEquivalent(
                      countedStockQtyText,
                      line.stockUom,
                    ),
                  ),
                ),
            ],
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.inventoryCountCurrentAmount(currentQtyText, line.stockUom),
              ),
            ),
            if (!line.isMissing)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Text(l10n.inventoryCountDeltaLabel),
                    Text(
                      '$deltaText ${line.stockUom}'.trim(),
                      style: TextStyle(
                        color: deltaColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatComponentQuantity(double value) {
    final text = value.toStringAsFixed(3);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
