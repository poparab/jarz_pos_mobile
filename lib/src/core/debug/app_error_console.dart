import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../network/frappe_error_message.dart';
import 'app_error_reporter.dart';

class AppErrorConsole extends StatelessWidget {
  const AppErrorConsole({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppErrorReporter.instance,
      builder: (context, _) {
        final reporter = AppErrorReporter.instance;

        return Stack(
          children: <Widget>[
            child,
            if (reporter.hasRecords)
              Positioned(
                right: 16,
                bottom: 16,
                child: SafeArea(
                  child: Material(
                    elevation: 6,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => _showDiagnosticsSheet(context),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB3261E),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.bug_report_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              reporter.records.length == 1
                                  ? '1 error'
                                  : '${reporter.records.length} errors',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showDiagnosticsSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return AnimatedBuilder(
              animation: AppErrorReporter.instance,
              builder: (context, _) {
                final records = AppErrorReporter.instance.records.reversed
                    .toList(growable: false);

                return Material(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                        child: Row(
                          children: <Widget>[
                            const Expanded(
                              child: Text(
                                'Diagnostics',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: records.isEmpty
                                  ? null
                                  : () {
                                      AppErrorReporter.instance.clear();
                                      Navigator.of(context).pop();
                                    },
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Clear'),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Recent uncaught, provider, logger, and API errors are listed here with copyable details.',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            return _ErrorRecordTile(record: records[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ErrorRecordTile extends StatelessWidget {
  const _ErrorRecordTile({required this.record});

  final AppErrorRecord record;

  @override
  Widget build(BuildContext context) {
    final detailsText = record.details.isEmpty
        ? null
        : const JsonEncoder.withIndent('  ').convert(record.details);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          record.message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('${record.source} • ${record.timestamp.toLocal()}'),
        ),
        trailing: IconButton(
          tooltip: 'Copy error',
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(text: record.toClipboardText()),
            );
            if (!context.mounted) {
              return;
            }
            final messenger = ScaffoldMessenger.maybeOf(context);
            messenger?.showSnackBar(
              const SnackBar(content: Text('Error details copied')),
            );
          },
          icon: const Icon(Icons.copy_all_outlined),
        ),
        children: <Widget>[
          if (record.summary != null && record.summary != record.message)
            _DetailBlock(label: 'Summary', value: record.summary!),
          _DetailBlock(label: 'Fatal', value: record.fatal ? 'Yes' : 'No'),
          if (record.occurrences > 1)
            _DetailBlock(label: 'Occurrences', value: '${record.occurrences}'),
          if (detailsText != null)
            _DetailBlock(label: 'Details', value: detailsText, monospace: true),
          if (record.stackTrace != null)
            _DetailBlock(
              label: 'Stack trace',
              value: record.stackTrace!,
              monospace: true,
            ),
        ],
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
    required this.label,
    required this.value,
    this.monospace = false,
  });

  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final style = monospace
        ? Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace')
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          SelectionArea(child: Text(value, style: style)),
        ],
      ),
    );
  }
}

Widget buildAppErrorWidget(FlutterErrorDetails details) {
  final message = extractFrappeErrorMessage(
    details.exception,
    fallback: details.exceptionAsString(),
  );

  return Material(
    color: const Color(0xFFFFF7F7),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: DefaultTextStyle(
        style: const TextStyle(color: Color(0xFF7A1C1C)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.error_outline, color: Color(0xFFB3261E), size: 40),
            const SizedBox(height: 16),
            const Text(
              'A screen failed to render.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(message),
            if (details.context != null) ...<Widget>[
              const SizedBox(height: 10),
              Text(details.context!.toDescription()),
            ],
            const SizedBox(height: 14),
            const Text(
              'Open the diagnostics button to inspect and copy the full error details.',
            ),
          ],
        ),
      ),
    ),
  );
}
