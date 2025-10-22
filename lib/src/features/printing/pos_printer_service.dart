import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:jarz_pos/src/core/printer/classic_printer_channel.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
    this.deliveryDateTime,
    required this.total,
    required this.paid,
    required this.outstanding,
    this.shipping = 0.0,
    required this.items,
  });
}

class PosPrinterService extends ChangeNotifier {
  PosPrinterService({bool autoInit = true}) {
    if (autoInit) {
      _init();
    }
  }

  static const _prefsBoxName = 'pos_printer_prefs';
  static const _lastPrinterKey = 'last_printer_id';
  static const _lastPrinterTypeKey = 'last_printer_type'; // 'ble' | 'classic'

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

  Future<void> startScan({Duration timeout = const Duration(seconds: 8)}) async {
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
      await device.connect(autoConnect: false, license: License.free).timeout(const Duration(seconds: 10), onTimeout: () => device.disconnect());
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
      final bytes = await _buildReceipt(inv);
      if (isConnected) {
        const chunk = 180;
        for (int o = 0; o < bytes.length; o += chunk) {
          final part = bytes.sublist(o, (o + chunk).clamp(0, bytes.length));
          await _writeChar!.write(part, withoutResponse: true);
          await Future.delayed(const Duration(milliseconds: 20));
        }
      } else if (isClassicConnected) {
        await ClassicPrinterChannel.instance.write(bytes);
      }
      _setError(null);
      return PrintResult.success;
    } catch (e) { debugPrint('[PosPrinterService] print error: $e'); _setError('Print failed: $e'); return PrintResult.failed; }
  }

  Future<Uint8List> _buildReceipt(PrintableInvoice inv) async {
    final b = BytesBuilder();
    void esc(List<int> c) => b.add(Uint8List.fromList(c));
    bool hasNonAscii(String s) => RegExp(r'[^\x00-\x7F]').hasMatch(s);
    Future<void> text(String s, {bool bold=false, bool center=false}) async {
      if (hasNonAscii(s)) {
        await _addRasterText(b, s, bold: bold, center: center);
      } else {
        esc([0x1B, 0x4D, 0x01]); // Font B (smaller)
        esc([0x1B,0x21,bold?0x20:0x00]);
        esc([0x1B,0x61, center?0x01:0x00]);
        b.add(utf8.encode(s)); esc([0x0A]);
      }
    }
  void feed(int n) => esc([0x1B, 0x64, n.clamp(0, 255)]);
  Future<void> hr() async { await text('-'*48); }
  // Removed invoice date display; eliminate unused date helpers.
    String shortInv(String full) {
      if (full.length <= 5) return full;
      // Keep only last 5 digits/characters; strip non-alphanumerics at end if any
      final cleaned = full.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
      if (cleaned.length <= 5) return cleaned;
      return cleaned.substring(cleaned.length - 5);
    }
    String formatDeliveryRange(DateTime start, {Duration slot = const Duration(hours: 1)}) {
      final end = start.add(slot);
      final day = start.day.toString().padLeft(2,'0');
      final month = start.month.toString().padLeft(2,'0');
      final sh = start.hour.toString().padLeft(2,'0');
      final sm = start.minute.toString().padLeft(2,'0');
      final eh = end.hour.toString().padLeft(2,'0');
      final em = end.minute.toString().padLeft(2,'0');
      return '$day-$month from $sh:$sm to $eh:$em';
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
    // Use Font B globally (smaller)
    esc([0x1B, 0x4D, 0x01]);
    // HEADER ---------------------------------------------------------
    // Centered logo (always centered). Logo pre-rendered for width 288px (scaled down 25%).
    if (_logoEscPos != null) {
      esc([0x1B,0x61,0x01]); // center
      b.add(_logoEscPos!);
      esc([0x1B,0x61,0x00]); // left
    }
    await text('ORDER RECEIPT', bold: true, center: true);
    feed(1);
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
    // Define max character widths assuming Font B monospaced-like width.
    const leftWidthChars = 28;
    const rightWidthChars = 28;
    // Build raw logical entries first.
    final leftEntries = <MapEntry<String,String>>[];
    leftEntries.add(MapEntry('Customer', inv.customer));
    if ((inv.customerPhone ?? '').isNotEmpty) {
      leftEntries.add(MapEntry('Phone', inv.customerPhone!));
    }
    // Delivery time will be rendered as its own full-width line after the columns, so omit from columns.
    final rightEntries = <MapEntry<String,String>>[];
    rightEntries.add(MapEntry('Inv No', shortInv(inv.id)));
    // Arabic-only detection: if ALL values across both columns are Arabic (or mixed non-ASCII) we fallback to single-column raster lines
    final allValues = [
      ...leftEntries.map((e)=>e.value),
      ...rightEntries.map((e)=>e.value),
    ].where((v)=>v.trim().isNotEmpty).toList();
    final containsArabic = allValues.any((v)=>RegExp(r'[\u0600-\u06FF]').hasMatch(v));
    if (containsArabic) {
      // Fallback: print each field on its own line as 'Label: Value' using raster (RTL aware in _addRasterText)
      for (final e in leftEntries) {
        await _addRasterText(b, '${e.key}: ${e.value}', center:false);
      }
      for (final e in rightEntries) {
        await _addRasterText(b, '${e.key}: ${e.value}', center:false);
      }
    } else {
      // Normal two-column path
      final leftLines = <List<String>>[]; // list of segments per original entry
      for (final e in leftEntries) { leftLines.add(wrapColumn(e.key, e.value, leftWidthChars)); }
      final rightLines = <List<String>>[]; for (final e in rightEntries) { rightLines.add(wrapColumn(e.key, e.value, rightWidthChars)); }
      int visualRows = 0;
      final flatLeft = <String>[]; for (final segs in leftLines) { flatLeft.addAll(segs); }
      final flatRight = <String>[]; for (final segs in rightLines) { flatRight.addAll(segs); }
      visualRows = flatLeft.length > flatRight.length ? flatLeft.length : flatRight.length;
      for (int i=0;i<visualRows;i++) {
        final lVal = i < flatLeft.length ? flatLeft[i] : '';
        final rVal = i < flatRight.length ? flatRight[i] : '';
        await _twoColRow(b, lLabel: '', lValue: lVal, rLabel: '', rValue: rVal);
      }
    }
    // Delivery full-width line (like address) if present
    if (inv.deliveryDateTime != null) {
      await _addRasterText(b, 'Delivery: ${formatDeliveryRange(inv.deliveryDateTime!)}', center: false);
    }
    // Print full address block left-aligned (raster for robustness with possible Unicode / wrapping).
    if (addressLines.isNotEmpty) {
      for (final line in addressLines) {
        await _addRasterText(b, line, center: false);
      }
    }
    await hr();

    // BODY -----------------------------------------------------------
  // Smaller items header (non-bold). Force ASCII path by ensuring no non-ascii chars.
  await text(_col4('Item','Qty','Rate','Amt'), bold:false);
    await hr();
    for (final it in inv.items) {
      await text(_col4(_truncate(it.name,16), it.qty.toStringAsFixed(0), _money(it.rate), _money(it.amount)));
    }
    await hr();
    // Totals section: inv.total is authoritative grand total (already includes shipping income).
    // If shipping income > 0, show Subtotal = grand_total - shipping, then Shipping, then Total = grand_total.
    final grand = inv.total;
    if (inv.shipping > 0 && inv.shipping <= grand) {
      final double subtotal = (grand - inv.shipping).clamp(0, grand);
      await text(_labelVal('Subtotal', _money(subtotal)));
      await text(_labelVal('Shipping', _money(inv.shipping)));
      await text(_labelVal('Total', _money(grand)), bold:true);
    } else {
      await text(_labelVal('Total', _money(grand)), bold:true);
    }
    final statusPaid = inv.outstanding <= 0.0001;
    await text(_labelVal('Status', statusPaid ? 'PAID' : 'UNPAID'));
    await hr();

    // FOOTER ---------------------------------------------------------
    await text('Thank you for Your Order', center:true);
    await text('Call us 01061332266', center:true);
    await text('www.orderjarz.com', center:true);
  // Add two cut guide lines so user can manually cut at the marked area
  await hr();
  await hr();
  // Add ~1cm gap (assuming ~8 dots/mm at 203dpi => ~80 dots). ESC/POS feed n is in lines; approximate using 8 lines (~1cm).
  feed(8);
    esc([0x1D,0x56,0x42,0x00]); // cut
    return b.toBytes();
  }

  String _money(double v) => v.toStringAsFixed(2);
  String _truncate(String s, int max) => s.length <= max ? s : '${s.substring(0, max-1)}…';
  String _col4(String a,String b,String c,String d) {
    String pad(String s,int w,{bool right=false}) { if (s.length>w) return s.substring(0,w); return right? s.padLeft(w):s.padRight(w);} 
    return '${pad(a,18)}${pad(b,8,right:true)}${pad(c,10,right:true)}${pad(d,12,right:true)}';
  }
  String _labelVal(String l,String v) { final ml=20; final x=l.length>ml?l.substring(0,ml):l; return '${x.padRight(30)}${v.padLeft(18)}'; }

  // Removed legacy _kv and _wrap helpers (now unused after two-column redesign).

  Future<Uint8List?> _prepareLogoEscPos() async {
    try {
      final data = await rootBundle.load('assets/images/logo.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final img = frame.image;
  // Target width reduced 25% (from 384 to 288) for a more compact centered logo.
  const targetW = 288;
      final scale = targetW / img.width;
      final targetH = (img.height * scale).round();
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final paint = ui.Paint();
      // White background to avoid black where logo has transparency
      final bg = ui.Paint()..color = const ui.Color(0xFFFFFFFF);
      canvas.drawRect(ui.Rect.fromLTWH(0, 0, targetW.toDouble(), targetH.toDouble()), bg);
      canvas.scale(scale);
      canvas.drawImage(img, const ui.Offset(0,0), paint);
      final picture = recorder.endRecording();
      final resized = await picture.toImage(targetW, targetH);
      final byteData = await resized.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return null;
      final rgba = byteData.buffer.asUint8List();
      // Convert to 1bpp monochrome (threshold)
      final bytesPerRow = (targetW + 7) >> 3;
      final out = Uint8List(bytesPerRow * targetH);
      int o = 0;
      for (int y=0; y<targetH; y++) {
        int bit = 0; int cur = 0;
        for (int x=0; x<targetW; x++) {
          final idx = (y*targetW + x) * 4;
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

  Future<void> _addRasterText(BytesBuilder b, String s, {bool bold=false, bool center=false}) async {
    // Increase target width to 576 for 80mm printers where supported; fallback effective on narrower printers (they'll wrap/clip as per firmware).
    const targetW = 576;
    // Prepare text painter
  final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(s);
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: const ui.Color(0xFF000000),
          fontSize: 18, // smaller font
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
  textDirection: hasArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      textAlign: center ? TextAlign.center : TextAlign.left,
      maxLines: 4,
    );
    tp.layout(maxWidth: targetW.toDouble());
    final height = tp.height.ceil().clamp(1, 512); // cap line height for safety
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    // white bg
    final bg = ui.Paint()..color = const ui.Color(0xFFFFFFFF);
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, targetW.toDouble(), height.toDouble()), bg);
    tp.paint(canvas, const ui.Offset(0, 0));
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
    const leftWidth = 28; const rightWidth = 28;
    String pad(String s, int w){ return s.length > w ? s.substring(0,w) : s.padRight(w); }
    if (asciiOk) {
      final line = pad(left.trimRight(), leftWidth) + pad(right.trimRight(), rightWidth);
      b.add(Uint8List.fromList([0x1B, 0x4D, 0x01]));
      b.add(Uint8List.fromList([0x1B,0x21,0x00]));
      b.add(Uint8List.fromList([0x1B,0x61,0x00]));
      b.add(utf8.encode(line));
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

