// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sales_material.freezed.dart';
part 'sales_material.g.dart';

/// One item in the shareable sales-material library: a price list, a sheet of
/// product photos, a certificate.
///
/// Mirrors `jarz_pos.api.materials.get_sales_materials`. Deliberately does NOT
/// carry the render manifest — the app never renders the pages, it only sends a
/// link to the page that does.
@freezed
class SalesMaterial with _$SalesMaterial {
  const SalesMaterial._();

  const factory SalesMaterial({
    required String name,
    @Default('') String title,
    @JsonKey(name: 'title_ar') @Default('') String titleAr,
    @JsonKey(name: 'display_title') @Default('') String displayTitle,
    @JsonKey(name: 'material_type') @Default('') String materialType,
    @JsonKey(name: 'download_url') @Default('') String downloadUrl,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(name: 'page_count') @Default(0) int pageCount,

    /// False while the backend is still rasterising this file. The rep can
    /// still send it — the customer's page self-heals — but the sheet says so,
    /// because a link opened ten seconds after a 40MB upload is the one case
    /// where the reader waits.
    @Default(false) bool ready,
  }) = _SalesMaterial;

  factory SalesMaterial.fromJson(Map<String, dynamic> json) =>
      _$SalesMaterialFromJson(json);

  /// What to show in the picker: the Arabic title when the library has one.
  String get label {
    final display = displayTitle.trim();
    if (display.isNotEmpty) return display;
    final arabic = titleAr.trim();
    if (arabic.isNotEmpty) return arabic;
    return title.trim().isNotEmpty ? title.trim() : name;
  }
}

/// The send sheet's whole payload in one response: what can be sent, and the
/// message template to send it with.
///
/// One call rather than two because a rep opens this standing in a cafe on a
/// weak signal, and the placeholders travel with it so the substitution
/// contract has exactly one definition (the server's).
@freezed
class MaterialLibrary with _$MaterialLibrary {
  const MaterialLibrary._();

  const factory MaterialLibrary({
    @Default(<SalesMaterial>[]) List<SalesMaterial> materials,
    @JsonKey(name: 'message_template') @Default('') String messageTemplate,
    @JsonKey(name: 'name_placeholder') @Default('{name}') String namePlaceholder,
    @JsonKey(name: 'link_placeholder') @Default('{link}') String linkPlaceholder,
    @JsonKey(name: 'name_fallback') @Default('') String nameFallback,
  }) = _MaterialLibrary;

  factory MaterialLibrary.fromJson(Map<String, dynamic> json) =>
      _$MaterialLibraryFromJson(json);

  /// The template with the contact's name filled in, ready to show in the
  /// editor. `{link}` is left alone on purpose: the URL does not exist until
  /// the share row is inserted, so the server substitutes it at send time and
  /// no amount of editing here can produce a message without a link.
  String previewFor(String? contactName) {
    final person = (contactName ?? '').trim();
    return messageTemplate.replaceAll(
      namePlaceholder,
      person.isNotEmpty ? person : nameFallback,
    );
  }
}

/// A minted share: the link, and the WhatsApp deep link that carries it.
@freezed
class MaterialShare with _$MaterialShare {
  const factory MaterialShare({
    @Default('') String name,
    @Default('') String token,
    @Default('') String url,
    @JsonKey(name: 'whatsapp_url') @Default('') String whatsappUrl,
    @Default('') String message,
    @Default('') String msisdn,

    /// Materials still being rasterised when the link was minted.
    @JsonKey(name: 'pending_render') @Default(<String>[]) List<String> pendingRender,
  }) = _MaterialShare;

  factory MaterialShare.fromJson(Map<String, dynamic> json) =>
      _$MaterialShareFromJson(json);
}

/// One previously sent link, with what the prospect did with it.
///
/// `viewCount` is the whole reason this feature sends a link instead of
/// attachments: with files in a chat, "did they even look?" is unanswerable.
@freezed
class MaterialShareSummary with _$MaterialShareSummary {
  const MaterialShareSummary._();

  const factory MaterialShareSummary({
    @Default('') String name,
    @Default('') String url,
    @JsonKey(name: 'contact_name') @Default('') String contactName,
    @JsonKey(name: 'contact_phone') @Default('') String contactPhone,
    @Default('') String channel,
    @JsonKey(name: 'sent_by') @Default('') String sentBy,
    @JsonKey(name: 'sent_on') String? sentOn,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
    @JsonKey(name: 'first_viewed_on') String? firstViewedOn,
    @JsonKey(name: 'last_viewed_on') String? lastViewedOn,
    @Default('') String message,
    @Default(<String>[]) List<String> titles,
  }) = _MaterialShareSummary;

  factory MaterialShareSummary.fromJson(Map<String, dynamic> json) =>
      _$MaterialShareSummaryFromJson(json);

  bool get opened => viewCount > 0;

  DateTime? get sentAt => _parse(sentOn);
  DateTime? get lastViewedAt => _parse(lastViewedOn);

  static DateTime? _parse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }
}
