# Jarz POS — Manual Testing Scenarios

> Pre-production manual testing checklist. Each scenario includes steps, expected results, and edge cases.

---

## How to Use This Document

- **Status column**: Mark each test as ✅ Pass, ❌ Fail, or ⏭️ Skipped.
- **Test with multiple roles**: Where noted, repeat the test as Manager, Line Manager, and Staff.
- **Test in both languages**: Where UI text is involved, verify in English and Arabic.

---

## 1. Authentication & Session

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 1.1 | Successful login | Enter valid credentials → tap Login | User is logged in, redirected to POS profile selection or POS screen | |
| 1.2 | Invalid credentials | Enter wrong password → tap Login | Error message shown, user stays on login screen | |
| 1.3 | Session persistence | Log in → close app → reopen app | Session is retained, user does not need to log in again | |
| 1.4 | Session expiry | Wait for session to expire (or clear cookies manually) → try an action | App detects expired session, redirects to login | |
| 1.5 | Logout | Open drawer → tap Logout | Session cleared, user returned to login screen | |

---

## 2. POS Profile Selection

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 2.1 | Profile list — Manager | Log in as Manager | All active POS profiles are shown | |
| 2.2 | Profile list — Staff | Log in as Staff user | Only profiles linked in POS Profile User table are shown | |
| 2.3 | Select profile | Tap on a profile | Profile is selected, user enters POS screen | |
| 2.4 | Shift required | Log in as user with `custom_require_pos_shift` enabled → select profile | Shift start screen is shown before POS access | |
| 2.5 | No profiles linked | Log in as Staff user with no linked profiles | Appropriate message, cannot proceed | |

---

## 3. POS Screen — Item Grid

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 3.1 | View categories | Open POS screen | Category tabs/filters are displayed | |
| 3.2 | Switch category | Tap different category tabs | Items update to show only items in selected category | |
| 3.3 | Item count label | View category with items | "X items" label shows correct count at page bottom | |
| 3.4 | Bundle count label | View category containing bundles | "X bundles" label shows correct count | |
| 3.5 | Item images | View items with images configured | Item images load and display correctly | |
| 3.6 | Item without image | View item with no image | Placeholder or item name displayed cleanly | |
| 3.7 | Search items | Use search bar → type item name | Matching items are filtered in real-time | |
| 3.8 | Search — no results | Search for non-existent item | "No items found" or empty state shown | |

---

## 4. POS Screen — Cart Operations

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 4.1 | Add single item | Tap an item in the grid | Item appears in cart with qty = 1 | |
| 4.2 | Add same item again | Tap the same item twice | Cart shows qty = 2 for that item | |
| 4.3 | Add bundle | Tap a bundle item | Bundle appears in cart with grouped contents displayed (e.g., "Item x3, Item2 x2") | |
| 4.4 | Increase quantity | Tap + on a cart item | Quantity increments by 1 | |
| 4.5 | Decrease quantity | Tap − on a cart item with qty > 1 | Quantity decrements by 1 | |
| 4.6 | Remove item | Tap − on a cart item with qty = 1 (or delete button) | Item removed from cart | |
| 4.7 | Change rate | Tap on the rate field → enter new rate | Rate updates, totals recalculate | |
| 4.8 | Stock limit enforcement | Add item until stock limit reached → try to add one more | Quantity is capped at available stock, warning shown | |
| 4.9 | Empty cart | Remove all items from cart | Cart shows empty state, checkout disabled | |
| 4.10 | Cart total calculation | Add multiple items with different quantities | Grand total = sum of (qty × rate) for each item | |
| 4.11 | Bundle price display | Add a bundle to cart | Bundle rate is displayed correctly (not blank or 0) | |

---

## 5. Customer Management

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 5.1 | Search existing customer | In checkout, type customer name or phone | Matching customers appear in dropdown | |
| 5.2 | Select customer | Tap a customer from search results | Customer is assigned to the invoice | |
| 5.3 | Create customer — full details | Tap "New Customer" → fill name, phone, secondary phone, territory | Customer created successfully | |
| 5.4 | Create customer — minimal | Tap "New Customer" → fill only required fields (name, phone) | Customer created, secondary phone is empty | |
| 5.5 | Create customer — duplicate phone | Enter a phone number that already exists | Error or warning about duplicate | |
| 5.6 | Secondary phone stored | Create customer with secondary phone → check in ERPNext | Secondary phone appears in Contact doc's phone field | |

---

