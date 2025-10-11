# Jarz POS Mobile - Flow Diagrams Quick Reference

## Overview

This document provides consolidated visual diagrams for the Jarz POS Mobile application flows. For detailed documentation, see:
- [POS Flow Documentation](POS_FLOW_DOCUMENTATION.md)
- [Kanban Flow Documentation](KANBAN_FLOW_DOCUMENTATION.md)

---

## Complete System Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     JARZ POS MOBILE - COMPLETE SYSTEM                       │
└─────────────────────────────────────────────────────────────────────────────┘

                            ┌──────────────┐
                            │   User       │
                            │   Login      │
                            └──────┬───────┘
                                   │
                        ┌──────────▼──────────┐
                        │  Select POS Profile │
                        │  (Branch/Location)  │
                        └──────────┬──────────┘
                                   │
                ┌──────────────────┴──────────────────┐
                │                                     │
        ┌───────▼─────────┐              ┌───────────▼──────────┐
        │   POS SCREEN    │              │   KANBAN BOARD       │
        │                 │              │                      │
        │ • Select        │◄────────────►│ • Track Orders       │
        │   Customer      │              │ • Update States      │
        │ • Build Cart    │  Navigation  │ • Assign Couriers    │
        │ • Checkout      │              │ • Process Payments   │
        │                 │              │ • Settlement         │
        └───────┬─────────┘              └───────────┬──────────┘
                │                                    │
                │ Creates Invoice                    │ Manages Invoice
                ▼                                    ▼
        ┌───────────────┐                   ┌────────────────┐
        │  Sales Invoice│─────────────────► │  Order         │
        │  (Unpaid/Paid)│   Appears in      │  Fulfillment   │
        │               │   Kanban          │                │
        └───────────────┘                   └────────────────┘
```

---

## POS Flow Summary

```
┌─────────────────────────────────────────────────────────────────────┐
│                         POS WORKFLOW                                │
└─────────────────────────────────────────────────────────────────────┘

    STEP 1              STEP 2              STEP 3            STEP 4
 ┌──────────┐       ┌──────────┐       ┌──────────┐       ┌──────────┐
 │ Customer │       │ Delivery │       │   Cart   │       │ Checkout │
 │ Selection│──────►│   Mode   │──────►│Management│──────►│ Payment  │
 └──────────┘       └──────────┘       └──────────┘       └──────────┘
      │                   │                  │                  │
      ▼                   ▼                  ▼                  ▼
 • Search/          • Delivery         • Add Items       • Payment Type
   Create           • Pickup           • Add Bundles     • Create Invoice
 • Territory        • Sales            • Adjust Qty      • Print Receipt
 • Auto-calc          Partner          • Calculate       • Navigate to
   Delivery Fee                          Total             Kanban

OPTIONS:
├─ Customer: New (create) | Existing (search)
├─ Delivery Mode: 
│  ├─ Delivery (with slot & fee)
│  ├─ Pickup (no fee, no slot)
│  └─ Sales Partner (no fee, partner handles)
├─ Cart:
│  ├─ Regular Items
│  ├─ Bundles (may have free shipping)
│  └─ Delivery Fee (conditional)
└─ Payment: Cash | Online (advisory flag)
```

---

## Kanban Flow Summary

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         KANBAN WORKFLOW                                     │
└─────────────────────────────────────────────────────────────────────────────┘

COLUMN 1         COLUMN 2         COLUMN 3         COLUMN 4         COLUMN 5
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ RECEIVED │───►│PROCESSING│───►│  READY   │───►│   OFD    │───►│DELIVERED │
└──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘
     │               │               │               │               │
     ▼               ▼               ▼               ▼               ▼
 Initial         Preparing      Ready for      In Transit        Complete
  State           Order          Delivery

DRAG & DROP ACTIONS:
├─ Any State → Any State (flexible)
├─ Most Common: Sequential (Received → Processing → Ready → OFD → Delivered)
└─ Special: Direct transitions for Pickup/Fast-track

OFD TRANSITION (Most Complex):
├─ Courier Assignment Required
├─ Payment Processing (if unpaid)
├─ Settlement Decision:
│  ├─ Pay Now (immediate settlement)
│  └─ Pay Later (deferred settlement)
└─ Creates: Delivery Note, Payment Entry, Settlement Entry
```

