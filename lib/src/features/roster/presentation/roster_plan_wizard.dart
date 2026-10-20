import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../../core/localization/user_error_message.dart';
import '../data/roster_repository.dart';
import '../models/roster_models.dart';
import '../models/roster_plan_models.dart';
import '../state/roster_filter.dart';
import '../state/roster_plan_draft.dart';
import '../state/roster_providers.dart';
import 'roster_formats.dart';
import 'widgets/roster_plan_person_card.dart';
import 'widgets/roster_plan_review.dart';

const Key rosterPlanNextKey = ValueKey<String>('roster-plan-next');
const Key rosterPlanBackKey = ValueKey<String>('roster-plan-back');
const Key rosterPlanApplyKey = ValueKey<String>('roster-plan-apply');
const Key rosterPlanSameForEveryoneKey = ValueKey<String>(
  'roster-plan-same-for-everyone',
);
const Key rosterPlanCustomPeriodKey = ValueKey<String>('roster-plan-custom');
Key rosterPlanStepKey(int step) => ValueKey<String>('roster-plan-step-$step');
Key rosterPlanPersonKey(String employee) =>
    ValueKey<String>('roster-plan-pick-$employee');
Key rosterPlanBranchToggleKey(String branch) =>
    ValueKey<String>('roster-plan-branch-$branch');

/// Opens the wizard full screen. Resolves to true when a plan was applied.
Future<bool?> showRosterPlanWizard(BuildContext context) {
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const RosterPlanWizard(),
    ),
  );
}

/// "Plan the rota": a whole period, and the standing week after it, in four
/// steps — When → Who → Their week → Check & apply.
///
/// Built for a branch manager who is not technical: one decision per row,
/// big chips, Back / Next at the bottom. The server does all the real work
/// (`roster.apply_plan`); this screen only collects the plan and shows the
/// dry run's verdict before anything is written.
class RosterPlanWizard extends ConsumerStatefulWidget {
  const RosterPlanWizard({super.key, this.today});

  /// The clock, for tests. Defaults to now.
  final DateTime? today;

  @override
  ConsumerState<RosterPlanWizard> createState() => _RosterPlanWizardState();
}

class _RosterPlanWizardState extends ConsumerState<RosterPlanWizard> {
  static const _lastStep = 3;

  int _step = 0;

  bool _loading = true;
  Object? _loadError;
  RosterPlanDefaults? _defaults;

  RosterPlanPeriodKind _periodKind = RosterPlanPeriodKind.nextMonth;
  RosterPlanPeriod? _custom;

  final Set<String> _selected = <String>{};
  final Map<String, RosterPlanRowDraft> _rows = <String, RosterPlanRowDraft>{};

  bool _replaceManual = false;
  bool _grantPos = true;

  bool _previewing = false;
  RosterPlanResult? _preview;
  String? _previewError;
  int _previewSeq = 0;
  bool _applying = false;

