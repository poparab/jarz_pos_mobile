import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:jarz_pos/src/core/printer/classic_printer_channel.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/timing_config.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/constants/business_constants.dart';
import '../../core/constants/api_endpoints.dart';
import 'package:permission_handler/permission_handler.dart';
import 'printer_status.dart';

class PrintableInvoiceItem {
  final String name;
  final double qty;
  final double rate;
  final double amount;
  PrintableInvoiceItem({required this.name, required this.qty, required this.rate}) : amount = qty * rate;
}

class PrintableInvoice {
  final String id;
  final DateTime date;
  final String customer;
  final String? customerAddress;
  final String? customerPhone;
  final String? territory;
  final DateTime? deliveryDateTime;
  final double total; // Grand total (ERPNext Sales Invoice grand_total) INCLUDING shipping income
  final double paid;
  final double outstanding;
  final double shipping; // Shipping income component (single source of truth from Sales Invoice); do NOT add again to total
  final List<PrintableInvoiceItem> items;
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
  });
}

class PosPrinterService extends ChangeNotifier {
  PosPrinterService({Dio? dio, bool autoInit = true}) : _dio = dio {
    if (autoInit) {
      _init();
    }
  }

  final Dio? _dio;
  static const String _defaultReceiptHeader = 'ORDER RECEIPT';
  static const String _defaultReceiptFooter = 'Thank you for Your Order';
  static const String _defaultReceiptPhone = '01061332266';
  static const String _defaultReceiptWebsite = 'www.orderjarz.com';

  String _receiptHeader = _defaultReceiptHeader;
  String _receiptFooter = _defaultReceiptFooter;
  String _receiptPhone = _defaultReceiptPhone;
  String _receiptWebsite = _defaultReceiptWebsite;
  String _receiptLogo = '';
  bool _receiptConfigLoaded = false;

  static const _prefsBoxName = HiveBoxes.printerPrefs;
  static const _lastPrinterKey = HiveKeys.lastPrinterId;
  static const _lastPrinterTypeKey = HiveKeys.lastPrinterType; // 'ble' | 'classic'

  Box? _prefsBox;
  bool _connecting = false;
  String? _lastError; // human-readable error for UI

  PrinterUnifiedStatus get unifiedStatus {
    if (_connecting) return PrinterUnifiedStatus.connecting;
    if (isConnected) return PrinterUnifiedStatus.connectedBle;
    if (isClassicConnected) return PrinterUnifiedStatus.connectedClassic;
    if (_lastError != null) return PrinterUnifiedStatus.error;
    return PrinterUnifiedStatus.disconnected;
  }
  String? get lastErrorMessage => _lastError;
  void _setError(String? msg) { _lastError = msg; notifyListeners(); }

  // BLE state
  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeChar;

  // Classic (SPP) state via custom MethodChannel
  ClassicBondedDevice? _classicDevice;
  bool _classicConnected = false;
  List<ClassicBondedDevice> _classicBonded = [];
  List<ClassicBondedDevice> get classicBonded => _classicBonded;

  // Pre-rendered ESC/POS bytes for logo (centered)
  Uint8List? _logoEscPos;

  // Scan stream (BLE only)
  final _scanController = StreamController<List<ScanResult>>.broadcast();
  Stream<List<ScanResult>> get scanStream => _scanController.stream;
  bool _isScanning = false;
  bool get isScanning => _isScanning;

  Future<void> startScan({Duration timeout = BluetoothTimeouts.defaultScan}) async {
    if (_isScanning) { try { await FlutterBluePlus.stopScan(); } catch (_) {} }
    await _ensurePermissions();
    final adapter = await FlutterBluePlus.adapterState.first;
    if (adapter != BluetoothAdapterState.on) {
      _scanController.add(const []);
      // Even if adapter off, still attempt to load bonded classic list for visibility
      await _loadClassicBonded();
      return;
    }
    _isScanning = true;
    _scanController.add(const []);
    // Pre-load classic bonded list immediately so UI can show it alongside BLE results
    unawaited(_loadClassicBonded());
    final startedAt = DateTime.now();
    late StreamSubscription<List<ScanResult>> sub;
    sub = FlutterBluePlus.scanResults.listen((r) {
      _scanController.add(List.unmodifiable(r));
      if (r.isNotEmpty) {
        debugPrint('[PosPrinterService] First BLE device(s) after ${DateTime.now().difference(startedAt).inMilliseconds}ms');
      }
    });
    try {
      await FlutterBluePlus.startScan(timeout: timeout, androidUsesFineLocation: true);
      await Future.delayed(timeout + const Duration(milliseconds: 200));
    } catch (e) {
      debugPrint('[PosPrinterService] startScan error: $e');
    } finally {
      try { await FlutterBluePlus.stopScan(); } catch (_) {}
      await sub.cancel();
      _isScanning = false;
      // Attempt silent reconnect if nothing appeared
      final last = lastPrinterId;
      if (last != null && !isConnected && !isClassicConnected) {
        if (lastPrinterType == 'ble') {
          unawaited(connectLastSaved());
        } else if (lastPrinterType == 'classic') {
          unawaited(_attemptClassicReconnect(last));
        }
      }
      // Always refresh classic bonded list at end
      await _loadClassicBonded();
    }
  }

