import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../manager/state/manager_providers.dart';
import '../data/manufacturing_service.dart';

class ManufacturingScreen extends ConsumerStatefulWidget {
  const ManufacturingScreen({super.key});

  @override
  ConsumerState<ManufacturingScreen> createState() => _ManufacturingScreenState();
}

class _ManufacturingScreenState extends ConsumerState<ManufacturingScreen> {
  String search = '';
  final List<_MfgLine> lines = [];

  @override
  void dispose() {
    // Dispose controllers for all remaining lines to avoid leaks
    for (final l in lines) {
      l.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final allowed = ref.watch(managerAccessProvider).maybeWhen(data: (v) => v, orElse: () => false);
    if (!allowed) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.manufacturingTitle)),
        drawer: const AppDrawer(),
        body: Center(child: Text(l10n.manufacturingManagersOnly)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manufacturingTitle),
        actions: [
          IconButton(
            tooltip: l10n.manufacturingRecentWorkOrdersTooltip,
            icon: const Icon(Icons.history),
            onPressed: _openRecentWorkOrders,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Row(
        children: [
          // Left: items with default BOM
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.manufacturingSearchDefaultBom),
                    onChanged: (v) => setState(() => search = v),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _buildItemResults()),
                ],
              ),
            ),
          ),
          Container(width: 1, color: Colors.grey.shade300),
          // Right: selected manufacturing lines
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.factory),
                      const SizedBox(width: 8),
                      Text(l10n.manufacturingWorkOrdersTitle(lines.length), style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: lines.isEmpty || !lines.any((l) => l.itemQty > 0) ? null : _submitAll,
                        icon: const Icon(Icons.send),
                        label: Text(l10n.manufacturingSubmitAll),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: lines.isEmpty
                        ? Center(child: Text(l10n.manufacturingNoItemsSelected))
                        : ListView.separated(
                            itemCount: lines.length,
                            separatorBuilder: (a, b) => const SizedBox(height: 10),
                            itemBuilder: (ctx, i) => _buildLineCard(lines[i], i),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemResults() {
    final service = ref.read(manufacturingServiceProvider);
    final l10n = context.l10n;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: service.listDefaultBomItems(search),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? [];
        if (items.isEmpty) return Center(child: Text(l10n.manufacturingNoItemsFound));
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (a, b) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final it = items[i];
            final code = it['item_code'];
            final name = it['item_name'] ?? code;
            final stockUom = it['stock_uom'];
            final bomQty = (it['bom_qty'] as num).toDouble();
            return ListTile(
              title: Text(
                l10n.commonNameWithCode(name, code),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                l10n.manufacturingBomDescription(
                  (it['default_bom'] ?? '').toString(),
                  bomQty.toStringAsFixed(2),
                  stockUom?.toString() ?? '',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: ElevatedButton(
                onPressed: () async {
                  // Fetch BOM details for components
                  final details = await service.getBomDetails(code);
                  setState(() {
                    lines.add(_MfgLine.from(details));
                  });
                },
                child: Text(l10n.commonAdd),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLineCard(_MfgLine line, int index) {
    final l10n = context.l10n;
    final dt = line.scheduledAt;
    final dateLabel = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final timeLabel = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${line.itemName} (${line.itemCode})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  onPressed: line.itemQty > 0 ? () => _submitSingle(line) : null,
                  icon: const Icon(Icons.playlist_add_check),
                  label: Text(l10n.commonSubmit),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() {
                      final removed = lines.removeAt(index);
                      removed.dispose();
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // BOM count (multiplier)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.manufacturingBomLabel),
                    const SizedBox(width: 6),
                    _StepperButton(
                      icon: Icons.remove,
                      onPressed: () => setState(() => line.decBom()),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 90,
                      child: TextFormField(
                        controller: line.bomCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (v) {
                          setState(() {
                            line.onBomChanged(v);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    _StepperButton(
                      icon: Icons.add,
                      onPressed: () => setState(() => line.incBom()),
                    ),
                  ],
                ),
                // OR item quantity
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.commonQtyWithUom(line.stockUom)),
                    const SizedBox(width: 6),
                    _StepperButton(
                      icon: Icons.remove,
                      onPressed: () => setState(() => line.decQty()),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 110,
                      child: TextFormField(
                        controller: line.qtyCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (v) {
                          setState(() {
                            line.onQtyChanged(v);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    _StepperButton(
                      icon: Icons.add,
                      onPressed: () => setState(() => line.incQty()),
                    ),
                  ],
                ),
                // Date & time pickers
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dt,
                          firstDate: DateTime(now.year - 1),
                          lastDate: DateTime(now.year + 2),
                        );
                        if (picked != null) {
                          setState(() => line.scheduledAt = DateTime(picked.year, picked.month, picked.day, dt.hour, dt.minute));
                        }
                      },
                      child: Text(dateLabel),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(dt));
                        if (picked != null) {
                          setState(() => line.scheduledAt = DateTime(dt.year, dt.month, dt.day, picked.hour, picked.minute));
                        }
                      },
                      child: Text(timeLabel),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Components collapsible
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(l10n.manufacturingRequiredItems),
              children: [
                _buildComponents(line),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}:00';
  }

  void _showProgress(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: SizedBox(
          height: 64,
          child: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitAll() async {
    final service = ref.read(manufacturingServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    final l10n = context.l10n;

    // Build payload lines (skip zero/negative quantities)
    final payload = [
      for (final l in lines)
        if (l.itemQty > 0)
          {
            'item_code': l.itemCode,
            'bom_name': l.bomName,
            'item_qty': l.itemQty,
            'scheduled_at': _formatTimestamp(l.scheduledAt),
          }
    ];
    if (payload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.manufacturingNothingToSubmit)));
      return;
    }

    // Show progress dialog (do not await)
    _showProgress(l10n.manufacturingSubmittingWorkOrders);

    Map<String, dynamic> result;
    try {
      // Actually call the API while dialog is shown
      result = await service.submitWorkOrders(payload);
    } catch (e) {
      if (navigator.canPop()) navigator.pop();
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.manufacturingSubmitFailed('$e'))));
      return;
    }

    if (navigator.canPop()) navigator.pop();

    // Summarize results if available
    String message = l10n.manufacturingSubmitAllSuccess;
    if (result.containsKey('results') && result['results'] is List) {
      final list = (result['results'] as List);
      final okCount = list.where((e) => e is Map && (e['ok'] == true || e['status'] == 'success')).length;
      message = l10n.manufacturingSubmitAllResult(list.length, okCount);

      // Remove successfully submitted lines from UI (match by item_code+bom_name+qty timestamp)
      final toRemove = <int>{};
      for (final e in list) {
        if (e is Map && (e['ok'] == true || e['status'] == 'success')) {
          final line = e['line'] as Map?;
          if (line == null) continue;
          for (int i = 0; i < lines.length; i++) {
            final l = lines[i];
            final match = l.itemCode == line['item_code'] &&
                l.bomName == line['bom_name'] &&
                (l.itemQty - (line['item_qty'] as num).toDouble()).abs() < 0.0001;
            if (match) {
              toRemove.add(i);
              break;
            }
          }
        }
      }
      if (toRemove.isNotEmpty) {
        setState(() {
          final sorted = toRemove.toList()..sort((a, b) => b.compareTo(a));
          for (final idx in sorted) {
            if (idx >= 0 && idx < lines.length) {
              lines[idx].dispose();
              lines.removeAt(idx);
            }
          }
        });
      }
    }

    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submitSingle(_MfgLine l) async {
    if (l.itemQty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.manufacturingQuantityMustBePositive)));
      return;
    }

    final service = ref.read(manufacturingServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    final l10n = context.l10n;

    // Show progress dialog (do not await)
    _showProgress(l10n.manufacturingSubmittingSingleWorkOrder);

    Map<String, dynamic> result;
    try {
      result = await service.submitSingleWorkOrder(
        itemCode: l.itemCode,
        bomName: l.bomName,
        itemQty: l.itemQty,
        scheduledAt: _formatTimestamp(l.scheduledAt),
      );
    } catch (e) {
      if (navigator.canPop()) navigator.pop();
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.manufacturingSubmitFailed('$e'))));
      return;
    }

    if (navigator.canPop()) navigator.pop();

    String message = l10n.manufacturingSubmitResult;
    if (result.containsKey('status')) message = l10n.manufacturingSubmitStatus('${result['status']}');
    if (result.containsKey('work_order')) {
      message += l10n.manufacturingSubmitWorkOrder('${result['work_order']}');
    }

    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(message)));

    // Remove the line on success (heuristic: presence of work_order indicates success)
    if ((result['work_order'] ?? '').toString().isNotEmpty) {
      setState(() {
        lines.remove(l);
        l.dispose();
      });
    }
  }

  Future<void> _openRecentWorkOrders() async {
    final service = ref.read(manufacturingServiceProvider);
    List<Map<String, dynamic>> rows = const [];
    try {
      rows = await service.listRecentWorkOrders(limit: 100);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.manufacturingLoadFailed('$e'))));
      return;
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
      title: Text(context.l10n.manufacturingRecentWorkOrdersTitle),
          content: SizedBox(
            width: 600,
            height: 400,
            child: rows.isEmpty
        ? Center(child: Text(context.l10n.manufacturingNoWorkOrders))
                : ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, i2) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final r = rows[i];
                      final name = r['name'];
                      final item = r['production_item'];
                      final qty = (r['qty'] as num?)?.toDouble() ?? 0;
                      final bom = r['bom_no'] ?? '';
                      final status = r['status'] ?? '';
                      final created = (r['creation'] ?? '').toString();
                      return ListTile(
                        dense: true,
                        title: Text(context.l10n.manufacturingRecentWorkOrderTitle('$name', '$status')),
                        subtitle: Text(context.l10n.manufacturingRecentWorkOrderSubtitle('$item', qty.toString(), '$bom')),
                        trailing: Text(created),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(), child: Text(context.l10n.commonClose)),
          ],
        );
      },
    );
  }

  Widget _buildComponents(_MfgLine line) {
    final l10n = context.l10n;
    final comps = line.componentsForCurrentQty();
    return Column(
      children: [
        for (final c in comps)
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Text(l10n.commonNameWithCode(c.itemName, c.itemCode)),
            subtitle: c.availableQty != null
                ? Text(l10n.manufacturingComponentAvailable(c.availableQty!.toStringAsFixed(3), c.uom))
                : null,
            trailing: Text('${c.totalQty.toStringAsFixed(3)} ${c.uom}'),
          ),
      ],
    );
  }
}

