import 'package:flutter/material.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/production_round.dart';
import 'production_round_format.dart';
import 'production_round_tab_scaffold.dart';

/// The prep to do before the jars, then the materials — short ones first,
/// and by default ONLY the short ones whenever something is short.
class ProductionRoundMaterialsTab extends StatefulWidget {
  const ProductionRoundMaterialsTab({
    super.key,
    required this.round,
    required this.onRefresh,
  });

  final ProductionRound round;
  final Future<void> Function() onRefresh;

  @override
  State<ProductionRoundMaterialsTab> createState() =>
      _ProductionRoundMaterialsTabState();
}

class _ProductionRoundMaterialsTabState
    extends State<ProductionRoundMaterialsTab> {
  /// Null until the user picks: the default follows the data, so a refresh
  /// that clears every shortage does not leave the list stuck on "missing".
  bool? _missingOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final round = widget.round;
    final missing = round.missingMaterials;
    final prep = round.prepToDo;
    final missingOnly = _missingOnly ?? missing.isNotEmpty;
    final shown = missingOnly ? missing : round.materials;

    if (prep.isEmpty && round.materials.isEmpty) {
      return RefreshableMessage(
        onRefresh: widget.onRefresh,
        icon: Icons.inventory_2_outlined,
        title: l10n.productionRoundNoMaterials,
      );
    }

    return RefreshableList(
      onRefresh: widget.onRefresh,
      children: [
        if (prep.isNotEmpty) ...[
          _MakeFirstCard(prep: prep),
          const SizedBox(height: 14),
        ],
        if (round.materials.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.productionRoundFilterMissing(missing.length)),
                selected: missingOnly,
                onSelected: (_) => setState(() => _missingOnly = true),
              ),
              ChoiceChip(
                label: Text(
                  l10n.productionRoundFilterAll(round.materials.length),
                ),
                selected: !missingOnly,
                onSelected: (_) => setState(() => _missingOnly = false),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l10n.productionRoundNothingMissing,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < shown.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    _MaterialRow(material: shown[i]),
                  ],
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _MakeFirstCard extends StatelessWidget {
  const _MakeFirstCard({required this.prep});

  final List<ProductionRoundPrep> prep;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.blender_outlined,
                  size: 18,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.productionRoundMakeFirst,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (final row in prep)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        row.displayName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _prepDetail(l10n, row),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// "0.91 batch (12.43 Kg)" for a stored base; "fresh, 7.2 batches" for a
  /// phantom mix that is made inside the jar batch and never stored.
  static String _prepDetail(AppLocalizations l10n, ProductionRoundPrep row) {
    final batches = batchesLabel(l10n, row.batches);
    if (row.madeFresh) return l10n.productionRoundPrepFresh(batches);
    return l10n.productionRoundPrepStored(
      batches,
      fmtMaterialQty(row.toMake, row.uom),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({required this.material});

  final ProductionRoundMaterial material;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final short = material.isMissing;
    final barColor = short
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  material.displayName,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (short) ...[
                const SizedBox(width: 8),
                Text(
                  l10n.productionRoundShort(
                    fmtMaterialQty(material.missing, material.uom),
                  ),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            l10n.productionRoundNeedHave(
              fmtMaterialQty(material.required, material.uom),
              fmtMaterialQty(material.onHand, material.uom),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (material.alternativeOnHand > 0)
            Text(
              l10n.productionRoundAlternative(
                fmtMaterialQty(material.alternativeOnHand, material.uom),
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: material.coverage,
              minHeight: 3,
              color: barColor,
              backgroundColor: barColor.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}
