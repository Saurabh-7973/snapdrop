# Snapdrop R8/ProGuard keep-rules (release minify is on).
# socket_io_client is pure Dart — no native/reflection rule needed.

# Flutter (embedding + plugins) and Firebase/Play services ship their own
# consumer R8 rules. Blanket `-keep class io.flutter.** / com.google.firebase.**
# / com.google.android.gms.** { *; }` here kept them all unobfuscated and
# unshrunk — Play flagged a 37% obfuscation rate. Only warnings stay muted.
-dontwarn io.flutter.embedding.**
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Crashlytics: keep source-file + line-number info so stack traces stay readable.
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# ---- qr_code_scanner_plus (ships no consumer rules) + its zxing deps ----
-keep class net.touchcapture.qr.flutterqrplus.** { *; }
-keep class com.journeyapps.barcodescanner.** { *; }
-keep class com.google.zxing.** { *; }
-dontwarn com.journeyapps.barcodescanner.**
-dontwarn com.google.zxing.**

# ---- General: keep annotations + native methods ----
-keepattributes *Annotation*
-keepclasseswithmembernames class * {
    native <methods>;
}
