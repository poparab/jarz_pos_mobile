import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'printer_compatibility.dart';
import 'printer_status.dart';

/// Data class for a printable invoice item (shared across mobile & web).
class PrintableInvoiceItem {
  final String name;
  final double qty;
  final double rate;
  final double amount;
  final bool showPricing;
  final int indentLevel;
  final bool bold;
  final String? description;
  PrintableInvoiceItem({
    required this.name,
    required this.qty,
    required this.rate,
    double? amount,
    this.showPricing = true,
    this.indentLevel = 0,
    this.bold = false,
    this.description,
  }) : amount = amount ?? qty * rate;
}

/// Data class for a printable invoice (shared across mobile & web).
class PrintableInvoice {
  final String id;
  final DateTime date;
  final String customer;
  final String? customerAddress;
  final String? customerPhone;
  final String? territory;
  final DateTime? deliveryDateTime;
  final double total;
  final double paid;
  final double outstanding;
  final double shipping;
  final List<PrintableInvoiceItem> items;
  final String? orderNo;
  final String? paymentMethod;
  final String? orderDate;
  final String? deliveryTimeRange;
  final String? deliveryDateFormatted;
  // True when outstanding moved to courier outstanding account but courier hasn't remitted yet.
  final bool hasUnsettledCourierTxn;
  PrintableInvoice({
    required this.id,
    required this.date,
    required this.customer,
    this.customerAddress,
    this.customerPhone,
    this.territory,
    this.deliveryDateTime,
    required this.total,
    required this.paid,
    required this.outstanding,
    this.shipping = 0.0,
    required this.items,
    this.orderNo,
    this.paymentMethod,
    this.orderDate,
    this.deliveryTimeRange,
    this.deliveryDateFormatted,
    this.hasUnsettledCourierTxn = false,
  });
}

/// Web stub for PosPrinterService.
///
/// Bluetooth printing is not available in web browsers.
/// All methods are safe no-ops that report not available.
class PosPrinterService extends ChangeNotifier {
  PosPrinterService({Dio? dio, bool autoInit = true});

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
  Future<String> buildReceiptPreview(PrintableInvoice inv) async => 'Printing is not available on web.';
}

/// Print result enum (must mirror the one in pos_printer_service.dart).
enum PrintResult { success, disconnected, failed }
