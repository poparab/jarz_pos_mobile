import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/followup_results.dart';
import '../../data/models/followup_models.dart';
import '../../state/followups_providers.dart';
import 'followup_message_sheet.dart';
import 'followup_results_common.dart';

const String _timePattern = 'MMM d • h:mm a';

/// Opens the sheet for [item]; "show all messages to this customer" filters the
/// Messages tab and jumps to it.
void _openMessage(
  BuildContext context,
  WidgetRef ref,
  FollowupSentItem item,
  String currency,
) {
  final tabs = DefaultTabController.maybeOf(context);
  showFollowupMessageSheet(
    context,
    item: item,
    currency: currency,
    onShowCustomer: (name) {
      ref.read(followupMessageFilterProvider.notifier).state =
          item.customer.isEmpty
              ? FollowupMessageFilter(query: name)
              : FollowupMessageFilter(
                  customer: item.customer,
                  customerName: name,
                );
      tabs?.animateTo(kFollowupMessagesTabIndex);
    },
  );
}

/// Index of the Messages tab in the results TabBar.
const int kFollowupMessagesTabIndex = 1;

// ------------------------------------------------------------- Messages

/// Messages tab: search, filter chips and one compact card per message.
class FollowupResultsMessages extends StatelessWidget {
  const FollowupResultsMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return ResultsAsync<FollowupSentReport>(
      provider: followupSentReportProvider,
      builder: (context, report) => _MessagesList(report: report),
    );
  }
}

class _MessagesList extends ConsumerStatefulWidget {
  const _MessagesList({required this.report});

  final FollowupSentReport report;

  @override
  ConsumerState<_MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends ConsumerState<_MessagesList> {
  late final TextEditingController _search = TextEditingController(
    text: ref.read(followupMessageFilterProvider).query,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _update(FollowupMessageFilter Function(FollowupMessageFilter) f) {
    final notifier = ref.read(followupMessageFilterProvider.notifier);
    notifier.state = f(notifier.state);
  }

  @override
  Widget build(BuildContext context) {
    // "Show all messages to this customer" sets the query from outside.
    ref.listen<FollowupMessageFilter>(followupMessageFilterProvider, (_, next) {
      if (_search.text != next.query) {
        _search.value = TextEditingValue(
          text: next.query,
          selection: TextSelection.collapsed(offset: next.query.length),
        );
      }
    });
    final filter = ref.watch(followupMessageFilterProvider);
    final report = widget.report;
    final shown = filterSentItems(report.items, filter);
    final currency = report.money?.currency ?? 'EGP';
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final header = _FilterHeader(
      report: report,
      filter: filter,
      controller: _search,
      onChanged: (f) => _update((_) => f),
    );
    final countLine = Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.followupResultsCountLine(
              formatCount(context, shown.length),
              formatCount(context, report.messageCount),
            ),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (report.itemsTruncated)
            Text(
              l10n.followupResultsTruncated(
                formatCount(context, report.items.length),
                formatCount(context, report.itemsTotal),
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );

    return ResultsList(
      itemCount: 2 + (shown.isEmpty ? 1 : shown.length),
      itemBuilder: (context, i) {
        if (i == 0) return header;
        if (i == 1) return countLine;
        if (shown.isEmpty) {
          return ResultsEmpty(message: l10n.followupResultsMessagesEmpty);
        }
        final item = shown[i - 2];
        return _MessageCard(
          item: item,
          currency: currency,
          onTap: () => _openMessage(context, ref, item, currency),
        );
      },
    );
  }
}

class _FilterHeader extends StatelessWidget {
  const _FilterHeader({
    required this.report,
    required this.filter,
    required this.controller,
    required this.onChanged,
  });

  final FollowupSentReport report;
  final FollowupMessageFilter filter;
  final TextEditingController controller;
  final ValueChanged<FollowupMessageFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final steps = sentItemSteps(report.items);

    Widget group(String label, List<Widget> chips) => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(spacing: 8, runSpacing: 4, children: chips),
        ],
      ),
    );

