import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/network/frappe_error_message.dart';
import '../../data/manufacturing_service.dart';
import '../../data/models/sop.dart';
import '../../state/sop_providers.dart';
import 'sop_step_card.dart' show SopAttachmentImage;

/// Injected so a test can drive the photo path without a camera. Overriding it
/// is also the escape hatch on a platform where `image_picker` has no
/// implementation.
final sopImagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

/// What the operator must record at a step: a number, a temperature, or a photo.
///
/// Numbers are range-checked locally before anything is recorded — an
/// out-of-range reading leaves the step unsatisfied, so the screen's Next
/// button stays disabled.
class SopCaptureField extends ConsumerStatefulWidget {
  const SopCaptureField({
    super.key,
    required this.step,
    required this.progress,
    required this.onValueCaptured,
    required this.onPhotoCaptured,
    this.workOrder,
  });

  final SopStep step;
  final SopStepProgress progress;

  /// Null clears the reading (blank or out of range).
  final ValueChanged<double?> onValueCaptured;

  /// [fileUrl] on a successful upload, [localPath] when the photo was taken but
  /// never reached the server.
  final void Function({String? fileUrl, String? localPath}) onPhotoCaptured;

  /// When null the SOP is only being read (no batch running), so nothing is
  /// posted server-side and the capture stays local.
  final String? workOrder;

  @override
  ConsumerState<SopCaptureField> createState() => _SopCaptureFieldState();
}

class _SopCaptureFieldState extends ConsumerState<SopCaptureField> {
  late final TextEditingController _controller;
  Timer? _recordDebounce;
  bool _outOfRange = false;
  bool _busy = false;

