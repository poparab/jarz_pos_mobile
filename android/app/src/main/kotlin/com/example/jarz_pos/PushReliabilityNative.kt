package com.example.jarz_pos

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings

/**
 * Whether Android will let a push wake this app at all.
 *
 * A new-order alert is a data-only FCM message, because that is the only shape
 * the alarm can be started from when the app is not in the foreground. The cost
 * is that delivery REQUIRES starting the app's process: once Android puts the
 * app into "stopped state" -- what a battery manager does when it decides an
 * app is unused, and what "Put unused apps to sleep" / "Deep sleeping apps"
 * does on Samsung -- every message is dropped. Not delayed, dropped, and FCM
 * still reports the send as successful, so nothing on the server ever shows it.
 * A notification-block message does not escape this either: the code that draws
 * the tray entry runs inside the app's own process, so a stopped app renders
 * nothing. Measured, not assumed: force-stopped, neither shape arrives; the
 * same token seconds later with the app merely closed receives both.
 *
 * So there is nothing a server can send to reach a sleeping device. The only
 * defence is to not be put to sleep, which is what the battery-optimisation
 * exemption below asks for.
 */
object PushReliabilityNative {

    /** True when Android has agreed not to doze this app into stopped state. */
    fun isIgnoringBatteryOptimizations(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        return try {
            val manager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            manager.isIgnoringBatteryOptimizations(context.packageName)
        } catch (_: Exception) {
            // A diagnostic must never be the thing that breaks the app, and a
            // false warning is worse than a missing one: it would train staff
            // to dismiss the banner that matters. Assume the good case.
            true
        }
    }

    /**
     * Opens the system's "allow this app to run in the background?" dialog.
     *
     * Needs REQUEST_IGNORE_BATTERY_OPTIMIZATIONS in the manifest; without it
     * the intent resolves to nothing. Play restricts that permission, which
     * does not apply here -- this app is distributed as an APK from
     * /pos/download/, never through Play.
     */
    fun requestIgnoreBatteryOptimizations(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return false
        val direct = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
            data = Uri.parse("package:" + context.packageName)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        if (startIfResolvable(context, direct)) return true

        // Some OEM builds strip the per-app dialog but keep the full list.
        val list = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (startIfResolvable(context, list)) return true

        return openAppSettings(context)
    }

    /**
     * Last resort: this app's own settings page. Every OEM has one, and the
     * per-manufacturer battery controls hang off it -- which is where a Samsung
     * user turns off "Put unused apps to sleep" for this app specifically.
     */
    fun openAppSettings(context: Context): Boolean {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.parse("package:" + context.packageName)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        return startIfResolvable(context, intent)
    }

    /**
     * Try the intent and report whether it actually opened.
     *
     * Deliberately NOT gated on resolveActivity(): from Android 11 that answer
     * is filtered by package visibility, so a settings screen that exists and
     * would open perfectly well can report itself absent, and we would fall
     * through to a worse option for no reason. Attempting it and catching
     * ActivityNotFoundException asks the only question that matters.
     */
    private fun startIfResolvable(context: Context, intent: Intent): Boolean {
        return try {
            context.startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }
}
