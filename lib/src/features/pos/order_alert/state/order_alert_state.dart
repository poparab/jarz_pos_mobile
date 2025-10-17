import '../domain/invoice_alert.dart';

class OrderAlertState {
  static const Object _sentinel = Object();

  final List<InvoiceAlert> queue;
  final InvoiceAlert? active;
  final bool isAcknowledging;
  final bool isMuted;
  final String? error;
  final DateTime? lastSynced;

  const OrderAlertState({
    this.queue = const [],
    this.active,
    this.isAcknowledging = false,
    this.isMuted = false,
    this.error,
    this.lastSynced,
  });

  bool get hasActive => active != null;

  OrderAlertState copyWith({
    List<InvoiceAlert>? queue,
    Object? active = _sentinel,
    bool? isAcknowledging,
    bool? isMuted,
    String? error,
    bool clearError = false,
    DateTime? lastSynced,
  }) {
    return OrderAlertState(
      queue: queue ?? this.queue,
      active: active == _sentinel ? this.active : active as InvoiceAlert?,
      isAcknowledging: isAcknowledging ?? this.isAcknowledging,
      isMuted: isMuted ?? this.isMuted,
      error: clearError ? null : (error ?? this.error),
      lastSynced: lastSynced ?? this.lastSynced,
    );
  }
}
