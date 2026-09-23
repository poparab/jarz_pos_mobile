import 'dart:async';

import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/manufacturing_service.dart';

/// Manufacturing history: submitted Work Orders, for confirming a batch landed
/// and on which day it counted in stock.
///
/// Every row shows two dates. `creation` is when the order was entered in the
/// app; `posted_at` is the posting date+time of its Manufacture entry, the day
/// every stock report counts the batch on. They differ for a backdated batch.
Future<void> showRecentWorkOrders(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _RecentWorkOrdersDialog(),
  );
}

enum _DatePreset { any, today, yesterday, last7, last30, custom }

const _statuses = [
  'Not Started',
  'In Process',
  'Completed',
  'Stopped',
  'Cancelled',
];

const _historyLimit = 300;

class _RecentWorkOrdersDialog extends ConsumerStatefulWidget {
  const _RecentWorkOrdersDialog();

  @override
  ConsumerState<_RecentWorkOrdersDialog> createState() =>
      _RecentWorkOrdersDialogState();
}

class _RecentWorkOrdersDialogState
    extends ConsumerState<_RecentWorkOrdersDialog> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  String _dateBasis = 'posting';
  String? _status;
  _DatePreset _preset = _DatePreset.any;
  DateTimeRange? _customRange;

  List<Map<String, dynamic>> _rows = const [];
  bool _loading = true;
  Object? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  DateTimeRange? get _range {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_preset) {
      case _DatePreset.any:
        return null;
      case _DatePreset.today:
        return DateTimeRange(start: today, end: today);
      case _DatePreset.yesterday:
        final y = today.subtract(const Duration(days: 1));
        return DateTimeRange(start: y, end: y);
      case _DatePreset.last7:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        );
      case _DatePreset.last30:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
        );
      case _DatePreset.custom:
        return _customRange;
    }
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    final range = _range;
    try {
      final rows = await ref
          .read(manufacturingServiceProvider)
          .listRecentWorkOrders(
            limit: _historyLimit,
            search: _searchController.text,
            status: _status,
            fromDate: range?.start,
            toDate: range?.end,
            dateBasis: _dateBasis,
          );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
  }

  Future<void> _selectPreset(_DatePreset preset) async {
    if (preset == _DatePreset.custom) {
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 3),
        lastDate: DateTime(now.year, now.month, now.day),
        initialDateRange: _customRange ?? _range,
      );
      if (picked == null || !mounted) return;
      _customRange = picked;
    }
    setState(() => _preset = preset);
    _load();
  }

  String _presetLabel(_DatePreset preset) {
    final l10n = context.l10n;
    switch (preset) {
      case _DatePreset.any:
        return l10n.manufacturingHistoryAnyDate;
      case _DatePreset.today:
        return l10n.manufacturingHistoryToday;
      case _DatePreset.yesterday:
        return l10n.manufacturingHistoryYesterday;
      case _DatePreset.last7:
        return l10n.manufacturingHistoryLast7;
      case _DatePreset.last30:
        return l10n.manufacturingHistoryLast30;
      case _DatePreset.custom:
        final range = _customRange;
        if (range == null) return l10n.manufacturingHistoryCustomRange;
        return '${formatDate(context, range.start, pattern: 'd MMM')} – '
            '${formatDate(context, range.end, pattern: 'd MMM')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPhone = ResponsiveUtils.isPhone(context);
    final width = ResponsiveUtils.getDialogWidth(
      context,
      small: 640,
      medium: 820,
      large: 960,
    );
    final height = ResponsiveUtils.getDialogHeight(
      context,
      phoneFraction: 0.92,
      tabletFraction: 0.88,
      max: 900,
    );

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isPhone ? 8 : 24,
        vertical: isPhone ? 12 : 24,
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            _buildFilters(context),
            const Divider(height: 1),
            _buildSummary(context),
            Expanded(child: _buildBody(context)),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  child: Text(l10n.commonClose),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
      child: Row(
        children: [
          const Icon(Icons.history),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.manufacturingRecentWorkOrdersTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Tooltip(
            message: l10n.manufacturingHistoryDateHelp,
            triggerMode: TooltipTriggerMode.tap,
            showDuration: const Duration(seconds: 6),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.info_outline),
            ),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(
              context,
            ).refreshIndicatorSemanticLabel,
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.manufacturingHistorySearchHint,
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.commonClear,
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _load();
                            },
                          ),
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String?>(
                  initialValue: _status,
                  isDense: true,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.manufacturingHistoryAllStatuses),
                    ),
                    for (final status in _statuses)
                      DropdownMenuItem<String?>(
                        value: status,
                        child: Text(_statusLabel(context, status)),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() => _status = value);
                    _load();
                  },
                ),
              ),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: 'posting',
                    icon: const Icon(Icons.inventory_2_outlined, size: 18),
                    label: Text(l10n.manufacturingHistoryBasisPosted),
                  ),
                  ButtonSegment(
                    value: 'creation',
                    icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                    label: Text(l10n.manufacturingHistoryBasisCreated),
                  ),
                ],
                selected: {_dateBasis},
                onSelectionChanged: (selection) {
                  setState(() => _dateBasis = selection.first);
                  _load();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final preset in _DatePreset.values)
                ChoiceChip(
                  label: Text(_presetLabel(preset)),
                  avatar: preset == _DatePreset.custom
                      ? const Icon(Icons.date_range, size: 18)
                      : null,
                  selected: _preset == preset,
                  onSelected: (_) => _selectPreset(preset),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    if (_loading || _error != null || _rows.isEmpty) {
      return const SizedBox.shrink();
    }
    final totalQty = _rows.fold<double>(
      0,
      (sum, row) => sum + ((row['qty'] as num?)?.toDouble() ?? 0),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(
        context.l10n.manufacturingHistorySummary(
          _rows.length,
          formatCount(context, totalQty),
        ),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.userErrorMessage(_error!, fallback: l10n.commonError),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(onPressed: _load, child: Text(l10n.commonRetry)),
          ],
        ),
      );
    }
    if (_rows.isEmpty) {
      return Center(child: Text(l10n.manufacturingNoWorkOrders));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) =>
          _WorkOrderHistoryTile(row: _rows[index]),
    );
  }
}

