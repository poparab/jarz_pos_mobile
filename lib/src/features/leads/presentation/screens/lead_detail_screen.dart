import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../b2b/data/b2b_repository.dart' show b2bRepositoryProvider;
import '../../../b2b/presentation/widgets/b2b_stage_chip.dart'
    show B2bStageChip, kB2bStages, kDefaultB2bStage;
import '../../../b2b/state/b2b_pipeline_notifier.dart' show b2bPipelineProvider;
import '../../data/models/lead.dart';
import '../../state/lead_categories_notifier.dart';
import '../../state/lead_detail_notifier.dart';
import '../../state/leads_notifier.dart' show leadsProvider;
import '../../state/not_suitable_reasons_notifier.dart';
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
        if (lead.notSuitable) ...[
          const SizedBox(height: 12),
          _NotSuitableBanner(lead: lead),
        ],
        const SizedBox(height: 16),
        _ContactRow(lead: lead),
        const SizedBox(height: 20),
        _EditableSection(lead: lead, leadName: leadName),
        const SizedBox(height: 20),
        _FitScoreSection(lead: lead, leadName: leadName),
        const SizedBox(height: 20),
        _B2bStageSection(lead: lead, leadName: leadName),
        const SizedBox(height: 20),
        _SuitabilitySection(lead: lead, leadName: leadName),
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

/// Editable fit score (0–100). Saved back through the detail notifier's
/// `save({'score': ...})`, which routes to `save_lead` → `custom_fit_score`.
/// A slider keeps the control compact and consistent with the other editors;
/// on save it refreshes the detail + Leads catalog (via the notifier) and,
/// guardedly, the B2B pipeline board so every surface reflects the new score.
class _FitScoreSection extends ConsumerStatefulWidget {
  const _FitScoreSection({required this.lead, required this.leadName});

  final Lead lead;
  final String leadName;

  @override
  ConsumerState<_FitScoreSection> createState() => _FitScoreSectionState();
}

class _FitScoreSectionState extends ConsumerState<_FitScoreSection> {
  late int _score;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Null/'' safe: `score` defaults to 0 in the model, but clamp defensively
    // so a missing or out-of-range value never breaks the slider.
    _score = widget.lead.score.clamp(0, 100);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(leadDetailProvider(widget.leadName).notifier)
          .save({'score': _score});

