// Legacy PDF receipt system removed. This stub remains only so old calls don't crash imports.
// All methods either return false or throw UnsupportedError to signal the feature is disabled.

class ReceiptService {
  static Future<bool> canPrint() async => false;
  static Future<void> printReceipt(Map<String, dynamic> invoice) async {
    throw UnsupportedError('PDF receipt printing was removed in favor of direct ESC/POS Bluetooth printing.');
  }
  static Future<void> shareReceipt(Map<String, dynamic> invoice) async {
    throw UnsupportedError('PDF receipt sharing was removed.');
  }
}
