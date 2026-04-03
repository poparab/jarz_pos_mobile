# Jarz POS — Manual Testing Scenarios

> Pre-production manual testing checklist. Each scenario includes steps, expected results, and what to verify in ERPNext Desk.

---

## How to Use This Document

- **Status column**: Mark each test as ✅ Pass, ❌ Fail, or ⏭️ Skipped.
- **Test with multiple roles**: Where noted, repeat the test as Manager, Line Manager, and Staff.
- **Test in both languages**: Where UI text is involved, verify in English and Arabic.
- **Desk verification**: After each action, open ERPNext Desk and verify the documents and fields listed in the "Verify in Desk" column.
- **Desk URL**: `https://erpstg.orderjarz.com` (staging)

---

## 1. Authentication & Session

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 1.1 | Successful login | Enter valid credentials → tap Login | Redirected to POS profile selection or POS screen | Activity Log: new login entry for user | |
| 1.2 | Invalid credentials | Enter wrong password → tap Login | Error message shown, stays on login screen | Activity Log: failed login attempt recorded | |
| 1.3 | Session persistence | Log in → close app → reopen | Session retained, no re-login needed | — | |
| 1.4 | Session expiry | Wait for session to expire → try an action | Redirected to login | — | |
| 1.5 | Logout | Drawer → Logout | Returned to login screen | — | |

---

## 2. POS Profile Selection

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 2.1 | Profile list — Manager | Log in as Manager | All active POS profiles shown | POS Profile list: check `disabled=0` profiles match what app shows | |
| 2.2 | Profile list — Staff | Log in as Staff | Only profiles where user is in POS Profile → User table | POS Profile → applicable_users child table: confirm user is listed | |
| 2.3 | Select profile | Tap a profile | Profile selected, POS screen loads | — | |
| 2.4 | Shift required | User with `custom_require_pos_shift` → select profile | Shift start screen shown before POS access | POS Profile: check `custom_require_pos_shift = 1` | |
| 2.5 | No profiles linked | Staff with no linked profiles → login | "No POS Profiles" message, cannot proceed | POS Profile: confirm user not in any User table | |

---

## 3. POS Screen — Item Grid

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 3.1 | View categories | Open POS screen | Category tabs/filters displayed | Item Group list: groups with `show_in_website=1` or linked items | |
| 3.2 | Switch category | Tap different category tabs | Items filtered by selected category | Item list: filter by `item_group`, confirm matching items | |
| 3.3 | Item count label | View category with items | "X items" count correct at bottom | — | |
| 3.4 | Bundle count label | View category with bundles | "X bundles" count correct | Item list: filter `is_stock_item=0` + has Product Bundle | |
| 3.5 | Item images | View items with images | Images load correctly | Item → image field: confirm URL exists and loads | |
| 3.6 | Item without image | View item with no image | Placeholder shown cleanly | Item → image field: confirm empty | |
| 3.7 | Search items | Type item name in search bar | Real-time filtering, matching items shown | — | |
| 3.8 | Search — no results | Search for non-existent item | "No items found" shown | — | |

---

## 4. POS Screen — Cart Operations

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 4.1 | Add single item | Tap item in grid | Item in cart, qty = 1 | — | |
| 4.2 | Add same item again | Tap same item twice | Cart qty = 2 for that item | — | |
| 4.3 | Add bundle | Tap a Product Bundle item | Bundle in cart with grouped contents ("Item x3, Item2 x2") | Product Bundle doc: verify components match display | |
| 4.4 | Increase quantity | Tap + on cart item | qty + 1 | — | |
| 4.5 | Decrease quantity | Tap − on cart item (qty > 1) | qty − 1 | — | |
| 4.6 | Remove item | Tap − on item with qty = 1 | Item removed from cart | — | |
| 4.7 | Change rate | Tap rate field → enter new rate | Rate and totals recalculate | — | |
| 4.8 | Stock limit | Add item until stock depleted → try +1 more | Capped at available stock, warning shown | Stock Ledger: check `actual_qty` in Bin for that warehouse | |
| 4.9 | Empty cart | Remove all items | Empty state, checkout disabled | — | |
| 4.10 | Cart total | Add multiple items, different quantities | Grand total = Σ(qty × rate) | — | |
| 4.11 | Bundle price | Add bundle | Rate displays correctly (not 0 or blank) | Product Bundle → total from component prices | |

---

