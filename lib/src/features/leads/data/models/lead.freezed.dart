// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Lead _$LeadFromJson(Map<String, dynamic> json) {
  return _Lead.fromJson(json);
}

/// @nodoc
mixin _$Lead {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_brand_id')
  String? get sourceBrandId => throw _privateConstructorUsedError;
  @JsonKey(name: 'lead_name')
  String get leadName => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  String get tier => throw _privateConstructorUsedError;
  @JsonKey(name: 'branch_count')
  int get branchCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_band')
  String get priceBand => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_rating')
  double? get avgRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_reviews')
  int get totalReviews => throw _privateConstructorUsedError;
  @JsonKey(name: 'open_status')
  String get openStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'sahel_branches')
  int get sahelBranches => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_specialty')
  bool get isSpecialty => throw _privateConstructorUsedError; // ── Google service signals ─────────────────────────────────────────────
  // TRUE means Google positively confirms it. FALSE means UNKNOWN, never
  // "no" — the Places API omits these fields entirely unless they are true.
  // So filter on `takeout == true` to find confirmed-takeaway venues, but
  // never treat `takeout == false` as "this place has no takeaway".
  @JsonKey(name: 'takeout')
  bool get takeout => throw _privateConstructorUsedError;
  @JsonKey(name: 'dine_in')
  bool get dineIn => throw _privateConstructorUsedError;
  @JsonKey(name: 'serves_dessert')
  bool get servesDessert => throw _privateConstructorUsedError; // ── Talabat presence ───────────────────────────────────────────────────
  // Sourced by reading Talabat's own per-area listings, NOT from Google, so
  // this one really is two-state: `false` means "not listed in any area we
  // swept", not "unknown". `talabatAreas` names the delivery zones the
  // listing was actually seen in.
  @JsonKey(name: 'on_talabat', fromJson: _flag)
  bool get onTalabat => throw _privateConstructorUsedError;
  @JsonKey(name: 'talabat_areas')
  List<String> get talabatAreas => throw _privateConstructorUsedError;
  @JsonKey(name: 'primary_area')
  String get primaryArea => throw _privateConstructorUsedError;
  List<String> get regions => throw _privateConstructorUsedError;
  List<String> get governorates => throw _privateConstructorUsedError;
  List<String> get areas => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get website => throw _privateConstructorUsedError;
  String get instagram => throw _privateConstructorUsedError;
  String get facebook => throw _privateConstructorUsedError;
  @JsonKey(name: 'maps_url')
  String get mapsUrl => throw _privateConstructorUsedError;
  String get confidence => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'b2b_stage')
  String get b2bStage => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_verified')
  String? get lastVerified => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude =>
      throw _privateConstructorUsedError; // ── Manual-inspection verdict ──────────────────────────────────────────
  // Set by a rep through `set_lead_suitability`, never through `save_lead`.
  // A not-suitable lead is hidden from the working catalog by default and
  // never appears on the B2B pipeline board.
  @JsonKey(name: 'not_suitable')
  bool get notSuitable => throw _privateConstructorUsedError;
  @JsonKey(name: 'not_suitable_reason')
  String get notSuitableReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'not_suitable_notes')
  String get notSuitableNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'not_suitable_on')
  String? get notSuitableOn => throw _privateConstructorUsedError;
  @JsonKey(name: 'not_suitable_by')
  String get notSuitableBy => throw _privateConstructorUsedError; // ── Duplicate-merge bookkeeping ────────────────────────────────────────
  // Non-empty on a lead that was merged INTO another as a duplicate. Such a
  // lead is excluded from the catalog server-side, so this is normally only
  // seen when a merged record is opened directly.
  @JsonKey(name: 'merged_into')
  String get mergedInto => throw _privateConstructorUsedError;
  @JsonKey(name: 'merged_on')
  String? get mergedOn => throw _privateConstructorUsedError;
  @JsonKey(name: 'merged_by')
  String get mergedBy => throw _privateConstructorUsedError; // ── People at the venue ───────────────────────────────────────────────
  // Rides on BOTH the catalog row and the detail: a rep looking at a card
  // needs to know who to ask for before walking in, not after opening it.
  List<LeadContact> get contacts =>
      throw _privateConstructorUsedError; // ── Detail-only fields (present on get_lead, null on get_leads) ────────
  @JsonKey(name: 'branches')
  List<LeadBranch> get branches => throw _privateConstructorUsedError;
  @JsonKey(name: 'primary_address')
  LeadAddress? get primaryAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_address')
  LeadAddress? get shippingAddress => throw _privateConstructorUsedError;
  String get notes =>
      throw _privateConstructorUsedError; // ── Journey diary ─────────────────────────────────────────────────────
  // The summary rides on BOTH the catalog row and the detail (so a list card
  // can show "visited 3 days ago, call due Thursday" without a request per
  // lead); the note list itself is detail-only.
  @JsonKey(name: 'journey_count')
  int get journeyCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_journey_date')
  String? get lastJourneyDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_journey_type')
  String? get lastJourneyType => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_journey_note')
  String? get lastJourneyNote => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_journey_contact')
  String? get lastJourneyContact => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_action_date')
  String? get nextActionDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_action')
  String? get nextAction => throw _privateConstructorUsedError;
  @JsonKey(name: 'journey_notes')
  List<JourneyNote> get journeyNotes => throw _privateConstructorUsedError;

  /// Serializes this Lead to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadCopyWith<Lead> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadCopyWith<$Res> {
  factory $LeadCopyWith(Lead value, $Res Function(Lead) then) =
      _$LeadCopyWithImpl<$Res, Lead>;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'source_brand_id') String? sourceBrandId,
    @JsonKey(name: 'lead_name') String leadName,
    String? category,
    int score,
    String tier,
    @JsonKey(name: 'branch_count') int branchCount,
    @JsonKey(name: 'price_band') String priceBand,
    @JsonKey(name: 'avg_rating') double? avgRating,
    @JsonKey(name: 'total_reviews') int totalReviews,
    @JsonKey(name: 'open_status') String openStatus,
    @JsonKey(name: 'sahel_branches') int sahelBranches,
    @JsonKey(name: 'is_specialty') bool isSpecialty,
    @JsonKey(name: 'takeout') bool takeout,
    @JsonKey(name: 'dine_in') bool dineIn,
    @JsonKey(name: 'serves_dessert') bool servesDessert,
    @JsonKey(name: 'on_talabat', fromJson: _flag) bool onTalabat,
    @JsonKey(name: 'talabat_areas') List<String> talabatAreas,
    @JsonKey(name: 'primary_area') String primaryArea,
    List<String> regions,
    List<String> governorates,
    List<String> areas,
    String phone,
    String website,
    String instagram,
    String facebook,
    @JsonKey(name: 'maps_url') String mapsUrl,
    String confidence,
    String status,
    @JsonKey(name: 'b2b_stage') String b2bStage,
    @JsonKey(name: 'last_verified') String? lastVerified,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'not_suitable') bool notSuitable,
    @JsonKey(name: 'not_suitable_reason') String notSuitableReason,
    @JsonKey(name: 'not_suitable_notes') String notSuitableNotes,
    @JsonKey(name: 'not_suitable_on') String? notSuitableOn,
    @JsonKey(name: 'not_suitable_by') String notSuitableBy,
    @JsonKey(name: 'merged_into') String mergedInto,
    @JsonKey(name: 'merged_on') String? mergedOn,
    @JsonKey(name: 'merged_by') String mergedBy,
    List<LeadContact> contacts,
    @JsonKey(name: 'branches') List<LeadBranch> branches,
    @JsonKey(name: 'primary_address') LeadAddress? primaryAddress,
    @JsonKey(name: 'shipping_address') LeadAddress? shippingAddress,
    String notes,
    @JsonKey(name: 'journey_count') int journeyCount,
    @JsonKey(name: 'last_journey_date') String? lastJourneyDate,
    @JsonKey(name: 'last_journey_type') String? lastJourneyType,
    @JsonKey(name: 'last_journey_note') String? lastJourneyNote,
    @JsonKey(name: 'last_journey_contact') String? lastJourneyContact,
    @JsonKey(name: 'next_action_date') String? nextActionDate,
    @JsonKey(name: 'next_action') String? nextAction,
    @JsonKey(name: 'journey_notes') List<JourneyNote> journeyNotes,
  });

  $LeadAddressCopyWith<$Res>? get primaryAddress;
  $LeadAddressCopyWith<$Res>? get shippingAddress;
}

