import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/frappe_error_message.dart';
import '../data/manufacturing_service.dart';
import '../data/models/sop.dart';

// ── Fetching ────────────────────────────────────────────────────────────────

/// Family key for [sopForItemProvider].
///
/// A `family` argument that is not value-equal makes the provider refetch on
/// every rebuild, because a fresh `SopRequest(...)` instance would key a fresh
/// provider each time. Same reasoning as `ReportRange` in
/// `features/reports/state/reports_providers.dart`.
@immutable
class SopRequest {
  const SopRequest({
    required this.itemCode,
    this.bom,
    this.batches = 1.0,
  });

  final String itemCode;

  /// Optional explicit BOM. Included in equality: two requests for the same
  /// item against different BOMs are different documents, and keying them the
  /// same would serve one from the other's cache.
  final String? bom;

  final double batches;

  @override
  bool operator ==(Object other) =>
      other is SopRequest &&
      other.itemCode == itemCode &&
      other.bom == bom &&
      other.batches == batches;

  @override
  int get hashCode => Object.hash(itemCode, bom, batches);

  @override
  String toString() => 'SopRequest($itemCode, bom: $bom, batches: $batches)';
}

/// The SOP for an item, already scaled server-side for [SopRequest.batches].
///
/// Resolves to `hasSop: false` rather than throwing when the item has none —
/// most items have no SOP and that is a normal answer.
final sopForItemProvider =
    FutureProvider.autoDispose.family<SopDocument, SopRequest>((ref, request) {
  return ref.read(manufacturingServiceProvider).getSopForItem(
        itemCode: request.itemCode,
        bom: request.bom,
        batches: request.batches,
      );
});

/// The SOP version stamped on a Work Order when it started, not whatever is
/// active now.
final sopForWorkOrderProvider =
    FutureProvider.autoDispose.family<SopDocument, String>((ref, workOrder) {
  return ref.read(manufacturingServiceProvider).getSopForWorkOrder(workOrder);
});

// ── Execution state ─────────────────────────────────────────────────────────

/// What the operator has recorded against one step.
@immutable
class SopStepProgress {
  const SopStepProgress({
    this.confirmed = false,
    this.value,
    this.fileUrl,
    this.localPhotoPath,
  });

  final bool confirmed;

  /// Number / temperature reading, already range-checked by the capture field.
  final double? value;

  /// Server-side URL of an uploaded photo.
  final String? fileUrl;

  /// Set when a photo was taken but the upload failed. The photo genuinely
  /// exists, so the operator is not blocked — but nothing reached the server,
  /// and the capture field says so out loud rather than pretending it did.
  final String? localPhotoPath;

  bool get hasCapture =>
      value != null ||
      (fileUrl != null && fileUrl!.isNotEmpty) ||
      (localPhotoPath != null && localPhotoPath!.isNotEmpty);

  /// True when a photo was taken but never made it to the server.
  bool get photoIsLocalOnly =>
      (fileUrl == null || fileUrl!.isEmpty) &&
      (localPhotoPath != null && localPhotoPath!.isNotEmpty);

