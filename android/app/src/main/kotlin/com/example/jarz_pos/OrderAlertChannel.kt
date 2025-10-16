package com.example.jarz_pos

import android.content.Context
import android.os.Bundle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class OrderAlertChannel : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var appContext: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "order_alert_native")
        channel.setMethodCallHandler(this)
        pendingLaunchPayload?.let { payload ->
            channel.invokeMethod("launchPayload", payload)
            pendingLaunchPayload = null
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startAlarm" -> {
                OrderAlertNative.startAlarm(appContext)
                result.success(null)
            }
            "stopAlarm" -> {
                OrderAlertNative.stopAlarm()
                result.success(null)
            }
            "cancelNotification" -> {
                val invoiceId = call.argument<String>("invoiceId")
                OrderAlertNative.cancelNotification(appContext, invoiceId)
                result.success(null)
            }
            "showNotification" -> {
                val data = call.argument<Map<String, String>>("data") ?: emptyMap()
                OrderAlertNative.showNotification(appContext, data)
                result.success(null)
            }
            "consumeLaunchPayload" -> {
                result.success(pendingLaunchPayload)
                pendingLaunchPayload = null
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        @Volatile
        private var pendingLaunchPayload: Map<String, String>? = null

        fun storeLaunchPayload(bundle: Bundle?) {
            if (bundle == null) {
                pendingLaunchPayload = null
                return
            }

            val mapped = mutableMapOf<String, String>()
            for (key in bundle.keySet()) {
                val value = bundle.get(key)
                if (value is Bundle) {
                    mapped.putAll(flattenBundle(value))
                } else if (value != null) {
                    mapped[key] = value.toString()
                }
            }
            pendingLaunchPayload = if (mapped.isEmpty()) null else mapped
        }

        private fun flattenBundle(bundle: Bundle): Map<String, String> {
            val mapped = mutableMapOf<String, String>()
            for (key in bundle.keySet()) {
                val value = bundle.get(key)
                if (value is Bundle) {
                    mapped.putAll(flattenBundle(value))
                } else if (value != null) {
                    mapped[key] = value.toString()
                }
            }
            return mapped
        }
    }
}
