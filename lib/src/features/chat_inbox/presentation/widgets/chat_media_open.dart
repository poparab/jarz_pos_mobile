import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/chat_repository.dart';
import '../../data/models/chat_models.dart';
import '../../state/chat_voice_note_playback.dart';

/// Opens a message attachment outside the app: the browser on web (its own
/// cookie), otherwise download with the session and hand the bytes to the
/// system share sheet (a plain URL launch would open a browser without the
/// session cookie and get a 403 on a private file). [bytes] skips the
/// download when the caller already has them. Failures show a snackbar.
Future<void> openChatMediaAttachment(
  BuildContext context,
  ChatRepository repo,
  ChatMessage message, {
  Uint8List? bytes,
}) async {
  final url = message.mediaUrl;
  if (!ChatRepository.isSessionMediaUrl(url)) return;
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  try {
    if (kIsWeb) {
      await launchUrl(
        Uri.parse(repo.absoluteMediaUrl(url!)),
        webOnlyWindowName: '_blank',
      );
      return;
    }
    final data = bytes ?? await repo.fetchMediaBytes(url!);
    final name = chatMediaFileName(url!);
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            data,
            name: name,
            // `audio/ogg; codecs=opus` confuses share targets; pass the bare
            // type.
            mimeType: chatBareMime(message.mediaMime),
          ),
        ],
        fileNameOverrides: [name],
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          context.userErrorMessage(e, fallback: l10n.chatMediaLoadFailed),
        ),
      ),
    );
  }
}
