import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/labels_repository.dart';
import '../../models/label_models.dart';
import '../../state/labels_notifier.dart'
    show labelErrorMessage, labelsNotifierProvider;

/// The "new customer" flow: pick the customer, tick their flavours off the
/// list the server already knows (price list + order history), say where the
/// labels live, confirm — and every design is tracked in one pass.
///
/// One screen with steps, not four routes: the wizard holds all its state, and
/// re-running it for an existing customer is additive (already-tracked
/// flavours are disabled here and skipped server-side).
class LabelSetupWizardScreen extends ConsumerStatefulWidget {
  /// Pre-selected customer (the "Add flavour" path); the wizard opens on the
  /// flavour step when set.
  final String? initialCustomer;
  final String? initialCustomerName;

  const LabelSetupWizardScreen({
    super.key,
    this.initialCustomer,
    this.initialCustomerName,
  });

  @override
  ConsumerState<LabelSetupWizardScreen> createState() =>
      _LabelSetupWizardScreenState();
}

class _LabelSetupWizardScreenState
    extends ConsumerState<LabelSetupWizardScreen> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  int _step = 0;
  bool _submitting = false;

  // Step 1: customer
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<LabelCustomerOption> _results = const [];
  LabelCustomerOption? _customer;
  bool _searching = false;

  // Step 2: flavours
  LabelFlavourOptions? _options;
  bool _loadingFlavours = false;
  String? _flavourError;
  final Set<String> _picked = <String>{};
  final Map<String, TextEditingController> _openingQty = {};

  // Step 3: location + batch
  String? _location;
  late final TextEditingController _sheetsController;

  @override
  void initState() {
    super.initState();
    final defaultSheets =
        ref.read(labelsNotifierProvider).settings.defaultPrintSheets;
    _sheetsController = TextEditingController(
      text: '${defaultSheets > 0 ? defaultSheets : 2}',
    );

    final initial = widget.initialCustomer?.trim();
    if (initial != null && initial.isNotEmpty) {
      _customer = LabelCustomerOption(
        customer: initial,
        customerName: widget.initialCustomerName?.trim().isNotEmpty == true
            ? widget.initialCustomerName!.trim()
            : initial,
        customerGroup: null,
        defaultPriceList: null,
        labelCount: 0,
      );
      _step = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadFlavours();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _search('');
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _sheetsController.dispose();
    for (final controller in _openingQty.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // ── Customer search ────────────────────────────────────────────────────
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);
    try {
      final results =
          await ref.read(labelsRepositoryProvider).searchCustomers(query);
      if (mounted) setState(() => _results = results);
    } catch (_) {
      if (mounted) setState(() => _results = const []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _selectCustomer(LabelCustomerOption option) {
    setState(() {
      _customer = option;
      _options = null;
      _picked.clear();
      _flavourError = null;
    });
    _loadFlavours();
  }

  // ── Flavours ───────────────────────────────────────────────────────────
  Future<void> _loadFlavours() async {
    final customer = _customer;
    if (customer == null) return;
    setState(() {
      _loadingFlavours = true;
      _flavourError = null;
    });
    try {
      final options = await ref
          .read(labelsRepositoryProvider)
          .getFlavourOptions(customer.customer);
      if (mounted) setState(() => _options = options);
    } catch (error) {
      if (mounted) setState(() => _flavourError = labelErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loadingFlavours = false);
    }
  }

  TextEditingController _openingControllerFor(String itemCode) {
    return _openingQty.putIfAbsent(
      itemCode,
      () => TextEditingController(text: '0'),
    );
  }

  // ── Submit ─────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    final customer = _customer;
    if (customer == null || _picked.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      final result =
          await ref.read(labelsRepositoryProvider).setupCustomerLabels(
                customer: customer.customer,
                flavours: [
                  for (final itemCode in _picked)
                    LabelSetupFlavour(
                      itemCode: itemCode,
                      openingQty: int.tryParse(
                              _openingQty[itemCode]?.text.trim() ?? '') ??
                          0,
                    ),
                ],
                storageLocation: _location,
                defaultPrintSheets:
                    int.tryParse(_sheetsController.text.trim()) ?? 0,
              );
      if (!mounted) return;
      context.pop(result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(labelErrorMessage(error))),
      );
    }
  }

  // ── Steps ──────────────────────────────────────────────────────────────
  bool get _stepValid {
    switch (_step) {
      case 0:
        return _customer != null;
      case 1:
        return _picked.isNotEmpty;
      default:
        return true;
    }
  }

  void _continue() {
    if (_step < 3) {
      setState(() => _step += 1);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step -= 1);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Set up customer labels')),
        body: Stepper(
          currentStep: _step,
          onStepContinue: _stepValid && !_submitting ? _continue : null,
          onStepCancel: _step == 0 || _submitting ? null : _back,
          onStepTapped: (index) {
            // Backwards only — jumping forward would skip validation.
            if (index < _step && !_submitting) setState(() => _step = index);
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  FilledButton(
                    onPressed: details.onStepContinue,
                    child: _submitting && _step == 3
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_step == 3 ? 'Start tracking' : 'Continue'),
                  ),
                  const SizedBox(width: 8),
                  if (details.onStepCancel != null)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Customer'),
              subtitle: _customer == null
                  ? null
                  : Text(_customer!.customerName),
              isActive: _step >= 0,
              state: _customer == null ? StepState.indexed : StepState.complete,
              content: _CustomerStep(
                controller: _searchController,
                results: _results,
                selected: _customer,
                searching: _searching,
                onChanged: _onSearchChanged,
                onSelect: _selectCustomer,
                onClear: () => setState(() => _customer = null),
              ),
            ),
            Step(
              title: const Text('Flavours'),
              subtitle: _picked.isEmpty
                  ? null
                  : Text('${_picked.length} picked'),
              isActive: _step >= 1,
              state: _picked.isEmpty ? StepState.indexed : StepState.complete,
              content: _FlavourStep(
                options: _options,
                loading: _loadingFlavours,
                error: _flavourError,
                picked: _picked,
                openingControllerFor: _openingControllerFor,
                onRetry: _loadFlavours,
                onToggle: (itemCode, selected) {
                  setState(() {
                    if (selected) {
                      _picked.add(itemCode);
                    } else {
                      _picked.remove(itemCode);
                    }
                  });
                },
              ),
            ),
            Step(
              title: const Text('Where the labels live'),
              subtitle: _location == null ? null : Text(_location!),
              isActive: _step >= 2,
              content: _LocationStep(
                location: _location,
                sheetsController: _sheetsController,
                onLocationChanged: (value) =>
                    setState(() => _location = value),
              ),
            ),
            Step(
              title: const Text('Confirm'),
              isActive: _step >= 3,
              content: _ConfirmStep(
                customer: _customer,
                priceList: _options?.priceList ?? _customer?.defaultPriceList,
                pickedCount: _picked.length,
                location: _location,
                sheets: int.tryParse(_sheetsController.text.trim()) ?? 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1: customer
// ---------------------------------------------------------------------------
class _CustomerStep extends StatelessWidget {
  final TextEditingController controller;
  final List<LabelCustomerOption> results;
  final LabelCustomerOption? selected;
  final bool searching;
  final ValueChanged<String> onChanged;
  final ValueChanged<LabelCustomerOption> onSelect;
  final VoidCallback onClear;

  const _CustomerStep({
    required this.controller,
    required this.results,
    required this.selected,
    required this.searching,
    required this.onChanged,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chosen = selected;

    if (chosen != null) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.storefront),
        title: Text(chosen.customerName),
        subtitle: Text(
          chosen.defaultPriceList == null
              ? chosen.customer
              : '${chosen.customer} · price list: ${chosen.defaultPriceList}',
        ),
        trailing: TextButton(onPressed: onClear, child: const Text('Change')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Search customers',
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            border: const OutlineInputBorder(),
            suffixIcon: searching
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
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: results.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    searching ? 'Searching…' : 'No company customers matched.',
                    style: theme.textTheme.bodySmall,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final option = results[index];
                    return ListTile(
                      dense: true,
                      title: Text(option.customerName),
                      subtitle: option.defaultPriceList == null
                          ? (option.customerGroup == null
                              ? null
                              : Text(option.customerGroup!))
                          : Text('Price list: ${option.defaultPriceList}'),
                      trailing: option.labelCount > 0
                          ? Chip(
                              label: Text('${option.labelCount}'),
                              visualDensity: VisualDensity.compact,
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: () => onSelect(option),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2: flavours
// ---------------------------------------------------------------------------
class _FlavourStep extends StatelessWidget {
  final LabelFlavourOptions? options;
  final bool loading;
  final String? error;
  final Set<String> picked;
  final TextEditingController Function(String itemCode) openingControllerFor;
  final VoidCallback onRetry;
  final void Function(String itemCode, bool selected) onToggle;

  const _FlavourStep({
    required this.options,
    required this.loading,
    required this.error,
    required this.picked,
    required this.openingControllerFor,
    required this.onRetry,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Could not load flavours.\n$error'),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      );
    }
    final data = options;
    if (data == null) {
      return Text('Pick a customer first.', style: theme.textTheme.bodySmall);
    }
    if (data.flavours.isEmpty) {
      return Text(
        'No flavours found for this customer — nothing on their price list '
        'and no order history yet.',
        style: theme.textTheme.bodyMedium,
      );
    }

    // Group by size, preserving the server's (size, name) order.
    final sizes = <String>[];
    final bySize = <String, List<LabelFlavourOption>>{};
    for (final flavour in data.flavours) {
      final size = flavour.size.isEmpty ? 'Other' : flavour.size;
      if (!bySize.containsKey(size)) {
        sizes.add(size);
        bySize[size] = [];
      }
      bySize[size]!.add(flavour);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tick every flavour whose label JARZ prints. Enter what is already '
          'on the shelf so nothing starts life as Out of Stock.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        for (final size in sizes) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 2),
            child: Text(
              size.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final flavour in bySize[size]!)
            _FlavourTile(
              flavour: flavour,
              selected: picked.contains(flavour.itemCode),
              openingController: picked.contains(flavour.itemCode)
                  ? openingControllerFor(flavour.itemCode)
                  : null,
              onToggle: (value) => onToggle(flavour.itemCode, value),
            ),
        ],
      ],
    );
  }
}

class _FlavourTile extends StatelessWidget {
  final LabelFlavourOption flavour;
  final bool selected;
  final TextEditingController? openingController;
  final ValueChanged<bool> onToggle;

  const _FlavourTile({
    required this.flavour,
    required this.selected,
    required this.openingController,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tracked = flavour.hasLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          value: tracked || selected,
          onChanged: tracked ? null : (value) => onToggle(value ?? false),
          title: Text(
            flavour.itemName,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tracked ? theme.colorScheme.onSurfaceVariant : null,
            ),
          ),
          subtitle: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (tracked)
                const _SourceBadge(text: 'Already tracked', muted: true)
              else ...[
                if (flavour.onPriceList)
                  const _SourceBadge(text: 'On price list'),
                if (flavour.orderedBefore)
                  const _SourceBadge(text: 'Ordered before'),
              ],
            ],
          ),
        ),
        if (selected && !tracked && openingController != null)
          Padding(
            padding: const EdgeInsets.only(left: 44, right: 8, bottom: 8),
            child: TextField(
              controller: openingController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Labels in stock now',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
      ],
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String text;
  final bool muted;

  const _SourceBadge({required this.text, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = muted
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3: location + usual batch
// ---------------------------------------------------------------------------
class _LocationStep extends ConsumerWidget {
  final String? location;
  final TextEditingController sheetsController;
  final ValueChanged<String?> onLocationChanged;

  const _LocationStep({
    required this.location,
    required this.sheetsController,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(labelStorageLocationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        locations.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => Text(
            'Could not load locations — you can set one per label later.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          data: (options) => DropdownButtonFormField<String?>(
            initialValue:
                options.any((o) => o.name == location) ? location : null,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Stored at',
              helperText:
                  'The branch or factory where these labels physically live.',
              helperMaxLines: 2,
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Not set'),
              ),
              ...options.map(
                (option) => DropdownMenuItem<String?>(
                  value: option.name,
                  child: Text(option.label, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            onChanged: onLocationChanged,
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: sheetsController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Usual print batch (sheets)',
            helperText: 'Applied to every flavour; changeable per label later.',
            helperMaxLines: 2,
            isDense: true,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 4: confirm
// ---------------------------------------------------------------------------
class _ConfirmStep extends StatelessWidget {
  final LabelCustomerOption? customer;
  final String? priceList;
  final int pickedCount;
  final String? location;
  final int sheets;

  const _ConfirmStep({
    required this.customer,
    required this.priceList,
    required this.pickedCount,
    required this.location,
    required this.sheets,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <(String, String)>[
      ('Customer', customer?.customerName ?? '—'),
      if (priceList != null) ('Price list', priceList!),
      ('Flavours', '$pickedCount'),
      ('Stored at', location ?? 'Not set'),
      ('Usual batch', '$sheets sheet${sheets == 1 ? '' : 's'}'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    row.$1,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(row.$2, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Flavours already tracked are left untouched — running this again '
          'is always safe.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
