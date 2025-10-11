# Jarz POS Mobile

A comprehensive Point of Sale (POS) mobile application built with Flutter for managing sales, inventory, and operations.

## Features

- 🛒 **POS System**: Complete point of sale with cart management, customer selection, and checkout
- 📊 **Kanban Board**: Visual sales invoice management with drag-and-drop functionality
- 💰 **Cash Transfers**: Manage cash movements between accounts
- 📦 **Stock Transfers**: Transfer inventory between warehouses
- 🏭 **Manufacturing**: Create and manage work orders
- 🛍️ **Purchase Management**: Handle purchase invoices and supplier management
- 📈 **Inventory Count**: Stock reconciliation and counting features
- 🔌 **Offline Support**: Queue transactions when offline and sync when connected
- 🖨️ **Printing**: Receipt printing via Bluetooth thermal printers

## Getting Started

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Android Studio / Xcode for mobile development
- ERPNext backend server

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure environment variables (see `ENVIRONMENT_SETUP.md`)

4. Run the app:
   ```bash
   flutter run --dart-define=ENV=local
   ```

## Testing

This project has a comprehensive test suite covering all major functionality.

### Run Tests
```bash
flutter test
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

For detailed testing information, see:
- [Test README](test/README.md) - Quick start guide for running tests
- [Test Documentation](test/TEST_DOCUMENTATION.md) - Comprehensive test suite documentation

## Documentation

> 📑 **[Documentation Index](DOCUMENTATION_INDEX.md)** - Complete guide to all documentation

### 📊 Flow Diagrams & Quick Reference
- **[Flow Diagrams Quick Reference](FLOW_DIAGRAMS_QUICK_REFERENCE.md)** - 🎯 **START HERE** - Visual overview of all flows
- [POS Flow Documentation](POS_FLOW_DOCUMENTATION.md) - Complete POS workflow with diagrams
- [Kanban Flow Documentation](KANBAN_FLOW_DOCUMENTATION.md) - Complete Kanban workflow with all scenarios

### 🏗️ Architecture
- [System Architecture](SYSTEM_ARCHITECTURE.md) - System design, components, and data flows

### 📚 Feature Documentation
- [Environment Setup](ENVIRONMENT_SETUP.md) - Configure environments (local/staging/production)
- [Kanban Board](KANBAN_README.md) - Kanban feature technical documentation
- [Business Documentation](BUSINESS_DOCUMENTATION.md) - Business rules and processes
- [User Manual](USER_MANUAL.md) - End-user guide
- [Invoice Scenarios](INVOICE_SCENARIOS_README.md) - Test coverage for invoice scenarios

## Architecture

The app follows clean architecture principles with:
- **Features**: Organized by business domain (auth, pos, kanban, etc.)
- **Core**: Shared utilities, services, and infrastructure
- **State Management**: Riverpod for reactive state management
- **Routing**: GoRouter for declarative navigation
- **Offline Support**: Hive for local storage and offline queue

## Project Structure

```
lib/
├── src/
│   ├── core/           # Shared core functionality
│   │   ├── network/    # API clients and networking
│   │   ├── offline/    # Offline queue management
│   │   ├── session/    # Session management
│   │   └── ...
│   └── features/       # Feature modules
│       ├── auth/       # Authentication
│       ├── pos/        # Point of Sale
│       ├── kanban/     # Kanban board
│       └── ...
test/
├── core/              # Core service tests
├── features/          # Feature tests
├── integration/       # Integration tests
└── helpers/           # Test utilities
```

## Contributing

1. Follow the existing code structure and patterns
2. Write tests for new features
3. Ensure all tests pass before submitting PRs
4. Follow Flutter/Dart best practices

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [ERPNext API Documentation](https://frappeframework.com/docs)
