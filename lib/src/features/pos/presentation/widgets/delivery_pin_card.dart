import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../geo/data/models/address_pin.dart';
import '../../../geo/data/repositories/address_pin_repository.dart';
import '../../../geo/presentation/widgets/add_pin_sheet.dart';

/// The cart bumps this when the server refuses a delivery order with
/// `AddressPinRequired`; [DeliveryPinCard] listens, scrolls itself into view and
/// puts the cursor in the link field.
final deliveryPinFocusRequestProvider = StateProvider<int>((ref) => 0);

/// What the address currently carries, or null when it could not be read.
///
/// A failed read must not block the cart: the server stays the authority on
/// whether the order may be placed, so "unknown" simply shows no card.
final deliveryAddressPinProvider = FutureProvider.autoDispose
    .family<AddressPin?, String>((ref, address) async {
      try {
        return await ref.read(addressPinRepositoryProvider).getAddressPin(address);
      } catch (_) {
        return null;
      }
    });

/// Delivery-pin prompt in the cart.
///
/// A pinned address shows one quiet confirmation line. An address without a
/// pin-grade pin shows the paste-a-link / pick-on-map form right in the cart,
/// because with `require_address_pin_for_delivery` on the order cannot be placed
/// without it and staff should not have to hunt for the fix after a refusal.
class DeliveryPinCard extends ConsumerStatefulWidget {
  const DeliveryPinCard({super.key, required this.addressName});

  final String addressName;

  static const cardKey = ValueKey('delivery_pin_card');
  static const pinnedKey = ValueKey('delivery_pin_pinned');

  @override
  ConsumerState<DeliveryPinCard> createState() => _DeliveryPinCardState();
}

class _DeliveryPinCardState extends ConsumerState<DeliveryPinCard> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _cardKey = GlobalKey();

  /// True once the server refused an order for this address: the card turns
  /// red and says the pin is required, not merely missing.
  bool _refused = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DeliveryPinCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.addressName != widget.addressName) _refused = false;
  }

  void _onFocusRequested() {
    setState(() => _refused = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cardContext = _cardKey.currentContext;
      if (cardContext != null) {
        Scrollable.ensureVisible(
          cardContext,
          duration: const Duration(milliseconds: 250),
          alignment: 0.1,
        );
      }
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(deliveryPinFocusRequestProvider, (previous, next) {
      if (next != previous) _onFocusRequested();
    });

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final pinAsync = ref.watch(deliveryAddressPinProvider(widget.addressName));

    return pinAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.courierLaunchPinCardChecking,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (pin) {
        if (pin == null) return const SizedBox.shrink();
        if (pin.isPinGrade) {
          return Padding(
            key: DeliveryPinCard.pinnedKey,
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.green[700]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.courierLaunchPinCardPinned,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final accent = _refused
            ? theme.colorScheme.error
            : Colors.orange.shade800;
        return Container(
          key: _cardKey,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent, width: _refused ? 2 : 1),
          ),
          child: Column(
            key: DeliveryPinCard.cardKey,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.location_off_outlined, size: 18, color: accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.courierLaunchPinCardTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _refused
                    ? l10n.courierLaunchPinCardRequired
                    : l10n.courierLaunchPinCardMissing,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              AddPinForm(
                addressName: widget.addressName,
                focusNode: _focusNode,
                onSaved: () {
                  setState(() => _refused = false);
                  ref.invalidate(deliveryAddressPinProvider(widget.addressName));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
