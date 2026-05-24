import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/localized_display_mappers.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/utils/responsive_utils.dart';
import '../models/kanban_models.dart';
import '../providers/kanban_provider.dart';

class PaymentCollectionChangeRequest {
  const PaymentCollectionChangeRequest({
    required this.method,
    this.receiptName,
    this.referenceNo,
    this.notes,
  });

  final String method;
  final String? receiptName;
  final String? referenceNo;
  final String? notes;
}

class PaymentCollectionChangeDialog extends ConsumerStatefulWidget {
  const PaymentCollectionChangeDialog({
    super.key,
    required this.invoice,
    required this.posProfile,
  });

  final InvoiceCard invoice;
  final String? posProfile;

  static Future<PaymentCollectionChangeRequest?> show(
    BuildContext context, {
    required InvoiceCard invoice,
    required String? posProfile,
  }) {
    return showDialog<PaymentCollectionChangeRequest>(
      context: context,
      builder: (_) => PaymentCollectionChangeDialog(
        invoice: invoice,
        posProfile: posProfile,
      ),
    );
  }

  @override
  ConsumerState<PaymentCollectionChangeDialog> createState() =>
      _PaymentCollectionChangeDialogState();
}

class _PaymentCollectionChangeDialogState
    extends ConsumerState<PaymentCollectionChangeDialog> {
  late String _selectedMethod;
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _receiptName;
  String? _receiptMethod;
  String? _receiptStatus;
  String? _receiptImageUrl;
  bool _isPreparingReceipt = false;
  bool _isUploadingReceipt = false;

  String get _currentMethod {
    final actual = widget.invoice.actualPaymentMethod?.trim() ?? '';
    if (actual.isNotEmpty) {
      return actual;
    }
    return widget.invoice.paymentMethod?.trim() ?? '';
  }

  bool get _requiresReceipt => _normalizeMethod(_selectedMethod) != 'cash';

  bool get _hasPosProfile => (widget.posProfile?.trim().isNotEmpty ?? false);

  bool get _isSameMethod =>
      _normalizeMethod(_selectedMethod) == _normalizeMethod(_currentMethod);

  bool get _hasUploadedReceipt {
    final receiptName = (_receiptName ?? '').trim();
    final imageUrl = (_receiptImageUrl ?? '').trim();
    return receiptName.isNotEmpty && imageUrl.isNotEmpty;
  }

  double get _receiptAmount {
    final outstanding = widget.invoice.outstandingAmount;
    if (outstanding > 0) {
      return outstanding;
    }
    return widget.invoice.grandTotal;
  }

  bool get _canSubmit {
    if (!_hasPosProfile || _isSameMethod) {
      return false;
    }
    if (_requiresReceipt && !_hasUploadedReceipt) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _selectedMethod = _normalizeMethod(_currentMethod) == 'cash'
        ? 'Instapay'
        : 'Cash';
    _syncReceiptForSelectedMethod();
    _referenceController.addListener(_handleChanged);
    _notesController.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _referenceController.removeListener(_handleChanged);
    _notesController.removeListener(_handleChanged);
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleChanged() {
    setState(() {});
  }

  String _normalizeMethod(String method) {
    return method.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  }

  String _receiptApiMethod(String method) {
    switch (_normalizeMethod(method)) {
      case 'instapay':
        return 'InstaPay';
      case 'mobilewallet':
      case 'wallet':
        return 'Wallet';
      default:
        return method;
    }
  }

  void _syncReceiptForSelectedMethod() {
    final selectedMethod = _normalizeMethod(_selectedMethod);
    if (selectedMethod == 'cash') {
      return;
    }

    if (_normalizeMethod(_receiptMethod ?? '') == selectedMethod &&
        (_receiptName?.trim().isNotEmpty ?? false)) {
      return;
    }

    if (_normalizeMethod(widget.invoice.paymentReceiptMethod ?? '') == selectedMethod) {
      _receiptName = widget.invoice.paymentReceiptName?.trim();
      _receiptMethod = widget.invoice.paymentReceiptMethod?.trim();
      _receiptStatus = widget.invoice.paymentReceiptStatus?.trim();
      _receiptImageUrl = widget.invoice.paymentReceiptImageUrl?.trim();
      return;
    }

    _receiptName = null;
    _receiptMethod = null;
    _receiptStatus = null;
    _receiptImageUrl = null;
  }

  void _handleMethodSelected(String value) {
    setState(() {
      _selectedMethod = value;
      _syncReceiptForSelectedMethod();
    });
  }

  Future<XFile?> _pickReceiptImage() async {
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
    if (source == null) {
      return null;
    }
    return _picker.pickImage(source: source);
  }

  Future<String> _ensureReceiptRecord() async {
    final receiptName = (_receiptName ?? '').trim();
    if (receiptName.isNotEmpty) {
      return receiptName;
    }

    final posProfile = widget.posProfile?.trim();
    final fallbackError = context.l10n.commonError;
    if (posProfile == null || posProfile.isEmpty) {
      throw Exception(context.l10n.invoiceSelectPosFirst);
    }

    final result = await ref.read(kanbanProvider.notifier).createPaymentReceipt(
          salesInvoice: widget.invoice.name,
          paymentMethod: _receiptApiMethod(_selectedMethod),
          amount: _receiptAmount,
          posProfile: posProfile,
        );
    final createdName = (result?['receipt_name'] ?? '').toString().trim();
    if (result == null || result['success'] != true || createdName.isEmpty) {
      throw Exception(
        result?['message']?.toString().trim().isNotEmpty == true
            ? result!['message'].toString()
            : fallbackError,
      );
    }

    setState(() {
      _receiptName = createdName;
      _receiptMethod = _receiptApiMethod(_selectedMethod);
      _receiptStatus = 'Unconfirmed';
    });
    return createdName;
  }

  String? _resolveReceiptUrl(String? rawUrl) {
    final value = (rawUrl ?? '').trim();
    if (value.isEmpty) {
      return null;
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final baseUrl = dotenv.get('ERP_BASE_URL', fallback: '').trim();
    if (baseUrl.isEmpty) {
      return null;
    }
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = value.startsWith('/') ? value : '/$value';
    return '$normalizedBase$normalizedPath';
  }

  Future<void> _previewReceipt() async {
    final resolvedUrl = _resolveReceiptUrl(_receiptImageUrl);
    if (resolvedUrl == null) {
      return;
    }
    final uri = Uri.tryParse(resolvedUrl);
    if (uri == null) {
      return;
    }
    await launchUrl(uri);
  }

  Future<void> _uploadReceiptImage() async {
    if (!_requiresReceipt || _isPreparingReceipt || _isUploadingReceipt) {
      return;
    }
    final image = await _pickReceiptImage();
    if (image == null || !mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      setState(() => _isPreparingReceipt = true);
      final receiptName = await _ensureReceiptRecord();
      final bytes = await image.readAsBytes();
      final encodedImage = base64Encode(bytes);

      if (!mounted) {
        return;
      }

      setState(() {
        _isPreparingReceipt = false;
        _isUploadingReceipt = true;
      });
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.receiptUploading)),
      );

      final result = await ref.read(kanbanProvider.notifier).uploadReceiptImage(
            receiptName: receiptName,
            imageData: encodedImage,
            filename: image.name,
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _receiptMethod = _receiptApiMethod(_selectedMethod);
        _receiptStatus = 'Unconfirmed';
        _receiptImageUrl = (result?['file_url'] ?? '').toString().trim();
        _isUploadingReceipt = false;
      });

      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.receiptUploadedSuccess)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isPreparingReceipt = false;
        _isUploadingReceipt = false;
      });
      final message = error.toString().trim();
      final friendly = message.startsWith('Exception: ')
          ? message.substring('Exception: '.length)
          : message;
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.l10n.receiptUploadError(friendly)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentMethodLabel = localizedPaymentMethodLabel(
      context,
      _currentMethod.isEmpty ? null : _currentMethod,
    );
    final isBusy = _isPreparingReceipt || _isUploadingReceipt;
    final receiptMethodLabel = localizedPaymentMethodLabel(
      context,
      (_receiptMethod ?? '').isEmpty ? _selectedMethod : _receiptMethod,
    );
    final receiptStatus = (_receiptStatus ?? '').trim().isEmpty
        ? 'Unconfirmed'
        : _receiptStatus!;

    return AlertDialog(
      title: Text(l10n.invoiceChangeCollectionMethod),
      content: SizedBox(
        width: ResponsiveUtils.getDialogWidth(
          context,
          small: 420,
          medium: 420,
          large: 480,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                label: l10n.invoiceRequestedPaymentMethod,
                value: localizedPaymentMethodLabel(
                  context,
                  widget.invoice.paymentMethod,
                ),
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: l10n.invoiceActualCollectionMethod,
                value: currentMethodLabel,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: l10n.posTotalLabel,
                value: widget.invoice.grandTotal.toStringAsFixed(2),
              ),
              if (!_hasPosProfile) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.invoiceSelectPosFirst,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                l10n.invoiceSelectPaymentMethod,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _MethodOptionTile(
                title: l10n.paymentMethodCash,
                value: 'Cash',
                selectedValue: _selectedMethod,
                onChanged: _handleMethodSelected,
                icon: Icons.payments_outlined,
              ),
              _MethodOptionTile(
                title: l10n.paymentMethodInstapay,
                value: 'Instapay',
                selectedValue: _selectedMethod,
                onChanged: _handleMethodSelected,
                icon: Icons.account_balance,
              ),
              _MethodOptionTile(
                title: l10n.paymentMethodMobileWallet,
                value: 'Mobile Wallet',
                selectedValue: _selectedMethod,
                onChanged: _handleMethodSelected,
                icon: Icons.account_balance_wallet,
              ),
              if (_requiresReceipt) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _referenceController,
                  decoration: InputDecoration(
                    labelText: l10n.invoiceCollectionReferenceLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _hasUploadedReceipt
                                ? Icons.verified_outlined
                                : Icons.upload_file_outlined,
                            color: _hasUploadedReceipt
                                ? Colors.green[700]
                                : Colors.orange[800],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _hasUploadedReceipt
                                  ? _receiptName ?? l10n.receiptUploadImageButton
                                  : l10n.receiptUploadImageButton,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$receiptMethodLabel • ${localizedStatusLabel(context, receiptStatus)}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isBusy) ...[
                        const SizedBox(height: 10),
                        const LinearProgressIndicator(),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: isBusy ? null : _uploadReceiptImage,
                            icon: const Icon(Icons.upload_file_outlined),
                            label: Text(l10n.receiptUploadImageButton),
                          ),
                          if (_hasUploadedReceipt)
                            OutlinedButton.icon(
                              onPressed: _previewReceipt,
                              icon: const Icon(Icons.open_in_new),
                              label: Text(l10n.commonPreview),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.commonNotesLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_isSameMethod) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.invoiceAlreadyStatus(currentMethodLabel),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: !_canSubmit
              ? null
              : () => Navigator.of(context).pop(
                    PaymentCollectionChangeRequest(
                      method: _selectedMethod,
                    receiptName: _requiresReceipt ? _receiptName : null,
                      referenceNo: _referenceController.text.trim().isEmpty
                          ? null
                          : _referenceController.text.trim(),
                      notes: _notesController.text.trim().isEmpty
                          ? null
                          : _notesController.text.trim(),
                    ),
                  ),
          child: Text(l10n.invoiceSubmit),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _MethodOptionTile extends StatelessWidget {
  const _MethodOptionTile({
    required this.title,
    required this.value,
    required this.selectedValue,
    required this.onChanged,
    required this.icon,
  });

  final String title;
  final String value;
  final String selectedValue;
  final ValueChanged<String> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final selected = value == selectedValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.green : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          color: selected ? Colors.green.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.green : Colors.grey[600]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.green[800] : Colors.black87,
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Colors.green : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}