  bool get _hasWorkOrder =>
      widget.workOrder != null && widget.workOrder!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final existing = widget.progress.value;
    _controller = TextEditingController(
      text: existing == null ? '' : _trimNumber(existing),
    );
  }

  @override
  void dispose() {
    _recordDebounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    if (!step.needsCapture) return const SizedBox.shrink();
    if (step.isPhotoCapture) return _buildPhoto(context);
    return _buildNumeric(context);
  }

  // ── Number / temperature ──────────────────────────────────────────────

  Widget _buildNumeric(BuildContext context) {
    final l10n = context.l10n;
    final step = widget.step;
    final theme = Theme.of(context);

    final label = (step.captureLabel ?? '').trim().isNotEmpty
        ? step.captureLabel!.trim()
        : (step.captureType == SopCapture.temperature
            ? l10n.sopCaptureTemperature
            : l10n.sopCaptureNumber);

    final rangeText = (step.captureMin != null || step.captureMax != null)
        ? l10n.sopCaptureOutOfRange(
            step.captureMin == null ? '–' : _trimNumber(step.captureMin!),
            step.captureMax == null ? '–' : _trimNumber(step.captureMax!),
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          // Temperatures go below zero, so the sign has to be reachable.
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*[.,]?\d*')),
          ],
          style: theme.textTheme.headlineSmall,
          decoration: InputDecoration(
            labelText: label,
            helperText: _outOfRange ? null : rangeText,
            errorText: _outOfRange ? rangeText : null,
            border: const OutlineInputBorder(),
          ),
          onChanged: _onValueChanged,
        ),
      ],
    );
  }

  void _onValueChanged(String raw) {
    _recordDebounce?.cancel();

    final parsed = double.tryParse(raw.trim().replaceAll(',', '.'));
    if (parsed == null) {
      if (_outOfRange) setState(() => _outOfRange = false);
      widget.onValueCaptured(null);
      return;
    }

    if (!widget.step.isInRange(parsed)) {
      if (!_outOfRange) setState(() => _outOfRange = true);
      // Nothing is recorded: an out-of-range reading must not satisfy the step.
      widget.onValueCaptured(null);
      return;
    }

    if (_outOfRange) setState(() => _outOfRange = false);
    widget.onValueCaptured(parsed);

    if (!_hasWorkOrder) return;
    // Debounced so typing "72" does not file a reading of 7 first.
    _recordDebounce = Timer(
      const Duration(milliseconds: 700),
      () => _record(value: parsed),
    );
  }

  // ── Photo ─────────────────────────────────────────────────────────────

  Widget _buildPhoto(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final captured = widget.progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((captured.fileUrl ?? '').isNotEmpty) ...[
          SopAttachmentImage(url: captured.fileUrl!, height: 160),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            FilledButton.icon(
              onPressed: _busy ? null : _takePhoto,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  // Restricted to glyphs the app already ships — a new icon
                  // rewrites the tree-shaken font and forces a full APK.
                  : const Icon(Icons.camera_alt),
              label: Text(
                (widget.step.captureLabel ?? '').trim().isNotEmpty
                    ? widget.step.captureLabel!.trim()
                    : l10n.sopCapturePhoto,
              ),
            ),
            if (captured.hasCapture) ...[
              const SizedBox(width: 12),
              Icon(
                captured.photoIsLocalOnly
                    ? Icons.cloud_off
                    : Icons.check_circle,
                size: 18,
                color: captured.photoIsLocalOnly
                    ? scheme.error
                    : scheme.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.sopPhotoCaptured,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _takePhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    setState(() => _busy = true);
    try {
      if (!await _ensureCameraPermission()) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.sopCameraPermissionDenied)),
        );
        return;
      }

      final XFile? shot = await _pick();
      if (shot == null) return;

      final bytes = await shot.readAsBytes();
      // Same failure as the InstaPay receipt sheet: a picker can hand back a
      // zero-byte file, which uploads as an empty body and comes back "File
      // does not exist" — or, worse, registers as a captured step photo that
      // holds nothing. Ask for the shot again instead.
      if (bytes.isEmpty) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.sopPhotoEmpty)));
        return;
      }
      try {
        final url = await ref
            .read(sopPhotoUploaderProvider)
            .upload(bytes: bytes, filename: shot.name);
        widget.onPhotoCaptured(fileUrl: url);
        if (_hasWorkOrder) await _record(fileUrl: url);
      } catch (error) {
        // The photo was genuinely taken; blocking the operator on a flaky
        // upload is worse than letting them continue with the failure shown.
        widget.onPhotoCaptured(localPath: shot.path);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              extractFrappeErrorMessage(error, fallback: l10n.commonError),
            ),
          ),
        );
      }
    } catch (error) {
      // Missing plugin, no camera, a platform that has no picker at all — say
      // so instead of taking the screen down mid-batch.
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            extractFrappeErrorMessage(error, fallback: l10n.commonError),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// True when the camera may be used. Web has no `permission_handler`
  /// implementation — the browser prompts on its own — and a plugin that is not
  /// wired up on a platform must not be fatal.
  Future<bool> _ensureCameraPermission() async {
    if (kIsWeb) return true;
    try {
      final status = await Permission.camera.request();
      return status.isGranted || status.isLimited;
    } on MissingPluginException {
      return true;
    } on PlatformException {
      return true;
    }
  }

  Future<XFile?> _pick() async {
    final picker = ref.read(sopImagePickerProvider);
    try {
      return await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 70,
      );
    } on PlatformException {
      // No camera on this device (a desk browser, an emulator) — the gallery is
      // still a usable answer.
      return picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 70,
      );
    }
  }

  // ── Server ────────────────────────────────────────────────────────────

  Future<void> _record({double? value, String? fileUrl}) async {
    if (!mounted) return;
    final workOrder = widget.workOrder;
    if (workOrder == null || workOrder.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    final fallback = context.l10n.commonError;
    try {
      await ref.read(manufacturingServiceProvider).recordSopStepCapture(
            workOrder: workOrder,
            stepNo: widget.step.stepNo,
            value: value,
            fileUrl: fileUrl,
          );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(extractFrappeErrorMessage(error, fallback: fallback)),
        ),
      );
    }
  }

  String _trimNumber(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toString();
  }
}
