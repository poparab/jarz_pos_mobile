# Jarz POS Mobile - System Architecture Diagram

## Overview

This document provides a visual representation of the Jarz POS Mobile system architecture, showing how components interact and data flows through the application.

---

## High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        JARZ POS MOBILE SYSTEM                               │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION LAYER                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌───────────────────┐          ┌───────────────────┐                     │
│   │   POS Screen      │          │  Kanban Screen    │                     │
│   │                   │          │                   │                     │
│   │ • Profile Select  │◄────────►│ • Board View      │                     │
│   │ • Customer Search │  Navigation │ • Drag & Drop   │                     │
│   │ • Cart Management │          │ • State Updates   │                     │
│   │ • Checkout        │          │ • Filters         │                     │
│   └─────────┬─────────┘          └─────────┬─────────┘                     │
│             │                               │                               │
│             │         ┌─────────────────────┴──┐                            │
│             │         │                        │                            │
│   ┌─────────▼─────────▼─────┐      ┌──────────▼────────┐                   │
│   │  Shared Components      │      │  Common Widgets   │                   │
│   │  • App Drawer           │      │  • Dialogs        │                   │
│   │  • Branch Filter        │      │  • Snackbars      │                   │
│   │  • Printer Status       │      │  • Error Handling │                   │
│   └─────────────────────────┘      └───────────────────┘                   │
│                                                                             │
└─────────────────────────────────────┬───────────────────────────────────────┘
                                      │
┌─────────────────────────────────────▼───────────────────────────────────────┐
│                          STATE MANAGEMENT LAYER                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌──────────────────────┐              ┌──────────────────────┐           │
│   │  POS State Provider  │              │ Kanban State Provider│           │
│   │  (Riverpod)          │              │ (Riverpod)           │           │
│   │                      │              │                      │           │
│   │ • profiles[]         │              │ • columns[]          │           │
│   │ • selectedProfile    │              │ • invoices{}         │           │
│   │ • items[]            │              │ • filters            │           │
│   │ • bundles[]          │              │ • selectedBranches   │           │
│   │ • cartItems[]        │              │ • transitioningInvs  │           │
│   │ • selectedCustomer   │              │                      │           │
│   │ • selectedSlot       │              │                      │           │
│   │ • isPickup           │              │                      │           │
│   └──────────┬───────────┘              └──────────┬───────────┘           │
│              │                                     │                       │
│              └─────────────┬───────────────────────┘                       │
│                            │                                               │
└────────────────────────────┼───────────────────────────────────────────────┘
                             │
┌────────────────────────────▼───────────────────────────────────────────────┐
│                          BUSINESS LOGIC LAYER                              │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│   ┌──────────────────────┐              ┌──────────────────────┐          │
│   │  POS Repository      │              │ Kanban Service       │          │
│   │                      │              │                      │          │
│   │ • getProfiles()      │              │ • getColumns()       │          │
│   │ • getItems()         │              │ • getInvoices()      │          │
│   │ • getBundles()       │              │ • updateState()      │          │
│   │ • searchCustomers()  │              │ • getPreview()       │          │
│   │ • createCustomer()   │              │ • handleOFD()        │          │
│   │ • createInvoice()    │              │ • settle()           │          │
│   │ • payInvoice()       │              │                      │          │
│   └──────────┬───────────┘              └──────────┬───────────┘          │
│              │                                     │                      │
│              └─────────────┬───────────────────────┘                      │
│                            │                                              │
└────────────────────────────┼──────────────────────────────────────────────┘
                             │
┌────────────────────────────▼──────────────────────────────────────────────┐
│                           CORE SERVICES LAYER                             │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌───────────────┐  ┌──────────────┐  ┌─────────────┐  ┌──────────────┐ │
│  │ Network       │  │ Offline      │  │ WebSocket   │  │ Connectivity │ │
│  │ Service (Dio) │  │ Queue        │  │ Service     │  │ Service      │ │
│  │               │  │              │  │             │  │              │ │
│  │ • HTTP Client │  │ • Queue Txns │  │ • Real-time │  │ • Monitor    │ │
│  │ • Interceptor │  │ • Auto-Sync  │  │   Updates   │  │   Network    │ │
│  │ • Session Mgmt│  │ • Retry      │  │ • Reconnect │  │ • Online/Off │ │
│  └───────┬───────┘  └──────┬───────┘  └──────┬──────┘  └──────┬───────┘ │
│          │                 │                  │                │         │
│          └─────────────────┴──────────────────┴────────────────┘         │
│                            │                                              │
└────────────────────────────┼──────────────────────────────────────────────┘
                             │