## 5. Customer Management

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 5.1 | Search existing customer | Type customer name or phone | Matching customers in dropdown | Customer list: confirm matches exist | |
| 5.2 | Select customer | Tap customer from results | Customer assigned to invoice | — | |
| 5.3 | Create customer — full | "New Customer" → name + phone + secondary phone + territory | Customer created | **Customer** doc: `customer_name`, `territory`, `customer_type=Individual`, `customer_group=Individual`. **Address** doc: `address_line1`, `city=territory_name`, `is_primary_address=1`, `is_shipping_address=1`, phone fields populated. **Contact** doc: `mobile_no=primary phone`, `phone=secondary phone`, `is_primary_contact=1` | |
| 5.4 | Create customer — minimal | "New Customer" → name + phone only | Created, secondary phone empty | Contact doc: `phone` field is empty, `mobile_no` has primary | |
| 5.5 | Duplicate phone | Enter existing phone number | Error: "Customer with mobile number already exists" | — | |
| 5.6 | Secondary phone stored | Create with secondary phone | | Contact doc → `phone` field (not `mobile_no`) has secondary number | |
| 5.7 | Territory assignment | Create customer with territory | Customer linked to parent territory | Customer doc → `territory` field matches selected territory | |

---

## 6. Payment & Checkout

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 6.1 | Cash — exact amount | Items → Checkout → Cash → exact amount → Pay | Invoice created, fully paid | **Sales Invoice**: `status=Paid`, `outstanding_amount=0`, `is_pos=1`. **Payment Entry**: `payment_type=Receive`, `paid_to=POS Profile cash account`, `paid_amount=grand_total` | |
| 6.2 | Cash — overpayment | Enter amount > total | Change amount displayed, invoice paid | Sales Invoice: `outstanding_amount=0`. Payment Entry: `paid_amount` = amount entered (change handled by UI) | |
| 6.3 | Instapay payment | Items → Checkout → Instapay | Invoice created with Instapay PE | **Payment Entry**: `mode_of_payment` matches Instapay, `paid_to` = Bank Account, `reference_no` populated | |
| 6.4 | Mobile Wallet payment | Items → Checkout → Mobile Wallet | Invoice + PE created | **Payment Entry**: `paid_to` = "Mobile Wallet - COMPANY_ABBR" | |
| 6.5 | Settle later | Items → Checkout → Settle Later | Invoice created, unpaid | **Sales Invoice**: `status=Unpaid`, `outstanding_amount=grand_total`. No Payment Entry created | |
| 6.6 | Split payment | Pay part cash, rest Instapay | Both PEs created, invoice fully paid | Two **Payment Entry** docs linked to same SI. SI `outstanding_amount=0` | |
| 6.7 | Delivery slot selection | Assign customer → select delivery slot | Slot saved on invoice | **Sales Invoice**: `custom_delivery_date`, `custom_delivery_time_from`, `custom_delivery_duration` are populated correctly | |
| 6.8 | Delivery slot duration | Create delivery with specific time slot | Duration matches slot size (e.g., 2h slot ≠ 1h) | SI: `custom_delivery_duration` matches timetable slot_hours for that territory | |
| 6.9 | Pickup order | Create order without delivery | Marked as pickup | **Sales Invoice**: `custom_pickup=1`, no delivery slot fields, no shipping charges | |
| 6.10 | Free shipping bundle | Add bundle with `free_shipping=1` → checkout | No delivery/shipping charges | SI: no delivery charge line item. Grand total = items only | |
| 6.11 | Sales partner order | As sales partner → create order | Delivery income suppressed, partner address auto-filled | **Sales Invoice**: `sales_partner` field set. No delivery charge line. Customer address from partner config | |
| 6.12 | Rounding | Order with >2 decimal total | Rounded correctly | SI: `grand_total` and `rounded_total` are proper | |
| 6.13 | Duplicate payment prevention | Rapidly tap pay button twice | Only one payment processed | Only 1 Payment Entry exists for this SI (check Payment Entry list filtered by SI reference) | |
| 6.14 | Payment receipt — Instapay | Pay via Instapay → upload photo receipt | Receipt uploaded, status = Unconfirmed | **POS Payment Receipt**: `status=Unconfirmed`, `payment_method=Instapay`, `sales_invoice` linked. **File** doc: receipt image attached | |
| 6.15 | Payment receipt — confirm | Manager confirms receipt | Status = Confirmed | **POS Payment Receipt**: `status=Confirmed`, `confirmed_by` = manager user, `confirmed_date` set | |

---

