# Kanban Flow Documentation

## Table of Contents
1. [Overview](#overview)
2. [Complete Kanban Flow Diagram](#complete-kanban-flow-diagram)
3. [Invoice States](#invoice-states)
4. [State Transition Rules](#state-transition-rules)
5. [Six Invoice Scenarios](#six-invoice-scenarios)
6. [Settlement Flows](#settlement-flows)
7. [Special Cases](#special-cases)
8. [Real-Time Updates](#real-time-updates)
9. [Filtering & Search](#filtering--search)
10. [API Integration](#api-integration)

---

## Overview

The Kanban Board provides a visual interface for managing Sales Invoice states and tracking order fulfillment. It supports drag-and-drop state transitions, real-time updates, courier assignment, payment processing, and settlement reconciliation.

### Key Features
- 📋 **Visual Order Tracking**: Drag-and-drop Kanban board interface
- 🔄 **Real-Time Updates**: WebSocket-based live state changes
- 💰 **Payment Processing**: Handle COD and online payments
- 🚚 **Courier Management**: Assign deliveries and track settlements
- 💼 **Settlement Reconciliation**: Automatic settlement calculations
- 🔍 **Advanced Filtering**: Filter by date, customer, amount, branch
- 🤝 **Sales Partner Support**: Special handling for partner transactions
- 📦 **Pickup Orders**: Direct state transitions without courier

---

## Complete Kanban Flow Diagram

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                    KANBAN BOARD - COMPLETE FLOW                              │
└──────────────────────────────────────────────────────────────────────────────┘

                         ┌────────────────────┐
                         │  Invoice Created   │
                         │  (From POS)        │
                         └─────────┬──────────┘
                                   │
                         ┌─────────▼──────────┐
                         │  RECEIVED State    │
                         │  (Initial)         │
                         └─────────┬──────────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        │                          │                          │
   ┌────▼─────┐             ┌──────▼──────┐           ┌──────▼──────┐
   │  Pickup  │             │   Regular   │           │    Sales    │
   │  Order?  │             │   Order     │           │   Partner?  │
   └────┬─────┘             └──────┬──────┘           └──────┬──────┘
        │                          │                          │
       YES                         │                         YES
        │                          │                          │
        │                  ┌───────┴────────┐                 │
        │                  │                │                 │
        │            ┌─────▼─────┐    ┌─────▼─────┐          │
        │            │   Paid?   │    │  Unpaid?  │          │
        │            └─────┬─────┘    └─────┬─────┘          │
        │                  │                │                 │
┌───────▼────────┐         │                │        ┌────────▼────────┐
│  PROCESSING    │         │                │        │  Sales Partner  │
│                │         │                │        │  Fast-Path      │
│  Direct State  │         │                │        │                 │
│  Transitions   │         │                │        │  (Auto Payment  │
│                │         │                │        │   if unpaid +   │
│  No Courier    │         │                │        │   DN creation)  │
│  Involved      │         │                │        └────────┬────────┘
└───────┬────────┘         │                │                 │
        │                  │                │                 │
        │                  │                │                 │
        │          ┌───────▼────────────────▼─────┐          │
        │          │  Drag to "Out for Delivery"  │          │
        │          │  Column (OFD Transition)     │          │
        │          └───────┬──────────────────────┘          │
        │                  │                                 │
        │          ┌───────▼────────────────────────────┐    │
        │          │    Courier Assignment Dialog       │    │
        │          │  • Select Courier                  │    │
        │          │  • Select Payment Mode (if unpaid) │    │
        │          │  • Settlement Options:             │    │
        │          │    - Pay Now (immediate)           │    │
        │          │    - Pay Later (deferred)          │    │
        │          └───────┬────────────────────────────┘    │
        │                  │                                 │
        │          ┌───────┴────────┐                        │
        │          │                │                        │
        │    ┌─────▼──────┐   ┌─────▼──────┐                │
        │    │  Pay Now   │   │ Pay Later  │                │
        │    │   Mode     │   │    Mode    │                │
        │    └─────┬──────┘   └─────┬──────┘                │
        │          │                │                        │
        │          │                │                        │
┌───────▼──────────▼────────────────▼────────────────────────▼────────┐
│                    OUT FOR DELIVERY State                           │
│                                                                     │
│  Actions Performed:                                                 │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ 1. Delivery Note (DN) Created                               │   │
│  │ 2. Payment Entry Created (if unpaid invoice)                │   │
│  │ 3. Courier Transaction Created (settlement record)          │   │
│  │    • Pay Now: Settlement executed immediately               │   │
│  │    • Pay Later: Deferred settlement (transaction marked)    │   │
│  │ 4. Invoice State Updated                                    │   │
│  │ 5. Real-time Broadcast to All Users                         │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
                          ┌───────▼────────┐
                          │   DELIVERED    │
                          │     State      │
                          │                │
                          │  (Final State) │
                          └────────────────┘


┌──────────────────────────────────────────────────────────────────────────────┐
│                        SETTLEMENT FLOW DETAILS                               │
└──────────────────────────────────────────────────────────────────────────────┘

                          ┌─────────────────┐
                          │  OFD Transition │
                          │  with Pay Now   │
                          └────────┬────────┘
                                   │
                          ┌────────▼────────────────┐
                          │  Get Settlement Preview │
                          │  API Call               │
                          └────────┬────────────────┘
                                   │
                          ┌────────▼────────────────────────────┐
                          │  Calculate Net Amount:              │
                          │  net_amount = outstanding -         │
                          │               delivery_income       │
                          └────────┬────────────────────────────┘
                                   │
                     ┌─────────────┴─────────────┐
                     │                           │
              ┌──────▼──────┐             ┌──────▼──────┐
              │ net_amount  │             │ net_amount  │
              │    > 0?     │             │    < 0?     │
              │             │             │             │
              │ (Courier    │             │ (Branch     │
              │  Collected) │             │  Owes)      │
              └──────┬──────┘             └──────┬──────┘
                     │                           │
         ┌───────────▼────────────┐  ┌───────────▼────────────┐
         │ settleCourier          │  │ settleSingleInvoice    │
         │ CollectedPayment       │  │ Paid                   │
         │                        │  │                        │
         │ Courier pays Branch    │  │ Branch pays Courier    │
         │ (Payment Entry:        │  │ (Payment Entry:        │
         │  Paid From: Courier    │  │  Paid To: Courier      │
         │  Paid To: Branch)      │  │  Paid From: Branch)    │
         └────────────────────────┘  └────────────────────────┘


┌──────────────────────────────────────────────────────────────────────────────┐
│                     PAY LATER (DEFERRED SETTLEMENT)                          │
└──────────────────────────────────────────────────────────────────────────────┘

                          ┌─────────────────┐
                          │  OFD Transition │
                          │  with Pay Later │
                          └────────┬────────┘
                                   │
                          ┌────────▼────────────────┐
                          │ Create Courier          │
                          │ Transaction Record      │
                          │                         │
                          │ Status: 'Pending'       │
                          │ Amount: delivery_income │
                          │ Courier: assigned       │
                          └────────┬────────────────┘
                                   │
                          ┌────────▼────────────────┐
                          │ Settlement Deferred     │
                          │                         │
                          │ User can settle later:  │
                          │ • View balances         │
                          │ • Settle individually   │
                          │ • Bulk settlement       │
                          └─────────────────────────┘
```

---

## Invoice States

The Kanban board organizes invoices into visual columns representing different states:

### State Definitions

| State | Description | Color | Actions Available |
|-------|-------------|-------|-------------------|
| **Received** | Initial state after invoice creation from POS | Blue | Drag to Processing/OFD |
| **Processing** | Order being prepared | Orange | Drag to Ready/OFD |
| **Ready** | Order ready for delivery/pickup | Green | Drag to OFD/Delivered |
| **Out for Delivery** | Assigned to courier, in transit | Purple | Drag to Delivered |
| **Delivered** | Order completed | Gray | View/Archive |

### State Progression

**Standard Flow**:
```
Received → Processing → Ready → Out for Delivery → Delivered
```

**Fast-Track Options**:
```
Received → Out for Delivery → Delivered (Skip preparation)
Received → Ready → Delivered (Pickup orders)
```

---

## State Transition Rules

### 1. Manual Transitions (Drag & Drop)

**Allowed Transitions**:
- Any state → Any other state (flexible workflow)
- Most common: Sequential progression
- Supports back-transitions for corrections

**Transition Validation**:
```dart
// Basic validation
if (invoice.status == 'Draft') {
  // Cannot transition draft invoices
  return error('Submit invoice first');
}

if (invoice.docstatus != 1) {
  // Must be submitted
  return error('Invoice must be submitted');
}
```

### 2. Automatic Transitions

**Trigger Events**:
- Payment completion (Unpaid → Paid status change)
- Delivery confirmation (OFD → Delivered)
- Courier updates (via WebSocket)

**WebSocket Events**:
```dart
// Real-time state change event
{
  'event': 'kanban_state_changed',
  'invoice': 'INV-2024-001',
  'old_state': 'Processing',
  'new_state': 'Ready',
  'updated_by': 'user@example.com'
}
```

### 3. Restricted Transitions

**Special Validation**:

1. **Out for Delivery Transition**
   - Requires courier assignment
   - Payment entry for unpaid invoices
   - Settlement decision (now/later)

2. **Delivered Transition**
   - From OFD state only (typically)
   - Marks order complete
   - Triggers final settlement (if pending)

---

## Six Invoice Scenarios

### Scenario 1: Paid Invoice + Settle Now

**Flow**:
```
1. Invoice created from POS (already paid)
2. Invoice appears in "Received" column
3. User drags to "Out for Delivery"
4. Courier Assignment Dialog:
   - Select courier
   - Settlement Preview shown:
     * Outstanding: 0.00 (already paid)
     * Delivery Income: 5.00
     * Net Amount: -5.00 (branch owes courier)
   - "Pay Now" selected
5. System Actions:
   - Creates Delivery Note
   - Calls settleSingleInvoicePaid API
   - Creates Payment Entry (Branch → Courier)
   - Updates invoice state to OFD
   - Broadcasts real-time update
6. Invoice moves to "Out for Delivery" column
```

**Settlement Logic**:
```dart
// API: settleSingleInvoicePaid
// When: Paid invoice, immediate settlement
// Net Amount = outstanding - delivery_income = 0 - 5 = -5
// Negative = Branch pays Courier
// Payment Entry: From Branch Account → To Courier Account
```

**Key Points**:
- Invoice already paid (outstanding = 0)
- Delivery income owed to courier
- Immediate payment to courier
- Single transaction completion

---

### Scenario 2: Paid Invoice + Settle Later

**Flow**:
```
1. Invoice created from POS (already paid)
2. Invoice appears in "Received" column
3. User drags to "Out for Delivery"
4. Courier Assignment Dialog:
   - Select courier
   - "Pay Later" selected
5. System Actions:
   - Creates Delivery Note
   - Creates Courier Transaction (status: Pending)
   - Records delivery_income amount
   - Updates invoice state to OFD
   - No immediate payment entry
6. Invoice moves to "Out for Delivery" column
7. Later Settlement:
   - View courier balances
   - Settle individually or in bulk
   - Payment entry created on demand
```

**Deferred Transaction**:
```dart
// Courier Transaction Record:
{
  'courier': 'COURIER-001',
  'invoice': 'INV-2024-001',
  'amount': 5.00,
  'status': 'Pending',
  'type': 'Delivery Income'
}
```

**Key Points**:
- Settlement postponed
- Courier transaction tracked
- Bulk settlement available
- Flexibility for cash flow management

---

### Scenario 3: Unpaid Invoice + Settle Now (COD)

**Flow**:
```
1. Invoice created from POS (unpaid, COD)
2. Invoice appears in "Received" column
3. User drags to "Out for Delivery"
4. Courier Assignment Dialog:
   - Select courier
   - Select payment mode (Cash/Wallet/InstaPay)
   - Settlement Preview shown:
     * Outstanding: 25.00 (unpaid invoice)
     * Delivery Income: 5.00
     * Net Amount: 20.00 (courier owes branch)
   - "Pay Now" selected
5. System Actions:
   - Creates Payment Entry (Customer → Branch via Courier)
   - Creates Delivery Note
   - Calls settleCourierCollectedPayment API
   - Creates Settlement Entry (Courier → Branch for net)
   - Updates invoice state to OFD
   - Marks invoice as Paid
   - Broadcasts real-time update
6. Invoice moves to "Out for Delivery" column
```

**Settlement Logic**:
```dart
// Step 1: Payment Entry (Customer pays)
// Amount: 25.00 (full outstanding)
// From: Customer Account
// To: Branch Account (via Courier)

// Step 2: Settlement Entry (Courier pays net to branch)
// API: settleCourierCollectedPayment
// Net Amount = outstanding - delivery_income = 25 - 5 = 20
// Positive = Courier owes Branch
// Payment Entry: From Courier Account → To Branch Account
// Amount: 20.00
```

**Key Points**:
- COD payment collected by courier
- Courier keeps delivery income
- Courier pays net amount to branch
- Immediate settlement and reconciliation

---

### Scenario 4: Unpaid Invoice + Settle Later (COD)

**Flow**:
```
1. Invoice created from POS (unpaid, COD)
2. Invoice appears in "Received" column
3. User drags to "Out for Delivery"
4. Courier Assignment Dialog:
   - Select courier
   - Select payment mode (Cash/Wallet/InstaPay)
   - "Pay Later" selected
5. System Actions:
   - Creates Payment Entry (Customer → Branch via Courier)
   - Creates Delivery Note
   - Creates Courier Transaction (status: Pending)
   - Records delivery_income amount
   - Updates invoice state to OFD
   - Marks invoice as Paid
   - No immediate settlement
6. Invoice moves to "Out for Delivery" column
7. Later Settlement:
   - Courier transaction shows outstanding delivery income
   - Settle when convenient
   - Payment entry created on settlement
```

**Deferred Transaction**:
```dart
// Courier Transaction Record:
{
  'courier': 'COURIER-001',
  'invoice': 'INV-2024-001',
  'payment_amount': 25.00,  // COD collected
  'delivery_income': 5.00,   // Courier's earning
  'net_due': 20.00,          // Owed to branch
  'status': 'Pending'
}
```

**Key Points**:
- Payment entry immediate (marks invoice paid)
- Settlement deferred
- Courier owes net to branch
- Tracked for later reconciliation

---

### Scenario 5: Sales Partner Invoice

**Flow for Unpaid Sales Partner**:
```
1. Invoice created from POS with Sales Partner
2. Invoice appears in "Received" column (NO delivery fee)
3. User drags to "Out for Delivery"
4. Sales Partner Fast-Path Dialog:
   - Select payment mode
   - "Collect Now" option (auto pay + OFD)
5. System Actions (Single API Call):
   - API: salesPartnerUnpaidOutForDelivery
   - Creates Payment Entry (Customer → Branch, mode: cash)
   - Creates Delivery Note
   - NO Courier Transaction (sales partner handles)
   - Updates invoice state to OFD
   - Marks invoice as Paid
6. Invoice moves to "Out for Delivery" column
```

**Flow for Paid Sales Partner**:
```
1. Invoice created from POS (paid) with Sales Partner
2. Invoice appears in "Received" column
3. User drags to "Out for Delivery"
4. Sales Partner Fast-Path Dialog:
   - Simple "Send to Delivery" button
5. System Actions:
   - API: salesPartnerPaidOutForDelivery
   - Creates Delivery Note
   - NO Payment Entry (already paid)
   - NO Courier Transaction (no courier)
   - Updates invoice state to OFD
6. Invoice moves to "Out for Delivery" column
```

**Key Points**:
- NO courier settlement (sales partner handles delivery)
- NO delivery fee charged
- Fast-path APIs for efficiency
- Auto-payment for unpaid sales partner orders
- Simplified workflow

---

### Scenario 6: Pickup Order

**Flow**:
```
1. Invoice created from POS (pickup mode)
2. Invoice appears in "Received" column (NO delivery fee)
3. User can drag to ANY state directly:
   - Received → Processing
   - Received → Ready
   - Received → Delivered (direct)
4. NO Courier Assignment Required
5. System Actions (Simple State Update):
   - API: updateInvoiceState
   - Updates sales_invoice_state field
   - NO Delivery Note
   - NO Courier Transaction
   - NO Settlement
   - Broadcasts state change
6. Invoice moves to selected column
```

**Direct Transition**:
```dart
// Simple state update, no complex logic
updateInvoiceState(
  invoiceId: 'INV-2024-001',
  newState: 'Ready for Pickup'
);
```

**Key Points**:
- NO courier involved
- NO delivery fee
- Direct state transitions
- Customer collects order
- Simplified workflow

---

## Settlement Flows

### Settlement Preview Calculation

**API**: `GET /api/method/jarz_pos.api.invoices.get_invoice_settlement_preview`

**Calculation Logic**:
```python
# Backend calculation
outstanding = invoice.outstanding_amount  # Unpaid amount
delivery_income = invoice.delivery_income  # Courier's fee
net_amount = outstanding - delivery_income

# Examples:
# 1. Paid invoice (outstanding=0, delivery=5):
#    net = 0 - 5 = -5 (Branch owes courier 5)

# 2. Unpaid invoice (outstanding=25, delivery=5):
#    net = 25 - 5 = 20 (Courier owes branch 20)

# 3. Pickup/Partner (outstanding=25, delivery=0):
#    net = 25 - 0 = 25 (No courier settlement)
```

**Response Format**:
```json
{
  "invoice": "INV-2024-001",
  "outstanding": 25.00,
  "delivery_income": 5.00,
  "net_amount": 20.00,
  "settlement_direction": "courier_to_branch",
  "customer": "CUST-001",
  "grand_total": 25.00
}
```

### Settlement Execution

#### 1. Settle Courier Collected Payment

**When**: Unpaid invoice, courier collects COD, immediate settlement

**API**: `POST /api/method/jarz_pos.api.invoices.settle_courier_collected_payment`

**Actions**:
1. Create Payment Entry (Customer → Branch)
   - Amount: Full outstanding
   - Mode: Selected payment mode
   - Marks invoice as Paid

2. Create Settlement Entry (Courier → Branch)
   - Amount: net_amount (outstanding - delivery_income)
   - From: Courier Account
   - To: Branch Account

**Example**:
```json
// Request
{
  "invoice_name": "INV-2024-001",
  "courier": "COURIER-001",
  "payment_mode": "cash",
  "pos_profile": "Main Branch"
}

// Creates:
// 1. Payment Entry: 25.00 (Customer pays invoice)
// 2. Settlement Entry: 20.00 (Courier pays net to branch)
```

#### 2. Settle Single Invoice Paid

**When**: Paid invoice, immediate settlement, branch owes courier

**API**: `POST /api/method/jarz_pos.api.invoices.settle_single_invoice_paid`

**Actions**:
1. Create Payment Entry (Branch → Courier)
   - Amount: delivery_income (absolute value of net_amount)
   - From: Branch Account
   - To: Courier Account

**Example**:
```json
// Request
{
  "invoice_name": "INV-2024-001",
  "courier": "COURIER-001",
  "pos_profile": "Main Branch"
}

// Creates:
// Payment Entry: 5.00 (Branch pays courier for delivery)
```

#### 3. Deferred Settlement (Pay Later)

**API**: `POST /api/method/jarz_pos.api.invoices.handle_out_for_delivery_transition`

**With mode: 'later'**:

**Actions**:
1. Create Delivery Note
2. Create Payment Entry (if unpaid)
3. Create Courier Transaction record
4. NO immediate settlement entry
5. Update invoice state

**Courier Transaction**:
```json
{
  "courier": "COURIER-001",
  "invoice": "INV-2024-001",
  "amount": 5.00,
  "status": "Pending",
  "transaction_type": "Delivery Income",
  "created_date": "2024-01-15"
}
```

**Later Settlement**:
- View in courier balances screen
- Settle individually via API
- Bulk settle multiple transactions
- Payment entry created on settlement

---

## Special Cases

### 1. Recently Paid Invoice

**Scenario**: Invoice paid within last 5 minutes, dragged to OFD

**Issue**: Backend hasn't updated `outstanding_amount` to 0 yet

**Handling**:
```dart
// Check if recently paid
bool isRecentlyPaid = invoice.payment_entry != null && 
                      invoice.payment_timestamp.isWithin(Duration(minutes: 5));

if (isRecentlyPaid) {
  // Treat as unpaid for settlement purposes
  // Use payment entry amount instead of outstanding
  net_amount = payment_amount - delivery_income;
}
```

**Settlement**:
- Use payment entry amount
- Calculate net as if unpaid
- Apply standard COD settlement logic

### 2. Sales Partner with Unpaid Invoice

**Scenario**: Sales partner order, unpaid, dragged to OFD

**Fast-Path**:
```dart
// Single API call does everything
salesPartnerUnpaidOutForDelivery(
  invoice: 'INV-2024-001',
  paymentMode: 'cash'
)

// Backend creates:
// 1. Payment Entry (auto cash payment)
// 2. Delivery Note
// 3. NO courier transaction
// 4. State update to OFD
```

**Key**: No courier settlement, no delivery fee

### 3. Pickup Order State Changes

**Scenario**: Pickup order, need to update state

**Simple Transition**:
```dart
// Direct state update, no dialog
updateInvoiceState(
  invoiceId: 'INV-2024-001',
  newState: 'Ready for Pickup'
)

// No courier assignment
// No payment processing
// No settlement
// Just state change
```

**States for Pickup**:
- Received → Processing → Ready for Pickup
- Received → Ready for Pickup (direct)
- Ready for Pickup → Picked Up (final)

### 4. Idempotency Handling

**Scenario**: Network retry or duplicate request

**Protection**:
```dart
// All settlement APIs use idempotency tokens
idempotencyToken = uuid();

handleOutForDeliveryTransition(
  invoice: 'INV-2024-001',
  courier: 'COURIER-001',
  mode: 'pay_now',
  idempotencyToken: idempotencyToken  // Prevents duplicate processing
)
```

**Backend Check**:
```python
# Check if already processed
if idempotency_token_exists(token):
    return cached_response
    
# Process and cache
result = process_transition(...)
cache_response(token, result)
return result
```

---

## Real-Time Updates

### WebSocket Integration

**Connection**:
```dart
// WebSocket URL
ws://backend-server/kanban/updates

// Auto-reconnect on disconnect
// Heartbeat ping every 30 seconds
```

**Event Types**:

#### 1. Kanban State Changed
```json
{
  "event": "kanban_state_changed",
  "invoice": "INV-2024-001",
  "old_state": "Processing",
  "new_state": "Out for Delivery",
  "updated_by": "user@example.com",
  "timestamp": "2024-01-15T14:30:00Z"
}
```

**Client Handling**:
```dart
// Listen to WebSocket stream
wsService.kanbanUpdates.listen((event) {
  final invoiceId = event['invoice'];
  final newState = event['new_state'];
  
  // Update local state
  moveInvoiceBetweenColumns(invoiceId, newState);
  
  // Show notification
  showSnackbar('Invoice ${invoiceId} moved to ${newState}');
});
```

#### 2. Payment Collected
```json
{
  "event": "payment_collected",
  "invoice": "INV-2024-001",
  "amount": 25.00,
  "mode": "cash",
  "courier": "COURIER-001"
}
```

#### 3. Settlement Completed
```json
{
  "event": "settlement_completed",
  "invoice": "INV-2024-001",
  "settlement_amount": 20.00,
  "courier": "COURIER-001",
  "type": "courier_to_branch"
}
```

### Optimistic Updates

**Strategy**: Update UI immediately, revert on error

**Flow**:
```dart
// 1. Optimistic Update
void dragInvoice(invoice, fromCol, toCol) {
  // Immediately move in UI
  setState(() {
    moveInvoiceLocal(invoice, fromCol, toCol);
  });
  
  // 2. Send to backend
  try {
    await updateInvoiceState(invoice.id, toCol.name);
  } catch (error) {
    // 3. Revert on error
    setState(() {
      moveInvoiceLocal(invoice, toCol, fromCol);
    });
    showError(error);
  }
}
```

**Benefits**:
- Instant UI feedback
- Better UX
- Graceful error handling

---

## Filtering & Search

### Available Filters

#### 1. Branch Filter
**Purpose**: Filter invoices by POS profile/branch

**UI**: Multi-select dropdown in app bar

**Implementation**:
```dart
// State
Set<String> selectedBranches = {'Branch A', 'Branch B'};

// API call includes branches
getKanbanInvoices(filters: {
  'branches': selectedBranches.toList()
});
```

#### 2. Date Range Filter
**Purpose**: Filter by invoice creation date

**UI**: Date picker dialog (from/to dates)

**Implementation**:
```dart
// State
DateTime? dateFrom = DateTime(2024, 1, 1);
DateTime? dateTo = DateTime(2024, 1, 31);

// API payload
{
  'date_from': '2024-01-01',
  'date_to': '2024-01-31'
}
```

#### 3. Customer Filter
**Purpose**: Filter by specific customer

**UI**: Dropdown with customer search

**Implementation**:
```dart
// State
String? selectedCustomer = 'CUST-001';

// API payload
{
  'customer': 'CUST-001'
}
```

#### 4. Status Filter
**Purpose**: Filter by payment status

**Options**:
- Paid
- Unpaid
- Partially Paid
- Overdue

**UI**: Dropdown selector

#### 5. Amount Range Filter
**Purpose**: Filter by invoice total amount

**UI**: Two text fields (min/max)

**Implementation**:
```dart
// State
double? amountFrom = 0.0;
double? amountTo = 1000.0;

// API payload
{
  'amount_from': 0.0,
  'amount_to': 1000.0
}
```

#### 6. Search Filter
**Purpose**: Text search in invoice numbers, customer names

**UI**: Search bar at top

**Implementation**:
```dart
// State
String searchTerm = 'INV-2024';

// API payload
{
  'search': 'INV-2024'
}
```

### Filter Persistence

**Local Storage**:
```dart
// Save filters to Hive
await filterBox.put('kanban_filters', filters.toJson());

// Restore on app restart
final savedFilters = filterBox.get('kanban_filters');
if (savedFilters != null) {
  state = state.copyWith(filters: KanbanFilters.fromJson(savedFilters));
}
```

---

## API Integration

### Core Endpoints

#### 1. Get Kanban Columns
```dart
GET /api/method/jarz_pos.api.kanban.get_kanban_columns

Response:
{
  "success": true,
  "columns": [
    {
      "id": "received",
      "name": "Received",
      "color": "#2196F3"
    },
    ...
  ]
}
```

#### 2. Get Kanban Invoices
```dart
POST /api/method/jarz_pos.api.kanban.get_kanban_invoices
Body: {
  "filters": {
    "branches": ["Branch A"],
    "date_from": "2024-01-01",
    "customer": "CUST-001"
  }
}

Response:
{
  "success": true,
  "data": {
    "received": [
      {
        "id": "INV-2024-001",
        "customer": "CUST-001",
        "grand_total": 25.00,
        ...
      }
    ],
    "processing": [...],
    ...
  }
}
```

#### 3. Update Invoice State
```dart
POST /api/method/jarz_pos.api.kanban.update_invoice_state
Body: {
  "invoice_id": "INV-2024-001",
  "new_state": "Processing"
}

Response:
{
  "success": true,
  "invoice": { updated invoice data }
}
```

#### 4. Handle Out For Delivery Transition
```dart
POST /api/method/jarz_pos.api.invoices.handle_out_for_delivery_transition
Body: {
  "invoice_name": "INV-2024-001",
  "courier": "COURIER-001",
  "mode": "pay_now",  // or "later"
  "payment_mode": "cash",  // if unpaid
  "pos_profile": "Main Branch",
  "idempotency_token": "uuid-here",
  "party_type": "Courier",  // optional
  "party": "COURIER-001"    // optional
}

Response:
{
  "success": true,
  "delivery_note": "DN-2024-001",
  "payment_entry": "PE-2024-001",  // if unpaid
  "settlement_entry": "PE-2024-002",  // if pay_now
  "courier_transaction": "CT-2024-001"  // if later
}
```

#### 5. Get Invoice Details
```dart
GET /api/method/jarz_pos.api.kanban.get_invoice_details
Params: { "invoice_id": "INV-2024-001" }

Response:
{
  "success": true,
  "invoice": {
    "id": "INV-2024-001",
    "customer": "CUST-001",
    "items": [...],
    "grand_total": 25.00,
    "outstanding": 25.00,
    "sales_invoice_state": "Received",
    ...
  }
}
```

#### 6. Get Settlement Preview
```dart
GET /api/method/jarz_pos.api.invoices.get_invoice_settlement_preview
Params: {
  "invoice_name": "INV-2024-001",
  "party_type": "Courier",
  "party": "COURIER-001"
}

Response:
{
  "invoice": "INV-2024-001",
  "outstanding": 25.00,
  "delivery_income": 5.00,
  "net_amount": 20.00,
  "settlement_direction": "courier_to_branch"
}
```

#### 7. Sales Partner Fast-Path APIs

```dart
// Unpaid Sales Partner
POST /api/method/jarz_pos.api.invoices.sales_partner_unpaid_out_for_delivery
Body: {
  "invoice_name": "INV-2024-001",
  "payment_mode": "cash"
}

Response:
{
  "success": true,
  "payment_entry": "PE-2024-001",
  "delivery_note": "DN-2024-001"
}
```

```dart
// Paid Sales Partner
POST /api/method/jarz_pos.api.invoices.sales_partner_paid_out_for_delivery
Body: {
  "invoice_name": "INV-2024-001"
}

Response:
{
  "success": true,
  "delivery_note": "DN-2024-001"
}
```

#### 8. Settlement APIs

```dart
// Settle Courier Collected Payment
POST /api/method/jarz_pos.api.invoices.settle_courier_collected_payment
Body: {
  "invoice_name": "INV-2024-001",
  "courier": "COURIER-001",
  "payment_mode": "cash",
  "pos_profile": "Main Branch"
}

Response:
{
  "success": true,
  "payment_entry": "PE-2024-001",
  "settlement_entry": "PE-2024-002"
}
```

```dart
// Settle Single Invoice Paid
POST /api/method/jarz_pos.api.invoices.settle_single_invoice_paid
Body: {
  "invoice_name": "INV-2024-001",
  "courier": "COURIER-001",
  "pos_profile": "Main Branch"
}

Response:
{
  "success": true,
  "settlement_entry": "PE-2024-001"
}
```

---

## Error Handling

### Common Errors

#### 1. Network Error
```dart
try {
  await updateInvoiceState(...);
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    showError('Connection timeout. Please check your network.');
  } else if (e.type == DioExceptionType.receiveTimeout) {
    showError('Server not responding. Please try again.');
  }
}
```

#### 2. Validation Error
```dart
Response Error:
{
  "success": false,
  "error": "Invoice already in Out for Delivery state"
}

// Show error dialog with specific message
showDialog(
  title: 'Cannot Update State',
  message: error.message,
  actions: [Retry, Cancel]
);
```

#### 3. Settlement Error
```dart
// Insufficient balance for settlement
{
  "success": false,
  "error": "Insufficient balance in branch account"
}

// Show error with context
showError(
  'Cannot complete settlement: ${error.message}\n'
  'Please check account balance.'
);
```

### Offline Handling

**Queue Failed Requests**:
```dart
// Offline queue for state transitions
if (!isOnline) {
  await offlineQueue.add({
    'type': 'update_invoice_state',
    'invoice_id': invoiceId,
    'new_state': newState,
    'timestamp': DateTime.now()
  });
  
  showMessage('Update queued. Will sync when online.');
}
```

**Auto-Sync**:
```dart
// Listen to connectivity changes
connectivityService.onStatusChange.listen((isOnline) {
  if (isOnline) {
    processOfflineQueue();
  }
});
```

---

## Performance Optimizations

### 1. Lazy Loading
```dart
// Load invoice details on demand
Future<InvoiceCard> loadInvoiceDetails(String id) async {
  // Check cache first
  if (cache.contains(id)) {
    return cache.get(id);
  }
  
  // Fetch from API
  final invoice = await kanbanService.getInvoiceDetails(id);
  
  // Cache result
  cache.put(id, invoice);
  
  return invoice;
}
```

### 2. Debounced Filters
```dart
// Debounce filter changes
Timer? _debounce;

void onFilterChanged(KanbanFilters filters) {
  _debounce?.cancel();
  _debounce = Timer(Duration(milliseconds: 500), () {
    loadInvoices(filters);
  });
}
```

### 3. Optimistic Updates
```dart
// Update UI immediately, sync later
void moveInvoice(invoice, toColumn) {
  // Update UI
  setState(() {
    moveInvoiceLocal(invoice, toColumn);
  });
  
  // Sync to backend (async)
  updateInvoiceState(invoice.id, toColumn.name)
    .catchError((error) {
      // Revert on error
      setState(() {
        moveInvoiceBack(invoice);
      });
    });
}
```

---

## Related Documentation

- [POS Flow Documentation](POS_FLOW_DOCUMENTATION.md) - Invoice creation flow
- [Invoice Scenarios Visual Map](test/INVOICE_SCENARIOS_VISUAL_MAP.md) - Test coverage diagrams
- [Invoice Scenarios Test Coverage](test/INVOICE_SCENARIOS_TEST_COVERAGE.md) - Detailed test documentation
- [Business Documentation](BUSINESS_DOCUMENTATION.md) - Business rules and processes
- [User Manual](USER_MANUAL.md) - End-user guide

---

**Last Updated**: 2024-01-15  
**Version**: 1.0  
**Status**: Complete