---

## Invoice Scenarios Quick Reference

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    6 INVOICE SCENARIOS SUMMARY                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ 1️⃣  PAID + SETTLE NOW                                                       │
│    Invoice: Already Paid | Courier: Assigned | Settlement: Immediate       │
│    Flow: Received → OFD (dialog) → Select Courier → Pay Now               │
│    Result: Branch pays courier delivery fee immediately                    │
│    API: settleSingleInvoicePaid                                            │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ 2️⃣  PAID + SETTLE LATER                                                     │
│    Invoice: Already Paid | Courier: Assigned | Settlement: Deferred        │
│    Flow: Received → OFD (dialog) → Select Courier → Pay Later             │
│    Result: Courier transaction created, settle later in bulk               │
│    API: handleOutForDeliveryTransition (mode: later)                       │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ 3️⃣  UNPAID + SETTLE NOW (COD)                                               │
│    Invoice: Unpaid | Courier: Collects COD | Settlement: Immediate         │
│    Flow: Received → OFD (dialog) → Courier + Payment Mode → Pay Now       │
│    Result: Payment entry created, courier pays net to branch               │
│    API: settleCourierCollectedPayment                                      │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ 4️⃣  UNPAID + SETTLE LATER (COD)                                             │
│    Invoice: Unpaid | Courier: Collects COD | Settlement: Deferred          │
│    Flow: Received → OFD (dialog) → Courier + Payment Mode → Pay Later     │
│    Result: Payment entry created, settlement deferred                      │
│    API: handleOutForDeliveryTransition (mode: later)                       │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ 5️⃣  SALES PARTNER                                                           │
│    Invoice: Paid/Unpaid | Partner: Handles Delivery | No Courier           │
│    Flow: Received → OFD (fast-path) → Auto-process                         │
│    Result: No courier settlement, partner handles everything                │
│    API: salesPartnerPaidOutForDelivery OR salesPartnerUnpaidOutForDelivery │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ 6️⃣  PICKUP ORDER                                                            │
│    Invoice: Any Status | Customer: Self Pickup | No Courier                │
│    Flow: Received → Any State (direct) → No dialog needed                 │
│    Result: Simple state update, no courier/settlement                      │
│    API: updateInvoiceState                                                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Settlement Decision Tree

```
                          ┌─────────────┐
                          │   Invoice   │
                          │   in OFD    │
                          └──────┬──────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
              ┌─────▼──────┐           ┌─────▼──────┐
              │  Special   │           │  Regular   │
              │   Cases?   │           │  Invoice   │
              └─────┬──────┘           └─────┬──────┘
                    │                         │
        ┌───────────┴───────────┐             │
        │                       │             │
   ┌────▼────┐            ┌────▼─────┐       │
   │ Pickup? │            │Partner?  │       │
   └────┬────┘            └────┬─────┘       │
        │                      │             │
       YES                    YES            │
        │                      │             │
   ┌────▼────────┐      ┌─────▼──────┐      │
   │ No Courier  │      │ No Courier │      │
   │ Settlement  │      │ Settlement │      │
   └─────────────┘      └────────────┘      │
                                             │
                                    ┌────────▼────────┐
                                    │ Get Settlement  │
                                    │    Preview      │
                                    └────────┬────────┘
                                             │
                            ┌────────────────┴────────────────┐
                            │                                 │
                       ┌────▼────┐                       ┌────▼────┐
                       │  Paid   │                       │ Unpaid  │
                       │Invoice? │                       │Invoice? │
                       └────┬────┘                       └────┬────┘
                            │                                 │
                ┌───────────┴──────────┐          ┌───────────┴──────────┐
                │                      │          │                      │
          ┌─────▼─────┐          ┌─────▼─────┐  ┌─▼────────┐   ┌────────▼──┐
          │ Pay Now   │          │Pay Later  │  │ Pay Now  │   │Pay Later  │
          └─────┬─────┘          └─────┬─────┘  └─────┬────┘   └────┬──────┘
                │                      │              │             │
         ┌──────▼──────┐        ┌──────▼──────┐  ┌────▼─────┐ ┌────▼──────┐
         │ Settle      │        │ Create      │  │ Payment  │ │ Payment + │
         │ Single      │        │ Courier     │  │ Entry +  │ │ Courier   │
         │ Invoice     │        │ Transaction │  │ Settle   │ │ Txn       │
         │ Paid API    │        │ (Deferred)  │  │ Courier  │ │(Deferred) │
         └─────────────┘        └─────────────┘  │ Payment  │ └───────────┘
                                                 │ API      │
                                                 └──────────┘

LEGEND:
├─ Special Cases: Pickup, Sales Partner (bypass standard settlement)
├─ Regular: Standard courier-based delivery with settlement
├─ Paid: Invoice already paid, branch owes courier delivery fee
├─ Unpaid: COD invoice, courier collects and owes branch net amount
├─ Pay Now: Immediate settlement via Payment Entry
└─ Pay Later: Deferred settlement via Courier Transaction record
```

