import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/chat_repository.dart';
import '../../data/models/chat_models.dart';
import '../chat_labels.dart';

/// The planted-draft (training check) outcome of a `send_draft`, or null
/// when the draft was a normal one.
enum ChatPlantedOutcome {
  /// Sent as-is: blocked, nothing reached the customer.
  notSent,

  /// Edited and the edit removed the mistake.
  caught,

  /// Edited but the mistake went out: the moderator must correct it.
  missed,
}

ChatPlantedOutcome? chatPlantedOutcome(ChatSendDraftResult result) {
  if (!result.planted) return null;
  if (!result.wasSent) return ChatPlantedOutcome.notSent;
  return result.caught ? ChatPlantedOutcome.caught : ChatPlantedOutcome.missed;
}

/// The dialog text for a training-check outcome. [plantedError] is what was
/// changed ("price 120→150"); the wording drops it when the server did not
/// send it.
String chatPlantedMessage(
  AppLocalizations l10n,
  ChatPlantedOutcome outcome,
  String? plantedError,
) {
  final error = plantedError?.trim() ?? '';
  return switch (outcome) {
    ChatPlantedOutcome.notSent => error.isEmpty
        ? l10n.chatPlantedNotSentNoDetail
        : l10n.chatPlantedNotSent(error),
    ChatPlantedOutcome.caught => error.isEmpty
        ? l10n.chatPlantedCaughtNoDetail
        : l10n.chatPlantedCaught(error),
    ChatPlantedOutcome.missed => error.isEmpty
        ? l10n.chatPlantedMissedNoDetail
        : l10n.chatPlantedMissed(error),
  };
}

Future<void> showChatPlantedDialog(
  BuildContext context, {
  required ChatPlantedOutcome outcome,
  String? plantedError,
  bool realDraftReady = false,
}) {
  final l10n = context.l10n;
  final theme = Theme.of(context);
  final icon = switch (outcome) {
    ChatPlantedOutcome.caught => Icons.verified_outlined,
    ChatPlantedOutcome.notSent => Icons.school_outlined,
    ChatPlantedOutcome.missed => Icons.report_gmailerrorred,
  };
  final color = switch (outcome) {
    ChatPlantedOutcome.caught => Colors.green.shade700,
    ChatPlantedOutcome.notSent => theme.colorScheme.primary,
    ChatPlantedOutcome.missed => theme.colorScheme.error,
  };
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      key: const ValueKey('chat-planted-dialog'),
      icon: Icon(icon, color: color),
      title: Text(l10n.chatPlantedTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(chatPlantedMessage(l10n, outcome, plantedError)),
          if (realDraftReady) ...[
            const SizedBox(height: 12),
            Text(
              l10n.chatPlantedRealDraftReady,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonOk),
        ),
      ],
    ),
  );
}

/// Asks why a draft is rejected. Returns the `reason` to send, or null when
/// cancelled.
Future<String?> showChatRejectSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _RejectSheet(),
  );
}

class _RejectSheet extends StatefulWidget {
  const _RejectSheet();

  @override
  State<_RejectSheet> createState() => _RejectSheetState();
}

class _RejectSheetState extends State<_RejectSheet> {
  ChatRejectReason? _reason;
  final _note = TextEditingController();
  bool _showErrors = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _noteRequired => _reason == ChatRejectReason.other;

  void _submit() {
    final reason = _reason;
    if (reason == null || (_noteRequired && _note.text.trim().isEmpty)) {
      setState(() => _showErrors = true);
      return;
    }
    Navigator.of(context).pop(chatRejectReasonText(reason, _note.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.chatRejectTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final reason in ChatRejectReason.values)
                  ChoiceChip(
                    key: ValueKey('chat-reject-${reason.name}'),
                    label: Text(reason.label(l10n)),
                    selected: _reason == reason,
                    onSelected: (_) => setState(() => _reason = reason),
                  ),
              ],
            ),
            if (_showErrors && _reason == null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.chatRejectChooseReason,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('chat-reject-note'),
              controller: _note,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.chatRejectNoteHint,
                border: const OutlineInputBorder(),
                errorText:
                    _showErrors && _noteRequired && _note.text.trim().isEmpty
                        ? l10n.chatRejectNoteRequired
                        : null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: const ValueKey('chat-reject-confirm'),
                  onPressed: _submit,
                  child: Text(l10n.chatRejectConfirm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Optional instruction for `regenerate_draft`. Returns the hint (possibly
/// empty) or null when cancelled.
Future<String?> showChatRegenerateDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _RegenerateDialog(),
  );
}

class _RegenerateDialog extends StatefulWidget {
  const _RegenerateDialog();

  @override
  State<_RegenerateDialog> createState() => _RegenerateDialogState();
}

class _RegenerateDialogState extends State<_RegenerateDialog> {
  final _hint = TextEditingController();

  @override
  void dispose() {
    _hint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.chatRegenerateTitle),
      content: TextField(
        key: const ValueKey('chat-regenerate-hint'),
        controller: _hint,
        autofocus: true,
        minLines: 1,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: l10n.chatRegenerateHintLabel,
          hintText: l10n.chatRegenerateHintExample,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const ValueKey('chat-regenerate-confirm'),
          onPressed: () => Navigator.of(context).pop(_hint.text.trim()),
          child: Text(l10n.chatDraftRegenerate),
        ),
      ],
    );
  }
}

