package com.saurabh7973.snapdrop

import android.os.Build
import android.util.Log

object EmulatorChecker {
    fun isEmulator(): Boolean {
        val result = Build.FINGERPRINT.lowercase().startsWith("generic") ||
                Build.FINGERPRINT.lowercase().startsWith("unknown") ||
                Build.MODEL.lowercase().contains("google_sdk") ||
                Build.MODEL.lowercase().contains("emulator") ||
                Build.MODEL.lowercase().contains("android sdk built for x86") ||
                Build.MODEL.equals("nexus player", ignoreCase = true) ||
                Build.MANUFACTURER.lowercase().contains("genymotion") ||
                Build.MANUFACTURER.lowercase().contains("unknown") ||
                Build.DEVICE.lowercase().contains("generic") ||
                Build.DEVICE.equals("fugu", ignoreCase = true) ||
                Build.BRAND.lowercase().startsWith("generic") ||
                Build.PRODUCT.equals("google_sdk", ignoreCase = true) ||
                Build.PRODUCT.equals("sdk", ignoreCase = true) ||
                Build.PRODUCT.equals("fugu", ignoreCase = true) ||
                Build.HARDWARE.lowercase().contains("goldfish") ||
                Build.HARDWARE.lowercase().contains("ranchu") ||
                Build.HARDWARE.lowercase().contains("vbox86") ||
                Build.HARDWARE.lowercase().contains("vbox_x86")

        Log.d("EmulatorCheck", "Emulator detected: $result")
        return result
    }
}