┌────────────────────────────▼──────────────────────────────────────────────┐
│                         DATA PERSISTENCE LAYER                            │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│   ┌──────────────────────────────┐      ┌──────────────────────────────┐ │
│   │   Hive (Local Storage)       │      │   Session Storage           │ │
│   │                              │      │                             │ │
│   │ • Offline Queue              │      │ • Auth Token                │ │
│   │ • Cached Data                │      │ • User Session              │ │
│   │ • Filter Preferences         │      │ • Cookies                   │ │
│   │ • App Settings               │      │                             │ │
│   └──────────────────────────────┘      └─────────────────────────────┘ │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
                             │
                             │ API Calls
                             ▼
┌───────────────────────────────────────────────────────────────────────────┐
│                           BACKEND (ERPNext)                               │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐    │
│  │                      API ENDPOINTS                               │    │
│  ├──────────────────────────────────────────────────────────────────┤    │
│  │                                                                  │    │
│  │  POS APIs:                      Kanban APIs:                    │    │
│  │  • get_pos_profiles             • get_kanban_columns            │    │
│  │  • get_profile_products         • get_kanban_invoices           │    │
│  │  • get_profile_bundles          • update_invoice_state          │    │
│  │  • search_customers             • get_invoice_details           │    │
│  │  • create_customer                                              │    │
│  │  • create_pos_invoice           Settlement APIs:                │    │
│  │                                 • get_settlement_preview         │    │
│  │  Customer APIs:                 • handle_ofd_transition          │    │
│  │  • get_territories              • settle_courier_collected       │    │
│  │  • create_customer              • settle_single_invoice_paid     │    │
│  │                                 • sales_partner_ofd (paid/unpaid)│    │
│  └──────────────────────────────────────────────────────────────────┘    │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐    │
│  │                   REAL-TIME (WebSocket/SocketIO)                 │    │
│  ├──────────────────────────────────────────────────────────────────┤    │
│  │                                                                  │    │
│  │  Events:                                                         │    │
│  │  • kanban_state_changed                                          │    │
│  │  • payment_collected                                             │    │
│  │  • settlement_completed                                          │    │
│  │  • courier_updated                                               │    │
│  └──────────────────────────────────────────────────────────────────┘    │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐    │
│  │                        DATABASE                                  │    │
│  ├──────────────────────────────────────────────────────────────────┤    │
│  │                                                                  │    │
│  │  DocTypes:                                                       │    │
│  │  • Sales Invoice (with custom field: sales_invoice_state)       │    │
│  │  • POS Profile                                                   │    │
│  │  • Customer                                                      │    │
│  │  • Item                                                          │    │
│  │  • Bundle                                                        │    │
│  │  • Payment Entry                                                 │    │
│  │  • Delivery Note                                                 │    │
│  │  • Courier Transaction                                           │    │
│  │  • Territory                                                     │    │
│  │  • Sales Partner                                                 │    │
│  └──────────────────────────────────────────────────────────────────┘    │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Diagrams

### 1. POS Invoice Creation Flow

```
┌─────────┐      ┌──────────┐      ┌────────────┐      ┌──────────┐
│  User   │─────►│   POS    │─────►│    POS     │─────►│ ERPNext  │
│         │      │  Screen  │      │ Repository │      │  Backend │
└─────────┘      └──────────┘      └────────────┘      └──────────┘
                       │                   │                  │
                       │ 1. Build Cart     │                  │
                       │◄──────────────────┤                  │
                       │                   │                  │
                       │ 2. Select         │                  │
                       │    Customer       │                  │
                       │◄──────────────────┤                  │
                       │                   │                  │
                       │ 3. Checkout       │                  │
                       │──────────────────►│                  │
                       │                   │                  │
                       │                   │ 4. Create        │
                       │                   │    Invoice API   │
                       │                   ├─────────────────►│
                       │                   │                  │
                       │                   │ 5. Invoice Data  │
                       │                   │◄─────────────────┤
                       │                   │                  │
                       │ 6. Invoice        │                  │
                       │    Created        │                  │
                       │◄──────────────────┤                  │
                       │                   │                  │
                       │ 7. Show Success   │                  │
                       │    + Print        │                  │
                       │                   │                  │
```

