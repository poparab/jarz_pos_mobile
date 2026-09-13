import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/purchase/presentation/widgets/line_rate_field.dart';

/// Picking another UOM re-prices a cart line. The rate box used to read its
/// value once, so it kept showing the old rate while the new one was totalled
/// and sent.
void main() {
  late double rate;

  Future<void Function(double)> pump(WidgetTester tester) async {
    rate = 120;
    late StateSetter setRate;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(builder: (context, setState) {
          setRate = setState;
          return LineRateField(
            rate: rate,
            onChanged: (r) => setState(() => rate = r),
          );
        }),
      ),
    ));
    return (value) => setRate(() => rate = value);
  }

  String shown(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText)).controller.text;

  testWidgets('shows the rate it was built with', (tester) async {
    await pump(tester);
    expect(shown(tester), '120.00');
  });

  testWidgets('follows a rate changed from outside, as a UOM change does',
      (tester) async {
    final changeRate = await pump(tester);
    changeRate(10);
    await tester.pump();
    expect(shown(tester), '10.00');
  });

  testWidgets('typing sets the rate without being rewritten under the cursor',
      (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextFormField), '12.5');
    await tester.pump();
    expect(rate, 12.5);
    expect(shown(tester), '12.5');
  });

  testWidgets('clearing the box keeps the last rate', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextFormField), '');
    await tester.pump();
    expect(rate, 120);
    expect(shown(tester), '');
  });
}
