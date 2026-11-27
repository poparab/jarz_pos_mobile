import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/studio/data/fake/fake_studio_api.dart';
import 'package:jarz_pos/src/studio/data/fake/studio_fixtures.g.dart';
import 'package:jarz_pos/src/studio/features/calendar/data/calendar_repository.dart';

import '../pieces/harness.dart';

const _id = 'SP-2026-00221';
const _path = '/calendar/post/$_id';
const _button = ValueKey('send-tiktok-now');

Map<String, dynamic> _postJson() =>
    jsonDecode(studioFixtures['calendar.post_get']!) as Map<String, dynamic>;

/// A Published post that goes to Instagram and TikTok, TikTok not sent yet.
Map<String, String> _fixtures({bool offered = true}) => patchedFixtures({
  'calendar.post_get': (j) {
    final m = j as Map;
    m['status'] = 'Published';
    m['platforms'] = ['Instagram', 'TikTok'];
    m['platform_status'] = {'Instagram': 'posted', 'TikTok': 'planned'};
    m['actions'] = [if (offered) 'send_tiktok_now'];
  },
});

Future<void> _scrollTo(WidgetTester tester, Finder f) => tester
    .scrollUntilVisible(f, 300, scrollable: find.byType(Scrollable).first);

Future<StudioTestHarness> _pump(
  WidgetTester tester, {
  String locale = 'en',
  double width = 390,
  bool offered = true,
  FakeStudioApi? api,
  String role = 'founder',
}) => pumpFeature(
  tester,
  location: _path,
  locale: locale,
  width: width,
  height: 3000,
  fixtures: _fixtures(offered: offered),
  role: role,
  api: api,
);

FakeStudioApi _fake({Duration delay = Duration.zero}) =>
    FakeStudioApi(role: 'founder', delay: delay, fixtures: _fixtures());

String? _tiktokState(StudioTestHarness h) =>
    h.container.read(postProvider(_id)).value?.platformStatus?['TikTok'];

const _titleEn = 'Send this post to TikTok now? Instagram is not touched.';
const _titleAr = 'تبعت البوست ده على TikTok دلوقتي؟ الـ Instagram مش هيتلمس.';

void main() {
  for (final width in [390.0, 1440.0]) {
    for (final locale in ['en', 'ar']) {
      final ar = locale == 'ar';
      final label = ar ? 'ابعت على TikTok دلوقتي' : 'Send to TikTok now';
      final title = ar ? _titleAr : _titleEn;
      final tag = '${locale.toUpperCase()} at ${width.toInt()}';

      group('Send to TikTok now ($tag)', () {
        testWidgets('is shown only when actions lists it', (tester) async {
          await _pump(tester, locale: locale, width: width);
          await _scrollTo(tester, find.byKey(_button));
          expect(find.byKey(_button), findsOneWidget);
          expect(find.text(label), findsOneWidget);
        });

        testWidgets('is hidden when actions does not list it', (tester) async {
          await _pump(tester, locale: locale, width: width, offered: false);
          expect(find.byKey(_button), findsNothing);
          expect(find.text(label), findsNothing);
        });

        testWidgets('asks first, then makes one call with a request id', (
          tester,
        ) async {
          final h = await _pump(tester, locale: locale, width: width);
          await _scrollTo(tester, find.byKey(_button));
          await tester.tap(find.byKey(_button));
          await tester.pumpAndSettle();
          expect(find.text(title), findsOneWidget);
          expect(h.api.calls, isNot(contains('tiktok.send_tiktok_now')));

          await tester.tap(find.byKey(const ValueKey('send-tiktok-confirm')));
          await tester.pumpAndSettle();

          final sent = [
            for (final c in h.api.callLog)
              if (c.key == 'tiktok.send_tiktok_now') c,
          ];
          expect(sent, hasLength(1));
          expect(sent.single.params['post_id'], _id);
          expect('${sent.single.params['request_id']}', isNotEmpty);
          // The card now shows the new state: TikTok posted, button gone.
          expect(_tiktokState(h), 'posted');
          expect(find.byKey(_button), findsNothing);
        });

        testWidgets('cancel sends nothing', (tester) async {
          final h = await _pump(tester, locale: locale, width: width);
          await _scrollTo(tester, find.byKey(_button));
          await tester.tap(find.byKey(_button));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('send-tiktok-cancel')));
          await tester.pumpAndSettle();
          expect(h.api.calls, isNot(contains('tiktok.send_tiktok_now')));
          expect(find.byKey(_button), findsOneWidget);
          expect(_tiktokState(h), 'planned');
        });
      });
    }
  }

  group('Send to TikTok now: errors and busy state', () {
    Future<void> confirm(WidgetTester tester) async {
      await _scrollTo(tester, find.byKey(_button));
      await tester.tap(find.byKey(_button));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('send-tiktok-confirm')));
      await tester.pumpAndSettle();
    }

    for (final width in [390.0, 1440.0]) {
      for (final locale in ['en', 'ar']) {
        testWidgets('VALIDATION shows the server message '
            '($locale at ${width.toInt()})', (tester) async {
          final api = _fake()
            ..failNext(
              'tiktok.send_tiktok_now',
              'VALIDATION',
              message: 'TikTok is not connected.',
            );
          final h = await _pump(tester, locale: locale, width: width, api: api);
          await confirm(tester);
          expect(find.text('TikTok is not connected.'), findsOneWidget);
          expect(_tiktokState(h), 'planned');
          // Nothing changed: the button is still there to try again.
          expect(find.byKey(_button), findsOneWidget);
        });

        testWidgets('GATE_FAILED lists the problems '
            '($locale at ${width.toInt()})', (tester) async {
          final api = _fake()
            ..failNext(
              'tiktok.send_tiktok_now',
              'GATE_FAILED',
              problems: [
                {
                  'code': 'no_video',
                  'message': 'The post has no video for TikTok',
                },
              ],
            );
          await _pump(tester, locale: locale, width: width, api: api);
          await confirm(tester);
          expect(find.byKey(const ValueKey('gate-sheet')), findsOneWidget);
          expect(find.text('The post has no video for TikTok'), findsOneWidget);
        });
      }
    }

    testWidgets('ALREADY_DONE refreshes the card with the server copy', (
      tester,
    ) async {
      final current = _postJson()
        ..['status'] = 'Published'
        ..['platforms'] = ['Instagram', 'TikTok']
        ..['platform_status'] = {'Instagram': 'posted', 'TikTok': 'posted'}
        ..['actions'] = <String>[];
      final api = _fake()
        ..failNext('tiktok.send_tiktok_now', 'ALREADY_DONE', current: current);
      final h = await _pump(tester, api: api);
      await confirm(tester);
      expect(_tiktokState(h), 'posted');
      expect(find.byKey(_button), findsNothing);
    });

    testWidgets('the button is disabled while the call runs', (tester) async {
      final api = _fake(delay: const Duration(milliseconds: 500));
      final h = await _pump(tester, api: api);
      await _scrollTo(tester, find.byKey(_button));
      await tester.tap(find.byKey(_button));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('send-tiktok-confirm')));
      await tester.pump(const Duration(milliseconds: 100));
      final running = tester.widget<ButtonStyleButton>(find.byKey(_button));
      expect(running.onPressed, isNull);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      final sent = [
        for (final c in h.api.callLog)
          if (c.key == 'tiktok.send_tiktok_now') c,
      ];
      expect(sent, hasLength(1));
    });

    testWidgets('a non-founder is never offered it', (tester) async {
      await _pump(tester, role: 'lead');
      expect(find.byKey(_button), findsNothing);
    });
  });
}
