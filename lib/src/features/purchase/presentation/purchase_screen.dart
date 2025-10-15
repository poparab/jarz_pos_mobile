import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../pos/state/pos_notifier.dart';
import '../../purchase/data/purchase_service.dart';

class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen({super.key});

  @override
  ConsumerState<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen> {
  String? supplier;
  String supplierQuery = '';
  String itemQuery = '';
  DateTime postingDate = DateTime.now();
  double shippingAmount = 0.0; // Freight & Forwarding (Actual amount)
  // Payment is always marked as paid in background

  // Cart lines: {item_code, item_name, uom, qty, rate, uoms:[], prices:[]}
  final List<Map<String, dynamic>> cart = [];
  late final TextEditingController _itemSearchController;
  late final TextEditingController _shippingController;

  @override
  void initState() {
    super.initState();
    _itemSearchController = TextEditingController(text: itemQuery);
    _shippingController = TextEditingController(text: shippingAmount.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _itemSearchController.dispose();
    _shippingController.dispose();
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.purchaseTitle)),
      drawer: const AppDrawer(),
      body: Row(
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
      ),
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
                      value: 'cash',
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
