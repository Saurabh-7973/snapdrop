package com.saurabh7973.snapdrop

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val worker = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "snapdrop/image")
            .setMethodCallHandler { call, result ->
                if (call.method != "downscaleIfLarger") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val path = call.argument<String>("path")
                val maxEdge = call.argument<Int>("maxEdge") ?: 0
                val quality = call.argument<Int>("quality") ?: 95
                if (path == null || maxEdge <= 0) {
                    result.error("bad_args", "path and maxEdge are required", null)
                    return@setMethodCallHandler
                }
                worker.execute {
                    try {
                        val bytes = downscaleIfLarger(path, maxEdge, quality)
                        runOnUiThread { result.success(bytes) }
                    } catch (e: Throwable) {
                        runOnUiThread { result.error("downscale_failed", e.toString(), null) }
                    }
                }
            }
    }

    /**
     * Returns JPEG bytes no larger than [maxEdge] on the long side, or null when
     * the image already fits (the caller then sends the untouched original).
     * This is what photo_manager's thumbnailDataWithSize did for the old grid;
     * the Photo Picker hands back plain files, so the app does it itself.
     */
    private fun downscaleIfLarger(path: String, maxEdge: Int, quality: Int): ByteArray? {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, bounds)
        val w = bounds.outWidth
        val h = bounds.outHeight
        if (w <= 0 || h <= 0) return null
        val longEdge = maxOf(w, h)
        if (longEdge <= maxEdge) return null

        // Decode at the largest power-of-two step that still covers maxEdge,
        // so a 50 MP photo never sits in memory at full size.
        var sample = 1
        while (longEdge / (sample * 2) >= maxEdge) sample *= 2
        val decoded = BitmapFactory.decodeFile(
            path, BitmapFactory.Options().apply { inSampleSize = sample }
        ) ?: return null

        val scale = maxEdge.toFloat() / maxOf(decoded.width, decoded.height)
        val matrix = Matrix()
        if (scale < 1f) matrix.postScale(scale, scale)
        // Re-encoding drops EXIF, so bake the orientation into the pixels.
        when (ExifInterface(path).getAttributeInt(
            ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL
        )) {
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
        }
        val out = Bitmap.createBitmap(
            decoded, 0, 0, decoded.width, decoded.height, matrix, true
        )
        if (out !== decoded) decoded.recycle()

        val stream = ByteArrayOutputStream()
        out.compress(Bitmap.CompressFormat.JPEG, quality, stream)
        out.recycle()
        return stream.toByteArray()
    }
}
