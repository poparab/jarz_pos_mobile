import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/leads_repository.dart';
import '../../data/models/lead.dart';
import '../../state/lead_categories_notifier.dart';
import '../../state/leads_notifier.dart';
import '../leads_theme.dart';

/// Add (or edit) a lead manually. Saves via `save_lead`, then persists any
/// primary/shipping addresses via `set_lead_address`.
class LeadFormScreen extends ConsumerStatefulWidget {
  const LeadFormScreen({super.key, this.existing});

  final Lead? existing;

  @override
  ConsumerState<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends ConsumerState<LeadFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final Map<String, TextEditingController> _c;
  String? _category;
  String _tier = 'B';
  String _priceBand = '';
  bool _isSpecialty = false;
  bool _saving = false;

  // Address sub-forms.
  late final Map<String, TextEditingController> _primary;
  late final Map<String, TextEditingController> _shipping;

  static const _tiers = ['A', 'B', 'C', 'REF'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _c = {
      'lead_name': TextEditingController(text: e?.leadName ?? ''),
      'company_name': TextEditingController(text: e?.sourceBrandId ?? ''),
      'phone': TextEditingController(text: e?.phone ?? ''),
      'mobile': TextEditingController(text: ''),
      'website': TextEditingController(text: e?.website ?? ''),
      'instagram': TextEditingController(text: e?.instagram ?? ''),
      'facebook': TextEditingController(text: e?.facebook ?? ''),
      'primary_area': TextEditingController(text: e?.primaryArea ?? ''),
    };
    _category = e?.category;
    _tier = e?.tier.isNotEmpty == true ? e!.tier : 'B';
    _priceBand = e?.priceBand ?? '';
    _isSpecialty = e?.isSpecialty ?? false;
    _primary = _addressControllers(e?.primaryAddress);
    _shipping = _addressControllers(e?.shippingAddress);
  }

  Map<String, TextEditingController> _addressControllers(LeadAddress? a) => {
        'line1': TextEditingController(text: a?.addressLine1 ?? ''),
        'line2': TextEditingController(text: a?.addressLine2 ?? ''),
        'city': TextEditingController(text: a?.city ?? ''),
        'state': TextEditingController(text: a?.state ?? ''),
        'country': TextEditingController(text: a?.country ?? ''),
        'pincode': TextEditingController(text: a?.pincode ?? ''),
        'phone': TextEditingController(text: a?.phone ?? ''),
      };

  @override
  void dispose() {
    for (final c in [..._c.values, ..._primary.values, ..._shipping.values]) {
      c.dispose();
    }
    super.dispose();
  }

