package com.example.abcde_app_v1_2

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.abcde_app_v1_2/deeplink"
    private var methodChannel: MethodChannel? = null

    // Route from the intent that launched the app (cold start), handed to
    // Flutter when it asks via getInitialRoute.
    private var pendingRoute: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialRoute" -> {
                    result.success(pendingRoute)
                    pendingRoute = null
                }
                else -> result.notImplemented()
            }
        }
        pendingRoute = routeFromIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val route = routeFromIntent(intent)
        if (route != null) {
            // App already running — tell Flutter to navigate now.
            methodChannel?.invokeMethod("navigate", route)
        }
    }

    /** Extracts "/diagnosis" from abcde://open/diagnosis. */
    private fun routeFromIntent(intent: Intent?): String? {
        val data: Uri = intent?.data ?: return null
        if (data.scheme != "abcde" || data.host != "open") return null
        val path = data.path
        return if (path.isNullOrEmpty()) null else path
    }
}
