import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/network/user_service.dart';
import '../../data/models/address_pin.dart';
import '../../data/models/pin_write_decision.dart';
import '../../data/repositories/address_pin_repository.dart';
import '../../domain/geo_pin_sources.dart';
import '../widgets/location_link_field.dart';
import '../widgets/location_point_picker.dart';
import '../widgets/location_preview_map.dart';

/// Correct the delivery pin on an EXISTING address.
///
/// `preview_maps_link` only ever runs at the moment an address is created
/// (see [LocationLinkField]); once an address exists with a bad pin nobody in
/// the field can fix it without a developer script. This screen is the fix:
/// load the current pin, propose a new one (paste a link or pick on the map),
/// dry-run the confidence-ladder decision, then commit.
///
/// Pushed with the Address `name` as the route `extra` — never a drawer entry.
class AddressPinScreen extends ConsumerStatefulWidget {
  const AddressPinScreen({super.key, required this.address});

  final String address;

  @override
  ConsumerState<AddressPinScreen> createState() => _AddressPinScreenState();
}

class _AddressPinScreenState extends ConsumerState<AddressPinScreen> {
  bool _loading = true;
  Object? _loadError;
  AddressPin? _pin;

  /// The proposed point, once a link resolves or a map pick lands. Cleared on
  /// every new input so a stale preview can never be committed against it.
  LatLng? _candidate;

  bool _dryRunning = false;
  PinWriteDecision? _decision;

  bool _saving = false;

  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final pin = await ref
          .read(addressPinRepositoryProvider)
          .getAddressPin(widget.address);
      if (!mounted) return;
      setState(() {
        _pin = pin;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e;
        _loading = false;
      });
    }
  }

  void _onCandidateChanged(LatLng? point) {
    setState(() {
      _candidate = point;
      _decision = null;
    });
  }

  Future<void> _pickOnMap() async {
    final point = await showLocationPointPicker(
      context,
      initial:
          _candidate ??
          (_pin?.hasPin == true
              ? LatLng(_pin!.latitude!, _pin!.longitude!)
              : null),
    );
    if (point == null) return;
    _onCandidateChanged(point);
  }

  Future<void> _runDryRun() async {
    final candidate = _candidate;
    if (candidate == null) return;
    setState(() => _dryRunning = true);
    try {
      final decision = await ref
          .read(addressPinRepositoryProvider)
          .dryRun(
            address: widget.address,
            latitude: candidate.latitude,
            longitude: candidate.longitude,
            source: GeoPinSource.manualOverride,
          );
      if (!mounted) return;
      setState(() => _decision = decision);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.userErrorMessage(
              e,
              fallback: context.l10n.addressPinDryRunFailed,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _dryRunning = false);
    }
  }

  Future<void> _commit() async {
    final candidate = _candidate;
    if (candidate == null) return;
    setState(() => _saving = true);
    try {
      final decision = await ref
          .read(addressPinRepositoryProvider)
          .setPin(
            address: widget.address,
            latitude: candidate.latitude,
            longitude: candidate.longitude,
            source: GeoPinSource.manualOverride,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      if (!mounted) return;
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            decision.accepted == true
                ? l10n.addressPinSaveSuccessAccepted
                : l10n.addressPinSaveSuccessRejected,
          ),
        ),
      );
      setState(() {
        _decision = decision;
        _candidate = null;
        _noteController.clear();
      });
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.userErrorMessage(e)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addressPinTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? _ErrorState(error: _loadError!, onRetry: _load)
          : _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = context.l10n;
    final pin = _pin;
    final canCommit = ref.watch(canActAsLineManagerProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.addressPinCurrentPin,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (pin != null) _CurrentPinCard(pin: pin),
        const SizedBox(height: 24),
        Text(
          l10n.addressPinProposeNew,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        LocationLinkField(
          labelText: l10n.locationLinkFieldLabel,
          onChanged: (value) => _onCandidateChanged(
            value.isConfirmed
                ? LatLng(value.latitude!, value.longitude!)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickOnMap,
          icon: const Icon(Icons.map_outlined),
          label: Text(l10n.addressPinPickOnMap),
        ),
        if (_candidate != null) ...[
          const SizedBox(height: 12),
          LocationPreviewMap(point: _candidate!),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: _dryRunning ? null : _runDryRun,
            icon: _dryRunning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.fact_check_outlined),
            label: Text(l10n.addressPinPreviewChanges),
          ),
        ],
        if (_decision != null) ...[
          const SizedBox(height: 12),
          _DecisionCard(decision: _decision!),
        ],
        if (_decision?.accepted == true) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.addressPinNoteLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          if (!canCommit)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.addressPinPermissionNote,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          FilledButton.icon(
            onPressed: (!canCommit || _saving) ? null : _commit,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(l10n.addressPinCommit),
          ),
        ],
      ],
    );
  }
}

