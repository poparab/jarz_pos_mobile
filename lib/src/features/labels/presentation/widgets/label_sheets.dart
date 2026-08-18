import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/labels_repository.dart';
import '../../models/label_models.dart';

/// What [PrintOrderSheet] collects. Ordering happens in SHEETS — the print
/// house sells sheets, not labels.
class PrintOrderRequest {
  final int qtySheets;
  final String? supplier;
  final double? totalCost;
  final String? notes;

  const PrintOrderRequest({
    required this.qtySheets,
    required this.supplier,
    required this.totalCost,
    required this.notes,
  });
}

/// What [RecordBillSheet] collects — the printer's bill for one batch.
class BillRequest {
  final String supplier;
  final double totalCost;
  final String? billNo;

  const BillRequest({
    required this.supplier,
    required this.totalCost,
    required this.billNo,
  });
}

/// What [CountSheet] collects.
///
/// Deliberately its own type rather than a reuse of [MovementRequest]: a count
/// is an absolute number that the server turns into a delta, not a movement, and
/// a shared type invites somebody to post it down the movement endpoint.
class CountRequest {
  final int countedQty;
  final String? remarks;

  const CountRequest({required this.countedQty, required this.remarks});
}

/// What [MovementSheet] collects.
class MovementRequest {
  final String movementType;
  final int qty;
  final String? remarks;

  const MovementRequest({
    required this.movementType,
    required this.qty,
    required this.remarks,
  });
}

/// What [LabelPolicySheet] collects.
class LabelPolicyRequest {
  final String labelTitle;
  final bool wePrint;
  final bool enabled;

  /// Empty string clears the home location server-side.
  final String storageLocation;
  final double labelsPerUnit;

  /// Zero means "use the size default" (21 Medium / 18 Large).
  final int labelsPerSheet;
  final int defaultPrintSheets;
  final int minStockQty;
  final String notes;

  const LabelPolicyRequest({
    required this.labelTitle,
    required this.wePrint,
    required this.enabled,
    required this.storageLocation,
    required this.labelsPerUnit,
    required this.labelsPerSheet,
    required this.defaultPrintSheets,
    required this.minStockQty,
    required this.notes,
  });
}