---

## Payment & Settlement Matrix

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PAYMENT & SETTLEMENT MATRIX                              │
└─────────────────────────────────────────────────────────────────────────────┘

INVOICE STATUS    SETTLEMENT MODE    PAYMENT ENTRY           SETTLEMENT ENTRY
─────────────────────────────────────────────────────────────────────────────
PAID              Pay Now            None (already paid)     Branch → Courier
                                                             (delivery_income)

PAID              Pay Later          None (already paid)     Deferred
                                                             (Courier Txn)

UNPAID (COD)      Pay Now            Customer → Branch       Courier → Branch
                                    (full outstanding)      (net_amount)

UNPAID (COD)      Pay Later          Customer → Branch       Deferred
                                    (full outstanding)      (Courier Txn)

SALES PARTNER     N/A                Auto Cash Entry         None
(Unpaid)                            (Customer → Branch)      (No Courier)

SALES PARTNER     N/NET               None (already paid)     None
(Paid)                                                       (No Courier)

PICKUP            N/A                None or Standard        None
                                                             (No Courier)

SETTLEMENT FORMULAS:
├─ net_amount = outstanding - delivery_income
├─ If net_amount > 0: Courier owes Branch (settleCourierCollectedPayment)
├─ If net_amount < 0: Branch owes Courier (settleSingleInvoicePaid)
└─ If net_amount = 0: No settlement needed (rare edge case)
```

---

## State Transitions Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      INVOICE STATE TRANSITIONS                              │
└─────────────────────────────────────────────────────────────────────────────┘

                            ┌──────────────┐
                            │   RECEIVED   │ ◄── Invoice Created (Initial)
                            └──────┬───────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
                    ▼              ▼              ▼
            ┌───────────┐   ┌──────────┐   ┌──────────┐
            │PROCESSING │   │  READY   │   │   OFD    │
            └─────┬─────┘   └────┬─────┘   └────┬─────┘
                  │              │              │
                  ▼              ▼              ▼
            ┌─────────────────────────────────────────┐
            │           Any State → Any State         │
            │        (Flexible Drag & Drop)           │
            └─────────────────┬───────────────────────┘
                              │
                              ▼
                        ┌──────────┐
                        │DELIVERED │ ◄── Final State
                        └──────────┘

SPECIAL TRANSITIONS:
├─ Received → OFD (Direct, with courier dialog)
├─ Received → Ready (Pickup orders, direct)
├─ Ready → Delivered (Pickup orders, final)
├─ Any → Any (Manual correction via drag)
└─ OFD → Delivered (Completion)

TRANSITION TRIGGERS:
├─ Manual: User drag & drop on Kanban board
├─ Automatic: Payment completion, delivery confirmation
├─ Real-time: WebSocket events from other users
└─ Batch: Bulk state updates (future enhancement)
```

---

## Filtering & Search Options

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     KANBAN BOARD FILTERS                                    │
└─────────────────────────────────────────────────────────────────────────────┘

FILTER TYPE          OPTIONS                  USAGE
─────────────────────────────────────────────────────────────────────────────
📍 Branch Filter     Multi-select dropdown    Filter by POS profile/branch
                    • Branch A                Show only selected branches
                    • Branch B
                    • Branch C

📅 Date Range        From/To Date Picker      Filter by invoice date
                    • From: 2024-01-01        Inclusive range
                    • To: 2024-01-31

