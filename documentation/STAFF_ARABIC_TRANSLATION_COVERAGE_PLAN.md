# Staff Arabic Translation Coverage Plan

Date: 2026-05-11  
Scope: Flutter POS app under `jarz_pos_mobile/jarz_pos`  
Target role: `Jarz POS Staff` / regular staff users as defined in `documentation/ACCESS_MATRIX.md`

## Goal

Make every staff-accessible Flutter app function fully usable in Arabic, with no hardcoded English in staff-facing UI, no raw backend status values shown to staff, and no date, currency, or number formatting that ignores the active locale.

This plan covers the regular staff role first. Moderator, Line Manager, Manager, and High Management screens are listed as an extension after the core staff role is complete.

## Current Baseline

The localization foundation is already in place:

- `l10n.yaml` points generated localization to `lib/l10n`.
- `MaterialApp.router` is wired to `AppLocalizations`, Flutter localization delegates, and supported locales.
- Locale selection is persisted through the locale notifier and exposed in the app drawer.
- `app_en.arb` and `app_ar.arb` have complete message-key parity.

Measured state from the audit:

| Check | Result |
| --- | ---: |
| English ARB message keys | 883 |
| Arabic ARB message keys | 883 |
| Missing Arabic message keys | 0 |
| Extra Arabic message keys | 0 |
| English placeholder metadata entries | 111 |
| Arabic placeholder metadata entries | 57 |
| Missing Arabic metadata entries | 54 |
| Likely hardcoded UI or surfaced English strings from source scan | 143 |

Conclusion: Arabic translation files are structurally complete at the message-key level, but staff-role Arabic coverage is incomplete because several widgets bypass localization and render hardcoded English, raw ERP/API values, or non-localized formatting.

## Staff Role Functional Scope

Based on `documentation/ACCESS_MATRIX.md`, the regular staff role can access these app functions:

| Staff function | Route or feature area | Arabic coverage requirement |
| --- | --- | --- |
| Login and session handling | `auth` | Labels, errors, snackbars, session expiry, profile errors |
| POS profile selection | `profile_selection` | Profile selection text, empty states, errors |
| Shift start and end | `shift` | Opening/closing labels, validations, summary, errors |
| POS selling and checkout | `pos` | Catalog, cart, drafts, checkout, payments, customer flow, delivery/pickup |
| New order alerts | `pos/order_alert` | Alert labels, item summary, actions, alarm state |
| Kanban board | `kanban` | Columns, filters, cards, actions, dialogs, status labels |
| Payment receipts | `kanban` receipt dialogs | Upload/confirm/filter labels, receipt statuses |
| Delivery trips | `trips` | List, details, create trip, OFD, delivered state, invoice detail |
| Courier balances | `courier_balances` | Balance labels, settlement actions, empty states, errors |
| Expenses | `expenses` | Create expense, cards, statuses, timeline, pending approval states |
| Printers and receipts | `printing` | Printer setup, receipt previews, compatibility toggles, print errors |
| Profile/settings/language | `settings`, app drawer | User profile, language switch, alarm sound controls, logout |

Out of core staff scope:

- Master Orders: Moderator and above only.
- Manager Dashboard: Line Manager and above only.
- Purchase, Manufacturing, Stock Transfer, Cash Transfer, Inventory Count, Reports: Manager and High Management only.

These elevated surfaces should be handled after the regular staff role is green, or earlier if the rollout definition of staff includes supervisors.

## Definition Of Done

Arabic coverage is complete for staff only when all of the following are true:

1. Switching the app to Arabic localizes every staff-visible static label, button, tab, chip, menu item, dialog title, dialog body, tooltip, snackbar, validator, empty state, loading state, and error fallback.
2. No staff-facing widget displays raw backend values such as `Paid`, `Unpaid`, `Draft`, `Created`, `Completed`, `Employee`, `Confirmed`, `Unconfirmed`, or `N/A` without a localized display mapper.
3. Dates, times, amounts, percentages, and currency values are formatted with the active locale.
4. Receipts and print previews use localized labels where the receipt is staff/customer-facing.
5. Arabic layout works in RTL without clipped buttons, overlapping chips, broken dialogs, or unreadable receipt rows.
6. Source data remains source data: customer names, item names, POS profile names, invoice IDs, usernames, and ERP document names do not need translation.
7. Automated checks prevent regressions in ARB parity, placeholder metadata, and obvious hardcoded English in staff-facing Flutter widgets.

