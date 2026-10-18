import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/network/user_service.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../leads/presentation/widgets/lead_actions.dart';
import '../../data/models/b2b_active_accounts.dart';
import '../../state/b2b_active_accounts_notifier.dart';

/// Which slice of the list the KPI tiles are filtering to.
enum _ActiveFilter { all, needsAttention, reorderDue }

/// Default B2B landing: only the accounts at the "Active" stage, each with a
/// few ordering numbers. The pipeline Kanban lives one tap away
/// ([AppRoutes.b2bPipeline]).
class B2bActiveAccountsScreen extends ConsumerStatefulWidget {
  const B2bActiveAccountsScreen({super.key});

  @override
  ConsumerState<B2bActiveAccountsScreen> createState() =>
      _B2bActiveAccountsScreenState();
}

class _B2bActiveAccountsScreenState
    extends ConsumerState<B2bActiveAccountsScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  _ActiveFilter _filter = _ActiveFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _refresh() => ref.invalidate(b2bActiveAccountsProvider);

  void _toggleFilter(_ActiveFilter f) =>
      setState(() => _filter = _filter == f ? _ActiveFilter.all : f);

  void _clearFilters() {
    _search.clear();
    setState(() {
      _query = '';
      _filter = _ActiveFilter.all;
    });
  }

  Future<void> _openAccount(B2bActiveAccount a) async {
    await context.push(
      AppRoutes.b2bAccount,
      extra: <String, dynamic>{'doctype': a.doctype, 'name': a.name},
    );
    // A stage change or a new order made in there belongs on this list now.
    if (mounted) _refresh();
  }

  List<B2bActiveAccount> _visible(List<B2bActiveAccount> all) {
    final q = _query.trim().toLowerCase();
    return [
      for (final a in all)
        if (switch (_filter) {
              _ActiveFilter.all => true,
              _ActiveFilter.needsAttention => a.needsAttention,
              _ActiveFilter.reorderDue => a.reorderDue,
            } &&
            (q.isEmpty ||
                a.title.toLowerCase().contains(q) ||
                (a.customerName ?? '').toLowerCase().contains(q) ||
                (a.territory ?? '').toLowerCase().contains(q)))
          a,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(b2bActiveAccountsProvider);
    final rolesAsync = ref.watch(userRolesFutureProvider);
    final roles = rolesAsync.valueOrNull;
    final isManager = roles?.canAccessManagerDashboard ?? false;
    final canSeeReport = roles?.canViewAllReports ?? false;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.b2bActiveTitle),
        actions: [
          IconButton(
            key: const Key('b2b_active_pipeline_action'),
            tooltip: l10n.b2bActivePipelineBoard,
            icon: const Icon(Icons.view_kanban_outlined),
            onPressed: () => context.push(AppRoutes.b2bPipeline),
          ),
          IconButton(
            tooltip: l10n.b2bRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
          PopupMenuButton<String>(
            key: const Key('b2b_active_overflow'),
            onSelected: (value) {
              switch (value) {
                case 'today':
                  context.push(AppRoutes.b2bToday);
                case 'calendar':
                  context.push(AppRoutes.b2bCalendar);
                case 'visits':
                  context.push(AppRoutes.b2bVisits);
                case 'labels':
                  context.push(AppRoutes.labels);
                case 'report':
                  context.push(AppRoutes.reportsB2b);
                case 'pos':
                  context.go(AppRoutes.pos);
                case 'kanban':
                  context.go(AppRoutes.kanban);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'today',
                child: Text(l10n.b2bMyFollowUps),
              ),
              PopupMenuItem(
                value: 'calendar',
                child: Text(l10n.journeyCalendarTitle),
              ),
              PopupMenuItem(
                value: 'visits',
                child: Text(l10n.visitPlannerTitle),
              ),
              PopupMenuItem(
                value: 'labels',
                child: Text(l10n.b2bCustomerLabelsTooltip),
              ),
              if (canSeeReport)
                PopupMenuItem(
                  value: 'report',
                  child: Text(l10n.rptB2bReportTooltip),
                ),
              // Managers can switch back to the B2C POS/Kanban flows.
              if (isManager) ...[
                const PopupMenuDivider(),
                PopupMenuItem(value: 'pos', child: Text(l10n.b2bGoToPos)),
                PopupMenuItem(
                  value: 'kanban',
                  child: Text(l10n.b2bGoToKanban),
                ),
              ],
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.leadForm),
        icon: const Icon(Icons.add),
        label: Text(l10n.b2bNewLead),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(error: error, onRetry: _refresh),
        data: _buildData,
      ),
    );
  }

  Widget _buildData(B2bActiveAccounts data) {
    final visible = _visible(data.accounts);
    final noAccounts = data.accounts.isEmpty;

    return RefreshIndicator(
      onRefresh: () async {
        _refresh();
        try {
          await ref.read(b2bActiveAccountsProvider.future);
        } catch (_) {
          // The error state renders itself; the spinner just has to stop.
        }
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (noAccounts)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyView(
                onOpenPipeline: () => context.push(AppRoutes.b2bPipeline),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 0),
                child: _SummaryHeader(
                  data: data,
                  filter: _filter,
                  onToggle: _toggleFilter,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.tonalIcon(
                      key: const Key('b2b_active_pipeline_button'),
                      onPressed: () => context.push(AppRoutes.b2bPipeline),
                      icon: const Icon(Icons.view_kanban_outlined),
                      label: Text(context.l10n.b2bActivePipelineBoard),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('b2b_active_search'),
                      controller: _search,
                      textInputAction: TextInputAction.search,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: context.l10n.b2bActiveSearchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _search.clear();
                                  setState(() => _query = '');
                                },
                              ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (visible.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _NoMatchesView(onClear: _clearFilters),
              )
            else
              SliverPadding(
                // Room for the FAB so the last card's actions stay tappable.
                padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 88),
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _AccountCard(
                    account: visible[i],
                    periodDays: data.periodDays,
                    onTap: () => _openAccount(visible[i]),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ── Summary ────────────────────────────────────────────────────────────────

class _SummaryHeader extends StatelessWidget {
  final B2bActiveAccounts data;
  final _ActiveFilter filter;
  final void Function(_ActiveFilter) onToggle;

  const _SummaryHeader({
    required this.data,
    required this.filter,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = data.summary;
    final days = data.periodDays;

    final tiles = <Widget>[
      _KpiTile(
        key: const Key('b2b_active_kpi_accounts'),
        icon: Icons.groups_outlined,
        label: l10n.b2bActiveKpiAccounts,
        value: formatCount(context, s.accounts),
      ),
      _KpiTile(
        key: const Key('b2b_active_kpi_billed'),
        icon: Icons.payments_outlined,
        label: l10n.b2bActiveKpiBilled(days),
        value: formatCompactCurrency(context, s.periodBilled),
        delta: s.periodChangePct,
        deltaCaption: l10n.b2bActiveVsPrevious(days),
      ),
      _KpiTile(
        key: const Key('b2b_active_kpi_orders'),
        icon: Icons.receipt_long_outlined,
        label: l10n.b2bActiveKpiOrders(days),
        value: formatCount(context, s.periodOrders),
      ),
      _KpiTile(
        key: const Key('b2b_active_kpi_outstanding'),
        icon: Icons.account_balance_wallet_outlined,
        label: l10n.b2bActiveKpiOutstanding,
        value: formatCompactCurrency(context, s.outstanding),
        valueColor: s.outstanding > 0 ? _kRed : null,
      ),
      _KpiTile(
        key: const Key('b2b_active_kpi_reorder'),
        icon: Icons.event_repeat,
        label: l10n.b2bActiveKpiReorderDue,
        value: formatCount(context, s.reorderDue),
        valueColor: s.reorderDue > 0 ? _kAmber : null,
        selected: filter == _ActiveFilter.reorderDue,
        onTap: () => onToggle(_ActiveFilter.reorderDue),
      ),
      _KpiTile(
        key: const Key('b2b_active_kpi_attention'),
        icon: Icons.notification_important_outlined,
        label: l10n.b2bActiveKpiNeedsAttention,
        value: formatCount(context, s.needsAttention),
        valueColor: s.needsAttention > 0 ? _kRed : null,
        selected: filter == _ActiveFilter.needsAttention,
        onTap: () => onToggle(_ActiveFilter.needsAttention),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final columns = constraints.maxWidth >= 720 ? 3 : 2;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final t in tiles) SizedBox(width: width, child: t)],
        );
      },
    );
  }
}

const Color _kRed = Color(0xFFC62828);
const Color _kGreen = Color(0xFF2E7D32);
const Color _kAmber = Color(0xFFB26A00);

class _KpiTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final double? delta;
  final String? deltaCaption;
  final bool selected;
  final VoidCallback? onTap;

  const _KpiTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.delta,
    this.deltaCaption,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: selected
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? scheme.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
              ),
              if (delta != null) ...[
                const SizedBox(height: 2),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    _DeltaBadge(pct: delta!),
                    if (deltaCaption != null)
                      Text(
                        deltaCaption!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ▲ 12% (green) / ▼ 8% (red) / unchanged (grey).
class _DeltaBadge extends StatelessWidget {
  final double pct;
  const _DeltaBadge({required this.pct});

  @override
  Widget build(BuildContext context) {
    final up = pct > 0;
    final down = pct < 0;
    final color = up ? _kGreen : (down ? _kRed : Colors.grey.shade600);
    final text = NumberFormat(
      '#,##0',
      context.l10n.localeName,
    ).format(pct.abs().round());
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          up
              ? Icons.arrow_drop_up
              : (down ? Icons.arrow_drop_down : Icons.remove),
          size: 20,
          color: color,
        ),
        Text(
          '$text%',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

// ── Account card ───────────────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  final B2bActiveAccount account;
  final int periodDays;
  final VoidCallback onTap;

  const _AccountCard({
    required this.account,
    required this.periodDays,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = account;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    final placeParts = <String>[
      if (a.territory != null) a.territory!,
      if (a.customerName != null && a.customerName != a.title) a.customerName!,
    ];

    final chips = <Widget>[
      ..._reorderChip(context, a),
      if (a.hasAlert(B2bActiveAlert.oldUnpaid))
        _StatusChip(
          icon: Icons.warning_amber_rounded,
          label: l10n.b2bActiveAlertOldUnpaid,
          color: _kRed,
        ),
      if (a.hasAlert(B2bActiveAlert.labels))
        _StatusChip(
          icon: Icons.label_important_outline,
          label: l10n.b2bActiveAlertLabels,
          color: _kAmber,
        ),
      if (a.hasAlert(B2bActiveAlert.noCustomer))
        _StatusChip(
          icon: Icons.link_off,
          label: l10n.b2bActiveAlertNoCustomer,
          color: Colors.blueGrey,
        ),
    ];

    final String lastOrderLine;
    if (a.lastOrderDate == null) {
      lastOrderLine = l10n.b2bActiveNoOrders;
    } else {
      final date = formatDateString(context, a.lastOrderDate);
      lastOrderLine = a.daysSinceLastOrder == null
          ? date
          : l10n.b2bActiveLastOrder(
              date,
              l10n.b2bActiveDaysAgo(a.daysSinceLastOrder!),
            );
    }

    final String? followUpLine;
    if (a.nextAction != null) {
      followUpLine = a.nextActionDate != null
          ? l10n.b2bActiveNextActionOn(
              a.nextAction!,
              formatDateString(context, a.nextActionDate, pattern: 'MMM d'),
            )
          : l10n.b2bActiveNextAction(a.nextAction!);
    } else if (a.lastJourneyNote != null) {
      followUpLine = l10n.b2bActiveLastNote(a.lastJourneyNote!);
    } else {
      followUpLine = null;
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 4, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (placeParts.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    size: 14,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      placeParts.join(' · '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (a.mobileNo != null)
                    IconButton.filledTonal(
                      key: Key('b2b_active_call_${a.name}'),
                      tooltip: l10n.b2bActiveCall,
                      icon: const Icon(Icons.call, size: 20),
                      onPressed: () => LeadActions.call(a.mobileNo!),
                    ),
                ],
              ),
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Wrap(spacing: 6, runSpacing: 6, children: chips),
                ),
              ],
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Text(lastOrderLine, style: muted),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _Figure(
                      label: l10n.b2bActiveFigPeriod(periodDays),
                      value: formatCurrency(context, a.periodBilled),
                      sub: l10n.b2bActiveFigOrders(a.periodOrders),
                      trailing: a.periodChangePct == null
                          ? null
                          : _DeltaBadge(pct: a.periodChangePct!),
                    ),
                    _Figure(
                      label: l10n.b2bActiveFigLifetime,
                      value: formatCurrency(context, a.billed),
                      sub: l10n.b2bActiveFigOrders(a.orders),
                    ),
                    _Figure(
                      label: l10n.b2bActiveFigAvgOrder,
                      value: formatCurrency(context, a.avgOrderValue),
                    ),
                    _Figure(
                      label: l10n.b2bActiveFigOutstanding,
                      value: formatCurrency(context, a.outstanding),
                      valueColor: a.outstanding > 0 ? _kRed : null,
                      sub: a.outstanding > 0 && a.oldestUnpaidDays != null
                          ? l10n.b2bActiveOldestUnpaid(a.oldestUnpaidDays!)
                          : null,
                      subColor: _kRed,
                    ),
                  ],
                ),
              ),
              if (followUpLine != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Row(
                    children: [
                      Icon(
                        a.nextAction != null
                            ? Icons.flag_outlined
                            : Icons.sticky_note_2_outlined,
                        size: 16,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          followUpLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _reorderChip(BuildContext context, B2bActiveAccount a) {
    final l10n = context.l10n;
    switch (a.reorderStatus) {
      case B2bReorderStatus.overdue:
        return [
          _StatusChip(
            icon: Icons.event_busy,
            label: l10n.b2bActiveReorderOverdue,
            color: _kRed,
          ),
        ];
      case B2bReorderStatus.dueSoon:
        return [
          _StatusChip(
            icon: Icons.schedule,
            label: l10n.b2bActiveReorderDueSoon,
            color: _kAmber,
          ),
        ];
      case B2bReorderStatus.ok:
        if (a.predictedNextOrder == null) return const [];
        return [
          _StatusChip(
            icon: Icons.event_available,
            label: l10n.b2bActiveReorderOk(
              formatDateString(
                context,
                a.predictedNextOrder,
                pattern: 'MMM d',
              ),
            ),
            color: _kGreen,
          ),
        ];
    }
    return const [];
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
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

/// A small labelled figure: caption, bold value, optional sub-line.
class _Figure extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final Color? valueColor;
  final Color? subColor;
  final Widget? trailing;

  const _Figure({
    required this.label,
    required this.value,
    this.sub,
    this.valueColor,
    this.subColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: muted),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 2), trailing!],
          ],
        ),
        if (sub != null)
          Text(
            sub!,
            style: theme.textTheme.labelSmall?.copyWith(color: subColor ?? muted),
          ),
      ],
    );
  }
}

// ── States ─────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final VoidCallback onOpenPipeline;
  const _EmptyView({required this.onOpenPipeline});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.b2bActiveEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.b2bActiveEmptyBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('b2b_active_empty_pipeline_button'),
              onPressed: onOpenPipeline,
              icon: const Icon(Icons.view_kanban_outlined),
              label: Text(l10n.b2bActivePipelineBoard),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMatchesView extends StatelessWidget {
  final VoidCallback onClear;
  const _NoMatchesView({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.b2bActiveNoMatches, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onClear,
              child: Text(l10n.b2bActiveClearFilters),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              context.userErrorMessage(error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