### 2. Kanban State Update Flow

```
┌─────────┐      ┌──────────┐      ┌────────────┐      ┌──────────┐
│  User   │─────►│  Kanban  │─────►│   Kanban   │─────►│ ERPNext  │
│         │      │  Board   │      │  Service   │      │  Backend │
└─────────┘      └──────────┘      └────────────┘      └──────────┘
                       │                   │                  │
                       │ 1. Drag Invoice   │                  │
                       │    to New Column  │                  │
                       │                   │                  │
                       │ 2. Optimistic     │                  │
                       │    Update (UI)    │                  │
                       │                   │                  │
                       │ 3. Update State   │                  │
                       │──────────────────►│                  │
                       │                   │                  │
                       │                   │ 4. Update API    │
                       │                   ├─────────────────►│
                       │                   │                  │
                       │                   │ 5. Success       │
                       │                   │◄─────────────────┤
                       │                   │                  │
                       │                   │ 6. WebSocket     │
                       │◄──────────────────┼──────────────────┤
                       │   Broadcast       │   publish_realtime
                       │                   │                  │
                       │ 7. Update All     │                  │
                       │    Clients        │                  │
                       │                   │                  │
```

### 3. Out for Delivery (OFD) Transition Flow

```
┌─────────┐      ┌──────────┐      ┌────────────┐      ┌──────────┐
│  User   │─────►│  Kanban  │─────►│   Kanban   │─────►│ ERPNext  │
│         │      │  Board   │      │  Service   │      │  Backend │
└─────────┘      └──────────┘      └────────────┘      └──────────┘
                       │                   │                  │
                       │ 1. Drag to OFD    │                  │
                       │                   │                  │
                       │ 2. Show Dialog    │                  │
                       │    • Courier      │                  │
                       │    • Pay Now/Later│                  │
                       │◄──────────────────┤                  │
                       │                   │                  │
                       │ 3. User Confirms  │                  │
                       │──────────────────►│                  │
                       │                   │                  │
                       │                   │ 4. Get Preview   │
                       │                   ├─────────────────►│
                       │                   │                  │
                       │                   │ 5. Preview Data  │
                       │                   │◄─────────────────┤
                       │                   │                  │
                       │ 6. Show Preview   │                  │
                       │◄──────────────────┤                  │
                       │                   │                  │
                       │ 7. Confirm        │                  │
                       │──────────────────►│                  │
                       │                   │                  │
                       │                   │ 8. Handle OFD    │
                       │                   │    Transition    │
                       │                   ├─────────────────►│
                       │                   │                  │
                       │                   │ 9. Creates:      │
                       │                   │    • DN          │
                       │                   │    • Payment     │
                       │                   │    • Settlement  │
                       │                   │◄─────────────────┤
                       │                   │                  │
                       │ 10. Success +     │                  │
                       │     WebSocket     │                  │
                       │◄──────────────────┼──────────────────┤
                       │     Broadcast     │                  │
                       │                   │                  │
```

### 4. Offline Queue Sync Flow