// ---------------------------------------------------------------------------
// Shared chrome
// ---------------------------------------------------------------------------
class _SheetScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> fields;
  final Widget action;

  const _SheetScaffold({
    required this.title,
    this.subtitle,
    required this.fields,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(title, style: theme.textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 16),
            ...fields,
            const SizedBox(height: 20),
            action,
          ],
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration(String label, {String? helper, String? suffix}) {
  return InputDecoration(
    labelText: label,
    helperText: helper,
    helperMaxLines: 3,
    suffixText: suffix,
    border: const OutlineInputBorder(),
    isDense: true,
  );
}

final _digits = [FilteringTextInputFormatter.digitsOnly];

int _parseInt(TextEditingController controller, {int fallback = 0}) {
  return int.tryParse(controller.text.trim()) ?? fallback;
}

double? _parseCost(TextEditingController controller) {
  final value = double.tryParse(controller.text.trim());
  return (value == null || value <= 0) ? null : value;
}

// ---------------------------------------------------------------------------
// Print supplier picker
// ---------------------------------------------------------------------------
/// Searchable supplier field backed by `get_print_suppliers`. Selecting a
/// result locks it in; typing again clears the selection and searches anew.
class SupplierField extends ConsumerStatefulWidget {
  final String? initialSupplier;
  final ValueChanged<LabelSupplierOption?> onChanged;
  final String label;

  const SupplierField({
    super.key,
    required this.onChanged,
    this.initialSupplier,
    this.label = 'Print supplier (optional)',
  });

  @override
  ConsumerState<SupplierField> createState() => _SupplierFieldState();
}

class _SupplierFieldState extends ConsumerState<SupplierField> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<LabelSupplierOption> _results = const [];
  LabelSupplierOption? _selected;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSupplier?.trim();
    if (initial != null && initial.isNotEmpty) {
      _selected = LabelSupplierOption(name: initial, supplierName: initial);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);
    try {
      final results =
          await ref.read(labelsRepositoryProvider).searchPrintSuppliers(query);
      if (mounted) setState(() => _results = results);
    } catch (_) {
      if (mounted) setState(() => _results = const []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _select(LabelSupplierOption? option) {
    setState(() {
      _selected = option;
      _results = const [];
      _controller.clear();
    });
    widget.onChanged(option);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    if (selected != null) {
      return InputDecorator(
        decoration: _fieldDecoration(widget.label),
        child: Row(
          children: [
            const Icon(Icons.factory_outlined, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selected.supplierName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: () => _select(null),
              child: const Icon(Icons.clear, size: 18),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          decoration: _fieldDecoration(widget.label).copyWith(
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          onChanged: _onChanged,
        ),
        if (_results.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 170),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final option = _results[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.factory_outlined, size: 18),
                  title: Text(option.supplierName),
                  onTap: () => _select(option),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Physical count
// ---------------------------------------------------------------------------
class CountSheet extends StatefulWidget {
  final CustomerLabel label;

  const CountSheet({super.key, required this.label});

  @override
  State<CountSheet> createState() => _CountSheetState();
}

class _CountSheetState extends State<CountSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: '${widget.label.onHandQty}');
  final _remarksController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final counted = int.tryParse(_controller.text.trim());
    final delta = counted == null ? null : counted - widget.label.onHandQty;

    return _SheetScaffold(
      title: 'Count labels',
      subtitle:
          'Enter what is physically on the shelf. The difference is posted to '
          'the ledger, so a label that keeps going missing shows up as a run of '
          'corrections rather than vanishing quietly.',
      fields: [
        TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: _digits,
          decoration: _fieldDecoration(
            'Counted quantity',
            helper: 'System currently shows ${widget.label.onHandQty}.',
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (delta != null && delta != 0) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                delta > 0 ? Icons.trending_up : Icons.trending_down,
                size: 18,
                color: delta > 0
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFB3261E),
              ),
              const SizedBox(width: 6),
              Text(
                delta > 0
                    ? '$delta more than recorded'
                    : '${delta.abs()} fewer than recorded',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _remarksController,
          decoration: _fieldDecoration('Note (optional)'),
        ),
      ],
      action: FilledButton(
        onPressed: counted == null
            ? null
            : () => Navigator.of(context).pop(
                  CountRequest(
                    countedQty: counted,
                    remarks: _remarksController.text.trim().isEmpty
                        ? null
                        : _remarksController.text.trim(),
                  ),
                ),
        child: const Text('Save count'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Send a batch to the printer (in sheets)
// ---------------------------------------------------------------------------
class PrintOrderSheet extends ConsumerStatefulWidget {
  final CustomerLabel label;

  const PrintOrderSheet({super.key, required this.label});

  @override
  ConsumerState<PrintOrderSheet> createState() => _PrintOrderSheetState();
}

class _PrintOrderSheetState extends ConsumerState<PrintOrderSheet> {
  late final TextEditingController _sheetsController = TextEditingController(
    text:
        '${widget.label.suggestedPrintSheets > 0 ? widget.label.suggestedPrintSheets : widget.label.defaultPrintSheets}',
  );
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  LabelSupplierOption? _supplier;

  @override
  void dispose() {
    _sheetsController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = widget.label;
    final sheets = int.tryParse(_sheetsController.text.trim()) ?? 0;
    final labels = label.labelsForSheets(sheets);

    return _SheetScaffold(
      title: 'Order a print batch',
      subtitle: '${label.customerName} · ${label.labelTitle}'
          '${label.size == null ? '' : ' · ${label.size}'}',
      fields: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.event_available, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label.expectedReadyIfOrderedToday == null
                      ? 'Printing takes ${label.leadDaysMin}–${label.leadDaysMax} '
                          'working days (${label.restDay} excluded).'
                      : 'Ordered today, ready around '
                          '${_dmy(label.expectedReadyIfOrderedToday!)} — '
                          '${label.leadDaysMin}–${label.leadDaysMax} working days, '
                          '${label.restDay} excluded.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _sheetsController,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: _digits,
          decoration: _fieldDecoration(
            'Sheets to print',
            helper: label.suggestedPrintSheets > 0
                ? 'Suggested ${label.suggestedPrintSheets} sheet'
                    '${label.suggestedPrintSheets == 1 ? '' : 's'}, based on '
                    'current usage and the usual batch.'
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (sheets > 0 && labels > 0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.grid_on, size: 16),
              const SizedBox(width: 6),
              Text(
                '$sheets sheet${sheets == 1 ? '' : 's'} = $labels labels',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        SupplierField(
          initialSupplier: null,
          onChanged: (option) => setState(() => _supplier = option),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _costController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _fieldDecoration(
            'Net cost (optional)',
            helper: 'What the printer quoted for the batch, before VAT. The '
                'bill itself is recorded when it arrives.',
            suffix: 'EGP',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: _fieldDecoration('Notes (optional)'),
        ),
      ],
      action: FilledButton.icon(
        onPressed: sheets <= 0
            ? null
            : () => Navigator.of(context).pop(
                  PrintOrderRequest(
                    qtySheets: sheets,
                    supplier: _supplier?.name,
                    totalCost: _parseCost(_costController),
                    notes: _notesController.text.trim().isEmpty
                        ? null
                        : _notesController.text.trim(),
                  ),
                ),
        icon: const Icon(Icons.local_printshop),
        label: const Text('Send to printer'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Receive a batch back
// ---------------------------------------------------------------------------
class ReceiveBatchSheet extends StatefulWidget {
  final LabelPrintOrder order;

  const ReceiveBatchSheet({super.key, required this.order});

  @override
  State<ReceiveBatchSheet> createState() => _ReceiveBatchSheetState();
}

class _ReceiveBatchSheetState extends State<ReceiveBatchSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: '${widget.order.qty}');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final received = int.tryParse(_controller.text.trim()) ?? 0;
    final ordered = order.qtySheets > 0
        ? '${order.qtySheets} sheet${order.qtySheets == 1 ? '' : 's'} · ${order.qty} labels'
        : '${order.qty} labels';
    return _SheetScaffold(
      title: 'Receive batch',
      subtitle: '${order.name} · ordered $ordered',
      fields: [
        TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: _digits,
          decoration: _fieldDecoration(
            'Labels received',
            helper: 'Adjust if the printer delivered short. Only this many are '
                'added to stock.',
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
      action: FilledButton.icon(
        onPressed: received <= 0 ? null : () => Navigator.of(context).pop(received),
        icon: const Icon(Icons.inventory_2),
        label: const Text('Add to stock'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Record the printer's bill
// ---------------------------------------------------------------------------
class RecordBillSheet extends StatefulWidget {
  final LabelPrintOrder order;

  const RecordBillSheet({super.key, required this.order});

  @override
  State<RecordBillSheet> createState() => _RecordBillSheetState();
}

class _RecordBillSheetState extends State<RecordBillSheet> {
  late final TextEditingController _costController = TextEditingController(
    text: widget.order.totalCost > 0
        ? widget.order.totalCost.toStringAsFixed(
            widget.order.totalCost == widget.order.totalCost.roundToDouble()
                ? 0
                : 2)
        : '',
  );
  final _billNoController = TextEditingController();
  LabelSupplierOption? _supplier;

  @override
  void initState() {
    super.initState();
    final existing = widget.order.supplier;
    if (existing != null && existing.isNotEmpty) {
      _supplier = LabelSupplierOption(name: existing, supplierName: existing);
    }
  }

  @override
  void dispose() {
    _costController.dispose();
    _billNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final cost = _parseCost(_costController);
    final ordered = order.qtySheets > 0
        ? '${order.qtySheets} sheet${order.qtySheets == 1 ? '' : 's'}'
        : '${order.qty} labels';

    return _SheetScaffold(
      title: "Record the printer's bill",
      subtitle: '${order.name} · $ordered. This books a supplier purchase '
          'invoice, so the batch lands on the books at its real cost.',
      fields: [
        SupplierField(
          initialSupplier: order.supplier,
          label: 'Print supplier',
          onChanged: (option) => setState(() => _supplier = option),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _costController,
          autofocus: order.totalCost <= 0,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _fieldDecoration(
            'Net cost',
            helper: 'What the printer charged for this batch, before VAT.',
            suffix: 'EGP',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _billNoController,
          decoration: _fieldDecoration("Supplier's bill no. (optional)"),
        ),
      ],
      action: FilledButton.icon(
        onPressed: (_supplier == null || cost == null)
            ? null
            : () => Navigator.of(context).pop(
                  BillRequest(
                    supplier: _supplier!.name,
                    totalCost: cost,
                    billNo: _billNoController.text.trim().isEmpty
                        ? null
                        : _billNoController.text.trim(),
                  ),
                ),
        icon: const Icon(Icons.receipt_long),
        label: const Text('Record bill'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Manual ledger entry
// ---------------------------------------------------------------------------
class MovementSheet extends StatefulWidget {
  final CustomerLabel label;

  const MovementSheet({super.key, required this.label});

  @override
  State<MovementSheet> createState() => _MovementSheetState();
}

class _MovementSheetState extends State<MovementSheet> {
  final _qtyController = TextEditingController();
  final _remarksController = TextEditingController();
  String _type = 'Consumed';

  static const _types = <String, String>{
    'Consumed': 'Used on jars',
    'Print Received': 'Received from the printer',
    'Scrapped': 'Damaged or thrown away',
    'Adjustment': 'Correction (+/-)',
  };

  @override
  void dispose() {
    _qtyController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
    final isAdjustment = _type == 'Adjustment';

    return _SheetScaffold(
      title: 'Record a movement',
      subtitle: '${widget.label.customerName} · ${widget.label.labelTitle}',
      fields: [
        DropdownButtonFormField<String>(
          initialValue: _type,
          isExpanded: true,
          decoration: _fieldDecoration('What happened'),
          items: _types.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (value) => setState(() => _type = value ?? _type),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _qtyController,
          autofocus: true,
          keyboardType: TextInputType.numberWithOptions(signed: isAdjustment),
          inputFormatters: isAdjustment
              ? [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))]
              : _digits,
          decoration: _fieldDecoration(
            'Quantity',
            helper: isAdjustment
                ? 'Use a minus sign to reduce stock.'
                : 'Enter a plain number — the direction follows from the type.',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _remarksController,
          decoration: _fieldDecoration('Note (optional)'),
        ),
      ],
      action: FilledButton(
        onPressed: qty == 0
            ? null
            : () => Navigator.of(context).pop(
                  MovementRequest(
                    movementType: _type,
                    qty: qty,
                    remarks: _remarksController.text.trim().isEmpty
                        ? null
                        : _remarksController.text.trim(),
                  ),
                ),
        child: const Text('Record'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit the label's policy
// ---------------------------------------------------------------------------
class LabelPolicySheet extends ConsumerStatefulWidget {
  final CustomerLabel label;

  const LabelPolicySheet({super.key, required this.label});

  @override
  ConsumerState<LabelPolicySheet> createState() => _LabelPolicySheetState();
}

class _LabelPolicySheetState extends ConsumerState<LabelPolicySheet> {
  late final TextEditingController _titleController =
      TextEditingController(text: widget.label.labelTitle);
  late final TextEditingController _perUnitController = TextEditingController(
      text: widget.label.labelsPerUnit.toStringAsFixed(
          widget.label.labelsPerUnit == widget.label.labelsPerUnit.roundToDouble()
              ? 0
              : 2));
  late final TextEditingController _minStockController =
      TextEditingController(text: '${widget.label.minStockQty}');
  late final TextEditingController _sheetsController =
      TextEditingController(text: '${widget.label.defaultPrintSheets}');
  late final TextEditingController _perSheetController =
      TextEditingController(text: '${widget.label.labelsPerSheet}');
  late final TextEditingController _notesController =
      TextEditingController(text: widget.label.notes ?? '');

  late bool _wePrint = widget.label.wePrint;
  late bool _enabled = widget.label.enabled;
  late String? _location = widget.label.storageLocation;

  @override
  void dispose() {
    _titleController.dispose();
    _perUnitController.dispose();
    _minStockController.dispose();
    _sheetsController.dispose();
    _perSheetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(labelStorageLocationsProvider);

    return _SheetScaffold(
      title: 'Label settings',
      subtitle: '${widget.label.customerName}'
          '${widget.label.size == null ? '' : ' · ${widget.label.size}'}',
      fields: [
        TextField(
          controller: _titleController,
          decoration: _fieldDecoration('Label name'),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _wePrint,
          onChanged: (value) => setState(() => _wePrint = value),
          title: const Text('We print this label'),
          subtitle: const Text(
            'Off means the customer supplies their own — stops all counting and '
            'alerting without losing the history.',
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _enabled,
          onChanged: (value) => setState(() => _enabled = value),
          title: const Text('Active'),
          subtitle: const Text('Turn off to retire a design that is no longer used.'),
        ),
        const SizedBox(height: 8),
        locations.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => const SizedBox.shrink(),
          data: (options) {
            final known = options.map((o) => o.name).toSet();
            return DropdownButtonFormField<String?>(
              initialValue:
                  (_location != null && known.contains(_location)) ||
                          _location == null
                      ? _location
                      : null,
              isExpanded: true,
              decoration: _fieldDecoration(
                'Stored at',
                helper: 'The branch or factory where this label physically lives.',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Not set'),
                ),
                ...options.map(
                  (option) => DropdownMenuItem<String?>(
                    value: option.name,
                    child: Text(option.label, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _location = value),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minStockController,
                keyboardType: TextInputType.number,
                inputFormatters: _digits,
                decoration: _fieldDecoration('Minimum stock'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _sheetsController,
                keyboardType: TextInputType.number,
                inputFormatters: _digits,
                decoration: _fieldDecoration('Usual batch (sheets)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _perSheetController,
                keyboardType: TextInputType.number,
                inputFormatters: _digits,
                decoration: _fieldDecoration(
                  'Labels per sheet',
                  helper: 'Leave 0 for the size default: 21 Medium, 18 Large.',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _perUnitController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _fieldDecoration(
                  'Labels per jar',
                  helper: 'Usually 1.',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: _fieldDecoration('Notes'),
        ),
      ],
      action: FilledButton(
        onPressed: () => Navigator.of(context).pop(
          LabelPolicyRequest(
            labelTitle: _titleController.text.trim().isEmpty
                ? widget.label.labelTitle
                : _titleController.text.trim(),
            wePrint: _wePrint,
            enabled: _enabled,
            // An empty string clears the home location server-side.
            storageLocation: _location ?? '',
            labelsPerUnit:
                double.tryParse(_perUnitController.text.trim()) ?? 1,
            labelsPerSheet: _parseInt(_perSheetController),
            defaultPrintSheets: _parseInt(_sheetsController),
            minStockQty: _parseInt(_minStockController),
            notes: _notesController.text.trim(),
          ),
        ),
        child: const Text('Save'),
      ),
    );
  }
}

String _dmy(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]}';
}
