import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../leads/presentation/leads_theme.dart';
import '../../data/journey_repository.dart';
import '../../data/models/journey_note.dart';
import '../journey_format.dart';

/// What the editor hands back: the fields of one journey note.
///
/// Every optional field is a plain (possibly empty) String rather than a
/// nullable, because the edit path uses "" to CLEAR a field server-side — a
/// null would mean "leave it alone", which is not what a rep emptying a box
/// means.
class JourneyNoteDraft {
  const JourneyNoteDraft({
    required this.note,
    required this.entryDate,
    required this.entryType,
    required this.contactPerson,
    required this.contactRole,
    required this.contactPhone,
    required this.nextAction,
    required this.nextActionDate,
    required this.outcome,
  });

  final String note;
  final String entryDate;
  final String entryType;
  final String contactPerson;
  final String contactRole;
  final String contactPhone;
  final String nextAction;
  final String nextActionDate;
  final String outcome;
}

/// Opens the journey-note editor as a modal sheet. Returns the draft, or null
/// when the rep backs out.
///
/// Pass [existing] to edit; omit it to log a new touch.
Future<JourneyNoteDraft?> showJourneyNoteEditor(
  BuildContext context, {
  JourneyNote? existing,
  String? defaultContactPhone,
}) {
  return showModalBottomSheet<JourneyNoteDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (_) => _JourneyNoteEditor(
      existing: existing,
      defaultContactPhone: defaultContactPhone,
    ),
  );
}

class _JourneyNoteEditor extends ConsumerStatefulWidget {
  const _JourneyNoteEditor({this.existing, this.defaultContactPhone});

  final JourneyNote? existing;
  final String? defaultContactPhone;

  @override
  ConsumerState<_JourneyNoteEditor> createState() => _JourneyNoteEditorState();
}

