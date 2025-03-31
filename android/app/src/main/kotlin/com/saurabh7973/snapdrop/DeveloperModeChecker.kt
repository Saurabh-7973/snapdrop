package com.saurabh7973.snapdrop

import android.provider.Settings
import android.content.Context

object DeveloperModeChecker {
    fun isDeveloperModeEnabled(context: Context): Boolean {
        return Settings.Secure.getInt(
            context.contentResolver,
            Settings.Secure.DEVELOPMENT_SETTINGS_ENABLED,
            0
        ) != 0
    }
}
