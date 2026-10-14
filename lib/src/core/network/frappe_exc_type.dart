import 'package:dio/dio.dart';

/// The Frappe `exc_type` of a refused call, or null.
///
/// Frappe puts the exception class name of a structured refusal in the reply
/// body (`{"exc_type": "AddressPinRequired", ...}`), and that class name is the
/// stable code clients branch on. `extractFrappeErrorMessage` / `mapFrappeError`
/// reduce an error to its human sentence and throw the code away, so read it
/// from the raw [DioException] BEFORE wrapping the error.
String? frappeExcType(Object? error) {
  if (error is! DioException) return null;
  final data = error.response?.data;
  if (data is Map) {
    final raw = data['exc_type'];
    final text = raw?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
  return null;
}
