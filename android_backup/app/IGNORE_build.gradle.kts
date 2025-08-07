// Module-level Gradle config (android/app/build.gradle.kts)

plugins {
  id("com.android.application")
  kotlin("android")
  id("com.google.gms.google-services")
}

android {
  namespace = "com.example.oldwisdom"       // ← your real package
  compileSdk = 35                            // highest API you want to compile against
  ndkVersion = "27.0.12077973"               // plugins expect NDK 27

  defaultConfig {
    applicationId = "com.example.oldwisdom"
    minSdk = 21
    targetSdk = 35
    versionCode = 1
    versionName = "1.0"
  }

  buildTypes {
    getByName("debug") { /* debug settings, if any */ }
    getByName("release") {
      isMinifyEnabled = false
      // proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
    }
  }

  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
  }
  kotlinOptions {
    jvmTarget = "11"
  }
}

dependencies {
  implementation("androidx.core:core-ktx:1.9.0")
  implementation("androidx.appcompat:appcompat:1.6.1")
  implementation("com.google.android.material:material:1.8.0")
  // All your Flutter plugins are brought in automatically by Flutter;
  // you don’t need to list io.supabase:supabase_flutter or com.google.firebase:… here.
}
