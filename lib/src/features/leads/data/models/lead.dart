// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lead.freezed.dart';
part 'lead.g.dart';

/// A B2B prospect. The same class serves both the lightweight list/map card
/// (`get_leads`) and the full detail view (`get_lead`); the detail-only fields
/// (branches, addresses, notes) are nullable so a card decodes cleanly too.
///
/// The backend sends snake_case keys; every field maps them via [JsonKey] and
/// defaults to null-safe values ('' for strings, 0 for ints, [] for lists) so
/// a partial/missing payload never throws. Ratings/lat/lng stay nullable.
@freezed
class Lead with _$Lead {
  const factory Lead({
    required String name,
    @JsonKey(name: 'source_brand_id') String? sourceBrandId,
    @JsonKey(name: 'lead_name') @Default('') String leadName,
    String? category,
    @Default(0) int score,
    @Default('') String tier,
    @JsonKey(name: 'branch_count') @Default(0) int branchCount,
    @JsonKey(name: 'price_band') @Default('') String priceBand,
    @JsonKey(name: 'avg_rating') double? avgRating,
    @JsonKey(name: 'total_reviews') @Default(0) int totalReviews,
    @JsonKey(name: 'open_status') @Default('') String openStatus,
    @JsonKey(name: 'sahel_branches') @Default(0) int sahelBranches,
    @JsonKey(name: 'is_specialty') @Default(false) bool isSpecialty,
    // ── Google service signals ─────────────────────────────────────────────
    // TRUE means Google positively confirms it. FALSE means UNKNOWN, never
    // "no" — the Places API omits these fields entirely unless they are true.
    // So filter on `takeout == true` to find confirmed-takeaway venues, but
    // never treat `takeout == false` as "this place has no takeaway".
    @JsonKey(name: 'takeout') @Default(false) bool takeout,
    @JsonKey(name: 'dine_in') @Default(false) bool dineIn,
    @JsonKey(name: 'serves_dessert') @Default(false) bool servesDessert,
    @JsonKey(name: 'primary_area') @Default('') String primaryArea,
    @Default(<String>[]) List<String> regions,
    @Default(<String>[]) List<String> governorates,
    @Default(<String>[]) List<String> areas,
    @Default('') String phone,
    @Default('') String website,
    @Default('') String instagram,
    @Default('') String facebook,
    @JsonKey(name: 'maps_url') @Default('') String mapsUrl,
    @Default('') String confidence,
    @Default('') String status,
    @JsonKey(name: 'b2b_stage') @Default('') String b2bStage,
    @JsonKey(name: 'last_verified') String? lastVerified,
    double? latitude,
    double? longitude,
    // ── Manual-inspection verdict ──────────────────────────────────────────
    // Set by a rep through `set_lead_suitability`, never through `save_lead`.
    // A not-suitable lead is hidden from the working catalog by default and
    // never appears on the B2B pipeline board.
    @JsonKey(name: 'not_suitable') @Default(false) bool notSuitable,
    @JsonKey(name: 'not_suitable_reason') @Default('') String notSuitableReason,
    @JsonKey(name: 'not_suitable_notes') @Default('') String notSuitableNotes,
    @JsonKey(name: 'not_suitable_on') String? notSuitableOn,
    @JsonKey(name: 'not_suitable_by') @Default('') String notSuitableBy,
    // ── Duplicate-merge bookkeeping ────────────────────────────────────────
    // Non-empty on a lead that was merged INTO another as a duplicate. Such a
    // lead is excluded from the catalog server-side, so this is normally only
    // seen when a merged record is opened directly.
    @JsonKey(name: 'merged_into') @Default('') String mergedInto,
    @JsonKey(name: 'merged_on') String? mergedOn,
    @JsonKey(name: 'merged_by') @Default('') String mergedBy,
    // ── Detail-only fields (present on get_lead, null on get_leads) ────────
    @JsonKey(name: 'branches') @Default(<LeadBranch>[]) List<LeadBranch> branches,
    @JsonKey(name: 'primary_address') LeadAddress? primaryAddress,
    @JsonKey(name: 'shipping_address') LeadAddress? shippingAddress,
    @Default('') String notes,
  }) = _Lead;

  factory Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);
}

/// A single branch/location of a lead brand.
@freezed
class LeadBranch with _$LeadBranch {
  const factory LeadBranch({
    @JsonKey(name: 'branch_name') @Default('') String branchName,
    @Default('') String area,
    @Default('') String region,
    @Default('') String governorate,
    double? rating,
    @Default(0) int reviews,
    @Default('') String price,
    @Default('') String status,
    @Default('') String hours,
    @Default('') String phone,
    @Default('') String website,
    @JsonKey(name: 'maps_url') @Default('') String mapsUrl,
    @Default('') String address,
    double? latitude,
    double? longitude,
  }) = _LeadBranch;

  factory LeadBranch.fromJson(Map<String, dynamic> json) =>
      _$LeadBranchFromJson(json);
}

/// A postal address attached to a lead (primary or shipping).
@freezed
class LeadAddress with _$LeadAddress {
  const factory LeadAddress({
    String? name,
    @JsonKey(name: 'address_line1') @Default('') String addressLine1,
    @JsonKey(name: 'address_line2') @Default('') String addressLine2,
    @Default('') String city,
    @Default('') String state,
    @Default('') String country,
    @Default('') String pincode,
    @Default('') String phone,
  }) = _LeadAddress;

  factory LeadAddress.fromJson(Map<String, dynamic> json) =>
      _$LeadAddressFromJson(json);
}

/// A lead the backend thinks might be a duplicate of another.
///
/// [reasons] carries the human-readable signals that matched ("Same brand
/// name", "Same phone"), and [score] is how many of them did. Both are shown
/// rather than just ranking silently: merging is destructive enough that a rep
/// should see WHY something was suggested before folding it in.
@freezed
class LeadMergeCandidate with _$LeadMergeCandidate {
  const factory LeadMergeCandidate({
    required String name,
    @JsonKey(name: 'lead_name') @Default('') String leadName,
    @Default('') String category,
    @JsonKey(name: 'branch_count') @Default(0) int branchCount,
    @JsonKey(name: 'primary_area') @Default('') String primaryArea,
    @Default('') String phone,
    @Default('') String instagram,
    @Default(0) int score,
    @Default(<String>[]) List<String> reasons,
  }) = _LeadMergeCandidate;

  factory LeadMergeCandidate.fromJson(Map<String, dynamic> json) =>
      _$LeadMergeCandidateFromJson(json);
}

/// A lead category (used for filter chips + the add-lead form dropdown).
@freezed
class LeadCategory with _$LeadCategory {
  const factory LeadCategory({
    required String name,
    @JsonKey(name: 'category_name') @Default('') String categoryName,
    String? color,
  }) = _LeadCategory;

  factory LeadCategory.fromJson(Map<String, dynamic> json) =>
      _$LeadCategoryFromJson(json);
}
