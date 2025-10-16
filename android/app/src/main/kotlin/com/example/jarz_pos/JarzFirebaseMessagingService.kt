package com.example.jarz_pos

import com.google.firebase.messaging.RemoteMessage
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService

class JarzFirebaseMessagingService : FlutterFirebaseMessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        val data = remoteMessage.data
        if (data.isNotEmpty()) {
            when (data["type"]) {
                "new_invoice" -> {
                    OrderAlertNative.startAlarm(applicationContext)
                    OrderAlertNative.showNotification(applicationContext, data)
                }
                "invoice_accepted" -> {
                    OrderAlertNative.stopAlarm()
                    OrderAlertNative.cancelNotification(applicationContext, data["invoice_id"])
                }
            }
        }
        super.onMessageReceived(remoteMessage)
    }
}
