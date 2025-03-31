package com.saurabh7973.snapdrop

import android.content.Intent
import android.os.Bundle
import android.util.Log  
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.view.WindowManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "security/developer_mode"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        java.lang.Thread.sleep(1000)
        super.configureFlutterEngine(flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Prevent screenshots and screen recording
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )

        // Prevent tapjacking by making the window not touchable
        //window.setFlags(
        //    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
        //    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
        //)

        // Security Checks

        // Developer Mode Detection  
        // if (DeveloperModeChecker.isDeveloperModeEnabled(this)) {
        //     Log.e("Security", "Developer Mode detected! Exiting app.")
        //     finish() // Close the app
        // }

        // Tamper Detection
        // if (!SecurityUtils.isAppSignatureValid(packageManager, packageName)) {
        //     Log.e("TamperCheck", "Tampered APK detected! Closing app.") 
        //     finish() // Kill the app if tampering is detected
        // }

        // Emulator Checker
        if (EmulatorChecker.isEmulator()) {
            Log.e("Security", "Emulator detected! Exiting app.")
            finish() // Close the app
        }

        // Root Detector
        if (RootUtil.isDeviceRooted(this)) {
            Log.e("Security", "Rooted device detected! Exiting app.")
            finish() // Kill the app
        }

        if (OverlayDetector.isOverlayEnabled(this)) {
            Log.e("Security", "Suspicious overlay detected! Exiting app.")
            finish() // Exit the app if an overlay is found
        }
    }
}
