import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../branch_access/presentation/server_error_text.dart';
import '../../data/roster_repository.dart';
import '../../models/roster_models.dart';
import '../../state/roster_providers.dart';
import '../roster_cell_style.dart';
import '../roster_formats.dart';
import 'roster_day_off_form.dart';
import 'roster_shift_picker.dart';

// The POS-access helpers lived here before the day-off form was shared with
// the bulk bar; re-exported so existing importers keep resolving them.
export 'roster_day_off_form.dart'
    show
        PosAccessCheckbox,
        findRosterLocation,
        isWithinPosAccessWindow,
        posAccessOutcomeMessage,
        resolveCoverLocation;

/// Edit one person's one day: change the shift, grant a day off, or undo one.
///
/// Resolves the day through the grid's [RosterStyleResolver], so the sheet
/// says the same thing as the cell that opened it. It used to carry a fifth,
/// unrelated colour mapping — working was `primary`, holiday `secondary`.
Future<void> showRosterDaySheet(
  BuildContext context, {
  required RosterEmployee employee,
  required String date,
  required RosterCell? cell,
  required List<RosterShift> catalog,
  String? coveringFor,
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
      coveringFor: coveringFor,
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
    this.coveringFor,
  });

  final RosterEmployee employee;
  final String date;
  final RosterCell? cell;
  final List<RosterShift> catalog;

  /// The colleague whose day this person is absorbing, when there is one.
  final String? coveringFor;

  @override
  ConsumerState<RosterDaySheet> createState() => _RosterDaySheetState();
}

class _RosterDaySheetState extends ConsumerState<RosterDaySheet> {
  bool _busy = false;

  /// "Also give POS access for this day" for a shift assignment. Off by
  /// default: access is a deliberate grant, never a side effect of rostering.
  bool _grantPosAccess = false;

  List<RosterLocation> get _locations =>
      ref.read(rosterBootstrapProvider).asData?.value.shiftLocations ??
      const <RosterLocation>[];