      // The notifier's save() already refreshes this detail and the Leads
      // catalog. Guardedly keep the B2B pipeline board in sync too so a fit
      // score edit is reflected wherever the lead is shown.
      try {
        await ref.read(b2bPipelineProvider.notifier).refresh();
      } catch (_) {
        // B2B pipeline not available in this context; ignore.
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fit score updated')),
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
    return _SectionCard(
      title: context.l10n.leadFitScore,
      children: [
        Row(
          children: [
            ScoreBar(_score, width: 44),
            const SizedBox(width: 12),
            Text(
              '$_score / 100',
              style: LeadsTheme.body.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: LeadsTheme.tabular,
              ),
            ),
          ],
        ),
        Slider(
          value: _score.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          label: '$_score',
          activeColor: LeadsTheme.berryPink,
          onChanged: _saving
              ? null
              : (v) => setState(() => _score = v.round()),
        ),
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
}

/// Editable B2B pipeline stage. Setting it here keeps the Leads detail in sync
/// with the B2B kanban: it calls the shared `advance_stage` endpoint (via
/// [b2bRepositoryProvider]) and then refreshes the detail, the Leads catalog,
/// and the B2B pipeline board so every surface reflects the new stage.
class _B2bStageSection extends ConsumerStatefulWidget {
  const _B2bStageSection({required this.lead, required this.leadName});

  final Lead lead;
  final String leadName;

  @override
  ConsumerState<_B2bStageSection> createState() => _B2bStageSectionState();
}

class _B2bStageSectionState extends ConsumerState<_B2bStageSection> {
  bool _saving = false;

  /// The lead's effective stage: an empty backend value is treated as the
  /// initial `Lead` stage.
  String get _currentStage {
    final raw = widget.lead.b2bStage.trim();
    return raw.isEmpty ? kDefaultB2bStage : raw;
  }

  Future<void> _onSelect(String stage) async {
    if (stage == _currentStage) return;

    String? reason;
    if (stage == 'Lost/On-hold') {
      reason = await _promptReason();
      if (reason == null) return; // cancelled
    }

    setState(() => _saving = true);
    try {
      await ref.read(b2bRepositoryProvider).advanceStage(
            doctype: 'Lead',
            name: widget.lead.name,
            stage: stage,
            reason: reason,
          );

      // Re-fetch this lead so the control reflects the server-confirmed stage.
      await ref.read(leadDetailProvider(widget.leadName).notifier).refresh();

      // Guardedly keep the Leads list and the B2B kanban in sync. Each refresh
      // is wrapped so a context where one provider is not initialised (or the
      // caller lacks access to it) never breaks the update flow.
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stage updated to $stage')),
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

  Future<String?> _promptReason() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reason'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Why is this lost / on hold?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentStage;
    // Only preselect a value the dropdown knows about; an unknown/legacy stage
    // renders the chip but leaves the dropdown unselected (no crash).
    final selected = kB2bStages.contains(current) ? current : null;
    return _SectionCard(
      title: context.l10n.leadB2bStage,
      children: [
        Row(
          children: [
            B2bStageChip(stage: current),
            const Spacer(),
            if (_saving)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: selected,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: context.l10n.leadB2bStage,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          style: LeadsTheme.body,
          items: [
            for (final stage in kB2bStages)
              DropdownMenuItem<String>(value: stage, child: Text(stage)),
          ],
          onChanged: _saving
              ? null
              : (value) {
                  if (value != null) _onSelect(value);
                },
        ),
      ],
    );
  }
}

/// Read-only summary of an active "not suitable" verdict, shown directly under
/// the header so a rep opening the lead sees immediately that it was set aside.
class _NotSuitableBanner extends StatelessWidget {
  const _NotSuitableBanner({required this.lead});

  final Lead lead;

  @override
  Widget build(BuildContext context) {
    final detail = [
      if (lead.notSuitableReason.isNotEmpty) lead.notSuitableReason,
      if (lead.notSuitableBy.isNotEmpty) 'by ${lead.notSuitableBy}',
      if (lead.notSuitableOn != null && lead.notSuitableOn!.isNotEmpty)
        'on ${lead.notSuitableOn!.split(' ').first}',
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LeadsTheme.rejectedBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LeadsTheme.rejected.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.block, size: 18, color: LeadsTheme.rejected),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Not suitable',
                  style: LeadsTheme.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: LeadsTheme.rejected,
                  ),
                ),
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(detail, style: LeadsTheme.bodyMuted),
                ],
                if (lead.notSuitableNotes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(lead.notSuitableNotes, style: LeadsTheme.bodyMuted),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Records the manual-inspection verdict: after visiting/calling a prospect a
/// rep can mark it not suitable (with a reason and optional notes), which hides
/// it from the working catalog and drops it off the B2B pipeline board. The
/// same control reverses the verdict when the call turns out to be wrong.
class _SuitabilitySection extends ConsumerStatefulWidget {
  const _SuitabilitySection({required this.lead, required this.leadName});

  final Lead lead;
  final String leadName;

  @override
  ConsumerState<_SuitabilitySection> createState() =>
      _SuitabilitySectionState();
}

class _SuitabilitySectionState extends ConsumerState<_SuitabilitySection> {
  bool _saving = false;

  Future<void> _mark() async {
    final reasons = await ref.read(notSuitableReasonsProvider.future);
    if (!mounted) return;

    final verdict = await showDialog<_NotSuitableVerdict>(
      context: context,
      builder: (ctx) => _NotSuitableDialog(reasons: reasons),
    );
    if (verdict == null) return; // cancelled

    await _apply(
      notSuitable: true,
      reason: verdict.reason,
      notes: verdict.notes,
      message: 'Marked not suitable',
    );
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore lead?'),
        content: const Text(
          'This clears the not-suitable verdict and puts the lead back in the '
          'catalog at the Lead stage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _apply(notSuitable: false, message: 'Lead restored');
  }

  Future<void> _apply({
    required bool notSuitable,
    String? reason,
    String? notes,
    required String message,
  }) async {
    setState(() => _saving = true);
    try {
      await ref.read(leadDetailProvider(widget.leadName).notifier).setSuitability(
            notSuitable: notSuitable,
            reason: reason,
            notes: notes,
          );

      // Keep the B2B kanban in sync — marking removes the card, clearing puts
      // it back. Guarded: the board is not always initialised in this context.
      try {
        await ref.read(b2bPipelineProvider.notifier).refresh();
      } catch (_) {
        // B2B pipeline not available in this context; ignore.
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
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
    final marked = widget.lead.notSuitable;
    return _SectionCard(
      title: 'Suitability',
      children: [
        Text(
          marked
              ? 'This prospect was judged not suitable after manual inspection. '
                  'It is hidden from the catalog and off the pipeline board.'
              : 'Inspected this prospect and it is not worth pursuing? Mark it '
                  'not suitable to take it out of the working catalog.',
          style: LeadsTheme.bodyMuted,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: marked
              ? OutlinedButton.icon(
                  onPressed: _saving ? null : _clear,
                  icon: _saving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.undo, size: 16),
                  label: const Text('Restore lead'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LeadsTheme.deepPlum,
                    side: const BorderSide(color: LeadsTheme.line),
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: _saving ? null : _mark,
                  icon: _saving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.block, size: 16),
                  label: const Text('Mark not suitable'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LeadsTheme.rejected,
                    side: BorderSide(
                      color: LeadsTheme.rejected.withValues(alpha: 0.5),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

/// The reason + notes captured when marking a lead not suitable.
class _NotSuitableVerdict {
  const _NotSuitableVerdict({required this.reason, required this.notes});

  final String reason;
  final String notes;
}

/// Reason picker + optional notes. Confirm stays disabled until a reason is
/// chosen — the backend rejects a reasonless verdict, so the UI does too.
class _NotSuitableDialog extends StatefulWidget {
  const _NotSuitableDialog({required this.reasons});

  final List<String> reasons;

  @override
  State<_NotSuitableDialog> createState() => _NotSuitableDialogState();
}

class _NotSuitableDialogState extends State<_NotSuitableDialog> {
  final _notesController = TextEditingController();
  String? _reason;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mark not suitable'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _reason,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Reason',
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: [
              for (final reason in widget.reasons)
                DropdownMenuItem<String>(value: reason, child: Text(reason)),
            ],
            onChanged: (value) => setState(() => _reason = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'What did the inspection show?',
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _reason == null
              ? null
              : () => Navigator.pop(
                    context,
                    _NotSuitableVerdict(
                      reason: _reason!,
                      notes: _notesController.text.trim(),
                    ),
                  ),
          style: FilledButton.styleFrom(backgroundColor: LeadsTheme.rejected),
          child: const Text('Mark not suitable'),
        ),
      ],
    );
  }
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
