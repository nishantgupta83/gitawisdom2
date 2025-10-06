import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.hub4apps.gitawisdom"
    compileSdk = 36  // Required by plugins (app_links, path_provider, etc) - backward compatible
   // ndkVersion = flutter.ndkVersion
    ndkVersion = "28.0.12674087"  // Updated for API 35 compatibility

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    signingConfigs {
        create("release") {
            // Use environment variables for secure signing
            // For local development, create android/keystore.properties with:
            // storeFile=path/to/keystore.jks
            // storePassword=your_store_password
            // keyAlias=your_key_alias
            // keyPassword=your_key_password
            val keystorePropertiesFile = rootProject.file("keystore.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(keystorePropertiesFile.inputStream())

                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String

                println("✅ Using keystore from keystore.properties")
            } else {
                // For CI/CD environments, use environment variables
                val keyAlias = System.getenv("ANDROID_KEY_ALIAS")
                val keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
                val keystorePath = System.getenv("ANDROID_KEYSTORE_PATH")
                val storePassword = System.getenv("ANDROID_STORE_PASSWORD")

                if (keyAlias != null && keyPassword != null && keystorePath != null && storePassword != null) {
                    this.keyAlias = keyAlias
                    this.keyPassword = keyPassword
                    this.storeFile = file(keystorePath)
                    this.storePassword = storePassword
                    println("✅ Using keystore from environment variables")
                } else {
                    println("⚠️ WARNING: No signing config found. Release builds will fail.")
                    println("   For debug builds, use: flutter run --debug")
                    println("   For release builds, create android/keystore.properties")
                }
            }
        }
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.hub4apps.gitawisdom"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.

        // Set explicit SDK versions for Google Play API 35 compliance
        // Android 5.0 (API 21) covers 99%+ of Indian market including older OPPO/Vivo devices
        minSdk = flutter.minSdkVersion  // Covers Android 5.0+ (99% Indian market coverage)
        targetSdk = 35  // Android 15 (API 35) - Required for Google Play compliance
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Enable multidex for better compatibility
        multiDexEnabled = true
        
        // Add comprehensive ABI filters for maximum device support
        // Covers all major chipsets used by OPPO, Vivo, OnePlus, Samsung, Xiaomi
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64", "x86")
        }
        
        // Add render script support for better graphics compatibility
        renderscriptTargetApi = 21
        renderscriptSupportModeEnabled = true
        
        // Vector drawable support for older devices
        vectorDrawables.useSupportLibrary = true
        
        // Resource configurations for Indian market
        resConfigs("en", "hi", "ta", "te", "gu", "mr", "kn", "ml", "bn", "pa", "or", "as")
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            
            // Enable ProGuard for device-specific optimizations
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        
        // Debug build for testing on various devices
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
            // Enable device-specific debugging
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-DEBUG"
        }
    }
    
    // Split APKs for better device targeting
    splits {
        abi {
            isEnable = true
            reset()
            include("arm64-v8a", "armeabi-v7a", "x86_64", "x86")
            isUniversalApk = true  // Also generate universal APK
        }
        
        density {
            isEnable = true
            reset()
            include("ldpi", "mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi")
            compatibleScreens("small", "normal", "large", "xlarge")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Multidex support for better compatibility
    implementation("androidx.multidex:multidex:2.0.1")
    // Core library desugaring for flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
