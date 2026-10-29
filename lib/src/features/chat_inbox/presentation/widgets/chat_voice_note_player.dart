import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/chat_repository.dart';
import '../../data/models/chat_models.dart';
import '../../state/chat_voice_note_playback.dart';
import 'chat_media_open.dart';

/// Where a voice-note player is in its life.
enum ChatVoiceNoteStatus { idle, loading, ready, error }

/// An inline player for an `audio` chat message: play/pause, a seek slider
/// with elapsed / total time, and a small share (open on web) action.
///
/// Nothing is fetched until the first tap on play: then the bytes come down
/// with the session (private files), become a temp file / blob URL, and load
/// into a [ChatVoiceNoteEngine]. Only one note plays at a time
/// ([ChatVoiceNoteCoordinator]). The engine and the source are released when
/// the bubble goes away; while a note is playing the bubble is kept alive so
/// scrolling the thread does not cut it off.
class ChatVoiceNotePlayer extends ConsumerStatefulWidget {
  const ChatVoiceNotePlayer({super.key, required this.message});

  final ChatMessage message;

  @override
  ConsumerState<ChatVoiceNotePlayer> createState() =>
      _ChatVoiceNotePlayerState();
}

class _ChatVoiceNotePlayerState extends ConsumerState<ChatVoiceNotePlayer>
    with AutomaticKeepAliveClientMixin {
  late final ChatVoiceNoteCoordinator _coordinator;
  ChatVoiceNoteEngine? _engine;
  ChatVoiceNoteSource? _source;
  final _subscriptions = <StreamSubscription<dynamic>>[];

  ChatVoiceNoteStatus _status = ChatVoiceNoteStatus.idle;
  bool _playing = false;
  bool _sharing = false;
  Duration _position = Duration.zero;
  Duration? _duration;
  double? _dragMs;
  int _generation = 0;

  @override
  bool get wantKeepAlive => _playing;

  String _bi(String en, String ar) =>
      Localizations.localeOf(context).languageCode == 'ar' ? ar : en;

  bool get _available =>
      ChatRepository.isSessionMediaUrl(widget.message.mediaUrl);

  @override
  void initState() {
    super.initState();
    _coordinator = ref.read(chatVoiceNoteCoordinatorProvider);
  }

  @override
  void dispose() {
    _generation++;
    _coordinator.release(this);
    _releasePlayback();
    super.dispose();
  }

  /// Drops the engine and the source (fire-and-forget: dispose is sync).
  void _releasePlayback() {
    for (final sub in _subscriptions) {
      unawaited(sub.cancel());
    }
    _subscriptions.clear();
    final engine = _engine;
    final source = _source;
    _engine = null;
    _source = null;
    if (engine != null) unawaited(_quietly(engine.dispose));
    if (source != null) unawaited(source.release());
  }

  static Future<void> _quietly(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {}
  }

  void _setPlaying(bool value) {
    if (_playing == value) return;
    setState(() => _playing = value);
    updateKeepAlive();
  }

  Future<void> _onMainPressed() async {
    switch (_status) {
      case ChatVoiceNoteStatus.loading:
        return;
      case ChatVoiceNoteStatus.idle:
      case ChatVoiceNoteStatus.error:
        await _loadAndPlay();
        return;
      case ChatVoiceNoteStatus.ready:
        if (_playing) {
          await _pause();
        } else {
          await _play();
        }
    }
  }

  Future<void> _loadAndPlay() async {
    final url = widget.message.mediaUrl;
    if (!_available) return;
    final loader = ref.read(chatVoiceNoteSourceLoaderProvider);
    final createEngine = ref.read(chatVoiceNoteEngineFactoryProvider);
    final generation = ++_generation;
    _releasePlayback();
    setState(() {
      _status = ChatVoiceNoteStatus.loading;
      _position = Duration.zero;
      _dragMs = null;
    });

    ChatVoiceNoteSource? source;
    ChatVoiceNoteEngine? engine;
    try {
      source = await loader(url!, widget.message.mediaMime);
      if (!mounted || generation != _generation) {
        await source.release();
        return;
      }
      engine = createEngine();
      _engine = engine;
      _source = source;
      _listen(engine, generation);
      final duration = await engine.load(source.uri);
      if (!mounted || generation != _generation) return;
      setState(() {
        _duration = duration ?? _duration;
        _status = ChatVoiceNoteStatus.ready;
      });
      await _play();
    } catch (e) {
      if (!mounted || generation != _generation) {
        if (engine == null) await source?.release();
        return;
      }
      _fail(e);
    }
  }

  void _listen(ChatVoiceNoteEngine engine, int generation) {
    bool current() => mounted && generation == _generation;
    _subscriptions
      ..add(engine.playingStream.listen((playing) {
        if (current()) _setPlaying(playing);
      }))
      ..add(engine.positionStream.listen((position) {
        if (current() && position != _position) {
          setState(() => _position = position);
        }
      }))
      ..add(engine.durationStream.listen((duration) {
        if (current() && duration != null && duration != _duration) {
          setState(() => _duration = duration);
        }
      }))
      ..add(engine.completedStream.listen((_) {
        if (current()) unawaited(_onCompleted());
      }))
      ..add(engine.errorStream.listen((error) {
        if (current()) _fail(error);
      }));
  }

  Future<void> _onCompleted() async {
    final engine = _engine;
    _coordinator.release(this);
    if (engine == null) return;
    await _quietly(engine.pause);
    await _quietly(() => engine.seek(Duration.zero));
    if (!mounted) return;
    setState(() => _position = Duration.zero);
    _setPlaying(false);
  }

  void _fail(Object error) {
    debugPrint('chat voice note ${widget.message.name}: $error');
    _generation++;
    _coordinator.release(this);
    _releasePlayback();
    setState(() {
      _status = ChatVoiceNoteStatus.error;
      _dragMs = null;
    });
    _setPlaying(false);
  }

  Future<void> _play() async {
    final engine = _engine;
    if (engine == null) return;
    _coordinator.activate(this, () => unawaited(_quietly(engine.pause)));
    try {
      await engine.play();
    } catch (e) {
      if (mounted) _fail(e);
    }
  }

  Future<void> _pause() async {
    final engine = _engine;
    if (engine == null) return;
    await _quietly(engine.pause);
  }

  Future<void> _seekTo(double ms) async {
    final engine = _engine;
    setState(() {
      _dragMs = null;
      _position = Duration(milliseconds: ms.round());
    });
    if (engine == null) return;
    await _quietly(() => engine.seek(Duration(milliseconds: ms.round())));
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await openChatMediaAttachment(
        context,
        ref.read(chatRepositoryProvider),
        widget.message,
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final foreground =
        DefaultTextStyle.of(context).style.color ?? theme.colorScheme.onSurface;
    final muted = foreground.withValues(alpha: 0.72);
    final key = 'chat-voice-player-${widget.message.name}';

    if (!_available) {
      return Row(
        key: ValueKey(key),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic_off_outlined, size: 18, color: muted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l10n.chatMediaUnavailable,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      );
    }

    final ready = _status == ChatVoiceNoteStatus.ready;
    final totalMs = (_duration?.inMilliseconds ?? 0).toDouble();
    final positionMs = _dragMs ??
        _position.inMilliseconds.toDouble().clamp(0.0, totalMs);
    final canSeek = ready && totalMs > 0;

    final Widget mainButton;
    switch (_status) {
      case ChatVoiceNoteStatus.loading:
        mainButton = const SizedBox(
          key: ValueKey('chat-voice-loading'),
          width: 48,
          height: 48,
          child: Padding(
            padding: EdgeInsets.all(14),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case ChatVoiceNoteStatus.error:
        mainButton = IconButton(
          key: const ValueKey('chat-voice-retry'),
          tooltip: _bi('Retry', 'إعادة المحاولة'),
          onPressed: _onMainPressed,
          icon: Icon(Icons.refresh, color: theme.colorScheme.error),
        );
      case ChatVoiceNoteStatus.idle:
      case ChatVoiceNoteStatus.ready:
        mainButton = IconButton(
          key: const ValueKey('chat-voice-play'),
          tooltip: _playing ? _bi('Pause', 'إيقاف مؤقت') : _bi('Play', 'تشغيل'),
          onPressed: _onMainPressed,
          icon: Icon(
            _playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
            size: 32,
            color: theme.colorScheme.primary,
          ),
        );
    }

    final String timeText;
    if (ready && _duration != null) {
      final elapsed = Duration(milliseconds: positionMs.round());
      timeText = '${formatChatVoiceDuration(elapsed)} / '
          '${formatChatVoiceDuration(_duration!)}';
    } else {
      timeText = formatChatVoiceDuration(_duration ?? Duration.zero);
    }

    return ConstrainedBox(
      key: ValueKey(key),
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              mainButton,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                          disabledThumbRadius: 5,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14,
                        ),
                      ),
                      child: SizedBox(
                        height: 28,
                        child: Slider(
                          key: const ValueKey('chat-voice-slider'),
                          value: canSeek ? positionMs : 0,
                          max: canSeek ? totalMs : 1,
                          onChanged: canSeek
                              ? (v) => setState(() => _dragMs = v)
                              : null,
                          onChangeEnd: canSeek ? _seekTo : null,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 14),
                      child: Text(
                        timeText,
                        key: const ValueKey('chat-voice-time'),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: muted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const ValueKey('chat-voice-share'),
                tooltip: l10n.chatOpenMedia,
                visualDensity: VisualDensity.compact,
                onPressed: _sharing ? null : _share,
                icon: _sharing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        kIsWeb ? Icons.open_in_new : Icons.share_outlined,
                        size: 18,
                        color: muted,
                      ),
              ),
            ],
          ),
          if (_status == ChatVoiceNoteStatus.error)
            Padding(
              key: const ValueKey('chat-voice-error'),
              padding: const EdgeInsetsDirectional.only(start: 8, bottom: 2),
              child: Text(
                _bi(
                  "Couldn't play this voice note. Tap retry, or open it.",
                  'تعذر تشغيل الرسالة الصوتية. اضغط إعادة المحاولة أو افتحها.',
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