## 6. Payment & Checkout

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 6.1 | Cash payment — exact amount | Add items → Checkout → select Cash → enter exact amount | Invoice created, status = Paid | |
| 6.2 | Cash payment — overpayment | Enter amount greater than total | Change amount displayed, invoice created | |
| 6.3 | Card payment | Add items → Checkout → select Card | Invoice created with card payment entry | |
| 6.4 | Settle later | Add items → Checkout → select Settle Later | Invoice created with unpaid status | |
| 6.5 | Split payment | Pay partially with cash, rest with card | Both payment entries created, invoice fully paid | |
| 6.6 | Delivery order — slot selection | Assign customer → select delivery slot | Delivery slot saved on invoice with correct start/end time | |
| 6.7 | Delivery order — duration | Create delivery order with specific time slot → check kanban | Duration matches slot size (not always 1 hour) | |
| 6.8 | Pickup order | Create order without delivery (pickup) | Invoice marked as pickup, no delivery slot | |
| 6.9 | Free shipping bundle | Add bundle with free shipping → checkout | Delivery/shipping charges suppressed | |
| 6.10 | Sales partner order | Log in as sales partner → create order | Delivery items hidden, address auto-filled from partner | |
| 6.11 | Rounding | Create order where total has >2 decimal places | Total rounded correctly | |
| 6.12 | Duplicate payment prevention | Rapidly tap pay button twice | Only one payment is processed (DB lock prevents double) | |

---

## 7. Kanban Board

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 7.1 | View columns | Open Kanban | Columns shown: Preparing, Ready, Out for Delivery, Delivered, Cancelled | |
| 7.2 | Invoice cards | View kanban with existing orders | Each invoice shows customer name, amount, time, status badges | |
| 7.3 | Drag — Preparing → Ready | Drag an order from Preparing to Ready | Status updates to Ready | |
| 7.4 | Drag — Ready → OFD | Drag a delivery order from Ready to OFD | Status updates to Out for Delivery, Delivery Note created | |
| 7.5 | Drag — skip columns | Try to drag from Preparing directly to OFD | Transition blocked — can only move one step at a time | |
| 7.6 | OFD — pickup order without payment | Try to move unpaid pickup order to OFD | Blocked — pickup orders need payment first | |
| 7.7 | OFD — custom shipping pending | Try to move order with pending custom shipping to OFD | Blocked — custom shipping must be confirmed first | |
| 7.8 | Delivered status | Drag from OFD to Delivered | Status updates, delivery completed | |
| 7.9 | Real-time updates | Create a new order from another device | New order appears on kanban without manual refresh (polling every 30s) | |
| 7.10 | Card menu — Preview | Tap card menu → Preview | Invoice preview dialog opens with full details | |
| 7.11 | Card menu — Print | Tap card menu → Print | Receipt prints on connected thermal printer | |

---

## 8. Kanban — Role-Restricted Actions

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 8.1 | Transfer order — Line Manager | Log in as Line Manager → open card menu | "Transfer Order" option is visible | |
| 8.2 | Transfer order — Staff | Log in as Staff → open card menu | "Transfer Order" option is NOT visible | |
| 8.3 | Transfer order — execute | As Line Manager → Transfer Order → select target profile | Order moves to target POS profile | |
| 8.4 | Cancel order — Line Manager | Log in as Line Manager → open card menu | "Cancel Order" option is visible and enabled | |
| 8.5 | Cancel order — Staff | Log in as Staff → open card menu | "Cancel Order" option is NOT visible | |
| 8.6 | Cancel order — partial payment | As Line Manager → try to cancel order with partial payment | Cancel button is greyed out, shows "Settle first" message | |
| 8.7 | Cancel order — execute | As Line Manager → Cancel Order on unpaid order | Order moves to Cancelled column | |

---

## 9. Delivery Partners & Couriers

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 9.1 | View delivery partners | Open delivery partner selection | Both employee and supplier couriers listed | |
| 9.2 | Assign delivery partner | Select a courier for an order | Courier assigned, visible on invoice card | |
| 9.3 | Courier balances | Open Courier Balances from drawer | Shows outstanding amounts for all couriers | |
| 9.4 | Settle courier | Tap Settle on a courier with balance | Settlement processed, creates JE (debit cash / credit Creditors) | |

---

## 10. Trip Management

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 10.1 | View trips | Open Trips from drawer | List of trips displayed | |
| 10.2 | Create trip | Tap Create Trip → select invoices | Trip created with selected invoices | |
| 10.3 | Add pickup order to trip | Try to add a pickup order | Blocked — pickup orders cannot be added to trips | |
| 10.4 | Send trip for delivery | Select trip → Send for Delivery | All trip invoices transition to OFD, Delivery Notes created | |
| 10.5 | Multi-territory trip | Create trip with orders from different territories | Double shipping multiplier applied | |

