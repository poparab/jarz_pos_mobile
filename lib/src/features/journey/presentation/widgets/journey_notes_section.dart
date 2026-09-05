import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../leads/presentation/leads_theme.dart';
import '../../data/models/journey_note.dart';
import '../../state/journey_notes_notifier.dart';
import '../journey_format.dart';
import 'journey_note_editor.dart';

/// The rep's dated field diary for one account, as a timeline.
///
/// The SAME widget backs the leads catalog and the B2B pipeline's account
/// screen — the diary is one thing, so a note logged from the board is the note
/// the lead page shows. Pass [referenceDoctype] 'Lead' | 'Opportunity' |
/// 'Customer' and the record's name.
///
/// [onChanged] fires after any successful write so the host screen can refresh
/// whatever ELSE the note moved — a next-action date restamps the account's
/// follow-up, which the surrounding page is already showing.
class JourneyNotesSection extends ConsumerWidget {
  const JourneyNotesSection({
    super.key,
    required this.referenceDoctype,
    required this.referenceName,
    this.defaultContactPhone,
    this.onChanged,
  });

  final String referenceDoctype;
  final String referenceName;

  /// Pre-fills the editor's phone box (the account's own number) so a rep does
  /// not retype it for the common case of "spoke to whoever answered".
  final String? defaultContactPhone;

  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = JourneyRef(doctype: referenceDoctype, name: referenceName);
    final async = ref.watch(journeyNotesProvider(key));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Text(context.l10n.journeySectionTitle,
                    style: LeadsTheme.heading)),
            async.maybeWhen(
              data: (notes) => notes.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${notes.length}',
                        style: LeadsTheme.bodyMuted,
                      ),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
            TextButton.icon(
              onPressed: () => _add(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: Text(context.l10n.journeyLogVisit),
              style: TextButton.styleFrom(
                foregroundColor: LeadsTheme.berryPink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (err, _) => _ErrorCard(
            error: err,
            onRetry: () => ref.read(journeyNotesProvider(key).notifier).refresh(),
          ),
          data: (notes) => notes.isEmpty
              ? const _EmptyCard()
              : Column(
                  children: [
                    for (var i = 0; i < notes.length; i++)
                      _JourneyTile(
                        note: notes[i],
                        isLast: i == notes.length - 1,
                        onEdit: () => _edit(context, ref, notes[i]),
                        onDelete: () => _delete(context, ref, notes[i]),
                        onToggleDone: (done) =>
                            _toggleDone(context, ref, notes[i], done),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  JourneyRef get _key =>
      JourneyRef(doctype: referenceDoctype, name: referenceName);

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final draft = await showJourneyNoteEditor(
      context,
      defaultContactPhone: defaultContactPhone,
      reference: _key,
    );
    if (draft == null || !context.mounted) return;
    await _run(context, ref, () async {
      await ref.read(journeyNotesProvider(_key).notifier).add(
        note: draft.note,
        entryDate: draft.entryDate,
        entryType: draft.entryType,
        contactPerson: draft.contactPerson,
        contactRole: draft.contactRole,
        contactPhone: draft.contactPhone,
        nextAction: draft.nextAction,
        nextActionDate: draft.nextActionDate,
        outcome: draft.outcome,
      );
    }, success: context.l10n.journeyNoteAdded);
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    JourneyNote note,
  ) async {
    final draft =
        await showJourneyNoteEditor(context, existing: note, reference: _key);
    if (draft == null || !context.mounted) return;
    await _run(context, ref, () async {
      await ref.read(journeyNotesProvider(_key).notifier).edit(
        name: note.name,
        note: draft.note,
        entryDate: draft.entryDate,
        entryType: draft.entryType,
        contactPerson: draft.contactPerson,
        contactRole: draft.contactRole,
        contactPhone: draft.contactPhone,
        nextAction: draft.nextAction,
        nextActionDate: draft.nextActionDate,
        outcome: draft.outcome,
      );
    }, success: context.l10n.journeyNoteUpdated);
  }

  /// Closes (or reopens) the promise on one note.
  ///
  /// Goes through the same [_run] path as every other write so a rejected
  /// toggle — the server is the only judge of who may complete an action —
  /// reads as a SnackBar rather than a silently unchanged checkbox.
  Future<void> _toggleDone(
    BuildContext context,
    WidgetRef ref,
    JourneyNote note,
    bool done,
  ) async {
    final l10n = context.l10n;
    await _run(
      context,
      ref,
      () => ref
          .read(journeyNotesProvider(_key).notifier)
          .setActionDone(name: note.name, done: done),
      success: done ? l10n.journeyActionMarkedDone : l10n.journeyActionReopened,
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    JourneyNote note,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.journeyDeleteTitle),
        content: Text(context.l10n.journeyDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: LeadsTheme.rejected),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _run(
      context,
      ref,
      () => ref.read(journeyNotesProvider(_key).notifier).remove(note.name),
      success: context.l10n.journeyNoteDeleted,
    );
  }

  /// Runs a write, reports the outcome, and tells the host screen to refresh.
  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action, {
    required String success,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(success)));
      onChanged?.call();
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text(userErrorMessageFor(l10n, e))));
    }
  }
}

