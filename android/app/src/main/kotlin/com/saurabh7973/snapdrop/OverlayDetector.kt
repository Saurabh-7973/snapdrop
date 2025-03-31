import android.content.Context
import android.provider.Settings
import android.util.Log

object OverlayDetector {
    fun isOverlayEnabled(context: Context): Boolean {
        return Settings.canDrawOverlays(context).also { canDraw ->
            if (canDraw) Log.e("Security", "Overlay detected! Potential Tapjacking.")
        }
    }
}