---

## 11. Receipt Printing

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 11.1 | Connect printer | Open Printers → scan for Bluetooth devices → select printer | Printer connected successfully | |
| 11.2 | Print receipt — English | Print receipt for English-language order | Receipt prints clearly, no garbled characters | |
| 11.3 | Print receipt — Arabic | Print receipt with Arabic item names | Arabic text renders correctly (raster mode) | |
| 11.4 | Receipt content | Print and inspect receipt | Shows: store name, date, items with qty/rate, totals, payment method | |
| 11.5 | Bundle on receipt | Print receipt for order containing a bundle | Bundle contents shown grouped (e.g., "Item x3") | |
| 11.6 | Print from kanban | Open card menu → Print | Receipt prints for that specific invoice | |
| 11.7 | Printer disconnected | Try to print with no printer connected | Error message shown, app does not crash | |
| 11.8 | Long receipt | Print order with 20+ line items | All items print, receipt is complete | |

---

## 12. Expenses

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 12.1 | Create expense — Staff | Log in as Staff → Expenses → Create | Expense created with `requires_approval = 1` | |
| 12.2 | Create expense — Manager | Log in as Manager → Expenses → Create | Expense auto-approved and submitted | |
| 12.3 | Payment sources — Staff | As Staff → Create Expense → view payment sources | Only own POS profile accounts visible | |
| 12.4 | Payment sources — Manager | As Manager → Create Expense → view payment sources | All accounts + cash-like accounts visible | |
| 12.5 | Approve expense | As Manager → open pending expense → Approve | Expense approved, JE created | |
| 12.6 | Approve as Staff | As Staff → try to approve an expense | Rejected — "Only managers can approve expenses" | |
| 12.7 | Mobile wallet expense | Create expense with Mobile Wallet payment | Requires approval regardless of role | |
| 12.8 | List expenses | Open Expenses screen | All expenses for the POS profile listed with status | |

---

## 13. Shift Management

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 13.1 | Start shift | Select profile → Start Shift → enter opening amounts | Shift created, user can access POS | |
| 13.2 | Start shift — already open | Try to start shift when one is already active | Blocked — cannot have two active shifts on same profile | |
| 13.3 | End shift | End Shift → enter closing amounts | POS Closing Entry created | |
| 13.4 | Shift discrepancy | Enter closing amount different from expected | Discrepancy JE created (Cash Over/Short) | |
| 13.5 | End another user's shift | Try to close a shift opened by different user | Blocked — only the opener can close it | |
| 13.6 | Shift summary | End shift → view summary | Shows opening/closing amounts, transactions, discrepancy | |

---

## 14. Manager Dashboard

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 14.1 | Access as Manager | Log in as Manager → open Manager Dashboard | Dashboard loads with analytics and summary | |
| 14.2 | Access as Staff | Log in as Staff → check drawer | Manager Dashboard option is NOT visible | |
| 14.3 | Summary cards | View dashboard | Sales totals, order counts, branch-scoped data shown | |
| 14.4 | Historical data | Select a past date | Data reflects that date's totals | |
| 14.5 | Pending shipping requests | View pending custom shipping requests | List of orders awaiting shipping confirmation | |

---

## 15. Purchase Invoices (Manager Only)

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 15.1 | Access as Manager | Open Purchase Invoices from drawer | Purchase screen loads | |
| 15.2 | Access as Staff | Log in as Staff → check drawer | Purchase Invoices option NOT visible | |
| 15.3 | Create purchase invoice | Select supplier → add items → submit | Purchase Invoice created, auto-paid, stock updated | |
| 15.4 | Supplier search | Type supplier name | Matching suppliers shown | |
| 15.5 | Item search | Search for items to purchase | Items listed with standard buying rate | |

---

## 16. Stock Transfer (Manager Only)

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 16.1 | Access check | Log in as non-manager → check drawer | Stock Transfer NOT visible | |
| 16.2 | Transfer items | Select source → target → items → quantities → submit | Stock Entry created, SLE updated | |
| 16.3 | Same source and target | Select same warehouse as source and target | Blocked — source ≠ target required | |
| 16.4 | Zero quantity | Try to transfer 0 qty | Rejected | |
| 16.5 | Exceeds available stock | Try to transfer more than available (accounting for reserved) | Rejected or capped | |

---

## 17. Cash Transfer (Manager Only)

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 17.1 | Access check | Log in as non-manager → check drawer | Cash Transfer NOT visible | |
| 17.2 | Transfer cash | Select from account → to account → amount → submit | Journal Entry created (double-entry) | |
| 17.3 | Same account | Select same account as source and target | Blocked — from ≠ to required | |
| 17.4 | Zero or negative amount | Enter 0 or negative amount | Rejected | |

