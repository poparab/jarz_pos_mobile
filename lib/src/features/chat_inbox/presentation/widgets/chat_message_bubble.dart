import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/chat_repository.dart';
import '../../data/models/chat_models.dart';
import '../../state/chat_providers.dart';
import '../chat_labels.dart';

/// One message: inbound on the start side, outbound on the end side.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final outbound = message.isOutbound;
    final background = outbound
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final foreground = outbound
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;
    final time = message.time;

    final footer = <String>[
      if (time != null) formatDateTime(context, time, pattern: 'h:mm a'),
      if (outbound && message.sentVia == 'Phone') l10n.chatSentFromPhone,
      if (outbound && message.sentVia == 'System') l10n.chatSentBySystem,
      if (outbound &&
          message.sentVia != 'Phone' &&
          (message.sentByName ?? message.sentBy) != null)
        l10n.chatSentBy((message.sentByName ?? message.sentBy)!),
    ];

    return Align(
      alignment:
          outbound ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          key: ValueKey('chat-message-${message.name}'),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadiusDirectional.only(
              topStart: const Radius.circular(14),
              topEnd: const Radius.circular(14),
              bottomStart: Radius.circular(outbound ? 14 : 4),
              bottomEnd: Radius.circular(outbound ? 4 : 14),
            ),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: foreground),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ChatMessageContent(message: message),
                if (footer.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    footer.join(' · '),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: foreground.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                if (message.isFailed)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 14,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            message.error == null
                                ? l10n.chatMessageFailed
                                : '${l10n.chatMessageFailed}: ${message.error}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The body of a message by type: text, image, location link, or an "open"
/// tile for audio / video / documents.
class ChatMessageContent extends StatelessWidget {
  const ChatMessageContent({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final type = message.messageType;
    final body = message.body.trim();

    Widget? caption() => body.isEmpty ? null : SelectableText(body);

    switch (type) {
      case 'image':
      case 'sticker':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ChatMessageImage(message: message),
            if (caption() != null) ...[
              const SizedBox(height: 6),
              caption()!,
            ],
          ],
        );
      case 'audio':
      case 'video':
      case 'document':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ChatMediaOpenTile(message: message),
            if (caption() != null) ...[
              const SizedBox(height: 6),
              caption()!,
            ],
          ],
        );
      case 'location':
        final location = message.location;
        return InkWell(
          onTap: location == null
              ? null
              : () => launchUrl(
                    Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query='
                      '${location.lat},${location.lng}',
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.place_outlined, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  location == null ? l10n.chatMessageLocation : l10n.chatOpenInMaps,
                  style: const TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        );
      case 'reaction':
        return Text(body.isEmpty ? l10n.chatMessageReaction : body);
      default:
        if (body.isNotEmpty) return SelectableText(body);
        final label = chatMessageTypeLabel(l10n, type);
        return Text(
          label.isEmpty ? l10n.chatMessageUnsupported : label,
          style: const TextStyle(fontStyle: FontStyle.italic),
        );
    }
  }
}

/// A message image, fetched with the session (private files) and shown with
/// `Image.memory`. Only same-site `/files` paths are fetched.
class ChatMessageImage extends ConsumerWidget {
  const ChatMessageImage({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final url = message.mediaUrl;
    if (!ChatRepository.isSessionMediaUrl(url)) {
      return _MediaPlaceholder(
        icon: Icons.image_outlined,
        label: l10n.chatMediaUnavailable,
      );
    }
    final bytes = ref.watch(chatMediaBytesProvider(url!));
    return bytes.when(
      loading: () => const SizedBox(
        width: 180,
        height: 140,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (e, _) => _MediaPlaceholder(
        icon: Icons.broken_image_outlined,
        label: l10n.chatMediaLoadFailed,
      ),
      data: (data) => GestureDetector(
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            insetPadding: const EdgeInsets.all(12),
            child: InteractiveViewer(child: Image.memory(data)),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260, maxWidth: 260),
            child: Image.memory(
              data,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _MediaPlaceholder(
                icon: Icons.broken_image_outlined,
                label: l10n.chatMediaLoadFailed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Audio / video / document as a tile that opens the file: the browser on
/// web (its own cookie), otherwise download with the session and hand the
/// bytes to the system share sheet (a plain URL launch would open a browser
/// without the session cookie and get a 403 on a private file).
class ChatMediaOpenTile extends ConsumerStatefulWidget {
  const ChatMediaOpenTile({super.key, required this.message});

  final ChatMessage message;

  @override
  ConsumerState<ChatMediaOpenTile> createState() => _ChatMediaOpenTileState();
}

class _ChatMediaOpenTileState extends ConsumerState<ChatMediaOpenTile> {
  bool _busy = false;

  String _fileName(String url) {
    final last = url.split('/').last;
    return last.isEmpty ? 'attachment' : Uri.decodeComponent(last);
  }

  Future<void> _open() async {
    final url = widget.message.mediaUrl;
    if (!ChatRepository.isSessionMediaUrl(url) || _busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final repo = ref.read(chatRepositoryProvider);
    setState(() => _busy = true);
    try {
      if (kIsWeb) {
        await launchUrl(
          Uri.parse(repo.absoluteMediaUrl(url!)),
          webOnlyWindowName: '_blank',
        );
        return;
      }
      final bytes = await repo.fetchMediaBytes(url!);
      final name = _fileName(url);
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              name: name,
              mimeType: widget.message.mediaMime,
            ),
          ],
          fileNameOverrides: [name],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            context.userErrorMessage(e, fallback: l10n.chatMediaLoadFailed),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final type = widget.message.messageType;
    final available = ChatRepository.isSessionMediaUrl(widget.message.mediaUrl);
    return OutlinedButton.icon(
      onPressed: available && !_busy ? _open : null,
      icon: _busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(chatMessageTypeIcon(type)),
      label: Text(
        available
            ? '${chatMessageTypeLabel(l10n, type)} · ${l10n.chatOpenMedia}'
            : l10n.chatMediaUnavailable,
      ),
    );
  }
}

class _MediaPlaceholder extends StatelessWidget {
  const _MediaPlaceholder({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}
