import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

typedef CreatedVoiceNoteUri = ({Uri uri, Future<void> Function() release});

/// Wraps [bytes] (fetched through the authenticated Dio client) in a Blob and
/// returns its object URL, so the audio element never needs the session
/// cookie. Release revokes the URL.
Future<CreatedVoiceNoteUri> createVoiceNoteUri(
  Uint8List bytes, {
  String? mime,
  required String fileName,
}) async {
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: mime ?? ''),
  );
  final url = web.URL.createObjectURL(blob);
  return (
    uri: Uri.parse(url),
    release: () async => web.URL.revokeObjectURL(url),
  );
}
