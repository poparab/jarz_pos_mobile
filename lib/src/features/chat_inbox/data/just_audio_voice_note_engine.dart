import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../state/chat_voice_note_playback.dart';

/// [ChatVoiceNoteEngine] on just_audio: ExoPlayer on Android (plays the
/// WhatsApp ogg/opus notes), AVPlayer on iOS, the audio element on web.
/// The [AudioPlayer] is created lazily, on the first [load].
class JustAudioVoiceNoteEngine implements ChatVoiceNoteEngine {
  JustAudioVoiceNoteEngine();

  AudioPlayer? _player;
  StreamSubscription<PlaybackEvent>? _events;
  final _errors = StreamController<Object>.broadcast();
  final _playing = StreamController<bool>.broadcast();
  final _position = StreamController<Duration>.broadcast();
  final _duration = StreamController<Duration?>.broadcast();
  final _completed = StreamController<void>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  bool _disposed = false;

  AudioPlayer _ensurePlayer() {
    final existing = _player;
    if (existing != null) return existing;
    final player = AudioPlayer();
    _player = player;
    _subscriptions
      ..add(player.playingStream.listen(_playing.add))
      ..add(player.positionStream.listen(_position.add))
      ..add(player.durationStream.listen(_duration.add))
      ..add(player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) _completed.add(null);
      }));
    _events = player.playbackEventStream.listen(
      (_) {},
      onError: (Object error, StackTrace _) {
        if (!_errors.isClosed) _errors.add(error);
      },
    );
    return player;
  }

  @override
  Stream<bool> get playingStream => _playing.stream;

  @override
  Stream<Duration> get positionStream => _position.stream;

  @override
  Stream<Duration?> get durationStream => _duration.stream;

  @override
  Stream<void> get completedStream => _completed.stream;

  @override
  Stream<Object> get errorStream => _errors.stream;

  @override
  Future<Duration?> load(Uri uri) {
    return _ensurePlayer().setAudioSource(AudioSource.uri(uri));
  }

  @override
  Future<void> play() async {
    final player = _player;
    if (player == null || _disposed) return;
    // just_audio's play() completes only when playback stops; do not await.
    unawaited(player.play().catchError((Object error) {
      if (!_errors.isClosed) _errors.add(error);
    }));
  }

  @override
  Future<void> pause() async => _player?.pause();

  @override
  Future<void> seek(Duration position) async => _player?.seek(position);

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    await _events?.cancel();
    await _player?.dispose();
    await _errors.close();
    await _playing.close();
    await _position.close();
    await _duration.close();
    await _completed.close();
  }
}
