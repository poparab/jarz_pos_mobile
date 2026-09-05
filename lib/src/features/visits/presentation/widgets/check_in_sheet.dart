import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../journey/presentation/journey_format.dart';
import '../../data/models/visit_plan.dart';
import '../../state/visit_plan_notifier.dart';

/// Record what happened at a door, without leaving the route.
///
/// The sheet exists because of what a check-in has to be worth: a visit that
/// produces no record has not happened as far as the pipeline is concerned.
/// So the default is to write a real journey note — the same diary entry the
/// lead page, the B2B account screen and the follow-up reminders already read
/// — and the rep can turn that off rather than having to remember to turn it
/// on.
///
/// Errors render INLINE, never as a SnackBar: this sheet covers the bottom of
/// the screen, which is exactly where a SnackBar appears. Same reason the
/// journey note editor does it.
Future<void> showCheckInSheet(
  BuildContext context,
  WidgetRef ref,
  String planName,
  VisitStop stop,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _CheckInSheet(planName: planName, stop: stop),
    ),
  );
}

class _CheckInSheet extends ConsumerStatefulWidget {
  const _CheckInSheet({required this.planName, required this.stop});

  final String planName;
  final VisitStop stop;

  @override
  ConsumerState<_CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends ConsumerState<_CheckInSheet> {
  final _outcome = TextEditingController();
  final _note = TextEditingController();
  final _nextAction = TextEditingController();

  bool _logNote = true;
  DateTime? _nextActionDate;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _outcome.text = widget.stop.outcome;
  }

  @override
  void dispose() {
    _outcome.dispose();
    _note.dispose();
    _nextAction.dispose();
    super.dispose();
  }

  Future<void> _submit(String status) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final notifier = ref.read(visitPlanProvider(widget.planName).notifier);
    await notifier.checkIn(
      stopName: widget.stop.name,
      status: status,
      outcome: _outcome.text.trim(),
      logNote: _logNote && status == 'Visited',
      noteText: _note.text.trim().isEmpty ? null : _note.text.trim(),
      nextAction:
          _nextAction.text.trim().isEmpty ? null : _nextAction.text.trim(),
      nextActionDate:
          _nextActionDate == null ? null : JourneyFormat.iso(_nextActionDate!),
    );

    final error = ref.read(visitPlanProvider(widget.planName)).error;
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.stop.displayTitle, style: theme.textTheme.titleMedium),
            if (widget.stop.address.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  widget.stop.address,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _outcome,
              decoration: InputDecoration(
                labelText: l10n.visitOutcome,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _logNote,
              onChanged: (value) => setState(() => _logNote = value),
              title: Text(l10n.visitLogJourneyNote),
              subtitle: Text(
                l10n.visitLogJourneyNoteHint,
                style: theme.textTheme.bodySmall,
              ),
            ),
            if (_logNote) ...[
              TextField(
                controller: _note,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.visitNoteWhatHappened,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nextAction,
                decoration: InputDecoration(
                  labelText: l10n.visitNextAction,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _nextActionDate ??
                        now.add(const Duration(days: 7)),
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _nextActionDate = picked);
                  }
                },
                icon: const Icon(Icons.event, size: 18),
                label: Text(
                  _nextActionDate == null
                      ? l10n.visitNextActionDate
                      : JourneyFormat.pretty(
                          context, JourneyFormat.iso(_nextActionDate!)),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(context.userErrorMessage(_error!),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy ? null : () => _submit('Skipped'),
                    child: Text(l10n.visitSkip),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : () => _submit('Visited'),
                    icon: _busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: Text(l10n.visitMarkVisited),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
