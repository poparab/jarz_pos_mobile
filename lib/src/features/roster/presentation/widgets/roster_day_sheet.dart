import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../branch_access/presentation/server_error_text.dart';
import '../../data/roster_repository.dart';
import '../../models/roster_models.dart';
import '../../state/roster_providers.dart';
import '../roster_cell_style.dart';
import '../roster_formats.dart';
import '../roster_shift_palette.dart';

/// Edit one person's one day: change the shift, grant a day off, or undo one.
///
/// Takes the grid's [RosterShiftPalette] rather than building its own, so the
/// sheet is the same colour as the cell that opened it. It used to carry a
/// fifth, unrelated mapping — working was `primary`, holiday `secondary` — so
/// tapping a pale-yellow cell opened a purple panel.
Future<void> showRosterDaySheet(
  BuildContext context, {
  required RosterEmployee employee,
  required String date,
  required RosterCell? cell,
  required List<RosterShift> catalog,
  required RosterShiftPalette palette,
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
      palette: palette,
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
    required this.palette,
    this.coveringFor,
  });

  final RosterEmployee employee;
  final String date;
  final RosterCell? cell;
  final List<RosterShift> catalog;
  final RosterShiftPalette palette;

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
            const SizedBox(height: 12),
            _CurrentState(
              employee: widget.employee,
              date: widget.date,
              cell: cell,
              palette: widget.palette,
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
                _ShiftPicker(
                  catalog: widget.catalog,
                  palette: widget.palette,
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
        locations: _locations,
        absentLocation: widget.cell?.shiftLocation,
      ),
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
    required this.palette,
    required this.coveringFor,
  });

  final RosterEmployee employee;
  final String date;
  final RosterCell? cell;
  final RosterShiftPalette palette;
  final String? coveringFor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final data = cell;

    final resolver = RosterStyleResolver.of(context, palette: palette);
    final state = resolver.stateFor(cell: data, date: date);
    final style = resolver.styleFor(state, shiftType: data?.shiftType);
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
          data!.dayOff!.offType,
          data.dayOff!.coveredByName ?? '',
        );
      case RosterCellState.offUncovered:
        detail = l10n.rosterOffUncovered(data!.dayOff!.offType);
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
              else if (style.shiftCode != null)
                _CodeBadge(code: style.shiftCode!, foreground: style.foreground)
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
          for (final marker in markers)
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

/// The shift type's code, in the same shape the grid cell uses.
class _CodeBadge extends StatelessWidget {
  const _CodeBadge({required this.code, required this.foreground});

  final String code;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}

class _ShiftPicker extends StatelessWidget {
  const _ShiftPicker({
    required this.catalog,
    required this.palette,
    required this.selected,
    required this.onPick,
  });

  final List<RosterShift> catalog;
  final RosterShiftPalette palette;
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
          final style = palette.styleFor(shift.shiftType);
          return ListTile(
            dense: true,
            selected: isSelected,
            // The colour and code the grid will draw once this is picked, so
            // the choice is made in the same vocabulary it is read in.
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

class _DayOffChoice {
  const _DayOffChoice({
    required this.offType,
    this.coveredBy,
    this.coverShiftType,
    this.notes,
    this.grantPosAccess = false,
    this.posAccessBranch,
  });

  final String offType;
  final String? coveredBy;
  final String? coverShiftType;
  final String? notes;

  /// Give the covering person POS access at the covered branch for the day.
  final bool grantPosAccess;
  final String? posAccessBranch;
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
    this.locations = const [],
    this.absentLocation,
  });

  final List<String> offTypes;
  final List<RosterEmployee> colleagues;
  final List<RosterShift> catalog;
  final String date;

  /// The bootstrap's branches, carrying which ones can take a POS grant.
  final List<RosterLocation> locations;

  /// The absent person's branch on this day, if rostered.
  final String? absentLocation;

  @override
  State<_DayOffForm> createState() => _DayOffFormState();
}

class _DayOffFormState extends State<_DayOffForm> {
  late String _offType = widget.offTypes.isEmpty
      ? 'Weekly Off'
      : widget.offTypes.first;
  String? _coveredBy;
  String? _coverShiftType;
  bool _grantPosAccess = false;
  final _notes = TextEditingController();

