import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/cash_custody_repository.dart';
import '../../models/cash_custody_models.dart';

/// Searchable employee picker over `list_custody_candidates`.
///
/// Returns the chosen employee, or null if the dialog is dismissed.
class CustodyCandidatePicker extends ConsumerStatefulWidget {
  const CustodyCandidatePicker({super.key});

  static Future<CustodyCandidate?> show(BuildContext context) {
    return showDialog<CustodyCandidate>(
      context: context,
      builder: (_) => const CustodyCandidatePicker(),
    );
  }

  @override
  ConsumerState<CustodyCandidatePicker> createState() =>
      _CustodyCandidatePickerState();
}

class _CustodyCandidatePickerState
    extends ConsumerState<CustodyCandidatePicker> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<CustodyCandidate> _results = const [];
  bool _loading = false;
  Object? _error;

  /// Drops a slow answer to an older query that lands after a newer one.
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(value));
  }

  Future<void> _search(String query) async {
    final id = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await ref
          .read(cashCustodyRepositoryProvider)
          .listCandidates(search: query);
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget body;
    if (_loading && _results.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Text(
          context.userErrorMessage(_error),
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    } else if (_results.isEmpty) {
      body = Center(child: Text(l10n.custodyNoCandidates));
    } else {
      body = ListView.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final candidate = _results[index];
          return ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(candidate.displayName),
            subtitle: Text(
              [candidate.employee, if (candidate.user != null) candidate.user!]
                  .join(' • '),
            ),
            onTap: () => Navigator.of(context).pop(candidate),
          );
        },
      );
    }

    return AlertDialog(
      title: Text(l10n.custodyAddHolder),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.custodySearchEmployee,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: _onChanged,
            ),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            const SizedBox(height: 8),
            Expanded(child: body),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
      ],
    );
  }
}
