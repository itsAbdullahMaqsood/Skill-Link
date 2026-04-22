import java.io.FileInputStream
import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load `GOOGLE_MAPS_API_KEY` from `android/local.properties` (gitignored)
// so the key never lands in version control. AndroidManifest.xml picks it
// up via the `${MAPS_API_KEY}` manifest placeholder declared below.
val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) FileInputStream(f).use(::load)
}
val mapsApiKey: String = localProps.getProperty("GOOGLE_MAPS_API_KEY", "")

android {
    namespace = "com.example.skilllink"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications (used by SkillLink labour-side) requires
        // Java 8+ APIs available via core library desugaring.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.skilllink"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true

        // Exposes the key to AndroidManifest.xml as ${MAPS_API_KEY}.
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    signingConfigs {
        create("release") {
            storeFile = file("new_app_keystore.jks")
            storePassword = "909090"
            keyAlias = "skilllink_key"
            keyPassword = "909090"
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }

    // `adb install` (used by `flutter run`) prints no progress until the full APK
    // is pushed, so the CLI timer looks frozen during long installs. Debug APKs are
    // dominated by `kernel_blob.bin` (JIT). Dropping the optional Vulkan validation
    // layer trims install size a bit; for much smaller ARM-only builds on a real
    // phone use: `flutter run --target-platform=android-arm64` (add `,android-arm`
    // if you need 32-bit ARM).
    packaging {
        jniLibs {
            excludes += "**/libVkLayer_khronos_validation.so"
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
