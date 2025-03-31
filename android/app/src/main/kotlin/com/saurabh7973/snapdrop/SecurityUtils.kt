import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import android.util.Base64
import android.util.Log
import java.security.MessageDigest

class SecurityUtils {
    companion object {
        private const val EXPECTED_SIGNATURE = "3A:72:93:F2:13:B4:42:B3:4D:03:D8:39:05:54:14:14:AA:80:6B:5E:7F:55:84:E7:94:D1:0B:90:C1:A7:21:CA" // Replace with your actual signature

        fun isAppSignatureValid(packageManager: PackageManager, packageName: String): Boolean {
            return try {
                val packageInfo: PackageInfo =
                    packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES)

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    packageInfo.signingInfo?.apkContentsSigners?.let { signatures ->
                        for (signature in signatures) {
                            val md = MessageDigest.getInstance("SHA")
                            md.update(signature.toByteArray())
                            val currentSignature = Base64.encodeToString(md.digest(), Base64.DEFAULT).trim()

                            if (EXPECTED_SIGNATURE == currentSignature) {
                                return true // ✅ App is genuine
                            }
                        }
                    }
                } else {
                    @Suppress("DEPRECATION")
                    packageInfo.signatures?.let { signatures ->
                        for (signature in signatures) {
                            val md = MessageDigest.getInstance("SHA")
                            md.update(signature.toByteArray())
                            val currentSignature = Base64.encodeToString(md.digest(), Base64.DEFAULT).trim()

                            if (EXPECTED_SIGNATURE == currentSignature) {
                                return true // ✅ App is genuine
                            }
                        }
                    }
                }

                false // ❌ Tampered APK detected
            } catch (e: Exception) {
                Log.e("TamperCheck", "Error checking app signature", e)
                false
            }
        }
    }
}
