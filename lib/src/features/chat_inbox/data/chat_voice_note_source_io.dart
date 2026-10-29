import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'chat_voice_note_source.dart' show chatVoiceNoteExtension;

typedef CreatedVoiceNoteUri = ({Uri uri, Future<void> Function() release});

/// Writes [bytes] to a uniquely named file under the app's temp directory
/// (`chat_voice_notes/`) and returns its file URI; release deletes it.
Future<CreatedVoiceNoteUri> createVoiceNoteUri(
  Uint8List bytes, {
  String? mime,
  required String fileName,
}) async {
  final temp = await getTemporaryDirectory();
  final dir = Directory('${temp.path}${Platform.pathSeparator}chat_voice_notes');
  await dir.create(recursive: true);
  var safe = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  if (safe.isEmpty) safe = 'voice';
  if (!safe.contains('.')) safe = '$safe${chatVoiceNoteExtension(mime)}';
  final file = File(
    '${dir.path}${Platform.pathSeparator}'
    '${DateTime.now().microsecondsSinceEpoch}_$safe',
  );
  await file.writeAsBytes(bytes, flush: true);
  return (
    uri: Uri.file(file.path),
    release: () async {
      if (await file.exists()) await file.delete();
    },
  );
}
