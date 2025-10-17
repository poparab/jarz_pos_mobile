package com.example.jarz_pos

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import kotlin.jvm.Volatile

object OrderAlertNative {
    private const val DEFAULT_NOTIFICATION_ID = 4010
    const val CHANNEL_ID = "jarz_order_alerts"

    private var mediaPlayer: MediaPlayer? = null
    private var audioManager: AudioManager? = null
    private var focusRequest: AudioFocusRequest? = null
    @Volatile
    private var volumeLocked: Boolean = false

    fun startAlarm(context: Context) {
        synchronized(this) {
            if (mediaPlayer?.isPlaying == true) {
                return
            }

            val manager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
            audioManager = manager

            val attributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
                    .setAudioAttributes(attributes)
                    .setOnAudioFocusChangeListener { }
                    .build()
                focusRequest = request
                manager.requestAudioFocus(request)
            } else {
                @Suppress("DEPRECATION")
                manager.requestAudioFocus(null, AudioManager.STREAM_ALARM, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
            }

            val mp = MediaPlayer()
            mp.setAudioAttributes(attributes)
            mp.isLooping = true
            mp.setDataSource(context, resolveAlarmUri(context))
            mp.setVolume(1.0f, 1.0f)
            mp.prepare()
            mp.start()
            mediaPlayer = mp
            setVolumeLock(true)
        }
    }

    fun stopAlarm() {
        synchronized(this) {
            try {
                mediaPlayer?.stop()
            } catch (_: Exception) {
            }
            try {
                mediaPlayer?.release()
            } catch (_: Exception) {
            }
            mediaPlayer = null

            audioManager?.let { manager ->
                focusRequest?.let {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        manager.abandonAudioFocusRequest(it)
                    }
                } ?: run {
                    @Suppress("DEPRECATION")
                    manager.abandonAudioFocus(null)
                }
            }
            focusRequest = null
            setVolumeLock(false)
        }
    }

    fun showNotification(context: Context, data: Map<String, String>) {
        ensureChannel(context)

        val invoiceId = data["invoice_id"] ?: ""
        val notificationId = if (invoiceId.isNotEmpty()) invoiceId.hashCode() else DEFAULT_NOTIFICATION_ID

        val extras = Bundle().apply {
            data.forEach { (key, value) -> putString(key, value) }
        }

        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("order_alert_invoice_id", invoiceId)
            putExtra("order_alert_payload", extras)
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            notificationId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val title = data["customer_name"].takeUnless { it.isNullOrBlank() } ?: context.getString(android.R.string.dialog_alert_title)
        val total = data["grand_total"].takeUnless { it.isNullOrBlank() } ?: ""
        val body = buildString {
            if (total.isNotEmpty()) {
                append("Total: ").append(total)
            }
            data["item_summary"].takeUnless { it.isNullOrBlank() }?.let {
                if (isNotEmpty()) append(" • ")
                append(it)
            }
        }

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_sys_warning)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentTitle(title)
            .setContentText(body)
            .setOngoing(true)
            .setAutoCancel(false)
            .setFullScreenIntent(pendingIntent, true)
            .setContentIntent(pendingIntent)
            .setShowWhen(true)

        NotificationManagerCompat.from(context).notify(notificationId, builder.build())
    }

    fun cancelNotification(context: Context, invoiceId: String?) {
        val notificationId = if (!invoiceId.isNullOrBlank()) invoiceId.hashCode() else DEFAULT_NOTIFICATION_ID
        NotificationManagerCompat.from(context).cancel(notificationId)
    }

    fun setVolumeLock(locked: Boolean) {
        volumeLocked = locked
    }

    fun isVolumeLocked(): Boolean = volumeLocked

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val existing = manager.getNotificationChannel(CHANNEL_ID)
            if (existing == null) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Order Alerts",
                    NotificationManager.IMPORTANCE_HIGH,
                )
                channel.description = "Urgent alerts for new POS orders"
                channel.setBypassDnd(true)
                channel.enableVibration(true)
                // Notification sound intentionally null; alarm playback is handled separately
                channel.setSound(null, null)
                manager.createNotificationChannel(channel)
            }
        }
    }

    private fun resolveAlarmUri(context: Context): Uri {
        val alarm = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        if (alarm != null) return alarm

        val notification = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        if (notification != null) return notification

        val ringtone = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
        if (ringtone != null) return ringtone

        return Uri.parse("content://settings/system/notification_sound")
    }
}
