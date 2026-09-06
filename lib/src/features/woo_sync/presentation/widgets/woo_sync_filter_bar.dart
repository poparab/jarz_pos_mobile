import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../providers/woo_sync_filters.dart';
import 'woo_sync_labels.dart';

const _searchDebounce = Duration(milliseconds: 350);

/// Search box + dimension chips for the event list. Mirrors the Kanban
/// board's filter-bar shape: always-visible search, one chip per dimension
/// that shows its current value and carries its own clear affordance.
class WooSyncFilterBar extends StatefulWidget {
  final WooSyncFilters filters;
  final ValueChanged<WooSyncFilters> onChanged;

  const WooSyncFilterBar({super.key, required this.filters, required this.onChanged});

  @override
  State<WooSyncFilterBar> createState() => _WooSyncFilterBarState();
}

class _WooSyncFilterBarState extends State<WooSyncFilterBar> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  static const _statuses = [
    'Pending',
    'Processing',
    'Succeeded',
    'RetryScheduled',
    'Skipped',
    'Superseded',
    'Failed',
    'NeedsReview',
    'DeadLetter',
  ];
  static const _directions = ['Inbound', 'Outbound'];
  static const _reviewStates = ['Open', 'Investigating', 'Resolved', 'Ignored'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filters.search);
  }

  @override
  void didUpdateWidget(covariant WooSyncFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filters.search != _searchController.text && widget.filters.search.isEmpty) {
      _searchController.text = '';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      widget.onChanged(widget.filters.copyWith(search: value));
    });
  }

  Future<void> _pickFromList({
    required String title,
    required List<String> options,
    required String? current,
    required String Function(String) labelOf,
    required ValueChanged<String?> onPicked,
  }) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(context.l10n.wooSyncFilterAny),
              trailing: current == null ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(ctx, ''),
            ),
            for (final opt in options)
              ListTile(
                title: Text(labelOf(opt)),
                trailing: current == opt ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, opt),
              ),
          ],
        ),
      ),
    );
    if (result != null) onPicked(result.isEmpty ? null : result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final f = widget.filters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: l10n.wooSyncSearchHint,
            isDense: true,
            border: const OutlineInputBorder(),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      widget.onChanged(f.copyWith(search: ''));
                    },
                  ),
          ),
          onChanged: _onSearchChanged,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: Text(l10n.wooSyncFilterAttentionOnly),
              selected: f.attentionOnly,
              onSelected: (v) => widget.onChanged(f.copyWith(attentionOnly: v, clearStatus: v)),
            ),
            FilterChip(
              label: Text(l10n.wooSyncFilterAllEvents),
              selected: !f.attentionOnly && f.status == null,
              onSelected: (v) => widget.onChanged(
                f.copyWith(attentionOnly: !v, clearStatus: true),
              ),
            ),
            ActionChip(
              avatar: const Icon(Icons.tune, size: 16),
              label: Text(f.status == null
                  ? l10n.wooSyncFilterStatusLabel
                  : '${l10n.wooSyncFilterStatusLabel}: ${wooSyncStatusLabel(context, f.status!)}'),
              onPressed: () => _pickFromList(
                title: l10n.wooSyncFilterStatusLabel,
                options: _statuses,
                current: f.status,
                labelOf: (s) => wooSyncStatusLabel(context, s),
                onPicked: (v) => widget.onChanged(
                  f.copyWith(status: v, clearStatus: v == null, attentionOnly: v != null ? false : f.attentionOnly),
                ),
              ),
            ),
            ActionChip(
              avatar: const Icon(Icons.swap_horiz, size: 16),
              label: Text(f.direction == null
                  ? l10n.wooSyncFilterDirectionLabel
                  : '${l10n.wooSyncFilterDirectionLabel}: ${wooSyncDirectionLabel(context, f.direction!)}'),
              onPressed: () => _pickFromList(
                title: l10n.wooSyncFilterDirectionLabel,
                options: _directions,
                current: f.direction,
                labelOf: (s) => wooSyncDirectionLabel(context, s),
                onPicked: (v) => widget.onChanged(f.copyWith(direction: v, clearDirection: v == null)),
              ),
            ),
            ActionChip(
              avatar: const Icon(Icons.flag_outlined, size: 16),
              label: Text(f.reviewState == null
                  ? l10n.wooSyncFilterReviewStateLabel
                  : '${l10n.wooSyncFilterReviewStateLabel}: ${wooSyncReviewStateLabel(context, f.reviewState)}'),
              onPressed: () => _pickFromList(
                title: l10n.wooSyncFilterReviewStateLabel,
                options: _reviewStates,
                current: f.reviewState,
                labelOf: (s) => wooSyncReviewStateLabel(context, s),
                onPicked: (v) => widget.onChanged(f.copyWith(reviewState: v, clearReviewState: v == null)),
              ),
            ),
            if (!f.isEmpty)
              ActionChip(
                avatar: const Icon(Icons.clear, size: 16),
                label: Text(l10n.wooSyncClearFilters),
                onPressed: () {
                  _searchController.clear();
                  widget.onChanged(const WooSyncFilters());
                },
              ),
          ],
        ),
      ],
    );
  }
}
