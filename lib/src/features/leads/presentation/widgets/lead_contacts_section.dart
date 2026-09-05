import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/device_contact_picker.dart';
import '../../data/models/lead.dart';
import '../leads_theme.dart';
import 'lead_actions.dart';

/// The people at a lead: owner, manager, shift manager, barista, whoever the
/// rep actually met.
///
/// A lead is a business, not a person. Whoever is on shift when a rep walks in
/// is rarely whoever signs the order, so the record holds every contact side by
/// side, each with the title the venue itself uses, and one tap on any of them
/// dials the phone.
///
/// Edits are wholesale: the sheet mutates a local copy of the list and the
/// whole list is sent to `save_lead_contacts`, which is the same shape the
/// backend stores (a child table), so there is no per-row id to track.
class LeadContactsSection extends ConsumerStatefulWidget {
  const LeadContactsSection({
    super.key,
    required this.contacts,
    required this.onSave,
  });

  final List<LeadContact> contacts;

  /// Persists the full replacement list. Throws on failure so this widget can
  /// report it; the caller owns the request and the refresh.
  final Future<void> Function(List<LeadContact> contacts) onSave;

  @override
  ConsumerState<LeadContactsSection> createState() =>
      _LeadContactsSectionState();
}

class _LeadContactsSectionState extends ConsumerState<LeadContactsSection> {
  bool _saving = false;

  Future<void> _commit(List<LeadContact> next) async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await widget.onSave(next);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.leadContactsSaved)),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(context.userErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addOrEdit({LeadContact? existing, int? index}) async {
    final edited = await showModalBottomSheet<LeadContact>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LeadContactEditorSheet(contact: existing),
    );
    if (edited == null) return;

    final next = [...widget.contacts];
    if (index == null) {
      // The very first person recorded becomes the primary by default; the
      // backend would do this anyway, doing it here keeps the UI honest before
      // the round trip.
      next.add(next.isEmpty ? edited.copyWith(isPrimary: true) : edited);
    } else {
      next[index] = edited;
    }
    await _commit(_withSinglePrimary(next, preferred: index ?? next.length - 1));
  }

  Future<void> _makePrimary(int index) async {
    await _commit(_withSinglePrimary(
      [
        for (var i = 0; i < widget.contacts.length; i++)
          widget.contacts[i].copyWith(isPrimary: i == index),
      ],
      preferred: index,
    ));
  }

  Future<void> _remove(int index) async {
    final contact = widget.contacts[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.leadContactsRemoveTitle),
        content: Text(ctx.l10n.leadContactsRemoveBody(contact.displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(ctx.l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final next = [...widget.contacts]..removeAt(index);
    await _commit(_withSinglePrimary(next, preferred: 0));
  }

  /// Exactly one contact stays primary. [preferred] is the row that just
  /// changed, so an explicit "make primary" always wins over the old flag.
  static List<LeadContact> _withSinglePrimary(
    List<LeadContact> rows, {
    required int preferred,
  }) {
    if (rows.isEmpty) return rows;
    var primary = preferred >= 0 && preferred < rows.length && rows[preferred].isPrimary
        ? preferred
        : rows.indexWhere((c) => c.isPrimary);
    if (primary < 0) primary = 0;
    return [
      for (var i = 0; i < rows.length; i++)
        rows[i].copyWith(isPrimary: i == primary),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final contacts = widget.contacts;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LeadsTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  contacts.isEmpty
                      ? l10n.leadContactsTitle
                      : l10n.leadContactsTitleCount(contacts.length),
                  style: LeadsTheme.heading.copyWith(fontSize: 16),
                ),
              ),
              if (_saving)
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (contacts.isEmpty)
            Text(l10n.leadContactsEmpty, style: LeadsTheme.bodyMuted)
          else
            for (var i = 0; i < contacts.length; i++)
              _ContactTile(
                contact: contacts[i],
                enabled: !_saving,
                onCall: () => LeadActions.call(contacts[i].phone),
                onEdit: () => _addOrEdit(existing: contacts[i], index: i),
                onMakePrimary:
                    contacts[i].isPrimary ? null : () => _makePrimary(i),
                onRemove: () => _remove(i),
              ),
          const SizedBox(height: 4),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: _saving ? null : () => _addOrEdit(),
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: Text(l10n.leadContactsAdd),
            ),
          ),
        ],
      ),
    );
  }
}

