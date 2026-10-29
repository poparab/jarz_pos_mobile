import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/chat_repository.dart';
import '../data/chat_voice_note_source.dart';
import '../data/just_audio_voice_note_engine.dart';

export '../data/chat_voice_note_source.dart' show ChatVoiceNoteSource;

/// The playback surface the voice-note player drives. The app uses
/// [JustAudioVoiceNoteEngine]; tests substitute a fake so no platform channel
/// is needed.
abstract class ChatVoiceNoteEngine {
  /// Whether audio is currently playing.
  Stream<bool> get playingStream;

  /// The playback position, updated while playing and after a seek.
  Stream<Duration> get positionStream;

  /// The track length once known.
  Stream<Duration?> get durationStream;

  /// Fires each time playback reaches the end.
  Stream<void> get completedStream;

  /// Playback failures after a successful [load] (decoder, focus loss...).
  Stream<Object> get errorStream;

  /// Loads [uri] (a file or blob URL) and returns its length when known.
  Future<Duration?> load(Uri uri);

  /// Starts playback. Returns once playback has been requested, NOT when the
  /// track ends.
  Future<void> play();

  Future<void> pause();

  Future<void> seek(Duration position);

  Future<void> dispose();
}

typedef ChatVoiceNoteEngineFactory = ChatVoiceNoteEngine Function();

/// Fetches a voice note's bytes with the session and turns them into a URI
/// the engine can load.
typedef ChatVoiceNoteSourceLoader = Future<ChatVoiceNoteSource> Function(
  String mediaUrl,
  String? mime,
);

/// One voice note at a time: starting a note pauses whichever other note was
/// playing. Pure Dart; each player registers itself with a token (its State)
/// and a callback that pauses it.
class ChatVoiceNoteCoordinator {
  Object? _activeToken;
  void Function()? _pauseActive;

  /// The token of the note that last started playing, if still registered.
  Object? get activeToken => _activeToken;

  bool isActive(Object token) => identical(_activeToken, token);

  /// [token] is about to play: pause the previous note (if a different one)
  /// and remember [pause] for the next note that starts.
  void activate(Object token, void Function() pause) {
    final previous = _pauseActive;
    final wasOther = _activeToken != null && !identical(_activeToken, token);
    _activeToken = token;
    _pauseActive = pause;
    if (wasOther && previous != null) previous();
  }

  /// [token] stopped (finished or was disposed): forget it if it is still
  /// the active one. A stale release is ignored.
  void release(Object token) {
    if (!identical(_activeToken, token)) return;
    _activeToken = null;
    _pauseActive = null;
  }
}

final chatVoiceNoteCoordinatorProvider =
    Provider<ChatVoiceNoteCoordinator>((ref) => ChatVoiceNoteCoordinator());

final chatVoiceNoteEngineFactoryProvider =
    Provider<ChatVoiceNoteEngineFactory>(
  (ref) => JustAudioVoiceNoteEngine.new,
);

final chatVoiceNoteSourceLoaderProvider =
    Provider<ChatVoiceNoteSourceLoader>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return (mediaUrl, mime) async {
    final bytes = await repo.fetchMediaBytes(mediaUrl);
    return createChatVoiceNoteSource(
      bytes,
      mime: chatBareMime(mime),
      fileName: chatMediaFileName(mediaUrl),
    );
  };
});

/// [mime] without its parameters: `audio/ogg; codecs=opus` -> `audio/ogg`.
/// Null when empty. Share sheets and blob types want the bare type.
String? chatBareMime(String? mime) {
  final bare = (mime ?? '').split(';').first.trim().toLowerCase();
  return bare.isEmpty ? null : bare;
}

/// The decoded last path segment of a media URL, or `attachment`.
String chatMediaFileName(String url) {
  final last = url.split('?').first.split('/').last;
  if (last.isEmpty) return 'attachment';
  try {
    return Uri.decodeComponent(last);
  } catch (_) {
    return last;
  }
}

/// `m:ss` (or `h:mm:ss` past an hour).
String formatChatVoiceDuration(Duration value) {
  final d = value.isNegative ? Duration.zero : value;
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:$seconds';
  }
  return '$minutes:$seconds';
}
