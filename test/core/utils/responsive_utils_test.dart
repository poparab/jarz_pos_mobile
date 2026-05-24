import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/utils/responsive_utils.dart';

class _ResponsiveSnapshot {
  const _ResponsiveSnapshot({
    required this.isPhone,
    required this.isPhonePortrait,
    required this.isPhoneLandscape,
    required this.itemColumns,
    required this.bundleColumns,
    required this.kanbanColumnWidth,
    required this.dialogWidth,
    required this.dialogHeight,
    required this.cartSheetInitialSize,
    required this.cartSheetMinSize,
  });

  final bool isPhone;
  final bool isPhonePortrait;
  final bool isPhoneLandscape;
  final int itemColumns;
  final int bundleColumns;
  final double kanbanColumnWidth;
  final double dialogWidth;
  final double dialogHeight;
  final double cartSheetInitialSize;
  final double cartSheetMinSize;
}

Future<_ResponsiveSnapshot> _captureResponsiveSnapshot(
  WidgetTester tester,
  Size logicalSize,
) async {
  tester.view.physicalSize = logicalSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  late _ResponsiveSnapshot snapshot;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          snapshot = _ResponsiveSnapshot(
            isPhone: ResponsiveUtils.isPhone(context),
            isPhonePortrait: ResponsiveUtils.isPhonePortrait(context),
            isPhoneLandscape: ResponsiveUtils.isPhoneLandscape(context),
            itemColumns: ResponsiveUtils.getItemGridColumns(context),
            bundleColumns: ResponsiveUtils.getBundleGridColumns(context),
            kanbanColumnWidth: ResponsiveUtils.getKanbanColumnWidth(context),
            dialogWidth: ResponsiveUtils.getDialogWidth(context),
            dialogHeight: ResponsiveUtils.getDialogHeight(context),
            cartSheetInitialSize: ResponsiveUtils.getCartBottomSheetInitialSize(context),
            cartSheetMinSize: ResponsiveUtils.getCartBottomSheetMinSize(context),
          );
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return snapshot;
}

void main() {
  group('ResponsiveUtils', () {
    testWidgets('should classify flagship phone portrait viewports as phones', (tester) async {
      final s25Ultra = await _captureResponsiveSnapshot(tester, const Size(432, 960));
      final iPhone15ProMax = await _captureResponsiveSnapshot(tester, const Size(430, 932));

      expect(s25Ultra.isPhone, isTrue);
      expect(s25Ultra.isPhonePortrait, isTrue);
      expect(s25Ultra.isPhoneLandscape, isFalse);
      expect(s25Ultra.itemColumns, 3);
      expect(s25Ultra.bundleColumns, 2);
      expect(s25Ultra.kanbanColumnWidth, 400);
      expect(s25Ultra.dialogWidth, closeTo(397.44, 0.001));
      expect(s25Ultra.dialogHeight, 720);
      expect(s25Ultra.cartSheetInitialSize, 0.72);
      expect(s25Ultra.cartSheetMinSize, 0.45);

      expect(iPhone15ProMax.isPhone, isTrue);
      expect(iPhone15ProMax.isPhonePortrait, isTrue);
      expect(iPhone15ProMax.isPhoneLandscape, isFalse);
      expect(iPhone15ProMax.itemColumns, 3);
      expect(iPhone15ProMax.bundleColumns, 2);
      expect(iPhone15ProMax.kanbanColumnWidth, 398);
      expect(iPhone15ProMax.dialogWidth, closeTo(395.6, 0.001));
      expect(iPhone15ProMax.dialogHeight, 720);
      expect(iPhone15ProMax.cartSheetInitialSize, 0.72);
      expect(iPhone15ProMax.cartSheetMinSize, 0.45);
    });

    testWidgets('should classify flagship phone landscape viewports as phones', (tester) async {
      final s25Ultra = await _captureResponsiveSnapshot(tester, const Size(960, 432));
      final iPhone15ProMax = await _captureResponsiveSnapshot(tester, const Size(932, 430));

      expect(s25Ultra.isPhone, isTrue);
      expect(s25Ultra.isPhonePortrait, isFalse);
      expect(s25Ultra.isPhoneLandscape, isTrue);
      expect(s25Ultra.itemColumns, 5);
      expect(s25Ultra.bundleColumns, 3);
      expect(s25Ultra.kanbanColumnWidth, 420);
      expect(s25Ultra.dialogWidth, 400);
      expect(s25Ultra.dialogHeight, closeTo(354.24, 0.001));
      expect(s25Ultra.cartSheetInitialSize, 0.86);
      expect(s25Ultra.cartSheetMinSize, 0.62);

      expect(iPhone15ProMax.isPhone, isTrue);
      expect(iPhone15ProMax.isPhonePortrait, isFalse);
      expect(iPhone15ProMax.isPhoneLandscape, isTrue);
      expect(iPhone15ProMax.itemColumns, 5);
      expect(iPhone15ProMax.bundleColumns, 3);
      expect(iPhone15ProMax.kanbanColumnWidth, 420);
      expect(iPhone15ProMax.dialogWidth, 400);
      expect(iPhone15ProMax.dialogHeight, closeTo(352.6, 0.001));
      expect(iPhone15ProMax.cartSheetInitialSize, 0.86);
      expect(iPhone15ProMax.cartSheetMinSize, 0.62);
    });

    testWidgets('should preserve tablet and desktop sizing decisions', (tester) async {
      final tablet = await _captureResponsiveSnapshot(tester, const Size(800, 1280));
      final desktop = await _captureResponsiveSnapshot(tester, const Size(1440, 900));

      expect(tablet.isPhone, isFalse);
      expect(tablet.isPhonePortrait, isFalse);
      expect(tablet.isPhoneLandscape, isFalse);
      expect(tablet.itemColumns, 2);
      expect(tablet.bundleColumns, 2);
      expect(tablet.kanbanColumnWidth, 300);
      expect(tablet.dialogWidth, 400);
      expect(tablet.dialogHeight, 720);
      expect(tablet.cartSheetInitialSize, 0.7);
      expect(tablet.cartSheetMinSize, 0.5);

      expect(desktop.isPhone, isFalse);
      expect(desktop.isPhonePortrait, isFalse);
      expect(desktop.isPhoneLandscape, isFalse);
      expect(desktop.itemColumns, 5);
      expect(desktop.bundleColumns, 4);
      expect(desktop.kanbanColumnWidth, 300);
      expect(desktop.dialogWidth, 640);
      expect(desktop.dialogHeight, 648);
      expect(desktop.cartSheetInitialSize, 0.7);
      expect(desktop.cartSheetMinSize, 0.5);
    });
  });
}