/// @nodoc
class _$LeadCopyWithImpl<$Res, $Val extends Lead>
    implements $LeadCopyWith<$Res> {
  _$LeadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? sourceBrandId = freezed,
    Object? leadName = null,
    Object? category = freezed,
    Object? score = null,
    Object? tier = null,
    Object? branchCount = null,
    Object? priceBand = null,
    Object? avgRating = freezed,
    Object? totalReviews = null,
    Object? openStatus = null,
    Object? sahelBranches = null,
    Object? isSpecialty = null,
    Object? takeout = null,
    Object? dineIn = null,
    Object? servesDessert = null,
    Object? onTalabat = null,
    Object? talabatAreas = null,
    Object? primaryArea = null,
    Object? regions = null,
    Object? governorates = null,
    Object? areas = null,
    Object? phone = null,
    Object? website = null,
    Object? instagram = null,
    Object? facebook = null,
    Object? mapsUrl = null,
    Object? confidence = null,
    Object? status = null,
    Object? b2bStage = null,
    Object? lastVerified = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? notSuitable = null,
    Object? notSuitableReason = null,
    Object? notSuitableNotes = null,
    Object? notSuitableOn = freezed,
    Object? notSuitableBy = null,
    Object? mergedInto = null,
    Object? mergedOn = freezed,
    Object? mergedBy = null,
    Object? contacts = null,
    Object? branches = null,
    Object? primaryAddress = freezed,
    Object? shippingAddress = freezed,
    Object? notes = null,
    Object? journeyCount = null,
    Object? lastJourneyDate = freezed,
    Object? lastJourneyType = freezed,
    Object? lastJourneyNote = freezed,
    Object? lastJourneyContact = freezed,
    Object? nextActionDate = freezed,
    Object? nextAction = freezed,
    Object? journeyNotes = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            sourceBrandId: freezed == sourceBrandId
                ? _value.sourceBrandId
                : sourceBrandId // ignore: cast_nullable_to_non_nullable
                      as String?,
            leadName: null == leadName
                ? _value.leadName
                : leadName // ignore: cast_nullable_to_non_nullable
                      as String,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            tier: null == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                      as String,
            branchCount: null == branchCount
                ? _value.branchCount
                : branchCount // ignore: cast_nullable_to_non_nullable
                      as int,
            priceBand: null == priceBand
                ? _value.priceBand
                : priceBand // ignore: cast_nullable_to_non_nullable
                      as String,
            avgRating: freezed == avgRating
                ? _value.avgRating
                : avgRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            totalReviews: null == totalReviews
                ? _value.totalReviews
                : totalReviews // ignore: cast_nullable_to_non_nullable
                      as int,
            openStatus: null == openStatus
                ? _value.openStatus
                : openStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            sahelBranches: null == sahelBranches
                ? _value.sahelBranches
                : sahelBranches // ignore: cast_nullable_to_non_nullable
                      as int,
            isSpecialty: null == isSpecialty
                ? _value.isSpecialty
                : isSpecialty // ignore: cast_nullable_to_non_nullable
                      as bool,
            takeout: null == takeout
                ? _value.takeout
                : takeout // ignore: cast_nullable_to_non_nullable
                      as bool,
            dineIn: null == dineIn
                ? _value.dineIn
                : dineIn // ignore: cast_nullable_to_non_nullable
                      as bool,
            servesDessert: null == servesDessert
                ? _value.servesDessert
                : servesDessert // ignore: cast_nullable_to_non_nullable
                      as bool,
            onTalabat: null == onTalabat
                ? _value.onTalabat
                : onTalabat // ignore: cast_nullable_to_non_nullable
                      as bool,
            talabatAreas: null == talabatAreas
                ? _value.talabatAreas
                : talabatAreas // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            primaryArea: null == primaryArea
                ? _value.primaryArea
                : primaryArea // ignore: cast_nullable_to_non_nullable
                      as String,
            regions: null == regions
                ? _value.regions
                : regions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            governorates: null == governorates
                ? _value.governorates
                : governorates // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            areas: null == areas
                ? _value.areas
                : areas // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            website: null == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String,
            instagram: null == instagram
                ? _value.instagram
                : instagram // ignore: cast_nullable_to_non_nullable
                      as String,
            facebook: null == facebook
                ? _value.facebook
                : facebook // ignore: cast_nullable_to_non_nullable
                      as String,
            mapsUrl: null == mapsUrl
                ? _value.mapsUrl
                : mapsUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            b2bStage: null == b2bStage
                ? _value.b2bStage
                : b2bStage // ignore: cast_nullable_to_non_nullable
                      as String,
            lastVerified: freezed == lastVerified
                ? _value.lastVerified
                : lastVerified // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            notSuitable: null == notSuitable
                ? _value.notSuitable
                : notSuitable // ignore: cast_nullable_to_non_nullable
                      as bool,
            notSuitableReason: null == notSuitableReason
                ? _value.notSuitableReason
                : notSuitableReason // ignore: cast_nullable_to_non_nullable
                      as String,
            notSuitableNotes: null == notSuitableNotes
                ? _value.notSuitableNotes
                : notSuitableNotes // ignore: cast_nullable_to_non_nullable
                      as String,
            notSuitableOn: freezed == notSuitableOn
                ? _value.notSuitableOn
                : notSuitableOn // ignore: cast_nullable_to_non_nullable
                      as String?,
            notSuitableBy: null == notSuitableBy
                ? _value.notSuitableBy
                : notSuitableBy // ignore: cast_nullable_to_non_nullable
                      as String,
            mergedInto: null == mergedInto
                ? _value.mergedInto
                : mergedInto // ignore: cast_nullable_to_non_nullable
                      as String,
            mergedOn: freezed == mergedOn
                ? _value.mergedOn
                : mergedOn // ignore: cast_nullable_to_non_nullable
                      as String?,
            mergedBy: null == mergedBy
                ? _value.mergedBy
                : mergedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            contacts: null == contacts
                ? _value.contacts
                : contacts // ignore: cast_nullable_to_non_nullable
                      as List<LeadContact>,
            branches: null == branches
                ? _value.branches
                : branches // ignore: cast_nullable_to_non_nullable
                      as List<LeadBranch>,
            primaryAddress: freezed == primaryAddress
                ? _value.primaryAddress
                : primaryAddress // ignore: cast_nullable_to_non_nullable
                      as LeadAddress?,
            shippingAddress: freezed == shippingAddress
                ? _value.shippingAddress
                : shippingAddress // ignore: cast_nullable_to_non_nullable
                      as LeadAddress?,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            journeyCount: null == journeyCount
                ? _value.journeyCount
                : journeyCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastJourneyDate: freezed == lastJourneyDate
                ? _value.lastJourneyDate
                : lastJourneyDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastJourneyType: freezed == lastJourneyType
                ? _value.lastJourneyType
                : lastJourneyType // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastJourneyNote: freezed == lastJourneyNote
                ? _value.lastJourneyNote
                : lastJourneyNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastJourneyContact: freezed == lastJourneyContact
                ? _value.lastJourneyContact
                : lastJourneyContact // ignore: cast_nullable_to_non_nullable
                      as String?,
            nextActionDate: freezed == nextActionDate
                ? _value.nextActionDate
                : nextActionDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            nextAction: freezed == nextAction
                ? _value.nextAction
                : nextAction // ignore: cast_nullable_to_non_nullable
                      as String?,
            journeyNotes: null == journeyNotes
                ? _value.journeyNotes
                : journeyNotes // ignore: cast_nullable_to_non_nullable
                      as List<JourneyNote>,
          )
          as $Val,
    );
  }

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LeadAddressCopyWith<$Res>? get primaryAddress {
    if (_value.primaryAddress == null) {
      return null;
    }

    return $LeadAddressCopyWith<$Res>(_value.primaryAddress!, (value) {
      return _then(_value.copyWith(primaryAddress: value) as $Val);
    });
  }

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LeadAddressCopyWith<$Res>? get shippingAddress {
    if (_value.shippingAddress == null) {
      return null;
    }

    return $LeadAddressCopyWith<$Res>(_value.shippingAddress!, (value) {
      return _then(_value.copyWith(shippingAddress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LeadImplCopyWith<$Res> implements $LeadCopyWith<$Res> {
  factory _$$LeadImplCopyWith(
    _$LeadImpl value,
    $Res Function(_$LeadImpl) then,
  ) = __$$LeadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'source_brand_id') String? sourceBrandId,
    @JsonKey(name: 'lead_name') String leadName,
    String? category,
    int score,
    String tier,
    @JsonKey(name: 'branch_count') int branchCount,
    @JsonKey(name: 'price_band') String priceBand,
    @JsonKey(name: 'avg_rating') double? avgRating,
    @JsonKey(name: 'total_reviews') int totalReviews,
    @JsonKey(name: 'open_status') String openStatus,
    @JsonKey(name: 'sahel_branches') int sahelBranches,
    @JsonKey(name: 'is_specialty') bool isSpecialty,
    @JsonKey(name: 'takeout') bool takeout,
    @JsonKey(name: 'dine_in') bool dineIn,
    @JsonKey(name: 'serves_dessert') bool servesDessert,
    @JsonKey(name: 'on_talabat', fromJson: _flag) bool onTalabat,
    @JsonKey(name: 'talabat_areas') List<String> talabatAreas,
    @JsonKey(name: 'primary_area') String primaryArea,
    List<String> regions,
    List<String> governorates,
    List<String> areas,
    String phone,
    String website,
    String instagram,
    String facebook,
    @JsonKey(name: 'maps_url') String mapsUrl,
    String confidence,
    String status,
    @JsonKey(name: 'b2b_stage') String b2bStage,
    @JsonKey(name: 'last_verified') String? lastVerified,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'not_suitable') bool notSuitable,
    @JsonKey(name: 'not_suitable_reason') String notSuitableReason,
    @JsonKey(name: 'not_suitable_notes') String notSuitableNotes,
    @JsonKey(name: 'not_suitable_on') String? notSuitableOn,
    @JsonKey(name: 'not_suitable_by') String notSuitableBy,
    @JsonKey(name: 'merged_into') String mergedInto,
    @JsonKey(name: 'merged_on') String? mergedOn,
    @JsonKey(name: 'merged_by') String mergedBy,
    List<LeadContact> contacts,
    @JsonKey(name: 'branches') List<LeadBranch> branches,
    @JsonKey(name: 'primary_address') LeadAddress? primaryAddress,
    @JsonKey(name: 'shipping_address') LeadAddress? shippingAddress,
    String notes,
    @JsonKey(name: 'journey_count') int journeyCount,
    @JsonKey(name: 'last_journey_date') String? lastJourneyDate,
    @JsonKey(name: 'last_journey_type') String? lastJourneyType,
    @JsonKey(name: 'last_journey_note') String? lastJourneyNote,
    @JsonKey(name: 'last_journey_contact') String? lastJourneyContact,
    @JsonKey(name: 'next_action_date') String? nextActionDate,
    @JsonKey(name: 'next_action') String? nextAction,
    @JsonKey(name: 'journey_notes') List<JourneyNote> journeyNotes,
  });

  @override
  $LeadAddressCopyWith<$Res>? get primaryAddress;
  @override
  $LeadAddressCopyWith<$Res>? get shippingAddress;
}

/// @nodoc
class __$$LeadImplCopyWithImpl<$Res>
    extends _$LeadCopyWithImpl<$Res, _$LeadImpl>
    implements _$$LeadImplCopyWith<$Res> {
  __$$LeadImplCopyWithImpl(_$LeadImpl _value, $Res Function(_$LeadImpl) _then)
    : super(_value, _then);

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? sourceBrandId = freezed,
    Object? leadName = null,
    Object? category = freezed,
    Object? score = null,
    Object? tier = null,
    Object? branchCount = null,
    Object? priceBand = null,
    Object? avgRating = freezed,
    Object? totalReviews = null,
    Object? openStatus = null,
    Object? sahelBranches = null,
    Object? isSpecialty = null,
    Object? takeout = null,
    Object? dineIn = null,
    Object? servesDessert = null,
    Object? onTalabat = null,
    Object? talabatAreas = null,
    Object? primaryArea = null,
    Object? regions = null,
    Object? governorates = null,
    Object? areas = null,
    Object? phone = null,
    Object? website = null,
    Object? instagram = null,
    Object? facebook = null,
    Object? mapsUrl = null,
    Object? confidence = null,
    Object? status = null,
    Object? b2bStage = null,
    Object? lastVerified = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? notSuitable = null,
    Object? notSuitableReason = null,
    Object? notSuitableNotes = null,
    Object? notSuitableOn = freezed,
    Object? notSuitableBy = null,
    Object? mergedInto = null,
    Object? mergedOn = freezed,
    Object? mergedBy = null,
    Object? contacts = null,
    Object? branches = null,
    Object? primaryAddress = freezed,
    Object? shippingAddress = freezed,
    Object? notes = null,
    Object? journeyCount = null,
    Object? lastJourneyDate = freezed,
    Object? lastJourneyType = freezed,
    Object? lastJourneyNote = freezed,
    Object? lastJourneyContact = freezed,
    Object? nextActionDate = freezed,
    Object? nextAction = freezed,
    Object? journeyNotes = null,
  }) {
    return _then(
      _$LeadImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        sourceBrandId: freezed == sourceBrandId
            ? _value.sourceBrandId
            : sourceBrandId // ignore: cast_nullable_to_non_nullable
                  as String?,
        leadName: null == leadName
            ? _value.leadName
            : leadName // ignore: cast_nullable_to_non_nullable
                  as String,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        tier: null == tier
            ? _value.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as String,
        branchCount: null == branchCount
            ? _value.branchCount
            : branchCount // ignore: cast_nullable_to_non_nullable
                  as int,
        priceBand: null == priceBand
            ? _value.priceBand
            : priceBand // ignore: cast_nullable_to_non_nullable
                  as String,
        avgRating: freezed == avgRating
            ? _value.avgRating
            : avgRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        totalReviews: null == totalReviews
            ? _value.totalReviews
            : totalReviews // ignore: cast_nullable_to_non_nullable
                  as int,
        openStatus: null == openStatus
            ? _value.openStatus
            : openStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        sahelBranches: null == sahelBranches
            ? _value.sahelBranches
            : sahelBranches // ignore: cast_nullable_to_non_nullable
                  as int,
        isSpecialty: null == isSpecialty
            ? _value.isSpecialty
            : isSpecialty // ignore: cast_nullable_to_non_nullable
                  as bool,
        takeout: null == takeout
            ? _value.takeout
            : takeout // ignore: cast_nullable_to_non_nullable
                  as bool,
        dineIn: null == dineIn
            ? _value.dineIn
            : dineIn // ignore: cast_nullable_to_non_nullable
                  as bool,
        servesDessert: null == servesDessert
            ? _value.servesDessert
            : servesDessert // ignore: cast_nullable_to_non_nullable
                  as bool,
        onTalabat: null == onTalabat
            ? _value.onTalabat
            : onTalabat // ignore: cast_nullable_to_non_nullable
                  as bool,
        talabatAreas: null == talabatAreas
            ? _value._talabatAreas
            : talabatAreas // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        primaryArea: null == primaryArea
            ? _value.primaryArea
            : primaryArea // ignore: cast_nullable_to_non_nullable
                  as String,
        regions: null == regions
            ? _value._regions
            : regions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        governorates: null == governorates
            ? _value._governorates
            : governorates // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        areas: null == areas
            ? _value._areas
            : areas // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        website: null == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String,
        instagram: null == instagram
            ? _value.instagram
            : instagram // ignore: cast_nullable_to_non_nullable
                  as String,
        facebook: null == facebook
            ? _value.facebook
            : facebook // ignore: cast_nullable_to_non_nullable
                  as String,
        mapsUrl: null == mapsUrl
            ? _value.mapsUrl
            : mapsUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        b2bStage: null == b2bStage
            ? _value.b2bStage
            : b2bStage // ignore: cast_nullable_to_non_nullable
                  as String,
        lastVerified: freezed == lastVerified
            ? _value.lastVerified
            : lastVerified // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        notSuitable: null == notSuitable
            ? _value.notSuitable
            : notSuitable // ignore: cast_nullable_to_non_nullable
                  as bool,
        notSuitableReason: null == notSuitableReason
            ? _value.notSuitableReason
            : notSuitableReason // ignore: cast_nullable_to_non_nullable
                  as String,
        notSuitableNotes: null == notSuitableNotes
            ? _value.notSuitableNotes
            : notSuitableNotes // ignore: cast_nullable_to_non_nullable
                  as String,
        notSuitableOn: freezed == notSuitableOn
            ? _value.notSuitableOn
            : notSuitableOn // ignore: cast_nullable_to_non_nullable
                  as String?,
        notSuitableBy: null == notSuitableBy
            ? _value.notSuitableBy
            : notSuitableBy // ignore: cast_nullable_to_non_nullable
                  as String,
        mergedInto: null == mergedInto
            ? _value.mergedInto
            : mergedInto // ignore: cast_nullable_to_non_nullable
                  as String,
        mergedOn: freezed == mergedOn
            ? _value.mergedOn
            : mergedOn // ignore: cast_nullable_to_non_nullable
                  as String?,
        mergedBy: null == mergedBy
            ? _value.mergedBy
            : mergedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        contacts: null == contacts
            ? _value._contacts
            : contacts // ignore: cast_nullable_to_non_nullable
                  as List<LeadContact>,
        branches: null == branches
            ? _value._branches
            : branches // ignore: cast_nullable_to_non_nullable
                  as List<LeadBranch>,
        primaryAddress: freezed == primaryAddress
            ? _value.primaryAddress
            : primaryAddress // ignore: cast_nullable_to_non_nullable
                  as LeadAddress?,
        shippingAddress: freezed == shippingAddress
            ? _value.shippingAddress
            : shippingAddress // ignore: cast_nullable_to_non_nullable
                  as LeadAddress?,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        journeyCount: null == journeyCount
            ? _value.journeyCount
            : journeyCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastJourneyDate: freezed == lastJourneyDate
            ? _value.lastJourneyDate
            : lastJourneyDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastJourneyType: freezed == lastJourneyType
            ? _value.lastJourneyType
            : lastJourneyType // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastJourneyNote: freezed == lastJourneyNote
            ? _value.lastJourneyNote
            : lastJourneyNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastJourneyContact: freezed == lastJourneyContact
            ? _value.lastJourneyContact
            : lastJourneyContact // ignore: cast_nullable_to_non_nullable
                  as String?,
        nextActionDate: freezed == nextActionDate
            ? _value.nextActionDate
            : nextActionDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        nextAction: freezed == nextAction
            ? _value.nextAction
            : nextAction // ignore: cast_nullable_to_non_nullable
                  as String?,
        journeyNotes: null == journeyNotes
            ? _value._journeyNotes
            : journeyNotes // ignore: cast_nullable_to_non_nullable
                  as List<JourneyNote>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeadImpl extends _Lead {
  const _$LeadImpl({
    required this.name,
    @JsonKey(name: 'source_brand_id') this.sourceBrandId,
    @JsonKey(name: 'lead_name') this.leadName = '',
    this.category,
    this.score = 0,
    this.tier = '',
    @JsonKey(name: 'branch_count') this.branchCount = 0,
    @JsonKey(name: 'price_band') this.priceBand = '',
    @JsonKey(name: 'avg_rating') this.avgRating,
    @JsonKey(name: 'total_reviews') this.totalReviews = 0,
    @JsonKey(name: 'open_status') this.openStatus = '',
    @JsonKey(name: 'sahel_branches') this.sahelBranches = 0,
    @JsonKey(name: 'is_specialty') this.isSpecialty = false,
    @JsonKey(name: 'takeout') this.takeout = false,
    @JsonKey(name: 'dine_in') this.dineIn = false,
    @JsonKey(name: 'serves_dessert') this.servesDessert = false,
    @JsonKey(name: 'on_talabat', fromJson: _flag) this.onTalabat = false,
    @JsonKey(name: 'talabat_areas')
    final List<String> talabatAreas = const <String>[],
    @JsonKey(name: 'primary_area') this.primaryArea = '',
    final List<String> regions = const <String>[],
    final List<String> governorates = const <String>[],
    final List<String> areas = const <String>[],
    this.phone = '',
    this.website = '',
    this.instagram = '',
    this.facebook = '',
    @JsonKey(name: 'maps_url') this.mapsUrl = '',
    this.confidence = '',
    this.status = '',
    @JsonKey(name: 'b2b_stage') this.b2bStage = '',
    @JsonKey(name: 'last_verified') this.lastVerified,
    this.latitude,
    this.longitude,
    @JsonKey(name: 'not_suitable') this.notSuitable = false,
    @JsonKey(name: 'not_suitable_reason') this.notSuitableReason = '',
    @JsonKey(name: 'not_suitable_notes') this.notSuitableNotes = '',
    @JsonKey(name: 'not_suitable_on') this.notSuitableOn,
    @JsonKey(name: 'not_suitable_by') this.notSuitableBy = '',
    @JsonKey(name: 'merged_into') this.mergedInto = '',
    @JsonKey(name: 'merged_on') this.mergedOn,
    @JsonKey(name: 'merged_by') this.mergedBy = '',
    final List<LeadContact> contacts = const <LeadContact>[],
    @JsonKey(name: 'branches')
    final List<LeadBranch> branches = const <LeadBranch>[],
    @JsonKey(name: 'primary_address') this.primaryAddress,
    @JsonKey(name: 'shipping_address') this.shippingAddress,
    this.notes = '',
    @JsonKey(name: 'journey_count') this.journeyCount = 0,
    @JsonKey(name: 'last_journey_date') this.lastJourneyDate,
    @JsonKey(name: 'last_journey_type') this.lastJourneyType,
    @JsonKey(name: 'last_journey_note') this.lastJourneyNote,
    @JsonKey(name: 'last_journey_contact') this.lastJourneyContact,
    @JsonKey(name: 'next_action_date') this.nextActionDate,
    @JsonKey(name: 'next_action') this.nextAction,
    @JsonKey(name: 'journey_notes')
    final List<JourneyNote> journeyNotes = const <JourneyNote>[],
  }) : _talabatAreas = talabatAreas,
       _regions = regions,
       _governorates = governorates,
       _areas = areas,
       _contacts = contacts,
       _branches = branches,
       _journeyNotes = journeyNotes,
       super._();

  factory _$LeadImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'source_brand_id')
  final String? sourceBrandId;
  @override
  @JsonKey(name: 'lead_name')
  final String leadName;
  @override
  final String? category;
  @override
  @JsonKey()
  final int score;
  @override
  @JsonKey()
  final String tier;
  @override
  @JsonKey(name: 'branch_count')
  final int branchCount;
  @override
  @JsonKey(name: 'price_band')
  final String priceBand;
  @override
  @JsonKey(name: 'avg_rating')
  final double? avgRating;
  @override
  @JsonKey(name: 'total_reviews')
  final int totalReviews;
  @override
  @JsonKey(name: 'open_status')
  final String openStatus;
  @override
  @JsonKey(name: 'sahel_branches')
  final int sahelBranches;
  @override
  @JsonKey(name: 'is_specialty')
  final bool isSpecialty;
  // ── Google service signals ─────────────────────────────────────────────
  // TRUE means Google positively confirms it. FALSE means UNKNOWN, never
  // "no" — the Places API omits these fields entirely unless they are true.
  // So filter on `takeout == true` to find confirmed-takeaway venues, but
  // never treat `takeout == false` as "this place has no takeaway".
  @override
  @JsonKey(name: 'takeout')
  final bool takeout;
  @override
  @JsonKey(name: 'dine_in')
  final bool dineIn;
  @override
  @JsonKey(name: 'serves_dessert')
  final bool servesDessert;
  // ── Talabat presence ───────────────────────────────────────────────────
  // Sourced by reading Talabat's own per-area listings, NOT from Google, so
  // this one really is two-state: `false` means "not listed in any area we
  // swept", not "unknown". `talabatAreas` names the delivery zones the
  // listing was actually seen in.
  @override
  @JsonKey(name: 'on_talabat', fromJson: _flag)
  final bool onTalabat;
  final List<String> _talabatAreas;
  @override
  @JsonKey(name: 'talabat_areas')
  List<String> get talabatAreas {
    if (_talabatAreas is EqualUnmodifiableListView) return _talabatAreas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_talabatAreas);
  }

  @override
  @JsonKey(name: 'primary_area')
  final String primaryArea;
  final List<String> _regions;
  @override
  @JsonKey()
  List<String> get regions {
    if (_regions is EqualUnmodifiableListView) return _regions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_regions);
  }

  final List<String> _governorates;
  @override
  @JsonKey()
  List<String> get governorates {
    if (_governorates is EqualUnmodifiableListView) return _governorates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_governorates);
  }

  final List<String> _areas;
  @override
  @JsonKey()
  List<String> get areas {
    if (_areas is EqualUnmodifiableListView) return _areas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_areas);
  }

  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String website;
  @override
  @JsonKey()
  final String instagram;
  @override
  @JsonKey()
  final String facebook;
  @override
  @JsonKey(name: 'maps_url')
  final String mapsUrl;
  @override
  @JsonKey()
  final String confidence;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'b2b_stage')
  final String b2bStage;
  @override
  @JsonKey(name: 'last_verified')
  final String? lastVerified;
  @override
  final double? latitude;
  @override
  final double? longitude;
  // ── Manual-inspection verdict ──────────────────────────────────────────
  // Set by a rep through `set_lead_suitability`, never through `save_lead`.
  // A not-suitable lead is hidden from the working catalog by default and
  // never appears on the B2B pipeline board.
  @override
  @JsonKey(name: 'not_suitable')
  final bool notSuitable;
  @override
  @JsonKey(name: 'not_suitable_reason')
  final String notSuitableReason;
  @override
  @JsonKey(name: 'not_suitable_notes')
  final String notSuitableNotes;
  @override
  @JsonKey(name: 'not_suitable_on')
  final String? notSuitableOn;
  @override
  @JsonKey(name: 'not_suitable_by')
  final String notSuitableBy;
  // ── Duplicate-merge bookkeeping ────────────────────────────────────────
  // Non-empty on a lead that was merged INTO another as a duplicate. Such a
  // lead is excluded from the catalog server-side, so this is normally only
  // seen when a merged record is opened directly.
  @override
  @JsonKey(name: 'merged_into')
  final String mergedInto;
  @override
  @JsonKey(name: 'merged_on')
  final String? mergedOn;
  @override
  @JsonKey(name: 'merged_by')
  final String mergedBy;
  // ── People at the venue ───────────────────────────────────────────────
  // Rides on BOTH the catalog row and the detail: a rep looking at a card
  // needs to know who to ask for before walking in, not after opening it.
  final List<LeadContact> _contacts;
  // ── People at the venue ───────────────────────────────────────────────
  // Rides on BOTH the catalog row and the detail: a rep looking at a card
  // needs to know who to ask for before walking in, not after opening it.
  @override
  @JsonKey()
  List<LeadContact> get contacts {
    if (_contacts is EqualUnmodifiableListView) return _contacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contacts);
  }

  // ── Detail-only fields (present on get_lead, null on get_leads) ────────
  final List<LeadBranch> _branches;
  // ── Detail-only fields (present on get_lead, null on get_leads) ────────
  @override
  @JsonKey(name: 'branches')
  List<LeadBranch> get branches {
    if (_branches is EqualUnmodifiableListView) return _branches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_branches);
  }

  @override
  @JsonKey(name: 'primary_address')
  final LeadAddress? primaryAddress;
  @override
  @JsonKey(name: 'shipping_address')
  final LeadAddress? shippingAddress;
  @override
  @JsonKey()
  final String notes;
  // ── Journey diary ─────────────────────────────────────────────────────
  // The summary rides on BOTH the catalog row and the detail (so a list card
  // can show "visited 3 days ago, call due Thursday" without a request per
  // lead); the note list itself is detail-only.
  @override
  @JsonKey(name: 'journey_count')
  final int journeyCount;
  @override
  @JsonKey(name: 'last_journey_date')
  final String? lastJourneyDate;
  @override
  @JsonKey(name: 'last_journey_type')
  final String? lastJourneyType;
  @override
  @JsonKey(name: 'last_journey_note')
  final String? lastJourneyNote;
  @override
  @JsonKey(name: 'last_journey_contact')
  final String? lastJourneyContact;
  @override
  @JsonKey(name: 'next_action_date')
  final String? nextActionDate;
  @override
  @JsonKey(name: 'next_action')
  final String? nextAction;
  final List<JourneyNote> _journeyNotes;
  @override
  @JsonKey(name: 'journey_notes')
  List<JourneyNote> get journeyNotes {
    if (_journeyNotes is EqualUnmodifiableListView) return _journeyNotes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_journeyNotes);
  }

  @override
  String toString() {
    return 'Lead(name: $name, sourceBrandId: $sourceBrandId, leadName: $leadName, category: $category, score: $score, tier: $tier, branchCount: $branchCount, priceBand: $priceBand, avgRating: $avgRating, totalReviews: $totalReviews, openStatus: $openStatus, sahelBranches: $sahelBranches, isSpecialty: $isSpecialty, takeout: $takeout, dineIn: $dineIn, servesDessert: $servesDessert, onTalabat: $onTalabat, talabatAreas: $talabatAreas, primaryArea: $primaryArea, regions: $regions, governorates: $governorates, areas: $areas, phone: $phone, website: $website, instagram: $instagram, facebook: $facebook, mapsUrl: $mapsUrl, confidence: $confidence, status: $status, b2bStage: $b2bStage, lastVerified: $lastVerified, latitude: $latitude, longitude: $longitude, notSuitable: $notSuitable, notSuitableReason: $notSuitableReason, notSuitableNotes: $notSuitableNotes, notSuitableOn: $notSuitableOn, notSuitableBy: $notSuitableBy, mergedInto: $mergedInto, mergedOn: $mergedOn, mergedBy: $mergedBy, contacts: $contacts, branches: $branches, primaryAddress: $primaryAddress, shippingAddress: $shippingAddress, notes: $notes, journeyCount: $journeyCount, lastJourneyDate: $lastJourneyDate, lastJourneyType: $lastJourneyType, lastJourneyNote: $lastJourneyNote, lastJourneyContact: $lastJourneyContact, nextActionDate: $nextActionDate, nextAction: $nextAction, journeyNotes: $journeyNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sourceBrandId, sourceBrandId) ||
                other.sourceBrandId == sourceBrandId) &&
            (identical(other.leadName, leadName) ||
                other.leadName == leadName) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.branchCount, branchCount) ||
                other.branchCount == branchCount) &&
            (identical(other.priceBand, priceBand) ||
                other.priceBand == priceBand) &&
            (identical(other.avgRating, avgRating) ||
                other.avgRating == avgRating) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.openStatus, openStatus) ||
                other.openStatus == openStatus) &&
            (identical(other.sahelBranches, sahelBranches) ||
                other.sahelBranches == sahelBranches) &&
            (identical(other.isSpecialty, isSpecialty) ||
                other.isSpecialty == isSpecialty) &&
            (identical(other.takeout, takeout) || other.takeout == takeout) &&
            (identical(other.dineIn, dineIn) || other.dineIn == dineIn) &&
            (identical(other.servesDessert, servesDessert) ||
                other.servesDessert == servesDessert) &&
            (identical(other.onTalabat, onTalabat) ||
                other.onTalabat == onTalabat) &&
            const DeepCollectionEquality().equals(
              other._talabatAreas,
              _talabatAreas,
            ) &&
            (identical(other.primaryArea, primaryArea) ||
                other.primaryArea == primaryArea) &&
            const DeepCollectionEquality().equals(other._regions, _regions) &&
            const DeepCollectionEquality().equals(
              other._governorates,
              _governorates,
            ) &&
            const DeepCollectionEquality().equals(other._areas, _areas) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.instagram, instagram) ||
                other.instagram == instagram) &&
            (identical(other.facebook, facebook) ||
                other.facebook == facebook) &&
            (identical(other.mapsUrl, mapsUrl) || other.mapsUrl == mapsUrl) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.b2bStage, b2bStage) ||
                other.b2bStage == b2bStage) &&
            (identical(other.lastVerified, lastVerified) ||
                other.lastVerified == lastVerified) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.notSuitable, notSuitable) ||
                other.notSuitable == notSuitable) &&
            (identical(other.notSuitableReason, notSuitableReason) ||
                other.notSuitableReason == notSuitableReason) &&
            (identical(other.notSuitableNotes, notSuitableNotes) ||
                other.notSuitableNotes == notSuitableNotes) &&
            (identical(other.notSuitableOn, notSuitableOn) ||
                other.notSuitableOn == notSuitableOn) &&
            (identical(other.notSuitableBy, notSuitableBy) ||
                other.notSuitableBy == notSuitableBy) &&
            (identical(other.mergedInto, mergedInto) ||
                other.mergedInto == mergedInto) &&
            (identical(other.mergedOn, mergedOn) ||
                other.mergedOn == mergedOn) &&
            (identical(other.mergedBy, mergedBy) ||
                other.mergedBy == mergedBy) &&
            const DeepCollectionEquality().equals(other._contacts, _contacts) &&
            const DeepCollectionEquality().equals(other._branches, _branches) &&
            (identical(other.primaryAddress, primaryAddress) ||
                other.primaryAddress == primaryAddress) &&
            (identical(other.shippingAddress, shippingAddress) ||
                other.shippingAddress == shippingAddress) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.journeyCount, journeyCount) ||
                other.journeyCount == journeyCount) &&
            (identical(other.lastJourneyDate, lastJourneyDate) ||
                other.lastJourneyDate == lastJourneyDate) &&
            (identical(other.lastJourneyType, lastJourneyType) ||
                other.lastJourneyType == lastJourneyType) &&
            (identical(other.lastJourneyNote, lastJourneyNote) ||
                other.lastJourneyNote == lastJourneyNote) &&
            (identical(other.lastJourneyContact, lastJourneyContact) ||
                other.lastJourneyContact == lastJourneyContact) &&
            (identical(other.nextActionDate, nextActionDate) ||
                other.nextActionDate == nextActionDate) &&
            (identical(other.nextAction, nextAction) ||
                other.nextAction == nextAction) &&
            const DeepCollectionEquality().equals(
              other._journeyNotes,
              _journeyNotes,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    name,
    sourceBrandId,
    leadName,
    category,
    score,
    tier,
    branchCount,
    priceBand,
    avgRating,
    totalReviews,
    openStatus,
    sahelBranches,
    isSpecialty,
    takeout,
    dineIn,
    servesDessert,
    onTalabat,
    const DeepCollectionEquality().hash(_talabatAreas),
    primaryArea,
    const DeepCollectionEquality().hash(_regions),
    const DeepCollectionEquality().hash(_governorates),
    const DeepCollectionEquality().hash(_areas),
    phone,
    website,
    instagram,
    facebook,
    mapsUrl,
    confidence,
    status,
    b2bStage,
    lastVerified,
    latitude,
    longitude,
    notSuitable,
    notSuitableReason,
    notSuitableNotes,
    notSuitableOn,
    notSuitableBy,
    mergedInto,
    mergedOn,
    mergedBy,
    const DeepCollectionEquality().hash(_contacts),
    const DeepCollectionEquality().hash(_branches),
    primaryAddress,
    shippingAddress,
    notes,
    journeyCount,
    lastJourneyDate,
    lastJourneyType,
    lastJourneyNote,
    lastJourneyContact,
    nextActionDate,
    nextAction,
    const DeepCollectionEquality().hash(_journeyNotes),
  ]);

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadImplCopyWith<_$LeadImpl> get copyWith =>
      __$$LeadImplCopyWithImpl<_$LeadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadImplToJson(this);
  }
}

