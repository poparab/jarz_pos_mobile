import 'package:flutter/material.dart';
import '../models/kanban_models.dart';
import 'invoice_card_widget.dart';

class KanbanColumnWidget extends StatefulWidget { // changed to Stateful for hover/drag animation
  final KanbanColumn column;
  final List<InvoiceCard> invoices;
  final Future<void> Function(String invoiceId, String fromColumnId, String newColumnId) onCardMoved;
  final bool Function(String invoiceId, String fromColumnId, String newColumnId)? canAcceptMove;
  final ValueChanged<bool>? onCardPointerActive; // new

  const KanbanColumnWidget({
    super.key,
    required this.column,
    required this.invoices,
    required this.onCardMoved,
    this.canAcceptMove,
    this.onCardPointerActive,
  });

  @override
  State<KanbanColumnWidget> createState() => _KanbanColumnWidgetState();
}

class _KanbanColumnWidgetState extends State<KanbanColumnWidget> {
  bool _isDragOver = false;
  String? _draggingId;
  late final ScrollController _columnScrollController;

  @override
  void initState() {
    super.initState();
    _columnScrollController = ScrollController();
  }

  @override
  void dispose() {
    _columnScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _hexToColor(widget.column.color);
  final headerColor = baseColor.withValues(alpha: 0.85);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutQuart,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [baseColor.withValues(alpha: 0.55), baseColor.withValues(alpha: 0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isDragOver ? Colors.blueAccent : Colors.grey[300]!,
          width: _isDragOver ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              boxShadow: _isDragOver
                  ? [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.25),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.column.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  scale: _isDragOver ? 1.15 : 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      widget.invoices.length.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isDragOver ? Colors.blueAccent : Colors.black87,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),

          // Cards & drop zone
          Expanded(
            child: DragTarget<Map<String, dynamic>>(
              onWillAcceptWithDetails: (details) {
                final payload = details.data;
                final invoiceId = payload['invoiceId']?.toString() ?? '';
                final fromColumnId = payload['fromColumnId']?.toString() ?? '';
                final canAccept = widget.canAcceptMove?.call(
                      invoiceId,
                      fromColumnId,
                      widget.column.id,
                    ) ??
                    true;
                if (!canAccept) {
                  setState(() {
                    _isDragOver = false;
                  });
                  return false;
                }
                setState(() {
                  _isDragOver = true;
                });
                return true;
              },
              onLeave: (_) => setState(() { _isDragOver = false; }),
              onAcceptWithDetails: (data) async {
                setState(() { _isDragOver = false; _draggingId = null; });
                final invoiceId = data.data['invoiceId'] as String;
                final fromColumnId = data.data['fromColumnId'] as String;
                if (fromColumnId != widget.column.id) {
                  await widget.onCardMoved(invoiceId, fromColumnId, widget.column.id);
                }
              },
              builder: (context, candidateData, rejectedData) {
                final highlight = _isDragOver || candidateData.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 14),
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: highlight
                        ? Border.all(color: Colors.blueAccent, width: 2, strokeAlign: BorderSide.strokeAlignOutside)
                        : null,
          gradient: highlight
            ? LinearGradient(
              colors: [Colors.blue.withValues(alpha: 0.08), Colors.blue.withValues(alpha: 0.02)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                  ),
                  child: _buildList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (widget.invoices.isEmpty) return _buildEmptyState();
    return Scrollbar(
      controller: _columnScrollController,
      thumbVisibility: true,
      radius: const Radius.circular(10),
      thickness: 6,
      child: ListView.builder(
        controller: _columnScrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(right: 4, left: 4, top: 4, bottom: 2),
        itemCount: widget.invoices.length,
        itemBuilder: (context, index) {
        final invoice = widget.invoices[index];
        final isDraggingThis = _draggingId == invoice.id;
        return Listener(
          onPointerDown: (_) => widget.onCardPointerActive?.call(true),
          onPointerUp: (_) => widget.onCardPointerActive?.call(false),
          onPointerCancel: (_) => widget.onCardPointerActive?.call(false),
          child: LongPressDraggable<Map<String, dynamic>>(
            data: {
              'invoiceId': invoice.id,
              'fromColumnId': widget.column.id,
            },
            dragAnchorStrategy: pointerDragAnchorStrategy,
            maxSimultaneousDrags: 1,
            onDragStarted: () => setState(() => _draggingId = invoice.id),
            onDraggableCanceled: (velocity, offset) {
              setState(() => _draggingId = null);
              widget.onCardPointerActive?.call(false);
            },
            onDragEnd: (_) {
              setState(() => _draggingId = null);
              widget.onCardPointerActive?.call(false);
            },
            feedback: Material(
              color: Colors.transparent,
              child: Transform.scale(
                scale: 1.03,
                child: Opacity(
                  opacity: 0.95,
                  child: SizedBox(
                    width: 300,
                    child: InvoiceCardWidget(
                      invoice: invoice,
                      isDragging: true,
                      compact: true,
                    ),
                  ),
                ),
              ),
            ),
            childWhenDragging: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: 0.25,
              child: InvoiceCardWidget(invoice: invoice, isDragging: false, compact: false),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => widget.onCardPointerActive?.call(true),
              onTapUp: (_) => widget.onCardPointerActive?.call(false),
              onTapCancel: () => widget.onCardPointerActive?.call(false),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 160),
                scale: isDraggingThis ? 0.92 : 1,
                child: InvoiceCardWidget(
                  invoice: invoice,
                  isDragging: false,
                  compact: false,
                ),
              ),
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _isDragOver ? 0.2 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 46, color: Colors.grey[400]),
              const SizedBox(height: 10),
              Text(
                'No invoices',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                'Long press & drag here',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