  Future<void> _loadClassicBonded({bool forceNotify = false}) async {
    try {
      final list = await ClassicPrinterChannel.instance.getBondedDevices();
      // Only notify if changed or forced
      bool changed = list.length != _classicBonded.length;
      if (!changed) {
        for (int i = 0; i < list.length; i++) {
          if (list[i].mac != _classicBonded[i].mac) { changed = true; break; }
        }
      }
      if (changed) {
        _classicBonded = list;
        notifyListeners();
      } else if (forceNotify) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[PosPrinterService] classic list error: $e');
    }
  }

  Future<void> stopScan() async { if (_isScanning) { try { await FlutterBluePlus.stopScan(); } catch (_) {} _isScanning = false; } }

  Future<bool> connectLastSaved() async {
    final id = lastPrinterId; if (id == null) return false;
    if (lastPrinterType == 'classic') { return _attemptClassicReconnect(id).then((_) => isClassicConnected); }
    try { final dev = BluetoothDevice.fromId(id); return await connect(dev); } catch (_) { return false; }
  }

  Future<bool> connectById(String id) async { try { final dev = BluetoothDevice.fromId(id); return await connect(dev); } catch (_) { return false; } }

  Future<Map<String, PermissionStatus>> permissionStatuses() async => {
    'scan': await Permission.bluetoothScan.status,
    'connect': await Permission.bluetoothConnect.status,
    'location': await Permission.location.status,
  };

