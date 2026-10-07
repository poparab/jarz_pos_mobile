package com.example.jarz_pos

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

/** Serves the receipt images in cache/receipt_share/ to the app they are sent to. */
class ReceiptShareFileProvider : FileProvider()

/**
 * Hands rendered receipt images straight to WhatsApp.
 *
 * With no chat named, WhatsApp opens its own "Send to" list — every chat and
 * every group — so the cashier picks who gets the receipt. That is the point:
 * a B2B shop is usually reached through a group, not the number on the
 * customer record. `jid` names one chat instead (the customer's number); it is
 * an extra WhatsApp has long honoured but never documented, and when it is
 * ignored the cashier simply lands on the same "Send to" list.
 *
 * Replies "sent", or "not_installed" when neither WhatsApp nor WhatsApp
 * Business is on the device, so Dart falls back to the OS share sheet.
 */
class WhatsAppShareChannel(private val activity: Activity) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL = "jarz/whatsapp_share"
        private val PACKAGES = listOf("com.whatsapp", "com.whatsapp.w4b")
        private const val DIR = "receipt_share"

        // A share is copied by WhatsApp when the cashier presses send; files
        // older than this belong to sends that finished long ago.
        private const val STALE_MS = 60 * 60 * 1000L

        // One send at a time, off the main thread: a statement for a shop
        // with many open orders is several PNGs to write.
        private val io = Executors.newSingleThreadExecutor()
    }

    private val main = Handler(Looper.getMainLooper())

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "shareImages" -> shareImages(call, result)
            else -> result.notImplemented()
        }
    }

    private fun shareImages(call: MethodCall, result: MethodChannel.Result) {
        val images = call.argument<List<ByteArray>>("images").orEmpty()
        val names = call.argument<List<String>>("names").orEmpty()
        val caption = call.argument<String>("caption")
        val jid = call.argument<String>("jid")
        if (images.isEmpty()) {
            result.error("no_images", "Nothing to send", null)
            return
        }

        val installed = PACKAGES.filter { isInstalled(it) }
        if (installed.isEmpty()) {
            result.success("not_installed")
            return
        }

        io.execute {
            val uris = try {
                writeImages(images, names)
            } catch (e: Exception) {
                main.post { result.error("write_failed", e.message, null) }
                return@execute
            }
            main.post { launch(installed, uris, caption, jid, result) }
        }
    }

    private fun launch(
        installed: List<String>,
        uris: List<Uri>,
        caption: String?,
        jid: String?,
        result: MethodChannel.Result,
    ) {
        // Granted per package rather than through the intent's flags: with
        // both WhatsApps installed the second one is reached through a
        // chooser, whose initial intents do not carry their own grants.
        for (pkg in installed) {
            for (uri in uris) activity.grantUriPermission(pkg, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        val intents = installed.map { buildIntent(it, uris, caption, jid) }
        try {
            if (intents.size == 1) {
                activity.startActivity(intents[0])
            } else {
                val chooser = Intent.createChooser(intents[0], null)
                chooser.putExtra(Intent.EXTRA_INITIAL_INTENTS, intents.drop(1).toTypedArray())
                activity.startActivity(chooser)
            }
            result.success("sent")
        } catch (e: ActivityNotFoundException) {
            result.success("not_installed")
        } catch (e: Exception) {
            result.error("launch_failed", e.message, null)
        }
    }

    private fun buildIntent(pkg: String, uris: List<Uri>, caption: String?, jid: String?): Intent {
        val intent = if (uris.size == 1) {
            Intent(Intent.ACTION_SEND).putExtra(Intent.EXTRA_STREAM, uris[0])
        } else {
            Intent(Intent.ACTION_SEND_MULTIPLE).putParcelableArrayListExtra(Intent.EXTRA_STREAM, ArrayList(uris))
        }
        intent.type = "image/png"
        intent.setPackage(pkg)
        if (!caption.isNullOrBlank()) intent.putExtra(Intent.EXTRA_TEXT, caption)
        if (!jid.isNullOrBlank()) intent.putExtra("jid", jid)
        val clip = ClipData.newRawUri(null, uris[0])
        uris.drop(1).forEach { clip.addItem(ClipData.Item(it)) }
        intent.clipData = clip
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        return intent
    }

    private fun writeImages(images: List<ByteArray>, names: List<String>): List<Uri> {
        val dir = File(activity.cacheDir, DIR).apply { mkdirs() }
        val now = System.currentTimeMillis()
        dir.listFiles()?.filter { now - it.lastModified() > STALE_MS }?.forEach { it.delete() }

        val authority = "${activity.packageName}.receipt_share"
        return images.mapIndexed { i, bytes ->
            val base = names.getOrNull(i)?.replace(Regex("[^A-Za-z0-9._-]"), "_")?.takeIf { it.isNotBlank() }
                ?: "receipt-$i.png"
            // Unique per send: a second send of the same order must not
            // overwrite a file WhatsApp may still be reading.
            val file = File(dir, "${now}_$i-$base")
            file.writeBytes(bytes)
            FileProvider.getUriForFile(activity, authority, file)
        }
    }

    private fun isInstalled(pkg: String): Boolean = try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            activity.packageManager.getPackageInfo(pkg, PackageManager.PackageInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            activity.packageManager.getPackageInfo(pkg, 0)
        }
        true
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }
}
