import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import android.util.Base64
import android.util.Log
import java.security.MessageDigest

class SecurityUtils {
    companion object {
        private const val EXPECTED_SIGNATURE = "B8:06:6B:92:65:E9:E1:64:B8:A8:29:E1:A9:E6:FC:CB:4A:A4:23:BF:D1:30:56:53:CC:99:19:0E:08:C0:FD:9A"


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