    Widget chip<T>(
      String label,
      Set<T> selected,
      T value,
      FollowupMessageFilter Function(Set<T>) apply,
    ) => FilterChip(
      label: Text(label),
      selected: selected.contains(value),
      visualDensity: VisualDensity.compact,
      onSelected: (_) =>
          onChanged(apply(FollowupMessageFilter.toggle(selected, value))),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filter.customer.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InputChip(
              avatar: const Icon(Icons.person_outline, size: 18),
              label: Text(
                filter.customerName.isEmpty
                    ? filter.customer
                    : filter.customerName,
              ),
              onDeleted: () => onChanged(
                filter.copyWith(customer: '', customerName: ''),
              ),
            ),
          ),
        TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.followupResultsSearchHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: filter.query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => onChanged(filter.copyWith(query: '')),
                  ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            isDense: true,
          ),
          onChanged: (v) => onChanged(filter.copyWith(query: v)),
        ),
        if (steps.length > 1)
          group(l10n.followupResultsFilterStep, [
            for (final s in steps)
              chip<String>(
                followupResultsStepLabel(context, s),
                filter.steps,
                s,
                (set) => filter.copyWith(steps: set),
              ),
          ]),
        group(l10n.followupResultsFilterStatus, [
          for (final s in const ['delivered', 'read', 'failed'])
            chip<String>(
              followupWaStatusLabel(context, s),
              filter.statuses,
              s,
              (set) => filter.copyWith(statuses: set),
            ),
        ]),
        group(l10n.followupResultsFilterOutcome, [
          for (final o in FollowupMessageOutcome.values)
            chip<FollowupMessageOutcome>(
              switch (o) {
                FollowupMessageOutcome.replied => l10n.followupResultsReplied,
                FollowupMessageOutcome.ordered => l10n.followupResultsOrdered,
                FollowupMessageOutcome.usedCode =>
                  l10n.followupResultsOutcomeUsedCode,
                FollowupMessageOutcome.noResponse =>
                  l10n.followupResultsOutcomeNoResponse,
              },
              filter.outcomes,
              o,
              (set) => filter.copyWith(outcomes: set),
            ),
        ]),
        if (filter.isActive)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => onChanged(const FollowupMessageFilter()),
              icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
              label: Text(l10n.followupResultsClearFilters),
            ),
          ),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.item,
    required this.currency,
    required this.onTap,
  });

  final FollowupSentItem item;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final lastReply = item.replies.isEmpty ? null : item.replies.last;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.customerName.isEmpty
                              ? item.customer
                              : item.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (item.phone.isNotEmpty)
                          followupPhoneText(context, item.phone, style: muted),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ResultsPill(
                    label: followupWaStatusLabel(context, item.waStatus),
                    color: followupWaStatusColor(theme, item.waStatus),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                [
                  followupResultsStepLabel(context, item.step),
                  formatDateString(context, item.sentAt, pattern: _timePattern),
                ].join(' · '),
                style: muted,
              ),
              if (item.hasCode || item.codeStatus.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (item.hasCode)
                        ResultsPill(
                          label: item.tier.isEmpty
                              ? item.offerCode
                              : '${item.offerCode} · '
                                    '${followupTierLabel(context, item.tier)}',
                          color: scheme.secondary,
                          icon: Icons.confirmation_number_outlined,
                        ),
                      if (item.codeStatus.isNotEmpty)
                        ResultsPill(
                          label: followupCodeStatusLabel(
                            context,
                            item.codeStatus,
                          ),
                          color: followupCodeStatusColor(
                            theme,
                            item.codeStatus,
                          ),
                          icon: item.codeUsed
                              ? Icons.check_circle_outline
                              : null,
                        ),
                    ],
                  ),
                ),
              if (item.error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    item.error,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ),
              if (item.replied)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        lastReply?.isStop == true
                            ? Icons.block
                            : Icons.chat_bubble_outline,
                        size: 16,
                        color: lastReply?.isStop == true
                            ? scheme.error
                            : scheme.tertiary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          lastReply == null
                              ? context.l10n.followupResultsReplied
                              : followupReplyText(context, lastReply),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: lastReply?.isStop == true
                                ? scheme.error
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (item.orders.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final o in item.orders)
                        ResultsPill(
                          label:
                              '${o.displayId} · '
                              '${followupMoneyText(context, o.grandTotal, currency: currency)}',
                          color: Colors.green.shade700,
                          icon: o.usedCode
                              ? Icons.check_circle_outline
                              : Icons.receipt_long_outlined,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- Replies

/// Replies tab: only messages the customer answered, newest answer first.
class FollowupResultsReplies extends StatelessWidget {
  const FollowupResultsReplies({super.key});

  @override
  Widget build(BuildContext context) {
    return ResultsAsync<FollowupSentReport>(
      provider: followupSentReportProvider,
      builder: (context, report) => _RepliesList(report: report),
    );
  }
}

class _RepliesList extends ConsumerWidget {
  const _RepliesList({required this.report});

  final FollowupSentReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final items = repliedItems(report.items);
    final currency = report.money?.currency ?? 'EGP';
    if (items.isEmpty) {
      return ResultsList.children(
        children: [ResultsEmpty(message: l10n.followupResultsRepliesEmpty)],
      );
    }
    return ResultsList(
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openMessage(context, ref, item, currency),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.customerName.isEmpty
                              ? item.customer
                              : item.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (item.replyCount > 1)
                        ResultsPill(
                          label: l10n.followupResultsRepliesCount(
                            formatCount(context, item.replyCount),
                          ),
                          color: theme.colorScheme.tertiary,
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 6),
                    child: Text(
                      [
                        if (item.phone.isNotEmpty) item.phone,
                        followupResultsStepLabel(context, item.step),
                        formatDateString(
                          context,
                          item.sentAt,
                          pattern: _timePattern,
                        ),
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (item.replies.isEmpty)
                    Text(l10n.followupResultsReplied)
                  else
                    for (final r in item.replies) FollowupReplyBubble(reply: r),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// --------------------------------------------------------------- Orders

/// Orders tab: every distinct order that followed a message.
class FollowupResultsOrders extends StatelessWidget {
  const FollowupResultsOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return ResultsAsync<FollowupSentReport>(
      provider: followupSentReportProvider,
      builder: (context, report) => _OrdersList(report: report),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  const _OrdersList({required this.report});

  final FollowupSentReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final rows = distinctOrders(report.items);
    final currency = report.money?.currency ?? 'EGP';
    if (rows.isEmpty) {
      return ResultsList.children(
        children: [ResultsEmpty(message: l10n.followupResultsOrdersEmpty)],
      );
    }
    return ResultsList(
      itemCount: rows.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      // The server totals every order; the list below shows at
                      // most 5 per message, so prefer its figures to match
                      // Overview.
                      l10n.followupResultsOrdersSummary(
                        formatCount(context, report.money?.orders ?? rows.length),
                        followupMoneyText(
                          context,
                          report.money?.revenue ?? ordersTotal(rows),
                          currency: currency,
                        ),
                      ),
                      style: tabularFigures(
                        theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final row = rows[i - 1];
        final item = row.item;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openMessage(context, ref, item, currency),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FollowupOrderLine(order: row.order, currency: currency),
                  const SizedBox(height: 6),
                  Text(
                    [
                      item.customerName.isEmpty
                          ? item.customer
                          : item.customerName,
                      l10n.followupResultsOrderAfterStep(
                        followupResultsStepLabel(context, item.step),
                      ),
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
