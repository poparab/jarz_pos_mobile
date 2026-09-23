import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import '../../../core/localization/user_error_message.dart';

/// The server's own refusal, verbatim, when there is one.
///
/// Branch access refusals carry the fact the manager needs ("Dokki has an open
/// shift (seif@… since 12:47)…"), and the shared presenter drops an English
/// server sentence on an Arabic UI in favour of a generic line. So: when the
/// server answered, show what it said (still passed through the presenter's
/// safety filter — no tracebacks, SQL or URLs); only a transport failure, or a
/// body with nothing safe in it, falls back to the localised message.
String serverErrorText(BuildContext context, Object? error) {
  if (error is DioException && error.response != null) {
    final text = detailedServerMessage(error.response!.data);
    if (text != null) return text;
  }
  return context.userErrorMessage(error);
}
