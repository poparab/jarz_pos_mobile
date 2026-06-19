import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          return _AccountBody(
            account: account,
            busy: _busy,
            onSendSample: () => _bindAndOrder(account, isSample: true),
            onPlaceOrder: () => _bindAndOrder(account, isSample: false),
            onLogCall: () => _logCall(account),
            onMarkLost: () => _markLost(account),
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
    final nameCtrl = TextEditingController(text: account.title);
    final mobileCtrl =
        TextEditingController(text: account.contact.mobileNo ?? '');
    final addressCtrl = TextEditingController();
    final territoryCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<_LeadCustomerFields>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create customer for lead'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Customer name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: mobileCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Mobile'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: territoryCtrl,
                  decoration: const InputDecoration(labelText: 'Territory'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.pop(
                ctx,
                _LeadCustomerFields(
                  customerName: nameCtrl.text.trim(),
                  mobileNo: mobileCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                  territoryId: territoryCtrl.text.trim(),
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
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

  const _AccountBody({
    required this.account,
    required this.busy,
    required this.onSendSample,
    required this.onPlaceOrder,
    required this.onLogCall,
    required this.onMarkLost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                          title: Text(inv.name),
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
            const SizedBox(height: 80),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            elevation: 8,
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
                ],
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