## 7. Kanban Board

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 7.1 | View columns | Open Kanban | Columns: Received, Processing, Preparing, Out for Delivery, Delivered/Completed, Cancelled | — | |
| 7.2 | Invoice cards | View kanban with orders | Cards show customer name, amount, time, status badges | — | |
| 7.3 | Territory display — English | Set app language to English → view cards | Territory shows English name (e.g., "Nasr City") | Territory doc: `territory_name` = "Nasr City" | |
| 7.4 | Territory display — Arabic | Set app language to Arabic → view cards | Territory shows Arabic name (e.g., "مدينة نصر") | Translation doc: `source_text="Nasr City"`, `language=ar`, `translated_text="مدينة نصر"` | |
| 7.5 | State → Preparing | Move order to Preparing | State updates | **Sales Invoice**: `custom_sales_invoice_state = Preparing` | |
| 7.6 | State → Ready | Move from Preparing to Ready | State updates | SI: `custom_sales_invoice_state = Ready` | |
| 7.7 | State → OFD (single order) | Move Ready order to Out for Delivery | State updates, Delivery Note created | **Sales Invoice**: `custom_sales_invoice_state = Out for Delivery`. **Delivery Note**: `docstatus=1`, `per_billed=100`, remarks contains SI name | |
| 7.8 | Skip columns blocked | Try dragging Preparing → OFD directly | Transition blocked | SI state unchanged | |
| 7.9 | OFD — missing sub-territory | Move order to OFD where territory has children but sub-territory not set | Blocked, sub-territory selection prompt shown | SI: `custom_sub_territory` is empty; Territory has `is_group=1` or children exist | |
| 7.10 | OFD — custom shipping pending | Move order with pending custom shipping | Blocked: "Custom shipping request is pending" | SI: `custom_shipping_override_status = Pending`. Custom Shipping Request doc: `status=Pending` | |
| 7.11 | Delivered | Move OFD → Delivered | Delivery completed | SI: `custom_sales_invoice_state = Delivered` | |
| 7.12 | Real-time polling | Create order from another device | New card appears within ~30 seconds | — | |
| 7.13 | Card — Preview | Card menu → Preview | Invoice detail dialog opens | — | |
| 7.14 | Card — Print | Card menu → Print | Receipt prints on thermal printer | — | |
| 7.15 | Invoice acceptance | New order appears → tap Accept | Acceptance recorded | SI: `custom_acceptance_status=Accepted`, `custom_accepted_by` = user, `custom_accepted_on` = timestamp | |

---

## 8. Kanban — Role-Restricted Actions

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 8.1 | Transfer — Line Manager | As Line Manager → card menu | "Transfer Order" visible | — | |
| 8.2 | Transfer — Staff | As Staff → card menu | "Transfer Order" NOT visible | — | |
| 8.3 | Transfer — execute | Transfer → select target profile | Order moves to target profile | SI: `pos_profile` field changed to target profile name | |
| 8.4 | Cancel — Line Manager | As Line Manager → card menu | "Cancel Order" visible | — | |
| 8.5 | Cancel — Staff | As Staff → card menu | "Cancel Order" NOT visible | — | |
| 8.6 | Cancel unpaid order | As Line Manager → Cancel unpaid order | Moved to Cancelled | **Sales Invoice**: `docstatus=2` (cancelled). Comment added with reason + notes | |
| 8.7 | Cancel paid order | As Line Manager → Cancel paid order | Payments cancelled first, then invoice cancelled | **Payment Entry**: `docstatus=2` (all PEs for this SI). **Sales Invoice**: `docstatus=2`. Tolerance ±0.50 EGP | |
| 8.8 | Cancel — OFD+ blocked | Try to cancel order in OFD or Delivered state | Cancelled blocked | SI state unchanged. Error message shown | |

---

## 9. Delivery Partners & Couriers

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 9.1 | View couriers | Open delivery partner selection | Both Employee (group="Delivery") and Supplier (group="Delivery") listed | Employee list: `designation` or group = "Delivery". Supplier list: `supplier_group = Delivery` | |
| 9.2 | Create courier — Employee | Create new courier (Employee type) | Employee created in Delivery group | **Employee** doc: `employee_name`, group/branch set, `custom_delivery_partner` linked | |
| 9.3 | Create courier — Supplier | Create new courier (Supplier type) | Supplier created in Delivery group | **Supplier** doc: `supplier_name`, `supplier_group=Delivery` | |
| 9.4 | Assign courier | Select courier for order | Courier shown on invoice card | — | |
| 9.5 | Courier balances | Drawer → Courier Balances | Outstanding amounts for all couriers | **Courier Transaction** list: filter `status=Unsettled`, group by `party` | |
| 9.6 | Settle courier — collect | Settle courier who collected unpaid order payment | Cash collected from courier | **Journal Entry**: DR `POS Profile cash account` / CR `Creditors - ABBR` (party = courier). **Courier Transaction**: `status=Settled` | |
| 9.7 | Settle courier — shipping only | Settle courier for paid order (shipping settlement only) | Only shipping expense settled | **Journal Entry**: DR `Freight and Forwarding Charges - ABBR` / CR `Creditors - ABBR`. **Courier Transaction**: `amount=0`, `shipping_amount>0`, `status=Settled` | |
| 9.8 | Settlement preview | Tap settle → preview shown | Preview shows order_amount, shipping_amount, net_amount, branch_action (collect/pay) | — | |

---

