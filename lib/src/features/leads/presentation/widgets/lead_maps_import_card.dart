import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../geo/domain/maps_link_input.dart';
import '../../../geo/presentation/widgets/location_preview_map.dart';
import '../../data/models/lead_maps_preview.dart';
import '../leads_theme.dart';
import 'lead_actions.dart';

@immutable
class LeadMapsValue {
  const LeadMapsValue({this.mapsUrl = '', this.latitude, this.longitude});

  static const empty = LeadMapsValue();

  final String mapsUrl;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates {
    final lat = latitude;
    final lng = longitude;
    return lat != null &&
        lng != null &&
        lat.abs() <= 90 &&
        lng.abs() <= 180 &&
        !(lat == 0 && lng == 0);
  }

  @override
  bool operator ==(Object other) =>
      other is LeadMapsValue &&
      other.mapsUrl == mapsUrl &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(mapsUrl, latitude, longitude);
}

typedef LeadMapsPreviewResolver =
    Future<LeadMapsPreview> Function(
      String link, {
      bool Function()? keepPolling,
    });
typedef LeadMapsPreviewBuilder =
    Widget Function(BuildContext context, LatLng point);

/// Lead-specific Maps importer.
///
/// It intentionally does not reuse the customer-address location field: lead
/// lookup uses B2B permissions and may return Google place metadata in addition
/// to a point. Every text edit immediately drops the old coordinates, so a slow
/// response or a replacement link can never retain a pin from the prior place.
class LeadMapsImportCard extends ConsumerStatefulWidget {
  const LeadMapsImportCard({
    super.key,
    required this.resolver,
    this.initialValue = LeadMapsValue.empty,
    this.onChanged,
    this.onImported,
    this.previewBuilder,
  });

  final LeadMapsPreviewResolver resolver;
  final LeadMapsValue initialValue;
  final ValueChanged<LeadMapsValue>? onChanged;
  final ValueChanged<LeadMapsPreview>? onImported;
  final LeadMapsPreviewBuilder? previewBuilder;

  static const inputKey = ValueKey('lead_maps_link_input');
  static const pasteKey = ValueKey('lead_maps_paste');
  static const getDetailsKey = ValueKey('lead_maps_get_details');
  static const clearKey = ValueKey('lead_maps_clear');
  static const previewKey = ValueKey('lead_maps_preview');

  @override
  ConsumerState<LeadMapsImportCard> createState() => _LeadMapsImportCardState();
}

class _LeadMapsImportCardState extends ConsumerState<LeadMapsImportCard> {
  static const _debounceDelay = Duration(milliseconds: 600);