## Priority Model

| Priority | Meaning |
| --- | --- |
| P0 | Required for regular staff daily work. Must finish first. |
| P1 | Staff-visible but lower frequency, or shared infrastructure needed for correctness. |
| P2 | Elevated staff or manager-only extension after regular staff role is complete. |

## Gap Matrix By Staff Workflow

### P0 - Login, Profile, And Shift Flow

Relevant areas:

- `lib/src/features/auth/**`
- `lib/src/features/profile_selection/**`
- `lib/src/features/shift/**`
- `lib/src/core/network/frappe_error_message.dart`

Known gaps:

- Some login and network errors are built as English strings in state/repository layers, then displayed raw.
- Backend error text can leak directly to staff.
- Any shift validation or fallback message must be confirmed in Arabic.

Required work:

1. Convert login/session/profile/shift user-facing errors to localization keys or typed failure codes.
2. Keep raw backend exception text available for logs/support, not as the primary staff message.
3. Add localized fallback messages for network failure, timeout, permission denied, session expired, and unknown error.
4. Verify Arabic route flow: login -> profile selection -> shift start if required -> POS.

Acceptance checks:

- Staff can complete login/profile/shift in Arabic without seeing English fallback UI.
- Session expiry and network failures show Arabic-friendly text.

### P0 - POS Selling, Drafts, Checkout, And Order Alerts

Relevant areas:

- `lib/src/features/pos/presentation/**`
- `lib/src/features/pos/state/**`
- `lib/src/features/pos/data/**`
- `lib/src/features/pos/order_alert/**`

Known gaps:

- `draft_tabs_bar.dart` contains hardcoded labels and confirmation text such as `New`, `Delete Draft`, `Cancel`, and `Delete`.
- `order_alert_dialog.dart` contains many hardcoded staff-facing labels and actions such as `New Order`, `Customer`, `Walk-in`, `POS Profile`, `Not specified`, `Total`, `Delivery`, `Items`, `No line items`, `Mute Alarm`, `Unmute Alarm`, and `Accept Order`.
- Some checkout/payment repository errors are likely English if surfaced.
- Currency labels are inconsistent in some UI paths and must not be hardcoded as `$` or `PHP`.

Required work:

1. Add or reuse ARB keys for draft actions, draft limits, delete confirmations, order alert labels, empty item state, alarm actions, and accept-order states.
2. Replace hardcoded `Text`, `SnackBar`, `AlertDialog`, `tooltip`, `labelText`, and `hintText` values in staff POS widgets with `context.l10n`.
3. Localize order alert fallbacks for missing customer, missing POS profile, missing item name, scheduled order, and multiple item summary.
4. Standardize POS currency display through a shared formatter.
5. Review POS checkout failures and turn surfaced messages into localized friendly errors.

Acceptance checks:

- New draft, delete draft, draft limit, and order alert flows are fully Arabic.
- Order alert item summary remains readable in RTL.
- Payment and checkout errors do not show raw English unless the value is a document name or customer/item data.

### P0 - Kanban Board And Order Operations

Relevant areas:

- `lib/src/features/kanban/widgets/**`
- `lib/src/features/kanban/screens/**`
- `lib/src/features/kanban/services/**`
- `lib/src/features/kanban/models/**`

Known gaps:

- `custom_shipping_request_dialog.dart` is mostly hardcoded: title, current amount, requested amount, reason, hint, validators, cancel, submit.
- `payment_receipt_list_dialog.dart` contains hardcoded receipt details: customer, amount, payment, POS profile, uploaded by, confirmed/unconfirmed, and `N/A`.
- Kanban filters can expose raw backend statuses such as `Draft`, `Paid`, `Unpaid`, `Cancelled`, and `Return`.
- Some invoice card actions and service errors may show raw English.

Required work:

1. Add localized keys for custom shipping request labels, validators, actions, and success/error messages.
2. Add localized keys for payment receipt filters and receipt detail rows.
3. Build a localized display mapper for invoice/order/payment status values.
4. Replace raw filter option labels with mapper output while preserving the original backend values in requests.
5. Audit kanban card menus, invoice preview actions, courier assignment, settle courier, transfer, cancel, and delivery slot dialogs for hardcoded English.
6. Ensure all snackbar and dialog failures use localized user text.

