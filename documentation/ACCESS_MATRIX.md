# Jarz POS — Access Matrix

> Role-based access control reference for all app features.

---

## 1. Role Definitions

### Flutter App Roles

| Role | Constant | Description |
|------|----------|-------------|
| **JARZ Manager** | `isJarzManager` / `isManager` | Full management access — dashboard, financial operations, expense approval |
| **JARZ Line Manager** | `isLineManager` | Supervisory access — can cancel orders, transfer orders, mute notifications |
| **Moderator** | `isModerator` | Can mute notifications |
| **Sales User (Staff)** | *(default)* | Standard POS operations — create invoices, manage kanban, handle deliveries |

### Backend Role Groups (constants.py)

| Group | Roles Included | Purpose |
|-------|---------------|---------|
| `ROLES.ADMIN` | System Manager, POS Manager | Access ALL POS profiles |
| `ROLES.MANAGER` | System Manager, Accounts Manager, Stock Manager, Manufacturing Manager, Purchase Manager | Stock/Cash transfers, general treasury |
| `ROLES.STOCK` | System Manager, Stock Manager, Manufacturing Manager, Accounts Manager | Inventory count |
| `ROLES.MANUFACTURING` | System Manager, Manufacturing Manager, Stock Manager, Purchase Manager | Manufacturing / work orders |
| `ROLES.PURCHASE` | System Manager, Stock Manager, Manufacturing Manager, Purchase Manager, Accounts Manager | Purchase invoices |

---

## 2. POS Profile Access (Core Gate)

The POS profile a user can operate on is the first access gate — many features are scoped to the user's allowed profiles.

| User Type | Profiles Visible |
|-----------|-----------------|
| System Manager / POS Manager (`ROLES.ADMIN`) | **All** active profiles |
| Other users | Only profiles linked in **POS Profile User** table |

---

## 3. Feature Access Matrix

### Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Full access |
| ⚠️ | Conditional / limited access |
| ❌ | No access |

---

### 3.1 Navigation / Drawer Menu

| Feature | Manager | Line Manager | Moderator | Staff |
|---------|---------|-------------|-----------|-------|
| POS Screen | ✅ | ✅ | ✅ | ✅ |
| Kanban Board | ✅ | ✅ | ✅ | ✅ |
| Trips | ✅ | ✅ | ✅ | ✅ |
| Courier Balances | ✅ | ✅ | ✅ | ✅ |
| Expenses | ✅ | ✅ | ✅ | ✅ |
| Printers | ✅ | ✅ | ✅ | ✅ |
| Manager Dashboard | ✅ | ❌ | ❌ | ❌ |
| Purchase Invoices | ✅ | ❌ | ❌ | ❌ |
| Manufacturing | ✅ | ❌ | ❌ | ❌ |
| Stock Transfer | ✅ | ❌ | ❌ | ❌ |
| Cash Transfer | ✅ | ❌ | ❌ | ❌ |
| Inventory Count | ✅ | ❌ | ❌ | ❌ |

> **Note:** Manager Dashboard, Purchase, Manufacturing, Stock Transfer, Cash Transfer, and Inventory Count are only shown in the drawer when `hasManagerAccess` is true (user has `isJarzManager` role **and** has at least one allowed POS profile).

---

### 3.2 POS & Checkout

| Action | Manager | Line Manager | Moderator | Staff |
|--------|---------|-------------|-----------|-------|
| View items & bundles | ✅ | ✅ | ✅ | ✅ |
| Add items to cart | ✅ | ✅ | ✅ | ✅ |
| Change item quantity | ✅ | ✅ | ✅ | ✅ |
| Change item rate | ✅ | ✅ | ✅ | ✅ |
| Submit invoice (Cash) | ✅ | ✅ | ✅ | ✅ |
| Submit invoice (Card) | ✅ | ✅ | ✅ | ✅ |
| Submit invoice (Settle Later) | ✅ | ✅ | ✅ | ✅ |
| Assign customer | ✅ | ✅ | ✅ | ✅ |
| Select delivery slot | ✅ | ✅ | ✅ | ✅ |
| Create new customer | ✅ | ✅ | ✅ | ✅ |

> All POS operations are available to any user with access to a POS profile. Stock quantity limits are enforced for all users.

---

### 3.3 Kanban Board & Invoice Operations

| Action | Manager | Line Manager | Moderator | Staff |
|--------|---------|-------------|-----------|-------|
| View kanban board | ✅ | ✅ | ✅ | ✅ |
| Drag to next status | ✅ | ✅ | ✅ | ✅ |
| Preview invoice | ✅ | ✅ | ✅ | ✅ |
| Print invoice | ✅ | ✅ | ✅ | ✅ |
| **Transfer order** | ✅ | ✅ | ❌ | ❌ |
| **Cancel order** | ✅ | ✅ | ❌ | ❌ |
| Assign delivery partner | ✅ | ✅ | ✅ | ✅ |
| Settle courier | ✅ | ✅ | ✅ | ✅ |

