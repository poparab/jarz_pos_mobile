# Push Notification Fix - POS Profile Association

## Issue
Push notifications were not arriving for new orders despite the device being successfully registered with FCM (Firebase Cloud Messaging). Investigation revealed that devices were registered without an associated POS Profile, preventing proper notification filtering on the backend.

## Root Cause
The `_registerToken()` method in `order_alert_bridge.dart` was calling `registerDevice()` without passing the `posProfiles` parameter, even though:
1. The backend API expects POS profiles to filter which devices receive notifications
2. The `registerDevice()` method accepts an optional `posProfiles: List<String>?` parameter
3. The app's POS state contains the selected profile information

## Screenshot Evidence
User provided screenshot showing:
- Device successfully registered with FCM token
- **POS Profiles JSON field: empty/null** ← The problem
- Platform: Android
- Device registered but not receiving notifications

## Solution Implemented

### Code Changes
Modified `lib/src/features/pos/order_alert/order_alert_bridge.dart`:

1. **Added Import**:
   ```dart
   import '../state/pos_notifier.dart';
   ```

2. **Updated `_registerToken()` Method**:
   - Reads selected POS profile from `posNotifierProvider`
   - Extracts profile name from state
   - Passes profile name(s) to `registerDevice()` call
   - Added logging for debugging

3. **Enhanced Error Handling**:
   - Warns if no POS profile is selected
   - Logs which profile is being registered
   - Still registers device even without profile (with warning)

### Key Code Snippet
```dart
// Get current POS profile to associate device with it
final posState = _ref.read(posNotifierProvider);
final selectedProfileName = posState.selectedProfile?['name']?.toString();
final posProfiles = selectedProfileName != null ? [selectedProfileName] : <String>[];

if (posProfiles.isEmpty) {
  _logger.warning('No POS profile selected - device registered without profile filter');
} else {
  _logger.info('Registering device with POS profile: ${posProfiles.first}');
}

await _ref
    .read(orderAlertServiceProvider)
    .registerDevice(
      token: token,
      platform: 'Android',
      deviceName: 'Android POS',
      posProfiles: posProfiles.isNotEmpty ? posProfiles : null,
    );
```

## How It Works Now

1. **User Authentication Flow**:
   - User logs in
   - FCM token is obtained
   - Selected POS profile is read from app state
   - Device registration includes POS profile name

2. **Backend Filtering**:
   - Backend stores device FCM token with associated POS profile(s)
   - When new order arrives for a specific POS profile
   - Backend only sends notification to devices registered with that profile

3. **Profile Change Handling**:
   - Currently: device registration happens once at login
   - Future enhancement: could re-register when user switches profiles

## Testing Steps

To verify the fix:

1. **Update the app** with the latest code (commit d32d651)
2. **Uninstall and reinstall** the app OR clear app data (to force fresh device registration)
3. **Log in** to the app
4. **Select a POS profile**
5. **Check device registration** in ERPNext backend:
   - Navigate to the registered device record
   - Verify "POS Profiles JSON" field now contains the selected profile name
6. **Create test order** for that POS profile
7. **Verify push notification** arrives on the device

## Expected Backend Data

After fix, device registration should show:
```json
{
  "token": "fcm-token-here...",
  "platform": "Android",
  "device_name": "Android POS",
  "pos_profiles": "[\"Main Counter\"]"  // ← Now populated!
}
```

## Verification Completed

✅ Flutter analyzer: No issues found
✅ Code committed: `d32d651`
✅ Pushed to repository: `main` branch
✅ Android manifest: All required permissions present
✅ No compilation errors

## Additional Notes

### Permissions Already Configured
The Android manifest already includes all required permissions:
- `POST_NOTIFICATIONS` - For Android 13+ notification permission
- `USE_FULL_SCREEN_INTENT` - For full-screen notification alerts
- `WAKE_LOCK` - To wake device for urgent orders

### FCM Setup Verified
- Firebase messaging service: `JarzFirebaseMessagingService.kt`
- Background message handler: Configured in `main.dart`
- Foreground message listener: Set up in `OrderAlertBridge`
- Notification channel: `jarz_order_alerts` properly configured

### No Other Issues Found
Review of notification system revealed:
- Permission handling: ✅ Properly implemented
- Android native code: ✅ Correctly handles notifications and alarms
- Web fallback: ✅ Browser notifications implemented for web platform
- Error handling: ✅ Comprehensive try-catch blocks

## What User Should Do Next

1. **Deploy the latest code** to your device
2. **Clear the app cache** or reinstall to force device re-registration
3. **Log in and select your POS profile**
4. **Monitor the logs** to confirm registration includes POS profile:
   ```
   INFO: Registering device with POS profile: Main Counter
   INFO: Registered FCM token for username with 1 POS profile(s)
   ```
5. **Test with a real order** to confirm notifications arrive

If notifications still don't arrive after these steps, check:
- Backend logs for notification sending errors
- Network connectivity between device and backend
- FCM token validity in Firebase console
- POS profile name matches exactly between app and backend