---

## 18. Manufacturing (Manager Only)

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 18.1 | Access check | Log in as non-manager → check drawer | Manufacturing NOT visible | |
| 18.2 | View BOMs | Open Manufacturing screen | Items with default BOM listed | |
| 18.3 | Submit work order | Select BOM → enter quantity → submit | Work Order created | |
| 18.4 | Insufficient components | Submit WO when component stock is insufficient | Error — insufficient stock for components | |

---

## 19. Inventory Count (Manager Only)

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 19.1 | Access check | Log in as non-manager → check drawer | Inventory Count NOT visible | |
| 19.2 | Count items | Select warehouse → enter counts for items → submit | Stock Reconciliation created | |
| 19.3 | Partial count | Count only some items (with `enforce_all = false`) | Accepted — only counted items reconciled | |
| 19.4 | Negative count | Enter negative quantity | Clamped to 0 | |

---

## 20. Notifications & Real-Time Updates

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 20.1 | Push notification — new order | Submit order from one device | Push notification received on other devices | |
| 20.2 | Kanban polling | Leave kanban open → create order from another device | New order appears within ~30 seconds | |
| 20.3 | Mute notifications — Manager | As Manager → Profile → toggle Mute Notifications | Notifications muted, toggle visible | |
| 20.4 | Mute notifications — Staff | As Staff → Profile | Mute Notifications toggle NOT visible | |

---

## 21. Localization & UI

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 21.1 | Switch to Arabic | Profile → change language to Arabic | All UI text switches to Arabic, layout changes to RTL | |
| 21.2 | Switch to English | Profile → change language to English | All UI text switches to English, layout changes to LTR | |
| 21.3 | Language persistence | Change language → close app → reopen | Language preference retained | |
| 21.4 | Arabic receipt | Set Arabic → print receipt | Receipt text renders in Arabic correctly | |
| 21.5 | Mixed content | Arabic UI with English item names | Both scripts render correctly | |

---

## 22. Error Handling & Edge Cases

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 22.1 | Network disconnection | Disable network → try to create order | Appropriate error shown, no crash | |
| 22.2 | Slow network | Throttle network → perform various operations | Loading indicators shown, no timeouts without feedback | |
| 22.3 | Session expired mid-action | Let session expire → try to submit order | Redirected to login, data not lost if possible | |
| 22.4 | Concurrent modification | Two users edit same order simultaneously | Conflict handled gracefully, no data corruption | |
| 22.5 | App backgrounded during checkout | Background app during payment → return | Payment completes or shows clear status | |
| 22.6 | Large order | Create order with 30+ line items | All items saved, receipt prints fully | |

---

## 23. Cross-Feature Integration Tests

| # | Scenario | Steps | Expected Result | Status |
|---|----------|-------|-----------------|--------|
| 23.1 | Full delivery flow | Create order → assign customer → select delivery slot → pay (settle later) → assign courier → create trip → send OFD → mark delivered → settle courier | All steps complete, all documents created (Invoice, DN, Payment Entry, Courier Transaction, JE) | |
| 23.2 | Full pickup flow | Create order → pay cash → move to Ready → customer picks up → mark Delivered | Pickup order does not require delivery note or courier | |
| 23.3 | Shift lifecycle | Start shift → create multiple orders → process payments → end shift | Opening/closing amounts match, POS Closing Entry accurate | |
| 23.4 | Expense & approval flow | Staff creates expense → Manager approves → verify GL | JE created on approval with correct debit/credit accounts | |
| 23.5 | Stock flow | Purchase Invoice (adds stock) → POS sale (reduces stock) → verify inventory | Stock Ledger Entries balance correctly | |
| 23.6 | Bundle end-to-end | Add bundle to cart → verify display → checkout → print receipt → check kanban card | Bundle grouped correctly at every stage | |
| 23.7 | Cancel & re-order | Create order → Line Manager cancels → create new order with same items | Both orders exist, cancelled order in Cancelled column, new order in Preparing | |

---

## Testing Environment Checklist

Before starting testing, ensure:

- [ ] Staging server is running and accessible
- [ ] At least 2 test users configured: one Manager, one Staff
- [ ] POS Profiles created and linked to test users
- [ ] Items and bundles available with stock
- [ ] Thermal printer available and charged
- [ ] Both Android devices available for multi-device tests
- [ ] Delivery partners (employee + supplier) configured
- [ ] Territories configured for delivery testing
- [ ] BOM configured for at least one item (manufacturing tests)