```
┌─────────┐      ┌──────────┐      ┌────────────┐      ┌──────────┐
│  User   │─────►│   POS    │─────►│  Offline   │─────►│ ERPNext  │
│         │      │  Screen  │      │   Queue    │      │  Backend │
└─────────┘      └──────────┘      └────────────┘      └──────────┘
                       │                   │                  │
                       │ 1. Checkout       │                  │
                       │    (Offline)      │                  │
                       │──────────────────►│                  │
                       │                   │                  │
                       │                   │ 2. Queue Txn     │
                       │                   │    (Hive)        │
                       │                   │                  │
                       │ 3. Show Queued    │                  │
                       │    Message        │                  │
                       │◄──────────────────┤                  │
                       │                   │                  │
                       │                   │ 4. Network       │
                       │                   │    Online        │
                       │                   │                  │
                       │                   │ 5. Process Queue │
                       │                   ├─────────────────►│
                       │                   │                  │
                       │                   │ 6. Success       │
                       │                   │◄─────────────────┤
                       │                   │                  │
                       │ 7. Sync Complete  │ 8. Mark Processed│
                       │◄──────────────────┤                  │
                       │    Notification   │                  │
                       │                   │                  │
```

---

## Component Interaction Diagram

```
┌───────────────────────────────────────────────────────────────────────────┐
│                          COMPONENT INTERACTIONS                           │
└───────────────────────────────────────────────────────────────────────────┘

        POS SCREEN                                    KANBAN SCREEN
    ┌──────────────┐                              ┌──────────────────┐
    │              │                              │                  │
    │  • Profile   │                              │  • Columns       │
    │  • Customer  │                              │  • Invoice Cards │
    │  • Cart      │                              │  • Filters       │
    │  • Checkout  │                              │  • Drag & Drop   │
    │              │                              │                  │
    └──────┬───────┘                              └────────┬─────────┘
           │                                               │
           │ ref.read/watch                                │ ref.read/watch
           ▼                                               ▼
    ┌──────────────┐                              ┌──────────────────┐
    │ PosNotifier  │                              │ KanbanNotifier   │
    │ (StateNotif) │                              │ (StateNotifier)  │
    └──────┬───────┘                              └────────┬─────────┘
           │                                               │
           │ calls                                         │ calls
           ▼                                               ▼
    ┌──────────────┐                              ┌──────────────────┐
    │PosRepository │                              │ KanbanService    │
    └──────┬───────┘                              └────────┬─────────┘
           │                                               │
           │ uses                                          │ uses
           └───────────────┬───────────────────────────────┘
                           ▼
                    ┌──────────────┐
                    │ Dio Provider │
                    │ (HTTP Client)│
                    └──────┬───────┘
                           │
                           │ API calls
                           ▼
                    ┌──────────────┐
                    │   ERPNext    │
                    │   Backend    │
                    └──────────────┘

                    SHARED SERVICES
                    ┌──────────────────────────────────────┐
                    │                                      │
                    │  • WebSocketService (real-time)      │
                    │  • OfflineQueue (sync)               │
                    │  • ConnectivityService (network)     │
                    │  • SessionManager (auth)             │
                    │  • PrinterService (receipts)         │
                    │                                      │
                    └──────────────────────────────────────┘
```

---

## Technology Stack Layers

```
┌───────────────────────────────────────────────────────────────────────────┐
│                            PRESENTATION                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ Flutter UI (Material Design 3)                                      │  │
│  │ • Widgets (Stateless/Stateful)                                      │  │
│  │ • Screens (POS, Kanban, etc.)                                       │  │
│  │ • Dialogs, SnackBars, Sheets                                        │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼───────────────────────────────────────┐
│                         STATE MANAGEMENT                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ Riverpod 2.5.1+                                                     │  │
│  │ • StateNotifier (PosNotifier, KanbanNotifier)                       │  │
│  │ • Provider (Services, Repositories)                                 │  │
│  │ • AsyncNotifier (Async operations)                                  │  │
│  │ • Family Provider (Parameterized providers)                         │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼───────────────────────────────────────┐
│                          BUSINESS LOGIC                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ Repositories & Services                                             │  │
│  │ • PosRepository (POS operations)                                    │  │
│  │ • KanbanService (Kanban operations)                                 │  │
│  │ • CourierRepository (Courier management)                            │  │
│  │ • Data Models (Freezed classes)                                     │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼───────────────────────────────────────┐
│                           CORE SERVICES                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ • Dio 5.9.0+ (HTTP Client)                                          │  │
│  │ • WebSocketService (Real-time)                                      │  │
│  │ • OfflineQueue (Hive-based)                                         │  │
│  │ • ConnectivityService                                               │  │
│  │ • SessionManager                                                    │  │
│  │ • PrinterService                                                    │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼───────────────────────────────────────┐
│                        DATA PERSISTENCE                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ • Hive 2.2.3+ (NoSQL local DB)                                      │  │
│  │ • Secure Storage (Cookies, Tokens)                                  │  │
│  │ • Shared Preferences (Settings)                                     │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼───────────────────────────────────────┐
│                             ROUTING                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ GoRouter 16.2.0+                                                    │  │
│  │ • Declarative Routing                                               │  │
│  │ • Deep Linking                                                      │  │
│  │ • Navigation Guards                                                 │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼───────────────────────────────────────┐
│                           PLATFORM                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ Flutter 3.8.1+ / Dart 3.8.1+                                        │  │
│  │ • Android, iOS, Desktop                                             │  │
│  │ • Platform Channels (Native Integration)                            │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────┘
```

