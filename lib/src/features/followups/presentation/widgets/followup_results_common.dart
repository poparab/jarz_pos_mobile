import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/models/followup_models.dart';
import 'followup_card.dart';

/// Content never stretches wider than this, so the page reads the same in a
/// wide web window as on a tablet.
const double kResultsMaxWidth = 900;

/// [base] with tabular figures, so amounts and counts line up in a column.
TextStyle tabularFigures(TextStyle? base) => (base ?? const TextStyle())
    .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

/// Side padding that centres content in a [kResultsMaxWidth] column.
EdgeInsets resultsPadding(double width, {double top = 12, double bottom = 24}) {
  final side = math.max(12.0, (width - kResultsMaxWidth) / 2);
  return EdgeInsets.fromLTRB(side, top, side, bottom);
}

/// A scrolling list for one tab: pull to refresh, centred on wide screens.
class ResultsList extends StatelessWidget {
  const ResultsList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  /// A list of fixed children.
  ResultsList.children({super.key, required List<Widget> children})
    : itemCount = children.length,
      itemBuilder = ((context, i) => children[i]);

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: resultsPadding(c.maxWidth),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

/// Loads [provider], with a spinner, a retry on error and pull-to-refresh.
class ResultsAsync<T> extends ConsumerWidget {
  const ResultsAsync({
    super.key,
    required this.provider,
    required this.builder,
  });

  final AutoDisposeFutureProvider<T> provider;
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ref
        .watch(provider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.userErrorMessage(e),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => ref.invalidate(provider),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            ),
          ),
          data: (data) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(provider);
              await ref.read(provider.future);
            },
            child: builder(context, data),
          ),
        );
  }
}

/// A card with a title and a body, the unit of the Overview tab.
class ResultsSection extends StatelessWidget {
  const ResultsSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// A small rounded label: a status, a code state, a tier.
class ResultsPill extends StatelessWidget {
  const ResultsPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 3, 8, 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A horizontal bar for [fraction] (0–1) of its track.
class ResultsBar extends StatelessWidget {
  const ResultsBar({
    super.key,
    required this.fraction,
    this.color,
    this.height = 10,
  });

  final double fraction;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final f = fraction.isNaN ? 0.0 : fraction.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: scheme.surfaceContainerHighest,
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          widthFactor: f,
          child: Container(color: color ?? scheme.primary),
        ),
      ),
    );
  }
}

/// A centred "nothing here" message that still scrolls (pull to refresh).
class ResultsEmpty extends StatelessWidget {
  const ResultsEmpty({super.key, required this.message, this.compact = false});

  final String message;

  /// Inside a card: a line of text instead of a page-sized gap.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: compact
          ? const EdgeInsets.symmetric(vertical: 4)
          : const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- labels

/// Arabic-first label for a WhatsApp delivery status.
String followupWaStatusLabel(BuildContext context, String status) {
  final l10n = context.l10n;
  return switch (status.toLowerCase()) {
    'delivered' => l10n.followupsSentDelivered,
    'read' => l10n.followupsSentRead,
    'failed' => l10n.followupsSentFailed,
    _ => l10n.followupsSentTotal,
  };
}

Color followupWaStatusColor(ThemeData theme, String status) =>
    switch (status.toLowerCase()) {
      'read' => theme.colorScheme.primary,
      'delivered' => Colors.green.shade700,
      'failed' => theme.colorScheme.error,
      _ => theme.colorScheme.outline,
    };

/// The step of a sent message ("After 3 hours", "Day 32").
String followupResultsStepLabel(BuildContext context, String step) =>
    followupStepLabel(context, FollowupRow(name: '', step: step));

String followupTierLabel(BuildContext context, String tier) {
  final l10n = context.l10n;
  return switch (tier.toLowerCase()) {
    'vip' => l10n.followupResultsTierVip,
    'loyal' => l10n.followupResultsTierLoyal,
    'repeat' => l10n.followupResultsTierRepeat,
    'one_big' => l10n.followupResultsTierOneBig,
    'one' => l10n.followupResultsTierOne,
    _ => tier,
  };
}

String followupCodeStatusLabel(BuildContext context, String status) {
  final l10n = context.l10n;
  return switch (status) {
    'used' => l10n.followupResultsCodeUsed,
    'expired' => l10n.followupResultsCodeExpired,
    'unused' => l10n.followupResultsCodeUnused,
    _ => status,
  };
}

Color followupCodeStatusColor(ThemeData theme, String status) =>
    switch (status) {
      'used' => Colors.green.shade700,
      'expired' => theme.colorScheme.outline,
      _ => theme.colorScheme.primary,
    };

/// What a customer wrote: the text, or a localized "[image]"-style label for
/// anything that is not text (with the caption after it when there is one).
String followupReplyText(BuildContext context, FollowupSentReply reply) {
  final l10n = context.l10n;
  final type = reply.type.toLowerCase();
  if (type == 'text' || type.isEmpty) {
    return reply.hasText ? reply.text.trim() : l10n.followupResultsReplyOther;
  }
  final label = switch (type) {
    'image' => l10n.followupResultsReplyImage,
    'audio' || 'voice' => l10n.followupResultsReplyVoice,
    'video' => l10n.followupResultsReplyVideo,
    'document' => l10n.followupResultsReplyDocument,
    'sticker' => l10n.followupResultsReplySticker,
    'location' => l10n.followupResultsReplyLocation,
    'button' || 'interactive' => l10n.followupResultsReplyButton,
    _ => l10n.followupResultsReplyOther,
  };
  // A button tap carries the button's title; that is the answer itself.
  return reply.hasText ? '$label ${reply.text.trim()}' : label;
}

/// A phone number always reads left to right, even inside Arabic text.
Widget followupPhoneText(
  BuildContext context,
  String phone, {
  TextStyle? style,
}) =>
    Text(phone, textDirection: TextDirection.ltr, style: tabularFigures(style));

/// Money in the report's currency, 2 decimals, tabular.
String followupMoneyText(
  BuildContext context,
  num amount, {
  String? currency,
}) => formatCurrency(context, amount, currencyCode: currency);
