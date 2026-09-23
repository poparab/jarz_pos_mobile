// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/order_display_id.dart';
import '../../../journey/data/models/journey_note.dart';

part 'b2b_models.freezed.dart';
part 'b2b_models.g.dart';

/// A card on the B2B sales pipeline (Lead or Opportunity).
@freezed
class B2bCard with _$B2bCard {
  const B2bCard._();

  const factory B2bCard({
    required String doctype,
    required String name,
    required String title,
    @Default('Lead') String stage,
    String? owner,
    @JsonKey(name: 'lead_score') int? leadScore,
    String? customer,
    @JsonKey(name: 'last_activity') String? lastActivity,
    // How many of this account's labels need printing (0 when none / when the
    // backend predates the labels feature — absent keys default here).
    @JsonKey(name: 'label_alert') @Default(0) int labelAlert,
    // ── Journey diary summary ──────────────────────────────────────────
    // Folded in by `crm.get_b2b_pipeline` so the board shows when a prospect
    // was last visited and what is due, without a request per card.
    @JsonKey(name: 'journey_count') @Default(0) int journeyCount,
    @JsonKey(name: 'last_journey_date') String? lastJourneyDate,
    @JsonKey(name: 'last_journey_type') String? lastJourneyType,
    @JsonKey(name: 'last_journey_note') String? lastJourneyNote,
    @JsonKey(name: 'last_journey_contact') String? lastJourneyContact,
    @JsonKey(name: 'next_action_date') String? nextActionDate,
    @JsonKey(name: 'next_action') String? nextAction,
  }) = _B2bCard;

  factory B2bCard.fromJson(Map<String, dynamic> json) =>
      _$B2bCardFromJson(json);

  /// The card's journey read-out, in the shape the shared badge widget takes.
  JourneySummary get journey => JourneySummary(
    journeyCount: journeyCount,
    lastJourneyDate: lastJourneyDate,
    lastJourneyType: lastJourneyType,
    lastJourneyNote: lastJourneyNote,
    lastJourneyContact: lastJourneyContact,
    nextActionDate: nextActionDate,
    nextAction: nextAction,
  );
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

// -- Lenient scalar converters ----------------------------------------------
// Frappe hands numbers back as strings from some query paths and booleans as
// 0/1, so every stat on the branch / merge payloads is read through these.

double? _looseDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

int? _looseInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final text = value.trim();
    return int.tryParse(text) ?? double.tryParse(text)?.toInt();
  }
  return null;
}

bool _looseBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final text = value.trim().toLowerCase();
    return text == '1' || text == 'true' || text == 'yes';
  }
  return false;
}

