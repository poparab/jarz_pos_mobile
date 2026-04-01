# Jarz POS App — Feature List

## 1. Authentication and Access

- User login and logout
- Session persistence and session expiry handling
- Role-based access controls (Manager, Line Manager, Moderator, Staff)
- POS profile based access gating

## 2. POS Profile and Shift Control

- POS profile selection per user permissions
- Shift-required flow before POS access (when enabled)
- Shift start with opening amounts
- Shift end with closing reconciliation
- Shift discrepancy handling with over/short logic

## 3. POS Selling Interface

- Category-based item browsing
- Item and bundle listing with counts
- Search for items
- Item image support
- Real-time cart totals and recalculation

## 4. Cart and Pricing

- Add/remove items and bundles
- Increase/decrease item quantities
- Editable item rates before checkout
- Bundle details grouped by item and quantity
- Empty cart and state handling
- Stock quantity limit enforcement

## 5. Customer Management

- Customer search by name or phone
- Assign customer to invoice
- Create new customer from POS
- Optional secondary phone number on customer creation
- Territory selection during customer creation

## 6. Checkout and Payments

- Cash payment
- Card payment
- Settle later (credit) payment mode
- Split/partial payment handling
- Overpayment and change handling
- Rounding logic in totals
- Duplicate payment protection

## 7. Delivery and Order Type Handling

- Delivery vs pickup order flows
- Delivery slot selection (start and end)
- Delivery duration calculation from slot
- Delivery charge behavior based on bundle/free shipping rules
- Sales partner-specific behavior for address/delivery logic

## 8. Kanban Order Management

- Multi-column kanban board for order lifecycle
- Drag-and-drop state transitions with rule checks
- Invoice card details and status badges
- Real-time updates and polling refresh
- Restricted transitions for payment/shipping constraints

## 9. Kanban Card Actions

- Invoice preview
- Invoice print
- Transfer order (role-restricted)
- Cancel order (role and payment-state restricted)
- Courier settlement actions

## 10. Delivery Partners and Courier Operations

- Delivery partner assignment (employee and supplier)
- Courier balances view
- Courier settlement workflow
- Out-for-delivery transition controls

## 11. Trip Management

- Trip creation with multiple invoices
- Add/remove invoices to trips
- Send trip for delivery in bulk
- Multi-territory trip handling rules
- Pickup order exclusion from delivery trip flow

## 12. Receipt Printing

- Bluetooth thermal printer discovery and connection
- ESC/POS receipt printing
- Arabic and English receipt output support
- Bundle representation on printed receipts
- Print from POS and from Kanban
- Printer error handling and resilience

## 13. Expenses Module

- Create expense requests from mobile app
- Manager auto-approval behavior
- Staff approval-required expense flow
- Expense approval action (manager only)
- Payment source selection based on role and profile scope

## 14. Manager and Backoffice Mobile Features

- Manager dashboard and summary analytics
- Purchase invoice flow (manager access)
- Manufacturing flow with BOM/work order submission
- Stock transfer flow between warehouses
- Cash transfer flow between accounts
- Inventory count and reconciliation flow

## 15. Notifications and User Settings

- Push/realtime notifications for order activity
- Mute notifications setting (role-gated)
- User profile management
- POS profile switching

## 16. Localization and UX

- English and Arabic language support
- RTL support for Arabic
- Language preference persistence
- Locale-aware UI and printed content

## 17. Reliability and Operational Safeguards

- Network error handling for API actions
- Validation for restricted actions and invalid transitions
- Concurrency protections for sensitive payment actions
- Document creation safeguards in critical workflows

## 18. ERPNext Integrations Used by the App

- Selling and POS
- Accounts
- Stock
- Buying
- Manufacturing
- CRM
- User and role permission framework

---

This file is a product-level feature inventory. For step-by-step validation cases, use [TESTING_SCENARIOS.md](TESTING_SCENARIOS.md).