abstract class _Lead extends Lead {
  const factory _Lead({
    required final String name,
    @JsonKey(name: 'source_brand_id') final String? sourceBrandId,
    @JsonKey(name: 'lead_name') final String leadName,
    final String? category,
    final int score,
    final String tier,
    @JsonKey(name: 'branch_count') final int branchCount,
    @JsonKey(name: 'price_band') final String priceBand,
    @JsonKey(name: 'avg_rating') final double? avgRating,
    @JsonKey(name: 'total_reviews') final int totalReviews,
    @JsonKey(name: 'open_status') final String openStatus,
    @JsonKey(name: 'sahel_branches') final int sahelBranches,
    @JsonKey(name: 'is_specialty') final bool isSpecialty,
    @JsonKey(name: 'takeout') final bool takeout,
    @JsonKey(name: 'dine_in') final bool dineIn,
    @JsonKey(name: 'serves_dessert') final bool servesDessert,
    @JsonKey(name: 'on_talabat', fromJson: _flag) final bool onTalabat,
    @JsonKey(name: 'talabat_areas') final List<String> talabatAreas,
    @JsonKey(name: 'primary_area') final String primaryArea,
    final List<String> regions,
    final List<String> governorates,
    final List<String> areas,
    final String phone,
    final String website,
    final String instagram,
    final String facebook,
    @JsonKey(name: 'maps_url') final String mapsUrl,
    final String confidence,
    final String status,
    @JsonKey(name: 'b2b_stage') final String b2bStage,
    @JsonKey(name: 'last_verified') final String? lastVerified,
    final double? latitude,
    final double? longitude,
    @JsonKey(name: 'not_suitable') final bool notSuitable,
    @JsonKey(name: 'not_suitable_reason') final String notSuitableReason,
    @JsonKey(name: 'not_suitable_notes') final String notSuitableNotes,
    @JsonKey(name: 'not_suitable_on') final String? notSuitableOn,
    @JsonKey(name: 'not_suitable_by') final String notSuitableBy,
    @JsonKey(name: 'merged_into') final String mergedInto,
    @JsonKey(name: 'merged_on') final String? mergedOn,
    @JsonKey(name: 'merged_by') final String mergedBy,
    final List<LeadContact> contacts,
    @JsonKey(name: 'branches') final List<LeadBranch> branches,
    @JsonKey(name: 'primary_address') final LeadAddress? primaryAddress,
    @JsonKey(name: 'shipping_address') final LeadAddress? shippingAddress,
    final String notes,
    @JsonKey(name: 'journey_count') final int journeyCount,
    @JsonKey(name: 'last_journey_date') final String? lastJourneyDate,
    @JsonKey(name: 'last_journey_type') final String? lastJourneyType,
    @JsonKey(name: 'last_journey_note') final String? lastJourneyNote,
    @JsonKey(name: 'last_journey_contact') final String? lastJourneyContact,
    @JsonKey(name: 'next_action_date') final String? nextActionDate,
    @JsonKey(name: 'next_action') final String? nextAction,
    @JsonKey(name: 'journey_notes') final List<JourneyNote> journeyNotes,
  }) = _$LeadImpl;
  const _Lead._() : super._();

