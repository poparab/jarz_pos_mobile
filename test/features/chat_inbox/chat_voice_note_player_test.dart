// The inline voice-note player in the chat thread: idle until the first tap
// (nothing fetched), a spinner while the bytes load, play/pause with a time
// readout once ready, a retry on failure, and only one note playing at a
// time. The engine and the source loader are faked, so no platform channel
// (ExoPlayer / audio element / temp files) is touched.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/chat_inbox/data/chat_voice_note_source.dart';
import 'package:jarz_pos/src/features/chat_inbox/data/models/chat_models.dart';
import 'package:jarz_pos/src/features/chat_inbox/presentation/widgets/chat_message_bubble.dart';
import 'package:jarz_pos/src/features/chat_inbox/state/chat_voice_note_playback.dart';

import '../../helpers/test_helpers.dart';

class _FakeEngine implements ChatVoiceNoteEngine {
  static const loadDuration = Duration(seconds: 12);
  final playing = StreamController<bool>.broadcast(sync: true);
  final position = StreamController<Duration>.broadcast(sync: true);
  final duration = StreamController<Duration?>.broadcast(sync: true);
  final completed = StreamController<void>.broadcast(sync: true);
  final errors = StreamController<Object>.broadcast(sync: true);

  final loaded = <Uri>[];
  final seeks = <Duration>[];
  int plays = 0;
  int pauses = 0;
  bool disposed = false;
  bool isPlaying = false;

  @override
  Stream<bool> get playingStream => playing.stream;
  @override
  Stream<Duration> get positionStream => position.stream;
  @override
  Stream<Duration?> get durationStream => duration.stream;
  @override
  Stream<void> get completedStream => completed.stream;
  @override
  Stream<Object> get errorStream => errors.stream;

  @override
  Future<Duration?> load(Uri uri) async {
    loaded.add(uri);
    return loadDuration;
  }

  @override
  Future<void> play() async {
    plays++;
    isPlaying = true;
    playing.add(true);
  }

  @override
  Future<void> pause() async {
    pauses++;
    if (isPlaying) {
      isPlaying = false;
      playing.add(false);
    }
  }

  @override
  Future<void> seek(Duration value) async {
    seeks.add(value);
    position.add(value);
  }

  @override
  Future<void> dispose() async => disposed = true;
}

/// Records every engine it builds, in order.
class _EngineBench {
  final engines = <_FakeEngine>[];
  ChatVoiceNoteEngine create() {
    final engine = _FakeEngine();
    engines.add(engine);
    return engine;
  }
}

/// A loader the test drives: each call waits on its own completer unless
/// [autoComplete] is set.
class _Loader {
  _Loader({this.autoComplete = true});

  bool autoComplete;
  Object? failWith;
  final calls = <(String, String?)>[];
  final pending = <Completer<ChatVoiceNoteSource>>[];
  int released = 0;

  Future<ChatVoiceNoteSource> call(String url, String? mime) {
    calls.add((url, mime));
    if (failWith != null) return Future.error(failWith!);
    final source = ChatVoiceNoteSource(
      Uri.parse('file:///tmp/${calls.length}.ogg'),
      onRelease: () async => released++,
    );
    if (autoComplete) return Future.value(source);
    final completer = Completer<ChatVoiceNoteSource>();
    pending.add(completer);
    return completer.future.then((_) => source);
  }
}

ChatMessage _audio(String name, {String? url, String? transcript}) =>
    ChatMessage.fromJson({
      'name': name,
      'direction': 'Inbound',
      'message_type': 'audio',
      'body': '',
      'media_url': url ?? '/private/files/voice-$name.ogg',
      'media_mime': 'audio/ogg; codecs=opus',
      'timestamp': '2026-10-29 10:00:00',
      'transcript': transcript,
    });

Widget _app(
  List<ChatMessage> messages, {
  required _EngineBench bench,
  required _Loader loader,
  String locale = 'en',
}) =>
    ProviderScope(
      overrides: [
        chatVoiceNoteEngineFactoryProvider.overrideWithValue(bench.create),
        chatVoiceNoteSourceLoaderProvider.overrideWithValue(loader.call),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ListView(
            children: [
              for (final m in messages) ChatMessageBubble(message: m),
            ],
          ),
        ),
      ),
    );

Finder _inPlayer(String name, Finder finder) => find.descendant(
      of: find.byKey(ValueKey('chat-voice-player-$name')),
      matching: finder,
    );