/// One entry in the timeline: the date rail, then the touch itself.
class _JourneyTile extends StatelessWidget {
  const _JourneyTile({
    required this.note,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDone,
  });

  final JourneyNote note;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<void> Function(bool done) onToggleDone;

  @override
  Widget build(BuildContext context) {
    final relative = JourneyFormat.relativePast(context, note.entryDate);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail: a dot per touch, joined by a line except at the end.
          Column(
            children: [
              const SizedBox(height: 18),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: LeadsTheme.berryPink,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                const Expanded(
                  child: VerticalDivider(
                    width: 10,
                    thickness: 1,
                    color: LeadsTheme.line,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LeadsTheme.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        JourneyFormat.typeIcon(note.entryType),
                        size: 16,
                        color: LeadsTheme.deepPlum,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              JourneyFormat.pretty(context, note.entryDate),
                              style: const TextStyle(
                                fontFamily: LeadsTheme.bodyFont,
                                color: LeadsTheme.deepPlum,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFeatures: LeadsTheme.tabular,
                              ),
                            ),
                            if (relative.isNotEmpty)
                              Text(relative, style: LeadsTheme.bodyMuted),
                            if (note.entryType.trim().isNotEmpty)
                              _Chip(
                                label:
                                    localizedJourneyType(context, note.entryType),
                                bg: const Color(0xFFEDECEA),
                                fg: LeadsTheme.muted,
                              ),
                            if (note.outcome.trim().isNotEmpty)
                              _outcomeChip(context, note.outcome),
                          ],
                        ),
                      ),
                      if (note.canEdit)
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.more_vert,
                              size: 18,
                              color: LeadsTheme.muted,
                            ),
                            onSelected: (value) {
                              if (value == 'edit') onEdit();
                              if (value == 'delete') onDelete();
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                  value: 'edit',
                                  child: Text(context.l10n.journeyEdit)),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(context.l10n.commonDelete),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (note.contactLabel.isNotEmpty ||
                      note.contactPhone.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: LeadsTheme.muted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [
                              if (note.contactLabel.isNotEmpty)
                                note.contactLabel,
                              if (note.contactPhone.trim().isNotEmpty)
                                note.contactPhone.trim(),
                            ].join(' · '),
                            style: LeadsTheme.bodyMuted,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    note.note,
                    style: TextStyle(
                      fontFamily: LeadsTheme.fontFamilyFor(note.note),
                      color: LeadsTheme.deepPlum,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                  if (note.hasNextAction) ...[
                    const SizedBox(height: 10),
                    _NextActionRow(note: note, onToggleDone: onToggleDone),
                  ],
                  if (note.loggedByName.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.journeyLoggedBy(note.loggedByName),
                      style: const TextStyle(
                        fontFamily: LeadsTheme.bodyFont,
                        color: LeadsTheme.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outcomeChip(BuildContext context, String outcome) {
    final colors = JourneyFormat.outcomeColors(outcome);
    return _Chip(
      label: localizedJourneyOutcome(context, outcome),
      bg: colors.bg,
      fg: colors.fg,
    );
  }
}

/// The promise: what to do, when, and whether it was kept.
///
/// Tinted while it is due or overdue, because that is the whole reason a rep
/// writes it down — and deliberately UNtinted once it is done, so a closed
/// promise stops shouting. Only the server decides who may close one
/// ([JourneyNote.canComplete]); without that right the row still shows the
/// state, just with no control to change it.
class _NextActionRow extends StatefulWidget {
  const _NextActionRow({required this.note, required this.onToggleDone});

  final JourneyNote note;
  final Future<void> Function(bool done) onToggleDone;

  @override
  State<_NextActionRow> createState() => _NextActionRowState();
}

class _NextActionRowState extends State<_NextActionRow> {
  /// Guards the round-trip: the list reloads on success, so a second tap
  /// before it lands would toggle against a value the server already changed.
  bool _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onToggleDone(!widget.note.nextActionDone);
    } finally {
      // The tile is rebuilt from the reloaded list, but a failed write leaves
      // this same State mounted — so the spinner has to be cleared either way.
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final l10n = context.l10n;
    final done = note.nextActionDone;
    final due = !done && JourneyFormat.isDue(note.nextActionDate);
    final hasDate = (note.nextActionDate ?? '').isNotEmpty;

    final bg = due ? const Color(0xFFFDF2E3) : const Color(0xFFF6F5F3);
    final fg = due ? const Color(0xFF9A6B12) : LeadsTheme.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done
                ? Icons.check_circle
                : due
                    ? Icons.notifications_active_outlined
                    : Icons.event_outlined,
            size: 15,
            color: done ? JourneyFormat.doneGreen : fg,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasDate)
                  Text(
                    // A settled promise shows its due date plainly; an open one
                    // also shows how late it is, which is the actionable half.
                    done
                        ? JourneyFormat.pretty(context, note.nextActionDate)
                        : '${JourneyFormat.pretty(context, note.nextActionDate)}'
                            ' · ${JourneyFormat.relativeFuture(context, note.nextActionDate)}',
                    style: TextStyle(
                      fontFamily: LeadsTheme.bodyFont,
                      color: done ? LeadsTheme.muted : fg,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFeatures: LeadsTheme.tabular,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                if (note.nextAction.trim().isNotEmpty)
                  Text(
                    note.nextAction.trim(),
                    style: TextStyle(
                      fontFamily: LeadsTheme.fontFamilyFor(note.nextAction),
                      color: done ? LeadsTheme.muted : LeadsTheme.deepPlum,
                      fontSize: 13,
                      height: 1.3,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                if (done) ...[
                  const SizedBox(height: 4),
                  Text(
                    _doneLabel(context, note),
                    style: const TextStyle(
                      fontFamily: LeadsTheme.bodyFont,
                      color: JourneyFormat.doneGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (note.canComplete)
            IconButton(
              onPressed: _toggle,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: done ? l10n.journeyMarkNotDone : l10n.journeyMarkDone,
              icon: Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20,
                color: done ? JourneyFormat.doneGreen : fg,
              ),
            ),
        ],
      ),
    );
  }

  /// "Done 14 Aug 2026 · Sales Rep", degrading to whatever the payload has.
  String _doneLabel(BuildContext context, JourneyNote note) {
    final l10n = context.l10n;
    final on = (note.nextActionDoneOn ?? '').trim();
    final by = note.nextActionDoneByName.trim();
    if (on.isEmpty) return l10n.journeyDoneLabel;
    final date = JourneyFormat.pretty(context, on);
    return by.isEmpty
        ? l10n.journeyDoneOn(date)
        : l10n.journeyDoneByOn(date, by);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: LeadsTheme.bodyFont,
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LeadsTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.journeyEmptyTitle, style: LeadsTheme.body),
          const SizedBox(height: 4),
          Text(
            context.l10n.journeyEmptyBody,
            style: LeadsTheme.bodyMuted,
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LeadsTheme.rejectedBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LeadsTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.journeyLoadFailed, style: LeadsTheme.body),
          const SizedBox(height: 4),
          Text(context.userErrorMessage(error), style: LeadsTheme.bodyMuted),
          const SizedBox(height: 8),
          OutlinedButton(
              onPressed: onRetry, child: Text(context.l10n.commonRetry)),
        ],
      ),
    );
  }
}