👤 Customer Filter   Dropdown + Search        Filter by specific customer
                    • Search: Name/Code       Shows invoices for customer
                    • Select from list

💰 Status Filter     Dropdown                 Filter by payment status
                    • Paid                    Invoice payment state
                    • Unpaid
                    • Partially Paid
                    • Overdue

💵 Amount Range      Min/Max Input            Filter by invoice total
                    • From: 0.00              Inclusive range
                    • To: 1000.00

🔍 Search            Text Input               Search in invoice/customer
                    • Invoice #               Real-time search
                    • Customer Name

FILTER COMBINATIONS:
├─ Multiple filters can be applied simultaneously
├─ Filters are AND-combined (all conditions must match)
├─ Clear All button to reset all filters
└─ Filters persisted in local storage
```

---

## API Endpoints Quick Reference

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         API ENDPOINTS                                       │
└─────────────────────────────────────────────────────────────────────────────┘

POS APIs:
├─ POST /api/method/jarz_pos.api.pos.get_pos_profiles
├─ POST /api/method/jarz_pos.api.pos.get_profile_products
├─ POST /api/method/jarz_pos.api.pos.get_profile_bundles
├─ POST /api/method/jarz_pos.api.customer.search_customers
├─ POST /api/method/jarz_pos.api.customer.create_customer
├─ POST /api/method/jarz_pos.api.pos.get_sales_partners
└─ POST /api/method/jarz_pos.api.invoices.create_pos_invoice

KANBAN APIs:
├─ GET  /api/method/jarz_pos.api.kanban.get_kanban_columns
├─ POST /api/method/jarz_pos.api.kanban.get_kanban_invoices
├─ POST /api/method/jarz_pos.api.kanban.update_invoice_state
├─ GET  /api/method/jarz_pos.api.kanban.get_invoice_details
└─ GET  /api/method/jarz_pos.api.kanban.get_kanban_filters

SETTLEMENT APIs:
├─ GET  /api/method/jarz_pos.api.invoices.get_invoice_settlement_preview
├─ POST /api/method/jarz_pos.api.invoices.handle_out_for_delivery_transition
├─ POST /api/method/jarz_pos.api.invoices.settle_courier_collected_payment
├─ POST /api/method/jarz_pos.api.invoices.settle_single_invoice_paid
├─ POST /api/method/jarz_pos.api.invoices.sales_partner_paid_out_for_delivery
└─ POST /api/method/jarz_pos.api.invoices.sales_partner_unpaid_out_for_delivery

WEBSOCKET:
└─ ws://backend-server/kanban/updates (Real-time state changes)
```

---

## Technology Stack

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       TECHNOLOGY STACK                                      │
└─────────────────────────────────────────────────────────────────────────────┘

FRONTEND (Flutter):
├─ Framework: Flutter 3.8.1+
├─ Language: Dart 3.8.1+
├─ State Management: Riverpod 2.5.1+
├─ Navigation: GoRouter 16.2.0+
├─ HTTP Client: Dio 5.9.0+
├─ Local Storage: Hive 2.2.3+
├─ Code Generation: Freezed, JSON Serializable
└─ Real-time: WebSocket, Socket.IO Client

BACKEND (ERPNext):
├─ Framework: Frappe/ERPNext
├─ Language: Python
├─ Database: PostgreSQL/MariaDB
├─ API: RESTful JSON APIs
├─ Real-time: Frappe SocketIO
├─ Authentication: Cookie-based sessions
└─ Custom App: jarz_pos

INFRASTRUCTURE:
├─ Platform: Android, iOS, Desktop
├─ Deployment: APK/IPA distribution
├─ Network: WiFi/Cellular
└─ Offline: Hive + Queue System
```

---

## Key Concepts

### Delivery Fee Logic
```
delivery_fee = 0

IF sales_partner_selected:
    delivery_fee = 0  # Sales partner handles delivery

ELSE IF pickup_mode:
    delivery_fee = 0  # Customer picks up

ELSE IF bundle_has_free_shipping:
    delivery_fee = 0  # Bundle promotion

ELSE IF customer_has_territory:
    delivery_fee = customer.territory.delivery_income

ELSE:
    delivery_fee = 0  # Default