  factory _Lead.fromJson(Map<String, dynamic> json) = _$LeadImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'source_brand_id')
  String? get sourceBrandId;
  @override
  @JsonKey(name: 'lead_name')
  String get leadName;
  @override
  String? get category;
  @override
  int get score;
  @override
  String get tier;
  @override
  @JsonKey(name: 'branch_count')
  int get branchCount;
  @override
  @JsonKey(name: 'price_band')
  String get priceBand;
  @override
  @JsonKey(name: 'avg_rating')
  double? get avgRating;
  @override
  @JsonKey(name: 'total_reviews')
  int get totalReviews;
  @override
  @JsonKey(name: 'open_status')
  String get openStatus;
  @override
  @JsonKey(name: 'sahel_branches')
  int get sahelBranches;
  @override
  @JsonKey(name: 'is_specialty')
  bool get isSpecialty; // ── Google service signals ─────────────────────────────────────────────
  // TRUE means Google positively confirms it. FALSE means UNKNOWN, never
  // "no" — the Places API omits these fields entirely unless they are true.
  // So filter on `takeout == true` to find confirmed-takeaway venues, but
  // never treat `takeout == false` as "this place has no takeaway".
  @override
  @JsonKey(name: 'takeout')
  bool get takeout;
  @override
  @JsonKey(name: 'dine_in')
  bool get dineIn;
  @override
  @JsonKey(name: 'serves_dessert')
  bool get servesDessert; // ── Talabat presence ───────────────────────────────────────────────────
  // Sourced by reading Talabat's own per-area listings, NOT from Google, so
  // this one really is two-state: `false` means "not listed in any area we
  // swept", not "unknown". `talabatAreas` names the delivery zones the
  // listing was actually seen in.
  @override
  @JsonKey(name: 'on_talabat', fromJson: _flag)
  bool get onTalabat;
  @override
  @JsonKey(name: 'talabat_areas')
  List<String> get talabatAreas;
  @override
  @JsonKey(name: 'primary_area')
  String get primaryArea;
  @override
  List<String> get regions;
  @override
  List<String> get governorates;
  @override
  List<String> get areas;
  @override
  String get phone;
  @override
  String get website;
  @override
  String get instagram;
  @override
  String get facebook;
  @override
  @JsonKey(name: 'maps_url')
  String get mapsUrl;
  @override
  String get confidence;
  @override
  String get status;
  @override
  @JsonKey(name: 'b2b_stage')
  String get b2bStage;
  @override
  @JsonKey(name: 'last_verified')
  String? get lastVerified;
  @override
  double? get latitude;
  @override
  double? get longitude; // ── Manual-inspection verdict ──────────────────────────────────────────
  // Set by a rep through `set_lead_suitability`, never through `save_lead`.
  // A not-suitable lead is hidden from the working catalog by default and
  // never appears on the B2B pipeline board.
  @override
  @JsonKey(name: 'not_suitable')
  bool get notSuitable;
  @override
  @JsonKey(name: 'not_suitable_reason')
  String get notSuitableReason;
  @override
  @JsonKey(name: 'not_suitable_notes')
  String get notSuitableNotes;
  @override
  @JsonKey(name: 'not_suitable_on')
  String? get notSuitableOn;
  @override
  @JsonKey(name: 'not_suitable_by')
  String get notSuitableBy; // ── Duplicate-merge bookkeeping ────────────────────────────────────────
  // Non-empty on a lead that was merged INTO another as a duplicate. Such a
  // lead is excluded from the catalog server-side, so this is normally only
  // seen when a merged record is opened directly.
  @override
  @JsonKey(name: 'merged_into')
  String get mergedInto;
  @override
  @JsonKey(name: 'merged_on')
  String? get mergedOn;
  @override
  @JsonKey(name: 'merged_by')
  String get mergedBy; // ── People at the venue ───────────────────────────────────────────────
  // Rides on BOTH the catalog row and the detail: a rep looking at a card
  // needs to know who to ask for before walking in, not after opening it.
  @override
  List<LeadContact> get contacts; // ── Detail-only fields (present on get_lead, null on get_leads) ────────
  @override
  @JsonKey(name: 'branches')
  List<LeadBranch> get branches;
  @override
  @JsonKey(name: 'primary_address')
  LeadAddress? get primaryAddress;
  @override
  @JsonKey(name: 'shipping_address')
  LeadAddress? get shippingAddress;
  @override
  String get notes; // ── Journey diary ─────────────────────────────────────────────────────
  // The summary rides on BOTH the catalog row and the detail (so a list card
  // can show "visited 3 days ago, call due Thursday" without a request per
  // lead); the note list itself is detail-only.
  @override
  @JsonKey(name: 'journey_count')
  int get journeyCount;
  @override
  @JsonKey(name: 'last_journey_date')
  String? get lastJourneyDate;
  @override
  @JsonKey(name: 'last_journey_type')
  String? get lastJourneyType;
  @override
  @JsonKey(name: 'last_journey_note')
  String? get lastJourneyNote;
  @override
  @JsonKey(name: 'last_journey_contact')
  String? get lastJourneyContact;
  @override
  @JsonKey(name: 'next_action_date')
  String? get nextActionDate;
  @override
  @JsonKey(name: 'next_action')
  String? get nextAction;
  @override
  @JsonKey(name: 'journey_notes')
  List<JourneyNote> get journeyNotes;

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadImplCopyWith<_$LeadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeadContact _$LeadContactFromJson(Map<String, dynamic> json) {
  return _LeadContact.fromJson(json);
}

