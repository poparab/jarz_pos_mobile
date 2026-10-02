import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/widgets/item_title_with_arabic.dart';

/// The purchase item lists show the Arabic name under the English one, small
/// and muted, and nothing extra when the server has no Arabic name to send.
void main() {
  Future<void> pump(WidgetTester tester, Object? arabic) {
    return tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ItemTitleWithArabic(title: 'powder sugar', arabicName: arabic),
      ),
    ));
  }

  testWidgets('shows the Arabic name under the title in smaller type',
      (tester) async {
    await pump(tester, 'سكر بودرة');

    expect(find.text('powder sugar'), findsOneWidget);
    final arabic = find.text('سكر بودرة');
    expect(arabic, findsOneWidget);
    expect(
      tester.getTopLeft(arabic).dy,
      greaterThan(tester.getTopLeft(find.text('powder sugar')).dy),
      reason: 'the Arabic name sits below the title',
    );

    final titleSize = tester.widget<Text>(find.text('powder sugar')).style?.fontSize ??
        DefaultTextStyle.of(tester.element(find.text('powder sugar'))).style.fontSize!;
    final arabicSize = tester.widget<Text>(arabic).style!.fontSize!;
    expect(arabicSize, lessThan(titleSize));
  });

  testWidgets('a missing, null or blank Arabic name adds no line',
      (tester) async {
    for (final value in <Object?>[null, '', '   ']) {
      await pump(tester, value);
      expect(find.byType(Text), findsOneWidget, reason: 'value: $value');
      expect(find.byType(Column), findsNothing);
    }
  });
}