/// Searches customers (name or phone) and returns the one picked, or null.
/// [initialQuery] is usually the chat's phone number.
Future<ChatCustomerOption?> showChatLinkCustomerSheet(
  BuildContext context, {
  String? initialQuery,
}) {
  return showModalBottomSheet<ChatCustomerOption>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _LinkCustomerSheet(initialQuery: initialQuery),
  );
}

class _LinkCustomerSheet extends ConsumerStatefulWidget {
  const _LinkCustomerSheet({this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<_LinkCustomerSheet> createState() => _LinkCustomerSheetState();
}

class _LinkCustomerSheetState extends ConsumerState<_LinkCustomerSheet> {
  late final TextEditingController _query;
  Timer? _debounce;
  List<ChatCustomerOption> _results = const [];
  bool _loading = false;
  Object? _error;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    _query = TextEditingController(text: widget.initialQuery ?? '');
    if (_query.text.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _search);
  }

  Future<void> _search() async {
    final text = _query.text.trim();
    final seq = ++_seq;
    if (text.length < 2) {
      setState(() {
        _results = const [];
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results =
          await ref.read(chatRepositoryProvider).searchCustomers(text);
      if (!mounted || seq != _seq) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || seq != _seq) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.chatActionLinkCustomer, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('chat-link-search'),
              controller: _query,
              autofocus: true,
              onChanged: _onChanged,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: l10n.chatLinkSearchHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  context.userErrorMessage(
                    _error,
                    fallback: l10n.chatLinkSearchFailed,
                  ),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            if (!_loading &&
                _error == null &&
                _results.isEmpty &&
                _query.text.trim().length >= 2)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(l10n.chatLinkNoResults),
              ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final option = _results[index];
                  return ListTile(
                    key: ValueKey('chat-link-option-${option.name}'),
                    leading: const Icon(Icons.person_outline),
                    title: Text(option.customerName),
                    subtitle: Text(
                      [
                        if (option.mobileNo != null) option.mobileNo!,
                        if (option.customerName != option.name) option.name,
                      ].join(' · '),
                    ),
                    onTap: () => Navigator.of(context).pop(option),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The linked customer at a glance, or a prompt to link one.
Future<void> showChatCustomerCardSheet(
  BuildContext context, {
  required ChatCustomerCard? customer,
  required VoidCallback onLink,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      final theme = Theme.of(sheetContext);
      if (customer == null) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.chatCustomerNotLinked),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  onLink();
                },
                icon: const Icon(Icons.link),
                label: Text(l10n.chatActionLinkCustomer),
              ),
            ],
          ),
        );
      }
      final lastOrderDate = chatParseDateTime(customer.lastOrderDate);
      Widget row(String label, String value) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(label, style: theme.textTheme.bodySmall),
                ),
                Expanded(child: Text(value)),
              ],
            ),
          );
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            key: const ValueKey('chat-customer-card'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(customer.customerName, style: theme.textTheme.titleMedium),
              if (customer.customerName != customer.name)
                Text(customer.name, style: theme.textTheme.bodySmall),
              const Divider(height: 20),
              if (customer.mobileNo != null)
                row(l10n.chatCustomerPhone, customer.mobileNo!),
              if (customer.territory != null)
                row(l10n.chatCustomerTerritory, customer.territory!),
              row(
                l10n.chatCustomerTotalOrders,
                formatCount(sheetContext, customer.totalOrders),
              ),
              if (lastOrderDate != null || customer.lastOrderTotal != null)
                row(
                  l10n.chatCustomerLastOrder,
                  [
                    if (lastOrderDate != null)
                      formatDate(sheetContext, lastOrderDate),
                    if (customer.lastOrderTotal != null)
                      formatCurrency(sheetContext, customer.lastOrderTotal!),
                  ].join(' · '),
                ),
              row(
                l10n.chatCustomerLifetimeValue,
                formatCurrency(sheetContext, customer.lifetimeValue),
              ),
              if (customer.recentItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.chatCustomerRecentItems,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final item in customer.recentItems)
                      Chip(
                        label: Text(item),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  onLink();
                },
                icon: const Icon(Icons.link),
                label: Text(l10n.chatActionLinkCustomer),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Channel + status chips for the thread header subtitle.
String chatThreadSubtitle(
  AppLocalizations l10n,
  ChatConversationSummary summary,
) {
  final parts = <String>[
    chatChannelLabel(l10n, summary.channel),
    chatStatusLabel(l10n, summary.status),
    if (chatIntentLabel(l10n, summary.intent) != null &&
        summary.intent != 'Complaint')
      chatIntentLabel(l10n, summary.intent)!,
    if (summary.assignedToName != null)
      l10n.chatAssignedTo(summary.assignedToName!),
  ];
  return parts.join(' · ');
}
