package com.example.jarz_pos

import com.google.firebase.messaging.RemoteMessage
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService

class JarzFirebaseMessagingService : FlutterFirebaseMessagingService() {
    // A message carrying a notification block while the app is backgrounded is
    // rendered by the SDK from handleIntent, which never calls
    // onMessageReceived below -- so preparing the channels there alone is too
    // late for exactly the case that matters. The service is still constructed
    // to handle the intent, so onCreate is the earliest point that always runs.
    override fun onCreate() {
        super.onCreate()
        OrderAlertNative.prepareNotificationChannels(applicationContext)
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        OrderAlertNative.prepareNotificationChannels(applicationContext)
        val data = remoteMessage.data
        if (data.isNotEmpty()) {
            when (data["type"]) {
                "new_invoice" -> {
                    // startAlarm consults the mirrored mute state itself. Passing
                    // the invoice id is what lets it tell "this one is silenced"
                    // apart from "the device is silenced".
                    OrderAlertNative.startAlarm(applicationContext, data["invoice_id"])
                    // The notification is silent and stays useful even when the
                    // alarm is muted, so it is shown either way.
                    OrderAlertNative.showNotification(applicationContext, data)
                }
                "invoice_accepted" -> {
                    OrderAlertNative.stopAlarm()
                    OrderAlertNative.cancelNotification(applicationContext, data["invoice_id"])
                }
                "shift_started", "shift_ended" -> {
                    OrderAlertNative.showShiftNotification(applicationContext, data)
                }
                // onMessageReceived runs for a FOREGROUND message, and the SDK
                // deliberately draws no tray entry in that case -- so without
                // this branch a manager with the app open (the normal state for
                // a manager on the floor) got no notification, no sound and no
                // badge for an expense waiting on them. Exactly the silence the
                // feature exists to end. Backgrounded, this method is not
                // called and the SDK renders the notification block instead, so
                // there is one entry either way and never two.
                "expense_approval_required" -> {
                    OrderAlertNative.showApprovalNotification(applicationContext, data)
                }
                // Task Board: same foreground gap as the expense branch above,
                // on the same quiet approvals channel. The tap carries task_id
                // so _handleLaunchPayload opens the task itself.
                "task_notification" -> {
                    OrderAlertNative.showApprovalNotification(applicationContext, data)
                }
                // B2B collection reminder: same foreground gap, same quiet
                // approvals channel. The tap carries customer so
                // _handleLaunchPayload opens that shop's credit account.
                "settlement_reminder" -> {
                    OrderAlertNative.showApprovalNotification(applicationContext, data)
                }
            }
        }
        super.onMessageReceived(remoteMessage)
    }
}