## 10. Trip Management

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 10.1 | View trips | Drawer → Trips | Trip list with status badges | Delivery Trip list in Desk | |
| 10.2 | Create trip | Create Trip → select invoices → assign courier | Trip created with selected invoices | **Delivery Trip**: `status=Created`, `courier_party_type`, `courier_party` set. Child table `invoices` lists each SI with customer, territory, grand_total | |
| 10.3 | Trip territory display | View trip with territories | Territory names shown (English/Arabic based on language) | Trip detail: `territory_display` and `sub_territory_display` present | |
| 10.4 | Pickup order blocked | Try adding pickup order to trip | Blocked — not allowed | — | |
| 10.5 | Send trip — unpaid invoices | Send trip for delivery (with unpaid invoices) | All invoices → OFD, courier outstanding created | **Per unpaid invoice**: **Payment Entry** (outstanding → courier), **Courier Transaction** (`status=Unsettled`, `amount=grand_total`, `delivery_trip` linked), **Delivery Note** (submitted, per_billed=100). **Per paid invoice**: **Courier Transaction** (`amount=0`, `shipping_amount` set), **Delivery Note**. **Shipping JE** per invoice: DR `Freight and Forwarding Charges` / CR `Creditors` (party=courier). **Delivery Trip**: `status=Out for Delivery` | |
| 10.6 | Send trip — validation | Send trip with missing sub-territory | Blocked — all invoices validated before any transition | SI unchanged, error message about sub-territory | |
| 10.7 | Send trip — custom shipping pending | Trip has invoice with pending custom shipping | Entire trip blocked | Error: "Custom shipping request is pending manager approval" | |
| 10.8 | Double shipping | Create trip with `is_double_shipping=true` | Shipping × 2 | **Shipping JE**: amount = territory delivery_expense × 2. **Courier Transaction**: `shipping_amount` doubled | |
| 10.9 | Mark trip delivered | Trip → Mark as Delivered | Trip completed | **Delivery Trip**: `status=Completed`. All SIs: `custom_sales_invoice_state=Delivered` | |
| 10.10 | Mark delivered — idempotent | Mark already-delivered trip again | Returns success, no duplicate | No new documents created | |

---

## 11. Custom Shipping Requests

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 11.1 | Request custom shipping | On order → Request Custom Shipping → enter amount + reason | Request created, OFD blocked | **Custom Shipping Request**: `invoice`, `amount`, `reason`, `status=Pending`, `original_amount` (territory default). **Sales Invoice**: `custom_shipping_override_status=Pending` | |
| 11.2 | Reason too short | Enter reason < 10 characters | Error: "Please provide a reason of at least 10 characters" | — | |
| 11.3 | Duplicate request | Request custom shipping when one already pending | Error: "A custom shipping request is already pending" | — | |
| 11.4 | Approve request | Manager approves custom shipping | Override amount applied | **Custom Shipping Request**: `status=Approved`. **Sales Invoice**: `custom_shipping_override_status=Approved`, shipping amount updated | |
| 11.5 | Reject request | Manager rejects | OFD unblocked, original shipping restored | **Custom Shipping Request**: `status=Rejected`. **Sales Invoice**: `custom_shipping_override_status` cleared | |

---

## 12. Receipt Printing

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 12.1 | Connect printer | Printers → scan Bluetooth → select printer | Printer connected | — | |
| 12.2 | Print — English | Print English order receipt | Prints clearly, correct layout | — | |
| 12.3 | Print — Arabic | Print receipt with Arabic items | Arabic text renders correctly (raster mode) | — | |
| 12.4 | Receipt content | Print and inspect | Shows: store name, date/time, items (qty × rate), subtotal, delivery charge (if any), grand total, payment method, customer name | — | |
| 12.5 | Bundle on receipt | Print bundle order | Bundle contents grouped (e.g., "Item x3") | — | |
| 12.6 | Print from kanban | Card menu → Print | Correct invoice receipt prints | — | |
| 12.7 | Printer disconnected | Print with no printer | Error message, no crash | — | |
| 12.8 | Long receipt | Order with 20+ items | All items print, receipt complete | — | |

---

