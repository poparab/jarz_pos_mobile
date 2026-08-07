package com.example.jarz_pos

import com.google.firebase.messaging.RemoteMessage
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService

class JarzFirebaseMessagingService : FlutterFirebaseMessagingService() {
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
            }
        }
        super.onMessageReceived(remoteMessage)
    }
}
