# Flutter specific proguard rules for GitaWisdom

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter Play Store Split Support
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Keep Dart classes
-keep class dart.** { *; }

# Keep Supabase classes
-keep class io.supabase.** { *; }
-keep class com.supabase.** { *; }

# Keep audio related classes
-keep class com.ryanheise.just_audio.** { *; }

# Keep Google Fonts classes
-keep class io.flutter.plugins.googlemaps.** { *; }

# Keep Hive classes
-keep class io.flutter.plugins.hive.** { *; }

# General Android compatibility
-dontwarn java.lang.invoke.**
-dontwarn **$$serializer
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom application class
-keep public class * extends android.app.Application

# Network security
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# AndroidX and Support libraries
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**