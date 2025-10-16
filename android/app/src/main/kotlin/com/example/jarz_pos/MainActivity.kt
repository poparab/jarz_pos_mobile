package com.example.jarz_pos

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        OrderAlertChannel.storeLaunchPayload(intent?.extras)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        OrderAlertChannel.storeLaunchPayload(intent.extras)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Ensure generated plugins are registered
        GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine)
        // Manually register our custom plugin
        flutterEngine.plugins.add(ClassicPrinterChannel())
        flutterEngine.plugins.add(OrderAlertChannel())
    }
}
