import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../../data/models/b2b_models.dart';
import '../b2b_order_launch.dart';
import '../widgets/b2b_stage_chip.dart';

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
  late Future<B2bAccount> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<B2bAccount> _load() {
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
      appBar: AppBar(title: const Text('Account')),
      body: FutureBuilder<B2bAccount>(
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
                    Text('Failed to load account.\n${snapshot.error}',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _reload, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          final account = snapshot.requireData;
          final customer = account.customer;
          return _AccountBody(
            account: account,
            busy: _busy,
            onSendSample: () => _bindAndOrder(account, isSample: true),
            onPlaceOrder: () => _bindAndOrder(account, isSample: false),
            onLogCall: () => _logCall(account),
            onMarkLost: () => _markLost(account),
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

  bool get _isLead => widget.doctype == 'Lead';

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
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logCall(B2bAccount account) async {
    final note = await _promptText(
      title: 'Log call',
      hint: 'What was discussed?',
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
        const SnackBar(content: Text('Activity logged')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log activity: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _markLost(B2bAccount account) async {
    final reason = await _promptText(
      title: 'Mark lost / on-hold',
      hint: 'Reason',
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
        const SnackBar(content: Text('Marked Lost/On-hold')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
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
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
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
    return AlertDialog(
      title: const Text('Create customer for lead'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Customer name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Mobile'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              _buildTerritoryField(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
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
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildTerritoryField() {
    final territoriesAsync = ref.watch(territoriesProvider(null));
    return territoriesAsync.when(
      data: (territories) => DropdownButtonFormField<String>(
        initialValue: _territory,
        isExpanded: true,
        menuMaxHeight: 320,
        decoration: const InputDecoration(labelText: 'Territory'),
        items: territories.map<DropdownMenuItem<String>>((territory) {
          final name = territory['name']?.toString() ?? '';
          final label = (territory['territory_name_ar'] ??
                  territory['territory_name'] ??
                  name)
              .toString();
          return DropdownMenuItem<String>(
            value: name,
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (value) => setState(() => _territory = value),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      ),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading territories…'),
          ],
        ),
      ),
      error: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Failed to load territories',
          style: TextStyle(color: Colors.red),
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
  final bool busy;
  final VoidCallback onSendSample;
  final VoidCallback onPlaceOrder;
  final VoidCallback onLogCall;
  final VoidCallback onMarkLost;
  final VoidCallback? onViewPricing;

  const _AccountBody({
    required this.account,
    required this.busy,
    required this.onSendSample,
    required this.onPlaceOrder,
    required this.onLogCall,
    required this.onMarkLost,
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
            const SizedBox(height: 12),
            _section(context, 'Contact', [
              if (account.contact.mobileNo != null)
                _kv(context, 'Mobile', account.contact.mobileNo!),
              if (account.contact.phone != null)
                _kv(context, 'Phone', account.contact.phone!),
              if (account.contact.emailId != null)
                _kv(context, 'Email', account.contact.emailId!),
              if (account.customer != null)
                _kv(context, 'Customer', account.customer!),
            ]),
            if (account.doctype == 'Lead')
              _LeadProfileSection(leadName: account.name),
            _section(context, 'Insights', [
              if (account.predictedNextOrder != null)
                _kv(context, 'Predicted next order',
                    account.predictedNextOrder!),
              if (account.avgOrderCycleDays != null)
                _kv(context, 'Avg order cycle',
                    '${account.avgOrderCycleDays!.toStringAsFixed(1)} days'),
            ]),
            _section(
              context,
              'Recent invoices',
              account.recentInvoices.isEmpty
                  ? [const Text('None')]
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
              'Open to-dos',
              account.openTodos.isEmpty
                  ? [const Text('None')]
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
                      label: const Text('Send sample'),
                    ),
                    FilledButton.icon(
                      onPressed: busy ? null : onPlaceOrder,
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('Place order'),
                    ),
                    OutlinedButton.icon(
                      onPressed: busy ? null : onLogCall,
                      icon: const Icon(Icons.call),
                      label: const Text('Log call'),
                    ),
                    OutlinedButton.icon(
                      onPressed: busy ? null : onMarkLost,
                      icon: const Icon(Icons.block),
                      label: const Text('Mark lost'),
                    ),
                    if (onViewPricing != null)
                      OutlinedButton.icon(
                        onPressed: busy ? null : onViewPricing,
                        icon: const Icon(Icons.sell_outlined),
                        label: const Text('View pricing'),
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
          return const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Row(
              children: [
                SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Loading lead profile…'),
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
      _metric(Icons.storefront_outlined, '${lead.branchCount} branches'),
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
        Text('Lead profile', style: theme.textTheme.titleMedium),
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
              _contactActions(),
              if (primaryAddress != null || shippingAddress != null) ...[
                const SizedBox(height: 12),
                if (primaryAddress != null)
                  _addressRow(context, 'Primary address', primaryAddress),
                if (shippingAddress != null)
                  _addressRow(context, 'Shipping address', shippingAddress),
              ],
              if (lead.branches.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Branches (${lead.branches.length})',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                for (final branch in lead.branches.take(5))
                  _branchRow(context, branch),
                if (lead.branches.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+ ${lead.branches.length - 5} more',
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

  Widget _contactActions() {
    final hasPhone = lead.phone.trim().isNotEmpty;
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
          tooltip: 'Call',
          enabled: hasPhone,
          onTap: () => LeadActions.call(lead.phone),
        ),
        LeadActionButton(
          icon: Icons.language,
          tooltip: 'Website',
          enabled: hasWebsite,
          onTap: () => LeadActions.website(lead.website),
        ),
        LeadActionButton(
          icon: Icons.camera_alt_outlined,
          tooltip: 'Instagram',
          color: LeadsTheme.berryPink,
          enabled: hasInstagram,
          onTap: () => LeadActions.instagram(lead.instagram),
        ),
        LeadActionButton(
          icon: Icons.map_outlined,
          tooltip: 'Map',
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
