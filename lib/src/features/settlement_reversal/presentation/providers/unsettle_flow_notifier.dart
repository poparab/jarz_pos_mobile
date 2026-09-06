import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/unsettle_preview.dart';
import '../../data/settlement_reversal_service.dart';

enum UnsettleStep {
  loadingPreview,
  previewReady,
  committing,
  success,
  previewError,
  commitError,
}

class UnsettleState {
  final UnsettleStep step;
  final String journalEntry;
  final UnsettlePreview? preview;
  final Object? error;
  final Map<String, dynamic>? result;

  const UnsettleState({
    required this.step,
    required this.journalEntry,
    this.preview,
    this.error,
    this.result,
  });

  UnsettleState copyWith({
    UnsettleStep? step,
    UnsettlePreview? preview,
    Object? error,
    Map<String, dynamic>? result,
  }) {
    return UnsettleState(
      step: step ?? this.step,
      journalEntry: journalEntry,
      preview: preview ?? this.preview,
      error: error,
      result: result ?? this.result,
    );
  }
}

/// Drives one reversal attempt end to end: preview -> (optional re-preview on
/// an expired/mismatched token) -> commit -> result.
///
/// Scoped per Journal Entry via `.family` and `.autoDispose`: closing the
/// dialog that owns it forgets the in-memory preview token, which is exactly
/// right — a stale token must never be reused across dialog opens.
class UnsettleFlowNotifier extends StateNotifier<UnsettleState> {
  final SettlementReversalService _service;

  UnsettleFlowNotifier(this._service, String journalEntry)
      : super(UnsettleState(step: UnsettleStep.loadingPreview, journalEntry: journalEntry)) {
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    state = state.copyWith(step: UnsettleStep.loadingPreview);
    try {
      final preview = await _service.preview(journalEntry: state.journalEntry);
      state = state.copyWith(step: UnsettleStep.previewReady, preview: preview);
    } catch (e) {
      state = state.copyWith(step: UnsettleStep.previewError, error: e);
    }
  }

  /// Re-mints the preview (and its token) after an expiry, or after the user
  /// asks to retry from an error — this is the "handle expiry gracefully"
  /// path instead of leaving a dead token in front of the user.
  Future<void> refreshPreview() => _loadPreview();

  Future<bool> confirm({String? reason}) async {
    final preview = state.preview;
    final token = preview?.previewToken;
    if (preview == null || token == null || token.isEmpty) {
      // No usable token — the most useful recovery is a fresh preview, not a
      // raw "missing token" error.
      await _loadPreview();
      return false;
    }
    state = state.copyWith(step: UnsettleStep.committing);
    try {
      final result = await _service.commit(
        journalEntry: state.journalEntry,
        previewToken: token,
        reason: reason,
      );
      state = state.copyWith(step: UnsettleStep.success, result: result);
      return true;
    } catch (e) {
      state = state.copyWith(step: UnsettleStep.commitError, error: e);
      return false;
    }
  }
}

final unsettleFlowNotifierProvider = StateNotifierProvider.autoDispose
    .family<UnsettleFlowNotifier, UnsettleState, String>((ref, journalEntry) {
  final service = ref.watch(settlementReversalServiceProvider);
  return UnsettleFlowNotifier(service, journalEntry);
});
