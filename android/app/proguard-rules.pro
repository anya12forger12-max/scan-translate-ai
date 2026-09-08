# Flutter / Firebase release rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-dontwarn com.google.firebase.**
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Google ML Kit
-dontwarn com.google.mlkit.**
-keep class com.google.mlkit.** { *; }

# Google Play Core (split install / deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }

# Gson/reflection models
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep source file names and line numbers for crashes
-keepattributes SourceFile,LineNumberTable