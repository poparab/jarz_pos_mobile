import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            const Expanded(child: Text('Journey', style: LeadsTheme.heading)),
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
              label: const Text('Log visit'),
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
    }, success: 'Journey note added');
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    JourneyNote note,
  ) async {
    final draft = await showJourneyNoteEditor(context, existing: note);
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
    }, success: 'Journey note updated');
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    JourneyNote note,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this note?'),
        content: const Text(
          'The visit record is removed for everyone. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: LeadsTheme.rejected),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _run(
      context,
      ref,
      () => ref.read(journeyNotesProvider(_key).notifier).remove(note.name),
      success: 'Journey note deleted',
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
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(success)));
      onChanged?.call();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
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
  });

  final JourneyNote note;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final relative = JourneyFormat.relativePast(note.entryDate);
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
                              JourneyFormat.pretty(note.entryDate),
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
                                label: note.entryType,
                                bg: const Color(0xFFEDECEA),
                                fg: LeadsTheme.muted,
                              ),
                            if (note.outcome.trim().isNotEmpty)
                              _outcomeChip(note.outcome),
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
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
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
                    _NextActionRow(note: note),
                  ],
                  if (note.loggedByName.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Logged by ${note.loggedByName}',
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

  Widget _outcomeChip(String outcome) {
    final colors = JourneyFormat.outcomeColors(outcome);
    return _Chip(label: outcome, bg: colors.bg, fg: colors.fg);
  }
}

/// The promise: what to do, when. Tinted when it is due or overdue, because
/// that is the whole reason a rep writes it down.
class _NextActionRow extends StatelessWidget {
  const _NextActionRow({required this.note});

  final JourneyNote note;

  @override
  Widget build(BuildContext context) {
    final due = JourneyFormat.isDue(note.nextActionDate);
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
            due ? Icons.notifications_active_outlined : Icons.event_outlined,
            size: 15,
            color: fg,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasDate)
                  Text(
                    '${JourneyFormat.pretty(note.nextActionDate)}'
                    ' · ${JourneyFormat.relativeFuture(note.nextActionDate)}',
                    style: TextStyle(
                      fontFamily: LeadsTheme.bodyFont,
                      color: fg,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFeatures: LeadsTheme.tabular,
                    ),
                  ),
                if (note.nextAction.trim().isNotEmpty)
                  Text(
                    note.nextAction.trim(),
                    style: TextStyle(
                      fontFamily: LeadsTheme.fontFamilyFor(note.nextAction),
                      color: LeadsTheme.deepPlum,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No visits logged yet.', style: LeadsTheme.body),
          SizedBox(height: 4),
          Text(
            'Log what was said, who said it, and when to follow up — '
            'a dated next action also sets this account\'s reminder.',
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
          const Text('Could not load the journey.', style: LeadsTheme.body),
          const SizedBox(height: 4),
          Text('$error', style: LeadsTheme.bodyMuted),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