class _JourneyNoteEditorState extends ConsumerState<_JourneyNoteEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _noteCtrl;
  late final TextEditingController _personCtrl;
  late final TextEditingController _roleCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _nextActionCtrl;

  late DateTime _entryDate;
  DateTime? _nextActionDate;
  late String _entryType;
  String _outcome = '';

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _noteCtrl = TextEditingController(text: existing?.note ?? '');
    _personCtrl = TextEditingController(text: existing?.contactPerson ?? '');
    _roleCtrl = TextEditingController(text: existing?.contactRole ?? '');
    _phoneCtrl = TextEditingController(
      text: existing?.contactPhone ?? widget.defaultContactPhone ?? '',
    );
    _nextActionCtrl = TextEditingController(text: existing?.nextAction ?? '');
    _entryDate =
        JourneyFormat.parse(existing?.entryDate) ?? _todayOnly();
    _nextActionDate = JourneyFormat.parse(existing?.nextActionDate);
    _entryType = (existing?.entryType ?? '').trim().isEmpty
        ? 'Visit'
        : existing!.entryType.trim();
    _outcome = existing?.outcome.trim() ?? '';
  }

  static DateTime _todayOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _personCtrl.dispose();
    _roleCtrl.dispose();
    _phoneCtrl.dispose();
    _nextActionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(journeyOptionsProvider);
    final options = optionsAsync.maybeWhen(
      data: (o) => o,
      orElse: () => const JourneyOptions(
        entryTypes: kFallbackJourneyEntryTypes,
        outcomes: kFallbackJourneyOutcomes,
      ),
    );
    // A record whose type/outcome came from an older option set must still be
    // selectable, or the dropdown would assert on an unknown value.
    final entryTypes = _withCurrent(options.entryTypes, _entryType);
    final outcomes = _withCurrent(options.outcomes, _outcome);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: LeadsTheme.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _isEdit
                      ? context.l10n.journeyEditorEditTitle
                      : context.l10n.journeyEditorNewTitle,
                  style: LeadsTheme.heading,
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.journeyEditorSubtitle,
                  style: LeadsTheme.bodyMuted,
                ),
                const SizedBox(height: 16),

                // ── When + what ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: context.l10n.journeyEditorDate,
                        value: _entryDate,
                        onPick: (picked) => setState(() => _entryDate = picked),
                        // A rep logs today's or a recent visit; a diary entry
                        // dated next month is a next action, not a touch.
                        lastDate: _todayOnly(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _entryType,
                        isExpanded: true,
                        decoration: _dec(context.l10n.journeyEditorType),
                        items: [
                          for (final type in entryTypes)
                            DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(
                                    JourneyFormat.typeIcon(type),
                                    size: 16,
                                    color: LeadsTheme.muted,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      localizedJourneyType(context, type),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _entryType = value ?? 'Visit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _noteCtrl,
                  minLines: 3,
                  maxLines: 8,
                  autofocus: !_isEdit,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _dec(
                    context.l10n.journeyEditorNote,
                    hint: context.l10n.journeyEditorNoteHint,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? context.l10n.leadFormRequired
                          : null,
                ),
                const SizedBox(height: 20),

                // ── Who ──────────────────────────────────────────────────
                _SectionLabel(context.l10n.journeyEditorWhoSpoke),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _personCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: _dec(context.l10n.journeyEditorPerson,
                            hint: context.l10n.journeyEditorPersonHint),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _roleCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: _dec(context.l10n.journeyEditorRole,
                            hint: context.l10n.journeyEditorRoleHint),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _dec(context.l10n.journeyEditorTheirPhone),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _outcome.isEmpty ? null : _outcome,
                  isExpanded: true,
                  decoration: _dec(context.l10n.journeyEditorOutcome),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(context.l10n.pricingDash),
                    ),
                    for (final outcome in outcomes)
                      DropdownMenuItem(
                        value: outcome,
                        child:
                            Text(localizedJourneyOutcome(context, outcome)),
                      ),
                  ],
                  onChanged: (value) => setState(() => _outcome = value ?? ''),
                ),
                const SizedBox(height: 20),

                // ── What next ────────────────────────────────────────────
                _SectionLabel(context.l10n.journeyEditorNextAction),
                const SizedBox(height: 4),
                Text(
                  context.l10n.journeyEditorNextActionHelp,
                  style: LeadsTheme.bodyMuted,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nextActionCtrl,
                  minLines: 1,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _dec(
                    context.l10n.journeyEditorWhatToDo,
                    hint: context.l10n.journeyEditorWhatToDoHint,
                  ),
                ),
                const SizedBox(height: 12),
                _DateField(
                  label: context.l10n.journeyEditorWhen,
                  value: _nextActionDate,
                  hint: context.l10n.journeyEditorNoReminder,
                  firstDate: DateTime(2020),
                  onPick: (picked) => setState(() => _nextActionDate = picked),
                  onClear: _nextActionDate == null
                      ? null
                      : () => setState(() => _nextActionDate = null),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(context.l10n.commonCancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: LeadsTheme.berryPink,
                        ),
                        onPressed: _submit,
                        child: Text(_isEdit
                            ? context.l10n.commonSave
                            : context.l10n.journeyEditorLogIt),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Ensures a value already on the record survives an option list that no
  /// longer offers it.
  List<String> _withCurrent(List<String> options, String current) {
    final value = current.trim();
    if (value.isEmpty || options.contains(value)) return options;
    return [...options, value];
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      JourneyNoteDraft(
        note: _noteCtrl.text.trim(),
        entryDate: JourneyFormat.iso(_entryDate),
        entryType: _entryType,
        contactPerson: _personCtrl.text.trim(),
        contactRole: _roleCtrl.text.trim(),
        contactPhone: _phoneCtrl.text.trim(),
        nextAction: _nextActionCtrl.text.trim(),
        nextActionDate: _nextActionDate == null
            ? ''
            : JourneyFormat.iso(_nextActionDate!),
        outcome: _outcome.trim(),
      ),
    );
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    isDense: true,
    border: const OutlineInputBorder(),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: LeadsTheme.bodyFont,
        color: LeadsTheme.muted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// A tappable date box: shows the picked date, or [hint] when unset. Optional
/// clear affordance for dates that are genuinely optional.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
    this.hint,
    this.onClear,
    this.firstDate,
    this.lastDate,
  });

  final String label;
  final DateTime? value;
  final String? hint;
  final ValueChanged<DateTime> onPick;
  final VoidCallback? onClear;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final display = value == null
        ? (hint ?? context.l10n.journeyEditorPickDate)
        : JourneyFormat.pretty(context, JourneyFormat.iso(value!));
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(now.year, now.month, now.day),
          firstDate: firstDate ?? DateTime(now.year - 2),
          lastDate: lastDate ?? DateTime(now.year + 2),
        );
        if (picked != null) onPick(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
          suffixIcon: onClear == null
              ? const Icon(Icons.event, size: 18)
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  tooltip: context.l10n.journeyEditorClear,
                  onPressed: onClear,
                ),
        ),
        child: Text(
          display,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: value == null ? LeadsTheme.bodyMuted : LeadsTheme.body,
        ),
      ),
    );
  }
}
