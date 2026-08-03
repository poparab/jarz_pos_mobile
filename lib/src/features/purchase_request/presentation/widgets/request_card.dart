import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/purchase_request_models.dart';
import 'request_status_chip.dart';

/// One request in the queue. Collapsed it answers "who wants what, by when";
/// expanded it shows each line's fulfilment progress.
class RequestCard extends StatefulWidget {
  final ItemRequest request;
  final bool canReview;
  final VoidCallback? onReject;
  final VoidCallback? onReopen;

  const RequestCard({
    super.key,
    required this.request,
    required this.canReview,
    this.onReject,
    this.onReopen,
  });

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  bool _expanded = false;

  String _fmtDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('MMM d').format(date);
  }

  String _fmtQty(double value) {
    // Whole numbers read better without a trailing .00 on a busy list.
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final request = widget.request;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          request.items.isEmpty
                              ? request.name
                              : request.items.first.itemName,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      RequestStatusChip(
                        status: request.status,
                        isOverdue: request.isOverdue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 14, color: theme.colorScheme.outline),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          l10n.requestsRequestedBy(request.requestedBy),
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (request.posProfile != null) ...[
                        Icon(Icons.store_outlined,
                            size: 14, color: theme.colorScheme.outline),
                        const SizedBox(width: 4),
                        Text(
                          request.posProfile!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        l10n.requestsItemCount(request.itemCount),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.event_outlined,
                          size: 14, color: theme.colorScheme.outline),
                      const SizedBox(width: 4),
                      Text(
                        _fmtDate(request.scheduleDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: request.isOverdue
                              ? theme.colorScheme.error
                              : null,
                          fontWeight:
                              request.isOverdue ? FontWeight.w600 : null,
                        ),
                      ),
                      const Spacer(),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.keyboard_arrow_down,
                            size: 20, color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                  if (request.status == RequestStatus.partiallyReceived) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (request.perReceived / 100).clamp(0.0, 1.0),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in request.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            line.isFulfilled
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 15,
                            color: line.isFulfilled
                                ? Colors.green.shade600
                                : theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              line.itemName,
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            l10n.requestsLineProgress(
                              _fmtQty(line.receivedQty),
                              _fmtQty(line.stockQty),
                              line.stockUom,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (request.note != null && request.note!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        request.note!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                  if (widget.canReview) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (request.status.isRejected &&
                            widget.onReopen != null)
                          TextButton.icon(
                            onPressed: widget.onReopen,
                            icon: const Icon(Icons.undo, size: 16),
                            label: Text(l10n.requestsReopen),
                          )
                        else if (request.status.isOpen &&
                            widget.onReject != null)
                          TextButton.icon(
                            onPressed: widget.onReject,
                            icon: const Icon(Icons.block, size: 16),
                            label: Text(l10n.requestsReject),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
