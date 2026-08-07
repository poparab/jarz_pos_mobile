import '../domain/invoice_alert.dart';

class OrderAlertState {
  static const Object _sentinel = Object();

  final List<InvoiceAlert> queue;
  final InvoiceAlert? active;
  final bool isAcknowledging;

  /// Invoice ids the user silenced one by one.
  ///
  /// Mute is deliberately scoped to an invoice rather than being a single
  /// device-wide flag: a flag silenced *the next* order too, so a manager who
  /// muted one alarm stopped hearing every order after it until the queue
  /// happened to empty.
  final Set<String> mutedInvoiceIds;

  /// Device-wide mute from Settings. Mirrors the persisted preference.
  final bool globalMute;

  final String? error;
  final DateTime? lastSynced;

  const OrderAlertState({
    this.queue = const [],
    this.active,
    this.isAcknowledging = false,
    this.mutedInvoiceIds = const <String>{},
    this.globalMute = false,
    this.error,
    this.lastSynced,
  });

  bool get hasActive => active != null;

  /// Whether the *currently shown* alert is silenced. Derived, never stored —
  /// a stored copy is what used to drift out of sync with the muted invoice.
  bool get isMuted =>
      globalMute || (active != null && mutedInvoiceIds.contains(active!.invoiceId));

  bool isInvoiceMuted(String invoiceId) =>
      globalMute || mutedInvoiceIds.contains(invoiceId);

  OrderAlertState copyWith({
    List<InvoiceAlert>? queue,
    Object? active = _sentinel,
    bool? isAcknowledging,
    Set<String>? mutedInvoiceIds,
    bool? globalMute,
    String? error,
    bool clearError = false,
    DateTime? lastSynced,
  }) {
    return OrderAlertState(
      queue: queue ?? this.queue,
      active: active == _sentinel ? this.active : active as InvoiceAlert?,
      isAcknowledging: isAcknowledging ?? this.isAcknowledging,
      mutedInvoiceIds: mutedInvoiceIds ?? this.mutedInvoiceIds,
      globalMute: globalMute ?? this.globalMute,
      error: clearError ? null : (error ?? this.error),
      lastSynced: lastSynced ?? this.lastSynced,
    );
  }
}
