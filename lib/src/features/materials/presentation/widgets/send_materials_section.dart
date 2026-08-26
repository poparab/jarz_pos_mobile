import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/sales_material.dart';
import '../../state/materials_notifier.dart';
import 'send_materials_sheet.dart';

/// "Send the price list", and what happened to the last one.
///
/// Sits on the lead detail page directly under the contacts, because that is
/// the order the visit happens in: meet whoever is on shift, write them down,
/// send them the prices before you have left the pavement.
///
/// The history underneath is the part that does not exist when files are
/// attached to a chat: it says whether the prospect opened it, which is the
/// difference between "follow up because they are interested" and "follow up
/// because it is Tuesday".
class SendMaterialsSection extends ConsumerWidget {
  const SendMaterialsSection({
    super.key,
    required this.referenceName,
    required this.recipients,
    this.referenceDoctype = 'Lead',
  });

  final String referenceName;
  final String referenceDoctype;
  final List<MaterialRecipient> recipients;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final key = materialSharesKey(referenceDoctype, referenceName);
    final shares = ref.watch(materialSharesProvider(key));

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_as_pdf_outlined,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.materialsSectionTitle,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => showSendMaterialsSheet(
                context,
                referenceDoctype: referenceDoctype,
                referenceName: referenceName,
                recipients: recipients,
              ),
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text(l10n.materialsSendCta),
            ),
          ),
          const SizedBox(height: 10),
          shares.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
            // A history we could not load must not look like a history that is
            // empty: one invites a duplicate send, the other is just a gap.
            error: (error, _) => Text(
              l10n.materialsHistoryUnavailable,
              style: theme.textTheme.bodySmall,
            ),
            data: (rows) => rows.isEmpty
                ? Text(l10n.materialsNothingSent,
                    style: theme.textTheme.bodySmall)
                : Column(
                    children: [
                      for (final share in rows.take(3)) _ShareRow(share: share),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.share});

  final MaterialShareSummary share;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final sentAt = share.sentAt;
    final when = sentAt == null
        ? ''
        : DateFormat.yMMMd(Localizations.localeOf(context).toString())
            .format(sentAt.toLocal());

    final bits = <String>[
      if (share.contactName.trim().isNotEmpty) share.contactName.trim(),
      if (when.isNotEmpty) when,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            share.opened ? Icons.mark_email_read_outlined : Icons.schedule,
            size: 16,
            color: share.opened
                ? theme.colorScheme.primary
                : theme.disabledColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bits.isNotEmpty)
                  Text(bits.join(' · '), style: theme.textTheme.bodySmall),
                Text(
                  share.opened
                      ? l10n.materialsOpenedCount(share.viewCount)
                      : l10n.materialsNotOpenedYet,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: share.opened
                        ? theme.colorScheme.primary
                        : theme.disabledColor,
                    fontWeight:
                        share.opened ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (share.titles.isNotEmpty)
                  Text(
                    share.titles.join(' · '),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.disabledColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: l10n.materialsCopyLink,
            icon: const Icon(Icons.link, size: 18),
            onPressed: share.url.trim().isEmpty
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: share.url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.materialsLinkCopied)),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