Acceptance checks:

- Staff can view and operate the Kanban board in Arabic without English labels in cards, filters, dialogs, or receipt flows.
- Raw backend statuses are never rendered directly in staff-facing Kanban UI.

### P0 - Trips And Delivery

Relevant areas:

- `lib/src/features/trips/screens/trips_screen.dart`
- `lib/src/features/trips/screens/trip_detail_screen.dart`
- `lib/src/features/trips/widgets/create_trip_dialog.dart`
- `lib/src/features/trips/**`

Known gaps:

- Trips list shows hardcoded `No trips`, raw status labels, and English order counts.
- Trip detail shows hardcoded labels such as `Courier`, `Date`, `Orders`, `Total Amount`, `Shipping Expense`, `Double Shipping`, `Same territory`, `Notes`, `Invoices`, `Paid`, `Ship`, `Payment`, `Outstanding`, `Items`, `Item`, `Qty`, `Rate`, and `Amount`.
- Trip statuses such as `Created`, `Out for Delivery`, and `Completed` are raw backend values.
- Currency display can use `$` instead of the app currency convention.
- Create trip dialog can expose raw party type labels such as `Employee`.

Required work:

1. Add trip list, trip detail, invoice table, and create-trip dialog keys to both ARB files.
2. Add a trip-status display mapper.
3. Add party-type display mapper for trip assignee/courier source values.
4. Replace hardcoded trip labels and table headers with localized keys.
5. Replace raw order-count strings with plural-aware ARB messages.
6. Standardize trip amounts through shared localized currency formatting.

Acceptance checks:

- Staff can create, inspect, send, and mark trips delivered with Arabic UI.
- Trip detail invoice rows remain readable and do not overflow in RTL.
- Trip statuses are localized while backend values remain unchanged for API calls.

### P0 - Expenses

Relevant areas:

- `lib/src/features/expenses/presentation/**`
- `lib/src/features/expenses/data/**`
- `lib/src/features/expenses/domain/**`

Known gaps:

- `expense_form_sheet.dart` hardcodes form labels, validators, empty-options message, and submit text even though many expense keys already exist.
- `expense_card.dart` has hardcoded details such as `Pay from`, `Expense account`, `Paying account`, `POS Profile`, `Remarks`, `Journal Entry`, `Timeline`, `No timeline available`, and `by`.
- Expense statuses can appear as raw backend values.
- Date formatting must pass the active locale.

Required work:

1. Reuse existing expense ARB keys wherever possible before adding new keys.
2. Replace hardcoded form labels, validators, cards, timeline labels, approval states, and empty states with `context.l10n`.
3. Add an expense-status mapper.
4. Localize `DateFormat` calls by passing `Localizations.localeOf(context).toLanguageTag()`.
5. Verify staff-created expense states, especially pending approval, in Arabic.

Acceptance checks:

- Staff can create an expense and understand its pending/approval state in Arabic.
- Expense dates, amounts, and timeline labels are localized.

### P1 - Courier Balances

Relevant areas:

- `lib/src/features/courier_balances/**`
- Related Kanban courier settlement dialogs and services

Known gaps:

- No major gap was confirmed in the first audit, but this is a staff-accessible financial surface and must receive a dedicated pass.
- Courier names and document references are source data and should not be translated.
- Status labels, empty states, settlement actions, error messages, and amount formatting must be verified.

Required work:

1. Audit all courier balance screens and widgets for hardcoded `Text`, `SnackBar`, `AlertDialog`, `tooltip`, `labelText`, and `hintText` values.
2. Localize balance labels, settlement actions, empty states, refresh errors, and permission or validation messages.
3. Apply shared localized amount formatting.
4. Verify interaction from Kanban courier assignment/settlement to Courier Balances.

Acceptance checks:

- Staff can read courier balances and settlement-related UI in Arabic.
- No raw English status or fallback appears in the courier balance workflow.

### P1 - Printers, Receipts, And Print Preview

Relevant areas:

- `lib/src/features/printing/**`
- `lib/src/features/pos/presentation/widgets/receipt/**` if present
- Any receipt rendering or canvas renderer used by POS/Kanban

Known gaps:

- `printer_selection_screen.dart` contains hardcoded `Use new bitmap receipt` and explanatory text.
- Receipt rendering may include labels that are not covered by normal widget scans.
- Thermal receipt width makes Arabic wrapping and RTL alignment risky.

Required work:

1. Localize printer setup labels, compatibility options, print test states, and printer errors.
2. Audit receipt canvas/bitmap renderers for hardcoded labels.
3. Decide receipt language policy:
   - Arabic only when app locale is Arabic, or
   - bilingual receipt labels for customer clarity.
4. Test Arabic receipt rendering on the target receipt width.
5. Verify numbers, currency, invoice IDs, item names, totals, discounts, delivery charge, and payment method labels.

Acceptance checks:

- Staff printer setup screen is Arabic.
- Arabic receipt labels do not clip or overlap on expected paper width.

### P1 - Profile, Settings, Language, And Notifications

Relevant areas:

- `lib/src/features/settings/presentation/user_profile_screen.dart`
- `lib/src/core/widgets/app_drawer.dart`
- Notification/alarm settings used by staff or elevated staff

Known gaps:

- `user_profile_screen.dart` has hardcoded alarm sound controls such as `Preview`, `Browse Custom Sound File`, `No file selected`, and `Custom Sound`.
- The app drawer is mostly localized, but logout/profile/language states should be rechecked after ARB changes.
- Mute notifications is not regular staff, but it is visible to Moderator and above.

Required work:

1. Localize alarm sound labels, browse action, preview tooltip, selection state, and errors.
2. Confirm drawer menu labels and language switch remain correct in Arabic.
3. Keep regular staff and elevated notification controls separated by role.
4. Localize notification/alarm errors through shared error mapping.

Acceptance checks:

- Staff profile/settings screen is fully Arabic.
- Language switching is understandable and does not require English text.

## Shared Implementation Work

### 1. Restore ARB Metadata Parity

The Arabic ARB has all message keys, but it is missing 54 placeholder metadata entries that exist in English.

Required work:

1. Copy placeholder metadata blocks from `app_en.arb` to `app_ar.arb` for the missing entries.
2. Keep placeholders identical between English and Arabic.
3. Run `flutter gen-l10n` after ARB changes.
4. Add an automated parity check so this cannot drift again.

Acceptance check:

- English and Arabic ARB files have matching message keys and matching `@key` metadata entries, excluding `@@locale`.

### 2. Add Localized Display Mappers

Do not translate backend/API constants at the data layer. Keep backend values stable and translate only at the UI boundary.

Recommended file:

- `lib/src/core/localization/localized_display_mappers.dart`

Recommended mapper groups:

| Mapper | Example raw values | Output source |
| --- | --- | --- |
| `localizedInvoiceStatus` | `Draft`, `Paid`, `Unpaid`, `Overdue`, `Cancelled`, `Return` | ARB keys |
| `localizedTripStatus` | `Created`, `Out for Delivery`, `Completed`, `Cancelled` | ARB keys |
| `localizedExpenseStatus` | `Draft`, `Pending Approval`, `Approved`, `Rejected`, `Submitted` | ARB keys |
| `localizedReceiptStatus` | `Confirmed`, `Unconfirmed`, `Pending` | ARB keys |
| `localizedPaymentMode` | `Cash`, `Card`, `Instapay`, `Mobile Wallet`, `Settle Later` | ARB keys |
| `localizedPartyType` | `Employee`, `Supplier`, `Sales Partner`, `Customer` | ARB keys |
| `localizedFallbackValue` | `N/A`, `Not specified`, empty/null | ARB keys |

Implementation rules:

1. UI widgets call mappers with raw values.
2. API requests keep raw values unchanged.
3. Unknown raw values should use a localized `unknownValue(value)` message or a safe localized fallback, depending on the workflow.
4. Unknown values should be logged for support if they indicate unexpected backend drift.

### 3. Add Shared Formatting Helpers

Recommended file:

- `lib/src/core/localization/localized_formatters.dart`

Required helpers:

| Helper | Purpose |
| --- | --- |
| `formatCurrency(context, amount)` | App-standard EGP amount display |
| `formatCompactCurrency(context, amount)` | Optional compact cards/chips |
| `formatDate(context, date)` | Locale-aware date |
| `formatDateTime(context, dateTime)` | Locale-aware date and time |
| `formatCount(context, count)` | Locale-aware count if needed |

