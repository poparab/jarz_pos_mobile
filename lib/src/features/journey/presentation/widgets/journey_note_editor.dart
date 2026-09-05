import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../leads/data/models/lead.dart';
import '../../../leads/presentation/leads_theme.dart';
import '../../../leads/presentation/widgets/lead_contacts_section.dart';
import '../../data/journey_repository.dart';
import '../../data/models/journey_note.dart';
import '../../state/journey_notes_notifier.dart';
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
/// Pass [existing] to edit; omit it to log a new touch. Pass [reference] to
/// give the WHO box the account's people to pick from — without it the editor
/// still works, it just falls back to typing the name in by hand.
Future<JourneyNoteDraft?> showJourneyNoteEditor(
  BuildContext context, {
  JourneyNote? existing,
  String? defaultContactPhone,
  JourneyRef? reference,
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
      reference: reference,
    ),
  );
}

class _JourneyNoteEditor extends ConsumerStatefulWidget {
  const _JourneyNoteEditor({
    this.existing,
    this.defaultContactPhone,
    this.reference,
  });

  final JourneyNote? existing;
  final String? defaultContactPhone;

  /// The record this note hangs off, used to load (and add to) its people.
  final JourneyRef? reference;

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

  /// The person picked from the account's roster, when one was picked. Null
  /// means the boxes were typed by hand — which stays a valid way to log a
  /// note, so the chips never gate the form.
  LeadContact? _selectedContact;
  bool _savingContact = false;
  String? _contactError;

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
                _buildContactPicker(context),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _personCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: _dec(context.l10n.journeyEditorPerson,
                            hint: context.l10n.journeyEditorPersonHint),
                        // Typing over a picked person drops the selection: the
                        // chip must never claim a name the rep has edited away.
                        onChanged: (_) {
                          if (_selectedContact != null) {
                            setState(() => _selectedContact = null);
                          }
                        },
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

  /// The account's people as tappable chips, plus a "new person" chip that
  /// records someone on the spot.
  ///
  /// Renders nothing at all when there is no roster to offer AND nothing can
  /// be added (an Opportunity or Customer with no lead behind it, or a site
  /// that has not migrated the contacts table): the free-text boxes below are
  /// then the whole WHO section, exactly as before this picker existed.
  Widget _buildContactPicker(BuildContext context) {
    final reference = widget.reference;
    if (reference == null) return const SizedBox.shrink();

    final async = ref.watch(journeyContactsProvider(reference));
    if (async.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    final payload = async.maybeWhen(
      data: (value) => value,
      orElse: () => const JourneyContacts(),
    );
    if (payload.contacts.isEmpty && !payload.canAdd) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.journeyEditorWhoHint, style: LeadsTheme.bodyMuted),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final contact in payload.contacts)
              ChoiceChip(
                label: Text(_contactLabel(contact)),
                selected: _isSelected(contact),
                selectedColor: LeadsTheme.berryPink.withValues(alpha: 0.16),
                onSelected: (_) => _selectContact(contact),
              ),
            if (payload.canAdd)
              ActionChip(
                avatar: _savingContact
                    ? const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_alt, size: 16),
                label: Text(context.l10n.journeyEditorNewPerson),
                onPressed: _savingContact ? null : _addContact,
              ),
          ],
        ),
        if (_contactError != null) ...[
          const SizedBox(height: 6),
          Text(
            _contactError!,
            style: const TextStyle(
              fontFamily: LeadsTheme.bodyFont,
              color: LeadsTheme.rejected,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  String _contactLabel(LeadContact contact) {
    final role = contact.role.trim();
    final name = contact.displayName;
    return role.isEmpty ? name : '$name · $role';
  }

  /// Selected when the rep just tapped it, or — on an existing note — when the
  /// name already written on the note is this person's.
  bool _isSelected(LeadContact contact) {
    final picked = _selectedContact;
    if (picked != null) return picked == contact;
    final typed = _personCtrl.text.trim().toLowerCase();
    return typed.isNotEmpty && contact.displayName.toLowerCase() == typed;
  }

  /// Copies a picked person into the three boxes. The phone is overwritten
  /// even when that person has none: the note records who was actually spoken
  /// to, so leaving the venue's main line attributed to them would be a lie.
  void _selectContact(LeadContact contact) {
    setState(() {
      _selectedContact = contact;
      _contactError = null;
      _personCtrl.text = contact.displayName;
      _roleCtrl.text = contact.role.trim();
      _phoneCtrl.text = contact.phone.trim();
    });
  }

  /// Records a new person on the account through the SAME sheet the lead page
  /// uses (so the OS contact picker comes along), then selects them.
  Future<void> _addContact() async {
    final reference = widget.reference;
    if (reference == null) return;

    final draft = await showModalBottomSheet<LeadContact>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LeadContactEditorSheet(),
    );
    if (draft == null || !mounted) return;

    setState(() {
      _savingContact = true;
      _contactError = null;
    });
    // Failures land inline, not in a SnackBar: this sheet covers the bottom of
    // the screen, which is exactly where a SnackBar would appear.
    try {
      final saved = await ref
          .read(journeyContactsProvider(reference).notifier)
          .addContact(draft);
      if (!mounted) return;
      _selectContact(saved ?? draft);
    } catch (e) {
      if (!mounted) return;
      setState(() => _contactError = context.userErrorMessage(e));
    } finally {
      if (mounted) setState(() => _savingContact = false);
    }
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
