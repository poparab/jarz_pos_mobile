import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/lead.dart';
import '../../state/lead_categories_notifier.dart';
import '../../state/lead_detail_notifier.dart';
import '../leads_theme.dart';
import '../widgets/lead_actions.dart';
import '../widgets/sahel_badge.dart';
import '../widgets/score_bar.dart';
import '../widgets/tier_pill.dart';

/// Full detail view for a single lead: brand header + contacts, branches list,
/// and editable status / notes / category + primary/shipping addresses.
class LeadDetailScreen extends ConsumerWidget {
  const LeadDetailScreen({super.key, required this.leadName});

  final String leadName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(leadDetailProvider(leadName));

    return Scaffold(
      backgroundColor: LeadsTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: LeadsTheme.deepPlum,
        elevation: 0,
        title: Text('Lead', style: LeadsTheme.heading.copyWith(fontSize: 22)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: LeadsTheme.muted),
                const SizedBox(height: 12),
                Text('$err',
                    textAlign: TextAlign.center, style: LeadsTheme.bodyMuted),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.read(leadDetailProvider(leadName).notifier).refresh(),
                  style: FilledButton.styleFrom(
                      backgroundColor: LeadsTheme.berryPink),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (lead) => _DetailBody(lead: lead, leadName: leadName),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.lead, required this.leadName});

  final Lead lead;
  final String leadName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _Header(lead: lead),
        const SizedBox(height: 16),
        _ContactRow(lead: lead),
        const SizedBox(height: 20),
        _EditableSection(lead: lead, leadName: leadName),
        const SizedBox(height: 20),
        _AddressesSection(lead: lead, leadName: leadName),
        const SizedBox(height: 20),
        if (lead.branches.isNotEmpty) ...[
          Text('Branches (${lead.branches.length})', style: LeadsTheme.heading),
          const SizedBox(height: 8),
          for (final branch in lead.branches) _BranchTile(branch: branch),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.lead});

  final Lead lead;

  @override
  Widget build(BuildContext context) {
    final nameRtl = LeadsTheme.isArabic(lead.leadName);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LeadsTheme.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScoreBar(lead.score, width: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Directionality(
                  textDirection:
                      nameRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: Text(
                    lead.leadName.isEmpty ? lead.name : lead.leadName,
                    style: LeadsTheme.nameStyle(lead.leadName, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TierPill(lead.tier),
                    if (lead.sahelBranches > 0) SahelBadge(lead.sahelBranches),
                    if (lead.avgRating != null)
                      _Pill(
                        icon: Icons.star_rounded,
                        iconColor: LeadsTheme.gold,
                        text:
                            '${lead.avgRating!.toStringAsFixed(1)} (${lead.totalReviews})',
                      ),
                    if (lead.priceBand.isNotEmpty)
                      _Pill(icon: Icons.sell_outlined, text: lead.priceBand),
                    if (lead.primaryArea.isNotEmpty)
                      _Pill(
                          icon: Icons.place_outlined, text: lead.primaryArea),
                    if (lead.category != null && lead.category!.isNotEmpty)
                      _Pill(icon: Icons.category_outlined, text: lead.category!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.lead});

  final Lead lead;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ContactAction(
          icon: Icons.call,
          label: 'Call',
          enabled: lead.phone.trim().isNotEmpty,
          onTap: () => LeadActions.call(lead.phone),
        ),
        _ContactAction(
          icon: Icons.camera_alt_outlined,
          label: 'Instagram',
          color: LeadsTheme.berryPink,
          enabled: lead.instagram.trim().isNotEmpty,
          onTap: () => LeadActions.instagram(lead.instagram),
        ),
        _ContactAction(
          icon: Icons.language,
          label: 'Website',
          enabled: lead.website.trim().isNotEmpty,
          onTap: () => LeadActions.website(lead.website),
        ),
        _ContactAction(
          icon: Icons.map_outlined,
          label: 'Map',
          enabled: lead.mapsUrl.trim().isNotEmpty ||
              (lead.latitude != null && lead.longitude != null),
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
}

class _ContactAction extends StatelessWidget {
  const _ContactAction({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.color = LeadsTheme.deepPlum,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: enabled ? color : LeadsTheme.line),
            const SizedBox(height: 4),
            Text(
              label,
              style: LeadsTheme.bodyMuted.copyWith(
                color: enabled ? LeadsTheme.muted : LeadsTheme.line,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Editable status / notes / category, saved back through the repository.
class _EditableSection extends ConsumerStatefulWidget {
  const _EditableSection({required this.lead, required this.leadName});

  final Lead lead;
  final String leadName;

  @override
  ConsumerState<_EditableSection> createState() => _EditableSectionState();
}

class _EditableSectionState extends ConsumerState<_EditableSection> {
  late final TextEditingController _statusController;
  late final TextEditingController _notesController;
  String? _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _statusController = TextEditingController(text: widget.lead.status);
    _notesController = TextEditingController(text: widget.lead.notes);
    _category = widget.lead.category;
  }

  @override
  void dispose() {
    _statusController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(leadDetailProvider(widget.leadName).notifier).save({
        'status': _statusController.text.trim(),
        'notes': _notesController.text.trim(),
        if (_category != null) 'category': _category,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lead updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(leadCategoriesProvider);
    return _SectionCard(
      title: 'Status & notes',
      children: [
        TextField(
          controller: _statusController,
          style: LeadsTheme.body,
          decoration: _dec('Status'),
        ),
        const SizedBox(height: 12),
        categoriesAsync.maybeWhen(
          data: (categories) => DropdownButtonFormField<String?>(
            initialValue: categories.any((c) => c.name == _category)
                ? _category
                : null,
            isExpanded: true,
            decoration: _dec('Category'),
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
            onChanged: (value) => setState(() => _category = value),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          style: LeadsTheme.body,
          maxLines: 4,
          decoration: _dec('Notes'),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save'),
            style:
                FilledButton.styleFrom(backgroundColor: LeadsTheme.berryPink),
          ),
        ),
      ],
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      );
}

/// Primary + shipping address editors.
class _AddressesSection extends ConsumerWidget {
  const _AddressesSection({required this.lead, required this.leadName});

  final Lead lead;
  final String leadName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
      title: 'Addresses',
      children: [
        _AddressEditor(
          kind: 'primary',
          title: 'Primary address',
          leadName: leadName,
          address: lead.primaryAddress,
        ),
        const Divider(height: 24, color: LeadsTheme.line),
        _AddressEditor(
          kind: 'shipping',
          title: 'Shipping address',
          leadName: leadName,
          address: lead.shippingAddress,
        ),
      ],
    );
  }
}

class _AddressEditor extends ConsumerStatefulWidget {
  const _AddressEditor({
    required this.kind,
    required this.title,
    required this.leadName,
    required this.address,
  });

  final String kind;
  final String title;
  final String leadName;
  final LeadAddress? address;

  @override
  ConsumerState<_AddressEditor> createState() => _AddressEditorState();
}

class _AddressEditorState extends ConsumerState<_AddressEditor> {
  late final Map<String, TextEditingController> _controllers;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _controllers = {
      'line1': TextEditingController(text: a?.addressLine1 ?? ''),
      'line2': TextEditingController(text: a?.addressLine2 ?? ''),
      'city': TextEditingController(text: a?.city ?? ''),
      'state': TextEditingController(text: a?.state ?? ''),
      'country': TextEditingController(text: a?.country ?? ''),
      'pincode': TextEditingController(text: a?.pincode ?? ''),
      'phone': TextEditingController(text: a?.phone ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final address = LeadAddress(
        name: widget.address?.name,
        addressLine1: _controllers['line1']!.text.trim(),
        addressLine2: _controllers['line2']!.text.trim(),
        city: _controllers['city']!.text.trim(),
        state: _controllers['state']!.text.trim(),
        country: _controllers['country']!.text.trim(),
        pincode: _controllers['pincode']!.text.trim(),
        phone: _controllers['phone']!.text.trim(),
      );
      await ref.read(leadDetailProvider(widget.leadName).notifier).saveAddress(
            kind: widget.kind,
            address: address,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.title} saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title,
            style: LeadsTheme.body.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _field('line1', 'Address line 1'),
        _field('line2', 'Address line 2'),
        Row(
          children: [
            Expanded(child: _field('city', 'City')),
            const SizedBox(width: 8),
            Expanded(child: _field('state', 'State')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _field('country', 'Country')),
            const SizedBox(width: 8),
            Expanded(child: _field('pincode', 'Pincode')),
          ],
        ),
        _field('phone', 'Phone'),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined, size: 16),
            label: Text('Save ${widget.title.toLowerCase()}'),
            style: OutlinedButton.styleFrom(
              foregroundColor: LeadsTheme.deepPlum,
              side: const BorderSide(color: LeadsTheme.line),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(String key, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          controller: _controllers[key],
          style: LeadsTheme.body,
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
}

class _BranchTile extends StatelessWidget {
  const _BranchTile({required this.branch});

  final LeadBranch branch;

  @override
  Widget build(BuildContext context) {
    final locationParts = [
      if (branch.area.isNotEmpty) branch.area,
      if (branch.region.isNotEmpty) branch.region,
      if (branch.governorate.isNotEmpty) branch.governorate,
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
            children: [
              Expanded(
                child: Directionality(
                  textDirection: LeadsTheme.isArabic(branch.branchName)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Text(
                    branch.branchName.isEmpty
                        ? locationParts.join(', ')
                        : branch.branchName,
                    style:
                        LeadsTheme.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (branch.rating != null)
                _Pill(
                  icon: Icons.star_rounded,
                  iconColor: LeadsTheme.gold,
                  text:
                      '${branch.rating!.toStringAsFixed(1)} (${branch.reviews})',
                ),
            ],
          ),
          if (locationParts.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(locationParts.join(' · '), style: LeadsTheme.bodyMuted),
          ],
          if (branch.address.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(branch.address, style: LeadsTheme.bodyMuted),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              if (branch.hours.isNotEmpty)
                Expanded(
                  child: Text(branch.hours, style: LeadsTheme.bodyMuted),
                ),
              if (branch.phone.trim().isNotEmpty)
                TextButton.icon(
                  onPressed: () => LeadActions.call(branch.phone),
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Call'),
                  style: TextButton.styleFrom(
                      foregroundColor: LeadsTheme.deepPlum),
                ),
              if (branch.mapsUrl.trim().isNotEmpty ||
                  (branch.latitude != null && branch.longitude != null))
                TextButton.icon(
                  onPressed: () {
                    if (branch.mapsUrl.trim().isNotEmpty) {
                      LeadActions.maps(branch.mapsUrl);
                    } else {
                      LeadActions.mapsAt(branch.latitude!, branch.longitude!);
                    }
                  },
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text('Map'),
                  style: TextButton.styleFrom(
                      foregroundColor: LeadsTheme.deepPlum),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.text,
    this.iconColor = LeadsTheme.muted,
  });

  final IconData icon;
  final String text;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: LeadsTheme.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: LeadsTheme.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 3),
          Text(
            text,
            style: LeadsTheme.bodyMuted.copyWith(
              fontFeatures: LeadsTheme.tabular,
            ),
          ),
        ],
      ),
    );
  }
}
