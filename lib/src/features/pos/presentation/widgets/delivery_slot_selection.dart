import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../domain/models/delivery_slot.dart';
import '../../data/repositories/pos_repository.dart';
import '../../state/pos_notifier.dart';

class DeliverySlotSelection extends ConsumerStatefulWidget {
  final String posProfile;
  final DeliverySlot? selectedSlot;
  final Function(DeliverySlot?) onSlotChanged;
  final bool isRequired;

  const DeliverySlotSelection({
    super.key,
    required this.posProfile,
    this.selectedSlot,
    required this.onSlotChanged,
    this.isRequired = false,
  });

  @override
  ConsumerState<DeliverySlotSelection> createState() =>
      _DeliverySlotSelectionState();
}

class _DeliverySlotSelectionState extends ConsumerState<DeliverySlotSelection> {
  List<DeliverySlot> _slots = [];
  bool _isLoading = false;
  String? _error;
  DeliverySlot? _selectedSlot;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint(
        '🚀 DeliverySlotSelection widget initialized for profile: ${widget.posProfile}',
      );
    }
    _selectedSlot = widget.selectedSlot;
    // Attempt to use cached slots from POS state first to avoid visible loading delay
    final cached = ref.read(posNotifierProvider.select((s) => s.deliverySlots));
    if (cached.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('⚡ Using ${cached.length} cached delivery slots');
      }
      _slots = cached;
      // Auto-select default if needed
      if (_selectedSlot == null) {
        final defaultSlot = cached.firstWhere(
          (slot) => slot.isDefault,
          orElse: () => cached.first,
        );
        _selectedSlot = defaultSlot;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onSlotChanged(_selectedSlot);
        });
      }
    } else {
      _loadDeliverySlots();
    }
  }

  @override
  void didUpdateWidget(DeliverySlotSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.posProfile != widget.posProfile) {
      final cached = ref.read(posNotifierProvider.select((s) => s.deliverySlots));
      if (cached.isNotEmpty) {
        _slots = cached;
        setState(() {});
      } else {
        _loadDeliverySlots();
      }
    }
    if (oldWidget.selectedSlot != widget.selectedSlot) {
      _selectedSlot = widget.selectedSlot;
    }
  }

  Future<void> _loadDeliverySlots() async {
    if (kDebugMode) {
      debugPrint('🕐 Loading delivery slots for profile: ${widget.posProfile}');
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(posRepositoryProvider);
      if (kDebugMode) {
        debugPrint('🌐 Making API call to get delivery slots...');
      }
      final slots = await repository.getDeliverySlots(widget.posProfile);
      if (kDebugMode) {
        debugPrint('✅ Received ${slots.length} delivery slots from API');
      }

      setState(() {
        _slots = slots;
        _isLoading = false;

        // Auto-select the default slot if none is selected
        if (_selectedSlot == null && slots.isNotEmpty) {
          final defaultSlot = slots.firstWhere(
            (slot) => slot.isDefault,
            orElse: () => slots.first,
          );
          _selectedSlot = defaultSlot;
          widget.onSlotChanged(_selectedSlot);
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showSlotSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.posDeliveryDialogTitle),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _buildSlotList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.commonCancel),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotList() {
    final l10n = context.l10n;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              l10n.posDeliveryLoadFailed,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDeliverySlots,
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      );
    }

    if (_slots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.posDeliveryEmptyTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.posDeliveryEmptyBody,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Group slots by day
    Map<String, List<DeliverySlot>> slotsByDay = {};
    for (final slot in _slots) {
      slotsByDay.putIfAbsent(slot.dayLabel, () => []).add(slot);
    }

    return ListView.builder(
      itemCount: slotsByDay.keys.length,
      itemBuilder: (context, index) {
        final dayLabel = slotsByDay.keys.elementAt(index);
        final daySlots = slotsByDay[dayLabel]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                dayLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            ...daySlots.map((slot) => _buildSlotTile(slot)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildSlotTile(DeliverySlot slot) {
    final l10n = context.l10n;
    final isSelected = _selectedSlot?.datetime == slot.datetime;

    return ListTile(
      title: Text(
        slot.timeLabel,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
          : slot.isDefault
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.posDeliveryDefaultChip,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[700],
                ),
              ),
            )
          : null,
      onTap: () {
        setState(() {
          _selectedSlot = slot;
        });
        widget.onSlotChanged(slot);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(l10n.posDeliveryLoading),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _slots.isNotEmpty ? _showSlotSelectionDialog : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.isRequired && _selectedSlot == null
                ? Colors.red[300]!
                : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _slots.isEmpty ? Colors.grey[50] : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.schedule,
              color: _slots.isEmpty
                  ? Colors.grey[400]
                  : Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.posDeliveryFieldLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedSlot?.label ??
                        (_error != null
                            ? l10n.posDeliveryErrorLabel
                            : _slots.isEmpty
                            ? l10n.posDeliveryNoSlotsLabel
                            : l10n.posDeliverySelectPrompt),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _selectedSlot != null
                          ? Colors.black87
                          : Colors.grey[500],
                    ),
                  ),
                  if (widget.isRequired && _selectedSlot == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l10n.posDeliverySelectSlot,
                        style: TextStyle(fontSize: 12, color: Colors.red[600]),
                      ),
                    ),
                ],
              ),
            ),
            if (_slots.isNotEmpty)
              Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
