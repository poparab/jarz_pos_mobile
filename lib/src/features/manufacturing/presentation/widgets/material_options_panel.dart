import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/models/material_options.dart';
import '../../state/production_providers.dart';
import 'production_format.dart';

bool materialSelectionsAreValid(
  MaterialOptions options,
  Map<String, String> selections,
) {
  final componentCodes = options.components
      .map((component) => component.originalItemCode)
      .toSet();
  if (selections.keys.any((code) => !componentCodes.contains(code))) {
    return false;
  }
  final usedActualItems = <String>{};
  for (final component in options.components) {
    final selected =
        selections[component.originalItemCode] ?? component.originalItemCode;
    if (!component.options.any((option) => option.itemCode == selected)) {
      return false;
    }
    if (!usedActualItems.add(selected)) return false;
  }
  return true;
}

class MaterialOptionsPanel extends ConsumerWidget {
  const MaterialOptionsPanel({
    super.key,
    required this.bomName,
    required this.qty,
    required this.selections,
    required this.onSelectionChanged,
  });

  final String bomName;
  final double qty;
  final Map<String, String> selections;
  final void Function(String originalItemCode, String selectedItemCode)
  onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bomName.isEmpty || qty <= 0) return const SizedBox.shrink();
    final request = MaterialOptionsRequest(bomName: bomName, qty: qty);
    final optionsAsync = ref.watch(materialOptionsProvider(request));

    return optionsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.userErrorMessage(
                    error,
                    fallback: context.l10n.commonError,
                  ),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.invalidate(materialOptionsProvider(request)),
                child: Text(context.l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
      data: (materialOptions) {
        final knownOriginals = materialOptions.components
            .map((component) => component.originalItemCode)
            .toSet();
        final unknownSelections = selections.keys
            .where((code) => !knownOriginals.contains(code))
            .toList(growable: false);
        final components = materialOptions.components
            .where(
              (component) =>
                  component.hasAlternatives ||
                  component.selectionBlocked ||
                  selections.containsKey(component.originalItemCode),
            )
            .toList(growable: false);
        if (components.isEmpty && unknownSelections.isEmpty) {
          return const SizedBox.shrink();
        }
        final effectiveSelections = <String, String>{
          for (final component in materialOptions.components)
            component.originalItemCode:
                selections[component.originalItemCode] ??
                component.originalItemCode,
        };
        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.manufacturingRequiredItems,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                if (unknownSelections.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${context.l10n.commonError}: ${unknownSelections.join(', ')}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                if (selections.isNotEmpty)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () {
                        for (final original in selections.keys.toList()) {
                          onSelectionChanged(original, original);
                        }
                      },
                      child: Text(context.l10n.commonClear),
                    ),
                  ),
                const SizedBox(height: 8),
                for (final component in components) ...[
                  Builder(
                    builder: (context) {
                      final selected =
                          effectiveSelections[component.originalItemCode] ??
                          component.originalItemCode;
                      final selectedStillExists = component.options.any(
                        (option) => option.itemCode == selected,
                      );
                      final selectedElsewhere = effectiveSelections.entries.any(
                        (entry) =>
                            entry.key != component.originalItemCode &&
                            entry.value == selected,
                      );
                      if (!selectedStillExists ||
                          selectedElsewhere ||
                          (component.selectionBlocked &&
                              selected != component.originalItemCode)) {
                        return _UnavailableMaterialChoice(
                          component: component,
                          selectedItemCode: selected,
                          onReset: () => onSelectionChanged(
                            component.originalItemCode,
                            component.originalItemCode,
                          ),
                        );
                      }
                      if (component.selectionBlocked) {
                        return Text(
                          component.alternativeSelectionBlockedReason!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                      final usedByOtherComponents = effectiveSelections.entries
                          .where(
                            (entry) => entry.key != component.originalItemCode,
                          )
                          .map((entry) => entry.value)
                          .toSet();
                      return _MaterialChoice(
                        component: component,
                        selectedItemCode: selected,
                        unavailableItemCodes: usedByOtherComponents,
                        onChanged: (next) => onSelectionChanged(
                          component.originalItemCode,
                          next,
                        ),
                      );
                    },
                  ),
                  if (component != components.last) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MaterialChoice extends StatelessWidget {
  const _MaterialChoice({
    required this.component,
    required this.selectedItemCode,
    required this.unavailableItemCodes,
    required this.onChanged,
  });

  final MaterialOptionComponent component;
  final String selectedItemCode;
  final Set<String> unavailableItemCodes;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('${component.originalItemCode}:$selectedItemCode'),
      initialValue: selectedItemCode,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: component.originalItemName.trim().isEmpty
            ? component.originalItemCode
            : component.originalItemName,
        helperText: context.l10n.manufacturingComponentRequired(
          trimQty(component.requiredQty),
          component.stockUom,
        ),
      ),
      items: component.options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option.itemCode,
              enabled: !unavailableItemCodes.contains(option.itemCode),
              child: Text(
                '${option.displayName} · '
                '${context.l10n.manufacturingComponentAvailable(trimQty(option.availableQty), option.stockUom)}'
                '${option.valuationRate > 0 ? ' · ${formatCurrency(context, option.valuationRate)}/${option.stockUom}' : ''}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _UnavailableMaterialChoice extends StatelessWidget {
  const _UnavailableMaterialChoice({
    required this.component,
    required this.selectedItemCode,
    required this.onReset,
  });

  final MaterialOptionComponent component;
  final String selectedItemCode;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: component.originalItemName.trim().isEmpty
            ? component.originalItemCode
            : component.originalItemName,
        errorText: context.l10n.commonError,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(selectedItemCode, overflow: TextOverflow.ellipsis),
          ),
          TextButton(onPressed: onReset, child: Text(context.l10n.commonRetry)),
        ],
      ),
    );
  }
}
