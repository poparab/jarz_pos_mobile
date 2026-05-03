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
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import org.json.JSONArray
import kotlin.jvm.Volatile

object OrderAlertNative {
    private const val DEFAULT_NOTIFICATION_ID = 4010
    private const val SHIFT_NOTIFICATION_ID = 4020
    private const val MAX_EXPANDED_ITEM_LINES = 4
    const val CHANNEL_ID = "jarz_order_alerts"
    private const val SHIFT_CHANNEL_ID = "jarz_shift_updates"

    private var mediaPlayer: MediaPlayer? = null
    private var audioManager: AudioManager? = null
    private var focusRequest: AudioFocusRequest? = null
    private var previewRingtone: Ringtone? = null
    @Volatile
    private var volumeLocked: Boolean = false
    @Volatile
    private var selectedAlarmUri: String? = null

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

        val notificationContent = buildOrderNotificationContent(data)
        val expandedText = notificationContent.expandedLines.joinToString("\n")
        val expandedStyle = NotificationCompat.BigTextStyle()
            .setBigContentTitle(notificationContent.title)
            .bigText(expandedText)

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_sys_warning)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentTitle(notificationContent.title)
            .setContentText(notificationContent.body)
            .setStyle(expandedStyle)
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

    fun setAlarmSound(uriString: String?) {
        selectedAlarmUri = uriString
    }

    fun getAvailableAlarmSounds(context: Context): List<Map<String, String>> {
        val ringtoneManager = RingtoneManager(context)
        ringtoneManager.setType(RingtoneManager.TYPE_ALARM)
        val cursor = ringtoneManager.cursor
        val sounds = mutableListOf<Map<String, String>>()

        // Add default system alarm
        val defaultUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        if (defaultUri != null) {
            sounds.add(
                mapOf(
                    "title" to "Default Alarm",
                    "uri" to defaultUri.toString()
                )
            )
        }

        // Add all available alarms
        while (cursor.moveToNext()) {
            val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
            val id = cursor.getString(RingtoneManager.ID_COLUMN_INDEX)
            val uri = ringtoneManager.getRingtoneUri(cursor.position)
            if (uri != null) {
                sounds.add(
                    mapOf(
                        "title" to (title ?: "Alarm $id"),
                        "uri" to uri.toString()
                    )
                )
            }
        }

        return sounds
    }

    fun previewAlarmSound(context: Context, uriString: String) {
        stopPreview()
        try {
            val uri = Uri.parse(uriString)
            val ringtone = RingtoneManager.getRingtone(context, uri)
            ringtone.play()
            previewRingtone = ringtone
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun stopPreview() {
        try {
            previewRingtone?.stop()
            previewRingtone = null
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

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

    fun showShiftNotification(context: Context, data: Map<String, String>) {
        ensureShiftChannel(context)

        val notificationId = SHIFT_NOTIFICATION_ID + (System.currentTimeMillis() % 1000).toInt()

        val title = data["title"] ?: "Shift Update"
        val body = data["body"] ?: ""

        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            notificationId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = NotificationCompat.Builder(context, SHIFT_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setShowWhen(true)

        NotificationManagerCompat.from(context).notify(notificationId, builder.build())
    }

    private fun ensureShiftChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val existing = manager.getNotificationChannel(SHIFT_CHANNEL_ID)
            if (existing == null) {
                val channel = NotificationChannel(
                    SHIFT_CHANNEL_ID,
                    "Shift Updates",
                    NotificationManager.IMPORTANCE_DEFAULT,
                )
                channel.description = "Notifications when shifts are started or ended"
                manager.createNotificationChannel(channel)
            }
        }
    }

    private fun resolveAlarmUri(context: Context): Uri {
        // Use selected alarm if available
        if (!selectedAlarmUri.isNullOrBlank()) {
            try {
                return Uri.parse(selectedAlarmUri)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        // Fallback to defaults
        val alarm = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        if (alarm != null) return alarm

        val notification = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        if (notification != null) return notification

        val ringtone = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
        if (ringtone != null) return ringtone

        return Uri.parse("content://settings/system/notification_sound")
    }

    private fun buildOrderNotificationContent(data: Map<String, String>): OrderNotificationContent {
        val customerName = firstNonBlank(data["customer_name"], data["customer"])
        val branchDisplay = firstNonBlank(data["branch_display"], data["pos_profile"])
        val totalDisplay = firstNonBlank(data["total_display"], data["grand_total"])
        val itemSummary = firstNonBlank(data["item_summary"])
        val itemCount = data["item_count"]?.trim()?.toIntOrNull()?.takeIf { it > 0 }
        val itemLines = parseItemLines(data["items"])

        val title = customerName?.let { "New order: $it" } ?: "New order received"

        val bodyParts = mutableListOf<String>()
        branchDisplay?.let { bodyParts.add("Branch: $it") }
        totalDisplay?.let { bodyParts.add("Total: $it") }
        buildCollapsedItemsText(itemCount, itemLines, itemSummary)?.let { bodyParts.add(it) }

        val expandedLines = mutableListOf<String>()
        branchDisplay?.let { expandedLines.add("Branch: $it") }
        totalDisplay?.let { expandedLines.add("Total: $it") }

        if (itemLines.isNotEmpty()) {
            val displayedCount = minOf(itemLines.size, MAX_EXPANDED_ITEM_LINES)
            itemLines.take(displayedCount).forEach { expandedLines.add(it) }

            val totalItems = maxOf(itemCount ?: 0, itemLines.size)
            val remainingItems = totalItems - displayedCount
            if (remainingItems > 0) {
                val suffix = if (remainingItems == 1) "item" else "items"
                expandedLines.add("+$remainingItems more $suffix")
            }
        } else if (itemSummary != null && itemCount != null) {
            expandedLines.add("Items ($itemCount): $itemSummary")
        } else if (itemSummary != null) {
            expandedLines.add("Items: $itemSummary")
        } else if (itemCount != null) {
            val suffix = if (itemCount == 1) "item" else "items"
            expandedLines.add("Items: $itemCount $suffix")
        } else {
            expandedLines.add("Items: Not provided")
        }

        val body = bodyParts.joinToString(" | ").ifBlank { "Tap to review order" }
        return OrderNotificationContent(title = title, body = body, expandedLines = expandedLines)
    }

    private fun buildCollapsedItemsText(
        itemCount: Int?,
        itemLines: List<String>,
        itemSummary: String?,
    ): String? {
        val itemText = when {
            itemCount != null -> {
                val suffix = if (itemCount == 1) "item" else "items"
                "$itemCount $suffix"
            }
            itemLines.size > 1 -> "${itemLines.size} items"
            itemLines.size == 1 -> itemLines.first()
            itemSummary != null -> itemSummary
            else -> null
        } ?: return null

        return "Items: $itemText"
    }

    private fun parseItemLines(rawItems: String?): List<String> {
        if (rawItems.isNullOrBlank()) {
            return emptyList()
        }

        return try {
            val items = JSONArray(rawItems)
            val lines = mutableListOf<String>()
            for (index in 0 until items.length()) {
                val itemObject = items.optJSONObject(index)
                if (itemObject != null) {
                    val name = firstNonBlank(
                        itemObject.optString("item_name"),
                        itemObject.optString("item_code"),
                        itemObject.optString("name"),
                    )
                    val quantity = formatQuantity(itemObject.opt("qty") ?: itemObject.opt("quantity"))
                    val line = when {
                        name != null && quantity != null -> "$quantity x $name"
                        name != null -> name
                        else -> null
                    }
                    if (line != null) {
                        lines.add(line)
                    }
                    continue
                }

                val textValue = items.optString(index).trim()
                if (textValue.isNotEmpty()) {
                    lines.add(textValue)
                }
            }
            lines
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun formatQuantity(value: Any?): String? {
        val numericValue = when (value) {
            is Number -> value.toDouble()
            else -> value?.toString()?.trim()?.toDoubleOrNull()
        } ?: return null

        val longValue = numericValue.toLong()
        return if (numericValue == longValue.toDouble()) {
            longValue.toString()
        } else {
            numericValue.toString().trimEnd('0').trimEnd('.')
        }
    }

    private fun firstNonBlank(vararg values: String?): String? {
        values.forEach { value ->
            val normalized = value?.trim()
            if (!normalized.isNullOrEmpty()) {
                return normalized
            }
        }
        return null
    }

    private data class OrderNotificationContent(
        val title: String,
        val body: String,
        val expandedLines: List<String>,
    )
}
