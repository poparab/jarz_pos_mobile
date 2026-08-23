import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../journey/presentation/widgets/journey_notes_section.dart';
import '../../../labels/models/label_models.dart' show LabelStatus;
import '../../../labels/presentation/widgets/label_status_chip.dart';
import '../../../leads/data/leads_repository.dart';
import '../../../leads/data/models/lead.dart';
import '../../../leads/presentation/leads_theme.dart';
import '../../../leads/presentation/widgets/category_chip.dart';
import '../../../leads/presentation/widgets/lead_actions.dart';
import '../../../leads/presentation/widgets/sahel_badge.dart';
import '../../../leads/presentation/widgets/score_bar.dart';
import '../../../leads/presentation/widgets/tier_pill.dart';
import '../../../pos/presentation/widgets/customer_search_widget.dart'
    show territoriesProvider;
import '../../../pricing/presentation/screens/customer_pricing_screen.dart';
import '../../data/b2b_repository.dart';
import '../../data/models/b2b_account_labels.dart';
import '../../data/models/b2b_models.dart';
import '../b2b_order_launch.dart';
import '../widgets/b2b_stage_chip.dart';
import '../../../../core/utils/territory_label.dart';

/// B2B account detail: contact, stage, lead score, predicted next order, recent
/// invoices and open todos, plus quick actions (send sample, place order, log
/// call, mark lost).
class B2bAccountScreen extends ConsumerStatefulWidget {
  final String doctype;
  final String name;

  const B2bAccountScreen({
    super.key,
    required this.doctype,
    required this.name,
  });

  @override
  ConsumerState<B2bAccountScreen> createState() => _B2bAccountScreenState();
}