String? _looseString(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

class _NullableDoubleConverter implements JsonConverter<double?, Object?> {
  const _NullableDoubleConverter();
  @override
  double? fromJson(Object? json) => _looseDouble(json);
  @override
  Object? toJson(double? object) => object;
}

class _DoubleConverter implements JsonConverter<double, Object?> {
  const _DoubleConverter();
  @override
  double fromJson(Object? json) => _looseDouble(json) ?? 0;
  @override
  Object? toJson(double object) => object;
}

class _NullableIntConverter implements JsonConverter<int?, Object?> {
  const _NullableIntConverter();
  @override
  int? fromJson(Object? json) => _looseInt(json);
  @override
  Object? toJson(int? object) => object;
}

class _IntConverter implements JsonConverter<int, Object?> {
  const _IntConverter();
  @override
  int fromJson(Object? json) => _looseInt(json) ?? 0;
  @override
  Object? toJson(int object) => object;
}

class _BoolConverter implements JsonConverter<bool, Object?> {
  const _BoolConverter();
  @override
  bool fromJson(Object? json) => _looseBool(json);
  @override
  Object? toJson(bool object) => object;
}

class _NullableStringConverter implements JsonConverter<String?, Object?> {
  const _NullableStringConverter();
  @override
  String? fromJson(Object? json) => _looseString(json);
  @override
  Object? toJson(String? object) => object;
}

class _StringListConverter implements JsonConverter<List<String>, Object?> {
  const _StringListConverter();
  @override
  List<String> fromJson(Object? json) => json is List
      ? json
            .map((e) => e?.toString().trim() ?? '')
            .where((e) => e.isNotEmpty)
            .toList()
      : const <String>[];
  @override
  Object? toJson(List<String> object) => object;
}

/// An account invoice. The account screen's recent list and the per-branch
/// invoice screen share this shape. The branch keys are absent on servers
/// that predate branches and default to null.
@freezed
class B2bRecentInvoice with _$B2bRecentInvoice {
  const B2bRecentInvoice._();

  const factory B2bRecentInvoice({
    required String name,
    @JsonKey(name: 'woo_order_id') @_NullableIntConverter() int? wooOrderId,
    @JsonKey(name: 'posting_date') String? postingDate,
    @JsonKey(name: 'grand_total')
    @_NullableDoubleConverter()
    double? grandTotal,
    @JsonKey(name: 'outstanding_amount')
    @_NullableDoubleConverter()
    double? outstandingAmount,
    @JsonKey(name: 'custom_order_purpose') String? orderPurpose,
    @JsonKey(name: 'custom_payment_method')
    @_NullableStringConverter()
    String? paymentMethod,
    String? status,
    @JsonKey(name: 'is_return') @_BoolConverter() @Default(false) bool isReturn,
    @JsonKey(name: 'branch_address')
    @_NullableStringConverter()
    String? branchAddress,
    @JsonKey(name: 'branch_name')
    @_NullableStringConverter()
    String? branchName,
  }) = _B2bRecentInvoice;

  /// What the account screen labels this order with.
  String get displayId => orderDisplayId(name, wooOrderId: wooOrderId);

  factory B2bRecentInvoice.fromJson(Map<String, dynamic> json) =>
      _$B2bRecentInvoiceFromJson(json);
}

/// Invoice totals for one branch (or for the invoices matching no branch).
@freezed
class B2bBranchStats with _$B2bBranchStats {
  const factory B2bBranchStats({
    @JsonKey(name: 'invoice_count')
    @_IntConverter()
    @Default(0)
    int invoiceCount,
    @JsonKey(name: 'total_billed')
    @_DoubleConverter()
    @Default(0.0)
    double totalBilled,
    @_DoubleConverter() @Default(0.0) double outstanding,
    @JsonKey(name: 'last_order_date')
    @_NullableStringConverter()
    String? lastOrderDate,
  }) = _B2bBranchStats;

  factory B2bBranchStats.fromJson(Map<String, dynamic> json) =>
      _$B2bBranchStatsFromJson(json);
}

/// Reads `maps` leniently: anything that is not an object becomes null.
class _MapsInfoConverter implements JsonConverter<B2bMapsInfo?, Object?> {
  const _MapsInfoConverter();
  @override
  B2bMapsInfo? fromJson(Object? json) => json is Map
      ? B2bMapsInfo.fromJson(Map<String, dynamic>.from(json))
      : null;
  @override
  Object? toJson(B2bMapsInfo? object) => object?.toJson();
}

/// Reads a branch `source`, treating a missing / blank value as "address"
/// (what every branch was before the Google Maps branches were folded in).
class _BranchSourceConverter implements JsonConverter<String, Object?> {
  const _BranchSourceConverter();
  @override
  String fromJson(Object? json) =>
      _looseString(json)?.toLowerCase() ?? B2bBranch.sourceAddress;
  @override
  Object? toJson(String object) => object;
}

/// The Google Maps side of a branch: one row of the Lead's scraped branch
/// table (or `__self__`, the Lead's own listing).
@freezed
class B2bMapsInfo with _$B2bMapsInfo {
  const B2bMapsInfo._();

  const factory B2bMapsInfo({
    /// The Lead branch-table row id the link endpoint is keyed on.
    @_NullableStringConverter() String? row,
    @JsonKey(name: 'branch_name')
    @_NullableStringConverter()
    String? branchName,
    @_NullableStringConverter() String? area,
    @_NullableStringConverter() String? region,
    @_NullableStringConverter() String? governorate,
    @_NullableDoubleConverter() double? rating,
    @_NullableIntConverter() int? reviews,
    @JsonKey(name: 'maps_url') @_NullableStringConverter() String? mapsUrl,
    @_NullableStringConverter() String? phone,
    @_NullableStringConverter() String? address,
    @_NullableDoubleConverter() double? latitude,
    @_NullableDoubleConverter() double? longitude,
    @JsonKey(name: 'on_talabat')
    @_BoolConverter()
    @Default(false)
    bool onTalabat,
  }) = _B2bMapsInfo;

  factory B2bMapsInfo.fromJson(Map<String, dynamic> json) =>
      _$B2bMapsInfoFromJson(json);

  bool get hasLocation => latitude != null && longitude != null;

  /// Area, region and governorate on one line (may be empty).
  String get areaText => [
    area,
    region,
    governorate,
  ].whereType<String>().toSet().join(' · ');

  /// The listing's name, falling back to where it is.
  String get displayName => branchName ?? area ?? region ?? address ?? '';
}

/// One door of a B2B shop. Either a delivery branch (a named shipping Address
/// on the account's Customer, with its invoice totals — `source == "address"`,
/// optionally carrying the matched Google Maps listing in [maps]) or a Google
/// Maps branch of the Lead that is not a delivery branch yet
/// (`source == "maps"`: no address, zero stats).
@freezed
class B2bBranch with _$B2bBranch {
  const B2bBranch._();

  const factory B2bBranch({
    @JsonKey(name: 'address_name')
    @_NullableStringConverter()
    String? addressName,
    @JsonKey(name: 'branch_name')
    @_NullableStringConverter()
    String? branchName,
    @JsonKey(name: 'address_line1')
    @_NullableStringConverter()
    String? addressLine1,
    @JsonKey(name: 'address_line2')
    @_NullableStringConverter()
    String? addressLine2,
    @_NullableStringConverter() String? city,
    @_NullableStringConverter() String? phone,
    @_NullableStringConverter() String? territory,
    @JsonKey(name: 'territory_missing')
    @_BoolConverter()
    @Default(false)
    bool territoryMissing,
    @JsonKey(name: 'is_primary_address')
    @_BoolConverter()
    @Default(false)
    bool isPrimaryAddress,
    @_NullableDoubleConverter() double? latitude,
    @_NullableDoubleConverter() double? longitude,
    @JsonKey(name: 'member_address_names')
    @_StringListConverter()
    @Default(<String>[])
    List<String> memberAddressNames,
    @JsonKey(name: 'invoice_count')
    @_IntConverter()
    @Default(0)
    int invoiceCount,
    @JsonKey(name: 'total_billed')
    @_DoubleConverter()
    @Default(0.0)
    double totalBilled,
    @_DoubleConverter() @Default(0.0) double outstanding,
    @JsonKey(name: 'last_order_date')
    @_NullableStringConverter()
    String? lastOrderDate,

    /// `"address"` (a delivery branch) or `"maps"` (Google Maps only).
    @_BranchSourceConverter() @Default('address') String source,

    /// The Google Maps listing for this door, when one is known.
    @_MapsInfoConverter() B2bMapsInfo? maps,

    /// How [maps] got attached to a delivery branch: `"linked"` (a rep chose
    /// it) or `"auto"` (matched by name / pin). Null for maps-only entries.
    @JsonKey(name: 'maps_match')
    @_NullableStringConverter()
    String? mapsMatch,
  }) = _B2bBranch;

  factory B2bBranch.fromJson(Map<String, dynamic> json) =>
      _$B2bBranchFromJson(json);

  static const sourceAddress = 'address';
  static const sourceMaps = 'maps';

  /// A Google Maps branch that is not a delivery branch (yet).
  bool get isMapsOnly => source == sourceMaps;

  /// A delivery branch (shipping Address), with or without a Maps listing.
  bool get isDeliveryBranch => !isMapsOnly;

  bool get hasMaps => maps != null;

  /// The Lead branch-table row of [maps], or null.
  String? get mapsRow => maps?.row;

  /// True when [maps] was matched by the server rather than chosen by a rep.
  bool get isMapsAutoMatched => hasMaps && mapsMatch == 'auto';

  /// The Address record the branch filter is keyed on. Empty for a maps-only
  /// entry, which has no invoices to filter.
  String get key => isMapsOnly ? '' : (addressName ?? '');

  /// The name a rep knows the branch by, falling back to its street (or, for
  /// a maps-only entry, to the listing's own name / area).
  String get displayName =>
      branchName ??
      addressLine1 ??
      city ??
      addressName ??
      maps?.displayName ??
      '';

  /// Street, second line and city on one line (may be empty).
  String get addressText =>
      [addressLine1, addressLine2, city].whereType<String>().join(', ');

  bool get hasLocation => latitude != null && longitude != null;

  B2bBranchStats get stats => B2bBranchStats(
    invoiceCount: invoiceCount,
    totalBilled: totalBilled,
    outstanding: outstanding,
    lastOrderDate: lastOrderDate,
  );
}

/// `crm.get_account_invoices`: an account's invoices, optionally narrowed to a
/// single branch (or to the invoices matching no branch).
@freezed
class B2bAccountInvoices with _$B2bAccountInvoices {
  const factory B2bAccountInvoices({
    @_NullableStringConverter() String? customer,
    @_NullableStringConverter() String? branch,
    @Default(<B2bRecentInvoice>[]) List<B2bRecentInvoice> invoices,
    @Default(B2bBranchStats()) B2bBranchStats summary,
    @_BoolConverter() @Default(false) bool truncated,
  }) = _B2bAccountInvoices;

  factory B2bAccountInvoices.fromJson(Map<String, dynamic> json) =>
      _$B2bAccountInvoicesFromJson(json);
}

/// An account the current one can be merged into as a branch.
@freezed
class B2bMergeCandidate with _$B2bMergeCandidate {
  const B2bMergeCandidate._();

  const factory B2bMergeCandidate({
    @Default('Lead') String doctype,
    required String name,
    @_NullableStringConverter() String? title,
    @_NullableStringConverter() String? customer,
    @_NullableStringConverter() String? stage,
    @_NullableStringConverter() String? area,
    @JsonKey(name: 'mobile_no') @_NullableStringConverter() String? mobileNo,
    @JsonKey(name: 'branch_count') @_IntConverter() @Default(0) int branchCount,
  }) = _B2bMergeCandidate;

  factory B2bMergeCandidate.fromJson(Map<String, dynamic> json) =>
      _$B2bMergeCandidateFromJson(json);

  String get displayName => title ?? name;
}

/// One side (source or target) of a merge preview.
@freezed
class B2bMergeParty with _$B2bMergeParty {
  const B2bMergeParty._();

  const factory B2bMergeParty({
    @_NullableStringConverter() String? doctype,
    @_NullableStringConverter() String? name,
    @_NullableStringConverter() String? title,
    @_NullableStringConverter() String? lead,
    @_NullableStringConverter() String? customer,
  }) = _B2bMergeParty;

  factory B2bMergeParty.fromJson(Map<String, dynamic> json) =>
      _$B2bMergePartyFromJson(json);

  String get displayName => title ?? name ?? '';
}

/// What the server will do to the Customer / Lead records on a merge.
@freezed
class B2bMergePlan with _$B2bMergePlan {
  const factory B2bMergePlan({
    @JsonKey(name: 'customer_action')
    @_NullableStringConverter()
    String? customerAction,
    @JsonKey(name: 'lead_action')
    @_NullableStringConverter()
    String? leadAction,
    @JsonKey(name: 'requires_manager')
    @_BoolConverter()
    @Default(false)
    bool requiresManager,
    @JsonKey(name: 'final_customer')
    @_NullableStringConverter()
    String? finalCustomer,
  }) = _B2bMergePlan;

  factory B2bMergePlan.fromJson(Map<String, dynamic> json) =>
      _$B2bMergePlanFromJson(json);
}

/// A Customer's footprint as reported by the merge preview.
@freezed
class B2bMergeCustomerSummary with _$B2bMergeCustomerSummary {
  const factory B2bMergeCustomerSummary({
    @_NullableStringConverter() String? name,
    @JsonKey(name: 'customer_name')
    @_NullableStringConverter()
    String? customerName,
    @JsonKey(name: 'invoice_count')
    @_IntConverter()
    @Default(0)
    int invoiceCount,
    @JsonKey(name: 'total_billed')
    @_DoubleConverter()
    @Default(0.0)
    double totalBilled,
    @_DoubleConverter() @Default(0.0) double outstanding,
    @JsonKey(name: 'address_count')
    @_IntConverter()
    @Default(0)
    int addressCount,
    @JsonKey(name: 'credit_allowed')
    @_BoolConverter()
    @Default(false)
    bool creditAllowed,
  }) = _B2bMergeCustomerSummary;

  factory B2bMergeCustomerSummary.fromJson(Map<String, dynamic> json) =>
      _$B2bMergeCustomerSummaryFromJson(json);
}

/// `crm.preview_merge_as_branch`: a dry run of `crm.merge_as_branch`.
@freezed
class B2bMergePreview with _$B2bMergePreview {
  const factory B2bMergePreview({
    @Default(B2bMergeParty()) B2bMergeParty source,
    @Default(B2bMergeParty()) B2bMergeParty target,
    @Default(B2bMergePlan()) B2bMergePlan plan,
    @JsonKey(name: 'source_customer') B2bMergeCustomerSummary? sourceCustomer,
    @JsonKey(name: 'target_customer') B2bMergeCustomerSummary? targetCustomer,
    @JsonKey(name: 'can_execute')
    @_BoolConverter()
    @Default(false)
    bool canExecute,
    @_StringListConverter() @Default(<String>[]) List<String> warnings,

    /// Server-written sentences explaining why the merge cannot run at all
    /// (not a permission issue). Non-empty implies `can_execute == false`.
    @_StringListConverter() @Default(<String>[]) List<String> blockers,
  }) = _B2bMergePreview;

  factory B2bMergePreview.fromJson(Map<String, dynamic> json) =>
      _$B2bMergePreviewFromJson(json);
}

/// `crm.merge_as_branch` result. Only the fields the app acts on are kept;
/// `moved_invoices` is read as a count whether the server sends a number or
/// the list of moved invoice names.
class B2bMergeResult {
  final bool success;
  final String targetDoctype;
  final String targetName;
  final String? customer;
  final int movedInvoices;

  const B2bMergeResult({
    required this.success,
    required this.targetDoctype,
    required this.targetName,
    this.customer,
    this.movedInvoices = 0,
  });

  factory B2bMergeResult.fromJson(
    Map<String, dynamic> json, {
    required String fallbackDoctype,
    required String fallbackName,
  }) {
    final moved = json['moved_invoices'];
    return B2bMergeResult(
      success: json.containsKey('success') ? _looseBool(json['success']) : true,
      targetDoctype: _looseString(json['target_doctype']) ?? fallbackDoctype,
      targetName: _looseString(json['target_name']) ?? fallbackName,
      customer: _looseString(json['customer']),
      movedInvoices: moved is List ? moved.length : (_looseInt(moved) ?? 0),
    );
  }
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
  const B2bAccount._();

  const factory B2bAccount({
    required String doctype,
    required String name,
    required String title,
    @Default('Customer') String stage,
    String? owner,
    @Default(B2bContact()) B2bContact contact,
    String? customer,
    @JsonKey(name: 'predicted_next_order') String? predictedNextOrder,
    @JsonKey(name: 'avg_order_cycle_days') double? avgOrderCycleDays,
    @JsonKey(name: 'recent_invoices')
    @Default(<B2bRecentInvoice>[])
    List<B2bRecentInvoice> recentInvoices,
    @JsonKey(name: 'open_todos') @Default(<B2bTodo>[]) List<B2bTodo> openTodos,

    /// Every door of the shop, once each: the linked Customer's branches
    /// (named shipping Addresses, with their own invoice totals and any matched
    /// Google Maps listing) first, then the Lead's Google Maps branches that
    /// are not delivery branches yet. Empty on an older server.
    @Default(<B2bBranch>[]) List<B2bBranch> branches,

    /// Totals for the invoices that match no branch; null when there are none.
    @JsonKey(name: 'unassigned_invoices') B2bBranchStats? unassignedInvoices,

    /// The Lead whose Google Maps branches were folded into [branches] (the
    /// account itself for a Lead, the linked Lead for a Customer). Null when
    /// there is none or on an older server.
    @JsonKey(name: 'branch_lead') String? branchLead,

    /// The rep's dated field diary for this account, newest touch first. The
    /// account screen renders it through the shared journey timeline, which
    /// also owns the live (re-fetched) copy — this is the load-time snapshot.
    @JsonKey(name: 'journey_notes')
    @Default(<JourneyNote>[])
    List<JourneyNote> journeyNotes,
  }) = _B2bAccount;

  factory B2bAccount.fromJson(Map<String, dynamic> json) =>
      _$B2bAccountFromJson(json);

  /// Only the delivery branches (shipping Addresses) — what invoice filters
  /// and order flows key on.
  List<B2bBranch> get deliveryBranches =>
      branches.where((b) => b.isDeliveryBranch).toList();
}

/// `crm.link_branch` result: the account's unified branch list after the
/// link / unlink, and the refreshed unassigned-invoice totals.
class B2bBranchLinkResult {
  final List<B2bBranch> branches;
  final B2bBranchStats? unassigned;

  const B2bBranchLinkResult({required this.branches, this.unassigned});

  factory B2bBranchLinkResult.fromJson(Map<String, dynamic> json) {
    final raw = json['branches'];
    final unassigned = json['unassigned'] ?? json['unassigned_invoices'];
    return B2bBranchLinkResult(
      branches: raw is List
          ? raw
                .whereType<Map>()
                .map((e) => B2bBranch.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const <B2bBranch>[],
      unassigned: unassigned is Map
          ? B2bBranchStats.fromJson(Map<String, dynamic>.from(unassigned))
          : null,
    );
  }
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
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'order_purpose') required String orderPurpose,
    @JsonKey(name: 'price_list') String? priceList,
    @JsonKey(name: 'address_book')
    @Default(<String, dynamic>{})
    Map<String, dynamic> addressBook,
    @JsonKey(name: 'requires_shipping_address_selection')
    @Default(false)
    bool requiresShippingAddressSelection,
    @JsonKey(name: 'shipping_address_name') String? shippingAddressName,
  }) = _OrderBinding;

  factory OrderBinding.fromJson(Map<String, dynamic> json) =>
      _$OrderBindingFromJson(json);
}