```

### Settlement Net Amount Calculation
```
net_amount = outstanding_amount - delivery_income

IF net_amount > 0:
    # Courier owes Branch (collected more than delivery fee)
    settlement_direction = "courier_to_branch"
    settlement_amount = net_amount

ELSE IF net_amount < 0:
    # Branch owes Courier (only delivery fee, invoice paid)
    settlement_direction = "branch_to_courier"
    settlement_amount = abs(net_amount)

ELSE:
    # No settlement needed (rare: outstanding equals delivery income)
    settlement_direction = "none"
```

### Idempotency
```
All critical operations use UUID-based idempotency tokens:
├─ Out for Delivery transitions
├─ Payment entries
├─ Settlement entries
└─ Delivery note creation

Purpose: Prevent duplicate processing on network retries
```

---

## Common Workflows

### Workflow 1: Regular Delivery Order (Paid)
1. Create invoice in POS (customer pays immediately)
2. Invoice appears in Kanban "Received" column
3. Drag to "Processing" → prepare order
4. Drag to "Ready" → order ready
5. Drag to "Out for Delivery" → courier dialog appears
6. Select courier, click "Pay Now" (settle immediately)
7. System creates: Delivery Note + Settlement Entry
8. Invoice moves to "OFD" column
9. Drag to "Delivered" when complete

### Workflow 2: COD Order (Unpaid)
1. Create invoice in POS (customer will pay on delivery)
2. Invoice appears in Kanban "Received" column (unpaid)
3. Drag to "Out for Delivery" → courier dialog appears
4. Select courier + payment mode (cash/wallet)
5. Choose "Pay Now" or "Pay Later"
6. System creates: Payment Entry + Delivery Note + Settlement
7. Invoice moves to "OFD" column (now marked paid)
8. Drag to "Delivered" when complete

### Workflow 3: Sales Partner Order
1. Create invoice in POS with sales partner selected
2. Invoice appears in Kanban "Received" column
3. Drag to "Out for Delivery" → fast-path dialog
4. Click "Send to Partner" (one-click)
5. System creates: Delivery Note (no courier settlement)
6. Invoice moves to "OFD" column
7. Partner handles delivery independently

### Workflow 4: Pickup Order
1. Create invoice in POS with pickup mode enabled
2. Invoice appears in Kanban "Received" column
3. Drag directly to "Ready for Pickup" (skip processing)
4. No courier dialog, just state update
5. Customer arrives, drag to "Picked Up"
6. Order complete (no courier, no delivery)

---

## Troubleshooting Guide

### Issue: Invoice Not Appearing in Kanban
**Solution**: Check branch filter, ensure profile matches invoice

### Issue: Cannot Drag to OFD
**Solution**: Ensure invoice is submitted, not in draft state

### Issue: Settlement Amount Incorrect
**Solution**: Verify delivery_income and outstanding_amount values

### Issue: Real-time Updates Not Working
**Solution**: Check WebSocket connection, verify network connectivity

### Issue: Duplicate Payment Entry
**Solution**: Idempotency token prevents this, check backend logs

### Issue: Pickup Order Shows Delivery Fee
**Solution**: Ensure pickup flag set in POS, check cart calculation

---

## Related Documentation

📚 **Detailed Documentation**:
- [POS Flow Documentation](POS_FLOW_DOCUMENTATION.md) - Complete POS workflow
- [Kanban Flow Documentation](KANBAN_FLOW_DOCUMENTATION.md) - Complete Kanban workflow
- [Invoice Scenarios Visual Map](test/INVOICE_SCENARIOS_VISUAL_MAP.md) - Test coverage diagrams
- [Business Documentation](BUSINESS_DOCUMENTATION.md) - Business rules

🧪 **Testing**:
- [Test Documentation](test/TEST_DOCUMENTATION.md) - Test suite overview
- [Invoice Scenarios Test Coverage](test/INVOICE_SCENARIOS_TEST_COVERAGE.md) - Scenario tests

🛠️ **Setup**:
- [Environment Setup](ENVIRONMENT_SETUP.md) - Configuration guide
- [User Manual](USER_MANUAL.md) - End-user guide

---

**Last Updated**: 2024-01-15  
**Version**: 1.0  
**Status**: Quick Reference Guide
