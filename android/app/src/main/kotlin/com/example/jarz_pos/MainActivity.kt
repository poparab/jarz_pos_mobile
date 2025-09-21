package com.example.jarz_pos

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister

class MainActivity : FlutterActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		// Ensure generated plugins are registered
		GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine)
		// Manually register our custom plugin
		flutterEngine.plugins.add(ClassicPrinterChannel())
	}
}
