// Top-level Gradle config (android/build.gradle.kts)

buildscript {
  repositories {
    google()
    mavenCentral()
  }
  dependencies {
    // Android Gradle Plugin
    classpath("com.android.tools.build:gradle:8.0.2")
    // Kotlin support
    classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.20")
    // Google Services plugin (Firebase)
    classpath("com.google.gms:google-services:4.3.15")
  }
}

// ─── Inject a namespace into any Android library modules that don't have one ───
subprojects {
  afterEvaluate {
    if (plugins.hasPlugin("com.android.library")) {
      val libExt = extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
      if (libExt != null && libExt.namespace.isNullOrEmpty()) {
        // Read the app module’s applicationId
        val appExt = rootProject
          .project(":app")
          .extensions
          .getByType(com.android.build.gradle.AppExtension::class.java)
        libExt.namespace = appExt.defaultConfig.applicationId
      }
    }
  }
}
// ────────────────────────────────────────────────────────────────────────────────

allprojects {
  repositories {
    google()
    mavenCentral()
  }
}

tasks.register<Delete>("clean") {
  delete(rootProject.buildDir)
}
