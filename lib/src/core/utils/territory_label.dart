/// How a delivery area is named to a human anywhere in the app.
///
/// Territories are synced from WooCommerce and are *named* by their Woo area
/// code — `EGNASRCITY`, `EGHADAYEQAH`. On production `territory_name` is equal
/// to that code on most records, so neither the Link value nor the title is a
/// label a person can read. The only human name that exists is the Arabic one
/// in `custom_territory_name_ar`, which the backend sends as `territory_name_ar`
/// and which is what the WooCommerce checkout showed the customer in the first
/// place.
///
/// So every user-facing surface renders [territoryLabel]. The raw name is still
/// what gets sent back to the backend; only the label changes.
///
/// The fallbacks matter as much as the preference: the backend sends `""` — not
/// null — for a territory with no Arabic name yet, so a plain `?? ` chain
/// resolves to an empty string and prints nothing at all. Every step here
/// treats blank as absent.
library;

/// The best human name for a territory row returned by `get_territories`.
///
/// Prefers the Arabic name, then the (possibly translated) title, then the raw
/// record name — which is the Woo code, and the last thing worth showing, but
/// still better than a blank.
String territoryLabelOf(Map<dynamic, dynamic>? territory) {
  if (territory == null) return '';
  return territoryLabel(
    nameAr: territory['territory_name_ar'],
    display: territory['territory_name'],
    raw: territory['name'] ?? territory['id'] ?? territory['territory'],
  );
}

/// The best human name for an area, given the three forms it arrives in.
///
/// Models spell these `territoryNameAr` / `territoryDisplay` / `territory`;
/// raw JSON maps spell them `territory_name_ar` / `territory_name` / `name`.
/// Any scalar is accepted because realtime and FCM payloads flatten everything
/// to strings.
String territoryLabel({Object? nameAr, Object? display, Object? raw}) {
  for (final candidate in [nameAr, display, raw]) {
    final text = candidate?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return '';
}

/// Whether a territory can be chosen as the delivery area for an order.
///
/// Only territories carrying a WooCommerce code are real delivery areas. The
/// rest of the tree is structure (`Egypt`, `All Territories`), sub-zones that
/// are picked through the sub-territory sheet instead, and test fixtures —
/// choosing one of those attaches an order to an area with no Woo mapping and
/// no delivery rate.
///
/// `get_territories` already filters these out server-side; this is the client
/// half of the same rule, so a stale or unfiltered payload cannot put an
/// unshippable area back in a dropdown. A row that carries no `woo_code` key at
/// all is kept: that is a backend too old to send one, not a coded territory.
bool isSelectableTerritory(Map<dynamic, dynamic>? territory) {
  if (territory == null) return false;
  if (!territory.containsKey('woo_code')) return true;
  return territory['woo_code']?.toString().trim().isNotEmpty ?? false;
}

/// The selectable subset of a territory list, in the order the backend sent it.
List<Map<String, dynamic>> selectableTerritories(
  List<Map<String, dynamic>> territories,
) => territories.where(isSelectableTerritory).toList();