/// @nodoc
mixin _$LeadContact {
  @JsonKey(name: 'contact_name')
  String get contactName => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_primary')
  bool get isPrimary => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;

  /// Serializes this LeadContact to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeadContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadContactCopyWith<LeadContact> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadContactCopyWith<$Res> {
  factory $LeadContactCopyWith(
    LeadContact value,
    $Res Function(LeadContact) then,
  ) = _$LeadContactCopyWithImpl<$Res, LeadContact>;
  @useResult
  $Res call({
    @JsonKey(name: 'contact_name') String contactName,
    String role,
    String phone,
    String email,
    @JsonKey(name: 'is_primary') bool isPrimary,
    String notes,
  });
}

/// @nodoc
class _$LeadContactCopyWithImpl<$Res, $Val extends LeadContact>
    implements $LeadContactCopyWith<$Res> {
  _$LeadContactCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeadContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contactName = null,
    Object? role = null,
    Object? phone = null,
    Object? email = null,
    Object? isPrimary = null,
    Object? notes = null,
  }) {
    return _then(
      _value.copyWith(
            contactName: null == contactName
                ? _value.contactName
                : contactName // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            isPrimary: null == isPrimary
                ? _value.isPrimary
                : isPrimary // ignore: cast_nullable_to_non_nullable
                      as bool,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeadContactImplCopyWith<$Res>
    implements $LeadContactCopyWith<$Res> {
  factory _$$LeadContactImplCopyWith(
    _$LeadContactImpl value,
    $Res Function(_$LeadContactImpl) then,
  ) = __$$LeadContactImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'contact_name') String contactName,
    String role,
    String phone,
    String email,
    @JsonKey(name: 'is_primary') bool isPrimary,
    String notes,
  });
}

