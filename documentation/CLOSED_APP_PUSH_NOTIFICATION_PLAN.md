# Closed-App Push Notification Reliability Plan

## Status

- Investigation complete.
- Root cause identified.
- No code changes applied yet in this plan phase.
- Waiting for approval before implementation.

## Executive Summary

The current Android push flow for new orders depends on **data-only FCM messages** for `new_invoice` events.

That is the main reason notifications fail when the app is totally closed.

When the app process is terminated, Android does **not reliably deliver data-only pushes** to app code on all devices or in all power states. Because of that, the app often never gets the chance to run:

- `JarzFirebaseMessagingService.onMessageReceived(...)`
- `firebaseMessagingBackgroundHandler(...)`
- local notification rendering
- local alarm playback

The current implementation is therefore **best-effort**, not reliable, for a killed app.

The most reliable fix is to move new-order closed-app delivery to an **OS-rendered FCM notification payload**, while keeping the existing data payload for app routing and best-effort in-app/alarm behavior.

## What I Investigated

### App-side wiring already exists

These pieces are already present and are not the main blocker:

- `lib/main.dart`
  - registers `FirebaseMessaging.onBackgroundMessage(...)`
- `lib/src/features/pos/order_alert/order_alert_bridge.dart`
  - handles `onMessage`, `onMessageOpenedApp`, and `getInitialMessage()`
- `android/app/src/main/AndroidManifest.xml`
  - declares `JarzFirebaseMessagingService`
  - includes `POST_NOTIFICATIONS`, `WAKE_LOCK`, and a default channel ID
- `android/app/src/main/kotlin/com/example/jarz_pos/JarzFirebaseMessagingService.kt`
  - starts alarm and shows a native notification for `new_invoice`

### Backend behavior is the real reliability problem

In `jarz_pos/api/notifications.py`, `_send_fcm_notifications(...)` currently does this for `new_invoice`:

- `notification = None`
- `android_notification = None`
- send only `data`

There is also a test that explicitly enforces this behavior:

- `jarz_pos/tests/test_api_notifications_payload.py`
  - `test_send_fcm_notifications_sends_new_invoice_as_data_only`

That means the current system intentionally avoids OS-rendered push notifications for new orders and relies on app code receiving the message.

## Why It Fails When The App Is Totally Closed

### Current flow

1. Backend sends `new_invoice` as a high-priority **data-only** FCM message.
2. Android may deliver that message to the app process.
3. If delivered, the app's native service shows the notification and starts the alarm.

### Failure point

If Android does **not** wake the app process for that data-only message, nothing happens:

- no native service callback
- no Dart background handler
- no local notification
- no alarm

This is especially common when:

- the app is fully terminated
- the device is in Doze / aggressive battery optimization
- the OEM is restrictive
- the app process was reclaimed and Android decides not to start it for a data-only push

## Important Constraint

There is a hard Android tradeoff here:

- **Most reliable closed-app delivery** = server sends a real FCM `notification` payload and Android posts it itself.
- **Custom full-screen alarm behavior from app code** = requires the app process to receive and handle the message.

Those two goals are not equally reliable when the app is killed.

So the safest approach is:

- make **notification appearance** reliable for a closed app
- keep the **custom alarm/full-screen path** as a best-effort enhancement when Android does deliver app-side callbacks

## Recommended Fix

### Goal

Make sure a cashier receives a visible new-order push notification even when the app is fully closed.

### Recommended architecture

#### Phase 1: Reliable OS-level closed-app notification

Change backend `new_invoice` FCM sending from **data-only** to **notification + data**.

For `new_invoice`, send:

- `notification.title`
- `notification.body`
- `android.notification.channel_id = jarz_order_alerts`
- `android.priority = high`
- existing `data` payload unchanged for app routing

Result:

- when app is foreground: app can still process payload normally
- when app is background/terminated: Android posts the notification itself
- tapping notification still routes through `getInitialMessage()` / `onMessageOpenedApp`