  Future<void> _ensurePermissions() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final req = <Permission>[];
    if (await Permission.bluetoothScan.status.isDenied) req.add(Permission.bluetoothScan);
    if (await Permission.bluetoothConnect.status.isDenied) req.add(Permission.bluetoothConnect);
    if (await Permission.location.status.isDenied) req.add(Permission.location);
    if (req.isNotEmpty) await req.request();
  }

  Future<void> _init() async {
    try {
      _prefsBox = await Hive.openBox(_prefsBoxName);
      await _loadReceiptConfig();
      // Prepare logo bytes in background (ignore errors)
      try { _logoEscPos = await _prepareLogoEscPos(); } catch (e) { debugPrint('[PosPrinterService] Logo prepare failed: $e'); }
      final id = lastPrinterId; final type = lastPrinterType;
      if (id != null && id.isNotEmpty) {
        if (type == 'ble') {
          unawaited(_attemptReconnect(BluetoothDevice.fromId(id)));
        } else if (type == 'classic') {
          unawaited(_attemptClassicReconnect(id));
        }
      }
    } catch (_) {}
  }

  String _normalizeOrDefault(String? value, String fallback) {
    final v = (value ?? '')
        .replaceAll(RegExp(r'[\u0000-\u001F\u007F]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return v.isNotEmpty ? v : fallback;
  }

  @visibleForTesting
  Future<Uint8List> buildReceiptBytesForTest(PrintableInvoice inv) => _buildReceipt(inv);

  Future<void> _loadReceiptConfig() async {
    if (_receiptConfigLoaded || _dio == null) return;
    try {
      final resp = await _dio.get(ApiEndpoints.getReceiptConfig);
      final message = resp.data['message'];
      if (message is Map) {
        final data = Map<String, dynamic>.from(message);
        _receiptHeader = _normalizeOrDefault(data['header']?.toString(), _defaultReceiptHeader);
        _receiptFooter = _normalizeOrDefault(data['footer']?.toString(), _defaultReceiptFooter);
        _receiptPhone = _normalizeOrDefault(data['phone']?.toString(), _defaultReceiptPhone);
        _receiptWebsite = _normalizeOrDefault(data['website']?.toString(), _defaultReceiptWebsite);
        _receiptLogo = (data['logo']?.toString() ?? '').trim();
      }
    } catch (e) {
      debugPrint('[PosPrinterService] Receipt config fetch failed, using defaults: $e');
    } finally {
      _receiptConfigLoaded = true;
    }
  }

  Future<String> buildReceiptPreview(PrintableInvoice inv) async {
    await _loadReceiptConfig();
    final sb = StringBuffer();
    final bool isPaid = inv.outstanding <= 0.0001;

    sb.writeln(_receiptHeader);
    sb.writeln('');
    sb.writeln('Customer: ${inv.customer}');
    if ((inv.customerPhone ?? '').isNotEmpty) {
      sb.writeln('Phone: ${inv.customerPhone}');
    }
    sb.writeln('Inv No: ${inv.id}');
    if (inv.deliveryDateTime != null) {
      sb.writeln('Delivery: ${inv.deliveryDateTime}');
    }
    if ((inv.customerAddress ?? '').isNotEmpty) {
      sb.writeln('Address: ${inv.customerAddress}');
    }
    sb.writeln('');

    for (final item in inv.items) {
      sb.writeln('${item.name} x${item.qty.toStringAsFixed(0)} @ ${_money(item.rate)} = ${_money(item.amount)}');
    }
    sb.writeln('');

    final grand = inv.total;
    if (inv.shipping > 0 && inv.shipping <= grand) {
      final subtotal = (grand - inv.shipping).clamp(0.0, grand).toDouble();
      sb.writeln('Subtotal: ${_money(subtotal)}');
      sb.writeln('Shipping: ${_money(inv.shipping)}');
    }
    sb.writeln('Total: ${_money(grand)}');
    sb.writeln('Status: ${isPaid ? InvoiceStatus.paidUpper : InvoiceStatus.unpaidUpper}');
    sb.writeln('');
    sb.writeln(_receiptFooter);
    sb.writeln('Call us $_receiptPhone');
    sb.writeln(_receiptWebsite);
    if (_receiptLogo.isNotEmpty) {
      sb.writeln('Logo: configured');
    }

    return sb.toString().trimRight();
  }

  Future<void> _attemptReconnect(BluetoothDevice device) async { final ok = await connect(device); if (!ok) { try { await _prefsBox?.delete(_lastPrinterKey); await _prefsBox?.delete(_lastPrinterTypeKey);} catch (_) {} } }
  Future<void> _attemptClassicReconnect(String addr) async {
    try {
      final bonded = await ClassicPrinterChannel.instance.getBondedDevices();
      final found = bonded.firstWhere((d) => d.mac == addr, orElse: () => throw 'nf');
      final ok = await connectClassic(found, save: false);
      if (!ok) { try { await _prefsBox?.delete(_lastPrinterKey); await _prefsBox?.delete(_lastPrinterTypeKey);} catch (_) {} }
    } catch (_) {}
  }

  Future<bool> connect(BluetoothDevice device) async {
    if (_connecting) return false; _connecting = true;
    try {
      _device = device;
      await device.connect(autoConnect: false, license: License.free).timeout(BluetoothTimeouts.connect, onTimeout: () => device.disconnect());
      await _discoverWriteCharacteristic(device);
      if (_writeChar != null) {
        try { await _prefsBox?.put(_lastPrinterKey, device.remoteId.str); await _prefsBox?.put(_lastPrinterTypeKey, 'ble'); } catch (_) {}
        _setError(null);
        notifyListeners(); return true;
      }
      _setError('BLE printer write characteristic not found');
      return false;
    } catch (e) { _setError('BLE connect failed: $e'); return false; } finally { _connecting = false; }
  }

  bool get isConnected => _device != null && _writeChar != null;
  bool get isClassicConnected => _classicConnected;
  BluetoothDevice? get selectedDevice => _device;
  ClassicBondedDevice? get classicDevice => _classicDevice;
  String? get lastPrinterId => _prefsBox?.get(_lastPrinterKey) as String?;
  String? get lastPrinterType => _prefsBox?.get(_lastPrinterTypeKey) as String?;

  Future<void> forgetPrinter() async {
    try { await _prefsBox?.delete(_lastPrinterKey); await _prefsBox?.delete(_lastPrinterTypeKey);} catch (_) {}
    _device = null; _writeChar = null; await disconnectClassic(); notifyListeners();
  }

  Future<bool> connectClassic(ClassicBondedDevice dev, {bool save = true}) async {
    if (_connecting) return false; _connecting = true;
    try {
      // Retry with exponential backoff up to 3 attempts
      const maxAttempts = 3;
      int attempt = 0;
      bool ok = false;
      while (attempt < maxAttempts && !(ok)) {
        attempt++;
        try {
          ok = await ClassicPrinterChannel.instance.connect(dev.mac);
          if (ok) break;
        } catch (e) {
          _setError('Classic connect error: $e');
        }
        if (!ok) {
          final delay = Duration(milliseconds: 200 * (1 << (attempt - 1))); // 200,400,800
          await Future.delayed(delay);
        }
      }
      if (!ok) { _setError('Failed to connect classic printer after $attempt attempts'); return false; }
      _classicDevice = dev;
      _classicConnected = true;
      if (save) { try { await _prefsBox?.put(_lastPrinterKey, dev.mac); await _prefsBox?.put(_lastPrinterTypeKey, 'classic'); } catch (_) {} }
      _setError(null);
      notifyListeners(); return true;
    } catch (e) { debugPrint('[PosPrinterService] Classic connect error: $e'); return false; } finally { _connecting = false; }
  }
  Future<void> disconnectClassic() async { try { await ClassicPrinterChannel.instance.disconnect(); } catch (_) {} _classicConnected = false; _classicDevice = null; }

  Future<PrintResult> testPrint() async {
    if (!isConnected && !isClassicConnected) return PrintResult.disconnected;
    final demo = PrintableInvoice(
      id: 'TEST-0001',
      date: DateTime.now(),
      customer: 'Demo Customer',
      customerAddress: '123 Demo Street, Demo City',
      customerPhone: '01000000000',
      deliveryDateTime: DateTime.now().add(const Duration(hours: 1)),
      total: 120.0,
      paid: 120.0,
      outstanding: 0.0,
      shipping: 0.0,
      items: [
        PrintableInvoiceItem(name: 'Connection Test', qty: 1, rate: 120.0),
      ],
    );
    return printInvoice(demo);
  }

  Future<void> _discoverWriteCharacteristic(BluetoothDevice device) async {
    final services = await device.discoverServices();
    for (final s in services) {
      for (final c in s.characteristics) {
        final p = c.properties;
        if ((p.write || p.writeWithoutResponse) && p.notify) { _writeChar = c; return; }
      }
    }
  }

  Future<PrintResult> printInvoice(PrintableInvoice inv) async {
    if (!isConnected && !isClassicConnected) return PrintResult.disconnected;
    try {
      await _loadReceiptConfig();
      final bytes = await _buildReceipt(inv);
      // Use conservative chunking to avoid buffer overrun artifacts (especially with Arabic raster lines).
      const chunk = 96;
      if (isConnected) {
        for (int o = 0; o < bytes.length; o += chunk) {
          final part = bytes.sublist(o, (o + chunk).clamp(0, bytes.length));
          await _writeChar!.write(part, withoutResponse: true);
          await Future.delayed(const Duration(milliseconds: 30));
        }
      } else if (isClassicConnected) {
        for (int o = 0; o < bytes.length; o += chunk) {
          final part = bytes.sublist(o, (o + chunk).clamp(0, bytes.length));
          await ClassicPrinterChannel.instance.write(part);
          await Future.delayed(const Duration(milliseconds: 25));
        }
      }
      _setError(null);
      return PrintResult.success;
    } catch (e) { debugPrint('[PosPrinterService] print error: $e'); _setError('Print failed: $e'); return PrintResult.failed; }
  }

  Future<Uint8List> _buildReceipt(PrintableInvoice inv) async {
    final b = BytesBuilder();
    void esc(List<int> c) => b.add(Uint8List.fromList(c));
    bool hasArabic(String s) => RegExp(r'[\u0600-\u06FF]').hasMatch(s);
    bool hasNonAscii(String s) => RegExp(r'[^\x00-\x7F]').hasMatch(s);
    String normalizePrintable(String s) {
      final cleaned = s
          .replaceAll(RegExp(r'[^\x20-\x7E]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      return cleaned;
    }
    Future<void> text(String s, {bool bold=false, bool center=false, bool big=false, String? fontFamily, double? fontSize}) async {
      if (hasArabic(s) || fontFamily != null || fontSize != null) {
        final fs = fontSize ?? (big ? 28.0 : 18.0);
        await _addRasterText(b, s, bold: bold, center: center, fontSize: fs, fontFamily: fontFamily);
        return;
      }
      final printable = hasNonAscii(s) ? normalizePrintable(s) : s;
      if (printable.isEmpty) return;
      esc([0x1C, 0x2E]); // Ensure CJK mode stays cancelled
      esc([0x1B, 0x4D, 0x00]); // Font A (wider, fills paper width)
      int mode = 0;
      if (bold) mode |= 0x08;
      if (big) mode |= 0x10; // double-height
      esc([0x1B, 0x21, mode]);
      esc([0x1B,0x61, center?0x01:0x00]);
      b.add(latin1.encode(printable));
      esc([0x0A]);
      if (big) esc([0x1B, 0x21, 0x00]); // reset mode after big text
    }
  void feed(int n) => esc([0x1B, 0x64, n.clamp(0, 255)]);
  const lineChars = 48; // Full width for 80mm thermal printers: 576 dots / 12 dots per Font A char = 48.
  Future<void> hr() async { await text('-' * lineChars); }
  // Removed invoice date display; eliminate unused date helpers.
    String shortInv(String full) {
      if (full.length <= 5) return full;
      // Keep only last 5 digits/characters; strip non-alphanumerics at end if any
      final cleaned = full.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
      if (cleaned.length <= 5) return cleaned;
      return cleaned.substring(cleaned.length - 5);
    }
    String amPm(DateTime t) {
      final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
      final m = t.minute.toString().padLeft(2, '0');
      final p = t.hour < 12 ? 'AM' : 'PM';
      return '$h:$m $p';
    }
    String formatDeliveryRange(DateTime start, {Duration slot = const Duration(hours: 1)}) {
      final end = start.add(slot);
      final day = start.day.toString().padLeft(2,'0');
      final month = start.month.toString().padLeft(2,'0');
      return '$day-$month from ${amPm(start)} to ${amPm(end)}';
    }
    List<String> wrapColumn(String label, String value, int maxWidth) {
      final prefix = label.isNotEmpty ? '$label: ' : '';
      final full = (prefix + value).trim();
      if (full.isEmpty) return [];
      final words = full.split(RegExp(r'\s+'));
      final lines = <String>[];
      var cur = StringBuffer();
      for (final w in words) {
        if (cur.isEmpty) {
          cur.write(w);
          continue;
        }
        if (cur.length + 1 + w.length > maxWidth) {
          lines.add(cur.toString());
            cur = StringBuffer(w);
        } else {
          cur.write(' ');
          cur.write(w);
        }
      }
      if (cur.isNotEmpty) lines.add(cur.toString());
      return lines;
    }
    // Reset printer to a known state to avoid stray characters or misalignment
    esc([0x1B, 0x40]);
    // Cancel Chinese/Kanji double-byte character mode (FS .)
    // Many thermal printers ship with CJK mode enabled by default, causing
    // ASCII bytes to be interpreted as double-byte CJK character codes → garbled output.
    esc([0x1C, 0x2E]);
    // Set left margin to 0 (GS L nL nH) — eliminate any default left margin
    esc([0x1D, 0x4C, 0x00, 0x00]);
    // Set print area width to 576 dots = full 80mm printable width (GS W nL nH, 576 = 0x0240)
    esc([0x1D, 0x57, 0x40, 0x02]);
    // Set right-side character spacing to 0 (ESC SP n)
    esc([0x1B, 0x20, 0x00]);
    // Select single-byte character code table: PC437 (ESC t 0)
    esc([0x1B, 0x74, 0x00]);
    // Use Font A globally (wider, fills paper width)
    esc([0x1B, 0x4D, 0x00]);
    // HEADER ---------------------------------------------------------
    if (_logoEscPos != null) {
      esc([0x1B,0x61,0x01]); // center
      b.add(_logoEscPos!);
      esc([0x1B,0x61,0x00]); // left
    }
    await text(_receiptHeader, bold: true, center: true, fontFamily: 'DMSerifDisplay');
    // Build two vertical columns of fields for 80mm (wider) printers
    // Left column logical order: Customer, Phone, Delivery
    // Right column: Invoice No, Invoice Date, Address (first line)
  // Address now printed fully after the two-column section (left aligned), so we don't include it in columns.
  final addressLines = (inv.customerAddress ?? '')
    .split('\n')
    .map((e)=>e.trim())
    .where((e)=>e.isNotEmpty)
    .toList();
    // Column wrapping with independent line counts; each column keeps its own continuation lines.
    // Define max character widths for Font A 48-char line width.
    const leftWidthChars = 24;
    const rightWidthChars = 24;
    // Build raw logical entries first.
    final leftEntries = <MapEntry<String,String>>[];
    leftEntries.add(MapEntry('Customer', inv.customer));
    if ((inv.customerPhone ?? '').isNotEmpty) {
      leftEntries.add(MapEntry('Phone', inv.customerPhone!));
    }
    // Delivery time will be rendered as its own full-width line after the columns, so omit from columns.
    final rightEntries = <MapEntry<String,String>>[];
    rightEntries.add(MapEntry('Inv No', shortInv(inv.id)));
    final leftLines = <List<String>>[];
    for (final e in leftEntries) { leftLines.add(wrapColumn(e.key, e.value, leftWidthChars)); }
    final rightLines = <List<String>>[];
    for (final e in rightEntries) { rightLines.add(wrapColumn(e.key, e.value, rightWidthChars)); }
    int visualRows = 0;
    final flatLeft = <String>[];
    for (final segs in leftLines) { flatLeft.addAll(segs); }
    final flatRight = <String>[];
    for (final segs in rightLines) { flatRight.addAll(segs); }
    visualRows = flatLeft.length > flatRight.length ? flatLeft.length : flatRight.length;
    for (int i=0;i<visualRows;i++) {
      final lVal = i < flatLeft.length ? flatLeft[i] : '';
      final rVal = i < flatRight.length ? flatRight[i] : '';
      await _twoColRow(b, lLabel: '', lValue: lVal, rLabel: '', rValue: rVal);
    }
    // Delivery full-width line if present
    if (inv.deliveryDateTime != null) {
      await text('Delivery: ${formatDeliveryRange(inv.deliveryDateTime!)}');
    }
    // Territory on its own bold line
    if ((inv.territory ?? '').isNotEmpty) {
      await text(inv.territory!, bold: true);
    }
    // Address block — slightly larger font for readability
    if (addressLines.isNotEmpty) {
      for (final line in addressLines) {
        await text(line, fontSize: 22);
      }
    }
    await hr();

    // BODY -----------------------------------------------------------
    // Column widths in characters (Font A). Names are wrapped, never truncated.
    // Total = 48 chars to fill full 80mm paper width.
    const nameW = 20;
    const qtyW = 4;
    const rateW = 12;
    const amtW = 12;

    List<String> wrapFixed(String s, int width) {
      if (s.isEmpty) return [''];
      final words = s.split(RegExp(r'\s+'));
      final lines = <String>[];
      var cur = StringBuffer();
      for (final w in words) {
        if (cur.isEmpty) {
          cur.write(w);
          continue;
        }
        if (cur.length + 1 + w.length > width) {
          lines.add(cur.toString());
          cur = StringBuffer(w);
        } else {
          cur.write(' ');
          cur.write(w);
        }
      }
      if (cur.isNotEmpty) lines.add(cur.toString());
      // If any word is longer than width (no spaces), hard-wrap it
      final fixed = <String>[];
      for (final line in lines) {
        if (line.length <= width) {
          fixed.add(line);
        } else {
          for (int i = 0; i < line.length; i += width) {
            fixed.add(line.substring(i, (i + width).clamp(0, line.length)));
          }
        }
      }
      return fixed.isEmpty ? [''] : fixed;
    }

    String pad(String s, int w, {bool right = false}) {
      if (s.length > w) return s.substring(0, w);
      return right ? s.padLeft(w) : s.padRight(w);
    }

    List<String> col4Rows(String name, String qty, String rate, String amt) {
      final nameLines = wrapFixed(name, nameW);
      final rows = <String>[];
      final totalRows = nameLines.length;
      for (int i = 0; i < totalRows; i++) {
        final n = pad(nameLines[i], nameW);
        final q = i == 0 ? pad(qty, qtyW, right: true) : ' '.padLeft(qtyW);
        final r = i == 0 ? pad(rate, rateW, right: true) : ' '.padLeft(rateW);
        final a = i == 0 ? pad(amt, amtW, right: true) : ' '.padLeft(amtW);
        rows.add('$n$q$r$a');
      }
      return rows;
    }

    // Header
    for (final line in col4Rows('Item', 'Qty', 'Rate', 'Amt')) {
      await text(line, bold: false);
    }
    await hr();
    // Items
    for (int idx = 0; idx < inv.items.length; idx++) {
      final it = inv.items[idx];
      final rows = col4Rows(it.name, it.qty.toStringAsFixed(0), _money(it.rate), _money(it.amount));
      for (final line in rows) {
        await text(line);
      }
      // Thin separator + small spacing between items (skip after last item)
      if (idx < inv.items.length - 1) {
        await text('.' * lineChars);
        feed(1);
      }
    }
    // Spacing before totals
    // Totals section: inv.total is authoritative grand total (already includes shipping income).
    // If shipping income > 0, show Subtotal = grand_total - shipping, then Shipping, then Total = grand_total.
    final grand = inv.total;
    feed(2); // spacing before totals
    if (inv.shipping > 0 && inv.shipping <= grand) {
      final double subtotal = (grand - inv.shipping).clamp(0, grand);
      await text(_labelVal('Subtotal', _money(subtotal)));
      await text(_labelVal('Shipping', _money(inv.shipping)));
      feed(1);
      await text(_labelVal('Total', _money(grand)), bold:true, big:true);
    } else {
      await text(_labelVal('Total', _money(grand)), bold:true, big:true);
    }
    final statusPaid = inv.outstanding <= 0.0001;
    await text(_labelVal('Status', statusPaid ? InvoiceStatus.paidUpper : InvoiceStatus.unpaidUpper));
    // Status is enough separation from footer; skip extra divider for compact receipt.

    // FOOTER ---------------------------------------------------------
    // Plain ASCII footers are safer as native ESC/POS text here; some printers
    // corrupt the trailing footer block when it is forced through raster text.
    await text(_receiptFooter, center:true, bold:true);
    await text('Call us $_receiptPhone', center:true);
    await text(_receiptWebsite, center:true);
  // Add two cut guide lines so user can manually cut at the marked area
  // Single guide line and a short feed keeps output compact while preserving cut space.
  await hr();
  feed(3);
    esc([0x1D,0x56,0x42,0x00]); // cut
    return b.toBytes();
  }

  String _money(double v) => v.toStringAsFixed(2);
  String _labelVal(String l,String v) {
    const ml = 30;
    const totalW = 48;
    final x = l.length > ml ? l.substring(0, ml) : l;
    final left = x.padRight(totalW - v.length);
    return '$left$v';
  }

  // Removed legacy _kv and _wrap helpers (now unused after two-column redesign).

  Future<Uint8List?> _prepareLogoEscPos() async {
    try {
      final data = await rootBundle.load('assets/images/logo.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final img = frame.image;
      // Render into a canvas as wide as an 80mm printer (576px) and center the scaled logo.
      const canvasW = 576;
      const logoTargetW = 200; // compact logo for thermal receipt
      final scale = logoTargetW / img.width;
      final targetH = (img.height * scale).round();
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final paint = ui.Paint();
      // White background to avoid black where logo has transparency
      final bg = ui.Paint()..color = const ui.Color(0xFFFFFFFF);
      canvas.drawRect(ui.Rect.fromLTWH(0, 0, canvasW.toDouble(), targetH.toDouble()), bg);
      // Center horizontally on the wider canvas
      final padLeft = ((canvasW - logoTargetW) / 2).clamp(0, canvasW.toDouble()).toDouble();
      canvas.translate(padLeft, 0.0);
      canvas.scale(scale);
      canvas.drawImage(img, const ui.Offset(0,0), paint);
      final picture = recorder.endRecording();
      final resized = await picture.toImage(canvasW, targetH);
      final byteData = await resized.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return null;
      final rgba = byteData.buffer.asUint8List();
      // Convert to 1bpp monochrome (threshold)
      final bytesPerRow = (canvasW + 7) >> 3;
      final out = Uint8List(bytesPerRow * targetH);
      int o = 0;
      for (int y=0; y<targetH; y++) {
        int bit = 0; int cur = 0;
        for (int x=0; x<canvasW; x++) {
          final idx = (y*canvasW + x) * 4;
          final r = rgba[idx];
          final g = rgba[idx+1];
          final b = rgba[idx+2];
          final lum = (0.299*r + 0.587*g + 0.114*b).round();
          final black = lum < 200; // slightly higher threshold to keep background white
          cur = (cur << 1) | (black ? 1 : 0);
          bit++;
          if (bit == 8) { out[o++] = cur; bit = 0; cur = 0; }
        }
        if (bit != 0) { cur <<= (8-bit); out[o++] = cur; }
      }
      // ESC/POS raster format: GS v 0 m xL xH yL yH data
      final xL = bytesPerRow & 0xFF;
      final xH = (bytesPerRow >> 8) & 0xFF;
      final yL = targetH & 0xFF;
      final yH = (targetH >> 8) & 0xFF;
      final hdr = Uint8List.fromList([0x1D, 0x76, 0x30, 0x00, xL, xH, yL, yH]);
      final bb = BytesBuilder();
      bb.add(hdr); bb.add(out); bb.add([0x0A]);
      return bb.toBytes();
    } catch (e) {
      debugPrint('[PosPrinterService] _prepareLogoEscPos error: $e');
      return null;
    }
  }

  Future<void> _addRasterText(BytesBuilder b, String s, {bool bold=false, bool center=false, double fontSize=18, String? fontFamily}) async {
    // 576px matches common 80mm ESC/POS printers.
    const targetW = 576;
    // Prepare text painter
  final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(s);
    // Font selection: explicit fontFamily > Tajawal for Arabic > Inter for content
    final effectiveFamily = fontFamily ?? (hasArabic ? 'Tajawal' : 'Inter');
    final fallbacks = hasArabic
        ? const ['Tajawal', 'Noto Naskh Arabic', 'Inter', 'Roboto']
        : const ['Inter', 'Tajawal', 'Roboto'];
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: const ui.Color(0xFF000000),
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          fontFamily: effectiveFamily,
          fontFamilyFallback: fallbacks,
        ),
      ),
  textDirection: hasArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      textAlign: center ? TextAlign.center : TextAlign.start,
      maxLines: 4,
    );
    tp.layout(maxWidth: targetW.toDouble());
    final height = tp.height.ceil().clamp(1, 512); // cap line height for safety
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    // white bg
    final bg = ui.Paint()..color = const ui.Color(0xFFFFFFFF);
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, targetW.toDouble(), height.toDouble()), bg);
    // Center horizontally: TextPainter.textAlign only affects multi-line wrapping,
    // so we manually offset single-line text to center it on the raster image.
    final paintX = center ? ((targetW - tp.width) / 2).clamp(0.0, targetW.toDouble()) : 0.0;
    tp.paint(canvas, ui.Offset(paintX, 0));
    final picture = recorder.endRecording();
    final img = await picture.toImage(targetW, height);
    final bd = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (bd == null) return;
    final rgba = bd.buffer.asUint8List();
    final bytesPerRow = (targetW + 7) >> 3;
    final out = Uint8List(bytesPerRow * height);
    int o = 0;
    for (int y=0; y<height; y++) {
      int bit = 0; int cur = 0;
      for (int x=0; x<targetW; x++) {
        final idx = (y*targetW + x) * 4;
        final r = rgba[idx];
        final g = rgba[idx+1];
        final b2 = rgba[idx+2];
        final lum = (0.299*r + 0.587*g + 0.114*b2).round();
        final black = lum < 200;
        cur = (cur << 1) | (black ? 1 : 0);
        bit++;
        if (bit == 8) { out[o++] = cur; bit = 0; cur = 0; }
      }
      if (bit != 0) { cur <<= (8-bit); out[o++] = cur; }
    }
    final xL = bytesPerRow & 0xFF;
    final xH = (bytesPerRow >> 8) & 0xFF;
    final yL = height & 0xFF;
    final yH = (height >> 8) & 0xFF;
    final hdr = Uint8List.fromList([0x1D, 0x76, 0x30, 0x00, xL, xH, yL, yH]);
    b.add(hdr);
    b.add(out);
    b.add([0x0A]);
  }
  Future<void> _twoColRow(BytesBuilder b, {required String lLabel, required String lValue, required String rLabel, required String rValue}) async {
    // Here labels are already integrated into value lines (we passed empty labels in wrapped mode). Keep backwards compatibility.
    final left = (lLabel.isNotEmpty ? '$lLabel: ' : '') + lValue;
    final right = (rLabel.isNotEmpty ? '$rLabel: ' : '') + rValue;
    final asciiOk = !RegExp(r'[^\x00-\x7F]').hasMatch(left + right);
    const leftWidth = 24;
    const rightWidth = 24;
    String pad(String s, int w){ return s.length > w ? s.substring(0,w) : s.padRight(w); }
    if (asciiOk) {
      final line = pad(left.trimRight(), leftWidth) + pad(right.trimRight(), rightWidth);
      b.add(Uint8List.fromList([0x1C, 0x2E])); // Ensure CJK mode stays cancelled
      b.add(Uint8List.fromList([0x1B, 0x4D, 0x00])); // Font A
      b.add(Uint8List.fromList([0x1B,0x21,0x00]));
      b.add(Uint8List.fromList([0x1B,0x61,0x00]));
      b.add(latin1.encode(line));
      b.add([0x0A]);
    } else {
      // Fallback to raster for mixed or non-ASCII content.
      final separator = '   ';
      final line = left.isEmpty ? right : (right.isEmpty ? left : left + separator + right);
      await _addRasterText(b, line, bold:false, center:false);
    }
  }
}

enum PrintResult { success, disconnected, failed }

