import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/roster_models.dart';
import '../roster_formats.dart';

/// The list of shift types to roster onto, shared by the single-day sheet and
/// the bulk bar.
///
/// There used to be two copies (`_ShiftPicker` in the day sheet and
/// `_BulkShiftPicker` in the bulk bar) that had already drifted apart.
///
/// Each shift is its name and its time window — no colour swatch. Colour on
/// the roster means "needs fixing" and nothing else, so it never says which
/// shift a day is; the grid writes the time, and so does the picker.
class RosterShiftPicker extends StatelessWidget {
  const RosterShiftPicker({
    super.key,
    required this.catalog,
    required this.onPick,
    this.selected,
    this.maxHeight = 260,
  });

  final List<RosterShift> catalog;
  final ValueChanged<RosterShift> onPick;

  /// The shift the day is already on, if any. It is marked and not tappable:
  /// re-assigning the same shift would be a write that changes nothing.
  final String? selected;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    if (catalog.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(context.l10n.rosterNoShiftTypes),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: catalog.length,
        itemBuilder: (context, index) {
          final shift = catalog[index];
          final isSelected = shift.shiftType == selected;
          return ListTile(
            dense: true,
            selected: isSelected,
            title: Text(shift.shiftType),
            subtitle: Text(
              context.l10n.rosterShiftWindow(
                shift.window,
                rosterNumber(context, shift.hours),
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, size: 20)
                : null,
            onTap: isSelected ? null : () => onPick(shift),
          );
        },
      ),
    );
  }
}

/// [RosterShiftPicker] in its own bottom sheet, resolving to the pick (or
/// null when dismissed). Used by the bulk bar.
Future<RosterShift?> showRosterShiftPickerSheet(
  BuildContext context, {
  required String title,
  required List<RosterShift> catalog,
}) {
  return showModalBottomSheet<RosterShift>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                sheetContext,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            RosterShiftPicker(
              catalog: catalog,
              maxHeight: 320,
              onPick: (shift) => Navigator.of(sheetContext).pop(shift),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}
