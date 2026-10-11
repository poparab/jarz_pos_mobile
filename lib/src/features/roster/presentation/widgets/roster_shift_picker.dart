import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/roster_models.dart';
import '../roster_cell_style.dart';
import '../roster_formats.dart';
import '../roster_shift_palette.dart';

/// The list of shift types to roster onto, shared by the single-day sheet and
/// the bulk bar.
///
/// There used to be two copies (`_ShiftPicker` in the day sheet and
/// `_BulkShiftPicker` in the bulk bar) that had already drifted apart: the
/// bulk one built its own palette from the catalog, so a retired shift type
/// still on the grid could be a different colour in the picker than in the
/// cell. Both now take the grid's [palette].
class RosterShiftPicker extends StatelessWidget {
  const RosterShiftPicker({
    super.key,
    required this.catalog,
    required this.palette,
    required this.onPick,
    this.selected,
    this.maxHeight = 260,
  });

  final List<RosterShift> catalog;
  final RosterShiftPalette palette;
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
          final style = palette.styleFor(shift.shiftType);
          return ListTile(
            dense: true,
            selected: isSelected,
            // The colour and code the grid and the day sheet will show once
            // this is picked, so the choice is made in the same vocabulary it
            // is read in.
            leading: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: style.color,
                borderRadius: BorderRadius.circular(6),
                border: isSelected
                    ? Border.all(
                        color: RosterStyleResolver.selectionColor,
                        width: 2,
                      )
                    : null,
              ),
              child: Text(
                style.code,
                style: TextStyle(
                  color: style.onColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
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
  required RosterShiftPalette palette,
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
              palette: palette,
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