---

## Feature Module Architecture

```
┌───────────────────────────────────────────────────────────────────────────┐
│                     FEATURE MODULE STRUCTURE                              │
└───────────────────────────────────────────────────────────────────────────┘

lib/src/features/
│
├── auth/                          # Authentication Feature
│   ├── data/                      # Data Layer
│   │   ├── repositories/          # Data sources
│   │   └── models/                # DTOs
│   ├── domain/                    # Domain Layer
│   │   └── models/                # Entities
│   ├── state/                     # State Management
│   │   └── auth_provider.dart
│   └── presentation/              # UI Layer
│       ├── screens/
│       └── widgets/
│
├── pos/                           # POS Feature
│   ├── data/
│   │   ├── repositories/
│   │   │   └── pos_repository.dart
│   │   └── models/
│   │       ├── pos_models.dart
│   │       └── pos_cart_item.dart
│   ├── domain/
│   │   └── models/
│   │       └── delivery_slot.dart
│   ├── state/
│   │   ├── pos_notifier.dart
│   │   └── courier_balances_provider.dart
│   └── presentation/
│       ├── screens/
│       │   ├── pos_home_screen.dart
│       │   └── pos_screen.dart
│       └── widgets/
│           ├── cart_widget.dart
│           ├── customer_search_widget.dart
│           └── checkout_button_widget.dart
│
├── kanban/                        # Kanban Feature
│   ├── models/
│   │   ├── kanban_models.dart
│   │   └── kanban_filter_options.dart
│   ├── services/
│   │   ├── kanban_service.dart
│   │   └── notification_polling_service.dart
│   ├── providers/
│   │   └── kanban_provider.dart
│   ├── screens/
│   │   └── kanban_board_screen.dart
│   └── widgets/
│       ├── kanban_column_widget.dart
│       ├── invoice_card_widget.dart
│       ├── kanban_filters_widget.dart
│       └── settlement_preview_dialog.dart
│
└── printing/                      # Printing Feature
    ├── pos_printer_provider.dart
    └── printer_status.dart

lib/src/core/                      # Shared Core
├── network/
│   ├── dio_provider.dart          # Shared Dio instance
│   └── courier_service.dart
├── offline/
│   └── offline_queue.dart         # Offline sync
├── websocket/
│   └── websocket_service.dart     # Real-time
├── connectivity/
│   └── connectivity_service.dart  # Network monitoring
├── session/
│   └── session_manager.dart       # Auth sessions
├── router.dart                    # App routing
└── widgets/
    ├── app_drawer.dart            # Shared navigation
    └── branch_filter_dialog.dart  # Shared filters
```

---

## Security & Authentication Flow

