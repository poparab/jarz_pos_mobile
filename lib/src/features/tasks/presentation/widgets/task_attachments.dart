import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/tasks_repository.dart';
import '../../models/task_models.dart';
import '../../state/tasks_providers.dart';
import '../task_labels.dart';

/// A file picked on the device, ready to upload.
typedef TaskPickedFile = ({String filename, Uint8List bytes});

/// Extensions the server refuses (403): anything a browser could render as
/// active content when the file is opened from the download endpoint.
/// `file_picker` only takes an allow-list, so these are refused after the
/// pick, with a message, rather than sent to fail on the server.
const kTaskBlockedExtensions = {
  'html',
  'htm',
  'svg',
  'xml',
  'js',
  'mjs',
  'xhtml',
};

/// Whether [filename]'s extension is one the server refuses.
bool isTaskFileTypeBlocked(String filename) {
  final dot = filename.lastIndexOf('.');
  if (dot < 0 || dot == filename.length - 1) return false;
  return kTaskBlockedExtensions.contains(
    filename.substring(dot + 1).trim().toLowerCase(),
  );
}

enum _PickSource { camera, gallery, file }

/// Asks where the file comes from (camera, gallery, any file) and reads it.
///
/// Files over the server's 10 MB limit, and empty reads (a revoked permission
/// or an unreadable cloud asset hands back zero bytes), are refused here with
/// a snackbar rather than sent to fail on the server.
Future<List<TaskPickedFile>> pickTaskFiles(BuildContext context) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final source = await showModalBottomSheet<_PickSource>(
    context: context,
    useSafeArea: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.tasksAttachCamera),
            onTap: () => Navigator.of(sheetContext).pop(_PickSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.tasksAttachGallery),
            onTap: () => Navigator.of(sheetContext).pop(_PickSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.attach_file),
            title: Text(l10n.tasksAttachFile),
            onTap: () => Navigator.of(sheetContext).pop(_PickSource.file),
          ),
        ],
      ),
    ),
  );
  if (source == null) return const [];

  final picked = <TaskPickedFile>[];
  switch (source) {
    case _PickSource.camera:
    case _PickSource.gallery:
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source == _PickSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        // A phone photo is routinely 5-12 MB; this keeps it readable and
        // comfortably under the server's limit.
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 82,
      );
      if (image == null) return const [];
      picked.add((filename: image.name, bytes: await image.readAsBytes()));
    case _PickSource.file:
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return const [];
      for (final file in result.files) {
        final bytes = file.bytes;
        picked.add((filename: file.name, bytes: bytes ?? Uint8List(0)));
      }
  }

  final accepted = <TaskPickedFile>[];
  for (final file in picked) {
    if (isTaskFileTypeBlocked(file.filename)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.tasksFileTypeBlocked(file.filename))),
      );
      continue;
    }
    if (file.bytes.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.tasksFileEmpty)));
      continue;
    }
    if (file.bytes.length > taskAttachmentMaxBytes) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.tasksFileTooLarge(file.filename))),
      );
      continue;
    }
    accepted.add(file);
  }
  return accepted;
}

/// Opens a non-image attachment.
///
/// Web: the browser opens the download URL in a new tab with its own session
/// cookie. Mobile: the bytes are fetched through the authenticated client and
/// handed to the system "save as" dialog.
Future<void> openTaskAttachment(
  BuildContext context,
  WidgetRef ref,
  TaskAttachment attachment,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final repo = ref.read(tasksRepositoryProvider);
  try {
    if (kIsWeb) {
      await launchUrl(
        Uri.parse(repo.downloadUrl(attachment.name)),
        webOnlyWindowName: '_blank',
      );
      return;
    }
    final bytes = await repo.downloadAttachment(attachment.name);
    final path = await FilePicker.platform.saveFile(
      fileName: attachment.fileName.isNotEmpty
          ? attachment.fileName
          : attachment.name,
      bytes: bytes,
    );
    if (path == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.tasksFileSaved(path))),
    );
  } catch (e) {
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(taskErrorMessage(context, e))),
    );
  }
}

/// Full-screen preview of an image attachment, zoomable.
Future<void> showTaskImagePreview(
  BuildContext context,
  TaskAttachment attachment,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ImagePreviewDialog(attachment: attachment),
  );
}

class _ImagePreviewDialog extends ConsumerWidget {
  final TaskAttachment attachment;
  const _ImagePreviewDialog({required this.attachment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(taskAttachmentBytesProvider(attachment.name));
    final l10n = context.l10n;
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              attachment.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(attachment.uploaderDisplay),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: l10n.tasksDownload,
                  icon: const Icon(Icons.download),
                  onPressed: () => openTaskAttachment(context, ref, attachment),
                ),
                IconButton(
                  tooltip: l10n.commonClose,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Flexible(
            child: bytes.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text(taskErrorMessage(context, e)),
              ),
              data: (data) => InteractiveViewer(
                maxScale: 5,
                child: Image.memory(data, fit: BoxFit.contain),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A thumbnail (image) or a file chip (anything else). Tap previews or opens.
class TaskAttachmentTile extends ConsumerWidget {
  final TaskAttachment attachment;
  final VoidCallback? onRemove;
  final double size;

  const TaskAttachmentTile({
    super.key,
    required this.attachment,
    this.onRemove,
    this.size = 84,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final tooltip = attachment.creation == null
        ? '${attachment.fileName}\n${attachment.uploaderDisplay}'
        : '${attachment.fileName}\n${l10n.tasksUploadedBy(attachment.uploaderDisplay, formatDateTime(context, attachment.creation!))}';

    Widget content;
    if (attachment.isImage) {
      final bytes = ref.watch(taskAttachmentBytesProvider(attachment.name));
      content = SizedBox(
        width: size,
        height: size,
        child: bytes.when(
          loading: () => const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, _) => const Icon(Icons.broken_image_outlined),
          data: (data) => Image.memory(
            data,
            fit: BoxFit.cover,
            cacheWidth: (size * 2).round(),
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
          ),
        ),
      );
    } else {
      content = SizedBox(
        width: size * 1.6,
        height: size,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_fileIcon(attachment), size: 28, color: scheme.primary),
              const SizedBox(height: 4),
              Text(
                attachment.fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return Tooltip(
      message: tooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => attachment.isImage
                  ? showTaskImagePreview(context, attachment)
                  : openTaskAttachment(context, ref, attachment),
              child: content,
            ),
          ),
          if (onRemove != null)
            PositionedDirectional(
              top: -8,
              end: -8,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: l10n.tasksRemoveAttachment,
                style: IconButton.styleFrom(
                  backgroundColor: scheme.surface,
                  padding: EdgeInsets.zero,
                ),
                icon: Icon(Icons.cancel, color: scheme.error, size: 20),
                onPressed: onRemove,
              ),
            ),
        ],
      ),
    );
  }

  static IconData _fileIcon(TaskAttachment a) {
    final type = a.contentType.toLowerCase();
    final name = a.fileName.toLowerCase();
    if (type.contains('pdf') || name.endsWith('.pdf')) {
      return Icons.picture_as_pdf_outlined;
    }
    if (type.contains('sheet') ||
        type.contains('excel') ||
        name.endsWith('.xlsx') ||
        name.endsWith('.csv')) {
      return Icons.table_chart_outlined;
    }
    if (type.startsWith('video/')) return Icons.movie_outlined;
    if (type.startsWith('audio/')) return Icons.audiotrack_outlined;
    return Icons.insert_drive_file_outlined;
  }
}