/// @nodoc
class __$$LeadContactImplCopyWithImpl<$Res>
    extends _$LeadContactCopyWithImpl<$Res, _$LeadContactImpl>
    implements _$$LeadContactImplCopyWith<$Res> {
  __$$LeadContactImplCopyWithImpl(
    _$LeadContactImpl _value,
    $Res Function(_$LeadContactImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeadContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contactName = null,
    Object? role = null,
    Object? phone = null,
    Object? email = null,
    Object? isPrimary = null,
    Object? notes = null,
  }) {
    return _then(
      _$LeadContactImpl(
        contactName: null == contactName
            ? _value.contactName
            : contactName // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        isPrimary: null == isPrimary
            ? _value.isPrimary
            : isPrimary // ignore: cast_nullable_to_non_nullable
                  as bool,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeadContactImpl extends _LeadContact {
  const _$LeadContactImpl({
    @JsonKey(name: 'contact_name') this.contactName = '',
    this.role = '',
    this.phone = '',
    this.email = '',
    @JsonKey(name: 'is_primary') this.isPrimary = false,
    this.notes = '',
  }) : super._();

  factory _$LeadContactImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadContactImplFromJson(json);

  @override
  @JsonKey(name: 'contact_name')
  final String contactName;
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey(name: 'is_primary')
  final bool isPrimary;
  @override
  @JsonKey()
  final String notes;

  @override
  String toString() {
    return 'LeadContact(contactName: $contactName, role: $role, phone: $phone, email: $email, isPrimary: $isPrimary, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadContactImpl &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    contactName,
    role,
    phone,
    email,
    isPrimary,
    notes,
  );

  /// Create a copy of LeadContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadContactImplCopyWith<_$LeadContactImpl> get copyWith =>
      __$$LeadContactImplCopyWithImpl<_$LeadContactImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadContactImplToJson(this);
  }
}

abstract class _LeadContact extends LeadContact {
  const factory _LeadContact({
    @JsonKey(name: 'contact_name') final String contactName,
    final String role,
    final String phone,
    final String email,
    @JsonKey(name: 'is_primary') final bool isPrimary,
    final String notes,
  }) = _$LeadContactImpl;
  const _LeadContact._() : super._();

  factory _LeadContact.fromJson(Map<String, dynamic> json) =
      _$LeadContactImpl.fromJson;

  @override
  @JsonKey(name: 'contact_name')
  String get contactName;
  @override
  String get role;
  @override
  String get phone;
  @override
  String get email;
  @override
  @JsonKey(name: 'is_primary')
  bool get isPrimary;
  @override
  String get notes;

  /// Create a copy of LeadContact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadContactImplCopyWith<_$LeadContactImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeadBranch _$LeadBranchFromJson(Map<String, dynamic> json) {
  return _LeadBranch.fromJson(json);
}

/// @nodoc
mixin _$LeadBranch {
  @JsonKey(name: 'branch_name')
  String get branchName => throw _privateConstructorUsedError;
  String get area => throw _privateConstructorUsedError;
  String get region => throw _privateConstructorUsedError;
  String get governorate => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  int get reviews => throw _privateConstructorUsedError;
  String get price => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get hours => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get website => throw _privateConstructorUsedError;
  @JsonKey(name: 'maps_url')
  String get mapsUrl => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'on_talabat', fromJson: _flag)
  bool get onTalabat => throw _privateConstructorUsedError;

  /// Serializes this LeadBranch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeadBranch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadBranchCopyWith<LeadBranch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadBranchCopyWith<$Res> {
  factory $LeadBranchCopyWith(
    LeadBranch value,
    $Res Function(LeadBranch) then,
  ) = _$LeadBranchCopyWithImpl<$Res, LeadBranch>;
  @useResult
  $Res call({
    @JsonKey(name: 'branch_name') String branchName,
    String area,
    String region,
    String governorate,
    double? rating,
    int reviews,
    String price,
    String status,
    String hours,
    String phone,
    String website,
    @JsonKey(name: 'maps_url') String mapsUrl,
    String address,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'on_talabat', fromJson: _flag) bool onTalabat,
  });
}

/// @nodoc
class _$LeadBranchCopyWithImpl<$Res, $Val extends LeadBranch>
    implements $LeadBranchCopyWith<$Res> {
  _$LeadBranchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeadBranch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? branchName = null,
    Object? area = null,
    Object? region = null,
    Object? governorate = null,
    Object? rating = freezed,
    Object? reviews = null,
    Object? price = null,
    Object? status = null,
    Object? hours = null,
    Object? phone = null,
    Object? website = null,
    Object? mapsUrl = null,
    Object? address = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? onTalabat = null,
  }) {
    return _then(
      _value.copyWith(
            branchName: null == branchName
                ? _value.branchName
                : branchName // ignore: cast_nullable_to_non_nullable
                      as String,
            area: null == area
                ? _value.area
                : area // ignore: cast_nullable_to_non_nullable
                      as String,
            region: null == region
                ? _value.region
                : region // ignore: cast_nullable_to_non_nullable
                      as String,
            governorate: null == governorate
                ? _value.governorate
                : governorate // ignore: cast_nullable_to_non_nullable
                      as String,
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double?,
            reviews: null == reviews
                ? _value.reviews
                : reviews // ignore: cast_nullable_to_non_nullable
                      as int,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            hours: null == hours
                ? _value.hours
                : hours // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            website: null == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String,
            mapsUrl: null == mapsUrl
                ? _value.mapsUrl
                : mapsUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            onTalabat: null == onTalabat
                ? _value.onTalabat
                : onTalabat // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeadBranchImplCopyWith<$Res>
    implements $LeadBranchCopyWith<$Res> {
  factory _$$LeadBranchImplCopyWith(
    _$LeadBranchImpl value,
    $Res Function(_$LeadBranchImpl) then,
  ) = __$$LeadBranchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'branch_name') String branchName,
    String area,
    String region,
    String governorate,
    double? rating,
    int reviews,
    String price,
    String status,
    String hours,
    String phone,
    String website,
    @JsonKey(name: 'maps_url') String mapsUrl,
    String address,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'on_talabat', fromJson: _flag) bool onTalabat,
  });
}

