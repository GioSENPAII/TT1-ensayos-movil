import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "mx.ipn.escom.tt.ensayos_movil"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // Llave de firma del APK publicado: TT1/llaves/key.properties (fuera de git; respaldo en Secret
    // Manager: ensayos-apk-keystore y ensayos-apk-key-properties). Sin ella se firma con la de depuración.
    val llave = rootProject.file("../../llaves/key.properties")
    val propsLlave = Properties().apply { if (llave.exists()) llave.inputStream().use { load(it) } }
    signingConfigs {
        if (llave.exists()) {
            create("release") {
                storeFile = file(propsLlave.getProperty("storeFile"))
                storePassword = propsLlave.getProperty("storePassword")
                keyAlias = propsLlave.getProperty("keyAlias")
                keyPassword = propsLlave.getProperty("keyPassword")
            }
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "mx.ipn.escom.tt.ensayos_movil"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