## 13. Expenses

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 13.1 | Create — Staff | Staff → Expenses → Create → select reason + amount + payment source | Expense created, pending approval | **Jarz Expense Request**: `requires_approval=1`, `docstatus=0`, `requested_by` = staff user, `payment_source_type=POS Profile`, `pos_profile` set | |
| 13.2 | Create — Manager | Manager → Expenses → Create | Auto-approved, submitted | **Jarz Expense Request**: `docstatus=1`, `approved_by` = manager, `approved_on` set | |
| 13.3 | Payment sources — Staff | Staff → view sources | Only own POS Profile accounts | — | |
| 13.4 | Payment sources — Manager | Manager → view sources | All POS Profiles + bank/cash accounts | — | |
| 13.5 | Approve expense | Manager → pending expense → Approve | Approved, JE created | **Jarz Expense Request**: `docstatus=1`, `approved_by`, `approved_on`. **Journal Entry**: DR `reason_account` (Indirect Expenses) / CR `paying_account` (cash/bank) | |
| 13.6 | Approve — Staff blocked | Staff → try to approve | Error: "Only managers can approve expenses" | Expense `docstatus` unchanged | |
| 13.7 | Zero amount | Enter amount = 0 | Error: "Amount must be greater than zero" | — | |
| 13.8 | Missing reason | Submit without reason account | Error: "Reason (expense account) is required" | — | |
| 13.9 | List expenses | Open Expenses screen | All expenses for POS profile listed with status | Jarz Expense Request list: filter by `pos_profile` | |

---

## 14. Shift Management

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 14.1 | Start shift | Select profile → Start Shift → enter opening amount per payment method | Shift started, POS accessible | **POS Opening Entry**: `docstatus=1`, `pos_profile`, `user`, `period_start_date`. Child table `balance_details`: each row has `mode_of_payment` and `opening_amount` | |
| 14.2 | Already open shift | Try starting shift on profile with active shift | Blocked: cannot have two active shifts | POS Opening Entry: existing open entry for this profile (no closing entry yet) | |
| 14.3 | End shift — no discrepancy | End Shift → enter closing amounts matching system | Shift closed normally | **POS Closing Entry**: `docstatus=1`, `pos_opening_entry` linked. `grand_total` and `net_total` match. No discrepancy JE | |
| 14.4 | End shift — discrepancy | Enter closing amount ≠ expected | Discrepancy JE created | **POS Closing Entry**: created. **Journal Entry**: has "Cash Over/Short" account. If surplus: DR `POS Profile cash` / CR `Cash Over/Short - ABBR`. If deficit: DR `Cash Over/Short` / CR `POS Profile cash` | |
| 14.5 | Another user's shift | Try closing shift started by different user | Blocked | — | |
| 14.6 | Shift summary | End shift → view summary | Opening/closing amounts, transaction count, discrepancy shown | POS Closing Entry: `payment_reconciliation` child table | |
| 14.7 | Shift notifications | Start shift | Notification sent to all users on same POS profile | Websocket event `shift_started` emitted | |

---

## 15. Manager Dashboard

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 15.1 | Access — Manager | Manager → Drawer → Manager Dashboard | Dashboard loads with analytics | — | |
| 15.2 | Access — Staff | Staff → Drawer | Manager Dashboard NOT visible | — | |
| 15.3 | Summary cards | View dashboard | Sales totals, order counts, branch-scoped | SI list: filter by `pos_profile` and `posting_date`, verify totals match | |
| 15.4 | Historical data | Select past date | Data reflects that date | SI list: filter by date, compare totals | |
| 15.5 | Pending shipping | View pending custom shipping | Custom shipping requests listed | Custom Shipping Request list: filter `status=Pending` | |

---

## 16. Purchase Invoices (Manager Only)

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 16.1 | Access — Manager | Drawer → Purchase Invoices | Screen loads | — | |
| 16.2 | Access — Staff | Staff → Drawer | Purchase NOT visible | — | |
| 16.3 | Create PI — auto-paid | Supplier → items → quantities → submit (is_paid=1) | PI created, paid, stock updated | **Purchase Invoice**: `docstatus=1`, `is_paid=1`, `update_stock=1`, `outstanding_amount=0`. **Stock Ledger Entry**: new entry for each item, `actual_qty` increased in target warehouse. **GL Entry**: DR `Stock In Hand` / CR `Creditors`, DR `Creditors` / CR `Cash/Bank` | |
| 16.4 | PI with freight | Add shipping/freight charge | Freight added to valuation | **Purchase Invoice**: `taxes` table has row with `account_head = Freight and Forwarding Charges`, `category = Valuation and Total` | |
| 16.5 | Supplier search | Type supplier name | Matching suppliers shown | Supplier list: confirm matches | |
| 16.6 | Item price | Search item | Standard Buying rate shown | Item Price: filter `price_list=Standard Buying`, confirm rate matches | |

---

## 17. Stock Transfer (Manager Only)

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 17.1 | Access — non-manager | Non-manager → Drawer | Stock Transfer NOT visible | — | |
| 17.2 | Transfer items | Source warehouse → Target → items → quantities → submit | Transfer done | **Stock Entry**: `stock_entry_type=Material Transfer`, `docstatus=1`. Items table: each row has `s_warehouse` (from), `t_warehouse` (to), `qty`. **Stock Ledger Entry**: qty decreased in source, increased in target | |
| 17.3 | Same source/target | Select same warehouse for both | Error: source ≠ target required | — | |
| 17.4 | Zero quantity | Enter qty = 0 | Rejected | — | |
| 17.5 | Exceeds stock | Transfer more than available (minus reserved qty) | Rejected or capped | Bin: check `actual_qty` minus reserved (open SI `qty - delivered_qty`) | |

