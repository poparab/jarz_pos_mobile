import 'dart:async';

import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';
import '../localization/localized_formatters.dart';
import '../utils/responsive_utils.dart';

/// One page of a module's history, as the backend returns it.
class HistoryPage<T> {
  final List<T> items;
  final int total;

  const HistoryPage({required this.items, required this.total});

  const HistoryPage.empty()
      : items = const [],
        total = 0;
}

/// What the sheet asks the backend for.
class HistoryQuery {
  final int page;
  final int limit;
  final String? search;
  final DateTime? fromDate;
  final DateTime? toDate;

  const HistoryQuery({
    required this.page,
    required this.limit,
    this.search,
    this.fromDate,
    this.toDate,
  });
}

/// A paginated, searchable list of documents a module has already submitted.
///
/// Every screen that posts a document needs to answer the same question — "what
/// did I already send?" — and four of them could not: Stock Transfer, Cash
/// Transfer, Inventory Count and Shift each submitted into a void. Rather than
/// grow four near-identical history tabs, the chrome, paging, debounced search,
/// date range and the loading/error/empty states live here once; a module
/// supplies only [fetch] and [itemBuilder].
class HistorySheet<T> extends StatefulWidget {
  /// Sheet title, e.g. "Transfer history".
  final String title;

  /// Loads one page. Called on open, on every filter change, and on scroll.
  final Future<HistoryPage<T>> Function(HistoryQuery query) fetch;

  /// Renders one row.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Shown when the (possibly filtered) result set is empty.
  final String emptyMessage;

  /// Placeholder in the search field. Omit to hide search entirely — a module
  /// with nothing text-searchable should not show a box that does nothing.
  final String? searchHint;

  /// Whether to offer the from/to date range.
  final bool showDateRange;

  /// Extra filter row rendered under the search box (chips, dropdowns).
  final Widget Function(BuildContext context, VoidCallback refresh)?
      filterBuilder;

  final int pageSize;

  const HistorySheet({
    super.key,
    required this.title,
    required this.fetch,
    required this.itemBuilder,
    required this.emptyMessage,
    this.searchHint,
    this.showDateRange = true,
    this.filterBuilder,
    this.pageSize = 30,
  });

  /// Open the sheet as a centred dialog, sized for the current breakpoint.
  static Future<void> show<T>(
    BuildContext context, {
    required String title,
    required Future<HistoryPage<T>> Function(HistoryQuery query) fetch,
    required Widget Function(BuildContext context, T item) itemBuilder,
    required String emptyMessage,
    String? searchHint,
    bool showDateRange = true,
    Widget Function(BuildContext context, VoidCallback refresh)? filterBuilder,
    int pageSize = 30,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: ResponsiveUtils.getDialogWidth(context,
              small: 380, medium: 560, large: 700),
          height: ResponsiveUtils.getDialogHeight(context,
              phoneFraction: 0.82, tabletFraction: 0.72, max: 620),
          child: HistorySheet<T>(
            title: title,
            fetch: fetch,
            itemBuilder: itemBuilder,
            emptyMessage: emptyMessage,
            searchHint: searchHint,
            showDateRange: showDateRange,
            filterBuilder: filterBuilder,
            pageSize: pageSize,
          ),
        ),
      ),
    );
  }

  @override
  State<HistorySheet<T>> createState() => _HistorySheetState<T>();
}

class _HistorySheetState<T> extends State<HistorySheet<T>> {
  final List<T> _items = [];
  final _searchController = TextEditingController();

  int _total = 0;
  int _page = 0;
  bool _loading = false;
  Object? _error;
  String _search = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  Timer? _searchDebounce;

  /// Monotonic per-load token. A slow first page must not land after — and
  /// overwrite — the results of the filter the user has since typed.
  int _loadToken = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool append = false}) async {
    final token = ++_loadToken;
    setState(() {
      _loading = true;
      if (!append) _error = null;
    });
    try {
      final page = await widget.fetch(HistoryQuery(
        page: _page,
        limit: widget.pageSize,
        search: _search.isEmpty ? null : _search,
        fromDate: _fromDate,
        toDate: _toDate,
      ));
      if (!mounted || token != _loadToken) return;
      setState(() {
        if (!append) _items.clear();
        _items.addAll(page.items);
        _total = page.total;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted || token != _loadToken) return;
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  Future<void> _refresh() async {
    _page = 0;
    await _load();
  }

  void _loadMore() {
    if (_loading || _items.length >= _total) return;
    _page++;
    _load(append: true);
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _search = value.trim();
      _refresh();
    });
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
    );
    if (picked == null) return;
    setState(() {
      _fromDate = picked.start;
      _toDate = picked.end;
    });
    _refresh();
  }

  void _clearRange() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(
            children: [
              const Icon(Icons.history),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.title, style: theme.textTheme.titleMedium),
              ),
              IconButton(
                tooltip: l10n.commonRetry,
                icon: const Icon(Icons.refresh),
                onPressed: _refresh,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        _filterBar(context),
        Expanded(child: _list(context)),
      ],
    );
  }

  Widget _filterBar(BuildContext context) {
    final l10n = context.l10n;
    final hasSearch = widget.searchHint != null;
    final extra = widget.filterBuilder?.call(context, _refresh);
    if (!hasSearch && !widget.showDateRange && extra == null) {
      return const SizedBox.shrink();
    }
    final rangeLabel = _fromDate == null || _toDate == null
        ? l10n.historyDateRangeAll
        : l10n.historyDateRangeValue(
            formatDate(context, _fromDate!, pattern: 'MMM d'),
            formatDate(context, _toDate!, pattern: 'MMM d, yyyy'),
          );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasSearch)
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 20),
                hintText: widget.searchHint,
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        tooltip: l10n.commonClear,
                        onPressed: () {
                          _searchController.clear();
                          _search = '';
                          _refresh();
                        },
                      ),
              ),
              onChanged: _onSearchChanged,
            ),
          if (widget.showDateRange) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(rangeLabel, overflow: TextOverflow.ellipsis),
                    onPressed: _pickRange,
                  ),
                ),
                if (_fromDate != null)
                  IconButton(
                    tooltip: l10n.commonClear,
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: _clearRange,
                  ),
              ],
            ),
          ],
          if (extra != null) ...[const SizedBox(height: 8), extra],
        ],
      ),
    );
  }

  Widget _list(BuildContext context) {
    final l10n = context.l10n;
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.commonErrorWithDetails('$_error'),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _refresh,
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(widget.emptyMessage, textAlign: TextAlign.center),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels > scroll.metrics.maxScrollExtent - 200) {
            _loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
          itemCount: _items.length + (_items.length < _total ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _items.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return widget.itemBuilder(context, _items[index]);
          },
        ),
      ),
    );
  }
}