class _B2bAccountScreenState extends ConsumerState<B2bAccountScreen> {
  late Future<B2bAccountDetail> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<B2bAccountDetail> _load() {
    return ref
        .read(b2bRepositoryProvider)
        .getAccount(doctype: widget.doctype, name: widget.name);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.b2bAccountTitle)),
      body: FutureBuilder<B2bAccountDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        context.l10n
                            .b2bAccountLoadFailed('${snapshot.error}'),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                        onPressed: _reload,
                        child: Text(context.l10n.commonRetry)),
                  ],
                ),
              ),
            );
          }
          final detail = snapshot.requireData;
          final account = detail.account;
          final customer = account.customer;
          return _AccountBody(
            account: account,
            labels: detail.labels,
            busy: _busy,
            onSendSample: () => _bindAndOrder(account, isSample: true),
            onPlaceOrder: () => _bindAndOrder(account, isSample: false),
            onLogCall: () => _logCall(account),
            onMarkLost: () => _markLost(account),
            onJourneyChanged: _reload,
            // Only a Lead has a catalog page to open; an Opportunity does not.
            onOpenLead: _isLead ? _openLeadPage : null,
            onOpenLabel: _openLabelDetail,
            // Setting up labels needs a real Customer behind the account.
            onSetupLabels: (customer != null && customer.isNotEmpty)
                ? () => _openLabelSetup(customer, account.title)
                : null,
            onViewPricing: (customer != null && customer.isNotEmpty)
                ? () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            CustomerPricingScreen(customer: customer),
                      ),
                    )
                : null,
          );
        },
      ),
    );
  }

  /// Opens one flavour's label detail, then revalidates: a batch ordered or
  /// received there changes the status chips shown here.
  Future<void> _openLabelDetail(String label) async {
    await context.push(AppRoutes.labelDetail, extra: label);
    if (mounted) _reload();
  }

  /// Launches the label setup wizard with this account's customer preselected.
  Future<void> _openLabelSetup(String customer, String customerName) async {
    await context.push(
      AppRoutes.labelSetup,
      extra: <String, dynamic>{
        'customer': customer,
        'customer_name': customerName,
      },
    );
    if (mounted) _reload();
  }

  bool get _isLead => widget.doctype == 'Lead';

  /// Opens the full lead catalog page for this card — the rich profile, the
  /// branches, the addresses and the merge tools the account view only
  /// summarises. Revalidates on the way back so an edit made there (stage,
  /// suitability, a journey note) is reflected here immediately.
  Future<void> _openLeadPage() async {
    await context.push('/leads/${Uri.encodeComponent(widget.name)}');
    if (mounted) _reload();
  }

  Future<void> _bindAndOrder(
    B2bAccount account, {
    required bool isSample,
  }) async {
    // A Lead with no linked Customer must supply create-customer fields.
    _LeadCustomerFields? leadFields;
    if (_isLead && (account.customer == null || account.customer!.isEmpty)) {
      leadFields = await _promptLeadCustomerFields(account);
      if (leadFields == null) return; // cancelled
    }

    setState(() => _busy = true);
    final repo = ref.read(b2bRepositoryProvider);
    try {
      final binding = isSample
          ? await repo.requestSample(
              partyDoctype: widget.doctype,
              partyName: widget.name,
              customerName: leadFields?.customerName,
              mobileNo: leadFields?.mobileNo,
              customerPrimaryAddress: leadFields?.address,
              territoryId: leadFields?.territoryId,
            )
          : await repo.placeB2bOrder(
              partyDoctype: widget.doctype,
              partyName: widget.name,
              customerName: leadFields?.customerName,
              mobileNo: leadFields?.mobileNo,
              customerPrimaryAddress: leadFields?.address,
              territoryId: leadFields?.territoryId,
            );
      if (!mounted) return;
      launchB2bOrderInPos(
        context,
        binding: binding,
        customerName: leadFields?.customerName ?? account.title,
        mobileNo: leadFields?.mobileNo ?? account.contact.mobileNo,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.b2bFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logCall(B2bAccount account) async {
    final l10n = context.l10n;
    final note = await _promptText(
      title: l10n.b2bLogCall,
      hint: l10n.b2bLogCallHint,
    );
    if (note == null || note.isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(b2bRepositoryProvider).logActivity(
            doctype: widget.doctype,
            name: widget.name,
            note: note,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.b2bActivityLogged)),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.b2bLogActivityFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _markLost(B2bAccount account) async {
    final l10n = context.l10n;
    final reason = await _promptText(
      title: l10n.b2bMarkLostTitle,
      hint: l10n.b2bReasonHint,
    );
    if (reason == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(b2bRepositoryProvider).advanceStage(
            doctype: widget.doctype,
            name: widget.name,
            stage: 'Lost/On-hold',
            reason: reason,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.b2bMarkedLost)),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.b2bFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _promptText({
    required String title,
    required String hint,
  }) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(context.l10n.commonSave),
          ),
        ],
      ),
    );
  }

  Future<_LeadCustomerFields?> _promptLeadCustomerFields(
    B2bAccount account,
  ) {
    return showDialog<_LeadCustomerFields>(
      context: context,
      builder: (ctx) => _LeadCustomerDialog(account: account),
    );
  }
}

/// Create-customer dialog for a Lead with no linked Customer. Territory is a
/// dropdown sourced from [territoriesProvider]; all fields are required.
class _LeadCustomerDialog extends ConsumerStatefulWidget {
  final B2bAccount account;
  const _LeadCustomerDialog({required this.account});

  @override
  ConsumerState<_LeadCustomerDialog> createState() =>
      _LeadCustomerDialogState();
}

