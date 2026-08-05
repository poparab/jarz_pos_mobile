import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/maps_link_preview.dart';
import '../../data/repositories/geo_repository.dart';
import '../../domain/maps_link_input.dart';
import 'location_preview_map.dart';

/// What the field currently holds: the raw text staff pasted plus the point the
/// backend resolved it to, if any.
///
/// The host form owns this — the field hands a new value out on every change
/// and never writes anywhere itself.
@immutable
class LocationLinkValue {
  const LocationLinkValue({
    this.link = '',
    this.latitude,
    this.longitude,
    this.precision,
    this.distanceFromBranchM,
  });

  static const empty = LocationLinkValue();

  /// The pasted text, normalised (share-sheet prose stripped).
  final String link;
  final double? latitude;
  final double? longitude;

  /// `custom_geo_source` label the backend attached to the resolve.
  final String? precision;
  final double? distanceFromBranchM;

  /// True only when a point came back and survived the plausibility check.
  bool get isConfirmed => latitude != null && longitude != null;

  bool get isEmpty => link.isEmpty && !isConfirmed;

  /// Flattened for the `Map<String, String>` result maps the address dialogs
  /// pass around. Coordinates are only emitted alongside a confirmed resolve,
  /// so a half-checked paste can never stamp a pin.
  Map<String, String> toRequestFields() => {
        if (link.isNotEmpty) 'location_link': link,
        if (isConfirmed) ...{
          'latitude': latitude!.toString(),
          'longitude': longitude!.toString(),
          if (precision != null && precision!.isNotEmpty) 'geo_source': precision!,
        },
      };

  @override
  bool operator ==(Object other) =>
      other is LocationLinkValue &&
      other.link == link &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.precision == precision &&
      other.distanceFromBranchM == distanceFromBranchM;

  @override
  int get hashCode =>
      Object.hash(link, latitude, longitude, precision, distanceFromBranchM);
}

/// Builder seam for the resolved-point preview.
///
/// Defaults to [LocationPreviewMap]. Hosts (and widget tests, which must never
/// reach a tile server) can swap in their own.
typedef LocationPreviewBuilder = Widget Function(
  BuildContext context,
  LatLng point,
);

enum _FieldState { empty, pending, checking, confirmed, error }

enum _FieldError { unrecognized, unresolved, tooFar, network }

/// Paste-a-Maps-link field with inline validation and a map preview.
///
/// Accepts a long Google Maps URL, a short `maps.app.goo.gl` redirect, or a
/// bare `lat, lng` pair. Anything that is plainly not a location is rejected
/// locally and instantly; everything else goes to the backend resolver, which
/// is the only side that can follow a short link or measure the distance from
/// the branch.
///
/// A resolve that lands implausibly far from the branch is an error, not a
/// success — an address stamped with the wrong country's coordinates sends a
/// courier nowhere and is much harder to notice later than a red line here.
class LocationLinkField extends ConsumerStatefulWidget {
  const LocationLinkField({
    super.key,
    this.initialValue = LocationLinkValue.empty,
    this.onChanged,
    this.enabled = true,
    this.labelText,
    this.showPreview = true,
    this.previewBuilder,
    this.maxDistanceFromBranchM = MapsLinkInput.defaultMaxDistanceFromBranchM,
  });

  /// Existing link/pin when editing an address that already has one.
  final LocationLinkValue initialValue;
  final ValueChanged<LocationLinkValue>? onChanged;
  final bool enabled;
  final String? labelText;
  final bool showPreview;
  final LocationPreviewBuilder? previewBuilder;

  /// Distance from the branch beyond which a resolved point is rejected.
  final double maxDistanceFromBranchM;

  static const textFieldKey = ValueKey('location_link_input');
  static const clearButtonKey = ValueKey('location_link_clear');
  static const retryButtonKey = ValueKey('location_link_retry');
  static const previewKey = ValueKey('location_link_preview');

  @override
  ConsumerState<LocationLinkField> createState() => _LocationLinkFieldState();
}

class _LocationLinkFieldState extends ConsumerState<LocationLinkField> {
  /// Long enough that a paste followed by a stray keystroke is one request,
  /// short enough that staff see the result before they reach for Save.
  static const _debounceDelay = Duration(milliseconds: 600);

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounce;

