package com.saurabh7973.snapdrop

import android.os.Bundle
import android.util.Log  
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.view.WindowManager
import android.app.AlertDialog
import android.content.DialogInterface

class MainActivity : FlutterActivity() {
    private val CHANNEL = "security/developer_mode"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
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

        var securityMessage: String? = null

        // Developer Mode Detection  
        if (DeveloperModeChecker.isDeveloperModeEnabled(this)) {
            securityMessage = "Developer Mode is enabled. This app cannot run on devices with Developer Mode enabled."
        }

        // Tamper Detection
        if (!SecurityUtils.isAppSignatureValid(packageManager, packageName)) {
            securityMessage = "This app's integrity has been compromised. Please install a legitimate version from the Play Store."
        }

        // Emulator Detection
        if (EmulatorChecker.isEmulator()) {
            securityMessage = "This app cannot run on an emulator."
        }

        // Root Detector
        if (RootUtil.isDeviceRooted(this)) {
            securityMessage = "This device is rooted. For security reasons, this app cannot run on rooted devices."
        }

        // Overlay Detection
        if (OverlayDetector.isOverlayEnabled(this)) {
            securityMessage = "A screen overlay was detected. Please disable overlay apps before using this app."
        }

        // If any security threat is detected, pause the screen and show the alert
        securityMessage?.let {
            freezeAppUI() // Freeze the app's UI
            showSecurityDialog(it)
        }
    }

    // Function to freeze the app UI
    private fun freezeAppUI() {
        window.setFlags(
            WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
            WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
        )
    }

    private fun showSecurityDialog(message: String) {
    val alertDialog = AlertDialog.Builder(this)
        .setTitle("Security Alert")
        .setMessage(message)
        .setCancelable(false) // Prevents dismissal by tapping outside
        .setPositiveButton("Close App") { _: DialogInterface, _: Int ->
            // Clear all app data
            val activityManager = getSystemService(ACTIVITY_SERVICE) as android.app.ActivityManager
            activityManager.clearApplicationUserData()  // This wipes all app data
            // Close app
            finishAffinity()
        }
        .create()

        alertDialog.show()
    }
}
