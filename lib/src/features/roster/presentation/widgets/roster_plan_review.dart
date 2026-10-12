import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../models/roster_plan_models.dart';
import '../roster_formats.dart';

const Key rosterPlanReplaceManualKey = ValueKey<String>(
  'roster-plan-replace-manual',
);
const Key rosterPlanGrantPosKey = ValueKey<String>('roster-plan-grant-pos');
const Key rosterPlanPreviewRetryKey = ValueKey<String>(
  'roster-plan-preview-retry',
);

/// Amber for "worth checking" — a problem, but not one that blocks Apply.
/// Red is the theme's error colour; everything else stays neutral.
const Color _warningColor = Color(0xFFB26A00);

/// "Check & apply": what the dry run says will happen, and every problem.
///
/// Colour appears only on problems: red for errors (Apply stays disabled
/// while any exist), amber for warnings, muted for notes.
class RosterPlanReview extends StatelessWidget {
  const RosterPlanReview({
    super.key,
    required this.loading,
    required this.preview,
    required this.error,
    required this.onRetry,
    required this.replaceManual,
    required this.onReplaceManualChanged,
    required this.showGrantPos,
    required this.grantPos,
    required this.onGrantPosChanged,
    this.periodText,
  });

  final bool loading;
  final RosterPlanResult? preview;
  final String? error;
  final VoidCallback onRetry;
  final bool replaceManual;
  final ValueChanged<bool> onReplaceManualChanged;
  final bool showGrantPos;
  final bool grantPos;
  final ValueChanged<bool> onGrantPosChanged;
  final String? periodText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final result = preview;

    if (loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.rosterPlanChecking),
          ],
        ),
      );
    }
    if (error != null || result == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(height: 8),
              Text(
                l10n.rosterPlanCheckFailed,
                style: theme.textTheme.titleMedium,
              ),
              if (error != null) ...[
                const SizedBox(height: 4),
                Text(error!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 16),
              FilledButton(
                key: rosterPlanPreviewRetryKey,
                onPressed: onRetry,
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      );
    }

    final summary = result.summary;
    final errors = result.errors;
    final warnings = result.warnings;
    final notes = result.notes;
    final manualRows = result.rowsWithManualDays;
    final showManual =
        manualRows.isNotEmpty ||
        replaceManual ||
        summary.manualKept > 0 ||
        summary.manualReplaced > 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (periodText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              periodText!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        _SectionTitle(l10n.rosterPlanSummaryTitle),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _Count(l10n.rosterPlanSummaryPeople, summary.people),
                _Count(l10n.rosterPlanSummaryShiftDays, summary.shiftDays),
                _Count(l10n.rosterPlanSummaryDayOffs, summary.dayOffs),
                _Count(l10n.rosterPlanSummaryCovers, summary.covers),
                if (summary.manualKept > 0)
                  _Count(l10n.rosterPlanSummaryManualKept, summary.manualKept),
                if (summary.manualReplaced > 0)
                  _Count(
                    l10n.rosterPlanSummaryManualReplaced,
                    summary.manualReplaced,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (errors.isNotEmpty) ...[
          _SectionTitle(
            l10n.rosterPlanErrorsTitle,
            color: theme.colorScheme.error,
          ),
          for (final issue in errors)
            _IssueTile(
              issue: issue,
              icon: Icons.error,
              color: theme.colorScheme.error,
            ),
        ],
        if (warnings.isNotEmpty) ...[
          _SectionTitle(l10n.rosterPlanWarningsTitle, color: _warningColor),
          for (final issue in warnings)
            _IssueTile(
              issue: issue,
              icon: Icons.warning_amber_rounded,
              color: _warningColor,
            ),
        ],
        if (notes.isNotEmpty) ...[
          _SectionTitle(l10n.rosterPlanNotesTitle),
          for (final issue in notes)
            _IssueTile(
              issue: issue,
              icon: Icons.info_outline,
              color: theme.colorScheme.onSurfaceVariant,
              muted: true,
            ),
        ],
        if (errors.isEmpty && warnings.isEmpty && !result.hasErrors)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle_outline),
            title: Text(l10n.rosterPlanNoIssues),
          ),
        if (showManual) ...[
          const SizedBox(height: 8),
          _SectionTitle(l10n.rosterPlanManualTitle),
          Text(
            l10n.rosterPlanManualHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SwitchListTile(
            key: rosterPlanReplaceManualKey,
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.rosterPlanReplaceManual),
            value: replaceManual,
            onChanged: onReplaceManualChanged,
          ),
          for (final row in manualRows) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                row.displayName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final day in row.manualDays)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8, bottom: 2),
                child: Text(
                  l10n.rosterPlanManualLine(
                    formatDateString(context, day.date, pattern: 'EEE d MMM'),
                    day.kind == 'empty' || day.current == null
                        ? l10n.rosterPlanManualEmpty
                        : day.current!,
                  ),
                ),
              ),
          ],
        ],
        if (showGrantPos) ...[
          const Divider(height: 32),
          SwitchListTile(
            key: rosterPlanGrantPosKey,
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.point_of_sale_outlined),
            title: Text(l10n.rosterPlanGrantPos),
            value: grantPos,
            onChanged: onGrantPosChanged,
          ),
        ],
        if (result.hasErrors)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              l10n.rosterPlanApplyBlocked,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          Text(
            rosterNumber(context, value),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueTile extends StatelessWidget {
  const _IssueTile({
    required this.issue,
    required this.icon,
    required this.color,
    this.muted = false,
  });

  final RosterPlanIssue issue;
  final IconData icon;
  final Color color;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final name = issue.employeeName ?? issue.employee;
    final date = issue.date == null
        ? null
        : formatDateString(context, issue.date, pattern: 'EEE d MMM');
    final where = name != null && date != null
        ? l10n.rosterPlanIssueWhere(name, date)
        : (name ?? date);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        issue.message.isEmpty ? issue.code : issue.message,
        style: muted
            ? theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )
            : null,
      ),
      subtitle: where == null ? null : Text(where),
    );
  }
}
