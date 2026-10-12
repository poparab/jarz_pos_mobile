import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/roster_repository.dart';
import '../../models/roster_models.dart';
import '../../state/roster_providers.dart';
import 'roster_day_off_form.dart';
import 'roster_shift_picker.dart';

/// Action bar shown while a run of days is selected on one employee's row.
///
/// Everything here sends exactly ONE `bulk_assign` request for the whole
/// selection — that is the entire point of the feature: building or clearing a
/// stretch of days used to cost one round trip per day.
class RosterBulkBar extends ConsumerStatefulWidget {
  const RosterBulkBar({super.key, required this.selection});

  final RosterSelection selection;

  @override
  ConsumerState<RosterBulkBar> createState() => _RosterBulkBarState();
}

class _RosterBulkBarState extends ConsumerState<RosterBulkBar> {
  bool _busy = false;

  /// Drops the selection AND leaves select mode: Cancel is the way out of
  /// selecting, and a finished bulk change is done with it too.
  void _clearSelection() {
    ref.read(rosterSelectionProvider.notifier).state = null;
    ref.read(rosterSelectModeProvider.notifier).state = false;
  }

  /// Runs [changes] as one bulk request, refreshes the grid, and — this is the
  /// part a naive "it didn't throw" success message would miss — surfaces
  /// every row that failed rather than only the rows that worked.
  Future<void> _submit(List<Map<String, dynamic>> changes) async {
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(rosterRepositoryProvider)
          .bulkAssign(changes);
      ref.invalidate(rosterMonthDataProvider);
      ref.invalidate(rosterHoursProvider);
      if (!mounted) return;
      _clearSelection();
      await _reportResult(result);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.userErrorMessage(error)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reportResult(RosterBulkResult result) async {
    final l10n = context.l10n;
    if (result.isFullSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.rosterBulkSuccess(result.appliedCount))),
      );
      return;
    }
    if (result.isFullFailure) {
      await _showFailures(l10n.rosterBulkAllFailed, result.failures);
      return;
    }
    // Partial failure: never let this collapse into a plain success toast —
    // the whole reason bulk_assign applies rows independently is so a bad row
    // does not discard the rest, but the manager still has to be told which
    // day did not land.
    await _showFailures(
      l10n.rosterBulkPartialFailureBody(result.appliedCount,
          result.appliedCount + result.failedCount),
      result.failures,
    );
  }

  Future<void> _showFailures(
    String message,
    List<RosterBulkFailure> failures,
  ) {
    final l10n = context.l10n;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.rosterBulkPartialFailureTitle),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView(
                  shrinkWrap: true,
                  children: failures
                      .map(
                        (f) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.error_outline, size: 18),
                          title: Text(f.date ?? '—'),
                          subtitle: Text(f.error),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonClose),
          ),
        ],
      ),
    );
  }

  Future<void> _assignShift() async {
    final month = ref.read(rosterMonthDataProvider).asData?.value;
    final catalog = month?.shiftCatalog ?? const <RosterShift>[];
    final shift = await showRosterShiftPickerSheet(
      context,
      title: context.l10n.rosterBulkAssignShift,
      catalog: catalog,
    );
    if (shift == null) return;
    final selection = widget.selection;
    await _submit([
      for (final date in selection.dates)
        {
          'employee': selection.employee,
          'date': date,
          'action': 'assign',
          'shift_type': shift.shiftType,
        },
    ]);
  }

  Future<void> _markOff() async {
    final month = ref.read(rosterMonthDataProvider).asData?.value;
    final bootstrap = ref.read(rosterBootstrapProvider).asData?.value;
    final employees = month?.employees ?? const <RosterEmployee>[];
    final colleagues = employees
        .where((e) => e.employee != widget.selection.employee)
        .toList();
    RosterEmployee? absent;
    for (final e in employees) {
      if (e.employee == widget.selection.employee) absent = e;
    }

    final choice = await showRosterDayOffForm(
      context,
      title: context.l10n.rosterBulkMarkOff,
      offTypes: bootstrap?.offTypes ?? rosterDefaultOffTypes,
      colleagues: colleagues,
      catalog: month?.shiftCatalog ?? const <RosterShift>[],
      dates: widget.selection.dates.toList()..sort(),
      // The shift the absent person works most across the selected days.
      defaultCoverShift: rosterMostCommonShift(
        absent,
        widget.selection.dates,
      ),
      // `bulk_assign` rows carry neither notes nor a POS grant; the form does
      // not ask for what the request would drop.
      allowNotes: false,
      allowPosAccess: false,
    );
    if (choice == null) return;

    if (!mounted) return;
    final l10n = context.l10n;
    final selection = widget.selection;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.rosterBulkConfirmOffTitle(selection.count)),
        content: Text(l10n.rosterBulkConfirmOffBody(selection.employeeName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton.icon(
            // Deliberately NOT the error colour it used to wear: marking days
            // off is not destructive. Plain theme colours, because on the
            // roster a red or amber means "needs fixing".
            icon: const Icon(Icons.beach_access, size: 18),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            label: Text(l10n.rosterBulkMarkOff),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _submit([
      for (final date in selection.dates)
        {
          'employee': selection.employee,
          'date': date,
          'action': 'day_off',
          'off_type': choice.offType,
          if (choice.coveredBy != null) 'covered_by': choice.coveredBy,
          if (choice.coverShiftType != null)
            'cover_shift_type': choice.coverShiftType,
        },
    ]);
  }

  Future<void> _clearOff() async {
    final selection = widget.selection;
    await _submit([
      for (final date in selection.dates)
        {
          'employee': selection.employee,
          'date': date,
          'action': 'clear_day_off',
        },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final selection = widget.selection;

    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: _busy
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.rosterBulkSelectionCount(
                        selection.count,
                        selection.employeeName,
                      ),
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: _assignShift,
                          icon: const Icon(Icons.work_outline, size: 18),
                          label: Text(l10n.rosterBulkAssignShift),
                        ),
                        OutlinedButton.icon(
                          onPressed: _markOff,
                          icon: const Icon(
                            Icons.beach_access_outlined,
                            size: 18,
                          ),
                          label: Text(l10n.rosterBulkMarkOff),
                        ),
                        OutlinedButton.icon(
                          onPressed: _clearOff,
                          icon: const Icon(Icons.undo, size: 18),
                          label: Text(l10n.rosterBulkClearOff),
                        ),
                        TextButton.icon(
                          onPressed: _clearSelection,
                          icon: const Icon(Icons.close, size: 18),
                          label: Text(l10n.rosterBulkCancelSelection),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