  LeadAddress? _buildAddress(Map<String, TextEditingController> src) {
    final line1 = src['line1']!.text.trim();
    final city = src['city']!.text.trim();
    // Only submit an address if at least a line or city is provided.
    if (line1.isEmpty && city.isEmpty) return null;
    return LeadAddress(
      addressLine1: line1,
      addressLine2: src['line2']!.text.trim(),
      city: city,
      state: src['state']!.text.trim(),
      country: src['country']!.text.trim(),
      pincode: src['pincode']!.text.trim(),
      phone: src['phone']!.text.trim(),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(leadsRepositoryProvider);
    try {
      final payload = <String, dynamic>{
        'lead_name': _c['lead_name']!.text.trim(),
        'company_name': _c['company_name']!.text.trim(),
        if (_category != null) 'category': _category,
        'tier': _tier,
        'price_band': _priceBand,
        'phone': _c['phone']!.text.trim(),
        'mobile_no': _c['mobile']!.text.trim(),
        'website': _c['website']!.text.trim(),
        'instagram': _c['instagram']!.text.trim(),
        'facebook': _c['facebook']!.text.trim(),
        'primary_area': _c['primary_area']!.text.trim(),
        'is_specialty': _isSpecialty,
      };
      final name = await repo.saveLead(payload, name: widget.existing?.name);

      final primary = _buildAddress(_primary);
      if (primary != null) {
        await repo.setLeadAddress(
            name: name, kind: 'primary', address: primary);
      }
      final shipping = _buildAddress(_shipping);
      if (shipping != null) {
        await repo.setLeadAddress(
            name: name, kind: 'shipping', address: shipping);
      }

      // Refresh the catalog so the new lead appears in the list.
      await ref.read(leadsProvider.notifier).refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead saved')),
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    try {
      final created = await ref
          .read(leadCategoriesProvider.notifier)
          .add(categoryName: name);
      if (mounted) setState(() => _category = created.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(leadCategoriesProvider);
    final isEdit = widget.existing != null;
    return Scaffold(
      backgroundColor: LeadsTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: LeadsTheme.deepPlum,
        elevation: 0,
        title: Text(
          isEdit ? 'Edit lead' : 'Add lead',
          style: LeadsTheme.heading.copyWith(fontSize: 22),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _card('Brand', [
              _text('lead_name', 'Lead name *', required: true),
              _text('company_name', 'Company name'),
              _CategoryField(
                categoriesAsync: categoriesAsync,
                value: _category,
                onChanged: (v) => setState(() => _category = v),
                onAddNew: _addCategory,
              ),
              const SizedBox(height: 12),
              _dropdown(
                label: 'Tier',
                value: _tier,
                items: _tiers,
                onChanged: (v) => setState(() => _tier = v ?? 'B'),
              ),
              const SizedBox(height: 12),
              _text('primary_area', 'Primary area'),
              TextFormField(
                initialValue: _priceBand,
                style: LeadsTheme.body,
                decoration: _dec('Price band'),
                onChanged: (v) => _priceBand = v,
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeThumbColor: LeadsTheme.berryPink,
                title: const Text('Specialty', style: LeadsTheme.body),
                value: _isSpecialty,
                onChanged: (v) => setState(() => _isSpecialty = v),
              ),
            ]),
            const SizedBox(height: 16),
            _card('Contact', [
              _text('phone', 'Phone', keyboard: TextInputType.phone),
              _text('mobile', 'Mobile', keyboard: TextInputType.phone),
              _text('website', 'Website'),
              _text('instagram', 'Instagram'),
              _text('facebook', 'Facebook'),
            ]),
            const SizedBox(height: 16),
            _card('Primary address', _addressFields(_primary)),
            const SizedBox(height: 16),
            _card('Shipping address', _addressFields(_shipping)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(isEdit ? 'Save changes' : 'Create lead'),
              style: FilledButton.styleFrom(
                backgroundColor: LeadsTheme.berryPink,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _addressFields(Map<String, TextEditingController> src) => [
        _addrField(src, 'line1', 'Address line 1'),
        _addrField(src, 'line2', 'Address line 2'),
        Row(
          children: [
            Expanded(child: _addrField(src, 'city', 'City')),
            const SizedBox(width: 8),
            Expanded(child: _addrField(src, 'state', 'State')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _addrField(src, 'country', 'Country')),
            const SizedBox(width: 8),
            Expanded(child: _addrField(src, 'pincode', 'Pincode')),
          ],
        ),
        _addrField(src, 'phone', 'Phone', keyboard: TextInputType.phone),
      ];

  Widget _addrField(
    Map<String, TextEditingController> src,
    String key,
    String label, {
    TextInputType? keyboard,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          controller: src[key],
          keyboardType: keyboard,
          style: LeadsTheme.body,
          decoration: _dec(label),
        ),
      );

  Widget _text(
    String key,
    String label, {
    bool required = false,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: _c[key],
        keyboardType: keyboard,
        style: LeadsTheme.body,
        decoration: _dec(label),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: _dec(label),
      style: LeadsTheme.body,
      items: [
        for (final item in items)
          DropdownMenuItem(value: item, child: Text(item)),
      ],
      onChanged: onChanged,
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LeadsTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: LeadsTheme.heading.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      );
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.categoriesAsync,
    required this.value,
    required this.onChanged,
    required this.onAddNew,
  });

  final AsyncValue<List<LeadCategory>> categoriesAsync;
  final String? value;
  final ValueChanged<String?> onChanged;
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context) {
    return categoriesAsync.maybeWhen(
      data: (categories) => Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String?>(
              initialValue:
                  categories.any((c) => c.name == value) ? value : null,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Category',
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: LeadsTheme.body,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('None'),
                ),
                for (final cat in categories)
                  DropdownMenuItem<String?>(
                    value: cat.name,
                    child: Text(cat.categoryName.isEmpty
                        ? cat.name
                        : cat.categoryName),
                  ),
              ],
              onChanged: onChanged,
            ),
          ),
          IconButton(
            tooltip: 'Add category',
            icon: const Icon(Icons.add_circle_outline,
                color: LeadsTheme.berryPink),
            onPressed: onAddNew,
          ),
        ],
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
