package com.saurabh7973.snapdrop

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader

object RootUtil {

    fun isDeviceRooted(context: Context): Boolean {
        return checkRootMethod1() || checkRootMethod2() || checkRootMethod3() || hasRootManagerSystemApp(context)
    }

    // Check if build tags contain "test-keys"
    private fun checkRootMethod1(): Boolean {
        return Build.TAGS?.contains("test-keys") == true
    }

    // Check common root paths
    private fun checkRootMethod2(): Boolean {
        val paths = arrayOf(
            "/system/xbin/su",
            "/system/bin/su",
            "/system/xbin/busybox",
            "/system/bin/busybox",
            "/system/app/Superuser.apk",
            "/system/app/SuperSu.apk",
            "/system/etc/init.d/99SuperSUDaemon"
        )
        return paths.any { File(it).exists() }
    }

    // Try executing "su" command
    private fun checkRootMethod3(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec("su")
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            reader.readLine() != null
        } catch (e: Exception) {
            false
        }
    }

    // Detect root manager apps
    private fun hasRootManagerSystemApp(context: Context): Boolean {
        val rootApps = listOf(
            "com.noshufou.android.su",
            "com.noshufou.android.su.elite",
            "eu.chainfire.supersu",
            "com.koushikdutta.superuser",
            "com.thirdparty.superuser",
            "com.yellowes.su",
            "com.koushikdutta.rommanager",
            "com.koushikdutta.rommanager.license",
            "com.dimonvideo.luckypatcher",
            "com.chelpus.lackypatch",
            "com.ramdroid.appquarantine",
            "com.ramdroid.appquarantinepro",
            "com.devadvance.rootcloak",
            "com.devadvance.rootcloakplus",
            "de.robv.android.xposed.installer",
            "com.saurik.substrate",
            "com.zachspong.temprootremovejb",
            "com.amphoras.hidemyroot",
            "com.amphoras.hidemyrootadfree",
            "com.formyhm.hiderootPremium",
            "com.formyhm.hideroot",
            "me.phh.superuser",
            "eu.chainfire.supersu.pro",
            "com.topjohnwu.magisk"
        )

        return rootApps.any {
            try {
                context.packageManager.getApplicationInfo(it, 0)
                true
            } catch (e: PackageManager.NameNotFoundException) {
                false
            }
        }
    }
}
