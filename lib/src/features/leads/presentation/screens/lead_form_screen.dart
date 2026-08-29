import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../b2b/data/b2b_repository.dart' show b2bLeadSourcesProvider;
import '../../../b2b/state/b2b_pipeline_notifier.dart' show b2bPipelineProvider;
import '../../../pos/presentation/widgets/customer_search_widget.dart'
    show territoriesProvider;
import '../../data/leads_repository.dart';
import '../../data/models/lead.dart';
import '../../state/lead_categories_notifier.dart';
import '../../state/leads_notifier.dart';
import '../leads_theme.dart';
import '../../../../core/utils/territory_label.dart';

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
  int? _score;
  bool _isSpecialty = false;
  bool _saving = false;

  // B2B CRM fields (shared with the former quick-add form).
  String? _source;
  String? _territory;

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
      'email': TextEditingController(text: ''),
      'website': TextEditingController(text: e?.website ?? ''),
      'instagram': TextEditingController(text: e?.instagram ?? ''),
      'facebook': TextEditingController(text: e?.facebook ?? ''),
      'primary_area': TextEditingController(text: e?.primaryArea ?? ''),
    };
    _category = e?.category;
    _tier = e?.tier.isNotEmpty == true ? e!.tier : 'B';
    _priceBand = e?.priceBand ?? '';
    // Null-safe: `score` defaults to 0 in the model. Treat a 0 on a brand-new
    // form as "unset" so we don't force a zero score, but preserve an existing
    // lead's score when editing.
    _score = (e != null && e.score > 0) ? e.score : null;
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
        if (_score != null) 'score': _score,
        'email_id': _c['email']!.text.trim(),
        if (_source != null && _source!.isNotEmpty) 'source': _source,
        if (_territory != null && _territory!.isNotEmpty) 'territory': _territory,
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

      // Refresh BOTH catalogs so the new lead shows everywhere it is listed:
      // the Leads research list and the B2B pipeline board. Each refresh is
      // guarded so an environment where one provider is not initialised (or the
      // caller lacks access to it) never breaks the save flow.
      try {
        await ref.read(leadsProvider.notifier).refresh();
      } catch (_) {
        // Leads catalog not available in this context; ignore.
      }
      try {
        await ref.read(b2bPipelineProvider.notifier).refresh();
      } catch (_) {
        // B2B pipeline not available in this context; ignore.
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.leadFormSaved)),
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
                content: Text(context.l10n.leadDetailFailed('$e'))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addCategory() async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.leadFormNewCategory),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration:
              InputDecoration(labelText: l10n.leadFormCategoryName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(l10n.commonAdd),
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
            .showSnackBar(SnackBar(
                content: Text(context.l10n.leadDetailFailed('$e'))));
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
          isEdit ? context.l10n.leadFormEditTitle : context.l10n.leadsAddLead,
          style: LeadsTheme.heading.copyWith(fontSize: 22),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _card(context.l10n.leadFormCardBrand, [
              _grid([
                _Field.full(_text(
                    'lead_name', context.l10n.leadFormLeadName,
                    required: true)),
                _Field.half(
                    _text('company_name', context.l10n.leadFormCompanyName)),
                _Field.half(_CategoryField(
                  categoriesAsync: categoriesAsync,
                  value: _category,
                  onChanged: (v) => setState(() => _category = v),
                  onAddNew: _addCategory,
                )),
              ]),
            ]),
            const SizedBox(height: 16),
            _card(context.l10n.leadFormCardClassification, [
              _grid([
                _Field.half(_dropdown(
                  label: context.l10n.leadFormTier,
                  value: _tier,
                  items: _tiers,
                  onChanged: (v) => setState(() => _tier = v ?? 'B'),
                )),
                _Field.half(_priceBandField()),
                _Field.half(_sourceField()),
                _Field.half(_territoryField()),
                _Field.half(
                    _text('primary_area', context.l10n.leadFormPrimaryArea)),
                _Field.half(_scoreField()),
                _Field.full(SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeThumbColor: LeadsTheme.berryPink,
                  title: Text(context.l10n.leadFormSpecialty,
                      style: LeadsTheme.body),
                  value: _isSpecialty,
                  onChanged: (v) => setState(() => _isSpecialty = v),
                )),
              ]),
            ]),
            const SizedBox(height: 16),
            _card(context.l10n.leadFormCardContact, [
              _grid([
                _Field.half(_text(
                  'email',
                  context.l10n.leadFieldEmail,
                  keyboard: TextInputType.emailAddress,
                )),
                _Field.half(_text('phone', context.l10n.leadFieldPhone,
                    keyboard: TextInputType.phone)),
                _Field.half(_text('mobile', context.l10n.leadFieldMobile,
                    keyboard: TextInputType.phone)),
                _Field.half(_text('website', context.l10n.leadFieldWebsite)),
                _Field.half(
                    _text('instagram', context.l10n.leadFieldInstagram)),
                _Field.half(
                    _text('facebook', context.l10n.leadFieldFacebook)),
              ]),
            ]),
            const SizedBox(height: 16),
            _card(context.l10n.leadDetailPrimaryAddress,
                _addressFields(_primary)),
            const SizedBox(height: 16),
            _card(context.l10n.leadDetailShippingAddress,
                _addressFields(_shipping)),
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
              label: Text(isEdit
                  ? context.l10n.leadFormSaveChanges
                  : context.l10n.leadFormCreate),
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
        _grid([
          _Field.full(
              _addrField(src, 'line1', context.l10n.leadFieldAddressLine1)),
          _Field.full(
              _addrField(src, 'line2', context.l10n.leadFieldAddressLine2)),
          _Field.half(_addrField(src, 'city', context.l10n.leadFieldCity)),
          _Field.half(_addrField(src, 'state', context.l10n.leadFieldState)),
          _Field.half(
              _addrField(src, 'country', context.l10n.leadFieldCountry)),
          _Field.half(
              _addrField(src, 'pincode', context.l10n.leadFieldPincode)),
          _Field.half(_addrField(src, 'phone', context.l10n.leadFieldPhone,
              keyboard: TextInputType.phone)),
        ]),
      ];

  /// Responsive grid: two columns when the available width is comfortable
  /// (tablets / landscape), one column on narrow phones. Full-span fields
  /// always take the whole row. Spacing is owned here so field builders stay
  /// padding-free. RTL-safe: `Wrap` follows the ambient text direction.
  Widget _grid(List<_Field> fields) {
    const spacing = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final twoCol = maxW >= 560;
        // floorToDouble guards against sub-pixel rounding pushing a pair onto
        // a second run (which would look like an overflow-driven wrap).
        final halfW =
            twoCol ? ((maxW - spacing) / 2).floorToDouble() : maxW;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final f in fields)
              SizedBox(
                width: f.span == _Span.full ? maxW : halfW,
                child: f.child,
              ),
          ],
        );
      },
    );
  }

  Widget _priceBandField() => TextFormField(
        initialValue: _priceBand,
        style: LeadsTheme.body,
        decoration: _dec(context.l10n.leadFormPriceBand),
        onChanged: (v) => _priceBand = v,
      );

  Widget _scoreField() => TextFormField(
        initialValue: _score?.toString() ?? '',
        style: LeadsTheme.body,
        keyboardType: TextInputType.number,
        decoration: _dec(
            context.l10n.leadFormFitScoreRange(context.l10n.leadFitScore)),
        validator: (v) {
          final text = v?.trim() ?? '';
          if (text.isEmpty) return null; // optional
          final n = int.tryParse(text);
          if (n == null || n < 0 || n > 100) {
            return context.l10n.leadFormScoreRangeError;
          }
          return null;
        },
        onChanged: (v) {
          final text = v.trim();
          _score = text.isEmpty ? null : int.tryParse(text);
        },
      );

  Widget _addrField(
    Map<String, TextEditingController> src,
    String key,
    String label, {
    TextInputType? keyboard,
  }) =>
      TextField(
        controller: src[key],
        keyboardType: keyboard,
        style: LeadsTheme.body,
        decoration: _dec(label),
      );

  Widget _text(
    String key,
    String label, {
    bool required = false,
    TextInputType? keyboard,
  }) {
    return TextFormField(
      controller: _c[key],
      keyboardType: keyboard,
      style: LeadsTheme.body,
      decoration: _dec(label),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty)
              ? context.l10n.leadFormRequired
              : null
          : null,
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
      isExpanded: true,
      decoration: _dec(label),
      style: LeadsTheme.body,
      items: [
        for (final item in items)
          DropdownMenuItem(value: item, child: Text(item)),
      ],
      onChanged: onChanged,
    );
  }

  /// Lead Source dropdown fed by the shared [b2bLeadSourcesProvider]. Optional.
  Widget _sourceField() {
    final label = context.l10n.leadFieldSource;
    final sourcesAsync = ref.watch(b2bLeadSourcesProvider);
    return sourcesAsync.when(
      data: (sources) => DropdownButtonFormField<String>(
        initialValue: sources.contains(_source) ? _source : null,
        isExpanded: true,
        decoration: _dec(label),
        style: LeadsTheme.body,
        items: [
          for (final s in sources)
            DropdownMenuItem<String>(
              value: s,
              child: Text(localizedLeadSource(context, s)),
            ),
        ],
        onChanged: (v) => setState(() => _source = v),
      ),
      loading: () => _loadingField(label),
      error: (_, _) => _loadingField(label, spinner: false),
    );
  }

  /// Territory dropdown fed by the shared [territoriesProvider]. Optional.
  Widget _territoryField() {
    final label = context.l10n.leadFieldTerritory;
    final territoriesAsync = ref.watch(territoriesProvider(null));
    return territoriesAsync.when(
      data: (territories) {
        final names = territories
            .map((t) => t['name']?.toString() ?? '')
            .toSet();
        return DropdownButtonFormField<String>(
          initialValue: names.contains(_territory) ? _territory : null,
          isExpanded: true,
          menuMaxHeight: 320,
          decoration: _dec(label),
          style: LeadsTheme.body,
          items: territories.map<DropdownMenuItem<String>>((territory) {
            final name = territory['name']?.toString() ?? '';
            final text = territoryLabelOf(territory);
            return DropdownMenuItem<String>(
              value: name,
              child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (v) => setState(() => _territory = v),
        );
      },
      loading: () => _loadingField(label),
      error: (_, _) => _loadingField(label, spinner: false),
    );
  }

  /// Disabled placeholder shown while a dropdown's options load (or fail).
  Widget _loadingField(String label, {bool spinner = true}) => InputDecorator(
        decoration: _dec(label),
        child: spinner
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const SizedBox(height: 18),
      );

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

/// Column span for a field inside [_LeadFormScreenState._grid].
enum _Span { full, half }

/// A single grid cell: its widget plus how many columns it should occupy.
class _Field {
  const _Field.full(this.child) : span = _Span.full;
  const _Field.half(this.child) : span = _Span.half;

  final Widget child;
  final _Span span;
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
                labelText: context.l10n.leadFormCategoryLabel,
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: LeadsTheme.body,
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(context.l10n.leadDetailCategoryNone),
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
            tooltip: context.l10n.leadFormAddCategory,
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
