import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../pos/state/pos_notifier.dart';
import '../../purchase/data/purchase_service.dart';
import '../../../core/constants/business_constants.dart';

class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen({super.key});

  @override
  ConsumerState<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen> with SingleTickerProviderStateMixin {
  String? supplier;
  String supplierQuery = '';
  String itemQuery = '';
  DateTime postingDate = DateTime.now();
  double shippingAmount = 0.0;

  final List<Map<String, dynamic>> cart = [];
  late final TextEditingController _itemSearchController;
  late final TextEditingController _shippingController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _itemSearchController = TextEditingController(text: itemQuery);
    _shippingController = TextEditingController(text: shippingAmount.toStringAsFixed(2));
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _itemSearchController.dispose();
    _shippingController.dispose();
    _tabController.dispose();
    for (final line in cart) {
      try {
        (line['qtyCtrl'] as TextEditingController?)?.dispose();
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.purchaseTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add_shopping_cart), text: 'New Invoice'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewInvoiceTab(),
          _PurchaseHistoryTab(onNavigateToInvoice: (inv) {
            // Switch to new invoice tab and pre-populate supplier
            _tabController.animateTo(0);
            final supplierName = (inv['supplier'] ?? inv['supplier_name'] ?? '').toString();
            if (supplierName.isNotEmpty) {
              setState(() => supplier = supplierName);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildNewInvoiceTab() {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Row(
        children: [
          // Left: suppliers + items
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.purchaseSupplierSectionTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openSupplierPicker(initialRecent: true),
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: supplier ?? l10n.purchaseTapToPickSupplier,
                            ),
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _openSupplierPicker(initialRecent: false),
                      child: Text(l10n.commonChoose),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Text(l10n.purchaseItemsSectionTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _itemSearchController,
                    decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.commonSearchItems),
                    onChanged: (v) => setState(() => itemQuery = v),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _buildItemsList()),
                ],
              ),
            ),
          ),
          // Right: cart and summary
          Container(width: 1, color: Colors.grey.shade300),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final d = await showDatePicker(
                          context: context,
                          firstDate: DateTime(now.year - 1),
                          lastDate: DateTime(now.year + 1),
                          initialDate: postingDate,
                        );
                        if (d != null) setState(() => postingDate = d);
                      },
                      child: Text(_fmtDate(postingDate)),
                    ),
                    const Spacer(),
                  ]),
                  const SizedBox(height: 8),
                  // Payment will be marked paid automatically; no toggle shown
                  Expanded(child: _buildCartList()),
                  const SizedBox(height: 8),
                  // Shipping input and summary
                  Row(
                    children: [
                      Text(l10n.purchaseShippingLabel),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: _shippingController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (v) {
                            final parsed = double.tryParse(v);
                            if (parsed == null) return;
                            setState(() => shippingAmount = parsed);
                          },
                        ),
                      ),
                      const Spacer(),
                      Builder(builder: (ctx) {
                        final total = _cartSubtotal() + (shippingAmount);
                        return Text(l10n.commonTotalValue(total.toStringAsFixed(2)));
                      })
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: cart.isEmpty || supplier == null ? null : _submit,
                          icon: const Icon(Icons.check),
                          label: Text(l10n.purchaseSubmit),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
    );
  }

  Future<void> _openSupplierPicker({required bool initialRecent}) async {
    final service = ref.read(purchaseServiceProvider);
    List<Map<String, dynamic>> results = [];
    try {
      results = initialRecent
          ? await service.getRecentSuppliers()
          : await service.getSuppliers(supplierQuery);
    } catch (_) {}
    if (!mounted) return;
    final queryController = TextEditingController(text: supplierQuery);
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        final dialogL10n = ctx.l10n;
        return StatefulBuilder(builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: Text(dialogL10n.purchaseSelectSupplier),
            content: SizedBox(
              width: 480,
              height: 520,
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: queryController,
                        decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: dialogL10n.commonSearchSuppliers),
                        onChanged: (v) async {
                          setStateDialog(() {});
                          try {
                            final data = await service.getSuppliers(v);
                            setStateDialog(() => results = data);
                          } catch (_) {}
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () async {
                        try {
                          final data = await service.getRecentSuppliers();
                          setStateDialog(() => results = data);
                        } catch (_) {}
                      },
                      icon: const Icon(Icons.history),
                      label: Text(dialogL10n.purchaseRecent),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Expanded(
                    child: results.isEmpty
                        ? Center(child: Text(dialogL10n.commonNoSuppliers))
                        : ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (ctx, i) {
                              final s = results[i];
                              final group = (s['supplier_group'] ?? '') as String;
                              final buffer = StringBuffer(group);
                              if (s['disabled'] == 1) {
                                buffer.write(dialogL10n.purchaseSupplierDisabledSuffix);
                              }
                              final subtitle = buffer.toString();
                              return ListTile(
                                title: Text(s['supplier_name'] ?? s['name'] ?? ''),
                                subtitle: subtitle.isEmpty ? null : Text(subtitle),
                                onTap: () => Navigator.pop(ctx, s),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
    if (selected != null) {
      setState(() {
        supplier = selected['name'] ?? selected['supplier_name'];
        supplierQuery = '';
      });
    }
  }

  Widget _buildItemsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ref.read(purchaseServiceProvider).searchItems(itemQuery),
      builder: (context, snap) {
        final l10n = context.l10n;
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? [];
        if (items.isEmpty) return Center(child: Text(l10n.commonNoItems));
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, i) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final itemL10n = ctx.l10n;
            final it = items[i];
            final code = it['item_code'];
            final name = it['item_name'] ?? code;
            final stockUom = it['stock_uom']?.toString() ?? '';
            return ListTile(
              title: Text(itemL10n.commonNameWithCode(name, code)),
              subtitle: Text(itemL10n.commonUomValue(stockUom)),
              trailing: ElevatedButton(
                onPressed: () => _addToCart(it),
                child: Text(itemL10n.commonAdd),
              ),
            );
          },
        );
      },
    );
  }

  void _addToCart(Map<String, dynamic> it) {
    final code = it['item_code'];
    final name = it['item_name'] ?? code;
    final stockUom = it['stock_uom'];
    final uoms = (it['uoms'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final prices = (it['prices'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final priceForStock = prices.firstWhere(
      (p) => (p['uom'] == stockUom),
      orElse: () => {'uom': stockUom, 'rate': 0},
    );
    setState(() {
      cart.add({
        'item_code': code,
        'item_name': name,
        'uom': stockUom,
        'qty': 1.0,
        // controller for qty two-way binding (supports steppers)
        'qtyCtrl': TextEditingController(text: 1.0.toStringAsFixed(2)),
        'rate': (priceForStock['rate'] ?? 0).toDouble(),
        'stock_uom': stockUom,
        'uoms': uoms,
        'prices': prices,
      });
    });
  }

  Widget _buildCartList() {
    final l10n = context.l10n;
    if (cart.isEmpty) return Center(child: Text(l10n.purchaseNoItemsInCart));
    return ListView.separated(
      itemCount: cart.length,
      separatorBuilder: (_, i) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final itemL10n = ctx.l10n;
        final line = cart[i];
        final uoms = (line['uoms'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final uom = (line['uom'] ?? '').toString();
        final qty = (line['qty'] as num).toDouble();
        final rate = (line['rate'] as num).toDouble();
        final amount = qty * rate;
        // ensure qty controller exists
        line['qtyCtrl'] ??= TextEditingController(text: qty.toStringAsFixed(2));
        final TextEditingController qtyCtrl = line['qtyCtrl'] as TextEditingController;
        return ListTile(
          title: Text(itemL10n.commonNameWithCode(line['item_name'] as String, line['item_code'] as String)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(itemL10n.commonUomLabel),
                const SizedBox(width: 6),
                DropdownButton<String>(
                  value: uom.isEmpty && uoms.isNotEmpty ? uoms.first['uom'] : uom,
                  items: [
                    for (final u in uoms)
                      DropdownMenuItem(
                        value: u['uom'] as String,
                        child: Text(_uomLabel(u, line['stock_uom'] as String?)),
                      ),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    // Prefer instant local computation using conversion factor; fallback to API only if needed
                    final String itemCode = (line['item_code'] as String);
                    final String stockUom = (line['stock_uom'] as String? ?? '');
                    final double conv = _convForUom(uoms, v);
                    final prices = (line['prices'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                    final priceForSelected = prices.firstWhere(
                      (p) => (p['uom'] == v),
                      orElse: () => {},
                    );
                    final priceForStock = prices.firstWhere(
                      (p) => (p['uom'] == stockUom),
                      orElse: () => {},
                    );

                    double? newRate;
                    final selRate = priceForSelected['rate'];
                    if (selRate != null) {
                      newRate = (selRate as num).toDouble();
                    } else if (priceForStock['rate'] != null) {
                      newRate = ((priceForStock['rate'] as num).toDouble()) * conv;
                    }

                    if (newRate != null) {
                      setState(() {
                        line['uom'] = v;
                        line['rate'] = newRate!;
                      });
                    } else {
                      try {
                        final price = await ref.read(purchaseServiceProvider).getItemPrice(itemCode, uom: v);
                        var apiRate = (price['rate'] ?? 0).toDouble();
                        final priceUom = (price['uom'] as String?);
                        if (priceUom != null && priceUom != v && priceUom == stockUom) {
                          apiRate = apiRate * conv; // lift stock price by conversion
                        }
                        setState(() {
                          line['uom'] = v;
                          line['rate'] = apiRate;
                        });
                      } catch (_) {
                        setState(() => line['uom'] = v);
                      }
                    }
                  },
                ),
                const SizedBox(width: 12),
                Text(itemL10n.commonQtyLabel),
                const SizedBox(width: 6),
                // Stepper -
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      final newQty = (qty - 1).clamp(0, double.infinity);
                      setState(() {
                        line['qty'] = newQty;
                        qtyCtrl.text = (newQty as double).toStringAsFixed(2);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 90,
                  child: TextFormField(
                    controller: qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) {
                      final q = double.tryParse(v) ?? qty;
                      setState(() => line['qty'] = q);
                    },
                  ),
                ),
                const SizedBox(width: 4),
                // Stepper +
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final newQty = qty + 1;
                      setState(() {
                        line['qty'] = newQty;
                        qtyCtrl.text = newQty.toStringAsFixed(2);
                      });
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Text(itemL10n.commonRateLabel),
                const SizedBox(width: 6),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    initialValue: rate.toStringAsFixed(2),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) {
                      final r = double.tryParse(v) ?? rate;
                      setState(() => line['rate'] = r);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Text(itemL10n.commonAmountValue(amount.toStringAsFixed(2))),
              ]),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() {
              try {
                (line['qtyCtrl'] as TextEditingController?)?.dispose();
              } catch (_) {}
              cart.removeAt(i);
            }),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    final service = ref.read(purchaseServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final paymentOption = await _choosePaymentOption();
      if (paymentOption == null) return;
      final items = cart
          .map((l) => {
                'item_code': l['item_code'],
                'qty': l['qty'],
                'uom': l['uom'],
                'rate': l['rate'],
              })
          .toList();
      final res = await service.createPurchaseInvoice(
        supplier: supplier!,
        postingDate: _fmtDate(postingDate),
        isPaid: true,
        items: items,
        paymentOption: paymentOption,
        shippingAmount: shippingAmount > 0 ? shippingAmount : null,
      );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.purchaseCreated((res['purchase_invoice'] ?? '-').toString()))),
      );
      if (!mounted) return;
      _resetForm();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.purchaseSubmitFailed('$e'))));
    }
  }

  String _fmtDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}' ;

  // Helpers for UOM labels and conversion lookups
  String _uomLabel(Map<String, dynamic> u, String? stockUom) {
    final uom = (u['uom'] as String? ?? '');
    final cf = (u['conversion_factor'] is num) ? (u['conversion_factor'] as num).toDouble() : 1.0;
    final base = stockUom ?? '';
    final cfStr = cf % 1 == 0 ? cf.toStringAsFixed(0) : cf.toString();
    if (base.isEmpty) return uom;
    return '$uom (x$cfStr $base)';
  }

  double _convForUom(List<Map<String, dynamic>> uoms, String uom) {
    final m = uoms.firstWhere(
      (e) => (e['uom'] == uom),
      orElse: () => const {'conversion_factor': 1},
    );
    final v = m['conversion_factor'];
    if (v is num) return v.toDouble();
    return 1.0;
  }

  double _cartSubtotal() {
    double sum = 0.0;
    for (final l in cart) {
      final qty = (l['qty'] as num).toDouble();
      final rate = (l['rate'] as num).toDouble();
      sum += qty * rate;
    }
    return sum;
  }

  void _resetForm() {
    for (final l in cart) {
      try {
        (l['qtyCtrl'] as TextEditingController?)?.dispose();
      } catch (_) {}
    }
    setState(() {
      cart.clear();
      supplier = null;
      supplierQuery = '';
      itemQuery = '';
      postingDate = DateTime.now();
      shippingAmount = 0.0;
    });
    _itemSearchController.clear();
    _shippingController.text = shippingAmount.toStringAsFixed(2);
  }

  Future<String?> _choosePaymentOption() async {
    // Build dynamic options: all POS Profiles by name, then InstaPay and Cash
    final posState = ref.read(posNotifierProvider);
    final profiles = posState.profiles;
    // Default to first profile if exists, else 'instapay' or 'cash'
    String selected = profiles.isNotEmpty ? (profiles.first['name'] as String) : 'instapay';
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            final dialogL10n = ctx.l10n;
            return AlertDialog(
              title: Text(dialogL10n.purchaseSelectPayment),
              content: RadioGroup<String>(
                groupValue: selected,
                onChanged: (v) => setStateDialog(() => selected = v ?? selected),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // One option per POS Profile (value is the profile name)
                    for (final p in profiles)
                      RadioListTile<String>(
                        value: p['name'] as String,
                        title: Text(p['name'] as String),
                        subtitle: Text(dialogL10n.purchasePaymentProfileSubtitle),
                        dense: true,
                      ),
                    const Divider(),
                    RadioListTile<String>(
                      value: 'instapay',
                      title: Text(dialogL10n.purchasePaymentInstapayTitle),
                      subtitle: Text(dialogL10n.purchasePaymentInstapaySubtitle),
                      dense: true,
                    ),
                    RadioListTile<String>(
                      value: PaymentModes.cashLower,
                      title: Text(dialogL10n.purchasePaymentCashTitle),
                      subtitle: Text(dialogL10n.purchasePaymentCashSubtitle),
                      dense: true,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(dialogL10n.commonCancel)),
                ElevatedButton(onPressed: () => Navigator.pop(ctx, selected), child: Text(dialogL10n.commonContinue)),
              ],
            );
          },
        );
      },
    );
  }
}

