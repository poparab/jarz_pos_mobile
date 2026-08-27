import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/network/frappe_error_message.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../kanban/providers/kanban_provider.dart';
import '../../data/instapay_reconciliation_service.dart';
import '../../data/models/unconfirmed_online_order.dart';
import '../../state/instapay_reconciliation_providers.dart';

/// Bottom sheet used by the reconciliation screen to confirm that the InstaPay
/// bank transfer for an awaiting order actually arrived.
///
/// It reuses the payment-receipt attach flow (`createPaymentReceipt` →
/// `uploadReceiptImage`, method `InstaPay`) plus a bank-reference field, and
/// the Confirm action is gated on BOTH a receipt screenshot and a reference
/// being present. Returns `true` when the payment was confirmed.
class ConfirmPaymentSheet extends ConsumerStatefulWidget {
  const ConfirmPaymentSheet({
    super.key,
    required this.order,
    required this.posProfile,
  });

  final UnconfirmedOnlineOrder order;
  final String? posProfile;

  static Future<bool?> show(
    BuildContext context, {
    required UnconfirmedOnlineOrder order,
    required String? posProfile,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ConfirmPaymentSheet(order: order, posProfile: posProfile),
    );
  }

  @override
  ConsumerState<ConfirmPaymentSheet> createState() =>
      _ConfirmPaymentSheetState();
}

