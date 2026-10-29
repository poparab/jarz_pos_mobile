import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/network/user_service.dart';
import '../../data/chat_repository.dart';
import '../../data/models/chat_models.dart';
import '../../state/chat_providers.dart';
import '../widgets/chat_dialogs.dart';
import '../widgets/chat_draft_panel.dart';
import '../widgets/chat_message_bubble.dart';

enum _ThreadAction { assignToMe, close, reopen, customerCard, linkCustomer, startOrder }

/// `/chats/:name` — one conversation: bubbles, the AI draft panel docked
/// above a free composer, and header actions (assign to me, close / reopen,
/// customer card, link customer, start order).
class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({super.key, required this.conversation});

  final String conversation;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _composer = TextEditingController();
  bool _draftBusy = false;
  bool _sending = false;
  bool _actionBusy = false;

  String get _name => widget.conversation;
  ChatThreadNotifier get _notifier =>
      ref.read(chatThreadProvider(_name).notifier);

  @override
  void initState() {
    super.initState();
    _composer.addListener(_onComposerChanged);
  }

  @override
  void dispose() {
    _composer.removeListener(_onComposerChanged);
    _composer.dispose();
    super.dispose();
  }

  void _onComposerChanged() {
    if (mounted) setState(() {});
  }

  void _snack(String text, {SnackBarAction? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), action: action));
  }

  void _snackError(Object error) {
    if (!mounted) return;
    _snack(context.userErrorMessage(error, fallback: context.l10n.chatActionFailed));
  }

  // ── Draft actions ─────────────────────────────────────────────────────

  Future<void> _sendDraft(ChatDraft draft, String text) async {
    if (_draftBusy) return;
    setState(() => _draftBusy = true);
    try {
      final result = await _notifier.sendDraft(draft: draft.name, finalText: text);
      if (!mounted) return;
      // The send is over; do not keep the panel spinning behind the dialog.
      setState(() => _draftBusy = false);
      final outcome = chatPlantedOutcome(result);
      if (outcome != null) {
        await showChatPlantedDialog(
          context,
          outcome: outcome,
          plantedError: result.draft.plantedError ?? draft.plantedError,
          realDraftReady: result.nextDraft != null,
        );
      }
    } catch (e) {
      _snackError(e);
    } finally {
      if (mounted) setState(() => _draftBusy = false);
    }
  }

  Future<void> _rejectDraft(ChatDraft draft) async {
    if (_draftBusy) return;
    final reason = await showChatRejectSheet(context);
    if (reason == null || !mounted) return;
    setState(() => _draftBusy = true);
    try {
      final result = await _notifier.rejectDraft(draft: draft.name, reason: reason);
      if (!mounted) return;
      if (result.planted) _snack(context.l10n.chatRejectCaught);
    } catch (e) {
      _snackError(e);
    } finally {
      if (mounted) setState(() => _draftBusy = false);
    }
  }

  /// `regenerate_draft` with the moderator's instruction. When our message
  /// is the newest (the "Ask AI for a message" bar, or Regenerate on a draft
  /// it produced) the AI drafts an extra message from Jarz, so the
  /// instruction is required.
  Future<void> _regenerate() async {
    if (_draftBusy) return;
    final current = ref.read(chatThreadProvider(_name)).valueOrNull;
    final requireHint = current != null && chatNewestIsOurs(current);
    final hint = await showChatRegenerateDialog(
      context,
      requireHint: requireHint,
    );
    if (hint == null || !mounted) return;
    if (requireHint && hint.isEmpty) return;
    setState(() => _draftBusy = true);
    try {
      final draft = await _notifier.regenerateDraft(hint: hint);
      if (draft == null && requireHint) {
        _snack(_bi(
          'The AI did not return a message. Try again or type it yourself.',
          'الذكاء الاصطناعي مرجعش رسالة. جرّب تاني أو اكتبها بنفسك.',
        ));
      }
    } catch (e) {
      _snackError(e);
    } finally {
      if (mounted) setState(() => _draftBusy = false);
    }
  }

  // ── Composer ──────────────────────────────────────────────────────────

  Future<void> _sendTyped() async {
    final text = _composer.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _notifier.sendMessage(text);
      _composer.clear();
    } catch (e) {
      _snackError(e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ── Header actions ────────────────────────────────────────────────────

  Future<void> _runAction(Future<void> Function() action) async {
    if (_actionBusy) return;
    setState(() => _actionBusy = true);
    try {
      await action();
    } catch (e) {
      _snackError(e);
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _linkCustomer(ChatConversationSummary conversation) async {
    final picked = await showChatLinkCustomerSheet(
      context,
      initialQuery: conversation.phone ?? conversation.contactName,
    );
    if (picked == null || !mounted) return;
    final l10n = context.l10n;
    await _runAction(() async {
      final result = await _notifier.linkCustomer(picked.name);
      _snack(l10n.chatLinkDone(
        result.customer?.customerName ?? picked.customerName,
      ));
    });
  }

  /// Inline bilingual text (no .arb key: an .arb edit forces a full APK).
  String _bi(String en, String ar) =>
      Localizations.localeOf(context).languageCode == 'ar' ? ar : en;

  void _showReadingOrder() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        key: const ValueKey('chat-reading-order'),
        duration: ChatRepository.orderPrefillTimeout,
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(_bi(
                'Reading the order from the chat…',
                'جارٍ قراءة الطلب من المحادثة…',
              )),
            ),
          ],
        ),
      ));
  }

  /// `get_order_prefill` with the chat's order read by the AI. A failed or
  /// timed-out read falls back to the plain (customer-only) prefill, with
  /// the reason in [ChatOrderPrefill.orderError], so "Start order" still
  /// opens the POS as it did before.
  Future<ChatOrderPrefill> _prefillWithOrder() async {
    final messenger = ScaffoldMessenger.of(context);
    _showReadingOrder();
    try {
      return await _notifier.orderPrefill(withOrder: true);
    } catch (e) {
      final reason = mounted
          ? context.userErrorMessage(e, fallback: context.l10n.chatActionFailed)
          : e.toString();
      final plain = await _notifier.orderPrefill();
      return ChatOrderPrefill(
        customer: plain.customer,
        phone: plain.phone,
        contactName: plain.contactName,
        orderError: reason,
      );
    } finally {
      messenger.hideCurrentSnackBar();
    }
  }

  Future<void> _startOrder(ChatConversationSummary conversation) async {
    final l10n = context.l10n;
    await _runAction(() async {
      // Reading the order costs a model call; skip it when the chat has no
      // linked customer, because the POS cannot open without one anyway.
      final linked = conversation.customer != null;
      var prefill = linked
          ? await _prefillWithOrder()
          : await _notifier.orderPrefill();
      if (!mounted) return;
      if (!linked && prefill.customer != null) {
        // The summary was stale: the server has a customer on this chat.
        prefill = await _prefillWithOrder();
        if (!mounted) return;
      }
      final customer = prefill.customer;
      if (customer == null) {
        _snack(
          l10n.chatStartOrderNeedsCustomer,
          action: SnackBarAction(
            label: l10n.chatActionLinkCustomer,
            onPressed: () => _linkCustomer(conversation),
          ),
        );
        return;
      }
      final order = prefill.order;
      final orderError = prefill.orderError;
      if (order == null && orderError != null) {
        _snack(_bi(
          'Could not read the order from the chat: $orderError',
          'تعذّرت قراءة الطلب من المحادثة: $orderError',
        ));
      } else if (order != null && order.isEmpty) {
        _snack(_bi(
          'No order found in the chat; add the items by hand.',
          'لم يُعثر على طلب في المحادثة؛ أضف الأصناف يدويًا.',
        ));
      }
      unawaited(context.push(AppRoutes.pos, extra: <String, dynamic>{
        'mode': 'chat_order',
        'conversation': _name,
        'customer': customer,
        if (order != null && !order.isEmpty) 'chat_order': order.toJson(),
      }));
    });
  }

  void _onAction(_ThreadAction action, ChatThreadState state) {
    final l10n = context.l10n;
    switch (action) {
      case _ThreadAction.assignToMe:
        _runAction(() async {
          await _notifier.assignToMe();
          _snack(l10n.chatAssignedToYou);
        });
      case _ThreadAction.close:
        _runAction(() async {
          await _notifier.setStatus(ChatStatuses.closed);
          _snack(l10n.chatClosedDone);
        });
      case _ThreadAction.reopen:
        _runAction(() async {
          await _notifier.setStatus(ChatStatuses.open);
          _snack(l10n.chatReopenedDone);
        });
      case _ThreadAction.customerCard:
        showChatCustomerCardSheet(
          context,
          customer: state.customer,
          onLink: () => _linkCustomer(state.conversation),
        );
      case _ThreadAction.linkCustomer:
        _linkCustomer(state.conversation);
      case _ThreadAction.startOrder:
        _startOrder(state.conversation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final thread = ref.watch(chatThreadProvider(_name));
    final state = thread.valueOrNull;
    final currentUser = ref.watch(userRolesFutureProvider).valueOrNull?.user;

    return Scaffold(
      appBar: AppBar(
        title: state == null
            ? Text(_name)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.conversation.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    chatThreadSubtitle(l10n, state.conversation),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
        actions: state == null
            ? null
            : [
                if (_actionBusy)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                IconButton(
                  key: const ValueKey('chat-start-order'),
                  tooltip: l10n.chatActionStartOrder,
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: _actionBusy
                      ? null
                      : () => _onAction(_ThreadAction.startOrder, state),
                ),
                PopupMenuButton<_ThreadAction>(
                  key: const ValueKey('chat-thread-menu'),
                  enabled: !_actionBusy,
                  onSelected: (action) => _onAction(action, state),
                  itemBuilder: (context) => [
                    if (currentUser == null ||
                        state.conversation.assignedTo != currentUser)
                      PopupMenuItem(
                        value: _ThreadAction.assignToMe,
                        child: Text(l10n.chatActionAssignToMe),
                      ),
                    if (state.conversation.isClosed)
                      PopupMenuItem(
                        value: _ThreadAction.reopen,
                        child: Text(l10n.chatActionReopen),
                      )
                    else
                      PopupMenuItem(
                        value: _ThreadAction.close,
                        child: Text(l10n.chatActionClose),
                      ),
                    PopupMenuItem(
                      value: _ThreadAction.customerCard,
                      child: Text(l10n.chatActionCustomerCard),
                    ),
                    PopupMenuItem(
                      value: _ThreadAction.linkCustomer,
                      child: Text(l10n.chatActionLinkCustomer),
                    ),
                    PopupMenuItem(
                      value: _ThreadAction.startOrder,
                      child: Text(l10n.chatActionStartOrder),
                    ),
                  ],
                ),
              ],
      ),
      body: thread.when(
        skipLoadingOnReload: true,
        skipError: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 40),
                const SizedBox(height: 12),
                Text(
                  context.userErrorMessage(e, fallback: l10n.chatThreadLoadError),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(chatThreadProvider(_name)),
                  child: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
        data: (data) => _ThreadBody(
          state: data,
          composer: _composer,
          sending: _sending,
          draftBusy: _draftBusy,
          onSendTyped: _sendTyped,
          onSendDraft: (text) => _sendDraft(data.draft!, text),
          onRejectDraft: () => _rejectDraft(data.draft!),
          onRegenerate: _regenerate,
          onLoadOlder: () async {
            try {
              await _notifier.loadOlder();
            } catch (e) {
              _snackError(e);
            }
          },
        ),
      ),
    );
  }
}

class _ThreadBody extends StatelessWidget {
  const _ThreadBody({
    required this.state,
    required this.composer,
    required this.sending,
    required this.draftBusy,
    required this.onSendTyped,
    required this.onSendDraft,
    required this.onRejectDraft,
    required this.onRegenerate,
    required this.onLoadOlder,
  });

  final ChatThreadState state;
  final TextEditingController composer;
  final bool sending;
  final bool draftBusy;
  final VoidCallback onSendTyped;
  final ValueChanged<String> onSendDraft;
  final VoidCallback onRejectDraft;
  final VoidCallback onRegenerate;
  final VoidCallback onLoadOlder;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final messages = state.messages;
    final draft = state.draft;
    final showOlder = state.hasMoreOlder;
    final count = messages.length + (showOlder ? 1 : 0);

    return Column(
      children: [
        if (!state.conversation.windowOpen)
          Container(
            key: const ValueKey('chat-window-closed'),
            width: double.infinity,
            color: theme.colorScheme.errorContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.schedule, color: theme.colorScheme.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.chatWindowClosedBanner,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          // Reversed so the newest message sits at the bottom and new
          // arrivals stay in view.
          child: ListView.builder(
            key: const ValueKey('chat-thread-list'),
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: count,
            itemBuilder: (context, index) {
              if (showOlder && index == count - 1) {
                return Center(
                  child: state.loadingOlder
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TextButton(
                          onPressed: onLoadOlder,
                          child: Text(l10n.chatLoadOlder),
                        ),
                );
              }
              final message = messages[messages.length - 1 - index];
              return ChatMessageBubble(message: message);
            },
          ),
        ),
        switch (chatAiSlot(state)) {
          ChatAiSlot.draft => ChatDraftPanel(
              key: ValueKey('chat-draft-${draft!.name}'),
              draft: draft,
              busy: draftBusy,
              onSend: onSendDraft,
              onReject: onRejectDraft,
              onRegenerate: onRegenerate,
            ),
          ChatAiSlot.askForMessage => ChatAskAiBar(
              windowClosed: false,
              busy: draftBusy,
              onAsk: onRegenerate,
            ),
          ChatAiSlot.windowClosed => ChatAskAiBar(
              windowClosed: true,
              busy: draftBusy,
              onAsk: onRegenerate,
            ),
          ChatAiSlot.none => const SizedBox.shrink(),
        },
        Material(
          elevation: 4,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('chat-composer'),
                      controller: composer,
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 4096,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: l10n.chatComposerHint,
                        isDense: true,
                        counterText: '',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  sending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          key: const ValueKey('chat-composer-send'),
                          tooltip: l10n.chatComposerSendTooltip,
                          icon: const Icon(Icons.send),
                          onPressed:
                              composer.text.trim().isEmpty ? null : onSendTyped,
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