---

## 18. Cash Transfer (Manager Only)

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 18.1 | Access — non-manager | Non-manager → Drawer | Cash Transfer NOT visible | — | |
| 18.2 | Transfer cash | From account → To account → amount → submit | Cash moved | **Journal Entry**: `docstatus=1`. Account rows: CR `from_account` (source), DR `to_account` (destination). Amount matches input. `posting_date` correct | |
| 18.3 | Account list | Open cash transfer screen | Shows Cash, Bank, Mobile Wallet, POS Profile accounts | Account list: type in (Cash, Bank), name like "Mobile Wallet", POS Profile linked accounts | |
| 18.4 | Same account | Select same from and to | Error: from ≠ to required | — | |
| 18.5 | Zero/negative amount | Enter 0 or negative | Rejected | — | |
| 18.6 | With remark | Add remark to transfer | Remark saved on JE | **Journal Entry**: `user_remark` field contains the note | |

---

## 19. Manufacturing (Manager Only)

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 19.1 | Access — non-manager | Non-manager → Drawer | Manufacturing NOT visible | — | |
| 19.2 | View BOMs | Open Manufacturing | Items with default BOM listed, component stock shown | BOM list: filter `is_default=1`, `docstatus=1`. For each BOM, components are in BOM Item child table | |
| 19.3 | Submit work order | Select BOM → enter qty → Submit | WO + 2 Stock Entries created | **Work Order**: `docstatus=1`, `production_item`, `qty`, `bom_no`, `wip_warehouse`, `fg_warehouse`. **Stock Entry #1**: `stock_entry_type=Material Transfer for Manufacture`, items move from source → WIP warehouse. **Stock Entry #2**: `stock_entry_type=Manufacture`, finished goods move from WIP → FG warehouse. Stock Ledger: component qty decreased, FG qty increased | |
| 19.4 | Warehouse check | Submit WO → verify output location | Finished goods in FG warehouse | **Manufacturing Settings**: `default_fg_warehouse`. Or Warehouse with `warehouse_type=Finished Goods`. Check **Bin**: `item_code` + `warehouse` = FG warehouse, `actual_qty` increased | |
| 19.5 | Insufficient components | Submit WO when components out of stock | Error about insufficient stock | Bin: check component `actual_qty` < required qty | |
| 19.6 | Bulk submit | Select multiple items → Submit All | Multiple WOs created | Work Order list: multiple new WOs with today's date | |

---

## 20. Inventory Count (Manager Only)

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 20.1 | Access — non-manager | Non-manager → Drawer | Inventory Count NOT visible | — | |
| 20.2 | Count items | Select warehouse → enter counts → submit | Reconciliation created | **Stock Reconciliation**: `docstatus=1`, `purpose=Stock Reconciliation`. Items table: each row has `item_code`, `qty` (counted), `warehouse`, `valuation_rate`. **Stock Ledger Entry**: qty adjusted to match counted amount. **Bin**: `actual_qty` now equals counted qty | |
| 20.3 | Partial count | Count only some items | Only counted items reconciled | Stock Reconciliation items table: only counted items listed, others unchanged | |
| 20.4 | Negative count | Enter negative qty | Clamped to 0 | Stock Reconciliation: qty = 0 for that item | |
| 20.5 | Valuation rate | Submit count for item with no prior transactions | Valuation rate auto-resolved | Stock Reconciliation item: `valuation_rate` sourced from (in order): last SLE, `last_purchase_rate`, Item Price (buying), Item Price (selling) | |

---

## 21. Notifications & Real-Time Updates

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 21.1 | FCM registration | Open app → allow notifications | Device registered | **Jarz Mobile Device**: `token` (FCM token), `user`, `platform`, `device_name`, `enabled=1`, `pos_profiles` listed | |
| 21.2 | Push — new order | Submit order from device A | Push notification on device B (same POS profile) | — | |
| 21.3 | Push — state change | Move order to OFD | Notification sent to profile users | — | |
| 21.4 | Push — trip events | Create trip / send OFD / deliver | Notifications for TRIP_CREATED, TRIP_OFD, TRIP_COMPLETED | — | |
| 21.5 | Kanban polling | Leave kanban open → create order elsewhere | New card appears within ~30 seconds | — | |
| 21.6 | Mute — Manager | Manager → Profile → toggle Mute | Notifications muted | — | |
| 21.7 | Mute — Staff | Staff → Profile | Mute toggle NOT visible | — | |
| 21.8 | Invoice acceptance | New order → tap Accept on notification | Acceptance tracked | SI: `custom_acceptance_status=Accepted` | |

---

