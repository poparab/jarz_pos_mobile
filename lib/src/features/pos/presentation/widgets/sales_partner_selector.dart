import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/repositories/pos_repository.dart';
import '../../state/pos_notifier.dart';

class SalesPartnerSelectorDialog extends ConsumerStatefulWidget {
  const SalesPartnerSelectorDialog({super.key});

  @override
  ConsumerState<SalesPartnerSelectorDialog> createState() => _SalesPartnerSelectorDialogState();
}

class _SalesPartnerSelectorDialogState extends ConsumerState<SalesPartnerSelectorDialog> {
  List<Map<String, dynamic>> _partners = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(posRepositoryProvider);
      final data = await repo.getSalesPartners(search: _search.isEmpty ? null : _search, limit: 10);
      setState(() => _partners = data);
    } catch (_) {
      setState(() => _partners = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(posNotifierProvider.select((s) => s.selectedSalesPartner));
    final dialogWidth = ResponsiveUtils.getDialogWidth(context);
    final isPhone = ResponsiveUtils.isPhone(context);
    return AlertDialog(
      title: Text(context.l10n.salesPartnerTitle),
      content: SizedBox(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: context.l10n.salesPartnerSearchHint),
              onChanged: (v) {
                _search = v.trim();
                _loadPartners();
              },
            ),
            const SizedBox(height: 12),
            if (_loading)
              const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
            else if (_partners.isEmpty)
              SizedBox(height: 200, child: Center(child: Text(context.l10n.salesPartnerNotFound)))
            else
              SizedBox(
                height: 280,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isPhone ? 1 : 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: isPhone ? 5.0 : 3.5,
                  ),
                  itemCount: _partners.length,
                  itemBuilder: (_, i) {
                    final p = _partners[i];
                    final isSelected = selected != null && selected['name'] == p['name'];
                    return OutlinedButton(
                      style: OutlinedButton.styleFrom(
            backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : null,
                      ),
                      onPressed: () => Navigator.pop(context, p),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(p['title'] ?? p['partner_name'] ?? p['name'] ?? ''),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonClose),
        ),
        if (selected != null)
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(context.l10n.commonClear),
          ),
      ],
    );
  }
}