class _LeadCustomerDialogState extends ConsumerState<_LeadCustomerDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _mobileCtrl;
  final _addressCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _territory;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.account.title);
    _mobileCtrl =
        TextEditingController(text: widget.account.contact.mobileNo ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.b2bCreateCustomerTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration:
                    InputDecoration(labelText: l10n.b2bCustomerName),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.leadFormRequired
                    : null,
              ),
              TextFormField(
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
                decoration:
                    InputDecoration(labelText: l10n.leadFieldMobile),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.leadFormRequired
                    : null,
              ),
              TextFormField(
                controller: _addressCtrl,
                decoration: InputDecoration(labelText: l10n.b2bAddress),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.leadFormRequired
                    : null,
              ),
              _buildTerritoryField(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(
              context,
              _LeadCustomerFields(
                customerName: _nameCtrl.text.trim(),
                mobileNo: _mobileCtrl.text.trim(),
                address: _addressCtrl.text.trim(),
                territoryId: _territory!.trim(),
              ),
            );
          },
          child: Text(l10n.b2bContinue),
        ),
      ],
    );
  }

  Widget _buildTerritoryField() {
    final l10n = context.l10n;
    final territoriesAsync = ref.watch(territoriesProvider(null));
    return territoriesAsync.when(
      data: (territories) => DropdownButtonFormField<String>(
        initialValue: _territory,
        isExpanded: true,
        menuMaxHeight: 320,
        decoration:
            InputDecoration(labelText: l10n.leadFieldTerritory),
        items: territories.map<DropdownMenuItem<String>>((territory) {
          final name = territory['name']?.toString() ?? '';
          final label = territoryLabelOf(territory);
          return DropdownMenuItem<String>(
            value: name,
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (value) => setState(() => _territory = value),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? l10n.leadFormRequired : null,
      ),
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(l10n.b2bLoadingTerritories),
          ],
        ),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          l10n.b2bTerritoriesFailed,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}

class _LeadCustomerFields {
  final String customerName;
  final String mobileNo;
  final String address;
  final String territoryId;
  const _LeadCustomerFields({
    required this.customerName,
    required this.mobileNo,
    required this.address,
    required this.territoryId,
  });
}

class _AccountBody extends StatelessWidget {
  final B2bAccount account;
  final B2bAccountLabels? labels;
  final bool busy;
  final VoidCallback onSendSample;
  final VoidCallback onPlaceOrder;
  final VoidCallback onLogCall;
  final VoidCallback onMarkLost;
  final VoidCallback onJourneyChanged;
  final VoidCallback? onOpenLead;
  final void Function(String label)? onOpenLabel;
  final VoidCallback? onSetupLabels;
  final VoidCallback? onViewPricing;

  const _AccountBody({
    required this.account,
    required this.labels,
    required this.busy,
    required this.onSendSample,
    required this.onPlaceOrder,
    required this.onLogCall,
    required this.onMarkLost,
    required this.onJourneyChanged,
    this.onOpenLead,
    this.onOpenLabel,
    this.onSetupLabels,
    this.onViewPricing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Reserve room for the pinned action bar plus the bottom system inset so
    // the last list content is never hidden behind the bar.
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final trailingSpacer = 80.0 + bottomInset;
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    account.title,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                B2bStageChip(stage: account.stage),
              ],
            ),
            if (onOpenLead != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: busy ? null : onOpenLead,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(context.l10n.b2bOpenLeadPage),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _section(context, context.l10n.b2bSectionContact, [
              if (account.contact.mobileNo != null)
                _kv(context, context.l10n.leadFieldMobile,
                    account.contact.mobileNo!),
              if (account.contact.phone != null)
                _kv(context, context.l10n.leadFieldPhone,
                    account.contact.phone!),
              if (account.contact.emailId != null)
                _kv(context, context.l10n.leadFieldEmail,
                    account.contact.emailId!),
              if (account.customer != null)
                _kv(context, context.l10n.commonCustomerLabel,
                    account.customer!),
            ]),
            if (account.doctype == 'Lead')
              _LeadProfileSection(leadName: account.name),
            const SizedBox(height: 16),
            // The same diary the lead page shows — one journey per account, not
            // one per screen. `onJourneyChanged` reloads the account because a
            // dated next action restamps its follow-up server-side.
            JourneyNotesSection(
              referenceDoctype: account.doctype,
              referenceName: account.name,
              defaultContactPhone:
                  account.contact.mobileNo ?? account.contact.phone,
              onChanged: onJourneyChanged,
            ),
            _section(context, context.l10n.b2bSectionInsights, [
              if (account.predictedNextOrder != null)
                _kv(context, context.l10n.b2bPredictedNextOrder,
                    account.predictedNextOrder!),
              if (account.avgOrderCycleDays != null)
                _kv(
                    context,
                    context.l10n.b2bAvgOrderCycle,
                    context.l10n.b2bDaysValue(
                        account.avgOrderCycleDays!.toStringAsFixed(1))),
            ]),
            _LabelsSection(
              labels: labels,
              onOpenLabel: busy ? null : onOpenLabel,
              onSetupLabels: busy ? null : onSetupLabels,
            ),
            _section(
              context,
              context.l10n.b2bSectionRecentInvoices,
              account.recentInvoices.isEmpty
                  ? [Text(context.l10n.b2bNone)]
                  : account.recentInvoices
                      .map(
                        (inv) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(inv.displayId),
                          subtitle: Text(
                            '${inv.postingDate ?? ''} · '
                            '${inv.orderPurpose ?? ''} · ${inv.status ?? ''}',
                          ),
                          trailing: Text(
                            inv.grandTotal?.toStringAsFixed(2) ?? '',
                          ),
                        ),
                      )
                      .toList(),
            ),
            _section(
              context,
              context.l10n.b2bSectionOpenTodos,
              account.openTodos.isEmpty
                  ? [Text(context.l10n.b2bNone)]
                  : account.openTodos
                      .map(
                        (todo) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: const Icon(Icons.check_box_outline_blank),
                          title: Text(todo.description ?? todo.name),
                          subtitle: todo.date != null ? Text(todo.date!) : null,
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: trailingSpacer),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            elevation: 8,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: busy ? null : onSendSample,
                      icon: const Icon(Icons.science_outlined),
                      label: Text(context.l10n.b2bSendSample),
                    ),
                    FilledButton.icon(
                      onPressed: busy ? null : onPlaceOrder,
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text(context.l10n.b2bPlaceOrder),
                    ),
                    OutlinedButton.icon(
                      onPressed: busy ? null : onLogCall,
                      icon: const Icon(Icons.call),
                      label: Text(context.l10n.b2bLogCall),
                    ),
                    OutlinedButton.icon(
                      onPressed: busy ? null : onMarkLost,
                      icon: const Icon(Icons.block),
                      label: Text(context.l10n.b2bMarkLost),
                    ),
                    if (onViewPricing != null)
                      OutlinedButton.icon(
                        onPressed: busy ? null : onViewPricing,
                        icon: const Icon(Icons.sell_outlined),
                        label: Text(context.l10n.b2bViewPricing),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (busy)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x33000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title, style: theme.textTheme.titleMedium),
        const Divider(),
        ...children,
      ],
    );
  }

  Widget _kv(BuildContext context, String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              key,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

/// Printed-label stock for this account, one row per flavour, straight off the
/// account payload. Tapping a row opens the label's own detail screen; an
/// account with nothing tracked gets a "Set up labels" shortcut into the
/// wizard (shown only when a real Customer is linked — labels hang off the
/// Customer, not the Lead).
class _LabelsSection extends StatelessWidget {
  final B2bAccountLabels? labels;
  final void Function(String label)? onOpenLabel;
  final VoidCallback? onSetupLabels;

  const _LabelsSection({
    required this.labels,
    this.onOpenLabel,
    this.onSetupLabels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = labels;
    final empty = data == null || data.isEmpty;

    // No labels and no way to create any: stay out of the way entirely.
    if (empty && onSetupLabels == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text(context.l10n.b2bLabelsSection,
                style: theme.textTheme.titleMedium),
            if (!empty && data.needsAttention > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFB3261E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  context.l10n.b2bLabelsNeedPrinting(data.needsAttention),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFB3261E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        const Divider(),
        if (empty) ...[
          Text(
            context.l10n.b2bNoLabelsTracked,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: onSetupLabels,
              icon: const Icon(Icons.label_outline, size: 18),
              label: Text(context.l10n.b2bSetUpLabels),
            ),
          ),
        ] else
          ...data.flavours.map(
            (flavour) => ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.label_outline, size: 20),
              title: Text(flavour.title),
              subtitle: Text(
                [
                  if (flavour.size.isNotEmpty) flavour.size,
                  '${flavour.onHandQty} on hand',
                ].join(' · '),
              ),
              trailing: LabelStatusChip(
                status: LabelStatus.parse(flavour.status),
                dense: true,
              ),
              onTap: (onOpenLabel == null || flavour.label.isEmpty)
                  ? null
                  : () => onOpenLabel!(flavour.label),
            ),
          ),
      ],
    );
  }
}