/// @nodoc
class __$$LeadBranchImplCopyWithImpl<$Res>
    extends _$LeadBranchCopyWithImpl<$Res, _$LeadBranchImpl>
    implements _$$LeadBranchImplCopyWith<$Res> {
  __$$LeadBranchImplCopyWithImpl(
    _$LeadBranchImpl _value,
    $Res Function(_$LeadBranchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeadBranch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? branchName = null,
    Object? area = null,
    Object? region = null,
    Object? governorate = null,
    Object? rating = freezed,
    Object? reviews = null,
    Object? price = null,
    Object? status = null,
    Object? hours = null,
    Object? phone = null,
    Object? website = null,
    Object? mapsUrl = null,
    Object? address = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? onTalabat = null,
  }) {
    return _then(
      _$LeadBranchImpl(
        branchName: null == branchName
            ? _value.branchName
            : branchName // ignore: cast_nullable_to_non_nullable
                  as String,
        area: null == area
            ? _value.area
            : area // ignore: cast_nullable_to_non_nullable
                  as String,
        region: null == region
            ? _value.region
            : region // ignore: cast_nullable_to_non_nullable
                  as String,
        governorate: null == governorate
            ? _value.governorate
            : governorate // ignore: cast_nullable_to_non_nullable
                  as String,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double?,
        reviews: null == reviews
            ? _value.reviews
            : reviews // ignore: cast_nullable_to_non_nullable
                  as int,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        hours: null == hours
            ? _value.hours
            : hours // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        website: null == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String,
        mapsUrl: null == mapsUrl
            ? _value.mapsUrl
            : mapsUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        onTalabat: null == onTalabat
            ? _value.onTalabat
            : onTalabat // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeadBranchImpl implements _LeadBranch {
  const _$LeadBranchImpl({
    @JsonKey(name: 'branch_name') this.branchName = '',
    this.area = '',
    this.region = '',
    this.governorate = '',
    this.rating,
    this.reviews = 0,
    this.price = '',
    this.status = '',
    this.hours = '',
    this.phone = '',
    this.website = '',
    @JsonKey(name: 'maps_url') this.mapsUrl = '',
    this.address = '',
    this.latitude,
    this.longitude,
    @JsonKey(name: 'on_talabat', fromJson: _flag) this.onTalabat = false,
  });

  factory _$LeadBranchImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadBranchImplFromJson(json);

  @override
  @JsonKey(name: 'branch_name')
  final String branchName;
  @override
  @JsonKey()
  final String area;
  @override
  @JsonKey()
  final String region;
  @override
  @JsonKey()
  final String governorate;
  @override
  final double? rating;
  @override
  @JsonKey()
  final int reviews;
  @override
  @JsonKey()
  final String price;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String hours;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String website;
  @override
  @JsonKey(name: 'maps_url')
  final String mapsUrl;
  @override
  @JsonKey()
  final String address;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey(name: 'on_talabat', fromJson: _flag)
  final bool onTalabat;

  @override
  String toString() {
    return 'LeadBranch(branchName: $branchName, area: $area, region: $region, governorate: $governorate, rating: $rating, reviews: $reviews, price: $price, status: $status, hours: $hours, phone: $phone, website: $website, mapsUrl: $mapsUrl, address: $address, latitude: $latitude, longitude: $longitude, onTalabat: $onTalabat)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadBranchImpl &&
            (identical(other.branchName, branchName) ||
                other.branchName == branchName) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.governorate, governorate) ||
                other.governorate == governorate) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviews, reviews) || other.reviews == reviews) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.hours, hours) || other.hours == hours) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.mapsUrl, mapsUrl) || other.mapsUrl == mapsUrl) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.onTalabat, onTalabat) ||
                other.onTalabat == onTalabat));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    branchName,
    area,
    region,
    governorate,
    rating,
    reviews,
    price,
    status,
    hours,
    phone,
    website,
    mapsUrl,
    address,
    latitude,
    longitude,
    onTalabat,
  );

  /// Create a copy of LeadBranch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadBranchImplCopyWith<_$LeadBranchImpl> get copyWith =>
      __$$LeadBranchImplCopyWithImpl<_$LeadBranchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadBranchImplToJson(this);
  }
}

abstract class _LeadBranch implements LeadBranch {
  const factory _LeadBranch({
    @JsonKey(name: 'branch_name') final String branchName,
    final String area,
    final String region,
    final String governorate,
    final double? rating,
    final int reviews,
    final String price,
    final String status,
    final String hours,
    final String phone,
    final String website,
    @JsonKey(name: 'maps_url') final String mapsUrl,
    final String address,
    final double? latitude,
    final double? longitude,
    @JsonKey(name: 'on_talabat', fromJson: _flag) final bool onTalabat,
  }) = _$LeadBranchImpl;

  factory _LeadBranch.fromJson(Map<String, dynamic> json) =
      _$LeadBranchImpl.fromJson;

  @override
  @JsonKey(name: 'branch_name')
  String get branchName;
  @override
  String get area;
  @override
  String get region;
  @override
  String get governorate;
  @override
  double? get rating;
  @override
  int get reviews;
  @override
  String get price;
  @override
  String get status;
  @override
  String get hours;
  @override
  String get phone;
  @override
  String get website;
  @override
  @JsonKey(name: 'maps_url')
  String get mapsUrl;
  @override
  String get address;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  @JsonKey(name: 'on_talabat', fromJson: _flag)
  bool get onTalabat;

  /// Create a copy of LeadBranch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadBranchImplCopyWith<_$LeadBranchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeadAddress _$LeadAddressFromJson(Map<String, dynamic> json) {
  return _LeadAddress.fromJson(json);
}

/// @nodoc
mixin _$LeadAddress {
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_line1')
  String get addressLine1 => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_line2')
  String get addressLine2 => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  String get pincode => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;

  /// Serializes this LeadAddress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeadAddress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadAddressCopyWith<LeadAddress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadAddressCopyWith<$Res> {
  factory $LeadAddressCopyWith(
    LeadAddress value,
    $Res Function(LeadAddress) then,
  ) = _$LeadAddressCopyWithImpl<$Res, LeadAddress>;
  @useResult
  $Res call({
    String? name,
    @JsonKey(name: 'address_line1') String addressLine1,
    @JsonKey(name: 'address_line2') String addressLine2,
    String city,
    String state,
    String country,
    String pincode,
    String phone,
  });
}

/// @nodoc
class _$LeadAddressCopyWithImpl<$Res, $Val extends LeadAddress>
    implements $LeadAddressCopyWith<$Res> {
  _$LeadAddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeadAddress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? addressLine1 = null,
    Object? addressLine2 = null,
    Object? city = null,
    Object? state = null,
    Object? country = null,
    Object? pincode = null,
    Object? phone = null,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            addressLine1: null == addressLine1
                ? _value.addressLine1
                : addressLine1 // ignore: cast_nullable_to_non_nullable
                      as String,
            addressLine2: null == addressLine2
                ? _value.addressLine2
                : addressLine2 // ignore: cast_nullable_to_non_nullable
                      as String,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as String,
            country: null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String,
            pincode: null == pincode
                ? _value.pincode
                : pincode // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeadAddressImplCopyWith<$Res>
    implements $LeadAddressCopyWith<$Res> {
  factory _$$LeadAddressImplCopyWith(
    _$LeadAddressImpl value,
    $Res Function(_$LeadAddressImpl) then,
  ) = __$$LeadAddressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? name,
    @JsonKey(name: 'address_line1') String addressLine1,
    @JsonKey(name: 'address_line2') String addressLine2,
    String city,
    String state,
    String country,
    String pincode,
    String phone,
  });
}

/// @nodoc
class __$$LeadAddressImplCopyWithImpl<$Res>
    extends _$LeadAddressCopyWithImpl<$Res, _$LeadAddressImpl>
    implements _$$LeadAddressImplCopyWith<$Res> {
  __$$LeadAddressImplCopyWithImpl(
    _$LeadAddressImpl _value,
    $Res Function(_$LeadAddressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeadAddress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? addressLine1 = null,
    Object? addressLine2 = null,
    Object? city = null,
    Object? state = null,
    Object? country = null,
    Object? pincode = null,
    Object? phone = null,
  }) {
    return _then(
      _$LeadAddressImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        addressLine1: null == addressLine1
            ? _value.addressLine1
            : addressLine1 // ignore: cast_nullable_to_non_nullable
                  as String,
        addressLine2: null == addressLine2
            ? _value.addressLine2
            : addressLine2 // ignore: cast_nullable_to_non_nullable
                  as String,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
        pincode: null == pincode
            ? _value.pincode
            : pincode // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeadAddressImpl implements _LeadAddress {
  const _$LeadAddressImpl({
    this.name,
    @JsonKey(name: 'address_line1') this.addressLine1 = '',
    @JsonKey(name: 'address_line2') this.addressLine2 = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.pincode = '',
    this.phone = '',
  });

  factory _$LeadAddressImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadAddressImplFromJson(json);

  @override
  final String? name;
  @override
  @JsonKey(name: 'address_line1')
  final String addressLine1;
  @override
  @JsonKey(name: 'address_line2')
  final String addressLine2;
  @override
  @JsonKey()
  final String city;
  @override
  @JsonKey()
  final String state;
  @override
  @JsonKey()
  final String country;
  @override
  @JsonKey()
  final String pincode;
  @override
  @JsonKey()
  final String phone;

  @override
  String toString() {
    return 'LeadAddress(name: $name, addressLine1: $addressLine1, addressLine2: $addressLine2, city: $city, state: $state, country: $country, pincode: $pincode, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadAddressImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.addressLine1, addressLine1) ||
                other.addressLine1 == addressLine1) &&
            (identical(other.addressLine2, addressLine2) ||
                other.addressLine2 == addressLine2) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.pincode, pincode) || other.pincode == pincode) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    addressLine1,
    addressLine2,
    city,
    state,
    country,
    pincode,
    phone,
  );

  /// Create a copy of LeadAddress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadAddressImplCopyWith<_$LeadAddressImpl> get copyWith =>
      __$$LeadAddressImplCopyWithImpl<_$LeadAddressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadAddressImplToJson(this);
  }
}

abstract class _LeadAddress implements LeadAddress {
  const factory _LeadAddress({
    final String? name,
    @JsonKey(name: 'address_line1') final String addressLine1,
    @JsonKey(name: 'address_line2') final String addressLine2,
    final String city,
    final String state,
    final String country,
    final String pincode,
    final String phone,
  }) = _$LeadAddressImpl;

  factory _LeadAddress.fromJson(Map<String, dynamic> json) =
      _$LeadAddressImpl.fromJson;

