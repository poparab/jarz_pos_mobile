import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'localization_extensions.dart';

const String localeSettingsBoxName = 'app_settings';
const String _localeStorageKey = 'preferred_locale';

Locale? _localeFromCode(String? code) {
  if (code == null || code.isEmpty) return null;
  return Locale(code);
}

Locale? _loadInitialLocale(Box box) {
  final stored = box.get(_localeStorageKey) as String?;
  return _localeFromCode(stored);
}

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier(this._box) : super(_loadInitialLocale(_box));

  final Box _box;

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _box.delete(_localeStorageKey);
    } else {
      await _box.put(_localeStorageKey, locale.languageCode);
    }
    state = locale;
  }
}

final localeNotifierProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final box = Hive.box(localeSettingsBoxName);
  return LocaleNotifier(box);
});

const supportedLocales = <Locale>[
  Locale('en'),
  Locale('ar'),
];

String describeLocale(BuildContext context, Locale locale) {
  switch (locale.languageCode) {
    case 'ar':
      return context.l10n.menuLanguageArabic;
    default:
      return context.l10n.menuLanguageEnglish;
  }
}