  /// Monotonic request id — a slow reply for text that has since been edited
  /// must not overwrite a newer result.
  int _requestId = 0;

  _FieldState _state = _FieldState.empty;
  _FieldError? _error;

  /// Text of the most recent resolve attempt, so a blur right after a debounced
  /// check does not fire the same request again.
  String _lastAttempted = '';

  LatLng? _point;
  String? _precision;
  double? _distanceFromBranchM;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.link);
    _focusNode = FocusNode()..addListener(_onFocusChanged);

    final initial = widget.initialValue;
    if (initial.isConfirmed) {
      _point = LatLng(initial.latitude!, initial.longitude!);
      _precision = initial.precision;
      _distanceFromBranchM = initial.distanceFromBranchM;
      _lastAttempted = initial.link;
      _state = _FieldState.confirmed;
    } else if (initial.link.isNotEmpty) {
      _state = _FieldState.pending;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ── value plumbing ──────────────────────────────────────────────────────

  LocationLinkValue get _value => LocationLinkValue(
        link: MapsLinkInput.normalize(_controller.text),
        latitude: _state == _FieldState.confirmed ? _point?.latitude : null,
        longitude: _state == _FieldState.confirmed ? _point?.longitude : null,
        precision: _state == _FieldState.confirmed ? _precision : null,
        distanceFromBranchM:
            _state == _FieldState.confirmed ? _distanceFromBranchM : null,
      );

  void _emit() => widget.onChanged?.call(_value);

  // ── input handling ──────────────────────────────────────────────────────

  void _onTextChanged(String raw) {
    _debounce?.cancel();

    if (raw.trim().isEmpty) {
      setState(() {
        _state = _FieldState.empty;
        _error = null;
        _point = null;
        _precision = null;
        _distanceFromBranchM = null;
        _lastAttempted = '';
      });
      _emit();
      return;
    }

    // Any edit invalidates a previous resolve: the coordinates on screen no
    // longer belong to the text in the box.
    setState(() {
      _state = _FieldState.pending;
      _error = null;
      _point = null;
      _precision = null;
      _distanceFromBranchM = null;
    });
    _emit();

    _debounce = Timer(_debounceDelay, () {
      if (mounted) _resolve();
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) return;
    _debounce?.cancel();
    if (_state == _FieldState.pending) _resolve();
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {
      _state = _FieldState.empty;
      _error = null;
      _point = null;
      _precision = null;
      _distanceFromBranchM = null;
      _lastAttempted = '';
    });
    _emit();
  }

  Future<void> _resolve({bool force = false}) async {
    final input = MapsLinkInput.normalize(_controller.text);
    if (input.isEmpty) return;
    if (!force && input == _lastAttempted && _state != _FieldState.pending) {
      return;
    }
    _lastAttempted = input;

    if (!MapsLinkInput.looksResolvable(input)) {
      setState(() {
        _state = _FieldState.error;
        _error = _FieldError.unrecognized;
      });
      _emit();
      return;
    }

    final requestId = ++_requestId;
    setState(() {
      _state = _FieldState.checking;
      _error = null;
    });

    MapsLinkPreview preview;
    try {
      preview = await ref.read(geoRepositoryProvider).previewMapsLink(input);
    } catch (e) {
      // Degraded to an inline "try again", but never silently: a resolve that
      // is actually a 500 has to be findable in the logs.
      debugPrint('LocationLinkField: preview threw for "$input" — $e');
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _state = _FieldState.error;
        _error = _FieldError.network;
      });
      _emit();
      return;
    }

    if (!mounted || requestId != _requestId) return;

    if (!preview.isResolved) {
      // The server's own wording is English-only and often internal, so the
      // user sees a localised message — but the detail still gets logged.
      debugPrint(
        'LocationLinkField: "$input" unresolved — ${preview.error ?? 'no reason given'}',
      );
      setState(() {
        _state = _FieldState.error;
        _error = _FieldError.unresolved;
      });
      _emit();
      return;
    }

    final distance = preview.distanceFromBranchM;
    if (distance != null && distance > widget.maxDistanceFromBranchM) {
      setState(() {
        _state = _FieldState.error;
        _error = _FieldError.tooFar;
        // Kept so the message can name the distance; the value stays out of
        // [_value] because the state is not `confirmed`.
        _distanceFromBranchM = distance;
        _point = null;
      });
      _emit();
      return;
    }

    setState(() {
      _state = _FieldState.confirmed;
      _error = null;
      _point = preview.point;
      _precision = preview.precision;
      _distanceFromBranchM = distance;
    });
    _emit();
  }

  // ── presentation ────────────────────────────────────────────────────────

  /// Distance rendered in the unit staff actually think in.
  String _distanceLabel(double metres) {
    final l10n = context.l10n;
    if (metres >= 1000) {
      return l10n.locationLinkDistanceKm((metres / 1000).toStringAsFixed(1));
    }
    return l10n.locationLinkDistanceMeters(metres.round().toString());
  }

  String? get _errorText {
    final l10n = context.l10n;
    switch (_error) {
      case _FieldError.unrecognized:
        return l10n.locationLinkErrorUnrecognized;
      case _FieldError.unresolved:
        return l10n.locationLinkErrorUnresolved;
      case _FieldError.tooFar:
        final distance = _distanceFromBranchM;
        return l10n.locationLinkErrorTooFar(
          distance == null ? '' : _distanceLabel(distance),
        );
      case _FieldError.network:
        return l10n.locationLinkErrorNetwork;
      case null:
        return null;
    }
  }

  Widget? _buildSuffix() {
    final children = <Widget>[];

    if (_state == _FieldState.checking) {
      children.add(
        const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else if (_state == _FieldState.error) {
      children.add(
        IconButton(
          key: LocationLinkField.retryButtonKey,
          icon: const Icon(Icons.refresh, size: 20),
          tooltip: context.l10n.locationLinkRetry,
          onPressed: widget.enabled ? () => _resolve(force: true) : null,
        ),
      );
    } else if (_state == _FieldState.confirmed) {
      children.add(
        Icon(Icons.check_circle, size: 20, color: Colors.green[600]),
      );
    }

    if (_controller.text.trim().isNotEmpty) {
      children.add(
        IconButton(
          key: LocationLinkField.clearButtonKey,
          icon: const Icon(Icons.close, size: 18),
          tooltip: context.l10n.locationLinkClear,
          onPressed: widget.enabled ? _clear : null,
        ),
      );
    }

    if (children.isEmpty) return null;
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget? _buildStatusLine() {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    switch (_state) {
      case _FieldState.empty:
      case _FieldState.error:
        // The error already renders under the field; a second line repeats it.
        return null;
      case _FieldState.pending:
        return _StatusLine(
          icon: Icons.location_searching,
          color: theme.colorScheme.outline,
          text: l10n.locationLinkUnconfirmed,
        );
      case _FieldState.checking:
        return _StatusLine(
          icon: Icons.location_searching,
          color: theme.colorScheme.outline,
          text: l10n.locationLinkChecking,
        );
      case _FieldState.confirmed:
        final distance = _distanceFromBranchM;
        final text = distance == null
            ? l10n.locationLinkConfirmed
            : '${l10n.locationLinkConfirmed} · ${_distanceLabel(distance)}';
        return _StatusLine(
          icon: Icons.check_circle,
          color: Colors.green[700]!,
          text: text,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusLine = _buildStatusLine();
    final point = _state == _FieldState.confirmed ? _point : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          key: LocationLinkField.textFieldKey,
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          keyboardType: TextInputType.url,
          // URLs and coordinates are LTR even when the UI is Arabic; without
          // this the punctuation in a pasted link reorders on screen.
          textDirection: TextDirection.ltr,
          onChanged: _onTextChanged,
          onSubmitted: (_) => _resolve(force: true),
          decoration: InputDecoration(
            labelText: widget.labelText ?? l10n.locationLinkFieldLabel,
            hintText: l10n.locationLinkPasteHint,
            hintTextDirection: TextDirection.ltr,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.link),
            errorText: _errorText,
            errorMaxLines: 3,
            suffixIcon: _buildSuffix(),
          ),
        ),
        if (statusLine != null) ...[
          const SizedBox(height: 6),
          statusLine,
        ],
        if (widget.showPreview && point != null) ...[
          const SizedBox(height: 8),
          KeyedSubtree(
            key: LocationLinkField.previewKey,
            child: widget.previewBuilder?.call(context, point) ??
                LocationPreviewMap(
                  point: point,
                  tileProvider: ref.watch(locationTileProviderProvider),
                ),
          ),
        ],
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
