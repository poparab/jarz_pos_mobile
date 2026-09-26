// Side-menu screenshots per role. NOT run by CI (no workflow job globs
// test/screenshots).
//
// Renders the real AppDrawer for the role set each Jarz role profile resolves
// to on production, with each drawer group opened in turn, and writes one PNG
// per open group to test/screenshots/shots/role-menus/<role>/<lang>/.
//
//   flutter test test/screenshots/role_menus_screenshots_test.dart --update-goldens
//
// No server, no login, no real data: only the role list is supplied, and every
// gate is computed from it by production code.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/widgets/app_drawer.dart';

import '../helpers/role_drawer_harness.dart';
import '../helpers/test_helpers.dart';

final _sdkFonts = () {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null || root.isEmpty) return '';
  final s = Platform.pathSeparator;
  return '$root${s}bin${s}cache${s}artifacts${s}material_fonts';
}();

Future<void> _load(String family, List<String> paths) async {
  final present = paths.where((p) => p.isNotEmpty && File(p).existsSync());
  if (present.isEmpty) return;
  final loader = FontLoader(family);
  for (final path in present) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(
      Future<ByteData>.value(ByteData.sublistView(Uint8List.fromList(bytes))),
    );
  }
  await loader.load();
}

Future<void> _loadFonts() async {
  String sdk(String n) =>
      _sdkFonts.isEmpty ? '' : '$_sdkFonts${Platform.pathSeparator}$n';
  await _load('Roboto', [
    sdk('Roboto-Regular.ttf'),
    sdk('roboto-regular.ttf'),
    sdk('Roboto-Medium.ttf'),
    sdk('roboto-medium.ttf'),
    sdk('Roboto-Bold.ttf'),
    sdk('roboto-bold.ttf'),
  ]);
  await _load('MaterialIcons', [
    sdk('MaterialIcons-Regular.otf'),
    sdk('materialicons-regular.otf'),
  ]);
  await _load('Inter', [
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Bold.ttf',
  ]);
  await _load('Tajawal', [
    'assets/fonts/Tajawal-Regular.ttf',
    'assets/fonts/Tajawal-Bold.ttf',
  ]);
}

ThemeData _theme() => ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      fontFamilyFallback: const ['Tajawal', 'Roboto'],
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    );

const _roles = <String, List<String>>{
  'line-manager': RoleProfiles.lineManager,
  'moderator': RoleProfiles.moderator,
  'staff': RoleProfiles.staff,
  'manager': RoleProfiles.manager,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();
  setUpAll(_loadFonts);

  for (final lang in const ['en', 'ar']) {
    for (final entry in _roles.entries) {
      testWidgets('menu — ${entry.key} [$lang]', (tester) async {
        tester.view.physicalSize = const Size(390, 1100);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final key = GlobalKey<ScaffoldState>();
        await tester.pumpWidget(
          ProviderScope(
            overrides: roleDrawerOverrides(entry.value),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: Locale(lang),
              theme: _theme(),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                key: key,
                body: const SizedBox.expand(),
                drawer: const AppDrawer(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        key.currentState!.openDrawer();
        await tester.pumpAndSettle();

        final headers = find.descendant(
          of: find.byType(AppDrawer),
          matching: find.byType(ExpansionTile),
        );
        final count = tester.widgetList(headers).length;
        for (var i = 0; i < count; i++) {
          final tile = tester.widget<ExpansionTile>(headers.at(i));
          if (!(tile.controller?.isExpanded ?? false)) {
            await tester.tap(find
                .descendant(of: headers.at(i), matching: find.byType(ListTile))
                .first);
            await tester.pumpAndSettle();
          }
          // Scroll the drawer back to the top so every shot frames the same way.
          await tester.drag(find.byType(ListView).last, const Offset(0, 2000));
          await tester.pumpAndSettle();
          await expectLater(
            find.byType(AppDrawer),
            matchesGoldenFile(
              'shots/role-menus/${entry.key}/$lang/group-$i.png',
            ),
          );
        }
      });
    }
  }
}
