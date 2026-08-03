import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../pos/state/pos_notifier.dart';
import '../../purchase/data/purchase_service.dart';
import '../domain/request_allocation.dart';
import '../../purchase_request/presentation/widgets/buy_from_requests_sheet.dart';
import '../../../core/constants/business_constants.dart';

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
  double shippingAmount = 0.0;

  /// Supplier's own invoice number. ERPNext rejects a duplicate for the same
  /// supplier, which is the built-in guard against entering a bill twice.
  String billNo = '';
  DateTime? billDate;
  String? taxesTemplate;
  List<Map<String, dynamic>> taxesTemplates = const [];

  /// Guards the submit path. Without it a double tap on a slow connection
  /// created two invoices — double stock and double cash out.
  bool _submitting = false;

  /// Regenerated after every successful submit. Sent with the create call so a
  /// network-level retry is deduplicated server-side rather than buying twice.
  String _idempotencyKey = _newIdempotencyKey();

  final List<Map<String, dynamic>> cart = [];
  StateSetter? _sheetSetState;
  late final TextEditingController _itemSearchController;
  late final TextEditingController _shippingController;
  late final TextEditingController _billNoController;

  // Item search runs as explicit state rather than a Future built inside
  // build(). The old code created a new Future on every rebuild, so changing a
  // quantity or typing in the shipping box fired a fresh search request.
  Timer? _itemDebounce;
  int _itemSearchToken = 0;
  List<Map<String, dynamic>> _items = const [];
  bool _itemsLoading = true;

  static String _newIdempotencyKey() =>
      'pi-${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(DateTime.now())}';

  @override
  void initState() {
    super.initState();
    _itemSearchController = TextEditingController(text: itemQuery);
    _shippingController = TextEditingController(text: shippingAmount.toStringAsFixed(2));
    _billNoController = TextEditingController(text: billNo);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runItemSearch(itemQuery);
      _loadTaxesTemplates();
    });
  }

  @override
  void dispose() {
    _itemDebounce?.cancel();
    _itemSearchController.dispose();
    _shippingController.dispose();
    _billNoController.dispose();
    for (final line in cart) {
      try {
        (line['qtyCtrl'] as TextEditingController?)?.dispose();
      } catch (_) {}
    }
    super.dispose();
  }

  void _onItemQueryChanged(String value) {
    setState(() => itemQuery = value);
    _itemDebounce?.cancel();
    // One request per keystroke was the previous behaviour; 300ms of quiet
    // turns a typed word into roughly two calls instead of twenty.
    _itemDebounce = Timer(
      const Duration(milliseconds: 300),
      () => _runItemSearch(value),
    );
  }

  Future<void> _runItemSearch(String query) async {
    // Monotonic token: a slow response for "ah" must not overwrite the results
    // already shown for "ahmed".
    final token = ++_itemSearchToken;
    if (mounted) setState(() => _itemsLoading = true);
    try {
      final results = await ref.read(purchaseServiceProvider).searchItems(query);
      if (!mounted || token != _itemSearchToken) return;
      setState(() {
        _items = results;
        _itemsLoading = false;
      });
    } catch (_) {
      if (!mounted || token != _itemSearchToken) return;
      setState(() {
        _items = const [];
        _itemsLoading = false;
      });
    }
  }

  Future<void> _loadTaxesTemplates() async {
    try {
      final payload =
          await ref.read(purchaseServiceProvider).getPurchaseTaxesTemplates();
      if (!mounted) return;
      final templates = ((payload['templates'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      setState(() {
        taxesTemplates = templates;
        taxesTemplate = payload['default'] as String?;
      });
    } catch (_) {
      // Tax templates are optional; a failure here must not block purchasing.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.purchaseTitle),
        actions: [
          // The consolidated buying list — one row per item, demand summed
          // across every open team request.
          IconButton(
            tooltip: l10n.purchaseFromRequests,
            icon: const Icon(Icons.playlist_add_check),
            onPressed: _openBuyFromRequests,
          ),
          IconButton(
            tooltip: l10n.purchaseHistoryTitle,
            icon: const Icon(Icons.history),
            onPressed: _openPurchaseHistory,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildNewInvoiceTab(),
    );
  }

  Widget _buildNewInvoiceTab() {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isPhone = ResponsiveUtils.isPhone(context);
    final padding = ResponsiveUtils.getResponsivePadding(context, small: 10, medium: 12, large: 12);

    final leftPanel = Padding(
      padding: padding,
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
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.commonSearchItems,
              suffixIcon: _itemsLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            onChanged: _onItemQueryChanged,
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildItemsList()),
        ],
      ),
    );

    if (isPhone) {
      return Stack(
        children: [
          leftPanel,
          Positioned(
            right: 16,
            bottom: 16,
            child: Badge(
              isLabelVisible: cart.isNotEmpty,
              label: Text('${cart.length}'),
              child: FloatingActionButton(
                onPressed: _openCartSheet,
                tooltip: l10n.purchaseSubmit,
                child: const Icon(Icons.shopping_cart),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: leftPanel,
        ),
        Container(width: 1, color: Colors.grey.shade300),
        Expanded(
          flex: 2,
          child: Padding(
            padding: padding,
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
                Expanded(child: _buildCartList()),
                const SizedBox(height: 8),
                _buildInvoiceMetaRow(context),
                const SizedBox(height: 8),
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
                      final total = _cartSubtotal() + shippingAmount;
                      return Text(l10n.commonTotalValue(total.toStringAsFixed(2)));
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: cart.isEmpty || supplier == null || _submitting
                            ? null
                            : _submit,
                        icon: _submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check),
                        label: Text(_submitting
                            ? l10n.purchaseSubmitting
                            : l10n.purchaseSubmit),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openCartSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: ResponsiveUtils.getCartBottomSheetInitialSize(context),
          minChildSize: ResponsiveUtils.getCartBottomSheetMinSize(context),
          maxChildSize: ResponsiveUtils.getCartBottomSheetMaxSize(context),
          expand: false,
          builder: (_, scrollController) {
            return StatefulBuilder(
              builder: (_, setSheetState) {
                _sheetSetState = setSheetState;
                final l10n = context.l10n;
                final colorScheme = Theme.of(context).colorScheme;
                final total = _cartSubtotal() + shippingAmount;
                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      // Date + supplier row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18),
                            const SizedBox(width: 6),
                            TextButton(
                              onPressed: () async {
                                final now = DateTime.now();
                                final d = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(now.year - 1),
                                  lastDate: DateTime(now.year + 1),
                                  initialDate: postingDate,
                                );
                                if (d != null) {
                                  setState(() => postingDate = d);
                                  setSheetState(() {});
                                }
                              },
                              child: Text(_fmtDate(postingDate)),
                            ),
                            const Spacer(),
                            if (supplier != null)
                              Flexible(
                                child: Text(
                                  supplier!,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Cart items
                      Expanded(
                        child: cart.isEmpty
                            ? Center(child: Text(l10n.purchaseNoItemsInCart))
                            : ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                itemCount: cart.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (_, i) {
                                  if (i >= cart.length) return const SizedBox.shrink();
                                  return _buildCartItemTile(cart[i], i, onChanged: () => setSheetState(() {}));
                                },
                              ),
                      ),
                      // Shipping + total + submit
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Column(
                          children: [
                            _buildInvoiceMetaRow(context,
                                onChanged: () => setSheetState(() {})),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(l10n.purchaseShippingLabel),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 120,
                                  child: TextField(
                                    controller: _shippingController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (v) {
                                      final parsed = double.tryParse(v);
                                      if (parsed == null) return;
                                      setState(() => shippingAmount = parsed);
                                      setSheetState(() {});
                                    },
                                  ),
                                ),
                                const Spacer(),
                                Text(l10n.commonTotalValue(total.toStringAsFixed(2))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed:
                                    cart.isEmpty || supplier == null || _submitting
                                        ? null
                                        : () async {
                                            await _submit();
                                            if (context.mounted) {
                                              setSheetState(() {});
                                            }
                                          },
                                icon: _submitting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.check),
                                label: Text(_submitting
                                    ? l10n.purchaseSubmitting
                                    : l10n.purchaseSubmit),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(sheetCtx).padding.bottom),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() => _sheetSetState = null);
  }

  Widget _buildCartItemTile(Map<String, dynamic> line, int i, {required VoidCallback onChanged}) {
    final l10n = context.l10n;
    final uoms = (line['uoms'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final uom = (line['uom'] ?? '').toString();
    final qty = (line['qty'] as num).toDouble();
    final rate = (line['rate'] as num).toDouble();
    final amount = qty * rate;
    line['qtyCtrl'] ??= TextEditingController(text: qty.toStringAsFixed(2));
    final TextEditingController qtyCtrl = line['qtyCtrl'] as TextEditingController;
    return ListTile(
      title: Text(l10n.commonNameWithCode(line['item_name'] as String, line['item_code'] as String)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(l10n.commonUomLabel),
            const SizedBox(width: 6),
            DropdownButton<String>(
              value: uom.isEmpty && uoms.isNotEmpty ? uoms.first['uom'] : uom,
              items: [
                for (final u in uoms)
                  DropdownMenuItem(value: u['uom'] as String, child: Text(_uomLabel(u, line['stock_uom'] as String?))),
              ],
              onChanged: (v) async {
                if (v == null) return;
                final String stockUom = (line['stock_uom'] as String? ?? '');
                final double conv = _convForUom(uoms, v);
                final prices = (line['prices'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                final priceForSelected = prices.firstWhere((p) => (p['uom'] == v), orElse: () => {});
                final priceForStock = prices.firstWhere((p) => (p['uom'] == stockUom), orElse: () => {});
                double? newRate;
                final selRate = priceForSelected['rate'];
                if (selRate != null) {
                  newRate = (selRate as num).toDouble();
                } else if (priceForStock['rate'] != null) {
                  newRate = ((priceForStock['rate'] as num).toDouble()) * conv;
                }
                if (newRate != null) {
                  setState(() { line['uom'] = v; line['rate'] = newRate!; });
                } else {
                  try {
                    final price = await ref.read(purchaseServiceProvider).getItemPrice(line['item_code'] as String, uom: v);
                    var apiRate = (price['rate'] ?? 0).toDouble();
                    final priceUom = (price['uom'] as String?);
                    if (priceUom != null && priceUom != v && priceUom == stockUom) apiRate = apiRate * conv;
                    setState(() { line['uom'] = v; line['rate'] = apiRate; });
                  } catch (_) {
                    setState(() => line['uom'] = v);
                  }
                }
                onChanged();
              },
            ),
            const SizedBox(width: 8),
            SizedBox(width: 28, height: 28, child: IconButton(
              padding: EdgeInsets.zero, iconSize: 18, visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove),
              onPressed: () {
                final newQty = (qty - 1).clamp(0, double.infinity) as double;
                setState(() { line['qty'] = newQty; qtyCtrl.text = newQty.toStringAsFixed(2); });
                onChanged();
              },
            )),
            const SizedBox(width: 4),
            SizedBox(width: 80, child: TextFormField(
              controller: qtyCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) { final q = double.tryParse(v) ?? qty; setState(() => line['qty'] = q); onChanged(); },
            )),
            const SizedBox(width: 4),
            SizedBox(width: 28, height: 28, child: IconButton(
              padding: EdgeInsets.zero, iconSize: 18, visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add),
              onPressed: () {
                final newQty = qty + 1;
                setState(() { line['qty'] = newQty; qtyCtrl.text = newQty.toStringAsFixed(2); });
                onChanged();
              },
            )),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Text(l10n.commonRateLabel),
            const SizedBox(width: 6),
            SizedBox(width: 90, child: TextFormField(
              // Keyed by item, not list position. Without a key Flutter reuses
              // the field element by index, so deleting a row left the next
              // row's rate box showing the deleted row's number — silently
              // mis-pricing the line.
              key: ValueKey('rate-${line['item_code']}-$i'),
              initialValue: rate.toStringAsFixed(2),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) { final r = double.tryParse(v) ?? rate; setState(() => line['rate'] = r); onChanged(); },
            )),
            const SizedBox(width: 12),
            Text(l10n.commonAmountValue(amount.toStringAsFixed(2))),
          ]),
          if (line['requested_qty'] != null)
            _requestedChip(context, line, qty),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () {
          setState(() {
            try { (line['qtyCtrl'] as TextEditingController?)?.dispose(); } catch (_) {}
            cart.removeAt(i);
          });
          onChanged();
          _sheetSetState?.call(() {});
        },
      ),
    );
  }

  /// "requested 40, buying 35" — makes a deliberate deviation from what the
  /// team asked for visible at a glance instead of silent.
  Widget _requestedChip(
      BuildContext context, Map<String, dynamic> line, double qty) {
    final requested = _num(line['requested_qty']);
    if (requested <= 0) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final deviates = (qty - requested).abs() > 0.0001;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        deviates
            ? context.l10n
                .purchaseBuyingLess(_fmtQty(requested), _fmtQty(qty))
            : context.l10n.purchaseRequestedQty(_fmtQty(requested)),
        style: theme.textTheme.bodySmall?.copyWith(
          color: deviates ? theme.colorScheme.tertiary : theme.colorScheme.outline,
          fontWeight: deviates ? FontWeight.w600 : null,
        ),
      ),
    );
  }

  void _openPurchaseHistory() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: ResponsiveUtils.getDialogWidth(context, small: 380, medium: 560, large: 700),
          height: ResponsiveUtils.getDialogHeight(context, phoneFraction: 0.78, tabletFraction: 0.65, max: 500),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                child: Row(
                  children: [
                    const Icon(Icons.history),
                    const SizedBox(width: 8),
                    Text(context.l10n.purchaseHistoryTitle,
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: _PurchaseHistoryTab(
                  onNavigateToInvoice: (inv) {
                    Navigator.of(context, rootNavigator: true).pop();
                    final supplierName =
                        (inv['supplier'] ?? inv['supplier_name'] ?? '').toString();
                    if (supplierName.isNotEmpty) {
                      setState(() => supplier = supplierName);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
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
    // Monotonic token per dialog: a slow response for "ah" must not land after
    // — and overwrite — the results already shown for "ahmed".
    var searchToken = 0;
    Timer? debounce;

    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        final dialogL10n = ctx.l10n;
        return StatefulBuilder(builder: (ctx, setStateDialog) {
          Future<void> runSearch(String query) async {
            final token = ++searchToken;
            try {
              final data = await service.getSuppliers(query);
              if (token != searchToken) return;
              setStateDialog(() => results = data);
            } catch (_) {
              if (token != searchToken) return;
              setStateDialog(() => results = const []);
            }
          }

          return AlertDialog(
            title: Text(dialogL10n.purchaseSelectSupplier),
            content: SizedBox(
              width: ResponsiveUtils.getDialogWidth(context, small: 340, medium: 420, large: 480),
              height: ResponsiveUtils.getDialogHeight(context, phoneFraction: 0.75, tabletFraction: 0.65, max: 520),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: queryController,
                        decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: dialogL10n.commonSearchSuppliers),
                        onChanged: (v) {
                          debounce?.cancel();
                          debounce = Timer(
                            const Duration(milliseconds: 300),
                            () => runSearch(v),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final token = ++searchToken;
                        try {
                          final data = await service.getRecentSuppliers();
                          if (token != searchToken) return;
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
            actions: [
              // A new vendor turning up mid-purchase used to mean abandoning
              // the cart and opening Desk.
              TextButton.icon(
                onPressed: () => Navigator.pop(ctx, const {'__new__': true}),
                icon: const Icon(Icons.add, size: 18),
                label: Text(dialogL10n.purchaseNewSupplier),
              ),
            ],
          );
        });
      },
    );

    debounce?.cancel();
    queryController.dispose();

    if (selected == null || !mounted) return;
    if (selected['__new__'] == true) {
      await _createSupplier();
      return;
    }
    setState(() {
      supplier = selected['name'] ?? selected['supplier_name'];
      supplierQuery = '';
    });
  }

  Future<void> _createSupplier() async {
    final service = ref.read(purchaseServiceProvider);
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    List<Map<String, dynamic>> groups = const [];
    String? group;
    try {
      groups = await service.getSupplierGroups();
    } catch (_) {}
    if (!mounted) {
      nameController.dispose();
      phoneController.dispose();
      return;
    }

    final created = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        final dialogL10n = ctx.l10n;
        return StatefulBuilder(builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: Text(dialogL10n.purchaseNewSupplier),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: dialogL10n.purchaseNewSupplierName),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: group,
                  isExpanded: true,
                  decoration: InputDecoration(
                      labelText: dialogL10n.purchaseNewSupplierGroup),
                  items: [
                    for (final g in groups)
                      DropdownMenuItem(
                        value: g['name'] as String,
                        child: Text(g['name'] as String),
                      ),
                  ],
                  onChanged: (v) => setStateDialog(() => group = v),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      labelText: dialogL10n.purchaseNewSupplierPhone),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(dialogL10n.commonCancel),
              ),
              ElevatedButton(
                onPressed: nameController.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(ctx, {
                          'supplier_name': nameController.text.trim(),
                          'supplier_group': group,
                          'phone': phoneController.text.trim(),
                        }),
                child: Text(dialogL10n.commonContinue),
              ),
            ],
          );
        });
      },
    );

    nameController.dispose();
    phoneController.dispose();
    if (created == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final result = await service.createSupplier(
        supplierName: created['supplier_name'] as String,
        supplierGroup: created['supplier_group'] as String?,
        phone: created['phone'] as String?,
      );
      if (!mounted) return;
      final payload =
          Map<String, dynamic>.from(result['supplier'] as Map);
      setState(() => supplier = payload['name'] as String?);
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.purchaseSupplierCreated(
            (payload['supplier_name'] ?? '').toString())),
      ));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.commonErrorWithDetails('$e'))),
      );
    }
  }

  Widget _buildItemsList() {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (_itemsLoading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) return Center(child: Text(l10n.commonNoItems));

    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final itemL10n = ctx.l10n;
        final it = _items[i];
        final code = it['item_code'];
        final name = it['item_name'] ?? code;
        final stockUom = it['stock_uom']?.toString() ?? '';
        final onHand = _num(it['on_hand_qty']);
        final lastPaid = _num(it['last_purchase_rate']);
        return ListTile(
          title: Text(itemL10n.commonNameWithCode(name, code)),
          // Stock and last-paid inline: a buyer choosing a price blind is the
          // single most common complaint about a bare item picker.
          subtitle: Row(
            children: [
              Text(itemL10n.commonUomValue(stockUom),
                  style: theme.textTheme.bodySmall),
              const SizedBox(width: 10),
              Text(itemL10n.purchaseOnHand(_fmtQty(onHand)),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline)),
              if (lastPaid > 0) ...[
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    itemL10n.purchaseLastPaid(lastPaid.toStringAsFixed(2)),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          trailing: ElevatedButton(
            onPressed: () => _addToCart(it),
            child: Text(itemL10n.commonAdd),
          ),
        );
      },
    );
  }

  /// Supplier bill reference + tax template.
  ///
  /// The bill number is what makes ERPNext's built-in duplicate-invoice guard
  /// actually fire — it rejects a repeated `bill_no` for the same supplier, but
  /// only when one is recorded. Without it the same paper invoice could be
  /// entered twice by two different people.
  Widget _buildInvoiceMetaRow(BuildContext context, {VoidCallback? onChanged}) {
    final l10n = context.l10n;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                // A controller owned by state, not built inline: rebuilding one
                // per frame resets the cursor to position 0 mid-typing.
                controller: _billNoController,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: l10n.purchaseBillNoLabel,
                  hintText: l10n.purchaseBillNoHint,
                ),
                onChanged: (v) {
                  billNo = v;
                  onChanged?.call();
                },
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(now.year - 1),
                  lastDate: now,
                  initialDate: billDate ?? now,
                );
                if (picked != null) {
                  setState(() => billDate = picked);
                  onChanged?.call();
                }
              },
              icon: const Icon(Icons.event_outlined, size: 16),
              label: Text(
                billDate == null
                    ? l10n.purchaseBillDateLabel
                    : _fmtDate(billDate!),
              ),
            ),
          ],
        ),
        if (taxesTemplates.isNotEmpty)
          Row(
            children: [
              Text(l10n.purchaseTaxesLabel),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String?>(
                  value: taxesTemplate,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.purchaseTaxesNone),
                    ),
                    for (final t in taxesTemplates)
                      DropdownMenuItem<String?>(
                        value: t['name'] as String,
                        child: Text(
                          (t['title'] ?? t['name']).toString(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (v) {
                    setState(() => taxesTemplate = v);
                    onChanged?.call();
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  static double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _fmtQty(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

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
    final lastPaid = _num(it['last_purchase_rate']);
    // Prefer the price list, but fall back to what was actually last paid so a
    // brand-new item does not land in the cart at zero.
    final rate = _num(priceForStock['rate']) > 0
        ? _num(priceForStock['rate'])
        : lastPaid;
    setState(() {
      cart.add({
        'item_code': code,
        'item_name': name,
        'uom': stockUom,
        'qty': 1.0,
        // controller for qty two-way binding (supports steppers)
        'qtyCtrl': TextEditingController(text: 1.0.toStringAsFixed(2)),
        'rate': rate,
        'stock_uom': stockUom,
        'uoms': uoms,
        'prices': prices,
      });
    });
  }

  /// Open the consolidated buying list and fold the buyer's choices into the
  /// cart, carrying the request links that let ERPNext close each request.
  Future<void> _openBuyFromRequests() async {
    final selections = await BuyFromRequestsSheet.show(context);
    if (selections == null || selections.isEmpty || !mounted) return;

    setState(() {
      for (final selection in selections) {
        final demand = selection.demand;
        // Demand is expressed in stock UOM, so allocation and the invoice line
        // agree without a conversion step.
        var remaining = selection.qty;
        final links = <Map<String, dynamic>>[];
        for (final source in demand.sources) {
          if (remaining <= 0) break;
          final take = remaining < source.outstandingQty
              ? remaining
              : source.outstandingQty;
          links.add({
            'material_request': source.materialRequest,
            'material_request_item': source.materialRequestItem,
            'qty': take,
          });
          remaining -= take;
        }

        cart.add({
          'item_code': demand.itemCode,
          'item_name': demand.itemName,
          'uom': demand.stockUom,
          'stock_uom': demand.stockUom,
          'qty': selection.qty,
          'qtyCtrl':
              TextEditingController(text: selection.qty.toStringAsFixed(2)),
          'rate': demand.lastPurchaseRate,
          'uoms': [
            {'uom': demand.stockUom, 'conversion_factor': 1}
          ],
          'prices': const <Map<String, dynamic>>[],
          // Kept on the line so the cart can show "requested N, buying M" and
          // the submit call can split the purchase across source requests.
          'requested_qty': demand.outstandingQty,
          'request_links': links,
        });
      }
    });
    _sheetSetState?.call(() {});
  }

  /// Expand a cart line into one or more invoice rows.
  ///
  /// A line bought against several requests becomes several rows — one per
  /// request line — because ERPNext credits `received_qty` per link. The
  /// distribution itself lives in [allocateAcrossRequests] so it can be tested
  /// without a widget.
  List<Map<String, dynamic>> _expandLineForSubmit(Map<String, dynamic> line) {
    final qty = (line['qty'] as num).toDouble();
    final base = {
      'item_code': line['item_code'],
      'uom': line['uom'],
      'rate': (line['rate'] as num).toDouble(),
    };

    final targets = ((line['request_links'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map((link) => RequestAllocationTarget(
              materialRequest: (link['material_request'] ?? '').toString(),
              materialRequestItem:
                  (link['material_request_item'] ?? '').toString(),
              outstandingQty: _num(link['qty']),
            ))
        .toList();

    return [
      for (final row in allocateAcrossRequests(qty, targets))
        {
          ...base,
          'qty': row.qty,
          if (row.isLinked) 'material_request': row.materialRequest,
          if (row.isLinked) 'material_request_item': row.materialRequestItem,
        },
    ];
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
                    // See the note on the sheet's rate field: an unkeyed
                    // TextFormField in a list reuses state by index and shows a
                    // deleted row's value on the row that takes its place.
                    key: ValueKey('rate-panel-${line['item_code']}-$i'),
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
              if (line['requested_qty'] != null)
                _requestedChip(context, line, qty),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                try {
                  (line['qtyCtrl'] as TextEditingController?)?.dispose();
                } catch (_) {}
                cart.removeAt(i);
              });
              _sheetSetState?.call(() {});
            },
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    // Re-entrancy guard. The button is also disabled while this runs, but the
    // flag is what actually makes a fast double tap safe.
    if (_submitting) return;

    final service = ref.read(purchaseServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    final paymentOption = await _choosePaymentOption();
    if (paymentOption == null || !mounted) return;

    // `_creditPaymentOption` means "buy on supplier terms" — the invoice is
    // submitted unpaid and settled later from the history sheet.
    final isPaid = paymentOption != _creditPaymentOption;

    setState(() => _submitting = true);
    _sheetSetState?.call(() {});
    try {
      final items = cart.expand(_expandLineForSubmit).toList();
      final res = await service.createPurchaseInvoice(
        supplier: supplier!,
        postingDate: _fmtDate(postingDate),
        isPaid: isPaid,
        items: items,
        paymentOption: isPaid ? paymentOption : null,
        shippingAmount: shippingAmount > 0 ? shippingAmount : null,
        billNo: billNo,
        billDate: billDate == null ? null : _fmtDate(billDate!),
        taxesTemplate: taxesTemplate,
        idempotencyKey: _idempotencyKey,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.purchaseCreated((res['purchase_invoice'] ?? '-').toString()))),
      );
      _resetForm();
      _sheetSetState?.call(() {});
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.purchaseSubmitFailed('$e'))));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
        _sheetSetState?.call(() {});
      }
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
      billNo = '';
      billDate = null;
      // A fresh key per purchase — reusing the previous one would make the
      // *next* genuine purchase look like a retry of the last.
      _idempotencyKey = _newIdempotencyKey();
    });
    _itemSearchController.clear();
    _billNoController.clear();
    _shippingController.text = shippingAmount.toStringAsFixed(2);
    _runItemSearch('');
  }

  /// Sentinel for "don't pay now". Not a real payment mode — the submit path
  /// turns it into `is_paid = 0`, leaving a payable against the supplier.
  static const _creditPaymentOption = '__credit__';

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
              content: SingleChildScrollView(
                child: RadioGroup<String>(
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
                      const Divider(),
                      // Buying on supplier terms. Previously impossible from
                      // the app: is_paid was hardcoded true, so every purchase
                      // had to be settled on the spot.
                      RadioListTile<String>(
                        value: _creditPaymentOption,
                        title: Text(dialogL10n.purchasePaymentCredit),
                        subtitle: Text(dialogL10n.purchasePaymentCreditSubtitle),
                        dense: true,
                      ),
                    ],
                  ),
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

  String? _statusFilter;
  String _searchQuery = '';
  Timer? _searchDebounce;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _searchQuery = value;
      _refresh();
    });
  }

  void _setStatus(String? status) {
    setState(() => _statusFilter = status);
    _refresh();
  }

  /// Settle an outstanding (credit) purchase.
  Future<void> _pay(Map<String, dynamic> invoice) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final option = await _pickPaymentAccount();
    if (option == null || !mounted) return;
    try {
      final result = await ref.read(purchaseServiceProvider).payPurchaseInvoice(
            purchaseInvoice: (invoice['name'] ?? '').toString(),
            paymentOption: option,
          );
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.purchasePaid((result['payment_entry'] ?? '-').toString())),
      ));
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.commonErrorWithDetails('$e'))),
      );
    }
  }

  Future<String?> _pickPaymentAccount() async {
    final profiles = ref.read(posNotifierProvider).profiles;
    String selected = profiles.isNotEmpty
        ? (profiles.first['name'] as String)
        : PaymentModes.cashLower;
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          final dialogL10n = ctx.l10n;
          return AlertDialog(
            title: Text(dialogL10n.purchaseSelectPayment),
            content: SingleChildScrollView(
              child: RadioGroup<String>(
                groupValue: selected,
                onChanged: (v) => setStateDialog(() => selected = v ?? selected),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final p in profiles)
                      RadioListTile<String>(
                        value: p['name'] as String,
                        title: Text(p['name'] as String),
                        dense: true,
                      ),
                    RadioListTile<String>(
                      value: 'instapay',
                      title: Text(dialogL10n.purchasePaymentInstapayTitle),
                      dense: true,
                    ),
                    RadioListTile<String>(
                      value: PaymentModes.cashLower,
                      title: Text(dialogL10n.purchasePaymentCashTitle),
                      dense: true,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(dialogL10n.commonCancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, selected),
                child: Text(dialogL10n.commonContinue),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Send goods back to the supplier. Omitting per-line quantities returns the
  /// whole invoice, which is what the confirm dialog does.
  Future<void> _returnInvoice(Map<String, dynamic> invoice) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.purchaseReturnTitle),
        content: TextField(
          controller: reasonController,
          autofocus: true,
          decoration: InputDecoration(labelText: ctx.l10n.purchaseReturnReason),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.purchaseReturnSubmit),
          ),
        ],
      ),
    );
    final reason = reasonController.text;
    reasonController.dispose();
    if (confirmed != true || !mounted) return;

    try {
      final result =
          await ref.read(purchaseServiceProvider).returnPurchaseInvoice(
                purchaseInvoice: (invoice['name'] ?? '').toString(),
                reason: reason,
              );
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.purchaseReturned((result['return_invoice'] ?? '-').toString())),
      ));
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.commonErrorWithDetails('$e'))),
      );
    }
  }

  Future<void> _loadInvoices({bool append = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(purchaseServiceProvider);
      final result = await service.getPurchaseInvoices(
        limit: _pageSize,
        page: _page,
        status: _statusFilter,
        search: _searchQuery,
      );
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
    return Column(
      children: [
        _filterBar(context),
        Expanded(child: _list(context)),
      ],
    );
  }

  /// Search + status filters. The history was previously an unfiltered scroll,
  /// so finding one invoice among months of them meant scrolling to it.
  Widget _filterBar(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search, size: 20),
              hintText: l10n.purchaseHistorySearchHint,
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _searchQuery = '';
                        _refresh();
                      },
                    ),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final entry in <(String?, String)>[
                  (null, l10n.purchaseHistoryFilterAll),
                  ('Unpaid', l10n.purchaseOutstandingLabel),
                  ('Paid', l10n.purchasePaymentCashTitle),
                  ('Overdue', l10n.requestsOverdue),
                  ('Return', l10n.purchaseReturnAction),
                ])
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6),
                    child: ChoiceChip(
                      label: Text(entry.$2),
                      selected: _statusFilter == entry.$1,
                      onSelected: (_) => _setStatus(entry.$1),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context) {
    if (_loading && _invoices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.commonErrorWithDetails(_error.toString()), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _refresh, child: Text(context.l10n.commonRetry)),
          ],
        ),
      );
    }
    if (_invoices.isEmpty) {
      return Center(child: Text(context.l10n.purchaseNoInvoicesYet));
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
              key: ValueKey(_invoices[index]['name']),
              invoice: _invoices[index],
              onReorder: widget.onNavigateToInvoice != null
                  ? () => widget.onNavigateToInvoice!(_invoices[index])
                  : null,
              onPay: () => _pay(_invoices[index]),
              onReturn: () => _returnInvoice(_invoices[index]),
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
  final VoidCallback? onPay;
  final VoidCallback? onReturn;
  const _PurchaseInvoiceCard({
    super.key,
    required this.invoice,
    this.onReorder,
    this.onPay,
    this.onReturn,
  });

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
    final currency = (inv['currency'] ?? '').toString();
    final billNo = (inv['bill_no'] ?? '').toString();
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
                          status.isEmpty && isPaid ? 'Paid' : status,
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
                        // Was a hardcoded '$' on an EGP business. formatCurrency
                        // resolves the symbol from the invoice currency and the
                        // active locale (EGP / ج.م).
                        formatCurrency(context, grandTotal,
                            currencyCode: currency),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.green),
                      ),
                      if (outstanding > 0.01) ...[
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            '${context.l10n.purchaseOutstandingLabel}: '
                            '${formatCurrency(context, outstanding, currencyCode: currency)}',
                            style: TextStyle(fontSize: 12, color: Colors.red[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(context.l10n.purchaseItemsInvoiceCount(items.length),
                          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
                  if (billNo.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.description_outlined,
                            size: 13, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${context.l10n.purchaseBillNoLabel} $billNo',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      // Settling a credit purchase later — the counterpart to
                      // the "on account" payment option.
                      if (outstanding > 0.01 && widget.onPay != null)
                        OutlinedButton.icon(
                          onPressed: widget.onPay,
                          icon: const Icon(Icons.payments_outlined, size: 16),
                          label: Text(context.l10n.purchasePayNow),
                        ),
                      if (widget.onReturn != null)
                        OutlinedButton.icon(
                          onPressed: widget.onReturn,
                          icon: const Icon(Icons.assignment_return_outlined,
                              size: 16),
                          label: Text(context.l10n.purchaseReturnAction),
                        ),
                      if (widget.onReorder != null)
                        OutlinedButton.icon(
                          onPressed: widget.onReorder,
                          icon: const Icon(Icons.replay, size: 16),
                          label: Text(context.l10n.purchaseReorderFromSupplier),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.indigo,
                            side: const BorderSide(color: Colors.indigo),
                          ),
                        ),
                    ],
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
