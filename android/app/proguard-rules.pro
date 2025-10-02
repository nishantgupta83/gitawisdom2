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

# ============================================
# Device-Specific Compatibility Rules
# For OPPO, Vivo, OnePlus, Samsung, Xiaomi
# ============================================

# ColorOS (OPPO) specific - Prevents crashes on OPPO devices
-dontwarn com.oppo.**
-dontwarn com.color.**
-keep class com.oppo.** { *; }
-keep class com.color.** { *; }
-keep class com.heytap.** { *; }

# FuntouchOS (Vivo) specific - Ensures compatibility with Vivo ROMs
-dontwarn com.vivo.**
-dontwarn com.bbk.**
-keep class com.vivo.** { *; }
-keep class com.bbk.** { *; }
-keep class com.iqoo.** { *; }

# OxygenOS (OnePlus) specific - OnePlus optimizations
-dontwarn com.oneplus.**
-dontwarn net.oneplus.**
-keep class com.oneplus.** { *; }
-keep class net.oneplus.** { *; }
-keep class com.oplus.** { *; }

# MIUI (Xiaomi/Redmi) specific - Xiaomi/Redmi compatibility
-dontwarn com.xiaomi.**
-dontwarn com.miui.**
-keep class com.xiaomi.** { *; }
-keep class com.miui.** { *; }
-keep class miui.** { *; }

# Samsung OneUI specific - Samsung device support
-dontwarn com.samsung.**
-dontwarn com.sec.**
-keep class com.samsung.** { *; }
-keep class com.sec.** { *; }

# Realme UI specific
-dontwarn com.realme.**
-keep class com.realme.** { *; }

# ============================================
# Performance Optimizations for Indian Market
# ============================================

# Multidex support for budget devices
-keep class androidx.multidex.** { *; }
-keep class com.android.support.multidex.** { *; }

# Memory optimization for 4GB RAM devices
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses

# Keep critical UI components for high refresh displays
-keep class android.view.** { *; }
-keep class android.widget.** { *; }

# 5G network optimization
-keep class android.net.** { *; }
-keep class android.telephony.** { *; }

# ============================================
# TensorFlow Lite Support - Fix R8 Build Issues
# ============================================

# Keep TensorFlow Lite classes
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.**

# Keep TensorFlow Lite GPU delegate factory
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }

# Keep TensorFlow Lite interpreter and related classes
-keep class org.tensorflow.lite.Interpreter { *; }
-keep class org.tensorflow.lite.Tensor { *; }
-keep class org.tensorflow.lite.DataType { *; }

# Keep machine learning related classes
-dontwarn com.google.android.gms.tflite.**
-keep class com.google.android.gms.tflite.** { *; }