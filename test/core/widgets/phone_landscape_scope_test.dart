import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/widgets/global_orientation_enforcer.dart';

void main() {
  testWidgets(
    'leaving a landscape route resets the policy without reading a disposed widget ref',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final visible = ValueNotifier(true);
      addTearDown(visible.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ValueListenableBuilder<bool>(
              valueListenable: visible,
              builder: (_, show, _) => show
                  ? const PhoneLandscapeScope(child: SizedBox())
                  : const SizedBox(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(container.read(allowPhoneLandscapeProvider), isTrue);
      visible.value = false;
      await tester.pumpAndSettle();
      expect(container.read(allowPhoneLandscapeProvider), isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
