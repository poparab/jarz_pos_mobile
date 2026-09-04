import 'dart:typed_data';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/instapay_reconciliation/data/models/unconfirmed_online_order.dart';
import 'package:jarz_pos/src/features/instapay_reconciliation/presentation/widgets/confirm_payment_sheet.dart';
import 'package:jarz_pos/src/features/kanban/providers/kanban_provider.dart';

Future<void> _pumpHost(
  WidgetTester tester,
  Future<bool?>? Function() openSheet, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => openSheet(),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

UnconfirmedOnlineOrder _order({
  String? receiptName,
  String? receiptImageUrl,
  String? receiptStatus,
}) {
  return UnconfirmedOnlineOrder(
    invoice: 'INV-0001',
    customer: 'CUST-0001',
    customerName: 'Test Customer',
    amount: 150,
    paymentMethod: 'Instapay',
    receiptName: receiptName,
    receiptStatus: receiptStatus,
    receiptImageUrl: receiptImageUrl,
    canConfirm: true,
  );
}

ElevatedButton _confirmButton(WidgetTester tester) {
  return tester.widget<ElevatedButton>(
    find.widgetWithText(ElevatedButton, 'Confirm received'),
  );
}

void main() {
  group('ConfirmPaymentSheet gating', () {
    testWidgets(
      'Confirm stays disabled without a receipt even after a reference is typed',
      (tester) async {
        await _pumpHost(tester, () {
          return ConfirmPaymentSheet.show(
            tester.element(find.text('open')),
            order: _order(), // no receipt attached
            posProfile: 'Nasr City',
          );
        });

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        // Initially disabled (no receipt, no reference).
        expect(_confirmButton(tester).onPressed, isNull);

        // Typing a reference is not enough without a receipt screenshot.
        await tester.enterText(find.byType(TextField), 'REF-123');
        await tester.pumpAndSettle();
        expect(_confirmButton(tester).onPressed, isNull);
      },
    );

    testWidgets(
      'Confirm enables only once BOTH a receipt and a reference are present',
      (tester) async {
        await _pumpHost(tester, () {
          return ConfirmPaymentSheet.show(
            tester.element(find.text('open')),
            order: _order(
              receiptName: 'PPR-0001',
              receiptImageUrl: '/files/receipt.png',
            ),
            posProfile: 'Nasr City',
          );
        });

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        // Receipt present but no reference yet → still disabled.
        expect(_confirmButton(tester).onPressed, isNull);

        // Add the bank reference → now enabled.
        await tester.enterText(find.byType(TextField), 'REF-123');
        await tester.pumpAndSettle();
        expect(_confirmButton(tester).onPressed, isNotNull);
      },
    );

    testWidgets(
      'an unconfirmed receipt can be replaced or removed',
      (tester) async {
        await _pumpHost(tester, () {
          return ConfirmPaymentSheet.show(
            tester.element(find.text('open')),
            order: _order(
              receiptName: 'PPR-0001',
              receiptImageUrl: '/files/receipt.png',
              receiptStatus: 'Unconfirmed',
            ),
            posProfile: 'Nasr City',
          );
        });

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(find.text('Replace Image'), findsOneWidget);
        expect(find.text('Remove Image'), findsOneWidget);
        expect(find.text('Upload Receipt Image'), findsNothing);
      },
    );

    testWidgets(
      'a confirmed receipt is frozen — no replace, no remove',
      (tester) async {
        await _pumpHost(tester, () {
          return ConfirmPaymentSheet.show(
            tester.element(find.text('open')),
            order: _order(
              receiptName: 'PPR-0001',
              receiptImageUrl: '/files/receipt.png',
              receiptStatus: 'Confirmed',
            ),
            posProfile: 'Nasr City',
          );
        });

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(find.text('Replace Image'), findsNothing);
        expect(find.text('Remove Image'), findsNothing);
        expect(find.text('Upload Receipt Image'), findsNothing);
        expect(find.text('Preview'), findsOneWidget);
      },
    );

    // Production, money path: a picker handed back a zero-byte file, so
    // `image_data` went up as ''. The backend answered "File does not exist"
    // and the sheet still showed success — an InstaPay payment confirmed with
    // no proof attached to it.
    testWidgets(
      'a zero-byte pick shows the retry message and does not call upload',
      (tester) async {
        // Swap the picker's platform implementation for one that returns a
        // zero-byte pick — exactly what a revoked permission, an unreadable
        // cloud/HEIC asset or a cancelled camera write hands back.
        final original = ImagePickerPlatform.instance;
        ImagePickerPlatform.instance = _EmptyPickImagePickerPlatform();
        addTearDown(() => ImagePickerPlatform.instance = original);

        final kanban = _RecordingKanbanNotifier();

        await _pumpHost(
          tester,
          () {
            return ConfirmPaymentSheet.show(
              tester.element(find.text('open')),
              // Receipt row already exists, so `_ensureReceiptRecord` short
              // circuits and the only server call left in the flow is upload.
              order: _order(
                receiptName: 'PPR-0001',
                receiptStatus: 'Unconfirmed',
              ),
              posProfile: 'Nasr City',
            );
          },
          overrides: [kanbanProvider.overrideWith((ref) => kanban)],
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        // `ElevatedButton.icon` builds a private subclass, so `byType` will not
        // match it; the label Text is the reliable handle. The first match is
        // the card header, the second is the button.
        await tester.tap(find.text('Upload Receipt Image').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Gallery'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            "Couldn't read that photo. Try again, or pick a different one.",
          ),
          findsOneWidget,
        );
        // The whole point: no empty payload ever left the device.
        expect(kanban.uploadCalls, 0);
        // And the sheet is usable again rather than stuck on its busy flags —
        // the progress bar only renders while `_isBusy` is true.
        expect(find.byType(LinearProgressIndicator), findsNothing);
      },
    );
  });
}

/// Inert stand-in for the real KanbanNotifier, whose constructor opens sockets
/// and arms polling timers. Only the upload call matters here, and any other
/// server call reaching it is a test failure by way of NoSuchMethodError.
class _RecordingKanbanNotifier extends StateNotifier<KanbanState>
    implements KanbanNotifier {
  _RecordingKanbanNotifier() : super(KanbanState());

  int uploadCalls = 0;

  @override
  Future<Map<String, dynamic>?> uploadReceiptImage({
    required String receiptName,
    required String imageData,
    required String filename,
  }) async {
    uploadCalls++;
    return {'file_url': '/files/receipt.png', 'status': 'Unconfirmed'};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Hands back a pick with no bytes in it.
class _EmptyPickImagePickerPlatform extends ImagePickerPlatform {
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return XFile.fromData(
      Uint8List(0),
      name: 'receipt.png',
      mimeType: 'image/png',
    );
  }
}
