# Snapdrop R8/ProGuard keep-rules (release minify is on).
# socket_io_client is pure Dart — no native/reflection rule needed.

# ---- Flutter engine (standard) ----
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ---- Firebase: Analytics / Crashlytics / Performance ----
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Crashlytics: keep source-file + line-number info so stack traces stay readable.
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# ---- photo_manager (native plugin via platform channels + reflection) ----
-keep class com.fluttercandies.photo_manager.** { *; }
-dontwarn com.fluttercandies.photo_manager.**

# ---- General: keep annotations + native methods ----
-keepattributes *Annotation*
-keepclasseswithmembernames class * {
    native <methods>;
}
