// Web stub — canvas receipt renderer is Android/iOS only.
import 'dart:typed_data';
import '../pos_printer_service.dart'
    if (dart.library.html) '../pos_printer_service_web.dart';

class ReceiptCanvasRenderer {
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
    throw UnsupportedError('ReceiptCanvasRenderer is not supported on web.');
  }
}