## 22. Localization & Territory Translations

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 22.1 | English UI | Profile → English | All text English, LTR layout | — | |
| 22.2 | Arabic UI | Profile → Arabic | All text Arabic, RTL layout | — | |
| 22.3 | Language persistence | Change language → close → reopen | Language retained | — | |
| 22.4 | Territory name — English | English mode → view order with territory | Shows English name (e.g., "6th of October") | Territory doc: `territory_name = "6th of October"` | |
| 22.5 | Territory name — Arabic | Arabic mode → view order with territory | Shows Arabic name (e.g., "السادس من أكتوبر") | Translation doc: `source_text="6th of October"`, `language=ar`, `translated_text="السادس من أكتوبر"` | |
| 22.6 | Sub-territory selector | Select sub-territory for order | Dropdown shows translated name but sends territory code (name field) | SI: `custom_sub_territory` = territory code (e.g., "EG6OCT"), NOT the display name | |
| 22.7 | Territory on kanban card | View kanban card with territory assigned | Shows `territory_display` / `sub_territory_display` (translated) | — | |
| 22.8 | Territory on trip detail | View trip detail screen | Territory shows translated name | — | |
| 22.9 | Arabic receipt | Arabic mode → print receipt | Arabic text correct | — | |
| 22.10 | Mixed content | Arabic UI + English item names | Both scripts render | — | |

---

## 23. Sales Partner Orders

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 23.1 | Create partner order | As sales partner → create order | Partner assigned, no delivery charge | **Sales Invoice**: `sales_partner` set, no delivery charge line item, `grand_total` = items only | |
| 23.2 | Partner OFD — unpaid | Move unpaid partner order to OFD | Auto cash PE + Sales Partner Transaction | **Payment Entry**: `payment_type=Receive`, full outstanding. **Sales Partner Transactions**: `sales_partner`, `reference_invoice`, `amount=grand_total`, `status=Unsettled`, idempotency token `SPTRN::{invoice_name}` | |
| 23.3 | Partner OFD — paid | Move paid partner order to OFD | Only state change + Sales Partner Transaction | **Sales Partner Transactions** created, Payment Entry NOT created (already paid) | |
| 23.4 | No duplicate SPTRN | Move same partner order to OFD twice | Only 1 Sales Partner Transaction | Sales Partner Transactions list: only 1 record for that invoice | |

---

## 24. Error Handling & Edge Cases

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 24.1 | Network disconnection | Disable network → try to create order | Error shown, no crash | — | |
| 24.2 | Slow network | Throttle → perform operations | Loading indicators, no silent timeouts | — | |
| 24.3 | Session expired mid-action | Let session expire → try to submit | Redirected to login | — | |
| 24.4 | Concurrent modification | Two users edit same order | Conflict handled, no data corruption | SI: check `modified` timestamp, only latest change persisted | |
| 24.5 | App backgrounded during checkout | Background during payment → return | Payment completes or shows clear status | Check PE list: either 1 PE exists or 0 (not a half-created one) | |
| 24.6 | Large order | 30+ line items | All items saved, receipt prints fully | SI: items table has all 30+ rows. SLE: one entry per item | |

---

## 25. Cross-Feature Integration Tests

