// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeadImpl _$$LeadImplFromJson(Map<String, dynamic> json) => _$LeadImpl(
  name: json['name'] as String,
  sourceBrandId: json['source_brand_id'] as String?,
  leadName: json['lead_name'] as String? ?? '',
  category: json['category'] as String?,
  score: (json['score'] as num?)?.toInt() ?? 0,
  tier: json['tier'] as String? ?? '',
  branchCount: (json['branch_count'] as num?)?.toInt() ?? 0,
  priceBand: json['price_band'] as String? ?? '',
  avgRating: (json['avg_rating'] as num?)?.toDouble(),
  totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
  openStatus: json['open_status'] as String? ?? '',
  sahelBranches: (json['sahel_branches'] as num?)?.toInt() ?? 0,
  isSpecialty: json['is_specialty'] as bool? ?? false,
  primaryArea: json['primary_area'] as String? ?? '',
  regions:
      (json['regions'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  governorates:
      (json['governorates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  areas:
      (json['areas'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  phone: json['phone'] as String? ?? '',
  website: json['website'] as String? ?? '',
  instagram: json['instagram'] as String? ?? '',
  facebook: json['facebook'] as String? ?? '',
  mapsUrl: json['maps_url'] as String? ?? '',
  confidence: json['confidence'] as String? ?? '',
  status: json['status'] as String? ?? '',
  b2bStage: json['b2b_stage'] as String? ?? '',
  lastVerified: json['last_verified'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  branches:
      (json['branches'] as List<dynamic>?)
          ?.map((e) => LeadBranch.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <LeadBranch>[],
  primaryAddress: json['primary_address'] == null
      ? null
      : LeadAddress.fromJson(json['primary_address'] as Map<String, dynamic>),
  shippingAddress: json['shipping_address'] == null
      ? null
      : LeadAddress.fromJson(json['shipping_address'] as Map<String, dynamic>),
  notes: json['notes'] as String? ?? '',
);

Map<String, dynamic> _$$LeadImplToJson(_$LeadImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'source_brand_id': instance.sourceBrandId,
      'lead_name': instance.leadName,
      'category': instance.category,
      'score': instance.score,
      'tier': instance.tier,
      'branch_count': instance.branchCount,
      'price_band': instance.priceBand,
      'avg_rating': instance.avgRating,
      'total_reviews': instance.totalReviews,
      'open_status': instance.openStatus,
      'sahel_branches': instance.sahelBranches,
      'is_specialty': instance.isSpecialty,
      'primary_area': instance.primaryArea,
      'regions': instance.regions,
      'governorates': instance.governorates,
      'areas': instance.areas,
      'phone': instance.phone,
      'website': instance.website,
      'instagram': instance.instagram,
      'facebook': instance.facebook,
      'maps_url': instance.mapsUrl,
      'confidence': instance.confidence,
      'status': instance.status,
      'b2b_stage': instance.b2bStage,
      'last_verified': instance.lastVerified,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'branches': instance.branches,
      'primary_address': instance.primaryAddress,
      'shipping_address': instance.shippingAddress,
      'notes': instance.notes,
    };

_$LeadBranchImpl _$$LeadBranchImplFromJson(Map<String, dynamic> json) =>
    _$LeadBranchImpl(
      branchName: json['branch_name'] as String? ?? '',
      area: json['area'] as String? ?? '',
      region: json['region'] as String? ?? '',
      governorate: json['governorate'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble(),
      reviews: (json['reviews'] as num?)?.toInt() ?? 0,
      price: json['price'] as String? ?? '',
      status: json['status'] as String? ?? '',
      hours: json['hours'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      website: json['website'] as String? ?? '',
      mapsUrl: json['maps_url'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$LeadBranchImplToJson(_$LeadBranchImpl instance) =>
    <String, dynamic>{
      'branch_name': instance.branchName,
      'area': instance.area,
      'region': instance.region,
      'governorate': instance.governorate,
      'rating': instance.rating,
      'reviews': instance.reviews,
      'price': instance.price,
      'status': instance.status,
      'hours': instance.hours,
      'phone': instance.phone,
      'website': instance.website,
      'maps_url': instance.mapsUrl,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_$LeadAddressImpl _$$LeadAddressImplFromJson(Map<String, dynamic> json) =>
    _$LeadAddressImpl(
      name: json['name'] as String?,
      addressLine1: json['address_line1'] as String? ?? '',
      addressLine2: json['address_line2'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );

Map<String, dynamic> _$$LeadAddressImplToJson(_$LeadAddressImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address_line1': instance.addressLine1,
      'address_line2': instance.addressLine2,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'pincode': instance.pincode,
      'phone': instance.phone,
    };

_$LeadCategoryImpl _$$LeadCategoryImplFromJson(Map<String, dynamic> json) =>
    _$LeadCategoryImpl(
      name: json['name'] as String,
      categoryName: json['category_name'] as String? ?? '',
      color: json['color'] as String?,
    );

Map<String, dynamic> _$$LeadCategoryImplToJson(_$LeadCategoryImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category_name': instance.categoryName,
      'color': instance.color,
    };