/// Read-only "Lead profile" enrichment for a Lead-backed B2B account. Fetches
/// the rich lead (`leads.get_lead`) independently of the main account load and
/// silently omits itself if the fetch fails or returns an empty record.
class _LeadProfileSection extends ConsumerStatefulWidget {
  const _LeadProfileSection({required this.leadName});

  final String leadName;

  @override
  ConsumerState<_LeadProfileSection> createState() =>
      _LeadProfileSectionState();
}

class _LeadProfileSectionState extends ConsumerState<_LeadProfileSection> {
  late final Future<Lead?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Lead?> _load() async {
    try {
      final lead =
          await ref.read(leadsRepositoryProvider).getLead(widget.leadName);
      // Treat an empty record (no name / no display name) as "nothing to show".
      if (lead.name.trim().isEmpty && lead.leadName.trim().isEmpty) return null;
      return lead;
    } catch (_) {
      // Resilient by design: never break the account view if the lead is
      // unavailable.
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Lead?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(context.l10n.b2bLoadingLeadProfile),
              ],
            ),
          );
        }
        final lead = snapshot.data;
        if (lead == null) return const SizedBox.shrink();
        return _LeadProfileCard(lead: lead);
      },
    );
  }
}

/// The compact, read-only lead card: score + tier/category/sahel chips, a
/// metrics row, contact quick-actions, addresses, and a branches summary.
class _LeadProfileCard extends StatelessWidget {
  const _LeadProfileCard({required this.lead});

