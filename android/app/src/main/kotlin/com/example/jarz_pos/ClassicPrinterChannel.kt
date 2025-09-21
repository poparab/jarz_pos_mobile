package com.example.jarz_pos

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.io.OutputStream
import java.util.UUID
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock

class ClassicPrinterChannel : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private val adapter: BluetoothAdapter? get() = BluetoothAdapter.getDefaultAdapter()

    // SPP UUID
    private val sppUUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

    private var socket: BluetoothSocket? = null
    private var out: OutputStream? = null
    private val lock = ReentrantLock()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "classic_printer")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        disconnectInternal()
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getBondedDevices" -> {
                val bonded = adapter?.bondedDevices?.map { d -> mapOf("name" to (d.name ?: ""), "mac" to d.address) } ?: emptyList()
                result.success(bonded)
            }
            "connect" -> {
                val mac = call.argument<String>("mac")
                if (mac.isNullOrEmpty()) { result.success(false); return }
                val ok = connectInternal(mac)
                result.success(ok)
            }
            "disconnect" -> {
                disconnectInternal(); result.success(null)
            }
            "write" -> {
                val data = call.argument<ByteArray>("data")
                if (data == null) { result.success(false); return }
                val ok = writeInternal(data)
                result.success(ok)
            }
            "isConnected" -> result.success(socket?.isConnected == true)
            else -> result.notImplemented()
        }
    }

    private fun connectInternal(mac: String): Boolean {
        lock.withLock {
            disconnectInternal()
            val dev: BluetoothDevice? = try { adapter?.getRemoteDevice(mac) } catch (e: IllegalArgumentException) { null }
            if (dev == null) return false
            return try {
                // Use insecure to avoid pairing popups when already bonded
                val s = dev.createInsecureRfcommSocketToServiceRecord(sppUUID)
                s.connect()
                socket = s
                out = s.outputStream
                true
            } catch (e: IOException) {
                Log.e("ClassicPrinter", "connect error", e)
                disconnectInternal()
                false
            }
        }
    }

    private fun writeInternal(data: ByteArray): Boolean {
        lock.withLock {
            val o = out ?: return false
            return try {
                o.write(data)
                o.flush()
                true
            } catch (e: IOException) {
                Log.e("ClassicPrinter", "write error", e)
                disconnectInternal()
                false
            }
        }
    }

    private fun disconnectInternal() {
        lock.withLock {
            try { out?.flush() } catch (_: Exception) {}
            try { out?.close() } catch (_: Exception) {}
            try { socket?.close() } catch (_: Exception) {}
            out = null
            socket = null
        }
    }
}