Implementation rules:

1. Do not hardcode `$`, `PHP`, or inconsistent `EGP` labels in widgets.
2. Use `Localizations.localeOf(context).toLanguageTag()` for `intl` formatters.
3. Use plural-aware ARB entries for counts like order count and item count.
4. Keep document IDs and ERP names unformatted.

### 4. Replace Hardcoded Text By Pattern

Audit and replace these patterns in staff-facing folders:

- `Text('...')`
- `Text("...")`
- `labelText: '...'`
- `hintText: '...'`
- `helperText: '...'`
- `errorText: '...'`
- `tooltip: '...'`
- `SnackBar(content: Text('...'))`
- `AlertDialog(title: Text('...'), content: Text('...'))`
- `validator: (_) => '...'`
- Raw `.status`, `.paymentStatus`, `.partyType`, or `.docstatus` displayed in widgets
- Raw `DateFormat('MMMM d, yyyy')` or similar without locale
- Raw `toStringAsFixed` next to a hardcoded currency symbol

Non-issues to avoid changing:

- API method names.
- JSON field names.
- ERP document names.
- Route names and route paths.
- Log-only/debug-only strings that are never shown to staff.
- Customer, item, branch, warehouse, territory, and POS profile names returned by ERP.

## Implementation Phases

### Phase 0 - Baseline And Checklist

Estimated effort: 0.5 day

Tasks:

1. Create a staff-route checklist from `ACCESS_MATRIX.md` and `router.dart`.
2. Confirm every staff-accessible screen/widget folder.
3. Re-run the hardcoded-string scan and save results as the baseline.
4. Mark each finding as staff-visible, elevated-only, debug-only, or false positive.
5. Confirm whether receipts should be Arabic-only or bilingual when app locale is Arabic.

Deliverables:

- Updated checklist in this plan or a companion audit file.
- Baseline count of staff-visible hardcoded strings.
- Translation policy for receipts and backend unknown values.

### Phase 1 - Localization Infrastructure

Estimated effort: 1 day

Tasks:

1. Restore Arabic ARB placeholder metadata parity.
2. Add missing ARB keys for shared statuses, fallbacks, payment modes, party types, and common actions.
3. Add localized display mappers.
4. Add locale-aware formatting helpers.
5. Run `flutter gen-l10n`.
6. Run `flutter analyze`.

Deliverables:

- Complete ARB metadata parity.
- Mapper and formatter utilities.
- Analyzer-clean generated localization output.

### Phase 2 - Core Staff POS Flow

Estimated effort: 1.5 to 2 days

Tasks:

1. Localize login/profile/shift surfaced errors.
2. Localize POS draft tabs and draft delete confirmation.
3. Localize new order alert dialog.
4. Localize POS checkout/payment/customer/delivery leftovers found in the baseline.
5. Replace POS currency/date/count formatting with shared helpers.
6. Add widget tests for POS draft and order alert in Arabic.

Deliverables:

- Arabic-complete staff POS entry and selling flow.
- Tests for the highest-frequency POS dialogs.

### Phase 3 - Kanban And Payment Receipts

Estimated effort: 2 to 3 days

Tasks:

1. Localize Kanban filters and status chips using display mappers.
2. Localize custom shipping request dialog.
3. Localize payment receipt list/detail/upload/confirm flow.
4. Localize invoice card actions visible to regular staff.
5. Localize courier assignment and settle-courier dialogs.
6. Verify no raw invoice/payment statuses are shown.
7. Add Arabic widget tests for custom shipping and payment receipt dialogs.

Deliverables:

- Arabic-complete staff Kanban operations.
- Status mapper coverage for invoice/payment/receipt state.

### Phase 4 - Trips, Courier Balances, And Expenses

Estimated effort: 2 to 3 days

Tasks:

1. Localize trips list, trip detail, create trip dialog, and invoice table.
2. Add trip status and party type mapper usage.
3. Localize courier balances after dedicated audit.
4. Localize expense form and expense cards.
5. Add expense status mapper usage.
6. Replace dates and amounts with shared formatters.
7. Add Arabic widget tests for trip detail and expense form/card.

Deliverables:

- Arabic-complete staff delivery and expense workflows.
- No raw trip or expense statuses in regular staff UI.

### Phase 5 - Printers, Receipts, Settings, And Common Errors

