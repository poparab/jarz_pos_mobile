import 'package:flutter/material.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/roster_models.dart';
import '../roster_formats.dart';

/// What the day-off form resolved to.
class RosterDayOffChoice {
  const RosterDayOffChoice({
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

/// The off types offered when the bootstrap has not landed (or is an older
/// backend that does not send them).
const List<String> rosterDefaultOffTypes = <String>[
  'Weekly Off',
  'Vacation',
  'Sick',
  'Unpaid',
  'Other',
];

/// Keys a test can find the form's parts by.
const Key rosterCoveredByFieldKey = ValueKey<String>('roster-covered-by');
const Key rosterCoverShiftFieldKey = ValueKey<String>('roster-cover-shift');
const Key rosterMoreOptionsKey = ValueKey<String>('roster-more-options');
const Key rosterDayOffSaveKey = ValueKey<String>('roster-day-off-save');

/// Opens [RosterDayOffForm] in a bottom sheet.
Future<RosterDayOffChoice?> showRosterDayOffForm(
  BuildContext context, {
  required String title,
  required List<String> offTypes,
  required List<RosterEmployee> colleagues,
  required List<RosterShift> catalog,
  required List<String> dates,
  List<RosterLocation> locations = const [],
  String? absentLocation,
  String? defaultCoverShift,
  bool allowNotes = true,
  bool allowPosAccess = true,
}) {
  return showModalBottomSheet<RosterDayOffChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => RosterDayOffForm(
      title: title,
      offTypes: offTypes,
      colleagues: colleagues,
      catalog: catalog,
      dates: dates,
      locations: locations,
      absentLocation: absentLocation,
      defaultCoverShift: defaultCoverShift,
      allowNotes: allowNotes,
      allowPosAccess: allowPosAccess,
    ),
  );
}

/// Grant a day off (or a run of them), and — in the same step — hand the day
/// to a colleague. Shared by the single-day sheet and the bulk bar; the two
/// used to carry their own copies (`_DayOffForm` / `_BulkDayOffForm`).
///
/// Cover is asked for here rather than left as a follow-up action because a
/// branch that loses one of its two overlapping shifts is not covered by simply
/// shortening the rota: somebody has to stretch onto the longer shift, and
/// splitting that into a second action leaves a window where the branch is
/// rostered half-open.
///
/// Only the reason and the coverer are visible up front. The cover shift
/// defaults to the absent person's own shift ([defaultCoverShift]) — the one a
/// coverer normally steps onto — so the manager rarely touches it, and it sits
/// under "More options" with the notes and the POS-access tick box. When there
/// is no default (the absent person was not rostered) the cover shift is shown
/// up front instead, because Save stays disabled until one is picked and a
/// disabled button with its reason hidden in a collapsed panel is a dead end.
class RosterDayOffForm extends StatefulWidget {
  const RosterDayOffForm({
    super.key,
    required this.title,
    required this.offTypes,
    required this.colleagues,
    required this.catalog,
    required this.dates,
    this.locations = const [],
    this.absentLocation,
    this.defaultCoverShift,
    this.allowNotes = true,
    this.allowPosAccess = true,
  });

  final String title;
  final List<String> offTypes;
  final List<RosterEmployee> colleagues;
  final List<RosterShift> catalog;

  /// The day(s) being marked off. One for the single-day sheet.
  final List<String> dates;

  /// The bootstrap's branches, carrying which ones can take a POS grant.
  final List<RosterLocation> locations;

  /// The absent person's branch on this day, if rostered.
  final String? absentLocation;

  /// The cover shift chosen automatically when a coverer is picked.
  final String? defaultCoverShift;

  /// The bulk request (`bulk_assign`) carries neither notes nor a POS grant,
  /// so the bulk bar turns both off rather than collecting input it drops.
  final bool allowNotes;
  final bool allowPosAccess;

  @override
  State<RosterDayOffForm> createState() => _RosterDayOffFormState();
}

class _RosterDayOffFormState extends State<RosterDayOffForm> {
  late String _offType = widget.offTypes.isEmpty
      ? 'Weekly Off'
      : widget.offTypes.first;
  String? _coveredBy;
  String? _coverShiftType;
  bool _grantPosAccess = false;
  final _notes = TextEditingController();

  /// [RosterDayOffForm.defaultCoverShift], when it is a shift that can still
  /// be picked. A retired shift type is not offered by the dropdown, so it
  /// cannot be its default either.
  String? get _usableDefault {
    final wanted = (widget.defaultCoverShift ?? '').trim();
    if (wanted.isEmpty) return null;
    for (final shift in widget.catalog) {
      if (shift.shiftType == wanted) return wanted;
    }
    return null;
  }

  /// The branch the cover is rostered at, resolved in the server's order.
  RosterLocation? get _coverTarget {
    final coveredBy = _coveredBy;
    if (coveredBy == null || widget.dates.length != 1) return null;
    RosterEmployee? coverer;
    for (final e in widget.colleagues) {
      if (e.employee == coveredBy) coverer = e;
    }
    return findRosterLocation(
      widget.locations,
      resolveCoverLocation(
        absentLocation: widget.absentLocation,
        covererLocationThatDay: coverer
            ?.cellFor(widget.dates.single)
            ?.shiftLocation,
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
        widget.allowPosAccess &&
        widget.dates.length == 1 &&
        coverTarget != null &&
        coverTarget.canGrantPosAccess &&
        isWithinPosAccessWindow(widget.dates.single);
    final coverShiftUpFront = _coveredBy != null && _usableDefault == null;
    final coverShiftInMore = _coveredBy != null && !coverShiftUpFront;

    final coverShiftField = DropdownButtonFormField<String>(
      // Keyed on the coverer so a programmatic default lands in the field
      // instead of being ignored as a stale initial value.
      key: ValueKey<String>('cover-shift-${_coveredBy ?? ''}'),
      initialValue: _coverShiftType,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.rosterCoverShift,
        helperText: l10n.rosterCoverShiftHelper,
        helperMaxLines: 2,
        border: const OutlineInputBorder(),
      ),
      items: widget.catalog
          .map(
            (shift) => DropdownMenuItem(
              value: shift.shiftType,
              child: Text(
                l10n.rosterShiftWindow(
                  shift.shiftType,
                  rosterNumber(context, shift.hours),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _coverShiftType = value),
    );

    final moreOptions = <Widget>[
      if (coverShiftInMore) ...[
        const SizedBox(height: 8),
        KeyedSubtree(key: rosterCoverShiftFieldKey, child: coverShiftField),
      ],
      if (offerPosAccess) ...[
        const SizedBox(height: 8),
        PosAccessCheckbox(
          value: _grantPosAccess,
          branch: coverTarget.posProfile!,
          onChanged: (value) => setState(() => _grantPosAccess = value),
        ),
      ],
      if (widget.allowNotes) ...[
        const SizedBox(height: 8),
        TextField(
          controller: _notes,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: l10n.rosterNotes,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    ];

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
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _offType,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.rosterOffType,
                  border: const OutlineInputBorder(),
                ),
                items: widget.offTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(rosterOffTypeLabel(l10n, type)),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _offType = value ?? _offType),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                key: rosterCoveredByFieldKey,
                initialValue: _coveredBy,
                isExpanded: true,
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
                  // The coverer steps onto the absent person's own shift
                  // unless the manager says otherwise; no coverer, no shift.
                  _coverShiftType = value == null ? null : _usableDefault;
                  // A different person may land at a different branch; a
                  // tick given for the last choice must not carry over.
                  _grantPosAccess = false;
                }),
              ),
              if (coverShiftUpFront) ...[
                const SizedBox(height: 16),
                KeyedSubtree(
                  key: rosterCoverShiftFieldKey,
                  child: coverShiftField,
                ),
              ],
              if (moreOptions.isNotEmpty) ...[
                const SizedBox(height: 8),
                ExpansionTile(
                  key: rosterMoreOptionsKey,
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  title: Text(l10n.rosterMoreOptions),
                  subtitle: coverShiftInMore && _coverShiftType != null
                      ? Text(l10n.rosterCoverShiftSummary(_coverShiftType!))
                      : null,
                  children: moreOptions,
                ),
              ],
              const SizedBox(height: 16),
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
                      key: rosterDayOffSaveKey,
                      // Naming a colleague without saying which shift they move
                      // onto is the one incomplete state here; the backend
                      // rejects it, so the button refuses first.
                      onPressed: needsCoverShift
                          ? null
                          : () => Navigator.of(context).pop(
                              RosterDayOffChoice(
                                offType: _offType,
                                coveredBy: _coveredBy,
                                coverShiftType: _coverShiftType,
                                notes:
                                    !widget.allowNotes ||
                                        _notes.text.trim().isEmpty
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
String rosterOffTypeLabel(AppLocalizations l10n, String raw) {
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
