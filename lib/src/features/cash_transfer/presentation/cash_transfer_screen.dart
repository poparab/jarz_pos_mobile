import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../manager/state/manager_providers.dart';
import '../data/cash_transfer_service.dart';

class CashTransferScreen extends ConsumerStatefulWidget {
  const CashTransferScreen({super.key});
  @override
  ConsumerState<CashTransferScreen> createState() => _CashTransferScreenState();
}

class _CashTransferScreenState extends ConsumerState<CashTransferScreen> {
  String? fromAccount;
  String? toAccount;
  DateTime? postingDate;
  final amountCtrl = TextEditingController(text: '0.00');
  final remarkCtrl = TextEditingController();
  List<Map<String, dynamic>> accounts = const [];
  bool loading = false;

  Color _colorForCategory(String? cat) {
    switch ((cat ?? 'other').toLowerCase()) {
      case 'cash':
        return Colors.green.shade600;
      case 'bank':
        return Colors.blue.shade600;
      case 'mobile':
        return Colors.purple.shade600;
      case 'pos_profile':
        return Colors.orange.shade700;
      case 'sales_partner':
        return Colors.teal.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _iconForCategory(String? cat) {
    switch ((cat ?? 'other').toLowerCase()) {
      case 'cash':
        return Icons.payments;
      case 'bank':
        return Icons.account_balance;
      case 'mobile':
        return Icons.phone_iphone;
      case 'pos_profile':
        return Icons.storefront;
      case 'sales_partner':
        return Icons.handshake;
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    remarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() => loading = true);
    try {
      final service = ref.read(cashTransferServiceProvider);
      final asOf = postingDate == null ? null : DateFormat('yyyy-MM-dd').format(postingDate!);
      accounts = await service.listAccounts(asOf: asOf);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Map<String, dynamic>? _find(String? acc) => accounts.firstWhere(
        (a) => a['account'] == acc,
        orElse: () => const {},
      );

  double _balance(String? acc) => ((acc == null) ? 0.0 : ((_find(acc)?['balance'] as num?)?.toDouble() ?? 0.0));

  bool _canSubmit() {
    final amt = double.tryParse(amountCtrl.text.trim()) ?? 0;
    if (amt <= 0) return false;
    if (fromAccount == null || toAccount == null) return false;
    if (fromAccount == toAccount) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(managerAccessProvider).maybeWhen(data: (v) => v, orElse: () => false);
    if (!allowed) {
      return Scaffold(appBar: AppBar(title: const Text('Cash Transfer')), body: const Center(child: Text('Managers only')));
    }
    final amt = double.tryParse(amountCtrl.text.trim()) ?? 0;
    final fromBal = _balance(fromAccount);
    final toBal = _balance(toAccount);
    final fromAfter = fromBal - amt;
    final toAfter = toBal + amt;
    return Scaffold(
      appBar: AppBar(title: const Text('Cash Transfer')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: _accountDropdown('From Account', fromAccount, (v) {
                setState(() {
                  fromAccount = v;
                  if (fromAccount == toAccount) {
                    toAccount = null; // force reselect
                  }
                });
              })),
              const SizedBox(width: 8),
              Expanded(child: _accountDropdown('To Account', toAccount, (v) {
                setState(() {
                  toAccount = v;
                  if (toAccount == fromAccount) {
                    toAccount = null; // prevent same
                  }
                });
              })),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final initial = postingDate ?? now;
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initial,
                    firstDate: DateTime(now.year - 5),
                    lastDate: DateTime(now.year + 5),
                  );
                  if (picked != null) {
                    setState(() => postingDate = DateTime(picked.year, picked.month, picked.day));
                    await _loadAccounts();
                  }
                },
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(postingDate == null ? 'Posting: Today' : 'Posting: ${DateFormat('yyyy-MM-dd').format(postingDate!)}'),
              ),
              if (postingDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Use Today',
                  onPressed: () async {
                    setState(() => postingDate = null);
                    await _loadAccounts();
                  },
                  icon: const Icon(Icons.close),
                ),
              ]
            ]),
            const SizedBox(height: 8),
            TextFormField(
              controller: remarkCtrl,
              decoration: const InputDecoration(labelText: 'Remark (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            if (fromAccount != null || toAccount != null)
              Card(
                elevation: 0,
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(child: _balanceTile('From', fromAccount, fromBal, fromAfter)),
                      const SizedBox(width: 8),
                      Expanded(child: _balanceTile('To', toAccount, toBal, toAfter)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton.icon(
                onPressed: _canSubmit() ? _submit : null,
                icon: const Icon(Icons.send),
                label: const Text('Submit'),
              ),
              if (fromAccount == toAccount && fromAccount != null) ...[
                const SizedBox(width: 12),
                const Text('Accounts must differ', style: TextStyle(color: Colors.red)),
              ],
            ]),
            const SizedBox(height: 12),
            Expanded(child: _accountsOverview()),
          ],
        ),
      ),
    );
  }

  Widget _accountDropdown(String label, String? value, ValueChanged<String?> onChanged) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: const Text('Select account'),
          items: [
            for (final a in accounts)
              DropdownMenuItem<String>(
                value: a['account'] as String,
                child: Row(
                  children: [
                    Icon(_iconForCategory(a['category'] as String?), color: _colorForCategory(a['category'] as String?)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(a['label'] as String? ?? a['account'] as String)),
                    const SizedBox(width: 8),
                    Text(((a['balance'] as num?)?.toDouble() ?? 0).toStringAsFixed(2),
                        style: TextStyle(color: _colorForCategory(a['category'] as String?))),
                  ],
                ),
              )
          ],
          onChanged: (v) => onChanged(v),
        ),
      ),
    );
  }

  Widget _balanceTile(String title, String? acc, double before, double after) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        if (acc != null)
          Row(children: [
            Icon(_iconForCategory(_find(acc)?['category'] as String?), color: _colorForCategory(_find(acc)?['category'] as String?)),
            const SizedBox(width: 6),
            Expanded(child: Text(acc)),
          ])
        else
          const Text('—'),
        const SizedBox(height: 8),
        Text('Before: ${before.toStringAsFixed(2)}'),
        Text('After:  ${after.toStringAsFixed(2)}'),
      ]),
    );
  }

  Widget _accountsOverview() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (accounts.isEmpty) return const Center(child: Text('No accounts found'));
    // Group accounts by category for clarity
    final byCat = <String, List<Map<String, dynamic>>>{};
    for (final a in accounts) {
      final cat = (a['category'] as String?)?.toLowerCase() ?? 'other';
      byCat.putIfAbsent(cat, () => <Map<String, dynamic>>[]).add(a);
    }

    return ListView(
      children: [
        for (final entry in byCat.entries)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                child: Row(children: [
                  Icon(_iconForCategory(entry.key), color: _colorForCategory(entry.key)),
                  const SizedBox(width: 6),
                  Text(entry.key.toUpperCase(), style: TextStyle(color: _colorForCategory(entry.key), fontWeight: FontWeight.bold)),
                ]),
              ),
              ...entry.value.map((a) {
                final name = a['label'] ?? a['account'];
                final bal = (a['balance'] as num?)?.toDouble() ?? 0.0;
                final color = _colorForCategory(a['category'] as String?);
                return ListTile(
                  leading: Icon(_iconForCategory(a['category'] as String?), color: color),
                  title: Text(name as String),
                  subtitle: Text(a['account'] as String),
                  trailing: Text(bal.toStringAsFixed(2), style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                  onTap: () {
                    setState(() {
                      if (fromAccount == null) {
                        fromAccount = a['account'] as String;
                      } else if (toAccount == null && a['account'] != fromAccount) {
                        toAccount = a['account'] as String;
                      } else {
                        fromAccount = a['account'] as String; // toggle selection preference
                        if (fromAccount == toAccount) toAccount = null;
                      }
                    });
                  },
                );
              }),
              const Divider(height: 1),
            ],
          ),
      ],
    );
  }

  Future<void> _submit() async {
    final service = ref.read(cashTransferServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
      final dateStr = postingDate == null ? null : DateFormat('yyyy-MM-dd').format(postingDate!);
      final res = await service.submitCashTransfer(
        fromAccount: fromAccount!,
        toAccount: toAccount!,
        amount: amt,
        postingDate: dateStr,
        remark: remarkCtrl.text.trim().isEmpty ? null : remarkCtrl.text.trim(),
      );
      messenger.showSnackBar(SnackBar(content: Text('Journal Entry: ${res['journal_entry']}')));
      // Refresh balances
      await _loadAccounts();
      setState(() {
        amountCtrl.text = '0.00';
      });
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }
}
