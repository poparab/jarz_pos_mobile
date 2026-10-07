import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_endpoints.dart';
import 'printer_compatibility.dart';
import 'printer_status.dart';
import 'receipt/receipt_branding.dart';
import 'receipt/receipt_canvas_renderer.dart';
import 'receipt/receipt_statement.dart';

export 'printable_models.dart';
import 'printable_models.dart';

/// Web stub for PosPrinterService.
///
/// Bluetooth printing is not available in web browsers.
/// All methods are safe no-ops that report not available.
class PosPrinterService extends ChangeNotifier {
  PosPrinterService({Dio? dio, bool autoInit = true}) : _dio = dio;

  final Dio? _dio;
  ReceiptBranding? _branding;

  final PrinterCompatibilitySettings compatibilitySettings =
      PrinterCompatibilitySettings();

  // Status always disconnected on web
  PrinterUnifiedStatus get unifiedStatus => PrinterUnifiedStatus.disconnected;
  String? get lastErrorMessage => 'Printing is not available on web';

  // Connection state
  bool get isConnected => false;
  bool get isClassicConnected => false;
  dynamic get selectedDevice => null;
  dynamic get classicDevice => null;
  String? get lastPrinterId => null;
  String? get lastPrinterType => null;
  List<dynamic> get classicBonded => const [];

  // Scan
  Stream<List<dynamic>> get scanStream => const Stream.empty();
  bool get isScanning => false;
  Future<void> startScan({Duration timeout = const Duration(seconds: 4)}) async {}
  Future<void> stopScan() async {}

  // Connect / disconnect
  Future<bool> connectLastSaved() async => false;
  Future<bool> connectById(String id) async => false;
  Future<bool> connect(dynamic device) async => false;
  Future<bool> connectClassic(dynamic device) async => false;
  Future<void> disconnect() async {}
  Future<void> disconnectClassic() async {}
  Future<void> forgetPrinter() async {}
  Future<void> updateCompatibilitySettings(PrinterCompatibilitySettings settings) async {}
  Future<void> resetCompatibilitySettings() async {}

  // Permissions
  Future<Map<String, dynamic>> permissionStatuses() async => {};

  // Printing
  Future<PrintResult> testPrint() async => PrintResult.disconnected;
  Future<PrintResult> printInvoice(PrintableInvoice inv) async => PrintResult.disconnected;
  Future<PrintResult> printBatchSheet(PrintableBatchSheet sheet) async => PrintResult.disconnected;
  Future<String> buildReceiptPreview(PrintableInvoice inv) async => 'Printing is not available on web.';

  // Sharing: the web share path sends the text receipt only.
  /// The shop lines from `get_receipt_config`, as the mobile service uses
  /// them, so a receipt sent from the web says the same as one sent from a
  /// phone. Falls back to the defaults field by field, once per session.
  Future<ReceiptBranding> receiptBranding() async {
    if (_branding != null) return _branding!;
    const d = ReceiptBranding.defaults();
    String pick(Object? v, String fallback) {
      final t = (v ?? '').toString().replaceAll(RegExp(r'\s+'), ' ').trim();
      return t.isNotEmpty ? t : fallback;
    }

    try {
      final message = (await _dio?.get(ApiEndpoints.getReceiptConfig))?.data['message'];
      if (message is Map) {
        return _branding = ReceiptBranding(
          header: pick(message['header'], d.header),
          footer: pick(message['footer'], d.footer),
          phone: pick(message['phone'], d.phone),
          website: pick(message['website'], d.website),
        );
      }
    } catch (e) {
      debugPrint('[PosPrinterService/web] receipt config fetch failed, using defaults: $e');
    }
    return d;
  }

  /// The receipt as a PNG — the same canvas the Android app prints and
  /// shares, so a receipt sent from the browser looks like one sent from
  /// the phone.
  Future<Uint8List> renderReceiptPng(PrintableInvoice inv) async {
    final b = await receiptBranding();
    return ReceiptCanvasRenderer.renderPng(
      inv: inv,
      header: b.header,
      footer: b.footer,
      phone: b.phone,
      website: b.website,
    );
  }

  /// A consolidated statement of several orders as a PNG, for sharing.
  Future<Uint8List> renderStatementPng(PrintableStatement statement) async {
    final b = await receiptBranding();
    return ReceiptCanvasRenderer.renderStatementPng(
      statement: statement,
      footer: b.footer,
      phone: b.phone,
      website: b.website,
    );
  }
}

/// Print result enum (must mirror the one in pos_printer_service.dart).
enum PrintResult { success, disconnected, failed }
