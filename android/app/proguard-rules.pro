# ==============================================================================
# ProGuard / R8 Optimization & Obfuscation Rules for Smart Somiti
# Reduces APK size while protecting Flutter, WebView, and Firebase runtimes
# ==============================================================================

# Flutter core & framework
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Keep JavaScript Interface & WebView bridge methods
-keepattributes JavascriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class android.webkit.** { *; }
-keep class androidx.webkit.** { *; }
-keep class io.flutter.plugins.webviewflutter.** { *; }

# Google Sign-In, Credentials, and Play Services
-keep class com.google.android.gms.auth.api.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class io.flutter.plugins.googlesignin.** { *; }

# Firebase Core, Auth, and Firestore
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Permissions & Image Picker plugins
-keep class com.baseflow.permissionhandler.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }

# Application & MainActivity
-keep class com.example.cloud_sync_drive.** { *; }
-keep class androidx.multidex.** { *; }

# Preserve type signatures and annotations for reflection
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod,Exceptions

# Suppress harmless warnings from dependencies
-dontwarn javax.annotation.**
-dontwarn java.lang.invoke.**