Estimated effort: 1.5 to 2 days

Tasks:

1. Localize printer setup labels and compatibility toggle.
2. Audit receipt renderer strings and localize staff/customer-facing labels.
3. Test Arabic receipt rendering width and alignment.
4. Localize user profile/settings alarm sound controls.
5. Localize shared network and backend error fallbacks.
6. Re-run the staff hardcoded-string scan.

Deliverables:

- Arabic-complete printer/settings paths for staff.
- Receipt rendering verified in Arabic.
- Shared error surface localized.

### Phase 6 - Automated Guardrails

Estimated effort: 1 to 2 days

Tasks:

1. Add ARB key parity and metadata parity test.
2. Add a hardcoded-string audit script for staff-facing `presentation`, `screens`, and `widgets` folders.
3. Add a focused scan for raw status rendering patterns.
4. Add Arabic widget tests for every staff route shell or primary screen.
5. Add RTL screenshot/golden checks for high-risk dialogs where practical.
6. Document known false positives for IDs, names, logs, and API constants.

Recommended local commands:

```powershell
Set-Location c:\ERPNext\jarz_pos_mobile\jarz_pos
flutter gen-l10n
flutter analyze
flutter test
```

Notes:

- Run Flutter analyzer from `c:\ERPNext\jarz_pos_mobile\jarz_pos`; running from the workspace root can include archived Dart files under `artifacts/`.
- For staging Flutter web, CanvasKit may not expose stable text semantics. Prefer widget tests/goldens for text coverage and use Playwright staging checks for route reachability, workflow completion, screenshots, and backend/API verification.

Deliverables:

- Tests fail if ARB parity drifts.
- Tests or scripts flag new hardcoded English in staff-facing Flutter UI.
- Arabic smoke coverage exists for staff workflows.

### Phase 7 - Staging Verification And Release

Estimated effort: 0.5 to 1 day

Tasks:

1. Build and deploy to staging through the git-only deployment path.
2. Log in as a dedicated `Jarz POS Staff` staging user.
3. Switch app language to Arabic.
4. Execute the staff Arabic smoke checklist:
   - Login.
   - POS profile selection.
   - Shift start if required.
   - POS catalog/cart/draft/delete draft.
   - Cash checkout or test invoice path.
   - New order alert if available.
   - Kanban view, filters, receipt dialog, courier assignment/settlement surface.
   - Trips list/detail/create trip where safe.
   - Expense create path.
   - Courier balances.
   - Printer setup and receipt preview/print test.
   - Profile/settings/language/logout.
5. Capture screenshots for the high-risk screens.
6. Fix any overflow, clipping, or remaining English text before production release.

Deliverables:

- Staging Arabic verification notes.
- Screenshot artifact set.
- Production-ready release once staging is clean.

## Suggested ARB Key Groups

Use grouped, descriptive key names rather than generic labels that will be ambiguous later.

| Area | Suggested key prefix |
| --- | --- |
| POS drafts | `posDraft...` |
| Order alerts | `orderAlert...` |
| Kanban statuses and filters | `kanban...` or `status...` |
| Custom shipping | `customShipping...` |
| Payment receipts | `paymentReceipt...` |
| Trips | `trips...` |
| Expense cards/forms | `expenses...` |
| Courier balances | `courierBalances...` |
| Printers/receipts | `printing...`, `receipt...` |
| Settings/alarm | `settings...` |
| Shared display values | `display...`, `status...`, `paymentMode...`, `partyType...` |
| Shared errors | `error...`, `network...` |

Plural and placeholder examples to include where needed:

- order count
- item count
- more item count
- amount with currency
- customer name in a label
- invoice number copied
- status changed from/to
- trip sent for delivery confirmation
- mark all as delivered confirmation

## Verification Matrix

