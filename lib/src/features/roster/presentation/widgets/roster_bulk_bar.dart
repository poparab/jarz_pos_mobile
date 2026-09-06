import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/roster_repository.dart';
import '../../models/roster_models.dart';
import '../../state/roster_providers.dart';

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

  void _clearSelection() =>
      ref.read(rosterSelectionProvider.notifier).state = null;

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
    final shift = await showModalBottomSheet<RosterShift>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _BulkShiftPicker(catalog: catalog),
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
    final colleagues = (month?.employees ?? const <RosterEmployee>[])
        .where((e) => e.employee != widget.selection.employee)
        .toList();

    final choice = await showModalBottomSheet<_BulkDayOffChoice>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _BulkDayOffForm(
        offTypes:
            bootstrap?.offTypes ??
            const ['Weekly Off', 'Vacation', 'Sick', 'Unpaid', 'Other'],
        colleagues: colleagues,
        catalog: month?.shiftCatalog ?? const <RosterShift>[],
      ),
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
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.rosterBulkMarkOff),
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

class _BulkShiftPicker extends StatelessWidget {
  const _BulkShiftPicker({required this.catalog});

  final List<RosterShift> catalog;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.rosterBulkAssignShift,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (catalog.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(l10n.rosterNoShiftTypes),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: catalog.length,
                  itemBuilder: (context, index) {
                    final shift = catalog[index];
                    return ListTile(
                      dense: true,
                      title: Text(shift.shiftType),
                      subtitle: Text(shift.window),
                      onTap: () => Navigator.of(context).pop(shift),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _BulkDayOffChoice {
  const _BulkDayOffChoice({
    required this.offType,
    this.coveredBy,
    this.coverShiftType,
  });

  final String offType;
  final String? coveredBy;
  final String? coverShiftType;
}

class _BulkDayOffForm extends StatefulWidget {
  const _BulkDayOffForm({
    required this.offTypes,
    required this.colleagues,
    required this.catalog,
  });

  final List<String> offTypes;
  final List<RosterEmployee> colleagues;
  final List<RosterShift> catalog;

  @override
  State<_BulkDayOffForm> createState() => _BulkDayOffFormState();
}

class _BulkDayOffFormState extends State<_BulkDayOffForm> {
  late String _offType = widget.offTypes.isEmpty
      ? 'Weekly Off'
      : widget.offTypes.first;
  String? _coveredBy;
  String? _coverShiftType;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final needsCoverShift = _coveredBy != null && _coverShiftType == null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.rosterBulkMarkOff,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _offType,
                decoration: InputDecoration(
                  labelText: l10n.rosterOffType,
                  border: const OutlineInputBorder(),
                ),
                items: widget.offTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _offType = value ?? _offType),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _coveredBy,
                decoration: InputDecoration(
                  labelText: l10n.rosterCoveredBy,
                  helperText: l10n.rosterCoverHelper,
                  border: const OutlineInputBorder(),
                ),
                items: <DropdownMenuItem<String?>>[
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.rosterNobodyCovers),
                  ),
                  ...widget.colleagues.map(
                    (e) => DropdownMenuItem<String?>(
                      value: e.employee,
                      child: Text(e.employeeName),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() {
                  _coveredBy = value;
                  if (value == null) _coverShiftType = null;
                }),
              ),
              if (_coveredBy != null) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _coverShiftType,
                  decoration: InputDecoration(
                    labelText: l10n.rosterCoverShift,
                    helperText: l10n.rosterCoverShiftHelper,
                    border: const OutlineInputBorder(),
                  ),
                  items: widget.catalog
                      .map(
                        (shift) => DropdownMenuItem(
                          value: shift.shiftType,
                          child: Text(shift.shiftType),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _coverShiftType = value),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.commonCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: needsCoverShift
                          ? null
                          : () => Navigator.of(context).pop(
                              _BulkDayOffChoice(
                                offType: _offType,
                                coveredBy: _coveredBy,
                                coverShiftType: _coverShiftType,
                              ),
                            ),
                      child: Text(l10n.commonSave),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
