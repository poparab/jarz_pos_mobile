// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'b2b_models.freezed.dart';
part 'b2b_models.g.dart';

/// A card on the B2B sales pipeline (Lead or Opportunity).
@freezed
class B2bCard with _$B2bCard {
  const factory B2bCard({
    required String doctype,
    required String name,
    required String title,
    required String stage,
    String? owner,
    @JsonKey(name: 'lead_score') int? leadScore,
    String? customer,
    @JsonKey(name: 'last_activity') String? lastActivity,
  }) = _B2bCard;

  factory B2bCard.fromJson(Map<String, dynamic> json) =>
      _$B2bCardFromJson(json);
}

/// The full pipeline: ordered stage names + cards grouped by stage.
@freezed
class B2bPipeline with _$B2bPipeline {
  const factory B2bPipeline({
    required List<String> stages,
    required Map<String, List<B2bCard>> columns,
  }) = _B2bPipeline;

  factory B2bPipeline.fromJson(Map<String, dynamic> json) {
    final stagesRaw = (json['stages'] as List?) ?? const [];
    final stages = stagesRaw.map((e) => e.toString()).toList();

    final columnsRaw = (json['columns'] as Map?) ?? const {};
    final columns = <String, List<B2bCard>>{};
    columnsRaw.forEach((key, value) {
      final cards = (value as List? ?? const [])
          .whereType<Map>()
          .map((raw) => B2bCard.fromJson(Map<String, dynamic>.from(raw)))
          .toList();
      columns[key.toString()] = cards;
    });

    return B2bPipeline(stages: stages, columns: columns);
  }
}

/// Contact details for a pipeline account.
@freezed
class B2bContact with _$B2bContact {
  const factory B2bContact({
    @JsonKey(name: 'mobile_no') String? mobileNo,
    @JsonKey(name: 'email_id') String? emailId,
    String? phone,
  }) = _B2bContact;

  factory B2bContact.fromJson(Map<String, dynamic> json) =>
      _$B2bContactFromJson(json);
}

/// A recent invoice shown on the account detail screen.
@freezed
class B2bRecentInvoice with _$B2bRecentInvoice {
  const factory B2bRecentInvoice({
    required String name,
    @JsonKey(name: 'posting_date') String? postingDate,
    @JsonKey(name: 'grand_total') double? grandTotal,
    @JsonKey(name: 'custom_order_purpose') String? orderPurpose,
    String? status,
  }) = _B2bRecentInvoice;

  factory B2bRecentInvoice.fromJson(Map<String, dynamic> json) =>
      _$B2bRecentInvoiceFromJson(json);
}

/// An open ToDo associated with the account.
@freezed
class B2bTodo with _$B2bTodo {
  const factory B2bTodo({
    required String name,
    String? description,
    String? date,
  }) = _B2bTodo;

  factory B2bTodo.fromJson(Map<String, dynamic> json) =>
      _$B2bTodoFromJson(json);
}

/// Full account detail for a Lead or Opportunity.
@freezed
class B2bAccount with _$B2bAccount {
  const factory B2bAccount({
    required String doctype,
    required String name,
    required String title,
    required String stage,
    String? owner,
    @Default(B2bContact()) B2bContact contact,
    String? customer,
    @JsonKey(name: 'predicted_next_order') String? predictedNextOrder,
    @JsonKey(name: 'avg_order_cycle_days') double? avgOrderCycleDays,
    @JsonKey(name: 'recent_invoices')
    @Default(<B2bRecentInvoice>[])
    List<B2bRecentInvoice> recentInvoices,
    @JsonKey(name: 'open_todos') @Default(<B2bTodo>[]) List<B2bTodo> openTodos,
  }) = _B2bAccount;

  factory B2bAccount.fromJson(Map<String, dynamic> json) =>
      _$B2bAccountFromJson(json);
}

/// A follow-up ToDo on the Today screen.
@freezed
class FollowupItem with _$FollowupItem {
  const factory FollowupItem({
    required String name,
    @JsonKey(name: 'reference_type') String? referenceType,
    @JsonKey(name: 'reference_name') String? referenceName,
    String? description,
    String? date,
  }) = _FollowupItem;

  factory FollowupItem.fromJson(Map<String, dynamic> json) =>
      _$FollowupItemFromJson(json);
}

/// A reorder-due card (customer predicted to be due for a reorder).
@freezed
class ReorderDueItem with _$ReorderDueItem {
  const factory ReorderDueItem({
    required String name,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'last_order_date') String? lastOrderDate,
    @JsonKey(name: 'avg_basket_value') double? avgBasketValue,
    @JsonKey(name: 'predicted_next_order') String? predictedNextOrder,
  }) = _ReorderDueItem;

  factory ReorderDueItem.fromJson(Map<String, dynamic> json) =>
      _$ReorderDueItemFromJson(json);
}

/// The Today screen payload: todos + reorder-due cards.
@freezed
class B2bFollowups with _$B2bFollowups {
  const factory B2bFollowups({
    @Default(<FollowupItem>[]) List<FollowupItem> todos,
    @JsonKey(name: 'reorder_due')
    @Default(<ReorderDueItem>[])
    List<ReorderDueItem> reorderDue,
  }) = _B2bFollowups;

  factory B2bFollowups.fromJson(Map<String, dynamic> json) =>
      _$B2bFollowupsFromJson(json);
}

/// The response from request_sample / place_b2b_order: binds a customer +
/// order purpose (+ optional price list) for the existing POS cart flow.
@freezed
class OrderBinding with _$OrderBinding {
  const factory OrderBinding({
    required String customer,
    @JsonKey(name: 'order_purpose') required String orderPurpose,
    @JsonKey(name: 'price_list') String? priceList,
  }) = _OrderBinding;

  factory OrderBinding.fromJson(Map<String, dynamic> json) =>
      _$OrderBindingFromJson(json);
}