  /// The branch the cover is rostered at, resolved in the server's order.
  RosterLocation? get _coverTarget {
    final coveredBy = _coveredBy;
    if (coveredBy == null) return null;
    RosterEmployee? coverer;
    for (final e in widget.colleagues) {
      if (e.employee == coveredBy) coverer = e;
    }
    return findRosterLocation(
      widget.locations,
      resolveCoverLocation(
        absentLocation: widget.absentLocation,
        covererLocationThatDay: coverer?.cellFor(widget.date)?.shiftLocation,
        covererHomeLocation: coverer?.fallbackLocation,
      ),
    );
  }

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
    final coverTarget = _coverTarget;
    final offerPosAccess =
        coverTarget != null &&
        coverTarget.canGrantPosAccess &&
        isWithinPosAccessWindow(widget.date);

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
                  // A different person may land at a different branch; a
                  // tick given for the last choice must not carry over.
                  _grantPosAccess = false;
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
                            context.l10n.rosterShiftWindow(
                              shift.shiftType,
                              rosterNumber(context, shift.hours),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _coverShiftType = value),
                ),
                if (offerPosAccess) ...[
                  const SizedBox(height: 8),
                  PosAccessCheckbox(
                    value: _grantPosAccess,
                    branch: coverTarget.posProfile!,
                    onChanged: (value) =>
                        setState(() => _grantPosAccess = value),
                  ),
                ],
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
                                grantPosAccess:
                                    offerPosAccess && _grantPosAccess,
                                posAccessBranch: coverTarget?.posProfile,
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

/// The bootstrap entry for [shiftLocation], or null.
RosterLocation? findRosterLocation(
  List<RosterLocation> locations,
  String? shiftLocation,
) {
  final name = (shiftLocation ?? '').trim();
  if (name.isEmpty) return null;
  for (final location in locations) {
    if (location.shiftLocation == name) return location;
  }
  return null;
}

/// Where a cover is rostered, in the server's order: the ABSENT person's
/// branch first (the branch that is short), then where the coverer was already
/// rostered that day, then the coverer's home branch.
String? resolveCoverLocation({
  String? absentLocation,
  String? covererLocationThatDay,
  String? covererHomeLocation,
}) {
  for (final candidate in [
    absentLocation,
    covererLocationThatDay,
    covererHomeLocation,
  ]) {
    final value = (candidate ?? '').trim();
    if (value.isNotEmpty) return value;
  }
  return null;
}

/// Whether [date] is one the server will accept a day access for: today up to
/// 14 days ahead. Outside it the tick box is not offered at all, rather than
/// offered and then refused.
bool isWithinPosAccessWindow(String date, {DateTime? now}) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return false;
  final clock = now ?? DateTime.now();
  final today = DateTime(clock.year, clock.month, clock.day);
  final day = DateTime(parsed.year, parsed.month, parsed.day);
  final diff = day.difference(today).inDays;
  return diff >= 0 && diff <= 14;
}

/// The snackbar line for a roster write that asked for POS access.
String posAccessOutcomeMessage(
  AppLocalizations l10n,
  PosAccessOutcome? outcome, {
  required String fallbackBranch,
}) {
  if (outcome == null || !outcome.requested) {
    return l10n.rosterPosAccessNotConfirmed;
  }
  final branch = outcome.posProfile ?? fallbackBranch;
  if (outcome.granted) {
    return outcome.isScheduled
        ? l10n.rosterPosAccessScheduled(branch)
        : l10n.rosterPosAccessGranted(branch);
  }
  if (outcome.alreadyMember) return l10n.rosterPosAccessAlreadyMember(branch);
  // The server's reason, verbatim - it names the open shift or the missing
  // user, which a generic line would throw away.
  return l10n.rosterPosAccessNotGranted(
    outcome.reason ?? l10n.rosterPosAccessNoReason,
  );
}

/// "Also give POS access for this day" - one tick box, used by both the
/// assign and the day-off-with-cover flows.
class PosAccessCheckbox extends StatelessWidget {
  const PosAccessCheckbox({
    super.key,
    required this.value,
    required this.branch,
    required this.onChanged,
  });

  final bool value;
  final String branch;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CheckboxListTile(
      value: value,
      onChanged: (checked) => onChanged(checked ?? false),
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      secondary: const Icon(Icons.point_of_sale_outlined),
      title: Text(l10n.rosterGrantPosAccess),
      subtitle: Text(l10n.rosterGrantPosAccessHelper(branch)),
    );
  }
}