> **Transfer Order** and **Cancel Order** require `isLineManager` (which is true for both JARZ Manager and JARZ Line Manager). Cancel Order is also blocked if the invoice has a partial payment.

**Backend enforcement for Cancel Order:**
- Allowed roles: `Administrator`, `JARZ Line Manager`
- Returns error "You are not permitted to cancel orders" for other users

---

### 3.4 Delivery & Trips

| Action | Manager | Line Manager | Moderator | Staff |
|--------|---------|-------------|-----------|-------|
| View trips | ✅ | ✅ | ✅ | ✅ |
| Create trip | ✅ | ✅ | ✅ | ✅ |
| Add invoices to trip | ✅ | ✅ | ✅ | ✅ |
| Send trip for delivery (OFD) | ✅ | ✅ | ✅ | ✅ |

> OFD transition requires `Sales User` or `Accounts User` role on the backend. Pickup orders cannot be added to trips.

---

### 3.5 Expenses

| Action | Manager | Line Manager | Moderator | Staff |
|--------|---------|-------------|-----------|-------|
| Create expense | ✅ | ✅ | ✅ | ✅ |
| **Approve expense** | ✅ | ❌ | ❌ | ❌ |
| **Payment sources — all accounts** | ✅ | ❌ | ❌ | ❌ |
| Payment sources — own POS profiles | ✅ | ✅ | ✅ | ✅ |

> Manager-created expenses are **auto-approved** and automatically submitted. Staff-created expenses are created with `requires_approval = 1` and remain in draft until a manager approves them. Mobile Wallet payments always require approval.

---

### 3.6 Financial Operations (Manager Only)

| Action | Required Backend Roles |
|--------|----------------------|
| Cash Transfer — list accounts | `ROLES.MANAGER` (System Manager, Accounts Manager, Stock Manager, Manufacturing Manager, Purchase Manager) |
| Cash Transfer — submit | `ROLES.MANAGER` |
| Stock Transfer — search items | `ROLES.MANAGER` |
| Stock Transfer — submit | `ROLES.MANAGER` |
| Purchase Invoice — create | `ROLES.PURCHASE` (System Manager, Stock Manager, Manufacturing Manager, Purchase Manager, Accounts Manager) |
| Manufacturing — list BOMs | `ROLES.MANUFACTURING` (System Manager, Manufacturing Manager, Stock Manager, Purchase Manager) |
| Manufacturing — submit work orders | `ROLES.MANUFACTURING` |
| Inventory Count — list items | `ROLES.STOCK` (System Manager, Stock Manager, Manufacturing Manager, Accounts Manager) |
| Inventory Count — submit reconciliation | `ROLES.STOCK` |

---

### 3.7 Settings & Notifications

| Action | Manager | Line Manager | Moderator | Staff |
|--------|---------|-------------|-----------|-------|
| View profile | ✅ | ✅ | ✅ | ✅ |
| Change language | ✅ | ✅ | ✅ | ✅ |
| Select POS profile | ✅ | ✅ | ✅ | ✅ |
| **Mute notifications** | ✅ | ✅ | ✅ | ❌ |

> Mute notifications is available when `canMuteNotifications` = `isJarzManager || isLineManager || isModerator`.

---

### 3.8 Shift Management

| Action | All Users |
|--------|-----------|
| Start shift | ✅ (if `custom_require_pos_shift` is enabled on the user and no active shift exists on that profile) |
| End own shift | ✅ |
| End another user's shift | ❌ (blocked — only the user who opened the shift can close it) |

> Shift requirement is per-user, controlled by the `custom_require_pos_shift` flag on the User doctype.

---

## 4. Summary: Role Capabilities at a Glance

| Capability | Manager | Line Manager | Moderator | Staff |
|------------|---------|-------------|-----------|-------|
| POS (create invoices) | ✅ | ✅ | ✅ | ✅ |
| Kanban (view & transition) | ✅ | ✅ | ✅ | ✅ |
| Cancel / Transfer orders | ✅ | ✅ | ❌ | ❌ |
| Manager Dashboard | ✅ | ❌ | ❌ | ❌ |
| Cash Transfer | ✅ | ❌ | ❌ | ❌ |
| Stock Transfer | ✅ | ❌ | ❌ | ❌ |
| Purchase Invoices | ✅ | ❌ | ❌ | ❌ |
| Manufacturing | ✅ | ❌ | ❌ | ❌ |
| Inventory Count | ✅ | ❌ | ❌ | ❌ |
| Approve Expenses | ✅ | ❌ | ❌ | ❌ |
| Mute Notifications | ✅ | ✅ | ✅ | ❌ |
| Trips & Delivery | ✅ | ✅ | ✅ | ✅ |
| Expenses (create) | ✅ | ✅ | ✅ | ✅ |
| Printing | ✅ | ✅ | ✅ | ✅ |
