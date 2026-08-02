import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/sop.dart';
import '../../state/sop_providers.dart';

/// One SOP step, filling a page.
///
/// Deliberately dumb: it takes the step, what has been recorded against it and
/// two callbacks, so it can be pumped in a test without a network or a router.
/// The capture control is passed in as a slot rather than built here.
class SopStepCard extends StatelessWidget {
  const SopStepCard({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.progress,
    required this.onConfirmedChanged,
    this.captureField,
  });

  final SopStep step;
  final int stepIndex;
  final SopStepProgress progress;
  final ValueChanged<bool> onConfirmedChanged;

  /// The Number / Temperature / Photo control for this step, when it has one.
  final Widget? captureField;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final imageUrl = (step.imageUrl ?? '').trim();
    final satisfied = step.isSatisfied(
      confirmed: progress.confirmed,
      captured: progress.hasCapture,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    satisfied ? scheme.primary : scheme.surfaceContainerHighest,
                child: Text(
                  '${step.stepNo > 0 ? step.stepNo : stepIndex + 1}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color:
                        satisfied ? scheme.onPrimary : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.title,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (step.durationMins > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  l10n.sopDurationMins(formatSopNumber(step.durationMins)),
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
          if (imageUrl.isNotEmpty) ...[
            const SizedBox(height: 14),
            SopAttachmentImage(url: imageUrl, height: 220),
          ],
          if (step.instructionText.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            // Plain text: the server already substituted the quantity tokens
            // and stripped the HTML, so no markup package is needed.
            Text(
              step.instructionText,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                height: 1.5,
              ),
            ),
          ],
          if (captureField != null) ...[
            const SizedBox(height: 20),
            captureField!,
          ],
          if (step.needsCapture && !progress.hasCapture) ...[
            const SizedBox(height: 8),
            Text(
              l10n.sopCaptureRequired,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ],
          if (step.requiresConfirmation) ...[
            const SizedBox(height: 20),
            CheckboxListTile(
              value: progress.confirmed,
              onChanged: (next) => onConfirmedChanged(next ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.sopConfirmStep,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A Frappe `Attach Image` URL with a visible failure state.
///
/// SOP images are site-relative and permission-gated: an operator with
/// `desk_access = 0` can get a 403, and the default behaviour is an empty box
/// that looks exactly like "this step has no picture". The placeholder makes
/// the failure obvious instead.
class SopAttachmentImage extends StatelessWidget {
  const SopAttachmentImage({
    super.key,
    required this.url,
    this.height = 200,
    this.width,
  });

  final String url;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final absolute = absoluteSopUrl(url);
    if (absolute.isEmpty) return _placeholder(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        absolute,
        height: height,
        width: width ?? double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, _, _) => _placeholder(context),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            height: height,
            width: width ?? double.infinity,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: scheme.surfaceContainerHighest,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icons here are limited to glyphs the app already ships: a new
              // one changes the tree-shaken MaterialIcons font, which turns an
              // otherwise Dart-only change into a full APK release.
              Icon(
                Icons.error_outline,
                size: 36,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              // Says WHY rather than showing a bare broken-image box. An
              // operator with desk_access = 0 gets a 403 on these attachments,
              // and silently rendering an empty frame reads as "no picture"
              // rather than "you cannot see this picture".
              Text(
                context.l10n.sopImageUnavailable,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Turns a site-relative `/files/...` attachment path into something loadable.
///
/// Returns an empty string when the base URL is unknown (tests, or a build
/// without a `.env`), which the caller renders as the failure placeholder.
String absoluteSopUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }

  String base = '';
  if (dotenv.isInitialized) {
    base = dotenv.get('ERP_BASE_URL', fallback: '').trim();
  }
  if (base.isEmpty) return '';

  final normalisedBase = base.endsWith('/')
      ? base.substring(0, base.length - 1)
      : base;
  final normalisedPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$normalisedBase$normalisedPath';
}

/// Drops a trailing `.0` — "12 min", not "12.0 min"; "3 batches", not "3.0".
String formatSopNumber(double value) {
  if (value.isNaN || value.isInfinite) return '0';
  final rounded = value.round();
  if ((value - rounded).abs() < 0.05) return '$rounded';
  return value.toStringAsFixed(1);
}