/// History tab showing recent purchase invoices with expandable item details.
class _PurchaseHistoryTab extends ConsumerStatefulWidget {
  final void Function(Map<String, dynamic> invoice)? onNavigateToInvoice;
  const _PurchaseHistoryTab({this.onNavigateToInvoice});

  @override
  ConsumerState<_PurchaseHistoryTab> createState() => _PurchaseHistoryTabState();
}

class _PurchaseHistoryTabState extends ConsumerState<_PurchaseHistoryTab> {
  List<Map<String, dynamic>> _invoices = [];
  int _total = 0;
  bool _loading = false;
  String? _error;
  int _page = 0;
  static const _pageSize = 30;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices({bool append = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(purchaseServiceProvider);
      final result = await service.getPurchaseInvoices(limit: _pageSize, page: _page);
      final list = (result['invoices'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      setState(() {
        if (append) {
          _invoices.addAll(list);
        } else {
          _invoices = list;
        }
        _total = (result['total'] as int?) ?? 0;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    _page = 0;
    await _loadInvoices();
  }

  void _loadMore() {
    if (_invoices.length < _total && !_loading) {
      _page++;
      _loadInvoices(append: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _invoices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_invoices.isEmpty) {
      return const Center(child: Text('No purchase invoices yet'));
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels > scroll.metrics.maxScrollExtent - 200) {
            _loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _invoices.length + (_invoices.length < _total ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _invoices.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _PurchaseInvoiceCard(
              invoice: _invoices[index],
              onReorder: widget.onNavigateToInvoice != null
                  ? () => widget.onNavigateToInvoice!(_invoices[index])
                  : null,
            );
          },
        ),
      ),
    );
  }
}

class _PurchaseInvoiceCard extends StatefulWidget {
  final Map<String, dynamic> invoice;
  final VoidCallback? onReorder;
  const _PurchaseInvoiceCard({required this.invoice, this.onReorder});

  @override
  State<_PurchaseInvoiceCard> createState() => _PurchaseInvoiceCardState();
}

class _PurchaseInvoiceCardState extends State<_PurchaseInvoiceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;
    final name = (inv['name'] ?? '').toString();
    final supplierName = (inv['supplier_name'] ?? inv['supplier'] ?? '').toString();
    final postingDate = (inv['posting_date'] ?? '').toString();
    final grandTotal = _parseDouble(inv['grand_total']);
    final outstanding = _parseDouble(inv['outstanding_amount']);
    final status = (inv['status'] ?? '').toString();
    final isPaid = (inv['is_paid'] == 1 || inv['is_paid'] == true);
    final items = (inv['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final statusColor = switch (status.toLowerCase()) {
      'paid' => Colors.green,
      'unpaid' => Colors.red,
      'overdue' => Colors.red[800]!,
      'cancelled' => Colors.grey,
      _ => Colors.blue,
    };

    String formattedDate = postingDate;
    try {
      final dt = DateTime.parse(postingDate);
      formattedDate = DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {}

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isPaid ? 'Paid' : status,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.store, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(supplierName, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ),
                      Text(formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.green),
                      ),
                      if (outstanding > 0.01) ...[
                        const SizedBox(width: 12),
                        Text(
                          'Outstanding: \$${outstanding.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 12, color: Colors.red[600]),
                        ),
                      ],
                      const Spacer(),
                      Text('${items.length} items', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  // Item rows
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              (item['item_name'] ?? item['item_code'] ?? '').toString(),
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '${_parseDouble(item['qty']).toStringAsFixed(1)} ${item['uom'] ?? ''}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '@${_parseDouble(item['rate']).toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(
                              '\$${_parseDouble(item['amount']).toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (widget.onReorder != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.onReorder,
                        icon: const Icon(Icons.replay, size: 16),
                        label: const Text('Reorder from same supplier'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.indigo,
                          side: const BorderSide(color: Colors.indigo),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
