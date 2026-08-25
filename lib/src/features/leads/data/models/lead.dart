// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../journey/data/models/journey_note.dart';

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
  const Lead._();

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
    // ── Talabat presence ───────────────────────────────────────────────────
    // Sourced by reading Talabat's own per-area listings, NOT from Google, so
    // this one really is two-state: `false` means "not listed in any area we
    // swept", not "unknown". `talabatAreas` names the delivery zones the
    // listing was actually seen in.
    @JsonKey(name: 'on_talabat', fromJson: _flag) @Default(false) bool onTalabat,
    @JsonKey(name: 'talabat_areas') @Default(<String>[]) List<String> talabatAreas,
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
    // ── People at the venue ───────────────────────────────────────────────
    // Rides on BOTH the catalog row and the detail: a rep looking at a card
    // needs to know who to ask for before walking in, not after opening it.
    @Default(<LeadContact>[]) List<LeadContact> contacts,
    // ── Detail-only fields (present on get_lead, null on get_leads) ────────
    @JsonKey(name: 'branches') @Default(<LeadBranch>[]) List<LeadBranch> branches,
    @JsonKey(name: 'primary_address') LeadAddress? primaryAddress,
    @JsonKey(name: 'shipping_address') LeadAddress? shippingAddress,
    @Default('') String notes,
    // ── Journey diary ─────────────────────────────────────────────────────
    // The summary rides on BOTH the catalog row and the detail (so a list card
    // can show "visited 3 days ago, call due Thursday" without a request per
    // lead); the note list itself is detail-only.
    @JsonKey(name: 'journey_count') @Default(0) int journeyCount,
    @JsonKey(name: 'last_journey_date') String? lastJourneyDate,
    @JsonKey(name: 'last_journey_type') String? lastJourneyType,
    @JsonKey(name: 'last_journey_note') String? lastJourneyNote,
    @JsonKey(name: 'last_journey_contact') String? lastJourneyContact,
    @JsonKey(name: 'next_action_date') String? nextActionDate,
    @JsonKey(name: 'next_action') String? nextAction,
    @JsonKey(name: 'journey_notes')
    @Default(<JourneyNote>[])
    List<JourneyNote> journeyNotes,
  }) = _Lead;

  factory Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);

  /// The person to ring first: the flagged primary, else the first contact
  /// with a number, else null. Never throws on an empty list.
  LeadContact? get primaryContact {
    for (final c in contacts) {
      if (c.isPrimary && c.phone.trim().isNotEmpty) return c;
    }
    for (final c in contacts) {
      if (c.phone.trim().isNotEmpty) return c;
    }
    return contacts.isEmpty ? null : contacts.first;
  }

  /// The best number to call: the lead's own line, else the primary contact's.
  /// Empty when nobody on this record has a number.
  String get callablePhone {
    final own = phone.trim();
    if (own.isNotEmpty) return own;
    return primaryContact?.phone.trim() ?? '';
  }

  /// The lead's journey read-out, in the shape the shared badge widget takes.
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

/// A person at a lead: the owner, the manager, the shift manager, the barista.
///
/// A lead is a business, not a human, and a rep who walks in meets whoever is
/// on shift — so the record holds as many people as the rep has met. [role] is
/// free text because every venue names its own jobs, and [isPrimary] marks the
/// one person to ring first (the backend guarantees at most one).
@freezed
class LeadContact with _$LeadContact {
  const LeadContact._();

  const factory LeadContact({
    @JsonKey(name: 'contact_name') @Default('') String contactName,
    @Default('') String role,
    @Default('') String phone,
    @Default('') String email,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
    @Default('') String notes,
  }) = _LeadContact;

  factory LeadContact.fromJson(Map<String, dynamic> json) =>
      _$LeadContactFromJson(json);

  /// What to show as the person's name when they were saved by number only.
  String get displayName =>
      contactName.trim().isNotEmpty ? contactName.trim() : phone.trim();

  bool get canCall => phone.trim().isNotEmpty;
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
    @JsonKey(name: 'on_talabat', fromJson: _flag) @Default(false) bool onTalabat,
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

/// Decodes a Frappe Check field into a bool.
///
/// The API coerces these before sending, but a Check column reads back as 0/1
/// straight out of the database, and a plain `as bool` cast on an int takes the
/// whole catalog parse down with it. Being lenient here costs nothing and keeps
/// one stray raw payload from emptying the leads screen.
bool _flag(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}