String _statusLabel(BuildContext context, String status) {
  final l10n = context.l10n;
  switch (status) {
    case 'Not Started':
      return l10n.manufacturingWoStatusNotStarted;
    case 'In Process':
      return l10n.manufacturingWoStatusInProcess;
    case 'Completed':
      return l10n.manufacturingWoStatusCompleted;
    case 'Stopped':
      return l10n.manufacturingWoStatusStopped;
    case 'Cancelled':
      return l10n.manufacturingWoStatusCancelled;
    default:
      return status;
  }
}

/// Frappe sends site-local naive timestamps; parse them as-is.
DateTime? _parseServerDate(Object? raw) {
  final value = raw?.toString().trim() ?? '';
  if (value.isEmpty) return null;
  return DateTime.tryParse(value);
}

class _WorkOrderHistoryTile extends StatelessWidget {
  const _WorkOrderHistoryTile({required this.row});

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final itemCode = '${row['production_item'] ?? ''}';
    final itemName = '${row['item_name'] ?? ''}'.trim();
    final status = '${row['status'] ?? ''}';
    final qty = (row['qty'] as num?)?.toDouble() ?? 0;
    final created = _parseServerDate(row['creation']);
    final posted = _parseServerDate(row['posted_at']);
    final backdated =
        created != null &&
        posted != null &&
        DateUtils.dateOnly(posted).isBefore(DateUtils.dateOnly(created));

    final statusColor = switch (status) {
      'Completed' => Colors.green,
      'Cancelled' || 'Stopped' => scheme.error,
      _ => Colors.orange,
    };

    String fmt(DateTime d) =>
        formatDateTime(context, d, pattern: 'EEE d MMM yyyy • h:mm a');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  itemName.isNotEmpty && itemName != itemCode
                      ? '$itemName ($itemCode)'
                      : itemCode,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Text(
                l10n.manufacturingHistoryQty(formatCount(context, qty)),
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('${row['name'] ?? ''}', style: theme.textTheme.bodySmall),
              _Tag(label: _statusLabel(context, status), color: statusColor),
              if (backdated)
                _Tag(
                  label: l10n.manufacturingHistoryBackdated,
                  color: scheme.tertiary,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 20,
            runSpacing: 4,
            children: [
              _DateLine(
                icon: Icons.inventory_2_outlined,
                text: posted != null
                    ? l10n.manufacturingHistoryPostedAt(fmt(posted))
                    : l10n.manufacturingHistoryNotPosted,
                emphasized: posted != null,
              ),
              if (created != null)
                _DateLine(
                  icon: Icons.edit_calendar_outlined,
                  text: l10n.manufacturingHistoryCreatedAt(fmt(created)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateLine extends StatelessWidget {
  const _DateLine({
    required this.icon,
    required this.text,
    this.emphasized = false,
  });

  final IconData icon;
  final String text;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = emphasized
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: emphasized ? FontWeight.w600 : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
