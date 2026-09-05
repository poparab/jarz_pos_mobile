import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/pos/data/models/draft_cart.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/draft_cart_repository.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import 'package:jarz_pos/src/features/pos/presentation/widgets/checkout_button_widget.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';

class _Drafts extends DraftCartRepository {
  @override
  Future<List<DraftCart>> loadAll() async => [];
}

class _Checkout extends PosNotifier {
  _Checkout({required this.fail}) : super(PosRepository(Dio()), _Drafts()) {
    state = PosState(
      selectedProfile: {'name': 'Main'},
      cartItems: [
        {'item_code': 'ITEM', 'quantity': 1, 'rate': 10},
      ],
    );
  }

  final bool fail;

  @override
  List<Map<String, dynamic>> getCartItemsExceedingStock() => [];

  @override
  Future<void> checkout({
    String? paymentType,
    String? overridePosProfileName,
    String? paymentMethod,
    bool posProfileOverride = false,
  }) async {
    // The real notifier returns normally after recording a failed submission.
    state = state.copyWith(
      error: fail ? 'DioException: Traceback SELECT * FROM tabInvoice' : null,
      cartItems: fail ? state.cartItems : [],
      clearError: !fail,
      isLoading: false,
    );
  }
}

void main() {
  for (final locale in ['ar', 'en']) {
    for (final fail in [true, false]) {
      testWidgets(
        'checkout $locale only reports success when submission succeeds ($fail)',
        (tester) async {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                posNotifierProvider.overrideWith(
                  (ref) => _Checkout(fail: fail),
                ),
              ],
              child: MaterialApp(
                locale: Locale(locale),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const Scaffold(body: CheckoutButtonWidget()),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final l10n = AppLocalizations.of(
            tester.element(find.byType(CheckoutButtonWidget)),
          );
          await tester.tap(find.text(l10n.checkoutPay));
          await tester.pumpAndSettle();

          expect(
            find.text(l10n.checkoutOrderSuccess),
            fail ? findsNothing : findsOneWidget,
          );
          expect(find.textContaining('DioException'), findsNothing);
          expect(find.textContaining('SELECT *'), findsNothing);
          expect(tester.takeException(), isNull);
          if (fail) {
            final visible = tester
                .widgetList<Text>(
                  find.descendant(
                    of: find.byType(SnackBar),
                    matching: find.byType(Text),
                  ),
                )
                .map((text) => text.data ?? '')
                .join(' ');
            expect(visible, isNotEmpty);
            if (locale == 'ar')
              expect(visible, matches(RegExp(r'[\u0600-\u06ff]')));
          }
        },
      );
    }
  }
}
