// Canvas-based receipt renderer — pure dart:ui, no Flutter widget tree required.
// Extends the proven _addRasterText technique to full-page receipt rendering.
// Renders the complete receipt as a single bitmap → banded GS v 0 ESC/POS bytes.
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../pos_printer_service.dart';

class ReceiptCanvasRenderer {
  // ── Constants ──────────────────────────────────────────────────────────────
  static const double _receiptW = 576.0; // paper width in pixels (80mm at 203 DPI)
  static const double _padX = 10.0; // horizontal side padding
  static const double _lineGap = 3.0; // vertical gap after each text element
  static const double _sectionGap = 6.0; // gap between receipt sections
  static const double _colGutter = 4.0; // gap between two-column gutters
  static const double _colW = (_receiptW - 2 * _padX - _colGutter) / 2; // ~276 px
  static const double _colR = _padX + _colW + _colGutter; // right col start x

  // Items table column x-positions and widths (sum = _receiptW)
  static const double _tSnoX = 0;
  static const double _tSnoW = 36.0;
  static const double _tProdX = _tSnoW;
  static const double _tProdW = 226.0;
  static const double _tQtyX = _tProdX + _tProdW;
  static const double _tQtyW = 68.0;
  static const double _tUnitX = _tQtyX + _tQtyW;
  static const double _tUnitW = 123.0;
  static const double _tAmtX = _tUnitX + _tUnitW;
  static const double _tAmtW = _receiptW - _tAmtX; // = 123 px

  static final RegExp _arabicRe = RegExp(r'[\u0600-\u06FF]');