class _ConfirmPaymentSheetState extends ConsumerState<ConfirmPaymentSheet> {
  final TextEditingController _referenceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _receiptName;
  String? _receiptImageUrl;
  bool _isPreparingReceipt = false;
  bool _isUploadingReceipt = false;
  bool _isRemovingReceipt = false;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    // Seed from any receipt already attached to the order so the manager can
    // just add the reference and confirm.
    _receiptName = widget.order.receiptName;
    _receiptImageUrl = widget.order.receiptImageUrl;
    if ((widget.order.expectedReference ?? '').isNotEmpty) {
      _referenceController.text = widget.order.expectedReference!;
    }
    _referenceController.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _referenceController.removeListener(_handleChanged);
    _referenceController.dispose();
    super.dispose();
  }

  void _handleChanged() => setState(() {});

  bool get _hasPosProfile => (widget.posProfile?.trim().isNotEmpty ?? false);

  bool get _hasReceipt {
    final name = (_receiptName ?? '').trim();
    final image = (_receiptImageUrl ?? '').trim();
    return name.isNotEmpty && image.isNotEmpty;
  }

  bool get _hasReference => _referenceController.text.trim().isNotEmpty;

  bool get _isBusy =>
      _isPreparingReceipt ||
      _isUploadingReceipt ||
      _isRemovingReceipt ||
      _isConfirming;

  /// A receipt can only be swapped or dropped before it is confirmed.
  bool get _isReceiptEditable {
    final status = (widget.order.receiptStatus ?? '').trim();
    return status.isEmpty || status == 'Unconfirmed';
  }

  bool get _canConfirm =>
      _hasPosProfile && _hasReceipt && _hasReference && !_isBusy;

  Future<XFile?> _pickReceiptImage() async {
    final l10n = context.l10n;
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.receiptSelectImageSource),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.receiptCamera),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.receiptGallery),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;
    return _picker.pickImage(source: source);
  }

  Future<String> _ensureReceiptRecord() async {
    final existing = (_receiptName ?? '').trim();
    if (existing.isNotEmpty) return existing;

    final fallbackError = context.l10n.commonError;
    final posProfile = widget.posProfile?.trim();
    if (posProfile == null || posProfile.isEmpty) {
      throw Exception(context.l10n.invoiceSelectPosFirst);
    }

    final result = await ref.read(kanbanProvider.notifier).createPaymentReceipt(
          salesInvoice: widget.order.invoice,
          paymentMethod: 'InstaPay',
          amount: widget.order.amount,
          posProfile: posProfile,
        );
    final createdName = (result?['receipt_name'] ?? '').toString().trim();
    if (result == null || result['success'] != true || createdName.isEmpty) {
      throw Exception(
        (result?['message']?.toString().trim().isNotEmpty ?? false)
            ? result!['message'].toString()
            : fallbackError,
      );
    }
    setState(() => _receiptName = createdName);
    return createdName;
  }

  Future<void> _uploadReceiptImage() async {
    if (_isBusy || !_isReceiptEditable) return;
    final image = await _pickReceiptImage();
    if (image == null) return;
    if (!mounted) return;

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      setState(() => _isPreparingReceipt = true);
      final receiptName = await _ensureReceiptRecord();
      final bytes = await image.readAsBytes();
      final encoded = base64Encode(bytes);
      if (!mounted) return;

      setState(() {
        _isPreparingReceipt = false;
        _isUploadingReceipt = true;
      });
      messenger.showSnackBar(SnackBar(content: Text(l10n.receiptUploading)));

      final result = await ref.read(kanbanProvider.notifier).uploadReceiptImage(
            receiptName: receiptName,
            imageData: encoded,
            filename: image.name,
          );
      if (!mounted) return;

      setState(() {
        _receiptImageUrl = (result?['file_url'] ?? '').toString().trim();
        _isUploadingReceipt = false;
      });
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.receiptUploadedSuccess)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isPreparingReceipt = false;
        _isUploadingReceipt = false;
      });
      final friendly = extractFrappeErrorMessage(error, fallback: l10n.commonError);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.receiptUploadError(friendly))),
      );
    }
  }

  Future<void> _removeReceiptImage() async {
    if (_isBusy || !_hasReceipt || !_isReceiptEditable) return;
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.receiptRemoveConfirmTitle),
        content: Text(l10n.receiptRemoveConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.receiptRemoveImageButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final receiptName = (_receiptName ?? '').trim();
    try {
      setState(() => _isRemovingReceipt = true);
      messenger.showSnackBar(SnackBar(content: Text(l10n.receiptRemoving)));

      await ref.read(kanbanProvider.notifier).removeReceiptImage(
            receiptName: receiptName,
          );
      if (!mounted) return;

      // Keep the receipt record so the next upload reuses the same row.
      setState(() {
        _receiptImageUrl = null;
        _isRemovingReceipt = false;
      });
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.receiptRemovedSuccess)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isRemovingReceipt = false);
      final friendly = extractFrappeErrorMessage(
        error,
        fallback: l10n.receiptRemoveFailed,
      );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.receiptRemoveError(friendly))),
      );
    }
  }

  String? _resolveReceiptUrl(String? rawUrl) {
    final value = (rawUrl ?? '').trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final baseUrl = dotenv.get('ERP_BASE_URL', fallback: '').trim();
    if (baseUrl.isEmpty) return null;
    final normalizedBase =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final normalizedPath = value.startsWith('/') ? value : '/$value';
    return '$normalizedBase$normalizedPath';
  }

  Future<void> _previewReceipt() async {
    final resolved = _resolveReceiptUrl(_receiptImageUrl);
    if (resolved == null) return;
    final uri = Uri.tryParse(resolved);
    if (uri == null) return;
    await launchUrl(uri);
  }

  Future<void> _confirm() async {
    if (!_canConfirm) return;
    final posProfile = widget.posProfile!.trim();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isConfirming = true);
    try {
      await ref.read(instapayReconciliationServiceProvider).confirmOnlinePayment(
            invoiceName: widget.order.invoice,
            posProfile: posProfile,
            referenceNo: _referenceController.text.trim(),
            receiptName: _receiptName!.trim(),
          );
      if (!mounted) return;
      ref.invalidate(unconfirmedOnlineOrdersProvider(widget.posProfile));
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.instapayPaymentConfirmed)),
      );
      navigator.pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isConfirming = false);
      final failedMessage = context.l10n.instapayConfirmFailed;
      final friendly =
          extractFrappeErrorMessage(error, fallback: failedMessage);
      messenger.showSnackBar(SnackBar(content: Text(friendly)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final width = ResponsiveUtils.getDialogWidth(
      context,
      small: 420,
      medium: 460,
      large: 520,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SizedBox(
          width: width,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.instapayConfirmSheetTitle,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.order.displayId} · ${widget.order.customerName}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                if ((widget.order.expectedReference ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Expected reference: ${widget.order.expectedReference}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                if (!_hasPosProfile) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.invoiceSelectPosFirst,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _referenceController,
                  decoration: InputDecoration(
                    labelText: context.l10n.instapayBankReference,
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
                            _hasReceipt
                                ? Icons.verified_outlined
                                : Icons.upload_file_outlined,
                            color: _hasReceipt
                                ? Colors.green[700]
                                : Colors.orange[800],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _hasReceipt
                                  ? (_receiptName ?? l10n.receiptUploadImageButton)
                                  : l10n.receiptUploadImageButton,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      if (_isBusy) ...[
                        const SizedBox(height: 10),
                        const LinearProgressIndicator(),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_isReceiptEditable)
                            ElevatedButton.icon(
                              onPressed: _isBusy ? null : _uploadReceiptImage,
                              icon: Icon(
                                _hasReceipt
                                    ? Icons.refresh
                                    : Icons.upload_file_outlined,
                              ),
                              label: Text(
                                _hasReceipt
                                    ? l10n.receiptReplaceImageButton
                                    : l10n.receiptUploadImageButton,
                              ),
                            ),
                          if (_hasReceipt)
                            OutlinedButton.icon(
                              onPressed: _isBusy ? null : _previewReceipt,
                              icon: const Icon(Icons.open_in_new),
                              label: Text(l10n.commonPreview),
                            ),
                          if (_hasReceipt && _isReceiptEditable)
                            TextButton.icon(
                              onPressed: _isBusy ? null : _removeReceiptImage,
                              icon: const Icon(Icons.delete_outline),
                              label: Text(l10n.receiptRemoveImageButton),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canConfirm ? _confirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, size: 18),
                        const SizedBox(width: 6),
                        Text(context.l10n.instapayConfirmReceived),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed:
                        _isBusy ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n.commonCancel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
