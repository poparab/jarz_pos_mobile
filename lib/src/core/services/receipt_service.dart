import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class ReceiptService {
  static final _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static Future<void> printReceipt(Map<String, dynamic> invoice) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          margin: const pw.EdgeInsets.all(8),
          build: (context) {
            return _buildReceiptContent(invoice);
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'receipt_${invoice['name'] ?? 'unknown'}.pdf',
      );
      
      if (kDebugMode) {
        debugPrint('✅ RECEIPT: Printed successfully for ${invoice['name']}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RECEIPT: Print error: $e');
      }
      throw Exception('Failed to print receipt: $e');
    }
  }

  static pw.Widget _buildReceiptContent(Map<String, dynamic> invoice) {
    final items = (invoice['items'] as List?) ?? [];
    final subtotal = (invoice['net_total'] as num?) ?? 0;
    final tax = (invoice['total_taxes_and_charges'] as num?) ?? 0;
    final total = (invoice['grand_total'] as num?) ?? 0;
    final paid = (invoice['paid_amount'] as num?) ?? 0;
    final change = paid - total;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                'JARZ POS',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Point of Sale System',
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),

        // Invoice Info
        pw.Text('Invoice: ${invoice['name'] ?? 'N/A'}'),
        pw.Text('Date: ${_formatDate(invoice['posting_date'])}'),
        pw.Text('Customer: ${invoice['customer_name'] ?? 'Walk-in Customer'}'),
        if (invoice['territory'] != null)
          pw.Text('Territory: ${invoice['territory']}'),
        
        pw.SizedBox(height: 12),
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 8),

        // Items header
        pw.Row(
          children: [
            pw.Expanded(flex: 3, child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 1, child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
            pw.Expanded(flex: 2, child: pw.Text('Rate', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
            pw.Expanded(flex: 2, child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Divider(thickness: 0.5),

        // Items
        ...items.map((item) => _buildItemRow(item)),

        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 8),

        // Totals
        _buildTotalRow('Subtotal:', subtotal),
        if (tax > 0) _buildTotalRow('Tax:', tax),
        pw.SizedBox(height: 4),
        pw.Divider(thickness: 0.5),
        _buildTotalRow('TOTAL:', total, isTotal: true),

        if (paid > 0) ...[
          pw.SizedBox(height: 8),
          _buildTotalRow('Paid:', paid),
          if (change > 0) _buildTotalRow('Change:', change),
        ],

        pw.SizedBox(height: 16),

        // Footer
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                'Thank you for your business!',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Powered by Jarz POS',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                _dateFormat.format(DateTime.now()),
                style: pw.TextStyle(fontSize: 8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildItemRow(Map<String, dynamic> item) {
    final name = item['item_name'] ?? item['item_code'] ?? 'Unknown Item';
    final qty = (item['qty'] as num?) ?? 0;
    final rate = (item['rate'] as num?) ?? 0;
    final amount = (item['amount'] as num?) ?? 0;

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              name,
              style: pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              qty.toString(),
              style: pw.TextStyle(fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              _currencyFormat.format(rate),
              style: pw.TextStyle(fontSize: 10),
              textAlign: pw.TextAlign.right,
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              _currencyFormat.format(amount),
              style: pw.TextStyle(fontSize: 10),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, num amount, {bool isTotal = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: isTotal ? 12 : 10,
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          _currencyFormat.format(amount),
          style: pw.TextStyle(
            fontSize: isTotal ? 12 : 10,
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  static String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      if (date is String) {
        final parsedDate = DateTime.parse(date);
        return _dateFormat.format(parsedDate);
      }
      return date.toString();
    } catch (e) {
      return date.toString();
    }
  }

  static Future<bool> canPrint() async {
    try {
      final info = await Printing.info();
      return info.canPrint;
    } catch (e) {
      return false;
    }
  }

  static Future<void> shareReceipt(Map<String, dynamic> invoice) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return _buildReceiptContent(invoice);
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'receipt_${invoice['name'] ?? 'unknown'}.pdf',
      );
      
      if (kDebugMode) {
        debugPrint('✅ RECEIPT: Shared successfully for ${invoice['name']}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RECEIPT: Share error: $e');
      }
      throw Exception('Failed to share receipt: $e');
    }
  }
}