  @override
  String? get name;
  @override
  @JsonKey(name: 'address_line1')
  String get addressLine1;
  @override
  @JsonKey(name: 'address_line2')
  String get addressLine2;
  @override
  String get city;
  @override
  String get state;
  @override
  String get country;
  @override
  String get pincode;
  @override
  String get phone;

  /// Create a copy of LeadAddress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadAddressImplCopyWith<_$LeadAddressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeadMergeCandidate _$LeadMergeCandidateFromJson(Map<String, dynamic> json) {
  return _LeadMergeCandidate.fromJson(json);
}

/// @nodoc
mixin _$LeadMergeCandidate {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'lead_name')
  String get leadName => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'branch_count')
  int get branchCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'primary_area')
  String get primaryArea => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get instagram => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  List<String> get reasons => throw _privateConstructorUsedError;

  /// Serializes this LeadMergeCandidate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeadMergeCandidate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadMergeCandidateCopyWith<LeadMergeCandidate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadMergeCandidateCopyWith<$Res> {
  factory $LeadMergeCandidateCopyWith(
    LeadMergeCandidate value,
    $Res Function(LeadMergeCandidate) then,
  ) = _$LeadMergeCandidateCopyWithImpl<$Res, LeadMergeCandidate>;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'lead_name') String leadName,
    String category,
    @JsonKey(name: 'branch_count') int branchCount,
    @JsonKey(name: 'primary_area') String primaryArea,
    String phone,
    String instagram,
    int score,
    List<String> reasons,
  });
}

/// @nodoc
class _$LeadMergeCandidateCopyWithImpl<$Res, $Val extends LeadMergeCandidate>
    implements $LeadMergeCandidateCopyWith<$Res> {
  _$LeadMergeCandidateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeadMergeCandidate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? leadName = null,
    Object? category = null,
    Object? branchCount = null,
    Object? primaryArea = null,
    Object? phone = null,
    Object? instagram = null,
    Object? score = null,
    Object? reasons = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            leadName: null == leadName
                ? _value.leadName
                : leadName // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            branchCount: null == branchCount
                ? _value.branchCount
                : branchCount // ignore: cast_nullable_to_non_nullable
                      as int,
            primaryArea: null == primaryArea
                ? _value.primaryArea
                : primaryArea // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            instagram: null == instagram
                ? _value.instagram
                : instagram // ignore: cast_nullable_to_non_nullable
                      as String,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            reasons: null == reasons
                ? _value.reasons
                : reasons // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeadMergeCandidateImplCopyWith<$Res>
    implements $LeadMergeCandidateCopyWith<$Res> {
  factory _$$LeadMergeCandidateImplCopyWith(
    _$LeadMergeCandidateImpl value,
    $Res Function(_$LeadMergeCandidateImpl) then,
  ) = __$$LeadMergeCandidateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'lead_name') String leadName,
    String category,
    @JsonKey(name: 'branch_count') int branchCount,
    @JsonKey(name: 'primary_area') String primaryArea,
    String phone,
    String instagram,
    int score,
    List<String> reasons,
  });
}

/// @nodoc
class __$$LeadMergeCandidateImplCopyWithImpl<$Res>
    extends _$LeadMergeCandidateCopyWithImpl<$Res, _$LeadMergeCandidateImpl>
    implements _$$LeadMergeCandidateImplCopyWith<$Res> {
  __$$LeadMergeCandidateImplCopyWithImpl(
    _$LeadMergeCandidateImpl _value,
    $Res Function(_$LeadMergeCandidateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeadMergeCandidate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? leadName = null,
    Object? category = null,
    Object? branchCount = null,
    Object? primaryArea = null,
    Object? phone = null,
    Object? instagram = null,
    Object? score = null,
    Object? reasons = null,
  }) {
    return _then(
      _$LeadMergeCandidateImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        leadName: null == leadName
            ? _value.leadName
            : leadName // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        branchCount: null == branchCount
            ? _value.branchCount
            : branchCount // ignore: cast_nullable_to_non_nullable
                  as int,
        primaryArea: null == primaryArea
            ? _value.primaryArea
            : primaryArea // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        instagram: null == instagram
            ? _value.instagram
            : instagram // ignore: cast_nullable_to_non_nullable
                  as String,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        reasons: null == reasons
            ? _value._reasons
            : reasons // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeadMergeCandidateImpl implements _LeadMergeCandidate {
  const _$LeadMergeCandidateImpl({
    required this.name,
    @JsonKey(name: 'lead_name') this.leadName = '',
    this.category = '',
    @JsonKey(name: 'branch_count') this.branchCount = 0,
    @JsonKey(name: 'primary_area') this.primaryArea = '',
    this.phone = '',
    this.instagram = '',
    this.score = 0,
    final List<String> reasons = const <String>[],
  }) : _reasons = reasons;

  factory _$LeadMergeCandidateImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadMergeCandidateImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'lead_name')
  final String leadName;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey(name: 'branch_count')
  final int branchCount;
  @override
  @JsonKey(name: 'primary_area')
  final String primaryArea;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String instagram;
  @override
  @JsonKey()
  final int score;
  final List<String> _reasons;
  @override
  @JsonKey()
  List<String> get reasons {
    if (_reasons is EqualUnmodifiableListView) return _reasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reasons);
  }

  @override
  String toString() {
    return 'LeadMergeCandidate(name: $name, leadName: $leadName, category: $category, branchCount: $branchCount, primaryArea: $primaryArea, phone: $phone, instagram: $instagram, score: $score, reasons: $reasons)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadMergeCandidateImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.leadName, leadName) ||
                other.leadName == leadName) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.branchCount, branchCount) ||
                other.branchCount == branchCount) &&
            (identical(other.primaryArea, primaryArea) ||
                other.primaryArea == primaryArea) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.instagram, instagram) ||
                other.instagram == instagram) &&
            (identical(other.score, score) || other.score == score) &&
            const DeepCollectionEquality().equals(other._reasons, _reasons));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    leadName,
    category,
    branchCount,
    primaryArea,
    phone,
    instagram,
    score,
    const DeepCollectionEquality().hash(_reasons),
  );

  /// Create a copy of LeadMergeCandidate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadMergeCandidateImplCopyWith<_$LeadMergeCandidateImpl> get copyWith =>
      __$$LeadMergeCandidateImplCopyWithImpl<_$LeadMergeCandidateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadMergeCandidateImplToJson(this);
  }
}

abstract class _LeadMergeCandidate implements LeadMergeCandidate {
  const factory _LeadMergeCandidate({
    required final String name,
    @JsonKey(name: 'lead_name') final String leadName,
    final String category,
    @JsonKey(name: 'branch_count') final int branchCount,
    @JsonKey(name: 'primary_area') final String primaryArea,
    final String phone,
    final String instagram,
    final int score,
    final List<String> reasons,
  }) = _$LeadMergeCandidateImpl;

  factory _LeadMergeCandidate.fromJson(Map<String, dynamic> json) =
      _$LeadMergeCandidateImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'lead_name')
  String get leadName;
  @override
  String get category;
  @override
  @JsonKey(name: 'branch_count')
  int get branchCount;
  @override
  @JsonKey(name: 'primary_area')
  String get primaryArea;
  @override
  String get phone;
  @override
  String get instagram;
  @override
  int get score;
  @override
  List<String> get reasons;

  /// Create a copy of LeadMergeCandidate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadMergeCandidateImplCopyWith<_$LeadMergeCandidateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeadCategory _$LeadCategoryFromJson(Map<String, dynamic> json) {
  return _LeadCategory.fromJson(json);
}

/// @nodoc
mixin _$LeadCategory {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_name')
  String get categoryName => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;

  /// Serializes this LeadCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeadCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadCategoryCopyWith<LeadCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadCategoryCopyWith<$Res> {
  factory $LeadCategoryCopyWith(
    LeadCategory value,
    $Res Function(LeadCategory) then,
  ) = _$LeadCategoryCopyWithImpl<$Res, LeadCategory>;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'category_name') String categoryName,
    String? color,
  });
}

/// @nodoc
class _$LeadCategoryCopyWithImpl<$Res, $Val extends LeadCategory>
    implements $LeadCategoryCopyWith<$Res> {
  _$LeadCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeadCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? categoryName = null,
    Object? color = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeadCategoryImplCopyWith<$Res>
    implements $LeadCategoryCopyWith<$Res> {
  factory _$$LeadCategoryImplCopyWith(
    _$LeadCategoryImpl value,
    $Res Function(_$LeadCategoryImpl) then,
  ) = __$$LeadCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'category_name') String categoryName,
    String? color,
  });
}

/// @nodoc
class __$$LeadCategoryImplCopyWithImpl<$Res>
    extends _$LeadCategoryCopyWithImpl<$Res, _$LeadCategoryImpl>
    implements _$$LeadCategoryImplCopyWith<$Res> {
  __$$LeadCategoryImplCopyWithImpl(
    _$LeadCategoryImpl _value,
    $Res Function(_$LeadCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeadCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? categoryName = null,
    Object? color = freezed,
  }) {
    return _then(
      _$LeadCategoryImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeadCategoryImpl implements _LeadCategory {
  const _$LeadCategoryImpl({
    required this.name,
    @JsonKey(name: 'category_name') this.categoryName = '',
    this.color,
  });

  factory _$LeadCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadCategoryImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'category_name')
  final String categoryName;
  @override
  final String? color;

  @override
  String toString() {
    return 'LeadCategory(name: $name, categoryName: $categoryName, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadCategoryImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, categoryName, color);

  /// Create a copy of LeadCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadCategoryImplCopyWith<_$LeadCategoryImpl> get copyWith =>
      __$$LeadCategoryImplCopyWithImpl<_$LeadCategoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadCategoryImplToJson(this);
  }
}

abstract class _LeadCategory implements LeadCategory {
  const factory _LeadCategory({
    required final String name,
    @JsonKey(name: 'category_name') final String categoryName,
    final String? color,
  }) = _$LeadCategoryImpl;

  factory _LeadCategory.fromJson(Map<String, dynamic> json) =
      _$LeadCategoryImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'category_name')
  String get categoryName;
  @override
  String? get color;

  /// Create a copy of LeadCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadCategoryImplCopyWith<_$LeadCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
