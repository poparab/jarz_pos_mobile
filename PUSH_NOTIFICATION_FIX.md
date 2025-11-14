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

1. **Deferred Registration Until POS Profile Ready**:
   - `_registerToken` now waits for `posNotifierProvider` to expose at least one profile
   - If profiles are not yet loaded, the bridge triggers `loadProfiles()` and retries when ready
   - Registration is deferred (not attempted) until a concrete profile selection exists, preventing empty submissions

2. **Automatic Re-Registration**:
   - Added a listener on `posNotifierProvider` to re-register tokens whenever the user switches POS profiles
   - Cached the last registered token, profile list, and pending registration state to avoid redundant API calls

3. **Platform-Aware Device Metadata**:
   - Device registration now sends platform-specific values (`Android`, `iOS`, `Web`) with friendly device names

4. **Token Cache Enriched With Profile Context**:
   - `OrderAlertController` persists the last profile list in `SharedPreferences`
   - Re-registration is triggered when the profile set changes, even if the FCM token stays the same

### Key Code Snippet
```dart
final profiles = await _waitForPosProfiles();
if (profiles == null || profiles.isEmpty) {
  _logger.warning('POS profile unavailable; deferring device registration');
  _pendingToken = token;
  return;
}

final normalizedProfiles = [...profiles]..sort();
final shouldRegister = force
    ? true
    : await controller.shouldRegisterToken(token, user, normalizedProfiles);

if (!shouldRegister) {
  _logger.debug('Token already registered for $user with profiles $normalizedProfiles');
  return;
}

await _ref.read(orderAlertServiceProvider).registerDevice(
  token: token,
  platform: platformLabel,
  deviceName: deviceName,
  posProfiles: normalizedProfiles,
);
await controller.markTokenRegistered(token, user, normalizedProfiles);
```

## How It Works Now

1. **User Authentication Flow**:
   - User logs in
   - FCM token is obtained
   - Bridge waits for POS profiles to load; if none are ready it prefetches them and retries
   - Once a profile is selected (or auto-selected), device registration includes the profile list

2. **Backend Filtering**:
   - Backend stores device FCM token with associated POS profile(s)
   - When new order arrives for a specific POS profile
   - Backend only sends notification to devices registered with that profile

3. **Profile Change Handling**:
   - Listener re-registers the same token whenever the cashier switches POS profiles
   - Cached metadata in `SharedPreferences` ensures backend is updated only when the profile set actually changes

## Testing Steps

To verify the fix:

1. **Update the app** with the latest code (commit 57b5369+)
2. **Uninstall and reinstall** the app OR clear app data (to force fresh device registration)
3. **Log in** to the app
4. **Select (or confirm) a POS profile**
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
✅ Code committed: `57b5369`, `d32d651`
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

### Background Notification Failure Scenarios & Mitigations
- **POS profile missing or changed** → Deferred registration + automatic re-sync when profile updates
- **Notification permission denied (Android 13+/iOS)** → App prompts via `FirebaseMessaging.requestPermission()`; confirm OS settings if disabled
- **Battery optimizations / Doze mode** → Use full-screen intent, keep `WAKE_LOCK`; advise users to whitelist the app for reliable background delivery
- **Network connectivity loss** → Websocket + periodic polling keep in-app queue synced when network resumes; device re-registers on next successful login
- **FCM token rotation** → `onTokenRefresh` re-registers with current profiles
- **Logged-out state** → Token registration is skipped while logged out and cache cleared to avoid stale associations
- **Backend filter misconfiguration** → Device registration now always carries explicit profile names, making backend filters deterministic

## What User Should Do Next

1. **Deploy the latest code** to your device
2. **Clear the app cache** or reinstall to force device re-registration
3. **Log in and allow the POS profiles to load** (wait for the list before proceeding)
4. **Select your POS profile** (or confirm the auto-selected profile)
5. **Monitor the logs** to confirm registration includes POS profile:
   ```
   INFO: Registering device with POS profile: Main Counter
   INFO: Registered FCM token for username with 1 POS profile(s)
   ```
6. **Test with a real order** to confirm notifications arrive

If notifications still don't arrive after these steps, check:
- Backend logs for notification sending errors
- Network connectivity between device and backend
- FCM token validity in Firebase console
- POS profile name matches exactly between app and backend