class _CurrentPinCard extends StatelessWidget {
  const _CurrentPinCard({required this.pin});

  final AddressPin pin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pin.hasPin)
              LocationPreviewMap(
                point: LatLng(pin.latitude!, pin.longitude!),
              )
            else
              Text(
                l10n.addressPinNoPinYet,
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.source_outlined,
              text: l10n.addressPinSourceLabel(
                sourceLabel(context, pin.source),
              ),
            ),
            _InfoRow(
              icon: Icons.trending_up,
              text: l10n.addressPinConfidenceLabel(pin.confidence),
            ),
            _InfoRow(
              icon: Icons.gps_fixed,
              text: pin.hasAccuracy
                  ? l10n.addressPinAccuracyLabel(
                      pin.accuracyM!.round().toString(),
                    )
                  : l10n.addressPinAccuracyUnknown,
            ),
            if ((pin.verifiedOn ?? '').isNotEmpty)
              _InfoRow(
                icon: Icons.verified_outlined,
                text: l10n.addressPinVerifiedOn(
                  formatDateString(context, pin.verifiedOn),
                ),
              ),
            if ((pin.storedLink ?? '').isNotEmpty)
              _InfoRow(
                icon: Icons.link,
                text: '${l10n.addressPinStoredLinkLabel}: ${pin.storedLink}',
              ),
          ],
        ),
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({required this.decision});

  final PinWriteDecision decision;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final accepted = decision.accepted == true;
    final color = accepted ? Colors.green[700]! : theme.colorScheme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                accepted ? Icons.check_circle : Icons.info_outline,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  accepted
                      ? l10n.addressPinWillUpdate
                      : l10n.addressPinWillKeepExisting,
                  style: theme.textTheme.bodyMedium?.copyWith(color: color),
                ),
              ),
            ],
          ),
          if (accepted && decision.movedM != null) ...[
            const SizedBox(height: 6),
            Text(
              l10n.addressPinMovedBy(decision.movedM!.round().toString()),
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (accepted && decision.resultingSource != null) ...[
            const SizedBox(height: 6),
            Text(
              '${sourceLabel(context, decision.currentSource)} '
              '(${decision.currentRank ?? 0}) → '
              '${sourceLabel(context, decision.resultingSource)} '
              '(${decision.resultingRank ?? 0})',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              context.userErrorMessage(error),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

/// Human label for a `custom_geo_source` ladder key. Falls back to the raw
/// value for a label this build has never heard of — the ladder may grow
/// entries a shipped client predates.
String sourceLabel(BuildContext context, String? source) {
  final l10n = context.l10n;
  switch (source) {
    case GeoPinSource.territoryCentroid:
      return l10n.addressPinSourceTerritoryCentroid;
    case GeoPinSource.posLink:
      return l10n.addressPinSourcePosLink;
    case GeoPinSource.customerPin:
      return l10n.addressPinSourceCustomerPin;
    case GeoPinSource.courierWeb:
      return l10n.addressPinSourceCourierWeb;
    case GeoPinSource.courierVerified:
      return l10n.addressPinSourceCourierVerified;
    case GeoPinSource.manualOverride:
      return l10n.addressPinSourceManualOverride;
    default:
      return (source == null || source.isEmpty)
          ? l10n.addressPinSourceUnknown
          : source;
  }
}