/// One person: initial, name, role, number, and a call button that is the
/// whole point of the row.
class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.enabled,
    required this.onCall,
    required this.onEdit,
    required this.onMakePrimary,
    required this.onRemove,
  });

  final LeadContact contact;
  final bool enabled;
  final VoidCallback onCall;
  final VoidCallback onEdit;
  final VoidCallback? onMakePrimary;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = contact.displayName;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: contact.isPrimary
                ? LeadsTheme.blush
                : const Color(0xFFEDECEA),
            child: Text(
              initial,
              style: LeadsTheme.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: LeadsTheme.nameStyle(name, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (contact.isPrimary) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.star_rounded,
                          size: 15, color: LeadsTheme.gold),
                    ],
                  ],
                ),
                if (contact.role.trim().isNotEmpty)
                  Text(contact.role.trim(), style: LeadsTheme.bodyMuted),
                if (contact.phone.trim().isNotEmpty)
                  Text(
                    contact.phone.trim(),
                    style: LeadsTheme.number.copyWith(
                      fontSize: 13,
                      color: LeadsTheme.muted,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.leadActionCall,
            onPressed: enabled && contact.canCall ? onCall : null,
            icon: const Icon(Icons.call),
            color: LeadsTheme.deepPlum,
          ),
          PopupMenuButton<String>(
            enabled: enabled,
            icon: const Icon(Icons.more_vert, color: LeadsTheme.muted),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit();
                case 'primary':
                  onMakePrimary?.call();
                case 'remove':
                  onRemove();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'edit', child: Text(ctx.l10n.leadContactsEdit)),
              if (onMakePrimary != null)
                PopupMenuItem(
                  value: 'primary',
                  child: Text(ctx.l10n.leadContactsMakePrimary),
                ),
              PopupMenuItem(
                value: 'remove',
                child: Text(ctx.l10n.leadContactsRemove),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Add/edit sheet for one person. Pops the edited [LeadContact], or null when
/// the rep backs out.
class LeadContactEditorSheet extends StatefulWidget {
  const LeadContactEditorSheet({super.key, this.contact});

  final LeadContact? contact;

  @override
  State<LeadContactEditorSheet> createState() => _LeadContactEditorSheetState();
}

class _LeadContactEditorSheetState extends State<LeadContactEditorSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.contact?.contactName ?? '');
  late final TextEditingController _role =
      TextEditingController(text: widget.contact?.role ?? '');
  late final TextEditingController _phone =
      TextEditingController(text: widget.contact?.phone ?? '');
  late final TextEditingController _email =
      TextEditingController(text: widget.contact?.email ?? '');
  late final TextEditingController _notes =
      TextEditingController(text: widget.contact?.notes ?? '');
  late bool _primary = widget.contact?.isPrimary ?? false;
  bool _picking = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _phone.dispose();
    _email.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _importFromPhone() async {
    setState(() => _picking = true);
    final picked = await const DeviceContactPicker().pickOne();
    if (!mounted) return;
    setState(() {
      _picking = false;
      if (picked != null) {
        if (picked.fullName.isNotEmpty) _name.text = picked.fullName;
        if (picked.phone.isNotEmpty) _phone.text = picked.phone;
        _error = null;
      }
    });
  }

  void _submit() {
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    if (name.isEmpty && phone.isEmpty) {
      setState(() => _error = context.l10n.leadContactsNeedNameOrPhone);
      return;
    }
    Navigator.of(context).pop(
      LeadContact(
        contactName: name,
        role: _role.text.trim(),
        phone: phone,
        email: _email.text.trim(),
        isPrimary: _primary,
        notes: _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final roleSuggestions = <String>[
      l10n.leadContactRoleOwner,
      l10n.leadContactRoleManager,
      l10n.leadContactRoleShiftManager,
      l10n.leadContactRoleBarista,
      l10n.leadContactRolePurchasing,
      l10n.leadContactRoleAccountant,
    ];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        // Bounded so the fields scroll INSIDE the sheet and the Save row below
        // stays pinned. A sheet that grows past the screen puts Save out of
        // reach the moment the keyboard opens on a small phone.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contact == null
                      ? l10n.leadContactsAdd
                      : l10n.leadContactsEdit,
                  style: LeadsTheme.heading.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                // Only offered where the OS actually has a picker. The picker
                // runs out of process, so this reads exactly one contact and
                // needs no contacts permission.
                if (DeviceContactPicker.isSupported)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: OutlinedButton.icon(
                      onPressed: _picking ? null : _importFromPhone,
                      icon: _picking
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.contacts_outlined, size: 18),
                      label: Text(l10n.leadContactsPickFromPhone),
                    ),
                  ),
                const SizedBox(height: 8),
                _field(_name, l10n.leadContactsName,
                    textCapitalization: TextCapitalization.words),
                _field(_role, l10n.leadContactsRole,
                    hint: l10n.leadContactsRoleHint,
                    textCapitalization: TextCapitalization.words),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final role in roleSuggestions)
                      ActionChip(
                        label: Text(role, style: LeadsTheme.bodyMuted),
                        onPressed: () => setState(() => _role.text = role),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _field(
                  _phone,
                  l10n.leadContactsPhone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                  ],
                ),
                _field(_email, l10n.leadContactsEmail,
                    keyboardType: TextInputType.emailAddress),
                _field(_notes, l10n.leadContactsNotes, maxLines: 2),
                // The card above paints its own white background, and a
                // ListTile paints its tap ink on the nearest Material - which
                // was the Scaffold, underneath that white box, so the splash
                // was never visible. Flutter 3.41+ asserts on exactly this. A
                // transparent Material here gives the tile a surface of its
                // own without changing what the card looks like.
                Material(
                  type: MaterialType.transparency,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _primary,
                    onChanged: (v) => setState(() => _primary = v),
                    title: Text(l10n.leadContactsPrimary, style: LeadsTheme.body),
                    subtitle: Text(
                      l10n.leadContactsPrimaryHint,
                      style: LeadsTheme.bodyMuted,
                    ),
                  ),
                ),
                        if (_error != null) ...[
                          const SizedBox(height: 4),
                          // _error only ever holds this section's own localised
                          // validation text (see _submit); it is already user copy.
                          Text(_error!,
                            style: LeadsTheme.body
                                .copyWith(color: LeadsTheme.rejected),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.commonCancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _submit,
                      child: Text(l10n.commonSave),
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

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