| Workflow | Arabic UI check | Data/formatting check | Regression check |
| --- | --- | --- | --- |
| Login/profile/shift | No English labels or errors | Profile names remain source data | Arabic widget route smoke |
| POS drafts | Dialogs and snackbars Arabic | Counts pluralized | Draft widget test |
| Order alert | Labels/actions Arabic | Amount uses EGP formatter | Order alert widget test |
| Kanban filters/cards | Statuses localized | API raw values preserved | Mapper unit tests |
| Payment receipts | Detail rows Arabic | Amount/date localized | Dialog widget test |
| Trips | Statuses/table headers Arabic | Counts, dates, amounts localized | Trip screen/widget test |
| Expenses | Form/card/timeline Arabic | Expense dates localized | Expense widget test |
| Courier balances | Labels/actions/errors Arabic | Amounts localized | Screen smoke test |
| Printers/receipts | Setup and receipt labels Arabic | Receipt width/RTL checked | Screenshot/golden review |
| Settings | Alarm/profile labels Arabic | File names remain source data | Settings widget test |

## Elevated Staff Extension

After the regular `Jarz POS Staff` scope is complete, repeat the same process for elevated role surfaces:

| Role surface | Access level | Areas to audit |
| --- | --- | --- |
| Master Orders | Moderator and above | Filters, chips, raw order/payment states, actions |
| Manager Dashboard view | Line Manager and above | Recent order statuses, branch filters, custom shipping rejection dialog |
| Cancel/transfer order actions | Line Manager and above | Confirmation dialogs, reasons, errors |
| Mute notifications | Moderator and above | Mute/unmute labels, alarm state, errors |
| Manager financial modules | Manager and High Management | Purchase, Manufacturing, Stock Transfer, Cash Transfer, Inventory Count, Reports |

Do not block the regular staff Arabic rollout on manager-only modules unless the business wants one combined Arabic release for all role tiers.

## Risks And Mitigations

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Backend returns English exceptions | Staff still sees English in failure paths | Convert to typed/friendly localized errors in UI and log raw detail separately |
| Raw ERP statuses drift over time | Unknown statuses appear in English | Mapper fallback plus support logging for unknown raw values |
| Arabic text overflows compact chips/dialogs | Poor staff usability | RTL widget tests and screenshots for high-risk screens |
| Receipt Arabic wrapping fails on thermal width | Bad printed output | Dedicated receipt width tests and printer trial before production |
| Hardcoded strings return in future work | Regression | Static audit script in CI or release checklist |
| Duplicate ARB keys grow quickly | Maintenance cost | Reuse existing keys and keep grouped naming conventions |

## Final Acceptance Checklist

Before calling the staff-role Arabic translation complete, confirm:

- [ ] `app_en.arb` and `app_ar.arb` have matching message keys.
- [ ] `app_en.arb` and `app_ar.arb` have matching placeholder metadata entries, excluding `@@locale`.
- [ ] `flutter gen-l10n` completes.
- [ ] `flutter analyze` passes from `jarz_pos_mobile/jarz_pos`.
- [ ] `flutter test` passes for localization tests.
- [ ] Hardcoded-string audit has no staff-visible English findings.
- [ ] Raw-status audit has no staff-visible `.status` or backend constant rendering findings.
- [ ] Arabic smoke screenshots are captured for POS, Kanban, Trips, Expenses, Courier Balances, Printers, and Settings.
- [ ] Staff staging user can complete the core workflow in Arabic.
- [ ] Any remaining English is documented as source data, brand/product name, technical term, or approved exception.

## Recommended First Sprint

Start with these files because they are high-frequency staff surfaces and were confirmed to contain hardcoded English:

1. `lib/src/features/pos/order_alert/presentation/order_alert_dialog.dart`
2. `lib/src/features/pos/presentation/widgets/draft_tabs_bar.dart`
3. `lib/src/features/kanban/widgets/custom_shipping_request_dialog.dart`
4. `lib/src/features/kanban/widgets/payment_receipt_list_dialog.dart`
5. `lib/src/features/trips/screens/trips_screen.dart`
6. `lib/src/features/trips/screens/trip_detail_screen.dart`
7. `lib/src/features/trips/widgets/create_trip_dialog.dart`
8. `lib/src/features/expenses/presentation/widgets/expense_form_sheet.dart`
9. `lib/src/features/expenses/presentation/widgets/expense_card.dart`
10. `lib/src/features/printing/printer_selection_screen.dart`
11. `lib/src/features/settings/presentation/user_profile_screen.dart`

Expected first-sprint output:

- Shared mappers and formatters exist.
- ARB metadata parity is fixed.
- POS drafts, order alert, Kanban custom shipping, payment receipts, Trips, and Expenses no longer show hardcoded English in regular staff flow.
- Arabic widget tests cover the highest-risk dialogs.
