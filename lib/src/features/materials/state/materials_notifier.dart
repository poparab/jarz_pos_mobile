import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/materials_repository.dart';
import '../data/models/sales_material.dart';

/// The shareable library, fetched once per session.
///
/// Deliberately NOT auto-disposed: a rep opens the send sheet several times an
/// afternoon and the library changes about once a quarter, so re-fetching it
/// per sheet would spend the one thing they are short of on a pavement — the
/// signal. Call `ref.invalidate` after a manager edits the library.
final materialLibraryProvider = FutureProvider<MaterialLibrary>((ref) async {
  return ref.read(materialsRepositoryProvider).getLibrary();
});

/// Links already sent to one record, keyed `"<doctype>|<name>"`.
///
/// Auto-disposed because it is per-lead and goes stale the moment a new link
/// is minted; the send flow invalidates it.
final materialSharesProvider =
    FutureProvider.autoDispose.family<List<MaterialShareSummary>, String>(
  (ref, key) async {
    final parts = key.split('|');
    final doctype = parts.length > 1 ? parts.first : 'Lead';
    final name = parts.length > 1 ? parts.sublist(1).join('|') : key;
    if (name.trim().isEmpty) return const <MaterialShareSummary>[];
    return ref.read(materialsRepositoryProvider).getShares(
          referenceName: name,
          referenceDoctype: doctype,
        );
  },
);

/// Builds the key [materialSharesProvider] takes. One helper so the two
/// halves of the composite key can never drift between caller and provider.
String materialSharesKey(String referenceDoctype, String referenceName) =>
    '$referenceDoctype|$referenceName';
