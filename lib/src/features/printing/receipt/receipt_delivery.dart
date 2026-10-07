// Getting a receipt or statement off the device: the image handed to WhatsApp
// or the OS share sheet, shared by the order card and the credit account
// screen.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'receipt_share.dart';

/// A rendered receipt or statement and the file name it travels under.
///
/// The name is kept here rather than on an `XFile`: `XFile.fromData` on
/// Android drops it, and the image would reach WhatsApp as a random name.
class ReceiptImage {
  const ReceiptImage(this.png, this.fileName);
  final Uint8List png;
  final String fileName;

  XFile get xFile => XFile.fromData(png, name: fileName, mimeType: 'image/png');
}

/// [png] as `<name>.png`.
ReceiptImage receiptImageFile(Uint8List png, String name) => ReceiptImage(png, '$name.png');

const MethodChannel _whatsAppChannel = MethodChannel('jarz/whatsapp_share');

/// Sends a receipt or statement as images, to WhatsApp or the share sheet.
///
/// [toWhatsApp] on Android hands [files] straight to WhatsApp, which opens
/// its own "Send to" list — every chat and every group — so the cashier
/// picks who gets it. With [whatsappPhone] it opens that number's chat
/// instead. Everywhere else (web, no WhatsApp on the device, an install that
/// predates the native channel) the images go to the OS share sheet, where
/// WhatsApp is one of the targets and the same "Send to" list follows.
///
/// [text] is only for when there are no images to send (the render failed):
/// WhatsApp then gets it composed through wa.me, the share sheet as text.
///
/// When the share sheet cannot open — a browser refuses once the tap that
/// started the send has been spent loading the invoice — a snackbar offers a
/// retry, which is a fresh tap. That retry downloads the image in a browser
/// that cannot share files at all, so the cashier can still attach it.
Future<void> deliverReceipt({
  required ScaffoldMessengerState messenger,
  required List<ReceiptImage> files,
  required String caption,
  required String text,
  required bool toWhatsApp,
  String? whatsappPhone,
  required String failureMessage,
  required String retryLabel,
}) async {
  if (files.isEmpty) {
    if (toWhatsApp) {
      await openWhatsAppOrOfferRetry(
        messenger: messenger,
        uri: whatsappReceiptUri(whatsappPhone, text),
        failureMessage: failureMessage,
        retryLabel: retryLabel,
      );
      return;
    }
    if (await shareReceiptContent(text: text)) return;
    await openWhatsAppOrOfferRetry(
      messenger: messenger,
      uri: whatsappReceiptUri(null, text),
      failureMessage: failureMessage,
      retryLabel: retryLabel,
    );
    return;
  }

  if (toWhatsApp && await sendImagesToWhatsApp(files, caption: caption, phone: whatsappPhone)) return;
  if (await shareReceiptContent(files: files, text: caption, downloadFallback: false)) return;
  messenger.showSnackBar(
    SnackBar(
      content: Text(failureMessage),
      duration: const Duration(seconds: 8),
      action: SnackBarAction(
        label: retryLabel,
        onPressed: () => shareReceiptContent(files: files, text: caption),
      ),
    ),
  );
}

/// Opens WhatsApp on Android with [files] attached. False when that is not
/// possible here, so the caller falls back to the share sheet.
@visibleForTesting
Future<bool> sendImagesToWhatsApp(List<ReceiptImage> files, {required String caption, String? phone}) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
  final msisdn = whatsappMsisdn(phone);
  try {
    final outcome = await _whatsAppChannel.invokeMethod<String>('shareImages', {
      'images': [for (final f in files) f.png],
      'names': [for (final f in files) f.fileName],
      'caption': caption,
      if (msisdn.isNotEmpty) 'jid': '$msisdn@s.whatsapp.net',
    });
    return outcome == 'sent';
  } on MissingPluginException {
    return false;
  } catch (e) {
    debugPrint('[ReceiptDelivery] WhatsApp image send failed: $e');
    return false;
  }
}

/// Hands [files] to the OS share sheet with [text] as the caption, or [text]
/// alone when there are no files. Returns false when sharing threw — no share
/// plugin on this install, no Web Share API in this browser, or a browser
/// that refused because the tap's gesture was spent. [downloadFallback] lets
/// a browser without file sharing download the files instead.
Future<bool> shareReceiptContent({
  List<ReceiptImage> files = const [],
  required String text,
  bool downloadFallback = true,
}) async {
  try {
    await SharePlus.instance.share(
      files.isNotEmpty
          ? ShareParams(
              files: [for (final f in files) f.xFile],
              fileNameOverrides: [for (final f in files) f.fileName],
              text: text,
              downloadFallbackEnabled: downloadFallback,
            )
          : ShareParams(text: text),
    );
    return true;
  } catch (e) {
    debugPrint('[ReceiptDelivery] share failed: $e');
    return false;
  }
}

/// Launches the wa.me [uri]; on failure says so, with a tap-to-open action.
///
/// The action is not decoration: a browser (iPhone Safari above all) refuses
/// to open a window once the tap that started the send is spent, and loading
/// the invoices in between spends it. Tapping the action is a fresh gesture.
Future<void> openWhatsAppOrOfferRetry({
  required ScaffoldMessengerState messenger,
  required Uri uri,
  required String failureMessage,
  required String retryLabel,
}) async {
  Future<bool> launch() async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[ReceiptDelivery] WhatsApp launch failed: $e');
      return false;
    }
  }

  if (await launch()) return;
  messenger.showSnackBar(
    SnackBar(
      content: Text(failureMessage),
      duration: const Duration(seconds: 8),
      action: SnackBarAction(label: retryLabel, onPressed: launch),
    ),
  );
}
