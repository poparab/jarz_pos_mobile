# Jarz POS — Access Matrix

> Role-based access control reference for all app features.
> Last verified: 2026-04-19 (224/224 API permission tests passed on staging)

---

## 1. Role Definitions

### Custom App Roles — Hierarchy & Distinctions

The app has **four named roles**, each granting a distinct level of authority. They are listed from highest to lowest privilege:

| # | Role | Constant | Who it is | Unique capabilities vs. tier below |
|---|------|----------|-----------|--------------------------------------|
| 1 | **High Management** | `isHighManagement` | Cross-branch executives / owners (System Manager) | Unrestricted access to **all** features and **all** POS profiles with no profile assignment requirement; bypasses every app-level restriction |
| 2 | **JARZ Manager** | `isJarzManager` / `isManager` | Branch-level managers | Unlocks the Manager Dashboard, financial operations (cash/stock transfer, purchase invoices, manufacturing, inventory count), reports, and expense approval; POS profile access still requires profile assignment |
| 3 | **JARZ Line Manager** | `isLineManager` | Floor supervisors / shift leads | Can cancel and transfer orders, can skip the shift-opening flow, can view Master Orders and Manager Dashboard; no access to financial operations or reports |
| 4 | **Moderator** | `isModerator` | Senior staff / support agents | Same POS/Kanban access as regular staff plus the ability to mute push notifications and view Master Orders; cannot cancel orders or use any managerial feature |
| — | **Sales User (Staff)** | *(default)* | Regular sales staff | Standard POS operations only — create invoices, manage kanban, handle deliveries |

#### Key Distinctions at a Glance

| What distinguishes each role | High Mgmt | Manager | Line Manager | Moderator | Staff |
|------------------------------|:---------:|:-------:|:------------:|:---------:|:-----:|
| All POS profiles without assignment | ✅ | ❌ | ❌ | ❌ | ❌ |
| Manager Dashboard & financial ops | ✅ | ✅ | ❌ | ❌ | ❌ |
| Manager Dashboard (view only) | ✅ | ✅ | ✅ | ❌ | ❌ |
| Reports | ✅ | ✅ | ❌ | ❌ | ❌ |
| Approve expenses | ✅ | ✅ | ❌ | ❌ | ❌ |
| Master Orders (cross-branch view) | ✅ | ✅ | ✅ | ✅ | ❌ |
| Cancel / Transfer orders | ✅ | ✅ | ✅ | ❌ | ❌ |
| Mute push notifications | ✅ | ✅ | ✅ | ✅ | ❌ |
| Skip shift-opening flow | ✅ | ✅ | ✅ (opt-in) | ❌ | ❌ |
| Standard POS, Kanban, Trips, Expenses | ✅ | ✅ | ✅ | ✅ | ✅ |

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
| **High Management** | **All** active profiles (no assignment required) |
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

| Feature | High Mgmt | Manager | Line Manager | Moderator | Staff |
|---------|:---------:|:-------:|:------------:|:---------:|:-----:|
| POS Screen | ✅ | ✅ | ✅ | ✅ | ✅ |
| Kanban Board | ✅ | ✅ | ✅ | ✅ | ✅ |
| Trips | ✅ | ✅ | ✅ | ✅ | ✅ |
| Courier Balances | ✅ | ✅ | ✅ | ✅ | ✅ |
| Expenses | ✅ | ✅ | ✅ | ✅ | ✅ |
| Printers | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Master Orders** | ✅ | ✅ | ✅ | ✅ | ❌ |
| Manager Dashboard | ✅ | ✅ | ✅ | ❌ | ❌ |
| Purchase Invoices | ✅ | ✅ | ❌ | ❌ | ❌ |
| Manufacturing | ✅ | ✅ | ❌ | ❌ | ❌ |
| Stock Transfer | ✅ | ✅ | ❌ | ❌ | ❌ |
| Cash Transfer | ✅ | ✅ | ❌ | ❌ | ❌ |
| Inventory Count | ✅ | ✅ | ❌ | ❌ | ❌ |
| Reports | ✅ | ✅ | ❌ | ❌ | ❌ |