#### Phase 2: Keep best-effort alarm path

Retain the native order-alert service and local alarm logic for cases where Android *does* deliver app-side callbacks.

This preserves richer behavior without depending on it for closed-app reliability.

#### Phase 3: Dedupe and routing hardening

Because the system may now have both:

- OS-rendered notifications
- app-side alert handling

we should harden dedupe using:

- `invoice_id`
- `notification_id`
- `tag`

so the same order does not produce duplicate visible alerts.

## Implementation Plan After Approval

### Backend

1. Update `jarz_pos/api/notifications.py`
   - stop treating `new_invoice` as data-only only
   - build a standard `messaging.Notification(...)` for new orders
   - build `messaging.AndroidNotification(...)` for `jarz_order_alerts`
   - keep `data` payload intact

2. Update backend tests
   - replace the current data-only assertion for `new_invoice`
   - add tests for:
     - notification payload present
     - Android notification channel set correctly
     - data payload still contains routing fields

### Flutter / Android

3. Adjust app handling to expect system-rendered notifications for killed/background states
   - verify `onMessageOpenedApp` and `getInitialMessage()` continue to route correctly
   - ensure no app-side assumptions depend on `onMessageReceived` always firing

4. Add dedupe protection for order alerts
   - ignore repeated processing for the same `invoice_id` / `notification_id`
   - prevent duplicate queue/alarm behavior when both websocket and FCM arrive near the same time

5. Keep native alert code as fallback enhancement
   - do not remove `JarzFirebaseMessagingService`
   - do not remove `OrderAlertNative`
   - treat them as best-effort, not the sole closed-app delivery path

## What I Do **Not** Recommend As The Main Fix

### Keep data-only and only tweak priority

Not sufficient.

`priority=high` helps, but it does not make killed-app delivery reliable across devices.

### WorkManager / periodic polling as the primary closed-app solution

Not suitable for urgent orders.

Polling cannot guarantee immediate delivery and is much weaker than FCM for real-time alerts.

### Permanent foreground service

Technically stronger, but too heavy operationally.

It adds battery cost, UX friction, and ongoing status bar presence. I would only consider it if you explicitly want a permanently running alarm service model.

## Acceptance Criteria

After implementation, I will consider this fixed when all of the following are true:

1. A new order triggers a visible push notification while the app is fully closed.
2. Tapping that notification opens the app and routes to the correct order-alert flow.
3. Foreground behavior still works.
4. Background behavior still works.
5. No duplicate order notifications appear for a single invoice.
6. Shift notifications remain unaffected.

## Validation Plan

### Local / code validation

1. Backend unit tests for FCM payload shape.
2. Flutter tests for message routing / dedupe behavior where practical.
3. Static validation on touched Flutter and Python files.

### Device validation

1. App in foreground
2. App in background
3. App fully closed from recents
4. Device idle / locked screen
5. Tap notification from system tray

### Operational validation

1. Confirm device token registration still works.
2. Confirm `Jarz Mobile Device` rows remain correct.
3. Confirm backend logs show successful FCM sends.
4. Confirm a real device receives new-order notifications when closed.

## Why I Recommend Approving This Plan

Because it fixes the problem at the actual reliability boundary.

Right now the system expects Android to wake app code for a data-only push after the app is terminated. That is exactly the part Android does not guarantee consistently.

The proposed change moves closed-app delivery to the OS notification layer, which is the only dependable path for this requirement.

## Approval Decision Needed

If you approve, I will implement:

1. Backend FCM payload change for `new_invoice`
2. App-side dedupe / launch-routing hardening
3. Focused tests for the new payload contract and handling path

## Current Conclusion

The reason it is **not** working right now as intended is:

`new_invoice` is intentionally sent as a **data-only push**, and a totally closed Android app cannot be relied on to receive data-only messages consistently enough to build and display its own notification.