String _time(WidgetTester tester, String name) => tester
    .widget<Text>(_inPlayer(name, find.byKey(const ValueKey('chat-voice-time'))))
    .data!;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  group('ChatVoiceNoteCoordinator (only one note plays)', () {
    test('starting a second note pauses the first', () {
      final c = ChatVoiceNoteCoordinator();
      final a = Object(), b = Object();
      var aPaused = 0, bPaused = 0;
      c.activate(a, () => aPaused++);
      expect(c.isActive(a), isTrue);
      c.activate(b, () => bPaused++);
      expect(aPaused, 1);
      expect(bPaused, 0);
      expect(c.isActive(b), isTrue);
      expect(c.isActive(a), isFalse);
    });

    test('re-activating the same note does not pause it', () {
      final c = ChatVoiceNoteCoordinator();
      final a = Object();
      var paused = 0;
      c.activate(a, () => paused++);
      c.activate(a, () => paused++);
      expect(paused, 0);
    });

    test('a stale release is ignored; releasing the active one clears it', () {
      final c = ChatVoiceNoteCoordinator();
      final a = Object(), b = Object();
      var aPaused = 0;
      c.activate(a, () => aPaused++);
      c.activate(b, () {});
      c.release(a); // a is no longer active
      expect(c.isActive(b), isTrue);
      c.release(b);
      expect(c.activeToken, isNull);
      // Nothing is paused when the next note starts after a release.
      c.activate(a, () => aPaused++);
      expect(aPaused, 1); // only the first hand-over
    });
  });

  group('helpers', () {
    test('chatBareMime strips parameters', () {
      expect(chatBareMime('audio/ogg; codecs=opus'), 'audio/ogg');
      expect(chatBareMime(' Audio/MPEG '), 'audio/mpeg');
      expect(chatBareMime(''), isNull);
      expect(chatBareMime(null), isNull);
    });

    test('formatChatVoiceDuration', () {
      expect(formatChatVoiceDuration(Duration.zero), '0:00');
      expect(formatChatVoiceDuration(const Duration(seconds: 7)), '0:07');
      expect(formatChatVoiceDuration(const Duration(seconds: 91)), '1:31');
      expect(
        formatChatVoiceDuration(const Duration(hours: 1, seconds: 5)),
        '1:00:05',
      );
    });

    test('chatMediaFileName and extensions', () {
      expect(chatMediaFileName('/private/files/voice%201.ogg'), 'voice 1.ogg');
      expect(chatMediaFileName('/files/'), 'attachment');
      expect(chatVoiceNoteExtension('audio/ogg'), '.ogg');
      expect(chatVoiceNoteExtension('audio/mpeg'), '.mp3');
      expect(chatVoiceNoteExtension('application/pdf'), '');
    });
  });

  group('ChatVoiceNotePlayer', () {
    testWidgets('idle: a play button, nothing fetched, transcript below',
        (tester) async {
      final bench = _EngineBench();
      final loader = _Loader();
      await tester.pumpWidget(_app(
        [_audio('M1', transcript: 'Two jars please')],
        bench: bench,
        loader: loader,
      ));
      await tester.pump();

      expect(_inPlayer('M1', find.byKey(const ValueKey('chat-voice-play'))),
          findsOneWidget);
      expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);
      expect(_inPlayer('M1', find.byKey(const ValueKey('chat-voice-share'))),
          findsOneWidget);
      final slider = tester.widget<Slider>(
          find.byKey(const ValueKey('chat-voice-slider')));
      expect(slider.onChanged, isNull);
      expect(_time(tester, 'M1'), '0:00');
      expect(loader.calls, isEmpty);
      expect(bench.engines, isEmpty);
      expect(find.byKey(const ValueKey('chat-voice-transcript')),
          findsOneWidget);
      // The old open tile is gone for audio.
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('loading then playing: spinner, then pause + time readout',
        (tester) async {
      final bench = _EngineBench();
      final loader = _Loader(autoComplete: false);
      await tester.pumpWidget(
          _app([_audio('M1')], bench: bench, loader: loader));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('chat-voice-play')));
      await tester.pump();
      expect(find.byKey(const ValueKey('chat-voice-loading')), findsOneWidget);
      expect(loader.calls, [('/private/files/voice-M1.ogg', 'audio/ogg; codecs=opus')]);
      expect(bench.engines, isEmpty);

      loader.pending.single.complete(
          ChatVoiceNoteSource(Uri.parse('file:///unused')));
      await tester.pump();
      await tester.pump();

      final engine = bench.engines.single;
      expect(engine.loaded, [Uri.parse('file:///tmp/1.ogg')]);
      expect(engine.plays, 1);
      expect(find.byKey(const ValueKey('chat-voice-loading')), findsNothing);
      expect(find.byIcon(Icons.pause_circle_filled), findsOneWidget);
      expect(_time(tester, 'M1'), '0:00 / 0:12');

      engine.position.add(const Duration(seconds: 5));
      await tester.pump();
      expect(_time(tester, 'M1'), '0:05 / 0:12');
      final slider = tester.widget<Slider>(
          find.byKey(const ValueKey('chat-voice-slider')));
      expect(slider.onChanged, isNotNull);
      expect(slider.value, 5000);

      // Pause.
      await tester.tap(find.byKey(const ValueKey('chat-voice-play')));
      await tester.pump();
      expect(engine.pauses, 1);
      expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);

      // Play again: no second fetch.
      await tester.tap(find.byKey(const ValueKey('chat-voice-play')));
      await tester.pump();
      expect(engine.plays, 2);
      expect(loader.calls, hasLength(1));
      expect(bench.engines, hasLength(1));
    });

    testWidgets('fetch failure: error + retry, which loads and plays',
        (tester) async {
      final bench = _EngineBench();
      final loader = _Loader()..failWith = Exception('403');
      await tester.pumpWidget(
          _app([_audio('M1')], bench: bench, loader: loader));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('chat-voice-play')));
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const ValueKey('chat-voice-retry')), findsOneWidget);
      expect(find.byKey(const ValueKey('chat-voice-error')), findsOneWidget);
      expect(find.textContaining("Couldn't play"), findsOneWidget);
      // The share / open action stays available.
      expect(find.byKey(const ValueKey('chat-voice-share')), findsOneWidget);
      expect(bench.engines, isEmpty);

      loader.failWith = null;
      await tester.tap(find.byKey(const ValueKey('chat-voice-retry')));
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const ValueKey('chat-voice-error')), findsNothing);
      expect(bench.engines.single.plays, 1);
      expect(find.byIcon(Icons.pause_circle_filled), findsOneWidget);
    });

    testWidgets('Arabic error text', (tester) async {
      final bench = _EngineBench();
      final loader = _Loader()..failWith = Exception('boom');
      await tester.pumpWidget(_app([_audio('M1')],
          bench: bench, loader: loader, locale: 'ar'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('chat-voice-play')));
      await tester.pump();
      await tester.pump();
      expect(find.textContaining('تعذر تشغيل الرسالة الصوتية'), findsOneWidget);
    });

    testWidgets('a playback error after loading drops to the error state',
        (tester) async {
      final bench = _EngineBench();
      final loader = _Loader();
      await tester.pumpWidget(
          _app([_audio('M1')], bench: bench, loader: loader));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('chat-voice-play')));
      await tester.pump();
      await tester.pump();

      final engine = bench.engines.single;
      engine.errors.add(Exception('decoder'));
      await tester.pump();

      expect(find.byKey(const ValueKey('chat-voice-retry')), findsOneWidget);
      expect(engine.disposed, isTrue);
      expect(loader.released, 1);
    });

    testWidgets('playing a second note pauses the first', (tester) async {
      final bench = _EngineBench();
      final loader = _Loader();
      await tester.pumpWidget(_app(
        [_audio('M1'), _audio('M2')],
        bench: bench,
        loader: loader,
      ));
      await tester.pump();

      await tester.tap(
          _inPlayer('M1', find.byKey(const ValueKey('chat-voice-play'))));
      await tester.pump();
      await tester.pump();
      final first = bench.engines.single;
      expect(first.isPlaying, isTrue);

      await tester.tap(
          _inPlayer('M2', find.byKey(const ValueKey('chat-voice-play'))));
      await tester.pump();
      await tester.pump();
      final second = bench.engines.last;

      expect(bench.engines, hasLength(2));
      expect(second.isPlaying, isTrue);
      expect(first.pauses, 1);
      expect(first.isPlaying, isFalse);
      expect(
        _inPlayer('M1', find.byIcon(Icons.play_circle_fill)),
        findsOneWidget,
      );
      expect(
        _inPlayer('M2', find.byIcon(Icons.pause_circle_filled)),
        findsOneWidget,
      );
    });

    testWidgets('reaching the end rewinds and shows play', (tester) async {
      final bench = _EngineBench();
      final loader = _Loader();
      await tester.pumpWidget(
          _app([_audio('M1')], bench: bench, loader: loader));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('chat-voice-play')));
      await tester.pump();
      await tester.pump();

      final engine = bench.engines.single;
      engine.position.add(const Duration(seconds: 12));
      engine.completed.add(null);
      await tester.pump();
      await tester.pump();

      expect(engine.seeks.last, Duration.zero);
      expect(engine.isPlaying, isFalse);
      expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);
      expect(_time(tester, 'M1'), '0:00 / 0:12');
    });

    testWidgets('leaving the thread disposes the engine and the source',
        (tester) async {
      final bench = _EngineBench();
      final loader = _Loader();
      await tester.pumpWidget(
          _app([_audio('M1')], bench: bench, loader: loader));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('chat-voice-play')));
      await tester.pump();
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(bench.engines.single.disposed, isTrue);
      expect(loader.released, 1);
    });

    testWidgets('a non-site media URL shows "unavailable", no play button',
        (tester) async {
      final bench = _EngineBench();
      final loader = _Loader();
      await tester.pumpWidget(_app(
        [_audio('M1', url: 'https://evil.example/x.ogg')],
        bench: bench,
        loader: loader,
      ));
      await tester.pump();

      expect(find.byKey(const ValueKey('chat-voice-play')), findsNothing);
      expect(find.byIcon(Icons.mic_off_outlined), findsOneWidget);
    });
  });
}