  late final TextEditingController _controller;
  Timer? _debounce;
  int _requestId = 0;
  bool _checking = false;
  bool _unrecognized = false;
  bool _networkError = false;
  LeadMapsPreview? _preview;
  LatLng? _point;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.mapsUrl);
    final initial = widget.initialValue;
    if (initial.hasCoordinates) {
      _point = LatLng(initial.latitude!, initial.longitude!);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String get _link => MapsLinkInput.normalize(_controller.text);

  void _emit() {
    widget.onChanged?.call(
      LeadMapsValue(
        mapsUrl: _link,
        latitude: _point?.latitude,
        longitude: _point?.longitude,
      ),
    );
  }

  void _onTextChanged(String raw) {
    _debounce?.cancel();
    // Invalidate a currently running lookup before its replacement starts.
    // Otherwise it could land during this 600 ms debounce window and attach
    // the previous place's coordinates to the newly typed URL.
    _requestId++;
    final link = MapsLinkInput.normalize(raw);
    final recognizable = link.isEmpty || MapsLinkInput.looksResolvable(link);

    setState(() {
      _checking = false;
      _unrecognized = !recognizable;
      _networkError = false;
      _preview = null;
      _point = null;
    });
    _emit();

    if (link.isNotEmpty && recognizable) {
      _debounce = Timer(_debounceDelay, _resolve);
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    if (!mounted || text.trim().isEmpty) return;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _onTextChanged(text);
  }

  void _clear() {
    _debounce?.cancel();
    _requestId++;
    _controller.clear();
    setState(() {
      _checking = false;
      _unrecognized = false;
      _networkError = false;
      _preview = null;
      _point = null;
    });
    _emit();
  }

  Future<void> _resolve() async {
    _debounce?.cancel();
    final link = _link;
    if (link.isEmpty || !MapsLinkInput.looksResolvable(link)) return;

    final requestId = ++_requestId;
    setState(() {
      _checking = true;
      _networkError = false;
      _unrecognized = false;
    });

    LeadMapsPreview preview;
    try {
      preview = await widget.resolver(
        link,
        keepPolling: () => mounted && requestId == _requestId && link == _link,
      );
    } catch (_) {
      if (!mounted || requestId != _requestId || link != _link) return;
      setState(() {
        _checking = false;
        _networkError = true;
        _preview = null;
        _point = null;
      });
      _emit();
      return;
    }

    if (!mounted || requestId != _requestId || link != _link) return;
    setState(() {
      _checking = false;
      _networkError = false;
      _preview = preview;
      _point = preview.hasCoordinates
          ? LatLng(preview.latitude!, preview.longitude!)
          : null;
    });
    _emit();
    if (preview.success && preview.hasPlaceDetails) {
      widget.onImported?.call(preview);
    }
  }

  String? get _helperText {
    final l10n = context.l10n;
    if (_unrecognized) return l10n.leadMapsUnrecognized;
    if (_networkError) return l10n.leadMapsLookupFailed;
    if (_checking) return l10n.leadMapsChecking;
    final preview = _preview;
    if (preview?.pending == true) return l10n.leadMapsStillWorking;
    if (preview != null && !preview.success) return l10n.leadMapsLookupFailed;
    if (preview != null && preview.hasPlaceDetails) {
      return l10n.leadMapsDetailsImported;
    }
    if (preview != null && preview.hasCoordinates) {
      return l10n.leadMapsLocationImported;
    }
    if (_link.isNotEmpty && _point == null) return l10n.leadMapsLinkKept;
    if (_point != null) return l10n.leadMapsLocationImported;
    return null;
  }

  Color _helperColor(ThemeData theme) {
    if (_unrecognized || _networkError || (_preview?.success == false)) {
      return theme.colorScheme.error;
    }
    if (_point != null || _preview?.hasPlaceDetails == true) {
      return Colors.green[700]!;
    }
    return theme.colorScheme.outline;
  }

  Widget _detailRow(IconData icon, String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: LeadsTheme.muted),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: LeadsTheme.bodyMuted)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final helper = _helperText;
    final preview = _preview;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.leadMapsCardDescription, style: LeadsTheme.bodyMuted),
        const SizedBox(height: 12),
        TextField(
          key: LeadMapsImportCard.inputKey,
          controller: _controller,
          keyboardType: TextInputType.url,
          textDirection: TextDirection.ltr,
          onChanged: _onTextChanged,
          onSubmitted: (_) => _resolve(),
          decoration: InputDecoration(
            labelText: l10n.leadMapsFieldLabel,
            hintText: l10n.locationLinkPasteHint,
            hintTextDirection: TextDirection.ltr,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: _controller.text.trim().isEmpty
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_checking)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      IconButton(
                        key: LeadMapsImportCard.clearKey,
                        tooltip: l10n.locationLinkClear,
                        onPressed: _clear,
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            TextButton.icon(
              key: LeadMapsImportCard.pasteKey,
              onPressed: _paste,
              icon: const Icon(Icons.content_paste, size: 18),
              label: Text(l10n.leadMapsPaste),
            ),
            if (_link.isNotEmpty &&
                !_checking &&
                (_preview == null ||
                    _preview?.success == false ||
                    _preview?.pending == true))
              TextButton.icon(
                key: LeadMapsImportCard.getDetailsKey,
                onPressed: MapsLinkInput.looksResolvable(_link)
                    ? _resolve
                    : null,
                icon: Icon(
                  _networkError ||
                          _preview?.success == false ||
                          _preview?.pending == true
                      ? Icons.refresh
                      : Icons.auto_awesome_outlined,
                  size: 18,
                ),
                label: Text(
                  _networkError ||
                          _preview?.success == false ||
                          _preview?.pending == true
                      ? l10n.commonRetry
                      : l10n.leadMapsGetDetails,
                ),
              ),
            if (LeadActions.isSafeMapsUrl(_link))
              TextButton.icon(
                onPressed: () => LeadActions.maps(_link),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(l10n.leadMapsOpen),
              ),
          ],
        ),
        if (helper != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _point != null ? Icons.check_circle : Icons.info_outline,
                size: 16,
                color: _helperColor(theme),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  helper,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _helperColor(theme),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        if (preview?.hasPlaceDetails == true) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: LeadsTheme.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: LeadsTheme.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.leadMapsFoundDetails,
                  style: LeadsTheme.body.copyWith(fontWeight: FontWeight.w600),
                ),
                _detailRow(Icons.storefront, preview?.placeName),
                _detailRow(
                  Icons.place_outlined,
                  preview?.formattedAddress ?? preview?.addressLine1,
                ),
                _detailRow(Icons.phone_outlined, preview?.phone),
                _detailRow(Icons.language, preview?.website),
              ],
            ),
          ),
        ],
        if (_point != null) ...[
          const SizedBox(height: 10),
          KeyedSubtree(
            key: LeadMapsImportCard.previewKey,
            child:
                widget.previewBuilder?.call(context, _point!) ??
                LocationPreviewMap(
                  point: _point!,
                  tileProvider: ref.watch(locationTileProviderProvider),
                ),
          ),
        ],
      ],
    );
  }
}
