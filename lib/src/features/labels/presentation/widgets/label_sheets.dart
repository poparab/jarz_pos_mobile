import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/labels_repository.dart';
import '../../models/label_models.dart';

/// What [NewLabelSheet] collects.
class NewLabelRequest {
  final String customer;
  final String labelTitle;
  final bool wePrint;
  final String? itemGroup;
  final double labelsPerUnit;
  final int minStockQty;
  final int reorderQty;
  final int openingQty;
  final String? notes;

  const NewLabelRequest({
    required this.customer,
    required this.labelTitle,
    required this.wePrint,
    required this.itemGroup,
    required this.labelsPerUnit,
    required this.minStockQty,
    required this.reorderQty,
    required this.openingQty,
    required this.notes,
  });
}

/// What [PrintOrderSheet] collects.
class PrintOrderRequest {
  final int qty;
  final String? printerName;
  final String? notes;

  const PrintOrderRequest({
    required this.qty,
    required this.printerName,
    required this.notes,
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
  final String itemGroup;
  final double labelsPerUnit;
  final int minStockQty;
  final int reorderQty;
  final String notes;

  const LabelPolicyRequest({
    required this.labelTitle,
    required this.wePrint,
    required this.enabled,
    required this.itemGroup,
    required this.labelsPerUnit,
    required this.minStockQty,
    required this.reorderQty,
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

// ---------------------------------------------------------------------------
// Start tracking a customer's label
// ---------------------------------------------------------------------------
class NewLabelSheet extends ConsumerStatefulWidget {
  const NewLabelSheet({super.key});

  @override
  ConsumerState<NewLabelSheet> createState() => _NewLabelSheetState();
}

class _NewLabelSheetState extends ConsumerState<NewLabelSheet> {
  final _searchController = TextEditingController();
  final _titleController = TextEditingController(text: 'Default');
  final _perUnitController = TextEditingController(text: '1');
  final _minStockController = TextEditingController(text: '0');
  final _batchController = TextEditingController(text: '0');
  final _openingController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  Timer? _debounce;
  List<LabelCustomerOption> _results = const [];
  LabelCustomerOption? _selected;
  bool _searching = false;
  bool _wePrint = true;
  String? _itemGroup;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _titleController.dispose();
    _perUnitController.dispose();
    _minStockController.dispose();
    _batchController.dispose();
    _openingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);
    try {
      final results =
          await ref.read(labelsRepositoryProvider).searchCustomers(query);
      if (mounted) setState(() => _results = results);
    } catch (_) {
      if (mounted) setState(() => _results = const []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemGroups = ref.watch(labelItemGroupsProvider);

    return _SheetScaffold(
      title: 'Track a label',
      subtitle:
          'Pick the B2B customer whose labels JARZ prints. Leave "We print this '
          'label" off for customers who bring their own.',
      fields: [
        if (_selected == null) ...[
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: _fieldDecoration('Search customers').copyWith(
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
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: _results.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _searching ? 'Searching…' : 'No company customers matched.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final option = _results[index];
                      return ListTile(
                        dense: true,
                        title: Text(option.customerName),
                        subtitle: option.customerGroup == null
                            ? null
                            : Text(option.customerGroup!),
                        trailing: option.labelCount > 0
                            ? Chip(
                                label: Text('${option.labelCount}'),
                                visualDensity: VisualDensity.compact,
                              )
                            : const Icon(Icons.chevron_right),
                        onTap: () => setState(() => _selected = option),
                      );
                    },
                  ),
          ),
        ] else ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.storefront),
            title: Text(_selected!.customerName),
            subtitle: Text(_selected!.customer),
            trailing: TextButton(
              onPressed: () => setState(() => _selected = null),
              child: const Text('Change'),
            ),
          ),
          const Divider(),
          TextField(
            controller: _titleController,
            decoration: _fieldDecoration(
              'Label name',
              helper: 'Name this design, e.g. "250g Jar". Use one label per '
                  'design when a customer has more than one.',
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _wePrint,
            onChanged: (value) => setState(() => _wePrint = value),
            title: const Text('We print this label'),
            subtitle: const Text(
              'Off means the customer supplies their own — nothing is counted '
              'and no alerts are raised.',
            ),
          ),
          if (_wePrint) ...[
            const SizedBox(height: 4),
            itemGroups.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
              data: (groups) => DropdownButtonFormField<String?>(
                initialValue: _itemGroup,
                isExpanded: true,
                decoration: _fieldDecoration(
                  'Applies to item group (optional)',
                  helper: 'Leave blank when this label covers everything the '
                      'customer buys.',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Everything'),
                  ),
                  ...groups.map(
                    (group) => DropdownMenuItem<String?>(
                      value: group,
                      child: Text(group, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _itemGroup = value),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _openingController,
                    keyboardType: TextInputType.number,
                    inputFormatters: _digits,
                    decoration: _fieldDecoration('Labels in stock now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _perUnitController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _fieldDecoration('Labels per jar'),
                  ),
                ),
              ],
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
                    controller: _batchController,
                    keyboardType: TextInputType.number,
                    inputFormatters: _digits,
                    decoration: _fieldDecoration('Usual print batch'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: _fieldDecoration('Notes (optional)'),
            ),
          ],
        ],
      ],
      action: FilledButton(
        onPressed: _selected == null
            ? null
            : () => Navigator.of(context).pop(
                  NewLabelRequest(
                    customer: _selected!.customer,
                    labelTitle: _titleController.text.trim().isEmpty
                        ? 'Default'
                        : _titleController.text.trim(),
                    wePrint: _wePrint,
                    itemGroup: _itemGroup,
                    labelsPerUnit:
                        double.tryParse(_perUnitController.text.trim()) ?? 1,
                    minStockQty: _parseInt(_minStockController),
                    reorderQty: _parseInt(_batchController),
                    openingQty: _wePrint ? _parseInt(_openingController) : 0,
                    notes: _notesController.text.trim().isEmpty
                        ? null
                        : _notesController.text.trim(),
                  ),
                ),
        child: const Text('Start tracking'),
      ),
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
// Send a batch to the printer
// ---------------------------------------------------------------------------
class PrintOrderSheet extends StatefulWidget {
  final CustomerLabel label;

  const PrintOrderSheet({super.key, required this.label});

  @override
  State<PrintOrderSheet> createState() => _PrintOrderSheetState();
}

class _PrintOrderSheetState extends State<PrintOrderSheet> {
  late final TextEditingController _qtyController = TextEditingController(
    text: '${widget.label.suggestedPrintQty > 0 ? widget.label.suggestedPrintQty : widget.label.reorderQty}',
  );
  final _printerController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _qtyController.dispose();
    _printerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = widget.label;
    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;

    return _SheetScaffold(
      title: 'Order a print batch',
      subtitle: '${label.customerName} · ${label.labelTitle}',
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
          controller: _qtyController,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: _digits,
          decoration: _fieldDecoration(
            'Quantity to print',
            helper: label.suggestedPrintQty > 0
                ? 'Suggested ${label.suggestedPrintQty}, based on the usual '
                    'batch and current usage.'
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _printerController,
          decoration: _fieldDecoration('Printer / supplier (optional)'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: _fieldDecoration('Notes (optional)'),
        ),
      ],
      action: FilledButton.icon(
        onPressed: qty <= 0
            ? null
            : () => Navigator.of(context).pop(
                  PrintOrderRequest(
                    qty: qty,
                    printerName: _printerController.text.trim().isEmpty
                        ? null
                        : _printerController.text.trim(),
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
    final received = int.tryParse(_controller.text.trim()) ?? 0;
    return _SheetScaffold(
      title: 'Receive batch',
      subtitle: '${widget.order.name} · ordered ${widget.order.qty}',
      fields: [
        TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: _digits,
          decoration: _fieldDecoration(
            'Quantity received',
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
  late final TextEditingController _batchController =
      TextEditingController(text: '${widget.label.reorderQty}');
  late final TextEditingController _notesController =
      TextEditingController(text: widget.label.notes ?? '');

  late bool _wePrint = widget.label.wePrint;
  late bool _enabled = widget.label.enabled;
  late String? _itemGroup = widget.label.appliesToItemGroup;

  @override
  void dispose() {
    _titleController.dispose();
    _perUnitController.dispose();
    _minStockController.dispose();
    _batchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemGroups = ref.watch(labelItemGroupsProvider);

    return _SheetScaffold(
      title: 'Label settings',
      subtitle: widget.label.customerName,
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
        itemGroups.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => const SizedBox.shrink(),
          data: (groups) {
            final options = {...groups, if (_itemGroup != null) _itemGroup!};
            return DropdownButtonFormField<String?>(
              initialValue: _itemGroup,
              isExpanded: true,
              decoration: _fieldDecoration('Applies to item group'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Everything'),
                ),
                ...options.map(
                  (group) => DropdownMenuItem<String?>(
                    value: group,
                    child: Text(group, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _itemGroup = value),
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
                controller: _batchController,
                keyboardType: TextInputType.number,
                inputFormatters: _digits,
                decoration: _fieldDecoration('Usual print batch'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _perUnitController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _fieldDecoration(
            'Labels per jar',
            helper: 'Usually 1. Raise it when a jar carries more than one label.',
          ),
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
            // An empty string clears the scope back to catch-all server-side.
            itemGroup: _itemGroup ?? '',
            labelsPerUnit:
                double.tryParse(_perUnitController.text.trim()) ?? 1,
            minStockQty: _parseInt(_minStockController),
            reorderQty: _parseInt(_batchController),
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