> **Master Orders** requires `hasElevatedAccess` = `isJarzManager || isLineManager || isModerator` (or `isHighManagement`).
>
> Manager Dashboard requires `canAccessManagerDashboard` = `isJarzManager || isLineManager` (or `isHighManagement`).
>
> Purchase, Manufacturing, Stock Transfer, Cash Transfer, Inventory Count, and Reports require `isJarzManager` or `isHighManagement`.

---

### 3.2 POS & Checkout

| Action | High Mgmt | Manager | Line Manager | Moderator | Staff |
|--------|:---------:|:-------:|:------------:|:---------:|:-----:|
| View items & bundles | ✅ | ✅ | ✅ | ✅ | ✅ |
| Add items to cart | ✅ | ✅ | ✅ | ✅ | ✅ |
| Change item quantity | ✅ | ✅ | ✅ | ✅ | ✅ |
| Change item rate | ✅ | ✅ | ✅ | ✅ | ✅ |
| Submit invoice (Cash) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Submit invoice (Card) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Submit invoice (Settle Later) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Assign customer | ✅ | ✅ | ✅ | ✅ | ✅ |
| Select delivery slot | ✅ | ✅ | ✅ | ✅ | ✅ |
| Create new customer | ✅ | ✅ | ✅ | ✅ | ✅ |

> All POS operations are available to any user with access to a POS profile. Stock quantity limits are enforced for all users.

---

### 3.3 Kanban Board & Invoice Operations

| Action | High Mgmt | Manager | Line Manager | Moderator | Staff |
|--------|:---------:|:-------:|:------------:|:---------:|:-----:|
| View kanban board | ✅ | ✅ | ✅ | ✅ | ✅ |
| Drag to next status | ✅ | ✅ | ✅ | ✅ | ✅ |
| Preview invoice | ✅ | ✅ | ✅ | ✅ | ✅ |
| Print invoice | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Transfer order** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Cancel order** | ✅ | ✅ | ✅ | ❌ | ❌ |
| Assign delivery partner | ✅ | ✅ | ✅ | ✅ | ✅ |
| Settle courier | ✅ | ✅ | ✅ | ✅ | ✅ |

> **Transfer Order** and **Cancel Order** require `isLineManager` (true for JARZ Manager and JARZ Line Manager) or `isHighManagement`. Cancel Order is also blocked if the invoice has a partial payment.

**Backend enforcement for Cancel Order:**
- Allowed roles: `Administrator`, `JARZ Line Manager`
- Returns error "You are not permitted to cancel orders" for other users

---

### 3.4 Delivery & Trips

| Action | High Mgmt | Manager | Line Manager | Moderator | Staff |
|--------|:---------:|:-------:|:------------:|:---------:|:-----:|
| View trips | ✅ | ✅ | ✅ | ✅ | ✅ |
| Create trip | ✅ | ✅ | ✅ | ✅ | ✅ |
| Add invoices to trip | ✅ | ✅ | ✅ | ✅ | ✅ |
| Send trip for delivery (OFD) | ✅ | ✅ | ✅ | ✅ | ✅ |

> OFD transition requires `Sales User` or `Accounts User` role on the backend. Pickup orders cannot be added to trips.

---

### 3.5 Expenses

| Action | High Mgmt | Manager | Line Manager | Moderator | Staff |
|--------|:---------:|:-------:|:------------:|:---------:|:-----:|
| Create expense | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Approve expense** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Payment sources — all accounts** | ✅ | ✅ | ❌ | ❌ | ❌ |
| Payment sources — own POS profiles | ✅ | ✅ | ✅ | ✅ | ✅ |

> Manager- and High Management-created expenses are **auto-approved** and automatically submitted. Staff-created expenses are created with `requires_approval = 1` and remain in draft until a manager approves them. Mobile Wallet payments always require approval.

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

| Action | High Mgmt | Manager | Line Manager | Moderator | Staff |
|--------|:---------:|:-------:|:------------:|:---------:|:-----:|
| View profile | ✅ | ✅ | ✅ | ✅ | ✅ |
| Change language | ✅ | ✅ | ✅ | ✅ | ✅ |
| Select POS profile | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Mute notifications** | ✅ | ✅ | ✅ | ✅ | ❌ |

> Mute notifications is available when `canMuteNotifications` = `isHighManagement || isJarzManager || isLineManager || isModerator`.

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

