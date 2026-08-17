import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/labels_repository.dart';
import '../../models/label_models.dart';
import '../widgets/label_sheets.dart';
import '../widgets/label_status_chip.dart';

/// One customer's label: where it stands, what is at the printer, and the full
/// ledger of how it got there.
class LabelDetailScreen extends ConsumerStatefulWidget {
  final String labelName;

  const LabelDetailScreen({super.key, required this.labelName});

  @override
  ConsumerState<LabelDetailScreen> createState() => _LabelDetailScreenState();
}

class _LabelDetailScreenState extends ConsumerState<LabelDetailScreen> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  final _dateFormat = DateFormat('d MMM yyyy');
  final _shortDate = DateFormat('d MMM');

  CustomerLabel? _label;
  String? _error;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final label =
          await ref.read(labelsRepositoryProvider).getDetail(widget.labelName);
      if (mounted) setState(() => _label = label);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Runs a write, swaps in the label the server returns, and reports failure
  /// once — so no action handler has to repeat this.
  Future<void> _act(
    Future<CustomerLabel> Function() action, {
    String? success,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final label = await action();
      if (!mounted) return;
      setState(() => _label = label);
      if (success != null) {
        _messengerKey.currentState
            ?.showSnackBar(SnackBar(content: Text(success)));
      }
    } catch (error) {
      if (!mounted) return;
      _messengerKey.currentState
          ?.showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _label;

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(label?.customerName ?? 'Label'),
          actions: [
            if (label != null)
              IconButton(
                tooltip: 'Label settings',
                icon: const Icon(Icons.tune),
                onPressed: _busy ? null : () => _editPolicy(label),
              ),
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: _loading ? null : _load,
            ),
          ],
        ),
        body: _buildBody(label),
      ),
    );
  }

  Widget _buildBody(CustomerLabel? label) {
    if (_loading && label == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (label == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Could not load this label.\n${_error ?? ''}',
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _Header(label: label, shortDate: _shortDate),
          if (_busy) const LinearProgressIndicator(),
          _Actions(
            label: label,
            busy: _busy,
            onOrder: () => _orderBatch(label),
            onCount: () => _count(label),
            onMovement: () => _recordMovement(label),
          ),
          if (label.printOrders.isNotEmpty)
            _PrintOrders(
              orders: label.printOrders,
              dateFormat: _shortDate,
              busy: _busy,
              onReceive: (order) => _receive(label, order),
              onAdvance: (order, status) => _advance(label, order, status),
            ),
          _Policy(label: label, dateFormat: _dateFormat),
          _Ledger(movements: label.movements, dateFormat: _shortDate),
        ],
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────
  Future<void> _orderBatch(CustomerLabel label) async {
    final request = await showModalBottomSheet<PrintOrderRequest>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PrintOrderSheet(label: label),
    );
    if (request == null || !mounted) return;
    await _act(
      () => ref.read(labelsRepositoryProvider).createPrintOrder(
            label: label.name,
            qty: request.qty,
            printerName: request.printerName,
            notes: request.notes,
          ),
      success: '${request.qty} labels sent to the printer',
    );
  }

  Future<void> _count(CustomerLabel label) async {
    final request = await showModalBottomSheet<CountRequest>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CountSheet(label: label),
    );
    if (request == null || !mounted) return;
    await _act(
      () => ref.read(labelsRepositoryProvider).recordCount(
            label: label.name,
            countedQty: request.countedQty,
            remarks: request.remarks,
          ),
      success: 'Count saved',
    );
  }

  Future<void> _recordMovement(CustomerLabel label) async {
    final request = await showModalBottomSheet<MovementRequest>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MovementSheet(label: label),
    );
    if (request == null || !mounted) return;
    await _act(
      () => ref.read(labelsRepositoryProvider).recordMovement(
            label: label.name,
            movementType: request.movementType,
            qty: request.qty,
            remarks: request.remarks,
          ),
      success: 'Movement recorded',
    );
  }

  Future<void> _receive(CustomerLabel label, LabelPrintOrder order) async {
    final received = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReceiveBatchSheet(order: order),
    );
    if (received == null || !mounted) return;
    await _act(
      () => ref.read(labelsRepositoryProvider).updatePrintOrder(
            printOrder: order.name,
            status: 'Received',
            receivedQty: received,
          ),
      success: '$received labels added to stock',
    );
  }

  Future<void> _advance(
    CustomerLabel label,
    LabelPrintOrder order,
    String status,
  ) async {
    await _act(
      () => ref.read(labelsRepositoryProvider).updatePrintOrder(
            printOrder: order.name,
            status: status,
          ),
      success: 'Batch marked $status',
    );
  }

  Future<void> _editPolicy(CustomerLabel label) async {
    final request = await showModalBottomSheet<LabelPolicyRequest>(
      context: context,
      isScrollControlled: true,
      builder: (_) => LabelPolicySheet(label: label),
    );
    if (request == null || !mounted) return;
    await _act(
      () => ref.read(labelsRepositoryProvider).updateLabel(
            label: label.name,
            labelTitle: request.labelTitle,
            enabled: request.enabled,
            wePrint: request.wePrint,
            appliesToItemGroup: request.itemGroup,
            labelsPerUnit: request.labelsPerUnit,
            minStockQty: request.minStockQty,
            reorderQty: request.reorderQty,
            notes: request.notes,
          ),
      success: 'Settings saved',
    );
  }
}

