import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/localization/locale_notifier.dart';

void main() {
  group('LocaleNotifier', () {
    test('should start with no locale when storage is unavailable', () {
      // Arrange
      final sut = LocaleNotifier(null);

      // Assert
      expect(sut.state, isNull);
    });

    test('should update in-memory state when storage is unavailable', () async {
      // Arrange
      final sut = LocaleNotifier(null);

      // Act
      await sut.setLocale(const Locale('ar'));

      // Assert
      expect(sut.state, const Locale('ar'));
    });
  });
}