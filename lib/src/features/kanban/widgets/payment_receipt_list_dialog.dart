import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/network/frappe_error_message.dart';
import '../providers/kanban_provider.dart';

class PaymentReceiptListDialog extends ConsumerStatefulWidget {
  const PaymentReceiptListDialog({super.key});

  @override
  ConsumerState<PaymentReceiptListDialog> createState() => _PaymentReceiptListDialogState();
}

class _PaymentReceiptListDialogState extends ConsumerState<PaymentReceiptListDialog> {
  String? selectedPosProfile;
  List<String> posProfiles = [];
  List<Map<String, dynamic>> receipts = [];
  bool loading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    
    // Load accessible POS profiles
    final profiles = await ref.read(kanbanProvider.notifier).getAccessiblePOSProfiles();
    
    // Load receipts
    final receiptList = await ref.read(kanbanProvider.notifier).listPaymentReceipts(
      posProfile: selectedPosProfile,
    );
    
    setState(() {
      posProfiles = profiles;
      receipts = receiptList;
      loading = false;
    });
  }

  Future<void> _uploadImage(String receiptName) async {
    try {
      // Show source selection
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.l10n.receiptSelectImageSource),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(context.l10n.receiptCamera),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(context.l10n.receiptGallery),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Pick image
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      // Convert to base64
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Upload
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.receiptUploading)),
      );

      final result = await ref.read(kanbanProvider.notifier).uploadReceiptImage(
        receiptName: receiptName,
        imageData: base64Image,
        filename: image.name,
      );

      if (result != null && result['success'] == true) {
        messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.receiptUploadedSuccess)),
        );
        await _loadData(); // Refresh list
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.receiptUploadFailed)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = extractFrappeErrorMessage(
        e,
        fallback: context.l10n.receiptUploadFailed,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.receiptUploadError(errorMessage))),
      );
    }
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error, color: Colors.white, size: 48),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReceipt(String receiptName) async {
    try {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.receiptConfirming)),
      );

      final result = await ref.read(kanbanProvider.notifier).confirmReceipt(
        receiptName: receiptName,
      );

      if (result != null && result['success'] == true) {
        messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.receiptConfirmedSuccess)),
        );
        await _loadData(); // Refresh list
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.receiptConfirmFailed)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = extractFrappeErrorMessage(
        e,
        fallback: context.l10n.receiptConfirmFailed,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.receiptConfirmError(errorMessage))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Receipts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // POS Profile Filter
            if (posProfiles.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: selectedPosProfile,
                decoration: const InputDecoration(
                  labelText: 'Filter by POS Profile',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(context.l10n.receiptAllProfiles),
                  ),
                  ...posProfiles.map((profile) => DropdownMenuItem<String>(
                        value: profile,
                        child: Text(profile),
                      )),
                ],
                onChanged: (value) {
                  setState(() => selectedPosProfile = value);
                  _loadData();
                },
              ),
            const SizedBox(height: 16),

            // Receipt List
            if (loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (receipts.isEmpty)
              Expanded(
                child: Center(
                  child: Text(context.l10n.receiptNoReceiptsFound),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: receipts.length,
                  itemBuilder: (context, index) {
                    final receipt = receipts[index];
                    return _buildReceiptCard(receipt);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(Map<String, dynamic> receipt) {
    final receiptName = receipt['name'] as String;
    final salesInvoice = receipt['sales_invoice'] as String? ?? 'N/A';
    final paymentMethod = receipt['payment_method'] as String? ?? 'N/A';
    final amount = receipt['amount'] as num? ?? 0;
    final status = receipt['status'] as String? ?? 'Unconfirmed';
    final posProfile = receipt['pos_profile'] as String? ?? 'N/A';
    final receiptImageUrl = receipt['receipt_image_url'] as String?;
    final customerName = receipt['customer_name'] as String? ?? 'N/A';
    final uploadedBy = receipt['uploaded_by'] as String?;

    final isConfirmed = status == 'Confirmed';
    final hasImage = receiptImageUrl != null && receiptImageUrl.isNotEmpty;
    final canConfirm = receipt['can_confirm'] == true ||
      receipt['can_confirm'] == 1 ||
      receipt['can_confirm'] == '1';

    // Build full image URL: prepend ERP base URL if path is relative
    String? fullImageUrl;
    if (hasImage) {
      if (receiptImageUrl.startsWith('http')) {
        fullImageUrl = receiptImageUrl;
      } else {
        final base = dotenv.get('ERP_BASE_URL', fallback: '');
        fullImageUrl = '$base$receiptImageUrl';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    salesInvoice,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isConfirmed ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isConfirmed ? Colors.green[900] : Colors.orange[900],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Invoice details
            Text('Customer: $customerName', style: const TextStyle(fontSize: 14)),
            Text('Amount: ${amount.toStringAsFixed(2)} EGP', style: const TextStyle(fontSize: 14)),
            Text('Payment: $paymentMethod', style: const TextStyle(fontSize: 14)),
            Text('POS Profile: $posProfile', style: const TextStyle(fontSize: 14)),
            if (uploadedBy != null)
              Text('Uploaded by: $uploadedBy', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),

            // Receipt image thumbnail or upload button
            if (hasImage)
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showFullImage(context, fullImageUrl!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        fullImageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!isConfirmed && canConfirm)
                    ElevatedButton.icon(
                      onPressed: () => _confirmReceipt(receiptName),
                      icon: const Icon(Icons.check, size: 16),
                      label: Text(context.l10n.commonConfirm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: () => _uploadImage(receiptName),
                icon: const Icon(Icons.upload, size: 16),
                label: Text(context.l10n.receiptUploadImageButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