// ---------------------------------------------------------------------------
// Sections
// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  final CustomerLabel label;
  final DateFormat shortDate;

  const _Header({required this.label, required this.shortDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style =
        LabelStatusStyle.of(label.status, leadDaysMax: label.leadDaysMax);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      color: style.color.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.labelTitle,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              LabelStatusChip(
                status: label.status,
                leadDaysMax: label.leadDaysMax,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label.tracked ? '${label.onHandQty}' : '—',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: style.color,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text('labels on hand',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(style.explanation, style: theme.textTheme.bodySmall),
          if (label.tracked) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 22,
              runSpacing: 10,
              children: [
                _Stat(
                  label: 'Days of cover',
                  value: label.daysOfCover == null
                      ? 'unknown'
                      : label.daysOfCover!.toStringAsFixed(1),
                ),
                _Stat(
                  label: 'Used per day',
                  value: label.avgDailyUsage > 0
                      ? label.avgDailyUsage.toStringAsFixed(2)
                      : '—',
                ),
                _Stat(
                  label: 'Runs out',
                  value: label.runsOutOn == null
                      ? '—'
                      : shortDate.format(label.runsOutOn!),
                ),
                _Stat(
                  label: 'Used in ${label.usageWindowDays}d',
                  value: '${label.consumedInWindow}',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final CustomerLabel label;
  final bool busy;
  final VoidCallback onOrder;
  final VoidCallback onCount;
  final VoidCallback onMovement;

  const _Actions({
    required this.label,
    required this.busy,
    required this.onOrder,
    required this.onCount,
    required this.onMovement,
  });

  @override
  Widget build(BuildContext context) {
    if (!label.tracked) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          label.wePrint
              ? 'This label is retired. Turn it back on in label settings to '
                  'resume counting.'
              : 'This customer supplies their own labels, so nothing is counted '
                  'and no alerts are raised. Turn on "We print this label" in '
                  'settings if that changes.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: busy ? null : onOrder,
              icon: const Icon(Icons.local_printshop, size: 18),
              label: const Text('Order'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: busy ? null : onCount,
              icon: const Icon(Icons.checklist, size: 18),
              label: const Text('Count'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: busy ? null : onMovement,
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text('Record'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrintOrders extends StatelessWidget {
  final List<LabelPrintOrder> orders;
  final DateFormat dateFormat;
  final bool busy;
  final void Function(LabelPrintOrder) onReceive;
  final void Function(LabelPrintOrder, String) onAdvance;

  const _PrintOrders({
    required this.orders,
    required this.dateFormat,
    required this.busy,
    required this.onReceive,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Print batches'),
        ...orders.map((order) {
          final due = order.expectedReadyDate;
          final subtitleBits = <String>[
            if (order.requestedOn != null)
              'ordered ${dateFormat.format(order.requestedOn!)}',
            if (order.isOpen && due != null)
              order.isOverdue
                  ? 'overdue since ${dateFormat.format(due)}'
                  : 'due ${dateFormat.format(due)}',
            if (order.isReceived && order.receivedOn != null)
              'received ${dateFormat.format(order.receivedOn!)}'
                  '${order.receivedQty != order.qty ? ' (${order.receivedQty})' : ''}',
            if (order.printerName != null) order.printerName!,
          ];

          return ListTile(
            leading: Icon(
              order.isReceived
                  ? Icons.inventory_2
                  : order.status == 'Cancelled'
                      ? Icons.cancel
                      : Icons.local_shipping,
              color: order.isOverdue ? const Color(0xFFE65100) : null,
            ),
            title: Text('${order.qty} labels · ${order.status}'),
            subtitle: Text(
              subtitleBits.join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: order.isOverdue ? const Color(0xFFE65100) : null,
              ),
            ),
            trailing: !order.isOpen
                ? null
                : PopupMenuButton<String>(
                    enabled: !busy,
                    onSelected: (value) {
                      if (value == 'receive') {
                        onReceive(order);
                      } else {
                        onAdvance(order, value);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'receive',
                        child: Text('Receive into stock'),
                      ),
                      if (order.status == 'Requested')
                        const PopupMenuItem(
                            value: 'Printing', child: Text('Mark printing')),
                      if (order.status != 'Ready')
                        const PopupMenuItem(
                            value: 'Ready', child: Text('Mark ready')),
                      const PopupMenuItem(
                          value: 'Cancelled', child: Text('Cancel batch')),
                    ],
                  ),
          );
        }),
      ],
    );
  }
}

class _Policy extends StatelessWidget {
  final CustomerLabel label;
  final DateFormat dateFormat;

  const _Policy({required this.label, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <(String, String)>[
      ('Minimum stock', '${label.minStockQty}'),
      ('Usual print batch', '${label.reorderQty}'),
      ('Labels per jar', label.labelsPerUnit.toStringAsFixed(
          label.labelsPerUnit == label.labelsPerUnit.roundToDouble() ? 0 : 2)),
      ('Applies to', label.appliesToItemGroup ?? 'Everything'),
      (
        'Print lead time',
        '${label.leadDaysMin}–${label.leadDaysMax} working days '
            '(${label.restDay} excluded)'
      ),
      if (label.lastCountedOn != null)
        ('Last counted', dateFormat.format(label.lastCountedOn!)),
      if (label.lastMovementOn != null)
        ('Last movement', dateFormat.format(label.lastMovementOn!)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Setup'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: rows
                .map(
                  (row) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(
                            row.$1,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(row.$2,
                              style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        if (label.notes != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(label.notes!, style: theme.textTheme.bodySmall),
          ),
      ],
    );
  }
}

class _Ledger extends StatelessWidget {
  final List<LabelMovement> movements;
  final DateFormat dateFormat;

  const _Ledger({required this.movements, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (movements.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('History'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Nothing recorded yet. Labels come off automatically as this '
              'customer\'s orders are invoiced.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('History'),
        ...movements.map((movement) {
          final positive = movement.isIncoming;
          return ListTile(
            dense: true,
            leading: Icon(
              positive ? Icons.add_circle_outline : Icons.remove_circle_outline,
              color: positive
                  ? const Color(0xFF2E7D32)
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            title: Text(
              '${positive ? '+' : ''}${movement.qty}   ${movement.movementType}',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              [
                if (movement.postingDate != null)
                  dateFormat.format(movement.postingDate!),
                if (movement.referenceName != null) movement.referenceName!,
                if (movement.remarks != null) movement.remarks!,
              ].join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
            trailing: movement.isAutomatic
                ? Tooltip(
                    message: 'Posted automatically from the invoice',
                    child: Icon(Icons.bolt,
                        size: 16, color: theme.colorScheme.outline),
                  )
                : null,
          );
        }),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
