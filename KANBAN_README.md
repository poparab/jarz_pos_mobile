# Jarz POS - Kanban Board Implementation

## Overview
This implementation provides a complete Kanban board system for managing Sales Invoice states in the Jarz POS system. The system consists of both backend ERPNext API endpoints and a Flutter frontend with real-time updates.

## Features
- ✅ **Drag and Drop**: Move invoices between states by dragging cards
- ✅ **Real-time Updates**: Changes are broadcast to all users instantly
- ✅ **Collapsible Cards**: Click cards to expand and see detailed information
- ✅ **Advanced Filtering**: Filter by date range, customer, status, and amount
- ✅ **Responsive Design**: Works on different screen sizes
- ✅ **State Management**: Uses Riverpod for efficient state management
- ✅ **Error Handling**: Comprehensive error handling and loading states

## Backend Implementation

### API Endpoints
Located in: `c:\ERPNext\frappe_docker\development\frappe-bench\apps\jarz_pos\jarz_pos\api\kanban.py`

1. **get_kanban_columns()** - Get all available invoice states as columns
2. **get_kanban_invoices(filters)** - Get invoices organized by state with filtering
3. **update_invoice_state(invoice_id, new_state)** - Update invoice state and broadcast changes
4. **get_invoice_details(invoice_id)** - Get detailed invoice information
5. **get_kanban_filters()** - Get available filter options

### Database Requirements
- **Custom Field**: `sales_invoice_state` field on Sales Invoice DocType
- **Field Type**: Select with options: Received, Processing, Preparing, Out for delivery, Completed
- **Permissions**: Field allows changes on submitted documents (`allow_on_submit = 1`)

### Real-time Updates
Uses Frappe's `publish_realtime()` to broadcast state changes to all connected users.

## Frontend Implementation

### File Structure
```
lib/src/features/kanban/
├── models/
│   └── kanban_models.dart          # Data models
├── services/
│   └── kanban_service.dart         # API service layer
├── providers/
│   └── kanban_provider.dart        # Riverpod state management
├── screens/
│   └── kanban_board_screen.dart    # Main Kanban screen
└── widgets/
    ├── kanban_column_widget.dart   # Column widget with drag/drop
    ├── invoice_card_widget.dart    # Collapsible invoice cards
    └── kanban_filters_widget.dart  # Filter interface
```

### Key Components

#### 1. KanbanBoardScreen
- Main screen with filters and column layout
- Handles navigation and error states
- Responsive horizontal scrolling for columns

#### 2. KanbanColumnWidget
- Drag target for dropping cards
- Shows column name and invoice count
- Handles empty states

#### 3. InvoiceCardWidget
- Collapsible card with smooth animations
- Shows invoice summary and detailed information
- Drag source for moving between columns

#### 4. KanbanFiltersWidget
- Advanced filtering interface
- Date range picker, customer selection, status filters
- Amount range filtering

#### 5. KanbanProvider
- Riverpod state management
- WebSocket integration for real-time updates
- Optimistic updates for better UX

## Navigation Integration

### App Drawer
Added navigation drawer to POS screens with Kanban board access:
- Location: `lib/src/core/widgets/app_drawer.dart`
- Integrated in: `pos_home_screen.dart`

### Router Configuration
- Route: `/kanban`
- Navigation: `context.go('/kanban')`

## API Communication

### Base URLs
- Backend API: `http://localhost:8001/api/method/jarz_pos.jarz_pos.api.kanban.*`
- WebSocket: `ws://localhost:8001/kanban/updates` (for real-time updates)

### Response Format
All API endpoints return:
```json
{
  "success": true|false,
  "data": {...},
  "error": "error message if failed"
}
```

## Setup Instructions

### 1. Backend Setup
1. Custom field `sales_invoice_state` should already exist on Sales Invoice
2. Restart ERPNext: `bench restart`
3. The API endpoints are automatically available

### 2. Frontend Setup
1. Install dependencies: `flutter pub get`
2. Update `.env` file with correct backend URL
3. Run the app: `flutter run -d 5200bee8c09b6705`

### 3. Navigation
1. Open the app
2. Use the navigation drawer (hamburger menu)
3. Tap "Sales Kanban" to access the board

## Usage

### Moving Invoices
1. Drag an invoice card from one column
2. Drop it on another column
3. The state is updated in real-time
4. All users see the change immediately

### Filtering
1. Tap the filter icon in the app bar
2. Set date ranges, customer filters, etc.
3. Filters are applied instantly
4. Clear all filters with the "Clear All" button

### Card Details
1. Tap any invoice card to expand
2. View detailed information, items, totals
3. Use action buttons for view/edit operations

## Error Handling
- Network errors are displayed with retry options
- Invalid states are handled gracefully
- Loading indicators show during operations
- WebSocket reconnection is automatic

## Performance Optimizations
- Efficient Riverpod state management
- Optimistic updates for drag operations
- Lazy loading of invoice details
- Debounced filter updates

## Future Enhancements
- Bulk operations on multiple invoices
- Custom column configurations
- Advanced permissions and user roles
- Export functionality
- Mobile-specific gestures and interactions

## Troubleshooting

### Common Issues
1. **Custom field not found**: Ensure `sales_invoice_state` field exists on Sales Invoice
2. **API errors**: Check ERPNext server is running and accessible
3. **Real-time not working**: Verify WebSocket connection and ports
4. **Filter not working**: Check API response format matches expected structure

### Logs
- Backend errors: Check ERPNext error logs
- Frontend errors: Check Flutter debug console
- Network issues: Check browser developer tools network tab