  final Lead lead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = <Widget>[
      _metric(Icons.storefront_outlined,
          context.l10n.leadsBranchesCount(lead.branchCount)),
      if (lead.avgRating != null)
        _metric(
          Icons.star_rounded,
          '${lead.avgRating!.toStringAsFixed(1)} (${lead.totalReviews})',
          iconColor: LeadsTheme.gold,
        ),
      if (lead.primaryArea.trim().isNotEmpty)
        _metric(Icons.place_outlined, lead.primaryArea),
      if (lead.priceBand.trim().isNotEmpty)
        _metric(Icons.sell_outlined, lead.priceBand),
    ];

    final primaryAddress = _formatAddress(lead.primaryAddress);
    final shippingAddress = _formatAddress(lead.shippingAddress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(context.l10n.b2bLeadProfile,
            style: theme.textTheme.titleMedium),
        const Divider(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LeadsTheme.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScoreBar(lead.score, width: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TierPill(lead.tier),
                        if (lead.category != null &&
                            lead.category!.trim().isNotEmpty)
                          CategoryChip(
                            category: LeadCategory(
                              name: lead.category!,
                              categoryName: lead.category!,
                            ),
                            selected: false,
                            onTap: () {},
                          ),
                        if (lead.sahelBranches > 0)
                          SahelBadge(lead.sahelBranches),
                      ],
                    ),
                  ),
                ],
              ),
              if (metrics.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: metrics),
              ],
              const SizedBox(height: 12),
              _contactActions(context),
              // The people at the venue, each one tap from a call. Read-only
              // here: the lead screen owns editing them.
              if (lead.contacts.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  context.l10n.leadContactsTitleCount(lead.contacts.length),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                for (final contact in lead.contacts)
                  _contactRow(context, contact),
              ],
              if (primaryAddress != null || shippingAddress != null) ...[
                const SizedBox(height: 12),
                if (primaryAddress != null)
                  _addressRow(context, context.l10n.leadDetailPrimaryAddress,
                      primaryAddress),
                if (shippingAddress != null)
                  _addressRow(context, context.l10n.leadDetailShippingAddress,
                      shippingAddress),
              ],
              if (lead.branches.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  context.l10n.leadDetailBranchesCount(lead.branches.length),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                for (final branch in lead.branches.take(5))
                  _branchRow(context, branch),
                if (lead.branches.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      context.l10n
                          .b2bMoreBranches(lead.branches.length - 5),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// One person at the venue: name, title, and a call button.
  Widget _contactRow(BuildContext context, LeadContact contact) {
    final theme = Theme.of(context);
    final subtitle = [
      if (contact.role.trim().isNotEmpty) contact.role.trim(),
      if (contact.phone.trim().isNotEmpty) contact.phone.trim(),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          if (contact.isPrimary)
            const Padding(
              padding: EdgeInsetsDirectional.only(end: 4),
              child: Icon(Icons.star_rounded, size: 14, color: LeadsTheme.gold),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.displayName, style: theme.textTheme.bodyMedium),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          LeadActionButton(
            icon: Icons.call,
            tooltip: context.l10n.leadActionCall,
            enabled: contact.canCall,
            onTap: () => LeadActions.call(contact.phone),
          ),
        ],
      ),
    );
  }

  Widget _contactActions(BuildContext context) {
    // Falls back to the primary contact so a lead whose only number belongs to
    // a person is still one tap from a call.
    final callable = lead.callablePhone;
    final hasPhone = callable.isNotEmpty;
    final hasWebsite = lead.website.trim().isNotEmpty;
    final hasInstagram = lead.instagram.trim().isNotEmpty;
    final hasMaps = lead.mapsUrl.trim().isNotEmpty ||
        (lead.latitude != null && lead.longitude != null);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        LeadActionButton(
          icon: Icons.call,
          tooltip: context.l10n.leadActionCall,
          enabled: hasPhone,
          onTap: () => LeadActions.call(callable),
        ),
        LeadActionButton(
          icon: Icons.language,
          tooltip: context.l10n.leadActionWebsite,
          enabled: hasWebsite,
          onTap: () => LeadActions.website(lead.website),
        ),
        LeadActionButton(
          icon: Icons.camera_alt_outlined,
          tooltip: context.l10n.leadActionInstagram,
          color: LeadsTheme.berryPink,
          enabled: hasInstagram,
          onTap: () => LeadActions.instagram(lead.instagram),
        ),
        LeadActionButton(
          icon: Icons.map_outlined,
          tooltip: context.l10n.leadActionMap,
          enabled: hasMaps,
          onTap: () {
            if (lead.mapsUrl.trim().isNotEmpty) {
              LeadActions.maps(lead.mapsUrl);
            } else if (lead.latitude != null && lead.longitude != null) {
              LeadActions.mapsAt(lead.latitude!, lead.longitude!);
            }
          },
        ),
      ],
    );
  }

  Widget _metric(
    IconData icon,
    String text, {
    Color iconColor = LeadsTheme.muted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: LeadsTheme.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: LeadsTheme.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: LeadsTheme.deepPlum),
          ),
        ],
      ),
    );
  }

  Widget _addressRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _branchRow(BuildContext context, LeadBranch branch) {
    final theme = Theme.of(context);
    final location = [
      if (branch.area.trim().isNotEmpty) branch.area,
      if (branch.region.trim().isNotEmpty) branch.region,
    ].join(' · ');
    final hasName = branch.branchName.trim().isNotEmpty;
    final label = hasName
        ? (location.isNotEmpty ? '${branch.branchName} — $location' : branch.branchName)
        : (location.isNotEmpty ? location : '—');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.storefront_outlined,
              size: 14, color: LeadsTheme.muted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (branch.rating != null) ...[
            const Icon(Icons.star_rounded, size: 14, color: LeadsTheme.gold),
            const SizedBox(width: 2),
            Text(
              '${branch.rating!.toStringAsFixed(1)} (${branch.reviews})',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  String? _formatAddress(LeadAddress? address) {
    if (address == null) return null;
    final parts = [
      address.addressLine1,
      address.addressLine2,
      address.city,
      address.state,
      address.country,
      address.pincode,
    ].where((s) => s.trim().isNotEmpty).toList();
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }
}
