import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import java.security.MessageDigest

class SecurityUtils {
    companion object {
        // 🔒 Replace this with your **SHA-256** fingerprint (from Play Console)
        private const val EXPECTED_SIGNATURE = "3A:72:93:F2:13:B4:42:B3:4D:03:D8:39:05:54:14:14:AA:80:6B:5E:7F:55:84:E7:94:D1:0B:90:C1:A7:21:CA"

        fun isAppSignatureValid(packageManager: PackageManager, packageName: String): Boolean {
            return try {
                val packageInfo: PackageInfo =
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES)
                    } else {
                        @Suppress("DEPRECATION")
                        packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
                    }

                val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    packageInfo.signingInfo?.apkContentsSigners
                } else {
                    @Suppress("DEPRECATION")
                    packageInfo.signatures
                }

                signatures?.let { sigs ->
                    for (signature in sigs) {
                        val sha256Fingerprint = getSha256Fingerprint(signature.toByteArray())

                        Log.d("TamperCheck", "Calculated SHA-256: $sha256Fingerprint")
                        Log.d("TamperCheck", "Expected SHA-256: $EXPECTED_SIGNATURE")

                        if (sha256Fingerprint.equals(EXPECTED_SIGNATURE, ignoreCase = true)) {
                            return true // ✅ App is genuine
                        }
                    }
                }

                false // ❌ Tampered APK detected
            } catch (e: Exception) {
                Log.e("TamperCheck", "Error checking app signature", e)
                false
            }
        }

        // 🔥 Converts SHA-256 to Hex String (Fixing Base64 issue)
        private fun getSha256Fingerprint(signature: ByteArray): String {
            val md = MessageDigest.getInstance("SHA-256")
            val digest = md.digest(signature)
            return digest.joinToString(":") { "%02X".format(it) } // Convert bytes to Hex
        }
    }
}