class _MfgLine {
  final String itemCode;
  final String itemName;
  final String bomName;
  final String stockUom;
  final double bomQtyYield; // how many finished items one BOM produces
  double bomCount; // editable
  double itemQty; // editable
  DateTime scheduledAt;
  final List<_Component> components;

  // Controllers for two-way binding between BOM count and quantity
  final TextEditingController bomCtrl;
  final TextEditingController qtyCtrl;
  bool _updatingFromBom = false;
  bool _updatingFromQty = false;

  _MfgLine({
    required this.itemCode,
    required this.itemName,
    required this.bomName,
    required this.stockUom,
    required this.bomQtyYield,
    required this.bomCount,
    required this.itemQty,
    required this.scheduledAt,
    required this.components,
  })  : bomCtrl = TextEditingController(text: bomCount.toStringAsFixed(2)),
        qtyCtrl = TextEditingController(text: itemQty.toStringAsFixed(2));

  factory _MfgLine.from(Map<String, dynamic> bomDetails) {
    final bomQty = (bomDetails['bom_qty'] as num).toDouble();
    final comps = ((bomDetails['components'] as List?) ?? [])
        .map((e) => _Component(
              itemCode: e['item_code'] as String,
              itemName: (e['item_name'] ?? e['item_code']) as String,
              uom: e['uom'] as String,
              qtyPerBom: (e['qty_per_bom'] as num).toDouble(),
              availableQty: (e['available_qty'] as num?)?.toDouble(),
            ))
        .toList();
    return _MfgLine(
      itemCode: bomDetails['item_code'] as String,
      itemName: (bomDetails['item_name'] ?? bomDetails['item_code']) as String,
      bomName: bomDetails['default_bom'] as String,
      stockUom: bomDetails['stock_uom'] as String,
      bomQtyYield: bomQty,
      bomCount: 1,
      itemQty: bomQty, // initial linkage: 1 BOM -> bomQty items
      scheduledAt: DateTime.now(),
      components: comps,
    );
  }

