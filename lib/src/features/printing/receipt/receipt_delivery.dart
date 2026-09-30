// Getting a receipt or statement off the device: the wa.me launch and the OS
// share sheet, shared by the order card and the credit account screen.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// A rendered receipt or statement, as a file the share sheet can carry.
XFile receiptImageFile(Uint8List png, String name) =>
    XFile.fromData(png, name: '$name.png', mimeType: 'image/png');

/// Hands [files] to the OS share sheet with [text] as the caption, or [text]
/// alone when there are no files. Returns false when sharing threw — no share
/// plugin on this install, or no Web Share API in this browser — so the
/// caller can fall back to WhatsApp.
Future<bool> shareReceiptContent({List<XFile> files = const [], required String text}) async {
  try {
    await SharePlus.instance.share(
      files.isNotEmpty ? ShareParams(files: files, text: text) : ShareParams(text: text),
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