  // ── Public entry point ─────────────────────────────────────────────────────
  static Future<Uint8List> render({
    required PrintableInvoice inv,
    required String header,
    required String footer,
    required String phone,
    required String website,
    bool printLogo = false,
    int maxBandHeight = 200,
    int threshold = 200,
  }) async {
    ui.Image? logo;
    if (printLogo) {
      try {
        final data = await rootBundle.load('assets/images/logo.png');
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(),
          targetWidth: (_receiptW * 0.5).toInt(),
        );
        final frame = await codec.getNextFrame();
        logo = frame.image;
      } catch (e) {
        debugPrint('[ReceiptCanvasRenderer] logo load failed: $e');
      }
    }
    try {
      return await _buildBytes(
        inv: inv,
        header: header,
        footer: footer,
        phone: phone,
        website: website,
        logo: logo,
        maxBandHeight: maxBandHeight,
        threshold: threshold,
      );
    } finally {
      logo?.dispose();
    }
  }

  // ── Internal builder ───────────────────────────────────────────────────────
  static Future<Uint8List> _buildBytes({
    required PrintableInvoice inv,
    required String header,
    required String footer,
    required String phone,
    required String website,
    ui.Image? logo,
    required int maxBandHeight,
    required int threshold,
  }) async {
    // Two-pass approach:
    // Pass 1 — lay out all TextPainters and collect draw-ops with Y positions.
    // Pass 2 — paint everything onto a single canvas → toImage → ESC/POS bands.

    final ops = <_Op>[];
    double y = 0.0;

    // ── Helpers ──────────────────────────────────────────────────────────────
    void gap(double h) => y += h;

    void hline({double thickness = 1.0}) {
      ops.add(_LineOp(y: y, thickness: thickness));
      y += thickness + _lineGap;
    }

    // Paint a pre-laid-out TextPainter at (x, y) and advance y by its height.
    void placeTp(TextPainter tp, double x, {bool advance = true}) {
      ops.add(_TpOp(tp: tp, x: x, y: y));
      if (advance) y += tp.height + _lineGap;
    }

    // Build + layout a TextPainter.
    TextPainter tp(
      String text,
      double maxWidth, {
      bool bold = false,
      double fontSize = 12.0,
      String? fontFamily,
      TextAlign align = TextAlign.start,
    }) {
      final hasArabic = _arabicRe.hasMatch(text);
      final family = fontFamily ?? (hasArabic ? 'Tajawal' : 'Inter');
      final fallbacks = hasArabic
          ? const ['Tajawal', 'Noto Naskh Arabic', 'Inter', 'Roboto']
          : const ['Inter', 'Tajawal', 'Roboto'];
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: const ui.Color(0xFF000000),
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            fontFamily: family,
            fontFamilyFallback: fallbacks,
            height: 1.25,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
        textAlign: align,
      )..layout(maxWidth: maxWidth);
      return painter;
    }

    // Right-aligned text: place at x such that the text ends at (x + colWidth).
    void placeRight(TextPainter painter, double colX, double colW, {bool advance = true}) {
      final dx = colX + colW - painter.width;
      ops.add(_TpOp(tp: painter, x: dx.clamp(colX, colX + colW), y: y));
      if (advance) y += painter.height + _lineGap;
    }

    // Centered text inside a column.
    void placeCenter(TextPainter painter, double colX, double colW, {bool advance = true}) {
      final dx = colX + (colW - painter.width) / 2;
      ops.add(_TpOp(tp: painter, x: dx.clamp(colX, colX + colW), y: y));
      if (advance) y += painter.height + _lineGap;
    }

    // ── Section 1: Top padding ───────────────────────────────────────────────
    gap(8);

    // ── Section 2: Logo ──────────────────────────────────────────────────────
    if (logo != null) {
      const maxLogoH = 80.0;
      final scale = maxLogoH / logo.height;
      final drawW = (logo.width * scale).clamp(0.0, _receiptW * 0.6);
      final drawH = (logo.height * scale).clamp(0.0, maxLogoH);
      final logoX = (_receiptW - drawW) / 2;
      ops.add(_ImageOp(image: logo, x: logoX, y: y, w: drawW, h: drawH));
      y += drawH + 4;
    }

    // ── Section 3: Brand header ──────────────────────────────────────────────
    placeTp(
      tp(header, _receiptW - 2 * _padX, bold: true, fontSize: 24, fontFamily: 'DMSerifDisplay', align: TextAlign.center),
      _padX,
    );

    // ── Section 4: Website ───────────────────────────────────────────────────
    if (website.isNotEmpty) {
      placeTp(tp(website, _receiptW - 2 * _padX, fontSize: 12, align: TextAlign.center), _padX);
    }
    gap(_sectionGap);
    hline();
    gap(_sectionGap);

    // ── Section 5: Two-column info block ──────────────────────────────────────
    // Build all left-column TextPainters, record their heights.
    // Build all right-column TextPainters, record their heights.
    // Section height = max(sum of left heights, sum of right heights).

    final leftOps = <_TpEntry>[];
    final rightOps = <_TpEntry>[];
    double leftH = 0.0;
    double rightH = 0.0;

    void addLeft(TextPainter painter) {
      leftOps.add(_TpEntry(tp: painter));
      leftH += painter.height + _lineGap;
    }

    void addRight(TextPainter painter) {
      rightOps.add(_TpEntry(tp: painter));
      rightH += painter.height + _lineGap;
    }

    // Left column: Delivery Address
    addLeft(tp('Delivery Address', _colW, bold: true, fontSize: 13));
    if (inv.customer.isNotEmpty) addLeft(tp(inv.customer, _colW, fontSize: 12));
    if ((inv.customerAddress ?? '').isNotEmpty) {
      addLeft(tp(inv.customerAddress!, _colW, fontSize: 12));
    }
    if ((inv.customerPhone ?? '').isNotEmpty) {
      addLeft(tp(inv.customerPhone!, _colW, fontSize: 12));
    }
    if ((inv.deliveryDateFormatted ?? '').isNotEmpty) {
      addLeft(tp('Delivery Date:', _colW, bold: true, fontSize: 12));
      addLeft(tp(inv.deliveryDateFormatted!, _colW, fontSize: 12));
    } else if (inv.deliveryDateTime != null) {
      // Fallback: format the delivery datetime
      final dt = inv.deliveryDateTime!;
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      final formatted = '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
      addLeft(tp('Delivery Date:', _colW, bold: true, fontSize: 12));
      addLeft(tp(formatted, _colW, fontSize: 12));
    }

    // Right column: Order details
    if ((inv.orderNo ?? '').isNotEmpty) {
      addRight(_richTp('Order no: ', inv.orderNo!, _colW));
    }
    if ((inv.orderDate ?? '').isNotEmpty) {
      addRight(_richTp('Order date: ', inv.orderDate!, _colW));
    }
    if ((inv.paymentMethod ?? '').isNotEmpty) {
      addRight(_richTp('Payment method: ', inv.paymentMethod!, _colW));
    }
    if ((inv.deliveryTimeRange ?? '').isNotEmpty) {
      addRight(_richTp('Delivery Time: ', inv.deliveryTimeRange!, _colW));
    }

    // Place two columns at the current Y, both starting at sectionY
    final sectionStartY = y;
    for (final entry in leftOps) {
      ops.add(_TpOp(tp: entry.tp, x: _padX, y: y));
      y += entry.tp.height + _lineGap;
    }
    // Reset y to sectionStartY for right column (they're side-by-side)
    y = sectionStartY;
    for (final entry in rightOps) {
      ops.add(_TpOp(tp: entry.tp, x: _colR, y: y));
      y += entry.tp.height + _lineGap;
    }
    // Advance y to the bottom of whichever column was taller
    y = sectionStartY + (leftH > rightH ? leftH : rightH);

    gap(_sectionGap);
    hline();
    gap(_sectionGap);

    // ── Section 6: Items table ────────────────────────────────────────────────
    // Header row
    final headerRowY = y;
    final snHdr = tp('S.No', _tSnoW, bold: true, fontSize: 11, align: TextAlign.center);
    final prodHdr = tp('Product', _tProdW, bold: true, fontSize: 11);
    final qtyHdr = tp('Quantity', _tQtyW, bold: true, fontSize: 11, align: TextAlign.center);
    final unitHdr = tp('Unit\nprice', _tUnitW, bold: true, fontSize: 11, align: TextAlign.center);
    final amtHdr = tp('Total\nprice', _tAmtW, bold: true, fontSize: 11, align: TextAlign.center);
    final hdrH = [snHdr, prodHdr, qtyHdr, unitHdr, amtHdr].fold<double>(0, (m, t) => t.height > m ? t.height : m) + _lineGap;

    placeCenter(snHdr, _tSnoX, _tSnoW, advance: false);
    ops.add(_TpOp(tp: prodHdr, x: _tProdX, y: headerRowY));
    placeCenter(qtyHdr, _tQtyX, _tQtyW, advance: false);
    placeCenter(unitHdr, _tUnitX, _tUnitW, advance: false);
    placeCenter(amtHdr, _tAmtX, _tAmtW, advance: false);
    y = headerRowY + hdrH;

    hline();

    // Item rows
    int sno = 0;
    for (final item in inv.items) {
      final rowY = y;
      if (!item.showPricing) {
        // Bundle child row: full-width name, no pricing columns
        final indent = '  ' * item.indentLevel;
        final bullet = item.indentLevel > 0 ? '- ' : '';
        final nameTp = tp('$indent$bullet${item.name}', _receiptW - 2 * _padX, bold: item.bold, fontSize: 12);
        ops.add(_TpOp(tp: nameTp, x: _padX, y: rowY));
        y = rowY + nameTp.height + _lineGap;
        continue;
      }

      sno++;
      final snoTp = tp('$sno', _tSnoW, fontSize: 12, align: TextAlign.center);

      // Product name (may wrap) + optional description sub-line
      final nameTp = tp(item.name, _tProdW, bold: item.bold, fontSize: 12);
      TextPainter? descTp;
      if ((item.description ?? '').isNotEmpty) {
        descTp = tp(item.description!, _tProdW, fontSize: 10);
      }
      final prodColH = nameTp.height + (descTp != null ? (descTp.height + 1) : 0);

      final qtyTp = tp(_fmtQty(item.qty), _tQtyW, fontSize: 12, align: TextAlign.center);
      final unitTp = tp(_fmtAmt(item.rate), _tUnitW, fontSize: 12, align: TextAlign.right);
      final amtTp = tp(_fmtAmt(item.amount), _tAmtW, fontSize: 12, align: TextAlign.right);

      final rowH = [snoTp, qtyTp, unitTp, amtTp].fold<double>(prodColH, (m, t) => t.height > m ? t.height : m) + _lineGap;

      placeCenter(snoTp, _tSnoX, _tSnoW, advance: false);
      ops.add(_TpOp(tp: nameTp, x: _tProdX, y: rowY));
      if (descTp != null) {
        ops.add(_TpOp(tp: descTp, x: _tProdX + 4, y: rowY + nameTp.height + 1));
      }
      placeCenter(qtyTp, _tQtyX, _tQtyW, advance: false);
      // Right-align unit price and amount within their columns
      ops.add(_TpOp(tp: unitTp, x: (_tUnitX + _tUnitW - unitTp.width).clamp(_tUnitX, _tUnitX + _tUnitW), y: rowY));
      ops.add(_TpOp(tp: amtTp, x: (_tAmtX + _tAmtW - amtTp.width).clamp(_tAmtX, _tAmtX + _tAmtW), y: rowY));

      y = rowY + rowH;
    }

    hline();
    gap(_lineGap);

    // ── Section 7: Totals ─────────────────────────────────────────────────────
    final grand = inv.total;
    const totalsLabelX = _receiptW * 0.45;
    const totalsValX = _receiptW * 0.72;
    const totalsLabelW = _receiptW * 0.27;
    const totalsValW = _receiptW - totalsValX - _padX;

    if (inv.shipping > 0 && inv.shipping <= grand) {
      final subtotal = (grand - inv.shipping).clamp(0.0, grand);
      _addTotalRow(ops, y, totalsLabelX, totalsLabelW, totalsValX, totalsValW, 'Subtotal', _fmtAmt(subtotal), tp, placeRight);
      y += _tpHeight(tp('Subtotal', totalsLabelW, fontSize: 12)) + _lineGap;
      _addTotalRow(ops, y, totalsLabelX, totalsLabelW, totalsValX, totalsValW, 'Shipping', _fmtAmt(inv.shipping), tp, placeRight);
      y += _tpHeight(tp('Shipping', totalsLabelW, fontSize: 12)) + _lineGap;
      gap(_lineGap);
    }

    // Grand total (larger, bold)
    final totalLabelTp = tp('Total', totalsLabelW, bold: true, fontSize: 16);
    final totalValTp = tp(_fmtAmt(grand), totalsValW, bold: true, fontSize: 16, align: TextAlign.right);
    ops.add(_TpOp(tp: totalLabelTp, x: totalsLabelX, y: y));
    ops.add(_TpOp(tp: totalValTp, x: (totalsValX + totalsValW - totalValTp.width).clamp(totalsValX, totalsValX + totalsValW), y: y));
    y += totalLabelTp.height + _lineGap;

    // Status
    final isPaid = inv.outstanding <= 0.0001;
    final statusTp = tp(isPaid ? 'Status: PAID' : 'Status: UNPAID', _receiptW - 2 * _padX, fontSize: 12);
    ops.add(_TpOp(tp: statusTp, x: totalsLabelX, y: y));
    y += statusTp.height + _sectionGap;

    // ── Section 8: Footer ─────────────────────────────────────────────────────
    hline();
    gap(_lineGap);
    if (footer.isNotEmpty) {
      placeTp(tp(footer, _receiptW - 2 * _padX, bold: true, fontSize: 12, align: TextAlign.center), _padX);
    }
    if (phone.isNotEmpty) {
      placeTp(tp('Call us $phone', _receiptW - 2 * _padX, fontSize: 12, align: TextAlign.center), _padX);
    }
    if (website.isNotEmpty) {
      placeTp(tp(website, _receiptW - 2 * _padX, fontSize: 12, align: TextAlign.center), _padX);
    }
    gap(24); // bottom padding before cut

    // ── Pass 2: paint to canvas ───────────────────────────────────────────────
    final totalH = y.ceilToDouble();
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, ui.Rect.fromLTWH(0, 0, _receiptW, totalH));

    // White background
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, _receiptW, totalH),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );

    for (final op in ops) {
      op.paint(canvas);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(_receiptW.toInt(), totalH.toInt());

    try {
      return _imageToBandedEscPos(image, maxBandHeight: maxBandHeight, threshold: threshold);
    } finally {
      image.dispose();
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Build a TextPainter with a bold label followed by a normal value (same line).
  static TextPainter _richTp(String label, String value, double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              color: ui.Color(0xFF000000),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
              fontFamilyFallback: ['Tajawal', 'Roboto'],
              height: 1.25,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: ui.Color(0xFF000000),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
              fontFamilyFallback: ['Tajawal', 'Roboto'],
              height: 1.25,
            ),
          ),
        ],
      ),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.start,
    )..layout(maxWidth: maxWidth);
    return tp;
  }

  static double _tpHeight(TextPainter tp) => tp.height;

  static void _addTotalRow(
    List<_Op> ops,
    double rowY,
    double labelX,
    double labelW,
    double valX,
    double valW,
    String label,
    String value,
    TextPainter Function(String, double, {bool bold, double fontSize, String? fontFamily, TextAlign align}) mkTp,
    void Function(TextPainter, double, double, {bool advance}) placeRight,
  ) {
    final lTp = mkTp(label, labelW, fontSize: 12);
    final vTp = mkTp(value, valW, fontSize: 12, align: TextAlign.right);
    ops.add(_TpOp(tp: lTp, x: labelX, y: rowY));
    ops.add(_TpOp(tp: vTp, x: (valX + valW - vTp.width).clamp(valX, valX + valW), y: rowY));
  }

  static String _fmtQty(double qty) {
    if ((qty - qty.round()).abs() < 0.0001) return qty.round().toString();
    return qty.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  static String _fmtAmt(double v) => 'EGP ${v.toStringAsFixed(2)}';

  // ── ESC/POS banded raster converter ───────────────────────────────────────
  static Future<Uint8List> _imageToBandedEscPos(
    ui.Image image, {
    int maxBandHeight = 200,
    int threshold = 200,
  }) async {
    final imgW = image.width;
    final imgH = image.height;
    final bd = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (bd == null) return Uint8List(0);
    final rgba = bd.buffer.asUint8List();

    final b = BytesBuilder();

    // Printer init sequence
    b.add(const [0x1B, 0x40]); // ESC @ — init
    b.add(const [0x1C, 0x2E]); // FS .  — cancel CJK mode
    b.add(const [0x1D, 0x4C, 0x00, 0x00]); // GS L 0 — zero left margin
    const wDots = 576;
    b.add([0x1D, 0x57, wDots & 0xFF, (wDots >> 8) & 0xFF]); // GS W — paper width
    b.add(const [0x1B, 0x61, 0x00]); // ESC a 0 — left align

    final bytesPerRow = (imgW + 7) >> 3;

    for (int bandStart = 0; bandStart < imgH; bandStart += maxBandHeight) {
      final bandEnd = (bandStart + maxBandHeight).clamp(0, imgH);
      final bandH = bandEnd - bandStart;

      final bandBytes = Uint8List(bytesPerRow * bandH);
      int o = 0;

      for (int row = bandStart; row < bandEnd; row++) {
        int bit = 0;
        int cur = 0;
        for (int col = 0; col < imgW; col++) {
          final idx = (row * imgW + col) * 4;
          final r = rgba[idx];
          final g = rgba[idx + 1];
          final bv = rgba[idx + 2];
          final lum = (0.299 * r + 0.587 * g + 0.114 * bv).round();
          cur = (cur << 1) | (lum < threshold ? 1 : 0);
          bit++;
          if (bit == 8) {
            bandBytes[o++] = cur;
            bit = 0;
            cur = 0;
          }
        }
        if (bit != 0) {
          cur <<= (8 - bit);
          bandBytes[o++] = cur;
        }
      }

      // GS v 0 raster command
      final xL = bytesPerRow & 0xFF;
      final xH = (bytesPerRow >> 8) & 0xFF;
      final yL = bandH & 0xFF;
      final yH = (bandH >> 8) & 0xFF;
      b.add([0x1D, 0x76, 0x30, 0x00, xL, xH, yL, yH]);
      b.add(bandBytes);
    }

    // Feed and partial cut
    b.add(const [0x1B, 0x64, 0x03]); // ESC d 3 — feed 3 lines
    b.add(const [0x1D, 0x56, 0x42, 0x00]); // GS V B 0 — partial cut
    return b.toBytes();
  }
}

