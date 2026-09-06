/// Mirror of the backend confidence ladder (`jarz_pos.utils.geo.CONFIDENCE_RANK`
/// / `SOURCE_*`) that the pin-correction screen needs client-side.
///
/// Kept as plain string constants — like `MapsLinkInput` — rather than an enum,
/// because the wire value IS the string the server compares; an enum would just
/// add a mapping step that could drift from the backend's own spelling.
library;

abstract final class GeoPinSource {
  static const String territoryCentroid = 'territory_centroid';
  static const String posLink = 'pos_link';
  static const String customerPin = 'customer_pin';
  static const String courierWeb = 'courier_web';
  static const String courierVerified = 'courier_verified';

  /// What this screen always sends on a commit. Highest rank on the ladder
  /// deliberately — an authorised human correcting a bad pin must be able to
  /// make it stick against courier consensus. Gated server-side on the same
  /// line-manager tier `canActAsLineManagerProvider` mirrors on the client.
  static const String manualOverride = 'manual_override';

  /// Same ranks as `CONFIDENCE_RANK` in `jarz_pos/utils/geo.py`. Duplicated
  /// (not fetched) because the screen needs it to render "your correction will
  /// outrank the current pin" before the round trip that would confirm it —
  /// the ladder itself is returned by `get_address_pin` too and should be
  /// preferred over this map when both are available.
  static const Map<String, int> defaultRanks = {
    territoryCentroid: 10,
    posLink: 20,
    customerPin: 30,
    courierWeb: 35,
    courierVerified: 40,
    manualOverride: 50,
  };
}