```
┌───────────────────────────────────────────────────────────────────────────┐
│                       AUTHENTICATION FLOW                                 │
└───────────────────────────────────────────────────────────────────────────┘

    ┌─────────┐
    │  User   │
    └────┬────┘
         │
         │ 1. Login (username/password)
         ▼
    ┌────────────────┐
    │  Auth Screen   │
    └────┬───────────┘
         │
         │ 2. Submit credentials
         ▼
    ┌────────────────┐
    │ Auth Repository│
    └────┬───────────┘
         │
         │ 3. POST /api/method/login
         ▼
    ┌────────────────┐
    │  ERPNext       │
    │  Backend       │
    └────┬───────────┘
         │
         │ 4. Validate & Create Session
         ▼
    ┌────────────────┐
    │ Session Cookie │  ◄── Set-Cookie header
    │ (sid)          │
    └────┬───────────┘
         │
         │ 5. Store in Dio
         ▼
    ┌────────────────┐
    │ SessionManager │
    └────┬───────────┘
         │
         │ 6. Auto-attach to all requests
         ▼
    ┌────────────────┐
    │ Dio Interceptor│  ◄── Cookie: sid=...
    └────┬───────────┘
         │
         │ 7. Navigate to POS/Kanban
         ▼
    ┌────────────────┐
    │  App Screens   │
    └────────────────┘

SECURITY FEATURES:
├─ Cookie-based sessions (HTTP-only)
├─ Automatic session refresh
├─ Secure token storage
├─ Session timeout handling
└─ Logout and cleanup
```

---

## Deployment Architecture

```
┌───────────────────────────────────────────────────────────────────────────┐
│                        DEPLOYMENT DIAGRAM                                 │
└───────────────────────────────────────────────────────────────────────────┘

                        MOBILE DEVICES
        ┌─────────────────────────────────────────────┐
        │                                             │
        │  ┌──────────┐         ┌──────────┐         │
        │  │ Android  │         │   iOS    │         │
        │  │  Tablet  │         │  Tablet  │         │
        │  │          │         │          │         │
        │  │  APK     │         │  IPA     │         │
        │  └────┬─────┘         └─────┬────┘         │
        │       │                     │              │
        └───────┼─────────────────────┼──────────────┘
                │                     │
                │ WiFi/Cellular       │
                ▼                     ▼
        ┌───────────────────────────────────┐
        │         LOAD BALANCER             │
        │        (SSL Termination)          │
        └────────────────┬──────────────────┘
                         │
                         │ HTTPS
                         ▼
        ┌─────────────────────────────────────┐
        │       APPLICATION SERVER            │
        │                                     │
        │  ┌──────────────────────────────┐   │
        │  │     ERPNext Backend          │   │
        │  │     (Frappe Framework)       │   │
        │  │                              │   │
        │  │  • REST API Endpoints        │   │
        │  │  • Business Logic            │   │
        │  │  • Authentication            │   │
        │  └──────────────────────────────┘   │
        │                                     │
        │  ┌──────────────────────────────┐   │
        │  │     WebSocket Server         │   │
        │  │     (SocketIO)               │   │
        │  │                              │   │
        │  │  • Real-time Updates         │   │
        │  │  • Pub/Sub Events            │   │
        │  └──────────────────────────────┘   │
        │                                     │
        └─────────────────┬───────────────────┘
                          │
                          │
                          ▼
        ┌─────────────────────────────────────┐
        │       DATABASE SERVER               │
        │                                     │
        │  ┌──────────────────────────────┐   │
        │  │  PostgreSQL / MariaDB        │   │
        │  │                              │   │
        │  │  • Sales Invoices            │   │
        │  │  • Customers                 │   │
        │  │  • Items & Bundles           │   │
        │  │  • Payment Entries           │   │
        │  │  • Courier Transactions      │   │
        │  └──────────────────────────────┘   │
        │                                     │
        └─────────────────────────────────────┘

INFRASTRUCTURE:
├─ Cloud: AWS / Azure / Google Cloud
├─ CDN: Static assets & images
├─ Backup: Automated daily backups
├─ Monitoring: Uptime & performance
└─ Scaling: Horizontal scaling for app servers
```

---

## Related Documentation

- [Flow Diagrams Quick Reference](FLOW_DIAGRAMS_QUICK_REFERENCE.md)
- [POS Flow Documentation](POS_FLOW_DOCUMENTATION.md)
- [Kanban Flow Documentation](KANBAN_FLOW_DOCUMENTATION.md)
- [Documentation Index](DOCUMENTATION_INDEX.md)
- [README](README.md)

---

**Last Updated**: 2024-01-15  
**Version**: 1.0  
**Status**: System Architecture Documentation