| Capability | High Mgmt | Manager | Line Manager | Moderator | Staff |
|------------|:---------:|:-------:|:------------:|:---------:|:-----:|
| POS (create invoices) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Kanban (view & transition) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Trips & Delivery | ✅ | ✅ | ✅ | ✅ | ✅ |
| Expenses (create) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Printing | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Master Orders** | ✅ | ✅ | ✅ | ✅ | ❌ |
| Mute Notifications | ✅ | ✅ | ✅ | ✅ | ❌ |
| Cancel / Transfer orders | ✅ | ✅ | ✅ | ❌ | ❌ |
| Manager Dashboard | ✅ | ✅ | ✅ | ❌ | ❌ |
| Cash Transfer | ✅ | ✅ | ❌ | ❌ | ❌ |
| Stock Transfer | ✅ | ✅ | ❌ | ❌ | ❌ |
| Purchase Invoices | ✅ | ✅ | ❌ | ❌ | ❌ |
| Manufacturing | ✅ | ✅ | ❌ | ❌ | ❌ |
| Inventory Count | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Reports** | ✅ | ✅ | ❌ | ❌ | ❌ |
| Approve Expenses | ✅ | ✅ | ❌ | ❌ | ❌ |
| All POS profiles (no assignment) | ✅ | ❌ | ❌ | ❌ | ❌ |

---

## 5. Role Profiles & Module Profiles

Reusable templates created on staging for assigning roles to new users:

### Role Profiles

| Role Profile | Roles Included |
|-------------|---------------|
| **Jarz POS Staff** | POS User, Sales User, Accounts User |
| **Jarz POS Moderator** | POS User, Sales User, Accounts User, Moderator |
| **Jarz POS Line Manager** | POS User, Sales User, Accounts User, Moderator, JARZ line manager |
| **Jarz POS Manager** | POS User, Sales User, Accounts User, Moderator, JARZ line manager, JARZ Manager, POS Manager, Accounts Manager, Stock Manager, Manufacturing Manager, Purchase Manager, Stock User, Manufacturing User, Purchase User, Item Manager |

### Module Profiles

| Module Profile | Modules Allowed |
|---------------|----------------|
| **Jarz POS Staff Modules** | Selling, Stock, Accounts, Setup, jarz pos, Desk, Core |
| **Jarz POS Manager Modules** | Selling, Stock, Accounts, Setup, jarz pos, Desk, Core, Manufacturing, Buying |

### Assignment Guide

| User Tier | Role Profile | Module Profile |
|-----------|-------------|---------------|
| Staff | Jarz POS Staff | Jarz POS Staff Modules |
| Moderator | Jarz POS Moderator | Jarz POS Staff Modules |
| Line Manager | Jarz POS Line Manager | Jarz POS Staff Modules |
| Manager | Jarz POS Manager | Jarz POS Manager Modules |

> After assigning the Role Profile and Module Profile, also assign the user to the correct POS Profile(s) via the **POS Profile User** child table on each POS Profile.

---

## 6. Backend Enforcement

Backend API permission gates that were verified/fixed (commits `92798ac` and `f762838`):

| API Module | Gate Function | Allowed Roles | What it protects |
|-----------|--------------|--------------|-----------------|
| `manager.py` | `_ensure_manager_dashboard_access()` | `ROLES.ADMIN` ∪ `{JARZ Manager}` | Dashboard summary, orders, states, branch update |
| `manufacturing.py` | `_ensure_manager_access()` | `ROLES.MANUFACTURING` | BOM list, BOM details, work order submission |
| `orders.py` | `_ensure_elevated_access()` | `JARZ Manager`, `JARZ line manager`, `Moderator`, `System Manager`, `Administrator` | Master Orders list |
| `expenses.py` | (profile-based) | Any user with POS Profile | Expense bootstrap, month list |
| `purchase.py` | `_ensure_purchase_access()` | `ROLES.PURCHASE` | Supplier list, PO submission |
| `stock_transfer.py` | `_ensure_manager_access()` | `ROLES.MANAGER` | Transfer profiles, item search, submission |
| `cash_transfer.py` | `_ensure_manager_access()` | `ROLES.MANAGER` | Account list, transfer submission |
| `inventory.py` | `_ensure_stock_access()` | `ROLES.STOCK` | Warehouse list, stock reconciliation |
| `reports.py` | `_ensure_manager_access()` | `ROLES.MANAGER` | All report endpoints |
