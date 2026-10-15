import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/localization/localization_extensions.dart';

/// Builds an RFC 4180 CSV from [rows] (the first row is normally the header).
/// Cells containing a comma, quote, CR or LF are quoted, quotes doubled.
/// Lines end with CRLF. A UTF-8 BOM is prepended when [bom] is true so Excel
/// opens Arabic text correctly.
String buildReportCsv(List<List<String>> rows, {bool bom = true}) {
  String cell(String v) {
    if (v.contains(RegExp(r'[",\r\n]'))) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  final body = rows.map((r) => r.map(cell).join(',')).join('\r\n');
  return bom ? '﻿$body\r\n' : '$body\r\n';
}

/// `title_2026-10-15.csv` with the title reduced to filename-safe characters
/// (letters of any script, digits, `-`, `_`).
String reportCsvFileName(String title, [DateTime? now]) {
  final n = now ?? DateTime.now();
  final stamp = '${n.year.toString().padLeft(4, '0')}-'
      '${n.month.toString().padLeft(2, '0')}-'
      '${n.day.toString().padLeft(2, '0')}';
  var safe = title
      .trim()
      .replaceAll(RegExp(r'[\\/:*?"<>|&,;]+'), ' ')
      .replaceAll(RegExp(r'\s+'), '_');
  if (safe.isEmpty) safe = 'report';
  if (safe.length > 60) safe = safe.substring(0, 60);
  return '${safe}_$stamp.csv';
}

/// AppBar action that exports the visible report as CSV through the share
/// sheet (a file where the platform can share files; on a browser without
/// file sharing, a download). If sharing a file fails it shares the CSV as
/// text, and if that fails too it copies the CSV to the clipboard.
///
/// [rows] is called on tap, so it always exports the current data; return an
/// empty list (or only a header) when there is nothing loaded yet.
class ReportExportButton extends StatelessWidget {
  final String title;
  final List<List<String>> Function() rows;

  const ReportExportButton({
    super.key,
    required this.title,
    required this.rows,
  });

  Future<void> _export(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final box = context.findRenderObject() as RenderBox?;
    final origin = (box != null && box.hasSize)
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    List<List<String>> data;
    try {
      data = rows();
    } catch (e) {
      debugPrint('[ReportExport] rows() failed: $e');
      messenger?.showSnackBar(SnackBar(content: Text(l10n.rptExportFailed)));
      return;
    }
    if (data.length <= 1) {
      messenger?.showSnackBar(SnackBar(content: Text(l10n.rptExportEmpty)));
      return;
    }

    final csv = buildReportCsv(data);
    final fileName = reportCsvFileName(title);
    final bytes = Uint8List.fromList(utf8.encode(csv));

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, name: fileName, mimeType: 'text/csv')],
          fileNameOverrides: [fileName],
          subject: title,
          title: title,
          sharePositionOrigin: origin,
          downloadFallbackEnabled: true,
        ),
      );
      return;
    } catch (e) {
      debugPrint('[ReportExport] file share failed: $e');
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: buildReportCsv(data, bom: false),
          subject: title,
          sharePositionOrigin: origin,
        ),
      );
      return;
    } catch (e) {
      debugPrint('[ReportExport] text share failed: $e');
    }

    try {
      await Clipboard.setData(ClipboardData(text: buildReportCsv(data, bom: false)));
      messenger?.showSnackBar(SnackBar(content: Text(l10n.rptExportCopied)));
    } catch (e) {
      debugPrint('[ReportExport] clipboard failed: $e');
      messenger?.showSnackBar(SnackBar(content: Text(l10n.rptExportFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (btnContext) => IconButton(
        icon: const Icon(Icons.ios_share),
        tooltip: context.l10n.rptExport,
        onPressed: () => _export(btnContext),
      ),
    );
  }
}
