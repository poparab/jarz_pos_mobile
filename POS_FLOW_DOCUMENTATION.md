# POS Flow Documentation

## Table of Contents
1. [Overview](#overview)
2. [Complete POS Flow Diagram](#complete-pos-flow-diagram)
3. [Detailed Flow Steps](#detailed-flow-steps)
4. [Decision Points and Options](#decision-points-and-options)
5. [Payment Modes](#payment-modes)
6. [Special Cases](#special-cases)
7. [State Management](#state-management)
8. [API Integration](#api-integration)

---

## Overview

The Jarz POS Mobile application provides a comprehensive Point of Sale system with cart management, customer selection, delivery scheduling, and checkout. The flow supports multiple payment modes, sales partner integration, pickup orders, and offline synchronization.

### Key Features
- 🛒 **Cart Management**: Add items and bundles with quantity control
- 👤 **Customer Management**: Search, select, or create customers on-the-fly
- 📅 **Delivery Scheduling**: Select delivery slots for future fulfillment
- 💰 **Multiple Payment Modes**: Cash, Wallet, InstaPay, Bank Transfer
- 🤝 **Sales Partner Support**: Special handling for partner transactions
- 📦 **Pickup Mode**: Bypass delivery fees for customer pickup orders
- 🔌 **Offline Support**: Queue transactions when offline, sync when connected

---

## Complete POS Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         JARZ POS - COMPLETE FLOW                            │
└─────────────────────────────────────────────────────────────────────────────┘

                              ┌─────────────┐
                              │   START     │
                              │  POS App    │
                              └──────┬──────┘
                                     │
                              ┌──────▼──────────┐
                              │ Select POS      │
                              │ Profile/Branch  │
                              └──────┬──────────┘
                                     │
                          ┌──────────▼──────────┐
                          │  Load Profile       │
                          │  Configuration:     │
                          │  • Items            │
                          │  • Bundles          │
                          │  • Delivery Slots   │
                          └──────┬──────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────────┐
│                     CUSTOMER SELECTION                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐    ┌────────────┐    ┌──────────────────────┐   │
│  │  Search  │───▶│   Found?   │───▶│  Select Existing     │   │
│  │ Customer │    │    YES     │    │  Customer            │   │
│  └──────────┘    └────────────┘    └──────────┬───────────┘   │
│       │                                        │               │
│       │          ┌────────────┐                │               │
│       └─────────▶│   Found?   │                │               │
│                  │     NO     │                │               │
│                  └──────┬─────┘                │               │
│                         │                      │               │
│                  ┌──────▼──────────────┐       │               │
│                  │  Create New         │       │               │
│                  │  Customer:          │       │               │
│                  │  • Name             │       │               │
│                  │  • Phone            │       │               │
│                  │  • Territory        │       │               │
│                  │  • Delivery Income  │       │               │
│                  └──────┬──────────────┘       │               │
│                         │                      │               │
│                         └──────────────────────┘               │
│                                 │                              │
└─────────────────────────────────┼──────────────────────────────┘
                                  │
┌─────────────────────────────────▼────────────────────────────────┐
│                      DELIVERY MODE SELECTION                     │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│           ┌─────────────────┬──────────────────────┐            │
│           │                 │                      │            │
│      ┌────▼─────┐     ┌─────▼──────┐      ┌──────▼────────┐    │
│      │ Delivery │     │   Pickup   │      │ Sales Partner │    │
│      │   Mode   │     │    Mode    │      │     Mode      │    │
│      └────┬─────┘     └─────┬──────┘      └──────┬────────┘    │
│           │                 │                     │             │
│    ┌──────▼──────────┐      │                     │             │
│    │ Select Delivery │      │                     │             │
│    │ Slot & Date     │      │                     │             │
│    └──────┬──────────┘      │                     │             │
│           │                 │                     │             │
│    ┌──────▼──────────┐      │              ┌──────▼─────────┐   │
│    │ Delivery Fee    │      │              │ Select Sales   │   │
│    │ Applied         │      │              │ Partner        │   │
│    │ (from territory)│      │              └──────┬─────────┘   │
│    └──────┬──────────┘      │                     │             │
│           │                 │                     │             │
│           │                 │              ┌──────▼──────────┐  │
│           │                 │              │ No Delivery Fee │  │
│           │                 │              │ Applied         │  │
│           │                 │              └──────┬──────────┘  │
│           │                 │                     │             │
└───────────┼─────────────────┼─────────────────────┼─────────────┘
            │                 │                     │
            └─────────────────┴─────────────────────┘
                              │
┌─────────────────────────────▼────────────────────────────────┐
│                     CART MANAGEMENT                          │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │  Add Items   │    │ Add Bundles  │    │ Adjust Qty   │  │
│  │  (Products)  │    │ (Packages)   │    │ & Remove     │  │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘  │
│         │                   │                    │          │
│         └───────────────────┴────────────────────┘          │
│                             │                               │
│                      ┌──────▼──────────┐                    │
│                      │  Cart Summary:  │                    │
│                      │  • Items Total  │                    │
│                      │  • Delivery Fee │                    │
│                      │  • Grand Total  │                    │
│                      └──────┬──────────┘                    │
│                             │                               │
└─────────────────────────────┼───────────────────────────────┘
                              │
                       ┌──────▼──────┐
                       │  Validate   │
                       │  Cart       │
                       │  • Not Empty│
                       │  • Customer │
                       └──────┬──────┘
                              │
┌─────────────────────────────▼────────────────────────────────┐
│                    CHECKOUT & PAYMENT                        │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           Payment Type Selection                    │    │
│  │  (for Non-Sales Partner Orders)                     │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │                                                     │    │
│  │    ┌──────────┐         ┌──────────────┐           │    │
│  │    │   Cash   │         │    Online    │           │    │
│  │    │ Payment  │         │   Payment    │           │    │
│  │    └─────┬────┘         └──────┬───────┘           │    │
│  │          │                     │                   │    │
│  │          │  (Advisory flag     │                   │    │
│  │          │   sent to backend)  │                   │    │
│  │          └──────────┬──────────┘                   │    │
│  └─────────────────────┼──────────────────────────────┘    │
│                        │                                   │
│  ┌─────────────────────▼──────────────────────────────┐    │
│  │           Create Invoice API Call                  │    │
│  │  POST /api/method/jarz_pos.api.invoices           │    │
│  │       .create_pos_invoice                          │    │
│  │                                                     │    │
│  │  Payload:                                           │    │
│  │  • cart_json (items with qty, rate)               │    │
│  │  • customer_name                                    │    │
│  │  • pos_profile_name                                │    │
│  │  • delivery_charges_json (if applicable)           │    │
│  │  • required_delivery_datetime (if scheduled)       │    │
│  │  • sales_partner (if selected)                     │    │
│  │  • pickup (if pickup mode)                         │    │
│  │  • payment_type ('cash' | 'online')                │    │
│  └─────────────────────┬──────────────────────────────┘    │
│                        │                                   │
│                 ┌──────▼──────┐                            │
│                 │   Success?  │                            │
│                 └──┬────────┬─┘                            │
│                    │        │                              │
│              YES   │        │   NO                         │
│                    │        │                              │
│         ┌──────────▼─┐    ┌─▼──────────────┐              │
│         │  Invoice   │    │  Error Dialog  │              │
│         │  Created   │    │  Retry Option  │              │
│         └──────┬─────┘    └────────────────┘              │
│                │                                           │
└────────────────┼───────────────────────────────────────────┘
                 │
┌────────────────▼───────────────────────────────────────────┐
│                POST-INVOICE ACTIONS                        │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌──────────────────┐    ┌──────────────────────────┐     │
│  │  Print Receipt   │    │  View in Kanban Board    │     │
│  │  (Bluetooth/PDF) │    │  (Navigate to Kanban)    │     │
│  └────────┬─────────┘    └────────┬─────────────────┘     │
│           │                       │                       │
│           └───────────┬───────────┘                       │
│                       │                                   │
│                ┌──────▼──────┐                            │
│                │  Clear Cart │                            │
│                │  Reset POS  │                            │
│                └──────┬──────┘                            │
│                       │                                   │
└───────────────────────┼────────────────────────────────────┘
                        │
                  ┌─────▼──────┐
                  │  Ready for │
                  │  Next Order│
                  └────────────┘
```

---

## Detailed Flow Steps

### 1. Application Startup & Profile Selection

**Purpose**: Initialize POS session with specific business configuration

**Steps**:
1. Launch Jarz POS Mobile application
2. User selects from available POS Profiles (branches/locations)
3. App loads profile-specific configuration:
   - Product catalog (items)
   - Bundle packages
   - Delivery slots
   - Pricing rules
   - Default settings

**Data Loaded**:
```dart
// API: /api/method/jarz_pos.api.pos.get_pos_profiles
// Returns: List of profile names

// API: /api/method/jarz_pos.api.pos.get_profile_products
// Returns: Items with pricing for selected profile

// API: /api/method/jarz_pos.api.pos.get_profile_bundles
// Returns: Bundle packages for selected profile
```

**State Changes**:
- `selectedProfile`: Set to chosen profile
- `items`: Loaded from backend
- `bundles`: Loaded from backend
- `deliverySlots`: Loaded from backend

---

### 2. Customer Selection

**Purpose**: Identify the customer for the transaction

#### 2.1 Search Existing Customer

**Options**:
- **Search by Name**: Enter customer name to search
- **Search by Phone**: Enter phone number to search

```dart
// API: /api/method/jarz_pos.api.customer.search_customers
// Parameters: { 'name': query } OR { 'phone': query }
// Returns: List of matching customers
```

**Customer Data**:
- `name`: Customer ID/code
- `customer_name`: Display name
- `mobile_no`: Phone number
- `territory`: Geographic location
- `delivery_income`: Delivery fee for this territory

#### 2.2 Create New Customer

**When**: No matching customer found

**Required Fields**:
- Name (display name)
- Phone number
- Territory (dropdown selection)

**Automatic Calculation**:
- Delivery fee assigned based on selected territory

```dart
// API: /api/method/jarz_pos.api.customer.create_customer
// Parameters: {
//   'customer_name': name,
//   'mobile_no': phone,
//   'territory': territory
// }
// Returns: New customer object with delivery_income
```

**Error Handling**:
- Duplicate customer validation
- Phone number format validation
- Territory requirement validation

---

### 3. Delivery Mode Selection

**Three Modes Available**:

#### 3.1 Delivery Mode (Standard)

**Characteristics**:
- Requires delivery slot selection
- Delivery fee applied from customer's territory
- Requires delivery date/time

**Flow**:
1. Customer selects delivery slot from available options
2. System calculates delivery fee from territory
3. Delivery charge added to cart total
4. Delivery datetime recorded for invoice

```dart
// Delivery Slot Structure:
{
  'name': 'Slot ID',
  'display_name': 'Morning (9 AM - 12 PM)',
  'from_time': '09:00:00',
  'to_time': '12:00:00'
}
```

#### 3.2 Pickup Mode

**Characteristics**:
- No delivery fee applied
- No delivery slot required
- Customer collects from location
- Flagged as `pickup: true` in invoice

**Flow**:
1. Toggle "Pickup" mode ON
2. System bypasses delivery fee calculation
3. No slot selection required
4. Invoice marked with pickup flag

**Backend Handling**:
```dart
// Invoice payload includes:
{ 'pickup': 1 }
```

#### 3.3 Sales Partner Mode

**Characteristics**:
- No delivery fee applied
- Sales partner handles delivery
- Special settlement logic (no courier settlement)
- Auto-defaulted to 'cash' payment type

**Flow**:
1. Search and select Sales Partner
2. System suppresses delivery fee
3. Sales partner recorded in invoice
4. Special payment/settlement workflow applied

```dart
// API: /api/method/jarz_pos.api.pos.get_sales_partners
// Parameters: { 'search': query, 'limit': 10 }
// Returns: List of sales partners
```

---

### 4. Cart Management

**Purpose**: Build the order with items and bundles

#### 4.1 Add Products

**Options**:
- Browse by category
- Search by name
- View item details (price, stock, description)

**Item Addition**:
```dart
{
  'item_code': 'ITEM-001',
  'item_name': 'Product Name',
  'rate': 10.00,
  'quantity': 1,
  'type': 'item'
}
```

#### 4.2 Add Bundles

**Bundle Features**:
- Pre-configured product packages
- Custom components selection
- Bundle-level pricing
- Free shipping option (waives delivery fee)

**Bundle Addition**:
```dart
{
  'item_code': 'BUNDLE-001',
  'bundle_details': {
    'bundle_id': 'BUNDLE-001',
    'bundle_info': {
      'name': 'Bundle Name',
      'price': 50.00,
      'free_shipping': true/false
    },
    'selected_items': [
      {'item_code': 'ITEM-A', 'qty': 2},
      {'item_code': 'ITEM-B', 'qty': 1}
    ]
  },
  'rate': 50.00,
  'quantity': 1,
  'type': 'bundle'
}
```

**Free Shipping Logic**:
- If ANY bundle in cart has `free_shipping: true`
- System waives delivery fee (client-side suppression)
- Overrides territory-based delivery charge

#### 4.3 Cart Summary

**Calculation**:
```dart
// Items Total
cartTotal = sum(item.rate × item.quantity for all items)

// Delivery Fee Logic
shippingCost = 0.0

IF salesPartner != null:
  shippingCost = 0.0  // Sales partner handles delivery

ELSE IF isPickup == true:
  shippingCost = 0.0  // Pickup mode

ELSE IF any bundle has free_shipping:
  shippingCost = 0.0  // Bundle waives shipping

ELSE IF customer has delivery_income:
  shippingCost = customer.delivery_income

// Grand Total
grandTotal = cartTotal + shippingCost
```

---

### 5. Checkout & Payment

#### 5.1 Payment Type Selection

**For Non-Sales Partner Orders**:

User presented with dialog:
- **Cash Payment**: COD or immediate cash
- **Online Payment**: Wallet/InstaPay/Bank transfer

**For Sales Partner Orders**:
- Auto-defaulted to 'cash'
- No dialog shown

**Purpose**: Advisory flag for backend to record payment channel intent

```dart
// Dialog Selection Result:
payment_type = 'cash' | 'online'
```

#### 5.2 Invoice Creation

**API Endpoint**: `POST /api/method/jarz_pos.api.invoices.create_pos_invoice`

**Request Payload**:
```json
{
  "cart_json": "[{\"item_code\":\"ITEM-001\",\"qty\":2,\"rate\":10.0,\"is_bundle\":false}]",
  "customer_name": "CUST-001",
  "pos_profile_name": "Main Branch",
  "delivery_charges_json": "[{\"charge_type\":\"Delivery\",\"amount\":5.0}]",
  "required_delivery_datetime": "2024-01-15 14:00:00",
  "sales_partner": "PARTNER-001",  // optional
  "pickup": 1,  // optional, 1 for pickup mode
  "payment_type": "cash"  // optional, 'cash' or 'online'
}
```

**Response Success**:
```json
{
  "message": {
    "name": "INV-2024-001",
    "grand_total": 25.00,
    "customer": "CUST-001",
    "status": "Unpaid",
    "sales_invoice_state": "Received"
  }
}
```

**Response Error**:
- Display error dialog
- Provide retry option
- Log error details

#### 5.3 Offline Handling

**When Network Unavailable**:
1. Queue invoice creation request
2. Show "Queued for sync" message
3. Continue operation (optimistic UI)
4. Auto-sync when connection restored

```dart
// Offline Queue Entry:
{
  'id': uuid(),
  'type': 'create_invoice',
  'data': invoicePayload,
  'timestamp': DateTime.now()
}
```

---

### 6. Post-Invoice Actions

#### 6.1 Receipt Generation

**Options**:
- **Print Receipt**: Bluetooth thermal printer
- **PDF Receipt**: Generate and share PDF
- **Email Receipt**: Send to customer email

**Receipt Contains**:
- Invoice number and date
- Customer details
- Itemized list with quantities and prices
- Delivery charges (if applicable)
- Grand total
- Payment status

#### 6.2 Navigation Options

**View in Kanban**:
- Navigate to Kanban board
- Locate invoice in "Received" column
- Track order status

**New Order**:
- Clear cart
- Reset customer selection
- Return to item selection

---

## Decision Points and Options

### Decision Tree

```
START
  │
  ├─ Has Customer? ──NO──> Create New Customer
  │      │
  │     YES
  │      │
  ├─ Delivery Mode?
  │      ├─ Delivery ──> Select Slot ──> Apply Delivery Fee
  │      ├─ Pickup ───> Skip Slot ──> No Delivery Fee
  │      └─ Sales Partner ──> Select Partner ──> No Delivery Fee
  │
  ├─ Add Items/Bundles
  │      │
  │      ├─ Has Free Shipping Bundle? ──YES──> Waive Delivery Fee
  │      └─ NO ──> Keep Delivery Fee (if applicable)
  │
  ├─ Payment Type? (if NOT Sales Partner)
  │      ├─ Cash ──> Set payment_type: 'cash'
  │      └─ Online ──> Set payment_type: 'online'
  │
  └─ Create Invoice
         ├─ Success ──> Print/View/New Order
         └─ Error ──> Retry
```

---

## Payment Modes

### Supported Payment Methods

#### 1. Cash Payment
- **Type**: `payment_type: 'cash'`
- **Usage**: Cash on delivery or immediate cash payment
- **Settlement**: Handled via Kanban board settlement flow

#### 2. Online Payment
- **Type**: `payment_type: 'online'`
- **Methods Supported**:
  - Wallet (digital wallet integration)
  - InstaPay (instant payment)
  - Bank Transfer
- **Settlement**: Recorded in system, settled through Kanban

#### 3. Sales Partner Payment
- **Auto-default**: Always 'cash'
- **Special Handling**: Sales partner responsible for collection
- **No Dialog**: Payment type selector skipped

### Payment Entry API

**For Payment After Invoice Creation**:
```dart
// API: /api/method/jarz_pos.api.invoices.pay_invoice
// Parameters: {
//   'invoice_name': 'INV-2024-001',
//   'payment_mode': 'wallet' | 'instapay' | 'cash'
// }
// Returns: Payment entry details
```

---

## Special Cases

### 1. Bundle with Free Shipping

**Scenario**: Customer adds bundle marked `free_shipping: true`

**Behavior**:
- Delivery fee waived automatically
- Applied even if customer has delivery_income
- Client-side suppression (not sent to backend)
- User sees "FREE DELIVERY" in cart summary

**Logic**:
```dart
if (cartItems.any((item) => 
    item['type'] == 'bundle' && 
    item['bundle_details']['bundle_info']['free_shipping'] == true)) {
  deliveryFee = 0.0;
}
```

### 2. Sales Partner Order

**Scenario**: Order placed through sales partner

**Behavior**:
- No delivery fee applied
- Payment defaulted to 'cash'
- Sales partner recorded in invoice
- Special Kanban settlement (bypasses courier settlement)

**Backend Flag**:
```json
{
  "sales_partner": "PARTNER-001"
}
```

### 3. Pickup Order

**Scenario**: Customer chooses to pickup from location

**Behavior**:
- No delivery slot required
- No delivery fee
- Invoice flagged as pickup
- Backend skips shipping logic

**Backend Flag**:
```json
{
  "pickup": 1
}
```

### 4. Offline Transaction

**Scenario**: Network unavailable during checkout

**Behavior**:
1. Invoice request queued locally (Hive storage)
2. User notified: "Order queued for sync"
3. App allows continuation
4. Background service syncs when online
5. WebSocket notifies UI of sync completion

**Queue Management**:
- UUID-based idempotency
- Automatic retry on connection
- Error handling for failed syncs
- User notification of sync status

---

## State Management

### POS State Structure

```dart
class PosState {
  // Profile & Configuration
  List<Map<String, dynamic>> profiles;
  Map<String, dynamic>? selectedProfile;
  
  // Catalog Data
  List<Map<String, dynamic>> items;
  List<Map<String, dynamic>> bundles;
  List<DeliverySlot> deliverySlots;
  
  // Transaction State
  List<Map<String, dynamic>> cartItems;
  Map<String, dynamic>? selectedCustomer;
  DeliverySlot? selectedDeliverySlot;
  Map<String, dynamic>? selectedSalesPartner;
  
  // Modes & Flags
  bool isPickup;
  bool isLoading;
  String? error;
  
  // Computed Properties
  double get cartTotal;
  double get shippingCost;
  double get grandTotal;
}
```

### State Transitions

```
INITIAL
  ↓ loadProfiles()
PROFILES_LOADED
  ↓ selectProfile(profile)
PROFILE_SELECTED
  ↓ loadItems() & loadBundles()
CATALOG_LOADED
  ↓ selectCustomer() OR createCustomer()
CUSTOMER_SELECTED
  ↓ selectDeliveryMode()
MODE_SELECTED
  ↓ addToCart()
CART_BUILDING
  ↓ checkout()
INVOICE_CREATING
  ↓ success
INVOICE_CREATED
  ↓ clearCart()
READY_FOR_NEXT
```

---

## API Integration

### Authentication

**Method**: Cookie-based session management via Dio interceptor

**Flow**:
1. User logs in (separate auth flow)
2. Session cookie stored
3. Dio automatically includes cookie in all requests
4. Session validated on backend

### Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/method/jarz_pos.api.pos.get_pos_profiles` | POST | List POS profiles |
| `/api/method/jarz_pos.api.pos.get_profile_products` | POST | Get items for profile |
| `/api/method/jarz_pos.api.pos.get_profile_bundles` | POST | Get bundles for profile |
| `/api/method/jarz_pos.api.customer.search_customers` | POST | Search customers |
| `/api/method/jarz_pos.api.customer.create_customer` | POST | Create new customer |
| `/api/method/jarz_pos.api.pos.get_sales_partners` | POST | List sales partners |
| `/api/method/jarz_pos.api.pos.get_delivery_slots` | POST | Get delivery time slots |
| `/api/method/jarz_pos.api.invoices.create_pos_invoice` | POST | Create sales invoice |
| `/api/method/jarz_pos.api.invoices.pay_invoice` | POST | Register payment |

### Error Handling

**Common Errors**:

1. **Network Error**
   - Queue for offline sync
   - Notify user
   - Retry automatically

2. **Validation Error**
   - Display specific error message
   - Allow user to correct
   - Don't queue (user input required)

3. **Duplicate Customer**
   - Friendly error: "Customer already exists"
   - Offer to search existing
   - Don't create duplicate

4. **Insufficient Stock**
   - Error: "Item out of stock"
   - Remove from cart or reduce quantity
   - Update user

---

## Related Documentation

- [Kanban Flow Documentation](KANBAN_FLOW_DOCUMENTATION.md) - Order management after invoice creation
- [Business Documentation](BUSINESS_DOCUMENTATION.md) - Business rules and processes
- [User Manual](USER_MANUAL.md) - End-user guide
- [Environment Setup](ENVIRONMENT_SETUP.md) - Configuration guide

---

**Last Updated**: 2024-01-15  
**Version**: 1.0  
**Status**: Complete