  DateTime get _today => widget.today ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      // The grid's filter narrows the plan only when it is exactly one
      // branch and nobody picked by name: the backend takes ONE location, and
      // any other selection has no single-branch equivalent, so it plans
      // everyone in scope as before. The pruned filter, so a saved branch
      // that no longer exists is not sent.
      final filter = ref.read(rosterEffectiveFilterProvider);
      final singleBranch =
          filter.locations.length == 1 && filter.employees.isEmpty
          ? filter.locations.first
          : null;
      final defaults = await ref
          .read(rosterRepositoryProvider)
          .getPlanDefaults(shiftLocation: singleBranch);
      if (!mounted) return;
      setState(() {
        _defaults = defaults;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _loading = false;
      });
    }
  }

  // ── Derived ──────────────────────────────────────────────────────────

  // Read, not watched: these are also used from callbacks. [build] watches
  // the bootstrap so a late arrival still rebuilds the screen.
  List<RosterShift> get _catalog =>
      ref.read(rosterBootstrapProvider).asData?.value.shiftCatalog ??
      const <RosterShift>[];

  List<String> get _locations =>
      ref
          .read(rosterBootstrapProvider)
          .asData
          ?.value
          .shiftLocations
          .map((l) => l.shiftLocation)
          .where((l) => l.isNotEmpty)
          .toList() ??
      const <String>[];

  List<RosterPlanDefaultsEmployee> get _people =>
      _defaults?.employees ?? const <RosterPlanDefaultsEmployee>[];

  /// The ticked people, in the server's order.
  List<RosterPlanDefaultsEmployee> get _chosen =>
      _people.where((p) => _selected.contains(p.employee)).toList();

  RosterPlanPeriod? get _period => rosterPlanPeriodFor(
    _periodKind,
    today: _today,
    suggestedStart: _defaults?.suggestedStart,
    custom: _custom,
  );

  List<RosterPlanRowDraft> get _chosenRows => [
    for (final p in _chosen)
      if (_rows[p.employee] != null) _rows[p.employee]!,
  ];

  bool get _hasCovers => _chosenRows.any(
    (r) => r.offDays.any((d) => (r.covers[d]?.coveredBy ?? '').isNotEmpty),
  );

  bool get _canGoNext {
    switch (_step) {
      case 0:
        final period = _period;
        return period != null && !period.isTooLong;
      case 1:
        return _selected.isNotEmpty;
      case 2:
        final needBranch = _locations.isNotEmpty;
        return _chosenRows.isNotEmpty &&
            _chosenRows.every(
              (r) =>
                  r.isComplete &&
                  (!needBranch || (r.shiftLocation ?? '').isNotEmpty),
            );
      default:
        return false;
    }
  }

  bool get _canApply =>
      _step == _lastStep &&
      !_previewing &&
      !_applying &&
      _preview != null &&
      _previewError == null &&
      !_preview!.hasErrors;

  Map<String, dynamic> _payload() => buildRosterPlanPayload(
    period: _period!,
    rows: _chosenRows,
    catalog: _catalog,
    replaceManual: _replaceManual,
    grantPosAccess: _hasCovers && _grantPos,
  );

  // ── Navigation ───────────────────────────────────────────────────────

  void _ensureRows() {
    final known = {for (final p in _people) p.employee};
    final locations = _locations;
    for (final person in _chosen) {
      _rows.putIfAbsent(person.employee, () {
        final row = RosterPlanRowDraft.fromDefaults(person);
        // A coverer outside the caller's scope cannot be picked here; drop
        // the pre-fill rather than send a name the server will refuse.
        row.covers.removeWhere(
          (_, c) => c.coveredBy != null && !known.contains(c.coveredBy),
        );
        if ((row.shiftLocation ?? '').isEmpty && locations.length == 1) {
          row.shiftLocation = locations.single;
        }
        return row;
      });
    }
  }

  void _next() {
    if (!_canGoNext) return;
    setState(() {
      if (_step == 1) _ensureRows();
      _step++;
    });
    if (_step == _lastStep) _runPreview();
  }

  void _back() {
    if (_step == 0) return;
    setState(() {
      if (_step == _lastStep) {
        // Anything shown came from the plan as it was; editing invalidates it.
        _previewSeq++;
        _preview = null;
        _previewError = null;
        _previewing = false;
      }
      _step--;
    });
  }

  // ── Server ───────────────────────────────────────────────────────────

  Future<void> _runPreview() async {
    final seq = ++_previewSeq;
    final l10n = context.l10n;
    setState(() {
      _previewing = true;
      _previewError = null;
    });
    try {
      final result = await ref
          .read(rosterRepositoryProvider)
          .applyPlan(_payload(), dryRun: true);
      if (!mounted || seq != _previewSeq) return;
      setState(() {
        _preview = result;
        _previewing = false;
      });
    } catch (error) {
      if (!mounted || seq != _previewSeq) return;
      setState(() {
        _preview = null;
        _previewError = userErrorMessageFor(l10n, error);
        _previewing = false;
      });
    }
  }

  Future<void> _apply() async {
    if (!_canApply) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final localeName = l10n.localeName;
    setState(() => _applying = true);
    try {
      final result = await ref
          .read(rosterRepositoryProvider)
          .applyPlan(_payload(), dryRun: false);
      if (!mounted) return;
      if (!result.applied) {
        // The server found something the preview did not: show its verdict.
        setState(() {
          _preview = result;
          _applying = false;
        });
        return;
      }
      ref.invalidate(rosterMonthDataProvider);
      ref.invalidate(rosterHoursProvider);
      final people = result.summary.people > 0
          ? result.summary.people
          : _selected.length;
      navigator.pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.rosterPlanApplied(rosterNumberIn(localeName, people)),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _applying = false);
      messenger.showSnackBar(
        SnackBar(content: Text(userErrorMessageFor(l10n, error))),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(rosterBootstrapProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.rosterPlanTitle)),
      body: Column(
        children: [
          _StepIndicator(step: _step),
          const Divider(height: 1),
          Expanded(child: _body(context)),
        ],
      ),
      bottomNavigationBar: _bottomBar(context),
    );
  }

  Widget _body(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.rosterPlanLoadFailed,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                context.userErrorMessage(_loadError),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: Text(l10n.commonRetry)),
            ],
          ),
        ),
      );
    }
    switch (_step) {
      case 0:
        return _whenStep(context);
      case 1:
        return _whoStep(context);
      case 2:
        return _weekStep(context);
      default:
        return RosterPlanReview(
          loading: _previewing,
          preview: _preview,
          error: _previewError,
          onRetry: _runPreview,
          periodText: _periodText(context),
          replaceManual: _replaceManual,
          onReplaceManualChanged: (value) {
            setState(() => _replaceManual = value);
            _runPreview();
          },
          showGrantPos: _hasCovers,
          grantPos: _grantPos,
          onGrantPosChanged: (value) => setState(() => _grantPos = value),
        );
    }
  }

  Widget _bottomBar(BuildContext context) {
    final l10n = context.l10n;
    final isLast = _step == _lastStep;
    const height = Size.fromHeight(52);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: rosterPlanBackKey,
                style: OutlinedButton.styleFrom(minimumSize: height),
                onPressed: _step == 0 || _applying ? null : _back,
                child: Text(l10n.rosterPlanBack),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isLast
                  ? FilledButton(
                      key: rosterPlanApplyKey,
                      style: FilledButton.styleFrom(minimumSize: height),
                      onPressed: _canApply ? _apply : null,
                      child: _applying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.rosterPlanApply),
                    )
                  : FilledButton(
                      key: rosterPlanNextKey,
                      style: FilledButton.styleFrom(minimumSize: height),
                      onPressed: !_loading && _loadError == null && _canGoNext
                          ? _next
                          : null,
                      child: Text(l10n.rosterPlanNext),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String? _periodText(BuildContext context) {
    final period = _period;
    if (period == null) return null;
    return context.l10n.rosterPlanPeriodRange(
      formatDate(context, period.start, pattern: 'EEE d MMM'),
      formatDate(context, period.end, pattern: 'EEE d MMM yyyy'),
      rosterNumber(context, period.days),
    );
  }

  // ── Step 1: When ─────────────────────────────────────────────────────

  Future<void> _pickCustom() async {
    final today = DateTime(_today.year, _today.month, _today.day);
    final current = _custom;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 366)),
      initialDateRange: current == null
          ? null
          : DateTimeRange(
              start: DateTime(
                current.start.year,
                current.start.month,
                current.start.day,
              ),
              end: DateTime(
                current.end.year,
                current.end.month,
                current.end.day,
              ),
            ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _periodKind = RosterPlanPeriodKind.custom;
      _custom = RosterPlanPeriod(
        DateTime.utc(picked.start.year, picked.start.month, picked.start.day),
        DateTime.utc(picked.end.year, picked.end.month, picked.end.day),
      );
    });
  }

  Widget _whenStep(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final period = _period;
    final restOfMonth = rosterPlanPeriodFor(
      RosterPlanPeriodKind.restOfMonth,
      today: _today,
    );

    Widget chip(RosterPlanPeriodKind kind, String label, {Key? key}) {
      final enabled =
          kind != RosterPlanPeriodKind.restOfMonth || restOfMonth != null;
      return ChoiceChip(
        key: key,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelStyle: theme.textTheme.titleMedium,
        label: Text(label),
        selected: _periodKind == kind,
        onSelected: !enabled
            ? null
            : (_) {
                if (kind == RosterPlanPeriodKind.custom) {
                  if (_custom == null) {
                    _pickCustom();
                    return;
                  }
                }
                setState(() => _periodKind = kind);
              },
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Question(l10n.rosterPlanWhenQuestion),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            chip(RosterPlanPeriodKind.nextMonth, l10n.rosterPlanNextMonth),
            chip(RosterPlanPeriodKind.restOfMonth, l10n.rosterPlanRestOfMonth),
            chip(
              RosterPlanPeriodKind.custom,
              l10n.rosterPlanCustom,
              key: rosterPlanCustomPeriodKey,
            ),
          ],
        ),
        if (_periodKind == RosterPlanPeriodKind.custom) ...[
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: _pickCustom,
              icon: const Icon(Icons.date_range),
              label: Text(l10n.rosterPlanPickDates),
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (period == null)
          Text(l10n.rosterPlanPeriodNone, style: theme.textTheme.titleMedium)
        else ...[
          Text(
            _periodText(context)!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (period.isTooLong)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l10n.rosterPlanPeriodTooLong(
                  rosterNumber(context, rosterPlanMaxDays),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.rosterPlanStandingHint,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ── Step 2: Who ──────────────────────────────────────────────────────

  Widget _whoStep(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final people = _people;
    if (people.isEmpty) {
      return Center(child: Text(l10n.rosterPlanNoPeople));
    }

    final groups = <String, List<RosterPlanDefaultsEmployee>>{};
    for (final person in people) {
      groups.putIfAbsent(person.shiftLocation ?? '', () => []).add(person);
    }
    final branches = groups.keys.toList()
      ..sort((a, b) {
        if (a.isEmpty != b.isEmpty) return a.isEmpty ? 1 : -1;
        return a.toLowerCase().compareTo(b.toLowerCase());
      });

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _Question(l10n.rosterPlanWhoQuestion),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.rosterPlanSelectedCount(
              rosterNumber(context, _selected.length),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        for (final branch in branches) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    branch.isEmpty ? l10n.rosterPlanNoBranch : branch,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Builder(
                  builder: (context) {
                    final members = groups[branch]!;
                    final allOn = members.every(
                      (p) => _selected.contains(p.employee),
                    );
                    return TextButton(
                      key: rosterPlanBranchToggleKey(branch),
                      onPressed: () => setState(() {
                        for (final p in members) {
                          if (allOn) {
                            _selected.remove(p.employee);
                          } else {
                            _selected.add(p.employee);
                          }
                        }
                      }),
                      child: Text(
                        allOn
                            ? l10n.rosterPlanUnselectAll
                            : l10n.rosterPlanSelectAll,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          for (final person in groups[branch]!)
            CheckboxListTile(
              key: rosterPlanPersonKey(person.employee),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              value: _selected.contains(person.employee),
              title: Text(
                person.displayName,
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(person.shiftType ?? l10n.rosterPlanNoUsualWeek),
              onChanged: (checked) => setState(() {
                if (checked ?? false) {
                  _selected.add(person.employee);
                } else {
                  _selected.remove(person.employee);
                }
              }),
            ),
        ],
      ],
    );
  }

  // ── Step 3: Their week ───────────────────────────────────────────────

  Widget _weekStep(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final chosen = _chosen;
    final catalog = _catalog;
    final locations = _locations;
    final first = chosen.isEmpty ? null : chosen.first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (chosen.length > 1 && first != null) ...[
          OutlinedButton.icon(
            key: rosterPlanSameForEveryoneKey,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.copy_all_outlined),
            label: Text(l10n.rosterPlanSameForEveryone),
            onPressed: () {
              final source = _rows[first.employee];
              if (source == null) return;
              setState(() {
                for (final person in chosen.skip(1)) {
                  _rows[person.employee]?.copyWeekFrom(source);
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.rosterPlanSameForEveryoneDone(first.displayName),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Text(
              l10n.rosterPlanSameForEveryoneHint(first.displayName),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
        for (final person in chosen)
          if (_rows[person.employee] != null)
            RosterPlanPersonCard(
              key: ValueKey<String>('roster-plan-card-${person.employee}'),
              person: person,
              row: _rows[person.employee]!,
              people: _people,
              plannedRows: _rows,
              catalog: catalog,
              locations: locations,
              onChanged: () => setState(() {}),
            ),
        if (!_canGoNext)
          Text(
            l10n.rosterPlanIncomplete,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// "1 When · 2 Who · 3 Their week · 4 Check & apply", the current one bold.
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final labels = [
      l10n.rosterPlanStepWhen,
      l10n.rosterPlanStepWho,
      l10n.rosterPlanStepWeek,
      l10n.rosterPlanStepCheck,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Column(
                key: rosterPlanStepKey(i),
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: i <= step
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: i <= step
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    child: i < step
                        ? const Icon(Icons.check, size: 16)
                        : Text(rosterNumber(context, i + 1)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: i == step
                          ? FontWeight.w700
                          : FontWeight.normal,
                      color: i == step
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
