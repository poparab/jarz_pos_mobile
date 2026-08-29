import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/network/frappe_error_message.dart';
import '../../data/roster_repository.dart';
import '../../models/roster_models.dart';
import '../../state/roster_providers.dart';

/// Edit one person's one day: change the shift, grant a day off, or undo one.
Future<void> showRosterDaySheet(
  BuildContext context, {
  required RosterEmployee employee,
  required String date,
  required RosterCell? cell,
  required List<RosterShift> catalog,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => RosterDaySheet(
      employee: employee,
      date: date,
      cell: cell,
      catalog: catalog,
    ),
  );
}

class RosterDaySheet extends ConsumerStatefulWidget {
  const RosterDaySheet({
    super.key,
    required this.employee,
    required this.date,
    required this.cell,
    required this.catalog,
  });

  final RosterEmployee employee;
  final String date;
  final RosterCell? cell;
  final List<RosterShift> catalog;

  @override
  ConsumerState<RosterDaySheet> createState() => _RosterDaySheetState();
}

class _RosterDaySheetState extends ConsumerState<RosterDaySheet> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cell = widget.cell;
    final isOff = cell?.isOff ?? false;
    final parsed = DateTime.tryParse(widget.date);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.employee.employeeName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              parsed == null
                  ? widget.date
                  : formatDate(context, parsed, pattern: 'EEEE, MMM d'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _CurrentState(cell: cell),
            const SizedBox(height: 16),
            if (_busy)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (isOff)
                FilledButton.tonalIcon(
                  onPressed: _clearDayOff,
                  icon: const Icon(Icons.undo),
                  label: Text(l10n.rosterClearDayOff),
                )
              else ...[
                Text(
                  l10n.rosterChangeShift,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                _ShiftPicker(
                  catalog: widget.catalog,
                  selected: cell?.shiftType,
                  onPick: _assignShift,
                ),
                const Divider(height: 28),
                FilledButton.icon(
                  onPressed: _openDayOffFlow,
                  icon: const Icon(Icons.beach_access_outlined),
                  label: Text(l10n.rosterMarkDayOff),
                ),
              ],
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(rosterMonthDataProvider);
      ref.invalidate(rosterHoursProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(extractFrappeErrorMessage(error)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _assignShift(RosterShift shift) {
    _run(
      () => ref
          .read(rosterRepositoryProvider)
          .assignShift(
            employee: widget.employee.employee,
            date: widget.date,
            shiftType: shift.shiftType,
          ),
    );
  }

  void _clearDayOff() {
    _run(
      () => ref
          .read(rosterRepositoryProvider)
          .clearDayOff(
            employee: widget.employee.employee,
            date: widget.date,
          ),
    );
  }

  Future<void> _openDayOffFlow() async {
    final month = ref.read(rosterMonthDataProvider).asData?.value;
    final colleagues = (month?.employees ?? const <RosterEmployee>[])
        .where((e) => e.employee != widget.employee.employee)
        .toList();

    final result = await showModalBottomSheet<_DayOffChoice>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _DayOffForm(
        offTypes:
            ref.read(rosterBootstrapProvider).asData?.value.offTypes ??
            const ['Weekly Off', 'Vacation', 'Sick', 'Unpaid', 'Other'],
        colleagues: colleagues,
        catalog: widget.catalog,
        date: widget.date,
      ),
    );
    if (result == null) return;

    await _run(
      () => ref
          .read(rosterRepositoryProvider)
          .setDayOff(
            employee: widget.employee.employee,
            date: widget.date,
            offType: result.offType,
            coveredBy: result.coveredBy,
            coverShiftType: result.coverShiftType,
            notes: result.notes,
          ),
    );
  }
}

class _CurrentState extends StatelessWidget {
  const _CurrentState({required this.cell});

  final RosterCell? cell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final data = cell;

    String text;
    IconData icon;
    Color color;

    if (data != null && data.isOff) {
      final off = data.dayOff!;
      icon = Icons.beach_access;
      color = theme.colorScheme.tertiary;
      text = off.isCovered
          ? l10n.rosterOffCoveredBy(off.offType, off.coveredByName ?? '')
          : l10n.rosterOffUncovered(off.offType);
    } else if (data != null && data.isWorking) {
      icon = Icons.work_outline;
      color = theme.colorScheme.primary;
      text = l10n.rosterWorkingShift(
        data.shiftType!,
        _trimZero(data.hours),
        data.shiftLocation ?? '—',
      );
    } else if (data != null && data.isHoliday) {
      icon = Icons.celebration_outlined;
      color = theme.colorScheme.secondary;
      text = l10n.rosterHoliday;
    } else {
      // The state that stops somebody working, so it is stated outright rather
      // than shown as an empty slot.
      icon = Icons.block;
      color = theme.colorScheme.error;
      text = l10n.rosterUnrosteredWarning;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _ShiftPicker extends StatelessWidget {
  const _ShiftPicker({
    required this.catalog,
    required this.selected,
    required this.onPick,
  });

  final List<RosterShift> catalog;
  final String? selected;
  final ValueChanged<RosterShift> onPick;

  @override
  Widget build(BuildContext context) {
    if (catalog.isEmpty) {
      return Text(context.l10n.rosterNoShiftTypes);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 260),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: catalog.length,
        itemBuilder: (context, index) {
          final shift = catalog[index];
          final isSelected = shift.shiftType == selected;
          return ListTile(
            dense: true,
            selected: isSelected,
            leading: Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
            ),
            title: Text(shift.shiftType),
            subtitle: Text(
              context.l10n.rosterShiftWindow(
                shift.window,
                _trimZero(shift.hours),
              ),
            ),
            onTap: isSelected ? null : () => onPick(shift),
          );
        },
      ),
    );
  }
}

class _DayOffChoice {
  const _DayOffChoice({
    required this.offType,
    this.coveredBy,
    this.coverShiftType,
    this.notes,
  });

  final String offType;
  final String? coveredBy;
  final String? coverShiftType;
  final String? notes;
}

/// Grant a day off, and — in the same step — hand the day to a colleague.
///
/// Cover is asked for here rather than left as a follow-up action because a
/// branch that loses one of its two overlapping shifts is not covered by simply
/// shortening the rota: somebody has to stretch onto the longer shift, and
/// splitting that into a second action leaves a window where the branch is
/// rostered half-open.
class _DayOffForm extends StatefulWidget {
  const _DayOffForm({
    required this.offTypes,
    required this.colleagues,
    required this.catalog,
    required this.date,
  });

  final List<String> offTypes;
  final List<RosterEmployee> colleagues;
  final List<RosterShift> catalog;
  final String date;

  @override
  State<_DayOffForm> createState() => _DayOffFormState();
}

class _DayOffFormState extends State<_DayOffForm> {
  late String _offType = widget.offTypes.isEmpty
      ? 'Weekly Off'
      : widget.offTypes.first;
  String? _coveredBy;
  String? _coverShiftType;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final needsCoverShift = _coveredBy != null && _coverShiftType == null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.rosterMarkDayOff,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _offType,
                decoration: InputDecoration(
                  labelText: l10n.rosterOffType,
                  border: const OutlineInputBorder(),
                ),
                items: widget.offTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_localisedOffType(context, type)),
                      ),
                    )
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
                          child: Text(
                            '${shift.shiftType} · ${_trimZero(shift.hours)}h',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _coverShiftType = value),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _notes,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.rosterNotes,
                  border: const OutlineInputBorder(),
                ),
              ),
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
                      // Naming a colleague without saying which shift they move
                      // onto is the one incomplete state here; the backend
                      // rejects it, so the button refuses first.
                      onPressed: needsCoverShift
                          ? null
                          : () => Navigator.of(context).pop(
                              _DayOffChoice(
                                offType: _offType,
                                coveredBy: _coveredBy,
                                coverShiftType: _coverShiftType,
                                notes: _notes.text.trim().isEmpty
                                    ? null
                                    : _notes.text.trim(),
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

/// Off types are a server-side Select, so they arrive in English.
///
/// Translating them here rather than storing translated values keeps the stored
/// data one language — the same reason the kanban column vocabulary is mapped
/// on the client instead of in the database.
String _localisedOffType(BuildContext context, String raw) {
  final l10n = context.l10n;
  switch (raw) {
    case 'Weekly Off':
      return l10n.rosterOffTypeWeekly;
    case 'Vacation':
      return l10n.rosterOffTypeVacation;
    case 'Sick':
      return l10n.rosterOffTypeSick;
    case 'Unpaid':
      return l10n.rosterOffTypeUnpaid;
    case 'Other':
      return l10n.rosterOffTypeOther;
    default:
      return raw;
  }
}

String _trimZero(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}