| # | Scenario | Steps | Expected Result | Verify in Desk | Status |
|---|----------|-------|-----------------|----------------|--------|
| 25.1 | Full delivery flow (settle later) | Create order → customer → delivery slot → Settle Later → assign courier → create trip → Send OFD → Mark Delivered → Settle courier | All documents created | **Sales Invoice**: `is_pos=1`, `outstanding_amount` goes from `grand_total` → 0 after settlement. **Delivery Note**: `docstatus=1`. **Courier Transaction**: `status` goes `Unsettled` → `Settled`. **Payment Entry**: created on OFD (outstanding → courier). **Shipping JE**: DR Freight / CR Creditors. **Settlement JE**: DR Cash / CR Creditors. **Delivery Trip**: `status=Completed` | |
| 25.2 | Full delivery flow (paid) | Create order → pay cash → assign courier → trip → Send OFD → Deliver → Settle shipping | All documents, shipping only settled | **Sales Invoice**: `outstanding_amount=0` from start. **Payment Entry**: created at checkout. **Courier Transaction**: `amount=0`, `shipping_amount=X`. **Shipping JE**: DR Freight / CR Creditors. **Settlement JE**: shipping only | |
| 25.3 | Full pickup flow | Create order → pay cash → move Preparing → Ready → Delivered | No DN, no courier, no trip needed | **Sales Invoice**: `custom_pickup=1`, `status=Paid`. No Delivery Note. No Courier Transaction | |
| 25.4 | Shift lifecycle | Start shift → create orders → payments → end shift | Amounts match | **POS Opening Entry**: `docstatus=1`. All SIs and PEs linked to this shift. **POS Closing Entry**: `payment_reconciliation` matches actual PEs. Discrepancy JE only if amounts differ | |
| 25.5 | Expense approval flow | Staff creates expense → Manager approves | JE on approval | **Jarz Expense Request**: `docstatus=0` → `docstatus=1`. **Journal Entry**: DR `reason_account` / CR `paying_account` | |
| 25.6 | Stock lifecycle | Purchase Invoice (stock in) → POS sale (stock out) → verify | Stock balanced | **Bin**: `actual_qty` increased by PI, decreased by SI. **Stock Ledger Entry**: credit from PI, debit from SI | |
| 25.7 | Manufacturing lifecycle | Submit WO → verify stock | Components consumed, FG produced | **Bin** for component items: `actual_qty` decreased. **Bin** for FG item: `actual_qty` increased. Two Stock Entries (Material Transfer + Manufacture) | |
| 25.8 | Bundle end-to-end | Add bundle → checkout → print → kanban card | Bundle grouped at every stage | SI items: bundle components listed. Product Bundle doc matches. Receipt shows grouped items. Kanban card shows correct items | |
| 25.9 | Cancel & re-order | Create → Line Manager cancels → create same items | Both orders exist | **SI #1**: `docstatus=2`. **SI #2**: `docstatus=1`, in Preparing column | |
| 25.10 | Custom shipping flow | Create order → request custom shipping → manager approves → Send OFD | Custom rate applied | **Custom Shipping Request**: `status=Approved`. **Shipping JE**: amount = approved custom amount (not territory default) | |
| 25.11 | Payment receipt flow | Pay via Instapay → upload receipt photo → manager confirms | Receipt tracked | **POS Payment Receipt**: `Unconfirmed` → `Confirmed`. File attachment exists | |
| 25.12 | Territory translation flow | Create order with territory → view in English → switch to Arabic | Name changes per language | SI: `custom_sub_territory` stores CODE. Kanban card: `sub_territory_display` shows translated name | |

---

## Testing Environment Checklist

Before starting testing, ensure:

- [ ] Staging server running: `https://erpstg.orderjarz.com` accessible
- [ ] At least 2 test users: one Manager (has `Jarz Manager` role), one Staff
- [ ] At least 1 Line Manager user (has `Jarz Line Manager` role)
- [ ] POS Profiles created and linked to test users (check POS Profile → User table)
- [ ] Items and bundles available with stock (check Bin for `actual_qty > 0`)
- [ ] Product Bundles configured (at least one with `free_shipping=1`)
- [ ] Thermal printer available (Bluetooth) for receipt tests
- [ ] Two Android devices for multi-device notification tests
- [ ] Delivery partners configured: at least 1 Employee + 1 Supplier in "Delivery" group
- [ ] Territories configured with English names + Arabic translations (check Translation list)
- [ ] At least 1 territory with children (for sub-territory selection tests)
- [ ] BOM configured with `is_default=1` for at least 1 item (manufacturing tests)
- [ ] Manufacturing Settings: `default_wip_warehouse` and `default_fg_warehouse` set
- [ ] Jarz POS Settings configured: `cash_over_short_account` set
- [ ] At least 1 Sales Partner user configured
- [ ] Delivery slots configured in territory timetable
- [ ] FCM service account configured in `site_config.json`

---

## Quick Desk Navigation Reference

| Document | Desk Path |
|----------|-----------|
| Sales Invoice | Accounts → Sales Invoice |
| Payment Entry | Accounts → Payment Entry |
| Journal Entry | Accounts → Journal Entry |
| Delivery Note | Stock → Delivery Note |
| Delivery Trip | Stock → Delivery Trip |
| Stock Entry | Stock → Stock Entry |
| Stock Ledger Entry | Stock → Stock Ledger Entry |
| Stock Reconciliation | Stock → Stock Reconciliation |
| Work Order | Manufacturing → Work Order |
| Purchase Invoice | Accounts → Purchase Invoice |
| POS Opening Entry | Accounts → POS Opening Entry |
| POS Closing Entry | Accounts → POS Closing Entry |
| Customer | Selling → Customer |
| Address | Home → Address |
| Contact | Home → Contact |
| Territory | Setup → Territory |
| Translation | Home → Translation |
| Courier Transaction | (Custom) Search: Courier Transaction |
| Jarz Expense Request | (Custom) Search: Jarz Expense Request |
| Custom Shipping Request | (Custom) Search: Custom Shipping Request |
| Sales Partner Transactions | (Custom) Search: Sales Partner Transactions |
| POS Payment Receipt | (Custom) Search: POS Payment Receipt |
| Jarz Mobile Device | (Custom) Search: Jarz Mobile Device |
| Bin (stock qty) | Stock → Bin |
| GL Entry (accounting) | Accounts → GL Entry |
