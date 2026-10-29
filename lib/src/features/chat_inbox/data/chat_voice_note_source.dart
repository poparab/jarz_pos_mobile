import 'dart:typed_data';

import 'chat_voice_note_source_io.dart'
    if (dart.library.js_interop) 'chat_voice_note_source_web.dart' as impl;

/// A playable URI for voice-note bytes already fetched with the session: a
/// temp file on Android/iOS, a blob URL on web. Call [release] when done
/// (deletes the file / revokes the blob URL).
class ChatVoiceNoteSource {
  ChatVoiceNoteSource(this.uri, {Future<void> Function()? onRelease})
      : _onRelease = onRelease;

  final Uri uri;
  final Future<void> Function()? _onRelease;
  bool _released = false;

  Future<void> release() async {
    if (_released) return;
    _released = true;
    try {
      await _onRelease?.call();
    } catch (_) {
      // A leftover temp file / blob is harmless; never fail the caller.
    }
  }
}

/// [mime] must already be bare (no `; codecs=` parameters).
Future<ChatVoiceNoteSource> createChatVoiceNoteSource(
  Uint8List bytes, {
  String? mime,
  required String fileName,
}) async {
  final created = await impl.createVoiceNoteUri(
    bytes,
    mime: mime,
    fileName: fileName,
  );
  return ChatVoiceNoteSource(created.uri, onRelease: created.release);
}

/// The file extension to use for [mime] when the file name has none.
String chatVoiceNoteExtension(String? mime) {
  switch (mime) {
    case 'audio/ogg':
    case 'audio/opus':
      return '.ogg';
    case 'audio/mpeg':
    case 'audio/mp3':
      return '.mp3';
    case 'audio/mp4':
    case 'audio/x-m4a':
    case 'audio/m4a':
      return '.m4a';
    case 'audio/aac':
      return '.aac';
    case 'audio/amr':
      return '.amr';
    case 'audio/wav':
    case 'audio/x-wav':
      return '.wav';
    case 'audio/webm':
      return '.webm';
    default:
      return '';
  }
}