  SopStepProgress copyWith({
    bool? confirmed,
    double? value,
    bool clearValue = false,
    String? fileUrl,
    String? localPhotoPath,
    bool clearPhoto = false,
  }) {
    return SopStepProgress(
      confirmed: confirmed ?? this.confirmed,
      value: clearValue ? null : (value ?? this.value),
      fileUrl: clearPhoto ? null : (fileUrl ?? this.fileUrl),
      localPhotoPath:
          clearPhoto ? null : (localPhotoPath ?? this.localPhotoPath),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SopStepProgress &&
      other.confirmed == confirmed &&
      other.value == value &&
      other.fileUrl == fileUrl &&
      other.localPhotoPath == localPhotoPath;

  @override
  int get hashCode => Object.hash(confirmed, value, fileUrl, localPhotoPath);
}

/// Where the operator is in the instructions and what they have recorded.
@immutable
class SopExecutionState {
  const SopExecutionState({
    this.steps = const <SopStep>[],
    this.currentIndex = 0,
    this.progress = const <int, SopStepProgress>{},
  });

  final List<SopStep> steps;
  final int currentIndex;

  /// Keyed by list index rather than `step_no`: the index is guaranteed unique
  /// within a document, a step number is not.
  final Map<int, SopStepProgress> progress;

  int get total => steps.length;
  bool get isEmpty => steps.isEmpty;

  SopStep? get currentStep =>
      (currentIndex >= 0 && currentIndex < steps.length)
          ? steps[currentIndex]
          : null;

  SopStepProgress progressAt(int index) =>
      progress[index] ?? const SopStepProgress();

  bool isSatisfiedAt(int index) {
    if (index < 0 || index >= steps.length) return false;
    final recorded = progressAt(index);
    return steps[index].isSatisfied(
      confirmed: recorded.confirmed,
      captured: recorded.hasCapture,
    );
  }

  List<bool> get satisfiedFlags => List<bool>.generate(
        steps.length,
        isSatisfiedAt,
        growable: false,
      );

  int get satisfiedCount {
    var count = 0;
    for (var i = 0; i < steps.length; i++) {
      if (isSatisfiedAt(i)) count++;
    }
    return count;
  }

  /// Share of steps actually completed — not "how far the pager scrolled".
  /// A skipped-looking bar is the point: it tracks work done, not pages seen.
  double get progressFraction =>
      steps.isEmpty ? 0 : satisfiedCount / steps.length;

  bool get isOnFirstStep => currentIndex <= 0;
  bool get isOnLastStep => steps.isNotEmpty && currentIndex >= steps.length - 1;

  /// The gate: the current step must be confirmed and captured before the
  /// operator may move on.
  bool get canAdvance => isSatisfiedAt(currentIndex);

  bool get isComplete => steps.isNotEmpty && satisfiedCount == steps.length;

  SopExecutionState copyWith({
    List<SopStep>? steps,
    int? currentIndex,
    Map<int, SopStepProgress>? progress,
  }) {
    return SopExecutionState(
      steps: steps ?? this.steps,
      currentIndex: currentIndex ?? this.currentIndex,
      progress: progress ?? this.progress,
    );
  }
}

/// Per-execution progress, keyed by Work Order name (or item code when the SOP
/// is only being read).
///
/// Deliberately NOT persisted to Hive: an interrupted SOP restarting from step
/// one is acceptable in v1, and a half-restored checklist that claims steps
/// were done is worse than an obviously empty one.
final sopExecutionProvider = NotifierProvider.autoDispose
    .family<SopExecutionNotifier, SopExecutionState, String>(
  SopExecutionNotifier.new,
);

class SopExecutionNotifier
    extends AutoDisposeFamilyNotifier<SopExecutionState, String> {
  @override
  SopExecutionState build(String arg) => const SopExecutionState();

  /// Loads the step list. Idempotent — re-binding the same steps keeps the
  /// operator's place, so a rebuild never wipes a half-finished checklist.
  void bindSteps(List<SopStep> steps) {
    if (listEquals(state.steps, steps)) return;
    state = SopExecutionState(steps: List<SopStep>.unmodifiable(steps));
  }

  void setConfirmed(int index, bool confirmed) {
    _mutate(index, (current) => current.copyWith(confirmed: confirmed));
  }

  /// Records (or with a null [value], clears) a numeric reading.
  void recordValue(int index, double? value) {
    _mutate(
      index,
      (current) => value == null
          ? current.copyWith(clearValue: true)
          : current.copyWith(value: value),
    );
  }

  /// Records a photo. [fileUrl] is the uploaded URL; [localPath] is set
  /// instead when the upload failed.
  void recordPhoto(int index, {String? fileUrl, String? localPath}) {
    _mutate(
      index,
      (current) => (fileUrl == null && localPath == null)
          ? current.copyWith(clearPhoto: true)
          : current.copyWith(fileUrl: fileUrl, localPhotoPath: localPath),
    );
  }

  /// Moves to the next step. Returns false — and does nothing — when the
  /// current step is not satisfied yet.
  bool next() {
    if (!state.canAdvance) return false;
    if (state.isOnLastStep) return false;
    state = state.copyWith(currentIndex: state.currentIndex + 1);
    return true;
  }

  void previous() {
    if (state.isOnFirstStep) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }

  /// Jumps to [index]. Moving forward is still gated on the current step being
  /// satisfied; moving back is always allowed so the operator can re-read.
  bool goTo(int index) {
    if (index < 0 || index >= state.steps.length) return false;
    if (index > state.currentIndex && !state.canAdvance) return false;
    state = state.copyWith(currentIndex: index);
    return true;
  }

  void _mutate(
    int index,
    SopStepProgress Function(SopStepProgress current) change,
  ) {
    if (index < 0 || index >= state.steps.length) return;
    final next = Map<int, SopStepProgress>.from(state.progress);
    next[index] = change(state.progressAt(index));
    state = state.copyWith(progress: next);
  }
}

// ── Photo upload ────────────────────────────────────────────────────────────

/// Uploads a captured photo and hands back its file URL.
///
/// `record_sop_step_capture` takes a `file_url`, so the bytes have to land
/// somewhere first. This uses Frappe's core `upload_file`, which every logged-in
/// user can reach, rather than a POS-specific endpoint.
final sopPhotoUploaderProvider = Provider<SopPhotoUploader>(
  (ref) => SopPhotoUploader(ref.watch(dioProvider)),
);

class SopPhotoUploader {
  const SopPhotoUploader(this._dio);

  final Dio _dio;

  /// Frappe core endpoint. Lives in `ApiEndpoints` like every other path so a
  /// route change is a one-file edit rather than a search.
  static const String uploadPath = ApiEndpoints.uploadFile;

  Future<String> upload({
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
        // Public so the thumbnail renders for an operator with desk_access = 0.
        'is_private': 0,
        'folder': 'Home/Attachments',
      });
      final resp = await _dio.post(uploadPath, data: form);

      final payload = resp.data;
      final message = (payload is Map && payload['message'] is Map)
          ? Map<String, dynamic>.from(payload['message'] as Map)
          : (payload is Map ? Map<String, dynamic>.from(payload) : null);
      final url = (message?['file_url'] ?? '').toString();
      if (url.isEmpty) {
        throw Exception('Upload returned no file URL');
      }
      return url;
    } catch (error) {
      throw mapFrappeError(error, fallback: 'Failed to upload the photo');
    }
  }
}