// ── Internal draw-op types ──────────────────────────────────────────────────

abstract class _Op {
  void paint(ui.Canvas canvas);
}

class _TpOp extends _Op {
  final TextPainter tp;
  final double x;
  final double y;
  _TpOp({required this.tp, required this.x, required this.y});

  @override
  void paint(ui.Canvas canvas) => tp.paint(canvas, ui.Offset(x, y));
}

class _LineOp extends _Op {
  final double y;
  final double thickness;
  _LineOp({required this.y, this.thickness = 1.0});

  @override
  void paint(ui.Canvas canvas) {
    canvas.drawLine(
      ui.Offset(0, y + thickness / 2),
      ui.Offset(ReceiptCanvasRenderer._receiptW, y + thickness / 2),
      ui.Paint()
        ..color = const ui.Color(0xFF000000)
        ..strokeWidth = thickness,
    );
  }
}

class _ImageOp extends _Op {
  final ui.Image image;
  final double x;
  final double y;
  final double w;
  final double h;
  _ImageOp({required this.image, required this.x, required this.y, required this.w, required this.h});

  @override
  void paint(ui.Canvas canvas) {
    final src = ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dst = ui.Rect.fromLTWH(x, y, w, h);
    canvas.drawImageRect(image, src, dst, ui.Paint());
  }
}

class _TpEntry {
  final TextPainter tp;
  _TpEntry({required this.tp});
}