  /// Where an assignment on this day lands: the day's own branch if it has
  /// one, otherwise the person's schedule branch (`schedule_location`, or the
  /// first shift location on an older backend) - the same order the server
  /// resolves it in when no location is sent.
  RosterLocation? get _assignTarget => findRosterLocation(
    _locations,
    widget.cell?.shiftLocation ?? widget.employee.fallbackLocation,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cell = widget.cell;
    final isOff = cell?.isOff ?? false;
    final parsed = DateTime.tryParse(widget.date);
    // Watched so the tick box appears once the bootstrap lands.
    ref.watch(rosterBootstrapProvider);
    final assignTarget = _assignTarget;
    final offerPosAccess =
        assignTarget != null &&
        assignTarget.canGrantPosAccess &&
        isWithinPosAccessWindow(widget.date);

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
            // The overtime baseline. It used to sit under every name in the
            // grid; the grid now shows only the overtime dot, so the number
            // the dot is measured against lives here.
            if (widget.employee.standardHours > 0)
              Text(
                l10n.rosterStandardDay(
                  rosterNumber(context, widget.employee.standardHours),
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            const SizedBox(height: 12),
            _CurrentState(
              employee: widget.employee,
              date: widget.date,
              cell: cell,
              catalog: widget.catalog,
              coveringFor: widget.coveringFor,
            ),
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
                Text(l10n.rosterChangeShift, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                if (offerPosAccess)
                  PosAccessCheckbox(
                    value: _grantPosAccess,
                    branch: assignTarget.posProfile!,
                    onChanged: (value) =>
                        setState(() => _grantPosAccess = value),
                  ),
                RosterShiftPicker(
                  catalog: widget.catalog,
                  employee: widget.employee,
                  dates: [widget.date],
                  selected: cell?.shiftType,
                  onPick: (shift) => _assignShift(
                    shift,
                    grant: offerPosAccess && _grantPosAccess,
                  ),
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

  /// Run one roster write, then close the sheet.
  ///
  /// When [posAccessRequested] the write also asked for a day's POS access;
  /// its outcome is reported in a snackbar after the sheet closes. The roster
  /// write stands either way - the server never rolls it back over the grant.
  Future<void> _run(
    Future<PosAccessOutcome?> Function() action, {
    bool posAccessRequested = false,
    String? posAccessBranch,
  }) async {
    setState(() => _busy = true);
    // Captured before the pop: the sheet's context is gone afterwards.
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final outcome = await action();
      ref.invalidate(rosterMonthDataProvider);
      ref.invalidate(rosterHoursProvider);
      if (mounted) Navigator.of(context).pop();
      if (posAccessRequested) {
        final message = posAccessOutcomeMessage(
          l10n,
          outcome,
          fallbackBranch: posAccessBranch ?? '',
        );
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(serverErrorText(context, error)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _assignShift(RosterShift shift, {bool grant = false}) {
    _run(
      () => ref
          .read(rosterRepositoryProvider)
          .assignShift(
            employee: widget.employee.employee,
            date: widget.date,
            shiftType: shift.shiftType,
            grantPosAccess: grant,
          ),
      posAccessRequested: grant,
      posAccessBranch: _assignTarget?.posProfile,
    );
  }

  void _clearDayOff() {
    _run(() async {
      await ref
          .read(rosterRepositoryProvider)
          .clearDayOff(employee: widget.employee.employee, date: widget.date);
      return null;
    });
  }

  Future<void> _openDayOffFlow() async {
    final month = ref.read(rosterMonthDataProvider).asData?.value;
    final colleagues = (month?.employees ?? const <RosterEmployee>[])
        .where((e) => e.employee != widget.employee.employee)
        .toList();

    final result = await showRosterDayOffForm(
      context,
      title: context.l10n.rosterMarkDayOff,
      offTypes:
          ref.read(rosterBootstrapProvider).asData?.value.offTypes ??
          rosterDefaultOffTypes,
      colleagues: colleagues,
      catalog: widget.catalog,
      dates: [widget.date],
      locations: _locations,
      absentLocation: widget.cell?.shiftLocation,
      // Whoever covers normally steps onto the absent person's own shift.
      defaultCoverShift: widget.cell?.shiftType,
    );
    if (result == null) return;

    final grant = result.grantPosAccess && result.coveredBy != null;
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
            grantPosAccess: grant,
          ),
      posAccessRequested: grant,
      posAccessBranch: result.posAccessBranch,
    );
  }
}

/// What this day currently is, drawn exactly as the grid draws it.
///
/// Same resolver, same hue, same glyph — so the panel confirms the cell the
/// manager tapped instead of describing it in a different visual language.
class _CurrentState extends StatelessWidget {
  const _CurrentState({
    required this.employee,
    required this.date,
    required this.cell,
    required this.catalog,
    required this.coveringFor,
  });

  final RosterEmployee employee;
  final String date;
  final RosterCell? cell;
  final List<RosterShift> catalog;
  final String? coveringFor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final data = cell;

    final resolver = RosterStyleResolver.of(
      context,
      catalog: RosterShiftCatalog(catalog),
    );
    final state = resolver.stateFor(cell: data, date: date);
    final style = resolver.styleFor(
      state,
      shiftType: data?.shiftType,
      hours: data?.hours,
    );
    final markers = resolver.markersFor(
      cell: data,
      employee: employee,
      isCover: coveringFor != null || (data?.isCoverFlag ?? false),
    );

    final String detail;
    switch (state) {
      case RosterCellState.working:
        final branch = (data!.shiftLocation ?? '').trim();
        detail = l10n.rosterWorkingShift(
          data.shiftType!,
          rosterNumber(context, data.hours),
          branch.isEmpty ? l10n.rosterBranchUnknown : branch,
        );
      case RosterCellState.offCovered:
        detail = l10n.rosterOffCoveredBy(
          rosterOffTypeLabel(l10n, data!.dayOff!.offType),
          data.dayOff!.coveredByName ?? '',
        );
      case RosterCellState.offUncovered:
        detail = l10n.rosterOffUncovered(
          rosterOffTypeLabel(l10n, data!.dayOff!.offType),
        );
      case RosterCellState.holiday:
        detail = l10n.rosterHoliday;
      case RosterCellState.unrosteredFuture:
        // The state that stops somebody working, so it is stated outright
        // rather than shown as an empty slot.
        detail = l10n.rosterUnrosteredWarning;
      case RosterCellState.unrosteredPast:
        detail = l10n.rosterUnrosteredPast;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: style.hasBorder ? style.borderColor : theme.dividerColor,
          width: style.hasBorder ? style.borderWidth : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (style.icon != null)
                Icon(style.icon, size: 18, color: style.foreground)
              else
                Text(
                  style.token,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: style.foreground,
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: style.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          for (final marker in [
            ...markers,
            // Weekend is drawn on the grid's column header, never on a cell,
            // so the resolver does not report it as a cell marker. The sheet
            // says it anyway: it is one of the things the cell used to carry.
            if (_isWeekend) RosterCellMarker.weekend,
          ])
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(
                    resolver.markerStyle(marker).icon,
                    size: 14,
                    color: style.foreground,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _markerDetail(context, marker, resolver),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: style.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool get _isWeekend {
    final parsed = DateTime.tryParse(date);
    return parsed != null && isRosterWeekend(parsed);
  }

  /// The marker's legend wording, made specific where the sheet has room for
  /// the numbers and names the grid cannot fit.
  String _markerDetail(
    BuildContext context,
    RosterCellMarker marker,
    RosterStyleResolver resolver,
  ) {
    final l10n = context.l10n;
    switch (marker) {
      case RosterCellMarker.cover:
        final name = coveringFor;
        return name == null || name.isEmpty
            ? resolver.markerStyle(marker).label
            : l10n.rosterCoveringFor(name);
      case RosterCellMarker.overtime:
        return l10n.rosterAboveNormalDay(
          rosterNumber(context, cell?.hours ?? 0),
          rosterNumber(context, employee.standardHours),
        );
      case RosterCellMarker.holidayWorked:
      case RosterCellMarker.weekend:
      case RosterCellMarker.selected:
        return resolver.markerStyle(marker).label;
    }
  }
}