  // Maintain linkage: BOM count <-> item quantity
  void setBomCount(double n) {
    bomCount = n > 0 ? n : 0;
    itemQty = bomCount * bomQtyYield;
    // Update controllers safely
    _updatingFromBom = true;
    bomCtrl.text = bomCount.toStringAsFixed(2);
    qtyCtrl.text = itemQty.toStringAsFixed(2);
    _updatingFromBom = false;
  }

  void setItemQty(double n) {
    itemQty = n > 0 ? n : 0;
    // derive bom count; avoid divide-by-zero
    bomCount = bomQtyYield > 0 ? (itemQty / bomQtyYield) : 0;
    // Update controllers safely
    _updatingFromQty = true;
    qtyCtrl.text = itemQty.toStringAsFixed(2);
    bomCtrl.text = bomCount.toStringAsFixed(2);
    _updatingFromQty = false;
  }

  // Steppers
  void incBom({double step = 1}) => setBomCount(bomCount + step);
  void decBom({double step = 1}) => setBomCount((bomCount - step).clamp(0, double.infinity));
  void incQty({double step = 1}) => setItemQty(itemQty + step);
  void decQty({double step = 1}) => setItemQty((itemQty - step).clamp(0, double.infinity));

  List<_ComponentWithTotal> componentsForCurrentQty() {
    // per-BOM comp qty * bomCount
    return components
    .map((c) => _ComponentWithTotal(
              itemCode: c.itemCode,
              itemName: c.itemName,
              uom: c.uom,
      totalQty: c.qtyPerBom * bomCount,
      availableQty: c.availableQty,
            ))
        .toList();
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

extension _MfgLineEditing on _MfgLine {
  // Parse and update from BOM field; guard to avoid feedback loop
  void onBomChanged(String v) {
    if (_updatingFromQty) return; // ignore changes triggered by qty updates
    final n = double.tryParse(v.trim()) ?? bomCount;
    setBomCount(n);
  }

  // Parse and update from Qty field; guard to avoid feedback loop
  void onQtyChanged(String v) {
    if (_updatingFromBom) return; // ignore changes triggered by bom updates
    final n = double.tryParse(v.trim()) ?? itemQty;
    setItemQty(n);
  }

  void dispose() {
    bomCtrl.dispose();
    qtyCtrl.dispose();
  }
}

class _Component {
  final String itemCode;
  final String itemName;
  final String uom;
  final double qtyPerBom;
  final double? availableQty;

  _Component({required this.itemCode, required this.itemName, required this.uom, required this.qtyPerBom, this.availableQty});
}

class _ComponentWithTotal {
  final String itemCode;
  final String itemName;
  final String uom;
  final double totalQty;
  final double? availableQty;

  _ComponentWithTotal({required this.itemCode, required this.itemName, required this.uom, required this.totalQty, this.availableQty});
}
